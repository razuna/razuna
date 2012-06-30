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
	
	<!--- Set application values --->
	<cfset application.razuna.storage = application.razuna.api.storage>
	<cfset application.razuna.datasource = application.razuna.api.dsn>
	<cfset application.razuna.thedatabase = application.razuna.api.thedatabase>
	
	<!--- Asset: Get info --->
	<cffunction name="getasset" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="assetid" required="true" type="string">
		<cfargument name="assettype" required="true" type="string">
		<!--- Check key --->
		<cfset thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Param --->
			<cfset thestorage = "">
			<!--- Images --->
			<cfif arguments.assettype EQ "img">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1">
				SELECT /* #session.cachetoken#getassetimg */
				i.img_id id, 
				i.img_filename filename, 
				i.folder_id_r folder_id, 
				i.img_extension extension,
				i.img_filename_org filename_org, 
				i.thumb_extension extension_thumb, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(i.img_size, 0))</cfif> AS size, 
				i.img_width AS width,
				i.img_height AS height,
				it.img_description description, 
				it.img_keywords keywords,
				i.path_to_asset,
				i.cloud_url,
				i.cloud_url_org,
				i.img_meta metadata,
				(
					SELECT 
						CASE 
							WHEN count(img_id) = 0 THEN 'false'
							ELSE 'true'
						END AS test
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images isub
					WHERE isub.img_group = i.img_id
				) as hassubassets,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_thumb
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
				WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				</cfquery>
			<!--- Videos --->
			<cfelseif arguments.assettype EQ "vid">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1">
				SELECT /* #session.cachetoken#getassetvid */
				v.vid_id id, 
				v.vid_filename filename, 
				v.folder_id_r folder_id, 
				v.vid_extension extension, 
				v.vid_name_image as video_preview,
				v.vid_name_org filename_org, 
				v.vid_extension extension, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(v.vid_size, 0))</cfif> AS size, 
				v.vid_width AS width,
				v.vid_height AS height,
				vt.vid_description description, 
				vt.vid_keywords keywords,
				v.path_to_asset,
				v.cloud_url,
				v.cloud_url_org,
				v.vid_meta metadata,
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
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_image) AS local_url_preview
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos v 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
				WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				</cfquery>
			<!--- Audios --->
			<cfelseif arguments.assettype EQ "aud">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1">
				SELECT /* #session.cachetoken#getassetaud */
				a.aud_id id, 
				a.aud_name filename, 
				a.folder_id_r folder_id, 
				a.aud_extension extension, 
				a.aud_name_org filename_org,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(a.aud_size, 0))</cfif> AS size, 
				0 AS width,
				0 AS height,
				aut.aud_description description, 
				aut.aud_keywords keywords,
				a.path_to_asset,
				a.cloud_url,
				a.cloud_url_org,
				a.aud_meta metadata,
				(
					SELECT 
						CASE 
							WHEN count(aud_id) = 0 THEN 'false'
							ELSE 'true'
						END AS test
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios asub
					WHERE asub.aud_group = a.aud_id
				) as subassets,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',a.path_to_asset,'/',a.aud_name_org) AS local_url_org
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios a 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
				WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				</cfquery>
			<!--- Documents --->
			<cfelseif arguments.assettype EQ "doc">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1">
				SELECT /* #session.cachetoken#getassetfile */
				f.file_id id, 
				f.file_name filename, 
				f.folder_id_r folder_id, 
				f.file_extension extension, 
				f.file_name_org filename_org, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(f.file_size, 0))</cfif> AS size, 
				0 AS width,
				0 AS height,
				ft.file_desc description, 
				ft.file_keywords keywords,
				f.path_to_asset,
				f.cloud_url,
				f.cloud_url_org,
				f.file_meta metadata,
				'false' as subassets,
				concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',f.path_to_asset,'/',f.file_name_org) AS local_url_org
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#files f 
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
				WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
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
				<cfset thexml = querynew("responsecode,totalassetscount,calledwith")>
				<cfset queryaddrow(thexml,1)>
				<cfset querysetcell(thexml,"responsecode","1")>
				<cfset querysetcell(thexml,"totalassetscount",qry.recordcount)>
				<cfset querysetcell(thexml,"calledwith",arguments.assetid)>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
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
		<cfset thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set db and id --->
			<cfif arguments.assettype EQ "img">
				<cfset var thedb = "xmp">
				<cfset var theidr = "id_r">
			<cfelseif arguments.assettype EQ "doc">
				<cfset var thedb = "files_xmp">
				<cfset var theidr = "asset_id_r">
			</cfif>
			<!--- Loop over the assetid --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qrymeta">
			SELECT #arguments.assetmetadata#
			FROM #application.razuna.api.prefix["#arguments.api_key#"]##thedb#
			WHERE #theidr# IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#" list="Yes">)
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="qrymeta">
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
		<cfset thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set db and id --->
			<cfif arguments.assettype EQ "img">
				<cfset var thedb = "images_text">
				<cfset var theid = "img_id">
				<cfset var theidr = "img_id_r">
				<cfset var lucenecategory = "img">
				<cfset var cachetype = "images">
			<cfelseif arguments.assettype EQ "vid">
				<cfset var thedb = "videos_text">
				<cfset var theid = "vid_id">
				<cfset var theidr = "vid_id_r">
				<cfset var lucenecategory = "vid">
				<cfset var cachetype = "videos">
			<cfelseif arguments.assettype EQ "aud">
				<cfset var thedb = "audios_text">
				<cfset var theid = "aud_id">
				<cfset var theidr = "aud_id_r">
				<cfset var lucenecategory = "aud">
				<cfset var cachetype = "audios">
			<cfelse>
				<cfset var thedb = "files_desc">
				<cfset var theid = "file_id">
				<cfset var theidr = "file_id_r">
				<cfset var lucenecategory = "doc">
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
					<cfif #thejson[x][1]# CONTAINS "_">
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
				</cfif>
				<!--- Initiate the index --->
				<cfinvoke component="global.cfc.lucene" method="index_update_api" dsn="#application.razuna.api.dsn#" hostid="#application.razuna.api.hostid["#arguments.api_key#"]#" prefix="#application.razuna.api.prefix["#arguments.api_key#"]#" assetid="#i#" assetcategory="#lucenecategory#" userid="#application.razuna.api.userid["#arguments.api_key#"]#">
			</cfloop>
			<!--- Flush cache --->
			<cfset session.cachetoken = "#arguments.api_key##createuuid()#">
			<cfinvoke component="global.cfc.extQueryCaching" method="resetcachetoken" type="#cachetype#" />
			<!--- Feedback --->
			<cfset thexml.responsecode = 0>
			<cfset thexml.message = "Metadata successfully stored">
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" type="s" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>	
	
    <!--- Delete --->
	<cffunction name="remove" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="assetid" required="true">
    	<!--- Check key --->
		<cfset thesession = checkdb(arguments.api_key)>
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
			<cfinvoke component="authentication" method="timeout" type="s" returnvariable="thexml">
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
		<cfset thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1">
				<cfif arguments.assettype EQ "img">
					SELECT /* #session.cachetoken#getrenditionsimg */
					img_id id, 
					img_width width, 
					img_height height, 
					path_to_asset, 
					cloud_url_org,
					img_filename_org filename_org,
					img_extension extension,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(img_size, 0))</cfif> AS size,
					concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',path_to_asset,'/',img_filename_org) AS local_url_org
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images
					WHERE img_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				<cfelseif arguments.assettype EQ "vid">
					SELECT /* #session.cachetoken#getrenditionsvid */
					vid_id id, 
					vid_width width, 
					vid_height height, 
					path_to_asset,  
					cloud_url_org,
					vid_name_org filename_org,
					vid_extension extension,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(vid_size, 0))</cfif> AS size,
					concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',path_to_asset,'/',vid_name_org) AS local_url_org
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
					WHERE vid_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				<cfelseif arguments.assettype EQ "aud">
					SELECT /* #session.cachetoken#getrenditionsaud */
					aud_id id, 
					0 AS width, 
					0 AS height, 
					path_to_asset, 
					cloud_url_org,
					aud_name_org filename_org,
					aud_extension extension,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(aud_size, 0))</cfif> AS size,
					concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',path_to_asset,'/',aud_name_org) AS local_url_org
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
					WHERE aud_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
				</cfif>
				UNION ALL
				SELECT 
				av_id id, 
				0 AS width, 
				0 AS height, 
				"" AS path_to_asset, 
				av_link_url AS cloud_url_org,
				av_link_title AS filename_org,
				av_type AS extension,
				0 AS size,
				av_link_url AS local_url_org
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#additional_versions
				WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#">
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

    
</cfcomponent>