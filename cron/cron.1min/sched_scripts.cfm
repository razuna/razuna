<!--- <cfabort> --->
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

<!---

TODO:

- Get selected renditions

 --->


<cftry>

	<cfset _script_time = "1min">

	<cfset console("#now()# --- Executing script cron job #_script_time#")>

	<!--- Path --->
	<cfset _path = expandPath("../..")>

	<!--- Get database --->
	<cfquery datasource="razuna_default" name="_config">
	SELECT conf_database, conf_datasource, conf_storage, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_aws_tenant_in_one_bucket_name, conf_aws_tenant_in_one_bucket_enable
	FROM razuna_config
	</cfquery>

	<!--- Set DB --->
	<cfset _struct = structNew()>
	<cfset _struct.from_cron = true>
	<cfset _struct.fa = "">
	<cfset _struct.razuna.application.datasource = _config.conf_datasource>
	<cfset _struct.razuna.application.storage = _config.conf_storage>
	<cfset _struct.razuna.application.thedatabase = _config.conf_database>

	<!--- Prefix into session --->
	<cfset _struct.razuna.session.hostdbprefix = "raz1_">
	<cfset _struct.razuna.session.thelangid = 1>

	<!--- Check in script table for scripts that need to execute within this time --->
	<cfinvoke component="global.cfc.scheduler" method="getScriptTime" script_interval="#_script_time#" thestruct="#_struct#" returnvariable="qry_scripts" />

	<!--- Create lock file for this script --->
	<cfinvoke component="global.cfc.global" method="_lockFile" qry="#qry_scripts#" type="script_#_script_time#" returnvariable="_hosts" />

	<!--- SFTP --->
	<cfinvoke component="global.cfc.sftp" method="init" returnvariable="sftp">

	<!--- START --->

	<!--- Loop over hosts --->
	<cfloop query="qry_scripts">

		<!--- Prefix into session --->
		<cfset _struct.razuna.session.hostid = host_id>

		<!--- Grab all values of script --->
		<cfinvoke component="global.cfc.scheduler" method="getScript" id="#sched_id#" thestruct="#_struct#" returnvariable="qry_script" />
		<!--- <cfset console("SCRIPT : ", qry_script)> --->

		<!--- If this is a new record just continue --->
		<cfif qry_script.new_record>
			<cfcontinue>
		</cfif>

		<!--- If this record is not active just continue --->
		<cfif ! qry_script.sched_script_active>
			<cfcontinue>
		</cfif>

		<!--- CONTINUE --->

		<!--- Grab all matching files --->
		<cfset _struct.filename = qry_script.SCHED_SCRIPT_FILES_FILENAME>
		<cfset _struct.folderid = Serializejson([ qry_script.SCHED_SCRIPT_FILES_FOLDER ])>
		<cfset _struct.labels = Serializejson([ qry_script.SCHED_SCRIPT_FILES_LABEL ])>
		<cfinvoke component="global.cfc.scheduler" method="scriptFileSearch" thestruct="#_struct#" files_since="#qry_script.SCHED_SCRIPT_FILES_TIME#" files_since_unit="#qry_script.SCHED_SCRIPT_FILES_TIME_UNIT#" returnvariable="qry_files" />

		<!--- If no files found continue --->
		<cfif ! qry_files.recordcount>
			<cfset console("#now()# --- Executing script cron job #_script_time# : NO FILES FOUND within #qry_script.SCHED_SCRIPT_FILES_TIME# #qry_script.SCHED_SCRIPT_FILES_TIME_UNIT# and filename #qry_script.SCHED_SCRIPT_FILES_FILENAME# in folder #qry_script.SCHED_SCRIPT_FILES_FOLDER# and label #qry_script.SCHED_SCRIPT_FILES_LABEL#")>
			<cfcontinue>
		</cfif>

		<!--- Unique id for this script --->
		<cfset _uuid = createuuid('')>
		<cfset _file_file_name = "">
		<cfset _zip_file = "">
		<!--- Path to temp directory --->
		<cfset _path_temp = GetTempdirectory() & "/" & _uuid>
		<cfset _zip_file_name = "Omnipix.zip">
		<cfset _zip_file = GetTempdirectory() & _zip_file_name>

		<!--- Check what files we need to grab (Originals and renditions) Guess we could pass this in the search above --->

		<!--- Collect files here --->
		<cfinvoke component="global.cfc.scheduler" method="getScriptCollectFiles" files="#qry_files#" path_temp="#_path_temp#" thestruct="#_struct#" returnvariable="list_files" />
		<!--- <cfset list_files = _collectFiles( files=qry_files, path_temp=_path_temp, thestruct=_struct )> --->

		<!--- Check if we have to transform any files --->
		<cfinvoke component="global.cfc.scheduler" method="getScriptTranscodeFiles" files="#qry_files#" script="#qry_script#" path_temp="#_path_temp#" thestruct="#_struct#" returnvariable="_transcodeFiles" />
		<!--- <cfset _transcodeFiles( files=qry_files, script=qry_script, path_temp=_path_temp, thestruct=_struct )> --->

		<!--- Check if we have to create a metadata file --->
		<cfinvoke component="global.cfc.scheduler" method="getScriptMetaFile" files="#qry_files#" script="#qry_script#" path_temp="#_path_temp#" thestruct="#_struct#" returnvariable="_metaFile" />
		<!--- <cfset _metaFile( files=qry_files, script=qry_script, path_temp=_path_temp, thestruct=_struct )> --->

		<!--- Create a ZIP file --->
		<cfthread name="zip_#_uuid#" file="#_zip_file#" source="#_path_temp#">
			<cfzip action="create" zipfile="#attributes.file#" source="#attributes.source#" overwrite="true" />
		</cfthread>
		<!--- Only release when thread is done --->
		<cfthread action="join" name="zip_#_uuid#" />

		<!--- Finally connect to FTP site and transfer all files --->
		<cfset _connection = sftp.connect( host=qry_script.SCHED_SCRIPT_FTP_HOST, port=qry_script.SCHED_SCRIPT_FTP_PORT, user=qry_script.SCHED_SCRIPT_FTP_USER, pass=qry_script.SCHED_SCRIPT_FTP_PASS )>
		<cfset put = sftp.put(file_local=_zip_file, file_remote="/#_zip_file_name#")>
		<cfset sftp.disconnect()>

		<!--- Check if file could be transfered --->
		<cfset console("sFTP PUT STATUS : ", put)>

		<!--- Delete temp dir and zip file --->
		<cfset DirectoryDelete( _path_temp, true )>
		<cfset fileDelete( _zip_file )>

	</cfloop>

	<!--- END --->

	<!--- Remove lock files --->
	<cfinvoke component="global.cfc.global" method="_removeLockFile" qry_remove_lock="#qry_scripts#" type="script_#_script_time#"/>

	<cfset console("#now()# --- Finished script cron job #_script_time#")>

	<cfcatch type="any">
		<cfset console("#now()# ---------------------- Error script cron job #_script_time#")>
		<cfset console(cfcatch)>
	</cfcatch>
</cftry>

