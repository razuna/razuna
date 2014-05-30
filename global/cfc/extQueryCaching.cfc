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
<cfcomponent hint="Serves as parent only!" output="false">
	
<!--- Errors Object --->
<cfobject component="global.cfc.errors" name="errobj">

<!--- FUNCTION: INIT --->
<cffunction name="init" returntype="extQueryCaching" access="public" output="false">
	<cfset variables.dsn = application.razuna.datasource />
	<cfset variables.database = application.razuna.thedatabase />
	<cfset variables.setid = application.razuna.setid />
	<cfreturn this />
</cffunction>

<cffunction name="getcachetoken" output="false" returntype="string">
	<cfargument name="type" type="string" required="yes">
	<!--- Param --->
	<cfset var qry = queryNew("cache_token")>
	<!--- Query --->
	<cftry>
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT cache_token
		FROM cache
		WHERE host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
		AND cache_type = <cfqueryparam value="#arguments.type#" CFSQLType="CF_SQL_VARCHAR">
		</cfquery>
		<cfcatch type="any">
			<cfset queryAddRow(qry, 1)>
			<cfset querySetCell(qry, "cache_token", createuuid(''))>
		</cfcatch>
	</cftry>
	<cfreturn qry.cache_token />
</cffunction>

<!--- reset the global caching variable of this cfc-object --->
<cffunction name="resetcachetoken" output="false" returntype="string">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="nohost" type="string" required="false" default="false">
	<!--- Create token --->
	<cfset var t = createuuid('')>
	<!--- Update DB --->
	<cftry>
		<cfquery dataSource="#application.razuna.datasource#">
		UPDATE cache
		SET cache_token = <cfqueryparam value="#t#" CFSQLType="CF_SQL_VARCHAR">
		WHERE cache_type = <cfqueryparam value="#arguments.type#" CFSQLType="CF_SQL_VARCHAR">
		<cfif !arguments.nohost>
			AND host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
		</cfif>
		</cfquery>
		<cfcatch type="database"></cfcatch>
	</cftry>
	<cfreturn t>
</cffunction>

<!--- reset all --->
<cffunction name="resetcachetokenall" output="false" returntype="void">
	<!--- Create token --->
	<cfset var t = createuuid('')>
	<!--- Update DB --->
	<cftry>
		<cfquery dataSource="#application.razuna.datasource#">
		UPDATE cache
		SET cache_token = <cfqueryparam value="#t#" CFSQLType="CF_SQL_VARCHAR">
		WHERE host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
		</cfquery>
		<cfcatch type="database"></cfcatch>
	</cftry>
</cffunction>

<!--- Log Search --->
<cffunction name="log_search" output="false" access="public">
	<cfargument name="theuserid" type="string" required="yes" />
	<cfargument name="searchfor" type="string" required="yes" />
	<cfargument name="foundtotal" type="Numeric" required="yes" />
	<cfargument name="searchfrom" type="string" required="yes" />
	<!--- get next id --->
	<cfset var newlogid = createuuid()>
	<!--- Insert --->
	<cfquery datasource="#application.razuna.datasource#">
	INSERT INTO #session.hostdbprefix#log_search
	(LOG_ID,LOG_USER,LOG_DATE,LOG_TIME,LOG_SEARCH_FOR,LOG_FOUNDITEMS,LOG_SEARCH_FROM,LOG_TIMESTAMP, host_id)
	VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newlogid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchfor#">,	
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.foundtotal#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchfrom#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfinvoke method="resetcachetoken" type="logs" />
</cffunction>

<!--- Log Assets --->
<cffunction name="log_assets" output="false" access="public">
	<cfargument name="theuserid" type="string" required="yes" />
	<cfargument name="logaction" type="string" required="yes" />
	<cfargument name="logdesc" type="string" required="yes" />
	<cfargument name="logfiletype" type="string" required="yes" />
	<cfargument name="assetid" type="string" required="false" />
	<cfargument name="folderid" type="string" required="false" />
	<cftry>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#log_assets
		(log_id,log_user,log_action,log_date,log_time,log_desc,log_file_type,log_timestamp, host_id, asset_id_r, folder_id)
		VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#createuuid()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logaction#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logdesc#">,	
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logfiletype#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folderid#">
		)
		</cfquery>
		<!--- Flush Cache --->
		<cfinvoke method="resetcachetoken" type="logs" />
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function extQueryCaching.log_assets">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
</cffunction>

<!--- Log Folders --->
<cffunction name="log_folders" output="false" access="public">
	<cfargument name="theuserid" type="string" required="yes" />
	<cfargument name="logaction" type="string" required="yes" />
	<cfargument name="logdesc" type="string" required="yes" />
	<!--- get next id --->
	<cfset var newlogid = createuuid()>
	<cfquery datasource="#application.razuna.datasource#">
	INSERT INTO #session.hostdbprefix#log_folders
	(LOG_ID,LOG_USER,LOG_ACTION,LOG_DATE,LOG_TIME,LOG_DESC,LOG_TIMESTAMP, host_id)
	VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newlogid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logaction#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logdesc#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfinvoke method="resetcachetoken" type="logs" />
</cffunction>

<!--- LOG USERS --->
<cffunction name="log_users" output="false" access="public">
	<cfargument name="theuserid" type="string" required="yes" />
	<cfargument name="logaction" type="string" required="yes" />
	<cfargument name="logdesc" type="string" required="yes" />
	<cfargument name="logsection" type="string" required="yes" />
	<!--- get next id --->
	<cfset var newlogid = createuuid()>
	<cfquery datasource="#application.razuna.datasource#">
	INSERT INTO #session.hostdbprefix#log_users
	(LOG_ID,LOG_USER,LOG_ACTION,LOG_DATE,LOG_TIME,LOG_DESC,LOG_TIMESTAMP,LOG_SECTION, host_id)
	VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newlogid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theuserid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logaction#">,
		<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logdesc#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logsection#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfinvoke method="resetcachetoken" type="logs" />
</cffunction>

</cfcomponent>