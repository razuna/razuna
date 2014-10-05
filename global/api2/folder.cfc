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

<cfcomponent output="false" extends="authentication">
	
	<!--- Retrieve assets from a folder --->
	<cffunction name="getassets" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="folderid" type="string" required="true">
		<cfargument name="showsubfolders" type="any" required="false" default="false">
		<cfargument name="show" type="string" required="false" default="all">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for folder --->
			<cfset var folderaccess = checkFolderAccess(arguments.api_key, arguments.folderid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R"  OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Get Cachetoken --->
				<cfset var cachetokenvid = getcachetoken(arguments.api_key,"videos")>
				<cfset var cachetokenimg = getcachetoken(arguments.api_key,"images")>
				<cfset var cachetokenaud = getcachetoken(arguments.api_key,"audios")>
				<cfset var cachetokendoc = getcachetoken(arguments.api_key,"files")>
				<cfset var cachetoken = getcachetoken(arguments.api_key,"folders")>
				<!--- Param --->
				<cfset thestorage = "">
				<!--- If the folderid is empty then set it to 0 --->
				<cfif arguments.folderid EQ "">
					<cfset arguments.folderid = 0>
				</cfif>
				<!--- Show assets from subfolders or not --->
				<cfif arguments.showsubfolders>
					<cfset var thefolders= queryNew("")>
					<!--- Flush cache --->
					<cfset resetcachetoken(arguments.api_key,"folders")>
					<cfquery datasource="#application.razuna.api.dsn#" name="thefolders" cachedwithin="1" region="razcache">
					SELECT /* #cachetoken#getfolders */ folder_id
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders f
					LEFT JOIN  #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg ON f.folder_id = fg.folder_id_r AND f.host_id = fg.host_id
					WHERE f.folder_id != f.folder_id_r
					AND f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folderid#">
					AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					<!--- Check to ensure user has permissions for folder --->
					AND 
					(
						EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
						OR
						fg.grp_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
						OR
						fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">)
						OR 
						f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
					)
					</cfquery>
					<cfset thefolderlist = listappend(arguments.folderid, ValueList(thefolders.folder_id))>
				<cfelse>
					<cfset thefolderlist = arguments.folderid>
				</cfif>	
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
					<!--- Images --->
					<cfif arguments.show EQ "ALL" OR arguments.show EQ "img">
						SELECT  /* #cachetokenimg#getassetsfolder1 */
						i.img_id id, 
						i.img_filename filename, 
						i.folder_id_r folder_id, 
						i.img_extension extension, 
						'dummy' as video_image,
						i.img_filename_org filename_org, 
						'img' as kind, 
						i.thumb_extension extension_thumb, 
						<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar(100)), '0')</cfif> AS size, 
						i.img_width AS width,
						i.img_height AS height,
						it.img_description description, 
						it.img_keywords keywords,
						i.path_to_asset,
						i.cloud_url,
						i.cloud_url_org,
						i.img_create_time dateadd,
						i.img_change_time datechange,
						(
							SELECT 
								CASE 
									WHEN count(img_id) = 0 THEN 'false'
									ELSE 'true'
								END AS test
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#images isub
							WHERE isub.img_group = i.img_id
							AND isub.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						) as subassets,
						<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
							concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_thumb,
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/' + i.img_filename_org AS local_url_org,
							'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/' + 'thumb_' + i.img_id + '.' + i.thumb_extension AS local_url_thumb,
						</cfif>
						<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							(
								SELECT GROUP_CONCAT(DISTINCT ic.col_id_r ORDER BY ic.col_id_r SEPARATOR ',') AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ic
								WHERE ic.file_id_r = i.img_id
								AND ic.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							STUFF(
								(
									SELECT ', ' + ic.col_id_r
									FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ic
						         	WHERE ic.file_id_r = i.img_id
						         	AND ic.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						          	FOR XML PATH ('')
					          	)
					          	, 1, 1, ''
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "oracle">
							(
								SELECT wmsys.wm_concat(ic.col_id_r) AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ic
								WHERE ic.file_id_r = i.img_id
								AND ic.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						</cfif>
						,
						x.colorspace,
						x.xres AS xdpi,
						x.yres AS ydpi,
						x.resunit AS unit,
						i.hashtag AS md5hash
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i 
						LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
						LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
						WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
						AND (i.img_group IS NULL OR i.img_group = '')
						AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						AND i.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
						AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfif>
					<cfif arguments.show EQ "ALL">
						UNION ALL
					</cfif>
					<!--- Videos --->
					<cfif arguments.show EQ "ALL" OR arguments.show EQ "vid">
						SELECT /* #cachetokenvid#getassetsfolder2 */
						v.vid_id id, 
						v.vid_filename filename, 
						v.folder_id_r folder_id, 
						v.vid_extension extension, 
						v.vid_name_image as video_image,
						v.vid_name_org filename_org, 
						'vid' as kind, 
						v.vid_extension extension_thumb, 
						<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(v.vid_size as varchar(100)), '0')</cfif> AS size, 
						v.vid_width AS width,
						v.vid_height AS height,
						vt.vid_description description, 
						vt.vid_keywords keywords,
						v.path_to_asset,
						v.cloud_url,
						v.cloud_url_org,
						v.vid_create_time dateadd,
						v.vid_change_time datechange,
						(
							SELECT 
								CASE 
									WHEN count(vid_id) = 0 THEN 'false'
									ELSE 'true'
								END AS test
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos vsub
							WHERE vsub.vid_group = v.vid_id
							AND vsub.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						) as subassets,
						<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_org) AS local_url_org,
							concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_image) AS local_url_thumb,
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + v.path_to_asset + '/' + v.vid_name_org AS local_url_org,
							'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + v.path_to_asset + '/' + v.vid_name_image AS local_url_thumb,
						</cfif>
						<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							(
								SELECT GROUP_CONCAT(DISTINCT vc.col_id_r ORDER BY vc.col_id_r SEPARATOR ',') AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files vc
								WHERE vc.file_id_r = v.vid_id
								AND vc.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							STUFF(
								(
									SELECT ', ' + vc.col_id_r
									FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files vc
						         	WHERE vc.file_id_r = v.vid_id
						         	AND vc.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						          	FOR XML PATH ('')
					          	)
					          	, 1, 1, ''
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "oracle">
							(
								SELECT wmsys.wm_concat(vc.col_id_r) AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files vc
								WHERE vc.file_id_r = v.vid_id
								AND vc.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						</cfif>
						,
						'' AS colorspace,
						'' AS xdpi,
						'' AS ydpi,
						'' AS unit,
						v.hashtag AS md5hash
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos v 
						LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
						WHERE v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
						AND (v.vid_group IS NULL OR v.vid_group = '')
						AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						AND v.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
						AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfif>
					<cfif arguments.show EQ "ALL">
						UNION ALL
					</cfif>
					<!--- Audios --->
					<cfif arguments.show EQ "ALL" OR arguments.show EQ "aud">
						SELECT /* #cachetokenaud#getassetsfolder3 */ 
						a.aud_id id, 
						a.aud_name filename, 
						a.folder_id_r folder_id, 
						a.aud_extension extension, 
						'dummy' as video_image,
						a.aud_name_org filename_org, 
						'aud' as kind, 
						a.aud_extension extension_thumb, 
						<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(a.aud_size as varchar(100)), '0')</cfif> AS size, 
						0 AS width,
						0 AS height,
						aut.aud_description description, 
						aut.aud_keywords keywords,
						a.path_to_asset,
						a.cloud_url,
						a.cloud_url_org,
						a.aud_create_time dateadd,
						a.aud_change_time datechange,
						(
							SELECT 
								CASE 
									WHEN count(aud_id) = 0 THEN 'false'
									ELSE 'true'
								END AS test
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios asub
							WHERE asub.aud_group = a.aud_id
							AND asub.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						) as subassets,
						<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',a.path_to_asset,'/',a.aud_name_org) AS local_url_org,
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + a.path_to_asset + '/' + a.aud_name_org AS local_url_org,
						</cfif>
						'0' as local_url_thumb,
						<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							(
								SELECT GROUP_CONCAT(DISTINCT ac.col_id_r ORDER BY ac.col_id_r SEPARATOR ',') AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ac
								WHERE ac.file_id_r = a.aud_id
								AND ac.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							STUFF(
								(
									SELECT ', ' + ac.col_id_r
									FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ac
						         	WHERE ac.file_id_r = a.aud_id
						         	AND ac.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						          	FOR XML PATH ('')
					          	)
					          	, 1, 1, ''
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "oracle">
							(
								SELECT wmsys.wm_concat(ac.col_id_r) AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ac
								WHERE ac.file_id_r = a.aud_id
								AND ac.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						</cfif>
						,
						'' AS colorspace,
						'' AS xdpi,
						'' AS ydpi,
						'' AS unit,
						a.hashtag AS md5hash
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios a 
						LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
						WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
						AND (a.aud_group IS NULL OR a.aud_group = '')
						AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						AND a.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
						AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfif>
					<cfif arguments.show EQ "ALL">
						UNION ALL
					</cfif>
					<!--- Docs --->
					<cfif arguments.show EQ "ALL" OR arguments.show EQ "doc">
						SELECT /* #cachetokendoc#getassetsfolder4 */
						f.file_id id, 
						f.file_name filename, 
						f.folder_id_r folder_id, 
						f.file_extension extension, 
						'dummy' as video_image,
						f.file_name_org filename_org, 
						'doc' as kind, 
						f.file_extension extension_thumb, 
						<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(f.file_size as varchar(100)), '0')</cfif> AS size, 
						0 AS width,
						0 AS height,
						ft.file_desc description, 
						ft.file_keywords keywords,
						f.path_to_asset,
						f.cloud_url,
						f.cloud_url_org,
						f.file_create_time dateadd,
						f.file_change_time datechange,
						'false' as subassets,
						<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',f.path_to_asset,'/',f.file_name_org) AS local_url_org,
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + f.path_to_asset + '/' + f.file_name_org AS local_url_org,
						</cfif>
						'0' as local_url_thumb,
						<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
							(
								SELECT GROUP_CONCAT(DISTINCT fc.col_id_r ORDER BY fc.col_id_r SEPARATOR ',') AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files fc
								WHERE fc.file_id_r = f.file_id
								AND fc.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "mssql">
							STUFF(
								(
									SELECT ', ' + fc.col_id_r
									FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files fc
						         	WHERE fc.file_id_r = f.file_id
						         	AND fc.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						          	FOR XML PATH ('')
					          	)
					          	, 1, 1, ''
							) AS colid
						<cfelseif application.razuna.api.thedatabase EQ "oracle">
							(
								SELECT wmsys.wm_concat(fc.col_id_r) AS col_id
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files fc
								WHERE fc.file_id_r = f.file_id
								AND fc.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
							) AS colid
						</cfif>
						,
						'' AS colorspace,
						'' AS xdpi,
						'' AS ydpi,
						'' AS unit,
						f.hashtag AS md5hash
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#files f 
						LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
						WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
						AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						AND f.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
						AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfif>
				</cfquery>
				<!--- Only if we found records --->
				<cfif qry.recordcount NEQ 0>
					<!--- Add our own tags to the query --->
					<cfset q = querynew("responsecode,totalassetscount,calledwith")>
					<cfset queryaddrow(q,1)>
					<cfset querysetcell(q,"responsecode","0")>
					<cfset querysetcell(q,"totalassetscount",qry.recordcount)>
					<cfset querysetcell(q,"calledwith",arguments.folderid)>
					<!--- Put the 2 queries together --->
					<cfquery dbtype="query" name="thexml">
					SELECT *
					FROM qry, q
					</cfquery>
				<!--- Qry is null --->
				<cfelse>
					<cfset thexml = querynew("responsecode,totalassetscount,calledwith")>
					<cfset queryaddrow(thexml,1)>
					<cfset querysetcell(thexml,"responsecode","1")>
					<cfset querysetcell(thexml,"totalassetscount",qry.recordcount)>
					<cfset querysetcell(thexml,"calledwith",arguments.folderid)>
				</cfif>
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset var thexml = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
		
	<!--- Retrieve folders --->
	<cffunction name="getfolders" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="folderid" type="string" required="false" default="0">
		<cfargument name="collectionfolder" type="string" required="false" default="false">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			 <!--- Get permission for folder --->
			<cfset var folderaccess = checkFolderAccess(arguments.api_key, arguments.folderid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R"  OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Get Cachetoken --->
				<cfset var cachetoken = getcachetoken(arguments.api_key,"folders")>

				<!--- Query folder --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
				SELECT /* #cachetoken#getfolders */ f.folder_id, f.folder_name, f.folder_owner, 
				 (SELECT <cfif application.razuna.api.thedatabase EQ "mssql"> TOP 1</cfif> folder_desc from #application.razuna.api.prefix["#arguments.api_key#"]#folders_desc WHERE folder_id_r = f.folder_id AND lang_id_r = <cfqueryparam value="1" cfsqltype="cf_sql_numeric"> 
				 	<cfif application.razuna.api.thedatabase EQ "oracle">
						AND rownum = 1
					<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						LIMIT 1
					</cfif>
				 	) as folder_description, 
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "h2">NVL<cfelseif application.razuna.api.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username,
					(
						CASE WHEN EXISTS (SELECT 1
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders s
						WHERE s.folder_id <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id
						AND s.folder_id_r = f.folder_id
						AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						AND s.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">) THEN 'true' ELSE 'false' END
					)
					AS hassubfolders, '' totalassets, '' totalimg, '' totalvid, '' totaldoc, '' totalaud , '' howmanycollections, '1' folderperm
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders f
				LEFT JOIN users u ON u.user_id = f.folder_owner
				WHERE
				<cfif Arguments.folderid gt 0>
					f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.folderid#">
					AND f.folder_id_r <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id
				<cfelse>
					f.folder_id = f.folder_id_r
				</cfif>
				<cfif arguments.collectionfolder EQ "false">
					AND (f.folder_is_collection IS NULL OR f.folder_is_collection = '')
				<cfelse>
					AND lower(f.folder_is_collection) = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="t">
				</cfif>
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				<!--- Check to ensure user has permissions for folder --->
				AND 
				(
					EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
					OR
					EXISTS (SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE  f.folder_id = fg.folder_id_r  AND fg.grp_id_r = '0')
					OR
					EXISTS (SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE  f.folder_id = fg.folder_id_r  AND fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">))
					OR 
					f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
				)
				ORDER BY f.folder_name
				</cfquery>

				<!--- If this is NOT for a collection --->
				<cfif arguments.collectionfolder EQ "false">
					<cfset session.showsubfolders = "F">
					<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
					<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
					<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
					<cfloop query="qry">
						<!--- Query total count --->
						<cfinvoke component="global.cfc.folders" method="apifiletotalcount" folder_id="#qry.folder_id#" returnvariable="totalassets">
						<!--- Query total count for individual files --->
						<cfinvoke component="global.cfc.folders" method="apifiletotaltype" folder_id="#qry.folder_id#" returnvariable="totaltypes">
						<!--- Create additional query fields --->
						<cfset querysetcell(qry,"totalassets",totalassets.thetotal, qry.currentrow)>
						<cfset querysetcell(qry,"totalimg",totaltypes.img, qry.currentrow)>
						<cfset querysetcell(qry,"totalvid",totaltypes.vid, qry.currentrow)>
						<cfset querysetcell(qry,"totaldoc",totaltypes.files, qry.currentrow)>
						<cfset querysetcell(qry,"totalaud",totaltypes.aud, qry.currentrow)>
					</cfloop>
				<!--- This is for a collection --->
				<cfelse>
					<cfloop query="qry">
						<!--- Query how many collections are in this folder --->
						<cfquery datasource="#application.razuna.api.dsn#" name="q">
						SELECT count(col_id) as howmanycollections
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections
						WHERE folder_id_r  =<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.folder_id#">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
						</cfquery>
						<cfset querysetcell(qry,"howmanycollections",q.howmanycollections, qry.currentrow)>
					</cfloop>
				</cfif>
				
				<cfset thexml = qry>
			<!--- No access --->
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
	
	<!--- GetFolder --->
	<cffunction name="getfolder" output="false" access="remote" returnType="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="folderid" type="string" required="false">
		<cfargument name="foldername" type="string" required="false">
		<cfset var thexml ="">
		<cfif not isdefined("arguments.folderid") AND not isdefined("arguments.foldername")>
			<cfset var thexml = querynew("responsecode,message")>
			<cfset queryaddrow(thexml,1)>
			<cfset querysetcell(thexml,"responsecode","1")>
			<cfset querysetcell(thexml,"message","Either folderid or foldername parameter must be specified")>
			<cfreturn thexml>
		</cfif> 
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get Cachetoken --->
			<cfset var cachetoken = getcachetoken(arguments.api_key,"folders")>
			<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
			<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #cachetoken#getfolder */ f.folder_id, f.folder_id_r as folder_related_to, f.folder_name, fd.folder_desc as folder_description, 
			CASE WHEN lower(f.folder_shared) = 't' then 'true' else 'false' end folder_shared
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders f 
			LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders_desc fd ON fd.folder_id_r = f.folder_id AND fd.lang_id_r = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
			WHERE 
			f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			<cfif isDefined("arguments.folderid")>
				AND f.folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folderid#">
			</cfif>
			<cfif isDefined("arguments.foldername")>
				AND lower(f.folder_name)  like  <cfqueryparam cfsqltype="cf_sql_varchar" value="%#lcase(arguments.foldername)#%">
			</cfif>
			<!--- Check to ensure user has permissions for folder --->
			AND 
			(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE  f.folder_id = fg.folder_id_r  AND fg.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE  f.folder_id = fg.folder_id_r  AND fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">))
				OR 
				f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
			)
			</cfquery>
			<cfset var q = querynew("group_permission,totalassets,totalimg,totalvid,totaldoc,totalaud,folder_id")>
			
			<cfloop query="qry">
				<!--- Query total count --->
				<cfinvoke component="global.cfc.folders" method="apifiletotalcount"folder_id="#qry.folder_id#" returnvariable="totalassets">
				<!--- Query total count for individual files --->
				<cfinvoke component="global.cfc.folders" method="apifiletotaltype" folder_id="#qry.folder_id#" returnvariable="totaltypes">
				
				<!--- Get groups for folder --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thegroups" cachedwithin="1" region="razcache">
					SELECT /* #cachetoken#getfolder */ grp_id_r, grp_permission
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups
					WHERE folder_id_r = <cfqueryparam value="#qry.folder_id#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Add groups and related permissions to array --->
				<cfset var grparr = arrayNew(2)>
				<cfloop query = "thegroups">
					<cfset grparr[thegroups.currentrow][1] = thegroups.grp_id_r>
					<cfset grparr[thegroups.currentrow][2] = thegroups.grp_permission>
				</cfloop>
				<cfset grparr = SerializeJSON(grparr)>

				<!--- Create additional query fields --->
				<cfset queryaddrow(q,qry.currentrow)>
				<cfset querysetcell(q,"group_permission",grparr)>
				<cfset querysetcell(q,"totalassets",totalassets.thetotal)>
				<cfset querysetcell(q,"totalimg",totaltypes.img)>
				<cfset querysetcell(q,"totalvid",totaltypes.vid)>
				<cfset querysetcell(q,"totaldoc",totaltypes.doc)>
				<cfset querysetcell(q,"totalaud",totaltypes.aud)>
				<cfset querysetcell(q,"folder_id",qry.folder_id)>
			</cfloop>
			<!--- Put the 2 queries together --->
			<cfquery dbtype="query" name="thexml">
				SELECT qry.folder_id, qry.folder_related_to, qry.folder_name, qry.folder_description, qry.folder_shared, q.group_permission, q.totalassets, q.totalimg, q.totalvid, q.totaldoc, q.totalaud
				FROM qry, q
				WHERE qry.folder_id=q.folder_id
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- SetFolder --->
	<cffunction name="setfolder" output="false" access="remote" returnType="struct" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="folder_name" type="string" required="true">
		<cfargument name="folder_owner" type="string" required="false" default="">
		<cfargument name="folder_related" type="string" required="false" default="">
		<cfargument name="folder_collection" type="string" required="false" default="false">
		<cfargument name="folder_description" type="string" required="false" default="">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Create a new ID --->
			<cfset var newfolderid = createuuid("")>
			<!--- If this is on level 1 then have the main id inserted else query for it --->
			<cfif arguments.folder_related EQ "">
				<cfset var themainidr = newfolderid>
				<cfset var thelevel = 1>
				<!--- If folder on root level then check to ensure user is admin --->
				<cfif not(listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0)>
					<cfset var thexml = noaccess("s")>
					<cfreturn thexml>
				</cfif>
			<cfelse>
				<cfquery datasource="#application.razuna.api.dsn#" name="qrymainfid">
				SELECT folder_main_id_r, folder_level
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders
				WHERE folder_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_related#">
				</cfquery>
				<cfset var themainidr = qrymainfid.folder_main_id_r>
				<cfset var thelevel = qrymainfid.folder_level + 1>
			</cfif>
			<!--- Get permission for folder --->
			<cfset var folderaccess = checkFolderAccess(arguments.api_key, arguments.folder_related)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Insert --->
				<cfquery datasource="#application.razuna.api.dsn#">
				INSERT INTO #application.razuna.api.prefix["#arguments.api_key#"]#folders
				(folder_id, folder_name, folder_level, folder_id_r, folder_main_id_r, folder_owner, folder_create_date, folder_change_date,
				folder_create_time, folder_change_time, host_id
				<cfif arguments.folder_collection>, folder_is_collection</cfif>)
				VALUES (
				<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.folder_name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#thelevel#" cfsqltype="cf_sql_numeric">,
				<cfif arguments.folder_related NEQ "">
					<cfqueryparam value="#arguments.folder_related#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				,
				<cfqueryparam value="#themainidr#" cfsqltype="CF_SQL_VARCHAR">,
				<cfif arguments.folder_owner EQ "">
					<cfqueryparam value="#application.razuna.api.userid["#arguments.api_key#"]#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<cfqueryparam value="#arguments.folder_owner#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>	
				,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				<cfif arguments.folder_collection>
					,<cfqueryparam value="T" cfsqltype="cf_sql_varchar">
				</cfif>
				)
				</cfquery>
				<!--- Insert description --->
				<cfquery datasource="#application.razuna.api.dsn#">
				INSERT INTO #application.razuna.api.prefix["#arguments.api_key#"]#folders_desc
				(folder_id_r, lang_id_r, folder_desc, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#arguments.folder_description#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Call workflow --->
				<cfset executeworkflow(api_key=arguments.api_key,action='on_folder_add',fileid='0',folder_id=newfolderid)>
				<!--- Flush cache --->
				<cfset resetcachetoken(arguments.api_key,"folders")>
				<!--- Feedback --->
				<cfset thexml.responsecode = 0>
				<cfset thexml.folder_id = newfolderid>
				<!--- Apply custom settings to new folder --->
				<cfinvoke component="global.cfc.folders" method="apply_custom_shared_setting" folder_id="#newfolderid#" />
			<!--- No access --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Delete Folder --->
	<cffunction name="removefolder" output="false" access="remote" returnType="struct" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="folder_id" type="string" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for folder --->
			<cfset var folderaccess = checkFolderAccess(arguments.api_key, arguments.folder_id)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<cfif arguments.folder_id NEQ 1 AND arguments.folder_id NEQ 2>
					<!--- Struct --->
					<cfset var fs = structnew()>
					<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
					<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
					<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
					<!--- Get assetpath --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qrypath">
					SELECT set2_path_to_assets
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
					WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					</cfquery>
					<!--- Nirvanix --->
					<cfif application.razuna.api.storage EQ "nirvanix">
						<cfquery datasource="#application.razuna.api.dsn#" name="fs.qry_settings_nirvanix">
						SELECT set2_nirvanix_name, set2_nirvanix_pass
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
						WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<cfset nvx = createObject("component","global.cfc.nirvanix").init("#application.razuna.api.nvxappkey#")>
						<cfset fs.nvxsession = nvx.login("#fs#")>
					<!--- Amazon --->
					<cfelseif application.razuna.api.storage EQ "amazon">
						<cfquery datasource="#application.razuna.api.dsn#" name="qry">
						SELECT set2_aws_bucket
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
						WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<cfset fs.awsbucket = qry.set2_aws_bucket>
						<cfset createObject("component","global.cfc.amazon").init("#application.razuna.api.awskey#,#application.razuna.api.awskeysecret#")>
					<!--- Akamai --->
					<cfelseif application.razuna.api.storage EQ "akamai">
						<cfquery datasource="#application.razuna.api.dsn#" name="qry">
						SELECT set2_aka_url, set2_aka_img, set2_aka_vid, set2_aka_aud, set2_aka_doc
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
						WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<cfset fs.akaurl = qry.set2_aka_url>
						<cfset fs.akaimg = qry.set2_aka_img>
						<cfset fs.akavid = qry.set2_aka_vid>
						<cfset fs.akaaud = qry.set2_aka_aud>
						<cfset fs.akadoc = qry.set2_aka_doc>
					</cfif>
					<!--- Put in Struct --->
					<cfset fs.folder_id = arguments.folder_id>
					<cfset fs.assetpath = trim(qrypath.set2_path_to_assets)>
					<!--- Call CFC (Global) --->
					<cfinvoke component="global.cfc.folders" method="remove_folder_thread" thestruct="#fs#" />
					<!--- Feedback --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Folder and all content within has been successfully removed.">
				<cfelse>
					<!--- Feedback --->
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "You can not remove default folders!">
				</cfif>
			<!--- No access --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Set Custom Field Value --->
	<cffunction name="setFolderPermissions" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="permissions" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Deserialize the JSON back into a struct --->
				<cfset thejson = DeserializeJSON(arguments.permissions)>
				
				<!--- Loop over struct --->
				<cfloop array="#thejson#" index="f">
					<!--- Check to see if there is a record --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry">
					SELECT rec_uuid
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups
					WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
					AND grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[2]#">
					AND host_id = #application.razuna.api.hostid["#arguments.api_key#"]#
					</cfquery>
					<!--- Insert --->
					<cfif qry.recordcount EQ 0>
						<cfquery datasource="#application.razuna.api.dsn#">
						INSERT INTO #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups
						(folder_id_r, grp_id_r, grp_permission , host_id, rec_uuid)
						VALUES(
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#f[2]#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#f[3]#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
						)
						</cfquery>
					<!--- Update --->
					<cfelse>
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups
						SET grp_permission = <cfqueryparam cfsqltype="cf_sql_varchar" value="#f[3]#">
						WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[1]#">
						AND grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f[2]#">
						AND host_id = #application.razuna.api.hostid["#arguments.api_key#"]#
						</cfquery>
					</cfif>
					<!--- Check group 'folder_subscribe' setting and add all users in this group to receive folder notifications if set to true --->
					<cfinvoke component="global.cfc.groups" method="add_grp_users2notify" group_id='#f[2]#'>
				</cfloop>
				
				<!--- Flush cache --->
				<cfset resetcachetoken(arguments.api_key,"folders")>
				<!--- Feedback --->
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "Folder permissions successfully updated">
			<!--- User not admin --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
		
	<!--- Private Functions --->
	
		
</cfcomponent>