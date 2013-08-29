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
		<!--- Check to see if session is valid --->
		<cfif thesession>
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
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_thumb,
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/' + i.img_filename_org AS local_url_org,
					'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/thumb_'+ i.img_id + '.' + i.thumb_extension AS local_url_thumb,
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
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',a.path_to_asset,'/',a.aud_name_org) AS local_url_org,
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + a.path_to_asset + '/' + a.aud_name_org AS local_url_org,
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
					concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',f.path_to_asset,'/',f.file_name_org) AS local_url_org,
				<cfelseif application.razuna.api.thedatabase EQ "mssql">
					'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + f.path_to_asset + '/' + f.file_name_org AS local_url_org,
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
		<!--- Check to see if session is valid --->
		<cfif thesession>
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
		<cfargument name="assettype" type="string" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get Cachetoken --->
			<cfset var cachetokenvid = getcachetoken(arguments.api_key,"videos")>
			<cfset var cachetokenimg = getcachetoken(arguments.api_key,"images")>
			<cfset var cachetokenaud = getcachetoken(arguments.api_key,"audios")>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
				<cfif arguments.assettype EQ "img">
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
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/' + i.img_filename_org AS local_url_org,
					</cfif>
					x.colorspace,
					x.xres AS xdpi,
					x.yres AS ydpi,
					x.resunit AS unit,
					i.hashtag AS md5hash
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
					WHERE i.img_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
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
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/' + i.img_filename_org AS local_url_org,
					</cfif>
					x.colorspace,
					x.xres AS xdpi,
					x.yres AS ydpi,
					x.resunit AS unit,
					i.hashtag AS md5hash
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
					WHERE i.img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
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
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_org,
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/thumb_'+ i.img_id + '.' + i.thumb_extension AS local_url_org,
					</cfif>
					x.colorspace,
					x.xres AS xdpi,
					x.yres AS ydpi,
					x.resunit AS unit,
					i.hashtag AS md5hash
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#xmp x ON x.id_r = i.img_id
					WHERE i.img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
					AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				<cfelseif arguments.assettype EQ "vid">
					SELECT /* #cachetokenvid#getrenditionsvid */
					'rendition' as type,
					vid_id id, 
					vid_width width, 
					vid_height height, 
					path_to_asset,  
					cloud_url_org,
					vid_name_org filename_org,
					vid_extension extension,
					hashtag AS md5hash,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(vid_size as varchar(100)), '0')</cfif> AS size,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',path_to_asset,'/',vid_name_org) AS local_url_org
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + path_to_asset + '/' + vid_name_org AS local_url_org
					</cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
					WHERE vid_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
					AND vid_group IS NOT NULL
					AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					UNION ALL
					SELECT /* #cachetokenvid#getrenditionsvid */
					'org' as type,
					vid_id id, 
					vid_width width, 
					vid_height height, 
					path_to_asset,  
					cloud_url_org,
					vid_name_org filename_org,
					vid_extension extension,
					hashtag AS md5hash,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(vid_size as varchar(100)), '0')</cfif> AS size,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',path_to_asset,'/',vid_name_org) AS local_url_org
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + path_to_asset + '/' + vid_name_org AS local_url_org
					</cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
					WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
					AND vid_group IS NULL
					AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				<cfelseif arguments.assettype EQ "aud">
					SELECT /* #cachetokenaud#getrenditionsaud */
					'rendition' as type,
					aud_id id, 
					0 AS width, 
					0 AS height, 
					path_to_asset, 
					cloud_url_org,
					aud_name_org filename_org,
					aud_extension extension,
					hashtag AS md5hash,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(aud_size as varchar(100)), '0')</cfif> AS size,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',path_to_asset,'/',aud_name_org) AS local_url_org
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + path_to_asset + '/' + aud_name_org AS local_url_org
					</cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
					WHERE aud_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
					AND aud_group IS NOT NULL
					AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
					UNION ALL
					SELECT /* #cachetokenaud#getrenditionsaud */
					'org' as type,
					aud_id id, 
					0 AS width, 
					0 AS height, 
					path_to_asset, 
					cloud_url_org,
					aud_name_org filename_org,
					aud_extension extension,
					hashtag AS md5hash,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(aud_size as varchar(100)), '0')</cfif> AS size,
					<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
						concat('#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',path_to_asset,'/',aud_name_org) AS local_url_org
					<cfelseif application.razuna.api.thedatabase EQ "mssql">
						'#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + path_to_asset + '/' + aud_name_org AS local_url_org
					</cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
					WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
					AND aud_group IS NULL
					AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				</cfif>
				<cfif arguments.assettype NEQ "doc">UNION ALL</cfif>
				SELECT 
				'rendition' as type,
				av_id id, 
				0 AS width, 
				0 AS height, 
				'' AS path_to_asset, 
				av_link_url AS cloud_url_org,
				av_link_title AS filename_org,
				av_type AS extension,
				hashtag AS md5hash,
				'0' AS size,
				av_link_url AS local_url_org
				<cfif arguments.assettype EQ "img">
					,
					'' AS colorspace,
					'' AS xdpi,
					'' AS ydpi,
					'' AS unit
				</cfif>
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#additional_versions
				WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
			</cfquery>
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
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
    
</cfcomponent>