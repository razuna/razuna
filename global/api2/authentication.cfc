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
	<cfset application.razuna.api.thehttp = "http://">
	<cfparam name="application.razuna.api.lucene" default="global.cfc.lucene">

	<!--- Check for db entry --->
	<cffunction name="checkdb" access="public" output="no">
		<cfargument name="api_key" type="string" required="true">
		<!--- Param --->
		<cfparam name="thehostid" default="" />
		<!--- If api key is empty --->
		<cfif arguments.api_key EQ "">
			<cfset arguments.api_key = 0>
		</cfif>
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
			<cfset session.thelangid = 1>
			<cfset session.login = "T">
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

	<!--- Execute Workflow --->
	<cffunction name="executeworkflow" output="false" returntype="void">
		<cfargument name="api_key" type="string">
		<cfargument name="action" type="string">
		<cfargument name="fileid" type="string">
		<cfargument name="folder_id" type="string">
		<!--- Query --->
		<cfif arguments.action NEQ "on_folder_add">
			<cfquery datasource="#application.razuna.api.dsn#" name="qry_forwf">
			SELECT folder_id_r, img_filename AS thefilename, 'img' AS thefiletype
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#images
			WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			UNION ALL
			SELECT folder_id_r, vid_filename AS thefilename, 'vid' AS thefiletype
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos
			WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			UNION ALL
			SELECT folder_id_r, aud_name AS thefilename, 'aud' AS thefiletype
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios
			WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			UNION ALL
			SELECT folder_id_r, file_name AS thefilename, 'doc' AS thefiletype
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#files
			WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			</cfquery>
			<!--- Set vars --->
			<cfset arguments.folder_id = qry_forwf.folder_id_r>
			<cfset arguments.thefiletype = qry_forwf.thefiletype>
			<cfset arguments.file_name = qry_forwf.thefilename>
			<!--- Call workflow --->
			<cfset arguments.folder_action = false>
			<cfinvoke component="global.cfc.plugins" method="getactions" theaction="#arguments.action#" args="#arguments#" />
			<!--- Call workflow --->
			<cfset arguments.folder_action = true>
		</cfif>
		<cfinvoke component="global.cfc.plugins" method="getactions" theaction="#arguments.action#" args="#arguments#" />
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Update Search --->
	<cffunction name="updateSearch" output="false" returntype="void">
		<cfargument name="assetid" required="true">
		<cfargument name="assetcategory" required="true">
		<cfargument name="api_key" required="true">
		<!--- Thread --->
		<cfthread action="run" intstruct="#arguments#">
			<cfinvoke method="updateSearch_Thread">
				<cfinvokeargument name="assetid" value="#attributes.intstruct.assetid#" />
				<cfinvokeargument name="assetcategory" value="#attributes.intstruct.assetcategory#" />
				<cfinvokeargument name="api_key" value="#attributes.intstruct.api_key#" />
			</cfinvoke>
		</cfthread>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Update Search --->
	<cffunction name="updateSearch_Thread" output="false" returntype="void">
		<cfargument name="assetid" required="true">
		<cfargument name="assetcategory" required="true">
		<cfargument name="api_key" required="true">
		<!--- Call Lucene --->
		<cfif application.razuna.api.lucene EQ "global.cfc.lucene">
			<cfinvoke component="#application.razuna.api.lucene#" method="index_update_api" assetid="#arguments.assetid#" assetcategory="#arguments.assetcategory#" dsn="#application.razuna.api.dsn#" storage="#application.razuna.api.storage#" prefix="#application.razuna.api.prefix["#arguments.api_key#"]#" hostid="#application.razuna.api.hostid["#arguments.api_key#"]#" thedatabase="#application.razuna.api.thedatabase#">
		<cfelse>
			<cfhttp url="#application.razuna.api.lucene#/global/cfc/lucene.cfc">
				<cfhttpparam name="method" value="index_update_api" type="url" />
				<cfhttpparam name="assetid" value="#arguments.assetid#" type="url" />
				<cfhttpparam name="assetcategory" value="#arguments.assetcategory#" type="url" />
				<cfhttpparam name="dsn" value="#application.razuna.api.dsn#" type="url" />
				<cfhttpparam name="storage" value="#application.razuna.api.storage#" type="url" />
				<cfhttpparam name="thedatabase" value="#application.razuna.api.thedatabase#" type="url" />
				<cfhttpparam name="prefix" value="#application.razuna.api.prefix["#arguments.api_key#"]#" type="url" />
				<cfhttpparam name="hostid" value="#application.razuna.api.hostid["#arguments.api_key#"]#" type="url" />
			</cfhttp>
		</cfif>
	</cffunction>

	<!--- Search --->
	<cffunction name="search" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="category" required="true">
		<cfargument name="hostid" required="true">
		<!--- Call Lucene --->
		<cfif application.razuna.api.lucene EQ "global.cfc.lucene">
			<cfinvoke component="#application.razuna.api.lucene#" method="search" criteria="#arguments.criteria#" category="#arguments.category#" hostid="#arguments.hostid#" returnvariable="qrylucene">
		<cfelse>
			<cfhttp url="#application.razuna.api.lucene#/global/cfc/lucene.cfc">
				<cfhttpparam name="method" value="search" type="url" />
				<cfhttpparam name="criteria" value="#arguments.criteria#" type="url" />
				<cfhttpparam name="category" value="#arguments.category#" type="url" />
				<cfhttpparam name="hostid" value="#arguments.hostid#" type="url" />
			</cfhttp>
			<!--- Set the return --->
			<cfwddx action="wddx2cfml" input="#cfhttp.filecontent#" output="qrylucene" />
		</cfif>
		<!--- Return --->
		<cfreturn qrylucene>
	</cffunction>

</cfcomponent>