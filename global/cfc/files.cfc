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

<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("files")>

<!--- COUNT ALL FILES IN A FOLDER --->
<cffunction name="getFolderCount" description="COUNT ALL FILES IN A FOLDER" output="false" access="public" returntype="numeric">
	<cfargument name="folder_id" required="true" type="string">
	<cfargument name="file_extension" required="false" type="string" default="">
	<!--- init local vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getFolderCountfiles */ COUNT(*) AS folderCount
	FROM #session.hostdbprefix#files
	WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.folder_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<!--- Nirvanix and in Admin --->
	<cfif session.thisapp EQ "admin" AND application.razuna.storage EQ "nirvanix">
		AND lower(shared) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
	</cfif>
	<cfif Len(Arguments.file_extension)>
		AND
		<!--- if doc or xls also add office 2007 format to query --->
		<cfif Arguments.file_extension EQ "doc" OR Arguments.file_extension EQ "xls">
			(
			LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
			OR LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#x">
			)
		<!--- query all formats if not other --->
		<cfelseif Arguments.file_extension neq "other">
			LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
		<cfelse>
			LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
		</cfif>
	</cfif>
	</cfquery>
		<cfreturn qLocal.folderCount />
	</cffunction>
	
	<!--- GET ALL RECORDS OF THIS TYPE IN A FOLDER --->
	<cffunction name="getFolderAssets" access="public" description="GET ALL RECORDS OF THIS TYPE IN A FOLDER" output="false" returntype="query">
		<cfargument name="folder_id" type="string" required="true">
		<cfargument name="ColumnList" required="false" type="string" hint="the column list for the selection" default="file_id">
		<cfargument name="file_extension" required="false" type="string" default="">
		<cfargument name="offset" type="numeric" required="false" default="0">
		<cfargument name="rowmaxpage" type="numeric" required="false" default="0">
		<cfargument name="thestruct" type="struct" required="false" default="">
		<!--- init local vars --->
		<cfset var qLocal = 0>
		<!--- Set pages var --->
		<cfparam name="arguments.thestruct.pages" default="">
		<cfparam name="arguments.thestruct.thisview" default="">
		<!--- If we need to show subfolders --->
		<cfif session.showsubfolders EQ "T">
			<cfinvoke component="folders" method="getfoldersinlist" dsn="#variables.dsn#" folder_id="#arguments.folder_id#" hostid="#session.hostid#" database="#variables.database#" returnvariable="thefolders">
			<cfset thefolderlist = arguments.folder_id & "," & ValueList(thefolders.folder_id)>
		<cfelse>
			<cfset thefolderlist = arguments.folder_id & ",">
		</cfif>
		<!--- Set the session for offset correctly if the total count of assets in lower the the total rowmaxpage --->
		<cfif arguments.thestruct.qry_filecount LTE session.rowmaxpage>
			<cfset session.offset = 0>
		</cfif>
		<!--- 
		This is for Oracle and MSQL
		Calculate the offset .Show the limit only if pages is null or current (from print) 
		--->
		<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
			<cfif session.offset EQ 0>
				<cfset var min = 0>
				<cfset var max = session.rowmaxpage>
			<cfelse>
				<cfset var min = session.offset * session.rowmaxpage>
				<cfset var max = (session.offset + 1) * session.rowmaxpage>
				<cfif variables.database EQ "db2">
					<cfset min = min + 1>
				</cfif>
			</cfif>
		<cfelse>
			<cfset var min = 0>
			<cfset var max = 1000>
		</cfif>
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name" OR session.sortby EQ "kind">
			<cfset var sortby = "filename_forsort">
		<cfelseif session.sortby EQ "sizedesc">
			<cfset var sortby = "size DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "size ASC">
		<cfelseif session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		</cfif>
		<!--- Oracle --->
		<cfif variables.database EQ "oracle">
			<!--- Clean columnlist --->
			<cfset var thecolumnlist = replacenocase(arguments.columnlist,"f.","","all")>
			<!--- Query --->
			<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getFolderAssetsfiles */ rn, #thecolumnlist#<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc">,keywords, description, labels</cfif>, 
			filename_forsort, size, hashtag, date_create, date_change
			FROM (
				SELECT ROWNUM AS rn, #thecolumnlist#<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc">,keywords, description, labels</cfif>, 
				filename_forsort, size, hashtag, date_create, date_change
				FROM (
					SELECT #Arguments.ColumnList#<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc">,ft.file_keywords keywords, ft.file_desc description, '' as labels</cfif>, lower(file_name) filename_forsort, file_size size, hashtag, file_create_time date_create, file_change_date date_change
					FROM #session.hostdbprefix#files<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc"> LEFT JOIN #session.hostdbprefix#files_desc ft ON file_id = ft.file_id_r AND ft.lang_id_r = 1</cfif>
					WHERE folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
					<cfif Len(Arguments.file_extension)>
						AND
						<!--- if doc or xls also add office 2007 format to query --->
						<cfif Arguments.file_extension EQ "doc" OR Arguments.file_extension EQ "xls">
							(
							LOWER(NVL(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
							OR LOWER(NVL(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#x">
							)
						<!--- query all formats if not other --->
						<cfelseif Arguments.file_extension neq "other">
							LOWER(NVL(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
						<!--- query all files except the ones in the list --->
						<cfelse>
							(
							LOWER(NVL(file_extension, '')) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
							OR (file_extension IS NULL OR file_extension = '')
							)
						</cfif>
					</cfif>
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					ORDER BY #sortby#
					)
				WHERE ROWNUM <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#max#">
				)
			WHERE rn > <cfqueryparam cfsqltype="cf_sql_numeric" value="#min#">
			</cfquery>
		<!--- DB2 --->
		<cfelseif variables.database EQ "db2">
			<!--- Clean columnlist --->
			<cfset var thecolumnlist = replacenocase(arguments.columnlist,"f.","","all")>
			<!--- Query --->
			<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getFolderAssetsfiles */ #thecolumnlist#<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc">,ft.file_keywords keywords, ft.file_desc description, '' as labels</cfif>, filename_forsort, size, hashtag, date_create, date_change
			FROM (
				SELECT row_number() over() as rownr, #session.hostdbprefix#files.*<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc">, ft.*</cfif>, lower(file_name) filename_forsort, file_size size, hashtag, file_create_time date_create, file_change_date date_change
				FROM #session.hostdbprefix#files<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc"> LEFT JOIN #session.hostdbprefix#files_desc ft ON file_id = ft.file_id_r AND ft.lang_id_r = 1</cfif>
				WHERE folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				<cfif Len(Arguments.file_extension)>
					AND
					<!--- if doc or xls also add office 2007 format to query --->
					<cfif Arguments.file_extension EQ "doc" OR Arguments.file_extension EQ "xls">
						(
						LOWER(file_extension) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
						OR LOWER(file_extension) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#x">
						)
					<!--- query all formats if not other --->
					<cfelseif Arguments.file_extension neq "other">
						LOWER(file_extension) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
					<!--- query all files except the ones in the list --->
					<cfelse>
						(
						LOWER(file_extension) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
						OR (file_extension IS NULL OR file_extension = '')
						)
					</cfif>
				</cfif>
				AND #session.hostdbprefix#files.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				ORDER BY #sortby#
			)
			<!--- Show the limit only if pages is null or current (from print) --->
			<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
				WHERE rownr between #min# AND #max#
			</cfif>
			</cfquery>
		<!--- Other DB's --->
		<cfelse>
			<!--- MySQL Offset --->
			<cfset var mysqloffset = session.offset * session.rowmaxpage>
			<!--- Query --->
			<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getFolderAssetsfiles */ <cfif variables.database EQ "mssql">TOP #max# </cfif>#Arguments.ColumnList#<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc">,ft.file_keywords keywords, ft.file_desc description, '' as labels</cfif>, lower(file_name) filename_forsort, file_size size, hashtag, 
			file_create_time date_create, file_change_date date_change
			FROM #session.hostdbprefix#files<cfif session.view EQ "combined" OR arguments.thestruct.fuseaction EQ "c.view_doc"> LEFT JOIN #session.hostdbprefix#files_desc ft ON file_id = ft.file_id_r AND ft.lang_id_r = 1</cfif>
			WHERE folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			<cfif Len(Arguments.file_extension)>
				AND
				<!--- if doc or xls also add office 2007 format to query --->
				<cfif Arguments.file_extension EQ "doc" OR Arguments.file_extension EQ "xls">
					(
					LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
					OR LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#x">
					)
				<!--- query all formats if not other --->
				<cfelseif Arguments.file_extension neq "other">
					LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
				<!--- query all files except the ones in the list --->
				<cfelse>
					(
					LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
					OR (file_extension IS NULL OR file_extension = '')
					)
				</cfif>
			</cfif>
			AND #session.hostdbprefix#files.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<!--- MySQL --->
			<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
				ORDER BY #sortby#
				<!--- Show the limit only if pages is null or current (from print) --->
				<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
					LIMIT #mysqloffset#, #session.rowmaxpage#
				</cfif>
			<!--- MSSQL --->
			<cfelseif variables.database EQ "mssql">
				AND file_id NOT IN (
					SELECT TOP #min# file_id
					FROM #session.hostdbprefix#files
					WHERE folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
					AND #session.hostdbprefix#files.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					<cfif Len(Arguments.file_extension)>
						AND
						<!--- if doc or xls also add office 2007 format to query --->
						<cfif Arguments.file_extension EQ "doc" OR Arguments.file_extension EQ "xls">
							(
							LOWER(isnull(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
							OR LOWER(isnull(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#x">
							)
						<!--- query all formats if not other --->
						<cfelseif Arguments.file_extension neq "other">
							LOWER(isnull(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Arguments.file_extension)#">
						<!--- query all files except the ones in the list --->
						<cfelse>
							(
							LOWER(isnull(file_extension, '')) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
							OR (file_extension IS NULL OR file_extension = '')
							)
						</cfif>
					</cfif>
				)
				ORDER BY #sortby#
			</cfif>
			</cfquery>
		</cfif>
		<!--- Only get the labels if in the combinded view --->
		<cfif session.view EQ "combined">
			<!--- Get the cachetoken for here --->
			<cfset variables.cachetokenlabels = getcachetoken("labels")>
			<!--- Loop over files and get labels and add to qry --->
			<cfloop query="qLocal">
				<!--- Query labels --->
				<cfquery name="qry_l" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
				SELECT /* #variables.cachetokenlabels#getallassetslabels */ ct_label_id
				FROM ct_labels
				WHERE ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#file_id#">
				</cfquery>
				<!--- Add labels query --->
				<cfset QuerySetCell(qLocal, "labels", valueList(qry_l.ct_label_id), currentRow)>
			</cfloop>
		</cfif>
		<!--- Return --->
		<cfreturn qLocal />
	</cffunction>
	
	<!--- GET ALL RECORD-DETAILS OF THIS TYPE IN A FOLDER --->
	<cffunction name="getFolderAssetDetails" access="public" description="GET ALL RECORD-DETAILS OF THIS TYPE IN A FOLDER" output="false" returntype="query">
		<cfargument name="folder_id" type="string" required="true">
		<cfargument name="ColumnList" required="false" type="string" hint="the column list for the selection" default="file_id, folder_id_r, file_extension, file_type, file_create_date, file_create_time, file_change_date, file_change_time, file_owner, file_name, file_remarks, path_to_asset, cloud_url">
		<cfargument name="file_extension" type="string" required="false" default="">
		<cfargument name="offset" type="numeric" required="false" default="0">
		<cfargument name="rowmaxpage" type="numeric" required="false" default="0">
		<cfargument name="thestruct" type="struct" required="false" default="">
		<!--- Set thestruct if not here --->
		<cfif NOT isstruct(arguments.thestruct)>
			<cfset arguments.thestruct = structnew()>
		</cfif>
		<cfreturn getFolderAssets(folder_id=arguments.folder_id, columnlist=arguments.columnlist, file_extension=arguments.file_extension, offset=session.offset, rowmaxpage=session.rowmaxpage, thestruct=arguments.thestruct)>
	</cffunction>
	
	<!--- REMOVE THE FILE --->
	<cffunction hint="REMOVE THE FILE" name="removefile" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Get file detail for log --->
		<cfinvoke method="filedetail" theid="#arguments.thestruct.id#" thecolumn="file_name, folder_id_r, file_name_org filenameorg, lucene_key, link_kind, link_path_url, path_to_asset" returnvariable="thedetail">
		<!--- Log --->
		<cfinvoke component="extQueryCaching" method="log_assets">
			<cfinvokeargument name="theuserid" value="#session.theuserid#">
			<cfinvokeargument name="logaction" value="Delete">
			<cfinvokeargument name="logdesc" value="Removed: #thedetail.file_name#">
			<cfinvokeargument name="logfiletype" value="doc">
			<cfinvokeargument name="assetid" value="#arguments.thestruct.id#">
		</cfinvoke>
		<!--- Delete from files DB (including referenced data)--->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#files
		WHERE file_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Delete from collection --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#collections_ct_files
		WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_file_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Delete from favorites --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#users_favorites
		WHERE fav_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND fav_kind = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
		AND user_id_r = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Delete from Versions --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND ver_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Delete from Share Options --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#share_options
		WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Delete labels --->
		<cfinvoke component="labels" method="label_ct_remove" id="#arguments.thestruct.id#" />
		<!--- Delete from file system --->
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset arguments.thestruct.folder_id_r = thedetail.folder_id_r>
		<cfset arguments.thestruct.qrydetail = thedetail>
		<cfset arguments.thestruct.link_kind = thedetail.link_kind>
		<cfset arguments.thestruct.filenameorg = thedetail.filenameorg>
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="deletefromfilesystem" thestruct="#attributes.intstruct#">
		</cfthread>
		<!--- Execute workflow --->
		<cfset arguments.thestruct.fileid = arguments.thestruct.id>
		<cfset arguments.thestruct.file_name = thedetail.file_name>
		<cfset arguments.thestruct.thefiletype = "doc">
		<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
		<cfset arguments.thestruct.folder_action = true>
		<cfset arguments.thestruct.folderid = thedetail.folder_id_r>
		<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
		<cfreturn />
	</cffunction>
	
	<!--- REMOVE MANY FILES --->
	<cffunction name="removefilemany" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Set Params --->
		<cfset session.hostdbprefix = arguments.thestruct.hostdbprefix>
		<cfset session.hostid = arguments.thestruct.hostid>
		<cfset session.theuserid = arguments.thestruct.theuserid>
		<!--- Loop --->
		<!--- Delete from files DB (including referenced data)--->
		<cfloop list="#arguments.thestruct.id#" index="i" delimiters=",">
			<cfset i = listfirst(i,"-")>
			<!--- Get file detail for log --->
			<cfquery datasource="#application.razuna.datasource#" name="thedetail">
			SELECT file_name, folder_id_r, file_name_org filenameorg, lucene_key, link_kind, link_path_url, path_to_asset
			FROM #arguments.thestruct.hostdbprefix#files
			WHERE file_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Log --->
			<cfinvoke component="extQueryCaching" method="log_assets">
				<cfinvokeargument name="theuserid" value="#arguments.thestruct.theuserid#">
				<cfinvokeargument name="logaction" value="Delete">
				<cfinvokeargument name="logdesc" value="Removed: #thedetail.file_name#">
				<cfinvokeargument name="logfiletype" value="doc">
				<cfinvokeargument name="assetid" value="#i#">
			</cfinvoke>
			<cftransaction>
				<!--- Remove --->
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #arguments.thestruct.hostdbprefix#files
				WHERE file_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				</cfquery>
				<!--- Delete from collection --->
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #arguments.thestruct.hostdbprefix#collections_ct_files
				WHERE file_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
				AND col_file_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- Delete from favorites --->
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #arguments.thestruct.hostdbprefix#users_favorites
				WHERE fav_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
				AND fav_kind = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
				AND user_id_r = <cfqueryparam value="#arguments.thestruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				<!--- Delete from Versions --->
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #arguments.thestruct.hostdbprefix#versions
				WHERE asset_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
				AND ver_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- Delete from Share Options --->
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #arguments.thestruct.hostdbprefix#share_options
				WHERE asset_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cftransaction>
			<!--- Delete labels --->
			<cfinvoke component="labels" method="label_ct_remove" id="#i#" />
			<!--- Delete from file system --->
			<cfset arguments.thestruct.id = i>
			<cfset arguments.thestruct.folder_id_r = thedetail.folder_id_r>
			<cfset arguments.thestruct.qrydetail = thedetail>
			<cfset arguments.thestruct.link_kind = thedetail.link_kind>
			<cfset arguments.thestruct.filenameorg = thedetail.filenameorg>
			<cfthread intstruct="#arguments.thestruct#">
				<cfinvoke method="deletefromfilesystem" thestruct="#attributes.intstruct#">
			</cfthread>
			<!--- Execute workflow --->
			<cfset arguments.thestruct.fileid = i>
			<cfset arguments.thestruct.file_name = thedetail.file_name>
			<cfset arguments.thestruct.thefiletype = "doc">
			<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
			<cfset arguments.thestruct.folder_action = true>
			<cfset arguments.thestruct.folderid = thedetail.folder_id_r>
			<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
		</cfloop>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
		<cfreturn />
	</cffunction>
	
	<!--- SubFunction called from deletion above --->
	<cffunction name="deletefromfilesystem" output="false">
		<cfargument name="thestruct" type="struct">
		<cftry>
			<!--- Delete in Lucene --->
			<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.id#" category="doc">
			<cfif application.razuna.storage EQ "local">
				<!--- File --->
				<cfif DirectoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#") AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
					<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#" recurse="true">
				</cfif>
				<!--- Versions --->
				<cfif DirectoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/versions/doc/#arguments.thestruct.id#") AND arguments.thestruct.id NEQ "">
					<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/versions/doc/#arguments.thestruct.id#" recurse="true">
				</cfif>
			<cfelseif application.razuna.storage EQ "nirvanix" AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
				<!--- File --->
				<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/#arguments.thestruct.qrydetail.path_to_asset#">
				<!--- Versions --->
				<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/versions/doc/#arguments.thestruct.id#">
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
				<cfinvoke component="amazon" method="deletefolder" folderpath="#arguments.thestruct.qrydetail.path_to_asset#" awsbucket="#arguments.thestruct.awsbucket#" />
				<!--- Versions --->
				<cfinvoke component="amazon" method="deletefolder" folderpath="versions/doc/#arguments.thestruct.id#" awsbucket="#arguments.thestruct.awsbucket#" />
			</cfif>
			<cfcatch type="any">
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error on removing a file from system (HostID: #arguments.thestruct.hostid#, Asset: #arguments.thestruct.id#)" dump="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
		
	<!--- GET DETAIL BY COLUMN ONLY --->
	<cffunction name="filedetail" output="false">
		<cfargument name="theid" type="string">
		<cfargument name="thecolumn" type="string">
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#filedetailfiles */ #arguments.thecolumn#
		FROM #session.hostdbprefix#files
		WHERE file_id = <cfqueryparam value="#arguments.theid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfreturn qry>
	</cffunction>
	
	<!--- GET THE FILES DETAILS --->
	<cffunction name="detail" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var theassetsize = "">
		<cfset var qry = structnew()>
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("files")>
		<!--- Get details --->
		<cfquery datasource="#variables.dsn#" name="details" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#detailfiles */ f.file_id, f.folder_id_r, f.file_extension, f.file_type, f.file_create_date, f.file_create_time, 
		f.file_change_date, f.file_change_time, f.file_owner, f.file_name, f.file_remarks, f.file_name_org, f.shared, 
		f.link_path_url, f.link_kind, f.file_size, f.file_meta, f.path_to_asset, f.cloud_url, f.cloud_url_org,
		s.set2_doc_download, s.set2_intranet_gen_download, s.set2_url_website, s.set2_path_to_assets,
		u.user_first_name, u.user_last_name, fo.folder_name
		FROM #session.hostdbprefix#files f
		LEFT JOIN #session.hostdbprefix#settings_2 s ON s.set2_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#variables.setid#"> AND s.host_id = f.host_id
		LEFT JOIN users u ON u.user_id = f.file_owner
		LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = f.folder_id_r AND fo.host_id = f.host_id
		WHERE f.file_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Get descriptions and keywords --->
		<cfquery datasource="#variables.dsn#" name="desc" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#detaildescfiles */ lang_id_r, file_keywords, file_desc
		FROM #session.hostdbprefix#files_desc
		WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Get PDF XMP values--->
		<cfif details.file_extension EQ "pdf">
			<cfquery datasource="#variables.dsn#" name="pdfxmp" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#detailxmpfiles */ author, rights, authorsposition, captionwriter, webstatement, rightsmarked
			FROM #session.hostdbprefix#files_xmp
			WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Put into struct --->
			<cfset qry.pdfxmp = pdfxmp>
		</cfif>
		<!--- Get file size on file system --->
		<cfif (application.razuna.storage NEQ "nirvanix" OR application.razuna.storage NEQ "amazon") AND (details.file_size EQ "0" OR details.file_size EQ "0" AND details.link_kind NEQ "url")>
			<cfset thefilepath = "#details.set2_path_to_assets#/#session.hostid#/#details.path_to_asset#/#details.file_name_org#">
			<cfinvoke component="global" method="getfilesize" filepath="#thefilepath#" returnvariable="theassetsize">
		<cfelse>
			<cfset theassetsize = details.file_size>
		</cfif>
		<!--- Convert the size --->
		<cfif isnumeric(theassetsize)>
			<cfinvoke component="global" method="converttomb" returnvariable="qry.thesize" thesize="#theassetsize#">
		<cfelse>
			<cfset qry.thesize = 0>
		</cfif>
		<!--- Put into struct --->
		<cfset qry.detail = details>
		<cfset qry.desc = desc>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
	
	<!--- UPDATE FILES IN THREAD --->
	<cffunction name="update" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Set arguments --->
		<cfset arguments.thestruct.dsn = variables.dsn>
		<cfset arguments.thestruct.setid = variables.setid>
		<!--- Start the thread for updating --->
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="updatethread" thestruct="#attributes.intstruct#" />
		</cfthread>
	</cffunction>
	
	<!--- SAVE THE FILES DETAILS --->
	<cffunction name="updatethread" output="false">
		<cfargument name="thestruct" type="struct">
		<cfparam name="arguments.thestruct.shared" default="F">
		<cfparam name="arguments.thestruct.what" default="">
		<cfparam name="arguments.thestruct.frombatch" default="F">
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("files")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")> 
		<!--- Loop over the file_id (important when working on more then one image) --->
		<cfloop list="#arguments.thestruct.file_id#" delimiters="," index="i">
			<cfset i = listfirst(i,"-")>
			<cfset arguments.thestruct.file_id = i>
			<!--- Save the desc and keywords --->
			<cfloop list="#arguments.thestruct.langcount#" index="langindex">
				<!--- If we come from all we need to change the desc and keywords arguments name --->
				<cfif arguments.thestruct.what EQ "all">
					<cfset alldesc = "all_desc_" & #langindex#>
					<cfset allkeywords = "all_keywords_" & #langindex#>
					<cfset thisdesc = "arguments.thestruct.file_desc_" & #langindex#>
					<cfset thiskeywords = "arguments.thestruct.file_keywords_" & #langindex#>
					<cfset "#thisdesc#" =  evaluate(alldesc)>
					<cfset "#thiskeywords#" =  evaluate(allkeywords)>
				<cfelse>
					<cfset thisdesc = "file_desc_" & #langindex#>
					<cfset thiskeywords = "file_keywords_" & #langindex#>		
				</cfif>
				<cfset l = #langindex#>
				<cfif thisdesc CONTAINS "#l#" OR thiskeywords CONTAINS "#l#">
					<cfloop list="#arguments.thestruct.file_id#" delimiters="," index="f">
						<cfquery datasource="#variables.dsn#" name="ishere">
						SELECT file_id_r
						FROM #session.hostdbprefix#files_desc
						WHERE file_id_r = <cfqueryparam value="#f#" cfsqltype="CF_SQL_VARCHAR">
						AND lang_id_r = <cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">
						</cfquery>
						<cfif ishere.recordcount IS NOT 0>
							<cfquery datasource="#variables.dsn#">
							UPDATE #session.hostdbprefix#files_desc
							SET file_desc = <cfqueryparam value="#ltrim(evaluate(thisdesc))#" cfsqltype="cf_sql_varchar">,
							file_keywords = <cfqueryparam value="#ltrim(evaluate(thiskeywords))#" cfsqltype="cf_sql_varchar">
							WHERE file_id_r = <cfqueryparam value="#f#" cfsqltype="CF_SQL_VARCHAR">
							AND lang_id_r = <cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">
							</cfquery>
						<cfelse>
							<cfquery datasource="#variables.dsn#">
							INSERT INTO #session.hostdbprefix#files_desc
							(id_inc, file_id_r, lang_id_r, file_desc, file_keywords, host_id)
							VALUES(
							<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#f#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">,
							<cfqueryparam value="#ltrim(evaluate(thisdesc))#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#ltrim(evaluate(thiskeywords))#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
							)
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
			<!--- Only if not from batch function --->
			<cfif arguments.thestruct.frombatch NEQ "T">
				<!--- If PDF save XMP data --->
				<cfif arguments.thestruct.file_extension EQ "pdf" AND arguments.thestruct.link_kind NEQ "url">
					<!--- Check if info is in DB --->
					<cfquery datasource="#variables.dsn#" name="qryfilesxmp">
					SELECT asset_id_r
					FROM #session.hostdbprefix#files_xmp
					WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- If record is here do a update else a insert --->
					<cfif qryfilesxmp.recordcount EQ 1>
						<cfquery datasource="#variables.dsn#">
						UPDATE #session.hostdbprefix#files_xmp
						SET
						author = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.author#">, 
						rights = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rights#">, 
						authorsposition = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.authorsposition#">, 
						captionwriter = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.captionwriter#">, 
						webstatement = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.webstatement#">, 
						rightsmarked = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rightsmarked#">
						WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
					<cfelse>
						<cfquery datasource="#variables.dsn#">
						INSERT INTO #session.hostdbprefix#files_xmp
						(asset_id_r, author, rights, authorsposition, captionwriter, webstatement, rightsmarked, host_id)
						VALUES(
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.author#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rights#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.AuthorsPosition#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.CaptionWriter#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.WebStatement#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rightsmarked#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
						</cfquery>
					</cfif>
				</cfif>
				<!--- Save to the files table --->
				<cfif structkeyexists(arguments.thestruct,"file_name")>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#files
					SET file_name = <cfqueryparam value="#arguments.thestruct.file_name#" cfsqltype="cf_sql_varchar">,
					shared = <cfqueryparam value="#arguments.thestruct.shared#" cfsqltype="cf_sql_varchar">,
					file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					file_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					<!--- <cfif isdefined("remarks")>, file_remarks = <cfqueryparam value="#remarks#" cfsqltype="cf_sql_varchar"></cfif> --->
					WHERE file_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				</cfif>
			</cfif>
			<cfquery datasource="#variables.dsn#" name="qry">
			SELECT file_name_org, file_name, path_to_asset
			FROM #session.hostdbprefix#files
			WHERE file_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Select the record to get the original filename or assign if one is there --->
			<cfif NOT structkeyexists(arguments.thestruct,"filenameorg") OR arguments.thestruct.filenameorg EQ "">
				<cfset arguments.thestruct.qrydetail.filenameorg = qry.file_name_org>
				<cfset arguments.thestruct.filenameorg = qry.file_name_org>
				<cfset arguments.thestruct.file_name = qry.file_name>
			<cfelse>
				<cfset arguments.thestruct.qrydetail.filenameorg = arguments.thestruct.filenameorg>
			</cfif>
			<!--- Lucene --->
			<cfset arguments.thestruct.qrydetail.folder_id_r = arguments.thestruct.folder_id>
			<cfset arguments.thestruct.qrydetail.path_to_asset = qry.path_to_asset>
			<cfif application.razuna.storage EQ "local">
				<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.file_id#" category="doc">
				<cfinvoke component="lucene" method="index_update" dsn="#variables.dsn#" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.file_id#" category="doc">
			<!--- Nirvanix --->
			<cfelseif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.file_id#" category="doc" notfile="T">
				<cfinvoke component="lucene" method="index_update" dsn="#variables.dsn#" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.file_id#" category="doc" notfile="T">
			</cfif>
			<!--- Log --->
			<cfset log = #log_assets(theuserid=session.theuserid,logaction='Update',logdesc='Updated: #arguments.thestruct.file_name#',logfiletype='doc',assetid='#arguments.thestruct.file_id#')#>
		</cfloop>
	</cffunction>
	
	<!--- SERVE THE FILE TO THE BROWSER --->
	<cffunction name="servefile" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfparam name="arguments.thestruct.zipit" default="T">
		<cfparam name="arguments.thestruct.v" default="o">
		<cfset var qry = structnew()>
		<cfset qry.thefilename = "">
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery name="qFile" datasource="#variables.dsn#" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#servefileimg */ img_id, img_filename, img_extension, thumb_extension, img_filename_org filenameorg, folder_id_r,
			link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Correct filename for thumbnail or original --->
			<cfif arguments.thestruct.v EQ "o">
				<cfset qry.thefilename = listfirst(qfile.img_filename, ".") & "." & qfile.img_extension>
			<cfelse>
				<cfset qry.thefilename = "thumb_" & qfile.img_id & "." & qfile.thumb_extension>
			</cfif>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery name="qFile" datasource="#variables.dsn#" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#servefilevid */ vid_filename, vid_extension, vid_name_org filenameorg, folder_id_r, link_kind, link_path_url,
			path_to_asset, cloud_url, cloud_url_org
			FROM #session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Correct filename --->
			<cfset qry.thefilename = listfirst(qfile.vid_filename, ".") & "." & qfile.vid_extension>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery name="qFile" datasource="#variables.dsn#" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#servefileaud */ aud_name, aud_extension, aud_name_org filenameorg, folder_id_r, link_kind, link_path_url,
			path_to_asset, cloud_url, cloud_url_org
			FROM #session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Correct filename --->
			<cfset qry.thefilename = listfirst(qfile.aud_name, ".") & "." & qfile.aud_extension>
		<!--- Documents --->
		<cfelse>
			<cfquery name="qFile" datasource="#variables.dsn#" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#servefilefile */ file_name, file_extension, file_name_org filenameorg, folder_id_r, link_path_url, link_kind, 
			link_path_url, path_to_asset, cloud_url, cloud_url_org
			FROM #session.hostdbprefix#files
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Correct filename --->
			<cfset qry.thefilename = listfirst(qfile.file_name, ".") & "." & qfile.file_extension>
		</cfif>
		<!--- If name contains spaces then convert them to _ or else an incorrect name is being shown during download --->
		<cfset qry.thefilename = replacenocase(qry.thefilename," ","_","all")>
		<!--- Set variables --->
		<!--- <cfset qry.direct = "T"> --->
		<cfset qry.qFile = qFile>
		<cfreturn qry>
	</cffunction>
	
	<!--- WRITE FILE TO SYSTEM --->
	<cffunction name="writefile" output="true">
		<cfargument name="thestruct" type="struct">
		<cfparam name="arguments.thestruct.sendaszip" default="F">
		<!--- The tool paths --->
		<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
		<!--- Query --->
		<cfquery datasource="#variables.dsn#" name="getbin" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#writefilefile */ file_extension, folder_id_r, file_name_org, link_kind, link_path_url, path_to_asset, cloud_url_org
		FROM #session.hostdbprefix#files
		WHERE file_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Rename --->
		<!--- If filename contains /\ --->
		<cfset newname = replace(arguments.thestruct.zipname,"/","-","all")>
		<cfset newname = replace(newname,"\","-","all")>
		<cfset newname = replacenocase(newname, " ", "_", "All")>
		<cfset newname = replacenocase(newname, ".#getbin.file_extension#", "", "ALL")>
		<cfset newnamenoext = newname>
		<cfset newname = "#newname#" & ".#getbin.file_extension#">
		<!--- Put variables into struct for threads --->
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset arguments.thestruct.getbin = getbin>
		<cfset arguments.thestruct.newname = newname>
		<!--- Decide which path to zip --->
		<cfif application.razuna.storage EQ "local" AND getbin.link_kind EQ "">
			<!--- Copy file to the outgoing folder --->
			<cfthread name="download#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.getbin.path_to_asset#/#attributes.intstruct.getbin.file_name_org#" destination="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.newname#" mode="775">
			</cfthread>
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix" AND getbin.link_kind EQ "">
			<cfthread name="download#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<cfhttp url="#attributes.intstruct.getbin.cloud_url_org#" file="#attributes.intstruct.getbin.file_name_org#" path="#attributes.intstruct.thepath#/outgoing"></cfhttp>
			</cfthread>
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon" AND getbin.link_kind EQ "">
			<!--- Download file --->
			<cfthread name="download#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<cfinvoke component="amazon" method="Download">
					<cfinvokeargument name="key" value="/#attributes.intstruct.getbin.path_to_asset#/#attributes.intstruct.getbin.file_name_org#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.getbin.file_name_org#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
		<!--- If this is a linked asset --->
		<cfelseif getbin.link_kind EQ "lan">
			<!--- Copy file to the outgoing folder --->
			<cfthread name="download#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<cffile action="copy" source="#attributes.intstruct.getbin.link_path_url#" destination="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.newname#" mode="775">
			</cfthread>
		</cfif>
		<!--- Wait for the thread above until the file is downloaded fully --->
		<cfthread action="join" name="download#arguments.thestruct.file_id#" />
		<!--- Remove any file with the same name in this directory. Wrap in a cftry so if the file does not exist we don't have a error --->
		<cftry>
			<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#newnamenoext#.zip">
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- Zip the file --->	
		<cfzip action="create" ZIPFILE="#arguments.thestruct.thepath#/outgoing/#newnamenoext#.zip" source="#arguments.thestruct.thepath#/outgoing/#newname#" recurse="true" timeout="300" />
		<!--- Remove the file --->
		<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#newname#">
		<cfset newname="#newnamenoext#.zip">
		<!--- Return --->
		<cfreturn newname>
	</cffunction>
	
	<!--- MOVE FILE IN THREADS --->
	<cffunction name="movethread" output="true">
		<cfargument name="thestruct" type="struct">
		<cfparam name="arguments.thestruct.doc_id" default="">
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("files")>
		<cfset variables.cachetoken = resetcachetoken("folders")>
		<!--- Loop over files --->
		<cfloop list="#arguments.thestruct.file_id#" delimiters="," index="fileid">
			<cfset arguments.thestruct.doc_id = "">
			<cfset arguments.thestruct.doc_id = listfirst(fileid,"-")>
			<!--- If we are coming from a overview ids come with type --->
			<!--- <cfif arguments.thestruct.thetype EQ "all" AND fileid CONTAINS "-doc">
				<cfset arguments.thestruct.doc_id = listfirst(fileid,"-")>
			<cfelseif arguments.thestruct.thetype NEQ "all">
				<cfset arguments.thestruct.doc_id = fileid>
			</cfif> --->
			<cfif arguments.thestruct.doc_id NEQ "">
				<!--- <cfinvoke method="move" thestruct="#arguments.thestruct#" /> --->
				<cfthread intstruct="#arguments.thestruct#">
					<cfinvoke method="move" thestruct="#attributes.intstruct#" />
				</cfthread>
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- MOVE FILE --->
	<cffunction name="move" output="false">
		<cfargument name="thestruct" type="struct">
			<cfset arguments.thestruct.qrydoc = "">
			<!--- Get file details --->
			<cfinvoke method="filedetail" theid="#arguments.thestruct.doc_id#" thecolumn="file_name, folder_id_r, file_name_org filenameorg, lucene_key, link_kind, path_to_asset" returnvariable="arguments.thestruct.qrydoc">
			<!--- Ignore if the folder id is the same --->
			<cfif arguments.thestruct.folder_id NEQ arguments.thestruct.qrydoc.folder_id_r>
				<!--- Update DB --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
				WHERE file_id = <cfqueryparam value="#arguments.thestruct.doc_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Log --->
				<cfset log = #log_assets(theuserid=session.theuserid,logaction='Move',logdesc='Moved: #arguments.thestruct.qrydoc.file_name#',logfiletype='doc',assetid='#arguments.thestruct.doc_id#')#>
				<!--- Execute workflow --->
				<cfset arguments.thestruct.fileid = arguments.thestruct.doc_id>
				<cfset arguments.thestruct.file_name = arguments.thestruct.qrydoc.file_name>
				<cfset arguments.thestruct.thefiletype = "doc">
				<cfinvoke component="plugins" method="getactions" theaction="on_file_move" args="#arguments.thestruct#" />
				<cfset arguments.thestruct.folder_action = true>
				<cfset arguments.thestruct.folderid = arguments.thestruct.folder_id>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_move" args="#arguments.thestruct#" />
			</cfif>
		<cfreturn />
	</cffunction>
	
	<!--- List the PDF image files to be shown to the browser --->
	<cffunction name="pdfjpgs" output="true">
		<cfargument name="thestruct" type="struct">
		<cfset lqry = structnew()>
		<cfset lqry.thepdfjpgslist = "">
		<!--- Get some file details --->
		<cfinvoke method="filedetail" theid="#arguments.thestruct.file_id#" thecolumn="folder_id_r, path_to_asset" returnvariable="qry_thefile">
		<!--- Local --->
		<cfif application.razuna.storage EQ "local">
			<!--- Get the directory list --->
			<cfdirectory action="list" directory="#arguments.thestruct.assetpath#/#session.hostid#/#qry_thefile.path_to_asset#/razuna_pdf_images/" name="lqry.qry_pdfjpgs" filter="*.jpg">
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<!--- Call ListFolder --->
			<cfinvoke component="nirvanix" method="listfolder" returnvariable="filesxml">
				<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
				<cfinvokeargument name="folderpath" value="/#qry_thefile.path_to_asset#/razuna_pdf_images/">
				<cfinvokeargument name="pagenumber" value="1">
				<cfinvokeargument name="pagesize" value="100">
			</cfinvoke>
			<!--- XPath of the XML returned from Nirvanix --->
			<cfset mysearch = xmlsearch(filesxml, "/Response/ListFolder/File")>
			<!--- Set an empty query --->
			<cfset lqry.qry_pdfjpgs = QueryNew("Name")>
			<!--- Get lenght of Array --->
			<cfset nr = arraylen(mysearch)>
			<!--- Loop over XML and add it to query --->
			<cfif nr IS NOT 0>
				<cfloop from="1" to="#nr#" index="i">
					<cfset newRow = QueryAddRow(lqry.qry_pdfjpgs, i)>
					<cfset temp = QuerySetCell(lqry.qry_pdfjpgs, "Name", "#mysearch[i].Name.xmltext#", i)>
				</cfloop>
			</cfif>
			<!--- QoQ to filter out the null values since Nirvanix pagesize is so huge --->
			<cfquery dbtype="query" name="lqry.qry_pdfjpgs">
			SELECT *
			FROM lqry.qry_pdfjpgs
			WHERE name IS NOT NULL
			</cfquery>
		</cfif>
		<!--- Where to start in the loop. When only one record found start with 1 else with 0 --->
		<cfif lqry.qry_pdfjpgs.recordcount EQ 1>
			<cfset theloopstart = 1>
			<cfset looptil = lqry.qry_pdfjpgs.recordcount>
		<cfelse>
			<cfset theloopstart = 0>
			<cfset looptil = lqry.qry_pdfjpgs.recordcount - 1>
		</cfif>
		<!--- Loop over the directory list and replace the name with the actual record number found --->
		<cfloop from="#theloopstart#" to="#looptil#" index="i">
			<cfset lqry.thepdfjpgslist = lqry.thepdfjpgslist & "," & replacenocase(lqry.qry_pdfjpgs.name,"-0","-#i#","all")>
			<!--- <cfoutput>#replacenocase(qry_pdfjpgs.name,"-0","-#i#","all")#<br /></cfoutput> --->
		</cfloop>
		<!--- Return --->
		<cfreturn lqry>
	</cffunction>

	<!--- GET THE DETAILS FOR BASKET --->
	<cffunction name="detailforbasket" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Qry. We take the query and do a IN --->
		<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#detailforbasketfile */ file_id, file_extension, file_extension, file_size, folder_id_r, file_name_org, link_kind, link_path_url, path_to_asset, cloud_url, file_name filename
		FROM #session.hostdbprefix#files
		WHERE file_id 
		<cfif arguments.thestruct.qrybasket.recordcount EQ 0>
		= '0'
		<cfelse>
		IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qrybasket.cart_product_id)#" list="true">)
		</cfif>
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!--- Get description and keywords for print --->
	<cffunction name="gettext" output="false">
		<cfargument name="qry" type="query">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qryintern" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#gettextfile */ file_id_r tid, file_desc description, file_keywords keywords
		FROM #session.hostdbprefix#files_desc
		WHERE file_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.qry.id)#" list="true">)
		AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
		</cfquery>
		<!--- Return --->
		<cfreturn qryintern>
	</cffunction>
	
	<!--- GET RECORDS WITH EMTPY VALUES --->
	<cffunction name="getempty" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getemptyfile */
		file_id id, file_name, folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
		path_to_asset, lucene_key, file_name_org filenameorg
		FROM #session.hostdbprefix#files
		WHERE (folder_id_r IS NULL OR folder_id_r = '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
	
	<!--- GET PDF XMP --->
	<cffunction name="getpdfxmp" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="pdfxmp" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getpdfxmp */ author, rights, authorsposition, captionwriter, webstatement, rightsmarked
		FROM #session.hostdbprefix#files_xmp
		WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn pdfxmp>
	</cffunction>

	<!--- Check for existing MD5 mash records --->
	<cffunction name="checkmd5" output="false">
		<cfargument name="md5hash" type="string">
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#checkmd5 */ file_id
		FROM #session.hostdbprefix#files
		WHERE hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.md5hash#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfreturn qry />
	</cffunction>
	
</cfcomponent>