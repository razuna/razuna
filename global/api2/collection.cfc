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
	
	<!--- Retrieve assets from a Collection --->
	<cffunction name="getassets" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string">
		<cfargument name="collectionid" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get collection folder in which collection resides --->
			<cfquery datasource="#application.razuna.api.dsn#" name="colfolder">
			SELECT folder_id_r
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections
			WHERE col_id = <cfqueryparam value="#arguments.collectionid#" cfsqltype="CF_SQL_VARCHAR">
			AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			</cfquery>
			<!--- Get permission for collection folder --->
			<cfset var folderaccess = checkFolderAccess(arguments.api_key, colfolder.folder_id_r)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R"  OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Get Cachetoken --->
				<cfset var cachetokenvid = getcachetoken(arguments.api_key,"videos")>
				<cfset var cachetokenimg = getcachetoken(arguments.api_key,"images")>
				<cfset var cachetokenaud = getcachetoken(arguments.api_key,"audios")>
				<cfset var cachetokendoc = getcachetoken(arguments.api_key,"files")>
				<cfset var cachetokencol = getcachetoken(arguments.api_key,"general")>
				<!--- Param --->
				<cfset thestorage = "">
				<!--- Query which file are in this collection --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry_col" cachedwithin="1" region="razcache">
				SELECT /* #cachetokencol#getassetscol */ file_id_r, col_file_format
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ct
				WHERE ct.col_id_r = <cfqueryparam value="#arguments.collectionid#" cfsqltype="CF_SQL_VARCHAR">
				AND ct.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				</cfquery>
				<!--- If above qry return records --->
				<cfif qry_col.recordcount NEQ 0>
					<!--- Query the files --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
					SELECT  /* #cachetokenimg#getassetscol */
					i.img_id id, 
					i.img_filename filename, 
					i.folder_id_r folder_id, 
					fo.folder_name,
					i.img_extension extension,
					i.thumb_extension extension_thumb, 
					'dummy' as video_image, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar(100)), '0')</cfif> AS size,
					i.img_width AS width,
					i.img_height AS height,
					i.img_filename_org filename_org, 
					'img' as kind, 
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
					CASE
						WHEN (ct.col_file_format = 'original' OR ct.col_file_format = 'thumb') THEN i.img_id
						ELSE ct.col_file_format
					END as rendition_id,
					CASE
						WHEN (ct.col_file_format = 'original' OR ct.col_file_format = 'thumb') THEN 
							<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
								concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org)
							<cfelseif application.razuna.api.thedatabase EQ "mssql">
								'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/' + i.img_filename_org
							</cfif>
						ELSE 
							<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
								concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',(SELECT path_to_asset FROM #application.razuna.api.prefix["#arguments.api_key#"]#images WHERE img_id = ct.col_file_format),'/',(SELECT img_filename_org FROM #application.razuna.api.prefix["#arguments.api_key#"]#images WHERE img_id = ct.col_file_format))
							<cfelseif application.razuna.api.thedatabase EQ "mssql">
								'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + (SELECT path_to_asset FROM #application.razuna.api.prefix["#arguments.api_key#"]#images WHERE img_id = ct.col_file_format) + '/' + (SELECT img_filename_org FROM #application.razuna.api.prefix["#arguments.api_key#"]#images WHERE img_id = ct.col_file_format)
							</cfif>
					END as rendition_url,
					x.colorspace,
					x.xres AS xdpi,
					x.yres AS ydpi,
					x.resunit AS unit,
					i.hashtag AS md5hash
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ct ON ct.file_id_r = i.img_id AND ct.col_id_r = '#arguments.collectionid#'
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = i.folder_id_r AND fo.host_id = i.host_id
					WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
					AND (i.img_group IS NULL OR i.img_group = '')
					AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND i.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					UNION ALL
					SELECT /* #cachetokenvid#getassetscol */
					v.vid_id id, 
					v.vid_filename filename, 
					v.folder_id_r folder_id, 
					fo.folder_name,
					v.vid_extension extension, 
					'0' as extension_thumb,
					v.vid_name_image as video_image, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(v.vid_size as varchar(100)), '0')</cfif> AS size,
					v.vid_width AS width,
					v.vid_height AS height, 
					v.vid_name_org filename_org,
					'vid' as kind,
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
					CASE
						WHEN (ct.col_file_format = 'video') THEN v.vid_id
						ELSE ct.col_file_format
					END as rendition_id,
					CASE
						WHEN (ct.col_file_format = 'video') THEN 
							<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
								concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_org)
							<cfelseif application.razuna.api.thedatabase EQ "mssql">
								'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + v.path_to_asset + '/' + v.vid_name_org
							</cfif>
						ELSE 
							<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
								concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',(SELECT path_to_asset FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos WHERE vid_id = ct.col_file_format),'/',(SELECT vid_name_org FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos WHERE vid_id = ct.col_file_format))
							<cfelseif application.razuna.api.thedatabase EQ "mssql">
								'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + (SELECT path_to_asset FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos WHERE vid_id = ct.col_file_format) + '/' + (SELECT vid_name_org FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos WHERE vid_id = ct.col_file_format)
							</cfif>
					END as rendition_url,
					'' AS colorspace,
					'' AS xdpi,
					'' AS ydpi,
					'' AS unit,
					v.hashtag AS md5hash
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos v 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ct ON ct.file_id_r = v.vid_id AND ct.col_id_r = '#arguments.collectionid#'
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = v.folder_id_r AND fo.host_id = v.host_id
					WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
					AND (v.vid_group IS NULL OR v.vid_group = '')
					AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND v.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					UNION ALL
					<!--- Audios --->
					SELECT /* #cachetokenaud#getassetscol */
					a.aud_id id, 
					a.aud_name filename, 
					a.folder_id_r folder_id, 
					fo.folder_name,
					a.aud_extension extension,
					'0' extension_thumb, 
					'dummy' as video_image,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.aud_size as varchar(100)), '0')</cfif> AS size,
					0 AS width,
					0 AS height,
					a.aud_name_org filename_org, 
					'aud' as kind, 
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
					CASE
						WHEN (ct.col_file_format = '' OR ct.col_file_format = 'audio') THEN a.aud_id
						ELSE ct.col_file_format
					END as rendition_id,
					CASE
						WHEN (ct.col_file_format = '' OR ct.col_file_format = 'audio') THEN 
							<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
								concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',a.path_to_asset,'/',a.aud_name_org)
							</cfif>
						ELSE 
							<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
								concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',(SELECT path_to_asset FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios WHERE aud_id = ct.col_file_format),'/',(SELECT aud_name_org FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios WHERE aud_id = ct.col_file_format))
							<cfelseif application.razuna.api.thedatabase EQ "mssql">
								'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + (SELECT path_to_asset FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios WHERE aud_id = ct.col_file_format) + '/' + (SELECT aud_name_org FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios WHERE aud_id = ct.col_file_format)
							</cfif>
					END as rendition_url,
					'' AS colorspace,
					'' AS xdpi,
					'' AS ydpi,
					'' AS unit,
					a.hashtag AS md5hash
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios a 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ct ON ct.file_id_r = a.aud_id AND ct.col_id_r = '#arguments.collectionid#'
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = a.folder_id_r AND fo.host_id = a.host_id
					WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
					AND (a.aud_group IS NULL OR a.aud_group = '')
					AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND a.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					UNION ALL
					SELECT /* #cachetokendoc#getassetscol */
					f.file_id id, 
					f.file_name filename, 
					f.folder_id_r folder_id, 
					fo.folder_name,
					f.file_extension extension, 
					'0' as extension_thumb, 
					'dummy' as video_image, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(f.file_size as varchar(100)), '0')</cfif> AS size,
					0 AS width,
					0 AS height,
					f.file_name_org filename_org, 
					f.file_type as kind, 
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
					'0' as rendition_id,
					'0' as rendition_url,
					'' AS colorspace,
					'' AS xdpi,
					'' AS ydpi,
					'' AS unit,
					f.hashtag AS md5hash
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#files f 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = f.folder_id_r AND fo.host_id = f.host_id
					WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND f.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					ORDER BY filename
					</cfquery>
					<!--- Add our own tags to the query --->
					<cfset q = querynew("responsecode,totalassetscount,calledwith")>
					<cfset queryaddrow(q,1)>
					<cfset querysetcell(q,"responsecode","0")>
					<cfset querysetcell(q,"totalassetscount",qry.recordcount)>
					<cfset querysetcell(q,"calledwith","c-#arguments.collectionid#")>
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
					<cfset querysetcell(thexml,"calledwith","c-#arguments.collectionid#")>
				</cfif>
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
	
	<!--- Get Collections of this Collection folder --->
	<cffunction name="getcollections" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="folderid" type="string" required="true">
		<cfargument name="released" type="string" required="false" default="">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for folder --->
			<cfset var folderaccess = checkFolderAccess(arguments.api_key, arguments.folderid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R" OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT c.col_id, c.change_date, ct.col_name, ct.col_desc as collection_description, 
				ct.col_keywords as collection_keywords, c.col_released, c.col_copied_from,
					(
						SELECT count(file_id_r) 
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
						WHERE col_id_r = c.col_id 
						AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img">
						AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					) as totalimg,
					(
						SELECT count(file_id_r) 
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
						WHERE col_id_r = c.col_id 
						AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="vid">
						AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					) as totalvid,
					(
						SELECT count(file_id_r) 
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
						WHERE col_id_r = c.col_id
						AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="doc">
						AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					) as totaldoc,
					(
						SELECT count(file_id_r) 
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
						WHERE col_id_r = c.col_id 
						AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="aud">
						AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					) as totalaud,
					(
						SELECT count(file_id_r)
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files
						WHERE col_id_r = c.col_id
						AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					)  as totalassets
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections c
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#collections_text ct ON c.col_id = ct.col_id_r AND ct.lang_id_r = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
				WHERE c.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folderid#" list="true">)
				AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				<cfif arguments.released NEQ "">
					AND c.col_released = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.released#">
				</cfif>
				AND c.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				ORDER BY lower(ct.col_name)
				</cfquery>
			<!--- No access --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
					<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml />
	</cffunction>

	<!--- Search --->
	<cffunction name="search" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="id" type="string" required="false" default="">
		<cfargument name="name" type="string" required="false" default="">
		<cfargument name="keyword" type="string" required="false" default="">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="released" type="string" required="false" default="">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<cfset var thexml ="">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<cftry>
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT DISTINCT c.folder_id_r
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections c
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#collections_text ct ON c.col_id = ct.col_id_r
				WHERE c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				AND ct.lang_id_r = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
				AND c.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				<cfif arguments.id NEQ "">
					AND c.col_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.id#">
				</cfif>
				<cfif arguments.name NEQ "">
					AND lower(ct.col_name) LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#lcase(arguments.name)#%">
				</cfif>
				<cfif arguments.keyword NEQ "">
					AND lower(ct.col_keywords) LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#lcase(arguments.keyword)#%">
				</cfif>
				<cfif arguments.description NEQ "">
					AND lower(ct.col_desc) LIKE <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#lcase(arguments.description)#%">
				</cfif>
				<cfif arguments.released NEQ "">
					AND lower(c.col_released) = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#lcase(arguments.released)#">
				</cfif>
				</cfquery>
				<!--- Get getcollections --->
				<cfif qry.recordcount NEQ 0>
					<!--- Note: Method getcollections already has permission checks applied to it  --->
					<cfset thexml = getcollections(api_key=arguments.api_key,folderid=valueList(qry.folder_id_r),released=arguments.released)>
				<cfelse>
					<cfset thexml = querynew("responsecode,message")>
					<cfset queryaddrow(thexml,1)>
					<cfset querysetcell(thexml,"responsecode","1")>
					<cfset querysetcell(thexml,"message","No records found")>
				</cfif>
				<cfcatch type="any">
					<cfset consoleoutput(true)>
					<cfset console(cfcatch)>
					<cfabort>
				</cfcatch>
			</cftry>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml />
	</cffunction>
</cfcomponent>