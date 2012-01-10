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

<!--- FUNCTION: INIT --->
<cffunction name="init" returntype="extQueryCaching" access="public" output="false">
	<cfargument name="dsn" type="string" required="yes" />
	<cfargument name="database" type="string" required="yes" />
	<cfargument name="setid" type="numeric" required="no" default="#application.razuna.setid#" />
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.database = arguments.database />
	<cfset variables.setid = arguments.setid />
	<!--- init caching scope, this is a reference to a globally shared server-struct! --->
	<!--- <cfset Variables.sCache = intgetCache(dsn=Arguments.dsn, prefix=Arguments.prefix)> --->
	<!--- This MUST be updated after each modification to the DB !!!!!!!!! --->
	<!--- <cfset Variables.sCache.lastmod = GetTickCount() /> --->
	<cfreturn this />
</cffunction>

<cffunction name="intgetCache" output="false" access="private" returntype="struct">
	<cfargument name="dsn" type="string" required="yes" />
	<!--- init caching scope --->
	<!--- This is shared across applications if they use the same DB --->
	<cfif not IsDefined("Server.razunaServer.razuna.DB.#Arguments.dsn#.#Arguments.prefix##ListLast(GetMetaData(this).name, ".")#")>
		<cfset Server.razunaServer.razuna.DB[Arguments.dsn][Arguments.prefix & ListLast(GetMetaData(this).name, ".")] = StructNew()>
	</cfif>
	<cfreturn Server.razunaServer.razuna.DB[Arguments.dsn][Arguments.prefix & ListLast(GetMetaData(this).name, ".")] />
</cffunction>

<!--- reset the global caching variable of this cfc-object --->
<cffunction name="resetCaching" output="false" access="private" returntype="void">
	<!--- 1 second in the future --->
	<cfset Variables.sCache.lastmod = GetTickCount() + 1000>
</cffunction>

<!--- get the cachedWithin value --->
<cffunction name="cachedWithin" output="false" access="private" returntype="date">
	<cfreturn CreateODBCDateTime(Int((GetTickCount() - Variables.sCache.lastmod) /1000) /60 / 60 / 24)>
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
	<cfquery datasource="#variables.dsn#">
	INSERT INTO #session.hostdbprefix#log_search
	(LOG_ID,LOG_USER,LOG_DATE,LOG_TIME,LOG_SEARCH_FOR,LOG_FOUNDITEMS,LOG_SEARCH_FROM,LOG_TIMESTAMP, host_id<!--- ,LOG_BROWSER,LOG_IP --->)
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
	<!--- 
	,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
	--->
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_log" />
</cffunction>

<!--- Log Assets --->
<cffunction name="log_assets" output="false" access="public">
	<cfargument name="theuserid" type="string" required="yes" />
	<cfargument name="logaction" type="string" required="yes" />
	<cfargument name="logdesc" type="string" required="yes" />
	<cfargument name="logfiletype" type="string" required="yes" />
	<cfargument name="assetid" type="string" required="false" />
	<cftry>
		<cfthread intstruct="#arguments#">
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#log_assets
			(log_id,log_user,log_action,log_date,log_time,log_desc,log_file_type,log_timestamp, host_id, asset_id_r<!--- ,log_browser,log_ip --->)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#createuuid()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#attributes.intstruct.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.logaction#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.logdesc#">,	
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.logfiletype#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.assetid#">
			<!---
			,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
			--->
			)
			</cfquery>
			<!--- Flush Cache --->
			<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#attributes.intstruct.theuserid#_log" />
		</cfthread>
		<cfcatch type="any">
			<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="debug" dump="#cfcatch#">
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
	(LOG_ID,LOG_USER,LOG_ACTION,LOG_DATE,LOG_TIME,LOG_DESC,LOG_TIMESTAMP, host_id<!--- ,LOG_BROWSER,LOG_IP --->)
	VALUES(
	<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newlogid#">,
	<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theuserid#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logaction#">,
	<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logdesc#">,
	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
	<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<!---
	,	
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
	--->
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_log" />
</cffunction>

<!--- LOG USERS --->
<cffunction name="log_users" output="false" access="public">
	<cfargument name="theuserid" type="string" required="yes" />
	<cfargument name="logaction" type="string" required="yes" />
	<cfargument name="logdesc" type="string" required="yes" />
	<cfargument name="logsection" type="string" required="yes" />
	<!--- get next id --->
	<cfset var newlogid = createuuid()>
	<cfquery datasource="#variables.dsn#">
	INSERT INTO #session.hostdbprefix#log_users
	(LOG_ID,LOG_USER,LOG_ACTION,LOG_DATE,LOG_TIME,LOG_DESC,LOG_TIMESTAMP,LOG_SECTION, host_id <!--- ,LOG_BROWSER,LOG_IP --->)
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
	<!---
	,	
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">, 
	--->
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_log" />
</cffunction>

</cfcomponent>