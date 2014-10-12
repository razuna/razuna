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
<cfset variables.cachetoken = getcachetoken("general")>

<!--- GET ALL COLLECTIONS --->
<cffunction name="getAll" output="false">
	<cfargument name="lang" required="yes" type="numeric">
	<cfargument name="thestruct" required="no" type="struct">
	<!--- init local vars --->
	<cfset var qry = structnew()>
	<!--- Params --->
	<cfparam default="0" name="arguments.thestruct.folder_id">
	<cfparam default="false" name="arguments.thestruct.released">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("general")>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qrylist" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getAllcol */ c.col_id, c.change_date, ct.col_name, c.col_released,
	lower(ct.col_name) AS namesort,
	<!--- Permission follow but not for sysadmin and admin --->
	<cfif not Request.securityObj.CheckSystemAdminUser() and not Request.securityObj.CheckAdministratorUser()>
		CASE
			WHEN EXISTS(
				SELECT fg.col_id_r
				FROM #session.hostdbprefix#collections_groups fg LEFT JOIN ct_groups_users gu ON gu.ct_g_u_grp_id = fg.grp_id_r AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
				WHERE fg.col_id_r = c.col_id
				AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				) THEN 'unlocked'
			<!--- If this is the user folder or he is the owner --->
			WHEN ( c.col_owner = '#Session.theUserID#' ) THEN 'unlocked'
			<!--- If nothing meets the above lock the folder --->
			ELSE 'locked'
		END AS perm
	<cfelse>
		'unlocked' AS perm
	</cfif>
	FROM #session.hostdbprefix#collections c
	LEFT JOIN #session.hostdbprefix#collections_text ct ON c.col_id = ct.col_id_r 
	WHERE c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND c.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	<cfif structkeyexists(arguments.thestruct,"withfolder")>
		AND c.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
	</cfif>
	AND c.col_released = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.released#">
	GROUP BY c.col_id, c.change_date, ct.col_name, c.col_released, c.col_owner
	</cfquery>
	<!--- Query to get unlocked collections only --->
	<cfquery dbtype="query" name="qry.collist">
	SELECT *
	FROM qrylist
	WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
	ORDER BY namesort
	</cfquery>
	<!--- Get descriptions --->
	<cfif qry.collist.recordcount NEQ 0>
		<cfquery datasource="#variables.dsn#" name="qry.collistdesc" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getAlldesccol */ col_id_r, col_desc, lang_id_r
		FROM #session.hostdbprefix#collections_text
		WHERE col_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#valuelist(qry.collist.col_id)#" list="Yes">)
		ORDER BY lang_id_r
		</cfquery>
	</cfif>
	<cfreturn qry />
</cffunction>

<!--- LIST COLLECTION ITEMS --->
<cffunction name="content_collection" output="false" returntype="query">
	<cfargument name="col_id" required="true" type="string">
	<!--- init local vars --->
	<cfset var qry = 0>
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#content_collection */ file_id_r, col_file_type, col_item_order, col_file_format
	FROM #session.hostdbprefix#collections_ct_files
	WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.col_id#">
	ORDER BY col_item_order
	</cfquery>
	<cfreturn qry />
</cffunction>

<!--- ADD COLLECTION --->
<cffunction name="add" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam default="0" name="newcolid">
	<!--- Check if a collection by this name exists in this folder --->
	<cfquery datasource="#variables.dsn#" name="here">
	SELECT c.col_id, ct.col_name
	FROM #session.hostdbprefix#collections c, #session.hostdbprefix#collections_text ct
	WHERE c.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
	AND c.col_id = ct.col_id_r
	AND lower(ct.col_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.collectionname)#">
	AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Collection not here thus continue --->
	<cfif here.recordcount EQ 0>
		<!--- Create a new ID --->
		<cfset var newcolid = createuuid("")>
		<!--- Param --->
		<cfset var col_shared = "F">
		<cfset var share_dl_org = "F">
		<cfset var share_dl_thumb = "F">
		<cfset var share_comments = "F">
		<cfset var share_upload = "F">
		<!--- Get custom settings --->
		<cfinvoke component="settings" method="get_customization" returnvariable="cs" />
		<!--- Set settings according to settings --->
		<cfif cs.share_folder>
			<cfset var col_shared = "T">
		</cfif>
		<cfif cs.share_download_thumb>
			<cfset var share_dl_thumb = "T">
		</cfif>
		<cfif cs.share_download_original>
			<cfset var share_dl_org = "T">
		</cfif>
		<cfif cs.share_comments>
			<cfset var share_comments = "T">
		</cfif>
		<cfif cs.share_uploading>
			<cfset var share_upload = "T">
		</cfif>
		<!--- Add to main table --->
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#collections
		(col_id,folder_id_r,col_owner,create_date,create_time,change_date,change_time, host_id, col_shared, share_dl_org, share_dl_thumb, share_comments, share_upload)
		VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newcolid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#col_shared#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#share_dl_org#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#share_dl_thumb#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#share_comments#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#share_upload#">
		)
		</cfquery>
		<!--- Add name, description and keywords --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<cfset thisdesc = "arguments.thestruct.col_desc_" & "#langindex#">
			<cfset thiskeys = "arguments.thestruct.col_keywords_" & "#langindex#">
			<cfif thisdesc CONTAINS "#langindex#">
				<cfquery datasource="#variables.dsn#">
					insert into #session.hostdbprefix#collections_text
					(col_id_r, lang_id_r, col_desc, col_keywords, col_name, host_id, rec_uuid)
					values(
					<cfqueryparam value="#newcolid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#evaluate(thisdesc)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#evaluate(thiskeys)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#trim(arguments.thestruct.collectionname)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<!--- Return the col id --->
	<cfreturn newcolid>
</cffunction>

<!--- ADD ASSETS TO COLLECTION --->
<cffunction name="add_assets" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Loop over the file_id and add the items in the basket --->
	<cfloop query="arguments.thestruct.qry_basket">
		<!--- Check if file is already there --->
		<cfquery datasource="#variables.dsn#" name="here">
		SELECT file_id_r
		FROM #session.hostdbprefix#collections_ct_files
		WHERE file_id_r = <cfqueryparam value="#cart_product_id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_file_type = <cfqueryparam value="#cart_file_type#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- If this file is not in this collection then insert --->
		<cfif here.recordcount EQ 0>
			<!--- Get the order --->
			<cfquery datasource="#Variables.dsn#" name="theorder">
			SELECT max(col_item_order) as col_item_order
			FROM #session.hostdbprefix#collections_ct_files
			WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfif theorder.col_item_order EQ "">
				<cfset neworder = 1>
			<cfelse>
				<cfset neworder = #theorder.col_item_order# + 1>
			</cfif>
			<!--- Insert --->
			<cfquery datasource="#variables.dsn#">
			INSERT INTO #session.hostdbprefix#collections_ct_files
			(col_id_r, file_id_r, col_file_type, col_item_order, col_file_format, host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#cart_product_id#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#cart_file_type#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#neworder#" cfsqltype="cf_sql_numeric">,
			<cfif cart_file_type EQ "img">
				<cfqueryparam value="thumb" cfsqltype="cf_sql_varchar">
			<cfelseif cart_file_type EQ "vid">
				<cfqueryparam value="video" cfsqltype="cf_sql_varchar">
			<cfelse>
				<cfqueryparam value="" cfsqltype="cf_sql_varchar">
			</cfif>,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		<cfelse> <!--- If file already in collection the set in_trash to false if set to true --->
			<cfquery datasource="#Variables.dsn#" name="theorder">
			UPDATE #session.hostdbprefix#collections_ct_files
			SET in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
			WHERE file_id_r = <cfqueryparam value="#cart_product_id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="#cart_file_type#" cfsqltype="cf_sql_varchar">
			AND in_trash = <cfqueryparam value="T" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
</cffunction>

<!--- ADD SINGLE ASSETS TO COLLECTION --->
<cffunction name="add_assets_single" output="false">
	<cfargument name="thestruct" type="struct">
		<!--- Check if file is already there --->
		<cfquery datasource="#variables.dsn#" name="here">
		SELECT file_id_r
		FROM #session.hostdbprefix#collections_ct_files
		WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_file_type = <cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- If this file is not in this collection then insert --->
		<cfif here.recordcount EQ 0>
			<!--- Get the order --->
			<cfquery datasource="#Variables.dsn#" name="theorder">
			SELECT max(col_item_order) as col_item_order
			FROM #session.hostdbprefix#collections_ct_files
			WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfif theorder.col_item_order EQ "">
				<cfset neworder = 1>
			<cfelse>
				<cfset neworder = #theorder.col_item_order# + 1>
			</cfif>
			<!--- Insert --->
			<cfquery datasource="#variables.dsn#">
			INSERT INTO #session.hostdbprefix#collections_ct_files
			(col_id_r, file_id_r, col_file_type, col_item_order, col_file_format, host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#neworder#" cfsqltype="cf_sql_numeric">,
			<cfif arguments.thestruct.thetype EQ "img">
				<cfqueryparam value="thumb" cfsqltype="cf_sql_varchar">
			<cfelseif arguments.thestruct.thetype EQ "vid">
				<cfqueryparam value="video" cfsqltype="cf_sql_varchar">
			<cfelse>
				<cfqueryparam value="" cfsqltype="cf_sql_varchar">
			</cfif>,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		<cfelse> <!--- If file already in collection the set in_trash to false if set to true --->
			<cfquery datasource="#Variables.dsn#" name="theorder">
			UPDATE #session.hostdbprefix#collections_ct_files
			SET in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
			WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar">
			AND in_trash = <cfqueryparam value="T" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
</cffunction>

<!--- ADD ASSETS FROM LIST --->
<cffunction name="add_assets_loop" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Loop over the files ids --->
	<cfloop list="#session.file_id#" delimiters="," index="fileid">
		<!--- Get the ID and create thetype --->
		<cfif fileid CONTAINS "-img">
			<cfset arguments.thestruct.file_id = listfirst(fileid,"-")>
			<cfset arguments.thestruct.thetype = "img">
		<cfelseif fileid CONTAINS "-vid">
			<cfset arguments.thestruct.file_id = listfirst(fileid,"-")>
			<cfset arguments.thestruct.thetype = "vid">
		<cfelseif fileid CONTAINS "-aud">
			<cfset arguments.thestruct.file_id = listfirst(fileid,"-")>
			<cfset arguments.thestruct.thetype = "aud">
		<cfelse>
			<cfset arguments.thestruct.file_id = listfirst(fileid,"-")>
			<cfset arguments.thestruct.thetype = "doc">
		</cfif>
		<!--- Add Assets to Collection --->
		<cfinvoke method="add_assets_single" thestruct="#arguments.thestruct#">
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
</cffunction>

<!--- LIST COLLECTION DETAIL --->
<cffunction name="details" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- If there is no session for webgroups set --->
	<cfparam default="0" name="session.thegroupofuser">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#detailscol */ ct.col_name, ct.col_desc, ct.col_keywords, ct.lang_id_r, c.col_shared, c.col_name_shared, c.share_dl_org, 
	c.share_dl_thumb, c.share_comments, c.col_released, c.share_upload, c.share_order, c.share_order_user
	<!--- Permfolder --->
	<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
		, 'X' as colaccess
	<cfelse>
		,
		CASE
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#collections_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.col_id_r = c.col_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#collections_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.col_id_r = c.col_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#collections_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.col_id_r = c.col_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X'
			WHEN (c.col_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">) THEN 'X'
		END as colaccess
	</cfif>
	FROM #session.hostdbprefix#collections_text ct, #session.hostdbprefix#collections c
	WHERE ct.col_id_r = c.col_id
	AND c.col_id = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- GET COLLECTION ASSETS --->
<cffunction name="get_assets" output="false">
	<cfargument name="thestruct" type="struct">
	<cfparam name="arguments.thestruct.colaccess" default="">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#get_assetscol */ ct.col_id_r, ct.file_id_r as cart_product_id, ct.col_file_type, ct.col_item_order, ct.col_file_format,
		CASE 
			WHEN ct.col_file_type = 'doc' 
				THEN (
					SELECT file_name 
					FROM #session.hostdbprefix#files 
					WHERE file_id = ct.file_id_r
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
			WHEN ct.col_file_type = 'img'
				THEN (
					SELECT img_filename 
					FROM #session.hostdbprefix#images 
					WHERE img_id = ct.file_id_r
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
			WHEN ct.col_file_type = 'vid'
				THEN (
					SELECT vid_filename 
					FROM #session.hostdbprefix#videos 
					WHERE vid_id = ct.file_id_r
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
			WHEN ct.col_file_type = 'aud'
				THEN (
					SELECT aud_name 
					FROM #session.hostdbprefix#audios 
					WHERE aud_id = ct.file_id_r
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
		END as filename,
		CASE 
			WHEN ct.col_file_type = 'doc' 
				THEN (
					SELECT file_extension
					FROM #session.hostdbprefix#files 
					WHERE file_id = ct.file_id_r
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
			WHEN ct.col_file_type = 'aud' 
				THEN (
					SELECT aud_extension
					FROM #session.hostdbprefix#audios 
					WHERE aud_id = ct.file_id_r
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
		END as theextension
	FROM #session.hostdbprefix#collections_ct_files ct 
	LEFT JOIN #session.hostdbprefix#images i ON ct.file_id_r = i.img_id 
	LEFT JOIN #session.hostdbprefix#audios a ON ct.file_id_r = a.aud_id AND lower(a.in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">
	LEFT JOIN #session.hostdbprefix#videos v ON ct.file_id_r = v.vid_id AND lower(v.in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">
	LEFT JOIN #session.hostdbprefix#files f ON ct.file_id_r = f.file_id AND lower(f.in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">
	WHERE ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	AND ct.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	<cfif arguments.thestruct.colaccess EQ 'R'>
		AND (i.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR i.expiry_date is null)
		AND (a.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR a.expiry_date is null)
		AND (v.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR v.expiry_date is null)
		AND (f.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR f.expiry_date is null)
	</cfif>
	AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#images WHERE img_id = i.img_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
	AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#audios WHERE aud_id = a.aud_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
	AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#videos WHERE vid_id = v.vid_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
	AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#files WHERE file_id = f.file_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
	GROUP BY ct.col_id_r, ct.file_id_r, ct.col_file_type, ct.col_item_order, ct.col_file_format
	ORDER BY ct.col_item_order
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- MOVE COLLECTION ASSET TO TRASH--->
<cffunction name="col_asset_move_trash" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#Variables.dsn#" name="move_trash">
	UPDATE #session.hostdbprefix#collections_ct_files 
	SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">,
	col_item_order = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
	WHERE col_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.col_id#">
	AND file_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
</cffunction>

<!--- MOVE COLLECTION TO TRASH--->
<cffunction name="col_move_trash" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#Variables.dsn#" name="move_trash">
	UPDATE #session.hostdbprefix#collections 
	SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	WHERE col_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#">
	AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("labels")>
</cffunction>

<!--- GET COLLECTION FILES FROM TRASH --->
<cffunction name="get_trash_files" output="false">
	<cfargument name="noread" required="false" default="false">
	<!--- Param --->
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT c.col_id_r AS col_id, col.folder_id_r AS folder_id, i.img_filename AS filename, c.file_id_r AS file_id, i.folder_id_r, '' AS folder_main_id_r, 
		c.col_item_order, i.img_id AS id, i.thumb_extension AS ext, i.img_filename_org AS filename_org, 'img' AS kind, i.link_kind AS link_kind,
		i.path_to_asset, i.cloud_url, i.cloud_url_org, i.hashtag
		<!--- Permfolder --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'R' THEN 'R'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'W' THEN 'W'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#collections_ct_files AS c
		INNER JOIN  #session.hostdbprefix#images i ON c.file_id_r = i.img_id
		LEFT JOIN  #session.hostdbprefix#collections AS col ON c.col_id_r = col.col_id
		WHERE c.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND c.col_file_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="img">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!--- Audios --->
		UNION ALL
		SELECT c.col_id_r AS col_id, col.folder_id_r AS folder_id, a.aud_name AS filename, c.file_id_r AS file_id, a.folder_id_r, '' AS folder_main_id_r, 
		c.col_item_order, a.aud_id AS id, a.aud_extension AS ext, a.aud_name_org AS filename_org, 'aud' AS kind, a.link_kind,
		a.path_to_asset, a.cloud_url, a.cloud_url_org, a.hashtag
		<!--- Permfolder --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'R' THEN 'R'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'W' THEN 'W'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#collections_ct_files AS c
		INNER JOIN  #session.hostdbprefix#audios a  ON c.file_id_r = a.aud_id
		LEFT JOIN  #session.hostdbprefix#collections AS col ON c.col_id_r = col.col_id
		WHERE c.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND c.col_file_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="aud">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!--- Videos --->
		UNION ALL
		SELECT c.col_id_r AS col_id, col.folder_id_r AS folder_id, v.vid_filename AS filename, c.file_id_r AS file_id, v.folder_id_r, '' AS folder_main_id_r, 
		c.col_item_order, v.vid_id AS id, v.vid_extension AS ext, v.vid_name_image AS filename_org, 'vid' AS kind, v.link_kind, v.path_to_asset, 
		v.cloud_url, v.cloud_url_org, v.hashtag
		<!--- Permfolder --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'R' THEN 'R'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'W' THEN 'W'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#collections_ct_files AS c
		INNER JOIN  #session.hostdbprefix#videos v ON c.file_id_r = v.vid_id
		LEFT JOIN  #session.hostdbprefix#collections AS col ON c.col_id_r = col.col_id
		WHERE c.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND c.col_file_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="vid">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<!--- Files --->
		UNiON ALL
		SELECT c.col_id_r AS col_id, col.folder_id_r AS folder_id, f.file_name AS filename, c.file_id_r AS file_id, f.folder_id_r, '' AS folder_main_id_r, 
		c.col_item_order, f.file_id AS id,
		f.file_extension AS ext, f.file_name_org AS filename_org, 'doc' AS kind, f.link_kind, f.path_to_asset, f.cloud_url, 
		f.cloud_url_org, f.hashtag
		<!--- Permfolder --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'R' THEN 'R'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'W' THEN 'W'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = col.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#collections_ct_files AS c
		INNER JOIN  #session.hostdbprefix#files f  ON c.file_id_r = f.file_id
		LEFT JOIN  #session.hostdbprefix#collections AS col ON c.col_id_r = col.col_id
		WHERE c.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND c.col_file_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="doc">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfquery name="qry" dbtype="query">
		SELECT *
		FROM qry
		WHERE permfolder != <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">
		<cfif noread>
			AND lower(permfolder) != <cfqueryparam value="r" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>
	</cfquery>
	<!--- Return --->
	<cfreturn qry />
</cffunction>

<!--- GET COLLECTION FOLDERS FROM TRASH --->
<cffunction name="get_trash_folders" output="false">
	<cfargument name="noread" required="false" default="false">
	<!--- Param --->
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT '' AS col_id, f.folder_id,f.folder_level,f.folder_name AS filename, f.folder_id AS file_id, f.folder_id_r, f.folder_main_id_r, '' AS col_item_order, 
		f.folder_id AS id, '' AS ext, '' AS filename_org, 'folder' AS kind, '' AS link_kind, '' AS path_to_asset, '' AS cloud_url, 
		'' AS cloud_url_org, '' AS hashtag
		<!--- Permfolder --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'R' THEN 'R'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'W' THEN 'W'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#folders f 
		WHERE f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND f.folder_is_collection = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfquery name="qry" dbtype="query">
		SELECT *
		FROM qry
		WHERE permfolder != <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">
		<cfif noread>
			AND lower(permfolder) != <cfqueryparam value="r" cfsqltype="CF_SQL_VARCHAR">
		 </cfif> 
	</cfquery>
	<!--- Return --->
	<cfreturn qry />
</cffunction>

<!--- GET COLLECTION FROM TRASH  --->
<cffunction name="get_trash_collection" output="false">
	<cfargument name="noread" required="false" default="false">
	<!--- Param --->
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT c.col_id AS col_id, c.folder_id_r AS folder_id, col_text.col_name AS filename, '' AS file_id, c.folder_id_r, '' AS folder_main_id_r, 
		'' AS col_item_order, c.col_id AS id, '' AS ext, '' AS filename_org, 'collection' AS kind, '' AS link_kind, '' AS path_to_asset, 
		'' AS cloud_url, '' AS cloud_url_org, '' AS hashtag
		<!--- Permfolder --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = c.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'R' THEN 'R'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = c.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'W' THEN 'W'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = c.folder_id_r
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#collections AS c
		INNER JOIN #session.hostdbprefix#collections_text AS col_text ON col_text.col_id_r = c.col_id
		WHERE c.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="1">
	</cfquery>
	<cfquery name="qry" dbtype="query">
		SELECT *
		FROM qry
		WHERE permfolder != <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">
		<cfif noread>
			AND lower(permfolder) != <cfqueryparam value="r" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>
	</cfquery>
	<!--- Return --->
	<cfreturn qry />
</cffunction>

<!--- RESTORE COLLECTION ASSET--->
<cffunction name="restore_col_asset" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#Variables.dsn#" name="thedetail">
	SELECT col_id,folder_id_r AS folder_id FROM #session.hostdbprefix#collections 
	WHERE col_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.col_id#">
	AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfset var local = structNew()>
	<cfif thedetail.RecordCount EQ 0>
		<cfset local.istrash = "trash">
	<cfelse>
		<cfquery datasource="#Variables.dsn#" name="thefolderdetail">
		SELECT folder_id,folder_id_r,folder_main_id_r FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thedetail.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
		</cfquery>
		<cfquery datasource="#Variables.dsn#" name="dir_parent_id">
		SELECT folder_id,folder_id_r,in_trash FROM #session.hostdbprefix#folders 
		WHERE folder_main_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thefolderdetail.folder_main_id_r#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfloop query="dir_parent_id">
			<cfquery datasource="#application.razuna.datasource#" name="get_qry">
			SELECT folder_id,folder_id_r,in_trash FROM #session.hostdbprefix#folders 
			WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dir_parent_id.folder_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfif get_qry.in_trash EQ 'T'>
				<cfset local.istrash = "trash">
				<cfbreak />
			<cfelseif get_qry.folder_id EQ dir_parent_id.folder_id_r AND get_qry.in_trash EQ 'F'>
				<cfset local.root = "yes">
				<cfquery datasource="#Variables.dsn#" name="update_trash">
				UPDATE #session.hostdbprefix#collections_ct_files 
				SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE col_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.col_id#">
				AND file_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("general")>
	</cfif>
	<cfif isDefined('local.istrash') AND local.istrash EQ "trash">
		<cfset var is_trash = "intrash">
	<cfelse>
		<cfset var is_trash = "notrash">
	</cfif>
	<cfreturn is_trash />
</cffunction>

<!--- CHECK PARENT DIRECTORY FOR RESTORE COLLECTION --->
<cffunction name="restore_collection" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#Variables.dsn#" name="thedetail">
	SELECT folder_id_r,folder_main_id_r FROM #session.hostdbprefix#folders
	WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
	AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
	</cfquery>
	<cfset var local = structNew()>
	<cfif thedetail.RecordCount EQ 0>
		<cfset local.istrash = "trash">
	<cfelse>
		<cfquery datasource="#Variables.dsn#" name="dir_parent_id">
		SELECT folder_id,folder_id_r,in_trash FROM #session.hostdbprefix#folders
		WHERE folder_main_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thedetail.folder_main_id_r#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
		</cfquery>
		<cfloop query="dir_parent_id">
			<cfquery datasource="#application.razuna.datasource#" name="get_qry">
			SELECT folder_id,folder_id_r,in_trash FROM #session.hostdbprefix#folders 
			WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dir_parent_id.folder_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfif get_qry.in_trash EQ 'T'>
				<cfset local.istrash = "trash">
				<cfbreak />
			<cfelseif get_qry.folder_id EQ dir_parent_id.folder_id_r AND get_qry.in_trash EQ 'F'>
				<cfset local.root = "yes">
				<cfquery datasource="#Variables.dsn#" name="qry_update">
				UPDATE #session.hostdbprefix#collections 
				SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE col_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.col_id#">
				AND folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("folder")>
	<cfset resetcachetoken("labels")>
	<cfif isDefined('local.istrash') AND local.istrash EQ "trash">
		<cfset var is_trash = "intrash">
	<cfelse>
		<cfset var is_trash = "notrash">
	</cfif>
	<cfreturn is_trash />
</cffunction>

<!--- RESTORE ASSET COLLECTION --->
<cffunction name="restoreasset" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#Variables.dsn#" name="qry_restore">
	UPDATE #session.hostdbprefix#collections_ct_files 
	SET 
	col_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.col_id#">,
	in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	WHERE file_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.file_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
</cffunction>

<!--- RESTORE COLLECTION --->
<cffunction name="restorecollection" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#Variables.dsn#" name="qry_restore">
	UPDATE #session.hostdbprefix#collections
	SET 
	folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
	in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	WHERE col_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.col_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- COLLECTION TRASH COUNT IN COLLECTIONS--->
<cffunction name="get_col_count" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#application.razuna.datasource#" name="qry_count">
		SELECT COUNT(col_id) AS cnt
		FROM #session.hostdbprefix#collections col
		WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND CASE
			<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
				WHEN 1=1 THEN 'X' 
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = col.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = col.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = col.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	</cfquery>
	<!--- Return --->
	<cfreturn qry_count>
</cffunction>

<!--- FOLDER TRASH COUNT IN COLLECTIONS--->
<cffunction name="getCollectionFolderCount" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#application.razuna.datasource#" name="qry_count">
		SELECT COUNT(folder_id) AS cnt
		FROM #session.hostdbprefix#folders f WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND folder_is_collection = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND CASE
			<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
				WHEN 1=1 THEN 'X' 
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	</cfquery>
	<!--- Return --->
	<cfreturn qry_count>
</cffunction>

<!---  FILE TRASH COUNT COLLECTION--->
<cffunction name="getCollectionFileCount" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#application.razuna.datasource#" name="qry_count">
		SELECT COUNT(col_id_r) AS cnt
		FROM #session.hostdbprefix#collections_ct_files c, #session.hostdbprefix#collections col
		WHERE c.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND c.col_id_r = col.col_id
		AND CASE
			<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
				WHEN 1=1 THEN 'X' 
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = col.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = col.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = col.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	</cfquery>
	<!--- Return --->
	<cfreturn qry_count>
</cffunction>

<!--- MOVE COLLECTION ITEMS --->
<cffunction name="move" output="false">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<!--- Get the record which is one order higher --->
		<cfquery datasource="#variables.dsn#" name="oneup">
		SELECT file_id_r, col_item_order
		FROM #session.hostdbprefix#collections_ct_files
		WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_item_order = <cfqueryparam value="#arguments.thestruct.moveto#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- Get the record of the current order --->
		<cfquery datasource="#variables.dsn#" name="current">
		SELECT file_id_r, col_item_order
		FROM #session.hostdbprefix#collections_ct_files
		WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_item_order = <cfqueryparam value="#arguments.thestruct.currentorder#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- update the item with the moveto variable --->
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#collections_ct_files
		SET col_item_order = <cfqueryparam value="#arguments.thestruct.moveto#" cfsqltype="cf_sql_numeric">
		WHERE file_id_r = <cfqueryparam value="#current.file_id_r#" cfsqltype="CF_SQL_VARCHAR">
		AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- update the move to item with the currentorder variable --->
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#collections_ct_files
		SET col_item_order = <cfqueryparam value="#arguments.thestruct.currentorder#" cfsqltype="cf_sql_numeric">
		WHERE file_id_r = <cfqueryparam value="#oneup.file_id_r#" cfsqltype="CF_SQL_VARCHAR">
		AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Flush Cache --->
		<cfset resetcachetoken("general")>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while moviing item in collection in function collections.move">
			<cfset cfcatch.thestruct = arguments.thestruct>
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
</cffunction>

<!--- REMOVE ITEM FROM COLLECTION --->
<cffunction name="removeitem" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#collections_ct_files
	WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Rearrange the order --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#collections_ct_files
	SET col_item_order = col_item_order - 1
	WHERE col_item_order > <cfqueryparam value="#arguments.thestruct.order#" cfsqltype="cf_sql_numeric">
	AND col_item_order <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> 1
	AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
</cffunction>

<!--- TRASH ITEM FROM COLLECTION --->
<cffunction name="trashitem" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Update in_trash --->
	<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#collections_ct_files 
		SET in_trash=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.trash#">
		WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<!--- Rearrange the order --->
	<cfquery datasource="#variables.dsn#">
	UPDATE #session.hostdbprefix#collections_ct_files
	SET col_item_order = col_item_order - 1
	WHERE col_item_order > <cfqueryparam value="#arguments.thestruct.order#" cfsqltype="cf_sql_numeric">
	AND col_item_order <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> 1
	AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("labels")>
</cffunction>

<!--- REMOVE COLLECTION --->
<cffunction name="remove" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- MSSQL: Drop all constraints --->
	<cfif application.razuna.thedatabase EQ "mssql">
		<!--- <cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE #application.razuna.theschema#.#session.hostdbprefix#folders DROP CONSTRAINT
		</cfquery> --->
	<!--- MySQL --->
	<cfelseif application.razuna.thedatabase EQ "mysql">
		<cfquery datasource="#application.razuna.datasource#">
		SET foreign_key_checks = 0
		</cfquery>
	<!--- H2 --->
	<cfelseif application.razuna.thedatabase EQ "h2">
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE #session.hostdbprefix#folders SET REFERENTIAL_INTEGRITY false
		</cfquery>
	</cfif>
	<!--- delete collection files db --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#collections_ct_files
	WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	</cfquery>
	<!--- delete collection_text db --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#collections_text
	WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- delete collection db --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#collections
	WHERE col_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	</cfquery>
	<!--- Delete labels --->
	<cfinvoke component="labels" method="label_ct_remove" id="#arguments.thestruct.id#" />
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
</cffunction>


<!--- TRASH COLLECTION --->
<cffunction name="trash" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Update in_trash --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#collections 
	SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.trash#">
	WHERE col_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
</cffunction>

<!--- UPDATE --->
<cffunction name="update" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.col_shared" default="F">
	<cfparam name="arguments.thestruct.col_name_shared" default="#arguments.thestruct.col_id#">
	<cfparam name="arguments.thestruct.share_order_user" default="0">
	<cfparam name="arguments.thestruct.share_dl_org" default="f">
	<cfparam name="arguments.thestruct.share_dl_thumb" default="t">
	<cfparam name="arguments.thestruct.share_upload" default="F">
	<cfparam name="arguments.thestruct.share_comments" default="F">
	<cfparam name="arguments.thestruct.share_order" default="f">
	<cfparam name="arguments.thestruct.share_order_user" default="">
	<!--- Check if a collection by this name exists in this folder --->
	<cfquery datasource="#variables.dsn#" name="here">
	SELECT ct.col_name
	FROM #session.hostdbprefix#collections c, #session.hostdbprefix#collections_text ct
	WHERE c.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
	AND c.col_id <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
	AND c.col_id = ct.col_id_r
	AND lower(ct.col_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.collectionname)#">
	AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Collection not here thus continue --->
	<cfif here.recordcount EQ 0>
		<!--- Update --->
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#collections
		SET
		col_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
		change_date = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		col_shared = <cfqueryparam value="#arguments.thestruct.col_shared#" cfsqltype="cf_sql_varchar">,
		col_name_shared = <cfqueryparam value="#arguments.thestruct.col_name_shared#" cfsqltype="cf_sql_varchar">,
		share_dl_org = <cfqueryparam value="#arguments.thestruct.share_dl_org#" cfsqltype="cf_sql_varchar">,
		share_dl_thumb = <cfqueryparam value="#arguments.thestruct.share_dl_thumb#" cfsqltype="cf_sql_varchar">,
		share_upload = <cfqueryparam value="#arguments.thestruct.share_upload#" cfsqltype="cf_sql_varchar">,
		share_comments = <cfqueryparam value="#arguments.thestruct.share_comments#" cfsqltype="cf_sql_varchar">,
		share_order = <cfqueryparam value="#arguments.thestruct.share_order#" cfsqltype="cf_sql_varchar">,
		share_order_user = <cfqueryparam value="#arguments.thestruct.share_order_user#" cfsqltype="CF_SQL_VARCHAR">
		WHERE col_id = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Delete entry --->
		<cfquery datasource="#variables.dsn#">
		DELETE FROM #session.hostdbprefix#collections_text
		WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Add name, description and keywords --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<cfset var thisdesc="arguments.thestruct.col_desc_" & "#langindex#">
			<cfset var thiskeys="arguments.thestruct.col_keywords_" & "#langindex#">
			<cfif thisdesc CONTAINS #langindex#>
				<!--- Insert --->
				<cfquery datasource="#variables.dsn#">
				INSERT INTO #session.hostdbprefix#collections_text
				(lang_id_r, col_desc, col_keywords, col_name, col_id_r, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="#evaluate(thisdesc)#" cfsqltype="cf_sql_varchar">, 
				<cfqueryparam value="#evaluate(thiskeys)#" cfsqltype="cf_sql_varchar">, 
				<cfqueryparam value="#trim(arguments.thestruct.collectionname)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Loop over the asset ids of this collection --->
		<cfloop delimiters="," list="#arguments.thestruct.assetids#" index="id">
			<!--- Put together the ARTOFIMAGE value --->
			<cfset artofimage = "arguments.thestruct.artofimage" & id>
			<cfparam default="" name="#artofimage#">
			<!--- Update files with the choosen IMAGE format --->	
			<cfif evaluate(artofimage) NEQ "">
				<cfloop delimiters="," list="#evaluate(artofimage)#" index="art">
					<!--- Put image id and art into variables --->
					<cfset var theimgid = listfirst(art, "-")>
					<cfset var theart = listlast(art, "-")>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#collections_ct_files
					SET col_file_format = <cfqueryparam value="#theart#" cfsqltype="cf_sql_varchar">
					WHERE file_id_r = <cfqueryparam value="#theimgid#" cfsqltype="CF_SQL_VARCHAR">
					AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
				</cfloop>
			</cfif>
			<!--- Put together the ARTOFVIDEO value --->
			<cfset artofvideo = "arguments.thestruct.artofvideo" & id>
			<cfparam default="" name="#artofvideo#">
			<!--- Update files with the choosen VIDEO format --->	
			<cfif evaluate(artofvideo) NEQ "">
				<cfloop delimiters="," list="#evaluate(artofvideo)#" index="art">
					<!--- Put image id and art into variables --->
					<cfset var thevidid = listfirst(art, "-")>
					<cfset var theart = listlast(art, "-")>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#collections_ct_files
					SET col_file_format = <cfqueryparam value="#theart#" cfsqltype="cf_sql_varchar">
					WHERE file_id_r = <cfqueryparam value="#thevidid#" cfsqltype="CF_SQL_VARCHAR">
					AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
				</cfloop>
			</cfif>
			<!--- Put together the ARTOFAUDIO value --->
			<cfset artofaudio = "arguments.thestruct.artofaudio" & id>
			<cfparam default="" name="#artofaudio#">
			<!--- Update files with the choosen AUDIO format --->	
			<cfif evaluate(artofaudio) NEQ "">
				<cfloop delimiters="," list="#evaluate(artofaudio)#" index="art">
					<!--- Put image id and art into variables --->
					<cfset var theaudid = listfirst(art, "-")>
					<cfset var theart = listlast(art, "-")>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#collections_ct_files
					SET col_file_format = <cfqueryparam value="#theart#" cfsqltype="cf_sql_varchar">
					WHERE file_id_r = <cfqueryparam value="#theaudid#" cfsqltype="CF_SQL_VARCHAR">
					AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
				</cfloop>
			</cfif>
		</cfloop>
		<!--- First delete all the groups --->
		<cfquery datasource="#variables.dsn#">
		DELETE FROM #session.hostdbprefix#collections_groups
		WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Insert the Group and Permission --->
		<cfloop collection="#arguments.thestruct#" item="myform">
			<cfif #myform# CONTAINS "grp_">
				<cfset var grpid = ReplaceNoCase(#myform#, "grp_", "")>
				<cfset var theper = "per_" & "#grpid#">
				<cfquery datasource="#variables.dsn#">
				INSERT INTO #session.hostdbprefix#collections_groups
				(col_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#grpid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.thestruct[theper]#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("labels")>
	<cfset resetcachetoken("folders")>
</cffunction>

<!--- GET THE GROUPS FOR THIS COLLECTION --->
<cffunction name="getcollectiongroups" output="false">
	<cfargument name="col_id" default="" required="yes" type="string">
	<cfargument name="qrygroup" required="yes" type="query">
	<!--- Set --->
	<cfset var thegroups = 0>
	<!--- Query --->
	<cfif arguments.qrygroup.recordcount NEQ 0>
		<cfquery datasource="#variables.dsn#" name="thegroups" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getcollectiongroups */ grp_id_r, grp_permission
		FROM #session.hostdbprefix#collections_groups
		WHERE col_id_r = <cfqueryparam value="#arguments.col_id#" cfsqltype="CF_SQL_VARCHAR">
		AND grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.qrygroup.grp_id)#" list="true">)
		</cfquery>
	</cfif>
	<cfreturn thegroups>
</cffunction>

<!--- GET THE GROUPS FOR THIS FOLDER ZERO --->
<cffunction name="getcollectiongroupszero" output="false">
	<cfargument name="col_id" default="" required="yes" type="string">
	<cfquery datasource="#variables.dsn#" name="thegroups" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getcollectiongroupszero */ grp_id_r, grp_permission
	FROM #session.hostdbprefix#collections_groups
	WHERE col_id_r = <cfqueryparam value="#arguments.col_id#" cfsqltype="CF_SQL_VARCHAR">
	AND grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
	</cfquery>
	<cfreturn thegroups>
</cffunction>

<!--- Get all assets of this collection (for share) --->
<cffunction name="getallassets" output="false">
	<cfargument name="thestruct" type="struct" required="true">
	<cfparam name="arguments.thestruct.pages" default="">
	<cfparam name="arguments.thestruct.colaccess" default="">
	<!--- Param --->
	<cfset var qry = structnew()>
	<!--- If the collection has no files then set the the "IN" value to 0 or else we get errors in SQL --->
	<cfif arguments.thestruct.qry_files.recordcount NEQ 0>
		<cfset var thelist = valueList(arguments.thestruct.qry_files.cart_product_id)>
	<cfelse>
		<cfset var thelist = 0>
	</cfif>
	<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
		<!--- 
		This is for Oracle and MSQL
		Calculate the offset .Show the limit only if pages is null or current (from print) 
		--->	
		<cfif session.offset EQ 0>
			<cfset var min = 0>
			<cfset var max = session.rowmaxpage>
		<cfelse>
			<cfset var min = session.offset * session.rowmaxpage>
			<cfset var max = (session.offset + 1) * session.rowmaxpage>
			<cfif variables.database EQ "db2">
				<cfset var min = min + 1>
			</cfif>
		</cfif>
	<cfelse>
		<cfset var min = 0>
		<cfset var max = 1000>
	</cfif>
	<!--- MySQL Offset --->
	<cfset var mysqloffset = session.offset * session.rowmaxpage>
	<!--- Query --->
		
	<cfquery datasource="#variables.dsn#" name="qry.qry_files" cachedwithin="1" region="razcache">
	<!--- For pagination  --->
	<cfif NOT structKeyExists(arguments.thestruct,"searchtext")>
		<cfif variables.dsn EQ "mssql">
			SELECT * FROM (
			SELECT ROW_NUMBER() OVER ( ORDER BY theorder) AS RowNum,sorted_inline_view.* FROM (
		</cfif>
	</cfif>
	SELECT DISTINCT /* #variables.cachetoken#getallassetscol*/ i.img_id id, i.img_filename filename, i.folder_id_r, i.thumb_extension ext, i.img_filename_org filename_org, i.is_available,
	'img' as kind, it.img_description description, it.img_keywords keywords, link_kind, link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org, i.expiry_date,
	'0' as vheight, '0' as vwidth, i.hashtag,
		(
			SELECT ct.col_item_order
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE i.img_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'img' 
		) AS theorder,
		(
			SELECT ct.col_file_format
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE i.img_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'img'
		) AS theformat
	FROM #session.hostdbprefix#collections_ct_files ct, #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
	WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thelist#" list="true">)
	AND ct.file_id_r = i.img_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">
	AND ct.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND (i.img_group IS NULL OR i.img_group = '')
	<cfif arguments.thestruct.colaccess EQ 'R'>
		AND (i.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR i.expiry_date is null)
	</cfif>
	UNION ALL
	SELECT DISTINCT v.vid_id id, v.vid_name_org filename, v.folder_id_r, v.vid_extension ext, v.vid_name_image filename_org, v.is_available,
	'vid' as kind, vt.vid_description description, vt.vid_keywords keywords, link_kind, link_path_url, v.path_to_asset, v.cloud_url, v.cloud_url_org, v.expiry_date,
	v.vid_height as vheight, v.vid_width as vwidth, v.hashtag,
		(
			SELECT ct.col_item_order
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE v.vid_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'vid' 
		) AS theorder,
		(
			SELECT ct.col_file_format
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE v.vid_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'vid'
		) AS theformat
	FROM #session.hostdbprefix#collections_ct_files ct, #session.hostdbprefix#videos v LEFT JOIN #session.hostdbprefix#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
	WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thelist#" list="true">)
	AND ct.file_id_r = v.vid_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="vid">
	AND ct.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND (v.vid_group IS NULL OR v.vid_group = '')
	<cfif arguments.thestruct.colaccess EQ 'R'>
		AND (v.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR v.expiry_date is null)
	</cfif>

	UNION ALL
	SELECT DISTINCT a.aud_id id, a.aud_name filename, a.folder_id_r, a.aud_extension ext, a.aud_name_org filename_org, a.is_available,
	'aud' as kind, aut.aud_description description, aut.aud_keywords keywords, link_kind, link_path_url, a.path_to_asset, a.cloud_url, a.cloud_url_org, a.expiry_date,
	'0' as vheight, '0' as vwidth, a.hashtag,
		(
			SELECT ct.col_item_order
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE a.aud_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'aud' 
		) AS theorder,
		(
			SELECT ct.col_file_format
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE a.aud_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'aud'
		) AS theformat
	FROM #session.hostdbprefix#collections_ct_files ct, #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
	WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thelist#" list="true">)
	AND ct.file_id_r = a.aud_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="aud">
	AND ct.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND (a.aud_group IS NULL OR a.aud_group = '')
	<cfif arguments.thestruct.colaccess EQ 'R'>
		AND (a.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR a.expiry_date is null)
	</cfif>
	UNION ALL
	SELECT DISTINCT f.file_id id, f.file_name filename, f.folder_id_r, f.file_extension ext, f.file_name_org filename_org, f.is_available,
	f.file_type as kind, ft.file_desc description, ft.file_keywords keywords, link_kind, link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url_org, f.expiry_date,
	'0' as vheight, '0' as vwidth, f.hashtag,
		(
			SELECT ct.col_item_order
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE f.file_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'doc' 
		) AS theorder,
		(
			SELECT ct.col_file_format
			FROM #session.hostdbprefix#collections_ct_files ct
			WHERE f.file_id = ct.file_id_r
			AND ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
			AND ct.col_file_type = 'doc' 
		) AS theformat
	FROM #session.hostdbprefix#collections_ct_files ct, #session.hostdbprefix#files f LEFT JOIN #session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
	WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thelist#" list="true">)
	AND ct.file_id_r = f.file_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="doc">
	AND ct.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	<cfif arguments.thestruct.colaccess EQ 'R'>
		AND (f.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR f.expiry_date is null)
	</cfif>

	<!--- For pagination --->
	<cfif NOT structKeyExists(arguments.thestruct,"searchtext")>
		<!--- MSSQL --->
		<cfif application.razuna.thedatabase EQ "mssql">
			) sorted_inline_view
			 ) resultSet
			  WHERE RowNum > #mysqloffset# AND RowNum <= #mysqloffset+session.rowmaxpage# 
		</cfif>
		<!--- MYSQL --->
		<cfif variables.dsn EQ "mysql">
			ORDER BY theorder LIMIT #mysqloffset#,#session.rowmaxpage#
		</cfif>
	</cfif>
	</cfquery>
	<!--- Get the total --->
	<cfquery datasource="#variables.dsn#" name="qry.qry_filecount">
		SELECT count(ct.col_id_r) AS thetotal 
		FROM #session.hostdbprefix#collections_ct_files ct
		LEFT JOIN #session.hostdbprefix#images i on ct.file_id_r = i.img_id
		LEFT JOIN #session.hostdbprefix#audios a on ct.file_id_r = a.aud_id
		LEFT JOIN #session.hostdbprefix#videos v on ct.file_id_r = v.vid_id
		LEFT JOIN #session.hostdbprefix#files f on ct.file_id_r = f.file_id
		WHERE ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
		AND ct.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		<cfif arguments.thestruct.colaccess EQ 'R'>
		AND (i.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR i.expiry_date is null)
		AND (a.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR a.expiry_date is null)
		AND (v.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR v.expiry_date is null)
		AND (f.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR f.expiry_date is null)
		</cfif>
		AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#images WHERE img_id = i.img_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
		AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#audios WHERE aud_id = a.aud_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
		AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#videos WHERE vid_id = v.vid_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
		AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#files WHERE file_id = f.file_id AND lower(in_trash) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">)
	</cfquery>
	<!--- Put together the lists for a collections search --->
	<cfquery dbtype="query" name="qry.listimg">
	SELECT id
	FROM qry.qry_files
	WHERE kind = <cfqueryparam cfsqltype="cf_sql_varchar" value="img">
	</cfquery>
	<cfquery dbtype="query" name="qry.listvid">
	SELECT id
	FROM qry.qry_files
	WHERE kind = <cfqueryparam cfsqltype="cf_sql_varchar" value="vid">
	</cfquery>
	<cfquery dbtype="query" name="qry.listaud">
	SELECT id
	FROM qry.qry_files
	WHERE kind = <cfqueryparam cfsqltype="cf_sql_varchar" value="aud">
	</cfquery>
	<cfquery dbtype="query" name="qry.listdoc">
	SELECT id
	FROM qry.qry_files
	WHERE kind != <cfqueryparam cfsqltype="cf_sql_varchar" value="img">
	AND kind != <cfqueryparam cfsqltype="cf_sql_varchar" value="vid">
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Release --->
<cffunction name="dorelease" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.col_name" default="" />
	<!--- Set released --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#collections
	SET col_released = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.release#">
	WHERE col_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
	</cfquery>
	<!--- Change name --->
	<cfif trim(arguments.thestruct.col_name) NEQ "">
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#collections_text
		SET col_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.thestruct.col_name)#">
		WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.thelangid#">
		</cfquery>
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Copy --->
<cffunction name="docopy" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.release" default="false">
	<cfparam name="arguments.thestruct.copycol" default="false">
	<!--- This is called if we copy at the same time --->
	<cfif arguments.thestruct.copycol>
		<!--- New ID for collection --->
		<cfset var newid = createUUID("")>
		<!--- Copy the main record --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#collections
		(col_id, folder_id_r, col_owner, create_date, create_time, change_date, change_time, col_template, col_shared, col_name_shared, share_dl_org, share_dl_thumb, share_comments, share_upload, share_order, share_order_user, host_id, col_released, col_copied_from)
		SELECT <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid#">, folder_id_r, col_owner, <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, col_template, col_shared, col_name_shared, share_dl_org, share_dl_thumb, share_comments, share_upload, share_order, share_order_user, host_id, 'true', col_id
		FROM #session.hostdbprefix#collections
		WHERE col_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		</cfquery>
		<!--- Add name, description and keywords --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<cfset var thisdesc = "arguments.thestruct.col_desc_#langindex#">
			<cfset var thiskeys = "arguments.thestruct.col_keywords_#langindex#">
			<cfif thisdesc CONTAINS "#langindex#">
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#collections_text
				(col_id_r, lang_id_r, col_desc, col_keywords, col_name, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#evaluate(thisdesc)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#evaluate(thiskeys)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#trim(arguments.thestruct.col_name)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Copy files --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#collections_ct_files
		(col_id_r, file_id_r, col_file_type, col_item_order, col_file_format, host_id, rec_uuid)
		SELECT <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid#">, file_id_r, col_file_type, col_item_order, col_file_format, host_id, <cfif application.razuna.thedatabase EQ "mssql">newid()<cfelseif application.razuna.thedatabase EQ "oracle">sys_guid()<cfelseif application.razuna.thedatabase EQ "db2">generate_unique()<cfelseif application.razuna.thedatabase EQ "h2">random_uuid()<cfelseif application.razuna.thedatabase EQ "mysql">uuid()</cfif>
		FROM #session.hostdbprefix#collections_ct_files
		WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		</cfquery>
		<!--- Groups --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#collections_groups
		(col_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
		SELECT <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid#">, grp_id_r, grp_permission, host_id, <cfif application.razuna.thedatabase EQ "mssql">newid()<cfelseif application.razuna.thedatabase EQ "oracle">sys_guid()<cfelseif application.razuna.thedatabase EQ "db2">generate_unique()<cfelseif application.razuna.thedatabase EQ "h2">random_uuid()<cfelseif application.razuna.thedatabase EQ "mysql">uuid()</cfif>
		FROM #session.hostdbprefix#collections_groups
		WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		</cfquery>
		<!--- Comments --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#comments
		(com_id, asset_id_r, asset_type, user_id_r, com_text, com_date, host_id)
		SELECT <cfif application.razuna.thedatabase EQ "mssql">newid()<cfelseif application.razuna.thedatabase EQ "oracle">sys_guid()<cfelseif application.razuna.thedatabase EQ "db2">generate_unique()<cfelseif application.razuna.thedatabase EQ "h2">random_uuid()<cfelseif application.razuna.thedatabase EQ "mysql">uuid()</cfif>, <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid#">, asset_type, user_id_r, com_text, com_date, host_id
		FROM #session.hostdbprefix#comments
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		</cfquery>
		<!--- Widgets --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#widgets
		(widget_id, col_id_r, folder_id_r, widget_name, widget_description, widget_permission, widget_password, widget_style, widget_dl_org, widget_uploading, host_id)
		SELECT <cfif application.razuna.thedatabase EQ "mssql">newid()<cfelseif application.razuna.thedatabase EQ "oracle">sys_guid()<cfelseif application.razuna.thedatabase EQ "db2">generate_unique()<cfelseif application.razuna.thedatabase EQ "h2">random_uuid()<cfelseif application.razuna.thedatabase EQ "mysql">uuid()</cfif>, <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid#">, folder_id_r, widget_name, widget_description, widget_permission, widget_password, widget_style, widget_dl_org, widget_uploading, host_id
		FROM #session.hostdbprefix#widgets
		WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		</cfquery>
	<!--- We only need to make a release of the current collection --->
	<cfelse>
		<!--- Call internal release function --->
		<cfset dorelease(arguments.thestruct)>
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Remove all from Trash --->
<cffunction name="trash_remove_all" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Files --->
	<cfif arguments.thestruct.trashkind EQ "files">
		<!--- Get all trash files--->
		<cfinvoke method="get_trash_files" noread="true" returnvariable="arguments.qry" />
		<!--- Thread --->
		<cfthread instruct="#arguments#">
			<cfloop query="attributes.instruct.qry">
				<cfset attributes.instruct.thestruct.id = id>
				<cfset attributes.instruct.thestruct.col_id = col_id>
				<cfset attributes.instruct.thestruct.order = col_item_order>
				<!--- Remove --->
				<cfinvoke method="removeitem" thestruct="#attributes.instruct.thestruct#" />
			</cfloop>
		</cfthread>
	<!--- Collections --->
	<cfelseif arguments.thestruct.trashkind EQ "collections">
		<!--- Get all trash collections--->
		<cfinvoke method="get_trash_collection" noread="true" returnvariable="arguments.qry" />
		<!--- Thread --->
		<cfthread instruct="#arguments#">
			<cfloop query="attributes.instruct.qry">
				<cfset attributes.instruct.thestruct.id = id>
				<!--- Remove --->
				<cfinvoke method="remove" thestruct="#attributes.instruct.thestruct#" />
			</cfloop>
		</cfthread>
	<!--- Folders --->
	<cfelse>
		<!--- Get all trash folders --->
		<cfinvoke method="get_trash_folders"  noread="true"  returnvariable="arguments.qry" />
		<!--- Thread --->
		<cfthread instruct="#arguments#">
			<cfloop query="attributes.instruct.qry">
				<cfset attributes.instruct.thestruct.folder_id = folder_id>
				<!--- Remove --->
				<cfinvoke component="folders" method="remove" thestruct="#attributes.instruct.thestruct#" />
			</cfloop>
		</cfthread>
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Set all collection files ids in the session --->
<cffunction name="restoreallcollectionfiles" output="false">
	<!--- Set file id --->
	<cfset session.file_id ="">
	<!--- Get collection files in the trash --->
	<cfinvoke method="get_trash_files" noread="true" returnvariable="qry_trash" />
	<cfloop list="#valueList(qry_trash.file_id)#" index="i">
		<!--- set session file ids --->
		<cfset session.file_id = listAppend(session.file_id,i)>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Restore all collection files in the trash --->
<cffunction name="restore_col_file" output="false">
	<cfargument name="thestruct" type="struct">
	<cfloop list="#arguments.thestruct.file_id#" index="i">
		<cfif i CONTAINS "-">
			<cfset arguments.thestruct.file_id = listFirst(i,'-')>
		<cfelse>
			<cfset arguments.thestruct.file_id = i>
		</cfif>
		<!--- update the collection files --->
		<cfinvoke method="restoreasset" thestruct="#arguments.thestruct#">
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("folders")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Set all collections ids in the session --->
<cffunction name="restoreallcollections" output="false">
	<!--- Set file id --->
	<cfset session.file_id ="">
	<!--- Get all trash collections--->
	<cfinvoke method="get_trash_collection" noread="true" returnvariable="qry" />
	<cfloop list="#valueList(qry.col_id)#" index="i">
		<!--- set session col ids --->
		<cfset session.file_id = listAppend(session.file_id,i)>
	</cfloop>
	<!--- Return --->
	<cfreturn />	
</cffunction>

<!--- Restore all collections in the trash --->
<cffunction name="restore_all_collections" output="false">
	<cfargument name="thestruct" type="struct">
	<cfloop list="#arguments.thestruct.col_id#" index="i">
		<cfset arguments.thestruct.col_id = i>
		<!--- update the collection  --->
		<cfinvoke method="restorecollection" thestruct="#arguments.thestruct#" />
	</cfloop>
	<!--- Return --->
	<cfreturn />	
</cffunction>

<!--- Store selected collection file ids --->
<cffunction name="trash_file_values" output="false">
	<!--- Set file id --->
	<cfset session.file_id ="">
	<!--- Get collection files in the trash --->
	<cfinvoke method="get_trash_files" noread="true" returnvariable="qry_trash" />
	<cfloop query="qry_trash">
		<!--- set session file ids --->
		<cfset session.file_id = listAppend(session.file_id,"#file_id#-#kind#")>
	</cfloop>
	<!--- Return --->
	<cfreturn />	
</cffunction>
<!--- Remove selectedcollection files --->
<cffunction name="remove_selected_col_files" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<cfloop list="#arguments.thestruct.file_id#" index="i">
		<cfif i CONTAINS "-">
			<cfset file_id = listFirst(i,'-')>
		<cfelse>
			<cfset file_id = i>
		</cfif>
		<!--- Get the details --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT col_id_r AS col_id,file_id_r AS id,col_item_order 
			FROM #session.hostdbprefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#file_id#" cfsqltype="cf_sql_varchar">
			AND in_trash = <cfqueryparam value="T" cfsqltype="cf_sql_varchar">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif qry.RecordCount GTE 1>
			<cfloop query="qry">
				<cfset arguments.thestruct.id = id>
				<cfset arguments.thestruct.col_id = col_id>
				<cfset arguments.thestruct.order = col_item_order>
				<!--- Remove --->
				<cfinvoke method="removeitem" thestruct="#arguments.thestruct#" />
			</cfloop>
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn />	
</cffunction>

<!--- Store collection ids in session --->
<cffunction name="trash_col_values" output="false">
	<!--- Set col id --->
	<cfset session.file_id ="">
	<!--- Get all trash collections--->
	<cfinvoke method="get_trash_collection" noread="true" returnvariable="qry" />
	<cfloop list="#valueList(qry.col_id)#" index="i">
		<!--- set session col ids --->
		<cfset session.file_id = listAppend(session.file_id,"#i#-collection")>
	</cfloop>
	<!--- Return --->
	<cfreturn />	
</cffunction>

<!--- Restore selected collections --->
<cffunction name="restore_selected_collections" output="false">
<cfargument name="thestruct" type="struct">
	<cfloop list="#arguments.thestruct.col_id#" index="i">
		<cfif i CONTAINS "-">
			<cfset arguments.thestruct.col_id = listFirst(i,'-')>
		<cfelse>
			<cfset arguments.thestruct.col_id = i>
		</cfif>
		<!--- update the collection  --->
		<cfinvoke method="restorecollection" thestruct="#arguments.thestruct#" />
	</cfloop>
	<!--- Return --->
	<cfreturn />	
</cffunction>

<!--- Remove selected collections --->
<cffunction name="selected_collection_remove" output="false">
	<cfargument name="thestruct" type="struct">
	<cfloop list="#arguments.thestruct.col_id#" index="i">
		<cfif i CONTAINS "-">
			<cfset arguments.thestruct.id = listFirst(i,'-')>
		<cfelse>
			<cfset arguments.thestruct.id = i>
		</cfif>
		<!--- Remove --->
		<cfinvoke method="remove" thestruct="#arguments.thestruct#" />
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Store folder ids in session--->
<cffunction name="trash_folder_values" output="false">
	<!--- Set col id --->
	<cfset session.file_id ="">
	<!--- Get all trash folders--->
	<cfinvoke method="get_trash_folders" noread="true" returnvariable="qry" />
	<cfloop list="#valueList(qry.folder_id)#" index="i">
		<!--- set session col ids --->
		<cfset session.file_id = listAppend(session.file_id,"#i#-folder")>
	</cfloop>
	<!--- Return --->
	<cfreturn />	
</cffunction>

<cffunction name="samecollectionnamecheck" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<!--- Param --->
	<cfset var ishere = false>
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT 1
	FROM #session.hostdbprefix#collections_text ct, #session.hostdbprefix#collections c
	WHERE lower(ct.col_name) = <cfqueryparam value="#lcase(arguments.thestruct.collection_name)#" cfsqltype="CF_SQL_VARCHAR">
	AND ct.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND ct.col_id_r != <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	AND c.col_id = ct.col_id_r
	AND c.folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Set to true if found --->
	<cfif qry.recordCount NEQ 0>
		<cfset var ishere = true>
	</cfif>
	<cfreturn ishere>
</cffunction>

</cfcomponent>
