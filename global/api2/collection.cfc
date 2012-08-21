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
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Param --->
			<cfset thestorage = "">
			<!--- Query which file are in this collection --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry_col" cachedwithin="1" region="razcache">
			SELECT /* #application.razuna.api.cachetoken["#arguments.api_key#"]#getassets1 */ file_id_r
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files ct
			WHERE ct.col_id_r = <cfqueryparam value="#arguments.collectionid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- If above qry return records --->
			<cfif qry_col.recordcount NEQ 0>
				<!--- Query the files --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
				SELECT  /* #application.razuna.api.cachetoken["#arguments.api_key#"]#getassets2 */
				i.img_id id, 
				i.img_filename filename, 
				i.folder_id_r folder_id, 
				i.img_extension extension,
				i.thumb_extension extension_thumb, 
				'dummy' as video_image, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(i.img_size, 0))</cfif> AS size,
				i.img_width AS width,
				i.img_height AS height,
				i.img_filename_org filename_org, 
				'img' as kind, 
				it.img_description description, 
				it.img_keywords keywords,
				i.path_to_asset,
				i.cloud_url,
				i.cloud_url_org,
				(
					SELECT 
						CASE 
							WHEN count(img_id) = 0 THEN 'false'
							ELSE 'true'
						END AS test
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images isub
					WHERE isub.img_group = i.img_id
				) as subassets,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_thumb
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
				WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND (i.img_group IS NULL OR i.img_group = '')
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				AND i.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				UNION ALL
				SELECT 
				v.vid_id id, 
				v.vid_filename filename, 
				v.folder_id_r folder_id, 
				v.vid_extension extension, 
				'0' as extension_thumb,
				v.vid_name_image as video_image, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(v.vid_size, 0))</cfif> AS size,
				v.vid_width AS width,
				v.vid_height AS height, 
				v.vid_name_org filename_org,
				'vid' as kind,
				vt.vid_description description, 
				vt.vid_keywords keywords,
				v.path_to_asset,
				v.cloud_url,
				v.cloud_url_org,
				(
					SELECT 
						CASE 
							WHEN count(vid_id) = 0 THEN 'false'
							ELSE 'true'
						END AS test
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos vsub
					WHERE vsub.vid_group = v.vid_id
				) as subassets,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_org) AS local_url_org,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_image) AS local_url_thumb
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos v 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
				WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND (v.vid_group IS NULL OR v.vid_group = '')
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				AND v.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				UNION ALL
				<!--- Audios --->
				SELECT 
				a.aud_id id, 
				a.aud_name filename, 
				a.folder_id_r folder_id, 
				a.aud_extension extension,
				'0' extension_thumb, 
				'dummy' as video_image,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(a.aud_size, 0))</cfif> AS size,
				0 AS width,
				0 AS height,
				a.aud_name_org filename_org, 
				'aud' as kind, 
				aut.aud_description description, 
				aut.aud_keywords keywords,
				a.path_to_asset,
				a.cloud_url,
				a.cloud_url_org,
				(
					SELECT 
						CASE 
							WHEN count(aud_id) = 0 THEN 'false'
							ELSE 'true'
						END AS test
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios asub
					WHERE asub.aud_group = a.aud_id
				) as subassets,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',a.path_to_asset,'/',a.aud_name_org) AS local_url_org,
				'0' as local_url_thumb
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios a 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
				WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND (a.aud_group IS NULL OR a.aud_group = '')
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				AND a.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				UNION ALL
				SELECT 
				f.file_id id, 
				f.file_name filename, 
				f.folder_id_r folder_id, 
				f.file_extension extension, 
				'0' as extension_thumb, 
				'dummy' as video_image, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(f.file_size, 0))</cfif> AS size,
				0 AS width,
				0 AS height,
				f.file_name_org filename_org, 
				f.file_type as kind, 
				ft.file_desc description, 
				ft.file_keywords keywords,
				f.path_to_asset,
				f.cloud_url,
				f.cloud_url_org,
				'false' as subassets,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',f.path_to_asset,'/',f.file_name_org) AS local_url_org,
				'0' as local_url_thumb
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#files f 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
				WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				AND f.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
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
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
			SELECT /* #application.razuna.api.cachetoken["#arguments.api_key#"]#getcollections */ c.col_id, c.change_date, ct.col_name, 
				(
					SELECT count(file_id_r) 
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
					WHERE col_id_r = c.col_id 
					AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img">
				) as totalimg,
				(
					SELECT count(file_id_r) 
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
					WHERE col_id_r = c.col_id 
					AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="vid">
				) as totalvid,
				(
					SELECT count(file_id_r) 
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
					WHERE col_id_r = c.col_id
					AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="doc">
				) as totaldoc,
				(
					SELECT count(file_id_r) 
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files 
					WHERE col_id_r = c.col_id 
					AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="aud">
				) as totalaud,
				(
					SELECT count(file_id_r)
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections_ct_files
					WHERE col_id_r = c.col_id
				)  as totalassets
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#collections c
			LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#collections_text ct ON c.col_id = ct.col_id_r AND ct.lang_id_r = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
			WHERE c.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folderid#">
			AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
			ORDER BY lower(ct.col_name)
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml />
	</cffunction>
	
</cfcomponent>