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
<cfcomponent extends="extQueryCaching">

<!--- Get all versions --->
<cffunction name="get" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	SELECT v.ver_version,v.ver_extension, v.ver_date_add, v.ver_filename_org,v.ver_thumbnail,v.cloud_url_thumb,v.ver_type,v.asset_id_r, v.cloud_url_org,
	u.user_login_name, u.user_first_name, u.user_last_name
	FROM #arguments.thestruct.razuna.session.hostdbprefix#versions v LEFT JOIN users u ON u.user_id = v.ver_who
	WHERE v.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND v.ver_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
	ORDER BY v.ver_version DESC
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Remove versions --->
<cffunction name="remove" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<cfset var getinfo = "">
	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="getinfo">
	SELECT ver_filename_org, asset_id_r
	FROM #arguments.thestruct.razuna.session.hostdbprefix#versions
	WHERE ver_version = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.version#">
	AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND ver_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
	</cfquery>

	<!--- Query --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
	DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#versions
	WHERE ver_version = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.version#">
	AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND ver_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
	</cfquery>

	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	SELECT file_extension orgext, path_to_asset
	FROM #arguments.thestruct.razuna.session.hostdbprefix#files
	WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
	</cfquery>

	<!--- Delete asset on system --->
	<cfif arguments.thestruct.razuna.application.storage EQ "local">
		<cfif directoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#")>
			<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#" recurse="true">
		</cfif>
		<!--- If document is PDF then delete the folder named after the version number where pdf imgaes are stored  --->
		<cfif qry.orgext eq "pdf">
			<cfif directoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#arguments.thestruct.version#")>
				<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#arguments.thestruct.version#" recurse="true">
			</cfif>
		</cfif>
	<cfelseif arguments.thestruct.razuna.application.storage EQ "nirvanix">
		<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#">
	<cfelseif arguments.thestruct.razuna.application.storage EQ "amazon">
		<cfinvoke component="amazon" method="deletefolder" folderpath="#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<cfinvoke component="defaults" method="trans" transid="deleted" returnvariable="deleted" />
	<cfinvoke component="defaults" method="trans" transid="plugin_version" returnvariable="version" />
	<!--- Add entry into log --->
	<cfset log_assets(theuserid=arguments.thestruct.razuna.session.theuserid,logaction='Delete',logdesc='#deleted# #version#: #getinfo.ver_filename_org#',logfiletype='#arguments.thestruct.type#',assetid='#getinfo.asset_id_r#',folderid='#arguments.thestruct.folder_id#', hostid=arguments.thestruct.razuna.session.hostid)>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Playback --->
<cffunction name="playback" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset var cloud_url_2 = structnew()>
	<cfset var cloud_url_version = structnew()>
	<cfset var cloud_url_version_thumb = structnew()>
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_version.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cfset cloud_url_version_thumb.theurl = "">
	<cfset arguments.thestruct.therandom = createuuid("")>
	<cfset var qry = "">
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.thetools" />
	<!--- Get windows or not --->
	<cfinvoke component="global" method="iswindows" returnVariable="iswindows" />
	<!--- Set Exiftool --->
	<cfif isWindows>
		<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfset arguments.thestruct.theexeff = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
	<cfelse>
		<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset arguments.thestruct.theexeff = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
	</cfif>
	<cftry>
		<!--- First get details from current record --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
			SELECT
			folder_id_r, img_filename_org filenameorg, thumb_width, thumb_height, thumb_extension,
			img_width, img_height, img_size, thumb_size, img_extension orgext, path_to_asset, hashtag, img_meta as metadata
			FROM #arguments.thestruct.razuna.session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<cfset var thethumbname = "thumb_#arguments.thestruct.file_id#.#qry.thumb_extension#">
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
			SELECT
			folder_id_r, vid_name_org filenameorg, vid_size, vid_width, vid_height,
			vid_name_image, vid_extension orgext, path_to_asset, hashtag, vid_meta as metadata
			FROM #arguments.thestruct.razuna.session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<cfset var thethumbname = replacenocase(qry.filenameorg,".#qry.orgext#",".jpg","all")>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
			SELECT
			folder_id_r, aud_name_org filenameorg, aud_size, aud_extension orgext, path_to_asset, hashtag, aud_meta as metadata
			FROM #arguments.thestruct.razuna.session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<cfset var thethumbname = replacenocase(qry.filenameorg,".#qry.orgext#",".wav","all")>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
			SELECT folder_id_r, file_name_org filenameorg, file_extension orgext, path_to_asset, hashtag, file_meta as metadata, file_size
			FROM #arguments.thestruct.razuna.session.hostdbprefix#files
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<cfset var thethumbname = replacenocase(qry.filenameorg,".pdf",".jpg","all")>
		</cfif>
		<!--- Create a new version number --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qryversion">
		SELECT <cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">NVL<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql">ifnull<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mssql">isnull</cfif>(max(ver_version),0) + 1 AS newversion
		FROM #arguments.thestruct.razuna.session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ver_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Query original file name of this version we need to replay --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qrycurrentversion">
		SELECT ver_filename_org, ver_thumbnail, ver_type
		FROM #arguments.thestruct.razuna.session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ver_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar">
		AND ver_version = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.version#">
		</cfquery>
		<!--- Query to get the settings --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="arguments.thestruct.qrysettings">
		SELECT set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, set2_img_comp_width,
		set2_img_comp_heigth, set2_vid_preview_author, set2_vid_preview_copyright, set2_path_to_assets, set2_colorspace_rgb
		FROM #arguments.thestruct.razuna.session.hostdbprefix#settings_2
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<!--- Create directory --->
		<cfif arguments.thestruct.razuna.application.storage EQ "local">
			<!--- Create folder with the version --->
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#qryversion.newversion#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#qryversion.newversion#" mode="775">
			</cfif>
			<!--- Move the file to the versions directory --->
			<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#" destination="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#qryversion.newversion#" move="T">
			<!--- Delete existing files in directory before copying --->
			<cfdirectory action="list" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#" recurse="false" listinfo="name" name="qFile" />
			<!--- Loop through file query and delete files --->
			<cfloop query="qFile">
			    <cffile action="delete" file="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/#qFile.name#">
			</cfloop>
			<!--- Now copy the version to the original directory --->
			<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#" destination="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#">
			<!--- If document is a PDF then back up PDF images into the new version folder on playback and copy over images from the playback version folder into razuna_pdf_images  folder --->
			<cfif qry.orgext eq "pdf">
				<!--- Create folder with the new version inside razuna_pdf_images folder --->
				<cfif !directoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#qryversion.newversion#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#qryversion.newversion#" mode="775">
				</cfif>
				<!--- Move razuna_pdf_images folder content into new version folder  --->
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/" destination="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#qryversion.newversion#" fileaction="move" move="T">
				<cfif directoryExists("#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#arguments.thestruct.version#")>
					<!--- Copy over pdf images for playback version folder into razuna_pdf_images folder  --->
					 <cfdirectory action="list" directory="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#arguments.thestruct.version#" name="pdfimgscpy" filter="*.jpg"/>
					<cfloop query="pdfimgscpy">
						<cftry>
							<cffile action="copy" source="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images/#arguments.thestruct.version#/#name#" destination="#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images" mode="777">
							<cfcatch type="any"></cfcatch>
						</cftry>
					</cfloop>
				<cfelse> <!--- If directory does not exist for version then re-generate pdf images --->
				 	<cfobject component="global.cfc.files" name="fobj">
				 	<cfset var genjpgs = fobj.genpdfjpgs ("#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/#qrycurrentversion.ver_filename_org#","#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/#qry.path_to_asset#/razuna_pdf_images")>
				</cfif>
			</cfif>
		<!--- Amazon --->
		<cfelseif arguments.thestruct.razuna.application.storage EQ "amazon">
			<cfset arguments.thestruct.newversion = qryversion.newversion>
			<cfset arguments.thestruct.qrycurrentversion.ver_filename_org = qrycurrentversion.ver_filename_org>
			<cfset arguments.thestruct.qry = qry>
			<cfif arguments.thestruct.type EQ 'img' OR arguments.thestruct.type EQ 'vid' OR arguments.thestruct.type EQ 'doc' OR arguments.thestruct.type EQ 'aud'>
				<!--- Move the current directory images to new version --->
				<cfinvoke component="amazon" method="movefolder">
					<cfinvokeargument name="folderpath" value="#arguments.thestruct.qry.path_to_asset#">
					<cfinvokeargument name="folderpathdest" value="versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.newversion#">
					<cfinvokeargument name="awsbucket" value="#arguments.thestruct.awsbucket#">
					<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
				</cfinvoke>
				<!--- Copy the existing version images to current directory --->
				<cfinvoke component="amazon" method="copyfolder">
					<cfinvokeargument name="folderpath" value="versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#">
					<cfinvokeargument name="folderpathdest" value="#arguments.thestruct.qry.path_to_asset#">
					<cfinvokeargument name="awsbucket" value="#arguments.thestruct.awsbucket#">
					<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
				</cfinvoke>
			</cfif>
			<!--- Get SignedURL thumbnail --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qry.path_to_asset#/#qrycurrentversion.ver_thumbnail#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<!--- Get SignedURL original --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qry.path_to_asset#/#qrycurrentversion.ver_filename_org#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<!--- Get SignedURL for the original in the versions --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.qry.filenameorg#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<!--- Get the thumbnail --->
			<cfif arguments.thestruct.type EQ "img">
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version_thumb" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.newversion#/thumb_#arguments.thestruct.file_id#.#arguments.thestruct.qrysettings.set2_img_format#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<cfelseif arguments.thestruct.type EQ "vid">
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version_thumb" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.newversion#/#listFirst(arguments.thestruct.qry.filenameorg,".")#.jpg" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<cfelseif arguments.thestruct.type EQ 'doc' AND arguments.thestruct.qry.orgext EQ 'PDF'>
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version_thumb" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.newversion#/#listFirst(arguments.thestruct.qry.filenameorg,".")#.jpg" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfif>
		<!--- Update the record in versions DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#versions
		(asset_id_r, ver_version, ver_type,	ver_date_add, ver_who, ver_filename_org, ver_extension, host_id, cloud_url_org,cloud_url_thumb, ver_thumbnail, hashtag, rec_uuid, meta_data
		<!--- For images --->
		<cfif arguments.thestruct.type EQ "img">
		,
		thumb_width, thumb_height, img_width, img_height, img_size, thumb_size
		<!--- For Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
		,
		vid_size, vid_width, vid_height, vid_name_image
		<!--- For Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
		,
		vid_size
		<cfelse>
		,
		file_size
		</cfif>
		)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qryversion.newversion#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.razuna.session.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.filenameorg#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.orgext#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_version.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_version_thumb.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#thethumbname#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.hashtag#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.metadata#">
		<!--- For images --->
		<cfif arguments.thestruct.type EQ "img">
		,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qry.thumb_width#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qry.thumb_height#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qry.img_width#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qry.img_height#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.img_size#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.thumb_size#">
		<!--- For Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
		,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.vid_size#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qry.vid_width#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qry.vid_height#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.vid_name_image#">
		<!--- For Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
		,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.aud_size#">
		<cfelse>
		,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.file_size#">
		</cfif>
		)
		</cfquery>
		<!--- Query version db for filename --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qryv">
		SELECT
		ver_filename_org, ver_extension, thumb_width, thumb_height, img_width, img_height, img_size, thumb_size,
		vid_size, vid_width, vid_height, vid_name_image, hashtag, cloud_url_org, meta_data, file_size
		FROM #arguments.thestruct.razuna.session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ver_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
		AND ver_version = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.version#">
		</cfquery>
		<cfif qryv.RecordCount NEQ 0>
			<cfif arguments.thestruct.razuna.application.storage EQ "amazon" OR arguments.thestruct.razuna.application.storage EQ "nirvanix">
				<cfset arguments.thestruct.thesource = "#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#/#qryv.ver_filename_org#">
			<cfelse>
				<cfset arguments.thestruct.thesource = "#arguments.thestruct.assetpath#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#/#qryv.ver_filename_org#">
			</cfif>
		</cfif>
		<!--- Update asset db with playbacked version --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images
			SET
			img_filename_org = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_filename_org#">,
			img_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_extension#">,
			thumb_width = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qryv.thumb_width#">,
			thumb_height = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qryv.thumb_height#">,
			img_width = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qryv.img_width#">,
			img_height = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qryv.img_height#">,
			img_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.img_size#">,
			thumb_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.thumb_size#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qryv.hashtag#">,
			img_meta = <cfqueryparam value="#qryv.meta_data#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="images", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
			<!--- Do not parse XMP for Amazon as the file will have to be re-downloaded  from Amazon in order to do this which would cause too much overhead --->
			<cfif arguments.thestruct.razuna.application.storage NEQ 'Amazon'>
				<!--- Parse keywords and description from XMP --->
				<cfinvoke component="xmp" method="xmpwritekeydesc" thestruct="#arguments.thestruct#" />
				<!--- Parse the Metadata from the image --->
				<cfthread name="xmp#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#" action="run">
					<cfinvoke component="xmp" method="xmpparse" thestruct="#attributes.intstruct#" returnvariable="thread.thexmp" />
				</cfthread>
				<!--- Wait for the parsing --->
				<cfthread action="join" name="xmp#arguments.thestruct.file_id#" />
				<!--- Put the thread result into general struct --->
				<cfset arguments.thestruct.thexmp = cfthread["xmp#arguments.thestruct.file_id#"].thexmp>
				<!--- Write the Keywords and Description to the DB (if we are JPG we parse XMP and add them together) --->
				<cftry>
					<!--- Set Variable --->
					<cfset arguments.thestruct.assetpath = arguments.thestruct.qrysettings.set2_path_to_assets>
					<!--- Store XMP values in DB --->
					<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
					UPDATE #arguments.thestruct.razuna.session.hostdbprefix#xmp
					SET
					asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
					subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsubjectcode#">,
					creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.creator#">,
					title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.title#">,
					authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.authorstitle#">,
					captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.descwriter#">,
					ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcaddress#">,
					category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.category#">,
					supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.categorysub#">,
					urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.urgency#">,
					description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.description#">,
					ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccity#">,
					ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccountry#">,
					location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptclocation#">,
					ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptczip#">,
					ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcemail#">,
					ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcwebsite#">,
					citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcphone#">,
					intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcintelgenre#">,
					instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcinstructions#">,
					source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsource#">,
					usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcusageterms#">,
					copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copystatus#">,
					transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcjobidentifier#">,
					webstatement  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copyurl#">,
					headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcheadline#">,
					datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcdatecreated#">,
					city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecity#">,
					ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagestate#">,
					country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountry#">,
					countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountrycode#">,
					scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcscene#">,
					state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcstate#">,
					credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccredit#">,
					rights = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copynotice#">,
					colorspace = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.colorspace#">,
					xres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.xres#">,
					yres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.yres#">,
					resunit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.resunit#">,
					host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
					WHERE id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
					</cfquery>
					<cfcatch type="any">
					</cfcatch>
				</cftry>
			</cfif>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#videos
			SET
			vid_name_org = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_filename_org#">,
			vid_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_extension#">,
			vid_name_image = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.vid_name_image#">,
			vid_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.vid_size#">,
			vid_width = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qryv.vid_width#">,
			vid_height = <cfqueryparam cfsqltype="cf_sql_numeric" value="#qryv.vid_height#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qryv.hashtag#">,
			vid_meta = <cfqueryparam value="#qryv.meta_data#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#audios
			SET
			aud_name_org = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_filename_org#">,
			aud_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_extension#">,
			aud_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.vid_size#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qryv.hashtag#">,
			aud_meta = <cfqueryparam value="#qryv.meta_data#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#files
			SET
			file_name_org = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_filename_org#">,
			file_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_extension#">,
			<cfif isnumeric(qryv.file_size)>
				file_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.file_size#">,
			</cfif>
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qryv.hashtag#">,
			file_meta = <cfqueryparam value="#qryv.meta_data#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		</cfif>

		<cfset arguments.thestruct.qrydetail.path_to_asset = qry.path_to_asset>
		<cfset arguments.thestruct.qrydetail.filenameorg = qry.filenameorg>
		<cfset arguments.thestruct.qrydetail.folder_id_r = qry.folder_id_r>
		<cfset arguments.thestruct.filenameorg = qry.filenameorg>
		<!--- Add entry into log --->
		<cfset log_assets(theuserid=arguments.thestruct.razuna.session.theuserid,logaction='Update',logdesc='Playback of Version: #qrycurrentversion.ver_filename_org#',logfiletype='#qrycurrentversion.ver_type#',assetid='#arguments.thestruct.file_id#',folderid='#arguments.thestruct.folder_id#', hostid=arguments.thestruct.razuna.session.hostid)>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>
	</cftry>
	<!--- Reset folders cachetoken so preview images update --->
	<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Create Versions --->
<cffunction name="create" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_2 = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset var cloud_url_version = structnew()>
	<cfset var cloud_url_version_thumb = structNew()>
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_version.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cfset thumbnailname = "">
	<cfset cloud_url_version_thumb.theurl = "">
	<cfset var isAnimGIF = 0>
	<cfset arguments.thestruct.therandom = createuuid("")>
	<!--- Get windows or not --->
	<cfinvoke component="global" method="iswindows" returnVariable="iswindows" />
	<!--- Set Exiftool --->
	<cfif isWindows>
		<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfset arguments.thestruct.theexeff = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
	<cfelse>
		<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset arguments.thestruct.theexeff = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
	</cfif>
	<!--- Write the sh script files --->
	<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#arguments.thestruct.therandom#.sh">
	<!--- On Windows a .bat --->
	<cfif iswindows>
		<cfset arguments.thestruct.theshd = GetTempDirectory() & "/#arguments.thestruct.therandom#.bat">
	</cfif>
	<cftry>
		<!--- We need to query the existing file --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="arguments.thestruct.qryfilelocal">
			SELECT
			img_id, folder_id_r, img_filename_org file_name_org, thumb_width, thumb_height, hashtag,
			img_width, img_height, img_size, thumb_size, img_extension orgext, path_to_asset, cloud_url, cloud_url_org, img_meta as metadata, thumb_extension thumbext
			FROM #arguments.thestruct.razuna.session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- Check if image is an animated GIF. Remove double quotes from path if present --->
			<cfinvoke component="assets" method="isAnimatedGIF" imagepath="#replace(arguments.thestruct.thesource,'"','','ALL')#" thepathim= "#arguments.thestruct.thetools.imagemagick#" returnvariable="isAnimGIF">
			<!--- animated GIFs can only be converted to GIF --->
			<cfif isAnimGIF>
				<cfset QuerySetCell(arguments.thestruct.qrysettings, "set2_img_format", "gif", 1)>
			</cfif>
			<cfset arguments.thestruct.destination = "#arguments.thestruct.qryfile.path#/thumb_#arguments.thestruct.qryfile.file_id#.#arguments.thestruct.qrysettings.set2_img_format#">
			<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
			<cfset arguments.thestruct.width = arguments.thestruct.qrysettings.set2_img_thumb_width>
			<cfset arguments.thestruct.height = arguments.thestruct.qrysettings.set2_img_thumb_heigth>
			<cfset arguments.thestruct.newid = arguments.thestruct.therandom>
			<cfset arguments.thestruct.thexmp.orgwidth = arguments.thestruct.qryfilelocal.img_width>
			<cfset arguments.thestruct.thexmp.orgheight = arguments.thestruct.qryfilelocal.img_height>
			<!--- resize original to thumb. This also returns the original width and height --->
			<cfinvoke component="assets" method="resizeImage">
				<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
			</cfinvoke>
			<!--- Get size of original and thumbnail --->
			<cfset var ts = arguments.thestruct.therandom>
			<cfset var ths = "t#arguments.thestruct.therandom#">
			<cfthread name="#ts#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#" returnvariable="orgsize">
				<cfoutput>#trim(orgsize)#</cfoutput>
			</cfthread>
			<cfthread name="#ths#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.qryfile.path#/thumb_#attributes.intstruct.qryfile.file_id#.#attributes.intstruct.qrysettings.set2_img_format#" returnvariable="orgsize">
				<cfoutput>#trim(orgsize)#</cfoutput>
			</cfthread>
			<cfthread action="join" name="#ts#,#ths#" timeout="6000" />
			<!--- Write the sh script files --->
			<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#ts#w.sh">
			<cfset arguments.thestruct.theshh = GetTempDirectory() & "/#ts#h.sh">
			<!--- On Windows a .bat --->
			<cfif iswindows>
				<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#ts#w.bat">
				<cfset arguments.thestruct.theshh = GetTempDirectory() & "/#ts#h.bat">
			</cfif>
			<!--- Write script for getting height and weight --->
			<cffile action="write" file="#arguments.thestruct.theshh#" output="#arguments.thestruct.theexif# -S -s -ImageHeight #arguments.thestruct.thesource#" mode="777">
			<cffile action="write" file="#arguments.thestruct.theshw#" output="#arguments.thestruct.theexif# -S -s -ImageWidth #arguments.thestruct.thesource#" mode="777">
			<!--- Get height and width --->
			<cfexecute name="#arguments.thestruct.theshh#" timeout="60" variable="theheight" />
			<cfexecute name="#arguments.thestruct.theshw#" timeout="60" variable="thewidth" />
			<!--- Get width and height for thumbnail --->
			<cfexecute name="#arguments.thestruct.theexif#" arguments="-S -s -ImageHeight #arguments.thestruct.qryfile.path#/thumb_#arguments.thestruct.qryfile.file_id#.#arguments.thestruct.qrysettings.set2_img_format#" variable="thumbheight" timeout="60" />
			<cfexecute name="#arguments.thestruct.theexif#" arguments="-S -s -ImageWidth #arguments.thestruct.qryfile.path#/thumb_#arguments.thestruct.qryfile.file_id#.#arguments.thestruct.qrysettings.set2_img_format#" variable="thumbwidth" timeout="60" />
			<!--- Exiftool on windows return the whole path with the sizes thus trim and get last --->
			<cfset var theheight = trim(listlast(theheight," "))>
			<cfset var thewidth = trim(listlast(thewidth," "))>
			<cfif !isNumeric(theheight)>
				<cfset theheight = 0>
			</cfif>
			<cfif !isNumeric(thewidth)>
				<cfset thewidth = 0>
			</cfif>
			<!--- Remove the temp file sh --->
			<cffile action="delete" file="#arguments.thestruct.theshw#">
			<cffile action="delete" file="#arguments.thestruct.theshh#">
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = "thumb_#arguments.thestruct.qryfile.file_id#.#arguments.thestruct.qrysettings.set2_img_format#">
			<cfset arguments.thestruct.thumbnailname_new = arguments.thestruct.thumbnailname_existing>
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="ver_img_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="ver_img_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
			<!--- MD5 Hash --->
			<cfset var md5hash = hashbinary(arguments.thestruct.thesource)>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="arguments.thestruct.qryfilelocal">
			SELECT vid_id, folder_id_r, vid_name_org file_name_org, vid_size, vid_width, vid_height,
			vid_name_image, vid_extension orgext, path_to_asset, cloud_url, cloud_url_org, hashtag, vid_meta as metadata
			FROM #arguments.thestruct.razuna.session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- Put together the filenames --->
			<cfset arguments.thestruct.thisvid.theorgimage = "#arguments.thestruct.qryfile.filenamenoext#" & ".jpg">
			<!--- Just assign the current path to the finalpath --->
			<cfset arguments.thestruct.thisvid.finalpath = arguments.thestruct.qryfile.path>
			<cfset arguments.thestruct.thisvid.newid = arguments.thestruct.therandom>
			<cfset arguments.thestruct.thetempdirectory = GetTempDirectory()>
			<!--- Create thumbnail --->
			<cfthread name="p#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<cfinvoke component="videos" method="create_previews" thestruct="#attributes.intstruct#">
			</cfthread>
			<!--- Wait until Thumbnail is done --->
			<cfthread action="join" name="p#arguments.thestruct.therandom#" timeout="6000" />
			<!--- Move thumbnail to incoming directory --->
			<cffile action="move" source="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thisvid.theorgimage#" destination="#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.thisvid.theorgimage#" mode="775" />
			<!--- Check the platform and then decide on the ImageMagick tag --->
			<cfif FindNoCase("Windows", server.os.name)>
				<cfset arguments.thestruct.theidentify = """#arguments.thestruct.thetools.imagemagick#/identify.exe""">
			<cfelse>
				<cfset arguments.thestruct.theidentify = "#arguments.thestruct.thetools.imagemagick#/identify">
			</cfif>
			<!--- Get size of original --->
			<cfset var ts = "g#arguments.thestruct.therandom#">
			<cfthread name="#ts#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.qryfile.filename#" returnvariable="orgsize">
				<cfoutput>#trim(orgsize)#</cfoutput>
			</cfthread>
			<!--- Get image width --->
			<cfset var tw = "gw#arguments.thestruct.therandom#">
			<cfthread name="#tw#" intstruct="#arguments.thestruct#" output="yes">
				<cfexecute name="#attributes.intstruct.theexif#" arguments=" -S -s -ImageWidth #attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.thisvid.theorgimage#" timeout="10" variable="orgwidth" />
				<cfset orgwidth = trim(listlast(orgwidth," "))>
				<cfoutput>#trim(orgwidth)#</cfoutput>
			</cfthread>
			<!--- Get image height --->
			<cfset var th = "gh#arguments.thestruct.therandom#">
			<cfthread name="#th#" intstruct="#arguments.thestruct#" output="yes">
				<cfexecute name="#attributes.intstruct.theexif#" arguments="-S -s -ImageHeight #attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.thisvid.theorgimage#" timeout="10" variable="orgheight" />
				<cfset orgheight = trim(listlast(orgheight," "))>
				<cfoutput>#trim(orgheight)#</cfoutput>
			</cfthread>
			<!--- Join threads --->
			<cfthread action="join" name="#ts#,#tw#,#th#" timeout="6000" />
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = replacenocase(arguments.thestruct.qryfilelocal.file_name_org,".#arguments.thestruct.qryfilelocal.orgext#",".jpg","all")>
			<cfset arguments.thestruct.thumbnailname_new = arguments.thestruct.thisvid.theorgimage>
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="ver_vid_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="ver_vid_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
			<!--- MD5 Hash --->
			<cfset var md5hash = hashbinary("#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#")>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="arguments.thestruct.qryfilelocal">
			SELECT aud_id, folder_id_r, aud_name_org file_name_org, aud_size, aud_extension orgext, path_to_asset, cloud_url, cloud_url_org, hashtag, aud_meta as metadata
			FROM #arguments.thestruct.razuna.session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- Read Meta from audio file --->
			<cfexecute name="#arguments.thestruct.theexif#" arguments="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" timeout="5" variable="idtags" />
			<!--- Create Raw Audio file --->
			<cfthread name="wav#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<cfif attributes.intstruct.qryfile.extension NEQ "wav">
					<cfexecute name="#attributes.intstruct.theexeff#" arguments="-i #attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename# #attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filenamenoext#.wav" timeout="10" />
				</cfif>
			</cfthread>
			<!--- Wait until the WAV is done --->
			<cfthread action="join" name="wav#arguments.thestruct.therandom#" />
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = replacenocase(arguments.thestruct.qryfilelocal.file_name_org,".#arguments.thestruct.qryfilelocal.orgext#",".wav","all")>
			<cfset arguments.thestruct.thumbnailname_new = "#arguments.thestruct.qryfile.filenamenoext#.wav">
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="ver_aud_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="ver_aud_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
			<!--- MD5 Hash --->
			<cfset var md5hash = hashbinary('#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#')>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="arguments.thestruct.qryfilelocal">
			SELECT file_id, folder_id_r, file_name_org, file_extension orgext, path_to_asset, cloud_url, cloud_url_org, hashtag, file_meta as metadata, file_size
			FROM #arguments.thestruct.razuna.session.hostdbprefix#files
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = replacenocase(arguments.thestruct.qryfilelocal.file_name_org,".pdf",".jpg","all")>
			<cfset arguments.thestruct.thumbnailname_new = "#arguments.thestruct.qryfile.filenamenoext#.jpg">
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="ver_file_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="ver_file_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
			<!--- MD5 Hash --->
			<cfif arguments.thestruct.qryfile.path contains arguments.thestruct.qryfile.filename>
				<cfset var md5hash = hashbinary('#arguments.thestruct.qryfile.path#')>
			<cfelse>
				<cfset var md5hash = hashbinary('#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#')>
			</cfif>

			<!--- Remove the filename from the path --->
			<cfset arguments.thestruct.qryfile.path = replacenocase(arguments.thestruct.qryfile.path,"/#arguments.thestruct.qryfile.filename#","","one")>
		</cfif>
		<!--- Create a new version number --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qryversion">
		SELECT <cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">NVL<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql">ifnull<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mssql">isnull</cfif>(max(ver_version),0) + 1 AS newversion
		FROM #arguments.thestruct.razuna.session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
		AND ver_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Create directory --->
		<cfif arguments.thestruct.razuna.application.storage EQ "local">
			<!--- Create folder with the version --->
			<cfif !directoryExists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#" mode="775">
			</cfif>
			<!--- Move the file to the versions directory --->
			<cfif directoryExists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#")>
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#" move="T">
			</cfif>
			<!--- Grab the new version and move it to the old directory --->
			<cfif directoryExists(arguments.thestruct.qryfile.path)>
				<!--- Delete existing files in directory --->
				<cfdirectory action="list" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#" recurse="false" listinfo="name" name="qFile" />
				<!--- Loop through file query and delete files --->
				<cfloop query="qFile">
				    <cffile action="delete" file="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#/#qFile.name#">
				</cfloop>
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.qryfile.path#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#" move="T">
			</cfif>

			<cfif arguments.thestruct.qryfilelocal.orgext EQ 'PDF'>
				<!--- Create folder with the version inside razuna_pdf_images folder --->
				<cfif !directoryExists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#/razuna_pdf_images/#qryversion.newversion#")>
					<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#/razuna_pdf_images/#qryversion.newversion#" mode="775">
				</cfif>

				<!--- move {razuna_pdf_images folder} content {version #}  --->
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#/razuna_pdf_images/" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#/razuna_pdf_images/#qryversion.newversion#" fileaction="move" move="T">

				<!--- move from incoming folder JPGs to {razuna_pdf_images folder} --->
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.thepdfdirectory#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#/razuna_pdf_images/" fileaction="move"  move="T">
			</cfif>
		<!--- Amazon --->
		<cfelseif arguments.thestruct.razuna.application.storage EQ "amazon">
			<cfset arguments.thestruct.newversion = qryversion.newversion>
			<cfset var mtt = createuuid("")>
			<!--- Move the file to the versions directory --->
			<cfthread name="#mtt#" intstruct="#arguments.thestruct#">
				<!--- Move --->
				<cfinvoke component="amazon" method="movefolder">
					<cfinvokeargument name="folderpath" value="/#attributes.intstruct.qryfilelocal.path_to_asset#">
					<cfinvokeargument name="folderpathdest" value="versions/#attributes.intstruct.type#/#attributes.intstruct.qryfile.file_id#/#attributes.intstruct.newversion#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					<cfinvokeargument name="thestruct" value="#attributes.intstruct#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the move thread to finish --->
			<cfthread action="join" name="#mtt#" />
			<!--- Upload the new version to the old directory --->
			<cfthread name="u#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<!--- Upload Original --->
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qryfilelocal.path_to_asset#/#attributes.intstruct.qryfile.filename#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					<cfinvokeargument name="thestruct" value="#attributes.intstruct#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the upload thread to finish --->
			<cfthread action="join" name="u#arguments.thestruct.therandom#" />
			<!--- If document is not pdf or indd then no thumb is needed --->
			<cfif arguments.thestruct.type NEQ 'doc' OR (arguments.thestruct.qryfilelocal.orgext EQ 'PDF' OR arguments.thestruct.qryfilelocal.orgext EQ 'INDD')>
				<!--- Upload Thumbnail --->
				<cfthread name="ut#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Upload">
						<cfinvokeargument name="key" value="/#attributes.intstruct.qryfilelocal.path_to_asset#/#attributes.intstruct.thumbnailname_new#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.thumbnailname_new#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						<cfinvokeargument name="thestruct" value="#attributes.intstruct#">
					</cfinvoke>
				</cfthread>
				<!--- Wait for the upload thread to finish --->
				<cfthread action="join" name="ut#arguments.thestruct.therandom#" />
				<!--- Get SignedURL thumbnail --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfilelocal.path_to_asset#/#arguments.thestruct.thumbnailname_new#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			</cfif>
			<!--- Get SignedURL original --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfilelocal.path_to_asset#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<!--- Get SignedURL for the original in the versions --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.qryfilelocal.file_name_org#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<!--- Get the thumbnail  --->
			<cfif arguments.thestruct.type EQ "img">
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version_thumb" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/thumb_#arguments.thestruct.qryfile.file_id#.#arguments.thestruct.qrysettings.set2_img_format#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<cfelseif arguments.thestruct.type EQ "vid">
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version_thumb" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/#listFirst(arguments.thestruct.qryfilelocal.file_name_org,".")#.jpg" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			<cfelseif arguments.thestruct.type EQ 'doc' AND (arguments.thestruct.qryfilelocal.orgext EQ 'PDF' OR arguments.thestruct.qryfilelocal.orgext EQ 'INDD')>
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version_thumb" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/#listFirst(arguments.thestruct.qryfilelocal.file_name_org,".")#.jpg" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfif>
		<!--- Update the record in versions DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#versions
		(asset_id_r, ver_version, ver_type,	ver_date_add, ver_who, ver_filename_org, ver_extension, host_id, cloud_url_org,cloud_url_thumb, ver_thumbnail, hashtag, rec_uuid, meta_data
		<!--- For images --->
		<cfif arguments.thestruct.type EQ "img">
			,
			thumb_width, thumb_height, img_width, img_height, img_size, thumb_size
		<!--- For Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			,
			vid_size, vid_width, vid_height, vid_name_image
		<!--- For Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			,
			vid_size
		<cfelse>
			,
			file_size
		</cfif>
		)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qryversion.newversion#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.razuna.session.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.file_name_org#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.orgext#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_version.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_version_thumb.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thumbnailname_existing#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.hashtag#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.metadata#">
		<!--- For images --->
		<cfif arguments.thestruct.type EQ "img">
			,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.qryfilelocal.thumb_width#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.qryfilelocal.thumb_height#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.qryfilelocal.img_width#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.qryfilelocal.img_height#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.img_size#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.thumb_size#">
		<!--- For Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.vid_size#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.qryfilelocal.vid_width#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.qryfilelocal.vid_height#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.vid_name_image#">
		<!--- For Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.aud_size#">
		<cfelse>
			,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.file_size#">
		</cfif>
		)
		</cfquery>
		<!--- Update the root DB --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images
			SET
			img_filename_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			img_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			img_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			thumb_extension = <cfqueryparam value="#arguments.thestruct.qrysettings.set2_img_format#" cfsqltype="cf_sql_varchar">,
			thumb_width =
			<cfif isnumeric(thumbwidth)>
				<cfqueryparam value="#thumbwidth#" cfsqltype="cf_sql_numeric">
			<cfelse>
				null
			</cfif>
			, thumb_height =
			<cfif isnumeric(thumbheight)>
				<cfqueryparam value="#thumbheight#" cfsqltype="cf_sql_numeric">
			<cfelse>
				null
			</cfif>,
			img_width = <cfqueryparam value="#thewidth#" cfsqltype="cf_sql_numeric">,
			img_height = <cfqueryparam value="#theheight#" cfsqltype="cf_sql_numeric">,
			img_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cfthread["#ts#"].output)#">,
			thumb_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cfthread["#ths#"].output)#">,
			path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfilelocal.path_to_asset#" cfsqltype="cf_sql_varchar">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#md5hash#">,
			img_meta = <cfqueryparam value="#ver_img_meta#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif arguments.thestruct.razuna.application.storage EQ "nirvanix" OR arguments.thestruct.razuna.application.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="images", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
			<!--- Parse keywords and description from XMP --->
			<cfinvoke component="xmp" method="xmpwritekeydesc" thestruct="#arguments.thestruct#" />
			<!--- Parse the Metadata from the image --->
			<cfthread name="xmp#arguments.thestruct.qryfile.file_id#" intstruct="#arguments.thestruct#" action="run">
				<cfinvoke component="xmp" method="xmpparse" thestruct="#attributes.intstruct#" returnvariable="thread.thexmp" />
			</cfthread>
			<!--- Wait for the parsing --->
			<cfthread action="join" name="xmp#arguments.thestruct.qryfile.file_id#" />
			<!--- Put the thread result into general struct --->
			<cfset arguments.thestruct.thexmp = cfthread["xmp#arguments.thestruct.qryfile.file_id#"].thexmp>
			<!--- Write the Keywords and Description to the DB (if we are JPG we parse XMP and add them together) --->
			<cftry>
				<!--- Set Variable --->
				<cfset arguments.thestruct.assetpath = arguments.thestruct.qrysettings.set2_path_to_assets>
				<!--- Store XMP values in DB --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				UPDATE #arguments.thestruct.razuna.session.hostdbprefix#xmp
				SET
				asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
				subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsubjectcode#">,
				creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.creator#">,
				title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.title#">,
				authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.authorstitle#">,
				captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.descwriter#">,
				ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcaddress#">,
				category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.category#">,
				supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.categorysub#">,
				urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.urgency#">,
				description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.description#">,
				ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccity#">,
				ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccountry#">,
				location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptclocation#">,
				ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptczip#">,
				ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcemail#">,
				ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcwebsite#">,
				citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcphone#">,
				intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcintelgenre#">,
				instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcinstructions#">,
				source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsource#">,
				usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcusageterms#">,
				copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copystatus#">,
				transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcjobidentifier#">,
				webstatement  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copyurl#">,
				headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcheadline#">,
				datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcdatecreated#">,
				city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecity#">,
				ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagestate#">,
				country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountry#">,
				countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountrycode#">,
				scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcscene#">,
				state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcstate#">,
				credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccredit#">,
				rights = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copynotice#">,
				colorspace = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.colorspace#">,
				xres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.xres#">,
				yres = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.yres#">,
				resunit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.resunit#">,
				host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				WHERE id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
				</cfquery>
				<cfcatch type="any">
					<cfdump var="#cfcatch#">
				</cfcatch>
			</cftry>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#videos
			SET
			vid_name_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			vid_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			vid_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			vid_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			vid_name_image = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thisvid.theorgimage#">,
			vid_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cfthread["#ts#"].output)#">,
			vid_width = <cfqueryparam cfsqltype="cf_sql_numeric" value="#trim(cfthread["#tw#"].output)#">,
			vid_height = <cfqueryparam cfsqltype="cf_sql_numeric" value="#trim(cfthread["#th#"].output)#">,
			path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfilelocal.path_to_asset#" cfsqltype="cf_sql_varchar">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#md5hash#">,
			vid_meta = <cfqueryparam value="#ver_vid_meta#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif arguments.thestruct.razuna.application.storage EQ "nirvanix" OR arguments.thestruct.razuna.application.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="videos", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#audios
			SET
			aud_name_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			aud_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			aud_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			aud_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			aud_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.thesize#">,
			path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfilelocal.path_to_asset#" cfsqltype="cf_sql_varchar">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#md5hash#">,
			aud_meta = <cfqueryparam value="#ver_aud_meta#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif arguments.thestruct.razuna.application.storage EQ "nirvanix" OR arguments.thestruct.razuna.application.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="audios", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#files
			SET
			file_name_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			file_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			file_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			file_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.thesize#">,
			path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfilelocal.path_to_asset#" cfsqltype="cf_sql_varchar">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,<cfinvoke component="defaults" method="trans" transid="ftp_read_error" returnvariable="ftp_read_error" />
			<cfif cloud_url.theurl NEQ ''>cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,</cfif>
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#md5hash#">,
			file_meta = <cfqueryparam value="#ver_file_meta#" cfsqltype="cf_sql_varchar">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif arguments.thestruct.razuna.application.storage EQ "nirvanix" OR arguments.thestruct.razuna.application.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset resetcachetoken(type="files", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
			<!--- RAZ-2475 : Flush folders cache to get the latest thumbnail of PDF --->
			<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)> <!--- This will update folder view--->
			<!--- We need to update the information tab of the popup too. --->
		</cfif>

		<cfset arguments.thestruct.qrydetail.path_to_asset = arguments.thestruct.qryfilelocal.path_to_asset>
		<cfset arguments.thestruct.qrydetail.filenameorg = arguments.thestruct.qryfilelocal.file_name_org>
		<cfset arguments.thestruct.filenameorg = arguments.thestruct.qryfilelocal.file_name_org>
		<!--- Add entry into log --->
		<cfinvoke component="defaults" method="trans" transid="added" returnvariable="added_txt" />
		<cfinvoke component="defaults" method="trans" transid="new_version" returnvariable="new_version" />
		<cfset log_assets(theuserid=arguments.thestruct.razuna.session.theuserid,logaction='Add',logdesc='#added_txt# #new_version#: #arguments.thestruct.qryfilelocal.file_name_org#',logfiletype='#arguments.thestruct.type#',assetid='#arguments.thestruct.qryfile.file_id#',folderid='#arguments.thestruct.folder_id#', hostid=arguments.thestruct.razuna.session.hostid)>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>
	</cftry>
	<cfset consoleoutput(true, true)>
	<cfset console('VERSIOING DONE')>


	<!--- Reset folders cachetoken so preview images update --->
	<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- RAZ-2907 for bulk upload versions --->
<cffunction name="upload_old_versions" output="false" >
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_2 = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset var cloud_url_version = structnew()>
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_version.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cfset thumbnailname = "">
	<cfset var isAnimGIF = 0>
	<cfset arguments.thestruct.therandom = createuuid("")>
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" thestruct="#arguments.thestruct#" />
	<!--- Get windows or not --->
	<cfinvoke component="global" method="iswindows" returnVariable="iswindows" />

	<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#arguments.thestruct.therandom#.sh">
	<!--- Set Exiftool --->
	<cfif isWindows>
		<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfset arguments.thestruct.theexeff = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
	<cfelse>
		<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset arguments.thestruct.theexeff = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
	</cfif>
	<cftry>
		<cfif arguments.thestruct.type EQ "img">
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- Check if image is an animated GIF. Remove double quotes from path if present --->
			<cfinvoke component="assets" method="isAnimatedGIF" imagepath="#replace(arguments.thestruct.thesource,'"','','ALL')#" thepathim= "#arguments.thestruct.thetools.imagemagick#" returnvariable="isAnimGIF">
			<!--- animated GIFs can only be converted to GIF --->
			<cfif isAnimGIF>
				<cfset QuerySetCell(arguments.thestruct.qrysettings, "set2_img_format", "gif", 1)>
			</cfif>
			<cfset arguments.thestruct.destination = "#arguments.thestruct.qryfile.path#/thumb_#arguments.thestruct.qryfile.file_id#.#arguments.thestruct.qrysettings.set2_img_format#">
			<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
			<cfset arguments.thestruct.width = arguments.thestruct.qrysettings.set2_img_thumb_width>
			<cfset arguments.thestruct.height = arguments.thestruct.qrysettings.set2_img_thumb_heigth>
			<cfset arguments.thestruct.thexmp.orgwidth = "">
			<cfset arguments.thestruct.thexmp.orgheight = "">
			<cfset arguments.thestruct.newid = arguments.thestruct.therandom>
			<cfset arguments.thestruct.filename_org = arguments.thestruct.qryfile.filename>
			<cfset arguments.thestruct.org_ext = listlast("#arguments.thestruct.qryfile.filename#",'.')>
			<cfset arguments.thestruct.path_to_asset = "#arguments.thestruct.folder_id#/#arguments.thestruct.type#/#arguments.thestruct.file_id#">
			<!--- resize original to thumb. This also returns the original width and height --->
			<cfinvoke component="assets" method="resizeImage">
				<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
			</cfinvoke>
			<!--- Get size of original and thumbnail --->
			<cfset var ts = arguments.thestruct.therandom>
			<cfset var ths = "t#arguments.thestruct.therandom#">
			<cfthread name="#ts#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#" returnvariable="thread.orgsize">
				<cfoutput>#trim(thread.orgsize)#</cfoutput>
			</cfthread>
			<cfthread name="#ths#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.qryfile.path#/thumb_#attributes.intstruct.qryfile.file_id#.#attributes.intstruct.qrysettings.set2_img_format#" returnvariable="thread.orgsize">
				<cfoutput>#trim(thread.orgsize)#</cfoutput>
			</cfthread>
			<cfthread action="join" name="#ts#,#ths#" timeout="6000" />
			<!--- Size of original image --->
			<cfset arguments.thestruct.org_size = cfthread['#ts#'].orgsize >
			<!--- Size of original image --->
			<cfset arguments.thestruct.thumb_size = cfthread['#ths#'].orgsize >
			<!--- Write the sh script files --->
			<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#ts#w.sh">
			<cfset arguments.thestruct.theshh = GetTempDirectory() & "/#ts#h.sh">
			<!--- On Windows a .bat --->
			<cfif iswindows>
				<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#ts#w.bat">
				<cfset arguments.thestruct.theshh = GetTempDirectory() & "/#ts#h.bat">
			</cfif>
			<!--- Write script for getting height and weight --->
			<cffile action="write" file="#arguments.thestruct.theshh#" output="#arguments.thestruct.theexif# -S -s -ImageHeight #arguments.thestruct.thesource#" mode="777">
			<cffile action="write" file="#arguments.thestruct.theshw#" output="#arguments.thestruct.theexif# -S -s -ImageWidth #arguments.thestruct.thesource#" mode="777">
			<!--- Get height and width --->
			<cfexecute name="#arguments.thestruct.theshh#" timeout="60" variable="theheight" />
			<cfexecute name="#arguments.thestruct.theshw#" timeout="60" variable="thewidth" />
			<!--- Exiftool on windows return the whole path with the sizes thus trim and get last --->
			<cfset arguments.thestruct.theheight = trim(listlast(theheight," "))>
			<cfset arguments.thestruct.thewidth = trim(listlast(thewidth," "))>
			<cfif !isNumeric(arguments.thestruct.theheight)>
				<cfset arguments.thestruct.theheight = 0>
			</cfif>
			<cfif !isNumeric(arguments.thestruct.thewidth)>
				<cfset arguments.thestruct.thewidth = 0>
			</cfif>
			<!--- Remove the temp file sh --->
			<cffile action="delete" file="#arguments.thestruct.theshw#">
			<cffile action="delete" file="#arguments.thestruct.theshh#">
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = "thumb_#arguments.thestruct.qryfile.file_id#.#arguments.thestruct.qrysettings.set2_img_format#">
			<cfset arguments.thestruct.thumbnailname_new = arguments.thestruct.thumbnailname_existing>
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="arguments.thestruct.ver_img_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="arguments.thestruct.ver_img_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
			<!--- MD5 Hash --->
			<cfset arguments.thestruct.md5hash = hashbinary(arguments.thestruct.thesource)>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<!--- Put together the filenames --->
			<cfset arguments.thestruct.thisvid.theorgimage = "#arguments.thestruct.qryfile.filenamenoext#" & ".jpg">
			<!--- Just assign the current path to the finalpath --->
			<cfset arguments.thestruct.thisvid.finalpath = arguments.thestruct.qryfile.path>
			<cfset arguments.thestruct.thisvid.newid = arguments.thestruct.therandom>
			<cfset arguments.thestruct.thetempdirectory = GetTempDirectory()>
			<cfset arguments.thestruct.filename_org = arguments.thestruct.qryfile.filename>
			<cfset arguments.thestruct.org_ext = listlast("#arguments.thestruct.qryfile.filename#",'.')>
			<cfset arguments.thestruct.path_to_asset = "#arguments.thestruct.folder_id#/#arguments.thestruct.type#/#arguments.thestruct.file_id#">
			<!--- Create thumbnail --->
			<cfthread name="p#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<cfinvoke component="videos" method="create_previews" thestruct="#attributes.intstruct#">
			</cfthread>
			<!--- Wait until Thumbnail is done --->
			<cfthread action="join" name="p#arguments.thestruct.therandom#" timeout="6000" />
			<!--- Move thumbnail to incoming directory --->
			<cffile action="move" source="#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thisvid.theorgimage#" destination="#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.thisvid.theorgimage#" mode="775" />
			<!--- Check the platform and then decide on the ImageMagick tag --->
			<cfif FindNoCase("Windows", server.os.name)>
				<cfset arguments.thestruct.theidentify = """#arguments.thestruct.thetools.imagemagick#/identify.exe""">
			<cfelse>
				<cfset arguments.thestruct.theidentify = "#arguments.thestruct.thetools.imagemagick#/identify">
			</cfif>
			<!--- Get size of original --->
			<cfset var ts = "g#arguments.thestruct.therandom#">
			<cfthread name="#ts#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.qryfile.filename#" returnvariable="thread.orgsize">
				<cfoutput>#trim(thread.orgsize)#</cfoutput>
			</cfthread>
			<!--- Get image width --->
			<cfset var tw = "gw#arguments.thestruct.therandom#">
			<cfthread name="#tw#" intstruct="#arguments.thestruct#" output="yes">
				<cfexecute name="#attributes.intstruct.theexif#" arguments=" -S -s -ImageWidth #attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.thisvid.theorgimage#" timeout="10" variable="thread.orgwidth" />
				<cfset var orgwidth = trim(listlast(thread.orgwidth," "))>
				<cfoutput>#trim(orgwidth)#</cfoutput>
			</cfthread>
			<!--- Get image height --->
			<cfset var th = "gh#arguments.thestruct.therandom#">
			<cfthread name="#th#" intstruct="#arguments.thestruct#" output="yes">
				<cfexecute name="#attributes.intstruct.theexif#" arguments="-S -s -ImageHeight #attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.thisvid.theorgimage#" timeout="10" variable="thread.orgheight" />
				<cfset var orgheight = trim(listlast(thread.orgheight," "))>
				<cfoutput>#trim(orgheight)#</cfoutput>
			</cfthread>
			<!--- Join threads --->
			<cfthread action="join" name="#ts#,#tw#,#th#" timeout="6000" />
			<!--- Size of original --->
			<cfset arguments.thestruct.org_size = cfthread['#ts#'].orgsize >
			<!--- Image Width --->
			<cfset arguments.thestruct.org_width = cfthread['#tw#'].orgwidth >
			<!--- Image height --->
			<cfset arguments.thestruct.org_height = cfthread['#th#'].orgheight >
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = replacenocase(arguments.thestruct.filename_org,".#arguments.thestruct.org_ext#",".jpg","all")>
			<cfset arguments.thestruct.thumbnailname_new = arguments.thestruct.thisvid.theorgimage>
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="arguments.thestruct.ver_vid_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="arguments.thestruct.ver_vid_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
			<!--- MD5 Hash --->
			<cfset arguments.thestruct.md5hash = hashbinary("#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#")>
			<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<cfset arguments.thestruct.filename_org = arguments.thestruct.qryfile.filename>
			<cfset arguments.thestruct.path_to_asset = "#arguments.thestruct.folder_id#/#arguments.thestruct.type#/#arguments.thestruct.file_id#">
			<cfset arguments.thestruct.org_ext = listlast("#arguments.thestruct.qryfile.filename#",'.')>
			<!--- Read Meta from audio file --->
			<cfexecute name="#arguments.thestruct.theexif#" arguments="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" timeout="5" variable="idtags" />
			<!--- Create Raw Audio file --->
			<cfthread name="wav#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<cfif attributes.intstruct.qryfile.extension NEQ "wav">
					<cfexecute name="#attributes.intstruct.theexeff#" arguments="-i #attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename# #attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filenamenoext#.wav" timeout="10" />
				</cfif>
			</cfthread>
			<!--- Wait until the WAV is done --->
			<cfthread action="join" name="wav#arguments.thestruct.therandom#" />
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = replacenocase(arguments.thestruct.filename_org,".#arguments.thestruct.org_ext#",".wav","all")>
			<cfset arguments.thestruct.thumbnailname_new = "#arguments.thestruct.qryfile.filenamenoext#.wav">
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="arguments.thestruct.ver_aud_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="arguments.thestruct.ver_aud_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>
			<!--- Get size of original --->
			<cfset var ts = "g#arguments.thestruct.therandom#">
			<cfthread name="#ts#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.thesource#" returnvariable="thread.orgsize">
				<cfoutput>#trim(thread.orgsize)#</cfoutput>
			</cfthread>

			<!--- Join threads --->
			<cfthread action="join" name="#ts#" timeout="6000" />
			<!--- Size of original --->
			<cfset arguments.thestruct.org_size = cfthread['#ts#'].orgsize >

			<!--- MD5 Hash --->
			<cfset arguments.thestruct.md5hash = hashbinary('#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#')>
		<!--- Documents --->
		<cfelse>
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
			<cfset arguments.thestruct.filename_org = arguments.thestruct.qryfile.filename>
			<cfset arguments.thestruct.path_to_asset = "#arguments.thestruct.folder_id#/#arguments.thestruct.type#/#arguments.thestruct.file_id#">
			<cfset arguments.thestruct.org_ext = listlast("#arguments.thestruct.qryfile.filename#",'.')>
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = replacenocase(arguments.thestruct.filename_org,".pdf",".jpg","all")>
			<cfset arguments.thestruct.thumbnailname_new = "#arguments.thestruct.qryfile.filenamenoext#.jpg">
			<!--- GET RAW META --->
			<cfif iswindows>
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.theexif#" arguments="-fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" timeout="60" variable="ver_file_meta" />
			<cfelse>
				<!--- Write Script --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -fast -fast2 -a -g -x ExifToolVersion -x Directory -x filename #arguments.thestruct.thesource#" mode="777">
				<!--- Execute Script --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="ver_file_meta" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
			</cfif>

			<!--- Get size of original --->
			<cfset var ts = "g#arguments.thestruct.therandom#">
			<cfthread name="#ts#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.thesource#" returnvariable="thread.orgsize">
				<cfoutput>#trim(thread.orgsize)#</cfoutput>
			</cfthread>

			<!--- Join threads --->
			<cfthread action="join" name="#ts#" timeout="6000" />
			<!--- Size of original --->
			<cfset arguments.thestruct.org_size = cfthread['#ts#'].orgsize >

			<!--- MD5 Hash --->
			<cfset arguments.thestruct.md5hash = hashbinary('#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#')>
			<!--- Remove the filename from the path --->
			<cfset arguments.thestruct.qryfile.path = replacenocase(arguments.thestruct.qryfile.path,"/#arguments.thestruct.qryfile.filename#","","one")>
		</cfif>
		<!--- Create a new version number --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qryversion">
		SELECT <cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">NVL<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql">ifnull<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mssql">isnull</cfif>(max(ver_version),0) + 1 AS newversion
		FROM #arguments.thestruct.razuna.session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ver_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif arguments.thestruct.razuna.application.storage EQ "local">
		<!--- Create folder with the version --->
			<cfif !directoryExists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#" mode="775">
			</cfif>
			<!--- Move the file to the versions directory --->
			<cfif directoryExists("#arguments.thestruct.qryfile.path#")>
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.qryfile.path#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#" move="T">
			</cfif>
			<cfif arguments.thestruct.org_ext EQ 'PDF'>
				<!--- Create folder with the version inside razuna_pdf_images folder --->
				<cfif !directoryExists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.path_to_asset#/razuna_pdf_images/#qryversion.newversion#")>
					<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.path_to_asset#/razuna_pdf_images/#qryversion.newversion#" mode="775">
				</cfif>
				<!--- move {razuna_pdf_images folder} content {version #}  --->
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.thepdfdirectory#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.razuna.session.hostid#/#arguments.thestruct.path_to_asset#/razuna_pdf_images/#qryversion.newversion#" fileaction="move" move="T">
			</cfif>
		<!--- Amazon --->
		<cfelseif arguments.thestruct.razuna.application.storage EQ "amazon">
			<cfset arguments.thestruct.newversion = qryversion.newversion>
			<cfset var mtt = createuuid("")>
			<!--- Move the file to the versions directory --->
			<cfthread name="#mtt#" intstruct="#arguments.thestruct#">
				<!--- Move --->
				<cfinvoke component="amazon" method="movefolder">
					<cfinvokeargument name="folderpath" value="#attributes.intstruct.qryfile.path#">
					<cfinvokeargument name="folderpathdest" value="versions/#attributes.intstruct.type#/#attributes.intstruct.qryfile.file_id#/#attributes.intstruct.newversion#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					<cfinvokeargument name="thestruct" value="#attributes.intstruct#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the move thread to finish --->
			<cfthread action="join" name="#mtt#" />
			<!--- Upload the new version to the old directory --->

			<cfthread name="u#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<!--- Upload Original --->
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.razuna.session.hostid#/versions/#attributes.intstruct.type#/#attributes.intstruct.qryfile.file_id#/#attributes.intstruct.newversion#/#attributes.intstruct.qryfile.filename#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
					<cfinvokeargument name="thestruct" value="#attributes.intstruct#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the upload thread to finish --->
			<cfthread action="join" name="u#arguments.thestruct.therandom#" />
			<!--- If document is not pdf or indd then no thumb is needed --->
			<cfif arguments.thestruct.type NEQ 'doc' OR (arguments.thestruct.org_ext EQ 'PDF' OR arguments.thestruct.org_ext EQ 'INDD')>
				<!--- Upload Thumbnail --->
				<cfthread name="ut#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
					<cfinvoke component="amazon" method="Upload">
						<cfinvokeargument name="key" value="/#attributes.intstruct.razuna.session.hostid#/versions/#attributes.intstruct.type#/#attributes.intstruct.qryfile.file_id#/#attributes.intstruct.newversion#/#attributes.intstruct.thumbnailname_new#">
						<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.thumbnailname_new#">
						<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						<cfinvokeargument name="thestruct" value="#attributes.intstruct#">
					</cfinvoke>
				</cfthread>
				<!--- Wait for the upload thread to finish --->
				<cfthread action="join" name="ut#arguments.thestruct.therandom#" />
				<!--- Get SignedURL thumbnail --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.thumbnailname_new#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
			</cfif>
			<!--- Get SignedURL for the original in the versions --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version" key="/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
		</cfif>
		<!--- Update the record in versions DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#versions
		(asset_id_r, ver_version, ver_type,	ver_date_add, ver_who, ver_filename_org, ver_extension, host_id, cloud_url_org,cloud_url_thumb, ver_thumbnail, hashtag, rec_uuid
		<!--- For images --->
		<cfif arguments.thestruct.type EQ "img">
			, meta_data
			,
			thumb_width, thumb_height, img_width, img_height, img_size, thumb_size
		<!--- For Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			, meta_data
			,
			vid_size, vid_width, vid_height, vid_name_image
		<!--- For Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			, meta_data
			,
			vid_size
		<cfelse>
			, file_size
		</cfif>
		)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qryversion.newversion#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.razuna.session.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.filename_org#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.org_ext#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_version.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thumbnailname_existing#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.md5hash#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		<!--- For images --->
		<cfif arguments.thestruct.type EQ "img">
			,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.ver_img_meta#">,
			<cfif isnumeric(arguments.thestruct.width)>
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.width#">
			<cfelse>
				null
			</cfif>,
			<cfif isnumeric(arguments.thestruct.height)>
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.height#">
			<cfelse>
				null
			</cfif>,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.theheight#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.thewidth#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.org_size#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thumb_size#">
		<!--- For Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.ver_vid_meta#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.org_size#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.org_width#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.org_height#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thisvid.theorgimage#">
		<!--- For Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.ver_aud_meta#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.org_size#">
		<cfelse>
			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.org_size#">
		</cfif>
		)
		</cfquery>
		<cfset log_assets(theuserid=arguments.thestruct.razuna.session.theuserid,logaction='Add',logdesc='Added Old Version: #arguments.thestruct.filename_org#',logfiletype='#arguments.thestruct.type#',assetid='#arguments.thestruct.qryfile.file_id#',folderid='#arguments.thestruct.folder_id#', hostid=arguments.thestruct.razuna.session.hostid)>
		<cfcatch type="any">
		</cfcatch>
	</cftry>
</cffunction>
</cfcomponent>
