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
<cfcomponent extends="extQueryCaching">

<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("audios")>

<!--- GET ALL RECORDS OF THIS TYPE IN A FOLDER --->
<cffunction name="getFolderAssets" access="public" description="GET ALL RECORDS OF THIS TYPE IN A FOLDER" output="false" returntype="query">
	<cfargument name="folder_id" type="string" required="true">
	<cfargument name="offset" type="numeric" required="false" default="0">
	<cfargument name="rowmaxpage" type="numeric" required="false" default="0">
	<cfargument name="thestruct" type="struct" required="false" default="">
	<!--- Set thestruct if not here --->
	<cfif NOT isstruct(arguments.thestruct)>
		<cfset arguments.thestruct = structnew()>
	</cfif>
	<!--- init local vars --->
	<cfset qLocal = 0>
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
	<!--- This is for Oracle and MSQL. Calculate the offset .Show the limit only if pages is null or current (from print) --->
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
	<!--- If there is a columnlist then take it else the default--->
	<cfif structkeyexists(arguments.thestruct,"columnlist")>
		<cfset thecolumns = arguments.thestruct.columnlist>
	<cfelse>
		<cfset thecolumns = "a.aud_id, a.aud_name, a.aud_extension, a.aud_create_date, a.aud_change_date, a.folder_id_r, a.is_available">
	</cfif>
	<!--- Oracle --->
	<cfif variables.database EQ "oracle">
		<!--- Clean columnlist --->
		<cfset var thecolumnlist = replacenocase(arguments.columnlist,"v.","","all")>
		<!--- Query --->
		<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getFolderAssetsaud */ rn, aud_id, aud_name, aud_extension, aud_create_date, aud_change_date, folder_id_r, keywords, description, labels, filename_forsort, size, hashtag, date_create, date_change
		FROM (
			SELECT ROWNUM AS rn, aud_id, aud_name, aud_extension, aud_create_date, aud_change_date, folder_id_r, keywords, description, labels, filename_forsort, size, hashtag, date_create, date_change
			FROM (
				SELECT #thecolumns#, att.aud_keywords keywords, att.aud_description description, '' as labels, lower(a.aud_name) filename_forsort, a.aud_size size, a.hashtag, a.aud_create_time date_create, a.aud_change_time date_change
				FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text att ON a.aud_id = att.aud_id_r AND att.lang_id_r = 1
				WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND (a.aud_group IS NULL OR a.aud_group = '')
				AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				ORDER BY #sortby#
				)
			WHERE ROWNUM <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#max#">
			)
		WHERE rn > <cfqueryparam cfsqltype="cf_sql_numeric" value="#min#">
		</cfquery>
	<!--- DB2 --->
	<cfelseif variables.database EQ "db2">
		<!--- Clean columnlist --->
		<cfset var thecolumnlist = replacenocase(arguments.columnlist,"v.","","all")>
		<!--- Query --->
		<cfquery datasource="#Variables.dsn#" name="qLocal" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getFolderAssetsaud */ #thecolumnlist#, att.aud_keywords keywords, att.aud_description description, '' as labels, filename_forsort, size, hashtag, date_create, date_change
		FROM (
			SELECT row_number() over() as rownr, a.*, att.*, 
			lower(a.aud_name) filename_forsort,	a.aud_size size, a.hashtag, a.aud_create_time date_create, a.aud_change_time date_change
			FROM audios a LEFT JOIN #session.hostdbprefix#audios_text att ON a.aud_id = att.aud_id_r AND att.lang_id_r = 1
			WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND (a.aud_group IS NULL OR a.aud_group = '')
			AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
		SELECT /* #variables.cachetoken#getFolderAssetsaud */ 
		#thecolumns#, att.aud_keywords keywords, att.aud_description description, '' as labels,
		lower(a.aud_name) filename_forsort, a.aud_size size, a.hashtag, a.aud_create_time date_create, a.aud_change_time date_change
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">att
				<cfelse>a
				</cfif>.#m#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text att ON a.aud_id = att.aud_id_r AND att.lang_id_r = 1
		WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (a.aud_group IS NULL OR a.aud_group = '')
		AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
		WHERE aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
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
			WHERE ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#aud_id#">
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

<!--- GET THE AUDIO DETAILS --->
<cffunction name="detail" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var qry = structnew()>
	<cfparam default="0" name="session.thegroupofuser">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("audios")>
	<!--- Get details --->
	<cfquery datasource="#application.razuna.datasource#" name="details" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#detailaud */ 
	a.aud_id, a.aud_name, a.folder_id_r, a.aud_extension, a.aud_online, a.aud_owner, 
	a.cloud_url, a.cloud_url_org, a.aud_group,
	a.aud_create_date, a.aud_create_time, a.aud_change_date, a.aud_change_time, a.aud_name_noext,
	a.aud_name_org, a.aud_name_org filenameorg, a.shared, a.aud_size, a.aud_meta, a.link_kind, a.link_path_url, 
	a.path_to_asset, a.lucene_key, s.set2_img_download_org, s.set2_intranet_gen_download, s.set2_url_website,
	u.user_first_name, u.user_last_name, fo.folder_name,
	'' as perm
	FROM #session.hostdbprefix#audios a 
	LEFT JOIN #session.hostdbprefix#settings_2 s ON s.set2_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.setid#"> AND s.host_id = a.host_id
	LEFT JOIN users u ON u.user_id = a.aud_owner
	LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = a.folder_id_r AND fo.host_id = a.host_id
	WHERE a.aud_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
	AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
	SELECT /* #variables.cachetoken#detaildescaud */ aud_description, aud_keywords, lang_id_r, aud_description as thedesc, aud_keywords as thekeys
	FROM #session.hostdbprefix#audios_text
	WHERE aud_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cftry>
		<cfif details.recordcount NEQ 0>
			<cfif details.aud_size EQ "">
				<cfset details.aud_size = 1>
			</cfif>
			<!--- Convert the size --->
			<cfinvoke component="global" method="converttomb" returnvariable="thesize" thesize="#details.aud_size#">
		<cfelse>
			<cfset thesize = 0>
		</cfif>
		<cfcatch type="any">
			<cfdump var="#details#"><cfabort>
			<cfdump var="#cfcatch#"><cfdump var="#details.aud_size#"><cfabort>
		</cfcatch>
	</cftry>
	<!--- Put into struct --->
	<cfset qry.detail = details>
	<cfset qry.desc = desc>
	<cfset qry.thesize = thesize>
	<!--- <cfset qry.theprevsize = theprevsize> --->
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- UPDATE AUDIOS IN THREAD --->
<cffunction name="update" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Set arguments --->
	<cfset arguments.thestruct.dsn = variables.dsn>
	<cfset arguments.thestruct.setid = variables.setid>
	<!--- <cfinvoke method="updatethread" thestruct="#arguments.thestruct#" /> --->
	<!--- Start the thread for updating --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="updatethread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- SAVE THE AUDIO DETAILS --->
<cffunction name="updatethread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="arguments.thestruct.shared" default="F">
	<cfparam name="arguments.thestruct.what" default="">
	<cfparam name="arguments.thestruct.aud_online" default="F">
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
				<cfset var thisdesc = "arguments.thestruct.aud_desc_#langindex#">
				<cfset var thiskeywords = "arguments.thestruct.aud_keywords_#langindex#">
				<cfset "#thisdesc#" =  evaluate(alldesc)>
				<cfset "#thiskeywords#" =  evaluate(allkeywords)>
			<cfelse>
				<!--- <cfif langindex EQ 1>
					<cfset thisdesc = "desc_#langindex#">
					<cfset thiskeywords = "keywords_#langindex#">
				<cfelse> --->
					<cfset var thisdesc = "aud_desc_#langindex#">
					<cfset var thiskeywords = "aud_keywords_#langindex#">
				<!--- </cfif> --->
			</cfif>
			<cfset var l = langindex>
			<cfif thisdesc CONTAINS l OR thiskeywords CONTAINS l>
				<cfloop list="#arguments.thestruct.file_id#" delimiters="," index="f">
					<!--- query excisting --->
					<cfquery datasource="#variables.dsn#" name="ishere">
					SELECT aud_id_r, aud_description, aud_keywords
					FROM #session.hostdbprefix#audios_text
					WHERE aud_id_r = <cfqueryparam value="#f#" cfsqltype="CF_SQL_VARCHAR">
					AND lang_id_r = <cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">
					</cfquery>
					<cfif ishere.recordcount NEQ 0>
						<cfset tdesc = evaluate(thisdesc)>
						<cfset tkeywords = evaluate(thiskeywords)>
						<!--- If users chooses to append values --->
						<cfif !arguments.thestruct.batch_replace>
							<cfif ishere.aud_description NEQ "">
								<cfset tdesc = ishere.aud_description & " " & tdesc>
							</cfif>
							<cfif ishere.aud_keywords NEQ "">
								<cfset tkeywords = ishere.aud_keywords & "," & tkeywords>
							</cfif>
						</cfif>
						<!--- Update --->
						<cfquery datasource="#variables.dsn#">
						UPDATE #session.hostdbprefix#audios_text
						SET 
						aud_description = <cfqueryparam value="#ltrim(tdesc)#" cfsqltype="cf_sql_varchar">, 
						aud_keywords = <cfqueryparam value="#ltrim(tkeywords)#" cfsqltype="cf_sql_varchar">
						WHERE aud_id_r = <cfqueryparam value="#f#" cfsqltype="CF_SQL_VARCHAR">
						AND lang_id_r = <cfqueryparam value="#l#" cfsqltype="cf_sql_numeric">
						</cfquery>
					<cfelse>
						<cfquery datasource="#variables.dsn#">
						INSERT INTO #session.hostdbprefix#audios_text
						(id_inc, aud_id_r, lang_id_r, aud_description, aud_keywords, host_id)
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
		<!--- Save to the files table --->
		<cfif structkeyexists(arguments.thestruct,"fname") AND arguments.thestruct.frombatch NEQ "T">
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#audios
			SET
			aud_name = <cfqueryparam value="#arguments.thestruct.fname#" cfsqltype="cf_sql_varchar">,
			aud_online = <cfqueryparam value="#arguments.thestruct.aud_online#" cfsqltype="cf_sql_varchar">,
			shared = <cfqueryparam value="#arguments.thestruct.shared#" cfsqltype="cf_sql_varchar">
			WHERE aud_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- Update index --->
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#audios
		SET is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		WHERE aud_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Update main record with dates --->
		<cfinvoke component="global" method="update_dates" type="aud" fileid="#arguments.thestruct.file_id#" />
		<!--- Query --->
		<cfquery datasource="#variables.dsn#" name="qryorg">
		SELECT aud_name_org, aud_name, path_to_asset
		FROM #session.hostdbprefix#audios
		WHERE aud_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Select the record to get the original filename or assign if one is there --->
		<cfif NOT structkeyexists(arguments.thestruct,"filenameorg") OR arguments.thestruct.filenameorg EQ "">
			<cfset arguments.thestruct.qrydetail.filenameorg = qryorg.aud_name_org>
			<cfset arguments.thestruct.file_name = qryorg.aud_name>
		<cfelse>
			<cfset arguments.thestruct.qrydetail.filenameorg = arguments.thestruct.filenameorg>
		</cfif>
		<!--- Log --->
		<cfset log_assets(theuserid=session.theuserid,logaction='Update',logdesc='Updated: #qryorg.aud_name#',logfiletype='aud',assetid=arguments.thestruct.file_id)>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("audios")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")> 
</cffunction>

<!--- REMOVE THE AUDIO --->
<cffunction name="removeaudio" output="false" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Get file detail for log --->
	<cfquery datasource="#application.razuna.datasource#" name="details">
	SELECT aud_name, folder_id_r, link_kind, link_path_url, aud_name_org filenameorg, lucene_key, path_to_asset, aud_group
	FROM #session.hostdbprefix#audios
	WHERE aud_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfif details.recordcount NEQ 0>
		<!--- Execute workflow --->
		<cfset arguments.thestruct.fileid = arguments.thestruct.id>
		<cfset arguments.thestruct.file_name = details.aud_name>
		<cfset arguments.thestruct.thefiletype = "aud">
		<cfset arguments.thestruct.folder_id = details.folder_id_r>
		<cfset arguments.thestruct.folder_action = false>
		<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
		<cfset arguments.thestruct.folder_action = true>
		<cfinvoke component="plugins" method="getactions" theaction="on_file_remove" args="#arguments.thestruct#" />
		<!--- Update main record with dates --->
		<cfinvoke component="global" method="update_dates" type="aud" fileid="#details.aud_group#" />
		<!--- Log --->
		<cfinvoke component="extQueryCaching" method="log_assets">
			<cfinvokeargument name="theuserid" value="#session.theuserid#">
			<cfinvokeargument name="logaction" value="Delete">
			<cfinvokeargument name="logdesc" value="Deleted: #details.aud_name#">
			<cfinvokeargument name="logfiletype" value="aud">
			<cfinvokeargument name="assetid" value="#arguments.thestruct.id#">
		</cfinvoke>
		<!--- Delete from files DB (including referenced data)--->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#audios
		WHERE aud_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Delete from collection --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#collections_ct_files
		WHERE file_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND col_file_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Delete from favorites --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#users_favorites
		WHERE fav_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND fav_kind = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
		AND user_id_r = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Delete from Versions --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND ver_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
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
		<!--- Delete from file system --->
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset arguments.thestruct.folder_id_r = details.folder_id_r>
		<cfset arguments.thestruct.qrydetail = details>
		<cfset arguments.thestruct.link_kind = details.link_kind>
		<cfset arguments.thestruct.filenameorg = details.filenameorg>
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="deletefromfilesystem" thestruct="#attributes.intstruct#">
		</cfthread>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("audios")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
	</cfif>
	<cfreturn />
</cffunction>

<!--- TRASH THE AUDIO --->
<cffunction name="trashaudio" output="false">
	<cfargument name="thestruct" type="struct">
		<!--- Update in_trash --->
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#audios SET in_trash=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.trash#">
			WHERE aud_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("audios")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
		<!--- return --->
		<cfreturn />
</cffunction>

<!--- Get trash audio --->
<cffunction name="gettrashaudio" output="false" returntype="Query">
	<!--- Param --->
	<cfset var qry_audio = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("audios")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_audio" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#gettrashaudio */ 
		a.aud_id AS id, 
		a.aud_name AS filename, 
		a.folder_id_r, 
		a.aud_extension AS ext,
		a.aud_name_org AS filename_org, 
		'aud' AS kind, 
		a.link_kind, 
		a.path_to_asset, 
		a.cloud_url, 
		a.cloud_url_org,
		a.hashtag, 
		'false' AS in_collection, 
		'audios' as what, 
		'' AS folder_main_id_r
			<!--- Permfolder --->
			<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
				, 'X' as permfolder
			<cfelse>
				,
				CASE
					WHEN (SELECT DISTINCT fg5.grp_permission
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = a.folder_id_r
					AND fg5.grp_id_r = '0') = 'R' THEN 'R'
					WHEN (SELECT DISTINCT fg5.grp_permission
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = a.folder_id_r
					AND fg5.grp_id_r = '0') = 'W' THEN 'W'
					WHEN (SELECT DISTINCT fg5.grp_permission
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = a.folder_id_r
					AND fg5.grp_id_r = '0') = 'X' THEN 'X'
					<cfloop list="#session.thegroupofuser#" delimiters="," index="i">
						WHEN (SELECT DISTINCT fg5.grp_permission
						FROM #session.hostdbprefix#folders_groups fg5
						WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND fg5.folder_id_r = a.folder_id_r
						AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'R' THEN 'R'
						WHEN (SELECT DISTINCT fg5.grp_permission
						FROM #session.hostdbprefix#folders_groups fg5
						WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND fg5.folder_id_r = a.folder_id_r
						AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'W' THEN 'W'
						WHEN (SELECT DISTINCT fg5.grp_permission
						FROM #session.hostdbprefix#folders_groups fg5
						WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND fg5.folder_id_r = a.folder_id_r
						AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'X' THEN 'X'
					</cfloop>
					ELSE 'R'
				END as permfolder
			</cfif>
		FROM  
			#session.hostdbprefix#audios a 
		WHERE 
			a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			
	</cfquery>
	<cfif qry_audio.RecordCount NEQ 0>
		<cfset myArray = arrayNew( 1 )>
		<cfset temp= ArraySet(myArray, 1, qry_audio.RecordCount, "False")>
		<cfloop query="qry_audio">
			<cfquery name="alert_col" datasource="#application.razuna.datasource#">
			SELECT file_id_r
			FROM #session.hostdbprefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#qry_audio.id#" cfsqltype="CF_SQL_VARCHAR"> 
			</cfquery>
			<cfif alert_col.RecordCount NEQ 0>
				<cfset temp = QuerySetCell(qry_audio, "in_collection", "True", currentRow  )>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn qry_audio />
</cffunction>

<!--- TRASH MANY AUDIO --->
<cffunction name="trashaudiomany" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Loop --->
	<cfloop list="#arguments.thestruct.id#" index="i" delimiters=",">
		<cfset i = listfirst(i,"-")>
		<!--- Update in_trash --->
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#audios 
			SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.trash#">
			WHERE aud_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
		</cfquery>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("audios")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfreturn />
</cffunction>

<!--- RESTORE THE AUDIO --->
<cffunction name="restoreaudio" output="false">
	<cfargument name="thestruct" type="struct">
		<!--- check parent folder is exist --->
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
					UPDATE #session.hostdbprefix#audios SET in_trash=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.trash#">
					WHERE aud_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("audios")>
		<cfset resetcachetoken("folders")>
		<cfset resetcachetoken("search")>
	</cfif>
	<!--- Set is trash --->
	<cfif isDefined('local.istrash') AND  local.istrash EQ "trash">
		<cfset var is_trash = "intrash">
	<cfelse>
		<cfset var is_trash = "notrash">
	</cfif>
	<cfreturn is_trash />
</cffunction>

<!--- REMOVE MANY AUDIOS --->
<cffunction name="removeaudiomany" output="false" access="public">
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
		<cfquery datasource="#application.razuna.datasource#" name="thedetail">
		SELECT aud_name, folder_id_r, aud_name_org, aud_name_org filenameorg, link_kind, link_path_url, path_to_asset, lucene_key
		FROM #arguments.thestruct.hostdbprefix#audios
		WHERE aud_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
		</cfquery>
		<cfif thedetail.recordcount NEQ 0>
			<!--- Execute workflow --->
			<cfif !arguments.thestruct.fromfolderremove>
				<cfset arguments.thestruct.fileid = i>
				<cfset arguments.thestruct.file_name = thedetail.aud_name>
				<cfset arguments.thestruct.thefiletype = "aud">
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
				<cfinvokeargument name="logdesc" value="Deleted: #thedetail.aud_name#">
				<cfinvokeargument name="logfiletype" value="aud">
				<cfinvokeargument name="assetid" value="#i#">
			</cfinvoke>
			<!--- Delete from files DB (including referenced data)--->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Delete from collection --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from favorites --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#users_favorites
			WHERE fav_id = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND fav_kind = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
			AND user_id_r = <cfqueryparam value="#arguments.thestruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete from Versions --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #arguments.thestruct.hostdbprefix#versions
			WHERE asset_id_r = <cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">
			AND ver_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
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
	<cfset variables.cachetoken = resetcachetoken("audios")>
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("search")>
	<cfreturn />
</cffunction>

<!--- SubFunction called from deletion above --->
<cffunction name="deletefromfilesystem" output="false">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<!--- Delete in Lucene --->
		<cfinvoke component="lucene" method="index_delete" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.id#" category="aud">
		<!--- Delete File --->
		<cfif application.razuna.storage EQ "local">
			<cfif DirectoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#") AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
				<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#" recurse="true">
			</cfif>
			<!--- Versions --->
			<cfif DirectoryExists("#arguments.thestruct.assetpath#/#session.hostid#/versions/aud/#arguments.thestruct.id#") AND arguments.thestruct.id NEQ "">
				<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#session.hostid#/versions/aud/#arguments.thestruct.id#" recurse="true">
			</cfif>
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix" AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
			<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/#arguments.thestruct.qrydetail.path_to_asset#">
			<!--- Versions --->
			<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/versions/aud/#arguments.thestruct.id#">
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon" AND arguments.thestruct.qrydetail.path_to_asset NEQ "">
			<cfinvoke component="amazon" method="deletefolder" folderpath="#arguments.thestruct.qrydetail.path_to_asset#" awsbucket="#arguments.thestruct.awsbucket#" />
			<!--- Versions --->
			<cfinvoke component="amazon" method="deletefolder" folderpath="versions/aud/#arguments.thestruct.id#" awsbucket="#arguments.thestruct.awsbucket#" />
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai">
			<cfinvoke component="akamai" method="Delete">
				<cfinvokeargument name="theasset" value="">
				<cfinvokeargument name="thetype" value="#arguments.thestruct.akaaud#">
				<cfinvokeargument name="theurl" value="#arguments.thestruct.akaurl#">
				<cfinvokeargument name="thefilename" value="#arguments.thestruct.qrydetail.filenameorg#">
			</cfinvoke>
			<!--- Versions --->
			<!--- <cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/versions/aud/#arguments.thestruct.id#"> --->
		</cfif>
		<!--- REMOVE RELATED FOLDERS ALSO!!!! --->
		<!--- Get all that have the same vid_id as related --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT path_to_asset
		FROM #session.hostdbprefix#audios
		WHERE aud_group = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Loop over the found records --->
		<cfloop query="qry">
			<cftry>
				<cfif application.razuna.storage EQ "local">
					<cfif DirectoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#path_to_asset#") AND path_to_asset NEQ "">
						<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#path_to_asset#" recurse="true">
					</cfif>
				<cfelseif application.razuna.storage EQ "nirvanix" AND path_to_asset NEQ "">
					<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/#path_to_asset#">
				<cfelseif application.razuna.storage EQ "amazon" AND path_to_asset NEQ "">
					<cfinvoke component="amazon" method="deletefolder" awsbucket="#arguments.thestruct.awsbucket#" folderpath="#path_to_asset#">
				</cfif>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>
		<!--- Delete related videos as well --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#audios
		WHERE aud_group = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfcatch type="any">
			<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error on removing a audio from system (HostID: #arguments.thestruct.hostid#, Asset: #arguments.thestruct.id#)" dump="#cfcatch#">
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- MOVE FILE IN THREADS --->
<cffunction name="movethread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Loop over files --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfloop list="#attributes.intstruct.file_id#" delimiters="," index="fileid">
			<cfset attributes.intstruct.aud_id = "">
			<cfset attributes.intstruct.aud_id = listfirst(fileid,"-")>
			<cfif attributes.intstruct.aud_id NEQ "">
				<cfinvoke method="move" thestruct="#attributes.intstruct#" />
			</cfif>
		</cfloop>
	</cfthread>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("audios")>
</cffunction>

<!--- MOVE FILE --->
<cffunction name="move" output="false">
	<cfargument name="thestruct" type="struct">
		<cftry>
			<cfset arguments.thestruct.qryaud = "">
			<!--- Move --->
			<cfset arguments.thestruct.file_id = arguments.thestruct.aud_id>
			<cfinvoke method="detail" thestruct="#arguments.thestruct#" returnvariable="qrydetails">
			<cfset arguments.thestruct.qryaud = qrydetails.detail>
			<!--- Ignore if the folder id is the same --->
			<cfif arguments.thestruct.qryaud.recordcount NEQ 0 AND arguments.thestruct.folder_id NEQ arguments.thestruct.qryaud.folder_id_r>
				<!--- Update DB --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET 
				folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				in_trash = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
				is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE aud_id = <cfqueryparam value="#arguments.thestruct.aud_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- <cfthread intstruct="#arguments.thestruct#"> --->
					<!--- Update Dates --->
					<cfinvoke component="global" method="update_dates" type="aud" fileid="#arguments.thestruct.aud_id#" />
					<!--- MOVE ALL RELATED FOLDERS TOO!!!!!!! --->
					<cfinvoke method="moverelated" thestruct="#arguments.thestruct#">
					<!--- Execute workflow --->
					<cfset arguments.thestruct.fileid = arguments.thestruct.aud_id>
					<cfset arguments.thestruct.file_name = arguments.thestruct.qryaud.aud_name>
					<cfset arguments.thestruct.thefiletype = "aud">
					<cfset arguments.thestruct.folder_id = arguments.thestruct.folder_id>
					<cfset arguments.thestruct.folder_action = false>
					<cfinvoke component="plugins" method="getactions" theaction="on_file_move" args="#arguments.thestruct#" />
					<cfset arguments.thestruct.folder_action = true>
					<cfinvoke component="plugins" method="getactions" theaction="on_file_move" args="#arguments.thestruct#" />
					<cfinvoke component="plugins" method="getactions" theaction="on_file_add" args="#arguments.thestruct#" />
				<!--- </cfthread> --->
				<!--- Log --->
				<cfset log_assets(theuserid=session.theuserid,logaction='Move',logdesc='Moved: #arguments.thestruct.qryaud.aud_name#',logfiletype='aud',assetid=arguments.thestruct.aud_id)>
			</cfif>
			<cfcatch type="any">
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="error in moving audio" dump="#cfcatch#">
			</cfcatch>
		</cftry>
		<!--- Flush Cache --->
		<!--- <cfset resetcachetoken("folders")>
		<cfset variables.cachetoken = resetcachetoken("audios")> --->
	<cfreturn />
</cffunction>

<!--- Move related videos --->
<cffunction name="moverelated" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Get all that have the same aud_id as related --->
	<cfquery datasource="#application.razuna.datasource#" name="qryintern">
	SELECT folder_id_r, aud_id
	FROM #session.hostdbprefix#audios
	WHERE aud_group = <cfqueryparam value="#arguments.thestruct.aud_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Loop over the found records --->
	<cfif qryintern.recordcount NEQ 0>
		<cfloop query="qryintern">
			<!--- Update DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#audios
			SET 
			folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE aud_id = <cfqueryparam value="#aud_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
	</cfif>
	<cfreturn />
</cffunction>

<!--- GET THE VIDEO DETAILS FOR BASKET --->
<cffunction name="detailforbasket" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam default="F" name="arguments.thestruct.related">
	<cfparam default="0" name="session.thegroupofuser">
	<!--- Qry. We take the query and do a IN --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#detailforbasketaud */ a.aud_id, a.aud_name filename, a.aud_extension, a.aud_group, a.folder_id_r, a.aud_size, 
	a.link_kind, a.link_path_url, a.path_to_asset,
	'' as perm
	FROM #session.hostdbprefix#audios a
	WHERE 
	<cfif arguments.thestruct.related EQ "T">
		a.aud_group
	<cfelse>
		a.aud_id
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

<!--- CONVERT AUDIO IN A THREAD --->
<cffunction name="convertaudio" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- RFS --->
	<cfif application.razuna.rfs>
		<cfset arguments.thestruct.convert = true>
		<cfset arguments.thestruct.assettype = "aud">
		<!--- <cfthread intstruct="#arguments.thestruct#"> --->
			<cfinvoke component="rfs" method="notify" thestruct="#arguments.thestruct#" />
		<!--- </cfthread> --->
	<cfelse>
		<!--- Start the thread for converting --->
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="convertaudiothread" thestruct="#attributes.intstruct#" />
		</cfthread>
	</cfif>
</cffunction>

<!--- CONVERT AUDIO --->
<cffunction name="convertaudiothread" output="false" returntype="void">
	<cfargument name="thestruct" type="struct" required="true">
	<cftry>
		<!--- Param --->
		<cfparam name="fromadmin" default="F">
		<cfset arguments.thestruct.dsn = application.razuna.datasource>
		<cfset arguments.thestruct.setid = application.razuna.setid>
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset var cloud_url = structnew()>
		<cfset var cloud_url_org = structnew()>
		<cfset var cloud_url_2 = structnew()>
		<cfset cloud_url_org.theurl = "">
		<cfset cloud_url.theurl = "">
		<cfset cloud_url_2.theurl = "">
		<cfset cloud_url_org.newepoch = 0>
		<cfparam name="arguments.thestruct.upl_template" default="0">		
		<!--- Get Tools --->
		<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
		<!--- Get details --->
		<cfinvoke method="detail" thestruct="#arguments.thestruct#" returnvariable="arguments.thestruct.qry_detail">
		<!--- Update main record with dates --->
		<cfinvoke component="global" method="update_dates" type="aud" fileid="#arguments.thestruct.qry_detail.detail.aud_group#" />
		<!--- Create a temp directory to hold the video file (needed because we are doing other files from it as well) --->
		<cfset var tempfolder = "aud#createuuid('')#">
		<!--- set the folder path in a var --->
		<cfset var thisfolder = "#arguments.thestruct.thepath#/incoming/#tempfolder#">
		<!--- Create the temp folder in the incoming dir --->
		<cfdirectory action="create" directory="#thisfolder#" mode="775">
		<!--- Set vars for thread --->
		<cfset arguments.thestruct.thisfolder = thisfolder>
		<!--- Get name without extension --->
		<cfset arguments.thestruct.thenamenoext = listfirst(arguments.thestruct.qry_detail.detail.aud_name_org, ".")>
		<!--- Local --->
		<cfif application.razuna.storage EQ "local" AND arguments.thestruct.link_kind NEQ "lan">
			<!--- Now get the extension and the name after the position from above --->
			<cfset arguments.thestruct.thename = arguments.thestruct.qry_detail.detail.aud_name_org>
			<!--- Check to see if original file is in WAV format if so take it else take the WAV one --->
			<cfif arguments.thestruct.qry_detail.detail.aud_extension EQ "WAV">
				<!--- Set the input path --->
				<cfset var inputpath = "#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.detail.path_to_asset#/#arguments.thestruct.qry_detail.detail.aud_name_org#">
			<cfelse>
				<cfset var inputpath = "#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.detail.path_to_asset#/#arguments.thestruct.qry_detail.detail.aud_name_noext#.wav">
			</cfif>
			<cfthread name="convert#tempfolder#" />
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix" AND arguments.thestruct.link_kind NEQ "lan">
			<!--- Check to see if original file is in WAV format if so take it else take the WAV one --->
			<cfif arguments.thestruct.qry_detail.detail.aud_extension EQ "WAV">
				<!--- Set Name --->
				<cfset arguments.thestruct.thename = arguments.thestruct.qry_detail.detail.aud_name_org>
				<!--- Download --->
				<cfhttp url="#arguments.thestruct.qry_detail.detail.cloud_url_org#" file="#arguments.thestruct.qry_detail.detail.aud_name_org#" path="#arguments.thestruct.thisfolder#"></cfhttp>
			<cfelse>
				<!--- Set Name --->
				<cfset arguments.thestruct.thename = arguments.thestruct.qry_detail.detail.aud_name_noext & ".wav">
				<!--- Download file --->
				<cfhttp url="#arguments.thestruct.qry_detail.detail.cloud_url_org#" file="#arguments.thestruct.qry_detail.detail.aud_name_noext#.wav" path="#arguments.thestruct.thisfolder#"></cfhttp>
			</cfif>
			<!--- Wait for the thread above until the file is downloaded fully --->
			<cfthread name="convert#tempfolder#" />
			<!--- Set the input path --->
			<cfset var inputpath = "#arguments.thestruct.thisfolder#/#arguments.thestruct.thename#">
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon" AND arguments.thestruct.link_kind NEQ "lan">
			<!--- Check to see if original file is in WAV format if so take it else take the WAV one --->
			<cfif arguments.thestruct.qry_detail.detail.aud_extension EQ "WAV">
				<!--- Set Name --->
				<cfset arguments.thestruct.thename = arguments.thestruct.qry_detail.detail.aud_name_org>
				<!--- Download file --->
				<cfthread name="download#tempfolder#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="/#attributes.intstruct.qry_detail.detail.path_to_asset#/#attributes.intstruct.qry_detail.detail.aud_name_org#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.qry_detail.detail.aud_name_org#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
			<cfelse>
				<!--- Set Name --->
				<cfset arguments.thestruct.thename = arguments.thestruct.qry_detail.detail.aud_name_noext & ".wav">
				<!--- Download file --->
				<cfthread name="download#tempfolder#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="/#attributes.intstruct.qry_detail.detail.path_to_asset#/#attributes.intstruct.thename#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.qry_detail.detail.aud_name_noext#.wav">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					</cfinvoke>
				</cfthread>
			</cfif>
			<!--- Wait for the thread above until the file is downloaded fully --->
			<cfthread action="join" name="download#tempfolder#" />
			<cfthread name="convert#tempfolder#" />
			<!--- Set the input path --->
			<cfset var inputpath = "#thisfolder#/#arguments.thestruct.thename#">
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai" AND arguments.thestruct.link_kind NEQ "lan">
			<!--- Check to see if original file is in WAV format if so take it else take the WAV one --->
			<cfif arguments.thestruct.qry_detail.detail.aud_extension EQ "WAV">
				<!--- Set Name --->
				<cfset arguments.thestruct.thename = arguments.thestruct.qry_detail.detail.aud_name_org>
				<!--- Download --->
				<cfhttp url="#arguments.thestruct.aka##arguments.thestruct.akaaud#/#arguments.thestruct.qry_detail.detail.aud_name_org#" file="#arguments.thestruct.qry_detail.detail.aud_name_org#" path="#arguments.thestruct.thisfolder#"></cfhttp>
			<cfelse>
				<!--- Set Name --->
				<cfset arguments.thestruct.thename = arguments.thestruct.qry_detail.detail.aud_name_noext & ".wav">
				<!--- Download file --->
				<cfhttp url="#arguments.thestruct.aka##arguments.thestruct.akaaud#/#arguments.thestruct.qry_detail.detail.aud_name_noext#.wav" file="#arguments.thestruct.qry_detail.detail.aud_name_noext#.wav" path="#arguments.thestruct.thisfolder#"></cfhttp>
			</cfif>
			<!--- Wait for the thread above until the file is downloaded fully --->
			<cfthread name="convert#tempfolder#" />
			<!--- Set the input path --->
			<cfset var inputpath = "#arguments.thestruct.thisfolder#/#arguments.thestruct.thename#">
		<!--- If on LAN --->
		<cfelseif arguments.thestruct.link_kind EQ "lan">
			<cfset var inputpath = "#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.detail.path_to_asset#/#arguments.thestruct.thenamenoext#.wav">
			<cfthread name="convert#tempfolder#" />
		</cfif>
		<!--- Wait for the thread above until the file is downloaded fully --->
		<cfthread action="join" name="convert#tempfolder#" />
		<!--- Ok, file is here so continue --->
		
		<!--- Check the platform and then decide on the ffmpeg tag --->
		<cfif isWindows>
			<cfset arguments.thestruct.theexe = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
			<cfset var inputpath = """#inputpath#""">
			<cfset var inputpath4copy = inputpath>
		<cfelse>
			<cfset arguments.thestruct.theexe = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
			<cfset var inputpath4copy = inputpath>
			<cfset var inputpath = replace(inputpath," ","\ ","all")>
			<cfset var inputpath = replace(inputpath,"&","\&","all")>
			<cfset var inputpath = replace(inputpath,"'","\'","all")>
		</cfif>
		<!--- Now, loop over the selected extensions and convert and store audio --->
		<cfloop delimiters="," list="#arguments.thestruct.convert_to#" index="theformat">
			<!--- Param --->
			<cfparam name="arguments.thestruct.convert_bitrate_#theformat#" default="">
			<!--- Create a new ID for the audio --->
			<cfset var newid = structnew()>
			<cfset newid.id = createuuid("")>
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#audios
			(aud_id, host_id)
			VALUES( 
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid.id#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
			)
			</cfquery>
			<!--- If from upload templates --->
			<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "undefined"  AND arguments.thestruct.upl_template NEQ "">
				<cfquery datasource="#application.razuna.datasource#" name="qry_b">
				SELECT upl_temp_field, upl_temp_value
				FROM #session.hostdbprefix#upload_templates_val
				WHERE upl_temp_field = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="convert_bitrate_#theformat#">
				AND upl_temp_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_template#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				</cfquery>
				<!--- Set image width and height --->
				<cfset var thebitrate  = qry_b.upl_temp_value>
			<cfelse>
				<cfset var thebitrate = Evaluate("arguments.thestruct.convert_bitrate_#theformat#")>
			</cfif>
			<!--- From here on we need to remove the number of the format (if any) --->
			<cfset var theformat = listfirst(theformat,"_")>
			<!--- Put together the filenames --->
			<cfset var newname = listfirst(arguments.thestruct.qry_detail.detail.aud_name_org, ".")>
			<cfset var finalaudioname = "#newname#" & "_" & #newid.id# & "." & #theformat#>
			<!--- Check for os path --->
			<cfif isWindows>
				<cfset var thisfinalaudioname = """#thisfolder#/#finalaudioname#""">
				<cfset var thisfinalaudioname4copy = thisfinalaudioname>
			<cfelse>
				<cfset var thisfinalaudioname = "#thisfolder#/#finalaudioname#">
				<cfset var thisfinalaudioname4copy = thisfinalaudioname>
				<cfset var thisfinalaudioname = replace(thisfinalaudioname," ","\ ","all")>
				<cfset var thisfinalaudioname = replace(thisfinalaudioname,"&","\&","all")>
				<cfset var thisfinalaudioname = replace(thisfinalaudioname,"'","\'","all")>
			</cfif>
			<!--- FFMPEG: Set convert parameters for the different types --->
			<cfswitch expression="#theformat#">
				<!--- OGG --->
				<cfcase value="ogg">
					<cfset arguments.thestruct.theargument="-i #inputpath# -acodec libvorbis -aq #thebitrate# -y #thisfinalaudioname#">
				</cfcase>
				<!--- MP3 --->
				<cfcase value="mp3">
					<cfset arguments.thestruct.theargument="-i #inputpath# -ab #thebitrate#k -y #thisfinalaudioname#">
				</cfcase>
				<cfdefaultcase>
					<cfset arguments.thestruct.theargument="-i #inputpath# -y #thisfinalaudioname#">
				</cfdefaultcase>
			</cfswitch>
			<!--- FFMPEG: Convert --->
			<cfset arguments.thestruct.thesh = "#GetTempDirectory()#/#newid.id#.sh">
			<!--- On Windows a bat --->
			<cfif isWindows>
				<cfset arguments.thestruct.thesh = "#GetTempDirectory()#/#newid.id#.bat">
			</cfif>
			<!--- WAV (just copy the file) --->
			<cfif theformat EQ "WAV">
				<cffile action="copy" source="#inputpath4copy#" destination="#thisfinalaudioname4copy#" mode="775">
				<!--- Write files --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="." mode="777">
			<cfelse>
				<!--- Write files --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexe# #arguments.thestruct.theargument#" mode="777">
				<!--- Convert audio --->
				<cfthread name="#newid.id#" intstruct="#arguments.thestruct#">
					<cfexecute name="#attributes.intstruct.thesh#" timeout="9000" />
				</cfthread>
				<!--- Wait for the thread above until the file is fully converted --->
				<cfthread action="join" name="#newid.id#" />
			</cfif>
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
			<!--- Check if audio file could be generated by getting the size --->
			<cfinvoke component="global" method="getfilesize" filepath="#thisfolder#/#finalaudioname#" returnvariable="siz">
			<cfif siz EQ 0>
				<cfquery datasource="#application.razuna.datasource#" name="qryuser">
				SELECT user_email
				FROM users
				WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
				</cfquery>
				<cfinvoke component="email" method="send_email" to="#qryuser.user_email#" subject="Error on converting your audio" themessage="Your Audio could not be converted to the format #ucase(theformat)#. This can happen when the source audio is rendered with codecs that our conversion engine can not read/write.">
			<cfelse>
				<!--- Get size of original --->
				<cfinvoke component="global" method="getfilesize" filepath="#thisfolder#/#finalaudioname#" returnvariable="orgsize">
				<!--- MD5 Hash --->
				<cfif FileExists("#thisfolder#/#finalaudioname#")>
					<cfset var md5hash = hashbinary("#thisfolder#/#finalaudioname#")>
				</cfif>
				<!--- Storage: Local --->
				<cfif application.razuna.storage EQ "local">
					<!--- Now move the files to its own folder --->
					<!--- Create folder first --->
					<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.detail.folder_id_r#/aud/#newid.id#" mode="775">
					<!--- Move Audio --->
					<cffile action="move" source="#thisfolder#/#finalaudioname#" destination="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_detail.detail.folder_id_r#/aud/#newid.id#" mode="775">
					<cfthread name="uploadconvert#newid.id#"></cfthread>
				<!--- Nirvanix --->
				<cfelseif application.razuna.storage EQ "nirvanix">
					<!--- Set variables for thread --->
					<cfset arguments.thestruct.newid = newid.id>
					<cfset arguments.thestruct.finalaudioname = finalaudioname>
					<!--- Upload: Audio --->
					<cfthread name="uploadconvert#newid.id#" intstruct="#arguments.thestruct#">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qry_detail.detail.folder_id_r#/aud/#attributes.intstruct.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.finalaudioname#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for this thread to finish --->
					<cfthread action="join" name="uploadconvert#newid.id#" />
					<!--- Get signed URLS --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qry_detail.detail.folder_id_r#/aud/#arguments.thestruct.newid#/#arguments.thestruct.finalaudioname#" nvxsession="#arguments.thestruct.nvxsession#">
				<!--- Amazon --->
				<cfelseif application.razuna.storage EQ "amazon">
					<!--- Set variables for thread --->
					<cfset arguments.thestruct.newid = newid.id>
					<cfset arguments.thestruct.finalaudioname = finalaudioname>
					<cfthread name="uploadconvert#newid.id#" intstruct="#arguments.thestruct#">
						<!--- Upload: Audio --->
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qry_detail.detail.folder_id_r#/aud/#attributes.intstruct.newid#/#attributes.intstruct.finalaudioname#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.finalaudioname#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for this thread to finish --->
					<cfthread action="join" name="uploadconvert#newid.id#" />
					<!--- Get signed URLS --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qry_detail.detail.folder_id_r#/aud/#arguments.thestruct.newid#/#arguments.thestruct.finalaudioname#" awsbucket="#arguments.thestruct.awsbucket#">
				<!--- Akamai --->
				<cfelseif application.razuna.storage EQ "akamai">
					<!--- Set variables for thread --->
					<cfset arguments.thestruct.newid = newid.id>
					<cfset arguments.thestruct.finalaudioname = finalaudioname>
					<!--- Upload: Audio --->
					<cfthread name="uploadconvert#newid.id#" intstruct="#arguments.thestruct#">
						<cfinvoke component="akamai" method="Upload">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thisfolder#/#attributes.intstruct.finalaudioname#">
							<cfinvokeargument name="thetype" value="#attributes.intstruct.akaaud#">
							<cfinvokeargument name="theurl" value="#attributes.intstruct.akaurl#">
							<cfinvokeargument name="thefilename" value="#attributes.intstruct.finalaudioname#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for this thread to finish --->
					<cfthread action="join" name="uploadconvert#newid.id#" />
				</cfif>
				<!--- Add to shared options --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#share_options
				(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
				VALUES(
				<cfqueryparam value="#newid.id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.thestruct.qry_detail.detail.folder_id_r#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="aud" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#newid.id#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Update the audio record with other information --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET 
				<cfif isDefined('arguments.thestruct.aud_group_id') AND arguments.thestruct.aud_group_id NEQ ''>
					aud_group = <cfqueryparam value="#arguments.thestruct.aud_group_id#" cfsqltype="cf_sql_varchar">,
				<cfelse>
					aud_group = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">, 
				</cfif>
				aud_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#finalaudioname#">,
				aud_owner = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
				aud_create_date = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
				aud_change_date = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
				aud_create_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				aud_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				aud_extension = <cfqueryparam value="#theformat#" cfsqltype="cf_sql_varchar">,
				aud_name_org = <cfqueryparam cfsqltype="cf_sql_varchar" value="#finalaudioname#">,
				folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qry_detail.detail.folder_id_r#">,
			 	aud_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#orgsize#">,
			 	path_to_asset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qry_detail.detail.folder_id_r#/aud/#newid.id#">,
			 	cloud_url_org = <cfqueryparam value="#cloud_url_org.theurl#" cfsqltype="cf_sql_varchar">,
				cloud_url_exp = <cfqueryparam value="#cloud_url_org.newepoch#" cfsqltype="CF_SQL_NUMERIC">,
				is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
				hashtag = <cfqueryparam value="#md5hash#" cfsqltype="cf_sql_varchar">
				WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newid.id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Log --->
				<cfset log_assets(theuserid=session.theuserid,logaction='Convert',logdesc='Converted: #arguments.thestruct.qry_detail.detail.aud_name# to #finalaudioname#',logfiletype='aud',assetid='#arguments.thestruct.file_id#')>
				<!--- Call Plugins --->
				<cfset arguments.thestruct.fileid = newid.id>
				<cfset arguments.thestruct.file_name = finalaudioname>
				<cfset arguments.thestruct.folder_id = arguments.thestruct.qry_detail.detail.folder_id_r>
				<cfset arguments.thestruct.thefiletype = "aud">
				<cfset arguments.thestruct.folder_action = false>
				<!--- Check on any plugin that call the on_rendition_add action --->
				<cfinvoke component="plugins" method="getactions" theaction="on_rendition_add" args="#arguments.thestruct#" />
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("audios")>
		<cfcatch type="any">
			<cfmail to="support@razuna.com" from="server@razuna.com" subject="Error on convert audio" type="html">
				<cfdump var="#cfcatch#">
				<cfdump var="#arguments.thestruct#">
			</cfmail>
		</cfcatch>
	</cftry>
</cffunction>

<!--- GET RELATED AUDIOS --->
<cffunction name="relatedaudios" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("audios")>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#relatedaudios */ aud_id, folder_id_r, aud_name, aud_extension, aud_size, 
	path_to_asset, aud_group, aud_name_org
	FROM #session.hostdbprefix#audios
	WHERE aud_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY aud_extension
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- WRITE AUDIO TO SYSTEM --->
<cffunction name="writeaudio" output="true">
	<cfargument name="thestruct" type="struct">
	<cfparam name="arguments.thestruct.zipit" default="T">
	<!--- Create a temp folder --->
	<cfset tempfolder = createuuid("")>
	<cfdirectory action="create" directory="#arguments.thestruct.thepath#/outgoing/#tempfolder#" mode="775">
	<!--- Put the audio id into a variable --->
	<cfset theaudioid = #arguments.thestruct.file_id#>
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- set session.artofimage value if it is empty  --->
	<cfif session.artofimage EQ "">
		<cfset session.artofimage = arguments.thestruct.artofimage>
	</cfif>
	<!--- Start the loop to get the different kinds of audios --->
	<cfloop delimiters="," list="#session.artofimage#" index="art">
		<!--- Since the video format could be from the related table we need to check this here so if the value is a number it is the id for the video --->
		<cfif isnumeric(art)>
			<!--- Set the video id for this type of format and set the extension --->
			<cfset theaudioid = art>
			<cfquery name="ext" datasource="#variables.dsn#">
			SELECT aud_extension
			FROM #session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam value="#theaudioid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset art = ext.aud_extension>
		</cfif>
		<!--- Create subfolder for the kind of video --->
		<cfdirectory action="create" directory="#arguments.thestruct.thepath#/outgoing/#tempfolder#/#art#" mode="775">
		<!--- Set the colname to get from oracle to video_preview else to video always --->
		<cfset thecolname = "audio">
		<!--- Query the db --->
		<cfquery name="qry" datasource="#variables.dsn#">
		SELECT a.aud_name, a.aud_extension, a.aud_name_org, a.folder_id_r, a.aud_group, a.link_kind, 
		a.link_path_url, a.path_to_asset, a.cloud_url_org
		FROM #session.hostdbprefix#audios a, #session.hostdbprefix#settings_2 s
		WHERE a.aud_id = <cfqueryparam value="#theaudioid#" cfsqltype="CF_SQL_VARCHAR">
		AND s.set2_id = <cfqueryparam value="#variables.setid#" cfsqltype="cf_sql_numeric">
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- If we have the preview the name is different --->
		<cfset thefinalname = qry.aud_name_org>
		<!--- Put variables into struct for threads --->
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset arguments.thestruct.qry = qry>
		<cfset arguments.thestruct.theaudioid = theaudioid>
		<cfset arguments.thestruct.tempfolder = tempfolder>
		<cfset arguments.thestruct.art = art>
		<cfset arguments.thestruct.thefinalname = thefinalname>
		<cfset arguments.thestruct.thecolname = thecolname>
		<!--- Local --->
		<cfif application.razuna.storage EQ "local" AND qry.link_kind EQ "">
			<cfthread name="download#art##theaudioid#" intstruct="#arguments.thestruct#">
				<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.thefinalname#" destination="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#/#attributes.intstruct.thefinalname#" mode="775">
			</cfthread>
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix" AND qry.link_kind EQ "">
			<cfthread name="download#art##theaudioid#" intstruct="#arguments.thestruct#">
				<cfhttp url="#attributes.intstruct.qry.cloud_url_org#" file="#attributes.intstruct.thefinalname#" path="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#"></cfhttp>
			</cfthread>
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon" AND qry.link_kind EQ "">
			<!--- Download file --->
			<cfthread name="download#art##theaudioid#" intstruct="#arguments.thestruct#">
				<cfinvoke component="amazon" method="Download">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.thefinalname#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#/#attributes.intstruct.thefinalname#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
		<!--- Akamai --->
		<cfelseif application.razuna.storage EQ "akamai" AND qry.link_kind EQ "">
			<cfthread name="download#art##theaudioid#" intstruct="#arguments.thestruct#">
				<cfhttp url="#attributes.intstruct.akaurl##attributes.intstruct.akaaud#/#attributes.intstruct.thefinalname#" file="#attributes.intstruct.thefinalname#" path="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#"></cfhttp>
			</cfthread>
		<!--- If local link --->
		<cfelseif qry.link_kind EQ "lan">
			<!--- Copy file to the outgoing folder --->
			<cfthread name="download#art##theaudioid#" intstruct="#arguments.thestruct#">
				<!--- If Original --->
				<cfif attributes.intstruct.art EQ "audio">
					<cffile action="copy" source="#attributes.intstruct.qry.link_path_url#" destination="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#/#attributes.intstruct.thefinalname#" mode="775">
				<!--- different format --->
				<cfelse>
					<cffile action="copy" source="#attributes.intstruct.assetpath#/#attributes.intstruct.hostid#/#attributes.intstruct.qry.path_to_asset#/#attributes.intstruct.thefinalname#" destination="#attributes.intstruct.thepath#/outgoing/#attributes.intstruct.tempfolder#/#attributes.intstruct.art#/#attributes.intstruct.thefinalname#" mode="775">
				</cfif>
			</cfthread>
		</cfif>
		<!--- Wait for the thread above until the file is downloaded fully --->
		<cfthread action="join" name="download#art##theaudioid#" />
		<!--- Set extension --->
		<cfset theext = qry.aud_extension>
		<!--- If the art id not thumb and original we need to get the name from the parent record --->
		<cfif qry.aud_group NEQ "">
			<cfquery name="qry" datasource="#variables.dsn#">
			SELECT aud_name
			FROM #session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam value="#qry.aud_group#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- If filename contains /\ --->
		<cfset thenewname = replace(qry.aud_name,"/","-","all")>
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

<!--- Get description and keywords for print --->
<cffunction name="gettext" output="false">
	<cfargument name="qry" type="query">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("audios")>
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
			SELECT /* #variables.cachetoken#gettextaud */ aud_id_r tid, aud_description description, aud_keywords keywords
			FROM #session.hostdbprefix#audios_text
			WHERE aud_id_r IN ('0'<cfloop query="arguments.qry" startrow="#q_start#" endrow="#q_end#">,'#id#'</cfloop>)
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
	<cfset variables.cachetoken = getcachetoken("audios")>
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
			SELECT /* #variables.cachetoken#gettextrm */ aud_meta rawmetadata
			FROM #session.hostdbprefix#audios
			WHERE aud_id IN ('0'<cfloop query="arguments.qry" startrow="#q_start#" endrow="#q_end#">,'#id#'</cfloop>)
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
	aud_id id, aud_name, folder_id_r, cloud_url, cloud_url_org, aud_name_org filenameorg, link_kind, link_path_url, 
	path_to_asset, lucene_key
	FROM #session.hostdbprefix#audios
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
	<cfset variables.cachetoken = getcachetoken("audios")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#checkmd5 */ aud_id
	FROM #session.hostdbprefix#audios
	WHERE hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.md5hash#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
	</cfquery>
	<cfreturn qry />
</cffunction>

<!--- Update all copy Metadata --->
<cffunction name="copymetadataupdate" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- select audio name --->
	<!--- <cfquery datasource="#application.razuna.datasource#" name="thedetail">
		SELECT aud_name
		FROM #session.hostdbprefix#audios
		WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.file_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery> --->
	<!--- select audio details --->
	<cfquery datasource="#application.razuna.datasource#" name="theaudtext">
		SELECT aud_description,aud_keywords 
		FROM #session.hostdbprefix#audios_text
		WHERE aud_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.file_id#"> 
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfif arguments.thestruct.insert_type EQ 'replace'>
		<!--- replace the metadata --->
		<!--- update audio name --->
		<cfloop list="#arguments.thestruct.idlist#" index="i">
			<!--- <cfquery datasource="#application.razuna.datasource#" name="update">
				UPDATE #session.hostdbprefix#audios
				SET aud_NAME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thedetail.aud_name#">
				WHERE aud_ID  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery> --->
			<cfquery datasource="#application.razuna.datasource#" name="checkid">
				SELECT aud_id_r 
				FROM #session.hostdbprefix#audios_text
				WHERE aud_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#"> 
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfif checkid.RecordCount>
				<!--- update audio desc and keywords --->
				<cfquery datasource="#application.razuna.datasource#" name="updateaudtext">
					UPDATE #session.hostdbprefix#audios_text
					SET aud_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#theaudtext.aud_description#">,
					aud_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="#theaudtext.aud_keywords#">
					WHERE aud_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelse>
				<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#audios_text
					(id_inc, aud_id_r, lang_id_r, aud_description, aud_keywords, host_id)
					VALUES(
					<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">, 
					<cfqueryparam value="#theaudtext.aud_description#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#theaudtext.aud_keywords#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
				</cfquery>
			</cfif>
		</cfloop>
	<cfelse>
			<!--- append the metadata --->
		<cfloop list="#arguments.thestruct.idlist#" index="i">
			<cfquery datasource="#application.razuna.datasource#" name="theauddetail">
				SELECT aud_name
				FROM #session.hostdbprefix#audios
				WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#" name="theaudtextdetail">
				SELECT aud_description,aud_keywords 
				FROM #session.hostdbprefix#audios_text
				WHERE aud_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#"> 
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- update audio name --->
			<!--- <cfquery datasource="#application.razuna.datasource#" name="update">
				UPDATE #session.hostdbprefix#audios
				SET aud_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#theauddetail.aud_name# #thedetail.aud_name#">
				WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery> --->
			<!--- update audio desc and keywords --->
			<cfif theaudtextdetail.RecordCount>
				<cfquery datasource="#application.razuna.datasource#" name="updateaudtext">
					UPDATE #session.hostdbprefix#audios_text
					SET aud_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#theaudtextdetail.aud_description# #theaudtext.aud_description#">,
					aud_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="#theaudtextdetail.aud_keywords# #theaudtext.aud_keywords#">
					WHERE aud_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelse>
				<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#audios_text
					(id_inc, aud_id_r, lang_id_r, aud_description, aud_keywords, host_id)
					VALUES(
					<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">, 
					<cfqueryparam value="#theaudtext.aud_description#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#theaudtext.aud_keywords#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
</cffunction>
<!--- Get all asset from folder --->
<cffunction name="getAllFolderAsset" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#variables.dsn#" name="qry_data">
		SELECT aud_id AS id,aud_name AS filename
		FROM #session.hostdbprefix#audios
		WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
		AND aud_group IS NULL
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry_data>
</cffunction>
</cfcomponent>