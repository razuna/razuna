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

	<cfset consoleoutput(true, true)>
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
