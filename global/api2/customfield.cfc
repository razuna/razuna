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
		
	<!--- Get all custom fields --->
	<cffunction name="getall" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set values --->
			<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
			<!--- Call internal --->
			<cfinvoke component="global.cfc.custom_fields" method="get" returnVariable="qry">
			<!--- QoQ --->
			<cfquery dbtype="query" name="thexml">
			SELECT cf_id id, cf_type type, cf_enabled enabled, cf_show show, cf_text text
			FROM qry
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
		
	<!--- Add custom field --->
	<cffunction name="setfield" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="field_text" required="true">
		<cfargument name="field_type" required="true">
		<cfargument name="field_show" required="false" default="all">
		<cfargument name="field_enabled" required="false" default="t">
		<cfargument name="field_select_list" required="false" default="">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set Values --->
			<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
			<!--- Set Arguments --->
			<cfset arguments.thestruct.langcount = 1>
			<cfset arguments.thestruct.cf_text_1 = arguments.field_text>
			<cfset arguments.thestruct.cf_type = arguments.field_type>
			<cfset arguments.thestruct.cf_enabled = arguments.field_enabled>
			<cfset arguments.thestruct.cf_show = arguments.field_show>
			<cfset arguments.thestruct.cf_select_list = arguments.field_select_list>
			<!--- call internal method --->
			<cfinvoke component="global.cfc.custom_fields" method="add" thestruct="#arguments.thestruct#" returnVariable="theid">
			<!--- Return --->
			<cfset thexml.responsecode = 0>
			<cfset thexml.message = "Custom field successfully added">
			<cfset thexml.field_id = theid>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Set Custom Field Value --->
	<cffunction name="setfieldvalue" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="assetid" required="true">
		<cfargument name="field_values" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Deserialize the JSON back into a struct --->
			<cfset thejson = DeserializeJSON(arguments.field_values)>
			<!--- Loop over the assetid --->
			<cfloop list="#arguments.assetid#" index="i" delimiters=",">
				<!--- Loop over struct --->
				<cfloop array="#thejson#" index="f">
					<!--- Check to see if there is a record --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry">
					SELECT cf_id_r
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values
					WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
					AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
					</cfquery>
					<!--- Insert --->
					<cfif qry.recordcount EQ 0>
						<cfquery datasource="#application.razuna.api.dsn#">
						INSERT INTO #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values
						(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
						VALUES(
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#f[2]#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
						)
						</cfquery>
					<!--- Update --->
					<cfelse>
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values
						SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#f[2]#">
						WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
						AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
						</cfquery>
					</cfif>
				</cfloop>
				<!--- update change date (since we don't know the type we simply update all) --->
				<cfquery datasource="#application.razuna.api.dsn#">
				Update #application.razuna.api.prefix["#arguments.api_key#"]#images
				SET 
				img_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
				</cfquery>
				<cfquery datasource="#application.razuna.api.dsn#">
				Update #application.razuna.api.prefix["#arguments.api_key#"]#videos
				SET 
				vid_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				vid_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
				</cfquery>
				<cfquery datasource="#application.razuna.api.dsn#">
				Update #application.razuna.api.prefix["#arguments.api_key#"]#audios
				SET 
				aud_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				aud_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
				</cfquery>
				<cfquery datasource="#application.razuna.api.dsn#">
				Update #application.razuna.api.prefix["#arguments.api_key#"]#files
				SET 
				file_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
				</cfquery>
			</cfloop>
			<!--- Reset cache --->
			<cfset resetcachetoken(arguments.api_key,"images")>
			<cfset resetcachetoken(arguments.api_key,"videos")>
			<cfset resetcachetoken(arguments.api_key,"audios")>
			<cfset resetcachetoken(arguments.api_key,"files")>
			<cfset resetcachetoken(arguments.api_key,"search")>
			<cfset resetcachetoken(arguments.api_key,"general")>
			<!--- Return --->
			<cfset thexml.responsecode = 0>
			<cfset thexml.message = "Custom field values successfully added">
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- get custom fields from asset --->
	<cffunction name="getfieldsofasset" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="asset_id" required="true">
		<cfargument name="lang_id" required="false" default="1">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get Cachetoken --->
			<cfset cachetoken = getcachetoken(arguments.api_key,"general")>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
			SELECT DISTINCT /* #cachetoken#getfieldsofasset */ 
			ct.cf_id_r field_id, ct.cf_text field_text, cv.cf_value field_value, c.cf_order
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_text ct, #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields c, #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values cv
			WHERE cv.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.asset_id#" list="Yes">)
			AND ct.cf_id_r = cv.cf_id_r
			AND ct.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.lang_id#">
			AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
			ORDER BY c.cf_order
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
</cfcomponent>