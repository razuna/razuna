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
	
	<!--- Asset: Get info --->
	<cffunction name="getasset" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="assetid" required="true">
		<cfargument name="assettype" required="true">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Param --->
			<cfset thestorage = "">
			<!--- Images --->
			<cfif arguments.assettype EQ "img">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
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
				i.img_width AS thewidth,
				i.img_height AS theheight,
				it.img_description description, 
				it.img_keywords keywords,
				i.path_to_asset,
				i.cloud_url,
				i.cloud_url_org,
				i.img_meta themeta,
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
				WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
			<!--- Videos --->
			<cfelseif arguments.assettype EQ "vid">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
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
				v.vid_width AS thewidth,
				v.vid_height AS theheight,
				vt.vid_description description, 
				vt.vid_keywords keywords,
				v.path_to_asset,
				v.cloud_url,
				v.cloud_url_org,
				v.vid_meta themeta,
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
				WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
			<!--- Audios --->
			<cfelseif arguments.assettype EQ "aud">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
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
				0 AS thewidth,
				0 AS theheight,
				aut.aud_description description, 
				aut.aud_keywords keywords,
				a.path_to_asset,
				a.cloud_url,
				a.cloud_url_org,
				a.aud_meta themeta,
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
				WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
			<!--- Documents --->
			<cfelseif arguments.assettype EQ "doc">
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
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
				0 AS thewidth,
				0 AS theheight,
				ft.file_desc description, 
				ft.file_keywords keywords,
				f.path_to_asset,
				f.cloud_url,
				f.cloud_url_org,
				f.file_meta themeta,
				'false' as subassets
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#files f 
				LEFT JOIN #application.razuna.api.prefix["#arguments.sessiontoken#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
				WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.assetid#" list="true">)
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
			</cfif>
			<!--- Only if we found records --->
			<cfif qry.recordcount NEQ 0>
				<!--- Check on the storage --->
				<cfif application.razuna.api.storage EQ "local">
					<cfset thestorage = "#application.razuna.api.thehttp##cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfif>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<totalassetscount>#qry.recordcount#</totalassetscount>
<calledwith>#xmlformat(arguments.assetid)#</calledwith>
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
<size>#xmlformat(thesize)#</size>
<width>#xmlformat(thewidth)#</width>
<height>#xmlformat(theheight)#</height>
<folderid>#xmlformat(folder_id_r)#</folderid>
<metadata>#xmlformat(themeta)#</metadata>
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
	
	<!--- Metadata: Get --->
	<cffunction name="getmetadata" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="assetid" required="true">
		<cfargument name="assettype" required="true">
		<cfargument name="assetmetadata" required="true">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
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
			SELECT #theidr#, #arguments.assetmetadata#
			FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]##thedb#
			WHERE #theidr# IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.assetid#" list="Yes">)
			</cfquery>
			<!--- Feedback --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<cfoutput query="qrymeta">
<asset>
<assetid>#evaluate(theidr)#</assetid>
<cfloop list="#arguments.assetmetadata#" delimiters="," index="i">
<#i#>#evaluate(i)#</#i#>
</cfloop>
</asset>
</cfoutput>
</Response></cfoutput>
			</cfsavecontent>			
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Metadata: Add --->
	<cffunction name="setmetadata" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="assetid" required="true">
		<cfargument name="assettype" required="true">
		<cfargument name="assetmetadata" required="true">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.sessiontoken#"]>
			<cfset session.hostid = application.razuna.api.hostid["#arguments.sessiontoken#"]>
			<cfset session.theuserid = application.razuna.api.userid["#arguments.sessiontoken#"]>
			<!--- Set db and id --->
			<cfif arguments.assettype EQ "img">
				<cfset var thedb = "images_text">
				<cfset var theid = "img_id">
				<cfset var theidr = "img_id_r">
				<cfset var lucenecategory = "img">
			<cfelseif arguments.assettype EQ "vid">
				<cfset var thedb = "videos_text">
				<cfset var theid = "vid_id">
				<cfset var theidr = "vid_id_r">
				<cfset var lucenecategory = "vid">
			<cfelseif arguments.assettype EQ "aud">
				<cfset var thedb = "audios_text">
				<cfset var theid = "aud_id">
				<cfset var theidr = "aud_id_r">
				<cfset var lucenecategory = "aud">
			<cfelse>
				<cfset var thedb = "files_desc">
				<cfset var theid = "file_id">
				<cfset var theidr = "file_id_r">
				<cfset var lucenecategory = "doc">
			</cfif>
			<!--- Deserialize the JSON back into an array --->
			<cfset thejson = DeserializeJSON(arguments.assetmetadata)>
			<!--- Loop over the assetid --->
			<cfloop list="#arguments.assetid#" index="i" delimiters=",">
				<!--- Remove all values for this record first --->
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]##thedb#
				WHERE #theidr# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
				</cfquery>
				<!--- the id --->
				<cfset theid = createuuid("")>
				<!--- Create record --->
				<cfquery datasource="#application.razuna.api.dsn#">
				INSERT INTO #application.razuna.api.prefix["#arguments.sessiontoken#"]##thedb#
				(id_inc, host_id, lang_id_r, #theidr#)
				VALUES (
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
				)
				</cfquery>
				<!--- Add keywords and description to the asset (loop over the passed array) --->
				<cfloop index="x" from="1" to="#arrayLen(thejson)#">
					<cfif #thejson[x][1]# CONTAINS "_">
						<cfquery datasource="#application.razuna.api.dsn#">
						UPDATE #application.razuna.api.prefix["#arguments.sessiontoken#"]##thedb#
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
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#xmp
					WHERE asset_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">
					AND id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
					</cfquery>
					<!--- If record is not here then do insert --->
					<cfif ishere.recordcount EQ 0>				
						<cfquery datasource="#application.razuna.api.dsn#">
						INSERT INTO #application.razuna.api.prefix["#arguments.sessiontoken#"]#xmp
						(id_r, asset_type, host_id)
						VALUES(
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
						)
						</cfquery>
					</cfif>
					<!--- Update records --->
					<cfloop index="x" from="1" to="#arrayLen(thejson)#">
						<cfif #thejson[x][1]# NEQ "lang_id_r" AND #thejson[x][1]# DOES NOT CONTAIN "_">
							<cfquery datasource="#application.razuna.api.dsn#">
							UPDATE #application.razuna.api.prefix["#arguments.sessiontoken#"]#xmp
							SET #thejson[x][1]# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thejson[x][2]#">
							WHERE id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
				<!--- Initiate the index --->
				<!--- <cfinvoke component="global.cfc.lucene" method="index_update_api" assetid="#i#" assetcategory="#lucenecategory#"> --->
			</cfloop>
			<!--- Feedback --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>Metadata successfully stored</message>
</Response></cfoutput>
			</cfsavecontent>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>	
	
    <!--- Delete --->
	<cffunction name="remove" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="assetid" required="true">
    	<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Put values into struct to be compatible with global cfcs --->
			<cfset orgstruct = structnew()>
			<cfset orgstruct.hostdbprefix = application.razuna.api.prefix["#arguments.sessiontoken#"]>
			<cfset orgstruct.hostid = application.razuna.api.hostid["#arguments.sessiontoken#"]>
			<cfset orgstruct.theuserid = application.razuna.api.userid["#arguments.sessiontoken#"]>
			<cfset orgstruct.id = arguments.assetid>
			<!--- Set application values --->
			<cfset application.razuna.storage = application.razuna.api.storage>
			<cfset application.razuna.datasource = application.razuna.api.dsn>
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
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#settings_2
				WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
				<cfset nvx = createObject("component","global.cfc.nirvanix").init("#application.razuna.api.nvxappkey#")>
				<cfset nvxsession = nvx.login("#orgstruct#")>
			<!--- Amazon --->
			<cfelseif application.razuna.api.storage EQ "amazon">
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT set2_aws_bucket
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#settings_2
				WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
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
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message><![CDATA[Asset(s) have been removed successfully]]></message>
</Response></cfoutput>
			</cfsavecontent>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
    	<!--- Return --->
		<cfreturn thexml>
	</cffunction>
    
    
    
    
	<!--- Set shared (deprecated) --->
	<cffunction name="setshared" access="remote" output="false" returntype="string">
		<cfargument name="sessiontoken" required="true">
		<cfargument name="assetid">
		<cfargument name="assettype" type="string">
		<cfargument name="activate" type="numeric">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set db and id --->
			<cfif arguments.assettype EQ "img">
				<cfset var thedb = "images">
				<cfset var theid = "img_id">
				<cfset var thegroup = "img_group">
				<cfset var thecolumns = "img_id id, thumb_extension ext, folder_id_r, img_filename_org filename, path_to_asset">
			<cfelseif arguments.assettype EQ "vid">
				<cfset var thedb = "videos">
				<cfset var theid = "vid_id">
				<cfset var thegroup = "vid_group">
				<cfset var thecolumns = "vid_id id, vid_extension ext, folder_id_r, vid_name_org filename, path_to_asset">
			<cfelseif arguments.assettype EQ "aud">
				<cfset var thedb = "audios">
				<cfset var theid = "aud_id">
				<cfset var thegroup = "aud_group">
				<cfset var thecolumns = "aud_id id, aud_extension ext, folder_id_r, aud_name_org filename, path_to_asset">
			<cfelseif arguments.assettype EQ "doc">
				<cfset var thedb = "files">
				<cfset var theid = "file_id">
				<cfset var thecolumns = "aud_id id, aud_extension ext, folder_id_r, file_name_org filename, path_to_asset">
			</cfif>
			<!--- Nirvanix --->
			<cfif application.razuna.api.storage EQ "nirvanix">
				<cfset thestruct = structnew()>
				<cfset thestruct.isbrowser = "F">
				<cfquery datasource="#application.razuna.api.dsn#" name="thestruct.qry_settings_nirvanix">
				SELECT set2_nirvanix_name, set2_nirvanix_pass
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]#settings_2
				WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
				<!--- Login to Nirvanix and get the sessiontoken --->
				<cfset var nvx = createObject("component","global.cfc.nirvanix").init("#application.razuna.api.nvxappkey#")>
				<cfset var nvxsession = nvx.login("#thestruct#")>
			</cfif>
			<!--- Loop over the assetid --->
			<cfloop list="#arguments.assetid#" index="i" delimiters=",">
				<cfif arguments.activate>
					<cfset theshared = "t">
				<cfelse>
					<cfset theshared = "f">
				</cfif>
				<!--- Save the shared state --->
				<cfquery datasource="#application.razuna.api.dsn#">
				UPDATE #application.razuna.api.prefix["#arguments.sessiontoken#"]##thedb#
				SET shared = <cfqueryparam value="#theshared#" cfsqltype="cf_sql_varchar">
				WHERE #theid# = <cfqueryparam cfsqltype="cf_sql_numeric" value="#i#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
				<!--- Select the record --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qryorg">
				SELECT #thecolumns#
				FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]##thedb#
				WHERE #theid# = <cfqueryparam cfsqltype="cf_sql_numeric" value="#i#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
				</cfquery>
				<!--- If we have aud, img or vid we need to select the related records --->
				<cfif arguments.assettype EQ "img" OR arguments.assettype EQ "vid" OR arguments.assettype EQ "aud">
					<cfquery datasource="#application.razuna.api.dsn#" name="qryrel">
					SELECT #thecolumns#
					FROM #application.razuna.api.prefix["#arguments.sessiontoken#"]##thedb#
					WHERE #thegroup# = <cfqueryparam cfsqltype="cf_sql_numeric" value="#i#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.sessiontoken#"]#">
					</cfquery>
				</cfif>
				<!--- Set it on Nirvanix --->
				<cfif application.razuna.api.storage EQ "nirvanix">
					<!--- Enable Sharing --->
					<cfif arguments.activate>
						<cfinvoke component="global.cfc.nirvanix" method="CreateHostedItem" nvxsession="#nvxsession#" sharePath="/#qryorg.path_to_asset#/#qryorg.filename#">
						<!--- If this is for images we also enable thumbnails --->
						<cfif arguments.assettype EQ "img">
							<cfinvoke component="global.cfc.nirvanix" method="CreateHostedItem" nvxsession="#nvxsession#" sharePath="/#qryorg.path_to_asset#/thumb_#i#.#qryorg.ext#">
						</cfif>
						<!--- Loop over related ones as well --->
						<cfif arguments.assettype EQ "img" OR arguments.assettype EQ "vid" OR arguments.assettype EQ "aud">
							<cfloop query="qryrel">
								<cfinvoke component="global.cfc.nirvanix" method="CreateHostedItem" nvxsession="#nvxsession#" sharePath="/#path_to_asset#/#filename#">
								<!--- If this is for images we also enable thumbnails --->
								<cfif arguments.assettype EQ "img">
									<cfinvoke component="global.cfc.nirvanix" method="CreateHostedItem" nvxsession="#nvxsession#" sharePath="/#path_to_asset#/thumb_#id#.#ext#">
								</cfif>
							</cfloop>
						</cfif>
					<!--- Disable Sharing --->
					<cfelse>
						<cfinvoke component="global.cfc.nirvanix" method="RemoveHostedItem" nvxsession="#nvxsession#" sharePath="/#qryorg.path_to_asset#/#qryorg.filename#">
						<!--- If this is for images we also enable thumbnails --->
						<cfif arguments.assettype EQ "img">
							<cfinvoke component="global.cfc.nirvanix" method="RemoveHostedItem" nvxsession="#nvxsession#" sharePath="/#qryorg.path_to_asset#/thumb_#i#.#qryorg.ext#">
						</cfif>
						<!--- Loop over related ones as well --->
						<cfif arguments.assettype EQ "img" OR arguments.assettype EQ "vid" OR arguments.assettype EQ "aud">
							<cfloop query="qryrel">
								<cfinvoke component="global.cfc.nirvanix" method="RemoveHostedItem" nvxsession="#nvxsession#" sharePath="/#path_to_asset#/#filename#">
								<!--- If this is for images we also enable thumbnails --->
								<cfif arguments.assettype EQ "img">
									<cfinvoke component="global.cfc.nirvanix" method="RemoveHostedItem" nvxsession="#nvxsession#" sharePath="/#path_to_asset#/thumb_#id#.#ext#">
								</cfif>
							</cfloop>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
			<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>Asset shared</message>
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