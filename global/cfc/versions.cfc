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
	<!--- Query --->
	<cfquery datasource="#Variables.dsn#" name="qry">
	SELECT v.ver_version, v.ver_date_add, v.ver_filename_org, v.asset_id_r, v.cloud_url_org,
	u.user_login_name, u.user_first_name, u.user_last_name
	FROM #session.hostdbprefix#versions v LEFT JOIN users u ON u.user_id = v.ver_who
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
	<!--- Query --->
	<cfquery datasource="#Variables.dsn#">
	DELETE FROM #session.hostdbprefix#versions
	WHERE ver_version = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.version#">
	AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND ver_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
	</cfquery>
	<!--- Delete asset on system --->
	<cfif application.razuna.storage EQ "local">
		<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#" recurse="true">
	<cfelseif application.razuna.storage EQ "nirvanix">
		<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#">
	<cfelseif application.razuna.storage EQ "amazon">
		<cfinvoke component="amazon" method="deletefolder" folderpath="#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#" awsbucket="#arguments.thestruct.awsbucket#" />
	</cfif>
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
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_version.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cftry>
		<!--- First get details from current record --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#Variables.dsn#" name="qry">
			SELECT 
			folder_id_r, img_filename_org filenameorg, thumb_width, thumb_height, thumb_extension,
			img_width, img_height, img_size, thumb_size, img_extension orgext, path_to_asset, hashtag
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset thethumbname = "thumb_#arguments.thestruct.file_id#.#qry.thumb_extension#">
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#Variables.dsn#" name="qry">
			SELECT 
			folder_id_r, vid_name_org filenameorg, vid_size, vid_width, vid_height, 
			vid_name_image, vid_extension orgext, path_to_asset, hashtag
			FROM #session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset thethumbname = replacenocase(qry.filenameorg,".#qry.orgext#",".jpg","all")>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#Variables.dsn#" name="qry">
			SELECT 
			folder_id_r, aud_name_org filenameorg, aud_size, aud_extension orgext, path_to_asset, hashtag
			FROM #session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset thethumbname = replacenocase(qry.filenameorg,".#qry.orgext#",".wav","all")>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#Variables.dsn#" name="qry">
			SELECT folder_id_r, file_name_org filenameorg, file_extension orgext, path_to_asset, hashtag
			FROM #session.hostdbprefix#files
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset thethumbname = replacenocase(qry.filenameorg,".pdf",".jpg","all")>
		</cfif>
		<!--- Create a new version number --->
		<cfquery datasource="#Variables.dsn#" name="qryversion">
		SELECT <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(max(ver_version),0) + 1 AS newversion
		FROM #session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ver_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Query original file name of this version we need to replay --->
		<cfquery datasource="#Variables.dsn#" name="qrycurrentversion">
		SELECT ver_filename_org, ver_thumbnail
		FROM #session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ver_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar">
		AND ver_version = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.version#">
		</cfquery>
		<!--- Create directory --->
		<cfif application.razuna.storage EQ "local">
			<!--- Create folder with the version --->
			<cfif !directoryExists("#arguments.thestruct.assetpath#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#qryversion.newversion#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#qryversion.newversion#" mode="775">
			</cfif>
			<!--- Move the file to the versions directory --->
			<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.assetpath#/#session.hostid#/#qry.path_to_asset#" destination="#arguments.thestruct.assetpath#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#qryversion.newversion#" move="T">
			<!--- Now copy the version to the original directory --->
			<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.assetpath#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.version#" destination="#arguments.thestruct.assetpath#/#session.hostid#/#qry.path_to_asset#">
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<cfset arguments.thestruct.newversion = qryversion.newversion>
			<cfset arguments.thestruct.qry = qry>
			<!--- Move the file to the versions directory --->
			<cfthread name="movemo#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<!--- Move --->
				<cfinvoke component="nirvanix" method="MoveFolders">
					<cfinvokeargument name="srcFolderPath" value="/#attributes.intstruct.qry.path_to_asset#">
					<cfinvokeargument name="destFolderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="movemo#arguments.thestruct.file_id#" />
			<cfthread name="movero#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<!--- Rename --->
				<cfinvoke component="nirvanix" method="RenameFolders">
					<cfinvokeargument name="folderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#/#attributes.intstruct.file_id#">
					<cfinvokeargument name="newFolderName" value="#attributes.intstruct.newversion#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="movero#arguments.thestruct.file_id#" />
			<!--- Copy the new version to the old directory --->
			<cfthread name="movec#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<!--- Copy --->
				<cfinvoke component="nirvanix" method="CopyFolders">
					<cfinvokeargument name="srcFolderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#/#attributes.intstruct.version#">
					<cfinvokeargument name="destFolderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#/temp">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="movec#arguments.thestruct.file_id#" />
			<cfset sleep(5000)>
			<cfthread name="mover#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<!--- Rename --->
				<cfinvoke component="nirvanix" method="RenameFolders">
					<cfinvokeargument name="folderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#/temp/#attributes.intstruct.version#">
					<cfinvokeargument name="newFolderName" value="#attributes.intstruct.file_id#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="mover#arguments.thestruct.file_id#" />
			<cfthread name="movem#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<!--- Since we have the id as the last element of the path to asset we need to take it apart --->
				<cfset one = listgetat(attributes.intstruct.qry.path_to_asset,1,"/")>
				<cfset two = listgetat(attributes.intstruct.qry.path_to_asset,2,"/")>
				<cfset thepath = "#one#/#two#">
				<!--- Move folder to original directory --->
				<cfinvoke component="nirvanix" method="MoveFolders">
					<cfinvokeargument name="srcFolderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#/temp/#attributes.intstruct.file_id#">
					<cfinvokeargument name="destFolderPath" value="/#thepath#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="movem#arguments.thestruct.file_id#" />
			<!--- Get SignedURL thumbnail --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qry.path_to_asset#/#qrycurrentversion.ver_thumbnail#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- Get SignedURL original --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qry.path_to_asset#/#qrycurrentversion.ver_filename_org#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- Get SignedURL for the original in the versions --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_version" theasset="versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.qry.filenameorg#" nvxsession="#arguments.thestruct.nvxsession#">
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<cfset arguments.thestruct.newversion = qryversion.newversion>
			<cfset arguments.thestruct.qry = qry>
			<cfset arguments.thestruct.hostid = session.hostid>
			<!--- Move the file to the versions directory --->
			<cfthread name="move#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<!--- Move --->
				<cfinvoke component="amazon" method="movefolder">
					<cfinvokeargument name="folderpath" value="#attributes.intstruct.qry.path_to_asset#">
					<cfinvokeargument name="folderpathdest" value="#attributes.intstruct.hostid#/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#/#attributes.intstruct.newversion#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<cfset sleep(5000)>
			<!--- Wait for the move thread to finish --->
			<cfthread action="join" name="move#arguments.thestruct.file_id#" />
			<!--- Copy the new version to the old directory --->
			<cfthread name="movev#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<!--- Copy --->
				<cfinvoke component="amazon" method="copyfolder">
					<cfinvokeargument name="folderpath" value="#attributes.intstruct.hostid#/versions/#attributes.intstruct.type#/#attributes.intstruct.file_id#/#attributes.intstruct.version#">
					<cfinvokeargument name="folderpathdest" value="#attributes.intstruct.qry.path_to_asset#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the move thread to finish --->
			<cfthread action="join" name="movev#arguments.thestruct.file_id#" />
			<cfset sleep(5000)>
			<!--- Get SignedURL thumbnail --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qry.path_to_asset#/#qrycurrentversion.ver_thumbnail#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Get SignedURL original --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qry.path_to_asset#/#qrycurrentversion.ver_filename_org#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Get SignedURL for the original in the versions --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version" key="#arguments.thestruct.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.qry.filenameorg#" awsbucket="#arguments.thestruct.awsbucket#">
		</cfif>
		<!--- Update the record in versions DB --->
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#versions
		(asset_id_r, ver_version, ver_type,	ver_date_add, ver_who, ver_filename_org, ver_extension, host_id, cloud_url_org, ver_thumbnail, hashtag, rec_uuid
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
		</cfif>
		)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qryversion.newversion#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.filenameorg#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.orgext#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_version.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#thethumbname#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.hashtag#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
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
		</cfif>
		)
		</cfquery>
		<!--- Query version db for filename --->
		<cfquery datasource="#Variables.dsn#" name="qryv">
		SELECT 
		ver_filename_org, ver_extension, thumb_width, thumb_height, img_width, img_height, img_size, thumb_size,
		vid_size, vid_width, vid_height, vid_name_image, hashtag
		FROM #session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ver_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">
		AND ver_version = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.version#">
		</cfquery>
		<!--- Update asset db with playbacked version --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#Variables.dsn#">
			UPDATE #session.hostdbprefix#images
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
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("images")>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#Variables.dsn#">
			UPDATE #session.hostdbprefix#videos
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
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("videos")>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#Variables.dsn#">
			UPDATE #session.hostdbprefix#audios
			SET 
			aud_name_org = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_filename_org#">,
			aud_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_extension#">,
			aud_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.vid_size#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qryv.hashtag#">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("audios")>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#Variables.dsn#">
			UPDATE #session.hostdbprefix#files
			SET 
			file_name_org = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_filename_org#">,
			file_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryv.ver_extension#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qryv.hashtag#">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("files")>
		</cfif>
		<cfset arguments.thestruct.qrydetail.path_to_asset = qry.path_to_asset>
		<cfset arguments.thestruct.qrydetail.filenameorg = qry.filenameorg>
		<cfset arguments.thestruct.qrydetail.folder_id_r = qry.folder_id_r>
		<cfset arguments.thestruct.filenameorg = qry.filenameorg>
		<cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error in playback of a version">
				<cfdump var="#cfcatch#" />
			</cfmail>
		</cfcatch>
	</cftry>
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
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_2.theurl = "">
	<cfset cloud_url_version.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cfset thumbnailname = "">
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
	<!--- <cftry> --->
		<!--- We need to query the existing file --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#arguments.thestruct.dsn#" name="arguments.thestruct.qryfilelocal">
			SELECT 
			img_id, folder_id_r, img_filename_org file_name_org, thumb_width, thumb_height, hashtag,
			img_width, img_height, img_size, thumb_size, img_extension orgext, path_to_asset, cloud_url, cloud_url_org
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Params for resizeimage --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
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
			<cfset ts = arguments.thestruct.therandom>
			<cfset ths = "t#arguments.thestruct.therandom#">
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
			<!--- Exiftool on windows return the whole path with the sizes thus trim and get last --->
			<cfset theheight = trim(listlast(theheight," "))>
			<cfset thewidth = trim(listlast(thewidth," "))>
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
			<!--- MD5 Hash --->
			<cfset md5hash = hashbinary(arguments.thestruct.thesource)>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#arguments.thestruct.dsn#" name="arguments.thestruct.qryfilelocal">
			SELECT vid_id, folder_id_r, vid_name_org file_name_org, vid_size, vid_width, vid_height, 
			vid_name_image, vid_extension orgext, path_to_asset, cloud_url, cloud_url_org, hashtag
			FROM #session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
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
			<cfset ts = "g#arguments.thestruct.therandom#">
			<cfthread name="#ts#" intstruct="#arguments.thestruct#" output="yes">
				<cfinvoke component="global" method="getfilesize" filepath="#attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.qryfile.filename#" returnvariable="orgsize">
				<cfoutput>#trim(orgsize)#</cfoutput>
			</cfthread>
			<!--- Get image width --->
			<cfset tw = "gw#arguments.thestruct.therandom#">
			<cfthread name="#tw#" intstruct="#arguments.thestruct#" output="yes">
				<cfexecute name="#attributes.intstruct.theexif#" arguments=" -S -s -ImageWidth #attributes.intstruct.thisvid.finalpath#/#attributes.intstruct.thisvid.theorgimage#" timeout="10" variable="orgwidth" />
				<cfset orgwidth = trim(listlast(orgwidth," "))>
				<cfoutput>#trim(orgwidth)#</cfoutput>
			</cfthread>
			<!--- Get image height --->
			<cfset th = "gh#arguments.thestruct.therandom#">
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
			<!--- MD5 Hash --->
			<cfset md5hash = hashbinary("#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#")>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#arguments.thestruct.dsn#" name="arguments.thestruct.qryfilelocal">
			SELECT aud_id, folder_id_r, aud_name_org file_name_org, aud_size, aud_extension orgext, path_to_asset, cloud_url, cloud_url_org, hashtag
			FROM #session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
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
			<!--- MD5 Hash --->
			<cfset md5hash = hashbinary('#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#')>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#arguments.thestruct.dsn#" name="arguments.thestruct.qryfilelocal">
			SELECT file_id, folder_id_r, file_name_org, file_extension orgext, path_to_asset, cloud_url, cloud_url_org, hashtag
			FROM #session.hostdbprefix#files
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>		
			<!--- Name for thumbnail upload --->
			<cfset arguments.thestruct.thumbnailname_existing = replacenocase(arguments.thestruct.qryfilelocal.file_name_org,".pdf",".jpg","all")>
			<cfset arguments.thestruct.thumbnailname_new = "#arguments.thestruct.qryfile.filenamenoext#.jpg">
			<!--- MD5 Hash --->
			<cfset md5hash = hashbinary('#arguments.thestruct.qryfile.path#')>
			<!--- Remove the filename from the path --->
			<cfset arguments.thestruct.qryfile.path = replacenocase(arguments.thestruct.qryfile.path,"/#arguments.thestruct.qryfile.filename#","","one")>
		</cfif>
		<!--- Create a new version number --->
		<cfquery datasource="#arguments.thestruct.dsn#" name="qryversion">
		SELECT <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(max(ver_version),0) + 1 AS newversion
		FROM #session.hostdbprefix#versions
		WHERE asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
		AND ver_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Create directory --->
		<cfif application.razuna.storage EQ "local">
			<!--- Create folder with the version --->
			<cfif !directoryExists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#" mode="775">
			</cfif>
			<!--- Move the file to the versions directory --->
			<cfif directoryExists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#")>
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#qryversion.newversion#" move="T">
			</cfif>
			<!--- Grab the new version and move it to the old directory --->
			<cfif directoryExists(arguments.thestruct.qryfile.path)>
				<cfinvoke component="global" method="directoryCopy" source="#arguments.thestruct.qryfile.path#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfilelocal.path_to_asset#" move="T">
			</cfif>
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<cfset arguments.thestruct.newversion = qryversion.newversion>
			<cfset mtt = createuuid("")>
			<!--- Move the file to the versions directory --->
			<cfthread name="#mtt#" intstruct="#arguments.thestruct#">
				<!--- Move --->
				<cfinvoke component="nirvanix" method="MoveFolders">
					<cfinvokeargument name="srcFolderPath" value="/#attributes.intstruct.qryfilelocal.path_to_asset#">
					<cfinvokeargument name="destFolderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.qryfile.file_id#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the move thread to finish --->
			<cfthread action="join" name="#mtt#" />
			<!--- Rename the just moved folder --->
			<cfthread name="r#mtt#" intstruct="#arguments.thestruct#">
				<cfinvoke component="nirvanix" method="RenameFolders">
					<cfinvokeargument name="folderPath" value="/versions/#attributes.intstruct.type#/#attributes.intstruct.qryfile.file_id#/#attributes.intstruct.qryfile.file_id#">
					<cfinvokeargument name="newFolderName" value="#attributes.intstruct.newversion#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the rename thread to finish --->
			<cfthread action="join" name="r#mtt#" />
			<!--- Upload the new version to the old directory --->
			<cfthread name="u#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<!--- Upload Original --->
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfilelocal.path_to_asset#">
					<cfinvokeargument name="uploadfile" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the upload thread to finish --->
			<cfthread action="join" name="u#arguments.thestruct.therandom#" />
			<!--- Upload Thumbnail --->
			<cfthread name="ut#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfilelocal.path_to_asset#">
					<cfinvokeargument name="uploadfile" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.thumbnailname_new#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the upload thread to finish --->
			<cfthread action="join" name="ut#arguments.thestruct.therandom#" />
			<!--- Get SignedURL thumbnail --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfilelocal.path_to_asset#/#arguments.thestruct.thumbnailname_new#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- Get SignedURL original --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qryfilelocal.path_to_asset#/#arguments.thestruct.qryfile.filename#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- Get SignedURL for the original in the versions --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_version" theasset="versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.qryfilelocal.file_name_org#" nvxsession="#arguments.thestruct.nvxsession#">
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<cfset arguments.thestruct.newversion = qryversion.newversion>
			<cfset mtt = createuuid("")>
			<!--- Move the file to the versions directory --->
			<cfthread name="#mtt#" intstruct="#arguments.thestruct#">
				<!--- Move --->
				<cfinvoke component="amazon" method="movefolder">
					<cfinvokeargument name="folderpath" value="#attributes.intstruct.qryfilelocal.path_to_asset#">
					<cfinvokeargument name="folderpathdest" value="#attributes.intstruct.hostid#/versions/#attributes.intstruct.type#/#attributes.intstruct.qryfile.file_id#/#attributes.intstruct.newversion#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
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
				</cfinvoke>
			</cfthread>
			<!--- Wait for the upload thread to finish --->
			<cfthread action="join" name="u#arguments.thestruct.therandom#" />
			<!--- Upload Thumbnail --->
			<cfthread name="ut#arguments.thestruct.therandom#" intstruct="#arguments.thestruct#">
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qryfilelocal.path_to_asset#/#attributes.intstruct.thumbnailname_new#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.thumbnailname_new#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<!--- Wait for the upload thread to finish --->
			<cfthread action="join" name="ut#arguments.thestruct.therandom#" />
			<!--- Get SignedURL thumbnail --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfilelocal.path_to_asset#/#arguments.thestruct.thumbnailname_new#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Get SignedURL original --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfilelocal.path_to_asset#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Get SignedURL for the original in the versions --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_version" key="#session.hostid#/versions/#arguments.thestruct.type#/#arguments.thestruct.qryfile.file_id#/#arguments.thestruct.newversion#/#arguments.thestruct.qryfilelocal.file_name_org#" awsbucket="#arguments.thestruct.awsbucket#">
		</cfif>
		<!--- Update the record in versions DB --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO #session.hostdbprefix#versions
		(asset_id_r, ver_version, ver_type,	ver_date_add, ver_who, ver_filename_org, ver_extension, host_id, cloud_url_org, ver_thumbnail, hashtag, rec_uuid
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
		</cfif>
		)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#qryversion.newversion#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.type#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.file_name_org#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.orgext#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_version.theurl#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thumbnailname_existing#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfilelocal.hashtag#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
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
		</cfif>
		)
		</cfquery>
		<!--- Update the root DB --->
		<!--- Images --->
		<cfif arguments.thestruct.type EQ "img">
			<cfquery datasource="#arguments.thestruct.dsn#">
			UPDATE #session.hostdbprefix#images
			SET 
			img_filename_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			img_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			img_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			thumb_extension = <cfqueryparam value="#arguments.thestruct.qrysettings.set2_img_format#" cfsqltype="cf_sql_varchar">,
			thumb_width = <cfqueryparam value="#arguments.thestruct.qrysettings.set2_img_thumb_width#" cfsqltype="cf_sql_numeric">, 
			thumb_height = <cfqueryparam value="#arguments.thestruct.qrysettings.set2_img_thumb_heigth#" cfsqltype="cf_sql_numeric">, 
			img_width = <cfqueryparam value="#thewidth#" cfsqltype="cf_sql_numeric">, 
			img_height = <cfqueryparam value="#theheight#" cfsqltype="cf_sql_numeric">,
			img_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cfthread["#ts#"].output)#">,
			thumb_size = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(cfthread["#ths#"].output)#">,
			path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfilelocal.path_to_asset#" cfsqltype="cf_sql_varchar">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#md5hash#">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("images")>
		<!--- Videos --->
		<cfelseif arguments.thestruct.type EQ "vid">
			<cfquery datasource="#arguments.thestruct.dsn#">
			UPDATE #session.hostdbprefix#videos
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
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("videos")>
		<!--- Audios --->
		<cfelseif arguments.thestruct.type EQ "aud">
			<cfquery datasource="#arguments.thestruct.dsn#">
			UPDATE #session.hostdbprefix#audios
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
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("audios")>
		<!--- Documents --->
		<cfelse>
			<cfquery datasource="#arguments.thestruct.dsn#">
			UPDATE #session.hostdbprefix#files
			SET 
			file_name_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			file_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
			file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			file_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfilelocal.path_to_asset#" cfsqltype="cf_sql_varchar">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">,
			hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#md5hash#">,
			is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				,
				lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("files")>
		</cfif>
		<cfset arguments.thestruct.qrydetail.path_to_asset = arguments.thestruct.qryfilelocal.path_to_asset>
		<cfset arguments.thestruct.qrydetail.filenameorg = arguments.thestruct.qryfilelocal.file_name_org>
		<cfset arguments.thestruct.filenameorg = arguments.thestruct.qryfilelocal.file_name_org>
		<!--- <cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error in creating a new version">
				<cfdump var="#cfcatch#" />
			</cfmail>
		</cfcatch>
	</cftry> --->
	<!--- Return --->
	<cfreturn />
</cffunction>

</cfcomponent>
