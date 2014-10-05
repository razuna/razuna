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
	<cfparam name="application.razuna.api.lucene" default="global.cfc.lucene">

	<!--- Check for db entry --->
	<cffunction name="checkdb" access="public" output="no">
		<cfargument name="api_key" type="string" required="true">
		<!--- Param --->
		<cfparam name="thehostid" default="" />
		<cfparam default="0" name="session.thefolderorg">
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
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT  /* #theapikey##thehostid#checkdb */  u.user_id, gu.ct_g_u_grp_id grpid, ct.ct_u_h_host_id hostid
		FROM users u INNER JOIN ct_users_hosts ct ON u.user_id = ct.ct_u_h_user_id
		LEFT JOIN ct_groups_users gu ON gu.ct_g_u_user_id = u.user_id <!--- Left join on groups since users that are non admin can now also access the API and they may not be part of any groups --->
		WHERE user_api_key =<cfqueryparam value="#theapikey#" cfsqltype="cf_sql_varchar">
		<cfif thehostid NEQ "">
			AND ct.ct_u_h_host_id = <cfqueryparam value="#thehostid#" cfsqltype="cf_sql_numeric">
		</cfif> 
		GROUP BY user_id, ct_g_u_grp_id, ct_u_h_host_id
		</cfquery>
		<!--- If user not found then deny access --->
		<cfif qry.recordcount EQ 0>
			<!--- Set --->
			<cfset var status = false>
		<cfelse>
			<!--- Set --->
			<cfset var status = true>
			<cfset session.thegroupofuser = 0>
			<!--- Get Host prefix --->
			<cfquery datasource="#application.razuna.api.dsn#" name="pre" cachedwithin="1" region="razcache">
			SELECT /* #theapikey##thehostid#checkdb2 */ host_shard_group, host_path, host_name
			FROM hosts
			WHERE host_id = <cfqueryparam value="#qry.hostid#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<!--- Set Host information --->
			<cfset application.razuna.api.host_path = pre.host_path>
			<cfset application.razuna.api.prefix[#arguments.api_key#] = pre.host_shard_group>
			<cfset application.razuna.api.hostpath[#arguments.api_key#] = pre.host_path>
			<cfset application.razuna.api.hostname[#arguments.api_key#] = pre.host_name>
			<cfset application.razuna.api.hostid[#arguments.api_key#] = qry.hostid>
			<cfset application.razuna.api.userid[#arguments.api_key#] = qry.user_id>
			<cfset session.hostdbprefix = pre.host_shard_group>
			<cfset session.hostid = qry.hostid>
			<cfset session.theuserid = qry.user_id>
			<cfset session.thelangid = 1>
			<cfset session.login = "T">
			<!--- Put user groups into session if present--->
			<cfif listlen(valuelist(qry.grpid)) GT 0>
				<cfset session.thegroupofuser = valuelist(qry.grpid)>
			</cfif>
			<!--- Set vars needed for AWS --->
			<cfif application.razuna.api.storage EQ "amazon">
				<cfset var qry = "">
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT set2_aws_bucket
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#settings_2
				WHERE set2_id = <cfqueryparam value="#application.razuna.api.setid#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.api_key#"]#">
				</cfquery>
				<cfset application.razuna.awsbucket = qry.set2_aws_bucket>
				<cfset application.razuna.awskey = application.razuna.api.awskey>
				<cfset application.razuna.awskeysecret = application.razuna.api.awskeysecret>
				<cfset application.razuna.awslocation = application.razuna.api.awslocation>
				<cfif NOT isDefined("application.razuna.s3ds")>
					<cfset application.razuna.s3ds = AmazonRegisterDataSource("aws","#application.razuna.api.awskey#","#application.razuna.api.awskeysecret#","#application.razuna.api.awslocation#")>
				</cfif>
			</cfif>
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
			<cfset querysetcell(thexml,"message","Login not valid! Check user API Key and ensure with your administrator that the user has appropriate permissions for access.")>
			<cfelseif arguments.type EQ "x">
			<!--- Create the XML --->
			<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>Login not valid! Check user API Key and ensure with your administrator that the user has appropriate permissions for access.</message>
</Response></cfoutput>
			</cfsavecontent>
		<cfelse>
			<cfset thexml.responsecode = 1>
			<cfset thexml.message = "Login not valid! Check user API Key and ensure with your administrator that the user has appropriate permissions for access.">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>

	<!--- No access error message --->
	<cffunction name="noaccess" access="public" output="false">
		<cfargument name="type" required="false" default="q" type="string" />
		<!--- By default we say this returns a query --->
		<cfif arguments.type EQ "q">
			<cfset var thexml = querynew("responsecode,message")>
			<cfset queryaddrow(thexml,1)>
			<cfset querysetcell(thexml,"responsecode","1")>
			<cfset querysetcell(thexml,"message","No permissible data or action found for user! If you believe this is a mistake then please check with your administrator to ensure that you have appropriate permissions for access.")>
		<cfelse>
			<cfset thexml.responsecode = 1>
			<cfset thexml.message = "No permissible data or action found for user! If you believe this is a mistake then please check with your administrator to ensure that you have appropriate permissions for access.">
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
		<!--- For Workflow --->
		<cfset arguments.comingfrom = cgi.http_referer>
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
		<cfargument name="api_key" required="true">
		<!--- Thread --->
		<cfthread action="run" intstruct="#arguments#">
			<cfinvoke method="updateSearch_Thread">
				<cfinvokeargument name="assetid" value="#attributes.intstruct.assetid#" />
				<cfinvokeargument name="api_key" value="#attributes.intstruct.api_key#" />
			</cfinvoke>
		</cfthread>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Update Search --->
	<cffunction name="updateSearch_Thread" output="false" returntype="void">
		<cfargument name="assetid" required="true">
		<cfargument name="api_key" required="true">
		<!--- Call Lucene --->
		<cfif application.razuna.api.lucene EQ "global.cfc.lucene">
			<cfinvoke component="#application.razuna.api.lucene#" method="index_update_api">
				<cfinvokeargument name="assetid" value="#arguments.assetid#" />
				<cfinvokeargument name="dsn" value="#application.razuna.api.dsn#" />
				<cfinvokeargument name="storage" value="#application.razuna.api.storage#" />
				<cfinvokeargument name="prefix" value="#application.razuna.api.prefix["#arguments.api_key#"]#" />
				<cfinvokeargument name="hostid" value="#application.razuna.api.hostid["#arguments.api_key#"]#" />
				<cfinvokeargument name="thedatabase" value="#application.razuna.api.thedatabase#" />
			</cfinvoke>
		<cfelse>
			<cfhttp url="#application.razuna.api.lucene#/global/cfc/lucene.cfc">
				<cfhttpparam name="method" value="index_update_api" type="url" />
				<cfhttpparam name="assetid" value="#arguments.assetid#" type="url" />
				<cfhttpparam name="dsn" value="#application.razuna.api.dsn#" type="url" />
				<cfhttpparam name="storage" value="#application.razuna.api.storage#" type="url" />
				<cfhttpparam name="prefix" value="#application.razuna.api.prefix["#arguments.api_key#"]#" type="url" />
				<cfhttpparam name="hostid" value="#application.razuna.api.hostid["#arguments.api_key#"]#" type="url" />	
				<cfhttpparam name="thedatabase" value="#application.razuna.api.thedatabase#" type="url" />
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
			<cfinvoke component="#application.razuna.api.lucene#" method="search" returnvariable="qrylucene"> 
				<cfinvokeargument name="criteria" value="#arguments.criteria#" />
				<cfinvokeargument name="category" value="#arguments.category#" />
				<cfinvokeargument name="hostid" value="#arguments.hostid#" />
			</cfinvoke>
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

	<!--- Check for desktop user --->
	<cffunction name="checkDesktop" access="public" output="no">
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
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #theapikey##thehostid#checkdesktop */ u.user_id, gu.ct_g_u_grp_id grpid, ct.ct_u_h_host_id hostid
		FROM ct_users_hosts ct, users u left join ct_groups_users gu on gu.ct_g_u_user_id = u.user_id
		WHERE user_api_key = <cfqueryparam value="#theapikey#" cfsqltype="cf_sql_varchar"> 
		AND u.user_id = ct.ct_u_h_user_id
		<cfif thehostid NEQ "">
			AND ct.ct_u_h_host_id = <cfqueryparam value="#thehostid#" cfsqltype="cf_sql_numeric">
		</cfif>
		GROUP BY user_id, ct_g_u_grp_id, ct_u_h_host_id
		</cfquery>
		<!--- If timeout is within the last 30 minutes then extend it again --->
		<cfif qry.recordcount EQ 0>
			<!--- Set --->
			<cfset status.login = false>
			<cfset status.hostid = 0>
			<cfset status.grpid = 0>
		<cfelse>
			<!--- Set --->
			<cfset status.login = true>
			<cfset status.hostid = qry.hostid>
			<cfset status.grpid = qry.grpid>
			<!--- Get Host prefix --->
			<cfquery datasource="#application.razuna.api.dsn#" name="pre" cachedwithin="1" region="razcache">
			SELECT /* #theapikey##thehostid#checkdesktop2 */ host_shard_group,host_path
			FROM hosts
			WHERE host_id = <cfqueryparam value="#qry.hostid#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<!--- Set Host information --->
			<cfset application.razuna.api.host_path = pre.host_path>
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

	<!--- Check permissions on asset based on the folder permissions in which it resides --->
    <!--- Check to see if user has permission to access folder in which asset resides. There can be 3 cases:
	1) User has been granted appropriate access privileges on folder containing asset
	2) Folder containing asset has appropriate access for everyone (groupid=0)
	3) User is owner of folder (folder_owner column in raz1_folders) containing asset
	--->
	<cffunction name="checkFolderPerm" access="public" output="no">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="assetid" type="string" required="true">
		<!--- Param --->
		<cfset var qry = "">
		<cfset var folderaccess = "n">
		<!--- If there is no session for webgroups set --->
		<cfparam default="0" name="session.thegroupofuser">
		<!--- If user is in admin or sysadmin group he has full access --->
		<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
			<cfset var folderaccess = "x">
		<!--- Else we need to query group access for this user --->
		<cfelse>
			<!--- Get folder_id --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT a.folder_id_r, f.folder_owner, fg.grp_id_r, fg.grp_permission
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#images a, #application.razuna.api.prefix["#arguments.api_key#"]#folders f LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
			WHERE a.img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
			AND f.folder_id = a.folder_id_r
			AND f.host_id = a.host_id
			AND (
				fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">)
				OR
				fg.grp_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				OR 
				f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
			)
			UNION ALL
			SELECT a.folder_id_r, f.folder_owner, fg.grp_id_r, fg.grp_permission
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#videos a, #application.razuna.api.prefix["#arguments.api_key#"]#folders f LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
			WHERE a.vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
			AND f.folder_id = a.folder_id_r
			AND f.host_id = a.host_id
			AND (
				fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">)
				OR
				fg.grp_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				OR 
				f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
			)
			UNION ALL
			SELECT a.folder_id_r, f.folder_owner, fg.grp_id_r, fg.grp_permission
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#audios a, #application.razuna.api.prefix["#arguments.api_key#"]#folders f LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
			WHERE a.aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
			AND f.folder_id = a.folder_id_r
			AND f.host_id = a.host_id
			AND (
				fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">)
				OR
				fg.grp_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				OR 
				f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
			)
			UNION ALL
			SELECT a.folder_id_r, f.folder_owner, fg.grp_id_r, fg.grp_permission
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#files a, #application.razuna.api.prefix["#arguments.api_key#"]#folders f LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
			WHERE a.file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.assetid#">
			AND f.folder_id = a.folder_id_r
			AND f.host_id = a.host_id
			AND (
				fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">)
				OR
				fg.grp_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				OR 
				f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
			)
			</cfquery>
			<!--- If the user is the folder owner he has full access --->
			<cfif qry.folder_owner EQ session.theuserid>
				<cfset var folderaccess = "x">
			<!--- Loop over results --->
			<cfelse>
				<cfloop query="qry">
					<cfif grp_permission EQ "R" AND folderaccess NEQ "W" AND folderaccess NEQ "X">
						<cfset var folderaccess = grp_permission>
					<cfelseif grp_permission EQ "W" AND folderaccess NEQ "X">
						<cfset var folderaccess = grp_permission>
					<cfelseif grp_permission EQ "X">
						<cfset var folderaccess = grp_permission>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<!--- Return --->
		<cfreturn folderaccess>
	</cffunction>

	<!--- Get folder access for user --->
	<cffunction hint="Get Folder Access" name="checkFolderAccess" output="true" returntype="string">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="folder_id" required="true" type="string">
		<!--- Param --->
		<cfset var fprop = "">
		<!--- Set the access rights for this folder --->
		<cfset var folderaccess = "n">
		<!--- If there is no session for webgroups set --->
		<cfparam default="0" name="session.thegroupofuser">
		<!--- If user is in admin or sysadmin group he has full access. If root folder requested than also grant access as folder access then is checked for each individual folder. --->
		<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0 OR arguments.folder_id EQ 0>
			<cfset var folderaccess = "x">
		<!--- Else we need to query group access for this user --->
		<cfelse>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="fprop">
			SELECT  f.folder_owner, fg.grp_id_r, fg.grp_permission
			FROM  #application.razuna.api.prefix["#arguments.api_key#"]#folders f LEFT JOIN  #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg ON f.folder_id = fg.folder_id_r AND f.host_id = fg.host_id
			WHERE f.folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND (
				fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">)
				OR
				fg.grp_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				OR 
				f.folder_owner =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">
				)
			</cfquery>
			<!--- If the user is the folder owner he has full access --->
			<cfif fprop.folder_owner EQ session.theuserid>
				<cfset var folderaccess = "x">
			<!--- Loop over results --->
			<cfelse>
				<cfloop query="fprop">
					<cfif grp_permission EQ "R" AND folderaccess NEQ "W" AND folderaccess NEQ "X">
						<cfset var folderaccess = grp_permission>
					<cfelseif grp_permission EQ "W" AND folderaccess NEQ "X">
						<cfset var folderaccess = grp_permission>
					<cfelseif grp_permission EQ "X">
						<cfset var folderaccess = grp_permission>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<cfreturn folderaccess />
	</cffunction>

	<!--- Get label permissions for user --->
	<cffunction hint="Get Label Permissions" name="checkLabelPerm" output="true" returntype="string">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="label_id" required="true" type="string">
		<cfargument name="privileges" required="true" type="string">
		<!--- Param --->
		<cfset var fprop = "">
		<!--- Set the access rights for this folder --->
		<cfset var labelaccess = false>
		<!--- If there is no session for webgroups set --->
		<cfparam default="0" name="session.thegroupofuser">
		<!--- If user is in admin or sysadmin group he has full access --->
		<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
			<cfset var labelaccess = true>
		<!--- Else we need to query group access for this user --->
		<cfelse>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="lprop">
			SELECT 1
				FROM ct_labels l
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#images i ON l.ct_id_r = i.img_id AND  l.ct_type =<cfqueryparam value="img" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#audios a ON l.ct_id_r = a.aud_id  AND  l.ct_type =<cfqueryparam value="aud" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#videos v ON l.ct_id_r = v.vid_id  AND  l.ct_type =<cfqueryparam value="vid" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#files f ON l.ct_id_r = f.file_id  AND  l.ct_type =<cfqueryparam value="doc" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #application.razuna.api.prefix["#arguments.api_key#"]#folders fo ON l.ct_id_r = fo.folder_id  AND  l.ct_type =<cfqueryparam value="folder" cfsqltype="cf_sql_varchar"/>
				WHERE
				ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				<!--- Ensure user has access to folder in which asset resides --->
				AND 
				(
				<!--- Check if user is owner of folder containing asset that has label--->
				EXISTS (
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#session.theuserid#' 
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#session.theuserid#' 
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#session.theuserid#' 
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders WHERE folder_id =  f.folder_id_r AND folder_owner = '#session.theuserid#' 
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders WHERE folder_id =  fo.folder_id_r AND folder_owner = '#session.theuserid#' 
					) 
				OR
				<!--- Check if folder containing asset that has label is accessible to 'Everyone' and that user has appropriate access privileges on it   --->
				EXISTS (
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND  f.grp_id_r ='0' AND lower(f.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups f WHERE  a.folder_id_r = f.folder_id_r AND f.grp_id_r ='0' AND lower(f.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND lower(f.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE  f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = '0' AND lower(fg.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE  fo.folder_id = fg.folder_id_r AND fg.grp_id_r = '0' AND lower(fg.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					)
				OR
				<!--- Check if folder containing asset that has label is accessible to a group that user belows to and that he has appropriate access privileges on it  --->
				EXISTS (
					SELECT 1 FROM ct_groups_users c, #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id  AND lower(f.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND lower(fg.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #application.razuna.api.prefix["#arguments.api_key#"]#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND fo.folder_id = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND lower(fg.grp_permission) IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					)
				)
			</cfquery>
			<cfif lprop.recordcount neq 0>
				<cfset labelaccess = true>
			</cfif>
		</cfif>
		<cfreturn labelaccess />
	</cffunction>

</cfcomponent>