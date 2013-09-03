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
<cfset variables.cachetoken = getcachetoken("images")>

<!--- COUNT ALL IMAGES IN A FOLDER --->
<cffunction name="getFolderCount" description="COUNT ALL IMAGES IN A FOLDER" output="false" access="public" returntype="numeric">
	<cfargument name="folder_id" required="true" type="string">
	<cfargument name="file_extension" required="false" type="string" default="">
	<!--- init local vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getFolderCountimg */ COUNT(*) AS folderCount
		FROM #session.hostdbprefix#images
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.folder_id#">
		AND (img_group IS NULL OR img_group = '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!--- Nirvanix and in Admin --->
		<cfif session.thisapp EQ "admin">
			AND lower(shared) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		</cfif>
		<!--- todo : filter for file-extension --->
	</cfquery>
	<cfreturn qLocal.folderCount />
</cffunction>

<!--- GET ALL RECORDS OF THIS TYPE IN A FOLDER --->
<cffunction name="getFolderAssets" access="public" description="GET ALL RECORDS OF THIS TYPE IN A FOLDER" output="false" returntype="query">
	<cfargument name="folder_id" type="string" required="true">
	<cfargument name="ColumnList" required="false" type="string" hint="the column list for the selection" default="img_id">
	<cfargument name="file_extension" required="false" type="string" default="">
	<cfargument name="offset" type="numeric" required="false" default="0">
	<cfargument name="rowmaxpage" type="numeric" required="false" default="0">
	<cfargument name="thestruct" type="struct" required="false" default="">
	<!--- init local vars --->
	<cfset var qLocal = 0>
	<cfset var thefolderlist = 0>
	<!--- Set pages var --->
	<cfparam name="arguments.thestruct.pages" default="">
	<cfparam name="arguments.thestruct.thisview" default="">
	<cfparam name="session.customfileid" default="">
	<!--- If we need to show subfolders --->
	<cfif session.showsubfolders EQ "T">
		<cfinvoke component="folders" method="getfoldersinlist" dsn="#variables.dsn#" folder_id="#arguments.folder_id#" hostid="#session.hostid#" database="#variables.database#" returnvariable="thefolders">
		<cfset thefolderlist = arguments.folder_id & "," & ValueList(thefolders.folder_id)>
	<cfelse>
		<cfset thefolderlist = arguments.folder_id & ",">
	</cfif>
	<!--- Set the session for offset correctly if the total count of assets in lower then the total rowmaxpage --->
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
		<cfset var thecolumnlist = replacenocase(arguments.columnlist,"i.","","all")>
		<!--- Query --->
		<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getFolderAssetsimg */ rn, #thecolumnlist#, keywords, description, labels, filename_forsort, size, hashtag, date_create, date_change
		FROM (
			SELECT ROWNUM AS rn, #thecolumnlist#, keywords, description, labels, filename_forsort, size, hashtag, date_create, date_change
			FROM (
				SELECT #Arguments.ColumnList#, it.img_keywords keywords, it.img_description description, '' as labels, lower(i.img_filename) filename_forsort, i.img_size size, i.hashtag,
				i.img_create_time date_create, i.img_change_time date_change
				FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
				WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND (i.img_group IS NULL OR i.img_group = '')
				AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				ORDER BY #sortby#
				)
			WHERE ROWNUM <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#max#">
			)
		WHERE rn > <cfqueryparam cfsqltype="cf_sql_numeric" value="#min#">
		</cfquery>
	<!--- DB2 --->
	<cfelseif variables.database EQ "db2">
		<!--- Clean columnlist --->
		<cfset var thecolumnlist = replacenocase(arguments.columnlist,"i.","","all")>
		<!--- Query --->
		<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getFolderAssetsimg */ #thecolumnlist#, it.img_keywords keywords, it.img_description description, '' as labels, filename_forsort, size, hashtag, date_create, date_change
		FROM (
			SELECT row_number() over() as rownr, i.*, it.*,
			lower(i.img_filename) filename_forsort, i.img_size size, i.hashtag, i.img_create_time date_create, i.img_change_time date_change
			FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
			WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND (i.img_group IS NULL OR i.img_group = '')
			AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
		<!--- MSSQL --->
		<cfif variables.database EQ "mssql" AND (arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current")>
			SELECT * FROM (
			SELECT ROW_NUMBER() OVER ( ORDER BY #sortby# ) AS RowNum,sorted_inline_view.* FROM (
		</cfif>
		SELECT /* #variables.cachetoken#getFolderAssetsimg */ #Arguments.ColumnList#, it.img_keywords keywords, it.img_description description, '' as labels, lower(i.img_filename) filename_forsort, i.img_size size, i.hashtag, i.img_create_time date_create, i.img_change_time date_change
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">it
				<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename">i
				<cfelse>x
				</cfif>.#m#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1 LEFT JOIN #session.hostdbprefix#xmp x ON x.id_r = i.img_id
		WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (i.img_group IS NULL OR i.img_group = '')
		AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!--- MSSQL --->
		<cfif variables.database EQ "mssql" AND (arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current")>
			) sorted_inline_view
			 ) resultSet
			  WHERE RowNum > #mysqloffset# AND RowNum <= #mysqloffset+session.rowmaxpage# 
		</cfif>
		<!--- Show the limit only if pages is null or current (from print) --->
		<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
			<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
				ORDER BY #sortby# LIMIT #mysqloffset#, #session.rowmaxpage#
			</cfif>
		</cfif>
		</cfquery>
	</cfif>
	<!--- If coming from custom view and the session.customfileid is not empty --->
	<cfif session.customfileid NEQ "">
		<cfquery dbtype="query" name="qLocal">
		SELECT *
		FROM qLocal
		WHERE img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
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
			WHERE ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#img_id#">
			</cfquery>
			<!--- Add labels query --->
			<cfif qry_l.recordcount NEQ 0>
				<cfset QuerySetCell(qLocal, "labels", valueList(qry_l.ct_label_id), currentRow)>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Return --->
	<cfreturn qLocal />
</cffunction>

<!--- GET ALL RECORD-DETAILS OF THIS TYPE IN A FOLDER --->
<cffunction name="getFolderAssetDetails" access="public" description="GET ALL RECORD-DETAILS OF THIS TYPE IN A FOLDER" output="false" returntype="query">
	<cfargument name="folder_id" type="string" required="true">
	<cfargument name="ColumnList" required="false" type="string" hint="the column list for the selection" default="i.img_id, i.img_group, i.img_publisher, i.img_filename, i.folder_id_r, i.img_custom_id, i.img_online, i.img_owner, i.img_create_date, i.img_create_time, i.img_change_date, i.img_change_time, i.img_ranking rank, i.img_single_sale, i. img_is_new, i.img_selection, i.img_in_progress, i.img_alignment, i.img_license, i.img_dominant_color, i.img_color_mode, img_image_type, i.img_category_one, i.img_remarks">
	<cfargument name="file_extension" type="string" required="false" default="">
	<cfargument name="offset" type="numeric" required="true" default="0">
	<cfargument name="rowmaxpage" type="numeric" required="true" default="50">
	<cfargument name="thestruct" type="struct" required="false" default="">
	<!--- Set thestruct if not here --->
	<cfif NOT isstruct(arguments.thestruct)>
		<cfset arguments.thestruct = structnew()>
	</cfif>
	<cfreturn getFolderAssets(folder_id=Arguments.folder_id, ColumnList=Arguments.ColumnList, file_extension=Arguments.file_extension, offset=session.offset, rowmaxpage=session.rowmaxpage, thestruct=arguments.thestruct)>
</cffunction>

<!--- GET DETAILS OF ONE RECORD --->
<cffunction name="getAssetDetails" access="public" output="true" returntype="query">
	<cfargument name="file_id" type="string" required="true">
	<cfargument name="ColumnList" required="false" type="string" hint="the column list for the selection" default="*">
	<!--- init local vars --->
	<cfset qLocal = 0>
	<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getAssetDetailsimg */ #Arguments.ColumnList#
	FROM #session.hostdbprefix#images
	WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.file_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qLocal />
</cffunction>

<!--- GET DETAILS OF ONE RECORD SIMPLE!!! --->
<cffunction name="filedetail" access="public" output="false" returntype="query">
	<cfargument name="theid" type="string" required="true">
	<cfargument name="thecolumn" type="string" required="true">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("images")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#filedetailimg */ #arguments.thecolumn#
		FROM #session.hostdbprefix#images
		WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfreturn qry />
</cffunction>

<!--- REMOVE THE IMAGE --->
<cffunction name="removeimage" output="false">
	<cfargument name="thestruct" type="struct">
		<!--- Get file detail for log --->
		<cfinvoke method="filedetail" theid="#arguments.thestruct.id#" thecolumn="img_filename, folder_id_r, img_filename_org filenameorg, lucene_key, link_kind, link_path_url, path_to_asset, thumb_extension, img_group" returnvariable="thedetail">
		<cfif thedetail.recordcount NEQ 0>
			<!--- Execute workflow --->
			<cfset arguments.thestruct.fileid = arguments.thestruct.id>
			<cfset arguments.thestruct.file_name = thedetail.img_filename>
			<cfset arguments.thestruct.thefiletype = "img">
			<cfset arguments.thestruct.folder_id = thedetail.folder_id_r>
			<cfset arguments.thestruct.folder_action = false>
			<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
			<cfset arguments.thestruct.folder_action = true>
			<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
			<!--- Update main record with dates --->
			<cfinvoke component="global" method="update_dates" type="img" fileid="#thedetail.img_group#" />
			<!--- Delete from files DB (including referenced data) --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Delete from collection --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from favorites --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#users_favorites
			WHERE fav_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
			AND fav_kind = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			AND user_id_r = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete from Versions --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#versions
			WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
			AND ver_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Share Options --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#share_options
			WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete labels --->
			<cfinvoke component="labels" method="label_ct_remove" id="#arguments.thestruct.id#" />
			<!--- Custom field values --->
			<cfinvoke component="custom_fields" method="delete_values" fileid="#arguments.thestruct.id#" />
			<!--- Log --->
			<cfinvoke component="extQueryCaching" method="log_assets">
				<cfinvokeargument name="theuserid" value="#session.theuserid#">
				<cfinvokeargument name="logaction" value="Delete">
				<cfinvokeargument name="logdesc" value="Deleted: #thedetail.img_filename#">
				<cfinvokeargument name="logfiletype" value="img">
				<cfinvokeargument name="assetid" value="#arguments.thestruct.id#">
			</cfinvoke>
			<!--- Delete from file system --->
			<cfset arguments.thestruct.hostid = session.hostid>
			<cfset arguments.thestruct.folder_id_r = thedetail.folder_id_r>
			<cfset arguments.thestruct.qrydetail = thedetail>
			<cfset arguments.thestruct.link_kind = thedetail.link_kind>
			<cfset arguments.thestruct.filenameorg = thedetail.filenameorg>
			<cfthread intstruct="#arguments.thestruct#">
				<cfinvoke method="deletefromfilesystem" thestruct="#attributes.intstruct#">
			</cfthread>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("images")>
			<cfset resetcachetoken("folders")>
			<cfset resetcachetoken("search")>
		</cfif>
	<cfreturn />
</cffunction>

<!--- TRASH THE IMAGE --->
<cffunction name="trashimage" output="false">
	<cfargument name="thestruct" type="struct">
		<!--- Update in_trash --->
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images 
			SET in_trash=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.trash#">
			WHERE img_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("images")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
		<!--- return --->
		<cfreturn />
</cffunction>

<!--- TRASH MANY IMAGE --->
<cffunction name="trashimagemany" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Loop --->
	<cfloop list="#arguments.thestruct.id#" index="i" delimiters=",">
		<cfset i = listfirst(i,"-")>
		<!--- Update in_trash --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#images 
		SET in_trash=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.trash#">
		WHERE img_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
		</cfquery>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("images")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfreturn />
</cffunction>

<!--- Get images from trash --->
<cffunction name="gettrashimage" output="false" returntype="Query">
	<!--- Param --->
	<cfset var qry_image = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("images")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_image" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#gettrashimage */ i.img_id AS id, i.img_filename AS filename, i.folder_id_r, i.thumb_extension AS ext,
	i.img_filename_org AS filename_org, 'img' AS kind, i.link_kind, i.path_to_asset, i.cloud_url, i.cloud_url_org, 
	i.hashtag, 'false' AS in_collection, 'images' as what, '' AS folder_main_id_r
	<!--- Permfolder --->
	<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
		, 'X' as permfolder
	<cfelse>
		,
		CASE
			WHEN (SELECT DISTINCT fg5.grp_permission
			FROM #session.hostdbprefix#folders_groups fg5
			WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fg5.folder_id_r = i.folder_id_r
			AND fg5.grp_id_r = '0') = 'R' THEN 'R'
			WHEN (SELECT DISTINCT fg5.grp_permission
			FROM #session.hostdbprefix#folders_groups fg5
			WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fg5.folder_id_r = i.folder_id_r
			AND fg5.grp_id_r = '0') = 'W' THEN 'W'
			WHEN (SELECT DISTINCT fg5.grp_permission
			FROM #session.hostdbprefix#folders_groups fg5
			WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fg5.folder_id_r = i.folder_id_r
			AND fg5.grp_id_r = '0') = 'X' THEN 'X'
			<cfloop list="#session.thegroupofuser#" delimiters="," index="i">
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = i.folder_id_r
				AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'R' THEN 'R'
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = i.folder_id_r
				AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'W' THEN 'W'
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = i.folder_id_r
				AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'X' THEN 'X'
			</cfloop>
			ELSE 'R'
		END as permfolder
	</cfif>
	FROM #session.hostdbprefix#images i 
	WHERE i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfif qry_image.RecordCount NEQ 0>
		<cfset myArray = arrayNew( 1 )>
		<cfset temp= ArraySet(myArray, 1, qry_image.RecordCount, "False")>
		<cfloop query="qry_image">
			<cfquery name="alert_col" datasource="#application.razuna.datasource#">
			SELECT file_id_r
			FROM #session.hostdbprefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR"> 
			</cfquery>
			<cfif alert_col.RecordCount NEQ 0>
				<cfset temp = QuerySetCell(qry_image, "in_collection", "True", currentRow  )>
			</cfif>
		</cfloop> 
	</cfif>
	<cfreturn qry_image />
</cffunction>

<!--- RESTORE THE IMAGE --->
<cffunction name="restoreimage" output="false" returntype="any" >
	<cfargument name="thestruct" type="struct">
	<!--- check the parent folder is exist --->
	<cfquery datasource="#application.razuna.datasource#" name="thedetail">
		SELECT folder_main_id_r,folder_id_r FROM #session.hostdbprefix#folders 
		WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfset local = structNew()>
	<cfif thedetail.RecordCount EQ 0>
		<cfset local.istrash = "trash">
	<cfelse>
		<cfquery datasource="#application.razuna.datasource#" name="dir_parent_id">
			SELECT folder_id,folder_id_r,in_trash FROM #session.hostdbprefix#folders 
			WHERE folder_main_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thedetail.folder_main_id_r#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfloop query="dir_parent_id">
			<cfquery datasource="#application.razuna.datasource#" name="get_qry">
				SELECT folder_id,in_trash FROM #session.hostdbprefix#folders 
				WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dir_parent_id.folder_id_r#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfif get_qry.in_trash EQ 'T'>
				<cfset local.istrash = "trash">
			<cfelseif get_qry.folder_id EQ dir_parent_id.folder_id_r AND get_qry.in_trash EQ 'F'>
				<cfset local.root = "yes">
				<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#images 
					SET in_trash=<cfqueryparam cfsqltype="cf_sql_varchar" value="F">
					WHERE img_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("images")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
	</cfif>
	<!--- Set is_trash --->
	<cfif isDefined('local.istrash') AND  local.istrash EQ "trash">
		<cfset var is_trash = "intrash">
	<cfelse>
		<cfset var is_trash = "notrash">
	</cfif>
	<cfreturn is_trash />
</cffunction>

<!--- REMOVE MANY IMAGE --->
<cffunction name="removeimagemany" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Set Params --->
	<cfset session.hostdbprefix = arguments.thestruct.hostdbprefix>
	<cfset session.hostid = arguments.thestruct.hostid>
	<cfset session.theuserid = arguments.thestruct.theuserid>
	<cfparam name="arguments.thestruct.fromfolderremove" default="false" />
	<!--- Loop --->
	<cfloop list="#arguments.thestruct.id#" index="i" delimiters=",">
		<cfset i = listfirst(i,"-")>
		<!--- Get file detail for log --->
		<cfinvoke method="filedetail" theid="#i#" thecolumn="img_filename, folder_id_r, img_filename_org filenameorg, lucene_key, link_kind, link_path_url, path_to_asset, thumb_extension" returnvariable="thedetail">
		<cfif thedetail.recordcount NEQ 0>
			<!--- Execute workflow (but only if we DO NOT come from the remove folder) --->
			<cfif !arguments.thestruct.fromfolderremove>
				<cfset arguments.thestruct.fileid = i>
				<cfset arguments.thestruct.file_name = thedetail.img_filename>
				<cfset arguments.thestruct.thefiletype = "img">
				<cfset arguments.thestruct.folder_id = thedetail.folder_id_r>
				<cfset arguments.thestruct.folder_action = false>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
				<cfset arguments.thestruct.folder_action = true>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
			</cfif>
			<!--- Log --->
			<cfinvoke component="extQueryCaching" method="log_assets">
				<cfinvokeargument name="theuserid" value="#session.theuserid#">
				<cfinvokeargument name="logaction" value="Delete">
				<cfinvokeargument name="logdesc" value="Deleted: #thedetail.img_filename#">
				<cfinvokeargument name="logfiletype" value="img">
				<cfinvokeargument name="assetid" value="#i#">
			</cfinvoke>
			<!--- Delete from files DB (including referenced data)--->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#images
			WHERE img_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Delete from collection --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from favorites --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#users_favorites
			WHERE fav_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND fav_kind = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			AND user_id_r = <cfqueryparam value="#arguments.thestruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete from Versions --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#versions
			WHERE asset_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND ver_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Share Options --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#share_options
			WHERE asset_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete labels --->
			<cfinvoke component="labels" method="label_ct_remove" id="#i#" />
			<!--- Custom field values --->
			<cfinvoke component="custom_fields" method="delete_values" fileid="#i#" />
			<!--- Delete from file system --->
			<cfset arguments.thestruct.id = i>
			<cfset arguments.thestruct.folder_id_r = thedetail.folder_id_r>
			<cfset arguments.thestruct.qrydetail = thedetail>
			<cfset arguments.thestruct.link_kind = thedetail.link_kind>
			<cfset arguments.thestruct.filenameorg = thedetail.filenameorg>
			<cfthread intstruct="#arguments.thestruct#">
				<cfinvoke method="deletefromfilesystem" thestruct="#attributes.intstruct#">
			</cfthread>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("images")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfreturn />
</cffunction>

<!--- SubFunction called from deletion above --->
<cffunction name="deletefromfilesystem" output="false">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<!--- Delete in Lucene --->
		<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.id#" category="img">
		<!--- Delete File --->
		<cfif application.razuna.storage EQ "local">
			<cfif DirectoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#") AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
				<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#" recurse="true">
			</cfif>
			<!--- Versions --->
			<cfif DirectoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/versions/img/#arguments.thestruct.id#") AND arguments.thestruct.id NEQ "">
				<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/versions/img/#arguments.thestruct.id#" recurse="true">
			</cfif>
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<cfif arguments.thestruct.qrydetail.path_to_asset NEQ "">
				<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/#arguments.thestruct.qrydetail.path_to_asset#">
				<!--- Versions --->
				<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/versions/img/#arguments.thestruct.id#">
			</cfif>		
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<cfif arguments.thestruct.qrydetail.path_to_asset NEQ "">
				<cfinvoke component="amazon" method="deletefolder" folderpath="#arguments.thestruct.qrydetail.path_to_asset#" awsbucket="#arguments.thestruct.awsbucket#" />
				<!--- Versions --->
				<cfinvoke component="amazon" method="deletefolder" folderpath="versions/img/#arguments.thestruct.id#" awsbucket="#arguments.thestruct.awsbucket#" />
			</cfif>
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai">
			<cfif arguments.thestruct.qrydetail.path_to_asset NEQ "">
				<!--- Remove original --->
				<cfinvoke component="akamai" method="Delete">
					<cfinvokeargument name="theasset" value="">
					<cfinvokeargument name="thetype" value="#arguments.thestruct.akaimg#">
					<cfinvokeargument name="theurl" value="#arguments.thestruct.akaurl#">
					<cfinvokeargument name="thefilename" value="#arguments.thestruct.qrydetail.filenameorg#">
				</cfinvoke>
				<!--- Remove thumbnail --->
				<cfif DirectoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#") AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
					<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#" recurse="true">
				</cfif>
				<!--- Versions --->
				<!--- <cfinvoke component="amazon" method="deletefolder" folderpath="versions/img/#arguments.thestruct.id#" awsbucket="#arguments.thestruct.awsbucket#" /> --->
			</cfif>
		</cfif>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!--- REMOVE RELATED FOLDERS ALSO!!!! --->
	<!--- Get all that have the same img_id as related --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT path_to_asset
	FROM #session.hostdbprefix#images
	WHERE img_group = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Loop over the found records --->
	<cfloop query="qry">
		<cftry>
			<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
				<cfif DirectoryExists("#arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#") AND path_to_asset NEQ "">
					<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#session.hostid#/#path_to_asset#" recurse="true">
				</cfif>
			<cfelseif application.razuna.storage EQ "nirvanix" AND path_to_asset NEQ "">
				<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/#path_to_asset#">
			<cfelseif application.razuna.storage EQ "amazon" AND path_to_asset NEQ "">
				<cfinvoke component="amazon" method="deletefolder" folderpath="#path_to_asset#" awsbucket="#arguments.thestruct.awsbucket#" />
			</cfif>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfloop>
	<!--- Delete related images in db as well --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#images
	WHERE img_group = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn />
</cffunction>

<!--- GET THE IMAGE DETAILS --->
<cffunction name="detail" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var thesize = 0>
	<cfset var theprevsize = 0>
	<cfset var qry = structnew()>
	<cfparam default="0" name="session.thegroupofuser">
	<!--- Get details --->
	<cfquery datasource="#application.razuna.datasource#" name="details" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#detailimg */ i.img_id, i.img_group, i.img_publisher, i.img_filename, i.folder_id_r, i.img_custom_id, i.img_online, i.img_owner, i.img_create_date, i.img_create_time, i.img_change_date, i.img_change_time, 
	i.img_filename_org, i.img_filename_org filenameorg, i.thumb_extension, i.path_to_asset, i.cloud_url, i.cloud_url_org,
	i.img_width orgwidth, i.img_height orgheight, i.img_extension orgformat, i.thumb_width thumbwidth, 
	i.thumb_height thumbheight, i.img_size ilength, i.thumb_size thumblength, i.hashtag,
	i.img_ranking rank, i.img_single_sale, i. img_is_new, i.img_selection, i.img_in_progress, 
	i.img_alignment, i.img_license, i.img_dominant_color, i.img_color_mode, img_image_type, i.img_category_one,
	i.img_remarks, i.img_extension, i.shared, s.set2_img_download_org, i.link_kind, i.link_path_url, i.img_meta,
	s.set2_intranet_gen_download, s.set2_url_website, u.user_first_name, u.user_last_name, fo.folder_name,
	'' as perm
	FROM #session.hostdbprefix#images i 
	LEFT JOIN #session.hostdbprefix#settings_2 s ON s.set2_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.setid#"> AND s.host_id = i.host_id
	LEFT JOIN users u ON u.user_id = i.img_owner
	LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = i.folder_id_r AND fo.host_id = i.host_id
	WHERE i.img_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
	AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfif details.recordcount NEQ 0>
		<!--- Get proper folderaccess --->
		<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#details.folder_id_r#"  />
		<!--- Add labels query --->
		<cfif theaccess NEQ "">
			<cfset QuerySetCell(details, "perm", theaccess, 1)>
		</cfif>
	</cfif>
	<!--- Get descriptions and keywords --->
	<cfquery datasource="#application.razuna.datasource#" name="desc" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#detaildescimg */ img_description, img_keywords, lang_id_r, img_description as thedesc, img_keywords as thekeys
	FROM #session.hostdbprefix#images_text
	WHERE img_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Convert the size --->
	<cfif isnumeric(details.ilength)>
		<cfinvoke component="global" method="converttomb" returnvariable="thesize" thesize="#details.ilength#">
		<cfinvoke component="global" method="converttomb" returnvariable="theprevsize" thesize="#details.thumblength#">
	</cfif>
	<!--- Put into struct --->
	<cfset qry.detail = details>
	<cfset qry.desc = desc>
	<cfset qry.thesize = thesize>
	<cfset qry.theprevsize = theprevsize>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- GET THE IMAGE DETAILS FOR BASKET --->
<cffunction name="detailforbasket" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam default="F" name="arguments.thestruct.related">
	<cfparam default="0" name="session.thegroupofuser">
	<!--- Qry. We take the query and do a IN --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#detailforbasketimg */ i.img_id, i.img_extension, i.thumb_extension, i.img_group, 
	i.folder_id_r, i.path_to_asset, i.img_width orgwidth, i.img_height orgheight, i.img_extension orgformat, i.thumb_width thumbwidth, i.cloud_url, 
	i.thumb_height thumbheight, i.img_size ilength,	i.thumb_size thumblength, i.link_kind, i.link_path_url, i.img_filename filename,
	'' as perm
	FROM #session.hostdbprefix#images i
	WHERE 
	<cfif arguments.thestruct.related EQ "T">
		i.img_group
	<cfelse>
		i.img_id
	</cfif>
	<cfif arguments.thestruct.qrybasket.recordcount EQ 0>
	= '0'
	<cfelse>
	IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qrybasket.cart_product_id)#" list="true">)
	</cfif>
	</cfquery>
	<!--- Get proper folderaccess --->
	<cfif arguments.thestruct.fa NEQ "c.basket" AND arguments.thestruct.fa NEQ "c.basket_put">
		<cfloop query="qry">
			<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#folder_id_r#"  />
			<!--- Add labels query --->
			<cfif theaccess NEQ "">
				<cfset QuerySetCell(qry, "perm", theaccess, currentRow)>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn qry>
</cffunction>

<!--- UPDATE IMAGES IN THREAD --->
<cffunction name="update" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Set arguments --->
	<cfset arguments.thestruct.dsn = application.razuna.datasource>
	<cfset arguments.thestruct.setid = variables.setid>
	<!--- Start the thread for updating --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="updatethread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- SAVE THE IMAGE DETAILS --->
<cffunction name="updatethread" output="false">
	<cfargument name="thestruct" type="struct">
	<cfparam name="arguments.thestruct.shared" default="F">
	<cfparam name="arguments.thestruct.what" default="">
	<cfparam name="arguments.thestruct.frombatch" default="F">
	<cfparam name="arguments.thestruct.batch_replace" default="true">
	<!--- Loop over the file_id (important when working on more then one image) --->
	<cfloop list="#arguments.thestruct.file_id#" delimiters="," index="i">
		<cfset var i = listfirst(i,"-")>
		<cfset arguments.thestruct.file_id = i>
		<!--- Save the desc and keywords --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<!--- If we come from all we need to change the desc and keywords arguments name --->
			<cfif arguments.thestruct.what EQ "all">
				<cfset var alldesc = "all_desc_#langindex#">
				<cfset var allkeywords = "all_keywords_#langindex#">
				<cfset var thisdesc = "arguments.thestruct.img_desc_#langindex#">
				<cfset var thiskeywords = "arguments.thestruct.img_keywords_#langindex#">
				<cfset "#thisdesc#" =  evaluate(alldesc)>
				<cfset "#thiskeywords#" =  evaluate(allkeywords)>
			<cfelse>
				<!--- <cfif langindex EQ 1>
					<cfset thisdesc = "desc_#langindex#">
					<cfset thiskeywords = "keywords_#langindex#">
				<cfelse> --->
					<cfset var thisdesc = "img_desc_#langindex#">
					<cfset var thiskeywords = "img_keywords_#langindex#">
				<!--- </cfif> --->
			</cfif>
			<cfset var l = langindex>
			<cfif thisdesc CONTAINS l OR thiskeywords CONTAINS l>
				<cfloop list="#arguments.thestruct.file_id#" delimiters="," index="f">
					<!---<cftry>--->
						<cfquery datasource="#variables.dsn#" name="ishere">
						SELECT img_id_r, img_description, img_keywords
						FROM #session.hostdbprefix#images_text
						WHERE img_id_r = <cfqueryparam value="#f#" cfsqltype="CF_SQL_VARCHAR">
						AND lang_id_r = <cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">
						</cfquery>
						<cfif ishere.recordcount NEQ 0>
							<cfset tdesc = evaluate(thisdesc)>
							<cfset tkeywords = evaluate(thiskeywords)>
							<!--- If users chooses to append values --->
							<cfif !arguments.thestruct.batch_replace>
								<cfif ishere.img_description NEQ "">
									<cfset tdesc = ishere.img_description & " " & tdesc>
								</cfif>
								<cfif ishere.img_keywords NEQ "">
									<cfset tkeywords = ishere.img_keywords & "," & tkeywords>
								</cfif>
							</cfif>
							<!--- Update DB --->
							<cfquery datasource="#variables.dsn#">
							UPDATE #session.hostdbprefix#images_text
							SET 
							img_description = <cfqueryparam value="#ltrim(tdesc)#" cfsqltype="cf_sql_varchar">, 
							img_keywords = <cfqueryparam value="#ltrim(tkeywords)#" cfsqltype="cf_sql_varchar">
							WHERE img_id_r = <cfqueryparam value="#f#" cfsqltype="CF_SQL_VARCHAR">
							AND lang_id_r = <cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">
							</cfquery>
						<cfelse>
							<cfquery datasource="#variables.dsn#">
							INSERT INTO #session.hostdbprefix#images_text
							(id_inc, img_id_r, lang_id_r, img_description, img_keywords, host_id)
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
						<!---<cfcatch type="any">
							<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="error in #session.hostdbprefix#images_text" dump="#cfcatch#">
						</cfcatch>
					</cftry>--->
				</cfloop>
			</cfif>
		</cfloop>
		<!--- Save to the images table --->
		<cfif structkeyexists(arguments.thestruct,"fname") AND arguments.thestruct.frombatch NEQ "T">
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#images
			SET 
			img_filename = <cfqueryparam value="#arguments.thestruct.fname#" cfsqltype="cf_sql_varchar">,
			shared = <cfqueryparam value="#arguments.thestruct.shared#" cfsqltype="cf_sql_varchar">
			WHERE img_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- Update main record with dates --->
		<cfinvoke component="global" method="update_dates" type="img" fileid="#arguments.thestruct.file_id#" />
		<!--- Select the record to get the original filename or assign if one is there --->
		<cfquery datasource="#variables.dsn#" name="qryorg">
		SELECT img_filename_org, img_filename, img_extension, thumb_extension, link_kind, link_path_url, path_to_asset
		FROM #session.hostdbprefix#images
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Assign link_kind --->
		<cfset arguments.thestruct.link_kind = qryorg.link_kind>
		<cfset arguments.thestruct.qrydetail.link_path_url = qryorg.link_path_url>
		<!--- If filename is assign --->
		<cfif NOT structkeyexists(arguments.thestruct,"filenameorg") OR arguments.thestruct.filenameorg EQ "">
			<cfset arguments.thestruct.qrydetail.filenameorg = qryorg.img_filename_org>
			<cfset arguments.thestruct.file_name = qryorg.img_filename>
		<cfelse>
			<cfset arguments.thestruct.qrydetail.filenameorg = arguments.thestruct.filenameorg>
		</cfif>
		<!--- Log --->
		<cfset log_assets(theuserid=session.theuserid,logaction='Update',logdesc='Updated: #qryorg.img_filename#',logfiletype='img',assetid='#arguments.thestruct.file_id#')>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfset variables.cachetoken = resetcachetoken("images")>
</cffunction>

<!--- CONVERT ASSET IN THREADS --->
<cffunction name="convertimage" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- RFS --->
	<cfif application.razuna.rfs>
		<cfset arguments.thestruct.convert = true>
		<cfset arguments.thestruct.assettype = "img">
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke component="rfs" method="notify" thestruct="#attributes.intstruct#" />
		</cfthread>
	<cfelse>
		<!--- Start the thread for converting --->
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="convertImagethread" thestruct="#attributes.intstruct#" />
		</cfthread>
	</cfif>
</cffunction>

<!--- CONVERT AN ORIGINAL IMAGE TO ANOTHER FORMAT (JPG, GIF, TIFF, PNG, BMP) --------------------->
<cffunction name="convertImagethread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset var cloud_url_2 = structnew()>
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cfset var thetempids = "">
	<cfset var md5hash = "">
	<cfparam name="arguments.thestruct.upl_template" default="0">
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
	<!--- Get details of image --->
	<cfinvoke method="filedetail" theid="#arguments.thestruct.file_id#" thecolumn="img_id,folder_id_r,img_filename_org,img_extension,img_filename,path_to_asset,img_width,img_height,cloud_url_org" returnvariable="arguments.thestruct.qry_detail">
	<!--- Create a temp directory to hold the image file (needed because we are doing other files from it as well) --->
	<cfset var tempfolder = "img#createuuid('')#">
	<!--- set the folder path in a var --->
	<cfset var thisfolder = "#arguments.thestruct.thepath#/incoming/#tempfolder#">
	<!--- Create the temp folder in the incoming dir --->
	<cfdirectory action="create" directory="#thisfolder#" mode="775">
	<!--- Now get the extension and the name after the position from above --->
	<cfset var thenamenoext = listfirst(arguments.thestruct.qry_detail.img_filename_org, ".")>
	<cfset var thename = thenamenoext & ".#arguments.thestruct.qry_detail.img_extension#">
	<!--- Set vars for thread --->
	<cfset arguments.thestruct.thisfolder = thisfolder>
	<cfset arguments.thestruct.thename = thename>
	<cfset arguments.thestruct.hostid = session.hostid>
	<cfset arguments.thestruct.thenamenoext = thenamenoext>
	<cfset arguments.thestruct.thesource = "#thisfolder#/#thename#">
	<!--- Local --->
	<!--- On local link asset we have a different input path --->
	<cfif arguments.thestruct.link_kind NEQ "lan">
		<cfif application.razuna.storage EQ "local">
			<cfthread name="#tempfolder#" intstruct="#arguments.thestruct#">
				<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry_detail.path_to_asset#/#attributes.intstruct.qry_detail.img_filename_org#" destination="#attributes.intstruct.thisfolder#/#attributes.intstruct.thename#" mode="775">
			</cfthread>
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<cfthread name="#tempfolder#" intstruct="#arguments.thestruct#">
				<cfhttp url="#attributes.intstruct.qry_detail.cloud_url_org#" file="#attributes.intstruct.thename#" path="#attributes.intstruct.thisfolder#"></cfhttp>
			</cfthread>
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<!--- Download file --->
			<cfthread name="#tempfolder#" intstruct="#arguments.thestruct#">
				<cfinvoke component="amazon" method="Download">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qry_detail.path_to_asset#/#attributes.intstruct.qry_detail.img_filename_org#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.thename#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai">
			<cfthread name="convert#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akaimg#/#attributes.intstruct.thename#" file="#attributes.intstruct.thename#" path="#attributes.intstruct.thisfolder#"></cfhttp>
			</cfthread>
		</cfif>
	<!--- On a LAN asset --->
	<cfelse>
		<cfif isWindows>
			<cfset arguments.thestruct.thesource = """#arguments.thestruct.link_path_url#""">
		<cfelse>
			<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.link_path_url," ","\ ","all")>
		</cfif>
		<cfthread name="#tempfolder#" intstruct="#arguments.thestruct#" />
	</cfif>
	<!--- Wait for the thread above until the file is downloaded fully --->
	<cfthread action="join" name="#tempfolder#" />

	<!--- Ok, file is here so continue --->

	<!--- Check the platform and then decide on the ImageMagick tag --->
	<cfif isWindows>
		<cfset var theexe = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
		<cfset var themogrify = """#arguments.thestruct.thetools.imagemagick#/mogrify.exe""">
		<cfset var thecomposite = """#arguments.thestruct.thetools.imagemagick#/composite.exe""">
		<cfset var theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfset var thedcraw = """#arguments.thestruct.thetools.dcraw#/dcraw.exe""">
	<cfelse>
		<cfset var theexe = "#arguments.thestruct.thetools.imagemagick#/convert">
		<cfset var themogrify = "#arguments.thestruct.thetools.imagemagick#/mogrify">
		<cfset var thecomposite = "#arguments.thestruct.thetools.imagemagick#/composite">
		<cfset var theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset var thedcraw = "#arguments.thestruct.thetools.dcraw#/dcraw">
	</cfif>
	<!--- If the file is a PSD, AI or EPS we have to layer it to zero --->
	<cfif arguments.thestruct.qry_detail.img_extension EQ "psd" OR arguments.thestruct.qry_detail.img_extension EQ "eps" OR arguments.thestruct.qry_detail.img_extension EQ "ai">
		<cfset var theargument = "#arguments.thestruct.thesource#[0]">
		<cfset var theflatten = "">
	<cfelse>
		<cfset var theargument = "#arguments.thestruct.thesource#">
		<cfset var theflatten = "">
	</cfif>
	<!--- Set Colorspace --->
	<cfset var thecolorspace = "">
	<!--- Check the colorspace --->
	<cfif arguments.thestruct.qry_settings_image.set2_colorspace_rgb>
		<cfset var thecolorspace = "-colorspace sRGB">
	</cfif>
	<!--- Now, loop over the selected extensions and convert and store image --->
	<cfloop delimiters="," list="#arguments.thestruct.convert_to#" index="theformat">
		<!--- Create tempid --->
		<cfset arguments.thestruct.newid = createuuid("")>
		<!--- Put together the name --->
		<cfset arguments.thestruct.thenamenoext = arguments.thestruct.thenamenoext & "_" & arguments.thestruct.newid>
		<!--- If from upload templates we select with and height of image --->
		<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "undefined" AND arguments.thestruct.upl_template NEQ "">
			<!--- Get width --->
			<cfquery datasource="#application.razuna.datasource#" name="qry_w">
			SELECT upl_temp_value
			FROM #session.hostdbprefix#upload_templates_val
			WHERE upl_temp_field = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="convert_width_#theformat#">
			AND upl_temp_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_template#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Get height --->
			<cfquery datasource="#application.razuna.datasource#" name="qry_h">
			SELECT upl_temp_value
			FROM #session.hostdbprefix#upload_templates_val
			WHERE upl_temp_field = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="convert_height_#theformat#">
			AND upl_temp_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_template#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Get DPI --->
			<cfquery datasource="#application.razuna.datasource#" name="qry_d">
			SELECT upl_temp_value
			FROM #session.hostdbprefix#upload_templates_val
			WHERE upl_temp_field = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="convert_dpi_#theformat#">
			AND upl_temp_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_template#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Get watermark --->
			<cfquery datasource="#application.razuna.datasource#" name="qry_wm">
			SELECT upl_temp_value
			FROM #session.hostdbprefix#upload_templates_val
			WHERE upl_temp_field = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="convert_wm_#theformat#">
			AND upl_temp_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_template#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Set image width and height --->
			<cfset var newImgWidth  = qry_w.upl_temp_value>
			<cfset var newImgHeight = qry_h.upl_temp_value>
			<!--- If height and size is empty we take the default values from the original file --->
			<cfif NOT isnumeric(newImgWidth) AND NOT isnumeric(newImgHeight)>
				<cfset var newImgWidth  = arguments.thestruct.qry_detail.img_width>
				<cfset var newImgHeight = arguments.thestruct.qry_detail.img_height>
			</cfif>
			<!--- DPI --->
			<cfif qry_d.recordcount EQ 0>
				<cfset var thedpi = "">
			<cfelse>
				<cfset var thedpi = qry_d.upl_temp_value>
			</cfif>
			<!--- If there is a watermark being selected grab it here --->
			<cfif "convert_wm_#theformat#" NEQ "">
				<cfinvoke component="global" method="getWMtemplatedetail" wm_temp_id="#qry_wm.upl_temp_value#" returnvariable="thewm" />
			</cfif>
		<cfelse>
			<!--- Set image width and height --->
			<cfset var newImgWidth  = evaluate("convert_width_#theformat#")>
			<cfset var newImgHeight = evaluate("convert_height_#theformat#")>
			<cfset var thedpi = evaluate("convert_dpi_#theformat#")>
			<!--- If there is a watermark being selected grab it here --->
			<cfif "convert_wm_#theformat#" NEQ "">
				<cfset var wmid = evaluate("convert_wm_#theformat#")>
				<cfinvoke component="global" method="getWMtemplatedetail" wm_temp_id="#wmid#" returnvariable="thewm" />
			</cfif>
		</cfif>
		<!--- From here on we need to remove the number of the format (if any) --->
		<cfset var theformat = listfirst(theformat,"_")>
		<!--- Set the format into struct for threads --->
		<cfset arguments.thestruct.theformat = theformat>
		<!--- If it is Window rewrite path --->
		<cfif isWindows>
			<cfset var theoriginalasset = """#theargument#""">
			<cfset var theformatconv = """#thisfolder#/#arguments.thestruct.thenamenoext#.#theformat#""">
			<cfset var thethumbtconv = """#thisfolder#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qry_settings_image.set2_img_format#""">
		<cfelse>
			<cfset var theoriginalasset = theargument>
			<cfset var nameforim = replace(arguments.thestruct.thenamenoext," ","\ ","all")>
			<cfset var nameforim = replace(nameforim,"&","\&","all")>
			<cfset var nameforim = replace(nameforim,"'","\'","all")>
			<cfset var theformatconv = "#thisfolder#/#nameforim#.#theformat#">
			<cfset var thethumbtconv = "#thisfolder#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qry_settings_image.set2_img_format#">
		</cfif>
		<!--- IM commands --->
		<cfif thedpi EQ "">
			<cfset var theimarguments = "#theoriginalasset# -resize #newImgWidth#x#newImgHeight# #thecolorspace# #theflatten##theformatconv#">
		<cfelse>
			<cfset var theimarguments = "#theoriginalasset# -resample #thedpi# #thecolorspace# #theflatten##theformatconv#">
		</cfif>
		<cfset var theimargumentsthumb = "#theformatconv# -resize #arguments.thestruct.qry_settings_image.set2_img_thumb_width#x#arguments.thestruct.qry_settings_image.set2_img_thumb_heigth# #thecolorspace# #theflatten##thethumbtconv#">
		<!--- Create script files --->
		<cfset var thescript = createuuid()>
		<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.sh">
		<cfset arguments.thestruct.thesht = GetTempDirectory() & "/#thescript#t.sh">
		<cfset arguments.thestruct.theshtt = GetTempDirectory() & "/#thescript#tt.sh">
		<cfset arguments.thestruct.theshwm = GetTempDirectory() & "/#thescript#wm.sh">
		<!--- On Windows a .bat --->
		<cfif iswindows>
			<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.bat">
			<cfset arguments.thestruct.thesht = GetTempDirectory() & "/#thescript#t.bat">
			<cfset arguments.thestruct.theshtt = GetTempDirectory() & "/#thescript#tt.bat">
			<cfset arguments.thestruct.theshwm = GetTempDirectory() & "/#thescript#wm.bat">
		</cfif>
		<!--- If we are a RAW image --->
		<cfswitch expression="#arguments.thestruct.qry_detail.img_extension#">
			<cfcase value="3fr,ari,srf,sr2,bay,cap,iiq,eip,dcs,dcr,drf,k25,kdc,erf,fff,mef,mos,nrw,ptx,pef,pxn,r3d,raf,raw,rw2,rwl,dng,rwz">
				<!--- Write files --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#thedcraw# -w -b 1.8 -c #theoriginalasset# > #theformatconv#" mode="777">
				<cffile action="write" file="#arguments.thestruct.thesht#" output="#theexe# #theimarguments#" mode="777">
				<cffile action="write" file="#arguments.thestruct.theshtt#" output="#theexe# #theimargumentsthumb#" mode="777">
			</cfcase>
			<cfdefaultcase>
				<!--- Write files --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#theexe# #theimarguments#" mode="777">
				<cffile action="write" file="#arguments.thestruct.thesht#" output="#theexe# #theimargumentsthumb#" mode="777">
				<cffile action="write" file="#arguments.thestruct.theshtt#" output="x" mode="777">
			</cfdefaultcase>
		</cfswitch>
		<!--- Convert image to desired format --->
		<cfthread name="1#thescript#" intstruct="#arguments.thestruct#">
			<cfexecute name="#attributes.intstruct.thesh#" timeout="60" />
		</cfthread>
		<cfthread action="join" name="1#thescript#" />
		<!--- Since the image can not be read we use img to convert to itself --->
		<cfthread name="2#thescript#" intstruct="#arguments.thestruct#">
			<cfexecute name="#attributes.intstruct.thesht#" timeout="60" />
		</cfthread>
		<cfthread action="join" name="2#thescript#" />
		<!--- Thumb it --->
		<cfthread name="3#thescript#" intstruct="#arguments.thestruct#">
			<cfexecute name="#attributes.intstruct.theshtt#" timeout="60" />
		</cfthread>
		<cfthread action="join" name="3#thescript#" />
		<!--- Delete scripts --->
		<cffile action="delete" file="#arguments.thestruct.thesh#">
		<cffile action="delete" file="#arguments.thestruct.thesht#">
		<cffile action="delete" file="#arguments.thestruct.theshtt#">
		<!--- If we need to watermark this image then --->
		<cfif "convert_wm_#theformat#" NEQ "">
			<cfif thewm.wmval.wm_use_image>
				<cfexecute name="#thecomposite#" arguments="-dissolve #thewm.wmval.wm_image_opacity#% -gravity #thewm.wmval.wm_image_position# #arguments.thestruct.rootpath#global/host/watermark/#session.hostid#/#thewm.wmval.wm_image_path# #theformatconv# #theformatconv#" timeout="90" />
			</cfif>
			<cfif thewm.wmval.wm_use_text>
				<!--- Opacity --->
				<cfif thewm.wmval.wm_text_opacity EQ 100>
					<cfset var topa = "1.0">
				<cfelse>
					<cfset var topa = "0.#left(thewm.wmval.wm_text_opacity,1)#">
				</cfif>
				<!--- Put text into var --->
				<cfif iswindows>
					<cfset var thetext = """#thewm.wmval.wm_text_content#""">
				<cfelse>
					<cfset var thetext = "'#thewm.wmval.wm_text_content#'">
				</cfif>
				<!--- Write script --->
				<cffile action="write" file="#arguments.thestruct.theshwm#" output="#theexe# #theformatconv# -fill 'rgba(0,0,0,#topa#)' -gravity #thewm.wmval.wm_text_position# -pointsize #thewm.wmval.wm_text_font_size# -font #thewm.wmval.wm_text_font# -annotate 0 #thetext# #theformatconv#" mode="777">
				<!--- Execute it --->
				<cfexecute name="#arguments.thestruct.theshwm#" timeout="60" />
				<!--- Delete it --->
				<cffile action="delete" file="#arguments.thestruct.theshwm#">
			</cfif>
		</cfif>
		<!--- Add the metadata from the source to the converted one. If DPI is there we need to add new DPI information --->
		<cfif thedpi EQ "">
			<cfset var thedpitags = "">
		<cfelse>
			<cfset var thedpitags = " -Photoshop:XResolution=#thedpi# -Photoshop:YResolution=#thedpi# -IFD0:XResolution=#thedpi# -JFIF:XResolution=#thedpi# -IFD0:YResolution=#thedpi# -JFIF:YResolution=#thedpi#">
		</cfif>
		<cfexecute name="#theexif#" arguments="-TagsFromFile #theoriginalasset# -all:all#thedpitags# #theformatconv#" timeout="60" />
		<!--- Get size of original and thumnail --->
		<cfinvoke component="global" method="getfilesize" filepath="#thisfolder#/#arguments.thestruct.thenamenoext#.#theformat#" returnvariable="orgsize">
		<cfinvoke component="global" method="getfilesize" filepath="#thisfolder#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qry_settings_image.set2_img_format#" returnvariable="thumbsize">
		<!--- Get width and height --->
		<cfexecute name="#theexif#" arguments="-S -s -ImageHeight #theformatconv#" timeout="60" variable="theheight" />
		<cfexecute name="#theexif#" arguments="-S -s -ImageWidth #theformatconv#" timeout="60" variable="thewidth" />
		<!--- MD5 Hash --->
		<cfif FileExists("#thisfolder#/#arguments.thestruct.thenamenoext#.#theformat#")>
			<cfset var md5hash = hashbinary("#thisfolder#/#arguments.thestruct.thenamenoext#.#theformat#")>
		</cfif>
		<!---Create record--->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#images
		(img_id)
		VALUES(<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">)
		</cfquery>
		<!--- Local --->
		<cfif application.razuna.storage EQ "local">
			<!--- Create folder with the asset id --->
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#" mode="775">
			<!--- Move original image --->
			<cffile action="move" source="#thisfolder#/#arguments.thestruct.thenamenoext#.#theformat#" destination="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#/#arguments.thestruct.thenamenoext#.#theformat#" mode="775">
			<!--- Move thumbnail --->
			<cffile action="move" source="#thisfolder#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qry_settings_image.set2_img_format#" destination="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qry_settings_image.set2_img_format#" mode="775">
			<cfthread name="upload#theformat##arguments.thestruct.newid#">
			</cfthread>
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<cfthread name="upload#theformat##arguments.thestruct.newid#" intstruct="#arguments.thestruct#">
				<!--- Upload Original Image --->
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qry_detail.folder_id_r#/img/#attributes.intstruct.newid#">
					<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.thenamenoext#.#attributes.intstruct.theformat#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
				<!--- Upload Thumbnail --->
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qry_detail.folder_id_r#/img/#attributes.intstruct.newid#">
					<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thisfolder#/thumb_#attributes.intstruct.file_id#.#attributes.intstruct.qry_settings_image.set2_img_format#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for thread to finish --->
			<cfthread action="join" name="upload#theformat##arguments.thestruct.newid#" />
			<!--- Get signed URLS --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#/#arguments.thestruct.thenamenoext#.#arguments.thestruct.theformat#" nvxsession="#arguments.thestruct.nvxsession#">
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qry_settings_image.set2_img_format#" nvxsession="#arguments.thestruct.nvxsession#">
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<cfthread name="upload#theformat##arguments.thestruct.newid#" intstruct="#arguments.thestruct#">
				<!--- Upload Original Image --->
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qry_detail.folder_id_r#/img/#attributes.intstruct.newid#/#attributes.intstruct.thenamenoext#.#attributes.intstruct.theformat#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.thenamenoext#.#attributes.intstruct.theformat#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
				<!--- Upload Thumbnail --->
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qry_detail.folder_id_r#/img/#attributes.intstruct.newid#/thumb_#attributes.intstruct.file_id#.#attributes.intstruct.qry_settings_image.set2_img_format#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/thumb_#attributes.intstruct.file_id#.#attributes.intstruct.qry_settings_image.set2_img_format#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for thread to finish --->
			<cfthread action="join" name="upload#theformat##arguments.thestruct.newid#" />
			<!--- Get signed URLS --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#/#arguments.thestruct.thenamenoext#.#arguments.thestruct.theformat#" awsbucket="#arguments.thestruct.awsbucket#">
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qry_settings_image.set2_img_format#" awsbucket="#arguments.thestruct.awsbucket#">
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai">
			<cfthread name="upload#theformat##arguments.thestruct.newid#" intstruct="#arguments.thestruct#">
				<!--- Upload Original Image --->
				<cfinvoke component="akamai" method="Upload">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.thenamenoext#.#attributes.intstruct.theformat#">
					<cfinvokeargument name="thetype" value="#attributes.intstruct.akaimg#">
					<cfinvokeargument name="theurl" value="#attributes.intstruct.akaurl#">
					<cfinvokeargument name="thefilename" value="#attributes.intstruct.thenamenoext#.#attributes.intstruct.theformat#">
				</cfinvoke>
				<!--- Upload Thumbnail --->
				<!--- <cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qry_detail.folder_id_r#/img/#attributes.intstruct.newid#">
					<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thisfolder#/thumb_#attributes.intstruct.file_id#.#attributes.intstruct.qry_settings_image.set2_img_format#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke> --->
			</cfthread>
			<!--- Wait for thread to finish --->
			<cfthread action="join" name="upload#theformat##arguments.thestruct.newid#" />
		</cfif>
		<!--- Add to shared options --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#share_options
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
		<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.qry_detail.folder_id_r#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Add to DB --->
		<!---<cfquery datasource="#application.razuna.datasource#" name="qry_img_id">
			SELECT i.img_id FROM raz1_images i WHERE i.img_group IS NULL
		</cfquery>	--->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#images
		SET
		<cfif isDefined('arguments.thestruct.img_group_id') AND arguments.thestruct.img_group_id NEQ ''>
			img_group = <cfqueryparam value="#arguments.thestruct.img_group_id#" cfsqltype="cf_sql_varchar">,
		<cfelse>
			img_group = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">, 
		</cfif>
		img_filename = <cfqueryparam value="#arguments.thestruct.thenamenoext#.#theformat#" cfsqltype="cf_sql_varchar">, 
		img_online = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">, 
		folder_id_r = <cfqueryparam value="#arguments.thestruct.qry_detail.folder_id_r#" cfsqltype="CF_SQL_VARCHAR">, 
		img_owner = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
		img_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
		img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
		img_create_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		img_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
		img_custom_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">, 
		img_in_progress = <cfqueryparam value="T" cfsqltype="cf_sql_varchar">, 
		img_extension = <cfqueryparam value="#theformat#" cfsqltype="cf_sql_varchar">, 
		thumb_extension = <cfqueryparam value="#arguments.thestruct.qry_settings_image.set2_img_format#" cfsqltype="cf_sql_varchar">, 
		thumb_width = <cfqueryparam value="#arguments.thestruct.qry_settings_image.set2_img_thumb_width#" cfsqltype="cf_sql_numeric">,
		thumb_height = <cfqueryparam value="#arguments.thestruct.qry_settings_image.set2_img_thumb_heigth#" cfsqltype="cf_sql_numeric">, 
		<cfif isNumeric(#thewidth#)>
			img_width = <cfqueryparam value="#thewidth#" cfsqltype="cf_sql_numeric">,
		</cfif>
		<cfif isNumeric(#theheight#)>
			img_height = <cfqueryparam value="#theheight#" cfsqltype="cf_sql_numeric">,
		</cfif>
		img_filename_org = <cfqueryparam value="#arguments.thestruct.thenamenoext#.#theformat#" cfsqltype="cf_sql_varchar">,
		img_size = <cfqueryparam value="#orgsize#" cfsqltype="cf_sql_numeric">, 
		thumb_size = <cfqueryparam value="#thumbsize#" cfsqltype="cf_sql_numeric">,
		host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">, 
		path_to_asset = <cfqueryparam value="#arguments.thestruct.qry_detail.folder_id_r#/img/#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">, 
		cloud_url = <cfqueryparam value="#cloud_url.theurl#" cfsqltype="cf_sql_varchar">, 
		cloud_url_org = <cfqueryparam value="#cloud_url_org.theurl#" cfsqltype="cf_sql_varchar">, 
		cloud_url_exp = <cfqueryparam value="#cloud_url_org.newepoch#" cfsqltype="CF_SQL_NUMERIC">, 
		is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		img_meta = <cfqueryparam value="#thedpi#" cfsqltype="cf_sql_varchar">,
		hashtag = <cfqueryparam value="#md5hash#" cfsqltype="cf_sql_varchar">
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Get the colorspace of the original file --->
		<cfquery datasource="#application.razuna.datasource#" name="qry_colorspace">
		SELECT colorspace
		FROM #session.hostdbprefix#xmp
		WHERE id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		</cfquery>
		<!--- Add to XMP --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#xmp
		(id_r, asset_type, host_id, yres, xres, resunit, colorspace)
		VALUES(
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thedpi#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thedpi#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="inches">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry_colorspace.colorspace#">
		)
		</cfquery>
		<!--- Update main record with dates --->
		<cfinvoke component="global" method="update_dates" type="img" fileid="#arguments.thestruct.file_id#" />
		<!--- Log --->
		<cfset log_assets(theuserid=session.theuserid,logaction='Convert',logdesc='Converted: #thename# to #arguments.thestruct.thenamenoext#.#theformat# (#newImgWidth#x#newImgHeight#)',logfiletype='img',assetid='#arguments.thestruct.file_id#')>
		<!--- Call Plugins --->
		<cfset arguments.thestruct.fileid = arguments.thestruct.newid>
		<cfset arguments.thestruct.file_name = "#arguments.thestruct.thenamenoext#.#theformat#">
		<cfset arguments.thestruct.folder_id = arguments.thestruct.qry_detail.folder_id_r>
		<cfset arguments.thestruct.thefiletype = "img">
		<cfset arguments.thestruct.folder_action = false>
		<!--- Check on any plugin that call the on_rendition_add action --->
		<cfinvoke component="plugins" method="getactions" theaction="on_rendition_add" args="#arguments.thestruct#" />
		<!--- Reset name --->
		<cfset arguments.thestruct.thenamenoext = replace(arguments.thestruct.thenamenoext,"_#arguments.thestruct.newid#","","one")>
	</cfloop>
	<!--- Remove folder --->
	<cfif directoryexists(thisfolder)>
		<cfdirectory action="delete" directory="#thisfolder#" recurse="true">
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("search")>
	<cfset variables.cachetoken = resetcachetoken("images")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- GET RELATED IMAGES --->
<cffunction name="relatedimages" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("images")>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#relatedimagesimg */ i.img_id, i.img_group, i.img_publisher, i.img_filename, i.folder_id_r, i.img_custom_id, 
	i.img_online, i.img_owner, i.img_filename_org, i.img_meta,
	i.img_create_date, i.img_create_time, i.img_change_date, i.img_change_time, 
	i.img_width orgwidth, i.img_height orgheight, i.img_extension orgformat, i.thumb_width thumbwidth, 
	i.thumb_height thumbheight, i.img_size ilength,	i.thumb_size thumblength,
	i.img_ranking rank, i.img_single_sale, i. img_is_new, i.img_selection, i.img_in_progress, 
	i.img_alignment, i.img_license, i.img_dominant_color, i.img_color_mode, img_image_type, i.img_category_one, 
	i.img_remarks, i.img_extension, i.path_to_asset, i.cloud_url, i.cloud_url_org
	FROM #session.hostdbprefix#images i
	WHERE i.img_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#"> 
	AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY img_create_time DESC
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- WRITE IMAGE TO SYSTEM --->
<cffunction name="writeimage" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.zipit" default="T">
	<!--- Create a temp folder --->
	<cfset tempfolder = createuuid("")>
	<cfdirectory action="create" directory="#arguments.thestruct.thepath#/outgoing/#tempfolder#" mode="775">
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- Put the id into a variable --->
	<cfset theimageid = #arguments.thestruct.file_id#>
	<!--- set session.artofimage value if it is empty  --->
	<cfif session.artofimage EQ "">
		<cfset session.artofimage = arguments.thestruct.artofimage>
	</cfif>
	<!--- Start the loop to get the different kinds of images --->
	<cfloop delimiters="," list="#session.artofimage#" index="art">
		<!--- Since the image format could be from the related table we need to check this here so if the value is a number it is the id for the image --->
		<cfif isnumeric(art)>
			<!--- Set the image id for this type of format and set the extension --->
			<cfset theimageid = art>
			<cfquery name="ext" datasource="#variables.dsn#">
			SELECT img_extension
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam value="#theimageid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset art = ext.img_extension>
		</cfif>
		<!--- Create subfolder for the kind of image --->
		<cfdirectory action="create" directory="#arguments.thestruct.thepath#/outgoing/#tempfolder#/#art#" mode="775">
		<!--- Set the colname to get from oracle to thumbnail else to original always --->
		<cfif #art# EQ "thumb">
			<cfset thecolname = "thumb">
		<cfelse>
			<cfset thecolname = "original">
		</cfif>
		<!--- Query the db --->
		<cfquery name="qry" datasource="#variables.dsn#">
		SELECT i.img_filename, i.img_extension, i.thumb_extension, i.folder_id_r, i.img_filename_org, i.img_group,
		i.path_to_asset, s.set2_url_sp_#thecolname# urloracle, i.link_kind, i.link_path_url
		FROM #session.hostdbprefix#images i, #session.hostdbprefix#settings_2 s
		WHERE i.img_id = <cfqueryparam value="#theimageid#" cfsqltype="CF_SQL_VARCHAR">
		AND s.set2_id = <cfqueryparam value="#variables.setid#" cfsqltype="cf_sql_numeric">
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- If we have to serve thumbnail the name is different --->
		<cfif thecolname EQ "thumb">
			<cfset theimgname = "thumb_#theimageid#.#qry.thumb_extension#">
			<cfset thefinalname = listfirst(qry.img_filename_org,".") & ".#qry.thumb_extension#">
		<cfelse>
			<cfset theimgname = qry.img_filename_org>
			<cfset thefinalname = qry.img_filename_org>
		</cfif>
		<!--- Put variables into struct for threads --->
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset arguments.thestruct.qry = qry>
		<cfset arguments.thestruct.theimageid = theimageid>
		<cfset arguments.thestruct.theimgname = theimgname>
		<cfset arguments.thestruct.tempfolder = tempfolder>
		<cfset arguments.thestruct.art = art>
		<cfset arguments.thestruct.thefinalname = thefinalname>
		<!--- Decide on local link or not --->
		<cfif qry.link_kind NEQ "lan">
			<!--- Local --->
			<cfif application.razuna.storage EQ "local">
				<cfthread name="download#art##theimageid#" intstruct="#arguments.thestruct#">
					<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.theimgname#" destination="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#/#attributes.intstruct.thefinalname#" mode="775">
				</cfthread>
			<!--- Nirvanix --->
			<cfelseif application.razuna.storage EQ "nirvanix">
				<cfthread name="download#art##theimageid#" intstruct="#arguments.thestruct#">
					<cfhttp url="http://services.nirvanix.com/#attributes.intstruct.nvxsession#/razuna/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.theimgname#" file="#attributes.intstruct.thefinalname#" path="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#"></cfhttp>
				</cfthread>
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon">
				<!--- Download file --->
				<cfthread name="download#art##theimageid#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.theimgname#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#/#attributes.intstruct.thefinalname#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
			<!--- Nirvanix --->
			<cfelseif application.razuna.storage EQ "akamai">
				<cfthread name="download#art##theimageid#" intstruct="#arguments.thestruct#">
					<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akaimg#/#attributes.intstruct.theimgname#" file="#attributes.intstruct.thefinalname#" path="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#"></cfhttp>
				</cfthread>
			</cfif>
		<!--- It is a local link --->
		<cfelseif qry.link_kind EQ "lan">
			<cfthread name="download#art##theimageid#" intstruct="#arguments.thestruct#">
				<cffile action="copy" source="#attributes.intstruct.qry.link_path_url#" destination="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#/#attributes.intstruct.thefinalname#" mode="775">
			</cfthread>
		</cfif>
		<!--- Wait for the thread above until the file is downloaded fully --->
		<cfthread action="join" name="download#art##theimageid#" />
		<!--- Set extension --->
		<cfif thecolname EQ "thumb">
			<cfset theext = qry.thumb_extension>
		<cfelse>
			<cfset theext = qry.img_extension>
		</cfif>
		<!--- If the art id not thumb and original we need to get the name from the parent record --->
		<cfif qry.img_group NEQ "">
			<cfquery name="qry_fn" datasource="#variables.dsn#">
			SELECT img_filename
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam value="#qry.img_group#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset var thefilename = qry_fn.img_filename>
		<cfelse>
			<cfset var thefilename = qry.img_filename>
		</cfif>
		<!--- If filename contains /\ --->
		<cfset thenewname = replace(thefilename,"/","-","all")>
		<cfset thenewname = replace(thenewname,"\","-","all")>
		<cfset thenewname = listfirst(thenewname, ".") & "." & theext>
		<!--- Rename the file --->
		<cffile action="move" source="#arguments.thestruct.thepath#/outgoing/#tempfolder#/#art#/#thefinalname#" destination="#arguments.thestruct.thepath#/outgoing/#tempfolder#/#art#/#thenewname#">
	</cfloop>
	<!--- Check that the zip name contains no spaces --->
	<cfset zipname = replace(arguments.thestruct.zipname,"/","-","all")>
	<cfset zipname = replace(zipname,"\","-","all")>
	<cfset zipname = replace(zipname, " ", "_", "All")>
	<cfset zipname = zipname & ".zip">
	<!--- Remove any file with the same name in this directory. Wrap in a cftry so if the file does not exist we don't have a error --->
	<cftry>
		<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#zipname#">
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!--- Zip the folder --->
	<cfzip action="create" ZIPFILE="#arguments.thestruct.thepath#/outgoing/#zipname#" source="#arguments.thestruct.thepath#/outgoing/#tempfolder#" recurse="true" timeout="300" />
	<!--- Remove the temp folder --->
	<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#tempfolder#" recurse="yes">
	<!--- Return --->
	<cfreturn zipname>
</cffunction>

<!--- MOVE FILE IN THREADS --->
<cffunction name="movethread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Loop over files --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfloop list="#attributes.intstruct.file_id#" delimiters="," index="fileid">
			<cfset attributes.intstruct.img_id = "">
			<cfset attributes.intstruct.img_id = listfirst(fileid,"-")>
			<cfif attributes.intstruct.img_id NEQ "">
				<cfinvoke method="move" thestruct="#attributes.intstruct#" />
			</cfif>
		</cfloop>
	</cfthread>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
</cffunction>

<!--- MOVE FILE --->
<cffunction name="move" output="false">
	<cfargument name="thestruct" type="struct">
		<cfset arguments.thestruct.qryimg = "">
		<cfset arguments.thestruct.storage = application.razuna.storage>
		<!--- Move --->
		<cfinvoke method="filedetail" theid="#arguments.thestruct.img_id#" thecolumn="img_filename, folder_id_r" returnvariable="arguments.thestruct.qryimg">
		<!--- Ignore if the folder id is the same --->
		<cfif arguments.thestruct.qryimg.recordcount NEQ 0 AND arguments.thestruct.folder_id NEQ arguments.thestruct.qryimg.folder_id_r>
			<!--- Update DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images
			SET 
			folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE img_id = <cfqueryparam value="#arguments.thestruct.img_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- <cfthread intstruct="#arguments.thestruct#"> --->
				<!--- Update Dates --->
				<cfinvoke component="global" method="update_dates" type="img" fileid="#arguments.thestruct.img_id#" />
				<!--- MOVE ALL RELATED FOLDERS TOO!!!!!!! --->
				<cfinvoke method="moverelated" thestruct="#arguments.thestruct#">
				<!--- Execute workflow --->
				<cfset arguments.thestruct.fileid = arguments.thestruct.img_id>
				<cfset arguments.thestruct.file_name = arguments.thestruct.qryimg.img_filename>
				<cfset arguments.thestruct.thefiletype = "img">
				<cfset arguments.thestruct.folder_id = arguments.thestruct.folder_id>
				<cfset arguments.thestruct.folder_action = false>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_move" args="#arguments.thestruct#" />
				<cfset arguments.thestruct.folder_action = true>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_move" args="#arguments.thestruct#" />
				<cfinvoke component="plugins" method="getactions" theaction="on_file_add" args="#arguments.thestruct#" />
			<!--- </cfthread> --->
			<!--- Log --->
			<cfset log_assets(theuserid=session.theuserid,logaction='Move',logdesc='Moved: #arguments.thestruct.qryimg.img_filename#',logfiletype='img',assetid=arguments.thestruct.img_id)>
		</cfif>
	<cfreturn />
</cffunction>

<!--- Move related images --->
<cffunction name="moverelated" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Get all that have the same img_id as related --->
	<cfquery datasource="#application.razuna.datasource#" name="qryintern">
	SELECT folder_id_r, img_id
	FROM #session.hostdbprefix#images
	WHERE img_group = <cfqueryparam value="#arguments.thestruct.img_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Loop over the found records --->
	<cfif qryintern.recordcount NEQ 0>
		<cfloop query="qryintern">
			<!--- Update DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images
			SET 
			folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE img_id = <cfqueryparam value="#img_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
	</cfif>
	<cfreturn />
</cffunction>

<!--- Get description and keywords for print --->
<cffunction name="gettext" output="false">
	<cfargument name="qry" type="query">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("images")>
	<!--- Get how many loop --->
	<cfset var howmanyloop = ceiling(arguments.qry.recordcount / 990)>
	<!--- Set outer loop --->
	<cfset var pos_start = 1>
	<cfset var pos_end = howmanyloop>
	<!--- Set inner loop --->
	<cfset var q_start = 1>
	<cfset var q_end = 990>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qryintern" cachedwithin="1" region="razcache">
		<cfloop from="#pos_start#" to="#pos_end#" index="i">
			<cfif q_start NEQ 1>
				UNION ALL
			</cfif>
			SELECT /* #variables.cachetoken#gettextimg */ img_id_r tid, img_description description, img_keywords keywords
			FROM #session.hostdbprefix#images_text
			WHERE img_id_r IN ('0'<cfloop query="arguments.qry" startrow="#q_start#" endrow="#q_end#">,'#id#'</cfloop>)
			AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfset q_start = q_end + 1>
	    	<cfset q_end = q_end + 990>
	    </cfloop>
	</cfquery>
	<!--- Return --->
	<cfreturn qryintern>
</cffunction>

<!--- Get rawmetadata --->
<cffunction name="getrawmetadata" output="false">
	<cfargument name="qry" type="query">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("images")>
	<!--- Get how many loop --->
	<cfset var howmanyloop = ceiling(arguments.qry.recordcount / 990)>
	<!--- Set outer loop --->
	<cfset var pos_start = 1>
	<cfset var pos_end = howmanyloop>
	<!--- Set inner loop --->
	<cfset var q_start = 1>
	<cfset var q_end = 990>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qryintern" cachedwithin="1" region="razcache">
		<cfloop from="#pos_start#" to="#pos_end#" index="i">
			<cfif q_start NEQ 1>
				UNION ALL
			</cfif>
			SELECT /* #variables.cachetoken#gettextrm */ img_meta rawmetadata
			FROM #session.hostdbprefix#images
			WHERE img_id IN ('0'<cfloop query="arguments.qry" startrow="#q_start#" endrow="#q_end#">,'#id#'</cfloop>)
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfset q_start = q_end + 1>
	    	<cfset q_end = q_end + 990>
	    </cfloop>
	</cfquery>
	<!--- Return --->
	<cfreturn qryintern>
</cffunction>

<!--- GET RECORDS WITH EMTPY VALUES --->
<cffunction name="getempty" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT
	img_id id, img_filename, folder_id_r, path_to_asset, cloud_url, cloud_url_org, link_kind, link_path_url, 
	path_to_asset, lucene_key, img_filename_org filenameorg
	FROM #session.hostdbprefix#images
	WHERE (folder_id_r IS NULL OR folder_id_r = '')
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Check for existing MD5 mash records --->
<cffunction name="checkmd5" output="false">
	<cfargument name="md5hash" type="string">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("images")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#checkmd5 */ img_id
	FROM #session.hostdbprefix#images
	WHERE hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.md5hash#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
	</cfquery>
	<cfreturn qry />
</cffunction>

<!--- Update all Metadata --->
<cffunction name="copymetadataupdate" output="false" >
	<cfargument name="thestruct" type="struct">
	<!--- <cfquery name="select_images" datasource="#application.razuna.datasource#">
		SELECT img_filename,shared FROM #session.hostdbprefix#images
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="cf_sql_varchar" >
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery> --->
	<cfquery name="select_images_text" datasource="#application.razuna.datasource#">
		SELECT img_description,img_keywords FROM #session.hostdbprefix#images_text
		WHERE img_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="cf_sql_varchar" >
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfquery name="select_xmp" datasource="#application.razuna.datasource#">
		SELECT subjectcode,creator,title,authorsposition,captionwriter,ciadrextadr,category,supplementalcategories,urgency,description,ciadrcity,ciadrctry,location,
		ciadrpcode,ciemailwork,ciurlwork,citelwork,intellectualgenre,instructions,source,usageterms,copyrightstatus,transmissionreference,webstatement,headline,
		datecreated,city,ciadrregion,country,countrycode,scene,state,credit,rights FROM #session.hostdbprefix#xmp
		WHERE id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="cf_sql_varchar" >
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Update the tables --->
	<cfif arguments.thestruct.insert_type EQ 'replace'>
		<!--- <cfquery name="updateimages" datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images SET 
			img_filename = <cfqueryparam value="#select_images.img_filename#" cfsqltype="cf_sql_varchar">,
			shared = <cfqueryparam value="#select_images.shared#" cfsqltype="cf_sql_varchar">
			WHERE img_id IN (<cfqueryparam value="#arguments.thestruct.idList#" cfsqltype="cf_sql_varchar" list="true">)
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery> --->
		<cfquery name="updateimges_text" datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images_text SET 
			img_description = <cfqueryparam value="#select_images_text.img_description#" cfsqltype="cf_sql_varchar">,
			img_keywords = <cfqueryparam value="#select_images_text.img_keywords#" cfsqltype="cf_sql_varchar">
			WHERE img_id_r IN (<cfqueryparam value="#arguments.thestruct.idList#" cfsqltype="cf_sql_varchar" list="true">)
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery name="updateimges_text" datasource="#application.razuna.datasource#" >
			UPDATE #session.hostdbprefix#xmp
				SET
				subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.subjectcode#">,
				creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.creator#">, 
				title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.title#">, 
				authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.authorsposition#">, 
				captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.captionwriter#">, 
				ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrextadr#">, 
				category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.category#">, 
				supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.supplementalcategories#">, 
				urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.urgency#">, 
				description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.description#">, 
				ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrcity#">, 
				ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrctry#">, 
				location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.location#">, 
				ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrpcode#">, 
				ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciemailwork#">, 
				ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciurlwork#">, 
				citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.citelwork#">, 
				intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.intellectualgenre#">, 
				instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.instructions#">, 
				source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.source#">, 
				usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.usageterms#">, 
				copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.copyrightstatus#">, 
				transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.transmissionreference#">, 
				webstatement = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.webstatement#">, 
				headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.headline#">, 
				datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.datecreated#">, 
				city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.city#">, 
				ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrregion#">, 
				country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.country#">, 
				countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.countrycode#">, 
				scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.scene#">, 
				state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.state#">, 
				credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.credit#">, 
				rights  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.rights#">
				WHERE id_r IN (<cfqueryparam value="#arguments.thestruct.idList#" cfsqltype="cf_sql_varchar" list="true">)
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfelse>
		<cfloop list="#arguments.thestruct.idList#" index="theidtoupdate" >
			<cfquery name="append_images" datasource="#application.razuna.datasource#">
				SELECT img_filename,shared FROM #session.hostdbprefix#images
				WHERE img_id = <cfqueryparam value="#theidtoupdate#" cfsqltype="cf_sql_varchar" >
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfquery name="append_images_text" datasource="#application.razuna.datasource#">
				SELECT img_description,img_keywords FROM #session.hostdbprefix#images_text
				WHERE img_id_r = <cfqueryparam value="#theidtoupdate#" cfsqltype="cf_sql_varchar" >
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfquery name="append_xmp" datasource="#application.razuna.datasource#">
				SELECT subjectcode,creator,title,authorsposition,captionwriter,ciadrextadr,category,supplementalcategories,urgency,description,ciadrcity,ciadrctry,location,
				ciadrpcode,ciemailwork,ciurlwork,citelwork,intellectualgenre,instructions,source,usageterms,copyrightstatus,transmissionreference,webstatement,headline,
				datecreated,city,ciadrregion,country,countrycode,scene,state,credit,rights FROM #session.hostdbprefix#xmp
				WHERE id_r = <cfqueryparam value="#theidtoupdate#" cfsqltype="cf_sql_varchar" >
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfquery name="updateimagestext" datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images_text SET 
				img_description = <cfqueryparam value="#append_images_text.img_description# #select_images_text.img_description#" cfsqltype="cf_sql_varchar">,
				img_keywords = <cfqueryparam value="#append_images_text.img_keywords# #select_images_text.img_keywords#" cfsqltype="cf_sql_varchar">
				WHERE img_id_r = <cfqueryparam value="#theidtoupdate#" cfsqltype="cf_sql_varchar">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfquery name="updatexmp" datasource="#application.razuna.datasource#" >
				UPDATE #session.hostdbprefix#xmp
					SET
					subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.subjectcode# #select_xmp.subjectcode#">,
					creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.creator# #select_xmp.creator#">, 
					title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.title# #select_xmp.title#">, 
					authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.authorsposition# #select_xmp.authorsposition#">, 
					captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.captionwriter# #select_xmp.captionwriter#">, 
					ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrextadr#">, 
					category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.category#">, 
					supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.supplementalcategories# #select_xmp.supplementalcategories#">, 
					urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.urgency# #select_xmp.urgency#">, 
					description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.description# #select_xmp.description#">, 
					ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrcity#">, 
					ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrctry#">, 
					location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.location#">, 
					ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrpcode#">, 
					ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciemailwork#">, 
					ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciurlwork#">, 
					citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.citelwork#">, 
					intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.intellectualgenre# #select_xmp.intellectualgenre#">, 
					instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.instructions# #select_xmp.instructions#">, 
					source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.source# #select_xmp.source#">, 
					usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.usageterms# #select_xmp.usageterms#">, 
					copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.copyrightstatus# #select_xmp.copyrightstatus#">, 
					transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.transmissionreference# #select_xmp.transmissionreference#">, 
					webstatement = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.webstatement# #select_xmp.webstatement#">, 
					headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.headline# #select_xmp.headline#">, 
					datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.datecreated#">, 
					city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.city#">, 
					ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.ciadrregion#">, 
					country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.country#">, 
					countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.countrycode#">, 
					scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.scene# #select_xmp.scene#">, 
					state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_xmp.state#">, 
					credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.credit# #select_xmp.credit#">, 
					rights  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#append_xmp.rights# #select_xmp.rights#">
					WHERE id_r = <cfqueryparam value="#theidtoupdate#" cfsqltype="cf_sql_varchar">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
	</cfif>
</cffunction>
<!--- Get all asset from folder --->
<cffunction name="getAllFolderAsset" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#application.razuna.datasource#" name="qry_data">
		SELECT img_id AS id,img_filename AS filename
		FROM #session.hostdbprefix#images
		WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
		AND img_group IS NULL
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry_data>
</cffunction>
</cfcomponent>