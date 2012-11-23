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
	<cffunction name="searchassets" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="searchfor" type="string" required="true">
		<cfargument name="show" type="string" required="false" default="all">
		<cfargument name="doctype" type="string" required="false" default="">
		<cfargument name="datecreate" type="string" required="false" default="">
		<cfargument name="datechange" type="string" required="false" default="">
		<cfargument name="folderid" type="string" required="false" default="">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If we are on MS SQL the date has to be formated differently --->
			<cfif application.razuna.api.thedatabase EQ "mssql">
				<!--- Set the counter --->
				<cfset var thecountercreate = 1>
				<cfset var thecounterchange = 1>
				<cfif arguments.datecreate NEQ "">
					<cfloop list="#arguments.datecreate#" delimiters="-" index="i">
						<cfif thecountercreate EQ 1>
							<cfset var the_create_year = i>
						<cfelseif thecountercreate EQ 2>
							<cfset var the_create_month = i>
						<cfelseif thecountercreate EQ 3>
							<cfset var the_create_day = i>
						</cfif>
						<!--- Increase the counter --->
						<cfset var thecountercreate = thecountercreate + 1>
					</cfloop>
				</cfif>
				<cfif arguments.datechange NEQ "">
					<cfloop list="#arguments.datechange#" delimiters="-" index="i">
						<cfif thecounterchange EQ 1>
							<cfset var the_change_year = i>
						<cfelseif thecounterchange EQ 2>
							<cfset var the_change_month = i>
						<cfelseif thecounterchange EQ 3>
							<cfset var the_change_day = i>
						</cfif>
						<!--- Increase the counter --->
						<cfset var thecounterchange = thecounterchange + 1>
					</cfloop>
				</cfif>
			</cfif>
			<!--- Params --->
			<cfset var imgc = false>
			<cfset var vidc = false>
			<cfset var audc = false>
			<cfset var docc = false>
			<!--- Images --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "img">
				<!--- Search in Lucene --->
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="img" hostid="#application.razuna.api.hostid["#arguments.api_key#"]#" returnvariable="qryluceneimg">
				<!--- If lucene returns no records --->
				<cfif qryluceneimg.recordcount NEQ 0>
					<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
					<cfquery dbtype="query" name="cattreeimg">
					SELECT categorytree
					FROM qryluceneimg
					WHERE categorytree != ''
					GROUP BY categorytree
					ORDER BY categorytree
					</cfquery>
				</cfif>
			</cfif>
			<!--- Videos --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "vid">
				<!--- Search in Lucene --->
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="vid" hostid="#application.razuna.api.hostid["#arguments.api_key#"]#" returnvariable="qrylucenevid">
				<!--- If lucene returns no records --->
				<cfif qrylucenevid.recordcount NEQ 0>
					<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
					<cfquery dbtype="query" name="cattreevid">
					SELECT categorytree
					FROM qrylucenevid
					WHERE categorytree != ''
					GROUP BY categorytree
					ORDER BY categorytree
					</cfquery>
				</cfif>
			</cfif>
			<!--- Audios --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "aud">
				<!--- Search in Lucene --->
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="aud" hostid="#application.razuna.api.hostid["#arguments.api_key#"]#" returnvariable="qryluceneaud">
				<!--- If lucene returns no records --->
				<cfif qryluceneaud.recordcount NEQ 0>
					<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
					<cfquery dbtype="query" name="cattreeaud">
					SELECT categorytree
					FROM qryluceneaud
					WHERE categorytree != ''
					GROUP BY categorytree
					ORDER BY categorytree
					</cfquery>
				</cfif>
			</cfif>
			<!--- Doc --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "doc">
				<!--- Search in Lucene --->
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="doc" hostid="#application.razuna.api.hostid["#arguments.api_key#"]#" returnvariable="qrylucenedoc">
				<!--- If lucene returns no records --->
				<cfif qrylucenedoc.recordcount NEQ 0>
					<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
					<cfquery dbtype="query" name="cattreedoc">
					SELECT categorytree
					FROM qrylucenedoc
					WHERE categorytree != ''
					GROUP BY categorytree
					ORDER BY categorytree
					</cfquery>
				</cfif>
			</cfif>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				<!--- Images --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "img">
					<cfset imgc = true>
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_id as varchar), '0')</cfif> id, 
					i.img_filename filename, 
					i.folder_id_r folder_id, 
					i.img_extension extension, 
					'dummy' as video_image,
					i.img_filename_org filename_org, 
					'img' as kind, 
					i.thumb_extension extension_thumb, 
					i.path_to_asset, 
					i.cloud_url, 
					i.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar), '0')</cfif> AS size,
					i.img_width AS width,
					i.img_height AS height,
					it.img_description description, 
					it.img_keywords keywords,
					i.img_create_time dateadd,
					i.img_change_time datechange,
                    <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
					    concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
					    concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_thumb
                    <cfelseif application.razuna.api.thedatabase EQ "mssql">
                        'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/'  + i.img_filename_org AS local_url_org,
                        'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + i.path_to_asset + '/' + 'thumb_' + i.img_id + '.' + i.thumb_extension AS local_url_thumb
                    </cfif>
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#images i 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
					WHERE i.img_id IN (<cfif qryluceneimg.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreeimg.categorytree)#" list="Yes"></cfif>)
					AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					AND (i.img_group IS NULL OR i.img_group = '')
					<!--- Only if we have dates --->
					<cfif arguments.datecreate NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, i.img_create_time) = #the_create_year#
							AND DATEPART(mm, i.img_create_time) = #the_create_month#
							AND DATEPART(dd, i.img_create_time) = #the_create_day#)
						<cfelse>
							AND i.img_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datecreate#%">
						</cfif>
					</cfif>
					<cfif arguments.datechange NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, i.img_change_time) = #the_change_year#
							AND DATEPART(mm, i.img_change_time) = #the_change_month#
							AND DATEPART(dd, i.img_change_time) = #the_change_day#)
						<cfelse>
							AND i.img_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datechange#%">
						</cfif>
					</cfif>
					<!--- If we have a folderid --->
					<cfif arguments.folderid NEQ "">
						AND i.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folderid#">
					</cfif>
					<cfif application.razuna.api.thedatabase EQ "mssql">
						GROUP BY i.img_id, i.img_filename, i.folder_id_r, i.img_extension, i.img_filename_org, i.thumb_extension, i.path_to_asset, i.cloud_url, i.cloud_url_org, i.img_size, i.img_width, i.img_height,	i.img_create_time, i.img_change_time, it.img_description, it.img_keywords
					</cfif>
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Videos --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "vid">
					<cfset vidc = true>
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(v.vid_id as varchar), '0')</cfif> id, 
					v.vid_filename filename, 
					v.folder_id_r folder_id, 
					v.vid_extension extension, 
					v.vid_name_image as video_image,
					v.vid_name_org filename_org, 
					'vid' as kind, 
					v.vid_name_image extension_thumb, 
					v.path_to_asset, 
					v.cloud_url, 
					v.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(v.vid_size as varchar), '0')</cfif> AS size, 
					v.vid_width AS width,
					v.vid_height AS height,
					vt.vid_description description, 
					vt.vid_keywords keywords,
					v.vid_create_time dateadd,
					v.vid_change_time datechange,
	                <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
		                concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_org) AS local_url_org,
		                concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',v.path_to_asset,'/',v.vid_name_image) AS local_url_preview
	                <cfelseif application.razuna.api.thedatabase EQ "mssql">
		                'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + v.path_to_asset + '/' + v.vid_name_org AS local_url_org,
		                'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + v.path_to_asset + '/' + v.vid_name_image AS local_url_preview
                    </cfif>
                    FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos v 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
					WHERE v.vid_id IN (<cfif qrylucenevid.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreevid.categorytree)#" list="Yes"></cfif>)
					AND (v.vid_group IS NULL OR v.vid_group = '')
					AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					<!--- Only if we have dates --->
					<cfif arguments.datecreate NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, v.vid_create_time) = #the_create_year#
							AND DATEPART(mm, v.vid_create_time) = #the_create_month#
							AND DATEPART(dd, v.vid_create_time) = #the_create_day#)
						<cfelse>
							AND v.vid_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datecreate#%">
						</cfif>
					</cfif>
					<cfif arguments.datechange NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, v.vid_change_time) = #the_change_year#
							AND DATEPART(mm, v.vid_change_time) = #the_change_month#
							AND DATEPART(dd, v.vid_change_time) = #the_change_day#)
						<cfelse>
							AND v.vid_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datechange#%">
						</cfif>
					</cfif>
					<!--- If we have a folderid --->
					<cfif arguments.folderid NEQ "">
						AND v.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folderid#">
					</cfif>
					<cfif application.razuna.api.thedatabase EQ "mssql">
						GROUP BY v.vid_id, v.vid_filename, v.folder_id_r, v.vid_extension, v.vid_name_image, v.vid_name_org, v.vid_name_image, v.path_to_asset, v.cloud_url, v.cloud_url_org, v.vid_size, v.vid_width, v.vid_height, vt.vid_description, vt.vid_keywords, v.vid_create_time, v.vid_change_time
					</cfif>
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Audios --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "aud">
					<cfset audc = true>
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(a.aud_id as varchar), '0')</cfif> id, 
					a.aud_name filename, 
					a.folder_id_r folder_id, 
					a.aud_extension extension, 
					'dummy' as video_image,
					a.aud_name_org filename_org, 
					'aud' as kind, 
					a.aud_extension extension_thumb, 
					a.path_to_asset, 
					a.cloud_url, 
					a.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(a.aud_size as varchar), '0')</cfif> AS size,
					0 AS width,
					0 AS height,
					aut.aud_description description, 
					aut.aud_keywords keywords,
					a.aud_create_time dateadd,
					a.aud_change_time datechange,
	                <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
		                concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',a.path_to_asset,'/',a.aud_name_org) AS local_url_org,
	                <cfelseif application.razuna.api.thedatabase EQ "mssql">
		                'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + a.path_to_asset + '/' + a.aud_name_org AS local_url_org,
                     </cfif>
					'0' as local_url_thumb
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios a 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
					WHERE a.aud_id IN (<cfif qryluceneaud.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreeaud.categorytree)#" list="Yes"></cfif>)
					AND (a.aud_group IS NULL OR a.aud_group = '')
					AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					<!--- Only if we have dates --->
					<cfif arguments.datecreate NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, a.aud_create_time) = #the_create_year#
							AND DATEPART(mm, a.aud_create_time) = #the_create_month#
							AND DATEPART(dd, a.aud_create_time) = #the_create_day#)
						<cfelse>
							AND a.aud_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datecreate#%">
						</cfif>
					</cfif>
					<cfif arguments.datechange NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, a.aud_change_time) = #the_change_year#
							AND DATEPART(mm, a.aud_change_time) = #the_change_month#
							AND DATEPART(dd, a.aud_change_time) = #the_change_day#)
						<cfelse>
							AND a.aud_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datechange#%">
						</cfif>
					</cfif>
					<!--- If we have a folderid --->
					<cfif arguments.folderid NEQ "">
						AND a.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folderid#">
					</cfif>
					<cfif application.razuna.api.thedatabase EQ "mssql">
						GROUP BY a.aud_id, a.aud_name, a.folder_id_r, a.aud_extension, a.aud_name_org, a.aud_extension, a.path_to_asset, a.cloud_url, a.cloud_url_org, a.aud_size, aut.aud_description, aut.aud_keywords, a.aud_create_time, a.aud_change_time
					</cfif>
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Docs --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "doc">
					<cfset docc = true>
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(f.file_id as varchar), '0')</cfif> id, 
					f.file_name filename, 
					f.folder_id_r folder_id, 
					f.file_extension extension, 
					'dummy' as video_image,
					f.file_name_org filename_org, 
					'doc' as kind, 
					f.file_extension extension_thumb, 
					f.path_to_asset, 
					f.cloud_url, 
					f.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(f.file_size as varchar), '0')</cfif> AS size, 
					0 AS width,
					0 AS height,
					ft.file_desc description, 
					ft.file_keywords keywords,
					f.file_create_time dateadd,
					f.file_change_time datechange,
	                <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
		                concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/',f.path_to_asset,'/',f.file_name_org) AS local_url_org,
	                <cfelseif application.razuna.api.thedatabase EQ "mssql">
		                'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.api_key#"]#/' + f.path_to_asset + '/' + f.file_name_org AS local_url_org,
                    </cfif>
					'0' as local_url_thumb
					FROM #application.razuna.api.prefix["#arguments.api_key#"]#files f 
					LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
					WHERE f.file_id IN (<cfif qrylucenedoc.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreedoc.categorytree)#" list="Yes"></cfif>)
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
					<!--- Only if we have dates --->
					<cfif arguments.datecreate NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, f.file_create_time) = #the_create_year#
							AND DATEPART(mm, f.file_create_time) = #the_create_month#
							AND DATEPART(dd, f.file_create_time) = #the_create_day#)
						<cfelse>
							AND f.file_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datecreate#%">
						</cfif>
					</cfif>
					<cfif arguments.datechange NEQ "">
						<cfif application.razuna.api.thedatabase EQ "mssql">
							AND (DATEPART(yy, f.file_change_time) = #the_change_year#
							AND DATEPART(mm, f.file_change_time) = #the_change_month#
							AND DATEPART(dd, f.file_change_time) = #the_change_day#)
						<cfelse>
							AND f.file_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.datechange#%">
						</cfif>
					</cfif>
					<!--- If we have a folderid --->
					<cfif arguments.folderid NEQ "">
						AND f.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folderid#">
					</cfif>
					<cfif application.razuna.api.thedatabase EQ "mssql">
						GROUP BY f.file_id, f.file_name, f.folder_id_r, f.file_extension, f.file_name_org, f.file_extension, f.path_to_asset, f.cloud_url, f.cloud_url_org, f.file_size, ft.file_desc, ft.file_keywords, f.file_create_time, f.file_change_time
					</cfif>
				</cfif>
				<cfif application.razuna.api.thedatabase NEQ "mssql">
	            	GROUP BY id, filename, folder_id, extension, filename_org, path_to_asset, cloud_url, cloud_url_org, size, description, keywords, dateadd, datechange
	            </cfif>		
				ORDER BY filename 
			</cfquery>
			<!--- If we query for doc only and have a filetype we filter the results --->
			<cfif arguments.show NEQ "all" AND arguments.show EQ "doc" AND arguments.doctype NEQ "">
				<cfquery dbtype="query" name="qry">
				SELECT *
				FROM qry
				<cfswitch expression="#arguments.doctype#">
					<cfcase value="doc">
						WHERE qry.extension = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
					</cfcase>
					<cfcase value="xls">
						WHERE qry.extension = <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
					</cfcase>
					<cfcase value="pdf">
						WHERE qry.extension = <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
					</cfcase>
					<cfcase value="other">
						WHERE qry.extension != <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
						AND qry.extension != <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
						AND qry.extension != <cfqueryparam value="xlsx" cfsqltype="cf_sql_varchar">
						AND qry.extension != <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
						AND qry.extension != <cfqueryparam value="docx" cfsqltype="cf_sql_varchar">
					</cfcase>
				</cfswitch>
				</cfquery>
			</cfif>
			<!--- Set responsecode --->
			<cfif qry.recordcount NEQ 0>
				<cfset rescode = 0>
			<cfelse>
				<cfset rescode = 1>
			</cfif>
			<!--- Add our own tags to the query --->
			<cfset q = querynew("responsecode,totalassetscount,calledwith")>
			<cfset queryaddrow(q,1)>
			<cfset querysetcell(q,"responsecode",rescode)>
			<cfset querysetcell(q,"totalassetscount",qry.recordcount)>
			<cfset querysetcell(q,"calledwith",arguments.searchfor)>
			<!--- Put the 2 queries together --->
			<cfquery dbtype="query" name="thexml">
			SELECT *
			FROM qry, q
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
</cfcomponent>