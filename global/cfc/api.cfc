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
	<cffunction name="add_action" access="public" returntype="void">
		<cfargument name="pid" type="string" required="true" />
		<cfargument name="action" type="string" required="true" />
		<cfargument name="comp" type="string" required="true" />
		<cfargument name="func" type="string" required="true" />
		<cfargument name="args" type="string" required="false" default="" />
		<!--- Remove any same action first --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM plugins_actions
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pid#">
		AND lower(action) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.action)#">
		AND lower(comp) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.comp)#">
		AND lower(func) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.func)#">
		</cfquery>
		<!--- Add this action to DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO plugins_actions
		(action, comp, func, args, p_id)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.comp#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.func#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.args#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pid#">
		)
		</cfquery>
		<!--- Reset cache --->
		<cfset resetcachetoken("settings")>
	</cffunction>

	<!--- Del action --->
	<cffunction name="del_action" access="public" returntype="void">
		<cfargument name="pid" required="true" />
		<cfargument name="action" type="string" required="false" default="" />
		<cfargument name="comp" type="string" required="false" default="" />
		<cfargument name="func" type="string" required="false" default="" />
		<cfargument name="args" type="string" required="false" default="" />
		<!--- DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM plugins_actions
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pid#">
		<cfif arguments.action NEQ "">
			AND lower(action) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.action)#">
		</cfif>
		<cfif arguments.comp NEQ "">
			AND lower(comp) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.comp)#">
		</cfif>
		<cfif arguments.func NEQ "">
			AND lower(func) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.func)#">
		</cfif>
		<cfif arguments.args NEQ "">
			AND args LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.args#%">
		</cfif>
		</cfquery>
		<!--- Reset cache --->
		<cfset resetcachetoken("settings")>
	</cffunction>

	<!--- Get datasource --->
	<cffunction name="getDatasource" access="public" returntype="String">
		<cfreturn settingsObj.get_global().conf_datasource />
	</cffunction>

	<!--- Get database --->
	<cffunction name="getDatabase" access="public" returntype="String">
		<cfreturn settingsObj.get_global().conf_database />
	</cffunction>

	<!--- Get schema --->
	<cffunction name="getSchema" access="public" returntype="String">
		<cfreturn settingsObj.get_global().conf_schema />
	</cffunction>

	<!--- Get storage --->
	<cffunction name="getStorage" access="public" returntype="String">
		<cfreturn settingsObj.get_global().conf_storage />
	</cffunction>

	<!--- Get Sessions --->
	<cffunction name="getHostID" access="public" returntype="String">
		<cfreturn session.hostid />
	</cffunction>

	<!--- Get HostDBPrefix --->
	<cffunction name="getHostPrefix" access="public" returntype="String">
		<cfreturn session.HostDBPrefix />
	</cffunction>

	<!--- Get Groups --->
	<cffunction name="getGroups" access="public" returntype="query">
		<cfinvoke component="groups" method="getall" returnvariable="qrygrp" />
		<cfreturn qrygrp />
	</cffunction>

	<!--- Get Users --->
	<cffunction name="getUsers" access="public" returntype="query">
		<cfinvoke component="users" method="getall" returnvariable="qryusers" />
		<cfreturn qryusers />
	</cffunction>

	<!--- Get UploadTemplates --->
	<cffunction name="getUploadTemplates" access="public" returntype="query">
		<cfinvoke component="global" method="upl_templates" theactive="true" returnvariable="qryuptemp" />
		<cfreturn qryuptemp />
	</cffunction>

	<!--- Get Labels --->
	<cffunction name="getLabels" access="public" returntype="query">
		<cfinvoke component="labels" method="labels_dropdown" returnvariable="qrylabels" />
		<cfreturn qrylabels />
	</cffunction>

	<!--- Get CustomFields --->
	<cffunction name="getCustomFields" access="public" returntype="query">
		<cfinvoke component="custom_fields" method="get" fieldsenabled="true" returnvariable="qrycf" />
		<cfreturn qrycf />
	</cffunction>

	<!--- Get PluginID --->
	<cffunction name="getMyID" access="public" returntype="string">
		<cfargument name="pluginname" type="string" required="true" />
		<cfset var plugID = getProfileString("#expandPath("../..")#/global/plugins/#arguments.pluginname#/config/config.ini", "information", "id")>
		<cfreturn plugID />
	</cffunction>

	

</cfcomponent>