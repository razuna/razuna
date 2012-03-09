<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false" namespace="user">
	
	<!--- Add the user --->
	<cffunction name="add" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="user_first_name" type="string">
		<cfargument name="user_last_name" type="string">
		<cfargument name="user_email" type="string">
		<cfargument name="user_name" type="string">
		<cfargument name="user_pass" type="string">
		<cfargument name="user_active" type="string">
		<cfargument name="groupid" type="string">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
		<!--- Query for the sysadmingroup --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qryuser">
		SELECT groupofuser
		FROM webservices
		WHERE sessiontoken = <cfqueryparam value="#arguments.sessiontoken#" cfsqltype="cf_sql_varchar">
		AND groupofuser IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="1,2" list="true">)
		</cfquery>
		<!--- If user is in sysadmin --->
		<cfif qryuser.recordcount NEQ 0>
			<!--- Check that we don't have the same user --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry_sameuser">
			SELECT users.user_email, users.user_login_name, user_id
			FROM users, ct_users_hosts
			WHERE (
				lower(users.user_email) = <cfqueryparam value="#lcase(arguments.user_email)#" cfsqltype="cf_sql_varchar">
				OR lower(users.user_login_name) = <cfqueryparam value="#lcase(arguments.user_name)#" cfsqltype="cf_sql_varchar">
				)
			AND ct_users_hosts.ct_u_h_host_id = #application.razuna.api.hostid["#arguments.sessiontoken#"]#
			</cfquery>
			<!--- If user does not exist do the insert --->
			<cfif qry_sameuser.recordcount EQ 0>
				<!--- Create new ID --->
				<cfset newuserid = createuuid()>
				<!--- Hash Password --->
				<cfset thepass = hash(arguments.user_pass, "MD5", "UTF-8")>
				<!--- Insert the User into the DB --->
				<cfquery datasource="#application.razuna.api.dsn#">
				INSERT INTO users
				(user_id, user_login_name, user_email, user_pass, user_first_name, user_last_name, user_in_admin,
				user_create_date, user_active, user_in_dam)
				VALUES(
				<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.user_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.user_email#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.user_first_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.user_last_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#arguments.user_active#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="T" cfsqltype="cf_sql_varchar">
				)
				</cfquery>
				<!--- Insert the user to the user host cross table --->
				<cfquery datasource="#application.razuna.api.dsn#">
				INSERT INTO ct_users_hosts
				(ct_u_h_user_id, ct_u_h_host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">,
				#application.razuna.api.hostid["#arguments.sessiontoken#"]#,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Insert into group --->
				<cfif arguments.groupid NEQ 0>
					<cfquery datasource="#application.razuna.api.dsn#">
					INSERT INTO	ct_groups_users
					(ct_g_u_grp_id, ct_g_u_user_id, rec_uuid)
					VALUES(
					<cfqueryparam value="#arguments.groupid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#newuserid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">
					)
					</cfquery>
				</cfif>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>User has been added successfully</message>
<userid>#xmlformat(newuserid)#</userid>
</Response></cfoutput>
				</cfsavecontent>
			<!--- User exist thus fail message --->
			<cfelse>
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>User already exists</message>
<userid>#xmlformat(qry_sameuser.user_id)#</userid>
</Response></cfoutput>
				</cfsavecontent>
			</cfif>
		<!--- User not systemadmin --->
		<cfelse>
			<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>User is not a System Administrator</message>
</Response></cfoutput>
			</cfsavecontent>
		</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- Get this user information --->
	<cffunction name="getuser" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query the user --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT user_login_name, user_email, user_first_name, user_last_name
			FROM users
			WHERE user_id = <cfqueryparam value="#application.razuna.api.userid["#arguments.sessiontoken#"]#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- If user does not exist do the insert --->
			<cfif qry.recordcount NEQ 0>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<userid>#application.razuna.api.userid["#arguments.sessiontoken#"]#</userid>
<loginname>#xmlformat(qry.user_login_name)#</loginname>
<email>#xmlformat(qry.user_email)#</email>
<firstname>#xmlformat(qry.user_first_name)#</firstname>
<lastname>#xmlformat(qry.user_last_name)#</lastname>
</Response></cfoutput>
				</cfsavecontent>
			<!--- User not found --->
			<cfelse>
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>User with the ID could not be found</message>
</Response></cfoutput>
				</cfsavecontent>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Update user --->
	<cffunction name="update" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="userid" required="true">
		<cfargument name="userloginname" required="true">
		<cfargument name="useremail" required="true">
		<cfargument name="userdata" required="true" hint="JSON with fields to update">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query the user --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT user_id
			FROM users
			<cfif arguments.userid NEQ "">
				WHERE user_id = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_VARCHAR">
			<cfelseif arguments.userloginname NEQ "">
				WHERE lower(user_login_name) = <cfqueryparam value="#lcase(arguments.userloginname)#" cfsqltype="CF_SQL_VARCHAR">
			<cfelseif arguments.useremail NEQ "">
				WHERE lower(user_email) = <cfqueryparam value="#lcase(arguments.useremail)#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				WHERE user_email = <cfqueryparam value="nada" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			</cfquery>
			<!--- User found --->
			<cfif qry.recordcount EQ 1>
				<!--- deserializeJSON back into array --->
				<cfset var thejson = DeserializeJSON(arguments.userdata)>
				<cfset var l = "">
				<!--- Loop over JSON and update data --->
				<cfloop index="x" from="1" to="#arrayLen(thejson)#">
					<cfset l = l & "," & #thejson[x][1]#>
					<!--- Just user fields --->
					<cfif #thejson[x][1]# CONTAINS "user_">
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE users
						SET #thejson[x][1]# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thejson[x][2]#">
						WHERE user_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.user_id#">
						</cfquery>
					</cfif>
				</cfloop>
				<!--- Do the group update --->
				<!--- Does a key exists --->
				<cfif listcontains(l,"group_id") NEQ 0>
					<!--- There is a group_id remove all existing groups --->
					<cfquery datasource="#application.razuna.api.dsn#">
					DELETE FROM ct_groups_users
					WHERE ct_g_u_user_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.user_id#">
					</cfquery>
					<!--- Loop over json and insert group --->
					<cfloop index="x" from="1" to="#arrayLen(thejson)#">
						<!--- Just user fields --->
						<cfif #thejson[x][1]# CONTAINS "group_id">
							<cfquery datasource="#application.razuna.api.dsn#">
							INSERT INTO ct_groups_users
							(ct_g_u_grp_id, ct_g_u_user_id, rec_uuid)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thejson[x][2]#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.user_id#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
							)
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>User has been updated successfully</message>
<userid>#xmlformat(qry.user_id)#</userid>
</Response></cfoutput>
				</cfsavecontent>
			<!--- NOT found --->
			<cfelse>
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>User with the ID could not be found</message>
</Response></cfoutput>
				</cfsavecontent>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Delete user --->
	<cffunction name="delete" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="userid" required="true">
		<cfargument name="userloginname" required="true">
		<cfargument name="useremail" required="true">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query the user --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT user_id
			FROM users
			<cfif arguments.userid NEQ "">
				WHERE user_id = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_VARCHAR">
			<cfelseif arguments.userloginname NEQ "">
				WHERE lower(user_login_name) = <cfqueryparam value="#lcase(arguments.userloginname)#" cfsqltype="CF_SQL_VARCHAR">
			<cfelseif arguments.useremail NEQ "">
				WHERE lower(user_email) = <cfqueryparam value="#lcase(arguments.useremail)#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				WHERE user_email = <cfqueryparam value="nada" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			</cfquery>
			<!--- User found --->
			<cfif qry.recordcount EQ 1>
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM ct_users_hosts
				WHERE ct_u_h_user_id = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<!--- Remove Intra/extranet carts  --->
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#cart
				WHERE user_id = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
				<!--- Remove user comments  --->
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM users_comments
				WHERE user_id_r = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<!--- Remove from the User Table --->
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM users
				WHERE user_id = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>User has been removed successfully</message>
<userid>#xmlformat(qry.user_id)#</userid>
</Response></cfoutput>
				</cfsavecontent>
			<!--- NOT found --->
			<cfelse>
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>User with the ID could not be found</message>
</Response></cfoutput>
				</cfsavecontent>
			</cfif>
			<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
		
</cfcomponent>