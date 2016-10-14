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

	<!--- Create empty record --->
	<cffunction name="add" access="remote" output="false" returntype="query" returnformat="json" hint="Obvious">
		<cfargument name="api_key" required="true" hint="Your api key">
		<cfargument name="files" required="true" hint="Files data">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- deserializeJSON back into array --->
				<cfset var thejson = DeserializeJSON(arguments.files)>
				<cfset var l = "">
				<!--- Loop over JSON and update data --->
				<cfloop array='#thejson#' index="x">
					<cftry>
						<!--- Create temp ID --->
						<cfset _asset_id = createuuid("")>
						<!--- Create record in db --->
						<cfset _id = create_inserts(asset_id=_asset_id, host_id=x.host_id, folder_id=x.folder_id, is_available=x.is_available, filename_org=x.filename_org, filename=x.filename, type=x.type, api_key=arguments.api_key)>
						<!--- Add our own tags to the query --->
						<cfset thexml = querynew("asset_id, filename, type, status")>
						<cfset queryaddrow(thexml, 1)>
						<cfset querysetcell(thexml, "asset_id", _id)>
						<cfset querysetcell(thexml, "filename", x.filename)>
						<cfset querysetcell(thexml, "type", x.type)>
						<cfset querysetcell(thexml, "status", true)>
						<cfcatch>
							<cfset consoleoutput(true)>
							<cfset console(cfcatch)>
							<!--- Add our own tags to the query --->
							<cfset thexml = querynew("filename, type, status")>
							<cfset queryaddrow(thexml, 1)>
							<cfset querysetcell(thexml, "filename", x.filename)>
							<cfset querysetcell(thexml, "type", x.type)>
							<cfset querysetcell(thexml, "status", false)>
						</cfcatch>
					</cftry>
				</cfloop>
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

	<!--- Create empty record --->
	<cffunction name="addcloud" access="remote" output="false" returntype="query" returnformat="json" hint="Obvious">
		<cfargument name="api_key" required="true" hint="Your api key">
		<cfargument name="cloud" required="true" hint="Cloud data">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- deserializeJSON back into array --->
				<cfset var thejson = DeserializeJSON(arguments.cloud)>
				<cfset var l = "">
				<!--- Loop over JSON and update data --->
				<cfloop array='#thejson#' index="x">
					<!--- Images --->
					<cfif x.type EQ "img">
						<cfset var _db = "images">
						<cfset var _id = "img_id">
					<cfelse>
						<cfset var _db = "files">
						<cfset var _id = "file_id">
					</cfif>
					<cftry>
						<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix##_db#
						SET
						cloud_url = <cfqueryparam value="#x.cloud_url#" cfsqltype="CF_SQL_VARCHAR">,
						cloud_url_org = <cfqueryparam value="#x.cloud_url_org#" cfsqltype="CF_SQL_VARCHAR">
						WHERE #_id# = <cfqueryparam value="#x.asset_id#" cfsqltype="CF_SQL_VARCHAR">
						</cfquery>
						<!--- Add our own tags to the query --->
						<cfset thexml = querynew("asset_id, type, status")>
						<cfset queryaddrow(thexml, 1)>
						<cfset querysetcell(thexml, "asset_id", x.asset_id)>
						<cfset querysetcell(thexml, "type", x.type)>
						<cfset querysetcell(thexml, "status", true)>
						<cfcatch>
							<cfset consoleoutput(true)>
							<cfset console(cfcatch)>
							<!--- Add our own tags to the query --->
							<cfset thexml = querynew("asset_id, type, status")>
							<cfset queryaddrow(thexml, 1)>
							<cfset querysetcell(thexml, "asset_id", x.asset_id)>
							<cfset querysetcell(thexml, "type", x.type)>
							<cfset querysetcell(thexml, "status", false)>
						</cfcatch>
					</cftry>
				</cfloop>
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




	<!--- Create Inserts --->
	<cffunction name="create_inserts" output="true" access="private">
		<cfargument name="asset_id" type="string">
		<cfargument name="host_id" type="string">
		<cfargument name="folder_id" type="string">
		<cfargument name="is_available" type="string">
		<cfargument name="filename_org" type="string">
		<cfargument name="filename" type="string">
		<cfargument name="type" type="string">
		<cfargument name="api_key" type="string">
		<!--- IMAGES --->
		<cfif arguments.type EQ "img">
			<!--- Add records to the DB - We do this here so that fast subsequent calls from the API work --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#images
			(img_id, host_id, folder_id_r, is_available, img_filename, img_filename_org, img_create_time)
			VALUES(
			<cfqueryparam value="#arguments.asset_id#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.host_id#" cfsqltype="cf_sql_numeric">,
			<cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.is_available#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.filename#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.filename_org#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			)
			</cfquery>
			<!--- Create empty records in the table because we sometimes have images without XMP --->
			<!--- Insert --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#images_text
			(id_inc, img_id_r, lang_id_r, host_id)
			VALUES(
			<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.asset_id#" cfsqltype="CF_SQL_VARCHAR">, 
			<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
			<cfqueryparam value="#arguments.host_id#" cfsqltype="cf_sql_numeric">
			)
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#xmp
			(id_r)
			VALUES(
				<cfqueryparam value="#arguments.asset_id#" cfsqltype="CF_SQL_VARCHAR">
			)
			</cfquery>
		<!--- VIDEOS --->
		<cfelseif qry_mime.type_type EQ "vid">
			<!--- Insert record --->		
			<!--- <cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#videos
			(vid_id, vid_name_org, vid_filename, host_id, folder_id_r, path_to_asset, is_available, vid_create_time)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry_file.tempid#">,
			<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
				<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
			<cfelse>
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry_file.filename#">
			</cfif>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry_file.filename#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry_file.folder_id#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry_file.folder_id#/vid/#qry_file.tempid#">,
			<cfif qry_approval.approval_enabled>
				<cfqueryparam value="2" cfsqltype="cf_sql_varchar">
			<cfelse>
				<cfqueryparam value="0" cfsqltype="cf_sql_varchar">
			</cfif>,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			)
			</cfquery>
			<!--- Create empty records in the text table --->
			<cfloop list="#arguments.thestruct.langcount#" index="langindex">
				<!--- Insert --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#videos_text
				(id_inc, vid_id_r, lang_id_r, host_id)
				VALUES(
				<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">, 
				<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				)
				</cfquery>
			</cfloop>
			<!--- Add the TEXTS to the DB. We have to hide this is if we are coming from FCK --->
			<cfif structkeyexists(arguments.thestruct,"langcount")>
				<cfloop list="#arguments.thestruct.langcount#" index="langindex">
					<cfif arguments.thestruct.uploadkind EQ "many">
						<cfset var desc="file_desc_" & "#countnr#" & "_" & "#langindex#">
						<cfset var keywords="file_keywords_" & "#countnr#" & "_" & "#langindex#">
						<cfset var title="file_title_" & "#countnr#" & "_" & "#langindex#">
					<cfelse>
						<cfset var desc="arguments.thestruct.file_desc_" & "#langindex#">
						<cfset var keywords="arguments.thestruct.file_keywords_" & "#langindex#">
						<cfset var title="arguments.thestruct.file_title_" & "#langindex#">
					</cfif>
					<cfif desc CONTAINS langindex>
						<!--- check if form-vars are present. They will be missing if not coming from a user-interface (assettransfer, etc.) --->
						<cfif IsDefined(desc) and IsDefined(keywords) and IsDefined(title)>
							<cfquery datasource="#application.razuna.datasource#">
							UPDATE #session.hostdbprefix#videos_text
							SET
							vid_description = <cfqueryparam value="#evaluate(desc)#" cfsqltype="cf_sql_varchar">,
							vid_keywords = <cfqueryparam value="#evaluate(keywords)#" cfsqltype="cf_sql_varchar">, 
							vid_title = <cfqueryparam value="#evaluate(title)#" cfsqltype="cf_sql_varchar">
							WHERE vid_id_r = <cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
			</cfif> --->
		<!--- AUDIOS --->
		<cfelseif qry_mime.type_type EQ "aud">
			<!--- Add record --->
			<!--- <cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#audios
			(aud_id, is_available, folder_id_r, host_id, aud_create_time, aud_name)
			VALUES(
				<cfqueryparam value="#qry_file.tempid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfif qry_approval.approval_enabled>
					<cfqueryparam value="2" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam value="0" cfsqltype="cf_sql_varchar">
				</cfif>,
				<cfqueryparam value="#qry_file.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
				<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
					<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam value="#qry_file.filename#" cfsqltype="cf_sql_varchar">
				</cfif>
			)
			</cfquery> --->
		<!--- DOCUMENTS --->
		<cfelse>
			<!--- Insert --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#files
			(file_id, host_id, folder_id_r, is_available, file_name, file_name_org, file_create_time)
			VALUES(
				<cfqueryparam value="#arguments.asset_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.host_id#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.is_available#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.filename#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.filename_org#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			)
			</cfquery>
			<!--- Create empty records in the text table --->
			<!--- Insert --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#files_desc
			(id_inc, file_id_r, lang_id_r, host_id)
			VALUES(
			<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.asset_id#" cfsqltype="CF_SQL_VARCHAR">, 
			<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
			<cfqueryparam value="#arguments.host_id#" cfsqltype="cf_sql_numeric">
			)
			</cfquery>
		</cfif>
		<!--- Flush Cache (the api one does it for all types) --->
		<cfset resetcachetoken(arguments.api_key, "images")>
		<!--- Return --->
		<cfreturn arguments.asset_id />
	</cffunction>

</cfcomponent>
