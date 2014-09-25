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
<cfcomponent output="false" namespace="group" extends="authentication">

	<!--- Get group --->
	<cffunction name="getone" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="grp_id" required="true" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query the group --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT grp_id, grp_name
				FROM groups
				WHERE grp_id = <cfqueryparam value="#arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR">
				AND grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
				</cfquery>
				<!--- If group does not exist do the insert --->
				<cfif qry.recordcount EQ 0>
					<cfset thexml = querynew("responsecode,message")>
					<cfset queryaddrow(thexml,1)>
					<cfset querysetcell(thexml,"responsecode","1")>
					<cfset querysetcell(thexml,"message","Group with the ID could not be found")>
				</cfif>
			<!--- User not admin --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- Get all groups --->
	<cffunction name="getall" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query the group --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT grp_id, grp_name
				FROM groups
				WHERE grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
				</cfquery>
				<!--- If group does not exist do the insert --->
				<cfif qry.recordcount EQ 0>
					<cfset thexml = querynew("responsecode,message")>
					<cfset queryaddrow(thexml,1)>
					<cfset querysetcell(thexml,"responsecode","1")>
					<cfset querysetcell(thexml,"message","Group(s) with the ID could not be found")>
				</cfif>
			<!--- User not systemadmin --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- Get Users of group --->
	<cffunction name="getusersofgroups" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="grp_id" required="true" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query the group --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT u.user_id, u.user_first_name, u.user_last_name, u.user_email
				FROM users u, ct_users_hosts ct
				WHERE EXISTS(
					SELECT ctg.ct_g_u_user_id
					FROM ct_groups_users ctg INNER JOIN groups g ON ctg.ct_g_u_grp_id = g.grp_id
					WHERE(
						g.grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
						OR g.grp_host_id IS NULL
					)
					AND g.grp_id IN (<cfqueryparam value="#arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR" list="true">)
					AND ctg.ct_g_u_user_id = u.user_id
				)
				AND ct.ct_u_h_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
				AND u.user_id = ct.ct_u_h_user_id
				</cfquery>
				<!--- If user does not exist do the insert --->
				<cfif qry.recordcount EQ 0>
					<cfset thexml = querynew("responsecode,message")>
					<cfset queryaddrow(thexml,1)>
					<cfset querysetcell(thexml,"responsecode","1")>
					<cfset querysetcell(thexml,"message","Group(s) with the ID could not be found")>
				</cfif>
			<!--- User not systemadmin --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Add the group --->
	<cffunction name="add" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="grp_name" required="true" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Check that we don't have the same grou name already --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry_samegrp">
				SELECT grp_id
				FROM groups
				WHERE lower(grp_name) = <cfqueryparam value="#lcase(arguments.grp_name)#" cfsqltype="CF_SQL_VARCHAR">
				AND grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
				</cfquery>
				<!--- If group does not exist do the insert --->
				<cfif qry_samegrp.recordcount EQ 0>
					<!--- Create new ID --->
					<cfset newgrpid = createuuid()>
					<!--- Insert the group into the DB --->
					<cfquery datasource="#application.razuna.api.dsn#">
					INSERT INTO	groups
					(grp_id, grp_name, grp_host_id, grp_mod_id)
					VALUES(
					<cfqueryparam value="#newgrpid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.grp_name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="1" cfsqltype="cf_sql_numeric">
					)
					</cfquery>
					<!--- Response --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Group has been added successfully">
					<cfset thexml.grp_id = newgrpid>
				<!--- group exist thus fail message --->
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "Group already exists">
					<cfset thexml.grp_id = qry_samegrp.grp_id>
				</cfif>
			<!--- User not systemadmin --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- Update group --->
	<cffunction name="update" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="grp_name" required="true" type="string">
		<cfargument name="grp_id" required="true" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query the group --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT grp_id
				FROM groups
				WHERE grp_id = <cfqueryparam value="#arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR">
				AND grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
				</cfquery>
				<!--- group found --->
				<cfif qry.recordcount EQ 1>
					<cfquery datasource="#application.razuna.api.dsn#">
					UPDATE groups
					SET grp_name = <cfqueryparam value="#arguments.grp_name#" cfsqltype="CF_SQL_VARCHAR">
					WHERE grp_id = <cfqueryparam value="#arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR">
					AND grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
					</cfquery>
					<!--- Response --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Group has been updated successfully">
					<cfset thexml.grp_id = qry.grp_id>
				<!--- NOT found --->
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "Group with the ID could not be found">
				</cfif>
			<!--- User not systemadmin --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Delete group --->
	<cffunction name="delete" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="grp_id" required="true" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT grp_id
				FROM groups
				WHERE grp_id = <cfqueryparam value="#arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR">
				AND grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
				AND (grp_id <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR"> OR grp_id <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="2" cfsqltype="CF_SQL_VARCHAR">)
				</cfquery>
				<!--- group found --->
				<cfif qry.recordcount EQ 1>
					<cfquery datasource="#application.razuna.api.dsn#">
					DELETE FROM groups
					WHERE grp_id = <cfqueryparam value="#arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR">
					AND grp_host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric">
					</cfquery>
					<!--- Response --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Group has been removed successfully">
					<cfset thexml.grp_id = qry.grp_id>
				<!--- NOT found --->
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "Group with the ID could not be found">
				</cfif>
			<!--- User not systemadmin --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
			<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
		
</cfcomponent>