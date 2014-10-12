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
		<cfparam default="0" name="session.search.search_file_ids">
		
		<!--- Only applicable for files --->
		<cfparam default="" name="arguments.thestruct.doctype">
		<cfparam default="False" name="arguments.thestruct.avoidpagination">
		
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
			<cfset var sortby = "filename_forsort">
		<cfelseif session.sortby EQ "sizedesc">
			<cfset var sortby = "cast(size as decimal(12,0)) DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "cast(size as decimal(12,0)) ASC">
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
				<cfset var assetTypesArr = ["doc","img","aud","vid"]>
				<cfloop array="#assetTypesArr#" index="assetType">
					<!--- Filter data for assettype  --->
					<cfquery dbtype="query" name="qrylucene">
						select * from qryluceneAll where category = '#assetType#' 
					</cfquery>
					<cfset var catTreeArg = { 
						qrylucene = qrylucene, 
						iscol = arguments.thestruct.iscol,
						newsearch = arguments.thestruct.newsearch
					}>
					<cfif arguments.thestruct.iscol EQ "T">
						<cfset catTreeArg.listAsset = arguments.thestruct.qry['list#assetType#']>	
					</cfif>
					
					<!--- <cfif arguments.thestruct.newsearch EQ "F">	
						Do 'search within search' from previous saved search results
						<cfset catTreeArg.listAssetID = session.search.file_id>
					</cfif> --->
					<!--- <cfdump var="#catTreeArg.qrylucene#"><cfabort> --->
					<cfinvoke method="buildCategoryTree" thestruct="#catTreeArg#" returnvariable="cattreeStruct['#assetType#']">
				</cfloop>
				<!--- Save these search results in a session variable to be used for 'search within search' if needed next time--->
				<!--- <cfset session.search.file_id = valuelist(qryluceneAll.categorytree) > --->

				<!--- <cfdump var="#cattreeStruct#"><cfabort> --->

				<cfif cattreeStruct['img'].recordcount GT 0 or cattreeStruct['aud'].recordcount GT 0 or cattreeStruct['vid'].recordcount GT 0 or cattreeStruct['doc'].recordcount GT 0>
					<cfset var proceedToSQL = 1>
				<cfelse>
					<cfset var proceedToSQL = 0>
				</cfif>
			<cfelse>
				<!--- <cfset session.search.file_id = "0"> --->
				<cfset var proceedToSQL = 0>
			</cfif>	
		<cfelse>
			<cfinvoke component="lucene" method="search" criteria="#arguments.thestruct.searchtext#" category="#arguments.thestruct.thetype#" hostid="#session.hostid#" returnvariable="qrylucene">
			
			<cfset var catTreeArg = { qrylucene = qrylucene, 
									iscol = arguments.thestruct.iscol,
									newsearch = arguments.thestruct.newsearch
								}>
			<cfif arguments.thestruct.iscol EQ "T">
				<cfset catTreeArg.listAsset = arguments.thestruct.qry['list#arguments.thestruct.thetype#']>	
			</cfif>
			
			<!--- <cfif arguments.thestruct.newsearch EQ "F">					
				<cfset catTreeArg.listAssetID = session.search.file_id>
			</cfif>
			<cfif qrylucene.recordcount NEQ "0">
				<cfset session.search.file_id = valuelist(qrylucene.categorytree) >
			<cfelse>
				<cfset session.search.file_id = "0">
			</cfif> --->
			<cfinvoke method="buildCategoryTree" thestruct="#catTreeArg#" returnvariable="cattreeStruct['#arguments.thestruct.thetype#']">
			
			<cfset var proceedToSQL = cattreeStruct['#arguments.thestruct.thetype#'].recordcount>
			
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
				<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
					<cfif application.razuna.thedatabase EQ "mssql">
					with myresult as (
						SELECT ROW_NUMBER() OVER ( ORDER BY #sortby# ) AS RowNum,sorted_inline_view.*   FROM (
					</cfif>
				<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
					<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 1>
						SELECT COUNT(t.id) AS individualCount,kind FROM (
					<cfelse>		
						SELECT  * FROM (
					</cfif>
				</cfif>
				<cfset var unionEnabled = 0>
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "img") and  cattreeStruct['img'].recordcount NEQ 0>
				<cfset unionEnabled = 1>
				<cfset var cattree = cattreeStruct['img']>
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
					i.img_width width, i.img_height height, x.xres xres, x.yres yres, x.colorspace colorspace, CASE WHEN NOT (i.img_group is null OR i.img_group='') THEN (SELECT expiry_date FROM #session.hostdbprefix#images WHERE img_id=i.img_group) ELSE i.expiry_date END  expiry_date_actual,
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
							WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
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
							<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">i
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
					<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
					AND CASE 
					<!--- Check if admin user --->
					WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
					<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
					WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
					<!--- If rendition then look at expiry_date for original asset --->
					WHEN NOT (i.img_group is null OR i.img_group='')
					 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #session.hostdbprefix#images WHERE img_id = i.img_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
					ELSE 1 END  = 1

			    	<cfset q_start = q_end + 1>
			    	<cfset q_end = q_end + sqlInCluseLimit>
			    </cfloop>
				    GROUP BY i.img_id, i.img_filename, i.folder_id_r, i.thumb_extension, i.img_filename_org, i.is_available, i.img_create_time, i.img_change_date, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description, it.img_keywords, i.img_size, i.img_width, i.img_height, x.xres, x.yres, x.colorspace, i.hashtag, fo.folder_name, i.img_group, fo.folder_of_user, fo.folder_owner, i.in_trash, i.img_upc_number, i.expiry_date
				
				</cfif> <!--- Image search end here --->
				
				<!--- Documents search start here--->
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "doc") and  cattreeStruct['doc'].recordcount neq 0 >
					
					<cfif arguments.thestruct.thetype EQ "all" and unionEnabled eq 1>
						UNION ALL
					</cfif>
					<cfset var unionEnabled = 1>
					<cfset var cattree = cattreeStruct['doc']>
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
						'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace,f.expiry_date expiry_date_actual,
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
								WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
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
								<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number">f
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
						<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
						AND CASE 
						<!--- Check if admin user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
						<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
						ELSE 1 END  = 1
						<cfset q_start = q_end + 1>
				    	<cfset q_end = q_end + sqlInCluseLimit>
				    </cfloop>
			    	GROUP BY f.file_id, f.file_name, f.folder_id_r, f.file_extension, f.file_name_org, f.file_type, f.is_available, f.file_create_time, f.file_change_date, f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url_org, fd.file_desc, fd.file_keywords, f.file_name, f.file_size, f.hashtag, fo.folder_name, fo.folder_of_user, fo.folder_owner, f.in_trash, f.file_upc_number, f.expiry_date
				</cfif><!--- Document search end here --->
				
				
				
				<!--- Videos search start here --->
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "vid") and  cattreeStruct['vid'].recordcount neq 0 >
					
					<cfif arguments.thestruct.thetype EQ "all" and unionEnabled eq 1>
						UNION ALL
					</cfif>
					<cfset var unionEnabled = 1>
					<cfset var cattree = cattreeStruct['vid']>
					
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
						'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace, CASE WHEN NOT (v.vid_group is null OR v.vid_group='') THEN (SELECT expiry_date FROM #session.hostdbprefix#videos WHERE vid_id=v.vid_group) ELSE v.expiry_date END  expiry_date_actual,
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
								WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
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
						<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
						AND CASE 
						<!--- Check if admin user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
						<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
						<!--- If rendition then look at expiry_date for original asset --->
						WHEN NOT (v.vid_group is null OR v.vid_group='')
						 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #session.hostdbprefix#videos WHERE vid_id = v.vid_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
						ELSE 1 END  = 1
						<cfset q_start = q_end + 1>
				    	<cfset q_end = q_end + sqlInCluseLimit>
				    </cfloop>
				    GROUP BY v.vid_id, v.vid_filename, v.folder_id_r, v.vid_extension, v.vid_name_image, v.is_available, v.vid_create_time, v.vid_change_date, v.link_kind, v.link_path_url, v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description, vt.vid_keywords, v.vid_width, v.vid_height, v.vid_size, v.hashtag, fo.folder_name, v.vid_group, fo.folder_of_user, fo.folder_owner, v.in_trash, v.vid_upc_number, v.expiry_date
				</cfif><!--- Video search end here --->
				
				<!--- Audio search start here --->
				<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "aud") and  cattreeStruct['aud'].recordcount neq 0 >
					
					<cfif arguments.thestruct.thetype EQ "all" and unionEnabled eq 1>
						UNION ALL
					</cfif>
					<cfset var unionEnabled = 1>
					<cfset var cattree = cattreeStruct['aud']>
					
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
						'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace,CASE WHEN NOT (a.aud_group is null OR a.aud_group='') THEN (SELECT expiry_date FROM #session.hostdbprefix#audios WHERE aud_id=a.aud_group) ELSE a.expiry_date END  expiry_date_actual,
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
								WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
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
						<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
						AND CASE 
						<!--- Check if admin user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
						<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
						<!--- If rendition then look at expiry_date for original asset --->
						WHEN NOT (a.aud_group is null OR a.aud_group='')
						 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #session.hostdbprefix#audios WHERE aud_id = a.aud_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
						ELSE 1 END  = 1
						<cfset q_start = q_end + 1>
				    	<cfset q_end = q_end + sqlInCluseLimit>
				    </cfloop>
				    GROUP BY a.aud_id, a.aud_name, a.folder_id_r, a.aud_extension, a.aud_name_org, a.is_available, a.aud_create_time, a.aud_change_date, a.link_kind, a.link_path_url, a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description, aut.aud_keywords, a.aud_size, a.hashtag, fo.folder_name, a.aud_group, fo.folder_of_user, fo.folder_owner, a.in_trash, a.aud_upc_number, a.expiry_date
				</cfif><!--- Audio search end here --->
				<!--- MySql OR H2 --->
				<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
					<!--- Order by does not work with H2 as it needs the proper column name --->
					<cfif application.razuna.thedatabase NEQ "h2">ORDER BY #sortby#</cfif>
					) as t 
					WHERE t.perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
						AND permfolder IS NOT NULL
					</cfif>
					AND kind IS NOT NULL
					<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 0>
						<cfif structKeyExists(arguments.thestruct,'avoidpagination') AND arguments.thestruct.avoidpagination EQ "False">
							LIMIT #mysqloffset#,#session.rowmaxpage#
						</cfif>
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
						WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
							<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
								AND permfolder IS NOT NULL
							</cfif>
							AND kind IS NOT NULL
							<cfif structKeyExists(arguments.thestruct,'avoidpagination') AND arguments.thestruct.avoidpagination EQ "False">
									AND RowNum >
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
				</cfif>
			</cfquery>
			
			<!--- Select only records that are unlocked --->
			<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
				<!---<cfquery datasource="#application.razuna.datasource#" name="qryCount">
					SELECT found_rows() as total
				</cfquery>--->
				<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 1>
					<cfquery dbtype="query" name="qryCount">
						SELECT sum(individualCount) as cnt from qry
					</cfquery>
					<cfset var newQuery = queryNew("cnt,img_cnt,doc_cnt,aud_cnt,vid_cnt,other_cnt","Integer,Integer,Integer,Integer,Integer,Integer")>
					<cfset queryAddRow(newQuery)>
					<cfset querySetCell(newQuery, "cnt", qryCount.cnt)>
					<cfoutput  query="qry" >
						<cfset querySetCell(newQuery, qry.kind&"_cnt", val(individualCount))>
					</cfoutput>
					<cfset qry = newQuery />
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
				<!--- Init var for new fileid --->
				<cfset var editids = "0,">
				<cfset var fileids = "">
				<!--- Get proper folderaccess --->
				<cfloop query="qry">
					<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#folder_id_r#"  />
					<!--- Add labels query --->
					<cfset QuerySetCell(qry, "permfolder", theaccess, currentRow)>
					<!--- Store only file_ids where folder access is not read-only --->
					<cfif theaccess NEQ "R" AND theaccess NEQ "n">
						<cfset editids = editids & listid & ",">
					</cfif>
					<cfset fileids = fileids & id & ",">
				</cfloop>
				<!--- Save the editable ids in a session --->
				<cfset session.search.edit_ids = editids>
				<!--- Save fileids into session --->
				<cfset session.search.search_file_ids = fileids>
				<!--- Log Result --->
				<cfset log_search(theuserid=session.theuserid,searchfor='#arguments.thestruct.searchtext#',foundtotal=qry.recordcount,searchfrom='img')>
			</cfif>
		<!--- Since no records have been found we create a empty query --->
		<cfelse>
			<!--- Save the editable ids in a session --->
			<cfset session.search.edit_ids = "0">
			<!--- Save fileids into session --->
			<cfset session.search.search_file_ids = "0">
			<!--- Var --->
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
				<cfif session.search.search_file_ids EQ 0 OR session.search.search_file_ids EQ ''>
					= <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
				<cfelse>
					IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.search.search_file_ids#" list="true">)
				</cfif>
				</cfquery>
			</cfif>
		<cfelse>
			<cfset var cattree = querynew("categorytree")>
		</cfif>
		
		<cfreturn cattree>
	</cffunction>	
	
	<!--- SEARCH: FILES --->
	<cffunction name="search_files">
		<cfargument name="thestruct" type="struct">
			<!--- Get the document results only.  --->
			<cfif !structKeyExists(arguments.thestruct,'search_upc')>
				<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
			<cfelse>
				<!--- UPC Search --->
				<cfinvoke method="search_upc" thestruct="#arguments.thestruct#" returnvariable="qry">
			</cfif>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: IMAGES --->
	<cffunction name="search_images">
		<cfargument name="thestruct" type="struct">
		<!--- Get the images results only.  --->
			<cfif !structKeyExists(arguments.thestruct,'search_upc')>
				<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
			<cfelse>
				<!--- UPC Search --->
				<cfinvoke method="search_upc" thestruct="#arguments.thestruct#" returnvariable="qry">
			</cfif>
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>

	<!--- SEARCH: VIDEOS --->
	<cffunction name="search_videos">
		<cfargument name="thestruct" type="struct">
		<!--- Get the video results only.  --->
			<cfif !structKeyExists(arguments.thestruct,'search_upc')>
				<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
			<cfelse>
				<!--- UPC Search --->
				<cfinvoke method="search_upc" thestruct="#arguments.thestruct#" returnvariable="qry">
			</cfif>	
		<!--- Return query --->
		<cfreturn qry>
	</cffunction>
	
	<!--- SEARCH: AUDIOS --->
	<cffunction name="search_audios">
		<cfargument name="thestruct" type="struct">
		<!--- Get the audio results only.  --->
			<cfif !structKeyExists(arguments.thestruct,'search_upc')>
				<cfinvoke method="search_all" thestruct="#arguments.thestruct#" returnvariable="qry">
			<cfelse>
				<!--- UPC Search --->
				<cfinvoke method="search_upc" thestruct="#arguments.thestruct#" returnvariable="qry">
			</cfif>	
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
		<cfset var qry = "">
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
	
	<!--- Combine searches for API --->
	<cffunction name="search_combine_api" access="Public" output="false">
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
			<cfset var sortby = "cast(size as decimal(12,0)) DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "cast(size as decimal(12,0)) ASC">
		<cfelseif session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		<cfelse>
			<cfset var sortby = "filename_forsort">
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
		<cfparam name="arguments.thestruct.cs" default="">
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
			<cfinvokeargument name="cs" value="#arguments.thestruct.cs#">
		</cfinvoke>
		<!--- Return --->
		<cfreturn qry_search>
	</cffunction> 

	<!--- RAZ-2820 Search UPC --->
	<cffunction name="search_upc" access="public" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<cfparam default="0" name="arguments.thestruct.folder_id">
		<cfparam default="F" name="arguments.thestruct.iscol">
		<cfparam name="session.search.edit_ids" default = "0">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("search")>
		<cfset variables.cachetokenlogs = getcachetoken("logs")>
		<!--- Only applicable for files --->
		<cfparam default="" name="arguments.thestruct.doctype">
		<cfparam default="False" name="arguments.thestruct.avoidpagination">
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
			<cfset var sortby = "filename_forsort">
		<cfelseif session.sortby EQ "sizedesc">
			<cfset var sortby = "cast(size as decimal(12,0)) DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "cast(size as decimal(12,0)) ASC">
		<cfelseif session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		</cfif>
		<cfset var qry = "">
			<!--- MySQL Offset --->
			<cfset var mysqloffset = session.offset * session.rowmaxpage>
				<cfquery datasource="#application.razuna.datasource#" name="qry" cachedWithin="1" region="razcache">
					<cfif application.razuna.thedatabase EQ "mssql">
					with myresult as (
						SELECT ROW_NUMBER() OVER ( ORDER BY #sortby# ) AS RowNum,sorted_inline_view.*   FROM (
					</cfif>
				<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
					<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 1>
						SELECT COUNT(t.id) AS individualCount,kind FROM (
					<cfelse>		
						SELECT  * FROM (
					</cfif>
				</cfif>
					<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "img")>
					SELECT /* #variables.cachetoken#search_upc_images */i.img_id id, i.img_filename filename, i.folder_id_r, i.img_group groupid,
					i.thumb_extension ext, i.img_filename_org filename_org,'img' AS kind, i.is_available,
					i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
					i.path_to_asset,i.cloud_url, i.cloud_url_org, i.in_trash, it.img_description description, it.img_keywords keywords, 
					'0' AS vwidth, '0' AS vheight, 
					( 
					SELECT so.asset_format 
					FROM raz1_share_options so 
					WHERE i.img_id = so.group_asset_id 
					AND so.folder_id_r = i.folder_id_r 
					AND so.asset_type = 'img' 
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					) AS theformat, 
					LOWER(i.img_filename) 
					filename_forsort, 
					i.img_size size, 
					i.hashtag,
					fo.folder_name, 
					'' AS labels, 
					i.img_width width, i.img_height height, x.xres xres, x.yres yres, x.colorspace colorspace, CASE WHEN NOT (i.img_group is null OR i.img_group='') THEN (SELECT expiry_date FROM #session.hostdbprefix#images WHERE img_id=i.img_group) ELSE i.expiry_date END  expiry_date_actual,
					<!--- Check if this folder belongs to a user and lock/unlock --->
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
						'unlocked' AS perm, 
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
							WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
							ELSE 'locked'
						END as perm,
					</cfif>	
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser() AND session.customaccess EQ "">
						'X' AS permfolder 
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
							<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">i
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
					WHERE i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F"> 
					AND (
						<cfset var upcListLen = listlen(arguments.thestruct.search_upc)>
						<cfset var currentListPos = 1> 
					<cfloop list="#arguments.thestruct.search_upc#" index="single_upc_string">
						i.img_filename LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
						OR 
						i.img_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" > 

						<cfif currentListPos neq upcListLen> OR </cfif>
						<cfset currentListPos = currentListPos+1> 
					</cfloop>
					)
					 <!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
					AND CASE 
					<!--- Check if admin user --->
					WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
					<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
					WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
					<!--- If rendition then look at expiry_date for original asset --->
					WHEN NOT (i.img_group is null OR i.img_group='')
					 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #session.hostdbprefix#images WHERE img_id = i.img_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
					ELSE 1 END  = 1
					GROUP BY i.img_id, i.img_filename, i.folder_id_r, i.thumb_extension, i.img_filename_org, i.is_available, i.img_create_time, i.img_change_date, i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description, it.img_keywords, i.img_size, i.img_width, i.img_height, x.xres, x.yres, x.colorspace, i.hashtag, fo.folder_name, i.img_group, fo.folder_of_user, fo.folder_owner, i.in_trash, i.img_upc_number, i.expiry_date
					</cfif><!--- Images Search end here --->
						
					<!--- Document Search start here --->
					<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "doc")>
						<cfif arguments.thestruct.thetype EQ "all"> 
							UNION ALL
						</cfif> 
					SELECT /* #variables.cachetoken#search_upc_files */ f.file_id id, f.file_name filename, f.folder_id_r, '' AS groupid,
					f.file_extension ext, f.file_name_org filename_org, f.file_type AS kind,f.is_available, 
					f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url, 
					f.path_to_asset, f.cloud_url,f.cloud_url_org, f.in_trash, fd.file_desc description, fd.file_keywords keywords, 
					'0' AS vwidth, '0' AS vheight, '0' AS theformat,LOWER(f.file_name) filename_forsort, f.file_size size, f.hashtag, 
					fo.folder_name, 
					'' AS labels, 
					'0' AS width, '0' AS height, '' AS xres, '' AS yres,'' AS colorspace, f.expiry_date expiry_date_actual,
					<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
					'unlocked' AS perm,
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
								WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
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
								<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number">f
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
						WHERE f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F"> 
						AND (
							<cfset var upcListLen = listlen(arguments.thestruct.search_upc)>
							<cfset var currentListPos = 1> 
						<cfloop list="#arguments.thestruct.search_upc#" index="single_upc_string">
							f.file_name LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
							OR 
							f.file_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" > 

							<cfif currentListPos neq upcListLen> OR </cfif>
							<cfset currentListPos = currentListPos+1> 
						</cfloop>
						)
						<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
						AND CASE 
						<!--- Check if admin user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
						<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
						ELSE 1 END  = 1
						GROUP BY f.file_id, f.file_name, f.folder_id_r, f.file_extension, f.file_name_org, f.file_type, f.is_available, f.file_create_time, f.file_change_date, f.link_kind, f.link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url_org, fd.file_desc, fd.file_keywords, f.file_name, f.file_size, f.hashtag, fo.folder_name, fo.folder_of_user, fo.folder_owner, f.in_trash, f.file_upc_number, f.expiry_date
					</cfif><!--- Docs search end here --->
						
					<!--- Video search start here --->
					<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "vid")>
						<cfif arguments.thestruct.thetype EQ "all"> 
							UNION ALL
						</cfif> 
						SELECT /* #variables.cachetoken#search_upc_files */ v.vid_id id, v.vid_filename filename, v.folder_id_r, v.vid_group groupid, 
						v.vid_extension ext, v.vid_name_image filename_org,'vid' AS kind, v.is_available, 
						v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url, 
						v.path_to_asset,v.cloud_url, v.cloud_url_org, v.in_trash, vt.vid_description description, vt.vid_keywords keywords, CAST(v.vid_width AS CHAR) AS vwidth,CAST(v.vid_height AS CHAR) AS vheight,
						(
						SELECT so.asset_format
							FROM #session.hostdbprefix#share_options so
							WHERE v.vid_id = so.group_asset_id
							AND so.folder_id_r = v.folder_id_r
							AND so.asset_type = 'vid'
							AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1"> 
						 ) AS theformat,
						 LOWER(v.vid_filename) filename_forsort, 
						 v.vid_size size, v.hashtag, 
						 fo.folder_name, 
						 '' AS labels, '0' AS width, '0' AS height, '' AS xres, '' AS yres, '' AS colorspace, CASE WHEN NOT (v.vid_group is null OR v.vid_group='') THEN (SELECT expiry_date FROM #session.hostdbprefix#videos WHERE vid_id=v.vid_group) ELSE v.expiry_date END  expiry_date_actual,
						 <!--- Check if this folder belongs to a user and lock/unlock --->
						<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()> 
							'unlocked' AS perm,
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
								WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
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
						WHERE v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
						AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F"> 

						AND (
							<cfset var upcListLen = listlen(arguments.thestruct.search_upc)>
							<cfset var currentListPos = 1> 
						<cfloop list="#arguments.thestruct.search_upc#" index="single_upc_string">
							v.vid_filename LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
							OR 
							v.vid_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" > 

							<cfif currentListPos neq upcListLen> OR </cfif>
							<cfset currentListPos = currentListPos+1> 
						</cfloop>
						)
						<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
						AND CASE 
						<!--- Check if admin user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
						<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
						<!--- If rendition then look at expiry_date for original asset --->
						WHEN NOT (v.vid_group is null OR v.vid_group='')
						 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #session.hostdbprefix#videos WHERE vid_id = v.vid_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
						ELSE 1 END  = 1

						GROUP BY v.vid_id, v.vid_filename, v.folder_id_r, v.vid_extension, v.vid_name_image, v.is_available, v.vid_create_time, v.vid_change_date, v.link_kind, v.link_path_url, v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description, vt.vid_keywords, v.vid_width, v.vid_height, v.vid_size, v.hashtag, fo.folder_name, v.vid_group, fo.folder_of_user, fo.folder_owner, v.in_trash, v.vid_upc_number, v.expiry_date
						</cfif><!--- Video search end here --->
						
						<!--- Audio Search Start here --->
						<cfif (arguments.thestruct.thetype EQ "all" or arguments.thestruct.thetype EQ "aud")>
							<cfif arguments.thestruct.thetype EQ "all"> 
								UNION ALL
							</cfif> 
						SELECT /* #variables.cachetoken#search_upc_audios */ a.aud_id id, a.aud_name filename, a.folder_id_r, a.aud_group groupid, 
						a.aud_extension ext, a.aud_name_org filename_org, 'aud' AS kind,a.is_available, 
						a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url, 
						a.path_to_asset, a.cloud_url,a.cloud_url_org, a.in_trash, aut.aud_description description, aut.aud_keywords keywords,'0' AS vwidth, '0' AS vheight, 
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
						'0' as width, '0' as height, '' as xres, '' as yres, '' as colorspace, CASE WHEN NOT (a.aud_group is null OR a.aud_group='') THEN (SELECT expiry_date FROM #session.hostdbprefix#audios WHERE aud_id=a.aud_group) ELSE a.expiry_date END  expiry_date_actual,
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
								WHEN fo.folder_owner = '#session.theuserid#' THEN 'unlocked'
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
						WHERE  a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
						AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F"> 
						
						AND (
							<cfset var upcListLen = listlen(arguments.thestruct.search_upc)>
							<cfset var currentListPos = 1> 
						<cfloop list="#arguments.thestruct.search_upc#" index="single_upc_string">
							a.aud_name LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" >
							OR 
							a.aud_upc_number LIKE <cfqueryparam value="%#single_upc_string#%" cfsqltype="cf_sql_varchar" > 

							<cfif currentListPos neq upcListLen> OR </cfif>
							<cfset currentListPos = currentListPos+1> 
						</cfloop>
						)
						<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
						AND CASE 
						<!--- Check if admin user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
						<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
						WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('W','X') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
						<!--- If rendition then look at expiry_date for original asset --->
						WHEN NOT (a.aud_group is null OR a.aud_group='')
						 THEN CASE WHEN  EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('W','X') AND (SELECT expiry_date FROM  #session.hostdbprefix#audios WHERE aud_id = a.aud_group) < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0 ELSE 1 END
						ELSE 1 END  = 1
						GROUP BY a.aud_id, a.aud_name, a.folder_id_r, a.aud_extension, a.aud_name_org, a.is_available, a.aud_create_time, a.aud_change_date, a.link_kind, a.link_path_url, a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description, aut.aud_keywords, a.aud_size, a.hashtag, fo.folder_name, a.aud_group, fo.folder_of_user, fo.folder_owner, a.in_trash, a.aud_upc_number, a.expiry_date
						</cfif>
						<!--- Audio search end here --->
						<!--- MySql OR H2 --->
						<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
							<!--- Order by does not work with H2 as it needs the proper column name --->
							<cfif application.razuna.thedatabase NEQ "h2">ORDER BY #sortby#</cfif>
							) as t 
					WHERE t.perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
					<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
						AND permfolder IS NOT NULL
					</cfif>
					AND kind IS NOT NULL
					<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 0>
						<cfif structKeyExists(arguments.thestruct,'avoidpagination') AND arguments.thestruct.avoidpagination EQ "False">
							LIMIT #mysqloffset#,#session.rowmaxpage#
						</cfif>
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
					    	WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
							<cfif arguments.thestruct.folder_id EQ 0 AND arguments.thestruct.iscol EQ "F">
								AND permfolder IS NOT NULL
							</cfif>
							AND kind IS NOT NULL
							<cfif structKeyExists(arguments.thestruct,'avoidpagination') AND arguments.thestruct.avoidpagination EQ "False">
									AND RowNum >
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
						</cfif>
				</cfquery>
					<!--- Select only records that are unlocked --->
					<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
						<!---<cfquery datasource="#application.razuna.datasource#" name="qryCount">
							SELECT found_rows() as total
						</cfquery>--->
						<cfif structKeyExists(arguments.thestruct,'isCountOnly') AND arguments.thestruct.isCountOnly EQ 1>
							<cfquery dbtype="query" name="qryCount">
								SELECT sum(individualCount) as cnt from qry
							</cfquery>
							<cfset var newQuery = queryNew("cnt,img_cnt,doc_cnt,aud_cnt,vid_cnt,other_cnt","Integer,Integer,Integer,Integer,Integer,Integer")>
							<cfset queryAddRow(newQuery)>
							<cfset querySetCell(newQuery, "cnt", qryCount.cnt)>
							<cfoutput  query="qry" >
								<cfset querySetCell(newQuery, qry.kind&"_cnt", val(individualCount))>
							</cfoutput>
							<cfset qry =newQuery/>
						</cfif>
					</cfif>
			<!--- Qry Return --->
				<cfreturn qry>	
	</cffunction>
	
	<cffunction name="search_combine_upc">
		<cfargument name="thestruct" type="struct">
		<!--- Get the all asset results.  --->
			<cfinvoke method="search_upc" thestruct="#arguments.thestruct#" returnvariable="qry">
			<!--- Set the session for offset correctly if the total count of assets in lower then the total rowmaxpage --->
			<cfif structKeyExists(qry,'cnt') AND qry.cnt LTE session.rowmaxpage>
				<cfset session.offset = 0>
			</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
</cfcomponent>
