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
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry.collist" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getAllcol */ c.col_id, c.change_date, ct.col_name, c.col_released
	FROM #session.hostdbprefix#collections c
	LEFT JOIN #session.hostdbprefix#collections_text ct ON c.col_id = ct.col_id_r 
	WHERE c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<cfif structkeyexists(arguments.thestruct,"withfolder")>
		AND c.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
	</cfif>
	AND c.col_released = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.released#">
	GROUP BY c.col_id, c.change_date, ct.col_name, c.col_released
	ORDER BY lower(ct.col_name)
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
		<cfset newcolid = createuuid("")>
		<!--- Add to main table --->
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#collections
		(COL_ID,FOLDER_ID_R,COL_OWNER,CREATE_DATE,CREATE_TIME,CHANGE_DATE,CHANGE_TIME, host_id)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newcolid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>
		<!--- Add name, description and keywords --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<cfset thisdesc="arguments.thestruct.col_desc_" & "#langindex#">
			<cfset thiskeys="arguments.thestruct.col_keywords_" & "#langindex#">
			<cfif #thisdesc# CONTAINS "#langindex#">
				<cfquery datasource="#variables.dsn#">
					insert into #session.hostdbprefix#collections_text
					(col_id_r, lang_id_r, col_desc, col_keywords, col_name, host_id, rec_uuid)
					values(
					<cfqueryparam value="#newcolid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#evaluate(thisdesc)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#evaluate(thiskeys)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.thestruct.collectionname#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
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
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("general")>
		</cfif>
	</cfloop>
	
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
	<cfset variables.cachetoken = resetcachetoken("general")>
</cffunction>

<!--- LIST COLLECTION DETAIL --->
<cffunction name="details" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#detailscol */ ct.col_name, ct.col_desc, ct.col_keywords, ct.lang_id_r, c.col_shared, c.col_name_shared, c.share_dl_org, c.share_comments, c.col_released, c.share_upload, c.share_order, c.share_order_user
	FROM #session.hostdbprefix#collections_text ct, #session.hostdbprefix#collections c
	WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	AND col_id = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- GET COLLECTION ASSETS --->
<cffunction name="get_assets" output="false">
	<cfargument name="thestruct" type="struct">
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
	WHERE ct.col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	GROUP BY ct.col_id_r, ct.file_id_r, ct.col_file_type, ct.col_item_order, ct.col_file_format
	ORDER BY ct.col_item_order
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
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
		<cfset variables.cachetoken = resetcachetoken("general")>
		<cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="error moving item in collection">
				<cfdump var="#arguments.thestruct#" />
				<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>
	</cftry>
</cffunction>

<!--- REMOVE ITEM FROM COLLECTION --->
<cffunction name="removeitem" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#variables.dsn#">
	DELETE FROM #session.hostdbprefix#collections_ct_files
	WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Rearrange the order --->
	<cfquery datasource="#variables.dsn#">
	UPDATE #session.hostdbprefix#collections_ct_files
	SET col_item_order = col_item_order - 1
	WHERE col_item_order > <cfqueryparam value="#arguments.thestruct.order#" cfsqltype="cf_sql_numeric">
	AND col_item_order <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> 1
	AND col_id_r = <cfqueryparam value="#arguments.thestruct.col_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
</cffunction>

<!--- REMOVE COLLECTION --->
<cffunction name="remove" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- delete collection db --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM #session.hostdbprefix#collections
	WHERE col_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- delete collection_text db --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM #session.hostdbprefix#collections_text
	WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- delete collection files db --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM #session.hostdbprefix#collections_ct_files
	WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Delete labels --->
	<cfinvoke component="labels" method="label_ct_remove" id="#arguments.thestruct.id#" />
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
</cffunction>

<!--- UPDATE --->
<cffunction name="update" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.col_shared" default="F">
	<cfparam name="arguments.thestruct.col_name_shared" default="#arguments.thestruct.col_id#">
	<cfparam name="arguments.thestruct.share_order_user" default="0">
	<cfparam name="arguments.thestruct.share_dl_org" default="f">
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
			<cfset thisdesc="arguments.thestruct.col_desc_" & "#langindex#">
			<cfset thiskeys="arguments.thestruct.col_keywords_" & "#langindex#">
			<cfif thisdesc CONTAINS #langindex#>
				<!--- Insert --->
				<cfquery datasource="#variables.dsn#">
				INSERT INTO #session.hostdbprefix#collections_text
				(lang_id_r, col_desc, col_keywords, col_name, col_id_r, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">, 
				<cfqueryparam value="#evaluate(thisdesc)#" cfsqltype="cf_sql_varchar">, 
				<cfqueryparam value="#evaluate(thiskeys)#" cfsqltype="cf_sql_varchar">, 
				<cfqueryparam value="#arguments.thestruct.collectionname#" cfsqltype="cf_sql_varchar">,
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
					<cfset theimgid = listfirst(art, "-")>
					<cfset theart = listlast(art, "-")>
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
					<cfset thevidid = listfirst(art, "-")>
					<cfset theart = listlast(art, "-")>
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
					<cfset theaudid = listfirst(art, "-")>
					<cfset theart = listlast(art, "-")>
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
				<cfset grpid = ReplaceNoCase(#myform#, "grp_", "")>
				<cfset theper = "per_" & "#grpid#">
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
	<cfset variables.cachetoken = resetcachetoken("general")>
</cffunction>

<!--- GET THE GROUPS FOR THIS COLLECTION --->
<cffunction name="getcollectiongroups" output="false">
	<cfargument name="col_id" default="" required="yes" type="string">
	<cfargument name="qrygroup" required="yes" type="query">
	<!--- Set --->
	<cfset thegroups = 0>
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
	<cfset qry = structnew()>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry.qry_files" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getallassetscol */ i.img_id id, i.img_filename filename, i.folder_id_r, i.thumb_extension ext, i.img_filename_org filename_org, i.is_available,
	'img' as kind, it.img_description description, it.img_keywords keywords, link_kind, link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org,
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
	WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry_files.cart_product_id)#" list="true">)
	AND ct.file_id_r = i.img_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">
	AND (i.img_group IS NULL OR i.img_group = '')
	GROUP BY id
	UNION ALL
	SELECT v.vid_id id, v.vid_name_org filename, v.folder_id_r, v.vid_extension ext, v.vid_name_image filename_org, v.is_available,
	'vid' as kind, vt.vid_description description, vt.vid_keywords keywords, link_kind, link_path_url, v.path_to_asset, v.cloud_url, v.cloud_url_org,
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
	WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry_files.cart_product_id)#" list="true">)
	AND ct.file_id_r = v.vid_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="vid">
	AND (v.vid_group IS NULL OR v.vid_group = '')
	GROUP BY id
	UNION ALL
	SELECT a.aud_id id, a.aud_name filename, a.folder_id_r, a.aud_extension ext, a.aud_name_org filename_org, a.is_available,
	'aud' as kind, aut.aud_description description, aut.aud_keywords keywords, link_kind, link_path_url, a.path_to_asset, a.cloud_url, a.cloud_url_org,
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
	WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry_files.cart_product_id)#" list="true">)
	AND ct.file_id_r = a.aud_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="aud">
	AND (a.aud_group IS NULL OR a.aud_group = '')
	GROUP BY id
	UNION ALL
	SELECT f.file_id id, f.file_name filename, f.folder_id_r, f.file_extension ext, f.file_name_org filename_org, f.is_available,
	f.file_type as kind, ft.file_desc description, ft.file_keywords keywords, link_kind, link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url_org,
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
	WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry_files.cart_product_id)#" list="true">)
	AND ct.file_id_r = f.file_id
	AND ct.col_file_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="doc">
	GROUP BY id
	ORDER BY theorder
	</cfquery>
	<!--- Get the total --->
	<cfquery dbtype="query" name="qry.qry_filecount">
	SELECT count(id) thetotal
	FROM qry.qry_files
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
	<!--- <cfset qry.listimg = ValueList(listimg.id)>
	<cfset qry.listvid = ValueList(listvid.id)>
	<cfset qry.listdoc = ValueList(listdoc.id)> --->
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
	<cfif arguments.thestruct.col_name NEQ "">
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#collections_text
		SET col_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_name#">
		WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
		</cfquery>
	</cfif>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Copy --->
<cffunction name="copy" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.release" default="false">
	<!--- New ID for collection --->
	<cfset var newid = createUUID("")>
	<!--- Copy the main record --->
	<cfquery datasource="#application.razuna.datasource#">
	INSERT INTO #session.hostdbprefix#collections
	(col_id, folder_id_r, col_owner, create_date, create_time, change_date, change_time, col_template, col_shared, col_name_shared, share_dl_org, share_comments, share_upload, share_order, share_order_user, host_id, col_released, col_copied_from)
	SELECT <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid#">, folder_id_r, col_owner, <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">, <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, col_template, col_shared, col_name_shared, share_dl_org, share_comments, share_upload, share_order, share_order_user, host_id, <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.release#">, col_id
	FROM #session.hostdbprefix#collections
	WHERE col_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
	</cfquery>
	<!--- Add name, description and keywords --->
	<cfloop list="#arguments.thestruct.langcount#" index="langindex">
		<cfset thisdesc = "arguments.thestruct.col_desc_#langindex#">
		<cfset thiskeys = "arguments.thestruct.col_keywords_#langindex#">
		<cfif thisdesc CONTAINS "#langindex#">
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#collections_text
			(col_id_r, lang_id_r, col_desc, col_keywords, col_name, host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
			<cfqueryparam value="#evaluate(thisdesc)#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#evaluate(thiskeys)#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.col_name#" cfsqltype="cf_sql_varchar">,
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
	<!--- Return --->
	<cfreturn />
</cffunction>


</cfcomponent>
