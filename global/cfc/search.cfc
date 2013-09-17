<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.

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
	
	<cffunction name="search_all">
		<cfargument name="thestruct" type="struct">
		
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("search")>
		<cfset variables.cachetokenlogs = getcachetoken("logs")>
		<!--- Default params --->
		<cfset var qry = 0>
		<cfset var qrylucene = "">
		<cfset var qrymain = "">
		<cfparam default="" name="arguments.thestruct.on_day">
		<cfparam default="" name="arguments.thestruct.on_month">
		<cfparam default="" name="arguments.thestruct.on_year">
		<cfparam default="" name="arguments.thestruct.change_day">
		<cfparam default="" name="arguments.thestruct.change_month">
		<cfparam default="" name="arguments.thestruct.change_year">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="t" name="arguments.thestruct.newsearch">
		<cfparam default="0" name="session.thegroupofuser">
		<cfparam default="0" name="session.customaccess">
		
		<!--- Only applicable for files --->
		<cfparam default="" name="arguments.thestruct.doctype">
		
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
		<cfset var sqlInCluseLimit = 990>
		<cfset var q_end = sqlInCluseLimit>
		<!--- Search in Lucene  --->
		<cfif arguments.thestruct.thetype EQ "all">
			<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="doc,vid,img,aud" hostid="#session.hostid#" returnvariable="qryluceneAll">
			<cfif qryluceneAll.recordcount NEQ "0">
				<cfset session.search.file_id = valuelist(qryluceneAll.categorytree) >
				<cfset var assetTypesArr = ["doc","img","aud","vid"]>
				<cfloop array="#assetTypesArr#" index="assetType">
					<cfquery dbtype="query" name="qrylucene">
						select * from qryluceneAll where category = '#assetType#' 
					</cfquery>
					<cfset var catTreeArg = { qrylucene = qrylucene, 
										iscol = arguments.thestruct.iscol,
										newsearch = arguments.thestruct.newsearch
									}>
					<cfif arguments.thestruct.iscol EQ "T">
						<cfset catTreeArg.listAsset = arguments.thestruct.qry['list#assetType#']>	
					</cfif>
					
					<cfif arguments.thestruct.newsearch EQ "F">	
						<cfset catTreeArg.listAssetID = session.search.file_id>
					</cfif>
					<cfinvoke method="buildCategoryTree" thestruct="#catTreeArg#" returnvariable="cattreeStruct['#assetType#']">
					
				</cfloop>
				<cfif cattreeStruct['img'].recordcount GT 0 or cattreeStruct['aud'].recordcount GT 0 or cattreeStruct['vid'].recordcount GT 0 or cattreeStruct['doc'].recordcount GT 0>
					<cfset proceedToSQL = 1>
				<cfelse>
					<cfset proceedToSQL = 0>
				</cfif>
			<cfelse>
				<cfset session.search.file_id = "0">
				<cfset proceedToSQL = 0>
			</cfif>	
		<cfelse>
			<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="#arguments.thestruct.thetype#" hostid="#session.hostid#" returnvariable="qrylucene">
			<cfif qrylucene.recordcount NEQ "0">
				<cfset session.search.file_id = valuelist(qrylucene.categorytree) >
			<cfelse>
				<cfset session.search.file_id = "0">
			</cfif>
			<cfset var catTreeArg = { qrylucene = qrylucene, 
									iscol = arguments.thestruct.iscol,
									newsearch = arguments.thestruct.newsearch
								}>
			<cfif arguments.thestruct.iscol EQ "T">
				<cfset catTreeArg.listAsset = arguments.thestruct.qry['list#arguments.thestruct.thetype#']>	
			</cfif>
			
			<cfif arguments.thestruct.newsearch EQ "F">					
				<cfset catTreeArg.listAssetID = session.search.file_id>
			</cfif>	
			<cfinvoke method="buildCategoryTree" thestruct="#catTreeArg#" returnvariable="cattreeStruct['#arguments.thestruct.thetype#']">
			
			<cfset proceedToSQL = cattreeStruct['#arguments.thestruct.thetype#'].recordcount>
			
		</cfif>
		
		<!--- If the cattree is not empty --->
		<cfif proceedToSQL NEQ 0>
			
			
			<!--- MySQL Offset --->
			<cfset var mysqloffset = session.offset * session.rowmaxpage>
			
			<!---
			<cfset var min = session.offset * session.rowmaxpage>
			<cfset var max = (session.offset + 1) * session.rowmaxpage>
			<cfif application.razuna.thedatabase EQ "db2" and session.offset NEQ 0>
				<cfset var min = min + 1>
			</cfif>--->
			
			<!--- Grab the result and query file db --->
			<!---<cftransaction>--->
				<cfquery datasource="#application.razuna.datasource#" name="qry" >
				
				<cfif application.razuna.thedatabase EQ "mssql">
				with myresult as (
					SELECT ROW_NUMBER() OVER ( ORDER BY #sortby# ) AS RowNum,sorted_inline_view.*   FROM (
				</cfif>
				<cfif application.razuna.thedatabase EQ "mysql">
					<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 1>
						SELECT COUNT(t.id) AS individualCount,kind FROM (
					<cfelse>		
						SELECT  * FROM (
					</cfif>
				</cfif>
				<cfset unionEnabled = 0>
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "img") and  cattreeStruct['img'].recordcount NEQ 0>
				<cfset unionEnabled = 1>
				<cfset cattree = cattreeStruct['img']>	
				<!--- Get how many loop --->
				<cfset var howmanyloop = ceiling(cattree.recordcount / sqlInCluseLimit)>
				<!--- Set outer loop --->
				<cfset var pos_start = 1>
				<cfset var pos_end = howmanyloop>
				<!--- Set inner loop --->
				<cfset var q_start = 1>
			
				<cfloop from="#pos_start#" to="#pos_end#" index="i">
					<cfif q_start NEQ 1>
						UNION ALL
					</cfif>
					SELECT /* #variables.cachetoken#search_images */ i.img_id id, i.img_filename filename, i.folder_id_r, i.img_group groupid,
					i.thumb_extension ext, i.img_filename_org filename_org, 'img' as kind, i.is_available,
					i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
					i.path_to_asset, i.cloud_url, i.cloud_url_org, i.in_trash, it.img_description description, it.img_keywords keywords, 
					'0' as vwidth, '0' as vheight, 
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
					'' as labels,
					i.img_width width, i.img_height height, x.xres xres, x.yres yres, x.colorspace colorspace,
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
								AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
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
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser() AND session.customaccess EQ "">
						'X' as permfolder
					<cfelseif session.customaccess NEQ "">
						'#session.customaccess#' as permfolder
					<cfelse>
						'R' as permfolder
					</cfif>
					,
					<cfif application.razuna.thedatabase EQ "mssql">i.img_id + '-img'<cfelse>concat(i.img_id,'-img')</cfif> as listid
					<!--- custom metadata fields to show --->
					<cfif arguments.thestruct.cs.images_metadata NEQ "">
						<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
							,<cfif m CONTAINS "keywords" OR m CONTAINS "description">it
							<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename">i
							<cfelse>x
							</cfif>.#m#
						</cfloop>
					</cfif>
					<cfif arguments.thestruct.cs.videos_metadata NEQ "">
						<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
							,'' AS #listlast(m," ")#
						</cfloop>
					</cfif>
					<cfif arguments.thestruct.cs.files_metadata NEQ "">
						<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
							,'' AS #listlast(m," ")#
						</cfloop>
					</cfif>
					<cfif arguments.thestruct.cs.audios_metadata NEQ "">
						<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
							,'' AS #listlast(m," ")#
						</cfloop>
					</cfif>
					FROM #session.hostdbprefix#images i
					LEFT JOIN #session.hostdbprefix#xmp x ON i.img_id = x.id_r
					LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = i.folder_id_r AND i.host_id = fo.host_id
					LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
					WHERE i.img_id IN (<cfif cattree.categorytree EQ "">'0'<cfelse>'0'<cfloop query="cattree" startrow="#q_start#" endrow="#q_end#">,'#categorytree#'</cfloop></cfif>)
					<cfif arguments.thestruct.newsearch EQ 'F' AND ( (session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ '') OR (session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ '') )>
					AND i.img_id in (
						select img_id from #session.hostdbprefix#images where 1=1 
							<cfif session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ ''> 
								<cfif application.razuna.thedatabase EQ "mssql">
									AND (DATEPART(yy, i.img_create_time) = #session.search.on_year#
									AND DATEPART(mm, i.img_create_time) = #session.search.on_month#
									AND DATEPART(dd, i.img_create_time) = #session.search.on_day#)
								<cfelse>
									AND i.img_create_time LIKE '#session.search.on_year#-#session.search.on_month#-#session.search.on_day#%'
								</cfif>
							</cfif>
							<cfif session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ ''> 
								<cfif application.razuna.thedatabase EQ "mssql">
									AND (DATEPART(yy, i.img_change_time) = #session.search.change_year#
									AND DATEPART(mm, i.img_change_time) = #session.search.change_month#
									AND DATEPART(dd, i.img_change_time) = #session.search.change_day#)
								<cfelse>
									AND i.img_change_time LIKE '#session.search.change_year#-#session.search.change_month#-#session.search.change_day#%'
								</cfif>
							</cfif>
						
					) 
					</cfif>
					<!--- Only if we have dates --->
					<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
						<cfif application.razuna.thedatabase EQ "mssql">
							AND (DATEPART(yy, i.img_create_time) = #arguments.thestruct.on_year#
							AND DATEPART(mm, i.img_create_time) = #arguments.thestruct.on_month#
							AND DATEPART(dd, i.img_create_time) = #arguments.thestruct.on_day#)
						<cfelse>
							AND i.img_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
						</cfif>
					</cfif>
					<cfif arguments.thestruct.change_day NEQ "" AND arguments.thestruct.change_month NEQ "" AND arguments.thestruct.change_year NEQ "">
						<cfif application.razuna.thedatabase EQ "mssql">
							AND (DATEPART(yy, i.img_change_time) = #arguments.thestruct.change_year#
							AND DATEPART(mm, i.img_change_time) = #arguments.thestruct.change_month#
							AND DATEPART(dd, i.img_change_time) = #arguments.thestruct.change_day#)
						<cfelse>
							AND i.img_change_time LIKE '#arguments.thestruct.change_year#-#arguments.thestruct.change_month#-#arguments.thestruct.change_day#%'
						</cfif>
					</cfif>
					<!--- Only if we have a folder id that is not 0 --->
					<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
						AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
					</cfif>
					<!--- Exclude related images
					AND (i.img_group IS NULL OR i.img_group = '') --->
					AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			    	<cfset q_start = q_end + 1>
			    	<cfset q_end = q_end + sqlInCluseLimit>
			    </cfloop>
				    GROUP BY i.img_id, i.img_filename, i.folder_id_r, i.thumb_extension, i.img_filename_org, i.is_available, i.img_create_time, i.img_change_date, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description, it.img_keywords, i.img_filename, i.img_size, i.img_width, i.img_height, x.xres, x.yres, x.colorspace, i.hashtag, fo.folder_name, i.img_group, fo.folder_of_user, fo.folder_owner, i.in_trash
				
				</cfif> <!--- Image search end here --->
				
				<!--- Documents search start here--->
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "doc") and  cattreeStruct['doc'].recordcount neq 0 >
					
					<cfif arguments.thestruct.thetype EQ "all" and unionEnabled eq 1>
						UNION ALL
					</cfif>
					<cfset unionEnabled = 1>
					<cfset cattree = cattreeStruct['doc']>
					<!--- Get how many loop --->
					<cfset var howmanyloop = ceiling(cattree.recordcount / sqlInCluseLimit)>
					<!--- Set outer loop --->
					<cfset var pos_start = 1>
					<cfset var pos_end = howmanyloop>
					<!--- Set inner loop --->
					<cfset var q_start = 1>	
					
					<cfloop from="#pos_start#" to="#pos_end#" index="i">
						<cfif q_start NEQ 1>
							UNION ALL
						</cfif>
						SELECT /* #variables.cachetoken#search_files */ f.file_id id, f.file_name filename, f.folder_id_r, '' as groupid,
						f.file_extension ext, f.file_name_org filename_org, f.file_type as kind, f.is_available,
						f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url,
						f.path_to_asset, f.cloud_url, f.cloud_url_org, f.in_trash, fd.file_desc description, fd.file_keywords keywords, 
						'0' as vwidth, '0' as vheight, '0' as theformat, lower(f.file_name) filename_forsort, f.file_size size, f.hashtag, 
						fo.folder_name,
						'' as labels,
						'' as width, '' as height, '' as xres, '' as yres, '' as colorspace,
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
									AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
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
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser() AND session.customaccess EQ "">
							'X' as permfolder
						<cfelseif session.customaccess NEQ "">
							'#session.customaccess#' as permfolder
						<cfelse>
							'R' as permfolder
						</cfif>
						,
						<cfif application.razuna.thedatabase EQ "mssql">f.file_id + '-doc'<cfelse>concat(f.file_id,'-doc')</cfif> as listid
						<!--- custom metadata fields to show --->
						<cfif arguments.thestruct.cs.images_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.videos_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.files_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
								,<cfif m CONTAINS "keywords" OR m CONTAINS "description">fd
								<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename">f
								<cfelse>x
								</cfif>.#m#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.audios_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						FROM #session.hostdbprefix#files f
						LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = f.folder_id_r AND f.host_id = fo.host_id
						LEFT JOIN #session.hostdbprefix#files_desc fd ON f.file_id = fd.file_id_r AND fd.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
						LEFT JOIN #session.hostdbprefix#files_xmp x ON x.asset_id_r = f.file_id
						WHERE f.file_id IN (<cfif cattree.categorytree EQ "">'0'<cfelse>'0'<cfloop query="cattree" startrow="#q_start#" endrow="#q_end#">,'#categorytree#'</cfloop></cfif>)
						<cfif arguments.thestruct.newsearch EQ 'F' AND ( (session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ '') OR (session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ '') )>
						AND f.file_id in (
							select file_id from #session.hostdbprefix#files where 1=1 
								<cfif session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ ''> 
									<cfif application.razuna.thedatabase EQ "mssql">
										AND (DATEPART(yy, f.file_create_time) = #session.search.on_year#
										AND DATEPART(mm, f.file_create_time) = #session.search.on_month#
										AND DATEPART(dd, f.file_create_time) = #session.search.on_day#)
									<cfelse>
										AND f.file_create_time LIKE '#session.search.on_year#-#session.search.on_month#-#session.search.on_day#%'
									</cfif>
								</cfif>
								<cfif session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ ''> 
									<cfif application.razuna.thedatabase EQ "mssql">
										AND (DATEPART(yy, f.file_change_time) = #session.search.change_year#
										AND DATEPART(mm, f.file_change_time) = #session.search.change_month#
										AND DATEPART(dd, f.file_change_time) = #session.search.change_day#)
									<cfelse>
										AND f.file_change_time LIKE '#session.search.change_year#-#session.search.change_month#-#session.search.change_day#%'
									</cfif>
								</cfif>
							
						) 
						</cfif>
						<!--- Only if we have dates --->
						<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
							<cfif application.razuna.thedatabase EQ "mssql">
								AND (DATEPART(yy, f.file_create_time) = #arguments.thestruct.on_year#
								AND DATEPART(mm, f.file_create_time) = #arguments.thestruct.on_month#
								AND DATEPART(dd, f.file_create_time) = #arguments.thestruct.on_day#)
							<cfelse>
								AND f.file_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
							</cfif>
						</cfif>
						<cfif arguments.thestruct.change_day NEQ "" AND arguments.thestruct.change_month NEQ "" AND arguments.thestruct.change_year NEQ "">
							<cfif application.razuna.thedatabase EQ "mssql">
								AND (DATEPART(yy, f.file_change_time) = #arguments.thestruct.change_year#
								AND DATEPART(mm, f.file_change_time) = #arguments.thestruct.change_month#
								AND DATEPART(dd, f.file_change_time) = #arguments.thestruct.change_day#)
							<cfelse>
								AND f.file_change_time LIKE '#arguments.thestruct.change_year#-#arguments.thestruct.change_month#-#arguments.thestruct.change_day#%'
							</cfif>
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						<cfset q_start = q_end + 1>
				    	<cfset q_end = q_end + sqlInCluseLimit>
				    </cfloop>
			    	GROUP BY f.file_id, f.file_name, f.folder_id_r, f.file_extension, f.file_name_org, f.file_type, f.is_available, f.file_create_time, f.file_change_date, f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url_org, fd.file_desc, fd.file_keywords, f.file_name, f.file_size, f.hashtag, fo.folder_name, fo.folder_of_user, fo.folder_owner, f.in_trash
				</cfif><!--- Document search end here --->
				
				
				
				<!--- Videos search start here --->
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "vid") and  cattreeStruct['vid'].recordcount neq 0 >
					
					<cfif arguments.thestruct.thetype EQ "all" and unionEnabled eq 1>
						UNION ALL
					</cfif>
					<cfset unionEnabled = 1>
					<cfset cattree = cattreeStruct['vid']>
					
					<!--- Get how many loop --->
					<cfset var howmanyloop = ceiling(cattree.recordcount / sqlInCluseLimit)>
					<!--- Set outer loop --->
					<cfset var pos_start = 1>
					<cfset var pos_end = howmanyloop>
					<!--- Set inner loop --->
					<cfset var q_start = 1>	
						
					<cfloop from="#pos_start#" to="#pos_end#" index="i">
						<cfif q_start NEQ 1>
							UNION ALL
						</cfif>
						SELECT /* #variables.cachetoken#search_videos */ v.vid_id id, v.vid_filename filename, v.folder_id_r, v.vid_group groupid,
						v.vid_extension ext, v.vid_name_image filename_org, 'vid' as kind, v.is_available,
						v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url,
						v.path_to_asset, v.cloud_url, v.cloud_url_org, v.in_trash, vt.vid_description description, vt.vid_keywords keywords, CAST(v.vid_width AS CHAR) as vwidth, CAST(v.vid_height AS CHAR) as vheight,
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
						'' as labels,
						'' as width, '' as height, '' as xres, '' as yres, '' as colorspace,
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
									AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
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
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser() AND session.customaccess EQ "">
							'X' as permfolder
						<cfelseif session.customaccess NEQ "">
							'#session.customaccess#' as permfolder
						<cfelse>
							'R' as permfolder
						</cfif>
						,
						<cfif application.razuna.thedatabase EQ "mssql">v.vid_id + '-vid'<cfelse>concat(v.vid_id,'-vid')</cfif> as listid
						<!--- custom metadata fields to show --->
						<cfif arguments.thestruct.cs.images_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.videos_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
								,<cfif m CONTAINS "keywords" OR m CONTAINS "description">vt
								<cfelse>v
								</cfif>.#m#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.files_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.audios_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						FROM #session.hostdbprefix#videos v
						LEFT JOIN #session.hostdbprefix#videos_text vt ON vt.vid_id_r = v.vid_id AND vt.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
						LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = v.folder_id_r AND v.host_id = fo.host_id
						WHERE v.vid_id IN (<cfif  cattree.categorytree EQ "">'0'<cfelse>'0'<cfloop query="cattree" startrow="#q_start#" endrow="#q_end#">,'#categorytree#'</cfloop></cfif>)
						<cfif arguments.thestruct.newsearch EQ 'F' AND ( (session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ '') OR (session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ '') )>
						AND v.vid_id in (
							select vid_id from #session.hostdbprefix#videos where 1=1 
								<cfif session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ ''> 
									<cfif application.razuna.thedatabase EQ "mssql">
										AND (DATEPART(yy, v.vid_create_time) = #session.search.on_year#
										AND DATEPART(mm, v.vid_create_time) = #session.search.on_month#
										AND DATEPART(dd, v.vid_create_time) = #session.search.on_day#)
									<cfelse>
										AND v.vid_create_time LIKE '#session.search.on_year#-#session.search.on_month#-#session.search.on_day#%'
									</cfif>
								</cfif>
								<cfif session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ ''> 
									<cfif application.razuna.thedatabase EQ "mssql">
										AND (DATEPART(yy, v.vid_change_time) = #session.search.change_year#
										AND DATEPART(mm, v.vid_change_time) = #session.search.change_month#
										AND DATEPART(dd, v.vid_change_time) = #session.search.change_day#)
									<cfelse>
										AND v.vid_change_time LIKE '#session.search.change_year#-#session.search.change_month#-#session.search.change_day#%'
									</cfif>
								</cfif>
							
						) 
						</cfif>
						<!--- Only if we have dates --->
						<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
							<cfif application.razuna.thedatabase EQ "mssql">
								AND (DATEPART(yy, v.vid_create_time) = #arguments.thestruct.on_year#
								AND DATEPART(mm, v.vid_create_time) = #arguments.thestruct.on_month#
								AND DATEPART(dd, v.vid_create_time) = #arguments.thestruct.on_day#)
							<cfelse>
								AND v.vid_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
							</cfif>
						</cfif>
						<cfif arguments.thestruct.change_day NEQ "" AND arguments.thestruct.change_month NEQ "" AND arguments.thestruct.change_year NEQ "">
							<cfif application.razuna.thedatabase EQ "mssql">
								AND (DATEPART(yy, v.vid_change_time) = #arguments.thestruct.change_year#
								AND DATEPART(mm, v.vid_change_time) = #arguments.thestruct.change_month#
								AND DATEPART(dd, v.vid_change_time) = #arguments.thestruct.change_day#)
							<cfelse>
								AND v.vid_change_time LIKE '#arguments.thestruct.change_year#-#arguments.thestruct.change_month#-#arguments.thestruct.change_day#%'
							</cfif>
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images
						AND (v.vid_group IS NULL OR v.vid_group = '') --->
						AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
						<cfset q_start = q_end + 1>
				    	<cfset q_end = q_end + sqlInCluseLimit>
				    </cfloop>
				    GROUP BY v.vid_id, v.vid_filename, v.folder_id_r, v.vid_extension, v.vid_name_image, v.is_available, v.vid_create_time, v.vid_change_date, v.link_kind, v.link_path_url, v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description, vt.vid_keywords, v.vid_width, v.vid_height, v.vid_filename, v.vid_size, v.hashtag, fo.folder_name, v.vid_group, fo.folder_of_user, fo.folder_owner, v.in_trash
				</cfif><!--- Video search end here --->
				
				<!--- Audio search start here --->
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "aud") and  cattreeStruct['aud'].recordcount neq 0 >
					
					<cfif arguments.thestruct.thetype EQ "all" and unionEnabled eq 1>
						UNION ALL
					</cfif>
					<cfset unionEnabled = 1>
					<cfset cattree = cattreeStruct['aud']>
					
					<!--- Get how many loop --->
					<cfset var howmanyloop = ceiling(cattree.recordcount / sqlInCluseLimit)>
					<!--- Set outer loop --->
					<cfset var pos_start = 1>
					<cfset var pos_end = howmanyloop>
					<!--- Set inner loop --->
					<cfset var q_start = 1>	
						
					<cfloop from="#pos_start#" to="#pos_end#" index="i">
						<cfif q_start NEQ 1>
							UNION ALL
						</cfif>
						SELECT /* #variables.cachetoken#search_audios */ a.aud_id id, a.aud_name filename, a.folder_id_r, a.aud_group groupid,
						a.aud_extension ext, a.aud_name_org filename_org, 'aud' as kind, a.is_available,
						a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url,
						a.path_to_asset, a.cloud_url, a.cloud_url_org, a.in_trash, aut.aud_description description, aut.aud_keywords keywords, '0' as vwidth, '0' as vheight,
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
						'' as labels,
						'' as width, '' as height, '' as xres, '' as yres, '' as colorspace,
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
									AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
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
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser() AND session.customaccess EQ "">
							'X' as permfolder
						<cfelseif session.customaccess NEQ "">
							'#session.customaccess#' as permfolder
						<cfelse>
							'R' as permfolder
						</cfif>
						,
						<cfif application.razuna.thedatabase EQ "mssql">a.aud_id + '-aud'<cfelse>concat(a.aud_id,'-aud')</cfif> as listid
						<!--- custom metadata fields to show --->
						<cfif arguments.thestruct.cs.images_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.videos_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.files_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
								,'' AS #listlast(m," ")#
							</cfloop>
						</cfif>
						<cfif arguments.thestruct.cs.audios_metadata NEQ "">
							<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
								,<cfif m CONTAINS "keywords" OR m CONTAINS "description">aut
								<cfelse>a
								</cfif>.#m#
							</cfloop>
						</cfif>
						FROM #session.hostdbprefix#audios a
						LEFT JOIN #session.hostdbprefix#audios_text aut ON aut.aud_id_r = a.aud_id AND aut.lang_id_r = <cfqueryparam value="#session.thelangid#" cfsqltype="cf_sql_numeric">
						LEFT JOIN #session.hostdbprefix#folders fo ON fo.folder_id = a.folder_id_r AND a.host_id = fo.host_id
						WHERE a.aud_id IN (<cfif cattree.categorytree EQ "">'0'<cfelse>'0'<cfloop query="cattree" startrow="#q_start#" endrow="#q_end#">,'#categorytree#'</cfloop></cfif>)
						<cfif arguments.thestruct.newsearch EQ 'F' AND ( (session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ '') OR (session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ '') )>
						AND a.aud_id in (
							select aud_id from #session.hostdbprefix#audios where 1=1 
								<cfif session.search.on_year NEQ '' AND session.search.on_month NEQ '' AND session.search.on_day NEQ ''> 
									<cfif application.razuna.thedatabase EQ "mssql">
										AND (DATEPART(yy, a.aud_create_time) = #session.search.on_year#
										AND DATEPART(mm, a.aud_create_time) = #session.search.on_month#
										AND DATEPART(dd, a.aud_create_time) = #session.search.on_day#)
									<cfelse>
										AND a.aud_create_time LIKE '#session.search.on_year#-#session.search.on_month#-#session.search.on_day#%'
									</cfif>
								</cfif>
								<cfif session.search.change_year NEQ '' AND session.search.change_month NEQ '' AND session.search.change_day NEQ ''> 
									<cfif application.razuna.thedatabase EQ "mssql">
										AND (DATEPART(yy, a.aud_change_time) = #session.search.change_year#
										AND DATEPART(mm, a.aud_change_time) = #session.search.change_month#
										AND DATEPART(dd, a.aud_change_time) = #session.search.change_day#)
									<cfelse>
										AND a.aud_change_time LIKE '#session.search.change_year#-#session.search.change_month#-#session.search.change_day#%'
									</cfif>
								</cfif>
						) 
						</cfif>
						<!--- Only if we have dates --->
						<cfif arguments.thestruct.on_day NEQ "" AND arguments.thestruct.on_month NEQ "" AND arguments.thestruct.on_year NEQ "">
							<cfif application.razuna.thedatabase EQ "mssql">
								AND (DATEPART(yy, a.aud_create_time) = #arguments.thestruct.on_year#
								AND DATEPART(mm, a.aud_create_time) = #arguments.thestruct.on_month#
								AND DATEPART(dd, a.aud_create_time) = #arguments.thestruct.on_day#)
							<cfelse>
								AND a.aud_create_time LIKE '#arguments.thestruct.on_year#-#arguments.thestruct.on_month#-#arguments.thestruct.on_day#%'
							</cfif>
						</cfif>
						<cfif arguments.thestruct.change_day NEQ "" AND arguments.thestruct.change_month NEQ "" AND arguments.thestruct.change_year NEQ "">
							<cfif application.razuna.thedatabase EQ "mssql">
								AND (DATEPART(yy, a.aud_change_time) = #arguments.thestruct.change_year#
								AND DATEPART(mm, a.aud_change_time) = #arguments.thestruct.change_month#
								AND DATEPART(dd, a.aud_change_time) = #arguments.thestruct.change_day#)
							<cfelse>
								AND a.aud_change_time LIKE '#arguments.thestruct.change_year#-#arguments.thestruct.change_month#-#arguments.thestruct.change_day#%'
							</cfif>
						</cfif>
						<!--- Only if we have a folder id that is not 0 --->
						<cfif arguments.thestruct.folder_id NEQ 0 AND arguments.thestruct.iscol EQ "F">
							AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.list_recfolders#" list="yes">)
						</cfif>
						<!--- Exclude related images
						AND (a.aud_group IS NULL OR a.aud_group = '') --->
						AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
						<cfset q_start = q_end + 1>
				    	<cfset q_end = q_end + sqlInCluseLimit>
				    </cfloop>
				    GROUP BY a.aud_id, a.aud_name, a.folder_id_r, a.aud_extension, a.aud_name_org, a.is_available, a.aud_create_time, a.aud_change_date, a.link_kind, a.link_path_url, a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description, aut.aud_keywords, a.aud_name, a.aud_size, a.hashtag, fo.folder_name, a.aud_group, fo.folder_of_user, fo.folder_owner, a.in_trash
				</cfif><!--- Audio search end here --->
				<!--- MySql OR H2 --->
				<cfif application.razuna.thedatabase EQ "h2">
					LIMIT #mysqloffset#,#session.rowmaxpage#
				</cfif>
				<cfif application.razuna.thedatabase EQ "mysql">
					ORDER BY #sortby#
					) as t 
					WHERE t.perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
						AND permfolder IS NOT NULL
					</cfif>
					<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 0>
						LIMIT #mysqloffset#,#session.rowmaxpage#
					<cfelse>
						GROUP BY kind
					</cfif>
				</cfif>
				<cfif application.razuna.thedatabase EQ "mssql">
						) sorted_inline_view
						)select *,  
				    	(SELECT count(RowNum) FROM myresult) AS 'cnt',(SELECT count(kind) FROM myresult where kind='img') as img_cnt,
				    	(SELECT count(kind) FROM myresult where kind='doc') as doc_cnt,(SELECT count(kind) FROM myresult where kind='vid') as vid_cnt,
				    	(SELECT count(kind) FROM myresult where kind='aud') as aud_cnt,(SELECT count(kind) FROM myresult where kind='other') as other_cnt from myresult 
						WHERE 
						
						RowNum >
							CASE WHEN 
								(
									SELECT count(RowNum) FROM myresult 
									<cfif arguments.thestruct.thetype NEQ "all" >
										where kind='#arguments.thestruct.thetype#'
									</cfif>
								) > #mysqloffset#
								 
								THEN #mysqloffset#
								ELSE 0
								END
						AND 
						RowNum <= 
							CASE WHEN 
								(
									SELECT count(RowNum) FROM myresult 
									<cfif arguments.thestruct.thetype NEQ "all" >
										where kind='#arguments.thestruct.thetype#'
									</cfif>
								) > #mysqloffset#
								 
								THEN #mysqloffset+session.rowmaxpage#
								ELSE #session.rowmaxpage#
								END
						 
				</cfif>
			</cfquery>
			<!--- Select only records that are unlocked --->
			<cfif application.razuna.thedatabase EQ "mysql" >
				<!---<cfquery datasource="#application.razuna.datasource#" name="qryCount">
					SELECT found_rows() as total
				</cfquery>--->
				<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 1>
					<cfquery dbtype="query" name="qryCount">
						SELECT sum(individualCount) as cnt from qry
					</cfquery>
					<cfset newQuery = queryNew("cnt,img_cnt,doc_cnt,aud_cnt,vid_cnt,other_cnt","Integer,Integer,Integer,Integer,Integer,Integer")>
					<cfset queryAddRow(newQuery)>
					<cfset querySetCell(newQuery, "cnt", qryCount.cnt)>
					<cfoutput  query="qry" >
						<cfset querySetCell(newQuery, qry.kind&"_cnt", val(individualCount))>
					</cfoutput>
					<cfset qry =newQuery/>
				</cfif>
			</cfif>
		<!---</cftransaction>--->
		
			<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 0>
				<!--- Only get the labels if in the combinded view --->
				<cfif session.view EQ "combined">
					<!--- Get the cachetoken for here --->
					<cfset variables.cachetokenlabels = getcachetoken("labels")>
					<!--- Loop over files and get labels and add to qry --->
					<cfloop query="qry">
						<!--- Query labels --->
						<cfquery name="qry_l" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
						SELECT /* #variables.cachetokenlabels#getallassetslabels */ ct_label_id
						FROM ct_labels
						WHERE ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
						</cfquery>
						<!--- Add labels query --->
						<cfif qry_l.recordcount NEQ 0>
							<cfset QuerySetCell(qry, "labels", valueList(qry_l.ct_label_id), currentRow)>
						</cfif>
					</cfloop>
				</cfif>
				<!--- Get proper folderaccess --->
				<cfloop query="qry">
					<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#folder_id_r#"  />
					<!--- Add labels query --->
					<cfset QuerySetCell(qry, "permfolder", theaccess, currentRow)>
				</cfloop>
				<!--- Log Result --->
				<cfset log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='img')>
			</cfif>
		<!--- Since no records have been found we create a empty query --->
		<cfelse>
			<cfset var customlist = "">
			<!--- custom metadata fields to show --->
			<cfif arguments.thestruct.cs.images_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
					<cfset customlist = customlist & ", #listlast(m," ")#">
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.videos_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
					<cfset customlist = customlist & ", #listlast(m," ")#">
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.files_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
					<cfset customlist = customlist & ", #listlast(m," ")#">
				</cfloop>
			</cfif>
			<cfif arguments.thestruct.cs.audios_metadata NEQ "">
				<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
					<cfset customlist = customlist & ", #listlast(m," ")#">
				</cfloop>
			</cfif>
			<cfset qry = querynew("id, filename, folder_id_r, groupid, ext, filename_org, kind, is_available, date_create, date_change, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, in_trash, description, keywords, vwidth, vheight, theformat, filename_forsort, size, hashtag, folder_name, labels, width, height, xres, yres, colorspace, perm, permfolder, listid#customlist#, cnt")>
			<cfset queryaddrow(qry)>
			<cfset QuerySetCell(qry,"cnt",0)>
		</cfif>
		<!--- Return query --->
		<cfreturn qry>	
	</cffunction>		
	
	<cffunction name="buildCategoryTree" >
		<cfargument name="thestruct" type="Struct">
		<cfset var cattree = "">
		<!--- If lucene returns no records --->
		<cfif arguments.thestruct.qrylucene.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM arguments.thestruct.qrylucene
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
				<cfif arguments.thestruct.listAsset.recordcount EQ 0>
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.thestruct.listAsset.id)#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
			<!--- Search in a search --->
			<cfif arguments.thestruct.newsearch EQ "F">
				<cfquery dbtype="query" name="cattree">
				SELECT categorytree
				FROM cattree
				WHERE categorytree 
				<cfif arguments.thestruct.listAssetID EQ "">
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.listAssetID#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
		<cfelse>
			<cfset cattree = querynew("categorytree")>
		</cfif>
		
		<cfreturn cattree>
	</cffunction>	
	
	<!--- SEARCH: FILES --->
	<cffunction name="search_files">
		<cfargument name="thestruct" type="struct">
			<!--- Get the document results only.  --->
			<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: IMAGES --->
	<cffunction name="search_images">
		<cfargument name="thestruct" type="struct">
		<!--- Get the images results only.  --->
			<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: VIDEOS --->
	<cffunction name="search_videos">
		<cfargument name="thestruct" type="struct">
		<!--- Get the video results only.  --->
			<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>
	
	<!--- SEARCH: AUDIOS --->
	<cffunction name="search_audios">
		<cfargument name="thestruct" type="struct">
		<!--- Get the audio results only.  --->
			<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
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
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedWithin="1" region="razcache">
		SELECT /* #variables.cachetokenlogs#search */ log_search_for
		FROM #session.hostdbprefix#log_search
		WHERE lower(log_search_for) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.searchtext)#%">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND log_user = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
		AND log_founditems != 0
		GROUP BY log_search_for
		ORDER BY log_search_for
		</cfquery>
		<!--- Append --->
		<cfoutput query="qry" startrow="1" maxrows="10"> 
			<cfset arrayAppend(myarray, log_search_for)>
		</cfoutput>
		<cfoutput>#SerializeJSON(myarray)#</cfoutput>
		<cfreturn /> 
	</cffunction> 

	<!--- Combine searches (needed for new folder search) --->
	<cffunction name="search_combine" access="Public" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Get the all asset results.  --->
			<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
			<!--- Set the session for offset correctly if the total count of assets in lower then the total rowmaxpage --->
			<cfif structKeyExists(qry,'cnt') AND qry.cnt LTE session.rowmaxpage>
				<cfset session.offset = 0>
			</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction> 

	<!--- Call Search API --->
	<cffunction name="search_api" access="public" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfset var qry_search = structNew()>
		<!--- Set vars for API --->
		<cfset application.razuna.api.thedatabase = application.razuna.thedatabase>
		<cfset application.razuna.api.dsn = application.razuna.datasource>
		<cfset application.razuna.api.setid = application.razuna.setid>
		<cfset application.razuna.api.storage = application.razuna.storage>
		<!--- Params --->
		<cfparam name="arguments.thestruct.show" default="all">
		<cfparam name="arguments.thestruct.doctype" default="">
		<cfparam name="arguments.thestruct.datechange" default="">
		<cfparam name="arguments.thestruct.folderid" default="">
		<cfparam name="arguments.thestruct.datecreateparam" default="">
		<cfparam name="arguments.thestruct.datecreatestart" default="">
		<cfparam name="arguments.thestruct.datecreatestop" default="">
		<cfparam name="arguments.thestruct.datechangeparam" default="">
		<cfparam name="arguments.thestruct.datechangestart" default="">
		<cfparam name="arguments.thestruct.datechangestop" default="">
		<cfparam name="arguments.thestruct.sortby" default="name">
		<cfparam name="arguments.thestruct.ui" default="false">
		<!--- Fire of search --->
		<cfinvoke component="global.api2.search" method="searchassets" returnvariable="qry_search.qall">
			<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
			<cfinvokeargument name="searchfor" value="#arguments.thestruct.searchfor#">
			<cfinvokeargument name="show" value="#arguments.thestruct.show#">
			<cfinvokeargument name="doctype" value="#arguments.thestruct.doctype#">
			<cfinvokeargument name="datechange" value="#arguments.thestruct.datechange#">
			<cfinvokeargument name="folderid" value="#arguments.thestruct.folderid#">
			<cfinvokeargument name="datecreateparam" value="#arguments.thestruct.datecreateparam#">
			<cfinvokeargument name="datecreatestart" value="#arguments.thestruct.datecreatestart#">
			<cfinvokeargument name="datecreatestop" value="#arguments.thestruct.datecreatestop#">
			<cfinvokeargument name="datechangeparam" value="#arguments.thestruct.datechangeparam#">
			<cfinvokeargument name="datechangestart" value="#arguments.thestruct.datechangestart#">
			<cfinvokeargument name="datechangestop" value="#arguments.thestruct.datechangestop#">
			<cfinvokeargument name="sortby" value="#arguments.thestruct.sortby#">
			<cfinvokeargument name="ui" value="#arguments.thestruct.ui#">
		</cfinvoke>
		<!--- Return --->
		<cfreturn qry_search>
	</cffunction> 


</cfcomponent>
