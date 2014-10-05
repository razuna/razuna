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
	
	<!--- Asset: Get info --->
	<cffunction name="getasset" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="assetid" required="true" type="string">
		<cfargument name="assettype" required="true" type="string">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R"  OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Param --->
				<cfset thestorage = "">
				<!--- Images --->
				<cfif arguments.assettype EQ "img">
					<!--- Get Cachetoken --->
					<cfset var cachetoken = getcachetoken(arguments.api_key,"images")>
					<!--- Query --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
					SELECT /* #cachetoken#getassetimg */
					'img' as type,
					i.img_id id, 
					i.img_filename filename, 
					i.folder_id_r folder_id, 
					fo.folder_name,
					i.img_extension extension,
					i.img_filename_org filename_org, 
					i.thumb_extension extension_thumb, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar(100)), '0')</cfif> AS size, 
					i.img_width AS width,
					i.img_height AS height,
					it.img_description description, 
					it.img_keywords keywords,
					i.path_to_asset,
					i.cloud_url,
					i.cloud_url_org,
					i.img_meta metadata,
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
					) as hassubassets,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',i.host_id,'/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',i.host_id,'/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_thumb,
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + i.host_id + '/' + i.path_to_asset + '/' + i.img_filename_org AS local_url_org,
						'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + i.host_id + '/'+ i.path_to_asset + '/thumb_'+ i.img_id + '.' + i.thumb_extension AS local_url_thumb,
					</cfif>
					<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						(
							SELECT GROUP_CONCAT(DISTINCT ic.col_id_r ORDER BY ic.col_id_r SEPARATOR ',') AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ic
							WHERE ic.file_id_r = i.img_id
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						STUFF(
							(
								SELECT ', ' + ic.col_id_r
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ic
					         	WHERE ic.file_id_r = i.img_id
					          	FOR XML PATH ('')
				          	)
				          	, 1, 1, ''
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "oracle">
						(
							SELECT wmsys.wm_concat(ic.col_id_r) AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ic
							WHERE ic.file_id_r = i.img_id
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
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = i.folder_id_r AND fo.host_id = i.host_id
					WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
					AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfquery>
				<!--- Videos --->
				<cfelseif arguments.assettype EQ "vid">
					<!--- Get Cachetoken --->
					<cfset var cachetoken = getcachetoken(arguments.api_key,"videos")>
					<!--- Query --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
					SELECT /* #cachetoken#getassetvid */
					'vid' as type,
					v.vid_id id, 
					v.vid_filename filename, 
					v.folder_id_r folder_id, 
					fo.folder_name,
					v.vid_extension extension, 
					v.vid_name_image as video_preview,
					v.vid_name_org filename_org, 
					v.vid_extension extension, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(v.vid_size as varchar(100)), '0')</cfif> AS size, 
					v.vid_width AS width,
					v.vid_height AS height,
					vt.vid_description description, 
					vt.vid_keywords keywords,
					v.path_to_asset,
					v.cloud_url,
					v.cloud_url_org,
					v.vid_meta metadata,
					v.vid_create_time dateadd,
					v.vid_change_time datechange,
					v.hashtag AS md5hash,
					(
						SELECT 
							CASE 
								WHEN count(vid_id) = 0 THEN 'false'
								ELSE 'true'
							END AS test
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos vsub
						WHERE vsub.vid_group = v.vid_id
					) as subassets,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/',v.host_id,'/',v.path_to_asset,'/',v.vid_name_org) AS local_url_org,
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/',v.host_id,'/',v.path_to_asset,'/',v.vid_name_image) AS local_url_thumb,
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/' + v.host_id + '/'+ v.path_to_asset + '/' + v.vid_name_org AS local_url_org,
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/' + v.host_id + '/'+ v.path_to_asset + '/' + v.vid_name_image AS local_url_thumb,
					</cfif>
					<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						(
							SELECT GROUP_CONCAT(DISTINCT vc.col_id_r ORDER BY vc.col_id_r SEPARATOR ',') AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files vc
							WHERE vc.file_id_r = v.vid_id
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						STUFF(
							(
								SELECT ', ' + vc.col_id_r
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files vc
					         	WHERE vc.file_id_r = v.vid_id
					          	FOR XML PATH ('')
				          	)
				          	, 1, 1, ''
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "oracle">
						(
							SELECT wmsys.wm_concat(vc.col_id_r) AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files vc
							WHERE vc.file_id_r = v.vid_id
						) AS colid
					</cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos v 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = v.folder_id_r AND fo.host_id = v.host_id
					WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
					AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfquery>
				<!--- Audios --->
				<cfelseif arguments.assettype EQ "aud">
					<!--- Get Cachetoken --->
					<cfset var cachetoken = getcachetoken(arguments.api_key,"audios")>
					<!--- Query --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
					SELECT /* #cachetoken#getassetaud */
					'aud' as type,
					a.aud_id id, 
					a.aud_name filename, 
					a.folder_id_r folder_id, 
					fo.folder_name,
					a.aud_extension extension, 
					a.aud_name_org filename_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(a.aud_size as varchar(100)), '0')</cfif> AS size, 
					0 AS width,
					0 AS height,
					aut.aud_description description, 
					aut.aud_keywords keywords,
					a.path_to_asset,
					a.cloud_url,
					a.cloud_url_org,
					a.aud_meta metadata,
					a.aud_create_time dateadd,
					a.aud_change_time datechange,
					a.hashtag AS md5hash,
					(
						SELECT 
							CASE 
								WHEN count(aud_id) = 0 THEN 'false'
								ELSE 'true'
							END AS test
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios asub
						WHERE asub.aud_group = a.aud_id
					) as subassets,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/',a.host_id,'/',a.path_to_asset,'/',a.aud_name_org) AS local_url_org,
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/' + a.host_id + '/' + a.path_to_asset + '/' + a.aud_name_org AS local_url_org,
					</cfif>
					'' AS local_url_thumb,
					<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						(
							SELECT GROUP_CONCAT(DISTINCT ac.col_id_r ORDER BY ac.col_id_r SEPARATOR ',') AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ac
							WHERE ac.file_id_r = a.aud_id
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						STUFF(
							(
								SELECT ', ' + ac.col_id_r
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ac
					         	WHERE ac.file_id_r = a.aud_id
					          	FOR XML PATH ('')
				          	)
				          	, 1, 1, ''
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "oracle">
						(
							SELECT wmsys.wm_concat(ac.col_id_r) AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ac
							WHERE ac.file_id_r = a.aud_id
						) AS colid
					</cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios a 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = a.folder_id_r AND fo.host_id = a.host_id
					WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
					AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfquery>
				<!--- Documents --->
				<cfelseif arguments.assettype EQ "doc">
					<!--- Get Cachetoken --->
					<cfset var cachetoken = getcachetoken(arguments.api_key,"files")>
					<!--- Query --->
					<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
					SELECT /* #cachetoken#getassetfile */
					'doc' as type,
					f.file_id id, 
					f.file_name filename, 
					f.folder_id_r folder_id, 
					fo.folder_name,
					f.file_extension extension, 
					f.file_name_org filename_org, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(f.file_size as varchar(100)), '0')</cfif> AS size, 
					0 AS width,
					0 AS height,
					ft.file_desc description, 
					ft.file_keywords keywords,
					f.path_to_asset,
					f.cloud_url,
					f.cloud_url_org,
					f.file_meta metadata,
					f.file_create_time dateadd,
					f.file_change_time datechange,
					'false' as subassets,
					f.hashtag AS md5hash,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/',f.host_id,'/',f.path_to_asset,'/',f.file_name_org) AS local_url_org,
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/' + f.host_id + '/'+ f.path_to_asset + '/' + f.file_name_org AS local_url_org,
					</cfif>
					'' AS local_url_thumb,
					<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						(
							SELECT GROUP_CONCAT(DISTINCT fc.col_id_r ORDER BY fc.col_id_r SEPARATOR ',') AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files fc
							WHERE fc.file_id_r = f.file_id
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						STUFF(
							(
								SELECT ', ' + fc.col_id_r
								FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files fc
					         	WHERE fc.file_id_r = f.file_id
					          	FOR XML PATH ('')
				          	)
				          	, 1, 1, ''
						) AS colid
					<cfelseif application.razuna.api.thedatabase EQ "oracle">
						(
							SELECT wmsys.wm_concat(fc.col_id_r) AS col_id
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files fc
							WHERE fc.file_id_r = f.file_id
						) AS colid
					</cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#files f 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON fo.folder_id = f.folder_id_r AND fo.host_id = f.host_id
					WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					</cfquery>
				</cfif>
				<!--- Only if we found records --->
				<cfif qry.recordcount NEQ 0>
					<!--- Add our own tags to the query --->
					<cfset q = querynew("responsecode,totalassetscount,calledwith")>
					<cfset queryaddrow(q,1)>
					<cfset querysetcell(q,"responsecode","0")>
					<cfset querysetcell(q,"totalassetscount",qry.recordcount)>
					<cfset querysetcell(q,"calledwith",arguments.assetid)>
					<!--- Put the 2 queries together --->
					<cfquery dbtype="query" name="thexml">
					SELECT *
					FROM qry, q
					</cfquery>
				<!--- Qry is null --->
				<cfelse>
					<cfset var thexml = querynew("responsecode,totalassetscount,calledwith")>
					<cfset queryaddrow(thexml,1)>
					<cfset querysetcell(thexml,"responsecode","1")>
					<cfset querysetcell(thexml,"totalassetscount",qry.recordcount)>
					<cfset querysetcell(thexml,"calledwith",arguments.assetid)>
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
	
	<!--- Metadata: Get --->
	<cffunction name="getmetadata" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="assetid" required="true">
		<cfargument name="assettype" required="true">
		<cfargument name="assetmetadata" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R"  OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Set db and id --->
				<cfif arguments.assettype EQ "img">
					<cfset var thedb = "xmp">
					<cfset var theidr = "id_r">
					<cfset var cachetoken = getcachetoken(arguments.api_key,"images")>
				<cfelseif arguments.assettype EQ "doc">
					<cfset var thedb = "files_xmp">
					<cfset var theidr = "asset_id_r">
					<cfset var cachetoken = getcachetoken(arguments.api_key,"files")>
				</cfif>
				<!--- Loop over the assetid --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qrymeta" cachedwithin="1" region="razcache">
				SELECT /* #cachetoken#getmetadata */ #arguments.assetmetadata#
				FROM #application.razuna.api.prefix["#arguments.api_key#"]##thedb#
				WHERE #theidr# IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#" list="Yes">)
				</cfquery>
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset var qrymeta = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var qrymeta = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn qrymeta>
	</cffunction>
	
	<!--- Metadata: Add --->
	<cffunction name="setmetadata" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="assetid" required="true">
		<cfargument name="assettype" required="true">
		<cfargument name="assetmetadata" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
				<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
				<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
				<!--- Set db and id --->
				<cfif arguments.assettype EQ "img">
					<cfset var thedb = "images_text">
					<cfset var theid = "img_id">
					<cfset var theidr = "img_id_r">
					<cfset var cachetype = "images">
				<cfelseif arguments.assettype EQ "vid">
					<cfset var thedb = "videos_text">
					<cfset var theid = "vid_id">
					<cfset var theidr = "vid_id_r">
					<cfset var cachetype = "videos">
				<cfelseif arguments.assettype EQ "aud">
					<cfset var thedb = "audios_text">
					<cfset var theid = "aud_id">
					<cfset var theidr = "aud_id_r">
					<cfset var cachetype = "audios">
				<cfelse>
					<cfset var thedb = "files_desc">
					<cfset var theid = "file_id">
					<cfset var theidr = "file_id_r">
					<cfset var cachetype = "files">
				</cfif>
				<!--- Deserialize the JSON back into an array --->
				<cfset thejson = DeserializeJSON(arguments.assetmetadata)>
				<!--- Loop over the assetid --->
				<cfloop list="#arguments.assetid#" index="i" delimiters=",">
					<!--- Remove all values for this record first --->
					<cfquery datasource="#application.razuna.api.dsn#">
					DELETE FROM #application.razuna.api.prefix["#arguments.api_key#"]##thedb#
					WHERE #theidr# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
					</cfquery>
					<!--- the id --->
					<cfset theid = createuuid("")>
					<!--- Create record --->
					<cfquery datasource="#application.razuna.api.dsn#">
					INSERT INTO #application.razuna.api.prefix["#arguments.api_key#"]##thedb#
					(id_inc, host_id, lang_id_r, #theidr#)
					VALUES (
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
					)
					</cfquery>
					<!--- Add keywords and description to the asset (loop over the passed array) --->
					<cfloop index="x" from="1" to="#arrayLen(thejson)#">
						<cfif thejson[x][1] CONTAINS "_" AND thejson[x][1] NEQ "file_name">
							<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]##thedb#
							SET #thejson[x][1]# = <cfif #thejson[x][1]# EQ "lang_id_r"><cfqueryparam cfsqltype="cf_sql_numeric" value="#thejson[x][2]#"><cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thejson[x][2]#"></cfif>
							WHERE id_inc = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
							</cfquery>
						</cfif>
					</cfloop>
					<!--- If we are a image then also loop over the XMP fields --->
					<cfif arguments.assettype EQ "img">
						<!--- Check if there is a record for this asset --->
						<cfquery datasource="#application.razuna.api.dsn#" name="ishere">
						SELECT id_r
						FROM #application.razuna.api.prefix["#arguments.api_key#"]#xmp
						WHERE asset_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">
						AND id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
						</cfquery>
						<!--- If record is not here then do insert --->
						<cfif ishere.recordcount EQ 0>	
							<cfquery datasource="#application.razuna.api.dsn#">
							INSERT INTO #application.razuna.api.prefix["#arguments.api_key#"]#xmp
							(id_r, asset_type, host_id)
							VALUES(
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">,
								<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">,
								<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
							)
							</cfquery>
						</cfif>
						<!--- Update records --->
						<cfloop index="x" from="1" to="#arrayLen(thejson)#">
							<cfif #thejson[x][1]# NEQ "lang_id_r" AND #thejson[x][1]# DOES NOT CONTAIN "_">
								<cfquery datasource="#application.razuna.api.dsn#">
								UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#xmp
								SET #thejson[x][1]# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thejson[x][2]#">
								WHERE id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
								</cfquery>
							</cfif>
						</cfloop>
						<!--- Update file name --->
						<cfloop index="x" from="1" to="#arrayLen(thejson)#">
							<cfif thejson[x][1] EQ "file_name">
								<cfquery datasource="#application.razuna.api.dsn#">
								UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#images
								SET img_filename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thejson[x][2]#">
								WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
								</cfquery>
							</cfif>
						</cfloop>
						<!--- Update change date --->
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#images
						SET 
						img_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
						WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
						</cfquery>
					<cfelseif arguments.assettype EQ "vid">
						<!--- Update file name --->
						<cfloop index="x" from="1" to="#arrayLen(thejson)#">
							<cfif thejson[x][1] EQ "file_name">
								<cfquery datasource="#application.razuna.api.dsn#">
								UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#videos
								SET vid_filename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thejson[x][2]#">
								WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
								</cfquery>
							</cfif>
						</cfloop>
						<!--- Update change date --->
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#videos
						SET 
						vid_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						vid_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
						WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
						</cfquery>
					<cfelseif arguments.assettype EQ "aud">
						<!--- Update file name --->
						<cfloop index="x" from="1" to="#arrayLen(thejson)#">
							<cfif thejson[x][1] EQ "file_name">
								<cfquery datasource="#application.razuna.api.dsn#">
								UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#audios
								SET aud_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thejson[x][2]#">
								WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
								</cfquery>
							</cfif>
						</cfloop>
						<!--- Update change date --->
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#audios
						SET 
						aud_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						aud_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
						WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
						</cfquery>
					<cfelse>
						<!--- Update file name --->
						<cfloop index="x" from="1" to="#arrayLen(thejson)#">
							<cfif thejson[x][1] EQ "file_name">
								<cfquery datasource="#application.razuna.api.dsn#">
								UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#files
								SET file_name = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thejson[x][2]#">
								WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
								</cfquery>
							</cfif>
						</cfloop>
						<!--- Update change date --->
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#files
						SET 
						file_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
						WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
						</cfquery>
					</cfif>
					<!--- Call workflow --->
					<cfset executeworkflow(api_key=arguments.api_key,action='on_file_edit',fileid=i)>
				</cfloop>
				<!--- Flush cache --->
				<cfset resetcachetoken(arguments.api_key,cachetype)>
				<cfset resetcachetoken(arguments.api_key,"search")>
				<!--- Feedback --->
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "Metadata successfully stored">
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>	
	
    <!--- Delete --->
	<cffunction name="remove" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="assetid" required="true">
    	<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Put values into struct to be compatible with global cfcs --->
				<cfset orgstruct = structnew()>
				<cfset orgstruct.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
				<cfset orgstruct.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
				<cfset orgstruct.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
				<cfset orgstruct.id = arguments.assetid>
				<!--- Get assetpath --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT set2_path_to_assets
				FROM #orgstruct.hostdbprefix#settings_2
				WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#orgstruct.hostid#">
				</cfquery>
				<cfset orgstruct.assetpath = trim(qry.set2_path_to_assets)>
				<!--- Nirvanix --->
				<cfif application.razuna.api.storage EQ "nirvanix">
					<cfquery datasource="#application.razuna.api.dsn#" name="orgstruct.qry_settings_nirvanix">
					SELECT set2_nirvanix_name, set2_nirvanix_pass
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
					WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					</cfquery>
					<cfset nvx = createObject("component","global.cfc.nirvanix").init("#application.razuna.api.nvxappkey#")>
					<cfset nvxsession = nvx.login("#orgstruct#")>
				<!--- Amazon --->
				<cfelseif application.razuna.api.storage EQ "amazon">
					<cfquery datasource="#application.razuna.api.dsn#" name="qry">
					SELECT set2_aws_bucket
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
					WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					</cfquery>
					<cfset orgstruct.awsbucket = qry.set2_aws_bucket>
					<cfset createObject("component","global.cfc.amazon").init("#application.razuna.api.awskey#,#application.razuna.api.awskeysecret#")>
				<!--- Akamai --->
				<cfelseif application.razuna.api.storage EQ "akamai">
					<cfquery datasource="#application.razuna.api.dsn#" name="qry">
					SELECT set2_aka_url, set2_aka_img, set2_aka_vid, set2_aka_aud, set2_aka_doc
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
					WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					</cfquery>
					<cfset orgstruct.akaurl = qry.set2_aka_url>
					<cfset orgstruct.akaimg = qry.set2_aka_img>
					<cfset orgstruct.akavid = qry.set2_aka_vid>
					<cfset orgstruct.akaaud = qry.set2_aka_aud>
					<cfset orgstruct.akadoc = qry.set2_aka_doc>
				</cfif>
				<!--- Images --->	
				<cfinvoke component="global.cfc.images" method="removeimagemany" thestruct="#orgstruct#" />
	            <!--- Videos --->
	            <cfset orgstruct.id = arguments.assetid>
				<cfinvoke component="global.cfc.videos" method="removevideomany" thestruct="#orgstruct#" />
				<!--- Audios --->
				<cfset orgstruct.id = arguments.assetid>
				<cfinvoke component="global.cfc.audios" method="removeaudiomany" thestruct="#orgstruct#" />
				<!--- Files --->
				<cfset orgstruct.id = arguments.assetid>
				<cfinvoke component="global.cfc.files" method="removefilemany" thestruct="#orgstruct#" />
				<!--- Feedback --->
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "Asset(s) have been removed successfully">
		<!---No access --->
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
    
    <!--- Get converted formats --->
	<cffunction name="getrenditions" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="assetid" type="string" required="true">
		<!--- <cfargument name="assettype" type="string" required="true"> --->
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R"  OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Get Cachetoken --->
				<cfset var cachetokenvid = getcachetoken(arguments.api_key,"videos")>
				<cfset var cachetokenimg = getcachetoken(arguments.api_key,"images")>
				<cfset var cachetokenaud = getcachetoken(arguments.api_key,"audios")>
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
				SELECT /* #cachetokenimg#getrenditionsimg */
				'rendition' as type,
				i.img_id AS id, 
				i.img_width AS width, 
				i.img_height AS height, 
				i.path_to_asset, 
				i.cloud_url_org,
				i.img_filename_org AS filename_org,
				i.img_extension AS extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',i.host_id,'/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + i.host_id + '/'+ i.path_to_asset + '/' + i.img_filename_org AS local_url_org,
				</cfif>
				x.colorspace,
				x.xres AS xdpi,
				x.yres AS ydpi,
				x.resunit AS unit,
				i.hashtag AS md5hash,
				i.img_group AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
				WHERE i.img_group in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND i.img_group IS NOT NULL
				AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT /* #cachetokenimg#getrenditionsimg */
				'org' as type,
				i.img_id AS id, 
				i.img_width AS width, 
				i.img_height AS height, 
				i.path_to_asset, 
				i.cloud_url_org,
				i.img_filename_org AS filename_org,
				i.img_extension AS extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',i.host_id,'/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + i.host_id + '/'+ i.path_to_asset + '/' + i.img_filename_org AS local_url_org,
				</cfif>
				x.colorspace,
				x.xres AS xdpi,
				x.yres AS ydpi,
				x.resunit AS unit,
				i.hashtag AS md5hash,
				i.img_group AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
				WHERE i.img_id in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT /* #cachetokenimg#getrenditionsimg */
				'thumb' AS type,
				i.img_id AS id, 
				i.thumb_width AS width, 
				i.thumb_height AS height, 
				i.path_to_asset, 
				i.cloud_url_org,
				i.img_filename_org AS filename_org,
				i.thumb_extension AS extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',i.host_id,'/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_org,
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + i.host_id + '/'+ i.path_to_asset + '/thumb_'+ i.img_id + '.' + i.thumb_extension AS local_url_org,
				</cfif>
				x.colorspace,
				x.xres AS xdpi,
				x.yres AS ydpi,
				x.resunit AS unit,
				i.hashtag AS md5hash,
				i.img_group AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
				WHERE i.img_id in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT /* #cachetokenvid#getrenditionsvid */
				'rendition' AS type,
				vid_id id, 
				vid_width width, 
				vid_height height, 
				path_to_asset,  
				cloud_url_org,
				vid_name_org filename_org,
				vid_extension extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(vid_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',host_id,'/',path_to_asset,'/',vid_name_org) AS local_url_org
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + host_id + '/'+ path_to_asset + '/' + vid_name_org AS local_url_org
				</cfif>,
				'' AS colorspace,
				'' AS xdpi,
				'' AS ydpi,
				'' AS unit,
				hashtag AS md5hash,
				vid_group AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
				WHERE vid_group in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND vid_group IS NOT NULL
				AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT /* #cachetokenvid#getrenditionsvid */
				'org' AS type,
				vid_id id, 
				vid_width width, 
				vid_height height, 
				path_to_asset,  
				cloud_url_org,
				vid_name_org filename_org,
				vid_extension extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(vid_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',host_id,'/',path_to_asset,'/',vid_name_org) AS local_url_org
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/'+ host_id + '/' + path_to_asset + '/' + vid_name_org AS local_url_org
				</cfif>,
				'' AS colorspace,
				'' AS xdpi,
				'' AS ydpi,
				'' AS unit,
				hashtag AS md5hash,
				vid_group AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
				WHERE vid_id in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND vid_group IS NULL
				AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT /* #cachetokenaud#getrenditionsaud */
				'rendition' AS type,
				aud_id id, 
				0 AS width, 
				0 AS height, 
				path_to_asset, 
				cloud_url_org,
				aud_name_org filename_org,
				aud_extension extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(aud_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',host_id,'/',path_to_asset,'/',aud_name_org) AS local_url_org
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + host_id + '/' + path_to_asset + '/' + aud_name_org AS local_url_org
				</cfif>,
				'' AS colorspace,
				'' AS xdpi,
				'' AS ydpi,
				'' AS unit,
				hashtag AS md5hash,
				aud_group AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
				WHERE aud_group in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND aud_group IS NOT NULL
				AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT /* #cachetokenaud#getrenditionsaud */
				'org' AS type,
				aud_id id, 
				0 AS width, 
				0 AS height, 
				path_to_asset, 
				cloud_url_org,
				aud_name_org filename_org,
				aud_extension extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(aud_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',host_id,'/',path_to_asset,'/',aud_name_org) AS local_url_org
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/'+ host_id + '/' + path_to_asset + '/' + aud_name_org AS local_url_org
				</cfif>,
				'' AS colorspace,
				'' AS xdpi,
				'' AS ydpi,
				'' AS unit,
				hashtag AS md5hash,
				aud_group AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
				WHERE aud_id in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND aud_group IS NULL
				AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">	
				UNION ALL
				SELECT 
				'org' AS type,
				file_id id, 
				0 AS width, 
				0 AS height, 
				path_to_asset, 
				cloud_url_org,
				file_name_org filename_org,
				file_extension extension,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(file_size as varchar(100)), '0')</cfif> AS size,
				<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/',host_id,'/',path_to_asset,'/',file_name_org) AS local_url_org
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/assets/' + host_id + '/'+ path_to_asset + '/' + file_name_org AS local_url_org
				</cfif>,
				'' AS colorspace,
				'' AS xdpi,
				'' AS ydpi,
				'' AS unit,
				hashtag AS md5hash,
				''AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#files
				WHERE file_id in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">	
				UNION ALL
				SELECT 
				'rendition' AS type,
				av_id id, 
				0 AS width, 
				0 AS height, 
				'' AS path_to_asset, 
				av_link_url AS cloud_url_org,
				av_link_title AS filename_org,
				av_type AS extension,
				'0' AS size,
				av_link_url AS local_url_org,
				'' AS colorspace,
				'' AS xdpi,
				'' AS ydpi,
				'' AS unit,
				hashtag AS md5hash,
				asset_id_r AS parentid
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#additional_versions
				WHERE asset_id_r in (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				</cfquery>
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

	<!--- Move files --->
	<cffunction name="move" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="assetid" type="string" required="true">
		<cfargument name="destination_folder" type="string" required="true">
		<cfargument name="source_folder" type="string" required="false" default="0">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Params --->
				<cfset var s = structNew()>
				<cfset s.folder_id = arguments.destination_folder>
				<!--- Check if assetid is all and folder id 0 --->
				<cfif arguments.assetid EQ "all" AND arguments.source_folder EQ 0>
					<!--- Feedback --->
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "Whoops! If you set the assetid to all you must supply a valid folder id!">
				<cfelse>
					<!--- If assetid is "all" we assume user wants to move all assets from sourcefolder to destinationfolder tbus select all file ids in this folder --->
					<cfif arguments.assetid EQ "all">
						<!--- Call folder CFC --->
						<cfinvoke component="global.cfc.folders" method="getallassetsinfolder" folder_id="#arguments.source_folder#" returnvariable="qry_files_in_folder" />
						<!--- Create a list --->
						<cfset s.file_id = valueList(qry_files_in_folder.id)>
					<cfelse>
						<cfset s.file_id = arguments.assetid>
					</cfif>
					<!--- Put the s.file_id into local var --->
					<cfset var localid = s.file_id>
					<!--- Chek that s.file_id is not empty --->
					<cfif s.file_id NEQ "">
						<!--- images --->
						<cfinvoke component="global.cfc.images" method="movethread" thestruct="#s#" />
						<!--- videos --->
						<cfinvoke component="global.cfc.videos" method="movethread" thestruct="#s#" />
						<!--- audios --->
						<cfinvoke component="global.cfc.audios" method="movethread" thestruct="#s#" />
						<cfset s.file_id = localid>
						<!--- files --->
						<cfinvoke component="global.cfc.files" method="movethread" thestruct="#s#" />
					</cfif>
					<!--- Feedback --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Asset(s) have been moved successfully">
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
	
	<!--- Convert assets to other formats --->
	<cffunction name="createrenditions" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="assetid" type="string" required="true">
		<cfargument name="assettype" type="string" required="true">
		<cfargument name="convertdata" type="string" required="true" hint="JSON with fields to for renditions">
		<cfargument name="colorspace" type="string" required="false">
		<cfparam name="arguments.link_kind" default="">
		<cfset var convertToList = "">
		<cfset arguments.thedpi = "">
		<!--- Check api key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var qry = "">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Set file id --->
				<cfset arguments.file_id = arguments.assetid>
				<!--- Deserialize the JSON back into an array --->
				<cfset thejson = DeserializeJSON(arguments.convertdata)>
				<!--- Get assetpath --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
					SELECT set2_path_to_assets
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
					WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid['#arguments.api_key#']#">
				</cfquery>
				<!--- Set assetpath --->
				<cfset arguments.assetpath = trim(qry.set2_path_to_assets)>
				<cfset arguments.thepath = expandPath("../../#application.razuna.api.host_path#/dam")>

				<cfif arguments.assettype eq "img">
					<cfset var assettable = "images">
				<cfelseif arguments.assettype eq "aud">
					<cfset var assettable= "audios">
				<cfelseif arguments.assettype eq "vid">
					<cfset var assettable = "videos">
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfset thexml.message = "Assettype '#arguments.assettype#' is not supported for this method. Valid assetypes are 'img','aud 'and 'vid'">
					<cfreturn thexml>
				</cfif>
				<!--- Get group for asset --->
				<cfquery datasource="#application.razuna.api.dsn#" name="getgrp">
					SELECT #arguments.assettype#_group
					FROM #application.razuna.api.prefix["#arguments.api_key#"]##assettable#
					WHERE #arguments.assettype#_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				</cfquery>
				<!--- Set the groupid variable if asset is a rendition. This will be stored in the group column for the asset later on.--->
				<cfset var grpid= evaluate("getgrp.#arguments.assettype#_group")>
				<cfif grpid neq "">
					<cfset "arguments.#arguments.assettype#_group_id" = grpid>
				</cfif>  

				<cfif application.razuna.api.storage EQ "amazon">
					<cfset arguments.awsbucket = application.razuna.awsbucket >
				</cfif>

				<!--- Check the assettype --->
				<cfif arguments.assettype EQ "img">
					<!--- Get the data from array (loop over the passed array) --->
					<cfloop index="x" from="1" to="#arrayLen(thejson)#">
						<cfloop index="y" from="1" to="#arrayLen(thejson)#">
							<cfif arrayIsDefined(thejson[x],y) AND y EQ 1>
								<cfset convertToList = listAppend(convertToList,"#thejson[x][y][2]#")>
								<cfset StructInsert(arguments, "#thejson[x][y+1][1]#", #thejson[x][y+1][2]#)>
								<cfset StructInsert(arguments, "#thejson[x][y+2][1]#", #thejson[x][y+2][2]#)>
								<cfset StructInsert(arguments, "#thejson[x][y+3][1]#", #thejson[x][y+3][2]#)>
								<cfset StructInsert(arguments, "#thejson[x][y+4][1]#", #thejson[x][y+4][2]#)>
							</cfif>
						</cfloop>
					</cfloop>
					<cfset arguments.convert_to = convertToList>
					<!--- Get image settings --->
					<cfinvoke component="global.cfc.settings" method="prefs_image" thestruct="#arguments#" returnvariable="arguments.qry_settings_image" />
					<!--- Convert images --->
					<cfinvoke component="global.cfc.images" method="convertImagethread" thestruct="#arguments#" returnvariable="thefileid" />
					<!--- Feedback --->
					<cfif thefileid NEQ "">
						<cfset thexml.responsecode = 0>
						<cfset thexml.message = "Asset has been converted successfully">
					<cfelse>
						<cfset thexml.responsecode = 1>
						<cfset thexml.message = "Whoops! Set a valid URL!">
					</cfif>
				<cfelseif arguments.assettype EQ "aud">
					<!--- Get the data from array (loop over the passed array) --->
					<cfloop index="x" from="1" to="#arrayLen(thejson)#">
						<cfloop index="y" from="1" to="#arrayLen(thejson)#">
							<cfif arrayIsDefined(thejson[x],y) AND x LTE #arrayLen(thejson)# AND y EQ 1>
								<cfset convertToList = listAppend(convertToList,"#thejson[x][y][2]#")>
								<cfset StructInsert(arguments, "#thejson[x][y+1][1]#", #thejson[x][y+1][2]#)>
							</cfif>
						</cfloop>
					</cfloop>
					<cfset arguments.convert_to = convertToList>
					<cfloop list="#convertToList#" index="format">
						<cfif NOT isDefined("arguments.convert_bitrate_#format#")>
							<cfthrow message="Must specify a bitrate parameter by passing the convert_bitrate_(format) as the second parameter in the JSON string. Leave it empty for FLAC and WAV files.">
						<cfelseif NOT isnumeric("#evaluate('arguments.convert_bitrate_#format#')#") AND (format EQ 'mp3' OR format EQ 'ogg')>
							<cfthrow message="Must specify a numeric bitrate for MP3 and OGG file types in the convert_bitrate_(format) parameter">
						</cfif>
					</cfloop>
					<!--- Get audio settings --->
					<cfinvoke component="global.cfc.settings" method="prefs_video" thestruct="#arguments#" returnvariable="arguments.qry_settings_audio" />
					<!--- Convert audios --->
					<cfinvoke component="global.cfc.audios" method="convertaudiothread" thestruct="#arguments#" returnvariable="thefileid" />
					<!--- Feedback --->
					<cfif thefileid NEQ "">
						<cfset thexml.responsecode = 0>
						<cfset thexml.message = "Asset has been converted successfully">
					<cfelse>
						<cfset thexml.responsecode = 1>
						<cfset thexml.message = "Whoops! Set a valid URL!">
					</cfif>
				<cfelseif arguments.assettype EQ "vid">
					<!--- Get the data from array (loop over the passed array) --->
					<cfloop index="x" from="1" to="#arrayLen(thejson)#">
						<cfloop index="y" from="1" to="#arrayLen(thejson)#">
							<cfif arrayIsDefined(thejson[x],y) AND x LTE #arrayLen(thejson)# AND y EQ 1>
								<cfset convertToList = listAppend(convertToList,"#thejson[x][y][2]#")>
								<cfset StructInsert(arguments, "#thejson[x][y+1][1]#", #thejson[x][y+1][2]#)>
								<cfset StructInsert(arguments, "#thejson[x][y+2][1]#", #thejson[x][y+2][2]#)>
							</cfif>
						</cfloop>
					</cfloop>
					<cfset arguments.convert_to = convertToList>
					<!--- Get video settings --->
					<cfinvoke component="global.cfc.settings" method="prefs_video" thestruct="#arguments#" returnvariable="arguments.qry_settings_video" />
					<!--- Convert videos --->
					<cfinvoke component="global.cfc.videos" method="convertvideo" thestruct="#arguments#" returnvariable="thefileid" />
					<!--- Feedback --->
					<cfif thefileid NEQ "">
						<cfset thexml.responsecode = 0>
						<cfset thexml.message = "Asset has been converted successfully">
					<cfelse>
						<cfset thexml.responsecode = 1>
						<cfset thexml.message = "Whoops! Set a valid URL!">
					</cfif>
				</cfif>
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Regenerate metedata for assets --->
	<cffunction name="regeneratemetadata" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="assetid" type="string" required="true">
		<cfargument name="assettype" type="string" required="true">
		<!--- Param --->
		<cfset arguments.newid = createuuid()>
		<cfset thexml = structNew()>
		<cfset thesuccess = 0>
		<cfset theunsuccess = 0>
		<cfset var invalid_assets = ""> <!--- intialize list to store invalid asset id's passed to function --->

		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Get exiftool.exe file path --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qryexif">
					SELECT  thepath
					FROM tools
					WHERE thetool = <cfqueryparam value="exiftool" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- Set the path of exiftool --->
				<cfif FindNoCase("Windows", server.os.name)>
					<cfset theexif = """#qryexif.thepath#/exiftool.exe""">
				<cfelse>
					<!--- Create directory --->
					<cfif !directoryExists("#application.razuna.api.thispath#/metadata")>
						<cfdirectory action="create" directory="#application.razuna.api.thispath#/metadata" mode="775">
					</cfif>
					<cfset theexif = "#qryexif.thepath#/exiftool">
					<!--- Set scripts --->
					<cfset thesh = "#application.razuna.api.thispath#/metadata/#arguments.newid#.sh">
				</cfif>
				<!--- Get assetpath --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qryassetpath">
					SELECT set2_path_to_assets
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
					WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid['#arguments.api_key#']#">
				</cfquery>
				<!--- Set assetpath --->
				<cfset assetpath = trim(qryassetpath.set2_path_to_assets)>
				<!--- IMAGES --->
				<cfif arguments.assettype EQ "img">
					<!--- Loop --->
					<cfloop list="#arguments.assetid#" index="i">
						<!--- Get details of asset --->
						<cfquery datasource="#application.razuna.api.dsn#" name="qrydetail">
							SELECT img_filename_org AS filename,path_to_asset,cloud_url_org 
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#images
							WHERE img_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<!--- Check success --->
						<cfif qrydetail.RecordCount NEQ 0>
							<cfset thesuccess = 1>
						<cfelse>
							<cfset theunsuccess = 1>
							<cfset invalid_assets = listappend(invalid_assets,i)>
						</cfif>
						<!--- Set source --->
						<cfif application.razuna.api.storage EQ "local">
							<cfset thesource = "#assetpath#/#application.razuna.api.hostid['#arguments.api_key#']#/#qrydetail.path_to_asset#/#qrydetail.filename#">
						<cfelse>
							<!--- Create directory --->
							<cfif !directoryExists("#application.razuna.api.thispath#/metadata/#i#")>
								<cfdirectory action="create" directory="#application.razuna.api.thispath#/metadata/#i#" mode="775">
							</cfif>
							<cfhttp method="get" url="#qrydetail.cloud_url_org#" file="#qrydetail.filename#" path="#application.razuna.api.thispath#/metadata/#i#">
							<cfset thesource = "#application.razuna.api.thispath#/metadata/#i#/#qrydetail.filename#">
						</cfif>
						<!--- Check windows --->
						<cfif FindNoCase("Windows", server.os.name)>
							<!--- Execute Script --->
							<cfexecute name="#theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" timeout="60" variable="img_meta" />
						<cfelse>
							<!--- Write Script --->
							<cffile action="write" file="#thesh#" output="#theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" mode="777">
							<!--- Execute Script --->
							<cfexecute name="#thesh#" timeout="60" variable="img_meta" />
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
						</cfif>
						<!--- Update metadata in images DB --->
						<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#images
							SET	img_meta = <cfqueryparam value="#img_meta#" cfsqltype="cf_sql_varchar">
							WHERE img_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<cfset "arguments.thetools.exiftool" = qryexif.thepath>
						<cfset arguments.thesource = thesource>
						<cfinvoke component="global.cfc.xmp" method="xmpparse" thestruct="#arguments#" returnvariable="arguments.thexmp" />
						<!--- Store XMP values in DB --->
						<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#xmp
							SET 
									asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="img">, 
									subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcsubjectcode#">, 
									creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.creator#">, 
									title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.title#">, 
									authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.authorstitle#">, 
									captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.descwriter#">, 
									ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcaddress#">, 
									category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.category#">, 
									supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.categorysub#">, 
									urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.urgency#">,
									description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.description#">, 
									ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptccity#">, 
									ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptccountry#">, 
									location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptclocation#">, 
									ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptczip#">, 
									ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcemail#">, 
									ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcwebsite#">, 
									citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcphone#">, 
									intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcintelgenre#">, 
									instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcinstructions#">, 
									source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcsource#">, 
									usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcusageterms#">, 
									copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.copystatus#">, 
									transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcjobidentifier#">, 
									webstatement  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.copyurl#">, 
									headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcheadline#">, 
									datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcdatecreated#">, 
									city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcimagecity#">, 
									ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcimagestate#">, 
									country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcimagecountry#">, 
									countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcimagecountrycode#">, 
									scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcscene#">, 
									state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptcstate#">, 
									credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.iptccredit#">, 
									rights = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.copynotice#">, 
									colorspace = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.colorspace#">, 
									xres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.xres#">, 
									yres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.yres#">, 
									resunit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thexmp.resunit#">, 
									host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
							WHERE id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">
						</cfquery>
					</cfloop>
				<!--- VIDEOS --->
				<cfelseif arguments.assettype EQ "vid">
					<!--- Loop --->
					<cfloop list="#arguments.assetid#" index="i">
						<!--- Get details of asset --->
						<cfquery datasource="#application.razuna.api.dsn#" name="qrydetail">
							SELECT vid_name_org AS filename,path_to_asset,cloud_url_org 
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
							WHERE vid_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<!--- Check success --->
						<cfif qrydetail.RecordCount NEQ 0>
							<cfset thesuccess = 1>
						<cfelse>
							<cfset theunsuccess = 1>
							<cfset invalid_assets = listappend(invalid_assets,i)>
						</cfif>
						<!--- Set source --->
						<cfif application.razuna.api.storage EQ "local">
							<cfset thesource = "#assetpath#/#application.razuna.api.hostid['#arguments.api_key#']#/#qrydetail.path_to_asset#/#qrydetail.filename#">
						<cfelse>
							<!--- Create directory --->
							<cfif !directoryExists("#application.razuna.api.thispath#/metadata/#i#")>
								<cfdirectory action="create" directory="#application.razuna.api.thispath#/metadata/#i#" mode="775">
							</cfif>
							<cfhttp method="get" url="#qrydetail.cloud_url_org#" file="#qrydetail.filename#" path="#application.razuna.api.thispath#/metadata/#i#">
							<cfset thesource = "#application.razuna.api.thispath#/metadata/#i#/#qrydetail.filename#">
						</cfif>
						<!--- Check windows --->
						<cfif FindNoCase("Windows", server.os.name)>
							<!--- Execute Script --->
							<cfexecute name="#theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" timeout="60" variable="vid_meta" />
						<cfelse>
							<!--- Write Script --->
							<cffile action="write" file="#thesh#" output="#theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" mode="777">
							<!--- Execute Script --->
							<cfexecute name="#thesh#" timeout="60" variable="vid_meta" />
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
						</cfif>
						<!--- Update metadata in videos DB --->
						<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#videos
							SET	vid_meta = <cfqueryparam value="#vid_meta#" cfsqltype="cf_sql_varchar">
							WHERE vid_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
					</cfloop>
				<!--- AUDIOS --->
				<cfelseif arguments.assettype EQ "aud">
					<!--- Loop --->
					<cfloop list="#arguments.assetid#" index="i">
						<!--- Get details of asset --->
						<cfquery datasource="#application.razuna.api.dsn#" name="qrydetail">
							SELECT aud_name_org AS filename,path_to_asset,cloud_url_org 
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
							WHERE aud_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<!--- Check success --->
						<cfif qrydetail.RecordCount NEQ 0>
							<cfset thesuccess = 1>
						<cfelse>
							<cfset theunsuccess = 1>
							<cfset invalid_assets = listappend(invalid_assets,i)>
						</cfif>
						<!--- Set source --->
						<cfif application.razuna.api.storage EQ "local">
							<cfset thesource = "#assetpath#/#application.razuna.api.hostid['#arguments.api_key#']#/#qrydetail.path_to_asset#/#qrydetail.filename#">
						<cfelse>
							<!--- Create directory --->
							<cfif !directoryExists("#application.razuna.api.thispath#/metadata/#i#")>
								<cfdirectory action="create" directory="#application.razuna.api.thispath#/metadata/#i#" mode="775">
							</cfif>
							<cfhttp method="get" url="#qrydetail.cloud_url_org#" file="#qrydetail.filename#" path="#application.razuna.api.thispath#/metadata/#i#">
							<cfset thesource = "#application.razuna.api.thispath#/metadata/#i#/#qrydetail.filename#">
						</cfif>
						<!--- Check windows --->
						<cfif FindNoCase("Windows", server.os.name)>
							<!--- Execute Script --->
							<cfexecute name="#theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" timeout="60" variable="aud_meta" />
						<cfelse>
							<!--- Write Script --->
							<cffile action="write" file="#thesh#" output="#theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" mode="777">
							<!--- Execute Script --->
							<cfexecute name="#thesh#" timeout="60" variable="aud_meta" />
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
						</cfif>
						<!--- Update metadata in audios DB --->
						<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#audios
							SET	aud_meta = <cfqueryparam value="#aud_meta#" cfsqltype="cf_sql_varchar">
							WHERE aud_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
					</cfloop>
				<!--- FILES --->
				<cfelseif arguments.assettype EQ "doc">
					<!--- Loop --->
					<cfloop list="#arguments.assetid#" index="i">
						<!--- Get details of asset --->
						<cfquery datasource="#application.razuna.api.dsn#" name="qrydetail">
							SELECT file_name_org AS filename,path_to_asset,cloud_url_org 
							FROM #application.razuna.api.prefix["#arguments.api_key#"]#files
							WHERE file_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
						<!--- Check success --->
						<cfif qrydetail.RecordCount NEQ 0>
							<cfset thesuccess = 1>
						<cfelse>
							<cfset theunsuccess = 1>
							<cfset invalid_assets = listappend(invalid_assets,i)>
						</cfif>
						<!--- Set source --->
						<cfif application.razuna.api.storage EQ "local">
							<cfset thesource = "#assetpath#/#application.razuna.api.hostid['#arguments.api_key#']#/#qrydetail.path_to_asset#/#qrydetail.filename#">
						<cfelse>
							<!--- Create directory --->
							<cfif !directoryExists("#application.razuna.api.thispath#/metadata/#i#")>
								<cfdirectory action="create" directory="#application.razuna.api.thispath#/metadata/#i#" mode="775">
							</cfif>
							<cfhttp method="get" url="#qrydetail.cloud_url_org#" file="#qrydetail.filename#" path="#application.razuna.api.thispath#/metadata/#i#">
							<cfset thesource = "#application.razuna.api.thispath#/metadata/#i#/#qrydetail.filename#">
						</cfif>
						<!--- Check windows --->
						<cfif FindNoCase("Windows", server.os.name)>
							<!--- Execute Script --->
							<cfexecute name="#theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" timeout="60" variable="file_meta" />
						<cfelse>
							<!--- Write Script --->
							<cffile action="write" file="#thesh#" output="#theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #thesource#" mode="777">
							<!--- Execute Script --->
							<cfexecute name="#thesh#" timeout="60" variable="file_meta" />
							<!--- Delete scripts --->
							<cffile action="delete" file="#thesh#">
						</cfif>
						<!--- Update metadata in files DB --->
						<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.api_key#"]#files
							SET	file_meta = <cfqueryparam value="#aud_meta#" cfsqltype="cf_sql_varchar">
							WHERE file_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
							AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
						</cfquery>
					</cfloop>
				</cfif>
				<!--- Remove directory --->
				<cfif directoryExists("#application.razuna.api.thispath#/metadata")>
					<cfdirectory action="delete" directory="#application.razuna.api.thispath#/metadata" recurse="true">
				</cfif>
				<!--- Feedback --->
				<cfif thesuccess AND theunsuccess EQ 0>
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Metadata successfully stored">
				<cfelse>
					<cfset thexml.responsecode = 1>
					<cfif len(invalid_assets) neq 0>
						<cfset thexml.message = "The following assetid's were not found: #invalid_assets#. For the rest the metadata was successfully regenerated and stored">
					<cfelse>
						<cfset thexml.message = "Whoops! Set a valid URL!">
					</cfif>
				</cfif>
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml />	
	</cffunction>

	<cffunction name="getpdfimages" returntype="query" returnformat="JSON" access="remote" hint="Returns data for PDF images that have been extracted from PDF pages">
		<cfargument name="api_key" required="true" type="string" hint="API Key of user">
		<cfargument name="assetid" required="true" type="string" hint="Unique ID of asset">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.assetid)>
			<!--- If user has access --->
			<cfif folderaccess EQ "R"  OR folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Instantiate local vars --->
				<cfset var thestruct = structnew()>
				<cfset var theqry= querynew("responsecode,message")>
				<!--- Initialize the query object with a default responsecode. Query object will be overwritten if no errors are encountered. --->
				<cfset queryaddrow(theqry,1)>
				<cfset querysetcell(theqry,"responsecode","1")>
				<cfobject component="global.cfc.files" name="fobj"> <!--- Instantiate a files object --->
				<cfobject component="global.cfc.settings" name="sobj"> <!--- Instantiate a setting object --->
				<cfset thestruct.assetpath = sobj.assetpath()><!--- Get path of asset --->
				<cfset thestruct.file_id = arguments.assetid><!---  Put assetid in struct to pass to main function pdfjpgs --->
				<!--- Make query to get the Local URL for asset --->
				<cfquery datasource="#application.razuna.api.dsn#" name="getfileinfo" cachedwithin="1" region="razcache">
					SELECT file_extension, path_to_asset, host_id	
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#files f 
					WHERE f.file_id =<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				</cfquery>
				
				<cfif getfileinfo.recordcount eq 0><!--- Check if file could not be found --->	
					<cfset querysetcell(theqry,"message","Asset with the given assetid could not be found. Please check assetid and try again.")>
					<cfreturn theqry><!--- Check if file is not of type pdf --->
				<cfelseif getfileinfo.file_extension neq 'pdf'>	
					<cfset querysetcell(theqry,"message","Asset has to be of type PDF")>
					<cfreturn theqry>
				</cfif>
				<cftry>
					<cfset var pdfqry = fobj.pdfjpgs(thestruct)> <!--- Call function to retrieve jpg information for the pdf --->
					<cfcatch type="any">
						<cfset querysetcell(theqry,"message","Error Occurred: #cfcatch.message#, Detail: #cfcatch.detail#")>
						<cfreturn theqry>
					</cfcatch>
				</cftry>
				<!--- Form the URL path to asset  --->
				<cfset localurl = application.razuna.api.thehttp & cgi.HTTP_HOST & application.razuna.api.dynpath & "/assets/" & getfileinfo.host_id  & "/" & getfileinfo.path_to_asset & "/razuna_pdf_images/">
				<!--- Finally query the pdf jpg information retrieved and extract the information to be returned from it --->
				<cfquery name="theqry" dbtype="query">
					SELECT '#arguments.assetid#' assetid, name, directory local_directory, size, '#localurl#' + name as local_url_org  FROM pdfqry.qry_pdfjpgs
				</cfquery>
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset theqry = noaccess()>
			</cfif>
		<cfelse><!---  if session not validated --->
			<cfset theqry = timeout()>
		</cfif>
		<cfreturn theqry>
	</cffunction>	    
</cfcomponent>