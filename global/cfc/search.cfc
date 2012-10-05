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

	<!--- SEARCH: FILES --->
	<cffunction name="search_files">
		<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("search")>
		<cfset variables.cachetokenlogs = getcachetoken("logs")>
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="" name="arguments.thestruct.doctype">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
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
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "*">
		</cfif>
		<!--- Search in Lucene --->
		<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="doc" hostid="#session.hostid#" returnvariable="qrylucene">
		<!--- If lucene returns no records --->
		<cfif qrylucene.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattree">
			SELECT categorytree
			FROM qrylucene
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
			<!--- This is only needed if we come from a share which is a collection. We filter on the asset id in the collection --->
			<cfif arguments.thestruct.iscol EQ "T">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree 
				<cfif arguments.thestruct.qry.listdoc.recordcount EQ 0>
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry.listdoc.id)#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
			<!--- Search in a search --->
			<cfif arguments.thestruct.newsearch EQ "F">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree 
				<cfif arguments.thestruct.listdocid EQ "">
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.listdocid#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
		<cfelse>
			<cfset cattree = querynew("categorytree")>
		</cfif>
		<!--- Grab the result and query file db --->
		<cfquery datasource="#variables.dsn#" name="qrymain" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#search_files */ f.file_id id, f.file_name filename, f.folder_id_r, 
		f.file_extension ext, f.file_name_org filename_org, f.file_type as kind, f.is_available,
		f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url,
		f.path_to_asset, f.cloud_url, f.cloud_url_org, fd.file_desc description, fd.file_keywords keywords, '0' as vwidth, '0' as vheight, '0' as theformat,
		lower(f.file_name) filename_forsort, f.file_size size, f.hashtag, fo.folder_name,
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'unlocked' as perm,
		<cfelse>
			CASE
				<!--- Check permission on this folder --->
				WHEN EXISTS(
					SELECT fg.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg
					WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg.folder_id_r = f.folder_id_r
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)
					) THEN 'unlocked'
				<!--- When folder is shared for everyone --->
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2
					WHERE fg2.grp_id_r = '0'
					AND fg2.folder_id_r = f.folder_id_r
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				WHEN (lower(fo.folder_of_user) = 't' AND fo.folder_owner = '#session.theuserid#') THEN 'unlocked'
				ELSE 'locked'
			END as perm,
		</cfif>
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'X' as permfolder
		<cfelse>
			CASE
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = f.folder_id_r
				AND fg3.grp_id_r = '0') = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = f.folder_id_r
				AND fg3.grp_id_r = '0') = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = f.folder_id_r
				AND fg3.grp_id_r = '0') = 'X' THEN 'X'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = f.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = f.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = f.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		,
		<cfif application.razuna.thedatabase EQ "mssql">f.file_id + '-doc'<cfelse>concat(f.file_id,'-doc')</cfif> as listid
		FROM #session.hostdbprefix#files f
		LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = f.folder_id_r AND f.host_id = fo.host_id
		LEFT JOIN #session.hostdbprefix#files_desc fd ON f.file_id = fd.file_id_r AND fd.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
		WHERE f.file_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
		<!--- Only if we have dates --->
		<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
			AND f.file_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
		</cfif>
		<!--- Only if we have a folder id that is not 0 --->
		<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
			AND f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
		</cfif>
		GROUP BY id, filename, f.folder_id_r, ext, filename_org, kind, is_available, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, vwidth, vheight, theformat, filename_forsort, size, hashtag, folder_name
		ORDER BY #sortby#
		</cfquery>
		<!--- Show the results according to extension only. Needed when we have the doctype --->
		<cfif arguments.thestruct.doctype NEQ "">
			<cfquery dbtype="query" name="qry">
				SELECT *
				FROM qrymain
				<cfswitch expression="#arguments.thestruct.doctype#">
					<cfcase value="doc">
						WHERE file_extension = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
						AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					</cfcase>
					<cfcase value="xls">
						WHERE file_extension = <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
						AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					</cfcase>
					<cfcase value="pdf">
						WHERE file_extension = <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
						AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					</cfcase>
					<cfcase value="other">
						WHERE file_extension <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
						AND file_extension <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
						AND file_extension <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="xlsx" cfsqltype="cf_sql_varchar">
						AND file_extension <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
						AND file_extension <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="docx" cfsqltype="cf_sql_varchar">
						AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					</cfcase>
					<cfdefaultcase>
						WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					</cfdefaultcase>
				</cfswitch>
				<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
					AND permfolder IS NOT NULL
				</cfif>
			</cfquery>
		<cfelse>
			<!--- Select only records that are unlocked --->
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qrymain
			WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
			<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
				AND permfolder IS NOT NULL
			</cfif>
			</cfquery>
		</cfif>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry.recordcount>
		<cfset QueryAddcolumn(qry, "cnt", "integer", amount)>
		<!--- Log Result --->
		<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='doc')#>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: IMAGES --->
	<cffunction name="search_images">
		<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("search")>
		<cfset variables.cachetokenlogs = getcachetoken("logs")>
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
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
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "*">
		</cfif>
		<!--- Search in Lucene --->
		<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="img" hostid="#session.hostid#" returnvariable="qrylucene">
		<!--- If lucene returns no records --->
		<cfif qrylucene.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattree">
			SELECT categorytree
			FROM qrylucene
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
			<!--- This is only needed if we come from a share which is a collection. We filter on the asset id in the collection --->
			<cfif arguments.thestruct.iscol EQ "T">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree 
				<cfif arguments.thestruct.qry.listimg.recordcount EQ 0>
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry.listimg.id)#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
			<!--- Search in a search --->
			<cfif arguments.thestruct.newsearch EQ "F">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree 
				<cfif arguments.thestruct.listimgid EQ "">
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.listimgid#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
		<cfelse>
			<cfset cattree = querynew("categorytree")>
		</cfif>
		<!--- Grab the result and query file db --->
		<cfquery datasource="#variables.dsn#" name="qrymain" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#search_images */ i.img_id id, i.img_filename filename, 
		i.folder_id_r, i.thumb_extension ext, i.img_filename_org filename_org, 'img' as kind, i.is_available,
		i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
		i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description description, it.img_keywords keywords, '0' as vwidth, '0' as vheight, 
		(
			SELECT so.asset_format
			FROM #session.hostdbprefix#share_options so
			WHERE i.img_id = so.group_asset_id
			AND so.folder_id_r = i.folder_id_r
			AND so.asset_type = 'img'
			AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
		) AS theformat,
		lower(i.img_filename) filename_forsort,
		i.img_size size,
		i.hashtag,
		fo.folder_name,
		<!--- Check if this folder belongs to a user and lock/unlock --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'unlocked' as perm,
		<cfelse>
			CASE
				<!--- Check permission on this folder --->
				WHEN EXISTS(
					SELECT fg.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg
					WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg.folder_id_r = i.folder_id_r
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)
					) THEN 'unlocked'
				<!--- When folder is shared for everyone --->
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2
					WHERE fg2.grp_id_r = '0'
					AND fg2.folder_id_r = i.folder_id_r
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				WHEN (lower(fo.folder_of_user) = 't' AND fo.folder_owner = '#session.theuserid#') THEN 'unlocked'
				ELSE 'locked'
			END as perm,
		</cfif>
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'X' as permfolder
		<cfelse>
			CASE
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = i.folder_id_r
				AND fg3.grp_id_r = '0') = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = i.folder_id_r
				AND fg3.grp_id_r = '0') = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = i.folder_id_r
				AND fg3.grp_id_r = '0') = 'X' THEN 'X'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = i.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = i.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = i.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		,
		<cfif application.razuna.thedatabase EQ "mssql">i.img_id + '-img'<cfelse>concat(i.img_id,'-img')</cfif> as listid
		FROM #session.hostdbprefix#images i
		LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = i.folder_id_r AND i.host_id = fo.host_id
		LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
		WHERE i.img_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
		<!--- Only if we have dates --->
		<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
			AND i.img_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
		</cfif>
		<!--- Only if we have a folder id that is not 0 --->
		<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
			AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
		</cfif>
		<!--- Exclude related images --->
		AND (i.img_group IS NULL OR i.img_group = '')
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		GROUP BY id, filename, i.folder_id_r, ext, filename_org, kind, is_available, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, vwidth, vheight, theformat, filename_forsort, size, hashtag, folder_name
		ORDER BY #sortby#
		</cfquery>
		<!--- Select only records that are unlocked --->
		<cfquery dbtype="query" name="qry">
		SELECT *
		FROM qrymain
		WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
			AND permfolder IS NOT NULL
		</cfif>
		</cfquery>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry.recordcount>
		<cfset QueryAddcolumn(qry, "cnt", "integer", amount)>
		<!--- Log Result --->
		<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='img')#>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: VIDEOS --->
	<cffunction name="search_videos">
		<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("search")>
		<cfset variables.cachetokenlogs = getcachetoken("logs")>
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
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
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "*">
		</cfif>
		<!--- Search in Lucene --->
		<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="vid" hostid="#session.hostid#" returnvariable="qrylucene">
		<!--- If lucene returns no records --->
		<cfif qrylucene.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattree">
			SELECT categorytree
			FROM qrylucene
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
			<!--- This is only needed if we come from a share which is a collection. We filter on the asset id in the collection --->
			<cfif arguments.thestruct.iscol EQ "T">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree
				<cfif arguments.thestruct.qry.listvid.recordcount EQ 0>
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry.listvid.id)#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
			<!--- Search in a search --->
			<cfif arguments.thestruct.newsearch EQ "F">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree 
				<cfif arguments.thestruct.listvidid EQ "">
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.listvidid#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
		<cfelse>
			<cfset cattree = querynew("categorytree")>
		</cfif>
		<!--- Grab the result and query file db --->
		<cfquery datasource="#variables.dsn#" name="qrymain" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#search_videos */ v.vid_id id, v.vid_filename filename, v.folder_id_r, 
		v.vid_extension ext, v.vid_name_image filename_org, 'vid' as kind, v.is_available,
		v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url,
		v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description description, vt.vid_keywords keywords, CAST(v.vid_width AS CHAR) as vwidth, CAST(v.vid_height AS CHAR) as vheight,
		(
			SELECT so.asset_format
			FROM #session.hostdbprefix#share_options so
			WHERE v.vid_id = so.group_asset_id
			AND so.folder_id_r = v.folder_id_r
			AND so.asset_type = 'vid'
			AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
		) AS theformat,
		lower(v.vid_filename) filename_forsort,
		v.vid_size size,
		v.hashtag,
		fo.folder_name,
		<!--- Check if this folder belongs to a user and lock/unlock --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'unlocked' as perm,
		<cfelse>
			CASE
				<!--- Check permission on this folder --->
				WHEN EXISTS(
					SELECT fg.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg
					WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg.folder_id_r = v.folder_id_r
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)
					) THEN 'unlocked'
				<!--- When folder is shared for everyone --->
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2
					WHERE fg2.grp_id_r = '0'
					AND fg2.folder_id_r = v.folder_id_r
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				WHEN (lower(fo.folder_of_user) = 't' AND fo.folder_owner = '#session.theuserid#') THEN 'unlocked'
				ELSE 'locked'
			END as perm,
		</cfif>
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'X' as permfolder
		<cfelse>
			CASE
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = v.folder_id_r
				AND fg3.grp_id_r = '0') = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = v.folder_id_r
				AND fg3.grp_id_r = '0') = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = v.folder_id_r
				AND fg3.grp_id_r = '0') = 'X' THEN 'X'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = v.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = v.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = v.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		,
		<cfif application.razuna.thedatabase EQ "mssql">v.vid_id + '-vid'<cfelse>concat(v.vid_id,'-vid')</cfif> as listid
		FROM #session.hostdbprefix#videos v
		LEFT JOIN #session.hostdbprefix#videos_text vt ON vt.vid_id_r = v.vid_id AND vt.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
		LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = v.folder_id_r AND v.host_id = fo.host_id
		WHERE v.vid_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
		<!--- Only if we have dates --->
		<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
			AND v.vid_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
		</cfif>
		<!--- Only if we have a folder id that is not 0 --->
		<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
			AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
		</cfif>
		<!--- Exclude related images --->
		AND (v.vid_group IS NULL OR v.vid_group = '')
		AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		GROUP BY id, filename, v.folder_id_r, ext, filename_org, kind, is_available, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, vwidth, vheight, theformat, filename_forsort, size, hashtag, folder_name
		ORDER BY #sortby#
		</cfquery>
		<!--- Select only records that are unlocked --->
		<cfquery dbtype="query" name="qry">
		SELECT *
		FROM qrymain
		WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
			AND permfolder IS NOT NULL
		</cfif>
		</cfquery>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry.recordcount>
		<cfset QueryAddcolumn(qry, "cnt", "integer", amount)>
		<!--- Log Result --->
		<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='vid')#>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>
	
	<!--- SEARCH: AUDIOS --->
	<cffunction name="search_audios">
		<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("search")>
		<cfset variables.cachetokenlogs = getcachetoken("logs")>
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
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
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "*">
		</cfif>
		<!--- Search in Lucene --->
		<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="aud" hostid="#session.hostid#" returnvariable="qrylucene">
		<!--- If lucene returns no records --->
		<cfif qrylucene.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattree">
			SELECT categorytree
			FROM qrylucene
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
			<!--- This is only needed if we come from a share which is a collection. We filter on the asset id in the collection --->
			<cfif arguments.thestruct.iscol EQ "T">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree
				<cfif arguments.thestruct.qry.listaud.recordcount EQ 0>
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.qry.listaud.id)#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
			<!--- Search in a search --->
			<cfif arguments.thestruct.newsearch EQ "F">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree 
				<cfif arguments.thestruct.listaudid EQ "">
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.listaudid#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
		<cfelse>
			<cfset cattree = querynew("categorytree")>
		</cfif>
		<!--- Grab the result and query file db --->
		<cfquery datasource="#variables.dsn#" name="qrymain" cachedWithin="1">
		SELECT /* #variables.cachetoken#search_audios */ a.aud_id id, a.aud_name filename, a.folder_id_r, 
		a.aud_extension ext, a.aud_name_org filename_org, 'aud' as kind, a.is_available,
		a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url,
		a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description description, aut.aud_keywords keywords, '0' as vwidth, '0' as vheight,
		(
			SELECT so.asset_format
			FROM #session.hostdbprefix#share_options so
			WHERE a.aud_id = so.group_asset_id
			AND so.folder_id_r = a.folder_id_r
			AND so.asset_type = 'aud'
			AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
		) AS theformat,
		lower(a.aud_name) filename_forsort,
		a.aud_size size,
		a.hashtag,
		fo.folder_name,
		<!--- Check if this folder belongs to a user and lock/unlock --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'unlocked' as perm,
		<cfelse>
			CASE
				<!--- Check permission on this folder --->
				WHEN EXISTS(
					SELECT fg.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg
					WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg.folder_id_r = a.folder_id_r
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)
					) THEN 'unlocked'
				<!--- When folder is shared for everyone --->
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2
					WHERE fg2.grp_id_r = '0'
					AND fg2.folder_id_r = a.folder_id_r
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				WHEN (lower(fo.folder_of_user) = 't' AND fo.folder_owner = '#session.theuserid#') THEN 'unlocked'
				ELSE 'locked'
			END as perm,
		</cfif>
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			'X' as permfolder
		<cfelse>
			CASE
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = a.folder_id_r
				AND fg3.grp_id_r = '0') = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = a.folder_id_r
				AND fg3.grp_id_r = '0') = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = a.folder_id_r
				AND fg3.grp_id_r = '0') = 'X' THEN 'X'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = a.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'R' THEN 'R'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = a.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'W' THEN 'W'
				WHEN (SELECT fg3.grp_permission
				FROM #session.hostdbprefix#folders_groups fg3
				WHERE fg3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg3.folder_id_r = a.folder_id_r
				AND fg3.grp_id_r IN (SELECT ct_g_u_grp_id FROM ct_groups_users WHERE ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">)) = 'X' THEN 'X'
			END as permfolder
		</cfif>
		,
		<cfif application.razuna.thedatabase EQ "mssql">a.aud_id + '-aud'<cfelse>concat(a.aud_id,'-aud')</cfif> as listid
		FROM #session.hostdbprefix#audios a
		LEFT JOIN #session.hostdbprefix#audios_text aut ON aut.aud_id_r = a.aud_id AND aut.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
		LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = a.folder_id_r AND a.host_id = fo.host_id
		WHERE a.aud_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
		<!--- Only if we have dates --->
		<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
			AND a.aud_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
		</cfif>
		<!--- Only if we have a folder id that is not 0 --->
		<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
			AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
		</cfif>
		<!--- Exclude related images --->
		AND (a.aud_group IS NULL OR a.aud_group = '')
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		GROUP BY id, filename, a.folder_id_r, ext, filename_org, kind, is_available, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, vwidth, vheight, theformat, filename_forsort, size, hashtag, folder_name
		ORDER BY #sortby#
		</cfquery>
		<!--- Select only records that are unlocked --->
		<cfquery dbtype="query" name="qry">
		SELECT *
		FROM qrymain
		WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
			AND permfolder IS NOT NULL
		</cfif>
		</cfquery>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry.recordcount>
		<cfset QueryAddcolumn(qry, "cnt", "integer", amount)>
		<!--- Log Result --->
		<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='aud')#>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>
	
	<!--- Search for suggestion --->
	<cffunction name="search_suggest" access="remote" output="true">
		<cfargument name="searchtext" required="true">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetokenlogs = getcachetoken("logs")>
		<!--- The function must return suggestions as an array. ---> 
		<cfset var myarray = ArrayNew(1)> 
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedWithin="1">
		SELECT /* #variables.cachetokenlogs#search */ log_search_for
		FROM #session.hostdbprefix#log_search
		WHERE lower(log_search_for) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.searchtext)#%">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND log_user = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
		AND log_founditems != 0
		GROUP BY log_search_for
		ORDER BY log_founditems
		</cfquery>
		<!--- Append --->
		<cfloop query="qry"> 
			<cfset arrayAppend(myarray, log_search_for)>
		</cfloop>
		<cfoutput>#SerializeJSON(myarray)#</cfoutput>
		<cfreturn /> 
	</cffunction> 

	<!--- Combine searches (needed for new folder search) --->
	<cffunction name="search_combine" access="Public" output="false">
		<cfargument name="qdoc" required="true" type="query">
		<cfargument name="qimg" required="true" type="query">
		<cfargument name="qvid" required="true" type="query">
		<cfargument name="qaud" required="true" type="query">
		<!--- Param --->
		<cfset var qry = structnew()>
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
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
		<!--- Union the 4 query results into one --->
		<cfquery name="qry.qall" dbtype="query">
		SELECT *
		FROM arguments.qdoc
		WHERE id IS NOT NULL
		UNION ALL
		SELECT *
		FROM arguments.qimg
		WHERE id IS NOT NULL
		UNION ALL
		SELECT *
		FROM arguments.qvid
		WHERE id IS NOT NULL
		UNION ALL
		SELECT *
		FROM arguments.qaud
		WHERE id IS NOT NULL
		ORDER BY #sortby#
		</cfquery>
		<!--- Set each query result into struct --->
		<cfset qry.qdoc = arguments.qdoc>
		<cfset qry.qimg = arguments.qimg>
		<cfset qry.qvid = arguments.qvid>
		<cfset qry.qaud = arguments.qaud>
		<!--- If recordcount is empty then 0 the cnt --->
		<cfset var qdocc = arguments.qdoc.cnt>
		<cfset var qimgc = arguments.qimg.cnt>
		<cfset var qvidc = arguments.qvid.cnt>
		<cfset var qaudc = arguments.qaud.cnt>
		<cfif !isnumeric(arguments.qdoc.cnt)>
			<cfset qdocc = 0>
		</cfif>
		<cfif !isnumeric(arguments.qimg.cnt)>
			<cfset qimgc = 0>
		</cfif>
		<cfif !isnumeric(arguments.qvid.cnt)>
			<cfset qvidc = 0>
		</cfif>
		<cfif !isnumeric(arguments.qaud.cnt)>
			<cfset qaudc = 0>
		</cfif>
		<!--- Calculate the total found files together --->
		<cfset qry.thetotal = qdocc + qimgc + qvidc + qaudc>
		<!--- Set the session for offset correctly if the total count of assets in lower the the total rowmaxpage --->
		<cfif qry.thetotal LTE session.rowmaxpage>
			<cfset session.offset = 0>
		</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction> 

</cfcomponent>
