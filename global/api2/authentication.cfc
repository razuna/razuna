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
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT  /* #theapikey##thehostid#checkdb */  u.user_id, gu.ct_g_u_grp_id grpid, ct.ct_u_h_host_id hostid
		FROM users u INNER JOIN ct_users_hosts ct ON u.user_id = ct.ct_u_h_user_id
		LEFT JOIN ct_groups_users gu ON gu.ct_g_u_user_id = u.user_id <!--- Left join on groups since users that are non admin can now also access the API and they may not be part of any groups --->
		WHERE user_api_key = <cfqueryparam value="#theapikey#" cfsqltype="cf_sql_varchar">
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
			<cfquery datasource="#application.razuna.datasource#" name="pre" cachedwithin="1" region="razcache">
			SELECT /* #theapikey##thehostid#checkdb2 */ host_shard_group, host_path, host_name
			FROM hosts
			WHERE host_id = <cfqueryparam value="#qry.hostid#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<!--- Set Host information --->
			<!--- <cfset application.razuna.trans = createObject("component","global.cfc.ResourceManager").init('translations')> --->
			<cfset session.hostdbprefix = pre.host_shard_group>
			<cfset session.hostpath = pre.host_path>
			<cfset session.hostid = qry.hostid>
			<cfset session.theuserid = qry.user_id>
			<cfset session.thelang = "English">
			<cfset session.thelangid = 1>
			<cfset session.login = "T">
			<cfset session.libpath  =  replace(replace("#expandpath('../../')#WEB-INF\lib","/","#fileseparator()#","ALL"),"\","#fileseparator()#","ALL")>
			<!--- Put user groups into session if present--->
			<cfif listlen(valuelist(qry.grpid)) GT 0>
				<cfset session.thegroupofuser = valuelist(qry.grpid)>
			</cfif>
			<!--- Set application and session --->
			<cfset _setAppSession()>
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
		<!--- Call reset function --->
		<cfset var c = callFunction(comp="global.cfc.extQueryCaching", func="getcachetoken", type=arguments.type, hostid=session.hostid)>
		<!--- Return --->
		<cfreturn c />
	</cffunction>

	<!--- reset the global caching variable of this cfc-object --->
	<cffunction name="resetcachetoken" output="false" returntype="void">
		<cfargument name="api_key" type="string">
		<cfargument name="type" type="string" required="yes">
		<!--- Call reset function --->
		<cfset callFunction(comp="global.cfc.extQueryCaching", func="resetcachetokenall", hostid=session.hostid)>
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
			<cfquery datasource="#application.razuna.datasource#" name="qry_forwf">
			SELECT folder_id_r, img_filename AS thefilename, 'img' AS thefiletype
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			UNION ALL
			SELECT folder_id_r, vid_filename AS thefilename, 'vid' AS thefiletype
			FROM #session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			UNION ALL
			SELECT folder_id_r, aud_name AS thefilename, 'aud' AS thefiletype
			FROM #session.hostdbprefix#audios
			WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			UNION ALL
			SELECT folder_id_r, file_name AS thefilename, 'doc' AS thefiletype
			FROM #session.hostdbprefix#files
			WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
			</cfquery>
			<!--- Set vars --->
			<cfset arguments.folder_id = qry_forwf.folder_id_r>
			<cfset arguments.thefiletype = qry_forwf.thefiletype>
			<cfset arguments.file_name = qry_forwf.thefilename>
			<!--- Call workflow --->
			<cfset arguments.folder_action = false>
			<cfset callFunction(comp="global.cfc.plugins", func="getactions", theaction=arguments.action, args=arguments)>
			<!--- Call workflow --->
			<cfset arguments.folder_action = true>
		</cfif>
		<!--- Merge struct with default one --->
		<cfset callFunction(comp="global.cfc.plugins", func="getactions", theaction=arguments.action, args=arguments)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Get path to assets --->
	<cffunction name="getAssetsPath" output="false" returntype="string">
		<cfargument name="api_key" required="true">
		<!--- Temp --->
		<cfset var qry = "" />
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT set2_path_to_assets
		FROM #session.hostdbprefix#settings_2
		WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- Return --->
		<cfreturn qry.set2_path_to_assets />
	</cffunction>

	<!--- Get path to assets --->
	<cffunction name="getThumbExt" output="false" returntype="string">
		<cfargument name="api_key" required="true">
		<!--- Temp --->
		<cfset var qry = "" />
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT set2_img_format
		FROM #session.hostdbprefix#settings_2
		WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- Return --->
		<cfreturn qry.set2_img_format />
	</cffunction>

	<!--- Update Search --->
	<cffunction name="updateSearchIndex" output="false" returntype="void">
		<cfargument name="assetid" required="true">
		<cfargument name="api_key" required="true">
		<!--- Thread --->
		<cfthread action="run" intstruct="#arguments#">
			<cfinvoke method="updateSearchIndexThread">
				<cfinvokeargument name="assetid" value="#attributes.intstruct.assetid#" />
				<cfinvokeargument name="api_key" value="#attributes.intstruct.api_key#" />
				<cfinvokeargument name="thestruct" value="#attributes.intstruct.thestruct#" />
			</cfinvoke>
		</cfthread>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Update Search --->
	<cffunction name="updateSearchIndexThread" output="false" returntype="void">
		<cfargument name="assetid" required="true">
		<cfargument name="api_key" required="true">
		<!--- Call Lucene --->
		<cfif application.razuna.lucene EQ "global.cfc.lucene">
			<cfset callFunction(comp="global.cfc.lucene", func="index_update_api", assetid=arguments.assetid)>
		<cfelse>
			<!--- Merge struct with default one --->
			<cfset arguments = setStruct(arguments)>
			<cfhttp url="#application.razuna.lucene#/global/cfc/lucene.cfc">
				<cfhttpparam name="method" value="index_update_api" type="url" />
				<cfhttpparam name="assetid" value="#arguments.assetid#" type="url" />
				<cfhttpparam name="dsn" value="#application.razuna.datasource#" type="url" />
				<cfhttpparam name="prefix" value="#session.hostdbprefix#" type="url" />
				<cfhttpparam name="hostid" value="#session.hostid#" type="url" />
				<cfhttpparam name="thestruct" value="#arguments.thestruct#" type="url" />
			</cfhttp>
		</cfif>
	</cffunction>

	<!--- Search --->
	<cffunction name="search" output="false">
		<cfargument name="criteria" required="true">
		<cfargument name="category" required="true">
		<cfargument name="hostid" required="true">
		<cfargument name="startrow" required="true" type="numeric">
		<cfargument name="maxrows" required="true" type="numeric">
		<cfargument name="folderid" required="true" type="string">
		<cfargument name="showrenditions" required="false" default="true" type="string">
		<cfargument name="search_upc" type="boolean" required="false" default="false">
		<!--- Renditions param is boolean convert it here --->
		<cfif !arguments.showrenditions>
			<cfset var _rendition = "t">
		<cfelse>
			<cfset var _rendition = "f">
		</cfif>
		<!--- Call Lucene --->
		<cfif application.razuna.lucene EQ "global.cfc.lucene">
			<cfset var qrylucene = callFunction(comp="global.cfc.lucene", func="search", hostid=arguments.hostid, criteria=arguments.criteria, category=arguments.category, startrow=arguments.startrow, maxrows=arguments.maxrows, folderid=arguments.folderid, search_rendition=_rendition, search_upc=arguments.search_upc, search_type="" )>
		<cfelse>
			<!--- Merge struct with default one --->
			<cfset arguments = setStruct(arguments)>
			<cfhttp url="#application.razuna.lucene#/global/cfc/lucene.cfc">
				<cfhttpparam name="method" value="search" type="url" />
				<cfhttpparam name="criteria" value="#arguments.criteria#" type="url" />
				<cfhttpparam name="category" value="#arguments.category#" type="url" />
				<cfhttpparam name="hostid" value="#arguments.hostid#" type="url" />
				<cfhttpparam name="startrow" value="#arguments.startrow#" type="url" />
				<cfhttpparam name="maxrows" value="#arguments.maxrows#" type="url" />
				<cfhttpparam name="folderid" value="#arguments.folderid#" type="url" />
				<cfhttpparam name="search_rendition" value="#_rendition#" type="url" />
				<cfhttpparam name="search_upc" value="#arguments.search_upc#" type="url" />
				<cfhttpparam name="search_type" value="" type="url" />
			</cfhttp>
			<!--- Set the return --->
			<cfwddx action="wddx2cfml" input="#cfhttp.filecontent#" output="qrylucene" />
		</cfif>
		<!--- Return --->
		<cfreturn qrylucene>
	</cffunction>

	<!--- Combine searches for API --->
	<cffunction name="search_combine_api" access="Public" output="false">
		<cfargument name="qdoc" required="true" type="query">
		<cfargument name="qimg" required="true" type="query">
		<cfargument name="qvid" required="true" type="query">
		<cfargument name="qaud" required="true" type="query">
		<!--- Param --->
		<cfset var qry = structnew()>
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
			<cfset var sortby = "filename_forsort">
		<cfelseif session.sortby EQ "sizedesc">
			<cfset var sortby = "size DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "size ASC">
		<cfelseif session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		<cfelse>
			<cfset var sortby = "filename_forsort">
		</cfif>
		<!--- Union the 4 query results into one --->
		<cfquery name="qry.qall" dbtype="query">
		SELECT *
		FROM arguments.qdoc
		WHERE id IS NOT NULL
		UNION ALL
		SELECT *
		FROM arguments.qimg
		WHERE id IS NOT NULL
		UNION ALL
		SELECT *
		FROM arguments.qvid
		WHERE id IS NOT NULL
		UNION ALL
		SELECT *
		FROM arguments.qaud
		WHERE id IS NOT NULL
		ORDER BY #sortby#
		</cfquery>
		<!--- Set each query result into struct --->
		<cfset qry.qdoc = arguments.qdoc>
		<cfset qry.qimg = arguments.qimg>
		<cfset qry.qvid = arguments.qvid>
		<cfset qry.qaud = arguments.qaud>
		<!--- If recordcount is empty then 0 the cnt --->
		<cfset var qdocc = arguments.qdoc.cnt>
		<cfset var qimgc = arguments.qimg.cnt>
		<cfset var qvidc = arguments.qvid.cnt>
		<cfset var qaudc = arguments.qaud.cnt>
		<cfif !isnumeric(arguments.qdoc.cnt)>
			<cfset var qdocc = 0>
		</cfif>
		<cfif !isnumeric(arguments.qimg.cnt)>
			<cfset var qimgc = 0>
		</cfif>
		<cfif !isnumeric(arguments.qvid.cnt)>
			<cfset var qvidc = 0>
		</cfif>
		<cfif !isnumeric(arguments.qaud.cnt)>
			<cfset var qaudc = 0>
		</cfif>
		<!--- Calculate the total found files together --->
		<cfset qry.thetotal = qdocc + qimgc + qvidc + qaudc>
		<!--- Return --->
		<cfreturn qry>
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
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
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
			<cfquery datasource="#application.razuna.datasource#" name="pre" cachedwithin="1" region="razcache">
			SELECT /* #theapikey##thehostid#checkdesktop2 */ host_shard_group,host_path
			FROM hosts
			WHERE host_id = <cfqueryparam value="#qry.hostid#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<!--- Set Host information --->
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
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT a.folder_id_r, f.folder_owner, fg.grp_id_r, fg.grp_permission
			FROM #session.hostdbprefix#images a, #session.hostdbprefix#folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
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
			FROM #session.hostdbprefix#videos a, #session.hostdbprefix#folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
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
			FROM #session.hostdbprefix#audios a, #session.hostdbprefix#folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
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
			FROM #session.hostdbprefix#files a, #session.hostdbprefix#folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.folder_id = fg.folder_id_r AND fg.host_id = f.host_id
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
			<cfquery datasource="#application.razuna.datasource#" name="fprop">
			SELECT  f.folder_owner, fg.grp_id_r, fg.grp_permission
			FROM  #session.hostdbprefix#folders f LEFT JOIN  #session.hostdbprefix#folders_groups fg ON f.folder_id = fg.folder_id_r AND f.host_id = fg.host_id
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
			<cfquery datasource="#application.razuna.datasource#" name="lprop">
			SELECT 1
				FROM ct_labels l
				LEFT JOIN #session.hostdbprefix#images i ON l.ct_id_r = i.img_id AND  l.ct_type =<cfqueryparam value="img" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#audios a ON l.ct_id_r = a.aud_id  AND  l.ct_type =<cfqueryparam value="aud" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#videos v ON l.ct_id_r = v.vid_id  AND  l.ct_type =<cfqueryparam value="vid" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#files f ON l.ct_id_r = f.file_id  AND  l.ct_type =<cfqueryparam value="doc" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#folders fo ON l.ct_id_r = fo.folder_id  AND  l.ct_type =<cfqueryparam value="folder" cfsqltype="cf_sql_varchar"/>
				WHERE
				ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				<!--- Ensure user has access to folder in which asset resides --->
				AND
				(
				<!--- Check if user is owner of folder containing asset that has label--->
				EXISTS (
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#session.theuserid#'
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#session.theuserid#'
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#session.theuserid#'
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  f.folder_id_r AND folder_owner = '#session.theuserid#'
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  fo.folder_id_r AND folder_owner = '#session.theuserid#'
					)
				OR
				<!--- Check if folder containing asset that has label is accessible to 'Everyone' and that user has appropriate access privileges on it   --->
				EXISTS (
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND  f.grp_id_r ='0' AND f.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE  a.folder_id_r = f.folder_id_r AND f.grp_id_r ='0' AND f.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders_groups fg WHERE  f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = '0' AND fg.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM #session.hostdbprefix#folders_groups fg WHERE  fo.folder_id = fg.folder_id_r AND fg.grp_id_r = '0' AND fg.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					)
				OR
				<!--- Check if folder containing asset that has label is accessible to a group that user belows to and that he has appropriate access privileges on it  --->
				EXISTS (
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id  AND f.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND fg.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					UNION
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND fo.folder_id = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND fg.grp_permission IN  (<cfqueryparam cfsqltype="cf_sql_varchar" value="#privileges#" list="true">)
					)
				)
			</cfquery>
			<cfif lprop.recordcount neq 0>
				<cfset labelaccess = true>
			</cfif>
		</cfif>
		<cfreturn labelaccess />
	</cffunction>

	<!--- Call function --->
	<cffunction name="callFunction" returntype="any" access="public">
		<cfargument name="comp" type="string" required="true">
		<cfargument name="func" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="false" default="#structnew()#">
		<cfargument name="args" type="struct" required="false" default="#structnew()#">
		<cfargument name="folder_id" type="string" required="false" default="">
		<cfargument name="folderid" type="string" required="false" default="">
		<cfargument name="parentid" type="string" required="false" default="">
		<cfargument name="id" type="string" required="false" default="">
		<cfargument name="type" type="string" required="false" default="">
		<cfargument name="fileid" type="string" required="false" default="">
		<cfargument name="label_id" type="string" required="false" default="">
		<cfargument name="label_kind" type="string" required="false" default="">
		<cfargument name="fromapi" type="string" required="false" default="">
		<cfargument name="group_id" type="string" required="false" default="">
		<cfargument name="user_id" type="string" required="false" default="">
		<cfargument name="hostid" type="string" required="false" default="">
		<cfargument name="theaction" type="string" required="false" default="">
		<cfargument name="assetid" type="string" required="false" default="">
		<cfargument name="criteria" type="string" required="false" default="">
		<cfargument name="category" type="string" required="false" default="">
		<cfargument name="startrow" type="string" required="false" default="0">
		<cfargument name="maxrows" type="string" required="false" default="25">
		<cfargument name="search_rendition" type="string" required="false" default="">
		<cfargument name="search_upc" type="string" required="false" default="">
		<cfargument name="search_type" type="string" required="false" default="">
		<!--- Var --->
		<cfset var _return = "">
		<!--- Merge struct with default one --->
		<cfset arguments = setStruct(arguments)>
		<!--- Invoke function --->
		<cfinvoke component="#arguments.comp#" method="#arguments.func#" thestruct="#arguments.thestruct#" folder_id="#arguments.folder_id#" folderid="#arguments.folderid#" parentid="#arguments.parentid#" id="#arguments.id#" type="#arguments.type#" fileid="#arguments.fileid#" label_id="#arguments.label_id#" label_kind="#arguments.label_kind#" fromapi="#arguments.fromapi#" group_id="#arguments.group_id#" user_id="#arguments.user_id#" hostid="#arguments.hostid#" theaction="#arguments.theaction#" assetid="#arguments.assetid#" criteria="#arguments.criteria#" category="#arguments.category#" startrow="#arguments.startrow#" maxrows="#arguments.maxrows#" search_rendition="#arguments.search_rendition#" search_upc="#arguments.search_upc#" args="#arguments.args#" search_type="#arguments.search_type#" returnvariable="_return" />
		<!--- Return --->
		<cfreturn _return />
	</cffunction>

	<!--- Put intop the struct --->
	<cffunction name="setStruct" returntype="struct" access="public">
		<cfargument name="_s" type="struct" required="true">
		<!--- If thestruct is not here --->
		<cfif ! structKeyExists(arguments._s, "thestruct")>
			<cfset arguments._s.thestruct = structnew()>
		</cfif>
		<!--- Create struct --->
		<cfset var _new = structnew()>
		<cfset _new.thestruct.razuna = structnew()>
		<!--- Add application razuna scope --->
		<cfset _new.thestruct.razuna.application = application.razuna.application>
		<cfset _new.thestruct.razuna.session = application.razuna.session>
		<!--- Add passed in arguments to thestruct --->
		<cfset structAppend(_new.thestruct, arguments._s.thestruct)>
		<!--- Delete thestruct from arguments --->
		<cfset StructDelete(arguments._s, "thestruct")>
		<!--- Finally just merge new with arguments --->
		<cfset structAppend(arguments._s, _new)>
		<!--- Return --->
		<cfreturn arguments._s />
	</cffunction>

	<!--- Set App and session into app scope to pass them on --->
	<cffunction name="_setAppSession" returntype="void" access="private">
		<cfset application.razuna.session = structnew()>
		<cfset application.razuna.application.datasource = application.razuna.datasource>
		<cfset application.razuna.application.thedatabase = application.razuna.thedatabase>
		<cfset application.razuna.application.storage = application.razuna.storage>
		<cfset application.razuna.application.setid = application.razuna.setid>
		<cfset application.razuna.application.theschema = application.razuna.theschema>
		<cfset application.razuna.application.awskey = application.razuna.awskey>
		<cfset application.razuna.application.awskeysecret = application.razuna.awskeysecret>
		<cfset application.razuna.application.awslocation = application.razuna.awslocation>
		<cfset application.razuna.application.awstenaneonebucket = application.razuna.awstenaneonebucket>
		<cfset application.razuna.application.awstenaneonebucketname = application.razuna.awstenaneonebucketname>
		<cfset application.razuna.application.isp = application.razuna.isp>
		<cfset application.razuna.application.rfs = application.razuna.rfs>
		<cfset application.razuna.application.s3ds = application.razuna.s3ds>
		<cfset application.razuna.session = session>
	</cffunction>

</cfcomponent>