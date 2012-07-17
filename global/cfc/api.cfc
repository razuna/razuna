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
<cfcomponent output="false" extends="extQueryCaching">

	<!--- Settings Object --->
	<cfobject component="global.cfc.settings" name="settingsObj">

	<!--- Add action --->
	<cffunction name="add_action" access="public">
		<cfargument name="action" required="true" />
		<cfargument name="comp" required="true" />
		<cfargument name="func" required="true" />
		<cfargument name="args" required="false" default="" />
		<!--- Add this action to DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO plugins_actions
		(action, comp, func, args, p_id)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.comp#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.func#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.args#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thisPluginId#">
		)
		</cfquery>
		<!--- Reset cache --->
		<cfset resetcachetoken("settings")>
	</cffunction>

	<!--- Get datasource --->
	<cffunction name="getDatasource" access="public" returntype="String">
		<cfset var t = settingsObj.get_global().conf_datasource>
		<cfreturn t />
	</cffunction>

	<!--- Get database --->
	<cffunction name="getDatabase" access="public" returntype="String">
		<cfset var t = settingsObj.get_global().conf_database>
		<cfreturn t />
	</cffunction>

	<!--- Get schema --->
	<cffunction name="getSchema" access="public" returntype="String">
		<cfset var t = settingsObj.get_global().conf_schema>
		<cfreturn t />
	</cffunction>

	<!--- Get storage --->
	<cffunction name="getStorage" access="public" returntype="String">
		<cfset var t = settingsObj.get_global().conf_storage>
		<cfreturn t />
	</cffunction>

	<!--- Get Sessions --->
	<cffunction name="getHostID" access="public" returntype="String">
		<cfset var t = session.hostid>
		<cfreturn t />
	</cffunction>


</cfcomponent>