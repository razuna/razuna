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
<cfcomponent output="false" extends="extQueryCaching">

	<!--- Rendering Farm: Get all --->
	<cffunction name="rfs_get_all" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Query --->
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT rfs_id, rfs_server_name, rfs_active
		FROM rfs
		ORDER BY rfs_date_change
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
	
	<!--- Rendering Farm: get detail --->
	<cffunction name="rfs_get_detail" output="true">
		<cfargument name="rfs_id" type="string" required="true">
		<!--- Query --->
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT rfs_id, rfs_active, rfs_server_name, rfs_imagemagick, rfs_ffmpeg, rfs_dcraw, rfs_exiftool, rfs_mp4box, rfs_date_add, rfs_date_change, 
		rfs_location
		FROM rfs
		WHERE rfs_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.rfs_id#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
	
	<!--- Rendering Farm: remove --->
	<cffunction name="rfs_remove" output="true">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Query --->
		<cfquery dataSource="#application.razuna.datasource#">
		DELETE FROM rfs
		WHERE rfs_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		</cfquery>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Rendering Farm: update --->
	<cffunction name="rfs_update" output="true">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- If we add a record then do an insert --->
		<cfif arguments.thestruct.rfs_add>
			<!--- Insert --->
			<cfquery dataSource="#application.razuna.datasource#" name="qry">
			INSERT INTO rfs
			(
			rfs_id,
			rfs_active,
			rfs_server_name,
			rfs_imagemagick,
			rfs_ffmpeg,
			rfs_dcraw,
			rfs_exiftool,
			rfs_mp4box,
			rfs_location,
			rfs_date_add,
			rfs_date_change
			)
			VALUES
			(
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_id#">,
			<cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="#arguments.thestruct.rfs_active#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_server_name#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_imagemagick#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ffmpeg#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_dcraw#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_exiftool#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_mp4box#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_location#">,
			<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
			<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
			)
			</cfquery>
		<cfelse>
			<!--- Update --->
			<cfquery dataSource="#application.razuna.datasource#" name="qry">
			UPDATE rfs
			SET
			rfs_active = <cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="#arguments.thestruct.rfs_active#">,
			rfs_server_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_server_name#">,
			rfs_imagemagick = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_imagemagick#">,
			rfs_ffmpeg = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ffmpeg#">,
			rfs_dcraw = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_dcraw#">,
			rfs_exiftool = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_exiftool#">,
			rfs_mp4box = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_mp4box#">,
			rfs_location = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_location#">,
			rfs_date_change = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
			WHERE rfs_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_id#">
			</cfquery>
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Notify remote server --->
	<cffunction name="notify" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Thread --->
		<cfthread action="run" intstruct="#arguments.thestruct#">
			<cfinvoke method="notify_thread" thestruct="#attributes.intstruct#" />
		</cfthread>
	</cffunction>

	<!--- Notify remote server thread --->
	<cffunction name="notify_thread" returntype="void">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfparam name="arguments.thestruct.upl_template" default="0" />
		<!--- Get remote server records --->
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT rfs_id, rfs_server_name, rfs_location
		FROM rfs
		WHERE rfs_active = <cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="true">
		</cfquery>
		<!--- Get settings --->
		<cfinvoke component="settings" method="thissetting" thefield="rendering_farm_server" returnVariable="thehost" />
		
		<!--- Check here is the server is busy or not. If so, check for an alternate server in the pool --->
		
		<!--- Check according to location --->
		
		<!--- If this is from convert we write data into json --->
		<cfif structkeyexists(arguments.thestruct,"convert")>
			<!--- Variable --->
			<cfset var jdata = structnew()>
			<!--- Loop over structs --->
			<cfloop collection="#arguments.thestruct#" item="item">
				<!--- Only grab the needed fields --->
				<cfif item CONTAINS "file_id" OR item CONTAINS "convert">
					<!--- Add to struct --->
					<cfset structinsert(jdata, item, arguments.thestruct["#item#"])>
				</cfif>
			</cfloop>
			<!--- Create Json --->
			<cfset var jsondata = serializejson(jdata)>
		</cfif>
		<!--- Notify remote servers about a new file waiting for download --->
		<!--- Send the server ID with the request. The remote server checks the ID to this record --->
		<cfhttp url="#qry.rfs_server_name#" timeout="30">
			<cfhttpparam name="rfsid" value="#qry.rfs_id#" type="URL">
			<cfhttpparam name="hostid" value="#session.hostid#" type="URL">
			<cfhttpparam name="userid" value="#session.theuserid#" type="URL">
			<cfhttpparam name="dynpath" value="#arguments.thestruct.dynpath#" type="URL">
			<cfhttpparam name="httphost" value="#thehost#" type="URL">
			<cfhttpparam name="storage" value="#application.razuna.storage#" type="URL">
			<cfhttpparam name="dsnhost" value="#application.razuna.datasource#" type="URL">
			<cfhttpparam name="assettype" value="#arguments.thestruct.assettype#" type="URL">
			<cfif structkeyexists(arguments.thestruct,"convert")>
				<cfhttpparam name="upl_template" value="#arguments.thestruct.upl_template#" type="URL">
				<cfhttpparam name="convert" value="#arguments.thestruct.convert#" type="URL">
				<cfhttpparam name="jsondata" value="#jsondata#" type="URL">
			<cfelse>
				<cfhttpparam name="assetid" value="#arguments.thestruct.newid#" type="URL">
			</cfif>
		</cfhttp>		
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<cffunction name="SafeSerializeJSON" output="false" access="private" returntype="string">
		<cfargument name="obj" type="any" required="true" />
		<cfargument name="serializeQueryByColumns" type="boolean" required="false" default="false" />
		<cfset var jsonOutput = SerializeJSON(arguments.obj, arguments.serializeQueryByColumns) />
		<cfset jsonOutput = Replace(jsonOutput, chr(8232), "\u2028", "all") />
		<cfset jsonOutput = Replace(jsonOutput, chr(8233), "\u2029", "all") />
		<cfreturn jsonOutput />
	</cffunction>
	
	<!--- Pickup asset from rfs --->
	<cffunction name="pickup" output="true">
		<cfargument name="thestruct" type="struct">
		<cftry>
			<!--- Get remote server records --->
			<cfquery dataSource="#application.razuna.datasource#" name="qry">
			SELECT rfs_server_name, rfs_location
			FROM rfs
			WHERE rfs_active = <cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="true">
			AND rfs_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_id#">
			</cfquery>
			<!--- Go grab the platform --->
			<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
			<!--- IMAGES --->
			<cfif arguments.thestruct.rfs_assettype EQ "img">
				<cfset var forpath = "img">
				<cfset var fordb = "#session.hostdbprefix#images">
				<cfset var fordbid = "img_id">
			<!--- VIDEOS --->
			<cfelseif arguments.thestruct.rfs_assettype EQ "vid">
				<cfset var forpath = "vid">
				<cfset var fordb = "#session.hostdbprefix#videos">
				<cfset var fordbid = "vid_id">
			<!--- AUDIOS --->
			<cfelseif arguments.thestruct.rfs_assettype EQ "aud">
				<cfset var forpath = "aud">
				<cfset var fordb = "#session.hostdbprefix#audios">
				<cfset var fordbid = "aud_id">
			<!--- Docs and all other files --->
			<cfelse>
				<cfset var forpath = "doc">
				<cfset var fordb = "#session.hostdbprefix#files">
				<cfset var fordbid = "file_id">
			</cfif>
			<!--- If we come from convert we have jsondata in the arguments --->
			<cfif structkeyexists(arguments.thestruct,"rfs_jsondata")>
				<!--- Convert Json --->
				<cfset arguments.thestruct.json = deserializejson(arguments.thestruct.rfs_jsondata)>
				<cfset structappend(arguments.thestruct, arguments.thestruct.json)>
				<!--- Put asset path together --->
				<cfset var storein = arguments.thestruct.assetpath & "/" & session.hostid & "/" & arguments.thestruct.rfs_folderid & "/" & forpath & "/" & arguments.thestruct.newid>
				<!--- Create folder --->
				<cfif NOT directoryexists(storein)>
					<cfdirectory action="create" directory="#storein#" mode="775">
				</cfif>
				<!--- Download --->
				<cfif forpath EQ "aud">
					<cfhttp url="#qry.rfs_server_name#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.newid#/#arguments.thestruct.convertname#" file="#arguments.thestruct.convertname#" path="#storein#"></cfhttp>
				<cfelse>
					<cfhttp url="#qry.rfs_server_name#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.newid#/#arguments.thestruct.thumbname#" file="#arguments.thestruct.thumbname#" path="#storein#"></cfhttp>
					<cfhttp url="#qry.rfs_server_name#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.newid#/#arguments.thestruct.convertname#" file="#arguments.thestruct.convertname#" path="#storein#"></cfhttp>
				</cfif>
			<cfelse>
				<!--- Put asset path together --->
				<cfset var storein = arguments.thestruct.assetpath & "/" & session.hostid & "/" & arguments.thestruct.rfs_folderid & "/" & forpath & "/" & arguments.thestruct.rfs_assetid>
				<!--- Create folder --->
				<cfif NOT directoryexists(storein)>
					<cfdirectory action="create" directory="#storein#" mode="775">
				</cfif>
				<!--- Download --->
				<cfhttp url="#qry.rfs_server_name#/incoming/#arguments.thestruct.rfs_path#/#arguments.thestruct.rfs_asset#" file="#arguments.thestruct.rfs_asset#" path="#storein#"></cfhttp>
			</cfif>				
			<!--- If we are DOC/PDF we need to download the PDF images folder (zip) and extract it --->
			<cfif forpath EQ "doc">
				<!--- Get file --->
				<cfhttp url="#qry.rfs_server_name#/incoming/#arguments.thestruct.rfs_path#/razuna_pdf_images.zip" file="razuna_pdf_images.zip" path="#storein#"></cfhttp>
				<!--- Extract ZIP --->
				<cfzip action="extract" zipfile="#storein#/razuna_pdf_images.zip" destination="#storein#/razuna_pdf_images" />
				<!--- Remove the ZIP file --->
				<cffile action="delete" file="#storein#/razuna_pdf_images.zip" />
			</cfif>
			<!--- If we are the preview file then set the available flag --->
			<cfif !structkeyexists(arguments.thestruct,"rfs_jsondata")>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #fordb#
				SET is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
				WHERE #fordbid# = <cfqueryparam value="#arguments.thestruct.rfs_assetid#" cfsqltype="cf_sql_varchar">
				</cfquery>
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function rfs.pickup">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
</cfcomponent>