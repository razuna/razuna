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
<cfcomponent output="false">
	
	<!--- Set application values --->
	<cfset application.razuna.storage = application.razuna.api.storage>
	<cfset application.razuna.datasource = application.razuna.api.dsn>
	<cfset application.razuna.thedatabase = application.razuna.api.thedatabase>
	<cfset application.razuna.setid = application.razuna.api.setid>

	<!--- Check for db entry --->
	<cffunction name="checkdb" access="public" output="no">
		<cfargument name="api_key" type="string">
		<cfparam name="thehostid" default="" />
		<!--- Check to see if api key has a hostid --->
		<cfif arguments.api_key contains "-">
			<cfset var thehostid = listfirst(arguments.api_key,"-")>
			<cfset var theapikey = listlast(arguments.api_key,"-")>
		<cfelse>
			<cfset var theapikey = arguments.api_key>
		</cfif>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #theapikey##thehostid#checkdb */ u.user_id, gu.ct_g_u_grp_id grpid, ct.ct_u_h_host_id hostid
		FROM users u, ct_users_hosts ct, ct_groups_users gu
		WHERE user_api_key = <cfqueryparam value="#theapikey#" cfsqltype="cf_sql_varchar"> 
		AND u.user_id = ct.ct_u_h_user_id
		<cfif thehostid NEQ "">
			AND ct.ct_u_h_host_id = <cfqueryparam value="#thehostid#" cfsqltype="cf_sql_numeric">
		</cfif>
		AND gu.ct_g_u_user_id = u.user_id
		AND (
			gu.ct_g_u_grp_id = <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">
			OR
			gu.ct_g_u_grp_id = <cfqueryparam value="2" cfsqltype="CF_SQL_VARCHAR">
		)
		GROUP BY user_id, ct_g_u_grp_id, ct_u_h_host_id
		</cfquery>
		<!--- If timeout is within the last 30 minutes then extend it again --->
		<cfif qry.recordcount EQ 0>
			<!--- Set --->
			<cfset var status = false>
		<cfelse>
			<!--- Set --->
			<cfset var status = true>
			<!--- Get Host prefix --->
			<cfquery datasource="#application.razuna.api.dsn#" name="pre" cachedwithin="1" region="razcache">
			SELECT /* #theapikey##thehostid#checkdb2 */ host_shard_group
			FROM hosts
			WHERE host_id = <cfqueryparam value="#qry.hostid#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<!--- Set Host information --->
			<cfset application.razuna.api.prefix[#arguments.api_key#] = pre.host_shard_group>
			<cfset application.razuna.api.hostid[#arguments.api_key#] = qry.hostid>
			<cfset application.razuna.api.userid[#arguments.api_key#] = qry.user_id>
			<cfset session.hostdbprefix = pre.host_shard_group>
			<cfset session.hostid = qry.hostid>
			<cfset session.theuserid = qry.user_id>
		</cfif>
		<!--- Return --->
		<cfreturn status>
	</cffunction>
	
	<!--- Create timeout error --->
	<cffunction name="timeout" access="public" output="false">
		<cfargument name="type" required="false" default="q" type="string" />
		<!--- By default we say this returns a query --->
		<cfif arguments.type EQ "q">
			<cfset var thexml = querynew("responsecode,message")>
			<cfset queryaddrow(thexml,1)>
			<cfset querysetcell(thexml,"responsecode","1")>
			<cfset querysetcell(thexml,"message","Login not valid! Check API Key and that the user is Administrator")>
		<cfelse>
			<cfset thexml.responsecode = 1>
			<cfset thexml.message = "Login not valid! Check API Key and that user is Administrator">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- Get Cachetoken --->
	<cffunction name="getcachetoken" output="false" returntype="string">
		<cfargument name="api_key" type="string">
		<cfargument name="type" type="string" required="yes">
		<!--- Set session --->
		<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
		<!--- Call reset function --->
		<cfinvoke component="global.cfc.extQueryCaching" method="getcachetoken" type="#arguments.type#" returnvariable="c" />
		<!--- Return --->
		<cfreturn c />
	</cffunction>

	<!--- reset the global caching variable of this cfc-object --->
	<cffunction name="resetcachetoken" output="false" returntype="void">
		<cfargument name="api_key" type="string">
		<cfargument name="type" type="string" required="yes">
		<!--- Set session --->
		<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
		<!--- Call reset function --->
		<!--- <cfinvoke component="global.cfc.extQueryCaching" method="resetcachetoken" type="#arguments.type#" /> --->
		<cfinvoke component="global.cfc.extQueryCaching" method="resetcachetokenall" />
		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>