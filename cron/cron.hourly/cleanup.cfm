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
<cfabort>
<cftry>

	<cfset consoleoutput(true)>
	<cfset console("#now()# --- Executing cron job expiring assets")>

	<!--- Path --->
	<cfset _path = expandPath("../..")>

	<!--- Get database --->
	<cfquery datasource="razuna_default" name="_config">
	SELECT conf_datasource, conf_database, conf_datasource, conf_storage, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_aws_tenant_in_one_bucket_name, conf_aws_tenant_in_one_bucket_enable
	FROM razuna_config
	</cfquery>

	<!--- Set DB --->
	<cfset _db = _config.conf_datasource>
	<cfset _storage = _config.conf_storage>

	<!--- Get all the hosts --->
	<cfquery datasource="#_db#" name="_qry_hosts">
	SELECT host_shard_group, host_id
	FROM hosts
	GROUP BY host_id, host_shard_group
	</cfquery>

	<cfinvoke component="global.cfc.global" method="_lockFile" qry="#_qry_hosts#" type="trash" returnvariable="_hosts" />

	<!--- START --->



	<!--- END --->

	<cfinvoke component="global.cfc.global" method="_removeLockFile" qry_remove_lock="#_qry_hosts#" type="trash"/>

	<cfset console("#now()# --- Finished cron job expiring assets")>

	<cfcatch type="any">
		<cfset console("#now()# ---------------------- Error expiring assets crong job")>
		<cfset console(cfcatch)>
	</cfcatch>
</cftry>

<cftry>

	<cfset consoleoutput(true)>
	<cfset console("#now()# ---------------- Starting to clean up incoming, outgoing, and tmp directories")>

	<!--- Path --->
	<cfset _path = expandPath("../..")>
	<!--- Set time for remove --->
	<cfset _removetime_incoming = DateAdd("h", -2, now())>
	<cfset _removetime_outgoing = DateAdd("d", -4, now())>
	<cfset _removetime_tmp = DateAdd("h", -2, now())>

	<!--- Get database --->
	<cfquery datasource="razuna_default" name="_config">
	SELECT conf_datasource
	FROM razuna_config
	</cfquery>
	<!--- Set DB --->
	<cfset _db = _config.conf_datasource>

	<!--- Get all the hosts --->
	<cfquery datasource="#_db#" name="_qry_hosts">
	SELECT host_shard_group
	FROM hosts
	GROUP BY host_shard_group
	</cfquery>

	<cfloop query="_qry_hosts">
		<!--- Clear assets dbs from records which have no path_to_asset --->
		<cftransaction>
			<cfquery datasource="#_db#">
			DELETE FROM #host_shard_group#images
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND img_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime_incoming#">
			ORDER BY img_id
			</cfquery>
		</cftransaction>
		<cftransaction>
			<cfquery datasource="#_db#">
			DELETE FROM #host_shard_group#videos
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND vid_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime_incoming#">
			ORDER BY vid_id
			</cfquery>
		</cftransaction>
		<cftransaction>
			<cfquery datasource="#_db#">
			DELETE FROM #host_shard_group#files
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND file_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime_incoming#">
			ORDER BY file_id
			</cfquery>
		</cftransaction>
		<cftransaction>
			<cfquery datasource="#_db#">
			DELETE FROM #host_shard_group#audios
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND aud_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime_incoming#">
			ORDER BY aud_id
			</cfquery>
		</cftransaction>
		<cftransaction>
			<!--- Select temp assets which are older then 6 hours --->
			<cfquery datasource="#_db#" name="qry">
			SELECT path as temppath, tempid
			FROM #host_shard_group#assets_temp
			WHERE date_add < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime_incoming#">
			AND path LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%dam/incoming%">
			AND path IS NOT NULL
			</cfquery>
		</cftransaction>
		<cfset _host_shard_group = host_shard_group>
		<!--- Loop trough the found records --->
		<cfloop query="qry">
			<!--- Delete in the DB --->
			<cftransaction>
				<cfquery datasource="#_db#">
				DELETE FROM #_host_shard_group#assets_temp
				WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tempid#">
				</cfquery>
			</cftransaction>
			<!--- Delete on the file system --->
			<cfif directoryexists(temppath)>
				<cftry>
					<cfdirectory action="delete" recurse="true" directory="#temppath#">
					<cfcatch></cfcatch>
				</cftry>
			</cfif>
		</cfloop>
	</cfloop>


	<!--- Loop over hosts and dirs --->
	<cfloop query="_qry_hosts">
		<!--- Remove the "_" from the host --->
		<cfset _host = replacenocase(host_shard_group, "_", "", "ALL")>
		<cfset _full_path_incoming = "#_path##_host#/dam/incoming">
		<cfset _full_path_outgoing = "#_path##_host#/dam/outgoing">
		<!--- Get incoming --->
		<cfdirectory action="list" directory="#_full_path_incoming#" name="_qry_incoming">
		<!--- Get outgoing --->
		<cfdirectory action="list" directory="#_full_path_outgoing#" name="_qry_outgoing">
		<!--- Remove incoming dirs --->
		<cfloop query="_qry_incoming">
			<cfif directoryexists("#_full_path_incoming#/#name#")>
				<cfif type EQ "dir" AND datelastmodified LT _removetime_incoming>
					<cfset console("#now()# ---------------- Removing incoming: #_full_path_incoming#/#name#")>
					<cfdirectory action="delete" directory="#_full_path_incoming#/#name#" recurse="true" mode="775">
				</cfif>
				<cfif type EQ "file" AND datelastmodified LT _removetime_incoming>
					<cfset console("#now()# ---------------- Removing incoming: #_full_path_incoming#/#name#")>
					<cffile action="delete" file="#_full_path_incoming#/#name#" />
				</cfif>
			</cfif>
		</cfloop>
		<!--- Remove outgoing dirs and files --->
		<cfloop query="_qry_outgoing">
			<cfif directoryexists("#_full_path_outgoing#/#name#")>
				<cfif type EQ "dir" AND datelastmodified LT _removetime_outgoing>
					<cfset console("#now()# ---------------- Removing outgoing: #_full_path_outgoing#/#name#")>
					<cfdirectory action="delete" directory="#_full_path_outgoing#/#name#" recurse="true" mode="775">
				</cfif>
				<cfif type EQ "file" AND datelastmodified LT _removetime_outgoing>
					<cfset console("#now()# ---------------- Removing outgoing: #_full_path_outgoing#/#name#")>
					<cffile action="delete" file="#_full_path_outgoing#/#name#" />
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>

	<!--- Remove tmp files --->
	<cfset console("#now()# ---------------- Cleaning tmp dir!")>
	<cfdirectory action="list" directory="#GetTempDirectory()#" name="tmpList" type="file" />
	<cftry>
		<cfset console("------------REMOVING ANY LOCK OR OTHER TEMP FILES------------------")>
		<cfdirectory action="list" directory="#GetTempDirectory()#" name="tmpList" type="file" />
		<cfloop query="tmpList">
			<cfif (name CONTAINS ".sh" OR name CONTAINS ".tmp" OR name CONTAINS ".temp" OR name CONTAINS ".csv" OR name CONTAINS ".xls" OR name CONTAINS ".xlsx" OR name CONTAINS ".lock") AND datelastmodified LT _removetime_tmp>
				<cftry>
					<cfset console("#now()# ---------------- Removing file in temp dir: #GetTempDirectory()#/#name#")>
					<cffile action="delete" file="#GetTempDirectory()#/#name#" />
					<cfcatch type="any">
						<cfset console("------------ ERROR REMOVING TEMP FILE : #GetTempDirectory()#/#name# !!!!!!!!!!!!!!!!!!!!!!!!!")>
						<cfset console(cfcatch)>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfset consoleoutput(true)>
			<cfset console("------------ ERROR REMOVING TEMP FILES !!!!!!!!!!!!!!!!!!!!!!!!!")>
			<cfset console(cfcatch)>
		</cfcatch>
	</cftry>

	<cfset console("#now()# ---------------- Finished clean up job!")>

	<cfcatch type="any">
		<cfset console("#now()# ---------------- Error on clean up cron job")>
		<cfset console(cfcatch)>
	</cfcatch>
</cftry>
