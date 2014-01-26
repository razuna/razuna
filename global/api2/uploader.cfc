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
<cfcomponent output="true" extends="authentication">

	<cffunction name="checkLogin" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset var s = structnew()>
		<cfset s.login = checkDesktop(arguments.api_key).login>
		<cfset s.hostid = checkDesktop(arguments.api_key).hostid>
		<cfset s.grpid = checkDesktop(arguments.api_key).grpid>
		<!--- Return --->
		<cfreturn s>
	</cffunction>

	<cffunction name="getFolders" access="remote" output="true" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="thelist" required="false" default="" hint="list of parent folder-ids">
		<!--- Create struct --->
		<cfset var s = structnew()>
		<cfset var qry = "">
		<!--- Lets make sure the API key is still valid --->
		<cfset var login = checkDesktop(arguments.api_key)>
		<!--- Ok user is in --->
		<cfif login>
			<cfset var hostid = checkDesktop(arguments.api_key).hostid>
			<cfset var grpid = checkDesktop(arguments.api_key).grpid>
			<cfset s.login = true>
			<cftry>
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT folder_id, folder_name
				FROM #session.hostdbprefix#folders
				WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif arguments.thelist EQ "">
					AND folder_id = folder_id_r
				<cfelse>
					AND folder_id_r IN (<cfqueryparam value="#arguments.thelist#" cfsqltype="CF_SQL_VARCHAR" list="true">)
					AND folder_id != folder_id_r
				</cfif>
				</cfquery>
				<cfif qry.RecordCount NEQ 0>
					<cfinvoke method="getFolders" returnvariable="local_list">
						<cfinvokeargument name="thelist" value="#ValueList(qry.folder_id)#">
					</cfinvoke>
					<cfset Arguments.thelist = Arguments.thelist & "," & local_list>
				</cfif>
				<cfset s.folderlist = arguments.thelist>
				<cfcatch type="any"><cfdump var="#cfcatch#"></cfcatch>
			</cftry>
		<cfelse>
			<cfset s.login = false>
		</cfif>
		<!--- Return --->
		<cfreturn s>
	</cffunction>
	
</cfcomponent>