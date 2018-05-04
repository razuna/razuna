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

	<cffunction name="init" returntype="lucene" access="public" output="false">
		<cfreturn this />
	</cffunction>

	<!--- INDEX: Delete --->
	<cffunction name="index_delete" access="public" output="false">
		<cfargument name="thestruct" type="struct">
		<cfargument name="category" type="string" required="true">
		<cfargument name="assetid" type="string" required="false">
		<cfargument name="notfile" type="string" default="F" required="false">
		<cftry>
			<!--- Add to lucene delete table --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO lucene
			(id, type, host_id, time_stamp)
			VALUES (
				<cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.category#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			)
			</cfquery>
			<cfcatch type="any">
				<cfset consoleoutput(true, true)>
				<cfset console(cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- SEARCH --->
	<cffunction name="search" access="remote" output="false" returntype="query">
		<cfargument name="criteria" type="string">
		<cfargument name="category" type="string">
		<cfargument name="hostid" type="numeric">
		<cfargument name="startrow" type="numeric">
		<cfargument name="maxrows" type="numeric">
		<cfargument name="folderid" type="string">
		<cfargument name="search_type" type="string">
		<cfargument name="search_rendition" type="string">
		<cfargument name="searchupc" type="any">
		<cfargument name="thestruct" type="struct" required="false" />
		<!--- <cfset consoleoutput(true, true)>
		<cfset console("lucene search arguments", arguments)>
		<cfabort> --->
		<!--- Convert search_upc to boolean --->
		<cfset var _search_upc = arguments.searchupc EQ 'true' ? true : false>
		<!--- Param --->
		<cfset var _taskserver = "" />
		<!--- Query settings --->
		<cfinvoke component="settings" method="prefs_taskserver" thestruct="#arguments.thestruct#" returnvariable="_taskserver" />
		<!--- Taskserver URL according to settings --->
		<cfif _taskserver.taskserver_location EQ "remote">
			<cfset var _url = _taskserver.taskserver_remote_url />
		<cfelse>
			<cfset var _url = _taskserver.taskserver_local_url />
		</cfif>
		<!--- Search in task server --->
		<!--- URL and secret key should come from db --->
		<cfhttp url="#_url#/api/search.cfc" method="post" charset="utf-8">
			<cfhttpparam name="method" value="search" type="formfield" />
			<cfhttpparam name="secret" value="#_taskserver.taskserver_secret#" type="formfield" />
			<cfhttpparam name="collection" value="#arguments.thestruct.razuna.session.hostid#" type="formfield" />
			<cfhttpparam name="criteria" value="#arguments.criteria#" type="formfield" />
			<cfhttpparam name="category" value="#arguments.category#" type="formfield" />
			<cfhttpparam name="startrow" value="#arguments.startrow#" type="formfield" />
			<cfhttpparam name="maxrows" value="#arguments.maxrows#" type="formfield" />
			<cfhttpparam name="folderid" value="#arguments.folderid#" type="formfield" />
			<cfhttpparam name="search_type" value="#arguments.search_type#" type="formfield" />
			<cfhttpparam name="search_rendition" value="#arguments.search_rendition#" type="formfield" />
			<cfhttpparam name="search_upc" value="#_search_upc#" type="formfield" />
			<!--- <cfhttpparam name="thestruct" value="#arguments.thestruct#" type="formfield" /> --->
		</cfhttp>
		<!--- if statuscode is not 200 --->
		<cfif cfhttp.statuscode CONTAINS "200">
			<cftry>
				<!--- Grab results and serialize --->
				<cfset _json = deserializeJSON(cfhttp.filecontent) />
				<!--- If we don't have an error --->
				<cfif _json.success>
					<!--- Log --->
					<!--- <cfset console(_json)> --->
					<!--- Return --->
					<cfreturn _json.results>
				<cfelse>
					<!--- <cfset console(_json.error)> --->
					<cfoutput>
						<h2>An error occured</h2>
						<p>Please report the below error to your Administrator.</p>
					</cfoutput>
					<cfdump var="#_json.error#" label="ERROR" />
					<cfabort>
				</cfif>
				<cfcatch type="any">
					<cfoutput>
						<h2>An error occured</h2>
						<p>Please report the below error to your Administrator.</p>
					</cfoutput>
					<cfdump var="#cfcatch#" label="ERROR">
					<cfabort>
				</cfcatch>
			</cftry>

		<cfelse>
			<cfoutput>
				<h2>A connection error to the search server occured</h2>
				<p>Please report the below error to your Administrator.</p>
			</cfoutput>
			<cfdump var="#cfhttp#" label="ERROR" />
			<cfabort>
		</cfif>

	</cffunction>

	<!--- INDEX: Update from API --->
	<cffunction name="index_update_api" access="remote" output="false">
		<cfargument name="assetid" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Call to update asset --->
		<cfset rebuildIndex(assetid=arguments.assetid, thestruct=arguments.thestruct ) />
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- For status --->
	<cffunction name="statusOfIndex" access="public" output="false">
		<cfargument name="reset" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- If the user wants to reset index --->
		<cfif arguments.reset>
			<cfset rebuildIndex(assetid='all', thestruct=arguments.thestruct ) />
		</cfif>
		<!--- Var --->
		<cfset var qry = "" />
		<!--- Query how many files are not indexed --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT count(img_id) as count, 'Images' as type
		FROM #arguments.thestruct.razuna.session.hostdbprefix#images
		WHERE is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		UNION ALL
		SELECT count(vid_id) as count, 'Videos' as type
		FROM #arguments.thestruct.razuna.session.hostdbprefix#videos
		WHERE is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		UNION ALL
		SELECT count(file_id) as count, 'Documents' as type
		FROM #arguments.thestruct.razuna.session.hostdbprefix#files
		WHERE is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		UNION ALL
		SELECT count(aud_id) as count, 'Audios' as type
		FROM #arguments.thestruct.razuna.session.hostdbprefix#audios a
		WHERE is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Rebuild Index --->
	<cffunction name="rebuildIndex" access="public" output="false">
		<cfargument name="assetid" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Param --->
		<cfset var _taskserver = "" />
		<!--- Query settings --->
		<cfinvoke component="settings" method="prefs_taskserver" thestruct="#arguments.thestruct#" returnvariable="_taskserver" />
		<!--- Taskserver URL according to settings --->
		<cfif _taskserver.taskserver_location EQ "remote">
			<cfset var _url = _taskserver.taskserver_remote_url />
		<cfelse>
			<cfset var _url = _taskserver.taskserver_local_url />
		</cfif>
		<!--- Call search server to rebuild collection --->
		<cfhttp url="#_url#/api/collection.cfc" method="post" charset="utf-8">
			<cfhttpparam name="method" value="rebuildCollection" type="formfield" />
			<cfhttpparam name="secret" value="#_taskserver.taskserver_secret#" type="formfield" />
			<!--- <cfhttpparam name="thestruct" value="#arguments.thestruct#" type="formfield" /> --->
		</cfhttp>
		<!--- Set records to non indexed --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images
		SET is_indexed = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif arguments.assetid NEQ "all">
			AND img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
		</cfif>
		</cfquery>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		UPDATE #arguments.thestruct.razuna.session.hostdbprefix#videos
		SET is_indexed = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif arguments.assetid NEQ "all">
			AND vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
		</cfif>
		</cfquery>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		UPDATE #arguments.thestruct.razuna.session.hostdbprefix#audios
		SET is_indexed = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif arguments.assetid NEQ "all">
			AND aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
		</cfif>
		</cfquery>
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		UPDATE #arguments.thestruct.razuna.session.hostdbprefix#files
		SET is_indexed = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif arguments.assetid NEQ "all">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
		</cfif>
		</cfquery>
		<!--- Flush Caches --->
		<cfset resetcachetoken(type="images", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn  />
	</cffunction>

</cfcomponent>