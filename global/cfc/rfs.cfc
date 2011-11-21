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
		FROM renderingfarm
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
		SELECT rfs_id, rfs_active, rfs_server_name, rfs_watchfolder, rfs_connection, rfs_ftp_server, rfs_ftp_user, rfs_ftp_pass, rfs_ftp_passive,
		rfs_scp_login, rfs_imagemagick, rfs_ffmpeg, rfs_dcraw, rfs_exiftool, rfs_date_add, rfs_date_change
		FROM renderingfarm
		WHERE rfs_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.rfs_id#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>
	
	<!--- Rendering Farm: update --->
	<cffunction name="rfs_update" output="true">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- If we add a record then do an insert --->
		<cfif arguments.thestruct.rfs_add>
			<!--- Insert --->
			<cfquery dataSource="#application.razuna.datasource#" name="qry">
			INSERT INTO renderingfarm
			(
			rfs_id,
			rfs_active,
			rfs_server_name,
			rfs_watchfolder,
			rfs_connection,
			rfs_ftp_server,
			rfs_ftp_user,
			rfs_ftp_pass,
			rfs_ftp_passive,
			rfs_scp_login,
			rfs_imagemagick,
			rfs_ffmpeg,
			rfs_dcraw,
			rfs_exiftool,
			rfs_date_add,
			rfs_date_change
			)
			VALUES
			(
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_id#">,
			<cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="#arguments.thestruct.rfs_active#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_server_name#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_watchfolder#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_connection#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ftp_server#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ftp_user#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ftp_pass#">,
			<cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="#arguments.thestruct.rfs_ftp_passive#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_scp_login#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_imagemagick#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ffmpeg#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_dcraw#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_exiftool#">,
			<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
			<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
			)
			</cfquery>
		<cfelse>
			<!--- Update --->
			<cfquery dataSource="#application.razuna.datasource#" name="qry">
			UPDATE renderingfarm
			SET
			rfs_active = <cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="#arguments.thestruct.rfs_active#">,
			rfs_server_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_server_name#">,
			rfs_watchfolder = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_watchfolder#">,
			rfs_connection = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_connection#">,
			rfs_ftp_server = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ftp_server#">,
			rfs_ftp_user = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ftp_user#">,
			rfs_ftp_pass = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ftp_pass#">,
			rfs_ftp_passive = <cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="#arguments.thestruct.rfs_ftp_passive#">,
			rfs_scp_login = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_scp_login#">,
			rfs_imagemagick = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_imagemagick#">,
			rfs_ffmpeg = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_ffmpeg#">,
			rfs_dcraw = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_dcraw#">,
			rfs_exiftool = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_exiftool#">,
			rfs_date_change = <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
			WHERE rfs_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.rfs_id#">
			</cfquery>
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Notify remote server --->
	<cffunction name="notify" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Get remote server records --->
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT rfs_id, rfs_server_name, rfs_watchfolder
		FROM renderingfarm
		WHERE rfs_active = <cfqueryparam CFSQLType="CF_SQL_DOUBLE" value="true">
		</cfquery>
		<!--- Check here is the server is busy or not. If so, check for an alternate server in the pool --->
		
		<!--- Notify remote servers about a new file waiting for download --->
		<!--- Send the server ID with the request. The remote server checks the ID to this record --->
		<cfhttp url="#qry.rfs_server_name#" timeout="20">
			<cfhttpparam name="rfsid" value="#qry.rfs_id#" type="URL">
			<cfhttpparam name="hostid" value="#session.hostid#" type="URL">
			<cfhttpparam name="dynpath" value="#arguments.thestruct.dynpath#" type="URL">
			<cfhttpparam name="tempid" value="#arguments.thestruct.tempid#" type="URL">
			<cfhttpparam name="assetid" value="#arguments.thestruct.newid#" type="URL">
			<cfhttpparam name="httphost" value="#arguments.thestruct.httphost#" type="URL">
			<cfhttpparam name="storage" value="#application.razuna.storage#" type="URL">
		</cfhttp>
		
		
		
	
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	
	
</cfcomponent>