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
	
	<!--- Retrieve assets from a Collection --->
	<cffunction name="getassets" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" type="string">
		<cfargument name="collectionid" type="string">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Param --->
			<cfset thestorage = "">
			<!--- Query which file are in this collection --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry_col">
			SELECT file_id_r
			FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections_ct_files ct
			WHERE ct.col_id_r = <cfqueryparam value="#arguments.collectionid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- If above qry return records --->
			<cfif qry_col.recordcount NEQ 0>
				<!--- Query the files --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT 
				i.img_id id, 
				i.img_filename filename, 
				i.folder_id_r, 
				i.img_extension ext,
				i.thumb_extension thext, 
				'dummy' as vidimage, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(i.img_size, 0))</cfif> AS thesize,
				i.img_width AS thewidth,
				i.img_height AS theheight,
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
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#images isub
					WHERE isub.img_group = i.img_id
				) as subassets
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#images i 
				LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
				WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND (i.img_group IS NULL OR i.img_group = '')
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				AND i.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				UNION ALL
				SELECT 
				v.vid_id id, 
				v.vid_filename filename, 
				v.folder_id_r, 
				v.vid_extension ext, 
				v.vid_extension thext,
				v.vid_name_image as vidimage, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(v.vid_size, 0))</cfif> AS thesize,
				v.vid_width AS thewidth,
				v.vid_height AS theheight, 
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
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#videos vsub
					WHERE vsub.vid_group = v.vid_id
				) as subassets
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#videos v 
				LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
				WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND (v.vid_group IS NULL OR v.vid_group = '')
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				AND v.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				UNION ALL
				<!--- Audios --->
				SELECT 
				a.aud_id id, 
				a.aud_name filename, 
				a.folder_id_r, 
				a.aud_extension ext,
				a.aud_extension thext, 
				'dummy' as vidimage,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(a.aud_size, 0))</cfif> AS thesize,
				0 AS thewidth,
				0 AS theheight,
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
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#audios asub
					WHERE asub.aud_group = a.aud_id
				) as subassets
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#audios a 
				LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
				WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND (a.aud_group IS NULL OR a.aud_group = '')
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				AND a.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				UNION ALL
				SELECT 
				f.file_id id, 
				f.file_name filename, 
				f.folder_id_r, 
				f.file_extension ext, 
				f.file_extension thext, 
				'dummy' as vidimage, 
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(f.file_size, 0))</cfif> AS thesize,
				0 AS thewidth,
				0 AS theheight,
				f.file_name_org filename_org, 
				f.file_type as kind, 
				ft.file_desc description, 
				ft.file_keywords keywords,
				f.path_to_asset,
				f.cloud_url,
				f.cloud_url_org,
				'false' as subassets
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#files f 
				LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
				WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(qry_col.file_id_r)#" list="true">)
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				AND f.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				ORDER BY filename
				</cfquery>
				<!--- Check on the storage --->
				<cfif application.razuna.api.storage EQ "local">
					<cfset var thestorage = "#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				<!---
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
					<cfset var thestorageshared = "#application.razuna.api.nvxurlservices#/razuna/#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				--->
				</cfif>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<totalassetscount>#qry.recordcount#</totalassetscount>
<calledwith>c-#xmlformat(arguments.collectionid)#</calledwith>
<listassets>
<cfloop query="qry">
<asset>
<kind>#xmlformat(kind)#</kind>
<id>#xmlformat(id)#</id>
<filename>#xmlformat(filename)#</filename>
<extension>#xmlformat(ext)#</extension>
<description>#xmlformat(description)#</description>
<keywords>#xmlformat(keywords)#</keywords>
<url><cfif application.razuna.api.storage EQ "amazon" OR application.razuna.api.storage EQ "nirvanix">#cloud_url_org#<cfelse>#thestorage#/#path_to_asset#/#filename_org#</cfif></url>
<thumbnail><cfif kind EQ "doc" AND ext NEQ "pdf"><cfif FileExists("#ExpandPath("../")#host/dam/images/icons/icon_#ext#.png") IS "no">#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_txt.png<cfelse>#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_#ext#.png</cfif><cfelseif kind EQ "aud">#application.razuna.api.thehttp##cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png<cfelse><cfif application.razuna.api.storage EQ "amazon" OR application.razuna.api.storage EQ "nirvanix">#cloud_url#<cfelse>#thestorage#/#path_to_asset#/<cfif kind EQ "img">thumb_#id#.#thext#<cfelseif kind EQ "vid">#vidimage#<cfelseif kind EQ "doc" AND ext EQ "pdf">#replacenocase(filename_org, ".pdf", ".jpg", "all")#</cfif></cfif></cfif></thumbnail>
<size>#thesize#</size>
<width>#thewidth#</width>
<height>#theheight#</height>
<folderid>#xmlformat(folder_id_r)#</folderid>
<hasconvertedformats>#xmlformat(subassets)#</hasconvertedformats><cfif subassets EQ "true">
<cfinvoke component="folder" method="getsubassets" theid="#id#" thekind="#kind#" thestorage="#thestorage#" sessiontoken="#arguments.sessiontoken#" returnvariable="thesub">#thesub#</cfif>
</asset>
</cfloop>
</listassets>
</Response></cfoutput>
				</cfsavecontent>
			<!--- Qry is null --->
			<cfelse>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<totalassetscount>0</totalassetscount>
</Response></cfoutput>
				</cfsavecontent>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Get Collections of this Collection folder --->
	<cffunction name="getcollections" access="remote" output="false" returntype="String">
		<cfargument name="sessiontoken" type="string">
		<cfargument name="folderid" type="string">
		<cfargument name="e4x" type="numeric">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT c.col_id, c.change_date, ct.col_name
			FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections c
			LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections_text ct ON c.col_id = ct.col_id_r AND ct.lang_id_r = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
			WHERE c.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folderid#">
			AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
			ORDER BY lower(ct.col_name)
			</cfquery>
			<!--- Take the result and create XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<calledwith>#arguments.folderid#</calledwith>
<listcollections>
<cfloop query="qry">
<cfquery datasource="#application.razuna.api.dsn#" name="qrytotal">
SELECT count(file_id_r) thetotal, (SELECT count(file_id_r) FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections_ct_files WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#col_id#"> AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img">) totalimg, (SELECT count(file_id_r) FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections_ct_files WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#col_id#"> AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="vid">) totalvid, (SELECT count(file_id_r) FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections_ct_files WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#col_id#"> AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="doc">) totaldoc, (SELECT count(file_id_r) FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections_ct_files WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#col_id#"> AND col_file_type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="aud">) totalaud
FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#collections_ct_files
WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#col_id#">
GROUP BY file_id_r
</cfquery>
<cfif arguments.e4x EQ "0">
<collection>
<collectionid>#xmlformat(col_id)#</collectionid>
<collectionname>#xmlformat(col_name)#</collectionname>
<totalassets><cfif qrytotal.recordcount NEQ 0>#xmlformat(qrytotal.thetotal)#<cfelse>0</cfif></totalassets>
<totalimg><cfif qrytotal.recordcount NEQ 0>#xmlformat(qrytotal.totalimg)#<cfelse>0</cfif></totalimg>
<totalvid><cfif qrytotal.recordcount NEQ 0>#xmlformat(qrytotal.totalvid)#<cfelse>0</cfif></totalvid>
<totaldoc><cfif qrytotal.recordcount NEQ 0>#xmlformat(qrytotal.totaldoc)#<cfelse>0</cfif></totaldoc>
<totalaud><cfif qrytotal.recordcount NEQ 0>#xmlformat(qrytotal.totalaud)#<cfelse>0</cfif></totalaud>
</collection><cfelse>
<collection collectionid="#xmlformat(col_id)#" collectionname="#xmlformat(col_name)#" totalassets="#xmlformat(qrytotal.thetotal)#" totalimg="#xmlformat(qrytotal.totalimg)#" totalvid="#xmlformat(qrytotal.totalvid)#" totaldoc="#xmlformat(qrytotal.totaldoc)#" totalaud="#xmlformat(qrytotal.totalaud)#" />
</cfif>
</cfloop>
</listcollections>
</Response></cfoutput>
			</cfsavecontent>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml />
	</cffunction>
	
	<!--- Retrieve the collections in a tree --->
	<cffunction name="intgetfolderstree" output="true" access="private">
		<cfargument name="sessiontoken" type="string">
		<cfparam default="0" name="arguments.id">
		<!--- init internal vars --->
		<cfset var f_1 = 0>
		<cfset var qSub = 0>
		<cfset var qRet = 0>
		<!--- Do the select --->
		<cfquery datasource="#application.razuna.api.dsn#" name="f_1">
		SELECT f.folder_id, f.folder_level, f.folder_name, f.folder_id_r, f.folder_owner,
				CASE
					WHEN ( lower(f.folder_of_user) = 't' AND f.folder_owner = '#application.razuna.api.userid["#arguments.sessiontoken#"]#' AND lower(f.folder_name) = 'my folder') THEN 'unlocked'
					WHEN ( lower(f.folder_of_user) = 't' AND lower(f.folder_name) = 'my folder') THEN 'locked'
					ELSE 'unlocked'
				END AS perm,
				<!--- Check if there are any subfolders --->
				(
					SELECT<cfif application.razuna.api.thedatabase EQ "mssql"> TOP 1</cfif> <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "h2">NVL<cfelseif application.razuna.api.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull</cfif>(s.folder_id, 0)
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#folders s
					WHERE s.folder_id <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id
					AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
					AND s.folder_id_r = f.folder_id
					<cfif application.razuna.api.thedatabase EQ "oracle">
						AND ROWNUM = 1
					<cfelseif application.razuna.api.thedatabase EQ "db2">
						FETCH FIRST 1 ROWS ONLY
					<cfelse>
						LIMIT 1
					</cfif>
				)
				AS subhere
		FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#folders f
		WHERE 
		<cfif Arguments.id gt 0>
			f.folder_id <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
			AND
			f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.id#">
		<cfelse>
			f.folder_id = f.folder_id_r
		</cfif>
		AND lower(f.folder_is_collection) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
		ORDER BY lower(folder_name)
		</cfquery>
		<!--- dummy QoQ to get correct datatypes --->
		<cfquery dbtype="query" name="qRet">
		SELECT *
		FROM f_1
		WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		</cfquery>
		<!--- Construct the Queries together --->
		<cfloop query="f_1">
			<!--- Invoke this function again --->
			<cfif qret.subhere NEQ 0>
				<cfinvoke method="intgetfolderstree" returnvariable="qSub">
					<cfinvokeargument name="sessiontoken" value="#arguments.sessiontoken#">
					<cfinvokeargument name="id" value="#folder_id#">
				</cfinvoke>
			</cfif>
			<!--- Put together the query --->
			<cfquery dbtype="query" name="qRet">
			SELECT *
			FROM qRet
			UNION ALL
			SELECT *
			FROM f_1
			WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f_1.folder_id#">
			AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
			<cfif qret.subhere NEQ 0>
				UNION ALL
				SELECT *
				FROM qSub
				WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
			</cfif>
			</cfquery>
		</cfloop>
		<!--- Return --->
		<cfreturn qret>
	</cffunction>

	<!--- Retrieve the collections in a tree --->
	<cffunction name="getcollectionstree" access="remote" output="false" returntype="String">
		<cfargument name="sessiontoken" type="string">
		<cfargument name="e4x" type="numeric">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Call the internal function to get the tree --->
			<cfinvoke method="intgetfolderstree" returnvariable="qry">
				<cfinvokeargument name="sessiontoken" value="#arguments.sessiontoken#">
			</cfinvoke>
			<!--- Take the result and create XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<listcollections>
<cfloop query="qry">
<cfif arguments.e4x EQ "0">
<cfif folder_level EQ 1><collection>
<collectionid>#xmlformat(folder_id)#</collectionid>
<collectionname>#xmlformat(folder_name)#</collectionname>
<collectionlevel>#xmlformat(folder_level)#</collectionlevel>
<collectionowner>#xmlformat(folder_owner)#</collectionowner>
<parentid>#xmlformat(folder_id_r)#</parentid>
<hassubcollection><cfif subhere NEQ "">true<cfelse>false</cfif></hassubcollection><cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" returnvariable="subxml">#subxml#</cfif>
</collection></cfif><cfelse><cfif folder_level EQ 1>
<collection collectionid="#xmlformat(folder_id)#" collectionname="#xmlformat(folder_name)#" collectionlevel="#xmlformat(folder_level)#" parentid="#xmlformat(folder_id_r)#" hassubcollection="<cfif subhere NEQ "">true<cfelse>false</cfif>" collectionowner="#xmlformat(folder_owner)#">
<cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" returnvariable="subxml">#subxml#</cfif>
</collection></cfif>
</cfif>
</cfloop>
</listcollections>
</Response></cfoutput>
			</cfsavecontent>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Recursive subtree for XML --->
	<cffunction name="recursesubtreexml" output="false" access="private">
		<cfargument name="theqry" type="query">
		<cfargument name="thefolderlevel" type="numeric">
		<cfargument name="thecurrentid" type="string">
		<cfargument name="e4x" type="numeric">
		<!--- Set params --->
		<cfset curlevel = arguments.thefolderlevel + 1>
		<cfset curid = arguments.thecurrentid>
		<!--- Query --->
		<cfquery dbtype="query" name="qsub">
		SELECT * 
		FROM arguments.theqry 
		WHERE folder_id_r = '#curid#' 
		AND folder_level = #curlevel#
		</cfquery>
		<!--- Create XML --->
		<cfsavecontent variable="subxml"><cfoutput>
<cfloop query="qsub">
<cfif arguments.e4x EQ "0">
<subcollection>
<collectionid>#xmlformat(folder_id)#</collectionid>
<collectionname>#xmlformat(folder_name)#</collectionname>
<collectionlevel>#xmlformat(folder_level)#</collectionlevel>
<collectionowner>#xmlformat(folder_owner)#</collectionowner>
<parentid>#xmlformat(folder_id_r)#</parentid>
<hassubcollection><cfif subhere NEQ "">true<cfelse>false</cfif></hassubcollection><cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" returnvariable="subxml">#subxml#</cfif>
</subcollection><cfelse>
<subcollection collectionid="#xmlformat(folder_id)#" collectionname="#xmlformat(folder_name)#" collectionlevel="#xmlformat(folder_level)#" parentid="#xmlformat(folder_id_r)#" hassubcollection="<cfif subhere NEQ "">true<cfelse>false</cfif>" collectionowner="#xmlformat(folder_owner)#">
<cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" returnvariable="subxml">#subxml#</cfif>
</subcollection>
</cfif>
</cfloop>
</cfoutput>
		</cfsavecontent>
		<!--- Return --->
		<cfreturn subxml>
	</cffunction>
</cfcomponent>