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
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
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
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
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
			<!--- User not admin --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
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
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Deserialize the JSON back into a struct --->
			<cfset thejson = DeserializeJSON(arguments.field_values)>
			<!--- Loop over the assetid --->
			<cfloop list="#arguments.assetid#" index="i" delimiters=",">
				<!--- Get permission for asset (folder) --->
				<cfset var folderaccess = checkFolderPerm(arguments.api_key, i)>
				<!--- If user has access --->
				<cfif folderaccess EQ "W" OR folderaccess EQ "X">
					<!--- Loop over struct --->
					<cfloop array="#thejson#" index="f">
						<!--- Check to see if there is a record --->
						<cfquery datasource="#application.razuna.api.dsn#" name="qry">
						SELECT cf_id_r
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values
						WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
						AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">
						</cfquery>
						<!--- ORIGINAL CODE
						INSERT COMMENT
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
						UPDATE COMMENT
						<cfelse>
							<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values
							SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#f[2]#">
							WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
							AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
							</cfquery>
						</cfif>
						--->
						<!--- Anthony Rodriguez Edit --->
						<!--- Insert --->
						<cfif qry.recordcount EQ 0>
							<cfquery datasource="#application.razuna.api.dsn#">
							INSERT INTO #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values
							(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
							VALUES(
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#ReplaceNoCase(f[2],',','&##44;','ALL')#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
							)
							</cfquery>
						<!--- Update --->
						<cfelse>
							<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values
							SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ReplaceNoCase(f[2],',','&##44;','ALL')#">
							WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
							AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">
							</cfquery>
						</cfif>
						<!--- End Anthony Rodriguez Edit --->
						<!--- Nick Ryan Edit --->
						<!--- Check to see if item is part of select list --->
						<cfquery datasource="#application.razuna.api.dsn#" name="qry2">
						SELECT cf_id, cf_select_list
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields
						WHERE cf_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
						</cfquery>
						<cfset oldselectlist = listFind(qry2.cf_select_list, "#ReplaceNoCase(f[2],',','&##44;')#")>
						<!--- If not in list, update it --->
						<cfif oldselectlist is 0>
							<cfif len(trim(f[2]))>
								<cfset newselectlist =  listAppend(qry2.cf_select_list, "#ReplaceNoCase(f[2],',','&##44;')#", ",")>
								<cfquery datasource="#application.razuna.api.dsn#">
								UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields
								SET cf_select_list = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newselectlist#">
								WHERE cf_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
								AND cf_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="select">
								</cfquery>
							</cfif>						
						</cfif>
						<!--- End Nick Ryan Edit --->
					</cfloop>
					<!--- update change date (since we don't know the type we simply update all) --->
					<cfquery datasource="#application.razuna.api.dsn#">
					Update #application.razuna.api.prefix["#arguments.api_key#"]#images
					SET 
					img_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
					</cfquery>
					<cfquery datasource="#application.razuna.api.dsn#">
					Update #application.razuna.api.prefix["#arguments.api_key#"]#videos
					SET 
					vid_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					vid_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
					</cfquery>
					<cfquery datasource="#application.razuna.api.dsn#">
					Update #application.razuna.api.prefix["#arguments.api_key#"]#audios
					SET 
					aud_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					aud_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
					</cfquery>
					<cfquery datasource="#application.razuna.api.dsn#">
					Update #application.razuna.api.prefix["#arguments.api_key#"]#files
					SET 
					file_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
					WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
					</cfquery>
					<!--- Call workflow --->
					<cfset executeworkflow(api_key=arguments.api_key,action='on_file_edit',fileid=i)>
				<!--- No access --->
				<cfelse>
					<!--- Return --->
					<cfset var thexml = noaccess("s")>
				</cfif>
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
	
	<!--- Set Custom Field Value in bulk --->
	<cffunction name="setfieldvaluebulk" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="field_values" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set thread --->
			<cfthread action="run" name="#createuuid()#" intstruct="#arguments#">
				<!--- Grab the json and deserialize it --->
				<cfset j = DeserializeJSON(attributes.intstruct.field_values)>
				<!--- Loop over the array --->
				<cfloop array="#j#" index="id">
					<!--- This is the first array containing the assetid --->
					<cfset assetid = id[1]>
					<!--- This is the second value containing another array --->
					<cfset fieldvalues = SerializeJSON(id[2])>
					<!--- Call internal function --->
					<cfinvoke method="setfieldvalue">
						<cfinvokeargument name="api_key" value="#attributes.intstruct.api_key#" />
						<cfinvokeargument name="assetid" value="#assetid#" />
						<cfinvokeargument name="field_values" value="#fieldvalues#" />
					</cfinvoke>
				</cfloop>
			</cfthread>
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
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
			SELECT DISTINCT ct.cf_id_r field_id, ct.cf_text field_text, cv.cf_value field_value, c.cf_order, cv.asset_id_r file_id
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_text ct, #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields c, #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_values cv
			WHERE cv.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.asset_id#" list="Yes">)
			AND cv.cf_id_r = ct.cf_id_r
			AND c.cf_id = ct.cf_id_r
			AND ct.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.lang_id#">
			AND cv.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
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