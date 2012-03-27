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
<cfcomponent output="false" extends="authentication">

	<cffunction name="gethosts" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset thesession = checkdb(arguments.api_key)>
		<!--- If ISP --->
		<cfif application.razuna.api.isp>
			<cfset thesession = false>
		</cfif>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!---
<!--- Query for the sysadmingroup --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qryuser">
			SELECT groupofuser
			FROM webservices
			WHERE api_key = <cfqueryparam value="#arguments.api_key#" cfsqltype="cf_sql_varchar">
			AND groupofuser IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="1" list="true">)
			</cfquery>
			<!--- If user is in sysadmin --->
			<cfif qryuser.recordcount NEQ 0>
--->
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT host_id, host_name, host_path, host_db_prefix, host_shard_group
				FROM hosts
				</cfquery>
			<!--- User not systemadmin --->
			<!---
<cfelse>
				<cfset thexml.responsecode = 1>
				<cfset thexml.message = "User is not a System Administrator">
			</cfif>
--->
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
</cfcomponent>