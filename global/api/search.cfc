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
<cfcomponent output="false">
	
	<!--- Retrieve assets from a folder --->
	<cffunction name="searchassets" access="remote" output="false" returntype="String">
		<cfargument name="sessiontoken" type="string">
		<cfargument name="searchfor" type="string">
		<cfargument name="offset" type="numeric">
		<cfargument name="maxrows" type="numeric">
		<cfargument name="show" type="string">
		<cfargument name="doctype" type="string">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Params --->
			<cfset var imgc = false>
			<cfset var vidc = false>
			<cfset var audc = false>
			<cfset var docc = false>
			<!--- Check the searchfor --->
			<cfif arguments.searchfor EQ "">
				<cfset arguments.searchfor = "*">
			</cfif>
			<!--- Images --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "img">
				<!--- Search in Lucene --->
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="img" hostid="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="qryluceneimg">
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
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="vid" hostid="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="qrylucenevid">
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
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="aud" hostid="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="qryluceneaud">
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
				<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.searchfor#" category="doc" hostid="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="qrylucenedoc">
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
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(i.img_id, 0))</cfif> id, i.img_filename filename, i.folder_id_r, i.thumb_extension ext, 'dummy' as vidimage,
					i.img_filename_org filename_org, 'img' as kind, i.thumb_extension thext, i.path_to_asset, i.cloud_url, i.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(i.img_size, 0))</cfif> AS thesize,
					i.img_width AS thewidth,
					i.img_height AS theheight,
					it.img_description description, it.img_keywords keywords,
					count(i.img_id) AS rowtotal
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#images i 
					LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
					WHERE i.img_id IN (<cfif qryluceneimg.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreeimg.categorytree)#" list="Yes"></cfif>)
					AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
					AND (i.img_group IS NULL OR i.img_group = '')
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Videos --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "vid">
					<cfset vidc = true>
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(v.vid_id, 0))</cfif> id, v.vid_filename filename, v.folder_id_r, v.vid_extension ext, v.vid_name_image as vidimage,
					v.vid_name_org filename_org, 'vid' as kind, v.vid_name_image thext, v.path_to_asset, v.cloud_url, v.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(v.vid_size, 0))</cfif> AS thesize, 
					v.vid_width AS thewidth,
					v.vid_height AS theheight,
					vt.vid_description description, vt.vid_keywords keywords,
					count(v.vid_id) AS rowtotal
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#videos v 
					LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
					WHERE v.vid_id IN (<cfif qrylucenevid.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreevid.categorytree)#" list="Yes"></cfif>)
					AND (v.vid_group IS NULL OR v.vid_group = '')
					AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Audios --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "aud">
					<cfset audc = true>
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(a.aud_id, 0))</cfif> id, a.aud_name filename, a.folder_id_r, a.aud_extension ext, 'dummy' as vidimage,
					a.aud_name_org filename_org, 'aud' as kind, a.aud_extension thext, a.path_to_asset, a.cloud_url, a.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(a.aud_size, 0))</cfif> AS thesize,
					0 AS thewidth,
					0 AS theheight,
					aut.aud_description description, aut.aud_keywords keywords,
					count(a.aud_id) AS rowtotal
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#audios a 
					LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
					WHERE a.aud_id IN (<cfif qryluceneaud.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreeaud.categorytree)#" list="Yes"></cfif>)
					AND (a.aud_group IS NULL OR a.aud_group = '')
					AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Docs --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "doc">
					<cfset docc = true>
					SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(f.file_id, 0))</cfif> id, f.file_name filename, f.folder_id_r, f.file_extension ext, 'dummy' as vidimage,
					f.file_name_org filename_org, 'doc' as kind, f.file_extension thext, f.path_to_asset, f.cloud_url, f.cloud_url_org,
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(f.file_size, 0))</cfif> AS thesize, 
					0 AS thewidth,
					0 AS theheight,
					ft.file_desc description, ft.file_keywords keywords,
					count(f.file_id) AS rowtotal
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#files f 
					LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
					WHERE f.file_id IN (<cfif qrylucenedoc.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreedoc.categorytree)#" list="Yes"></cfif>)
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfif>
				GROUP BY <cfif arguments.show EQ "ALL">i.img_id, v.vid_id, a.aud_id, f.file_id</cfif><cfif arguments.show EQ "img">i.img_id</cfif><cfif arguments.show EQ "vid"><cfif imgc>,</cfif> v.vid_id</cfif><cfif arguments.show EQ "aud"><cfif vidc>,</cfif> a.aud_id</cfif><cfif arguments.show EQ "doc"><cfif audc>,</cfif> f.file_id</cfif>
				ORDER BY filename 
				<!--- MySQL / H2 --->
				<cfif (application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2") AND arguments.maxrows NEQ 0>
					LIMIT #arguments.offset#,#arguments.maxrows#
				</cfif>
			</cfquery>
			<!--- If we query for doc only and have a filetype we filter the results --->
			<cfif arguments.show NEQ "all" AND arguments.show EQ "doc" AND arguments.doctype NEQ "">
				<cfquery dbtype="query" name="qry">
				SELECT *
				FROM qry
				<cfswitch expression="#arguments.doctype#">
					<cfcase value="doc">
						WHERE qry.ext = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
					</cfcase>
					<cfcase value="xls">
						WHERE qry.ext = <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
					</cfcase>
					<cfcase value="pdf">
						WHERE qry.ext = <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
					</cfcase>
					<cfcase value="other">
						WHERE qry.ext != <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
						AND qry.ext != <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
						AND qry.ext != <cfqueryparam value="xlsx" cfsqltype="cf_sql_varchar">
						AND qry.ext != <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
						AND qry.ext != <cfqueryparam value="docx" cfsqltype="cf_sql_varchar">
					</cfcase>
				</cfswitch>
				</cfquery>
			</cfif>
			<cfquery dbtype="query" name="qrytotal">
			SELECT sum(rowtotal) as thetotal
			FROM qry
			</cfquery>
			<!--- Check on the storage --->
			<cfif application.razuna.api.storage EQ "local">
				<cfset var thestorage = "#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
			<cfelseif application.razuna.api.storage EQ "nirvanix">
				<cfset thestruct = structnew()>
				<cfset thestruct.isbrowser = "T">
				<cfquery datasource="#application.razuna.api.dsn#" name="thestruct.qry_settings_nirvanix">
				SELECT set2_nirvanix_name, set2_nirvanix_pass
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#settings_2
				WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
				<cfset nvx = createObject("component","global.cfc.nirvanix").init("#application.razuna.api.nvxappkey#")>
				<cfset nvxsession = nvx.login("#thestruct#")>
				<cfset var thestorage = "#application.razuna.api.nvxurlservices#/#nvxsession#/razuna/#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
			</cfif>
			<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode><cfif qrytotal.thetotal NEQ 0>0<cfelse>1</cfif></responsecode>
<listassets>
<totalassetscount>#qrytotal.thetotal#</totalassetscount>
<calledwith>#xmlformat(arguments.searchfor)#</calledwith>
<cfloop query="qry">
<asset>
<kind>#xmlformat(kind)#</kind>
<id>#xmlformat(id)#</id>
<filename>#xmlformat(filename)#</filename>
<extension>#xmlformat(ext)#</extension>
<description>#xmlformat(description)#</description>
<keywords>#xmlformat(keywords)#</keywords>
<folderid>#xmlformat(folder_id_r)#</folderid>
<url><cfif application.razuna.api.storage EQ "amazon" OR application.razuna.api.storage EQ "nirvanix">#cloud_url_org#<cfelse>#thestorage#/#path_to_asset#/#filename_org#</cfif></url>
<thumbnail><cfif kind EQ "doc" AND ext NEQ "pdf"><cfif FileExists("#ExpandPath("../")#host/dam/images/icons/icon_#ext#.png") IS "no">#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_txt.png<cfelse>#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_#ext#.png</cfif><cfelseif kind EQ "aud">#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png<cfelse><cfif application.razuna.api.storage EQ "amazon" OR application.razuna.api.storage EQ "nirvanix">#cloud_url#<cfelse>#thestorage#/#path_to_asset#/<cfif kind EQ "img">thumb_#id#.#ext#<cfelseif kind EQ "vid">#vidimage#<cfelseif kind EQ "doc" AND ext EQ "pdf">#replacenocase(filename_org, ".pdf", ".jpg", "all")#</cfif></cfif></cfif></thumbnail>
<size>#xmlformat(thesize)#</size>
<width>#xmlformat(thewidth)#</width>
<height>#xmlformat(theheight)#</height>
</asset>
</cfloop>
</listassets>
</Response></cfoutput>
			</cfsavecontent>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
</cfcomponent>