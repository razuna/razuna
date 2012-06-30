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
<cfcomponent output="false" namespace="user" extends="authentication">
	
	<!--- Add the user --->
	<cffunction name="add" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="user_first_name" type="string" required="true">
		<cfargument name="user_last_name" type="string" required="true">
		<cfargument name="user_email" type="string" required="true">
		<cfargument name="user_name" type="string" required="true">
		<cfargument name="user_pass" type="string" required="true">
		<cfargument name="user_active" type="string" required="false" default="f">
		<cfargument name="groupid" type="string" required="false" default="0">
		<!--- Check key --->
		<cfset thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Check that we don't have the same user --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry_sameuser">
			SELECT users.user_email, users.user_login_name, user_id
			FROM users, ct_users_hosts
			WHERE (
				lower(users.user_email) = <cfqueryparam value="#lcase(arguments.user_email)#" cfsqltype="cf_sql_varchar">
				OR lower(users.user_login_name) = <cfqueryparam value="#lcase(arguments.user_name)#" cfsqltype="cf_sql_varchar">
				)
			AND ct_users_hosts.ct_u_h_host_id = #application.razuna.api.hostid["#arguments.api_key#"]#
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
				#application.razuna.api.hostid["#arguments.api_key#"]#,
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
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "User has been added successfully">
				<cfset thexml.userid = newuserid>
			<!--- User exist thus fail message --->
			<cfelse>
				<cfset thexml.responsecode = 1>
				<cfset thexml.message = "User already exists">
				<cfset thexml.userid = qry_sameuser.user_id>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" type="s" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- Get this user information --->
	<cffunction name="getuser" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query the user --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
			SELECT user_id, user_login_name, user_email, user_first_name, user_last_name
			FROM users
			WHERE user_id = <cfqueryparam value="#application.razuna.api.userid["#arguments.api_key#"]#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- If user does not exist do the insert --->
			<cfif qry.recordcount EQ 0>
				<cfset thexml = querynew("responsecode,message")>
				<cfset queryaddrow(thexml,1)>
				<cfset querysetcell(thexml,"responsecode","1")>
				<cfset querysetcell(thexml,"message","User with the ID could not be found")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Update user --->
	<cffunction name="update" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="userid" required="false" type="string" default="">
		<cfargument name="userloginname" required="false" type="string" default="">
		<cfargument name="useremail" required="false" type="string" default="">
		<cfargument name="userdata" required="true" type="string" hint="JSON with fields to update">
		<!--- Check key --->
		<cfset thesession = checkdb(arguments.api_key)>
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
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "User has been updated successfully">
				<cfset thexml.userid = qry.user_id>
			<!--- NOT found --->
			<cfelse>
				<cfset thexml.responsecode = 1>
				<cfset thexml.message = "User with the ID could not be found">
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" type="s" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Delete user --->
	<cffunction name="delete" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="userid" required="false" type="string" default="">
		<cfargument name="userloginname" required="false" type="string" default="">
		<cfargument name="useremail" required="false" type="string" default="">
		<!--- Check key --->
		<cfset thesession = checkdb(arguments.api_key)>
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
				DELETE FROM #application.razuna.api.prefix["#arguments.api_key#"]#cart
				WHERE user_id = <cfqueryparam value="#qry.user_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
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
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "User has been removed successfully">
				<cfset thexml.userid = qry.user_id>
			<!--- NOT found --->
			<cfelse>
				<cfset thexml.responsecode = 1>
				<cfset thexml.message = "User with the ID could not be found">
			</cfif>
			<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" type="s" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
		
</cfcomponent>