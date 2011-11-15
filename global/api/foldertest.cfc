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
	<cffunction name="getassets" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" type="string">
		<cfargument name="folderid" type="string">
		<cfargument name="showsubfolders" type="numeric">
		<cfargument name="offset" type="numeric">
		<cfargument name="maxrows" type="numeric">
		<cfargument name="show" type="string">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Param --->
			<cfset thestorage = "">
			<!--- If the folderid is empty then set it to 0 --->
			<cfif arguments.folderid EQ "">
				<cfset arguments.folderid = 0>
			</cfif>
			<!--- Show assets from subfolders or not --->
			<cfif arguments.showsubfolders>
				<cfinvoke component="global.cfc.folders" method="getfoldersinlist" dsn="#application.razuna.api.dsn#" prefix="#application.razuna.api.prefix["#arguments.sessiontoken#"]#" database="#application.razuna.api.thedatabase#" folder_id="#arguments.folderid#" hostid="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="thefolders">
				<cfset thefolderlist = arguments.folderid & "," & ValueList(thefolders.folder_id)>
			<cfelse>
				<cfset thefolderlist = arguments.folderid>
			</cfif>	
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				<!--- Images --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "img">
					SELECT 
					i.img_id id, 
					i.img_filename filename, 
					i.folder_id_r, 
					i.img_extension ext, 
					'dummy' as vidimage,
					i.img_filename_org filename_org, 
					'img' as kind, 
					i.thumb_extension thext, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(i.img_size, 0))</cfif> AS thesize, 
					i.img_width width,
					i.img_height height,
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
					WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
					AND i.img_group IS NULL
					AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
					AND i.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					<!--- Nirvanix --->
					<!--- <cfif application.razuna.api.storage EQ "nirvanix" AND NOT cgi.HTTP_USER_AGENT CONTAINS "adobeair">
						AND lower(i.shared) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
					</cfif> --->
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Videos --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "vid">
					SELECT 
					v.vid_id id, 
					v.vid_filename filename, 
					v.folder_id_r, 
					v.vid_extension ext, 
					v.vid_name_image as vidimage,
					v.vid_name_org filename_org, 
					'vid' as kind, 
					v.vid_extension thext, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(v.vid_size, 0))</cfif> AS thesize, 
					v.vid_width width,
					v.vid_height height,
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
					WHERE v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
					AND v.vid_group IS NULL
					AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
					AND v.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					<!--- Nirvanix --->
					<!--- <cfif application.razuna.api.storage EQ "nirvanix" AND NOT cgi.HTTP_USER_AGENT CONTAINS "adobeair">
						AND lower(v.shared) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
					</cfif> --->
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Audios --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "aud">
					SELECT 
					a.aud_id id, 
					a.aud_name filename, 
					a.folder_id_r, 
					a.aud_extension ext, 
					'dummy' as vidimage,
					a.aud_name_org filename_org, 
					'aud' as kind, 
					a.aud_extension thext, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(a.aud_size, 0))</cfif> AS thesize, 
					'0' width,
					'0' height,
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
					WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
					AND a.aud_group IS NULL
					AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
					AND a.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					<!--- Nirvanix --->
					<!--- <cfif application.razuna.api.storage EQ "nirvanix" AND NOT cgi.HTTP_USER_AGENT CONTAINS "adobeair">
						AND lower(v.shared) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
					</cfif> --->
				</cfif>
				<cfif arguments.show EQ "ALL">
					UNION ALL
				</cfif>
				<!--- Docs --->
				<cfif arguments.show EQ "ALL" OR arguments.show EQ "doc">
					SELECT 
					f.file_id id, 
					f.file_name filename, 
					f.folder_id_r, 
					f.file_extension ext, 
					'dummy' as vidimage,
					f.file_name_org filename_org, 
					'doc' as kind, 
					f.file_extension thext, 
					<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(f.file_size, 0))</cfif> AS thesize, 
					'0' width,
					'0' height,
					ft.file_desc description, 
					ft.file_keywords keywords,
					f.path_to_asset,
					f.cloud_url,
					f.cloud_url_org,
					'false' as subassets
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#files f 
					LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
					WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
					AND f.is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					<!--- Nirvanix --->
					<!--- <cfif application.razuna.api.storage EQ "nirvanix" AND NOT cgi.HTTP_USER_AGENT CONTAINS "adobeair">
						AND lower(f.shared) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
					</cfif> --->
				</cfif>
			</cfquery>
			<!--- Only if we found records --->
			<cfif qry.recordcount NEQ 0>
				<!--- Check on the storage --->
				<cfif application.razuna.api.storage EQ "local">
					<cfset thestorage = "http://#cgi.HTTP_HOST#/assets/#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
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
<calledwith>#xmlformat(arguments.folderid)#</calledwith>
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
<thumbnail><cfif kind EQ "doc" AND ext NEQ "pdf"><cfif FileExists("#ExpandPath("../")#host/dam/images/icons/icon_#ext#.png") IS "no">http://#cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_txt.png<cfelse>http://#cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_#ext#.png</cfif><cfelseif kind EQ "aud">http://#cgi.HTTP_HOST##application.razuna.api.dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png<cfelse><cfif application.razuna.api.storage EQ "amazon" OR application.razuna.api.storage EQ "nirvanix">#cloud_url#<cfelse>#thestorage#/#path_to_asset#/<cfif kind EQ "img">thumb_#id#.#thext#<cfelseif kind EQ "vid">#vidimage#<cfelseif kind EQ "doc" AND ext EQ "pdf">#replacenocase(filename_org, ".pdf", ".jpg", "all")#</cfif></cfif></cfif></thumbnail>
<size>#thesize#</size>
<width>#width#</width>
<height>#height#</height>
<folderid>#xmlformat(folder_id_r)#</folderid>
<hasconvertedformats>#xmlformat(subassets)#</hasconvertedformats><cfif subassets EQ "true">
<cfinvoke method="getsubassets" theid="#id#" thekind="#kind#" thestorage="#thestorage#" sessiontoken="#arguments.sessiontoken#" returnvariable="thesub">#thesub#</cfif>
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
	
	<!--- Get converted formats --->
	<cffunction name="getsubassets" access="remote" output="false" returntype="String">
		<cfargument name="theid" type="string">
		<cfargument name="thekind" type="string">
		<cfargument name="thestorage" type="string">
		<cfargument name="sessiontoken" type="string">
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			<cfif arguments.thekind EQ "img">
				SELECT 
				img_id fid, 
				img_width fw, 
				img_height fh, 
				path_to_asset fpa, 
				cloud_url fthumb, 
				cloud_url_org furl,
				img_filename_org forg,
				<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">str(isnull(img_size, 0))</cfif> AS fsize
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#images
				WHERE img_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theid#">
			</cfif>
		</cfquery>
		<!--- Create the XML --->
		<cfsavecontent variable="thexml"><cfoutput>
<convertedformats><cfloop query="qry">
	<theformat>
		<formatid>#xmlformat(fid)#</formatid>
		<formatwidth>#xmlformat(fw)#</formatwidth>
		<formatheight>#xmlformat(fh)#</formatheight>
		<formatsize>#xmlformat(fsize)#</formatsize>
		<formaturl><cfif application.razuna.api.storage EQ "amazon" OR application.razuna.api.storage EQ "nirvanix">#xmlformat(furl)#<cfelse>#arguments.thestorage#/#fpa#/#forg#</cfif></formaturl>
	</theformat></cfloop>
</convertedformats>
</cfoutput></cfsavecontent>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Retrieve folders --->
	<cffunction name="getfolders" access="remote" output="false" returntype="String">
		<cfargument name="sessiontoken" type="string">
		<cfargument name="folderid" type="string">
		<cfargument name="e4x" type="numeric">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query folder --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT f.folder_id, f.folder_name, f.folder_owner,
			<cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "h2">NVL<cfelseif application.razuna.api.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username,
				(
					SELECT<cfif application.razuna.api.thedatabase EQ "mssql"> TOP 1</cfif> s.folder_id
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#folders s
					WHERE s.folder_id <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id
					AND s.folder_id_r = f.folder_id
					AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
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
			LEFT JOIN users u ON u.user_id = f.folder_owner
			WHERE
			<cfif Arguments.folderid gt 0>
				<!--- f.folder_id <cfif application.razuna.api.thedatabase EQ "oracle"><><cfelse>!=</cfif> f.folder_id_r
				AND --->
				f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.folderid#">
			<cfelse>
				f.folder_id = f.folder_id_r
			</cfif>
			<!--- AND f.folder_id <cfif application.razuna.api.thedatabase EQ "oracle"><><cfelse>!=</cfif> 1 --->
			AND f.folder_is_collection IS NULL
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
			<!--- AND lower(f.folder_of_user) = <cfqueryparam cfsqltype="cf_sql_varchar" value="f"> --->
			ORDER BY f.folder_name
			</cfquery>
			<!--- Query total count --->
			<cfinvoke component="global.cfc.folders" method="apifiletotalcount" apidsn="#application.razuna.api.dsn#" apiprefix="#application.razuna.api.prefix["#arguments.sessiontoken#"]#" folder_id="#arguments.folderid#" apidatabase="#application.razuna.api.thedatabase#" host_id="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="totalassets">
			<!--- Query total count for individual files --->
			<cfinvoke component="global.cfc.folders" method="apifiletotaltype" apidsn="#application.razuna.api.dsn#" apiprefix="#application.razuna.api.prefix["#arguments.sessiontoken#"]#" folder_id="#arguments.folderid#" apidatabase="#application.razuna.api.thedatabase#" host_id="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="totaltypes">
			<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<listfolders>
<cfloop query="qry"><cfif arguments.e4x EQ 0>
<folder>
<folderid>#xmlformat(folder_id)#</folderid>
<folderidpassed>#xmlformat(arguments.folderid)#</folderidpassed>
<foldername>#xmlformat(folder_name)#<cfif folder_name EQ "my folder" AND application.razuna.api.userid["#arguments.sessiontoken#"] NEQ folder_owner> (#xmlformat(username)#)</cfif></foldername>
<folderowner>#xmlformat(folder_owner)#</folderowner>
<hassubfolder><cfif subhere NEQ "">true<cfelse>false</cfif></hassubfolder>
<totalassets>#xmlformat(totalassets.thetotal)#</totalassets>
<totalimg>#xmlformat(totaltypes.img)#</totalimg>
<totalvid>#xmlformat(totaltypes.vid)#</totalvid>
<totaldoc>#xmlformat(totaltypes.doc)#</totaldoc>
<totalaud>#xmlformat(totaltypes.aud)#</totalaud>
</folder><cfelse>
<cfif folder_name EQ "my folder" AND application.razuna.api.userid["#arguments.sessiontoken#"] NEQ folder_owner>
<folder folderid="#folder_id#" folderidpassed="#xmlformat(arguments.folderid)#" foldername="#xmlformat(folder_name)# (#xmlformat(username)#)" hassubfolder="<cfif subhere NEQ "">true<cfelse>false</cfif>" totalassets="#xmlformat(totalassets.thetotal)#" totalimg="#xmlformat(totaltypes.img)#" totalvid="#xmlformat(totaltypes.vid)#" totaldoc="#xmlformat(totaltypes.doc)#" totalaud="#xmlformat(totaltypes.aud)#" folderowner="#xmlformat(folder_owner)#" />
<cfelse>
<folder folderid="#folder_id#" folderidpassed="#xmlformat(arguments.folderid)#" foldername="#xmlformat(folder_name)#" hassubfolder="<cfif subhere NEQ "">true<cfelse>false</cfif>" totalassets="#xmlformat(totalassets.thetotal)#" totalimg="#xmlformat(totaltypes.img)#" totalvid="#xmlformat(totaltypes.vid)#" totaldoc="#xmlformat(totaltypes.doc)#" totalaud="#xmlformat(totaltypes.aud)#" folderowner="#xmlformat(folder_owner)#" />
</cfif>
</cfif>
</cfloop>
</listfolders>
</Response></cfoutput>
			</cfsavecontent>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Retrieve the folders in a tree --->
	<cffunction name="intgetfolderstree" output="false" access="private">
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
				AND s.folder_id_r = f.folder_id
				AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				<cfif application.razuna.api.thedatabase EQ "oracle">
					AND rownum = 1
				<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
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
		AND f.folder_is_collection IS NULL
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
		<!--- filter user folders --->
		<!--- Does not apply to SystemAdmin users --->
		<!--- <cfif not Request.securityObj.CheckSystemAdminUser()> --->
			<!--- AND
				(
				LOWER(f.folder_of_user) <cfif application.razuna.api.thedatabase EQ "oracle"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
				OR f.folder_owner = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.userid#">
				) --->
		<!--- </cfif> --->
		ORDER BY <cfif application.razuna.api.thedatabase EQ "oracle">lower(folder_name)<cfelse>folder_name</cfif>
		</cfquery>
		<!--- dummy QoQ to get correct datatypes --->
		<cfquery dbtype="query" name="qRet">
		SELECT *
		FROM f_1
		WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
		AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		ORDER BY <cfif application.razuna.api.thedatabase EQ "oracle">lower(folder_name)<cfelse>folder_name</cfif>
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
		<cfreturn qRet>
	</cffunction>

	<!--- Retrieve the folders in a tree --->
	<cffunction name="getfolderstree" access="remote" output="false" returntype="String">
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
<listfolders>
<cfloop query="qry">
<!--- Query total count --->
<cfinvoke component="global.cfc.folders" method="apifiletotalcount" apidsn="#application.razuna.api.dsn#" apiprefix="#application.razuna.api.prefix["#arguments.sessiontoken#"]#" folder_id="#folder_id#" apidatabase="#application.razuna.api.thedatabase#" host_id="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="totalassets">
<!--- Query total count for individual files --->
<cfinvoke component="global.cfc.folders" method="apifiletotaltype" apidsn="#application.razuna.api.dsn#" apiprefix="#application.razuna.api.prefix["#arguments.sessiontoken#"]#" folder_id="#folder_id#" apidatabase="#application.razuna.api.thedatabase#" host_id="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="totaltypes">
<cfif arguments.e4x EQ "0">
<cfif folder_level EQ 1><folder>
<folderid>#xmlformat(folder_id)#</folderid>
<foldername>#xmlformat(folder_name)#</foldername>
<folderlevel>#xmlformat(folder_level)#</folderlevel>
<parentid>#xmlformat(folder_id_r)#</parentid>
<folderowner>#xmlformat(folder_owner)#</folderowner>
<totalassets>#xmlformat(totalassets.thetotal)#</totalassets>
<totalimg>#xmlformat(totaltypes.img)#</totalimg>
<totalvid>#xmlformat(totaltypes.vid)#</totalvid>
<totaldoc>#xmlformat(totaltypes.doc)#</totaldoc>
<totalaud>#xmlformat(totaltypes.aud)#</totalaud>
<hassubfolder><cfif subhere NEQ "">true<cfelse>false</cfif></hassubfolder><cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" sessiontoken="#arguments.sessiontoken#" returnvariable="subxml">#subxml#</cfif>
</folder></cfif><cfelse><cfif folder_level EQ 1>
<folder folderid="#xmlformat(folder_id)#" foldername="#xmlformat(folder_name)#" folderlevel="#xmlformat(folder_level)#" parentid="#xmlformat(folder_id_r)#" hassubfolder="<cfif subhere NEQ "">true<cfelse>false</cfif>" totalassets="#xmlformat(totalassets.thetotal)#" totalimg="#xmlformat(totaltypes.img)#" totalvid="#xmlformat(totaltypes.vid)#" totaldoc="#xmlformat(totaltypes.doc)#" totalaud="#xmlformat(totaltypes.aud)#" folderowner="#xmlformat(folder_owner)#">
<cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" sessiontoken="#arguments.sessiontoken#" returnvariable="subxml">#subxml#</cfif>
</folder></cfif>
</cfif>
</cfloop>
</listfolders>
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
		<cfargument name="sessiontoken" type="string">
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
<!--- Query total count --->
<cfinvoke component="global.cfc.folders" method="apifiletotalcount" apidsn="#application.razuna.api.dsn#" apiprefix="#application.razuna.api.prefix["#arguments.sessiontoken#"]#" folder_id="#folder_id#" apidatabase="#application.razuna.api.thedatabase#" host_id="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="totalassets">
<!--- Query total count for individual files --->
<cfinvoke component="global.cfc.folders" method="apifiletotaltype" apidsn="#application.razuna.api.dsn#" apiprefix="#application.razuna.api.prefix["#arguments.sessiontoken#"]#" folder_id="#folder_id#" apidatabase="#application.razuna.api.thedatabase#" host_id="#application.razuna.api.hostid["#arguments.sessiontoken#"]#" returnvariable="totaltypes">
<cfif arguments.e4x EQ "0">
<subfolder>
<folderid>#xmlformat(folder_id)#</folderid>
<foldername>#xmlformat(folder_name)#</foldername>
<folderlevel>#xmlformat(folder_level)#</folderlevel>
<folderowner>#xmlformat(folder_owner)#</folderowner>
<parentid>#xmlformat(folder_id_r)#</parentid>
<totalassets>#xmlformat(totalassets.thetotal)#</totalassets>
<totalimg>#xmlformat(totaltypes.img)#</totalimg>
<totalvid>#xmlformat(totaltypes.vid)#</totalvid>
<totaldoc>#xmlformat(totaltypes.doc)#</totaldoc>
<totalaud>#xmlformat(totaltypes.aud)#</totalaud>
<hassubfolder><cfif subhere NEQ "">true<cfelse>false</cfif></hassubfolder><cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" sessiontoken="#arguments.sessiontoken#" returnvariable="subxml">#subxml#</cfif>
</subfolder><cfelse>
<subfolder folderid="#xmlformat(folder_id)#" foldername="#xmlformat(folder_name)#" folderlevel="#xmlformat(folder_level)#" parentid="#xmlformat(folder_id_r)#" hassubfolder="<cfif subhere NEQ "">true<cfelse>false</cfif>" totalassets="#xmlformat(totalassets.thetotal)#" totalimg="#xmlformat(totaltypes.img)#" totalvid="#xmlformat(totaltypes.vid)#" totaldoc="#xmlformat(totaltypes.doc)#" totalaud="#xmlformat(totaltypes.aud)#" folderowner="#xmlformat(folder_owner)#">
<cfif subhere NEQ ""><cfinvoke method="recursesubtreexml" theqry="#qry#" thefolderlevel="#folder_level#" thecurrentid="#folder_id#" e4x="#arguments.e4x#" sessiontoken="#arguments.sessiontoken#" returnvariable="subxml">#subxml#</cfif>
</subfolder>
</cfif>
</cfloop>
</cfoutput>
		</cfsavecontent>
		<!--- Return --->
		<cfreturn subxml>
	</cffunction>
	
</cfcomponent>