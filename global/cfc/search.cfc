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
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="10" name="arguments.thestruct.rowmax">
		<cfparam default="0" name="arguments.thestruct.rowmin">
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="" name="arguments.thestruct.doctype">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "">
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
			<!--- ORACLE --->
			<cfif variables.database EQ "oracle">
				<!--- Query --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT rn, file_name, file_owner, file_create_date, file_change_date, folder_id_r, file_id, file_extension, file_type, file_online, file_name_org, howmany, folder_name, link_kind, link_path_url, path_to_asset, cloud_url, keywords, description, perm
				FROM (
					SELECT ROWNUM AS rn, file_name, file_owner, file_create_date, file_change_date, folder_id_r, file_id, file_extension, file_type, file_online, file_name_org, howmany, folder_name, link_kind, link_path_url, path_to_asset, cloud_url, keywords, description, perm
					FROM (
						SELECT f.file_name, f.file_owner, f.file_create_date, f.file_change_date, f.folder_id_r, f.file_id,
						f.file_extension, f.file_type, f.file_online, f.file_name_org, count(*) over() howmany, fo.folder_name,
						f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url, fd.file_keywords keywords, fd.file_desc description,
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
						FROM #session.hostdbprefix#files f
						LEFT JOIN #session.hostdbprefix#files_desc fd ON fd.file_id_r = f.file_id AND fd.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
						LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = f.folder_id_r AND f.host_id = fo.host_id
						WHERE f.file_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							<cfif arguments.thestruct.searchtext EQ "">WHERE<cfelse>AND</cfif> f.file_create_date = TO_DATE('#arguments.thestruct.on_month#/#arguments.thestruct.on_day#/#arguments.thestruct.on_year# 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						GROUP BY file_name, file_owner, file_create_date, file_change_date, f.folder_id_r, file_id, file_extension, file_type, file_online, file_name_org, folder_name, folder_of_user, folder_owner, file_keywords, file_desc, cloud_url
						ORDER BY file_name
						)
					WHERE ROWNUM <= <cfqueryparam value="#arguments.thestruct.rowmax#" cfsqltype="cf_sql_numeric">
					)
				WHERE rn > <cfqueryparam value="#arguments.thestruct.rowmin#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<!--- DB2 --->
			<cfelseif variables.database EQ "db2">
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT file_name, file_owner, file_create_date, file_change_date, folder_id_r, file_id, file_extension, link_kind, link_path_url,
				path_to_asset, cloud_url, file_type, file_online, file_name_org, folder_name, keywords, description, howmany, perm
				FROM (
					SELECT row_number() over() as rownr, f.file_name, f.file_owner, f.file_create_date, f.file_change_date, f.folder_id_r, 
					f.file_id, f.file_extension, f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url, f.file_type, f.file_online, f.file_name_org,
					fo.folder_name, fd.file_keywords keywords, fd.file_desc description,
						(
						SELECT COUNT(file_id)
						FROM #session.hostdbprefix#files
						WHERE file_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND file_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						) AS howmany,
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
					FROM #session.hostdbprefix#files f
					LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = f.folder_id_r AND f.host_id = fo.host_id
					LEFT JOIN #session.hostdbprefix#files_desc fd ON f.file_id = fd.file_id_r AND fd.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
					WHERE f.file_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND f.file_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					GROUP BY file_name, file_owner, file_create_date, file_change_date, f.folder_id_r, file_id, file_extension, 
					file_type, file_online, folder_name, file_name_org, folder_of_user, folder_owner, file_keywords, file_desc, 
					link_kind, link_path_url, path_to_asset, cloud_url
					ORDER BY file_name
				)
				WHERE rownr BETWEEN #arguments.thestruct.rowmin# AND #arguments.thestruct.rowmax#
				</cfquery>
			<!--- OTHER DATABASES --->
			<cfelse>
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT <cfif variables.database EQ "mssql">TOP #arguments.thestruct.rowmax# </cfif>f.file_name, 
				f.file_owner, f.file_create_date, f.file_change_date, f.folder_id_r, f.file_id, f.file_extension, 
				f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url,
				f.file_type, f.file_online, f.file_name_org, fo.folder_name, fd.file_keywords keywords, fd.file_desc description,
					(
					SELECT COUNT(file_id)
					FROM #session.hostdbprefix#files
					WHERE file_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND file_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					) AS howmany,
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
						'unlocked' as perm
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
						END as perm
					</cfif>
				FROM #session.hostdbprefix#files f
				LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = f.folder_id_r AND f.host_id = fo.host_id
				LEFT JOIN #session.hostdbprefix#files_desc fd ON f.file_id = fd.file_id_r AND fd.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
				WHERE f.file_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
				<!--- Only if we have dates --->
				<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
					AND f.file_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
				</cfif>
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				<!--- MSSQL --->
				<cfif variables.database EQ "mssql">
					AND f.file_id NOT IN (
						SELECT TOP #arguments.thestruct.rowmin# file_id
						FROM #session.hostdbprefix#files
						WHERE file_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND file_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
					)
				</cfif>
				GROUP BY file_name, file_owner, file_create_date, file_change_date, f.folder_id_r, file_id, file_extension, 
				file_type, file_online, folder_name, file_name_org, folder_of_user, folder_owner, file_keywords, file_desc, 
				link_kind, link_path_url, path_to_asset, cloud_url
				ORDER BY file_name
				<!--- MySQL / H2 --->
				<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
					LIMIT #arguments.thestruct.rowmin#,#arguments.thestruct.rowmax#
				</cfif>
				</cfquery>
			</cfif>
			<!--- Show the results according to exentions only. Needed when we have the doctype --->
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
				</cfquery>
			<cfelse>
				<cfquery dbtype="query" name="qry">
				SELECT *
				FROM qrymain
				WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
				</cfquery>
			</cfif>
			<!--- Log Result --->
			<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='doc')#>
		<cfelse>
			<cfset qry = querynew("file_id")>
		</cfif>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: IMAGES --->
	<cffunction name="search_images">
		<cfargument name="thestruct" type="struct">
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="10" name="arguments.thestruct.rowmax">
		<cfparam default="0" name="arguments.thestruct.rowmin">
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "">
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
			<!--- ORACLE --->
			<cfif variables.database EQ "oracle">
				<!--- Query --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT rn, img_id, img_filename, img_custom_id, thumbwidth, thumbheight, img_online, img_owner, thename, 
				img_create_date, img_change_date, folder_id_r, thumb_extension, howmany, howmany, folder_name, link_kind, 
				link_path_url, path_to_asset, cloud_url, keywords, description, perm
				FROM (
					SELECT ROWNUM AS rn, img_id, img_filename, img_custom_id, thumbwidth, thumbheight, img_online, img_owner,
					thename, img_create_date, img_change_date, folder_id_r, thumb_extension, howmany, folder_name, 
					link_kind, link_path_url, path_to_asset, cloud_url, keywords, description, perm
					FROM (
						SELECT i.img_id, i.img_filename, i.img_custom_id, i.thumb_width thumbwidth, 
						i.thumb_height thumbheight, i.img_online, i.img_owner, i.img_filename_org thename,
						i.img_create_date, i.img_change_date, i.folder_id_r, i.thumb_extension, count(*) over() howmany,
						fo.folder_name, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, it.img_keywords keywords,
						it.img_description description,
						<!--- Check if this folder belongs to a user and lock/unlock --->
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
						FROM #session.hostdbprefix#images i
						LEFT JOIN #session.hostdbprefix#images_text it ON it.img_id_r = i.img_id AND it.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
						LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = i.folder_id_r AND i.host_id = fo.host_id
						WHERE i.img_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							<cfif arguments.thestruct.searchtext EQ "">WHERE<cfelse>AND</cfif> i.img_create_date = TO_DATE('#arguments.thestruct.on_month#/#arguments.thestruct.on_day#/#arguments.thestruct.on_year# 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images --->
						AND (i.img_group IS NULL OR i.img_group = '')
						AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						GROUP BY img_id, img_filename, img_custom_id, thumb_width, thumb_height, img_online, img_owner,
						img_filename_org, img_create_date, img_change_date, i.folder_id_r, thumb_extension, folder_name, 
						folder_of_user, folder_owner, cloud_url
						ORDER BY img_filename
					)
					WHERE ROWNUM <= <cfqueryparam value="#arguments.thestruct.rowmax#" cfsqltype="cf_sql_numeric">
				)
				WHERE rn > <cfqueryparam value="#arguments.thestruct.rowmin#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<!--- DB2 --->
			<cfelseif variables.database EQ "db2">
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT img_id, img_filename, img_custom_id, thumbwidth, thumbheight, img_online, img_owner, thename, img_create_date,
				img_change_date, folder_id_r, thumb_extension, folder_name, link_kind, link_path_url, path_to_asset, cloud_url,
				keywords, description, howmany, perm
				FROM (
					SELECT row_number() over() as rownr, i.img_id, i.img_filename, i.img_custom_id, i.thumb_width thumbwidth, 
					i.thumb_height thumbheight, i.img_online, 
					i.img_owner, i.img_filename_org thename, i.img_create_date, i.img_change_date, i.folder_id_r, i.thumb_extension, 
					fo.folder_name, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, it.img_keywords keywords, it.img_description description,
						(
						SELECT COUNT(img_id)
						FROM #session.hostdbprefix#images
						WHERE img_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND img_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images --->
						AND (img_group IS NULL OR img_group = '')
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						) AS howmany,
						<!--- Check if this folder belongs to a user and lock/unlock --->
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
					FROM #session.hostdbprefix#images i
					LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = i.folder_id_r AND i.host_id = fo.host_id
					LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
					WHERE i.img_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND i.img_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					<!--- Exclude related images --->
					AND (i.img_group IS NULL OR i.img_group = '')
					AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					GROUP BY img_id, img_filename, img_custom_id, img_online, img_owner, img_create_date, 
					img_change_date, i.folder_id_r, folder_name, thumb_width, thumb_height, img_filename_org, thumb_extension, 
					folder_of_user, folder_owner, img_keywords, img_description, link_kind, link_path_url, path_to_asset, cloud_url
					ORDER BY img_filename
				)
				WHERE rownr BETWEEN #arguments.thestruct.rowmin# AND #arguments.thestruct.rowmax#
				</cfquery>
			<!--- OTHER DATABASES --->
			<cfelse>
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT <cfif variables.database EQ "mssql">TOP #arguments.thestruct.rowmax# </cfif>i.img_id, 
				i.img_filename, i.img_custom_id, i.thumb_width thumbwidth, i.thumb_height thumbheight, i.img_online, 
				i.img_owner, i.img_filename_org thename, i.img_create_date, i.img_change_date, i.cloud_url,
				i.folder_id_r, i.thumb_extension, fo.folder_name, i.link_kind, i.link_path_url, i.path_to_asset,
				it.img_keywords keywords, it.img_description description,
					(
					SELECT COUNT(img_id)
					FROM #session.hostdbprefix#images
					WHERE img_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND img_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					<!--- Exclude related images --->
					AND (img_group IS NULL OR img_group = '')
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					) AS howmany,
					<!--- Check if this folder belongs to a user and lock/unlock --->
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
						'unlocked' as perm
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
						END as perm
					</cfif>
				FROM #session.hostdbprefix#images i
				LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = i.folder_id_r AND i.host_id = fo.host_id
				LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
				WHERE i.img_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
				<!--- Only if we have dates --->
				<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
					AND i.img_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
				</cfif>
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				<!--- Exclude related images --->
				AND (i.img_group IS NULL OR i.img_group = '')
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<!--- MSSQL --->
				<cfif variables.database EQ "mssql">
					AND i.img_id NOT IN (
						SELECT TOP #arguments.thestruct.rowmin# img_id
						FROM #session.hostdbprefix#images
						WHERE img_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND img_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						AND (img_group IS NULL OR img_group = '')
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
				</cfif>
				GROUP BY img_id, img_filename, img_custom_id, img_online, img_owner, img_create_date, 
				img_change_date, i.folder_id_r, folder_name, thumb_width, thumb_height, img_filename_org, thumb_extension, 
				folder_of_user, folder_owner, img_keywords, img_description, link_kind, link_path_url, path_to_asset, cloud_url
				ORDER BY img_filename
				<!--- MySQL / H2 --->
				<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
					LIMIT #arguments.thestruct.rowmin#,#arguments.thestruct.rowmax#
				</cfif>
				</cfquery>
			</cfif>
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qrymain
			WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
			</cfquery>
			<!--- Log Result --->
			<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='img')#>
		<cfelse>
			<cfset qry = querynew("img_id")>
		</cfif>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: VIDEOS --->
	<cffunction name="search_videos">
		<cfargument name="thestruct" type="struct">
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="10" name="arguments.thestruct.rowmax">
		<cfparam default="0" name="arguments.thestruct.rowmin">
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "">
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
			<!--- ORACLE --->
			<cfif variables.database EQ "oracle">
				<!--- Query --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT rn, vid_id, vid_filename, folder_id_r, vid_custom_id, vid_online, vid_owner, vid_create_date,
				vid_change_date, vid_width, vid_height, howmany, folder_name, vid_name_image, link_kind, link_path_url, 
				path_to_asset, cloud_url, keywords, description, perm
				FROM (
					SELECT ROWNUM AS rn, vid_id, vid_filename, folder_id_r, vid_custom_id, vid_online, vid_owner,
					vid_create_date, vid_change_date, vid_width, vid_height, howmany, folder_name, vid_name_image, 
					link_kind, link_path_url, path_to_asset, cloud_url, keywords, description, perm
					FROM (
						SELECT v.vid_id, v.vid_filename, v.folder_id_r, v.vid_custom_id, v.vid_online,
						v.vid_owner, v.vid_create_date, v.vid_change_date, v.vid_width, v.vid_height, count(*) over() howmany,
						fo.folder_name, v.vid_name_image, v.link_kind, v.link_path_url, v.path_to_asset, v.cloud_url,
						vt.vid_keywords keywords, vt.vid_description description,
						<!--- Check if this folder belongs to a user and lock/unlock --->
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
						FROM #session.hostdbprefix#videos v
						LEFT JOIN #session.hostdbprefix#videos_text vt ON vt.vid_id_r = v.vid_id AND vt.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
						LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = v.folder_id_r AND v.host_id = fo.host_id
						WHERE v.vid_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							<cfif arguments.thestruct.searchtext EQ "">WHERE<cfelse>AND</cfif> v.vid_create_date = TO_DATE('#arguments.thestruct.on_month#/#arguments.thestruct.on_day#/#arguments.thestruct.on_year# 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images --->
						AND (v.vid_group IS NULL OR v.vid_group = '')
						AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						GROUP BY vid_id, vid_filename, v.folder_id_r, vid_custom_id, vid_online, vid_owner, vid_create_date,
						vid_change_date, vid_width, vid_height, folder_name, folder_of_user, folder_owner, vid_name_image, 
						vt.vid_keywords, vt.vid_description
						ORDER BY vid_filename
						)
					WHERE ROWNUM <= <cfqueryparam value="#arguments.thestruct.rowmax#" cfsqltype="cf_sql_numeric">
					)
				WHERE rn > <cfqueryparam value="#arguments.thestruct.rowmin#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<!--- DB2 --->
			<cfelseif variables.database EQ "db2">
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT vid_id, vid_filename, folder_id_r, vid_custom_id, vid_online, vid_owner, vid_create_date, vid_change_date, vid_width, 
				vid_height, vid_name_image, folder_name, vid_title, vid_description, link_kind, link_path_url, path_to_asset, keywords,
				description, howmany, perm
				FROM (
					SELECT row_number() over() as rownr, v.vid_id, v.vid_filename, 
					v.folder_id_r, v.vid_custom_id, v.vid_online, v.vid_owner, v.vid_create_date, v.vid_change_date, v.vid_width, 
					v.vid_height, v.vid_name_image, fo.folder_name, vt.vid_title, vt.vid_description, v.link_kind, v.link_path_url,
					v.path_to_asset, vt.vid_keywords keywords, vt.vid_description description,
						(
						SELECT COUNT(vid_id)
						FROM #session.hostdbprefix#videos
						WHERE vid_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND vid_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images --->
						AND (vid_group IS NULL OR vid_group = '')
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						) AS howmany,
						<!--- Check if this folder belongs to a user and lock/unlock --->
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
					FROM #session.hostdbprefix#videos v
					LEFT JOIN #session.hostdbprefix#videos_text vt ON vt.vid_id_r = v.vid_id AND vt.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
					LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = v.folder_id_r AND v.host_id = fo.host_id
					WHERE v.vid_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND v.vid_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					<!--- Exclude related images --->
					AND (v.vid_group IS NULL OR v.vid_group = '')
					AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					GROUP BY vid_id, vid_filename, v.folder_id_r, vid_custom_id, vid_online, vid_owner, vid_create_date,
					vid_change_date, vid_width, vid_height, vid_name_image, folder_name, vid_title, vid_description, 
					folder_of_user, folder_owner, vt.vid_keywords, vt.vid_description, link_kind, link_path_url, path_to_asset
					ORDER BY vid_filename
				)
				WHERE rownr BETWEEN #arguments.thestruct.rowmin# AND #arguments.thestruct.rowmax#
				</cfquery>
			<!--- OTHER DATABASES --->
			<cfelse>
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT <cfif variables.database EQ "mssql">TOP #arguments.thestruct.rowmax# </cfif>v.vid_id, v.vid_filename, v.cloud_url,
				v.folder_id_r, v.vid_custom_id, v.vid_online, v.vid_owner, v.vid_create_date, v.vid_change_date, v.vid_width, 
				v.vid_height, v.vid_name_image, fo.folder_name, vt.vid_title, vt.vid_description, v.link_kind, v.link_path_url,
				v.path_to_asset, vt.vid_keywords keywords, vt.vid_description description,
					(
					SELECT COUNT(vid_id)
					FROM #session.hostdbprefix#videos
					WHERE vid_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND vid_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					<!--- Exclude related images --->
					AND (vid_group IS NULL OR vid_group = '')
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					) AS howmany,
					<!--- Check if this folder belongs to a user and lock/unlock --->
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
						'unlocked' as perm
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
						END as perm
					</cfif>
				FROM #session.hostdbprefix#videos v
				LEFT JOIN #session.hostdbprefix#videos_text vt ON vt.vid_id_r = v.vid_id AND vt.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
				LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = v.folder_id_r AND v.host_id = fo.host_id
				WHERE v.vid_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
				<!--- Only if we have dates --->
				<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
					AND v.vid_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
				</cfif>
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				<!--- Exclude related images --->
				AND (v.vid_group IS NULL OR v.vid_group = '')
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<!--- MSSQL --->
				<cfif variables.database EQ "mssql">
					AND v.vid_id NOT IN (
						SELECT TOP #arguments.thestruct.rowmin# vid_id
						FROM #session.hostdbprefix#videos
						WHERE vid_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND vid_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						AND (vid_group IS NULL OR vid_group = '')
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
				</cfif>
				GROUP BY vid_id, vid_filename, v.folder_id_r, vid_custom_id, vid_online, vid_owner, vid_create_date,
				vid_change_date, vid_width, vid_height, vid_name_image, folder_name, vid_title, vid_description, 
				folder_of_user, folder_owner, vt.vid_keywords, vt.vid_description, link_kind, link_path_url, path_to_asset, cloud_url
				ORDER BY vid_filename
				<!--- MySQL / H2 --->
				<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
					LIMIT #arguments.thestruct.rowmin#,#arguments.thestruct.rowmax#
				</cfif>
				</cfquery>
			</cfif>
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qrymain
			WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
			</cfquery>
			<!--- Log Result --->
			<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='vid')#>
		<cfelse>
			<cfset qry = querynew("vid_id")>
		</cfif>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>
	
	<!--- SEARCH: AUDIOS --->
	<cffunction name="search_audios">
		<cfargument name="thestruct" type="struct">
		<!--- Default params --->
		<cfset var qry = 0>
		<cfparam default="10" name="arguments.thestruct.rowmax">
		<cfparam default="0" name="arguments.thestruct.rowmin">
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<!--- If search text is empty --->
		<cfif arguments.thestruct.searchtext EQ "">
			<cfset arguments.thestruct.searchtext = "">
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
			<!--- ORACLE --->
			<cfif variables.database EQ "oracle">
				<!--- Query --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT rn, aud_id, aud_name, folder_id_r, aud_online, aud_owner, aud_create_date, aud_change_date, aud_extension, 
				howmany, folder_name, link_kind, link_path_url, path_to_asset, cloud_url, keywords, description, perm
				FROM (
					SELECT ROWNUM AS rn, aud_id, aud_name, folder_id_r, aud_online, aud_owner,
					aud_create_date, aud_change_date, aud_extension, howmany, folder_name, link_kind, link_path_url, 
					path_to_asset, cloud_url, keywords, description, perm
					FROM (
						SELECT a.aud_id, a.aud_name, a.folder_id_r, a.aud_online,
						a.aud_owner, a.aud_create_date, a.aud_change_date, a.aud_extension, count(*) over() howmany,
						fo.folder_name, a.link_kind, a.link_path_url, a.path_to_asset, a.cloud_url, aut.aud_keywords keywords,
						aut.aud_description description,
						<!--- Check if this folder belongs to a user and lock/unlock --->
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
						FROM #session.hostdbprefix#audios a
						LEFT JOIN #session.hostdbprefix#audios_text aut ON aut.aud_id_r = a.aud_id AND aut.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
						LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = a.folder_id_r AND a.host_id = fo.host_id
						WHERE a.aud_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							<cfif arguments.thestruct.searchtext EQ "">WHERE<cfelse>AND</cfif> a.aud_create_date = TO_DATE('#arguments.thestruct.on_month#/#arguments.thestruct.on_day#/#arguments.thestruct.on_year# 00:00:00', 'MM/DD/YYYY HH24:MI:SS')
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images --->
						AND (a.aud_group IS NULL OR a.aud_group = '')
						AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						GROUP BY aud_id, aud_name, a.folder_id_r, aud_online, aud_owner, aud_create_date,
						aud_change_date, aud_extension, folder_name, folder_of_user, folder_owner
						ORDER BY aud_name
						)
					WHERE ROWNUM <= <cfqueryparam value="#arguments.thestruct.rowmax#" cfsqltype="cf_sql_numeric">
					)
				WHERE rn > <cfqueryparam value="#arguments.thestruct.rowmin#" cfsqltype="cf_sql_numeric">
				</cfquery>
			<!--- DB2 --->
			<cfelseif variables.database EQ "db2">
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT aud_id, aud_name, folder_id_r, aud_online, aud_owner, aud_create_date, aud_change_date, aud_extension, folder_name, 
				link_kind, link_path_url, path_to_asset, cloud_url, keywords, description, howmany, perm
				FROM (
					SELECT row_number() over() as rownr, a.aud_id, a.aud_name, a.folder_id_r, a.aud_online, a.aud_owner, a.aud_create_date,
					a.aud_change_date, a.aud_extension,
					fo.folder_name, a.link_kind, a.link_path_url, a.path_to_asset, a.cloud_url, aut.aud_keywords keywords, aut.aud_description description,
						(
						SELECT COUNT(aud_id)
						FROM #session.hostdbprefix#audios
						WHERE aud_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND aud_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images --->
						AND (aud_group IS NULL OR aud_group = '')
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						) AS howmany,
						<!--- Check if this folder belongs to a user and lock/unlock --->
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
							'unlocked' as perm
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
							END as perm
						</cfif>
					FROM #session.hostdbprefix#audios a
					LEFT JOIN #session.hostdbprefix#audios_text aut ON aut.aud_id_r = a.aud_id AND aut.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
					LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = a.folder_id_r AND a.host_id = fo.host_id
					WHERE a.aud_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND a.aud_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					<!--- Exclude related images --->
					AND (a.aud_group IS NULL OR a.aud_group = '')
					AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					GROUP BY aud_id, aud_name, a.folder_id_r, aud_online, aud_owner, aud_create_date, aud_change_date, aud_extension,
					folder_name, folder_of_user, folder_owner, aut.aud_keywords, aut.aud_description, link_kind, link_path_url,
					path_to_asset, cloud_url
					ORDER BY aud_name
				)
				WHERE rownr BETWEEN #arguments.thestruct.rowmin# AND #arguments.thestruct.rowmax#
				</cfquery>
			<!--- OTHER DATABASES --->
			<cfelse>
				<!--- Grab the result and query file db --->
				<cfquery datasource="#variables.dsn#" name="qrymain">
				SELECT <cfif variables.database EQ "mssql">TOP #arguments.thestruct.rowmax# </cfif>a.aud_id, a.aud_name, a.cloud_url,
				a.folder_id_r, a.aud_online, a.aud_owner, a.aud_create_date, a.aud_change_date, a.aud_extension, fo.folder_name, 
				a.link_kind, a.link_path_url, a.path_to_asset, aut.aud_keywords keywords, aut.aud_description description,
					(
					SELECT COUNT(aud_id)
					FROM #session.hostdbprefix#audios
					WHERE aud_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
					<!--- Only if we have dates --->
					<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
						AND aud_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					<!--- Exclude related images --->
					AND (aud_group IS NULL OR aud_group = '')
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					) AS howmany,
					<!--- Check if this folder belongs to a user and lock/unlock --->
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
						'unlocked' as perm
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
						END as perm
					</cfif>
				FROM #session.hostdbprefix#audios a
				LEFT JOIN #session.hostdbprefix#audios_text aut ON aut.aud_id_r = a.aud_id AND aut.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
				LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = a.folder_id_r AND a.host_id = fo.host_id
				WHERE a.aud_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
				<!--- Only if we have dates --->
				<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
					AND a.aud_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
				</cfif>
				<!--- Only if we have a folder id that is not 0 --->
				<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
					AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
				</cfif>
				<!--- Exclude related images --->
				AND (a.aud_group IS NULL OR a.aud_group = '')
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<!--- MSSQL --->
				<cfif variables.database EQ "mssql">
					AND a.aud_id NOT IN (
						SELECT TOP #arguments.thestruct.rowmin# aud_id
						FROM #session.hostdbprefix#audios
						WHERE aud_id IN (<cfif qrylucene.recordcount EQ 0 OR cattree.categorytree EQ "">'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattree.categorytree)#" list="Yes"></cfif>)
						<!--- Only if we have dates --->
						<cfif #arguments.thestruct.on_day# NEQ "" AND #arguments.thestruct.on_month# NEQ "" AND #arguments.thestruct.on_year# NEQ "">
							AND aud_create_date = '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#'
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						AND (aud_group IS NULL OR a.aud_group = '')
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
				</cfif>
				GROUP BY aud_id, aud_name, a.folder_id_r, aud_online, aud_owner, aud_create_date, aud_change_date, aud_extension,
				folder_name, folder_of_user, folder_owner, aut.aud_keywords, aut.aud_description, link_kind, link_path_url, cloud_url,
				path_to_asset
				ORDER BY aud_name
				<!--- MySQL / H2 --->
				<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
					LIMIT #arguments.thestruct.rowmin#,#arguments.thestruct.rowmax#
				</cfif>
				</cfquery>
			</cfif>
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qrymain
			WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
			</cfquery>
			<!--- Log Result --->
			<cfset log = #log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='aud')#>
		<cfelse>
			<cfset qry = querynew("aud_id")>
		</cfif>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>
	
	<!--- Search for suggestion --->
	<cffunction name="search_suggest" access="remote" output="false">
	<cfargument name="theterm" required="true">
		<!--- The function must return suggestions as an array. ---> 
		<cfset var myarray = ArrayNew(1)> 
		<!--- Get all unique last names that match the typed characters. ---> 
		<cfquery name="qry" datasource="#application.razuna.datasource#"> 
		SELECT img_filename
		FROM #session.hostdbprefix#images
		WHERE lower(img_filename) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.theterm)#%">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		GROUP BY img_filename
		</cfquery>
		<!--- Convert the query to an array. ---> 
		<cfloop query="qry"> 
			<cfset arrayAppend(myarray, img_filename)> 
		</cfloop>
		<cfset myarray = SerializeJSON(myarray)>
		<cfreturn myarray> 
	</cffunction> 


</cfcomponent>
