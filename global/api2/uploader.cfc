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
	
	<cffunction name="getFolders" access="remote" output="true" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Create struct --->
		<cfset var s = structnew()>
		<cfset var qry = "">
		<!--- Lets make sure the API key is still valid --->
		<cfset var login = checkDesktop(arguments.api_key).login>
		<!--- Ok user is in --->
		<cfif login>
			<cftry>
				<!--- Query root folders --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry_root">
				SELECT folder_id, folder_name, concat(folder_name) as path
				FROM #session.hostdbprefix#folders
				WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND (folder_is_collection IS NULL OR folder_is_collection = '')
				AND folder_id = folder_id_r
				ORDER BY folder_name
				</cfquery>
				<!--- Create new query object --->
				<cfset var qry = querynew('folder_id, folder_name, path')>
				<!--- Add query to our temp query --->
				<cfloop query="qry_root">
					<!--- Set cells of query --->
					<cfset queryaddrow(qry,1)>
					<cfset querysetcell(qry,"folder_id",folder_id)>
					<cfset querysetcell(qry,"folder_name",folder_name)>
					<cfset querysetcell(qry,"path",path)>
				</cfloop>
				<!--- Call sub function which does its recursive thing --->
				<cfinvoke method="getFoldersSub" returnvariable="qry_all">
					<cfinvokeargument name="theqry" value="#qry#">
					<cfinvokeargument name="qry_root" value="#qry_root#">
				</cfinvoke>
				<!--- Take the final query and sort by path --->
				<cfquery dbtype="query" name="qry">
				SELECT *
				FROM qry_all
				ORDER BY path
				</cfquery>
				<!--- Catch	--->
				<cfcatch type="any">
					<cfdump var="#cfcatch#">
					<cfabort>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<cffunction name="getFoldersSub" access="private" output="true" returntype="query">
		<cfargument name="theqry" required="true">
		<cfargument name="qry_root" required="true">
		<cfargument name="qry_root_name" required="false" default="">
		<!--- Params --->
		<cfset var qry_children = "">
		<!--- Loop --->
		<cfloop query="arguments.qry_root">
			<!--- Append the "/" on the root name but only on the first loop --->
			<cfif arguments.qry_root_name NEQ "" and arguments.qry_root.currentRow EQ 1>
				<cfset arguments.qry_root_name = "#arguments.qry_root_name#/">
			</cfif>
			<!--- Get next children --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry_children">
			SELECT folder_id, folder_name, concat('#arguments.qry_root_name##folder_name#','/',folder_name) as path
			FROM #session.hostdbprefix#folders
			WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND (folder_is_collection IS NULL OR folder_is_collection = '')
			AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#folder_id#">
			AND folder_id_r <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> folder_id
			ORDER BY folder_name
			</cfquery>
			<!--- If more found then call this function again --->
			<cfif qry_children.recordcount NEQ 0>
				<!--- Add children to query --->
				<cfloop query="qry_children">
					<cfset queryaddrow(arguments.theqry,1)>
					<cfset querysetcell(arguments.theqry,"folder_id",folder_id)>
					<cfset querysetcell(arguments.theqry,"folder_name",folder_name)>
					<cfset querysetcell(arguments.theqry,"path",path)>
				</cfloop>
				<!--- Look for more records --->
				<cfinvoke method="getFoldersSub" returnvariable="qry_all">
					<cfinvokeargument name="theqry" value="#arguments.theqry#">
					<cfinvokeargument name="qry_root" value="#qry_children#">
					<cfinvokeargument name="qry_root_name" value="#arguments.qry_root_name##folder_name#">
				</cfinvoke>
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn arguments.theqry>
	</cffunction>

</cfcomponent>