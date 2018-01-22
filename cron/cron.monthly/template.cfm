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
