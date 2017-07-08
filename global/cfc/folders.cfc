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
<cfcomponent output="false" extends="extQueryCaching">

<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("folders")>
<!--- GETTREE : GET THE FOLDERS AND SUBFOLDERS OF THIS HOST --->
<cffunction hint="GET THE FOLDERS AND SUBFOLDERS OF THIS HOST" name="getTree" output="false" access="public" returntype="query">
	<cfargument name="id" required="yes" type="string" hint="folder_id">
	<cfargument name="max_level_depth" default="0" required="false" type="numeric" hint="0 or negative numbers stand for all levels">
	<cfargument name="ColumnList" required="false" type="string" default="folder_id,folder_level,folder_name">
	<!--- this function implements only the interface & uses getTreeBy...()  --->
	<cfreturn getTreeByCollection(id=Arguments.id, max_level_depth=Arguments.max_level_depth, ColumnList=Arguments.ColumnList) />
</cffunction>

<!--- getTreeByCollection : GET THE FOLDERS AND SUBFOLDERS OF THIS HOST, WITH MORE OPTIONS --->
<cffunction name="getTreeByCollection" output="false" access="public" returntype="query">
	<cfargument name="id" required="yes" type="string" hint="folder_id">
	<cfargument name="max_level_depth" default="0" required="false" type="numeric" hint="0 or negative numbers stand for all levels">
	<cfargument name="ColumnList" required="false" type="string" default="folder_id,folder_level,folder_name">
	<cfargument name="ignoreCollections" required="no" type="boolean" default="0">
	<cfargument name="onlyCollections" required="no" type="boolean" default="0">
	<!--- init internal vars --->
	<cfset var f_1 = 0>
	<cfset var qSub = 0>
	<cfset var qRet = 0>
	<!--- Do the select --->
	<cfquery datasource="#variables.dsn#" name="f_1" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken##session.theUserID#getTreeByCollection */ #Arguments.ColumnList#,
		<!--- Permission follow but not for sysadmin and admin --->
		<cfif not session.is_system_admin and not session.is_administrator>
			CASE
				<!--- If this folder is protected with a group and this user belongs to this group --->
				WHEN EXISTS(
					SELECT fg.folder_id
					FROM #session.hostdbprefix#folders_groups fg, ct_groups_users gu
					WHERE fg.folder_id_r = f.folder_id
					AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
					AND gu.ct_g_u_grp_id = fg.grp_id_r
					AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2 LEFT JOIN ct_groups_users gu2 ON gu2.ct_g_u_grp_id = fg2.grp_id_r AND gu2.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
					WHERE fg2.folder_id_r = f.folder_id
					AND fg2.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					) THEN 'unlocked'
				<!--- If this is the user folder or he is the owner --->
				WHEN ( f.folder_of_user = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
				<!--- If this is the upload bin
				WHEN f.folder_id = 1 THEN 'unlocked' --->
				<!--- If this is a collection --->
				-- WHEN lower(f.folder_is_collection) = 't' THEN 'unlocked'
				<!--- If nothing meets the above lock the folder --->
				ELSE 'locked'
			END AS perm
		<cfelse>
			CASE
				WHEN ( f.folder_of_user = 't' AND f.folder_owner = '#Session.theUserID#' AND f.folder_name = 'my folder') THEN 'unlocked'
				WHEN ( f.folder_of_user = 't' AND f.folder_name = 'my folder') THEN 'locked'
				ELSE 'unlocked'
			END AS perm
		</cfif>
	FROM #session.hostdbprefix#folders f
	WHERE
	<cfif Arguments.id gt 0>
		f.folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
		AND
		f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.id#">
	<cfelse>
		f.folder_id = f.folder_id_r
	</cfif>
	<cfif Arguments.ignoreCollections>
		AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
	</cfif>
	<cfif Arguments.onlyCollections>
		AND f.folder_is_collection = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
	</cfif>
	<!--- filter user folders --->
	<!--- Does not apply to SystemAdmin users --->
	<cfif not session.is_system_admin>
		AND
			(
			<cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(f.folder_of_user,<cfqueryparam cfsqltype="cf_sql_varchar" value="f">) <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			OR f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
			)
	</cfif>
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY folder_name
	</cfquery>
	<!--- dummy QoQ to get correct datatypes --->
	<cfquery dbtype="query" name="qRet">
	SELECT *
	FROM f_1
	WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
	AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
	</cfquery>
	<!--- Construct the Queries together --->
	<cfloop query="f_1">
		<!--- Invoke this function again --->
		<cfif Arguments.max_level_depth neq 1>
			<cfinvoke method="getTreeByCollection" returnvariable="qSub">
				<cfinvokeargument name="id" value="#f_1.folder_id#">
				<cfinvokeargument name="max_level_depth" value="#Val(Arguments.max_level_depth-1)#">
				<cfinvokeargument name="ColumnList" value="#Arguments.ColumnList#">
				<cfinvokeargument name="ignoreCollections" value="#Arguments.ignoreCollections#">
			</cfinvoke>
		</cfif>
		<!--- Put together the query --->
		<cfquery dbtype="query" name="qRet">
		SELECT *
		FROM qRet
		UNION ALL
		SELECT *
		FROM f_1
		WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#f_1.folder_id#">
		AND perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		<cfif Arguments.max_level_depth neq 1>
			UNION ALL
			SELECT *
			FROM qSub
			WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		</cfif>
		</cfquery>
	</cfloop>
	<cfreturn qRet>
</cffunction>

<!--- GET FOLDER RECORD --->
<cffunction name="getfolder" output="false" access="public" description="GET FOLDER RECORD" returntype="query">
	<cfargument name="folder_id" required="yes" type="string">
	<cfargument name="avoid_link_path" required="false" default="no" type="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery name="qLocal" datasource="#Variables.dsn#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfolder */ f.folder_id, f.folder_id_r, f.folder_name, f.folder_level, f.folder_of_user, f.folder_is_collection, f.folder_owner, folder_main_id_r rid, f.folder_shared, f.folder_name_shared, f.link_path, share_dl_org, share_dl_thumb, share_comments, share_upload, share_order, share_order_user, share_dl_thumb, in_search_selection, share_inherit
	FROM #session.hostdbprefix#folders f
	WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.folder_id#">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<cfif structKeyExists(arguments,'avoid_link_path') AND arguments.avoid_link_path EQ 'yes'>
		AND (f.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '/' OR f.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '\\' OR f.link_path IS NULL)
	</cfif>
	<!--- filter folder permissions, not neccessary for SysAdmin or Admin --->
	<cfif not session.is_system_admin and not session.is_administrator>
		AND (
			<!--- R/W/X permission by group --->
			EXISTS(
				SELECT fg.GRP_ID_R,fg.GRP_PERMISSION
				FROM #session.hostdbprefix#folders_groups fg
				WHERE fg.folder_id_r = f.folder_id
				AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				AND fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND (
					<cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2">
						NVL(fg.grp_id_r, 0)
					<cfelseif application.razuna.thedatabase EQ "h2">
						NVL(fg.grp_id_r, '0')
					<cfelseif application.razuna.thedatabase EQ "mysql">
						ifnull(fg.grp_id_r, 0)
					<cfelseif application.razuna.thedatabase EQ "mssql">
						isnull(fg.grp_id_r, 0)
					</cfif> = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
					OR
					<!--- user in group --->
					EXISTS(
						SELECT gu.ct_g_u_grp_id, gu.ct_g_u_user_id
						FROM ct_groups_users gu
						WHERE gu.ct_g_u_grp_id = fg.grp_id_r
						AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
					)
				)
			)
			OR
			<!--- no group restriction --->
			NOT EXISTS(
				SELECT fg.GRP_ID_R,fg.GRP_PERMISSION
				FROM #session.hostdbprefix#folders_groups fg
				<!--- user in group --->
				INNER JOIN ct_groups_users gu ON gu.ct_g_u_grp_id = fg.grp_id_r
				WHERE gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
				AND fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg.folder_id_r = f.folder_id
				AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
			)
		)
	</cfif>
	</cfquery>
	<cfreturn qLocal>
</cffunction>

<!--- GET FOLDER RECORD --->
<cffunction name="getfolderproperties" output="false" access="public" description="GET FOLDER RECORD" returntype="query">
	<cfargument name="folder_id" required="yes" type="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery name="qLocal" datasource="#Variables.dsn#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfolderproperties */ f.folder_id, f.folder_id_r, f.folder_name, f.folder_level, f.folder_of_user,
	f.folder_is_collection, f.folder_owner, folder_main_id_r rid, f.folder_shared, f.folder_name_shared,
	share_dl_org, share_dl_thumb, share_comments, share_upload, share_order, share_order_user
	FROM #session.hostdbprefix#folders f
	WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.folder_id#">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qLocal>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- GET THE DESCRIPTION FOR THIS FOLDER (WITH PARAGRAPHS) --->
<cffunction hint="GET THE DESCRIPTIONS FOR THIS FOLDER" name="getfolderdesc" output="false">
	<cfargument name="folder_id" required="yes" type="string">
	<cfset var qry = "">
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfolderdesc */ folder_desc, lang_id_r
	FROM #session.hostdbprefix#folders_desc
	WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- GET THE FOLDER NAMES --->
<cffunction name="getfoldernames" output="false">
	<cfargument name="folder_id" required="yes" type="string">
	<cfset var qry = "">
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfoldernames */ lang_id_r, folder_name
	FROM #session.hostdbprefix#folders_name
	WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- If record doesn't exists (for old one we return the default folder query) --->
	<cfif qry.recordcount EQ 0>
		<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getfoldernames */ '1' AS lang_id_r, folder_name
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfif>
	<cfreturn qry>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- GET THE GROUPS FOR THIS FOLDER --->
<cffunction hint="GET THE GROUPS FOR THIS FOLDER" name="getfoldergroups" output="false">
	<cfargument name="folder_id" default="" required="yes" type="string">
	<cfargument name="qrygroup" required="yes" type="query">
	<cfargument name="in_folder_group" required="no" type="string" default="no" hint="Include the folder permission of current folder_id">
	<!--- Set --->
	<cfset var thegroups = QueryNew("grp_id_r")>
	<cfset var listgroups="">
	<!--- Check the current folder permission included or not  --->
	<cfif structKeyExists(arguments,'in_folder_group') AND arguments.in_folder_group EQ 'yes'>
		<cfset listgroups = 0>
		<cfset listgroups = listappend(listgroups,'#ValueList(arguments.qrygroup.grp_id)#', ',')>
	<cfelse>
		<cfset listgroups = listappend(listgroups,'#ValueList(arguments.qrygroup.grp_id)#', ',')>
	</cfif>
	<!--- Query --->
	<cfif arguments.qrygroup.recordcount NEQ 0>
		<cfquery datasource="#variables.dsn#" name="thegroups" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getfoldergroups */ grp_id_r, grp_permission
		FROM #session.hostdbprefix#folders_groups
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND grp_id_r IN (
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#listgroups#" list="true">
						)
		</cfquery>
	</cfif>
	<cfreturn thegroups>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- GET THE GROUPS FOR THIS FOLDER ZERO --->
<cffunction hint="GET THE GROUPS FOR THIS FOLDER ZERO" name="getfoldergroupszero" output="false">
	<cfargument name="folder_id" default="" required="yes" type="string">
	<cfquery datasource="#variables.dsn#" name="thegroups" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfoldergroupszero */ grp_id_r, grp_permission
	FROM #session.hostdbprefix#folders_groups
	WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn thegroups>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- THE FOLDER LIST --->
<cffunction hint="The Folder Listing" name="folderlist" output="false" access="public" returntype="query">
	<cfargument name="folder_id" required="yes" type="string">
	<cfargument name="ignoreCollections" required="no" type="boolean" default="0">
	<cfargument name="onlyCollections" required="no" type="boolean" default="0">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<!--- call tree-function, 1 level deep, security restrictions are there --->
	<cfinvoke method="getTreeByCollection" returnvariable="qLocal">
		<cfinvokeargument name="id" value="#Arguments.folder_id#">
		<cfinvokeargument name="max_level_depth" value="1">
		<cfinvokeargument name="ignoreCollections" value="#Arguments.ignoreCollections#">
		<cfinvokeargument name="ColumnList" value="folder_id, folder_name, folder_id_r, folder_main_id_r, folder_level, folder_owner, folder_of_user, folder_is_vid_folder, folder_is_img_folder, folder_is_collection">
		<cfinvokeargument name="onlyCollections" value="#Arguments.onlyCollections#">
	</cfinvoke>
	<cfreturn qLocal />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- ADD A NEW FOLDER --->
<cffunction hint="Add a New Folder" name="add" output="true" returntype="string">
	<cfargument name="thestruct" type="struct">
	<cfargument name="thefolderparam" required="no" type="struct" default="#StructNew()#" hint="special argument only for call from CFC files.extractZip">
	<cfargument name="formStruct" required="no" type="struct" default="#Form#" hint="Form-struct, can be simulated.">
	<cfargument name="noTransaction" required="no" type="boolean" default="0" hint="Do not execute cftransaction. Reason: Nested cTransaction not allowed!">
	<!--- Params --->
	<cfparam default="" name="arguments.thestruct.coll_folder">
	<cfparam default="" name="arguments.thestruct.link_path">
	<!--- If level is empty make it a 2 --->
	<cfif arguments.thestruct.level EQ "">
		<cfset arguments.thestruct.level = 2>
	</cfif>
	<!--- If this is NOT a link to a folder --->
	<cfif arguments.thestruct.link_path EQ "">
		<cftry>
			<!--- Get the first lang at position 1 (it is always sorted) --->
			<cfset var _lang = ListGetat(arguments.thestruct.langcount, 1)>
			<!--- Check that field exists if so we need to put it into folder_name and save it all with the new translation --->
			<cfif structKeyExists(arguments.thestruct, "folder_name_#_lang#")>
				<cfset var _folder = "folder_name_#_lang#">
				<cfset arguments.thestruct.folder_name = arguments.thestruct[_folder]>
			</cfif>
			<!--- Increase folder level --->
			<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
			<!--- Check for the same name --->
			<cfquery datasource="#variables.dsn#" name="samefolder">
			SELECT folder_id
			FROM #session.hostdbprefix#folders
			WHERE folder_name = <cfqueryparam value="#arguments.thestruct.folder_name#" cfsqltype="cf_sql_varchar">
			AND folder_level = <cfqueryparam value="#arguments.thestruct.level#" cfsqltype="cf_sql_numeric">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif arguments.thestruct.rid NEQ 0>
				AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			</cfquery>
			<!--- If folder does not already exist --->
			<cfif samefolder.recordcount EQ 0>
				<!--- Add folder --->
				<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
				<!--- Trim folderid --->
				<cfset var newfolderid = trim(newfolderid)>
				<cfoutput>#newfolderid#</cfoutput>
				<!--- If we store on the file system we create the folder here --->
				<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
					<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
						<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
					</cfif>
					<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
						<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
					</cfif>
					<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
						<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
					</cfif>
					<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
						<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
					</cfif>
					<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
						<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
					</cfif>
				</cfif>
				<!--- Check on any plugin that call the on_folder_add action --->
				<cfset arguments.thestruct.folder_id = newfolderid>
				<cfinvoke component="plugins" method="getactions" theaction="on_folder_add" args="#arguments.thestruct#" />
				<!--- Set the Action2: Fill certain arguments (folder name, collection) with supporting argument if coming from CFC files --->
				<cfif StructIsEmpty(arguments.thefolderparam)>
					<cfset this.action2="done">
				<cfelse>
					<cfset this.action2="#newfolderid#">
				</cfif>
				<!--- Return --->
				<cfreturn this.action2>
			<!--- Same Folder exists --->
			<cfelse>
				<cfif StructIsEmpty(arguments.thefolderparam)>
					<cfset this.action2="exists">
				<cfelse>
					<cfset this.action2="#samefolder.folder_id#">
				</cfif>
				<cfreturn this.action2>
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function folders.add">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				<cfabort>
			</cfcatch>
		</cftry>
	<!--- This is a link --->
	<cfelse>
		<!--- Param --->
		<cfset arguments.thestruct.link_kind = "lan">
		<cfset arguments.thestruct.dsn = variables.dsn>
		<cfset arguments.thestruct.setid = variables.setid>
		<cfset arguments.thestruct.database = application.razuna.thedatabase>
		<!--- Increase folder level --->
		<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(arguments.thestruct.link_path,"/\")>
		<!--- Add the folder --->
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="fnew_detail" thestruct="#attributes.intstruct#" returnvariable="attributes.intstruct.newfolderid">
			<!--- <cfoutput>#trim(arguments.thestruct.newfolderid)#</cfoutput> --->
			<!--- If we store on the file system we create the folder here --->

			<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
				<cfif !directoryexists("#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#")>
						<cfdirectory action="create" directory="#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#" mode="775">
				</cfif>
				<cfif !directoryexists("#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/img")>
					<cfdirectory action="create" directory="#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/img" mode="775">
				</cfif>
				<cfif !directoryexists("#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/vid")>
					<cfdirectory action="create" directory="#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/vid" mode="775">
				</cfif>
				<cfif !directoryexists("#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/doc")>
					<cfdirectory action="create" directory="#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/doc" mode="775">
				</cfif>
				<cfif !directoryexists("#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/aud")>
					<cfdirectory action="create" directory="#attributes.intstruct.assetpath#/#session.hostid#/#attributes.intstruct.newfolderid#/aud" mode="775">
				</cfif>
			</cfif>
			<!--- Now add all assets of this folder --->
			<cfdirectory action="list" directory="#attributes.intstruct.link_path#" name="thefiles" type="file">
			<!--- Filter out hidden files --->
			<cfquery dbtype="query" name="thefiles">
			SELECT *
			FROM thefiles
			WHERE attributes != 'H'
			</cfquery>
			<!--- Param --->
			<cfset attributes.intstruct.folder_id = attributes.intstruct.newfolderid>
			<!--- Thread for adding files of this folder --->
			<!--- <cfthread intstruct="#arguments.thestruct#"> --->
				<!--- Loop over the assets --->
				<cfloop query="thefiles">
					<!--- Params --->
					<cfset attributes.intstruct.link_path_url = directory & "/" & name>
					<cfset attributes.intstruct.orgsize = size>
					<!--- Now add the asset --->
					<cfinvoke component="assets" method="addassetlink" thestruct="#attributes.intstruct#">
				</cfloop>
			<!--- </cfthread> --->
			<!--- Check if folder has subfolders if so add them recursively --->
			<cfdirectory action="list" directory="#attributes.intstruct.link_path#" name="thedir" type="dir">
			<!--- Filter out hidden dirs --->
			<cfquery dbtype="query" name="thesubdirs">
			SELECT *
			FROM thedir
			WHERE attributes != 'H'
			</cfquery>
			<!--- Call rec function --->
			<cfif thesubdirs.recordcount NEQ 0>
				<!--- Put folderid into struct --->
				<cfset attributes.intstruct.theid = attributes.intstruct.newfolderid>
				<!--- Call function --->
				<!--- <cfthread intstruct="#arguments.thestruct#"> --->
					<cfinvoke method="folder_link_rec" thestruct="#attributes.intstruct#">
				<!--- </cfthread> --->
			</cfif>
		</cfthread>
	</cfif>
</cffunction>

<!--- FOLDER LINK: Rec function to add folders --->
<cffunction name="folder_link_rec" output="true" access="private">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
					<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = directory & "/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
					<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath2 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid2 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel2 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = directory & "/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub2" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath2>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid2>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel2>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub2" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath3 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid3 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel3 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = "#arguments.thestruct.link_path#/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub3" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath3>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid3>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel3>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub3" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath4 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid4 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel4 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = "#arguments.thestruct.link_path#/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub4" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath4>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid4>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel4>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub4" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath5 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid5 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel5 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = "#arguments.thestruct.link_path#/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub5" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath5>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid5>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel5>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub5" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath6 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid6 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel6 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = "#arguments.thestruct.link_path#/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub6" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath6>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid6>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel6>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub6" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath7 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid7 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel7 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = "#arguments.thestruct.link_path#/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub7" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath7>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid7>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel7>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub7" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath8 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid8 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel8 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = "#arguments.thestruct.link_path#/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfinvoke method="folder_link_rec_sub8" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath8>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid8>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel8>
	</cfloop>
</cffunction>

<!--- FOLDER LINK: Rec function to add SUB folders --->
<cffunction name="folder_link_rec_sub8" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Loop over the qry and add the folders and files within --->
	<cfloop query="thesubdirs">
		<!--- Name of folder --->
		<cfset arguments.thestruct.folder_name = name>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc" mode="775">
			</cfif>
			<cfif !directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud")>
				<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud" mode="775">
			</cfif>
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset var subfolderpath = "#arguments.thestruct.link_path#/#name#">
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Params --->
			<cfset arguments.thestruct.link_path_url = directory & "/" & name>
			<cfset arguments.thestruct.orgsize = size>
			<cfset arguments.thestruct.folder_id = newfolderid>
			<!--- Now add the asset --->
			<cfinvoke component="assets" method="addassetlink" thestruct="#arguments.thestruct#">
		</cfloop>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedirsub" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirssub">
		SELECT *
		FROM thedirsub
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.linkpath9 = arguments.thestruct.link_path>
		<cfset arguments.thestruct.thisfolderid9 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel9 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif thesubdirssub.recordcount NEQ 0>
			<!--- Add the dirname to the link_path --->
			<cfset arguments.thestruct.link_path = "#arguments.thestruct.link_path#/#name#">
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<!--- <cfinvoke method="folder_link_rec_sub4" thestruct="#arguments.thestruct#"> --->
		</cfif>
		<cfset arguments.thestruct.link_path = arguments.thestruct.linkpath9>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid9>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel9>
	</cfloop>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- DETAIL OF ADD A NEW FOLDER --->
<cffunction name="fnew_detail" output="true" returntype="string" access="public">
	<cfargument name="thestruct" type="struct">
	<cfargument name="thefolderparam" required="no"  type="struct" default="#StructNew()#" hint="special argument only for call from CFC files.extractZip">
	<!--- Param --->
	<cfparam name="arguments.thestruct.coll_folder" default="f" />
	<cfparam name="arguments.thestruct.link_path" default="" />
	<cfparam name="arguments.thestruct.langcount" default="1" />
	<cfparam name="arguments.thestruct.folder_desc_1" default="" />
	<!--- Create a new ID --->
	<cfset var newfolderid = createuuid("")>
	<!--- Insert --->
	<cfquery datasource="#application.razuna.datasource#">
	INSERT INTO #session.hostdbprefix#folders
	(folder_id, folder_name, folder_level, folder_id_r, folder_main_id_r, folder_owner, folder_create_date, folder_change_date,
	folder_create_time, folder_change_time, link_path, host_id
	<cfif arguments.thestruct.coll_folder EQ "T">, folder_is_collection</cfif>)
	VALUES (
	<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
	<cfqueryparam value="#trim(arguments.thestruct.folder_name)#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam value="#arguments.thestruct.level#" cfsqltype="cf_sql_numeric">,
	<cfif arguments.thestruct.level IS NOT 1>
		<cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
	<cfelse>
		<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>,
	<cfif arguments.thestruct.rid NEQ 0>
		<cfqueryparam value="#arguments.thestruct.rid#" cfsqltype="CF_SQL_VARCHAR">
	<cfelse>
		<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>,
	<cfqueryparam value="#arguments.thestruct.userid#" cfsqltype="CF_SQL_VARCHAR">,
	<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
	<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
	<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
	<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
	<cfqueryparam value="#arguments.thestruct.link_path#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<cfif arguments.thestruct.coll_folder EQ "T">
		,<cfqueryparam value="T" cfsqltype="cf_sql_varchar">
	</cfif>
	)
	</cfquery>
	<!--- Insert the DESCRIPTION (only if not from CFC files.extractZip coming) --->
	<cfif StructIsEmpty(arguments.thefolderparam)>
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<!--- Foldername --->
			<cfif structkeyexists(arguments.thestruct, "folder_name_#langindex#")>
				<cfset var thisfolder="arguments.thestruct.folder_name_" & "#langindex#">
				<cfif thisfolder CONTAINS langindex AND evaluate(thisfolder) NEQ "">
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#folders_name
					(folder_id_r, lang_id_r, folder_name, host_id, rec_uuid)
					VALUES(
					<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#evaluate(thisfolder)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				</cfif>
			</cfif>
			<!--- Description --->
			<cfset var thisfield="arguments.thestruct.folder_desc_" & "#langindex#">
			<cfif thisfield CONTAINS langindex>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#folders_desc
				(folder_id_r, lang_id_r, folder_desc, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#evaluate(thisfield)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Insert the Group and Permission --->
	<cfloop collection="#arguments.thestruct#" item="myform">
		<cfif myform CONTAINS "grp_">
			<cfset var grpid = ReplaceNoCase(myform, "grp_", "")>
			<cfset var grpidno = Replace(grpid, "-", "", "all")>
			<cfset var theper = "per_" & "#grpidno#">
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#folders_groups
			(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#grpid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#evaluate(theper)#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Add sub folder to assign label upc based on the UPC upload  --->
	<cfif structKeyExists(arguments.thestruct,'theid') AND arguments.thestruct.theid NEQ ''>
		<!--- Check the current folder having label text as upc --->
		<cfinvoke component="labels" method="getlabels" theid="#arguments.thestruct.theid#" thetype="folder" checkUPC="true" returnvariable="arguments.thestruct.qry_labels">
		<cfif arguments.thestruct.qry_labels NEQ ''>
			<cfloop list="#arguments.thestruct.qry_labels#" index="idx" >
				<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO ct_labels
					(
						ct_label_id,
						ct_id_r,
						ct_type,
						rec_uuid
					)
					VALUES
					(
						<cfqueryparam value="#idx#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#newfolderid#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
				</cfquery>
			</cfloop>
		</cfif>
	</cfif>
	<!--- Apply custom setting to new folder --->
	<cfinvoke method="apply_custom_shared_setting" folder_id="#newfolderid#" />
	<!--- Log --->
	<cfinvoke component="defaults" method="trans" transid="added" returnvariable="added" />
	<cfset log_folders(theuserid=session.theuserid,logaction='Add',logdesc='#added#: #arguments.thestruct.folder_name# (ID: #newfolderid#)')>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("folders")>
	<!--- Return --->
	<cfreturn newfolderid />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- APPLY SHARED SETTINGS --->
<cffunction name="apply_custom_shared_setting" output="false" returntype="void">
	<cfargument name="folder_id" type="string">
	<!--- Param --->
	<cfset var s = structNew()>
	<cfset s.theid = arguments.folder_id>
	<cfset s.folder_shared = "F">
	<cfset s.share_dl_org = "F">
	<cfset s.share_dl_thumb = "F">
	<cfset s.share_comments = "F">
	<cfset s.share_upload = "F">

	<!--- Check parent folder settings and if share settings is set to inherit then get settings from parent folder else get settings from customization --->
	<cfquery datasource="#application.razuna.datasource#" name="getparentsharesettings">
	SELECT parf.folder_shared, parf.share_dl_thumb, parf.share_dl_org, parf.share_inherit, parf.share_comments, parf.share_upload, parf.share_order, parf.share_order_user
	FROM raz1_folders parf, raz1_folders subf
	WHERE subf.folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND subf.folder_level > '1'
	AND subf.folder_id_r = parf.folder_id
	AND subf.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Check if parent folder setting is set to inherit to subfolders --->
	<cfif getparentsharesettings.recordcount NEQ 0 AND getparentsharesettings.share_inherit EQ 't'>
		<cfset s.folder_shared = getparentsharesettings.folder_shared>
		<cfset s.share_dl_org= getparentsharesettings.share_dl_org>
		<cfset s.share_dl_thumb= getparentsharesettings.share_dl_thumb>
		<cfset s.share_inherit= getparentsharesettings.share_inherit>
		<cfset s.share_comments= getparentsharesettings.share_comments>
		<cfset s.share_upload= getparentsharesettings.share_upload>
		<cfset s.share_order= getparentsharesettings.share_order>
		<cfset s.share_order_user= getparentsharesettings.share_order_user>
	<cfelse><!--- Get custom settings --->
		<cfinvoke component="settings" method="get_customization" returnvariable="cs" />
		<!--- Set settings according to settings --->
		<cfif cs.share_folder>
			<cfset s.folder_shared = "T">
		</cfif>
		<cfif cs.share_download_thumb>
			<cfset s.share_dl_thumb = "T">
		</cfif>
		<cfif cs.share_download_original>
			<cfset s.share_dl_org = "T">
		</cfif>
		<cfif cs.share_comments>
			<cfset s.share_comments = "T">
		</cfif>
		<cfif cs.share_uploading>
			<cfset s.share_upload = "T">
		</cfif>
	</cfif>

	<!--- Call internal function to update shared settings --->
	<cfinvoke method="update_sharing" thestruct="#s#" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- REMOVE THIS FOLDER ALL SUBFOLDER AND FILES WITHIN --->
<cffunction name="remove" output="true">
	<cfargument name="thestruct" type="struct">
		<cfinvoke method="remove_folder_thread" thestruct="#arguments.thestruct#" />
		<!--- <cfset var tt = createuuid()>
		<cfthread name="#tt#" intstruct="#arguments.thestruct#">
			<cfinvoke method="remove_folder_thread" thestruct="#attributes.intstruct#" />
		</cfthread>
		<cfthread action="join" name="#tt#" /> --->
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- TRASH THIS FOLDER ALL SUBFOLDER AND FILES WITHIN --->
<cffunction name="trash" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- CFC --->
	<cfinvoke method="trash_folder_thread" thestruct="#arguments.thestruct#" returnvariable="parent_folder_id"/>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn parent_folder_id />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- THREAD : REMOVE THIS FOLDER ALL SUBFOLDER AND FILES WITHIN --->
<cffunction name="remove_folder_thread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- function internal vars --->
	<cfset var foldernames = 0>
	<cfset var parentid = 0>
	<cfset var folderids = 0>
	<!--- function body --->
	<cftry>
		<!--- Get the Folder Name for the Log --->
		<cfquery datasource="#application.razuna.datasource#" name="foldername">
		SELECT folder_name, folder_level
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Get the parent folder id so we redirect correctly --->
		<cfquery datasource="#application.razuna.datasource#" name="parentid">
		SELECT folder_id_r, folder_level
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- If on top folder level then reset referenced folder id --->
		<cfif parentid.folder_level EQ 1>
			<cfset parentid.folder_id_r = 0>
		</cfif>
		<cfif foldername.recordcount NEQ 0>
			<!--- Delete aliases --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM ct_aliases
			WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete main folder --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM	#session.hostdbprefix#folders
			WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Log --->
			<cfinvoke component="defaults" method="trans" transid="deleted" returnvariable="deleted" />
			<cfset log_folders(theuserid=session.theuserid,logaction='Delete',logdesc='#deleted#: #foldername.folder_name# (ID: #arguments.thestruct.folder_id#)')>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("folders")>
			<!--- The rest goes in a thread since it can run in the background --->
			<cfthread intstruct="#arguments.thestruct#" priority="low">
				<!--- Call to get the recursive folder ids --->
				<cfinvoke method="recfolder" returnvariable="folderids">
					<cfinvokeargument name="thelist" value="#attributes.intstruct.folder_id#">
				</cfinvoke>
				<!--- MSSQL: Drop all constraints --->
				<cfif application.razuna.thedatabase EQ "mssql">
					<!--- <cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #application.razuna.theschema#.#session.hostdbprefix#folders DROP CONSTRAINT
					</cfquery> --->
				<!--- MySQL --->
				<cfelseif application.razuna.thedatabase EQ "mysql">
					<cfquery datasource="#application.razuna.datasource#">
					SET foreign_key_checks = 0
					</cfquery>
				<!--- H2 --->
				<cfelseif application.razuna.thedatabase EQ "h2">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #session.hostdbprefix#folders SET REFERENTIAL_INTEGRITY false
					</cfquery>
				</cfif>
				<!--- Delete Subscribe --->
				<cfinvoke method="removesubscribefolder" folderid="#folderids#" />
				<!--- Delete labels --->
				<cfinvoke component="labels" method="label_ct_remove" id="#attributes.intstruct.folder_id#" />
				<!--- Delete files in this folder --->
				<cfinvoke method="deleteassetsinfolder" thefolderid="#attributes.intstruct.folder_id#" thestruct="#attributes.intstruct#" />
				<!--- Loop to remove folder --->
				<cfloop list="#folderids#" index="thefolderid" delimiters=",">
					<cfif thefolderid NEQ attributes.intstruct.folder_id>
						<!--- Set folderid into arguments struct for other methods --->
						<cfset attributes.intstruct.folder_id = thefolderid>
						<!--- Get the Folder Name for the Log --->
						<cfquery datasource="#application.razuna.datasource#" name="foldernamesub">
						SELECT folder_name
						FROM #session.hostdbprefix#folders
						WHERE folder_id = <cfqueryparam value="#thefolderid#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
						<!--- Log --->
						<cfinvoke component="defaults" method="trans" transid="deleted" returnvariable="deleted" />
						<cfinvoke component="extQueryCaching" method="log_folders" theuserid="#session.theuserid#" logaction="Delete" logdesc="#deleted#: #foldernamesub.folder_name# (ID: #thefolderid#)" />
						<!--- Delete folder in DB --->
						<cfquery datasource="#application.razuna.datasource#">
						DELETE FROM	#session.hostdbprefix#folders
						WHERE folder_id = <cfqueryparam value="#thefolderid#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
						<!--- Delete labels --->
						<cfinvoke component="labels" method="label_ct_remove" id="#thefolderid#" />
						<!--- Delete all files which have the same folder_id_r, meaning they have not been moved --->
						<cfinvoke method="deleteassetsinfolder" thefolderid="#thefolderid#" thestruct="#attributes.intstruct#" />
					</cfif>
				</cfloop>
			</cfthread>
		</cfif>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while removing folder - #cgi.http_host# in function folders.remove_folder_thread">
			<cfset cfcatch.thestruct = arguments.thestruct>
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn parentid.folder_id_r>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- THREAD : TRASH THIS FOLDER ALL SUBFOLDER AND FILES WITHIN --->
<cffunction name="trash_folder_thread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Var --->
	<cfset var get_folder = "" />
	<cfset var _folderids = "" />
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="get_folder">
	SELECT folder_level, folder_id_r
	FROM #session.hostdbprefix#folders
	WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Set the parent folder id --->
	<cfif get_folder.folder_level EQ 1>
		<cfset var parent_folder_id_r = 0>
	<cfelse>
		<cfset var parent_folder_id_r = get_folder.folder_id_r>
	</cfif>
	<!--- Call to get the recursive folder ids --->
	<cfinvoke method="recfolder" returnvariable="_folderids">
		<cfinvokeargument name="thelist" value="#arguments.thestruct.folder_id#">
	</cfinvoke>
	<!--- Set the in_trash for folders --->
	<cfset _updateFolderInTrash(folder_ids=_folderids)>
	<!--- Get all files in the folders --->
	<cfset var _qry_files = _getFilesInFolder(folder_ids=_folderids)>
	<!--- Set the in_trash for files --->
	<cfset _updateFilesInTrash(qry_files=_qry_files, in_trash='T', is_indexed='1')>
	<!--- Return --->
	<cfreturn parent_folder_id_r />
</cffunction>

<!--- Set in_trash for files --->
<cffunction name="_updateFilesInTrash" access="remote" output="false">
	<cfargument name="qry_files" required="yes" type="query">
	<cfargument name="in_trash" required="yes" type="string">
	<cfargument name="is_indexed" required="yes" type="string">
	<!--- Loop over files list and update --->
	<cfloop query="arguments.qry_files">
		<cfif type EQ "img">
			<cfset var _db = "images">
			<cfset var _id = "img_id">
		<cfelseif type EQ "vid">
			<cfset var _db = "videos" />
			<cfset var _id = "vid_id" />
		<cfelseif type EQ "aud">
			<cfset var _db = "audios" />
			<cfset var _id = "aud_id" />
		<cfelseif type EQ "doc">
			<cfset var _db = "files" />
			<cfset var _id = "file_id" />
		</cfif>
		<!--- Update record --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix##_db#
		SET
		in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.in_trash#">,
		is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.is_indexed#">
		WHERE #_id# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
		</cfquery>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("search")>
</cffunction>

<!--- Update folders with in_trash --->
<cffunction name="_updateFolderInTrash" access="remote" output="false">
	<cfargument name="folder_ids" required="yes" type="string">
	<!--- Loop --->
	<cfloop list="#arguments.folder_ids#" index="f">
		<!--- Update the in_trash --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#folders
		SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
		WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#f#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfloop>
</cffunction>

<!--- Get foldername --->
<cffunction name="_getFilesInFolder" access="remote" output="false" returntype="Query">
	<cfargument name="folder_ids" required="yes" type="string">
	<!--- Param --->
	<cfset var qry = "">
	<!--- Query --->
	<cfquery name="qry" datasource="#application.razuna.datasource#">
	SELECT img_id AS ID, 'img' as type
	FROM #session.hostdbprefix#images
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_ids#" list="true">)
	UNION ALL
	SELECT vid_id AS ID, 'vid' as type
	FROM #session.hostdbprefix#videos
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_ids#" list="true">)
	UNION ALL
	SELECT aud_id AS ID, 'aud' as type
	FROM #session.hostdbprefix#audios
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_ids#" list="true">)
	UNION ALL
	SELECT file_id AS ID, 'doc' as type
	FROM #session.hostdbprefix#files
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_ids#" list="true">)
	</cfquery>
	<!--- Return --->
	<cfreturn qry />
</cffunction>

<!--- Get All Folder Trash --->
<cffunction name="gettrashfolder" output="false" returntype="Query">
	<cfargument name="noread" required="false" default="false">
	<!--- Param --->
	<cfset var folderIDs = "">
	<cfset var qry = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#gettrashfolder */
	f.folder_id AS id,
	f.folder_name AS filename,
	f.folder_id_r,
	f.folder_level,
	'' AS ext,
	'' AS filename_org,
	'folder' AS kind,
	'' AS link_kind,
	'' AS path_to_asset,
	'' AS cloud_url,
	'' AS cloud_url_org,
	'' AS hashtag,
	'false' AS in_collection,
	'folder' as what,
	f.folder_main_id_r
	<!--- Permfolder --->
	<cfif session.is_system_admin OR session.is_administrator>
		, 'X' as permfolder
	<cfelse>
		,
		CASE
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X'
			WHEN (f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">) THEN 'X'
		END as permfolder
	</cfif>
	FROM #session.hostdbprefix#folders f
	WHERE f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND (f.folder_is_collection IS NULL OR f.folder_is_collection = '')
	</cfquery>
	<!--- Add "in_collection" Column --->
	<cfif qry.RecordCount NEQ 0>
		<cfset var myArray = arrayNew( 1 )>
		<cfset var temp= ArraySet(myArray, 1, qry.RecordCount, "False")>
		<cfloop query="qry">
			<!--- Get All Sub Folder IDs Of Current Folder  --->
			<cfquery name="getColfolderIDs" datasource="#application.razuna.datasource#" >
			SELECT folder_id from #session.hostdbprefix#folders
			WHERE folder_level >= (
				SELECT
				folder_level
				FROM #session.hostdbprefix#folders
				WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">)
			AND folder_main_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#folder_main_id_r#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<cfset folderIDs = ValueList(getColfolderIDs.folder_id)>
			<cfif !listlen(folderIDs) AND folderIDs NEQ "">
				<cfinvoke method="getAssetsDetails" folder_id="#folderIDs#" returnvariable="flag">
				<!--- Update The "in_collection" Field With The Flag Returned From getAssetsDetails --->
				<cfif flag.recordcount NEQ 0>
					<cfset temp = QuerySetCell(qry, "in_collection", flag, currentRow  )>
				</cfif>
			</cfif>
		</cfloop>
		<cfquery name="qry" dbtype="query">
			SELECT *
			FROM qry
			WHERE permfolder != <cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">
			<cfif noread>
				AND permfolder != <cfqueryparam value="r" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
		</cfquery>
	</cfif>
	<cfreturn qry>
</cffunction>

<!--- Combine Trash queries --->
<cffunction name="gettrashcombined" output="false" returntype="query">
	<cfargument name="qry_images" type="Query">
	<cfargument name="qry_videos" type="Query">
	<cfargument name="qry_files" type="Query">
	<cfargument name="qry_audios" type="Query">
	<!--- Param --->
	<cfset var qry = "">
	<!--- Query together --->
	<cfquery dbtype="query" name="qry">
	SELECT *
	FROM arguments.qry_images
	UNION ALL
	SELECT *
	FROM arguments.qry_videos
	UNION ALL
	SELECT *
	FROM arguments.qry_audios
	UNION ALL
	SELECT *
	FROM arguments.qry_files
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Remove all files and folders when we empty trash --->
<cffunction name="trash_remove_all" output="false" returntype="void">
	<cfargument name="qry_all" type="Query">
	<cfargument name="thestruct" type="struct">
	<!--- Thread --->
	<cfthread instruct="#arguments#">
		<!--- Loop over the query --->
		<cfloop query="attributes.instruct.qry_all">
			<!--- Check that users has NOT only read access --->
			<cfif permfolder NEQ "R">
				<!--- IMAGES --->
				<cfif kind EQ "img">
					<!--- Change db to have another in_trash flag --->
					<!--- <cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#images
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery> --->
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="images" method="removeimage" thestruct="#attributes.instruct.thestruct#" />
				<!--- VIDEOS --->
				<cfelseif kind EQ "vid">
					<!--- Change db to have another in_trash flag --->
					<!--- <cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#videos
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery> --->
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="videos" method="removevideo" thestruct="#attributes.instruct.thestruct#" />
				<!--- FILES --->
				<cfelseif kind EQ "doc">
					<!--- Change db to have another in_trash flag --->
					<!--- <cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery> --->
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="files" method="removefile" thestruct="#attributes.instruct.thestruct#" />
				<!--- AUDIOS --->
				<cfelseif kind EQ "aud">
					<!--- Change db to have another in_trash flag --->
					<!--- <cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#audios
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery> --->
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="audios" method="removeaudio" thestruct="#attributes.instruct.thestruct#" />
				</cfif>
			</cfif>
		</cfloop>
	</cfthread>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("search")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Remove all folders in trash --->
<cffunction name="trash_remove_folder" output="false">
	<cfargument name="qry_all" type="Query">
	<cfargument name="thestruct" type="struct">
	<!--- Thread --->
	<cfthread instruct="#arguments#">
		<!--- Loop over the query --->
		<cfloop query="attributes.instruct.qry_all">
			<!--- Check that users has NOT only read access --->
			<cfif permfolder NEQ "R">
				<!--- Change db to have another in_trash flag --->
				<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#folders
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Flush cache --->
				<cfset attributes.instruct.thestruct.folder_id = id>
				<!--- Call remove function --->
				<cfinvoke method="remove" thestruct="#attributes.instruct.thestruct#" />
			</cfif>
		</cfloop>
	</cfthread>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Restore all assets in trash --->
<cffunction name="trash_restore_all" output="false">
	<cfargument name="qry_all" type="Query">
	<cfargument name="thestruct" type="struct">
		<!--- Loop over the query --->
		<cfloop query="arguments.qry_all">
			<cfif kind EQ "img">
				<!--- Update the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif kind EQ "aud">
				<!--- Update the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif kind EQ "vid">
				<!--- Update the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#videos
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif kind EQ "doc">
				<!--- Update the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("search")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- store trash files ids in session --->
<cffunction name="trash_file_values" output="false">
	<!--- set ids --->
	<cfset var ids = "">
	<!--- trash images --->
	<cfinvoke component="images" method="gettrashimage" returnvariable="imagetrash" noread="true" />
	<cfset var imageid = valueList(imagetrash.id)>
	<cfloop list="#imageid#" index="i">
		<!--- set ids --->
		<cfset var ids = listAppend(ids,"#i#-img")>
	</cfloop>
	<!--- trash audios --->
	<cfinvoke component="audios" method="gettrashaudio" returnvariable="audiotrash"  noread="true" />
	<cfset var audioid = valueList(audiotrash.id)>
	<cfloop list="#audioid#" index="i">
		<!--- set ids --->
		<cfset var ids = listAppend(ids,"#i#-aud")>
	</cfloop>
	<!--- trash files --->
	<cfinvoke component="files" method="gettrashfile" returnvariable="filetrash"  noread="true" />
	<cfset var fileid = valueList(filetrash.id)>
	<cfloop list="#fileid#" index="i">
		<!--- set ids --->
		<cfset var ids = listAppend(ids,"#i#-doc")>
	</cfloop>
	<!--- trash videos --->
	<cfinvoke component="videos" method="gettrashvideos" returnvariable="videotrash"  noread="true" />
	<cfset var videoid = valueList(videotrash.id)>
	<cfloop list="#videoid#" index="i">
		<!--- set ids --->
		<cfset var ids = listAppend(ids,"#i#-vid")>
	</cfloop>
	<!--- Set the sessions --->
	<cfset session.file_id = ids>
	<cfset session.thefileid = ids>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("search")>
	<cfset resetcachetoken("labels")>
	<cfreturn />
</cffunction>

<!--- Restore selected files in the trash --->
<cffunction name="restoreselectedfiles" output="false">
	<cfargument name="thestruct" type="struct">
	<cfloop list="#arguments.thestruct.id#" index="i" delimiters=",">
		<!--- get images --->
		<cfif i CONTAINS "-img">
			<!--- set image id --->
			<cfset var imageid = listFirst(i,'-')>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images
			SET
			folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
			in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imageid#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif i CONTAINS "-aud">
			<!--- set audio id --->
			<cfset var audioid = listFirst(i,'-')>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#audios
			SET
			folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
			in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#audioid#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif i CONTAINS "-vid">
			<!--- set video id --->
			<cfset var videoid = listFirst(i,'-')>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#videos
			SET
			folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
			in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#videoid#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelseif i CONTAINS "-doc">
			<!--- set file id --->
			<cfset var fileid = listFirst(i,'-')>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#files
			SET
			folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
			in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("search")>
	<cfset resetcachetoken("labels")>
	<cfreturn />
</cffunction>

<!--- Remove selected files in trash --->
<cffunction name="trashfiles_remove" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset arguments.thestruct.ids = arguments.thestruct.id>
	<cfthread instruct="#arguments.thestruct#" priority="high">
		<cfloop list="#attributes.instruct.ids#" index="i" delimiters=",">
			<!--- get images --->
			<cfif i CONTAINS "-img">
				<!--- set image id --->
				<cfset attributes.instruct.id = listFirst(i,'-')>
				<cfinvoke component="images" method="removeimage"  thestruct="#attributes.instruct#" />
			<cfelseif i CONTAINS "-aud">
				<!--- set audio id --->
				<cfset attributes.instruct.id = listFirst(i,'-')>
				<cfinvoke component="audios" method="removeaudio" thestruct="#attributes.instruct#" />
			<cfelseif i CONTAINS "-vid">
				<!--- set video id --->
				<cfset attributes.instruct.id = listFirst(i,'-')>
				<cfinvoke component="videos" method="removevideo" thestruct="#attributes.instruct#" />
			<cfelseif i CONTAINS "-doc">
				<!--- set file id --->
				<cfset attributes.instruct.id = listFirst(i,'-')>
				<cfinvoke component="files" method="removefile" thestruct="#attributes.instruct#" />
			</cfif>
		</cfloop>
	</cfthread>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("search")>
	<cfset resetcachetoken("labels")>
	<cfreturn />
</cffunction>

<!--- store trash folder ids in session --->
<cffunction name="trash_folder_values" output="false">
	<!--- set ids --->
	<cfset var ids = "">
	<!--- Get folders ids in the trash --->
	<cfinvoke component="folders" method="gettrashfolder" returnvariable="qry_trash" noread="true"/>
	<!--- set folder id --->
	<cfset var filderid = valueList(qry_trash.id)>
	<cfloop list="#filderid#" index="i">
		<cfset var ids = listAppend(ids,"#i#-folder")>
	</cfloop>
	<!--- Set the sessions --->
	<cfset session.file_id = ids>
	<cfset session.thefileid = ids>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
	<cfreturn />
</cffunction>

<!--- Restore selected folders in the trash --->
<cffunction name="restoreselectedfolders" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Get the details --->
	<cfquery datasource="#application.razuna.datasource#" name="thenewrootid">
		SELECT folder_id_r,folder_main_id_r,folder_level,folder_name FROM #session.hostdbprefix#folders
       WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.intofolderid#">
	</cfquery>
	<!--- Loop over the query --->
	<cfloop list="#arguments.thestruct.id#" index="i">
		<!--- set folder id --->
		<cfset var id = listFirst(i,'-')>
		<!--- Get the Folder Name/Folder Level for the Log --->
		<cfquery datasource="#variables.dsn#" name="foldername">
		SELECT folder_name, folder_level
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Call the compontent above to get the recursive folder ids --->
		<cfinvoke method="recfolder" returnvariable="folderids">
			<cfinvokeargument name="thelist" value="#id#">
			<cfinvokeargument name="thelevel" value="#foldername.folder_level#">
		</cfinvoke>
		<!--- Take the results from the compontent call above and add the root folder id --->
		<cfset var folderids="#folderids#">
		<!--- Change the folder_id_r of the folder we want to move --->
		<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_id_r = <cfif arguments.thestruct.intofolderid EQ 0><cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
			folder_main_id_r = <cfif arguments.thestruct.intofolderid EQ 0><cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
			in_trash = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">
			WHERE folder_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Now loop trough the folderids and change the folder_main_id_r and the folder_level --->
		<cfloop list="#folderids#" index="thenr" delimiters=",">
			<!--- check the folder level --->
			<cfif  arguments.thestruct.intofolderid  NEQ 0>
				<cfset arguments.thestruct.intolevel = arguments.thestruct.intolevel + 1>
			</cfif>
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_main_id_r = <cfif #arguments.thestruct.intofolderid# EQ 0><cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
			folder_level = <cfqueryparam value="#arguments.thestruct.intolevel#" cfsqltype="cf_sql_numeric"><!--- folder_level + #arguments.thestruct.difflevel# --->
			WHERE folder_id = <cfqueryparam value="#thenr#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Remove selected folders in trash --->
<cffunction name="trashfolders_remove" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Loop over the query --->
	<cfloop list="#arguments.thestruct.id#" index="i">
		<!--- set folder id --->
		<cfset var id = listFirst(i,'-')>
		<cfset arguments.thestruct.folder_id = id>
		<!--- Call remove function --->
		<cfinvoke method="remove" thestruct="#arguments.thestruct#" />
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Restore all folders in trash --->
<cffunction name="trash_restore_folders" output="false">
	<cfargument name="qry_all" type="Query">
	<cfargument name="thestruct" type="struct">
	<!--- Get the details --->
	<cfquery datasource="#application.razuna.datasource#" name="thenewrootid">
		SELECT folder_id_r,folder_main_id_r,folder_level,folder_name FROM #session.hostdbprefix#folders
       	WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.intofolderid#">
	</cfquery>
	<!--- Loop over the query --->
	<cfloop query="arguments.qry_all">
		<!--- Get the Folder Name/Folder Level for the Log --->
		<cfquery datasource="#variables.dsn#" name="foldername">
		SELECT folder_name, folder_level
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Call the compontent above to get the recursive folder ids --->
		<cfinvoke method="recfolder" returnvariable="folderids">
			<cfinvokeargument name="thelist" value="#id#">
			<cfinvokeargument name="thelevel" value="#foldername.folder_level#">
		</cfinvoke>
		<!--- Take the results from the compontent call above and add the root folder id --->
		<cfset var folderids="#folderids#">
		<!--- Change the folder_id_r of the folder we want to move --->
		<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_id_r = <cfif arguments.thestruct.intofolderid EQ 0><cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
			folder_main_id_r = <cfif arguments.thestruct.intofolderid EQ 0><cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
			in_trash = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">
			WHERE folder_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Now loop trough the folderids and change the folder_main_id_r and the folder_level --->
		<cfloop list="#folderids#" index="thenr" delimiters=",">
			<cfif arguments.thestruct.intofolderid NEQ 0>
				<cfset arguments.thestruct.intolevel = arguments.thestruct.intolevel + 1>
			</cfif>
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_main_id_r = <cfif #arguments.thestruct.intolevel# EQ 1><cfqueryparam value="#thenr#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
			folder_level = <cfqueryparam value="#arguments.thestruct.intolevel#" cfsqltype="cf_sql_numeric"><!--- folder_level + #arguments.thestruct.difflevel# --->
			WHERE folder_id = <cfqueryparam value="#thenr#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Restore the folder --->
<cffunction name="restorefolder" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- get the details --->
	<cfquery datasource="#application.razuna.datasource#" name="thenewrootid">
	SELECT folder_id_r,folder_main_id_r,folder_level FROM #session.hostdbprefix#folders
	WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.intofolderid#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Get the Folder Name/Folder Level for the Log --->
	<cfquery datasource="#variables.dsn#" name="foldername">
	SELECT folder_name, folder_level
	FROM #session.hostdbprefix#folders
	WHERE folder_id = <cfqueryparam value="#arguments.thestruct.tomovefolderid#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Call the compontent above to get the recursive folder ids --->
	<cfinvoke method="recfolder" returnvariable="folderids">
		<cfinvokeargument name="thelist" value="#arguments.thestruct.tomovefolderid#">
		<cfinvokeargument name="thelevel" value="#foldername.folder_level#">
	</cfinvoke>
	<!--- Take the results from the compontent call above and add the root folder id --->
	<cfset var folderids="#folderids#">
	<!--- Change the folder_id_r of the folder we want to move --->
	<cfquery datasource="#variables.dsn#">
	UPDATE #session.hostdbprefix#folders
	SET
	folder_id_r = <cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR">,
	folder_main_id_r = <cfif #arguments.thestruct.intolevel# EQ 1><cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
	in_trash = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">
	WHERE folder_id = <cfqueryparam value="#arguments.thestruct.tomovefolderid#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Now loop trough the folderids and change the folder_main_id_r and the folder_level --->
	<cfloop list="#folderids#" index="thenr" delimiters=",">
		<cfif arguments.thestruct.intofolderid NEQ arguments.thestruct.tomovefolderid>
			<cfset arguments.thestruct.intolevel = arguments.thestruct.intolevel + 1>
		</cfif>
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#folders
		SET folder_main_id_r = <cfif #arguments.thestruct.intolevel# EQ 1><cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
		folder_level = <cfqueryparam value="#arguments.thestruct.intolevel#" cfsqltype="cf_sql_numeric"><!--- folder_level + #arguments.thestruct.difflevel# --->
		WHERE folder_id = <cfqueryparam value="#thenr#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfloop>
	<!--- Get all files in the folders --->
	<cfset var _qry_files = _getFilesInFolder(folder_ids=folderids)>
	<!--- Set the in_trash for files --->
	<cfset _updateFilesInTrash(qry_files=_qry_files, in_trash='F', is_indexed='0')>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Delete files from folder removal --->
<cffunction name="deleteassetsinfolder" output="false">
	<cfargument name="thefolderid" type="string" />
	<cfargument name="thestruct" type="struct">
	<!--- Set sessions into struct since we need them in the remove many cfc --->
	<cfset arguments.thestruct.hostdbprefix = session.hostdbprefix>
	<cfset arguments.thestruct.hostid = session.hostid>
	<cfset arguments.thestruct.theuserid = session.theuserid>
	<cfset arguments.thestruct.fromfolderremove = true>
	<!--- Images --->
	<cfquery datasource="#application.razuna.datasource#" name="qryimg">
	Select img_id
	FROM #session.hostdbprefix#images
	WHERE folder_id_r = <cfqueryparam value="#arguments.thefolderid#" cfsqltype="CF_SQL_VARCHAR">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif qryimg.recordcount NEQ 0>
		<cfset arguments.thestruct.id = valuelist(qryimg.img_id)>
		<cfinvoke component="images" method="removeimagemany" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Videos --->
	<cfquery datasource="#application.razuna.datasource#" name="qryvid">
	Select vid_id
	FROM #session.hostdbprefix#videos
	WHERE folder_id_r = <cfqueryparam value="#arguments.thefolderid#" cfsqltype="CF_SQL_VARCHAR">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif qryvid.recordcount NEQ 0>
		<cfset arguments.thestruct.id = valuelist(qryvid.vid_id)>
		<cfinvoke component="videos" method="removevideomany" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Audios --->
	<cfquery datasource="#application.razuna.datasource#" name="qryaud">
	Select aud_id
	FROM #session.hostdbprefix#audios
	WHERE folder_id_r = <cfqueryparam value="#arguments.thefolderid#" cfsqltype="CF_SQL_VARCHAR">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif qryaud.recordcount NEQ 0>
		<cfset arguments.thestruct.id = valuelist(qryaud.aud_id)>
		<cfinvoke component="audios" method="removeaudiomany" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Docs --->
	<cfquery datasource="#application.razuna.datasource#" name="qrydoc">
	Select file_id
	FROM #session.hostdbprefix#files
	WHERE folder_id_r = <cfqueryparam value="#arguments.thefolderid#" cfsqltype="CF_SQL_VARCHAR">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif qrydoc.recordcount NEQ 0>
		<cfset arguments.thestruct.id = valuelist(qrydoc.file_id)>
		<cfinvoke component="files" method="removefilemany" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Collections --->
	<cfquery datasource="#application.razuna.datasource#" name="qrycol">
	Select col_id
	FROM #session.hostdbprefix#collections
	WHERE folder_id_r = <cfqueryparam value="#arguments.thefolderid#" cfsqltype="CF_SQL_VARCHAR">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfif qrycol.recordcount NEQ 0>
		<cfloop query="qrycol">
			<cfset arguments.thestruct.id = col_id>
			<cfinvoke component="collections" method="remove" thestruct="#arguments.thestruct#" />
		</cfloop>

	</cfif>
	<!--- Now check in all asset dbs again for the same folder. If we have no record anymore, remove the folder from the file system --->
	<cfquery datasource="#application.razuna.datasource#" name="qryfolder">
	SELECT img_id as id
	FROM #session.hostdbprefix#images
	WHERE path_to_asset LIKE '#arguments.thefolderid#%'
	UNION ALL
	SELECT aud_id as id
	FROM #session.hostdbprefix#audios
	WHERE path_to_asset LIKE '#arguments.thefolderid#%'
	UNION ALL
	SELECT file_id as id
	FROM #session.hostdbprefix#files
	WHERE path_to_asset LIKE '#arguments.thefolderid#%'
	UNION ALL
	SELECT vid_id as id
	FROM #session.hostdbprefix#videos
	WHERE path_to_asset LIKE '#arguments.thefolderid#%'
	</cfquery>
	<!--- If no asset is found which has this folder id in its path then it is safe to remove the folder --->
	<cfif qryfolder.recordcount EQ 0>
		<!--- Delete Folder --->
		<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
			<cfif isdefined("arguments.thestruct.assetpath") AND directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thefolderid#")>
				<cfdirectory action="delete" directory="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thefolderid#" recurse="true">
			</cfif>
		<cfelseif application.razuna.storage EQ "nirvanix">
			<cfinvoke component="nirvanix" method="DeleteFolders" nvxsession="#arguments.thestruct.nvxsession#" folderpath="/#arguments.thefolderid#">
		<cfelseif application.razuna.storage EQ "amazon">
			<cfinvoke component="amazon" method="deletefolder" folderpath="#arguments.thefolderid#" awsbucket="#arguments.thestruct.awsbucket#" />
		</cfif>
		<!--- Execute plugins --->
		<cfset arguments.thestruct.folder_id = arguments.thefolderid>
		<cfset arguments.thestruct.folder_action = false>
		<cfinvoke component="plugins" method="getactions" theaction="on_folder_remove" args="#arguments.thestruct#" />
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("search")>
	<cfset resetcachetoken("labels")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- SAVE SHARING PROPERTIES --->
<cffunction name="update_sharing" output="true" returntype="string">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="arguments.thestruct.folder_shared" default="F">
	<cfparam name="arguments.thestruct.folder_name_shared" default="#arguments.thestruct.theid#">
	<cfparam name="arguments.thestruct.share_order" default="F">
	<cfparam name="arguments.thestruct.share_order_user" default="0">
	<cfparam name="arguments.thestruct.share_inherit" default="f">
	<!--- Update Folders DB --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#folders
	SET
	folder_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
	folder_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
	folder_shared = <cfqueryparam value="#arguments.thestruct.folder_shared#" cfsqltype="cf_sql_varchar">,
	folder_name_shared = <cfqueryparam value="#arguments.thestruct.folder_name_shared#" cfsqltype="cf_sql_varchar">,
	share_dl_org = <cfqueryparam value="#arguments.thestruct.share_dl_org#" cfsqltype="cf_sql_varchar">,
	share_dl_thumb = <cfqueryparam value="#arguments.thestruct.share_dl_thumb#" cfsqltype="cf_sql_varchar">,
	share_upload = <cfqueryparam value="#arguments.thestruct.share_upload#" cfsqltype="cf_sql_varchar">,
	share_comments = <cfqueryparam value="#arguments.thestruct.share_comments#" cfsqltype="cf_sql_varchar">,
	share_order = <cfqueryparam value="#arguments.thestruct.share_order#" cfsqltype="cf_sql_varchar">,
	share_order_user = <cfqueryparam value="#arguments.thestruct.share_order_user#" cfsqltype="CF_SQL_VARCHAR">,
	share_inherit = <cfqueryparam value="#arguments.thestruct.share_inherit#" cfsqltype="CF_SQL_VARCHAR">
	WHERE folder_id = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("folders")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("images")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- SAVE FOLDER PROPERTIES --->
<cffunction name="update" output="true" returntype="string">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset arguments.thestruct.grpno = "T">
	<cfparam name="arguments.thestruct.in_search_selection" default="false" />
	<!--- Get the first lang at position 1 (it is always sorted) --->
	<cfset var _lang = ListGetat(arguments.thestruct.langcount, 1)>
	<!--- Put first folder name into folder_name (we wrap this is a try catch as when we come from private folder we only have folder_name) --->
	<cftry>
		<cfset var _folder = "folder_name_#_lang#">
		<cfset arguments.thestruct.folder_name = arguments.thestruct[_folder]>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!--- Check for the same name --->
	<cfquery datasource="#variables.dsn#" name="samefolder">
	SELECT folder_name
	FROM #session.hostdbprefix#folders
	WHERE folder_name = <cfqueryparam value="#arguments.thestruct.folder_name#" cfsqltype="cf_sql_varchar">
	AND folder_level = <cfqueryparam value="#arguments.thestruct.level#" cfsqltype="cf_sql_numeric">
	AND folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND folder_of_user <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- If there is not a record with the same name continue --->
	<cfif #samefolder.recordcount# EQ 0>
		<!--- Get Folder Name for the Log
		<cfquery datasource="#variables.dsn#" name="thisfolder">
			SELECT folder_name
			FROM #session.hostdbprefix#folders
			WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="cf_sql_numeric">
		</cfquery> --->
		<!--- Update Folders DB --->
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#folders
		SET
		folder_name = <cfqueryparam value="#trim(arguments.thestruct.folder_name)#" cfsqltype="cf_sql_varchar">,
		in_search_selection = <cfqueryparam value="#arguments.thestruct.in_search_selection#" cfsqltype="cf_sql_varchar">
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Update the Desc --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<!--- Folder --->
			<cfset var thisfolder = "arguments.thestruct.folder_name_" & "#langindex#">
			<cfif thisfolder CONTAINS langindex AND evaluate(thisfolder) NEQ "">
				<!--- Check if description in this language exists --->
				<cfquery datasource="#variables.dsn#" name="langFolder">
				SELECT folder_id_r
				FROM #session.hostdbprefix#folders_name
				WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
				AND lang_id_r = <cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Update existing or insert new description --->
				<cfif langFolder.recordCount GT 0>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#folders_name
					SET folder_name = <cfqueryparam value="#evaluate(thisfolder)#" cfsqltype="cf_sql_varchar">
					WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
					AND lang_id_r = <cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				<cfelse>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#folders_name
					(folder_id_r, lang_id_r, folder_name, host_id, rec_uuid)
					VALUES (
					<cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#evaluate(thisfolder)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				</cfif>
			</cfif>
			<!--- Description --->
			<cfset var thisfield="arguments.thestruct.folder_desc_" & "#langindex#">
			<cfif thisfield CONTAINS langindex>
				<!--- Check if description in this language exists --->
				<cfquery datasource="#variables.dsn#" name="langDesc">
				SELECT folder_id_r
				FROM #session.hostdbprefix#folders_desc
				WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
				AND lang_id_r = <cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Update existing or insert new description --->
				<cfif langDesc.recordCount GT 0>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#folders_desc
					SET folder_desc = <cfqueryparam value="#evaluate(thisfield)#" cfsqltype="cf_sql_varchar">
					WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
					AND lang_id_r = <cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				<cfelse>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#folders_desc
					(folder_id_r, lang_id_r, folder_desc, host_id, rec_uuid)
					VALUES (
					<cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#evaluate(thisfield)#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Update the Groups --->
		<!--- First delete all the groups --->
		<cfquery datasource="#variables.dsn#">
		DELETE FROM #session.hostdbprefix#folders_groups
		WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Now add the new groups --->
		<cfloop delimiters="," index="myform" list="#arguments.thestruct.fieldnames#">
			<cfif myform CONTAINS "grp_">
				<cfset arguments.thestruct.grpno = "F">
				<cfset var grpid = ReplaceNoCase(#myform#, "grp_", "", "one")>
				<cfset var grpidno = Replace(grpid, "-", "", "all")>
				<cfset var theper = "per_" & "#grpidno#">
				<cfquery datasource="#variables.dsn#">
				INSERT INTO #session.hostdbprefix#folders_groups
				(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#grpid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfif evaluate(theper) EQ "">
					 <cfqueryparam value="R" cfsqltype="cf_sql_varchar">,
				<cfelse>
					<cfqueryparam value="#evaluate(theper)#" cfsqltype="cf_sql_varchar">,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- Set user folder to f --->
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#folders
				SET folder_of_user = <cfqueryparam value="f" cfsqltype="cf_sql_varchar">
				WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Check group 'folder_subscribe' setting and add users in group to receive folder notifications if set to true --->
				<cfinvoke component="global.cfc.groups" method="add_grp_users2notify" group_id='#grpid#'>
			</cfif>
		</cfloop>
		<!--- If the user want this folder to himself then we set appropriate --->
		<cfif arguments.thestruct.grpno EQ "T">
			<!--- Set user folder to T --->
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_of_user = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
			WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- If the User wants to inherit this group/permission to subfolders then --->
		<cfif structkeyexists(arguments.thestruct,"perm_inherit")>
			<!--- Get the subfolders --->
			<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qrysubfolder">
			SELECT folder_id
			FROM #session.hostdbprefix#folders
			WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Call recursive function to inherit permissions --->
			<!--- If there are any then call this function again --->
			<cfif arguments.thestruct.qrysubfolder.recordcount NEQ 0>
				<cfinvoke method="folderinheritperm" thestruct="#arguments.thestruct#">
			</cfif>
		</cfif>
		<!--- Log --->
		<cfinvoke component="defaults" method="trans" transid="updated" returnvariable="updated" />
		<cfset log_folders(theuserid=session.theuserid,logaction='Update',logdesc='#updated#: #arguments.thestruct.folder_name# (ID: #arguments.thestruct.folder_id#)')>
		<!--- Flush Cache --->
		<cfset resetcachetoken("search")>
		<cfset resetcachetoken("labels")>
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("audios")>
		<cfset resetcachetoken("videos")>
		<cfset resetcachetoken("files")>
		<cfset variables.cachetoken = resetcachetoken("folders")>
		<!--- Set the Action2 var --->
		<cfset this.action2="done">
		<cfreturn this.action2>
	<!--- Same Folder exists --->
	<cfelse>
		<cfset this.action2="exists">
		<cfreturn this.action2>
	</cfif>
</cffunction>

<!--- Change folder permissions inherited --->
<cffunction name="folderinheritperm" output="true">
	<cfargument name="thestruct" required="yes" type="struct">
		<!--- Put the query of folder ids into a list --->
		<cfset var thefolderidlist = valuelist(arguments.thestruct.qrysubfolder.folder_id)>
		<!--- First delete all the groups --->
		<cfquery datasource="#variables.dsn#">
		DELETE FROM #session.hostdbprefix#folders_groups
		WHERE folder_id_r IN (<cfqueryparam value="#thefolderidlist#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Now add the new groups --->
		<cfloop collection="#arguments.thestruct#" item="myform">
			<cfif myform CONTAINS "grp_">
				<cfset var grpid = ReplaceNoCase(myform, "grp_", "")>
				<cfset var grpidno = Replace(grpid, "-", "", "all")>
				<cfset var theper = "per_" & "#grpidno#">
				<cfloop index="thisfolderid" list="#thefolderidlist#">
					<!--- Insert permission into folder_groups --->
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#folders_groups
					(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
					VALUES(
					<cfqueryparam value="#thisfolderid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#grpid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfif #evaluate(theper)# EQ "">
						 <cfqueryparam value="R" cfsqltype="cf_sql_varchar">,
					<cfelse>
						<cfqueryparam value="#evaluate(theper)#" cfsqltype="cf_sql_varchar">,
					</cfif>
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
					<!--- Set user folder to f --->
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#folders
					SET folder_of_user = <cfqueryparam value="f" cfsqltype="cf_sql_varchar">
					WHERE folder_id = <cfqueryparam value="#thisfolderid#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Query if there are any subfolder --->
					<!--- <cfquery datasource="#variables.dsn#" name="arguments.thestruct.qrysubfolder">
					SELECT folder_id
					FROM #session.hostdbprefix#folders
					WHERE folder_id_r = <cfqueryparam value="#thisfolderid#" cfsqltype="cf_sql_numeric">
					</cfquery>
					<!--- If there are any then call this function again --->
					<cfif arguments.thestruct.qrysubfolder.recordcount NEQ 0>
						<!--- Now call this method again --->
						<cfinvoke method="folderinheritperm">
							<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
						</cfinvoke>
					</cfif> --->
				</cfloop>
			</cfif>
		</cfloop>
		<!--- If the user want this folder to himself then we set appropriate --->
		<cfif arguments.thestruct.grpno EQ "T">
			<!--- Set user folder to T --->
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_of_user = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
			WHERE folder_id_r IN (<cfqueryparam value="#thefolderidlist#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
		<!--- Query if there are any subfolder --->
		<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qrysubfolder">
		SELECT folder_id
		FROM #session.hostdbprefix#folders
		WHERE folder_id_r IN (<cfqueryparam value="#thefolderidlist#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- If there are any then call this function again --->
		<cfif arguments.thestruct.qrysubfolder.recordcount NEQ 0>
			<!--- Now call this method again --->
			<cfinvoke method="folderinheritperm">
				<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
			</cfinvoke>
		</cfif>
		<!---
		<!--- If the user want this folder to himself then we set appropriate --->
		<cfif arguments.thestruct.grpno EQ "T">
			<!--- Set user folder to T --->
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_of_user = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
			WHERE folder_id_r IN (<cfqueryparam value="#arguments.thestruct.qrysubfolder.folder_id#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			</cfquery>
			<!--- Query if there are any subfolder --->
			<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qrysubfolder">
			SELECT folder_id
			FROM #session.hostdbprefix#folders
			WHERE folder_id_r IN (<cfqueryparam value="#arguments.thestruct.qrysubfolder.folder_id#" cfsqltype="CF_SQL_VARCHAR" list="true">)
			</cfquery>
			<!--- If there are any then call this function again --->
			<cfif arguments.thestruct.qrysubfolder.recordcount NEQ 0>
				<!--- Now call this method again --->
				<cfinvoke method="folderinheritperm">
					<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
				</cfinvoke>
			</cfif>
		</cfif> --->
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("folders")>
	<cfreturn />
</cffunction>

<!--- Call from API to filetotalcount --->
<cffunction name="apifiletotalcount" output="false">
	<cfargument name="folder_id" default="" required="yes" type="string">
	<!--- Call function --->
	<cfinvoke method="filetotalcount" folder_id="#arguments.folder_id#" theoverall="F" returnvariable="total">
	<!--- Return --->
	<cfreturn total>
</cffunction>

<!--- Call from API to filetotaltype --->
<cffunction name="apifiletotaltype" output="false">
	<cfargument name="folder_id" default="" required="yes" type="string">
	<!--- Set struct --->
	<cfset var totaltypes = structnew()>
	<cfset arguments.thestruct = structnew()>
	<cfset arguments.thestruct.folder_id = arguments.folder_id>
	<!--- Call function for IMG --->
	<cfset arguments.thestruct.kind = "img">
	<cfinvoke method="filetotaltype" thestruct="#arguments.thestruct#" returnvariable="totalimg">
	<cfset totaltypes.img = totalimg.thetotal>
	<!--- Call function for VID --->
	<cfset arguments.thestruct.kind = "vid">
	<cfinvoke method="filetotaltype" thestruct="#arguments.thestruct#" returnvariable="totalvid">
	<cfset totaltypes.vid = totalvid.thetotal>
	<!--- Call function for AUD --->
	<cfset arguments.thestruct.kind = "aud">
	<cfinvoke method="filetotaltype" thestruct="#arguments.thestruct#" returnvariable="totalaud">
	<cfset totaltypes.aud = totalaud.thetotal>
	<!--- Call function for DOC (formats .doc or .docx) --->
	<cfset arguments.thestruct.kind = "doc">
	<cfinvoke method="filetotaltype" thestruct="#arguments.thestruct#" returnvariable="totaldoc">
	<cfset totaltypes.doc = totaldoc.thetotal>
	<!--- Call function for ALL FILES (excludes audio, video or images)--->
	<cfset arguments.thestruct.kind = "allfiles">
	<cfinvoke method="filetotaltype" thestruct="#arguments.thestruct#" returnvariable="totalfiles">
	<cfset totaltypes.files = totalfiles.thetotal>
	<!--- Return --->
	<cfreturn totaltypes>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- HOW MANY FILES ARE IN TOTAL IN THIS FOLDER --->
<cffunction name="filetotalcount_temp" output="false">
	<cfset var s = structNew()>
	<cfset s.thetotal = session.total_count_of_folder>
	<cfset var qry = queryNew('thetotal')>
	<cfset queryAddRow(query=qry, data=s)>
	<cfreturn qry>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- HOW MANY FILES ARE IN TOTAL IN THIS FOLDER --->
<cffunction name="filetotalcount" output="false">
	<cfargument name="folder_id" default="" required="yes" type="string">
	<cfargument name="folderaccess" default="" required="no" type="string">
	<cfargument name="theoverall" default="f" required="no" type="string">
	<!--- Param --->
	<cfparam name="session.showsubfolders" default="F">
	<cfparam name="session.customfileid" default="">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Show assets from subfolders or not --->
	<cfif session.showsubfolders EQ "T">
		<cfinvoke method="getfoldersinlist" dsn="#application.razuna.datasource#" folder_id="#arguments.folder_id#" database="#application.razuna.thedatabase#" hostid="#session.hostid#" returnvariable="thefolders">
		<cfset var thefolderlist = arguments.folder_id & "," & ValueList(thefolders.folder_id)>
	<cfelse>
		<cfset var thefolderlist = arguments.folder_id & ",">
	</cfif>
	<!--- If folderlist is empty then set to a dummy value --->
	<cfif listlen(trim(thefolderlist)) EQ 0>
		<cfset var thefolderlist = '-1'>
	</cfif>

	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#filetotalcount */
		(
			SELECT count(asset_id_r)
			FROM ct_aliases
			WHERE folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		)
		+
		(
			SELECT count(fi.file_id)
			FROM #session.hostdbprefix#files fi, #session.hostdbprefix#folders f
			WHERE fi.folder_id_r = f.folder_id
			AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
			AND fi.folder_id_r IS NOT NULL
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fi.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fi.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND fi.is_available != <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
			<cfif arguments.theoverall EQ "f" AND arguments.folder_id NEQ "">
				AND fi.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			</cfif>
			<!--- If coming from custom view and the session.customfileid is not empty --->
			<cfif session.customfileid NEQ "">
				AND fi.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
			<cfif arguments.folderaccess EQ 'R'>
				AND (fi.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR fi.expiry_date is null)
			</cfif>
		)
		+
		(
			SELECT count(i.img_id)
			FROM #session.hostdbprefix#images i, #session.hostdbprefix#folders f
			WHERE i.folder_id_r = f.folder_id
			AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
			AND (i.img_group IS NULL OR i.img_group = '')
			AND i.folder_id_r IS NOT NULL
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND i.is_available != <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
			<cfif arguments.theoverall EQ "F" AND arguments.folder_id NEQ "">
				AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			</cfif>
			<!--- If coming from custom view and the session.customfileid is not empty --->
			<cfif session.customfileid NEQ "">
				AND i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
			<cfif arguments.folderaccess EQ 'R'>
				AND (i.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR i.expiry_date is null)
			</cfif>
		)
		+
		(
			SELECT count(v.vid_id)
			FROM #session.hostdbprefix#videos v, #session.hostdbprefix#folders f
			WHERE v.folder_id_r = f.folder_id
			AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
			AND (v.vid_group IS NULL OR v.vid_group = '')
			AND v.folder_id_r IS NOT NULL
			AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND v.is_available != <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
			<cfif arguments.theoverall EQ "F" AND arguments.folder_id NEQ "">
				AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			</cfif>
			<!--- If coming from custom view and the session.customfileid is not empty --->
			<cfif session.customfileid NEQ "">
				AND v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
			<cfif arguments.folderaccess EQ 'R'>
				AND (v.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR v.expiry_date is null)
			</cfif>
		)
		+
		(
			SELECT count(a.aud_id)
			FROM #session.hostdbprefix#audios a, #session.hostdbprefix#folders f
			WHERE a.folder_id_r = f.folder_id
			AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
			AND (a.aud_group IS NULL OR a.aud_group = '')
			AND a.folder_id_r IS NOT NULL
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND a.is_available != <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
			<cfif arguments.theoverall EQ "F" AND arguments.folder_id NEQ "">
				AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			</cfif>
			<!--- If coming from custom view and the session.customfileid is not empty --->
			<cfif session.customfileid NEQ "">
				AND a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
			<cfif arguments.folderaccess EQ 'R'>
				AND (a.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR a.expiry_date is null)
			</cfif>
		) as
		thetotal
		<cfif application.razuna.thedatabase EQ "db2">
			FROM sysibm.sysdummy1
		<cfelseif application.razuna.thedatabase EQ "oracle">
			FROM dual
		</cfif>
	</cfquery>
	<cfreturn total>
</cffunction>

<!--- GET COUNT OF FILE TYPES --->
<cffunction name="filetotaltype" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<!--- Param --->
	<cfparam name="session.showsubfolders" default="F">
	<cfparam name="session.customfileid" default="">
	<cfparam name="arguments.thestruct.folderaccess" default="">
	<cfset var thefolderlist = "">
	<!--- Show assets from subfolders or not --->
	<cfif arguments.thestruct.folder_id NEQ "">
		<cfif session.showsubfolders EQ "T">
			<cfinvoke method="getfoldersinlist" dsn="#application.razuna.datasource#" folder_id="#arguments.thestruct.folder_id#" database="#application.razuna.thedatabase#" hostid="#session.hostid#" returnvariable="thefolders">
			<cfset var thefolderlist = arguments.thestruct.folder_id & "," & ValueList(thefolders.folder_id)>
		<cfelse>
			<cfset var thefolderlist = arguments.thestruct.folder_id & ",">
		</cfif>
	</cfif>
	<!--- For aliases --->
	<cfset var alias_img = '0,'>
	<cfset var alias_vid = '0,'>
	<cfset var alias_aud = '0,'>
	<cfset var alias_doc = '0,'>
	<cfset var qry_aliases = ''>
	<!--- Query Aliases --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_aliases" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getallaliases */ asset_id_r, type
	FROM ct_aliases
	WHERE folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
	</cfquery>
	<cfloop query="qry_aliases">
		<cfif type EQ "img">
			<cfset var alias_img = alias_img & asset_id_r & ','>
		<cfelseif type EQ "vid">
			<cfset var alias_vid = alias_vid & asset_id_r & ','>
		<cfelseif type EQ "aud">
			<cfset var alias_aud = alias_aud & asset_id_r & ','>
		<cfelseif type EQ "doc">
			<cfset var alias_doc = alias_doc & asset_id_r & ','>
		</cfif>
	</cfloop>
	<!--- Images --->
	<cfif arguments.thestruct.kind EQ "img">
		<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#imgfiletotaltype */ count(img_id) as thetotal
		FROM #session.hostdbprefix#images
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND (img_group IS NULL OR img_group = '')
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif thefolderlist NEQ "">
			AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<cfif session.customfileid NEQ "">
			AND img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_img#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		</cfquery>
	<!--- Videos --->
	<cfelseif arguments.thestruct.kind EQ "vid">
		<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#vidfiletotaltype */ count(vid_id) as thetotal
		FROM #session.hostdbprefix#videos
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND (vid_group IS NULL OR vid_group = '')
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif thefolderlist NEQ "">
			AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<cfif session.customfileid NEQ "">
			AND vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_vid#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		</cfquery>
	<!--- Audios --->
	<cfelseif arguments.thestruct.kind EQ "aud">
		<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#audfiletotaltype */ count(aud_id) as thetotal
		FROM #session.hostdbprefix#audios
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND (aud_group IS NULL OR aud_group = '')
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif thefolderlist NEQ "">
			AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<cfif session.customfileid NEQ "">
			AND aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_aud#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		</cfquery>
	<!--- All Docs in this folder --->
	<cfelseif arguments.thestruct.kind EQ "doc">
		<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#docfiletotaltype */ count(file_id) as thetotal
		FROM #session.hostdbprefix#files
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif thefolderlist NEQ "">
			AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		AND	(file_extension = <cfqueryparam value="#arguments.thestruct.kind#" cfsqltype="cf_sql_varchar">
			OR file_extension = <cfqueryparam value="#arguments.thestruct.kind#x" cfsqltype="cf_sql_varchar">)
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_doc#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		</cfquery>
	<!--- Files --->
	<cfelseif arguments.thestruct.kind EQ "allfiles">
		<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#docfiletotaltype */ count(file_id) as thetotal
		FROM #session.hostdbprefix#files
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif thefolderlist NEQ "">
			AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_doc#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		</cfquery>
	<cfelse>
		<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#docfiletotaltype */ count(file_id) as thetotal
		FROM #session.hostdbprefix#files
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif thefolderlist NEQ "">
			AND folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		AND
		<cfif arguments.thestruct.kind NEQ "other">
			(
			file_extension = <cfqueryparam value="#arguments.thestruct.kind#" cfsqltype="cf_sql_varchar">
			OR file_extension = <cfqueryparam value="#arguments.thestruct.kind#x" cfsqltype="cf_sql_varchar">
			)
		<cfelse>
			file_extension NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
		</cfif>
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_doc#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		</cfquery>
	</cfif>
	<!--- Return --->
	<cfreturn total>
</cffunction>

<!--- GET ASSETS DETAILS --->
<cffunction name="getAssetsDetails" output="false" hint="GET ASSETS DETAILS" returntype="Any" >
	<cfargument name="folder_id" default="0" required="yes" type="string">
	<!--- If folder is is empty --->
	<cfif arguments.folder_id EQ "">
		<cfset arguments.folder_id = 0>
	</cfif>
	<!--- Param --->
	<cfset return_flag = false>
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Get All Assets From List Of Folders --->
	<cfquery datasource="#variables.dsn#" name="qTab" cachedwithin="1" region="razcache">
	SELECT i.img_id as id
	FROM #session.hostdbprefix#images i
	WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#" list="true">)
	AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	UNION ALL
		SELECT v.vid_id as id
		FROM #session.hostdbprefix#videos v
		WHERE v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#" list="true">)
		AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	UNION ALL
		SELECT f.file_id as id
		FROM #session.hostdbprefix#files f
		WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#" list="true">)
		AND f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	UNION ALL
		SELECT a.aud_id as id
		FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1 AND a.host_id = aut.host_id
		WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#" list="true">)
		AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfif qTab.RecordCount NEQ 0>
		<cfloop query="qTab">
			<!--- Get File IDs From Collections --->
			<cfquery name="alert_col" datasource="#application.razuna.datasource#">
			SELECT file_id_r
			FROM #session.hostdbprefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#qTab.id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Change Flag To True And Break The Loop If Records Found In Collections --->
			<cfif alert_col.RecordCount NEQ 0>
				<cfset return_flag = true>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn return_flag>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- CREATE QUERY TABLE WITH AMOUNT OF DIFFERENT FILE TYPES FOR TAB DISPLAY --->
<cffunction name="fileTotalAllTypes" output="false" hint="CREATE QUERY TABLE WITH AMOUNT OF DIFFERENT FILE TYPES FOR TAB DISPLAY">
	<cfargument name="folder_id" default="" required="yes" type="string">
	<cfargument name="folderaccess" default="" required="no" type="string">
	<cfargument name="sortby" default="" required="no" type="string">
	<!--- Params --->
	<cfparam name="session.customfileid" default="">
	<cfset var qTab = ''>
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- For aliases --->
	<cfset var alias_img = '0,'>
	<cfset var alias_vid = '0,'>
	<cfset var alias_aud = '0,'>
	<cfset var alias_doc = '0,'>
	<cfset var alias_pdf = '0,'>
	<cfset var alias_xls = '0,'>
	<cfset var alias_other = '0,'>
	<cfset var qry_aliases = ''>
	<!--- Query Aliases --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_aliases" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getallaliases */ c.asset_id_r, c.type, f.file_extension as file_ext
	FROM ct_aliases c, #session.hostdbprefix#files f
	WHERE c.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	AND c.asset_id_r = f.file_id
	</cfquery>
	<cfloop query="qry_aliases">
		<cfif type EQ "img">
			<cfset var alias_img = alias_img & asset_id_r & ','>
			<cfcontinue>
		<cfelseif type EQ "vid">
			<cfset var alias_vid = alias_vid & asset_id_r & ','>
			<cfcontinue>
		<cfelseif type EQ "aud">
			<cfset var alias_aud = alias_aud & asset_id_r & ','>
			<cfcontinue>
		<cfelseif type EQ "doc" AND file_ext contains 'doc'>
			<cfset var alias_doc = alias_doc & asset_id_r & ','>
			<cfcontinue>
		<cfelseif type EQ "doc" AND file_ext contains 'xls'>
			<cfset var alias_xls = alias_xls & asset_id_r & ','>
			<cfcontinue>
		<cfelseif type EQ "doc" AND file_ext EQ 'pdf'>
			<cfset var alias_pdf = alias_pdf & asset_id_r & ','>
			<cfcontinue>
		<cfelseif type EQ "doc">
			<cfset var alias_other= alias_other & asset_id_r & ','>
			<cfcontinue>
		</cfif>
	</cfloop>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qTab" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'doc' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_word' as scr, '0' as thetotal
		FROM #session.hostdbprefix#files
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND SUBSTR<cfif application.razuna.thedatabase EQ "mssql">ING</cfif>(file_extension,1,3) = <cfqueryparam cfsqltype="cf_sql_varchar" value="doc">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND is_available != <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.folderaccess EQ 'R'>
			AND (expiry_date >= <cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_doc#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		UNION ALL
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'xls' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_excel' as scr, '0' as thetotal
		FROM #session.hostdbprefix#files
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND SUBSTR<cfif application.razuna.thedatabase EQ "mssql">ING</cfif>(file_extension,1,3) = <cfqueryparam cfsqltype="cf_sql_varchar" value="xls">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND is_available != <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.folderaccess EQ 'R'>
		AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_xls#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		UNION ALL
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'pdf' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_pdf' as scr, '0' as thetotal
		FROM #session.hostdbprefix#files
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND SUBSTR<cfif application.razuna.thedatabase EQ "mssql">ING</cfif>(file_extension,1,3) = <cfqueryparam cfsqltype="cf_sql_varchar" value="pdf">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND is_available != <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.folderaccess EQ 'R'>
		AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_pdf#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		UNION ALL
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'other' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_others' as scr, '0' as thetotal
		FROM #session.hostdbprefix#files
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND ((SUBSTR<cfif application.razuna.thedatabase EQ "mssql">ING</cfif>(file_extension,1,3) <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="doc">
		AND SUBSTR<cfif application.razuna.thedatabase EQ "mssql">ING</cfif>(file_extension,1,3) <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="xls">
		AND file_extension <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="pdf">)
		OR  file_type = 'other')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.folderaccess EQ 'R'>
		AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_other#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		UNION ALL
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'img' as ext, count(img_id) as cnt, 'img' as typ, 'tab_images' as scr, '0' as thetotal
		FROM #session.hostdbprefix#images
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND (img_group IS NULL OR img_group = '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_img#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		UNION ALL
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'vid' as ext, count(vid_id) as cnt, 'vid' as typ, 'tab_videos' as scr, '0' as thetotal
		FROM #session.hostdbprefix#videos
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND (vid_group IS NULL OR vid_group = '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif session.customfileid NEQ "">
			AND vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_vid#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		UNION ALL
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'aud' as ext, count(aud_id) as cnt, 'aud' as typ, 'tab_audios' as scr, '0' as thetotal
		FROM #session.hostdbprefix#audios
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND (aud_group IS NULL OR aud_group = '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif session.customfileid NEQ "">
			AND aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		<cfif arguments.folderaccess EQ 'R'>
			AND (expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR expiry_date is null)
		</cfif>
		OR (
			aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_aud#" list="true">)
			AND
			in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		ORDER BY <cfif arguments.sortby NEQ "">#arguments.sortby#<cfelse>cnt DESC, scr</cfif>
	</cfquery>
	<!--- Add folder total in colum --->
	<cfset var _total = 0>
	<cfloop query="qTab">
		<cfset _total = _total + cnt>
	</cfloop>
	<cfset querySetCell(qTab, "thetotal", _total, 1)>
	<!--- Return --->
	<cfreturn qTab>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- SET ACCESS PERMISSION --->
<cffunction hint="SET ACCESS PERMISSION" name="setaccess" output="true" returntype="string">
	<cfargument name="folder_id" required="true" type="string">
	<cfargument name="sf"required="false" type="string" default="false">
	<!--- Param --->
	<cfset var fprop = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Set the access rights for this folder --->
	<cfset var folderaccess = "n">
	<!--- If there is no session for webgroups set --->
	<cfparam default="0" name="session.thegroupofuser">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="fprop" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#setaccess */ <cfif arguments.sf>'0' as folder_owner, '0' as folder_id_r<cfelse>f.folder_owner</cfif>,
	<cfif session.is_system_admin OR session.is_administrator>
		'X' as permfolder
	<cfelse>
		CASE
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = <cfif arguments.sf>f.sf_id<cfelse>f.folder_id</cfif>
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = <cfif arguments.sf>f.sf_id<cfelse>f.folder_id</cfif>
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = <cfif arguments.sf>f.sf_id<cfelse>f.folder_id</cfif>
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X'
			WHEN (<cfif arguments.sf>f.sf_who<cfelse>f.folder_owner</cfif> = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">) THEN 'X'
		END as permfolder
	</cfif>
	<cfif arguments.sf>
		FROM #session.hostdbprefix#smart_folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.sf_id = fg.folder_id_r AND f.host_id = fg.host_id
		WHERE f.sf_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	<cfelse>
		FROM #session.hostdbprefix#folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.folder_id = fg.folder_id_r AND f.host_id = fg.host_id
		WHERE f.folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Loop over results --->
	<cfloop query="fprop">
		<cfif permfolder EQ "R" AND folderaccess NEQ "W" AND folderaccess NEQ "X">
			<cfset var folderaccess = permfolder>
			<cfbreak>
		<cfelseif permfolder EQ "W" AND folderaccess NEQ "X">
			<cfset var folderaccess = permfolder>
			<cfbreak>
		<cfelseif permfolder EQ "X">
			<cfset var folderaccess = permfolder>
			<cfbreak>
		</cfif>
	</cfloop>
	<!--- If the user is a sys or admin or the owner of the folder give full access --->
	<cfif (session.is_system_admin OR session.is_administrator) OR fprop.folder_owner EQ session.theuserid>
		<cfset var folderaccess = "x">
	</cfif>
	<!--- If session.customaccess is here and is not empty --->
	<cfif structKeyExists(session,"customaccess") AND session.customaccess NEQ "">
		<cfset var folderaccess = session.customaccess>
	</cfif>
	<cfreturn folderaccess />
</cffunction>

<!--- SET ALIAS ACCESS PERMISSION --->
<cffunction hint="SET ALIAS ACCESS PERMISSION" name="setaliasaccess" output="true" returntype="string" hint="Looks at all folders that asset is an alias in and get permission for asset based on the alias folder permissions">
	<cfargument name="asset_id" required="true" type="string">
	<cfset var folderaccess = "n">
	<cfset var aliasfolders = "">
	<cfquery datasource="#application.razuna.datasource#" name="aliasfolders" cachedwithin="1" region="razcache">
		SELECT folder_id_r FROM ct_aliases WHERE asset_id_r =  <cfqueryparam value="#arguments.asset_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfloop query="aliasfolders">
		<cfset var permfolder = setaccess(folder_id_r)>
		<cfif permfolder EQ "R" AND folderaccess NEQ "W" AND folderaccess NEQ "X">
			<cfset var folderaccess = permfolder>
		<cfelseif permfolder EQ "W" AND folderaccess NEQ "X">
			<cfset var folderaccess = permfolder>
		<cfelseif permfolder EQ "X">
			<cfset var folderaccess = permfolder>
		</cfif>
	</cfloop>
	<cfreturn folderaccess />
</cffunction>

<!--- THE FOLDERS OF THIS HOST --------------------------------------------------->
<cffunction name="getserverdir" output="true">
	<cfargument name="thepath" type="string" default="">
	<cfdirectory action="list" directory="#arguments.thepath#" name="thedirs" sort="name ASC">
	<!--- exclude special folders --->
	<cfquery name="folderlist" dbtype="query">
	SELECT *
	FROM thedirs
	WHERE type = 'Dir'
	AND attributes != 'H'
	AND name NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="outgoing,js,images,.svn,parsed,model,controller,translations,views,.DS_Store,bluedragon,global,incoming,web-inf,.git,backup">)
	</cfquery>
	<cfreturn folderlist>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- MOVE THE FOLDER TO THE GIVEN POSITION --->
<cffunction hint="MOVE THE FOLDER TO THE GIVEN POSITION" name="move" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Wrap this in with a try catch --->
	<cftry>
		<!--- If there is a 0 in intolevel we assume the folder is coming from level 1, thus assign level 1 so
		we can increase the level further down in the code --->
		<cfif arguments.thestruct.intolevel EQ 0 OR arguments.thestruct.intolevel EQ "">
			<cfset arguments.thestruct.intolevel = 1>
		</cfif>
		<!--- Get the Folder Name/Folder Level for the Log --->
		<cfquery datasource="#variables.dsn#" name="foldername">
		SELECT folder_name, folder_level
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.tomovefolderid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Call the compontent above to get the recursive folder ids --->
		<cfinvoke method="recfolder" returnvariable="folderids">
			<cfinvokeargument name="thelist" value="#arguments.thestruct.tomovefolderid#">
			<cfinvokeargument name="thelevel" value="#foldername.folder_level#">
		</cfinvoke>
		<!--- Take the results from the compontent call above and add the root folder id --->
		<cfset var folderids="#folderids#">
		<!--- Get the folder_main_id_r from the folder we move the folder in --->
		<cfquery datasource="#variables.dsn#" name="thenewrootid">
		SELECT folder_main_id_r, folder_name, folder_level
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Change the folder_id_r of the folder we want to move --->
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#folders
		SET folder_id_r = <cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR">,
		folder_main_id_r = <cfif #arguments.thestruct.intolevel# EQ 1><cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
		in_trash = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.tomovefolderid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Now loop trough the folderids and change the folder_main_id_r and the folder_level --->
		<cfloop list="#folderids#" index="thenr" delimiters=",">
			<cfset arguments.thestruct.intolevel = arguments.thestruct.intolevel + 1>
			<cfquery datasource="#variables.dsn#">
			UPDATE #session.hostdbprefix#folders
			SET folder_main_id_r = <cfif #arguments.thestruct.intolevel# EQ 1><cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR"><cfelse><cfqueryparam value="#thenewrootid.folder_main_id_r#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
			folder_level = <cfqueryparam value="#arguments.thestruct.intolevel#" cfsqltype="cf_sql_numeric"><!--- folder_level + #arguments.thestruct.difflevel# --->
			WHERE folder_id = <cfqueryparam value="#thenr#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
		<!--- Clear session.type --->
		<cfset session.type = "">
		<!--- Log --->
		<cfinvoke component="defaults" method="trans" transid="moved" returnvariable="moved" />
		<cfset log_folders(theuserid=session.theuserid,logaction='Move',logdesc='#moved#: #foldername.folder_name# (ID: #arguments.thestruct.tomovefolderid#)')>
		<!--- Ups something went wrong --->
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while moving folder - #cgi.http_host# in function folders.move">
			<cfset cfcatch.thestruct = arguments.thestruct>
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- RECURSIVE SUBQUERY TO READ FOLDERS --->
<cffunction name="recfolder" output="false" access="public" returntype="string">
	<cfargument name="thelist" required="yes" hint="list of parent folder-ids">
	<cfargument name="thelevel" required="false" hint="the level">
	<!--- Cache --->
	<cfset var cachetoken = getcachetoken("folders")>
	<!--- function internal vars --->
	<cfset var local_query = 0>
	<cfset var local_list = "">
	<!--- If list empty then set to dummy value to prevent SQL from failing --->
	<cfif arguments.thelist EQ "">
		<cfset arguments.thelist = "-1">
	</cfif>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="local_query" cachedwithin="1" region="razcache">
	SELECT /* #cachetoken#recfolder */ folder_id, folder_level
	FROM #session.hostdbprefix#folders
	WHERE folder_id_r IN (<cfqueryparam value="#arguments.thelist#" cfsqltype="CF_SQL_VARCHAR" list="true">)
	AND folder_id <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> folder_id_r
	AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- get child-folders of next level but only if this is not the same folder_id. This fixes a bug some experiences where folders would not get removed --->
	<cfif local_query.RecordCount NEQ 0 AND arguments.thelist NEQ local_query.folder_id>
		<cfinvoke method="recfolder" returnvariable="local_list">
			<cfinvokeargument name="thelist" value="#ValueList(local_query.folder_id)#">
			<cfinvokeargument name="thelevel" value="#local_query.folder_level#">
		</cfinvoke>
		<cfset Arguments.thelist = Arguments.thelist & "," & local_list>
	</cfif>
	<cfreturn Arguments.thelist>
</cffunction>

<!--- GET FOLDER OF USER --------------------------------------------------->
<cffunction name="getuserfolder" output="false">
	<cfset var qry = "">
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getuserfolder */ folder_id
		FROM #session.hostdbprefix#folders
		WHERE folder_of_user = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfreturn qry.folder_id>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get all assets of this folder --->
<cffunction name="getallassets" output="true" returnType="query">
	<cfargument name="thestruct" type="struct" required="true">
	<cfparam name="arguments.thestruct.folderaccess" default="">
	<!--- Sometimes folderid is empty --->
	<cfif arguments.thestruct.folder_id EQ "">
		<cfset arguments.thestruct.folder_id = 0>
	</cfif>
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Set pages var --->
	<cfparam name="arguments.thestruct.pages" default="">
	<cfparam name="arguments.thestruct.thisview" default="">
	<cfparam name="session.customfileid" default="">
	<!--- Show assets from subfolders or not --->
	<cfif session.showsubfolders EQ "T">
		<cfinvoke method="getfoldersinlist" dsn="#variables.dsn#" folder_id="#arguments.thestruct.folder_id#" database="#application.razuna.thedatabase#" hostid="#session.hostid#" returnvariable="thefolders">
		<cfset var thefolderlist = arguments.thestruct.folder_id & "," & ValueList(thefolders.folder_id)>
	<cfelse>
		<cfset var thefolderlist = arguments.thestruct.folder_id & ",">
	</cfif>
	<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
		<!--- Set the session for offset correctly if the total count of assets in lower the the total rowmaxpage --->
		<cfif arguments.thestruct.qry_filecount LTE session.rowmaxpage>
			<cfset session.offset = 0>
		</cfif>
		<!---
		This is for Oracle and MSQL
		Calculate the offset .Show the limit only if pages is null or current (from print)
		--->
		<cfif session.offset EQ 0>
			<cfset var min = 0>
			<cfset var max = session.rowmaxpage>
		<cfelse>
			<cfset var min = session.offset * session.rowmaxpage>
			<cfset var max = (session.offset + 1) * session.rowmaxpage>
			<cfif application.razuna.thedatabase EQ "db2">
				<cfset var min = min + 1>
			</cfif>
		</cfif>
	<cfelse>
		<cfset var min = 0>
		<cfset var max = 1000>
	</cfif>
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
	</cfif>
	<cfset var qry = "">
	<!--- Oracle --->
	<!--- <cfif application.razuna.thedatabase EQ "oracle">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getallassets */ rn, id, filename, folder_id_r, ext, filename_org, kind, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, vheight, vwidth, theformat, filename_forsort, size, hashtag, labels, upc_number,extension
		FROM (
			SELECT ROWNUM AS rn, id, filename, folder_id_r, ext, filename_org, kind, date_create, date_change, link_kind,
			link_path_url, path_to_asset, cloud_url, cloud_url_org, description, keywords, vheight, vwidth, theformat, filename_forsort, size, hashtag, labels, upc_number,extension
			FROM (
				SELECT i.img_id as id, i.img_filename as filename, i.folder_id_r, i.thumb_extension as ext, i.img_filename_org as filename_org,
				'img' as kind, i.img_create_date, i.img_create_time as date_create, i.img_change_time as date_change,
				i.link_kind, i.link_path_url, i.path_to_asset, i.cloud_url, i.cloud_url_org,
				it.img_description as description, it.img_keywords as keywords, '0' as vheight, '0' as vwidth,
				(
					SELECT so.asset_format
					FROM #session.hostdbprefix#share_options so
					WHERE i.img_id = so.group_asset_id
					AND so.folder_id_r = i.folder_id_r
					AND so.asset_type = 'img'
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					GROUP BY so.asset_format
				) AS theformat,
				lower(i.img_filename) as filename_forsort,
				i.img_size as size,
				i.hashtag,
				'' as labels, i.img_upc_number as upc_number, i.img_extension as extension
				FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
				WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND (i.img_group IS NULL OR i.img_group = '')
				AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				UNION ALL
				SELECT v.vid_id as id, v.vid_filename as filename, v.folder_id_r, v.vid_extension as ext, v.vid_name_org as filename_org,
				'vid' as kind, v.vid_create_time as date_create, v.vid_change_time as date_change, v.link_kind, v.link_path_url,
				v.path_to_asset, v.cloud_url, v.cloud_url,
				vt.vid_description as description, vt.vid_keywords as keywords, v.vid_height as vheight, v.vid_width as vwidth,
				(
					SELECT so.asset_format
					FROM #session.hostdbprefix#share_options so
					WHERE v.vid_id = so.group_asset_id
					AND so.folder_id_r = v.folder_id_r
					AND so.asset_type = 'vid'
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					GROUP BY so.asset_format
				) AS theformat,
				lower(v.vid_filename) as filename_forsort,
				v.vid_size as size,
				v.hashtag,
				'' as labels, v.vid_upc_number as upc_number, v.vid_extension as extension
				FROM #session.hostdbprefix#videos v LEFT JOIN #session.hostdbprefix#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
				WHERE v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND (v.vid_group IS NULL OR v.vid_group = '')
				AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				UNION ALL
				SELECT f.file_id as id, f.file_name as filename, f.folder_id_r, f.file_extension as ext, f.file_name_org as filename_org,
				f.file_type as kind, f.file_create_time as date_create, f.file_change_time as date_change, f.link_kind,
				f.link_path_url, f.path_to_asset, f.cloud_url, f.cloud_url,
				ft.file_desc as description, ft.file_keywords as keywords, '0' as vheight, '0' as vwidth, '0' as theformat,
				lower(f.file_name) as filename_forsort, f.file_size as size, f.hashtag,
				'' as labels, f.file_upc_number as upc_number,  f.file_extension as extension
				FROM #session.hostdbprefix#files f LEFT JOIN #session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
				WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				UNION ALL
				SELECT a.aud_id as id, a.aud_name as filename, a.folder_id_r, a.aud_extension as ext, a.aud_name_org as filename_org,
				a.aud_type as kind, a.aud_create_time as date_create, a.aud_change_time as date_change, a.link_kind,
				a.link_path_url, a.path_to_asset, a.cloud_url, i.cloud_url_org,
				aut.aud_description as description, aut.aud_keywords as keywords, '0' as vheight, '0' as vwidth,
				(
					SELECT so.asset_format
					FROM #session.hostdbprefix#share_options so
					WHERE a.aud_id = so.group_asset_id
					AND so.folder_id_r = a.folder_id_r
					AND so.asset_type = 'aud'
					AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					GROUP BY so.asset_format
				) AS theformat,
				lower(a.aud_name) as filename_forsort,
				a.aud_size as size,
				a.hashtag,
				'' as labels, a.aud_upc_number as upc_number, a.aud_extension as extension
				FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
				WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#, filename_forsort
				<cfelse>
				ORDER BY #sortby#
				</cfif>
				<cfif !structKeyExists(arguments.thestruct,'widget_style') OR arguments.thestruct.widget_style NEQ 's'>
						)
					WHERE ROWNUM <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#max#">
					)
				WHERE rn > <cfqueryparam cfsqltype="cf_sql_numeric" value="#min#">
				</cfif>
		</cfquery>
	<!--- DB2 --->
	<cfelseif application.razuna.thedatabase EQ "db2">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getallassets */ id, filename, folder_id_r, ext, filename_org, kind, is_available, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, theformat, filename_forsort, size, hashtag, upc_number, extension
		FROM (
			SELECT row_number() over() as rownr, i.img_id as id, i.img_filename as filename,
			i.folder_id_r, i.thumb_extension as ext, i.img_filename_org as filename_org, 'img' as kind, i.is_available,
			i.img_create_time as date_create, i.img_change_time as date_change, i.link_kind, i.link_path_url,
			i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description as description, it.img_keywords as keywords, '0' as vheight, '0' as vwidth,
			(
				SELECT so.asset_format
				FROM #session.hostdbprefix#share_options so
				WHERE i.img_id = so.group_asset_id
				AND so.folder_id_r = i.folder_id_r
				AND so.asset_type = 'img'
				AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				GROUP BY so.asset_format
			) AS theformat,
			lower(i.img_filename) as filename_forsort,
			i.img_size as size,
			i.hashtag,
			'' as labels, i.img_upc_number as upc_number,  i.img_extension as extension
			FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
			WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND (i.img_group IS NULL OR i.img_group = '')
			AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			UNION ALL
			SELECT row_number() over() as rownr, v.vid_id as id, v.vid_filename as filename, v.folder_id_r,
			v.vid_extension as ext, v.vid_name_org as filename_org, 'vid' as kind, v.is_available,
			v.vid_create_time as date_create, v.vid_change_time as date_change, v.link_kind, v.link_path_url,
			v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description as description, vt.vid_keywords as keywords, v.vid_height as vheight, v.vid_width as vwidth,
			(
				SELECT so.asset_format
				FROM #session.hostdbprefix#share_options so
				WHERE v.vid_id = so.group_asset_id
				AND so.folder_id_r = v.folder_id_r
				AND so.asset_type = 'vid'
				AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				GROUP BY so.asset_format
			) AS theformat,
			lower(v.vid_filename) as filename_forsort,
			v.vid_size as size,
			v.hashtag,
			'' as labels, v.vid_upc_number as upc_number,  v.vid_extension as extension
			FROM #session.hostdbprefix#videos v LEFT JOIN #session.hostdbprefix#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
			WHERE v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND (v.vid_group IS NULL OR v.vid_group = '')
			AND v.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			UNION ALL
			SELECT row_number() over() as rownr, a.aud_id as id, a.aud_name as filename, a.folder_id_r,
			a.aud_extension as ext, a.aud_name_org as filename_org, 'aud' as kind, a.is_available,
			a.aud_create_time as date_create, a.aud_change_time as date_change, a.link_kind, a.link_path_url,
			a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description as description, aut.aud_keywords as keywords, '0' as vheight, '0' as vwidth,
			(
				SELECT so.asset_format
				FROM #session.hostdbprefix#share_options so
				WHERE a.aud_id = so.group_asset_id
				AND so.folder_id_r = a.folder_id_r
				AND so.asset_type = 'aud'
				AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
				GROUP BY so.asset_format
			) AS theformat,
			lower(a.aud_name) as filename_forsort,
			a.aud_size as size,
			a.hashtag,
			'' as labels, a.aud_upc_number as upc_number, a.aud_extension as extension
			FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
			WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND (a.aud_group IS NULL OR a.aud_group = '')
			AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			UNION ALL
			SELECT row_number() over() as rownr, f.file_id as id, f.file_name as filename, f.folder_id_r,
			f.file_extension as ext, f.file_name_org as filename_org, f.file_type as kind, f.is_available,
			f.file_create_time as date_create, f.file_change_time as date_change, f.link_kind, f.link_path_url,
			f.path_to_asset, f.cloud_url, f. cloud_url_org, ft.file_desc as description, ft.file_keywords as keywords, '0' as vheight, '0' as vwidth, '0' as theformat,
			lower(f.file_name) as filename_forsort, f.file_size as size, f.hashtag, '' as labels, f.file_upc_number as upc_number, f.file_extension as extension
			FROM #session.hostdbprefix#files f LEFT JOIN #session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
			WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND f.in_trash = 'F'
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<!--- Sorting made unique if two or more assets have the exact same sortby value --->
			<cfif #sortby# NEQ 'filename_forsort'>
				ORDER BY #sortby#, filename_forsort
			<cfelse>
			ORDER BY #sortby#
			</cfif>
		)
		<!--- Show the limit only if pages is null or current (from print) --->
		<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
			<cfif !structKeyExists(arguments.thestruct,'widget_style') OR arguments.thestruct.widget_style NEQ 's'>
				WHERE rownr between #min# AND #max#
			</cfif>
		</cfif>
		</cfquery>
	<!--- Other DB's --->
	<cfelse> --->
		<!--- MySQL Offset --->
		<cfset var mysqloffset = session.offset * session.rowmaxpage>
		<!--- For aliases --->
		<cfset var alias_img = '0,'>
		<cfset var alias_vid = '0,'>
		<cfset var alias_aud = '0,'>
		<cfset var alias_doc = '0,'>
		<cfset var qry_aliases = ''>
		<!--- Query Aliases --->
		<cfquery datasource="#application.razuna.datasource#" name="qry_aliases" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getallaliases */ asset_id_r, type
		FROM ct_aliases
		WHERE folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfquery>
		<cfloop query="qry_aliases">
			<cfif type EQ "img">
				<cfset var alias_img = alias_img & asset_id_r & ','>
			<cfelseif type EQ "vid">
				<cfset var alias_vid = alias_vid & asset_id_r & ','>
			<cfelseif type EQ "aud">
				<cfset var alias_aud = alias_aud & asset_id_r & ','>
			<cfelseif type EQ "doc">
				<cfset var alias_doc = alias_doc & asset_id_r & ','>
			</cfif>
		</cfloop>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		<!--- MSSQL --->
		<cfif application.razuna.thedatabase EQ "mssql">
			<cfif !structKeyExists(arguments.thestruct,'widget_style') OR arguments.thestruct.widget_style NEQ 's'>
				SELECT * FROM (
				SELECT ROW_NUMBER() OVER (
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#, filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif> ) AS RowNum,sorted_inline_view.* FROM (
			</cfif>
		</cfif>
		SELECT /* #variables.cachetoken#getallassets */ i.img_id as id,
		i.img_filename as filename, i.in_trash, i.folder_id_r, i.thumb_extension as ext, i.img_filename_org as filename_org, 'img' as kind, i.is_available,
		i.img_create_time as date_create, i.img_change_time as date_change, i.link_kind, i.link_path_url,
		i.path_to_asset, i.cloud_url, i.cloud_url_org, it.img_description as description, it.img_keywords as keywords, '0' as vwidth, '0' as vheight,
		(
			SELECT so.asset_format
			FROM #session.hostdbprefix#share_options so
			WHERE i.img_id = so.group_asset_id
			AND so.folder_id_r = i.folder_id_r
			AND so.asset_type = 'img'
			AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
			GROUP BY so.asset_format
		) AS theformat,
		i.img_filename as filename_forsort,
		cast(i.img_size as decimal(12,0)) as size,
		i.hashtag,
		'' as labels, i.img_upc_number as upc_number, i.img_extension as extension, i.expiry_date, 'null' as customfields
		<!--- custom metadata fields to show --->
		<cfif  arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">it
				<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">i

				<cfelse>x
				</cfif>.#m#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.videos_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.files_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#images i
		LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1 AND i.host_id = it.host_id
		LEFT JOIN #session.hostdbprefix#xmp x ON x.id_r = i.img_id AND i.host_id = x.host_id
		WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (i.img_group IS NULL OR i.img_group = '')
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		AND i.is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (i.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR i.expiry_date is null)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		OR (
			i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_img#" list="true">)
			AND
			i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)
		UNION ALL
		SELECT v.vid_id as id, v.vid_filename as filename, v.in_trash,v.folder_id_r,
		v.vid_extension as ext, v.vid_name_org as filename_org, 'vid' as kind, v.is_available,
		v.vid_create_time as date_create, v.vid_change_time as date_change, v.link_kind, v.link_path_url,
		v.path_to_asset, v.cloud_url, v.cloud_url_org, vt.vid_description as description, vt.vid_keywords as keywords, CAST(v.vid_width AS CHAR) as vwidth, CAST(v.vid_height AS CHAR) as vheight,
		(
			SELECT so.asset_format
			FROM #session.hostdbprefix#share_options so
			WHERE v.vid_id = so.group_asset_id
			AND so.folder_id_r = v.folder_id_r
			AND so.asset_type = 'vid'
			AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
			GROUP BY so.asset_format
		) AS theformat,
		v.vid_filename as filename_forsort,
		cast(v.vid_size as decimal(12,0))  as size,
		v.hashtag,
		'' as labels, v.vid_upc_number as upc_number, v.vid_extension as extension, v.expiry_date, 'null' as customfields
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.videos_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">vt
				<cfelse>v
				</cfif>.#m#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.files_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#videos v LEFT JOIN #session.hostdbprefix#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1 AND v.host_id = vt.host_id
		WHERE v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (v.vid_group IS NULL OR v.vid_group = '')
		AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		AND v.is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (v.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR v.expiry_date is null)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		OR (
			v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_vid#" list="true">)
			AND
			v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)

		UNION ALL
		SELECT a.aud_id as id, a.aud_name as filename, a.in_trash,a.folder_id_r,
		a.aud_extension as ext, a.aud_name_org as filename_org, 'aud' as kind, a.is_available,
		a.aud_create_time as date_create, a.aud_change_time as date_change, a.link_kind, a.link_path_url,
		a.path_to_asset, a.cloud_url, a.cloud_url_org, aut.aud_description as description, aut.aud_keywords as keywords, '0' as vwidth, '0' as vheight,
		(
			SELECT so.asset_format
			FROM #session.hostdbprefix#share_options so
			WHERE a.aud_id = so.group_asset_id
			AND so.folder_id_r = a.folder_id_r
			AND so.asset_type = 'aud'
			AND so.asset_selected = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
			GROUP BY so.asset_format
		) AS theformat,
		a.aud_name as filename_forsort,
		cast(a.aud_size as decimal(12,0))  as size,
		a.hashtag,
		'' as labels, a.aud_upc_number as upc_number, a.aud_extension as extension, a.expiry_date, 'null' as customfields
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.videos_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.files_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">aut
				<cfelse>a
				</cfif>.#m#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1 AND a.host_id = aut.host_id
		WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (a.aud_group IS NULL OR a.aud_group = '')
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		AND a.is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (a.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR a.expiry_date is null)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		OR (
			a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_aud#" list="true">)
			AND
			a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)

		UNION ALL
		SELECT f.file_id as id, f.file_name as filename,f.in_trash, f.folder_id_r,
		f.file_extension as ext, f.file_name_org as filename_org, f.file_type as kind, f.is_available,
		f.file_create_time as date_create, f.file_change_time as date_change, f.link_kind, f.link_path_url,
		f.path_to_asset, f.cloud_url, f.cloud_url_org, ft.file_desc as description, ft.file_keywords as keywords, '0' as vwidth, '0' as vheight, '0' as theformat,
		f.file_name as filename_forsort, cast(f.file_size as decimal(12,0))  as size, f.hashtag, '' as labels, f.file_upc_number as upc_number, f.file_extension as extension, f.expiry_date, 'null' as customfields
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.videos_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.files_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "desc">ft
				<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number" OR m CONTAINS "expiry_date">f
				<cfelse>x
				</cfif>.#m#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,null AS #listlast(m," ")#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#files f LEFT JOIN #session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1 AND f.host_id = ft.host_id LEFT JOIN #session.hostdbprefix#files_xmp x ON x.asset_id_r = f.file_id AND f.host_id = x.host_id
		WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		AND f.is_available <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		<cfif arguments.thestruct.folderaccess EQ 'R'>
			AND (f.expiry_date >=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#"> OR f.expiry_date is null)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		OR (
			f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_doc#" list="true">)
			AND
			f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		)

		<!--- MSSQL --->
		<cfif application.razuna.thedatabase EQ "mssql">
			<cfif !structKeyExists(arguments.thestruct,'widget_style') OR arguments.thestruct.widget_style NEQ 's'>
				) sorted_inline_view
				 ) resultSet
				  WHERE RowNum > #mysqloffset# AND RowNum <= #mysqloffset+session.rowmaxpage#
			</cfif>
		</cfif>
		<!--- Show the limit only if pages is null or current (from print) --->
		<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
			<!--- MySQL / H2 --->
			<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
				ORDER BY #sortby#
				</cfif>
				<cfif !structKeyExists(arguments.thestruct,'widget_style') OR arguments.thestruct.widget_style NEQ 's'>
					 LIMIT #mysqloffset#,#session.rowmaxpage#
				</cfif>
			</cfif>
		</cfif>
	</cfquery>
	<!--- </cfif> --->
	<!--- If coming from custom view and the session.customfileid is not empty --->
	<cfif session.customfileid NEQ "">
		<cfquery dbtype="query" name="qry">
		SELECT *
		FROM qry
		WHERE id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfquery>
	</cfif>
	<!--- Only get the labels if in the combinded view --->
	<cfif session.view EQ "combined">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetokenlabels = getcachetoken("labels")>
		<!--- Loop over files and get labels and add to qry --->
		<cfloop query="qry">
			<!--- Query labels --->
			<cfquery name="qry_l" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetokenlabels#getallassetslabels */ ct_label_id
			FROM ct_labels
			WHERE ct_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#id#">
			</cfquery>
			<!--- Add labels query --->
			<cfif qry_l.recordcount NEQ 0>
				<cfset QuerySetCell(query=qry, column="labels", value=valueList(qry_l.ct_label_id), row=currentrow)>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Add the custom fields to query --->
	<cfset qry = addCustomFieldsToQuery(qry)>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Sub function to put custom fields to query. Called from here, labels and from all cfcs that show thumbnails --->
<cffunction name="addCustomFieldsToQuery" output="false" returntype="query">
	<cfargument name="theqry" type="query" required="true">
	<!--- Get cachetokens --->
	<cfset variables.cachetokensetting = getcachetoken("settings")>
	<cfset variables.cachetokengeneral = getcachetoken("general")>
	<!--- Set var --->
	<cfset var cf_list = "">
	<cfset var qry_cf = "">
	<cfset var qrycfimg = "0">
	<cfset var qrycfvid = "0">
	<cfset var qrycfaud = "0">
	<cfset var qrycfdoc = "0">
	<!--- Get which custom field ids the user wants to show --->
	<cfquery name="qry_cf_img" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetokensetting#qry_cf_img */ custom_value
	FROM #session.hostdbprefix#custom
	WHERE custom_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="cf_images_metadata">
	AND host_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.hostid#">
	</cfquery>
	<cfquery name="qry_cf_vid" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetokensetting#qry_cf_vid */ custom_value
	FROM #session.hostdbprefix#custom
	WHERE custom_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="cf_videos_metadata">
	AND host_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.hostid#">
	</cfquery>
	<cfquery name="qry_cf_aud" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetokensetting#qry_cf_aud */ custom_value
	FROM #session.hostdbprefix#custom
	WHERE custom_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="cf_audios_metadata">
	AND host_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.hostid#">
	</cfquery>
	<cfquery name="qry_cf_doc" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetokensetting#qry_cf_doc */ custom_value
	FROM #session.hostdbprefix#custom
	WHERE custom_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="cf_files_metadata">
	AND host_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.hostid#">
	</cfquery>
	<cfif qry_cf_img.recordcount NEQ 0>
		<cfset qrycfimg = qry_cf_img.custom_value>
	</cfif>
	<cfif qry_cf_vid.recordcount NEQ 0>
		<cfset qrycfvid = qry_cf_vid.custom_value>
	</cfif>
	<cfif qry_cf_aud.recordcount NEQ 0>
		<cfset qrycfaud = qry_cf_aud.custom_value>
	</cfif>
	<cfif qry_cf_doc.recordcount NEQ 0>
		<cfset qrycfdoc = qry_cf_doc.custom_value>
	</cfif>

	<cfloop query="arguments.theqry">
		<cfquery name="qry_cf" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetokengeneral#folder_cf_fields */ CASE WHEN cfv.cf_value IS NULL OR  cfv.cf_value ='' THEN ' ' ELSE cfv.cf_value END as cf_value, cft.cf_text, cft.cf_id_r as cf_id
		FROM raz1_custom_fields_values cfv RIGHT JOIN raz1_custom_fields_text cft INNER JOIN raz1_custom_fields cf ON cf.cf_id = cft.cf_id_r
		ON cft.cf_id_r = cfv.cf_id_r AND cfv.asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.theqry.id#">
		<cfif kind EQ "img">
			AND cfv.cf_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qrycfimg#" list="true">)
		<cfelseif kind EQ "vid">
			AND cfv.cf_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qrycfvid#" list="true">)
		<cfelseif kind EQ "aud">
			AND cfv.cf_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qrycfaud#" list="true">)
		<cfelseif kind EQ "doc">
			AND cfv.cf_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qrycfdoc#" list="true">)
		</cfif>
		WHERE
		cft.lang_id_r = 1
		AND cft.host_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.hostid#">
		<cfif kind EQ "img">
			AND cf.cf_show IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img,all" list="true">)
		<cfelseif kind EQ "vid">
			AND cf.cf_show IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="vid,all" list="true">)
		<cfelseif kind EQ "aud">
			AND cf.cf_show IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="aud,all" list="true">)
		<cfelseif kind EQ "doc">
			AND cf.cf_show IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="doc,all" list="true">)
		</cfif>
		</cfquery>
		<cfloop query="qry_cf">
			<!--- Put list together --->
			<cfset cf_list = cf_list & cf_text & "|" & cf_id & "|" & cf_value & ",">
		</cfloop>
		<!--- Now add to query --->
		<cfset QuerySetCell(query=arguments.theqry, column="customfields", value=cf_list, row=arguments.theqry.currentrow)>
		<!--- Reset cf_list --->
		<cfset cf_list = "">
	</cfloop>

	<!--- Return --->
	<cfreturn arguments.theqry>
</cffunction>


<!--- Trash all selected records. Mixed data types thus get them here --->
<cffunction name="trashall" output="true">
	<cfargument name="thestruct" type="struct" required="true">
	<cfset var theids = structnew()>
	<cfset theids.imgids = "">
	<cfset theids.docids = "">
	<cfset theids.vidids = "">
	<cfset theids.audids = "">
	<cfset theids.aliasids = "">
	<cfset var isalias = "">
	<!--- Get the ids and put them into the right struct --->
	<cfloop list="#arguments.thestruct.id#" delimiters="," index="i">
		<cfquery name="isalias" datasource="#application.razuna.datasource#">
			SELECT rec_uuid FROM ct_aliases
			WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#listfirst(i,"-")#">
		</cfquery>
		<cfif isalias.recordcount NEQ 0>
			<cfset var aliasid = isalias.rec_uuid>
			<cfset theids.aliasids = aliasid & "," & theids.aliasids >
		<cfelseif i CONTAINS "-img">
			<cfset var imgid = listfirst(i,"-")>
			<cfset theids.imgids = imgid & "," & theids.imgids >
		<cfelseif  i CONTAINS "-doc">
			<cfset var docid = listfirst(i,"-")>
			<cfset theids.docids = docid & "," & theids.docids >
		<cfelseif  i CONTAINS "-vid">
			<cfset var vidid = listfirst(i,"-")>
			<cfset theids.vidids = vidid & "," & theids.vidids >
		<cfelseif  i CONTAINS "-aud">
			<cfset var audid = listfirst(i,"-")>
			<cfset theids.audids = audid & "," & theids.audids >
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn theids>
</cffunction>

<!--- Remove all selected records. Mixed data types thus get them here --->
<cffunction name="removeall" output="true">
	<cfargument name="thestruct" type="struct" required="true">
	<cfset var theids = structnew()>
	<cfset theids.imgids = "">
	<cfset theids.docids = "">
	<cfset theids.vidids = "">
	<cfset theids.audids = "">
	<!--- Get the ids and put them into the right struct --->
	<cfloop list="#arguments.thestruct.id#" delimiters="," index="i">
		<cfif i CONTAINS "-img">
			<cfset var imgid = listfirst(i,"-")>
			<cfset theids.imgids = imgid & "," & theids.imgids >
		<cfelseif  i CONTAINS "-doc">
			<cfset var docid = listfirst(i,"-")>
			<cfset theids.docids = docid & "," & theids.docids >
		<cfelseif  i CONTAINS "-vid">
			<cfset var vidid = listfirst(i,"-")>
			<cfset theids.vidids = vidid & "," & theids.vidids >
		<cfelseif  i CONTAINS "-aud">
			<cfset var audid = listfirst(i,"-")>
			<cfset theids.audids = audid & "," & theids.audids >
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn theids>
</cffunction>

<!--- Get all assets of this folder this coming from a external call --->
<cffunction name="getfoldersinlist" output="false">
	<cfargument name="dsn" type="string" required="true">
	<cfargument name="database" type="string" required="true">
	<cfargument name="folder_id" type="string" required="true">
	<cfargument name="hostid" type="numeric" required="true">
	<cfargument name="prefix" default="" type="string" required="false">
	<cfset var qry = "">
	<cfif arguments.prefix EQ "">
		<cfset arguments.prefix = session.hostdbprefix>
	</cfif>
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#arguments.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfoldersinlist */ folder_id
	FROM #arguments.prefix#folders f
	WHERE f.folder_id <cfif arguments.database EQ "oracle" OR arguments.database EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
	AND f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Retrieve folders --->
<cffunction name="getfoldersfortree" access="public" output="true">
	<cfargument name="id" type="string" required="false">
	<cfargument name="col" type="string" required="false">
	<cfargument name="actionismove" type="string" required="false">
	<cfargument name="permlist" type="string" required="false">
	<cfargument name="kind" type="string" required="false"
	<cfargument name="fromtrash" type="boolean" required="false">

	<!--- Check how many languages are enabled --->
	<cfinvoke component="defaults" method="getlangs" returnvariable="qry_lang">
	<!--- If col is T or the id contains col- --->
	<cfif arguments.col EQ "T" or arguments.id CONTAINS "col-">
		<cfset var iscol = "T">
		<cfset var theid = listlast(arguments.id, "-")>
	<cfelse>
		<cfset var iscol = "F">
		<cfset var theid = arguments.id>
	</cfif>
	<!--- If theid is only a hashtag --->
	<cfif theid EQ "##">
		<cfset var theid = 0>
	</cfif>
	<!--- If this use is not in the admin groups clear the showmyfolder session --->
	<cfif NOT session.is_system_admin AND NOT session.is_administrator>
		<cfset session.showmyfolder = "F">
	</cfif>
	<!--- Param --->
	<cfparam default="0" name="session.thefolderorg">
	<cfparam default="0" name="session.type">
	<cfparam default="0" name="session.thegroupofuser">
	<cfset var qry = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken##session.theUserID#getfoldersfortree */ folder_id, folder_name, folder_id_r, folder_of_user, folder_owner, folder_level, in_trash,link_path, username, perm, subhere, permfolder
	FROM (
		SELECT f.folder_id, f.folder_id_r, f.folder_of_user, f.folder_owner, f.folder_level,f.in_trash,f.link_path,
		<cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username,
		<!--- Folder name --->
		<cfif qry_lang.recordcount EQ 1>
			f.folder_name,
		<cfelse>
			CASE
				WHEN EXISTS (
					SELECT folder_name
					FROM #session.hostdbprefix#folders_name
					WHERE folder_id_r = f.folder_id
					AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.thelangid#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				) THEN (
					SELECT folder_name
					FROM #session.hostdbprefix#folders_name
					WHERE folder_id_r = f.folder_id
					AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.thelangid#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				) ELSE (
					f.folder_name
				)
			END AS folder_name,
		</cfif>
		<!--- Permission follow but not for sysadmin and admin --->
		<cfif not session.is_system_admin and not session.is_administrator>
			CASE
				<!--- Check permission on this folder --->
				WHEN EXISTS(
					SELECT fg.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg
					WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg.folder_id_r = f.folder_id
					AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permlist#" list="true">)
					AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					) THEN 'unlocked'
				<!--- When folder is shared for everyone --->
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2
					WHERE fg2.grp_id_r = '0'
					AND fg2.folder_id_r = f.folder_id
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg2.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permlist#" list="true">)
					) THEN 'unlocked'
				<!--- If this is the user folder or he is the owner --->
				WHEN f.folder_owner = '#Session.theUserID#' THEN 'unlocked'
				<!--- If this is the upload bin --->
				WHEN f.folder_id = '1' THEN 'unlocked'
				<!--- RAZ-2872 : Removed the below condition to show the collection folder as per the group permissions assigned to it --->
				<!--- If this is a collection
				WHEN lower(f.folder_is_collection) = 't' THEN 'unlocked' --->
				<!--- If nothing meets the above lock the folder --->
				ELSE 'locked'
			END AS perm
		<cfelse>
			'unlocked' AS perm
		</cfif>
		<!--- Check for subfolders --->
		,
		CASE
			<!--- First check if there is a subfolder --->
			WHEN EXISTS(
				SELECT <cfif application.razuna.thedatabase EQ "mssql">TOP 1 </cfif>*
				FROM #session.hostdbprefix#folders s1
				WHERE s1.folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id
				AND s1.folder_id_r = f.folder_id
				ANd s1.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND s1.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<!--- AND lower(s.folder_of_user) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">  --->
				<cfif not session.is_system_admin and not session.is_administrator>
					AND s1.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
				</cfif>
				<!--- If this is a move then dont show the folder that we are moving --->
				<cfif (arguments.actionismove EQ "T" AND session.type EQ "movefolder") OR session.type EQ "copyfolder">
					AND s1.folder_id <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thefolderorg#">
				</cfif>
				<!--- RAZ-583 : exclude link folder from subfolder count --->
				<cfif session.type NEQ ''>
					AND (s1.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '/' OR s1.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '\\' OR s1.link_path IS NULL)
				</cfif>
				<cfif application.razuna.thedatabase EQ "oracle">
					AND ROWNUM = 1
				<cfelseif  application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
					LIMIT 1
				</cfif>
			) THEN 1
			<!--- Check permission on this folder --->
			WHEN EXISTS(
				SELECT <cfif application.razuna.thedatabase EQ "mssql">TOP 1 </cfif>*
				FROM #session.hostdbprefix#folders s2, #session.hostdbprefix#folders_groups fg3
				WHERE s2.folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id
				AND s2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND s2.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND fg3.host_id = s2.host_id
				AND s2.folder_id_r = f.folder_id
				AND fg3.folder_id_r = s2.folder_id
				AND fg3.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permlist#" list="true">)
				AND fg3.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				<!--- If this is a move then dont show the folder that we are moving --->
				<cfif (arguments.actionismove EQ "T" AND session.type EQ "movefolder") OR session.type EQ "copyfolder">
					AND s2.folder_id <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thefolderorg#">
				</cfif>
				<!--- RAZ-583 : exclude link folder from subfolder count --->
				<cfif session.type NEQ ''>
					AND (s2.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '/' OR s2.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '\\' OR s2.link_path IS NULL)
				</cfif>
				<cfif application.razuna.thedatabase EQ "oracle">
					AND ROWNUM = 1
				<cfelseif  application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
					LIMIT 1
				</cfif>
			) THEN 1
			<!--- When folder is shared for everyone --->
			WHEN EXISTS(
				SELECT <cfif application.razuna.thedatabase EQ "mssql">TOP 1 </cfif>*
				FROM #session.hostdbprefix#folders s3, #session.hostdbprefix#folders_groups fg4
				WHERE s3.folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id
				AND s3.folder_id_r = f.folder_id
				ANd s3.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND fg4.grp_id_r = '0'
				AND fg4.folder_id_r = s3.folder_id
				AND fg4.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.permlist#" list="true">)
				AND s3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND s3.host_id = fg4.host_id
				<!--- If this is a move then dont show the folder that we are moving --->
				<cfif (arguments.actionismove EQ "T" AND session.type EQ "movefolder") OR session.type EQ "copyfolder">
					AND s3.folder_id <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thefolderorg#">
				</cfif>
				<!--- RAZ-583 : exclude link folder from subfolder count --->
				<cfif session.type NEQ ''>
					AND (s3.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '/' OR s3.link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '\\' OR s3.link_path IS NULL)
				</cfif>
				<cfif application.razuna.thedatabase EQ "oracle">
					AND ROWNUM = 1
				<cfelseif  application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
					LIMIT 1
				</cfif>
			) THEN 1
			<!--- If nothing meets the above lock the folder --->
			ELSE 0
		END AS subhere
		<!--- Permfolder --->
		<cfif session.is_system_admin OR session.is_administrator>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'R' THEN 'R'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'W' THEN 'W'
				WHEN (
					SELECT DISTINCT max(fg5.grp_permission)
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id
					AND (
						fg5.grp_id_r = '0'
						OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					)
				) = 'X' THEN 'X'
				WHEN (f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">) THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#folders f LEFT JOIN users u ON u.user_id = f.folder_owner
		WHERE
		<cfif theid gt 0>
			f.folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
			AND
			f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
		<cfelse>
			f.folder_id = f.folder_id_r
		</cfif>
		<cfif iscol EQ "F">
			AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
		<cfelse>
			AND f.folder_is_collection = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		</cfif>
		<!--- filter user folders, but not for collections --->
		<cfif iscol EQ "F" AND (NOT session.is_system_admin AND NOT session.is_administrator)>
			AND
				(
				<cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(f.folder_of_user,<cfqueryparam cfsqltype="cf_sql_varchar" value="f">) <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
				OR f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
				)
		</cfif>
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		) as itb
	WHERE itb.perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
	<!--- If this is a move or copy then don't show the folder that we are moving/copying into --->
	<cfif session.type EQ "movefolder" OR session.type EQ "copyfolder">
		AND itb.folder_id <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thefolderorg#">
	</cfif>
	<!--- RAZ-583 : exclude link folder from select --->
	<cfif session.type NEQ ''>
		AND (link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '/' OR link_path <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> '\\' OR link_path IS NULL)
	</cfif>
	ORDER BY folder_name
	</cfquery>

	<!--- <cfset consoleoutput(true)>
	<cfset console(session.theuserid)>
	<cfset console(" ISCOL : #iscol# ")>
	<cfset console(" THEID : #theid# ")>
	<cfset console(" ARGUMENTS.ID : #arguments.id# ")> --->

	<!--- Create the XML --->
	<cfif theid EQ 0>
		<!--- This is the ROOT level  --->
		<cfif session.showmyfolder EQ "F" AND iscol NEQ "T">
			<!--- <cfset console("HERE !!!!!!!!!!!!!!!")> --->
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qry
			WHERE (folder_of_user = <cfqueryparam cfsqltype="cf_sql_varchar" value="f"> OR folder_of_user IS NULL)
			OR (folder_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="my folder"> AND folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">)
			OR folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
			OR folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
			</cfquery>
		</cfif>
	</cfif>

	<!--- <cfset console(qry)>
	<cfabort> --->

	<!--- Node Array --->
	<cfset var _node = arrayNew()>
	<!--- Set row --->
	<cfset var _row = 1>

	<!--- Tree for the Explorer --->
	<cfif arguments.actionismove EQ "F">
		<!--- Loop --->
		<cfloop query="qry">
			<cfif qry.in_trash EQ 'F'>
				<!--- Default values --->
				<cfset _node[_row].children = false>
				<cfset var _attr_fa = "c.folder">
				<!--- Set id --->
				<cfset var _id = folder_id>
				<!--- if collection --->
				<cfif iscol EQ 'T'>
					<cfset var _id = "col-" & _id>
					<cfset var _attr_fa = "c.collections">
				</cfif>
				<!--- Set id finally --->
				<cfset _node[_row].id = _id>
				<!--- Folder name --->
				<cfset var _folder_name = folder_name>
				<cfif theid EQ 0>
					<cfif iscol EQ "F">
						<cfif session.theuserid NEQ folder_owner AND folder_owner NEQ "">
							<cfset var _folder_name = _folder_name & "*">
							<cfif folder_name EQ "my folder">
								<cfset var _folder_name = _folder_name & " <em>(" & username & ")</em>">
							</cfif>
						</cfif>
					</cfif>
				</cfif>
				<cfset _node[_row].text = _folder_name>
				<!--- Do we have children? --->
				<cfif subhere EQ "1">
					<cfset _node[_row].children = true>
				</cfif>
				<!--- Set link --->
				<cfset var _attr = structNew()>
				<cfset _attr.onclick = "scroll(0,0);loadcontent('rightside','index.cfm?fa=#_attr_fa#&col=F&folder_id=#_id#');">
				<cfset _node[_row].a_attr = _attr >
				<!--- Increase --->
				<cfset _row = _row + 1>
			</cfif>
		</cfloop>
		<!--- <cfdump var="#qry#">
		<cfdump var="#_node#">
		<cfabort> --->
	<!--- If we come from a move action --->
	<cfelse>
		<cfloop query="qry">
			<cfif qry.in_trash EQ 'F'>

				<!--- Default values --->
				<cfset var _attr_fa = "c.folder">
				<cfset var _attr_fa_explorer = "c.explorer">
				<cfset var _attr_div_explorer = "##explorer">
				<cfset var _attr_destroywindow = "destroywindow(1);">
				<cfset var _fromtrash = "">

				<cfif structKeyExists(session, "thefileid") AND NOT session.thefileid CONTAINS ",">
					<cfset var _attr_destroywindow = "destroywindow(2);">
				</cfif>

				<!--- Children --->
				<cfset _node[_row].children = false>
				<!--- Do we have children? --->
				<cfif subhere EQ "1">
					<cfset _node[_row].children = true>
				</cfif>
				<!--- Set id --->
				<cfset var _id = folder_id>
				<!--- if collection --->
				<cfif iscol EQ 'T'>
					<cfset var _id = "col-" & _id>
					<cfset var _attr_fa = "c.collections">
					<cfset var _attr_fa_explorer = "c.explorer_col">
					<cfset var _attr_div_explorer = "##explorer_col">
				</cfif>

				<!--- If fromtrash --->
				<cfif arguments.fromtrash>
					<cfset var _fromtrash = "$('##rightside').load('index.cfm?fa=#_attr_fa#_explorer_trash');">
				</cfif>

				<!--- Set id finally --->
				<cfset _node[_row].id = _id>
				<!--- Folder name --->
				<cfset var _folder_name = folder_name>
				<cfif iscol EQ "F" AND folder_name EQ "my folder" AND (session.is_system_admin OR session.is_administrator)>
					<cfif session.theuserid NEQ folder_owner AND folder_owner NEQ "">
						<cfset var _folder_name = _folder_name & " <em>(" & Encodeforjavascript(username) & ")</em>">
					</cfif>
				</cfif>
				<cfset _node[_row].text = Encodeforjavascript(_folder_name)>



				<!--- Set link --->
				<cfset var _attr = structNew()>
				<cfset _attr.style = "white-space:normal;">

				<!--- Only allow users with write permissions to perform actions on the folder --->
				<cfif !listfindnocase('w,x',qry.permfolder)>
					<!--- Nothing here --->
				<!--- movefile --->
				<cfelseif session.type EQ "movefile">
					<cfif session.thefolderorg NEQ folder_id>
						<cfif arguments.kind EQ "search">
							<cfset _attr.onclick = "$('##div_choosefolder_status_#session.tmpid#').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#&folder_name=#URLEncodedFormat(folder_name)#', function(){$('##div_choosefolder_status_#session.tmpid#').html('The file(s) are being moved now.<br />Note: For a large batch of files this can take some time until it reflects in the system!<br />You can close this window.');});">
						<cfelse>
							<cfset _attr.onclick = "$('##div_forall').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#', function(){$('##div_choosefolder_status_#session.tmpid#').html('The file(s) are being moved now.<br />Note: For a large batch of files this can take some time until it reflects in the system!<br />You can close this window.');});">
						</cfif>
					</cfif>
				<!--- movefolder --->
				<cfelseif session.type EQ "movefolder">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset _attr.onclick = "$('##div_forall').load('index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#', function(){$('##explorer').load('index.cfm?fa=#_attr_fa_explorer#');#_fromtrash#});destroywindow(1);return false;">
					</cfif>
				<!--- copyfolder --->
				<cfelseif session.type EQ "copyfolder">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset _attr.onclick = "loadcontent('div_forall','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#&inherit_perm='+$('##perm_inherit').is(':checked'), function(){#_fromtrash#');});$('#_attr_div_explorer#').load('index.cfm?fa=#_attr_fa_explorer#');destroywindow(1);return false;">
					</cfif>
				<!--- restorefolder --->
				<cfelseif session.type EQ "restorefolder">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset _attr.onclick = "loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#');$('##rightside').load('index.cfm?fa=c.folder_explorer_trash&trashkind=folders');destroywindow(1);return false;">
					</cfif>
				<!--- restoreselectedfolders --->
				<cfelseif session.type EQ "restoreselectedfolders">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset _attr.onclick = "loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#');destroywindow(1);return false;">
					</cfif>
				<!--- restorefile --->
				<cfelseif session.type EQ "restorefile">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset var _for_here_1 = "">
						<cfset var _for_here_2 = "">
						<cfif session.thefileid CONTAINS ",">
							<cfset var _for_here_1 = "loadoverlay();">
						</cfif>
						<cfif NOT session.thefileid CONTAINS ",">
							<cfset var _for_here_2_start = "loadcontent('thewindowcontent1','index.cfm?fa=c.">
							<cfif session.thetype EQ "doc">
								<cfset _for_here_2_sub = "files">
							<cfelseif session.thetype EQ "img">
								<cfset _for_here_2_sub = "images">
							<cfelseif session.thetype EQ "vid">
								<cfset _for_here_2_sub = "videos">
							<cfelseif session.thetype EQ "aud">
								<cfset _for_here_2_sub = "audios">
							</cfif>
							<cfset var _for_here_2 = _for_here_2_start & _for_here_2_sub & "_detail&file_id=" & session.thefileid & "&what=" & _for_here_2_sub & "&loaddiv=&folder_id=" & folder_id>
						</cfif>
						<cfset _attr.onclick = "#_for_here_1#$('##rightside').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#&intolevel=#folder_level#', function(){loadfolderwithdelay('#session.thefolderorg#');$('##bodyoverlay').remove();});#_attr_destroywindow##_for_here_2#');">
					</cfif>
				<!--- restorefileall --->
				<cfelseif session.type EQ "restorefileall">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset _attr.onclick = "$('##rightside').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
					</cfif>
				<!--- restoreselectedfiles --->
				<cfelseif session.type EQ "restoreselectedfiles">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset _attr.onclick = "$('##div_forall').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');delayloadingoflist();destroywindow(1);return false;">
					</cfif>
				<!--- restorefolderall --->
				<cfelseif session.type EQ "restorefolderall">
					<cfif session.thefolderorg NEQ folder_id>
						<cfset _attr.onclick = "$('##rightside').load('index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
					</cfif>
				<!--- saveaszip or as a collection --->
				<cfelseif session.type EQ "saveaszip" OR session.type EQ "saveascollection">
					<cfset _attr.onclick = "loadcontent('win_choosefolder_#session.tmpid#','index.cfm?fa=#session.savehere#&folder_id=#folder_id#&folder_name=#URLEncodedFormat(folder_name)#');">
				<!--- upload --->
				<cfelseif session.type EQ "uploadinto">
					<cfset _attr.onclick = "showwindow('index.cfm?fa=c.asset_add&folder_id=#folder_id#','Add your files',650,1);return false;">
				<!--- customization --->
				<cfelseif session.type EQ "customization">
					<cfset _attr.onclick = "javascript:document.form_admin_custom.folder_redirect.value = '#folder_id#'; document.form_admin_custom.folder_name.value = '#Encodeforjavascript(folder_name)#';destroywindow(1);">
				<!--- group detail--->
				<cfelseif session.type EQ "groups_detail">
					<cfset _attr.onclick = "javascript:document.grpedit.folder_redirect.value = '#folder_id#'; document.grpedit.folder_name.value = '#Encodeforjavascript(folder_name)#';destroywindow(2);">
				<!--- scheduler --->
				<cfelseif session.type EQ "scheduler">
					<cfset _attr.onclick = "javascript:document.schedulerform.folder_id.value = '#folder_id#'; document.schedulerform.folder_name.value = '#Encodeforjavascript(folder_name)#';destroywindow(2);">
				<!--- choose a collection --->
				<cfelseif session.type EQ "choosecollection">
					<cfset _attr.onclick = "loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
				<!--- choose a collection for restore file --->
				<cfelseif session.type EQ "restore_collection_file">
					<cfset _attr.onclick = "loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
				<!--- Restore all collection files in the trash --->
				<cfelseif session.type EQ "restoreallcollectionfiles">
					<cfset _attr.onclick = "loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
				<!--- Restore selected collection files in the trash --->
				<cfelseif session.type EQ "restoreselectedcolfiles">
					<cfset _attr.onclick = "loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
				<!--- choose a folder for restore collection --->
				<cfelseif session.type EQ "restore_collection">
					<cfset _attr.onclick = "loadcontent('collections','index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
				<!--- Restore all collections in the trash --->
				<cfelseif session.type EQ "restoreallcollections">
					<cfset _attr.onclick = "$('##rightside').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
				<!--- Restore selected collections  --->
				<cfelseif session.type EQ "restoreselectedcollection">
					<cfset _attr.onclick = "loadcontent('collections','index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
				<!--- Restore collection folder in the trash --->
				<cfelseif session.type EQ "restorecolfolder">
					<cfset _attr.onclick = "loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
				<!--- Restore all collection folder in the trash --->
				<cfelseif session.type EQ "restorecolfolderall">
					<cfset _attr.onclick = "$('##rightside').load('index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
				<!--- Restore all collection folder in the trash --->
				<cfelseif session.type EQ "restoreselectedcolfolder">
					<cfset _attr.onclick = "loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
				<!--- copy metadata --->
				<cfelseif session.type EQ "copymetadata">
					<cfset _attr.onclick = "loadcontent('result','index.cfm?fa=#session.savehere#&folder_id=#folder_id#&what=#session.thetype#&fid=#session.file_id#');destroywindow(2);return false;">
				<!--- Plugin --->
				<cfelseif session.type EQ "plugin">
					<cfset _attr.onclick = "$('##wf_folder_id_2').val('#folder_id#'); $('##wf_folder_name_2').val('#Encodeforjavascript(folder_name)#');destroywindow(1);">
				<!--- From Smart Folder --->
				<cfelseif session.type EQ "sf_download">
					<cfset _attr.onclick = "$('##div_forall').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');$('##div_choosefolder_status_#session.tmpid#').html('All file(s) are going to be downloaded now and stored in the chosen folder!');return false;">
				<!--- Alias --->
				<cfelseif session.type EQ "alias">
					<cfif session.thefolderorg NEQ folder_id>
						<cfif arguments.kind EQ "search">
							<cfset _attr.onclick = "$('##div_choosefolder_status_#session.tmpid#').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#&folder_name=#URLEncodedFormat(folder_name)#', function(){$('##div_choosefolder_status_#session.tmpid#').html('The alias has been created in the selected folder.<br />Note: If you want to create an alias for the same file(s) in another folder simply select it from the list above!<br />You can close this window.');});">
						<cfelse>
							<cfset _attr.onclick = "$('##div_forall').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#', function(){$('##div_choosefolder_status_#session.tmpid#').html('The alias has been created in the selected folder.<br />Note: If you want to create an alias for the same file(s) in another folder simply select it from the list above!<br />You can close this window.');});">
						</cfif>
					</cfif>
				</cfif>

				<cfset _node[_row].a_attr = _attr >

				<!--- Increase --->
				<cfset _row = _row + 1>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
	</cfif>
	<!---
	<cfset consoleoutput(true)>
	<cfloop array="#_node#" item="a" index='i'>
		<cfset console(a)>
	</cfloop>
	<cfdump var="#_node#">
	<cfabort>
	--->
	<cfreturn _node />
</cffunction>

<!--- Clean folderid of it is a collection --->
<cffunction name="cleanid" access="public" output="true">
	<cfargument name="id" type="string">
	<cfset var theid = listlast(arguments.id, "-")>
	<cfreturn theid>
</cffunction>

<!--- Share: Check on folder permissions --->
<cffunction name="sharecheckperm" output="true">
	<cfargument name="thestruct" type="struct" required="true">
	<!--- Param --->
	<cfset var shared = structnew()>
	<cfparam name="session.theuserid" default="">
	<cfparam name="session.iscol" default="F">
	<cfset var qry = "">
	<!--- Check if folder is even shared or not --->
	<cfif session.iscol EQ "F">
		<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#sharecheckperm */ folder_shared shared
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.fid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfelse>
		<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#sharecheckperm2 */ col_shared shared
		FROM #session.hostdbprefix#collections
		WHERE col_id = <cfqueryparam value="#arguments.thestruct.fid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfif>
	<!--- Set qry in struct --->
	<cfset shared.sharedfolder = qry.shared>
	<!--- If the folder is shared, check if the folder is for everyone --->
	<cfif qry.shared EQ "T">
		<cfif session.iscol EQ "F">
			<cfquery datasource="#variables.dsn#" name="qryfolder" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#sharecheckperm3 */ grp_id_r
			FROM #session.hostdbprefix#folders_groups
			WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.fid#" cfsqltype="CF_SQL_VARCHAR">
			AND grp_id_r = <cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<cfelse>
			<cfquery datasource="#variables.dsn#" name="qryfolder" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#sharecheckperm4 */ grp_id_r
			FROM #session.hostdbprefix#collections_groups
			WHERE col_id_r = <cfqueryparam value="#arguments.thestruct.fid#" cfsqltype="CF_SQL_VARCHAR">
			AND grp_id_r = <cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
		<!--- If the folder has the group 0 (everyone) --->
		<cfif qryfolder.recordcount EQ 1>
			<cfset shared.everyone = "T">
		<cfelse>
			<cfset shared.everyone = "F">
		</cfif>
	<cfelse>
		<cfset shared.everyone = "F">
	</cfif>
	<!--- Return --->
	<cfreturn shared>
</cffunction>

<!--- Share: Check for folder permissions --->
<cffunction name="sharecheckpermfolder" access="public" output="true">
	<cfargument name="fid" type="string">
	<cfset var qry = "">
	<!--- Query --->
	<cfif session.iscol EQ "F">
		<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#sharecheckpermfolder */ folder_id,
			<!--- Permission follow but not for sysadmin and admin --->
			<cfif not session.is_system_admin and not session.is_administrator>
				CASE
					WHEN EXISTS(
						SELECT fg.folder_id_r
						FROM #session.hostdbprefix#folders_groups fg INNER JOIN ct_groups_users gu ON gu.ct_g_u_grp_id = fg.grp_id_r AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
						WHERE fg.folder_id_r = f.folder_id
						AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						) THEN 'unlocked'
					<!--- If this is the user folder or he is the owner --->
					WHEN ( f.folder_of_user = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
					<!--- If this is the upload bin
					WHEN f.folder_id = 1 THEN 'unlocked' --->
					<!--- If this is a collection
					WHEN lower(f.folder_is_collection) = 't' THEN 'unlocked' --->
					<!--- If nothing meets the above lock the folder --->
					ELSE 'locked'
				END AS perm
			<cfelse>
				'unlocked' AS perm
			</cfif>
		FROM #session.hostdbprefix#folders f
		WHERE f.folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.fid#">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfelse>
		<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#sharecheckpermfolder */ col_id,
			<!--- Permission follow but not for sysadmin and admin --->
			<cfif not session.is_system_admin and not session.is_administrator>
				CASE
					WHEN EXISTS(
						SELECT fg.col_id_r
						FROM #session.hostdbprefix#collections_groups fg INNER JOIN ct_groups_users gu ON gu.ct_g_u_grp_id = fg.grp_id_r AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
						WHERE fg.col_id_r = f.col_id
						AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						) THEN 'unlocked'
					<!--- If this is the user folder or he is the owner --->
					WHEN ( f.col_owner = '#Session.theUserID#' ) THEN 'unlocked'
					<!--- If nothing meets the above lock the folder --->
					ELSE 'locked'
				END AS perm
			<cfelse>
				'unlocked' AS perm
			</cfif>
		FROM #session.hostdbprefix#collections f
		WHERE f.col_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.fid#">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfif>
	<cfoutput>#qry.perm#</cfoutput>
	<cfset request.shareperm_fldr = qry.perm>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Sharing for selected assets --->
<cffunction name="batch_sharing" output="true">
	<cfargument name="thestruct" type="struct" required="true">
	<cfset var qry = "">
	<!--- Loop over the file ids --->
	<cfloop list="#arguments.thestruct.file_ids#" index="i">
		<!--- Get the ID and the type --->
		<cfset var theid = listfirst(i,"-")>
		<cfset var thetype = listlast(i,"-")>
		<!--- Decide on the type what to do --->
		<!--- DOCUMENTS --->
		<cfif thetype EQ "doc">
			<!--- Save sharing state --->
			<cfquery datasource="#variables.dsn#">
            UPDATE #session.hostdbprefix#files
            SET shared = <cfqueryparam value="#arguments.thestruct.state#" cfsqltype="cf_sql_varchar">
            WHERE file_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
            AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Get filename --->
			<cfquery datasource="#variables.dsn#" name="qry">
			SELECT file_name_org
			FROM #session.hostdbprefix#files
			WHERE file_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<!--- IMAGES --->
		<cfelseif thetype EQ "img">
			<!--- Save sharing state --->
			<cfquery datasource="#variables.dsn#">
            UPDATE #session.hostdbprefix#images
            SET shared = <cfqueryparam value="#arguments.thestruct.state#" cfsqltype="cf_sql_varchar">
            WHERE img_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
            </cfquery>
			<cfquery datasource="#variables.dsn#" name="qry">
			SELECT img_filename_org, thumb_extension
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Get all related records --->
			<cfquery datasource="#variables.dsn#" name="qryrel">
			SELECT folder_id_r, img_id, img_filename_org, thumb_extension
			FROM #session.hostdbprefix#images
			WHERE img_group = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<!--- VIDEOS --->
		<cfelseif thetype EQ "vid">
			<!--- Save sharing state --->
			<cfquery datasource="#variables.dsn#">
            UPDATE #session.hostdbprefix#videos
            SET shared = <cfqueryparam value="#arguments.thestruct.state#" cfsqltype="cf_sql_varchar">
            WHERE vid_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
            </cfquery>
			<cfquery datasource="#variables.dsn#" name="qry">
			SELECT vid_name_org
			FROM #session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Get all related records --->
			<cfquery datasource="#variables.dsn#" name="qryrel">
			SELECT folder_id_r, vid_id, vid_name_org
			FROM #session.hostdbprefix#videos
			WHERE vid_group = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
	</cfloop>
</cffunction>

<!--- Get foldername --->
<cffunction name="getfoldername" output="false">
	<cfargument name="folder_id" required="yes" type="string">
	<cfset var qry = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfoldername */ folder_name
	FROM #session.hostdbprefix#folders
	WHERE folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry.folder_name>
</cffunction>

<!--- Get username of folder --->
<cffunction name="getusername" output="false">
	<cfargument name="folder_id" required="yes" type="string">
	<cfset var qry = "">
	<!--- Param --->
	<cfset var x = structnew()>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getusername */ u.user_first_name, u.user_last_name, f.folder_owner
	FROM #session.hostdbprefix#folders f LEFT JOIN users u ON f.folder_owner = u.user_id
	WHERE f.folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Check --->
	<cfif qry.recordcount EQ 0>
		<cfset x.user = "User not found">
		<cfset x.folder_owner = 0>
	<cfelse>
		<cfset x.user = qry.user_first_name & " " & qry.user_last_name>
		<cfset x.folder_owner = qry.folder_owner>
	</cfif>
	<cfreturn x>
</cffunction>

<!--- Save the combined view --->
<cffunction name="combined_save" output="false">
	<cfargument name="thestruct" type="struct" required="true">
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="combined_save_thread" thestruct="#attributes.intstruct#" />
	</cfthread>
	<cfreturn />
</cffunction>

<!--- THREAD: Save the combined view --->
<cffunction name="combined_save_thread" output="true">
	<cfargument name="thestruct" type="struct" required="true">
	<!--- Param --->
	<cfset var docid = 0>
	<cfset var audid = 0>
	<cfset var imgid = 0>
	<cfset var vidid = 0>
	<!--- Loop over the form fields --->
	<cfloop delimiters="," index="myform" list="#arguments.thestruct.fieldnames#">
		<!--- Images --->
		<cfif myform CONTAINS "img_">
			<!--- First part of the _ --->
			<cfset var theid = listfirst(myform,"_")>
			<cfif imgid NEQ theid>
				<!--- Set the file name --->
				<cfset var fname = theid & "_img_filename">
				<!--- Set the description --->
				<cfset var fdesc = theid & "_img_desc_1">
				<!--- Set the keywords --->
				<cfset var fkeys = theid & "_img_keywords_1">
				<!--- Finally update the record --->
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#images
				SET
				img_filename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fname#"]#">,
				is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- And the keywords & desc --->
				<cfquery datasource="#variables.dsn#" name="here_img">
				SELECT img_id_r
				FROM #session.hostdbprefix#images_text
				WHERE img_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				</cfquery>
				<cfif here_img.recordcount NEQ 0>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#images_text
					SET
					img_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
					<cfif trim(form["#fkeys#"]) EQ ",">
						img_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="">
					<cfelse>
						img_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">
					</cfif>
					WHERE img_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
					AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
					</cfquery>
				<cfelse>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#images_text
					(id_inc, img_description, img_keywords, img_id_r, lang_id_r, host_id)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid('')#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				</cfif>
				<!--- Call XMP to write metadata --->
				<cfset arguments.thestruct.file_id = theid>
				<cfset arguments.thestruct.img_keywords = form["#fkeys#"]>
				<cfset arguments.thestruct.img_desc = form["#fdesc#"]>
				<cfset arguments.thestruct.batch_replace = false>
				<cfinvoke component="xmp" method="xmpwritethread" thestruct="#arguments.thestruct#" />
				<!--- Store the id in a temp var --->
				<cfset var imgid = theid>
				<cfset arguments.thestruct.theid = theid>
				<!--- Execute workflow --->
				<cfset arguments.thestruct.fileid = arguments.thestruct.theid>
				<cfset arguments.thestruct.file_name = #form["#fname#"]#>
				<cfset arguments.thestruct.thefiletype = "img">
				<cfset arguments.thestruct.folder_id = arguments.thestruct.folder_id>
				<cfset arguments.thestruct.folder_action = false>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
				<cfset arguments.thestruct.folder_action = true>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
			</cfif>
		<!--- Videos --->
		<cfelseif myform CONTAINS "vid_">
			<!--- First part of the _ --->
			<cfset var theid = listfirst(myform,"_")>
			<cfif vidid NEQ theid>
				<!--- Set the file name --->
				<cfset var fname = theid & "_vid_filename">
				<!--- Set the description --->
				<cfset var fdesc = theid & "_vid_desc_1">
				<!--- Set the keywords --->
				<cfset var fkeys = theid & "_vid_keywords_1">
				<!--- If the keyword only contains a then empty it --->
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#videos
				SET
				vid_filename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fname#"]#">,
				is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- And the keywords & desc --->
				<cfquery datasource="#variables.dsn#" name="here_vid">
				SELECT vid_id_r
				FROM #session.hostdbprefix#videos_text
				WHERE vid_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfif here_vid.recordcount NEQ 0>
					<!--- And the keywords & desc --->
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#videos_text
					SET
					vid_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
					<cfif trim(form["#fkeys#"]) EQ ",">
						vid_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="">
					<cfelse>
						vid_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">
					</cfif>
					WHERE vid_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
					AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				<cfelse>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#videos_text
					(id_inc, vid_description, vid_keywords, vid_id_r, lang_id_r, host_id)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid('')#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				</cfif>
				<!--- Store the id in a temp var --->
				<cfset var vidid = theid>
				<cfset arguments.thestruct.theid = theid>
				<!--- Execute workflow --->
				<cfset arguments.thestruct.fileid = arguments.thestruct.theid>
				<cfset arguments.thestruct.file_name = #form["#fname#"]#>
				<cfset arguments.thestruct.thefiletype = "vid">
				<cfset arguments.thestruct.folder_id = arguments.thestruct.folder_id>
				<cfset arguments.thestruct.folder_action = false>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
				<cfset arguments.thestruct.folder_action = true>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
			</cfif>
		<!--- Audios --->
		<cfelseif myform CONTAINS "aud_">
			<!--- First part of the _ --->
			<cfset var theid = listfirst(myform,"_")>
			<cfif audid NEQ theid>
				<!--- Set the file name --->
				<cfset var fname = theid & "_aud_filename">
				<!--- Set the description --->
				<cfset var fdesc = theid & "_aud_desc_1">
				<!--- Set the keywords --->
				<cfset var fkeys = theid & "_aud_keywords_1">
				<!--- If the keyword only contains a then empty it --->
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#audios
				SET
				aud_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fname#"]#">,
				is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE aud_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfquery datasource="#variables.dsn#" name="here_aud">
				SELECT aud_id_r
				FROM #session.hostdbprefix#audios_text
				WHERE aud_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfif here_aud.recordcount NEQ 0>
					<!--- And the keywords & desc --->
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#audios_text
					SET
					aud_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
					<cfif trim(form["#fkeys#"]) EQ ",">
						aud_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="">
					<cfelse>
						aud_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">
					</cfif>
					WHERE aud_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
					AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
					</cfquery>
				<cfelse>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#audios_text
					(id_inc, aud_description, aud_keywords, aud_id_r, lang_id_r, host_id)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid('')#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				</cfif>
				<!--- Store the id in a temp var --->
				<cfset var audid = theid>
				<cfset arguments.thestruct.theid = theid>
				<!--- Execute workflow --->
				<cfset arguments.thestruct.fileid = arguments.thestruct.theid>
				<cfset arguments.thestruct.file_name = #form["#fname#"]#>
				<cfset arguments.thestruct.thefiletype = "aud">
				<cfset arguments.thestruct.folder_id = arguments.thestruct.folder_id>
				<cfset arguments.thestruct.folder_action = false>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
				<cfset arguments.thestruct.folder_action = true>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
			</cfif>
		<!--- Files --->
		<cfelseif myform CONTAINS "doc_">
			<!--- First part of the _ --->
			<cfset var theid = listfirst(myform,"_")>
			<cfif docid NEQ theid>
				<!--- Set the file name --->
				<cfset var fname = theid & "_doc_filename">
				<!--- Set the description --->
				<cfset var fdesc = theid & "_doc_desc_1">
				<!--- Set the keywords --->
				<cfset var fkeys = theid & "_doc_keywords_1">
				<!--- If the keyword only contains a then empty it --->
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#files
				SET
				file_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fname#"]#">,
				is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- And the keywords & desc --->
				<cfquery datasource="#variables.dsn#" name="here_doc">
				SELECT file_id_r
				FROM #session.hostdbprefix#files_desc
				WHERE file_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfif here_doc.recordcount NEQ 0>
					<cfquery datasource="#variables.dsn#">
					UPDATE #session.hostdbprefix#files_desc
					SET
					file_desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
					<cfif trim(form["#fkeys#"]) EQ ",">
						file_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="">
					<cfelse>
						file_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">
					</cfif>
					WHERE file_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
					AND lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				<cfelse>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#files_desc
					(id_inc, file_desc, file_keywords, file_id_r, lang_id_r, host_id)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid('')#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fdesc#"]#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#form["#fkeys#"]#">,
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					)
					</cfquery>
				</cfif>
				<!--- Store the id in a temp var --->
				<cfset var docid = theid>
				<cfset arguments.thestruct.theid = theid>
				<!--- Execute workflow --->
				<cfset arguments.thestruct.fileid = arguments.thestruct.theid>
				<cfset arguments.thestruct.file_name = #form["#fname#"]#>
				<cfset arguments.thestruct.thefiletype = "doc">
				<cfset arguments.thestruct.folder_id = arguments.thestruct.folder_id>
				<cfset arguments.thestruct.folder_action = false>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
				<cfset arguments.thestruct.folder_action = true>
				<cfinvoke component="plugins" method="getactions" theaction="on_file_edit" args="#arguments.thestruct#" />
			</cfif>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("audios")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("search")>
	<cfset resetcachetoken("folders")>
	<cfreturn />
</cffunction>

<!--- LINK: Check Folder --->
<cffunction name="link_check" output="false">
	<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfset var status = structnew()>
		<cfset status.dir = false>
		<!--- Does the dir contain /home --->
		<cfif (application.razuna.isp AND ListContains(arguments.thestruct.link_path, 'home', '/\') AND directoryexists("#arguments.thestruct.link_path#")) OR (!application.razuna.isp AND directoryexists("#arguments.thestruct.link_path#"))>
			<!--- Set to true --->
			<cfset status.dir = true>
			<!--- List the content of the Dir --->
			<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir">
			<!--- Count the files --->
			<cfquery dbtype="query" name="status.countfiles">
			SELECT count(name) thecount
			FROM thedir
			WHERE type = 'File'
			AND attributes != 'H'
			</cfquery>
			<!--- Count the dirs --->
			<cfquery dbtype="query" name="status.countdirs">
			SELECT count(name) thecount
			FROM thedir
			WHERE type = 'Dir'
			AND attributes != 'H'
			</cfquery>
		</cfif>
	<cfreturn status>
</cffunction>

<!--- Get Subfolders --->
<cffunction name="getsubfolders" output="false">
	<cfargument name="folder_id" type="string" required="true">
	<cfargument name="external" type="string" required="false">
	<cfargument name="folder_name" type="string" required="false">
	<!--- If there is no session for webgroups set --->
	<cfparam default="0" name="session.thegroupofuser">
	<cfset var qry = "">
	<cfset var qRet = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getsubfolders */ f.folder_id, f.folder_name, f.folder_id_r, f.folder_of_user, f.folder_owner, f.folder_level, <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username,
	<!--- Permission follow but not for sysadmin and admin --->
	<cfif session.is_system_admin AND NOT session.is_administrator AND NOT structkeyexists(arguments,"external")>
		CASE
			<!--- Check permission on this folder --->
			WHEN EXISTS(
				SELECT fg.folder_id_r
				FROM #session.hostdbprefix#folders_groups fg
				WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg.folder_id_r = f.folder_id
				AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				) THEN 'unlocked'
			<!--- When folder is shared for everyone --->
			WHEN EXISTS(
				SELECT fg2.folder_id_r
				FROM #session.hostdbprefix#folders_groups fg2
				WHERE fg2.grp_id_r = '0'
				AND fg2.folder_id_r = f.folder_id
				AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg2.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				) THEN 'unlocked'
			<!--- If this is the user folder or he is the owner --->
			WHEN ( f.folder_of_user = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
			<!--- If this is the upload bin --->
			WHEN f.folder_id = '1' THEN 'unlocked'
			<!--- If this is a collection --->
			<!--- WHEN lower(f.folder_is_collection) = 't' THEN 'unlocked' --->
			<!--- If nothing meets the above lock the folder --->
			ELSE 'locked'
		END AS perm
	<cfelse>
		'unlocked' AS perm
	</cfif>
	, '0' as filecount
	FROM #session.hostdbprefix#folders f LEFT JOIN users u ON u.user_id = f.folder_owner
	WHERE
	<cfif arguments.folder_id gt 0>
		f.folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
		AND
		f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	<cfelse>
		f.folder_id = f.folder_id_r
	</cfif>
	AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
	<!--- filter user folders, but not for collections --->
	<cfif session.is_system_admin AND NOT session.is_administrator AND NOT structkeyexists(arguments,"external")>
		AND
			(
			<cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(f.folder_of_user,<cfqueryparam cfsqltype="cf_sql_varchar" value="f">) <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			OR f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
			)
	</cfif>
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	<cfif structkeyexists(arguments,"folder_name") AND arguments.folder_name NEQ ''>
   	 	AND f.folder_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folder_name#%">
	</cfif>
	ORDER BY folder_name
	</cfquery>
	<!--- Query to get unlocked folders only --->
	<cfquery dbtype="query" name="qRet">
	SELECT *, folder_id as count_folder_id
	FROM qry
	WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
	</cfquery>
	<!--- Loop over folders and get the total count of each folder --->
	<cfloop query="qRet">
		<!--- Get total count of this folder --->
		<cfset var _filecount = filetotalcount(folder_id=count_folder_id)>
		<!--- Add count to final query --->
		<cfset querySetCell(qRet, "filecount", _filecount.thetotal, currentRow)>
	</cfloop>
	<cfreturn qret>
</cffunction>

<!--- Get folder breadcrumb (backwards) --->
<cffunction name="getbreadcrumb" output="false">
	<cfargument name="folder_id_r" required="yes" type="string">
	<cfargument name="folderlist" required="false" type="string" default="">
	<cfargument name="fromshare" required="false" type="string" default="false">
	<cfargument name="dsn" type="string" default="#application.razuna.datasource#" required="false">
	<cfargument name="prefix" type="string" default="#session.hostdbprefix#" required="false">
	<cfargument name="hostid" type="string" default="#session.hostid#" required="false">
	<cftry>
		<!--- Params --->
		<cfset var qry = "">
		<cfset var qryshared = "">
		<cfset var checkperm = false>
		<cfparam name="flist" default="">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("folders")>
		<!--- For share --->
		<cfif arguments.fromshare>
			<!--- If we come from share we need to check perm --->
			<cfset var checkperm = true>
			<!--- If there is no session for webgroups set --->
			<cfparam default="0" name="session.thegroupofuser">
			<!--- Grab the the stop folderid which is the folder id of the shared one but one above --->
			<cfquery datasource="#arguments.dsn#" name="qryshared" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getrootfolderidshared */ folder_id_r
			FROM #arguments.prefix#folders
			WHERE folder_id = <cfqueryparam value="#session.fid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Check the permission settings of a widget --->
			<cfif structKeyExists(session,"widget_id")>
				<cfset s = structnew()>
				<cfset s.widget_id = session.widget_id>
				<cfset s.external = "t">
				<!--- This return the permission in widget_permission / g = folder permissions --->
				<cfinvoke component="widgets" method="detail" thestruct="#s#" returnvariable="qry_widget" />
				<!--- if widget is set to check on folder permission then true else false --->
				<cfif qry_widget.widget_permission NEQ "g">
					<cfset var checkperm = false>
				</cfif>
			</cfif>
		</cfif>
		<!--- Query: Get current folder_id_r --->
		<cfquery datasource="#arguments.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getbreadcrumb */ f.folder_name, f.folder_id_r, f.folder_id
		<cfif checkperm>
			<cfif session.iscol EQ "F">
				,
				CASE
					<!--- Check permission on this folder --->
					WHEN EXISTS(
						SELECT fg.folder_id_r
						FROM #arguments.prefix#folders_groups fg
						WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
						AND fg.folder_id_r = f.folder_id
						AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
						) THEN 'unlocked'
					<!--- When folder is shared for everyone --->
					WHEN EXISTS(
						SELECT fg2.folder_id_r
						FROM #arguments.prefix#folders_groups fg2
						WHERE fg2.grp_id_r = '0'
						AND fg2.folder_id_r = f.folder_id
						AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
						AND fg2.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						) THEN 'unlocked'
					<!--- If this is the user folder or he is the owner --->
					WHEN ( f.folder_of_user = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
					<!--- If nothing meets the above lock the folder --->
					ELSE 'locked'
				END AS perm
			<cfelse>
				CASE
					WHEN EXISTS(
						SELECT fg.col_id_r
						FROM #arguments.prefix#collections_groups fg
						WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
						AND fg.col_id_r = f.col_id
						AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
						) THEN 'unlocked'
					<!--- If nothing meets the above lock the folder --->
					ELSE 'locked'
				END AS perm
			</cfif>
		</cfif>
		FROM #arguments.prefix#folders f
		WHERE f.folder_id = <cfqueryparam value="#arguments.folder_id_r#" cfsqltype="CF_SQL_VARCHAR">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
		</cfquery>
		<!--- QoQ do not do it if system or admin meaning return all folders --->
		<cfif checkperm AND (NOT session.is_system_admin AND NOT session.is_administrator)>
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qry
			WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
			</cfquery>
		</cfif>
		<!--- No recursivness if no more records --->
		<cfif qry.recordcount NEQ 0>
			<!--- Set the current values into the list --->
			<cfset flist = qry.folder_name & "|" & qry.folder_id & "|" & qry.folder_id_r & ";" & arguments.folderlist>
			<!--- If the folder_id_r is not the same the passed one --->
			<cfif qry.folder_id_r NEQ arguments.folder_id_r>
				<!--- Call this function again (need component otherwise it won't work for internal calls) --->
				<cfinvoke component="folders" returnvariable="flist" method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" folderlist="#flist#" fromshare="#arguments.fromshare#" dsn="#arguments.dsn#" prefix="#arguments.prefix#" hostid="#arguments.hostid#" />
			</cfif>
		<cfelse>
			<!--- Set the current values into the list --->
			<cfset flist = arguments.folderlist>
		</cfif>
		<!--- Return --->
		<cfreturn flist>
		<cfcatch type="any">
			<cfset consoleoutput(true)>
			<cfset console(cfcatch)>
		</cfcatch>
	</cftry>
</cffunction>

<!--- Download Folder --->
<cffunction name="download_folder" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<cfinvoke component="defaults" method="trans" transid="download_folder_output" returnvariable="download_folder_output" />
	<!--- Feedback --->
	<cfoutput><br/><strong>#download_folder_output#</strong><br /></cfoutput>
	<cfflush>
	<!--- Params --->
	<cfset var thisstruct = structnew()>
	<cfparam name="arguments.thestruct.awsbucket" default="" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<cftry>
		<!--- Set time for remove --->
		<cfset var removetime = DateAdd("h", -2, "#now()#")>
		<!--- Remove old directories --->
		<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing" name="thedirs">
		<!--- Loop over dirs --->
		<cfloop query="thedirs">
			<!--- If a directory --->
			<cfif type EQ "dir" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#name#" recurse="true" mode="775">
			<cfelseif type EQ "file" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#name#">
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while removing outgoing folders in function folders.download_folder">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Create directory --->
	<cfset var basketname = createuuid("")>
	<cfset arguments.thestruct.newpath = arguments.thestruct.thepath & "/outgoing/#basketname#">
	<cfdirectory action="create" directory="#arguments.thestruct.newpath#" mode="775">
	<!--- Create folders according to selection and download --->
	<!--- Thumbnails --->
	<cfif arguments.thestruct.download_thumbnails>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="download_folder_output4" returnvariable="download_folder_output4" />
		<cfoutput>#download_folder_output4#<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/thumbnails" mode="775">
		<!--- Download thumbnails --->
		<cfinvoke method="download_selected" dl_thumbnails="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#/thumbnails" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Originals --->
	<cfif arguments.thestruct.download_originals>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="download_folder_output5" returnvariable="download_folder_output5" />
		<cfoutput>#download_folder_output5#<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/originals" mode="775">
		<!--- Download originals --->
		<cfinvoke method="download_selected" dl_originals="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#/originals" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Renditions --->
	<cfif arguments.thestruct.download_renditions>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="download_folder_output6" returnvariable="download_folder_output6" />
		<cfoutput>#download_folder_output6#<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/renditions" mode="775">
		<!--- Download renditions --->
		<cfinvoke method="download_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#/renditions" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- RAZ-2831 : Move metadata export into folder --->
	<cfif arguments.thestruct.prefs.set2_meta_export EQ 't'>
		<cfif isdefined("arguments.thestruct.exportname")>
			<cfset var suffix = "#arguments.thestruct.exportname#">
		<cfelse>
			<cfset var suffix = "#session.hostid#-#session.theuserid#">
		</cfif>
		<cfif fileExists("#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv")>
			<cffile action="move" destination="#arguments.thestruct.newpath#" source="#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv">
		</cfif>
	</cfif>
	<!--- Feedback --->
	<cfinvoke component="defaults" method="trans" transid="download_folder_output2" returnvariable="download_folder_output2" />
	<cfoutput>#download_folder_output2#<br /></cfoutput>
	<cfflush>

	<!--- Put zip in a thread. This will force page to wait insted of timing out while zipping large files --->
	<cfset var tt=createUUID()>
	<!--- All done. ZIP and finish --->
	<cfthread action="run" intvar="#arguments.thestruct#" name="#tt#">
		<cfzip action="create" ZIPFILE="#attributes.intvar.thepath#/outgoing/folder_#attributes.intvar.folder_id#.zip" source="#attributes.intvar.newpath#" recurse="true"/>
	</cfthread>
	<!--- Get thread status --->
	<cfset var thethread=cfthread["#tt#"]>
	<!--- Output to page to prevent it from timing out while thread is running --->
	<cfloop condition="#thethread.status# EQ 'RUNNING' OR thethread.Status EQ 'NOT_STARTED' "> <!--- Wait till thread is finished --->
		<cfoutput> . </cfoutput>
		<cfset sleep(3000) >
		<cfflush>
	</cfloop>
	<cfthread action="join" name="#tt#"/>

	<!--- Zip path for download --->
	<cfinvoke component="defaults" method="trans" transid="download_folder_output3" returnvariable="download_folder_output3" />
	<cfoutput><p><a href="outgoing/folder_#arguments.thestruct.folder_id#.zip"><strong style="color:green;">#download_folder_output3#</strong></a></p></cfoutput>
	<cfflush>
	<!--- Remove the temp folder --->
	<cfdirectory action="delete" directory="#arguments.thestruct.newpath#" recurse="yes" />
</cffunction>

<!--- Select and download --->
<cffunction name="download_selected" output="false">
	<cfargument name="dl_thumbnails" default="false" required="false">
	<cfargument name="dl_originals" default="false" required="false">
	<cfargument name="dl_renditions" default="false" required="false">
	<cfargument name="dl_query" required="true" type="query">
	<cfargument name="dl_folder" required="true" type="string">
	<cfargument name="assetpath" required="true" type="string">
	<cfargument name="awsbucket" required="false" type="string">
	<cfargument name="rend_av" required="false" type="string" default="f">
	<cfargument name="thestruct" required="false" type="struct">
	<!--- Params --->
	<cfparam name="arguments.thestruct.akaimg" default="" />
	<cfparam name="arguments.thestruct.akavid" default="" />
	<cfparam name="arguments.thestruct.akaaud" default="" />
	<cfparam name="arguments.thestruct.akadoc" default="" />
	<!--- RAZ-2906: Get the dam settings --->
	<cfinvoke component="global.cfc.settings"  method="getsettingsfromdam" returnvariable="arguments.thestruct.getsettings" />
	<cfset var count = 1>
	<!--- If we are renditions we query again and set some variables --->
	<cfif arguments.dl_renditions>
		<!--- RAZ-2901 : Check for additional renditions --->
		<cfif rend_av EQ 'f'>
			<!--- Set original --->
			<cfset arguments.dl_originals = true>
			<!--- Query with group values --->
			<cfquery name="arguments.dl_query" datasource="#application.razuna.datasource#">
			SELECT img_filename filename, img_filename_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'img' as kind
			FROM #session.hostdbprefix#images
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND img_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(arguments.dl_query.id)#" list="Yes">)
				AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			UNION ALL
			SELECT vid_filename filename, vid_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'vid' as kind
			FROM #session.hostdbprefix#videos
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND vid_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(arguments.dl_query.id)#" list="Yes">)
				AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			UNION ALL
			SELECT aud_name filename, aud_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'aud' as kind
			FROM #session.hostdbprefix#audios
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND aud_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(arguments.dl_query.id)#" list="Yes">)
			AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			</cfquery>
			<!--- RAZ-2901 : QoQ to change the sort order by filename --->
			<cfquery name="arguments.dl_query" dbtype="query">
				SELECT *
				FROM arguments.dl_query
				ORDER BY filename
			</cfquery>
		<cfelseif rend_av EQ 't'>
			<!--- RAZ-2901 : Get additional renditions --->
			<cfquery name="arguments.dl_query" datasource="#application.razuna.datasource#">
				SELECT av.av_id, av.av_type, av.av_link_url, av.av_link_title, av.folder_id_r, img_id, img_filename filename, img_filename_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'img' as kind
				FROM #session.hostdbprefix#images i
				INNER JOIN raz1_additional_versions av ON i.img_id = av.asset_id_r and av.av_link = 0
				WHERE i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND i.img_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valuelist(dl_query.id)#" list="yes">)
				AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT av.av_id, av.av_type, av.av_link_url, av.av_link_title, av.folder_id_r, vid_id, vid_filename filename, vid_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'vid' as kind
				FROM #session.hostdbprefix#videos v
				INNER JOIN raz1_additional_versions av ON v.vid_id = av.asset_id_r and av.av_link = 0
				WHERE v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND v.vid_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valuelist(dl_query.id)#" list="yes">)
				AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT av.av_id, av.av_type, av.av_link_url, av.av_link_title, av.folder_id_r, aud_id, aud_name filename, aud_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'aud' as kind
				FROM #session.hostdbprefix#audios a
				INNER JOIN raz1_additional_versions av ON a.aud_id = av.asset_id_r and av.av_link = 0
				WHERE a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND a.aud_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valuelist(dl_query.id)#" list="yes">)
				AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT av.av_id, av.av_type, av.av_link_url, av.av_link_title, av.folder_id_r, file_id, file_name filename, file_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'doc' as kind
				FROM #session.hostdbprefix#files f
				INNER JOIN raz1_additional_versions av ON file_id = av.asset_id_r and av.av_link = 0
				WHERE f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND f.file_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valuelist(dl_query.id)#" list="yes">)
				AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">

				ORDER BY av_link_title
			</cfquery>
	  	</cfif>
	</cfif>
	<!--- Loop over records --->
	<cfloop query="arguments.dl_query">
		<!--- Set var --->
		<cfset var theorgname = "">
		<!--- Feedback --->
		<cfif rend_av EQ 'f'>
		<cfoutput>. </cfoutput>
		</cfif>
		<cfflush>
		<!--- RAZ-2906 : Get custom file name and original file name --->
		<cfset var name = filename>
		<cfset var theext = listlast(filename_org,".")>
		<cfset var theorgext = theext>
		<cfset var orgname = replaceNoCase('#replacenocase(filename_org,".#theext#","")#','_',' ','all')>
		<!--- <cfset var orgname = replaceNoCase('#listfirst(filename_org,".")#','_',' ','all')> --->

		<!--- If we have to get thumbnails then the name is different --->
		<cfif arguments.dl_thumbnails AND kind EQ "img">
			<cfset var theorgname = "thumb_#id#.#ext#">
			<cfset var thefinalname = theorgname>
			<cfset var thiscloudurl = cloud_url>
			<cfset var theorgext = ext>
			<cfset var tn = listfirst(filename,".")>
			<cfset var thefinalname = theorgname>
		<cfelseif arguments.dl_originals>
			<cfset var theorgname = filename_org>
			<cfset var thefinalname = filename>
			<cfset var thiscloudurl = cloud_url_org>
			<cfset var theorgext = listlast(filename_org,".")>
			<!--- If rendition we append the currentrow number in order to have same renditions formats still work --->
			<cfif arguments.dl_renditions>
				<cfif find('.', filename_org)>
					<cfset var te = "." & listlast(filename_org,".")>
				<cfelse>
					<cfset var te = "">
				</cfif>
				<cfset var tn = replacenocase(filename,te,"")>
				<cfset var thefinalname = "rend_" & tn & te>
			</cfif>
		</cfif>
		<!--- RAZ-2901 : Check for additional renditions --->
		<cfif rend_av EQ 't'>
			<cfset var tn = listfirst(av_link_title,".")>
			<cfif find('.', av_link_url)>
				<cfset var te = "." & listlast(av_link_url,".")>
			<cfelse>
				<cfset var te = "">
			</cfif>
			<cfset var avid = av_id>
			<cfset var thefinalname = "add_rend_" & tn & "_#av_id#" & te>
			<cfset var filename_av = listlast('#av_link_url#','/')>
			<cfset var theorgname = filename_av>
			<cfset var fs = replacenocase('#av_link_url#','/','','one')>
			<cfset var link_url = replacenocase('#fs#','#filename_av#','')>
			<cfset var path_to_asset = reverse('#replacenocase('#reverse('#link_url#')#','/','','one')#')>
		</cfif>

		<cfset var the_org_ext = "." & theorgext>

		<!--- Start download but only if theorgname is not empty --->
		<cfif theorgname NEQ "">
			<!--- RAZ-2901 : Check for additional renditions --->
			<cfif rend_av EQ 'f'>
	        			<!--- Check if thefinalname has an extension. If not add the original one --->
	        			<cfif listlast(thefinalname,".") NEQ theorgext>
	        				<cfset var thefinalname = filename & "." & theorgext>
	        			</cfif>
	        			<!--- RAZ-2901 : Set Original Video name --->
				<cfif kind EQ 'vid'>
					<cfset var theorgname = filename_org>
					<cfset var thefinalname = filename>
					<cfset var theorgext = listlast(thefinalname,".")>
				</cfif>
				<cfif kind EQ 'vid' AND arguments.dl_renditions>
					<cfset var tn = listfirst(filename,".")>
					<cfif find('.', filename_org)>
					<cfset var te = "." & listlast(filename_org,".")>
					<cfelse>
						<cfset var te = "">
					</cfif>
					<cfset var thefinalname = "rend_" & tn & te>
				</cfif>
			</cfif>

			<!--- RAZ-2906: Check the settings for download assets with ext or not  --->
        			<!--- <cfif structKeyExists(arguments.thestruct.getsettings,"set2_custom_file_ext") AND arguments.thestruct.getsettings.set2_custom_file_ext EQ "false">
        					<cfif arguments.dl_renditions>
        						<!--- <cfset var thefinalname = replacenocase(thefinalname,".#theext#","","ALL")> --->
        						<cfset var thefinalname = thefinalname>
        					<cfelseif arguments.dl_thumbnails AND kind EQ "img">
        						<cfset var thefinalname = "thumb_#id#">
        					<cfelseif arguments.dl_originals>
        						<cfset var thefinalname = filename>
        					</cfif>
        					<cfset var the_org_ext = "">
        					<cfif listlast(thefinalname,".") neq theext>
						<cfset thefinalname = replacenocase(thefinalname, ".#theext#","ALL")>
					</cfif>
        			<cfelse>
        				<cfif listlast(thefinalname,".") neq theext>
					<cfset thefinalname = thefinalname & ".#theext#">
				</cfif>
        			</cfif> --->
        			<cfif rend_av EQ 'f' and not arguments.dl_thumbnails>
        				<!--- Add filename extension if missing --->
	        			<cfif listlast(thefinalname,".") neq theext>
					<cfset thefinalname = thefinalname & ".#theext#">
				</cfif>
			</cfif>

			<!--- RAZ-2901 : Rename if file already exists --->
			<cfif arguments.dl_renditions AND fileexists('#arguments.dl_folder#/#thefinalname#')>
				<cfset var thefinalname = "rend_" & tn & "_#count#" & te>
			<cfelseif arguments.dl_originals AND fileexists('#arguments.dl_folder#/#thefinalname#')>
				<cfset var thefinalname = replacenocase(thefinalname,'.'&listlast(thefinalname,'.'),'')  & "_#count#" &  the_org_ext>
			</cfif>

			<!--- convert the filename without space and foreign chars --->
			<cfinvoke component="global" method="cleanfilename" returnvariable="thefinalname" thename="#thefinalname#">

			<!--- Local --->
			<cfif application.razuna.storage EQ "local" AND link_kind EQ "">
				<cftry>
				<cffile action="copy" source="#arguments.assetpath#/#session.hostid#/#path_to_asset#/#theorgname#" destination="#arguments.dl_folder#/#thefinalname#" mode="775">
				<cfcatch type="any">
						<cfset cfcatch.custom_message = "File '#theorgname#' is missing">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
			<!--- Nirvanix --->
			<cfelseif application.razuna.storage EQ "nirvanix" AND link_kind EQ "">
				<cftry>
					<cfif thiscloudurl CONTAINS "http">
						<cfhttp url="#thiscloudurl#" file="#thefinalname#" path="#arguments.dl_folder#"></cfhttp>
					</cfif>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Nirvanix error on download in folder download in function folders.download_selected">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
			<!--- Akamai --->
			<cfelseif application.razuna.storage EQ "akamai" AND link_kind EQ "">
				<!--- Define the Akamai type --->
				<cfif kind EQ "img">
					<cfset var akatype = arguments.thestruct.akaimg>
				<cfelseif kind EQ "vid">
					<cfset var akatype = arguments.thestruct.akavid>
				<cfelseif kind EQ "aud">
					<cfset var akatype = arguments.thestruct.akaaud>
				<cfelse>
					<cfset var akatype = arguments.thestruct.akadoc>
				</cfif>
				<!--- For thumbnails we copy from local --->
				<cfif arguments.dl_thumbnails>
					<cffile action="copy" source="#arguments.assetpath#/#session.hostid#/#path_to_asset#/#theorgname#" destination="#arguments.dl_folder#/#thefinalname#" mode="775">
				<cfelse>
					<cftry>
						<cfhttp url="#arguments.thestruct.akaurl##akatype#/#thefinalname#" file="#thefinalname#" path="#arguments.dl_folder#"></cfhttp>
						<cfcatch type="any">
							<cfset cfcatch.custom_message = "Akamai error on download in folder download in function folders.download_selected">
							<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
						</cfcatch>
					</cftry>
				</cfif>
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND link_kind EQ "">
					<cfif rend_av EQ 't'>
						<cfset path_to_asset = "#folder_id_r#/#av_type#/#av_id#">
						<cfset theorgname = av_link_title>
					</cfif>
					<cfinvoke component="amazon" method="Download">
						<cfinvokeargument name="key" value="/#path_to_asset#/#theorgname#">
						<cfinvokeargument name="theasset" value="#arguments.dl_folder#/#thefinalname#">
						<cfinvokeargument name="awsbucket" value="#arguments.awsbucket#">
					</cfinvoke>
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif link_kind EQ "url">
				<cffile action="write" file="#arguments.dl_folder#/#thefinalname#.txt" output="This asset is located on a external source. Here is the direct link to the asset:#link_path_url#" mode="775">
			<!--- If this is a linked asset --->
			<cfelseif link_kind EQ "lan">
				<cffile action="copy" source="#link_path_url#" destination="#arguments.dl_folder#/#thefinalname#" mode="775">
			</cfif>
			<!--- RAZ-2901 : Increment COUNT if previous filename is equal to current filename --->
			<cfif rend_av EQ 'f'>
				<cfif filename[currentrow-1] EQ filename[currentrow]>
					<cfset var count = count + 1>
				<cfelse>
					<cfset var count = 1>
				</cfif>
			</cfif>
		</cfif>
		<!--- Reset variables --->
		<cfset var theorgname = "">
		<cfset var thefinalname = "">
		<cfset var thiscloudurl = "">
	</cfloop>
	<!--- Feedback --->
	<cfoutput><br /></cfoutput>
	<cfflush>
</cffunction>


<!--- Store all values --->
<cffunction name="store_values" output="false" returntype="void">
	<cfargument name="thestruct" required="yes" type="struct">
	<!--- Get ids if this is a folder, folder_id set to 1 represents a collection --->
	<cfset var qry = "">
	<cfif arguments.thestruct.folder_id neq 1>
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		<cfif arguments.thestruct.thekind EQ "ALL" OR arguments.thestruct.thekind EQ "img">
			SELECT /* #variables.cachetoken#sv */ <cfif application.razuna.thedatabase EQ "mssql">img_id + '-img'<cfelse>concat(img_id,'-img')</cfif> as id
			FROM #session.hostdbprefix#images
			WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND (img_group IS NULL OR img_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			UNION
			SELECT /* #variables.cachetoken#sv */ <cfif application.razuna.thedatabase EQ "mssql">img_id + '-img'<cfelse>concat(img_id,'-img')</cfif> as id
			FROM #session.hostdbprefix#images i, ct_aliases ct
			WHERE i.img_id = ct.asset_id_r
			AND ct.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND (i.img_group IS NULL OR i.img_group = '')
			AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		</cfif>
		<cfif arguments.thestruct.thekind EQ "ALL">
			UNION ALL
		</cfif>
		<cfif arguments.thestruct.thekind EQ "ALL" OR arguments.thestruct.thekind EQ "vid">
			SELECT <cfif application.razuna.thedatabase EQ "mssql">vid_id + '-vid'<cfelse>concat(vid_id,'-vid')</cfif> as id
			FROM #session.hostdbprefix#videos
			WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND (vid_group IS NULL OR vid_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			UNION
			SELECT <cfif application.razuna.thedatabase EQ "mssql">vid_id + '-vid'<cfelse>concat(vid_id,'-vid')</cfif> as id
			FROM #session.hostdbprefix#videos v, ct_aliases ct
			WHERE v.vid_id = ct.asset_id_r
			AND ct.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND (v.vid_group IS NULL OR v.vid_group = '')
			AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		</cfif>
		<cfif arguments.thestruct.thekind EQ "ALL">
			UNION ALL
		</cfif>
		<cfif arguments.thestruct.thekind EQ "ALL" OR arguments.thestruct.thekind EQ "aud">
			SELECT <cfif application.razuna.thedatabase EQ "mssql">aud_id + '-aud'<cfelse>concat(aud_id,'-aud')</cfif> as id
			FROM #session.hostdbprefix#audios
			WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND (aud_group IS NULL OR aud_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			UNION
			SELECT <cfif application.razuna.thedatabase EQ "mssql">aud_id + '-aud'<cfelse>concat(aud_id,'-aud')</cfif> as id
			FROM #session.hostdbprefix#audios a, ct_aliases ct
			WHERE a.aud_id = ct.asset_id_r
			AND ct.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND (a.aud_group IS NULL OR a.aud_group = '')
			AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		</cfif>
		<cfif arguments.thestruct.thekind EQ "ALL">
			UNION ALL
		</cfif>
		<cfif arguments.thestruct.thekind EQ "ALL" OR (arguments.thestruct.thekind NEQ "vid" AND arguments.thestruct.thekind NEQ "img" AND arguments.thestruct.thekind NEQ "aud")>
			SELECT <cfif application.razuna.thedatabase EQ "mssql">file_id + '-doc'<cfelse>concat(file_id,'-doc')</cfif> as id
			FROM #session.hostdbprefix#files
			WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			<cfif arguments.thestruct.thekind EQ "other">
				AND file_extension NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
			<cfelseif arguments.thestruct.thekind NEQ "all">
				AND (
				file_extension = <cfqueryparam value="#arguments.thestruct.thekind#" cfsqltype="cf_sql_varchar">
				OR file_extension = <cfqueryparam value="#arguments.thestruct.thekind#x" cfsqltype="cf_sql_varchar">
				)
			</cfif>
			UNION
			SELECT <cfif application.razuna.thedatabase EQ "mssql">file_id + '-doc'<cfelse>concat(file_id,'-doc')</cfif> as id
			FROM #session.hostdbprefix#files f, ct_aliases ct
			WHERE f.file_id = ct.asset_id_r
			AND ct.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			<cfif arguments.thestruct.thekind EQ "other">
				AND f.file_extension NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
			<cfelseif arguments.thestruct.thekind NEQ "all">
				AND (
				f.file_extension = <cfqueryparam value="#arguments.thestruct.thekind#" cfsqltype="cf_sql_varchar">
				OR f.file_extension = <cfqueryparam value="#arguments.thestruct.thekind#x" cfsqltype="cf_sql_varchar">
				)
			</cfif>
		</cfif>
		</cfquery>
	<cfelse>
		<!--- Get ids if it is a collection --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT <cfif application.razuna.thedatabase EQ "mssql">file_id_r + '-' + col_file_type<cfelse>concat(file_id_r,'-',col_file_type)</cfif> as id
			FROM #session.hostdbprefix#collections_ct_files
			WHERE col_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.collection_id#">
		</cfquery>
	</cfif>
	<!--- Set the valuelist   --->
	<cfset var l = valuelist(qry.id)>
	<!--- Set the sessions --->
	<cfset session.file_id = l>
	<cfset session.thefileid = l>
	<cfset session.editids = l>
</cffunction>

<!--- Store selection --->
<cffunction name="store_selection" output="false" returntype="void">
	<cfargument name="thestruct" required="yes" type="struct">
	<!--- session --->
	<cfparam name="session.file_id" default="">
	<cfparam name="arguments.thestruct.del_file_id" default="">
	<!--- Check if files are individual selects --->
	<cfif isdefined("arguments.thestruct.individual_select") AND arguments.thestruct.individual_select EQ 'true'>
		<cfset session.individual_select = true>
	</cfif>
	<!--- Now simply add the selected fileids to the session --->
	<cfset session.file_id = "">
	<cfset session.file_id = listappend(session.file_id,"#arguments.thestruct.file_id#")>
	<cfset session.thefileid = session.file_id>
	<cfif session.file_id NEQ "">
		<cfset list_file_ids = "">
		<cfloop index="idx" from="1" to="#listlen(session.file_id)#">
			<!--- <cfif !listFindNoCase(#arguments.thestruct.del_file_id#,#listGetAt(session.file_id,idx)#)> --->
				<cfset list_file_ids = listAppend(list_file_ids,#listGetAt(session.file_id,idx)#,',')>
			<!--- </cfif> --->
		</cfloop>
		<cfset session.thefileid = list_file_ids>
		<cfset session.file_id = list_file_ids>
		<cfset session.editids = list_file_ids>
	</cfif>
</cffunction>

<!--- Same foldername check --->
<cffunction name="samefoldernamecheck" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<!--- Param --->
	<cfset var ishere = false>
	<cfset var qry = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfoldername */ folder_id
	FROM #session.hostdbprefix#folders
	WHERE folder_name = <cfqueryparam value="#arguments.thestruct.folder_name#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<cfif arguments.thestruct.folder_id_r EQ 0>
		AND folder_id_r = folder_id
	<cfelse>
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	<cfif arguments.thestruct.folder_id NEQ 0>
		AND folder_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	</cfquery>
	<!--- Set to true if found --->
	<cfif qry.recordCount NEQ 0>
		<cfset var ishere = true>
	</cfif>
	<cfreturn ishere>
</cffunction>

<!--- Check foldername for invalid characters --->
<cffunction name="foldernamecheck_invalidchars" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<!--- Param --->
	<cfset var isinvalid = false>
	<cfset var invalidcharlist= '/\\*?<>|":'>
	<!--- Check for invalid characters--->
	<cfif refind( "[#invalidcharlist#]" , arguments.thestruct.folder_name) >
		<cfset var isinvalid = true>
	</cfif>
	<cfreturn isinvalid>
</cffunction>

<!--- Asset Trash Count --->
<cffunction name="trashcount" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="asset_count" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#trashcount */ COUNT(img_id) AS cnt FROM #session.hostdbprefix#images i
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND CASE
			<cfif session.is_system_admin OR session.is_administrator>
				WHEN 1=1 THEN 'X'
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = i.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = i.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = i.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	UNION ALL
	SELECT COUNT(aud_id) AS cnt  FROM #session.hostdbprefix#audios a
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND CASE
			<cfif session.is_system_admin OR session.is_administrator>
				WHEN 1=1 THEN 'X'
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = a.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = a.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = a.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	UNION ALL
	SELECT COUNT(vid_id) AS cnt FROM #session.hostdbprefix#videos v
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND CASE
			<cfif session.is_system_admin OR session.is_administrator>
				WHEN 1=1 THEN 'X'
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = v.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = v.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = v.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	UNION ALL
	SELECT COUNT(file_id) AS cnt FROM #session.hostdbprefix#files f
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND CASE
			<cfif session.is_system_admin OR session.is_administrator>
				WHEN 1=1 THEN 'X'
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	</cfquery>
	<!--- Return --->
	<cfreturn asset_count />
</cffunction>

<!--- Folder Trash Count --->
<cffunction name="folderTrashCount" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="folder_count" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#trashcount */ COUNT(folder_id) AS cnt
	FROM #session.hostdbprefix#folders f
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND (folder_is_collection IS NULL OR folder_is_collection = '')
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND CASE
			<cfif session.is_system_admin OR session.is_administrator>
				WHEN 1=1 THEN 'X'
			</cfif>
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'R' THEN 'R'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'W' THEN 'W'
			WHEN (
				SELECT DISTINCT max(fg5.grp_permission)
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id
				AND (
					fg5.grp_id_r = '0'
					OR fg5.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				)
			) = 'X' THEN 'X' END !=''
	</cfquery>
	<cfreturn folder_count />
</cffunction>

<!--- Get fileid for next and back in detail view --->
<cffunction name="getdetailnextback" output="false" returntype="struct">
	<cfargument name="thestruct" type="struct">
	<!--- Create struct for return --->
	<cfset var f = structNew()>
	<cfset f.fileid = arguments.thestruct.file_id>
	<!--- Show only if row exists. Thus we prevent loading from basket or alike --->
	<cfif structKeyExists(arguments.thestruct,"row")>
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("folders")>
		<!--- Local query var --->
		<cfset var qry = "">
		<!--- The the row value for the next row and the last row --->
		<cfset f.row = arguments.thestruct.row + 1>
		<cfset f.rowback = arguments.thestruct.row - 1>
		<!--- According to type define id and db --->
		<cfif arguments.thestruct.what EQ "images">
			<cfset var thedb = "#session.hostdbprefix#images">
			<cfset var theid = "img_id">
			<cfset var thename = "img_filename">
			<cfset var thetype = "images">
			<cfset var thesize = "img_size">
			<cfset var thedatecreate = "img_create_time">
			<cfset var thedatechange = "img_change_time">
			<cfset var thehashtag = "hashtag">
			<cfset var thegroup = "img_group">
		<cfelseif arguments.thestruct.what EQ "videos">
			<cfset var thedb = "#session.hostdbprefix#videos">
			<cfset var theid = "vid_id">
			<cfset var thename = "vid_filename">
			<cfset var thetype = "videos">
			<cfset var thesize = "vid_size">
			<cfset var thedatecreate = "vid_create_time">
			<cfset var thedatechange = "vid_change_time">
			<cfset var thehashtag = "hashtag">
			<cfset var thegroup = "vid_group">
		<cfelseif arguments.thestruct.what EQ "audios">
			<cfset var thedb = "#session.hostdbprefix#audios">
			<cfset var theid = "aud_id">
			<cfset var thename = "aud_name">
			<cfset var thetype = "audios">
			<cfset var thesize = "aud_size">
			<cfset var thedatecreate = "aud_create_time">
			<cfset var thedatechange = "aud_change_time">
			<cfset var thehashtag = "hashtag">
			<cfset var thegroup = "aud_group">
		<cfelseif arguments.thestruct.what EQ "files">
			<cfset var thedb = "#session.hostdbprefix#files">
			<cfset var theid = "file_id">
			<cfset var thename = "file_name">
			<cfset var thetype = "files">
			<cfset var thesize = "file_size">
			<cfset var thedatecreate = "file_create_time">
			<cfset var thedatechange = "file_change_time">
			<cfset var thehashtag = "hashtag">
		</cfif>
		<!--- Set default sortby --->
		<cfset var sortby = "filename_forsort">
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
			<cfset var sortby = "filename_forsort">
		<cfelseif session.sortby EQ "kind">
			<cfset var sortby = "type">
		<cfelseif session.sortby EQ "sizedesc">
			<cfset var sortby = "size DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "size ASC">
		<cfelseif session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		<cfelseif session.sortby EQ "hashtag">
			<cfset var sortby = "hashtag">
		</cfif>
		<!--- For aliases --->
		<cfset var thealias='0,'>
		<cfset var alias_img = '0,'>
		<cfset var alias_vid = '0,'>
		<cfset var alias_aud = '0,'>
		<cfset var alias_doc = '0,'>
		<cfset var qry_aliases = "">
		<!--- Query Aliases --->
		<cfquery datasource="#application.razuna.datasource#" name="qry_aliases" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getdetailnextbackalias */ asset_id_r, type
		FROM ct_aliases
		WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
		</cfquery>
		<cfloop query="qry_aliases">
			<cfif type EQ "img">
				<cfset var alias_img = alias_img & asset_id_r & ','>
				<cfset var thealias = alias_img>
			<cfelseif type EQ "vid">
				<cfset var alias_vid = alias_vid & asset_id_r & ','>
				<cfset var thealias = alias_vid>
			<cfelseif type EQ "aud">
				<cfset var alias_aud = alias_aud & asset_id_r & ','>
				<cfset var thealias = alias_aud>
			<cfelseif type EQ "doc">
				<cfset var alias_doc = alias_doc & asset_id_r & ','>
				<cfset var thealias = alias_doc>
			</cfif>
		</cfloop>
		<!--- MySQL starts at 0 so we do -1 --->
		<cfset var detailrow = arguments.thestruct.row - 1>
		<!--- Query (if we come from the overall view we need to union all) --->
		<cfif arguments.thestruct.loaddiv EQ "content">
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- Oracle
			<cfif application.razuna.thedatabase EQ "oracle">
				SELECT * FROM (
					SELECT ROWNUM AS rn, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif> --->
			<!--- DB2
			<cfif application.razuna.thedatabase EQ "db2">
				SELECT * FROM (
					SELECT row_number() over() as rownr, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif> --->
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				select * from (
				select ROW_NUMBER() OVER (
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif> ) AS RowNum,sorted_inline_view.* from (
			</cfif>
			SELECT /* #variables.cachetoken#getdetailnextback */
			img_id as file_id,
			img_filename as filename_forsort,
			cast(img_size as decimal(12,0)) as size,
			img_create_time as date_create,
			img_change_time as date_change,
			hashtag,
			'images' as type
			FROM #session.hostdbprefix#images
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND (img_group IS NULL OR img_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			OR (
				img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_img#" list="true">)
				AND
				in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			    )

			UNION ALL
			SELECT
			vid_id as file_id,
			vid_filename as filename_forsort,
			cast(vid_size as decimal(12,0))  as size,
			vid_create_time as date_create,
			vid_change_time as date_change,
			hashtag,
			'videos' as type
			FROM #session.hostdbprefix#videos
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND (vid_group IS NULL OR vid_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			OR (
				vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_vid#" list="true">)
				AND
				in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			    )

			UNION ALL
			SELECT
			aud_id as file_id,
			aud_name as filename_forsort,
			cast(aud_size as decimal(12,0))  as size,
			aud_create_time as date_create,
			aud_change_time as date_change,
			hashtag,
			'audios' as type
			FROM #session.hostdbprefix#audios
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND (aud_group IS NULL OR aud_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			OR (
				aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_aud#" list="true">)
				AND
				in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			    )

			UNION ALL
			SELECT
			file_id as file_id,
			file_name as filename_forsort,
			cast(file_size as decimal(12,0))  as size,
			file_create_time as date_create,
			file_change_time as date_change,
			hashtag,
			file_type as type
			FROM #session.hostdbprefix#files
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			OR (
				file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#alias_doc#" list="true">)
				AND
				in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			    )
			<!--- MySql OR H2 --->
			<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif sortby NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif>
				LIMIT #detailrow#,1
			</cfif>
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				) sorted_inline_view
				 ) resultSet
				  where RowNum = #detailrow+1#
			</cfif>
			<!--- DB2
			<cfif application.razuna.thedatabase EQ "db2">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif>) sorted_inline_view )resultSet
				WHERE rownr = #detailrow+1#
			</cfif> --->
			<!--- Oracle
			<cfif application.razuna.thedatabase EQ "oracle">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif>) sorted_inline_view )resultSet
				WHERE ROWNUM = #detailrow+1#
			</cfif> --->
			</cfquery>
			<!--- <cfdump var="#qry#"><cfabort> --->
		<!--- We query below for within the same file type group --->
		<cfelse>
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- Oracle
			<cfif application.razuna.thedatabase EQ "oracle">
				SELECT * FROM (
					SELECT ROWNUM AS rn, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif> --->
			<!--- DB2
			<cfif application.razuna.thedatabase EQ "db2">
				SELECT * FROM (
					SELECT row_number() over() as rownr, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif> --->
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				SELECT * FROM (
				SELECT ROW_NUMBER() OVER (
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif> ) AS RowNum,sorted_inline_view.* FROM (
			</cfif>
			SELECT /* #variables.cachetoken#getdetailnextback */
			#theid# as file_id,
			#thename# as filename_forsort,
			cast(#thesize# as decimal(12,0)) as size,
			#thedatecreate# as date_create,
			#thedatechange# as date_change,
			#thehashtag#,
			'#thetype#' as type
			FROM #thedb#
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			<cfif isdefined("arguments.thestruct.file_extension")>
				AND
				<!--- if doc or xls also add office 2007 format to query --->
				<cfif arguments.thestruct.file_extension contains "doc" OR arguments.thestruct.file_extension contains "xls">
					(
					file_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.thestruct.file_extension,3)#">
					OR file_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.thestruct.file_extension,3)#x">
					)
				<!--- query all formats if not other --->
				<cfelseif arguments.thestruct.file_extension eq "pdf">
					file_extension = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.file_extension#">
				<!--- query all files except the ones in the list --->
				<cfelse>
					(
					file_extension NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
					OR (file_extension IS NULL OR file_extension = '')
					)
				</cfif>
			</cfif>
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif arguments.thestruct.what NEQ "files">
				AND (#thegroup# IS NULL OR #thegroup# = '')
			</cfif>
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			OR (
				#theid# IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thealias#" list="true">)
				AND
				in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				)
			<!--- MySql --->
			<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort LIMIT #detailrow#,1
				<cfelse>
					ORDER BY #sortby# LIMIT #detailrow#,1
				</cfif>
			</cfif>
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				) sorted_inline_view
				 ) resultSet
				  where RowNum = #detailrow+1#
			</cfif>
			<!--- DB2
			<cfif application.razuna.thedatabase EQ "db2">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif>) sorted_inline_view )resultSet
				WHERE rownr = #detailrow+1#
			</cfif> --->
			<!--- Oracle
			<cfif application.razuna.thedatabase EQ "oracle">
				<!--- Sorting made unique if two or more assets have the exact same sortby value --->
				<cfif #sortby# NEQ 'filename_forsort'>
					ORDER BY #sortby#,filename_forsort
				<cfelse>
					ORDER BY #sortby#
				</cfif>) sorted_inline_view )resultSet
				WHERE ROWNUM = #detailrow+1#
			</cfif> --->
			</cfquery>
		</cfif>
		<!--- Set returned fileid into struct --->
		<cfset f.fileid = qry.file_id>
		<cfset f.type = qry.type>
	</cfif>
	<!--- Return --->
	<cfreturn f />
</cffunction>

<!--- Get foldername --->
<cffunction name="getallassetsinfolder" access="remote" output="false" returntype="Query">
	<cfargument name="folder_id" required="yes" type="string">
	<cfargument name="columnlist" required="false" type="string" default="">
	<!--- Param --->
	<cfset var qry_folder = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery name="qry_folder" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getallassetsinfolder */ img_id AS ID, 'img' as type<cfif arguments.columnlist NEQ "">, #arguments.columnlist#</cfif>
	FROM #session.hostdbprefix#images
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	UNION ALL
	SELECT vid_id AS ID, 'vid' as type<cfif arguments.columnlist NEQ "">, #arguments.columnlist#</cfif>
	FROM #session.hostdbprefix#videos
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	UNION ALL
	SELECT aud_id AS ID, 'aud' as type<cfif arguments.columnlist NEQ "">, #arguments.columnlist#</cfif>
	FROM #session.hostdbprefix#audios
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	UNION ALL
	SELECT file_id AS ID, 'doc' as type<cfif arguments.columnlist NEQ "">, #arguments.columnlist#</cfif>
	FROM #session.hostdbprefix#files
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Return --->
	<cfreturn qry_folder />
</cffunction>

<!--- Copy THE FOLDER TO THE GIVEN POSITION --->
<cffunction hint="COPY THE FOLDER TO THE GIVEN POSITION" name="copy" output="true">
	<cfargument name="thestruct" type="struct">

	<!---<cftry>--->
		<!--- Get the reocord of the folder to be copied --->
		<cfinvoke method="getfolder" returnvariable="tocopyfolderdetails">
			<cfinvokeargument name="FOLDER_ID" value="#arguments.thestruct.tocopyfolderid#">
			<cfinvokeargument name="avoid_link_path" value="no">
		</cfinvoke>
		<cfif tocopyfolderdetails.recordcount NEQ 0>
			<cfif arguments.thestruct.count EQ 0>
				<!--- Get all the group --->
				<cfinvoke component="global.cfc.groups" method="getall" returnvariable="arguments.thestruct.qry_groups">
					<cfinvokeargument name="mod_id" value="1">
					<cfinvokeargument name="host_id" value="#session.hostid#">
				</cfinvoke>
				<!--- Parent folderId --->
				<cfset arguments.thestruct.root_copy_folder_id = arguments.thestruct.intofolderid >
			</cfif>
			<!--- RAZ- 273 Copy folder have a inherit permission to checked  --->
			<cfif structKeyExists(arguments.thestruct,"inherit_perm") AND arguments.thestruct.inherit_perm EQ 'true'>
				<!--- Get the reocord of the folder to set the access permission --->
				<cfinvoke method="getfoldergroups" returnvariable="tocopyfoldergroups" >
					<cfinvokeargument name="FOLDER_ID" value="#arguments.thestruct.root_copy_folder_id#">
					<cfinvokeargument name="qrygroup" value="#arguments.thestruct.qry_groups#">
					<cfinvokeargument name="in_folder_group" value="yes">
				</cfinvoke>
			<cfelse>
		<!--- Get the reocord of the folder to set the access permission --->
				<cfinvoke method="getfoldergroups" returnvariable="tocopyfoldergroups">
			<cfinvokeargument name="FOLDER_ID" value="#arguments.thestruct.tocopyfolderid#">
					<cfinvokeargument name="qrygroup" value="#arguments.thestruct.qry_groups#">
					<cfinvokeargument name="in_folder_group" value="yes">
		</cfinvoke>
			</cfif>
		<!--- Get the reocord of the folder into which the folder is to be copied --->
		<cfinvoke method="getfolder" returnvariable="intofolderdetails">
			<cfinvokeargument name="FOLDER_ID" value="#arguments.thestruct.intofolderid#">
		</cfinvoke>
		<!--- Check and change the into level --->
		<cfif arguments.thestruct.INTOLEVEL EQ 1 AND arguments.thestruct.intofolderid EQ arguments.thestruct.tocopyfolderid>
			<!--- Intolevel if copy into root --->
			<cfset arguments.thestruct.intolevel = 1>
		<cfelse>
			<!--- Intolevel if copy into Another folder --->
			<cfset arguments.thestruct.intolevel = arguments.thestruct.intolevel+1>
		</cfif>
		<!--- Naming the new folder as 'xxxx copy' --->
		<cfif arguments.thestruct.count EQ 0>
			<cfset tocopyfolderdetails.folder_name = tocopyfolderdetails.folder_name &' copy'>
			<!--- Get sub folders --->
			<cfinvoke method="getsubfolders" returnvariable="subfolders">
				<cfinvokeargument name="FOLDER_ID" value="#arguments.thestruct.intofolderid#">
				<cfinvokeargument name="FOLDER_NAME" value="#tocopyfolderdetails.folder_name#">
			</cfinvoke>
			<!--- Duplicate folder name --->
			<cfif subfolders.recordcount NEQ 0>
				<cfset tocopyfolderdetails.folder_name = tocopyfolderdetails.folder_name &'('& #subfolders.recordcount#+1 &')'>
			</cfif>
		</cfif>
		<!--- Copy the folder --->
		<cfset var newfolderid = "#createuuid('')#">
		<cfset var uid = "#createuuid('')#">
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#">
			<cfset directoryCreate('#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud')>
			<cfset directoryCreate('#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img')>
			<cfset directoryCreate('#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid')>
			<cfset directoryCreate('#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc')>
		</cfif>

		<!--- Insert into folders table --->
		<cfquery datasource="#variables.dsn#" name="insert_folder">
			INSERT INTO #session.hostdbprefix#folders
			(folder_id, folder_name, folder_level, folder_main_id_r, folder_id_r, folder_owner, folder_create_date, folder_change_date,
			folder_create_time, folder_change_time, host_id
			<cfif arguments.thestruct.ISCOL EQ "T">, folder_is_collection</cfif>)
			VALUES (
			<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#tocopyfolderdetails.folder_name#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.intolevel#" cfsqltype="cf_sql_numeric">,
			<cfif arguments.thestruct.INTOLEVEL EQ 1>
				<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfelse>
				<cfqueryparam value="#intofolderdetails.rid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR">,
			</cfif>
			<cfqueryparam value="#Session.theUserID#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif arguments.thestruct.ISCOL EQ "T">
				,<cfqueryparam value="T" cfsqltype="cf_sql_varchar">
			</cfif>
			)
		</cfquery>
		<!--- Insert the Group and Permission --->
			<cfif tocopyfoldergroups.recordcount NEQ 0>
		<cfloop query="tocopyfoldergroups">
			<cfquery datasource="#variables.dsn#">
				INSERT INTO #session.hostdbprefix#folders_groups
				(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#grp_id_r#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#grp_permission#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
		</cfloop>
			</cfif>
		<!--- Assign arguments --->
		<cfset arguments.thestruct.dsn = variables.dsn>
		<cfset arguments.thestruct.setid = variables.setid>
		<cfset arguments.thestruct.database = application.razuna.thedatabase>

		<!--- Get all assets of the current folder --->
		<cfset arguments.thestruct.folder_id = arguments.thestruct.tocopyfolderid>
		<cfset arguments.thestruct.qry_filecount = 0>
		<cfset arguments.thestruct.showsubfolders = 'F'>
		<cfset arguments.thestruct.sortby = 'name'>
		<cfset arguments.thestruct.pages = 'copy'>
		<cfinvoke method="getallassets" returnvariable="assets">
			<cfinvokeargument name="thestruct" value="#arguments.thestruct#" >
		</cfinvoke>
		<!--- Rename the assets and inserting into the appropriate table by loop --->
		<cfloop query="assets" >
			<cfset var cloud_url = structnew()>
			<cfset var cloud_url_org = structnew()>
			<cfif kind EQ 'img'>
				<cfset var newimgid = "#createuuid('')#">
				<!--- get the asset record from the image table --->
				<cfquery name="select_images" datasource="#application.razuna.datasource#">
					SELECT * FROM #session.hostdbprefix#images
					WHERE img_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar" >
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				</cfquery>
				<cfset arguments.thestruct.select_images = select_images>
				<cfset arguments.thestruct.newfolderid = newfolderid>
				<cfset arguments.thestruct.newimgid = newimgid>
				<!--- Rename the folder and thumbnail image --->
				<cfif application.razuna.storage EQ "local">
					<cfinvoke component="global" method="directoryCopy">
						<cfinvokeargument name="source" value="#arguments.thestruct.assetpath#/#session.hostid#/#assets.path_to_asset#">
						<cfinvokeargument name="destination" value="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img/#newimgid#">
						<cfinvokeargument name="directoryrecursive" value="true">
					</cfinvoke>
					<!---
					<cfdirectory action="rename" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img/#id#" newdirectory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img/#newimgid#" >
					--->
					<cffile action="rename" source="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img/#newimgid#/thumb_#id#.#select_images.thumb_extension#" destination="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/img/#newimgid#/thumb_#newimgid#.#select_images.thumb_extension#" >
				</cfif>
				<cfquery name="select_images_text" datasource="#application.razuna.datasource#">
					SELECT * FROM #session.hostdbprefix#images_text
					WHERE img_id_r = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar" >
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfquery name="select_xmp" datasource="#application.razuna.datasource#">
					SELECT * FROM #session.hostdbprefix#xmp
					WHERE id_r = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar" >
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>

				<cfif application.razuna.storage EQ "amazon">
					<cfset var upt = newimgid>
					<!--- Copy the folder to the old directory --->
					<cfthread name="copyfolderimg#newimgid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="amazon" method="copyfolder">
							<cfinvokeargument name="folderpath" value="#attributes.intupstruct.folder_id#/img/#attributes.intupstruct.select_images.img_id#">
							<cfinvokeargument name="folderpathdest" value="#attributes.intupstruct.newfolderid#/img/#attributes.intupstruct.newimgid#">
							<cfinvokeargument name="awsbucket" value="#attributes.intupstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfolderimg#newimgid#"  />
					<cfpause interval="5" />
					<cfthread name="renamethumb#newimgid#" intupstruct="#arguments.thestruct#">
						<cfset var renobj = createObject("component","global.cfc.s3").init(accessKeyId=application.razuna.awskey,secretAccessKey=application.razuna.awskeysecret,storagelocation = application.razuna.awslocation)>
						<cfset  renobj.renameObject(oldBucketName='#attributes.intupstruct.awsbucket#', newBucketName ="#attributes.intupstruct.awsbucket#", oldFileKey = "#attributes.intupstruct.newfolderid#/img/#attributes.intupstruct.newimgid#/thumb_#attributes.intupstruct.select_images.img_id#.jpg",  newFileKey = "#attributes.intupstruct.newfolderid#/img/#attributes.intupstruct.newimgid#/thumb_#attributes.intupstruct.newimgid#.jpg")>
					</cfthread>
					<cfthread action="join" name="renamethumb#newimgid#" />
					<cfpause interval="5" />
					<!--- Get SignedURL thumbnail --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#newfolderid#/img/#newimgid#/thumb_#newimgid#.jpg" awsbucket="#arguments.thestruct.awsbucket#">
					<!--- Get SignedURL original --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#newfolderid#/img/#newimgid#/#select_images.img_filename_org#" awsbucket="#arguments.thestruct.awsbucket#">
				<cfelseif application.razuna.storage EQ "nirvanix">
					<!--- Copy --->
					<cfthread name="copyfolderimg#newimgid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="nirvanix" method="CopyFolders">
							<cfinvokeargument name="srcFolderPath" value="#attributes.intupstruct.folder_id#/img/#attributes.intupstruct.select_images.img_id#">
							<cfinvokeargument name="destFolderPath" value="#attributes.intupstruct.newfolderid#/img/#attributes.intupstruct.newimgid#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfolderimg#newimgid#"  />
					<cfpause interval="5" />
					<!--- Rename Thumb --->
					<cfthread name="renamethumb#newimgid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="nirvanix" method="RenameFile">
							<cfinvokeargument name="filePath" value="#attributes.intupstruct.newfolderid#/img/#attributes.intupstruct.newimgid#">
							<cfinvokeargument name="newFileName" value="#attributes.intupstruct.newfolderid#/img/#attributes.intupstruct.newimgid#/thumb_#attributes.intupstruct.newimgid#.jpg">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="renamethumb#newimgid#" />
					<cfpause interval="5" />
					<!--- Get SignedURL thumbnail --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#newfolderid#/img/#newimgid#/thumb_#newimgid#.jpg" >
					<!--- Get SignedURL original --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#newfolderid#/img/#newimgid#/#select_images.img_filename_org#" >
				</cfif>
				<!--- Change the link path and reinsert with changing the root id --->
				<cfset link_path = '#arguments.thestruct.path#raz#session.hostid#/dam/incoming/api#newimgid#'>
				<cfquery name="updateimages" datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#images
					(IMG_ID,METABLOB,METAEXIF,METAIPTC,METAXMP,IMAGE,THUMB,COMP,COMP_UW,IMG_GROUP,IMG_PUBLISHER,IMG_FILENAME,FOLDER_ID_R,IMG_CUSTOM_ID,IMG_ONLINE,IMG_OWNER,IMG_CREATE_DATE,IMG_CREATE_TIME,IMG_CHANGE_DATE,IMG_CHANGE_TIME,IMG_RANKING,IMG_SINGLE_SALE,IMG_IS_NEW,IMG_SELECTION,IMG_IN_PROGRESS,IMG_ALIGNMENT,IMG_LICENSE,IMG_DOMINANT_COLOR,IMG_COLOR_MODE,IMG_IMAGE_TYPE,IMG_CATEGORY_ONE,IMG_REMARKS,IMG_EXTENSION,THUMB_EXTENSION,THUMB_WIDTH,THUMB_HEIGHT,IMG_FILENAME_ORG,IMG_WIDTH,IMG_HEIGHT,IMG_SIZE,THUMB_SIZE,LUCENE_KEY,SHARED,LINK_KIND,LINK_PATH_URL,IMG_META,HOST_ID,PATH_TO_ASSET,CLOUD_URL,CLOUD_URL_ORG,HASHTAG,IS_AVAILABLE,CLOUD_URL_EXP)
					VALUES(<cfqueryparam value="#newimgid#" cfsqltype="cf_sql_varchar" >,
					<cfqueryparam value="#select_images.METABLOB#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.METABLOB)#">,
					<cfqueryparam value="#select_images.METAEXIF#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.METAEXIF)#">,
					<cfqueryparam value="#select_images.METAIPTC#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.METAIPTC)#">,
					<cfqueryparam value="#select_images.METAXMP#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.METAXMP)#">,
					<cfqueryparam value="#select_images.IMAGE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMAGE)#">,
					<cfqueryparam value="#select_images.THUMB#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.THUMB)#">,
					<cfqueryparam value="#select_images.COMP#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.COMP)#">,
					<cfqueryparam value="#select_images.COMP_UW#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.COMP_UW)#">,
					<cfqueryparam value="#select_images.IMG_GROUP#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_GROUP)#">,
					<cfqueryparam value="#select_images.IMG_PUBLISHER#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_PUBLISHER)#">,
					<cfqueryparam value="#select_images.IMG_FILENAME#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_FILENAME)#">,
					<cfqueryparam value="#newfolderid#" cfsqltype="cf_sql_varchar" >,
					<cfqueryparam value="#select_images.IMG_CUSTOM_ID#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_CUSTOM_ID)#">,
					<cfqueryparam value="#select_images.IMG_ONLINE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_ONLINE)#">,
					<cfqueryparam value="#select_images.IMG_OWNER#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_OWNER)#">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
					<cfqueryparam value="#select_images.IMG_RANKING#" cfsqltype="cf_sql_integer" null="#NOT LEN(select_images.IMG_RANKING)#">,
					<cfqueryparam value="#select_images.IMG_SINGLE_SALE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_SINGLE_SALE)#">,
					<cfqueryparam value="#select_images.IMG_IS_NEW#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_IS_NEW)#">,
					<cfqueryparam value="#select_images.IMG_SELECTION#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_SELECTION)#">,
					<cfqueryparam value="#select_images.IMG_IN_PROGRESS#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_IN_PROGRESS)#">,
					<cfqueryparam value="#select_images.IMG_ALIGNMENT#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_ALIGNMENT)#">,
					<cfqueryparam value="#select_images.IMG_LICENSE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_LICENSE)#">,
					<cfqueryparam value="#select_images.IMG_DOMINANT_COLOR#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_DOMINANT_COLOR)#">,
					<cfqueryparam value="#select_images.IMG_COLOR_MODE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_COLOR_MODE)#">,
					<cfqueryparam value="#select_images.IMG_IMAGE_TYPE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_IMAGE_TYPE)#">,
					<cfqueryparam value="#select_images.IMG_CATEGORY_ONE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_CATEGORY_ONE)#">,
					<cfqueryparam value="#select_images.IMG_REMARKS#" cfsqltype="cf_sql_longvarchar" null="#NOT LEN(select_images.IMG_REMARKS)#">,
					<cfqueryparam value="#select_images.IMG_EXTENSION#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_EXTENSION)#">,
					<cfqueryparam value="#select_images.THUMB_EXTENSION#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.THUMB_EXTENSION)#">,
					<cfqueryparam value="#select_images.THUMB_WIDTH#" cfsqltype="cf_sql_integer" null="#NOT LEN(select_images.THUMB_WIDTH)#">,
					<cfqueryparam value="#select_images.THUMB_HEIGHT#" cfsqltype="cf_sql_integer" null="#NOT LEN(select_images.THUMB_HEIGHT)#">,
					<cfqueryparam value="#select_images.IMG_FILENAME_ORG#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_FILENAME_ORG)#">,
					<cfqueryparam value="#select_images.IMG_WIDTH#" cfsqltype="cf_sql_integer" null="#NOT LEN(select_images.IMG_WIDTH)#">,
					<cfqueryparam value="#select_images.IMG_HEIGHT#" cfsqltype="cf_sql_integer" null="#NOT LEN(select_images.IMG_HEIGHT)#">,
					<cfqueryparam value="#select_images.IMG_SIZE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_SIZE)#">,
					<cfqueryparam value="#select_images.THUMB_SIZE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.THUMB_SIZE)#">,
					<cfqueryparam value="#select_images.LUCENE_KEY#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.LUCENE_KEY)#">,
					<cfqueryparam value="#select_images.SHARED#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.SHARED)#">,
					<cfqueryparam value="#select_images.LINK_KIND#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.LINK_KIND)#">,
					<cfqueryparam value="#LINK_PATH#" cfsqltype="cf_sql_varchar" >,
					<cfqueryparam value="#select_images.IMG_META#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IMG_META)#">,
					<cfqueryparam value="#session.HOSTID#" cfsqltype="cf_sql_integer" >,
					<cfqueryparam value="#newfolderid#/img/#newimgid#" cfsqltype="cf_sql_varchar" >,
					<cfif structKeyExists(cloud_url,"theurl") AND cloud_url.theurl NEQ ''>
						<cfqueryparam value="#cloud_url.theurl#" cfsqltype="cf_sql_varchar" >,
					<cfelse>
						<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true" >,
					</cfif>
					<cfif structKeyExists(cloud_url_org,"theurl") AND cloud_url_org.theurl NEQ '' >
						<cfqueryparam value="#cloud_url_org.theurl#" cfsqltype="cf_sql_varchar" >,
					<cfelse>
						<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">,
					</cfif>

					<cfqueryparam value="#select_images.hashtag#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.hashtag)#">,
					<cfqueryparam value="#select_images.IS_AVAILABLE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images.IS_AVAILABLE)#">,
					<cfif structKeyExists(cloud_url_org,"newepoch") AND cloud_url_org.newepoch NEQ ''>
						<cfqueryparam value="#cloud_url_org.newepoch#" cfsqltype="cf_sql_integer" >
					<cfelse>
						<cfqueryparam value="" cfsqltype="cf_sql_integer" null="true" >
					</cfif>
					)
				</cfquery>
				<cfquery name="updateimges_text" datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#images_text
					(ID_INC,IMG_ID_R,LANG_ID_R,IMG_KEYWORDS,IMG_DESCRIPTION,HOST_ID)
					VALUES(
					<cfqueryparam value="#createuuid()#" cfsqltype="cf_sql_varchar" >,
					<cfqueryparam value="#newimgid#" cfsqltype="cf_sql_varchar" >,
					<cfqueryparam value="#select_images_text.LANG_ID_R#" cfsqltype="cf_sql_integer" null="#NOT LEN(select_images_text.LANG_ID_R)#">,
					<cfqueryparam value="#select_images_text.IMG_KEYWORDS#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images_text.IMG_KEYWORDS)#">,
					<cfqueryparam value="#select_images_text.IMG_DESCRIPTION#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_images_text.IMG_DESCRIPTION)#">,
					<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_integer" >
					)
				</cfquery>
				<cfquery name="updateimges_text" datasource="#application.razuna.datasource#" >
					INSERT INTO #session.hostdbprefix#xmp
					(id_r,asset_type,subjectcode,creator,title,authorsposition,captionwriter,ciadrextadr,category,supplementalcategories,urgency,description,ciadrcity,ciadrctry,location,ciadrpcode,ciemailwork,ciurlwork,citelwork,intellectualgenre,instructions,source,usageterms,copyrightstatus,transmissionreference,webstatement,headline,datecreated,city,ciadrregion,country,countrycode,scene,state,credit,rights,colorspace,xres,yres,resunit,host_id)
					VALUES(
					<cfqueryparam value="#newimgid#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#select_xmp.subjectcode#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.subjectcode)#">,
					<cfqueryparam value="#select_xmp.creator#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.creator)#">,
					<cfqueryparam value="#select_xmp.title#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.title)#">,
					<cfqueryparam value="#select_xmp.authorsposition#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.authorsposition)#">,
					<cfqueryparam value="#select_xmp.captionwriter#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.captionwriter)#">,
					<cfqueryparam value="#select_xmp.ciadrextadr#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.ciadrextadr)#">,
					<cfqueryparam value="#select_xmp.category#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.category)#">,
					<cfqueryparam value="#select_xmp.supplementalcategories#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.supplementalcategories)#">,
					<cfqueryparam value="#select_xmp.urgency#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.urgency)#">,
					<cfqueryparam value="#select_xmp.description#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.description)#">,
					<cfqueryparam value="#select_xmp.ciadrcity#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.ciadrcity)#">,
					<cfqueryparam value="#select_xmp.ciadrctry#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.ciadrctry)#">,
					<cfqueryparam value="#select_xmp.location#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.location)#">,
					<cfqueryparam value="#select_xmp.ciadrpcode#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.ciadrpcode)#">,
					<cfqueryparam value="#select_xmp.ciemailwork#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.ciemailwork)#">,
					<cfqueryparam value="#select_xmp.ciurlwork#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.ciurlwork)#">,
					<cfqueryparam value="#select_xmp.citelwork#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.citelwork)#">,
					<cfqueryparam value="#select_xmp.intellectualgenre#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.intellectualgenre)#">,
					<cfqueryparam value="#select_xmp.instructions#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.instructions)#">,
					<cfqueryparam value="#select_xmp.source#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.source)#">,
					<cfqueryparam value="#select_xmp.usageterms#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.usageterms)#">,
					<cfqueryparam value="#select_xmp.copyrightstatus#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.copyrightstatus)#">,
					<cfqueryparam value="#select_xmp.transmissionreference#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.transmissionreference)#">,
					<cfqueryparam value="#select_xmp.webstatement#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.webstatement)#">,
					<cfqueryparam value="#select_xmp.headline#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.headline)#">,
					<cfqueryparam value="#select_xmp.datecreated#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.datecreated)#">,
					<cfqueryparam value="#select_xmp.city#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.city)#">,
					<cfqueryparam value="#select_xmp.ciadrregion#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.ciadrregion)#">,
					<cfqueryparam value="#select_xmp.country#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.country)#">,
					<cfqueryparam value="#select_xmp.countrycode#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.countrycode)#">,
					<cfqueryparam value="#select_xmp.scene#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.scene)#">,
					<cfqueryparam value="#select_xmp.state#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.state)#">,
					<cfqueryparam value="#select_xmp.credit#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.credit)#">,
					<cfqueryparam value="#select_xmp.rights#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.rights)#">,
					<cfqueryparam value="#select_xmp.colorspace#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.colorspace)#">,
					<cfqueryparam value="#select_xmp.xres#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.xres)#">,
					<cfqueryparam value="#select_xmp.yres#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.yres)#">,
					<cfqueryparam value="#select_xmp.resunit#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_xmp.resunit)#">,
					<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_integer" >
					)
				</cfquery>
			<cfelseif kind EQ 'doc' OR kind EQ 'other'>
				<cfset var newfileid = "#createuuid('')#">
				<!--- Get the document records --->
				<cfquery datasource="#application.razuna.datasource#" name="select_files">
					SELECT * FROM #session.hostdbprefix#files
					WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				</cfquery>
				<cfset arguments.thestruct.select_files = select_files>
				<cfset arguments.thestruct.newfolderid = newfolderid>
				<cfset arguments.thestruct.newfileid = newfileid>
				<!--- Rename the folder --->
				<cfif application.razuna.storage EQ "local">

					<cfinvoke component="global" method="directoryCopy">
						<cfinvokeargument name="source" value="#arguments.thestruct.assetpath#/#session.hostid#/#assets.path_to_asset#">
						<cfinvokeargument name="destination" value="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc/#newfileid#">
						<cfinvokeargument name="directoryrecursive" value="true">
					</cfinvoke>
					<!---
					<cfdirectory action="rename" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc/#id#" newdirectory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/doc/#newfileid#" >
					--->
				</cfif>
				<cfquery datasource="#application.razuna.datasource#" name="select_files_desc">
					SELECT * FROM #session.hostdbprefix#files_desc
					WHERE file_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfif application.razuna.storage EQ "amazon">
					<cfset var upt = newfileid>
					<!--- Amazon Copyfolder  --->
					<cfthread name="copyfolderdoc#newfileid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="amazon" method="copyfolder">
							<cfinvokeargument name="folderpath" value="#attributes.intupstruct.folder_id#/doc/#attributes.intupstruct.select_files.file_id#">
							<cfinvokeargument name="folderpathdest" value="#attributes.intupstruct.newfolderid#/doc/#attributes.intupstruct.newfileid#">
							<cfinvokeargument name="awsbucket" value="#attributes.intupstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfolderdoc#newfileid#"  />
					<cfpause interval="5" />
					<!--- PDF file Thumbnail  --->
					<cfif assets.ext EQ "pdf">
						<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#newfolderid#/doc/#newfileid#/#select_files.file_name_noext#.jpg" awsbucket="#arguments.thestruct.awsbucket#">
					</cfif>
					<!--- Get SignedURL original --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#newfolderid#/doc/#newfileid#/#select_files.file_name_org#" awsbucket="#arguments.thestruct.awsbucket#">
				<cfelseif application.razuna.storage EQ "nirvanix">
					<!--- Nirvanix CopyFolders --->
					<cfthread name="copyfolderdoc#newfileid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="nirvanix" method="CopyFolders">
							<cfinvokeargument name="srcFolderPath" value="#attributes.intupstruct.folder_id#/doc/#attributes.intupstruct.select_files.file_id#">
							<cfinvokeargument name="destFolderPath" value="#attributes.intupstruct.newfolderid#/doc/#attributes.intupstruct.newfileid#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfolderdoc#newfileid#"  />
					<cfpause interval="5" />
					<!--- PDF file Thumbnail  --->
					<cfif assets.file_extension EQ "pdf">
						<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" key="#newfolderid#/doc/#newfileid#/#select_files.file_name_noext#.jpg" >
					</cfif>
					<!--- Get SignedURL original --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#newfolderid#/doc/#newfileid#/#select_files.file_name_org#" >
				</cfif>
				<!--- Insert into tables --->
				<cfset link_path = '#arguments.thestruct.path#raz#session.hostid#/dam/incoming/api#newfileid#'>
				<cfquery datasource="#application.razuna.datasource#" name="update_files" >
					INSERT INTO #session.hostdbprefix#files
					(FILE_ID,FOLDER_ID_R,FILE_CREATE_DATE,FILE_CREATE_TIME,FILE_CHANGE_DATE,FILE_CHANGE_TIME,FILE_OWNER,FILE_TYPE,FILE_NAME,FILE_EXTENSION,FILE_NAME_NOEXT,FILE_CONTENTTYPE,FILE_CONTENTSUBTYPE,FILE_REMARKS,FILE_ONLINE,FILE_NAME_ORG,FILE_SIZE,LUCENE_KEY,SHARED,LINK_KIND,LINK_PATH_URL,FILE_META,HOST_ID,PATH_TO_ASSET,CLOUD_URL,CLOUD_URL_ORG,HASHTAG,IS_AVAILABLE,CLOUD_URL_EXP)
					VALUES(
						<cfqueryparam value="#newfileid#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#newfolderid#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#session.theuserid#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#select_files.FILE_TYPE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_TYPE)#">,
						<cfqueryparam value="#select_files.FILE_NAME#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_NAME)#">,
						<cfqueryparam value="#select_files.FILE_EXTENSION#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_EXTENSION)#">,
						<cfqueryparam value="#select_files.FILE_NAME_NOEXT#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_NAME_NOEXT)#">,
						<cfqueryparam value="#select_files.FILE_CONTENTTYPE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_CONTENTTYPE)#">,
						<cfqueryparam value="#select_files.FILE_CONTENTSUBTYPE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_CONTENTSUBTYPE)#">,
						<cfqueryparam value="#select_files.FILE_REMARKS#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_REMARKS)#">,
						<cfqueryparam value="#select_files.FILE_ONLINE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_ONLINE)#">,
						<cfqueryparam value="#select_files.FILE_NAME_ORG#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_NAME_ORG)#">,
						<cfqueryparam value="#select_files.FILE_SIZE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_SIZE)#">,
						<cfqueryparam value="#select_files.LUCENE_KEY#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.LUCENE_KEY)#">,
						<cfqueryparam value="#select_files.SHARED#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.SHARED)#">,
						<cfqueryparam value="#select_files.LINK_KIND#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.LINK_KIND)#">,
						<cfqueryparam value="#LINK_PATH#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#select_files.FILE_META#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.FILE_META)#">,
						<cfqueryparam value="#session.HOSTID#" cfsqltype="cf_sql_integer" >,
						<cfqueryparam value="#newfolderid#/doc/#newfileid#" cfsqltype="cf_sql_varchar" >,
						<cfif structKeyExists(cloud_url,"theurl") AND cloud_url.theurl NEQ '' >
							<cfqueryparam value="#cloud_url.theurl#" cfsqltype="cf_sql_varchar" >,
						<cfelse>
							<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">,
						</cfif>
						<cfif structKeyExists(cloud_url_org,"theurl") AND cloud_url_org.theurl NEQ '' >
							<cfqueryparam value="#cloud_url_org.theurl#" cfsqltype="cf_sql_varchar" >,
						<cfelse>
							<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true" >,
						</cfif>
						<cfqueryparam value="#select_files.hashtag#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.hashtag)#">,
						<cfqueryparam value="#select_files.IS_AVAILABLE#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files.IS_AVAILABLE)#">,
						<cfif structKeyExists(cloud_url_org,"newepoch") AND cloud_url_org.newepoch NEQ ''>
							<cfqueryparam value="#cloud_url_org.newepoch#" cfsqltype="cf_sql_integer" >
						<cfelse>
							<cfqueryparam value="" cfsqltype="cf_sql_integer" null="true" >
						</cfif>
					)
				</cfquery>
				<cfif select_files_desc.recordcount>
					<cfquery datasource="#application.razuna.datasource#" name="update_files_desc" >
						INSERT INTO #session.hostdbprefix#files_desc
						(ID_INC,FILE_ID_R,LANG_ID_R,FILE_DESC,FILE_KEYWORDS,HOST_ID)
						VALUES(
						<cfqueryparam value="#createuuid()#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#newfileid#" cfsqltype="cf_sql_varchar" >,
						<cfqueryparam value="#select_files_desc.LANG_ID_R#" cfsqltype="cf_sql_integer" null="#NOT LEN(select_files_desc.LANG_ID_R)#">,
						<cfqueryparam value="#select_files_desc.FILE_DESC#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files_desc.FILE_DESC)#">,
						<cfqueryparam value="#select_files_desc.FILE_KEYWORDS#" cfsqltype="cf_sql_varchar" null="#NOT LEN(select_files_desc.FILE_KEYWORDS)#">,
						<cfqueryparam value="#session.HOSTID#" cfsqltype="cf_sql_integer" >
						)
					</cfquery>
				</cfif>
			<cfelseif kind EQ 'aud'>
				<cfset var newaudid = "#createuuid('')#">
				<!--- Get audio records --->
				<cfquery datasource="#application.razuna.datasource#" name="select_audios">
					SELECT * FROM #session.hostdbprefix#audios
					WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				</cfquery>
				<cfset arguments.thestruct.select_audios = select_audios>
				<cfset arguments.thestruct.newfolderid = newfolderid>
				<cfset arguments.thestruct.newaudid = newaudid>
				<!--- Rename the directory --->
				<cfif application.razuna.storage EQ "local">

					<cfinvoke component="global" method="directoryCopy">
						<cfinvokeargument name="source" value="#arguments.thestruct.assetpath#/#session.hostid#/#assets.path_to_asset#">
						<cfinvokeargument name="destination" value="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud/#newaudid#">
						<cfinvokeargument name="directoryrecursive" value="true">
					</cfinvoke>
					<!---
					<cfdirectory action="rename" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud/#id#" newdirectory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/aud/#newaudid#" >
						--->
				</cfif>
				<cfquery datasource="#application.razuna.datasource#" name="select_audios_text">
					SELECT * FROM #session.hostdbprefix#audios_text
					WHERE aud_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfif application.razuna.storage EQ "amazon">
					<cfset var upt = newaudid>
					<!--- Amazon Copyfolder  --->
					<cfthread name="copyfolderaud#newaudid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="amazon" method="copyfolder">
							<cfinvokeargument name="folderpath" value="#attributes.intupstruct.folder_id#/aud/#attributes.intupstruct.select_audios.aud_id#">
							<cfinvokeargument name="folderpathdest" value="#attributes.intupstruct.newfolderid#/aud/#attributes.intupstruct.newaudid#">
							<cfinvokeargument name="awsbucket" value="#attributes.intupstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfolderaud#newaudid#"  />
					<cfpause interval="5" />
					<!--- Get SignedURL original --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#newfolderid#/aud/#newaudid#/#select_audios.aud_name_org#" awsbucket="#arguments.thestruct.awsbucket#">
				<cfelseif application.razuna.storage EQ "nirvanix">
					<!--- Nirvanix CopyFolders --->
					<cfthread name="copyfolderaud#newaudid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="nirvanix" method="CopyFolders">
							<cfinvokeargument name="srcFolderPath" value="#attributes.intupstruct.folder_id#/aud/#attributes.intupstruct.select_audios.aud_id#">
							<cfinvokeargument name="destFolderPath" value="#attributes.intupstruct.newfolderid#/aud/#attributes.intupstruct.newaudid#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfolderaud#newaudid#"  />
					<cfpause interval="5" />
					<!--- Get SignedURL original --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#newfolderid#/aud/#newaudid#/#select_audios.aud_name_org#" >
				</cfif>
				<!--- Insert new audio records --->
				<cfset link_path = '#arguments.thestruct.path#raz#session.hostid#/dam/incoming/api#newaudid#'>
				<cfquery datasource="#application.razuna.datasource#" name="update_audios">
					INSERT INTO #session.hostdbprefix#audios
					(aud_ID,FOLDER_ID_R,aud_CREATE_DATE,aud_CREATE_TIME,aud_CHANGE_DATE,aud_CHANGE_TIME,aud_OWNER,aud_TYPE,aud_NAME,aud_EXTENSION,aud_NAME_NOEXT,aud_CONTENTTYPE,aud_CONTENTSUBTYPE,aud_ONLINE,aud_NAME_ORG,aud_GROUP,aud_size,LUCENE_KEY,SHARED,aud_meta,LINK_KIND,LINK_PATH_URL,HOST_ID,PATH_TO_ASSET,CLOUD_URL,CLOUD_URL_2,CLOUD_URL_ORG,HASHTAG,IS_AVAILABLE,CLOUD_URL_EXP)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newaudid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newfolderid#">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_TYPE#" null="#NOT LEN(select_audios.aud_TYPE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_NAME#" null="#NOT LEN(select_audios.aud_NAME)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_EXTENSION#" null="#NOT LEN(select_audios.aud_EXTENSION)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_NAME_NOEXT#" null="#NOT LEN(select_audios.aud_NAME_NOEXT)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_CONTENTTYPE#" null="#NOT LEN(select_audios.aud_CONTENTTYPE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_CONTENTSUBTYPE#" null="#NOT LEN(select_audios.aud_CONTENTSUBTYPE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_ONLINE#" null="#NOT LEN(select_audios.aud_ONLINE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_NAME_ORG#" null="#NOT LEN(select_audios.aud_NAME_ORG)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_GROUP#" null="#NOT LEN(select_audios.aud_GROUP)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_size#" null="#NOT LEN(select_audios.aud_size)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.LUCENE_KEY#" null="#NOT LEN(select_audios.LUCENE_KEY)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.SHARED#" null="#NOT LEN(select_audios.SHARED)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.aud_meta#" null="#NOT LEN(select_audios.aud_meta)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.LINK_KIND#" null="#NOT LEN(select_audios.LINK_KIND)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#LINK_PATH#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#session.HOSTID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newfolderid#/aud/#newaudid#">,
						<cfif structKeyExists(cloud_url_org,"theurl") AND cloud_url_org.theurl NEQ '' >
							<cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true" >,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_org.theurl#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true" >,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true">,
						</cfif>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.hashtag#" null="#NOT LEN(select_audios.hashtag)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios.IS_AVAILABLE#" null="#NOT LEN(select_audios.IS_AVAILABLE)#">,
						<cfif structKeyExists(cloud_url_org,"newepoch") AND cloud_url_org.newepoch NEQ ''>
							<cfqueryparam cfsqltype="cf_sql_integer" value="#cloud_url_org.newepoch#">
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_integer" value="" null="true" >
						</cfif>
					)
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#" name="update_audios_text">
					INSERT INTO #session.hostdbprefix#audios_text
					(id_inc,aud_ID_R,LANG_ID_R,aud_DESCRIPTION,aud_KEYWORDS,HOST_ID)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newaudid#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_audios_text.LANG_ID_R#" null="#NOT LEN(select_audios_text.LANG_ID_R)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios_text.aud_DESCRIPTION#" null="#NOT LEN(select_audios_text.aud_DESCRIPTION)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_audios_text.aud_KEYWORDS#" null="#NOT LEN(select_audios_text.aud_KEYWORDS)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#session.HOSTID#">
					)
				</cfquery>
			<cfelseif kind EQ 'vid'>
				<cfset var newvidid = "#createuuid('')#">
				<!--- Get video records --->
				<cfquery datasource="#application.razuna.datasource#" name="select_videos">
					SELECT * FROM #session.hostdbprefix#videos
					WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				</cfquery>
				<cfset arguments.thestruct.select_videos = select_videos>
				<cfset arguments.thestruct.newfolderid = newfolderid>
				<cfset arguments.thestruct.newvidid = newvidid>
				<!--- Rename the folder --->
				<cfif application.razuna.storage EQ "local">

					<cfinvoke component="global" method="directoryCopy">
						<cfinvokeargument name="source" value="#arguments.thestruct.assetpath#/#session.hostid#/#assets.path_to_asset#">
						<cfinvokeargument name="destination" value="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid/#newvidid#">
						<cfinvokeargument name="directoryrecursive" value="true">
					</cfinvoke>
					<!---
					<cfdirectory action="rename" directory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid/#id#" newdirectory="#arguments.thestruct.assetpath#/#session.hostid#/#newfolderid#/vid/#newvidid#" >
					--->
				</cfif>
				<cfquery datasource="#application.razuna.datasource#" name="select_videos_text">
					SELECT * FROM #session.hostdbprefix#videos_text
					WHERE vid_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfif application.razuna.storage EQ "amazon">
					<cfset var upt = newvidid>
					<!--- Amazon Copyfolder  --->
					<cfthread name="copyfoldervid#newvidid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="amazon" method="copyfolder">
							<cfinvokeargument name="folderpath" value="#attributes.intupstruct.folder_id#/vid/#attributes.intupstruct.select_videos.vid_id#">
							<cfinvokeargument name="folderpathdest" value="#attributes.intupstruct.newfolderid#/vid/#attributes.intupstruct.newvidid#">
							<cfinvokeargument name="awsbucket" value="#attributes.intupstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfoldervid#newvidid#"  />
					<cfpause interval="5" />
					<!--- Get SignedURL Thumb --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#newfolderid#/vid/#newvidid#/#select_videos.vid_name_image#" awsbucket="#arguments.thestruct.awsbucket#">
					<!--- Get SignedURL original --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#newfolderid#/vid/#newvidid#/#select_videos.vid_name_org#" awsbucket="#arguments.thestruct.awsbucket#">

				<cfelseif application.razuna.storage EQ "nirvanix">
					<!--- Nirvanix CopyFolders --->
					<cfthread name="copyfoldervid#newvidid#" intupstruct="#arguments.thestruct#">
						<cfinvoke component="nirvanix" method="CopyFolders">
							<cfinvokeargument name="srcFolderPath" value="#attributes.intupstruct.folder_id#/vid/#attributes.intupstruct.select_videos.vid_id#">
							<cfinvokeargument name="destFolderPath" value="#attributes.intupstruct.newfolderid#/vid/#attributes.intupstruct.newvidid#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="copyfoldervid#newvidid#"  />
					<cfpause interval="5" />
					<!--- Get SignedURL thumbnail --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#newfolderid#/vid/#newvidid#/#select_videos.vid_name_image#" >
					<!--- Get SignedURL original --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#newfolderid#/vid/#newvidid#/#select_videos.vid_name_org#" >
				</cfif>
				<cfset link_path = '#arguments.thestruct.path#raz#session.hostid#/dam/incoming/api#newvidid#'>
				<!--- Insert video details --->
				<cfquery datasource="#application.razuna.datasource#" name="update_videos">
					INSERT INTO #session.hostdbprefix#videos
					(VID_ID,VID_FILENAME,FOLDER_ID_R,VID_CUSTOM_ID,VID_ONLINE,VID_OWNER,VID_CREATE_DATE,VID_CREATE_TIME,VID_CHANGE_DATE,VID_CHANGE_TIME,VID_RANKING,VID_SINGLE_SALE,VID_IS_NEW,VID_SELECTION,VID_IN_PROGRESS,VID_LICENSE,VID_CATEGORY_ONE,VID_REMARKS,VID_WIDTH,VID_HEIGHT,VID_FRAMERESOLUTION,VID_FRAMERATE,VID_VIDEODURATION,VID_COMPRESSIONTYPE,VID_BITRATE,VID_EXTENSION,VID_MIMETYPE,VID_PREVIEW_WIDTH,VID_PREVIEW_HEIGTH,VID_GROUP,VID_PUBLISHER,VID_NAME_ORG,VID_NAME_IMAGE,VID_NAME_PRE,VID_NAME_PRE_IMG,VID_SIZE,VID_PREV_SIZE,LUCENE_KEY,SHARED,LINK_KIND,LINK_PATH_URL,VID_META,HOST_ID,PATH_TO_ASSET,CLOUD_URL,CLOUD_URL_ORG,HASHTAG,IS_AVAILABLE,CLOUD_URL_EXP)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newvidid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_FILENAME#" null="#NOT LEN(select_videos.VID_FILENAME)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newfolderid#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_ONLINE#" null="#NOT LEN(select_videos.VID_ONLINE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date" >,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_RANKING#" null="#NOT LEN(select_videos.VID_RANKING)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_SINGLE_SALE#" null="#NOT LEN(select_videos.VID_SINGLE_SALE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_IS_NEW#" null="#NOT LEN(select_videos.VID_IS_NEW)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_SELECTION#" null="#NOT LEN(select_videos.VID_SELECTION)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_IN_PROGRESS#" null="#NOT LEN(select_videos.VID_IN_PROGRESS)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_LICENSE#" null="#NOT LEN(select_videos.VID_LICENSE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_CATEGORY_ONE#" null="#NOT LEN(select_videos.VID_CATEGORY_ONE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_REMARKS#" null="#NOT LEN(select_videos.VID_REMARKS)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_WIDTH#" null="#NOT LEN(select_videos.VID_WIDTH)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_HEIGHT#" null="#NOT LEN(select_videos.VID_HEIGHT)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_FRAMERESOLUTION#" null="#NOT LEN(select_videos.VID_FRAMERESOLUTION)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_FRAMERATE#" null="#NOT LEN(select_videos.VID_FRAMERATE)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_VIDEODURATION#" null="#NOT LEN(select_videos.VID_VIDEODURATION)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_COMPRESSIONTYPE#" null="#NOT LEN(select_videos.VID_COMPRESSIONTYPE)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_BITRATE#" null="#NOT LEN(select_videos.VID_BITRATE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_EXTENSION#" null="#NOT LEN(select_videos.VID_EXTENSION)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_MIMETYPE#" null="#NOT LEN(select_videos.VID_MIMETYPE)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_PREVIEW_WIDTH#" null="#NOT LEN(select_videos.VID_PREVIEW_WIDTH)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos.VID_PREVIEW_HEIGTH#" null="#NOT LEN(select_videos.VID_PREVIEW_HEIGTH)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_GROUP#" null="#NOT LEN(select_videos.VID_GROUP)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_PUBLISHER#" null="#NOT LEN(select_videos.VID_PUBLISHER)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_NAME_ORG#" null="#NOT LEN(select_videos.VID_NAME_ORG)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_NAME_IMAGE#" null="#NOT LEN(select_videos.VID_NAME_IMAGE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_NAME_PRE#" null="#NOT LEN(select_videos.VID_NAME_PRE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_NAME_PRE_IMG#" null="#NOT LEN(select_videos.VID_NAME_PRE_IMG)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_SIZE#" null="#NOT LEN(select_videos.VID_SIZE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_PREV_SIZE#" null="#NOT LEN(select_videos.VID_PREV_SIZE)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.LUCENE_KEY#" null="#NOT LEN(select_videos.LUCENE_KEY)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.SHARED#" null="#NOT LEN(select_videos.SHARED)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.LINK_KIND#" null="#NOT LEN(select_videos.LINK_KIND)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#LINK_PATH#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.VID_META#" null="#NOT LEN(select_videos.VID_META)#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#session.HOSTID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newfolderid#/vid/#newvidid#">,
						<cfif structKeyExists(cloud_url,"theurl") AND cloud_url.theurl NEQ '' >
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url.theurl#" >,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true" >,
						</cfif>
						<cfif structKeyExists(cloud_url_org,"theurl") AND cloud_url_org.theurl NEQ '' >
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#cloud_url_org.theurl#">,
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true" >,
						</cfif>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.HASHTAG#" null="#NOT LEN(select_videos.HASHTAG)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos.IS_AVAILABLE#" null="#NOT LEN(select_videos.IS_AVAILABLE)#">,
						<cfif structKeyExists(cloud_url_org,"newepoch") AND cloud_url_org.newepoch NEQ ''>
							<cfqueryparam cfsqltype="cf_sql_integer" value="#cloud_url_org.newepoch#">
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_integer" value="" null="true" >
						</cfif>

					)
				</cfquery>
				<cfif select_videos_text.RecordCount>
					<cfquery datasource="#application.razuna.datasource#" name="update_videos_text">
						INSERT INTO #session.hostdbprefix#videos_text
						(ID_INC,VID_ID_R,LANG_ID_R,VID_KEYWORDS,VID_DESCRIPTION,VID_TITLE,HOST_ID)
						VALUES(
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#newvidid#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#select_videos_text.LANG_ID_R#"  null="#NOT LEN(select_videos_text.LANG_ID_R)#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos_text.VID_KEYWORDS#"  null="#NOT LEN(select_videos_text.VID_KEYWORDS)#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos_text.VID_DESCRIPTION#"  null="#NOT LEN(select_videos_text.VID_DESCRIPTION)#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#select_videos_text.VID_DESCRIPTION#"  null="#NOT LEN(select_videos_text.VID_DESCRIPTION)#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#session.HOSTID#">
						)
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Increment the count --->
		<cfset arguments.thestruct.count = arguments.thestruct.count + 1>
		<!--- Get sub folders --->
		<cfinvoke method="getsubfolders" returnvariable="tocopyfolderdetails">
			<cfinvokeargument name="FOLDER_ID" value="#arguments.thestruct.tocopyfolderid#">
				<cfinvokeargument name="avoid_link_path" value="yes">
		</cfinvoke>
		<!--- Loop the subfolder records and call the same function again --->
		<cfif tocopyfolderdetails.recordcount>
			<cfloop query="tocopyfolderdetails">
				<cfset arguments.thestruct.tocopyfolderid = folder_id>
				<cfset arguments.thestruct.intofolderid = newfolderid>
				<cfinvoke method="copy" returnvariable="done">
					<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
				</cfinvoke>
			</cfloop>
		</cfif>
		</cfif>
		<!---<cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error copy folder - #cgi.http_host#">
				<cfdump var="#cfcatch#" />
				<cfdump var="#arguments.thestruct#" />
			</cfmail>
		</cfcatch>
	</cftry>--->
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
	<cfreturn />
</cffunction>

<cffunction name="Extract_UPC" access="Public" output="false">
	<cfargument name="thestruct" type="struct">
	<cfargument name="sUPC" type="string" required="true">
	<cfargument name="iUPC_Option" type="numeric" required="true">
	<cfset Extract_UPC = "">
	<cfset iLen = Len(sUPC)>
	<cfset gb_strPkgeCode = "">
	<cfif arguments.thestruct.dl_query.upc_number NEQ ''>
		<cfswitch expression="#iUPC_Option#">
			<cfcase value="10">
				<cfswitch expression="#iLen#">
					<cfcase value="14">
						<cfset Extract_UPC = Mid(sUPC, 4, 10) >
					</cfcase>
					<cfcase value="13">
						<cfset Extract_UPC = Mid(sUPC, 3, 10) >
					</cfcase>
					<cfcase value="12">
						<cfset Extract_UPC = Mid(sUPC, 2, 10) >
					</cfcase>
					<cfcase value="11">
						<cfset Extract_UPC = Mid(sUPC, 2, 10) >
					</cfcase>
					<cfdefaultcase>
						<cfset Extract_UPC = sUPC >
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
			<cfcase value="11">
				<cfswitch expression="#iLen#">
					<cfcase value="14">
						<cfset Extract_UPC = Mid(sUPC, 3, 11) >
					</cfcase>
					<cfcase value="13">
						<cfset Extract_UPC = Mid(sUPC, 2, 11) >
					</cfcase>
					<cfcase value="12">
						<cfset Extract_UPC = Left(sUPC, 11) >
					</cfcase>
					<cfdefaultcase>
						<cfset Extract_UPC = sUPC >
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
			<cfcase value="12">
				<cfswitch expression="#iLen#">
					<cfcase value="14">
						<cfset Extract_UPC = Mid(sUPC, 3, 12) >
					</cfcase>
					<cfcase value="13">
						<cfset Extract_UPC = Mid(sUPC, 2, 12) >
					</cfcase>
					<cfdefaultcase>
						<cfset Extract_UPC = sUPC >
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
			<cfcase value="13">
				<cfswitch expression="#iLen#">
					<cfcase value="14">
						<cfset Extract_UPC = Mid(sUPC, 2, 13) >
					</cfcase>
					<cfdefaultcase>
						<cfset Extract_UPC = sUPC >
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
			<cfcase value="14">
				<cfswitch expression="#iLen#">
					<cfcase value="14">
						<cfset Extract_UPC = sUPC >
					</cfcase>
					<cfcase value="13">
						<cfset Extract_UPC = "0" & sUPC >
					</cfcase>
					<cfcase value="12">
						<cfset Extract_UPC = "00" & sUPC >
					</cfcase>
					<cfcase value="11">
						<cfset Extract_UPC = "000" & sUPC >
					</cfcase>
					<cfdefaultcase>
						<cfset Extract_UPC = sUPC >
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
		</cfswitch>
	</cfif>
	<cfreturn Extract_UPC >
</cffunction>

<!--- Find manufacturer String --->
<cffunction name="Find_Manuf_String" output="false" access="public" >
	<cfargument name="strManuf_UPC" type="string" required="true">
	<cfset Find_Manuf_String = "" >
	<cfset FldLen = Len(strManuf_UPC)>
	<cftry>
		<cfif strManuf_UPC NEQ ''>
			<cfif FldLen LT 13>
				<cfset Find_Manuf_String = Left(strManuf_UPC, (FldLen - 6))>
			<cfelse>
				<cfset Find_Manuf_String = Left(strManuf_UPC, (FldLen - 7))>
			</cfif>
			<cfif FldLen LT 13>
				<cfif FldLen LT 6 >
					<cfset Find_Manuf_String = "00000"	>
				<cfelse>
					<cfset Find_Manuf_String = Left(strManuf_UPC, (FldLen - 5))>
				</cfif>
			<cfelse>
				<cfset Find_Manuf_String = Left(strManuf_UPC, (FldLen - 6))>
			</cfif>
		</cfif>
	<cfcatch><cfset  Find_Manuf_String = "ERROR"></cfcatch>
	</cftry>
	<cfreturn Find_Manuf_String >
</cffunction>

<!--- Find product String --->
<cffunction name="Find_Prod_String" output="false" access="public" >
	<cfargument name="strManuf_UPC" type="string" required="true">
	<cfset Find_Prod_String = "">
	<cfset FldLen = Len(strManuf_UPC)>
	<cfif strManuf_UPC NEQ ''>
		<cfif FldLen LT 14>
			<cfif FldLen LT 13>
				<cfset Find_Prod_String = Right(strManuf_UPC, 5)>
			<cfelse>
				<cfset Find_Prod_String = Right(strManuf_UPC, 6)>
			</cfif>
		<cfelse>
			<cfset Find_Prod_String = Right(strManuf_UPC, 7)>
		</cfif>
	</cfif>
	<cfreturn Find_Prod_String >
</cffunction>


<!--- Download Folder --->
<cffunction name="download_upc_folder" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<cfinvoke component="defaults" method="trans" transid="download_folder_output" returnvariable="download_folder_output" />
	<!--- Feedback --->
	<cfoutput><br/><strong>#download_folder_output#</strong><br /></cfoutput>
	<cfflush>
	<!--- Params --->
	<cfset var thisstruct = structnew()>
	<cfparam name="arguments.thestruct.awsbucket" default="" />
	<cfparam name="arguments.thestruct.other_asset" default="false"/>
	<cfparam name="arguments.thestruct.upc_asset_id" default=""/>
	<cfparam name="arguments.thestruct.other_asset_id" default=""/>
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!---<cftry>--->
		<!--- Set time for remove --->
		<cfset var removetime = DateAdd("h", -2, "#now()#")>
		<!--- Remove old directories --->
		<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing" name="thedirs">
		<!--- Loop over dirs --->
		<cfloop query="thedirs">
			<!--- If a directory --->
			<cfif type EQ "dir" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#name#" recurse="true" mode="775">
			<cfelseif type EQ "file" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#name#">
			</cfif>
		</cfloop>
		<!---<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while removing outgoing folders in function folders.download_folder">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>--->
	<!--- Create directory --->
	<cfset var basketname = createuuid("")>
	<cfset arguments.thestruct.newpath = arguments.thestruct.thepath & "/outgoing/#basketname#">
	<cfdirectory action="create" directory="#arguments.thestruct.newpath#" mode="775">
	<!--- Get Parent folder names --->
	<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#arguments.thestruct.folder_id#" returnvariable="crumbs" />
	<cfset parentfoldersname = ''>
	<cfloop list="#crumbs#" index="idx" delimiters=";">
		<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
	</cfloop>
	<!--- Create Directory as per folder structure in Razuna --->
	<cfdirectory action="create" directory="#arguments.thestruct.newpath##parentfoldersname#" mode="775">

		<cfloop query="arguments.thestruct.qry_files">
			<cfif structKeyExists(arguments.thestruct,'qry_files') AND arguments.thestruct.qry_files.upc_number NEQ ''>
				<cfset arguments.thestruct.dl_query.upc_number = arguments.thestruct.qry_files.upc_number >
				<cfinvoke component="folders" method="Extract_UPC" returnvariable="extract_upcnumber">
					<cfinvokeargument name="thestruct" value="#arguments.thestruct#" />
					<cfinvokeargument name="sUPC" value="#arguments.thestruct.dl_query.upc_number#">
					<cfinvokeargument name="iUPC_Option" value="#arguments.thestruct.qry_GroupsOfUser.upc_size#">
				</cfinvoke>
				<cfinvoke component="folders" method="Find_Manuf_String" returnvariable="arguments.thestruct.folder_name">
					<cfinvokeargument name="strManuf_UPC" value="#extract_upcnumber#">
				</cfinvoke>
				<cfinvoke component="folders" method="Find_Prod_String" returnvariable="arguments.thestruct.upc_name">
					<cfinvokeargument name="strManuf_UPC" value="#extract_upcnumber#">
				</cfinvoke>
				<cfif arguments.thestruct.folder_name eq "ERROR">
					<cfthrow message="Error while converting UPC number '#arguments.thestruct.dl_query.upc_number#' to manufucturer string . Please check UPC number and make sure it is valid.">
				</cfif>
				<cfquery name="qry_upcgrp" dbtype="query">
					SELECT * FROM arguments.thestruct.qry_GroupsOfUser WHERE upc_size <>'' AND upc_size is not null
				</cfquery>
				<cfif qry_upcgrp.recordcount gt 1>
					<cfinvoke component="defaults" method="trans" transid="upc_user_multi_grps" returnvariable="upc_user_multi_grps" />
					<cftry>
					<cfthrow message="User is in more than one UPC group which is not allowed.">
					 <cfcatch type="any">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
						<cfoutput><font color="##CD5C5C"><strong>#upc_user_multi_grps#</strong></font> </cfoutput>
						<cfabort>
					</cfcatch>
					</cftry>
				</cfif>
				<cfif structKeyExists(arguments.thestruct,'qry_GroupsOfUser') AND qry_upcgrp.upc_folder_format EQ 'true'>
					<cfset create_dir_path = "#arguments.thestruct.newpath##parentfoldersname#/#arguments.thestruct.folder_name#">
					<!--- Create Directory as per folder structure in Razuna --->
					<cfif NOT directoryexists("#create_dir_path#")>
						<cfdirectory action="create" directory="#create_dir_path#" mode="775">
					</cfif>
				<cfelse>
					<cfset create_dir_path = "#arguments.thestruct.newpath##parentfoldersname#">
				</cfif>

				<!--- set UPC assetID --->
				<cfset arguments.thestruct.upc_asset_id = arguments.thestruct.qry_files.id>
				<!--- Originals --->
				<cfif arguments.thestruct.download_originals>
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="download_folder_output5" returnvariable="download_folder_output5" />
					<cfoutput>#download_folder_output5#<br /></cfoutput>
					<cfflush>
					<!--- Download originals --->
					<cfinvoke method="download_upc_selected" dl_originals="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#create_dir_path#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="yes"   />
				</cfif>
				<!--- Thumbnails --->
				<cfif arguments.thestruct.download_thumbnails>
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="download_folder_output4" returnvariable="download_folder_output4" />
					<cfoutput>#download_folder_output4#<br /></cfoutput>
					<cfflush>
					<!--- Download thumbnails --->
					<cfinvoke method="download_upc_selected" dl_thumbnails="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#create_dir_path#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="yes"  />
				</cfif>
				<!--- Renditions --->
				<cfif arguments.thestruct.download_renditions>
					<!--- Feedback --->
					<cfinvoke component="defaults" method="trans" transid="download_folder_output6" returnvariable="download_folder_output6" />
					<cfoutput>#download_folder_output6#<br /></cfoutput>
					<cfflush>
					<!--- Download renditions --->
					<cfinvoke method="download_upc_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#create_dir_path#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="yes"  />
					<!--- Download additional renditions --->
					<cfinvoke method="download_upc_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#create_dir_path#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="yes"  rend_av="t"  />
				</cfif>
			<cfelse>
				<cfset arguments.thestruct.other_asset_id = listappend(arguments.thestruct.other_asset_id,'#arguments.thestruct.qry_files.id#',',')>
				<cfset arguments.thestruct.other_asset = 'true'>
			</cfif>
		</cfloop>

	<!--- Other assets --->
	<cfif arguments.thestruct.other_asset EQ 'true'>
		<!--- Reset the UPC values --->
		<cfset arguments.thestruct.folder_name = "">
		<cfset arguments.thestruct.upc_name = "">
		<cfset arguments.thestruct.upc_asset_id = "">
		<!--- Create folders according to selection and download --->
		<!--- Originals --->
		<cfif arguments.thestruct.download_originals>
			<!--- Feedback --->
			<cfinvoke component="defaults" method="trans" transid="download_folder_output5" returnvariable="download_folder_output5" />
			<cfoutput>#download_folder_output5#<br /></cfoutput>
			<cfflush>
			<cfdirectory action="create" directory="#arguments.thestruct.newpath##parentfoldersname#/originals" mode="775">
			<!--- Download originals --->
			<cfinvoke method="download_upc_selected" dl_originals="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#/originals" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="no"/>
		</cfif>
		<!--- Thumbnails --->
		<cfif arguments.thestruct.download_thumbnails>
			<!--- Feedback --->
			<cfinvoke component="defaults" method="trans" transid="download_folder_output4" returnvariable="download_folder_output4" />
			<cfoutput>#download_folder_output4#<br /></cfoutput>
			<cfflush>
			<cfdirectory action="create" directory="#arguments.thestruct.newpath##parentfoldersname#/thumbnails" mode="775">
			<!--- Download thumbnails --->
			<cfinvoke method="download_upc_selected" dl_thumbnails="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#/thumbnails" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="no"/>
		</cfif>

		<!--- Renditions --->
		<cfif arguments.thestruct.download_renditions>
			<!--- Feedback --->
			<cfinvoke component="defaults" method="trans" transid="download_folder_output6" returnvariable="download_folder_output6" />
			<cfoutput>#download_folder_output6#<br /></cfoutput>
			<cfflush>
			<cfdirectory action="create" directory="#arguments.thestruct.newpath##parentfoldersname#/renditions" mode="775">
			<!--- Download renditions --->
			<cfinvoke method="download_upc_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#/renditions" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="no"/>
			<cfinvoke method="download_upc_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#/renditions" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" is_upc="no" rend_av='t'/>
		</cfif>
	</cfif>
	<!--- RAZ-2831 : Move metadata export into folder --->
	<cfif arguments.thestruct.prefs.set2_meta_export EQ 't'>
		<cfif isdefined("arguments.thestruct.exportname")>
			<cfset var suffix = "#arguments.thestruct.exportname#">
		<cfelse>
			<cfset var suffix = "#session.hostid#-#session.theuserid#">
		</cfif>
		<cfif fileExists("#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv")>
			<cffile action="move" destination="#arguments.thestruct.newpath#" source="#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv">
		</cfif>
	</cfif>
	<!--- Feedback --->
	<cfinvoke component="defaults" method="trans" transid="download_folder_output2" returnvariable="download_folder_output2" />
	<cfoutput>#download_folder_output2#<br /></cfoutput>
	<cfflush>

	<!--- Put zip in a thread. This will force page to wait insted of timing out while zipping large files --->
	<cfset var tt=createUUID()>
	<!--- All done. ZIP and finish --->
	<cfthread action="run" intvar="#arguments.thestruct#" name="#tt#">
		<cfzip action="create" ZIPFILE="#attributes.intvar.thepath#/outgoing/folder_#attributes.intvar.folder_id#.zip" source="#attributes.intvar.newpath#" recurse="true"/>
	</cfthread>
	<!--- Get thread status --->
	<cfset var thethread=cfthread["#tt#"]>
	<!--- Output to page to prevent it from timing out while thread is running --->
	<cfloop condition="#thethread.status# EQ 'RUNNING' OR thethread.Status EQ 'NOT_STARTED' "> <!--- Wait till thread is finished --->
		<cfoutput> . </cfoutput>
		<cfset sleep(3000) >
		<cfflush>
	</cfloop>
	<cfthread action="join" name="#tt#"/>

	<!--- Zip path for download --->
	<cfinvoke component="defaults" method="trans" transid="download_folder_output3" returnvariable="download_folder_output3" />
	<cfoutput><p><a href="outgoing/folder_#arguments.thestruct.folder_id#.zip"><strong style="color:green;">#download_folder_output3#</strong></a></p></cfoutput>
	<cfflush>
	<!--- Remove the temp folder --->
	<cfdirectory action="delete" directory="#arguments.thestruct.newpath#" recurse="yes" />
</cffunction>

<!--- Select and download --->
<cffunction name="download_upc_selected" output="false">
	<cfargument name="dl_thumbnails" default="false" required="false">
	<cfargument name="dl_originals" default="false" required="false">
	<cfargument name="dl_renditions" default="false" required="false">
	<cfargument name="dl_query" required="true" type="query">
	<cfargument name="dl_folder" required="true" type="string">
	<cfargument name="assetpath" required="true" type="string">
	<cfargument name="awsbucket" required="false" type="string">
	<cfargument name="thestruct" required="false" type="struct">
	<cfargument name="is_upc" required="false" type="string">
	<cfargument name="rend_av" required="false" type="string" default="f">
	<!--- Params --->
	<cfparam name="arguments.thestruct.akaimg" default="" />
	<cfparam name="arguments.thestruct.akavid" default="" />
	<cfparam name="arguments.thestruct.akaaud" default="" />
	<cfparam name="arguments.thestruct.akadoc" default="" />
	<!--- If we are renditions we query again and set some variables --->
	<cfif arguments.dl_renditions>
		<!--- RAZ-2901 : Check for additional renditions --->
		<cfif rend_av EQ 'f'>
			<!--- Set original --->
			<cfset arguments.dl_originals = true>
			<!--- Query with group values --->
			<cfquery name="arguments.dl_query" datasource="#application.razuna.datasource#">
				SELECT img_id as id,img_filename filename, img_filename_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'img' as kind, img_upc_number as upc_number, img_extension as extension
				FROM #session.hostdbprefix#images
				WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif structKeyExists(arguments.thestruct,'upc_asset_id') AND arguments.thestruct.upc_asset_id NEQ ''>
					AND img_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upc_asset_id#" list="Yes">)
				<cfelseif structKeyExists(arguments.thestruct,'other_asset_id') AND arguments.thestruct.other_asset_id NEQ ''>
					AND img_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.other_asset_id#" list="Yes">)
				</cfif>
				UNION ALL
				SELECT vid_id as id, vid_filename filename, vid_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'vid' as kind, vid_upc_number as upc_number, vid_extension as extension
				FROM #session.hostdbprefix#videos
				WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif structKeyExists(arguments.thestruct,'upc_asset_id') AND arguments.thestruct.upc_asset_id NEQ ''>
					AND vid_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upc_asset_id#" list="Yes">)
				<cfelseif structKeyExists(arguments.thestruct,'other_asset_id') AND arguments.thestruct.other_asset_id NEQ ''>
					AND vid_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.other_asset_id#" list="Yes">)
				</cfif>
				UNION ALL
				SELECT aud_id as id,aud_name filename, aud_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'aud' as kind, aud_upc_number as upc_number, aud_extension as extension
				FROM #session.hostdbprefix#audios
				WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif structKeyExists(arguments.thestruct,'upc_asset_id') AND arguments.thestruct.upc_asset_id NEQ ''>
					AND aud_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upc_asset_id#" list="Yes">)
				<cfelseif structKeyExists(arguments.thestruct,'other_asset_id') AND arguments.thestruct.other_asset_id NEQ ''>
					AND aud_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.other_asset_id#" list="Yes">)
				</cfif>
			</cfquery>
		<cfelseif rend_av EQ 't'>
			<!--- RAZ-2901 : Get additional renditions --->
			<cfquery name="arguments.dl_query" datasource="#application.razuna.datasource#">
				SELECT av_id as id, av_link_url, av_link_title, av.folder_id_r, av.av_type, img_id, img_filename filename, img_filename_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'img' as kind
				FROM #session.hostdbprefix#images i
				INNER JOIN raz1_additional_versions av ON i.img_id = av.asset_id_r and av.av_link = 0
				WHERE i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif structKeyExists(arguments.thestruct,'upc_asset_id') AND arguments.thestruct.upc_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upc_asset_id#" list="Yes">)
				<cfelseif structKeyExists(arguments.thestruct,'other_asset_id') AND arguments.thestruct.other_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.other_asset_id#" list="Yes">)
				</cfif>
				AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT av_id as id, av_link_url, av_link_title, av.folder_id_r, av.av_type, vid_id, vid_filename filename, vid_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'vid' as kind
				FROM #session.hostdbprefix#videos v
				INNER JOIN raz1_additional_versions av ON v.vid_id = av.asset_id_r and av.av_link = 0
				WHERE v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif structKeyExists(arguments.thestruct,'upc_asset_id') AND arguments.thestruct.upc_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upc_asset_id#" list="Yes">)
				<cfelseif structKeyExists(arguments.thestruct,'other_asset_id') AND arguments.thestruct.other_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.other_asset_id#" list="Yes">)
				</cfif>
				AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT av_id as id, av_link_url, av_link_title, av.folder_id_r, av.av_type, aud_id, aud_name filename, aud_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'aud' as kind
				FROM #session.hostdbprefix#audios a
				INNER JOIN raz1_additional_versions av ON a.aud_id = av.asset_id_r and av.av_link = 0
				WHERE a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif structKeyExists(arguments.thestruct,'upc_asset_id') AND arguments.thestruct.upc_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upc_asset_id#" list="Yes">)
				<cfelseif structKeyExists(arguments.thestruct,'other_asset_id') AND arguments.thestruct.other_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.other_asset_id#" list="Yes">)
				</cfif>
				AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
				UNION ALL
				SELECT av_id as id, av_link_url, av_link_title, av.folder_id_r, av.av_type, file_id, file_name filename, file_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'doc' as kind
				FROM #session.hostdbprefix#files f
				INNER JOIN raz1_additional_versions av ON file_id = av.asset_id_r and av.av_link = 0
				WHERE f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfif structKeyExists(arguments.thestruct,'upc_asset_id') AND arguments.thestruct.upc_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upc_asset_id#" list="Yes">)
				<cfelseif structKeyExists(arguments.thestruct,'other_asset_id') AND arguments.thestruct.other_asset_id NEQ ''>
					AND av.asset_id_r IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.other_asset_id#" list="Yes">)
				</cfif>
				AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			</cfquery>
	  	</cfif>
	</cfif>
	<!--- Loop over records --->
	<cfloop query="arguments.dl_query">
		<cfif (arguments.is_upc EQ 'yes' AND (arguments.dl_query.id EQ '#arguments.thestruct.upc_asset_id#' OR arguments.dl_renditions)) OR (arguments.is_upc EQ 'no' AND (listfindnocase('#arguments.thestruct.other_asset_id#','#arguments.dl_query.id#') OR arguments.dl_renditions)) >
		<!--- Set var --->
		<cfset var theorgname = "">
		<cfif not isdefined("extension")>
			<cfset var extension = listlast(filename_org,".")>
		</cfif>

		<!--- Feedback --->
		<cfoutput>. </cfoutput>
		<cfflush>
		<!--- Check if last char of filename is an alphabet. If so then it will be appeneded to resulting UPC filename --->
		<cfset var fn_last_char = "">
		<cfif find('.', filename)>
			 <cfset fn_last_char = right(listfirst(filename,'.'),1)>
			<cfif not isnumeric(fn_last_char)>
				<cfset var fn_ischar = true>
			<cfelse>
				<cfset fn_ischar = false>
				<cfset fn_last_char = "">
			</cfif>
		</cfif>
		<!--- If we have to get thumbnails then the name is different --->
		<cfif structKeyExists(arguments.thestruct,'upc_name') AND arguments.thestruct.upc_name NEQ ''>
			<cfif arguments.dl_thumbnails AND kind EQ "img">
				<cfset var theorgname = "thumb_#id#.#ext#">
				<cfset var thefinalname = theorgname>
				<cfset var rendition_version = listlast(filename,'.')>
				<cfset var thiscloudurl = cloud_url>
				<cfset var theorgext = ext>
			<cfelse>
				<cfif kind EQ 'vid' AND (arguments.dl_originals OR arguments.dl_renditions)>
					<cfset var theorgname = replace(filename_org,'#listlast(filename_org,'.')#','#extension#','one')>
				<cfelseif not(arguments.dl_thumbnails)>
					<cfset var theorgname = filename_org>
				</cfif>
				<cfset var rendition_version ="">
				<cfif find('.', filename)>
					<cfset rendition_version = listlast(filename,'.')>
					<cfif not isnumeric(rendition_version)>
						<cfset rendition_version ="">
					<cfelse>
						<cfset rendition_version ="." & rendition_version>
					</cfif>
				</cfif>
				<cfset var theorgext = listlast(theorgname,".")>
				<cfset var thefinalname = "#arguments.thestruct.upc_name##fn_last_char##rendition_version#.#theorgext#">
				<cfset var thiscloudurl = cloud_url_org>
			</cfif>
		<cfelse>
			<cfif arguments.dl_thumbnails AND kind EQ "img">
				<cfset var theorgname = "thumb_#id#.#ext#">
				<cfset var thefinalname = theorgname>
				<cfset var thiscloudurl = cloud_url>
				<cfset var theorgext = ext>
			<cfelseif arguments.dl_originals>
				<cfif kind EQ 'vid' AND (arguments.dl_originals OR arguments.dl_renditions)>
					<cfset var theorgname = replace(filename_org,'#listlast(filename_org,'.')#','#extension#','one')>
				<cfelse>
					<cfset var theorgname = filename_org>
				</cfif>
				<cfset var thefinalname = filename>
				<cfset var thiscloudurl = cloud_url_org>
				<cfset var theorgext = listlast(filename_org,".")>
				<!--- If rendition we append the currentrow number in order to have same renditions formats still work --->
				<cfif arguments.dl_renditions>
					<cfset var tn = listfirst(filename,".")>
					<cfset var te = listlast(filename_org,".")>
					<cfset var thefinalname = tn & "_" & currentRow & "." & te>
				</cfif>
			</cfif>
		</cfif>

		<cfif not isdefined("theorgext")>
			<cfset var theorgext = extension>
		</cfif>
		<!--- RAZ-2901 : Check for additional renditions --->
		<cfif rend_av EQ 't'>
			<cfset var filename_av = listlast('#av_link_url#','/')>
			<cfset extension = listlast('#av_link_url#','.')>
			<cfif arguments.is_upc EQ 'yes'>
				<cfset var rendition_version ="">
				<cfif find('.', av_link_title)>
					<cfset rendition_version = listlast(av_link_title,'.')>
					<cfif not isnumeric(rendition_version)>
						<cfset rendition_version ="">
					<cfelse>
						<cfset rendition_version ="." & rendition_version>
					</cfif>
				</cfif>
				<cfset var thefinalname = "#arguments.thestruct.upc_name##fn_last_char##rendition_version#.#extension#">
			<cfelse>
				<cfset var thefinalname = filename_av>
			</cfif>
			<cfset var theorgname = filename_av>
			<cfset var fs = replacenocase('#av_link_url#','/','','one')>
			<cfset var link_url = replacenocase('#fs#','#filename_av#','')>
			<cfset var path_to_asset = reverse('#replacenocase('#reverse('#link_url#')#','/','','one')#')>
		</cfif>

		<cfif not isdefined("thefinalname")>
			<cfset thefinalname = theorgname>
		</cfif>

		<cfif not arguments.dl_thumbnails and arguments.is_upc EQ 'yes'>
			<!--- Remove extension from filenames for UPC --->
			<cfset thefinalname = replacenocase(replacenocase(thefinalname,".#extension#","","ALL"),".jpg","ALL")>
		</cfif>
		<!--- Start download but only if theorgname is not empty --->
		<cfif theorgname NEQ "">
			<cfset fileNameOK = true>
			<cfset uniqueCount = 1>
			<cfloop condition="#fileNameOK#">
			       <cfif fileExists("#arguments.dl_folder#/#thefinalname#")>
			       		<cfif find ('.',thefinalname)>
			       			<cfset var suffix = "." & listLast(thefinalname,'.')>
			       		<cfelse>
			       			<cfset var suffix = "">
			       		</cfif>
					<cfset thefinalname = listfirst(listFirst(thefinalname,'.'),'_')&'_'&uniqueCount & suffix >
			               	<cfset uniqueCount = uniqueCount + 1>
			       <cfelse>
			               <cfset fileNameOK = false>
			       </cfif>
			</cfloop>
			<!--- convert the filename without space and foreign chars --->
			<cfinvoke component="global" method="cleanfilename" returnvariable="thefinalname" thename="#thefinalname#">

			<!--- Local --->
			<cfif application.razuna.storage EQ "local" AND link_kind EQ "">
				<cffile action="copy" source="#arguments.assetpath#/#session.hostid#/#path_to_asset#/#theorgname#" destination="#arguments.dl_folder#/#thefinalname#" mode="775" >
			<!--- Nirvanix --->
			<cfelseif application.razuna.storage EQ "nirvanix" AND link_kind EQ "">
				<cftry>
					<cfif thiscloudurl CONTAINS "http">
						<cfhttp url="#thiscloudurl#" file="#thefinalname#" path="#arguments.dl_folder#"></cfhttp>
					</cfif>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Nirvanix error on download in folder download in function folders.download_upc_selected">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
			<!--- Akamai --->
			<cfelseif application.razuna.storage EQ "akamai" AND link_kind EQ "">
				<!--- Define the Akamai type --->
				<cfif kind EQ "img">
					<cfset var akatype = arguments.thestruct.akaimg>
				<cfelseif kind EQ "vid">
					<cfset var akatype = arguments.thestruct.akavid>
				<cfelseif kind EQ "aud">
					<cfset var akatype = arguments.thestruct.akaaud>
				<cfelse>
					<cfset var akatype = arguments.thestruct.akadoc>
				</cfif>
				<!--- For thumbnails we copy from local --->
				<cfif arguments.dl_thumbnails>
					<cffile action="copy" source="#arguments.assetpath#/#session.hostid#/#path_to_asset#/#theorgname#" destination="#arguments.dl_folder#/#thefinalname#" mode="775">
				<cfelse>
					<cftry>
						<cfhttp url="#arguments.thestruct.akaurl##akatype#/#thefinalname#" file="#thefinalname#" path="#arguments.dl_folder#"></cfhttp>
						<cfcatch type="any">
							<cfset cfcatch.custom_message = "Akamai error on download in folder download in function folders.download_upc_selected">
							<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
						</cfcatch>
					</cftry>
				</cfif>
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND link_kind EQ "">
				<cfif rend_av EQ 't'>
					<cfset path_to_asset = "#folder_id_r#/#av_type#/#id#">
					<cfset theorgname = av_link_title>
				</cfif>
				<cfinvoke component="amazon" method="Download">
					<cfinvokeargument name="key" value="/#path_to_asset#/#theorgname#">
					<cfinvokeargument name="theasset" value="#arguments.dl_folder#/#thefinalname#">
					<cfinvokeargument name="awsbucket" value="#arguments.awsbucket#">
				</cfinvoke>
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif link_kind EQ "url">
				<cffile action="write" file="#arguments.dl_folder#/#thefinalname#.txt" output="This asset is located on a external source. Here is the direct link to the asset:#link_path_url#" mode="775">
			<!--- If this is a linked asset --->
			<cfelseif link_kind EQ "lan">
				<cffile action="copy" source="#link_path_url#" destination="#arguments.dl_folder#/#thefinalname#" mode="775">
			</cfif>
		</cfif>
		<!--- Reset variables --->
		<cfset var theorgname = "">
		<cfset var thefinalname = "">
		<cfset var thiscloudurl = "">
		</cfif>
	</cfloop>
	<!--- Feedback --->
	<cfoutput><br /></cfoutput>
	<cfflush>
</cffunction>

<!--- Subscribe E-mail notification --->
<cffunction name="subscribe" access="public" output="true">
	<cfargument name="thestruct" type="struct" required="true">
	<cfparam name="arguments.thestruct.asset_keywords" default="F" >
	<cfparam name="arguments.thestruct.asset_description" default="F" >
	<!--- Cache --->
	<cfset var cachetoken = getcachetoken("general")>
	<!--- Subscribe details --->
	<cfquery datasource="#application.razuna.datasource#" name="qfoldersubscribe" cachedwithin="1" region="razcache">
	SELECT /* #cachetoken#subscribe */ fs_id
	FROM #session.hostdbprefix#folder_subscribe
	WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theid#">
	AND user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theUserID#">
	</cfquery>
	<!--- If folder subscribe details already exists then delete else insert/update --->
	<cfif arguments.thestruct.emailnotify EQ 'no'>
		<!--- Delete Subscribe details --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#folder_subscribe
		WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theid#">
		AND user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theUserID#">
		</cfquery>
	<cfelse>
		<cfif qfoldersubscribe.recordcount NEQ 0>
			<!--- Update Subscribe details --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#folder_subscribe
			SET
			fs_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">,
			mail_interval_in_hours = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.emailinterval#">,
			last_mail_notification_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			auto_entry  = 'false',
			asset_keywords = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.asset_keywords#">,
			asset_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.asset_description#">
			WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theid#">
			AND user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theUserID#">
			</cfquery>
		<cfelse>
			<!--- Insert Subscribe details --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#folder_subscribe
			(fs_id, host_id, folder_id, user_id, mail_interval_in_hours, last_mail_notification_time, asset_keywords, asset_description)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theUserID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.emailinterval#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.asset_keywords#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.asset_description#">
			)
			</cfquery>
		</cfif>
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
</cffunction>

<!--- GET SUBSCRIBE FOLDER RECORD --->
<cffunction name="getsubscribefolder" output="false" access="public" returntype="query">
	<cfargument name="folder_id" required="yes" type="string">
	<!--- Cache --->
	<cfset var cachetoken = getcachetoken("general")>
	<!--- Subscribe folder details --->
	<cfquery datasource="#application.razuna.datasource#" name="qry_folder" cachedwithin="1" region="razcache">
	SELECT /* #cachetoken#getsubscribefolder */ mail_interval_in_hours, asset_keywords, asset_description
	FROM #session.hostdbprefix#folder_subscribe
	WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folder_id#">
	AND user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theUserID#">
	</cfquery>
	<cfreturn qry_folder />
</cffunction>

<!--- REMOVE FOLDER SUBSCRIBE --->
<cffunction name="removesubscribefolder" output="false" access="public">
	<cfargument name="folderid" required="yes" type="string">
	<cfloop list="#arguments.folderid#" index="ids">
		<!--- Delete folder subscribe --->
		<cfquery datasource="#application.razuna.datasource#" >
		DELETE FROM #session.hostdbprefix#folder_subscribe
		WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ids#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("general")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<cffunction name="download_folder_structure_flat" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<cfinvoke component="defaults" method="trans" transid="download_folder_output" returnvariable="download_folder_output" />
	<!--- Feedback --->
	<cfoutput><br/><strong>#download_folder_output#</strong><br /></cfoutput>
	<cfflush>
	<!--- Params --->
	<cfset var thisstruct = structnew()>
	<cfparam name="arguments.thestruct.awsbucket" default="" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<!--- Create directory --->
	<cfset var basketname = createuuid("")>
	<cfset arguments.thestruct.newpath = arguments.thestruct.thepath & "/outgoing/#basketname#/#arguments.thestruct.qry_labels_text#">
	<cfif !directoryexists("#arguments.thestruct.newpath#")>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#" mode="775">
	</cfif>
	<!--- Create folders according to selection and download --->
	<!--- Thumbnails --->
	<cfif arguments.thestruct.download_thumbnails>
		<!--- Feedback --->
		<cfoutput>Grabbing all the thumbnails<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/thumbnails" mode="775">
		<!--- Download thumbnails --->
		<cfinvoke method="download_selected" dl_thumbnails="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Originals --->
	<cfif arguments.thestruct.download_originals>
		<!--- Feedback --->
		<cfoutput>Grabbing all the originals<br /></cfoutput>
		<cfflush>
		<cfif !directoryexists("#arguments.thestruct.newpath#/originals")>
			<cfdirectory action="create" directory="#arguments.thestruct.newpath#/originals" mode="775">
		</cfif>
		<!--- Download originals --->
		<cfinvoke method="download_selected" dl_originals="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Renditions --->
	<cfif arguments.thestruct.download_renditions>
		<!--- Feedback --->
		<cfoutput>Grabbing all the renditions<br /></cfoutput>
		<cfflush>
		<cfif !directoryexists("#arguments.thestruct.newpath#/renditions")>
			<cfdirectory action="create" directory="#arguments.thestruct.newpath#/renditions" mode="775">
		</cfif>
		<!--- Download renditions --->
		<cfinvoke method="download_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
		<!--- Download additional renditions --->
		<cfinvoke method="download_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" rend_av="t" />
	</cfif>
	<!--- RAZ-2831 : Move metadata export into folder --->
	<!--- <cfif structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount NEQ 0> --->
		<!--- <cffile action="move" destination="#arguments.thestruct.newpath#" source="#arguments.thestruct.thepath#/outgoing/metadata-export-#session.hostid#-#session.theuserid#.csv"> --->
	<!--- </cfif> --->
	<!--- Feedback --->
	<cfinvoke component="defaults" method="trans" transid="download_folder_output2" returnvariable="download_folder_output2" />
	<cfoutput><br/><strong>#download_folder_output2#</strong><br />

	</cfoutput>
	<cfflush>
	<!--- Set downloadname --->
	<cfset var tt=createUUID()>
	<cfset var dl_name = "label_" & arguments.thestruct.qry_labels_text>
	<cfset arguments.dl_name = dl_name>
	<!--- All done. ZIP and finish --->
	<!--- Put zip in a thread. This will force page to wait insted of timing out while zipping large files --->
	<cfthread action="run" intvar="#arguments#" name="#tt#">
		<cfzip action="create" ZIPFILE="#attributes.intvar.thestruct.thepath#/outgoing/#attributes.intvar.dl_name#.zip" source="#attributes.intvar.thestruct.newpath#" recurse="true"/>
	</cfthread>
	<!--- Get thread status --->
	<cfset var thethread=cfthread["#tt#"]>
	<!--- Output to page to prevent it from timing out while thread is running --->
	<cfloop condition="#thethread.status# EQ 'RUNNING' OR thethread.Status EQ 'NOT_STARTED' "> <!--- Wait till thread is finished --->
		<cfoutput> . </cfoutput>
		<cfset sleep(3000) >
		<cfflush>
	</cfloop>
	<cfthread action="join" name="#tt#"/>
	<cfinvoke component="defaults" method="trans" transid="download_folder_output3" returnvariable="download_folder_output3" />
	<!--- Zip path for download --->
	<cfoutput><p><a href="outgoing/#dl_name#.zip"><strong style="color:green;">#download_folder_output3#</strong></a></p></cfoutput>
	<cfflush>
	<!--- Remove the temp folder --->
	<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#basketname#" recurse="yes" />
</cffunction>



<!--- RAZ-2901 : Download Folder as per folder structure Razuna --->
<cffunction name="download_folder_structure" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<cfinvoke component="defaults" method="trans" transid="download_folder_output" returnvariable="download_folder_output" />
	<!--- Feedback --->
	<cfoutput><br/><strong>#download_folder_output#</strong><br /></cfoutput>
	<cfflush>
	<!--- Params --->
	<cfset var thisstruct = structnew()>
	<cfparam name="arguments.thestruct.awsbucket" default="" />
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="arguments.thestruct.iswindows">
	<cftry>
		<!--- Set time for remove --->
		<cfset var removetime = DateAdd("h", -2, "#now()#")>
		<!--- Remove old directories --->
		<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing" name="thedirs">
		<!--- Loop over dirs --->
		<cfloop query="thedirs">
			<!--- If a directory --->
			<cfif type EQ "dir" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#name#" recurse="true" mode="775">
			<cfelseif type EQ "file" AND thedirs.attributes NEQ "H" AND datelastmodified LT removetime>
				<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#name#">
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error while removing outgoing folders in function folders.download_folder">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Create directory --->
	<cfset var basketname = createuuid("")>
	<cfset arguments.thestruct.newpath = arguments.thestruct.thepath & "/outgoing/#basketname#">
	<cfif !directoryexists("#arguments.thestruct.newpath#")>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#" mode="775">
	</cfif>
	<!--- Get Parent folder names --->
	<cfinvoke component="folders" method="getbreadcrumb" folder_id_r="#arguments.thestruct.folder_id#" returnvariable="crumbs" />
	<cfset var parentfoldersname = ''>
	<cfloop list="#crumbs#" index="idx" delimiters=";">
		<cfset parentfoldersname = parentfoldersname & '/' & listfirst('#idx#','|')>
	</cfloop>
	<!--- Create Directory as per folder structure in Razuna --->
	<cfif !directoryexists("#arguments.thestruct.newpath##parentfoldersname#")>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath##parentfoldersname#" mode="775">
	</cfif>
	<!--- Create folders according to selection and download --->
	<!--- Thumbnails --->
	<cfif arguments.thestruct.download_thumbnails>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="download_folder_output4" returnvariable="download_folder_output4" />
		<cfoutput>#download_folder_output4#<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/thumbnails" mode="775">
		<!--- Download thumbnails --->
		<cfinvoke method="download_selected" dl_thumbnails="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Originals --->
	<cfif arguments.thestruct.download_originals>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="download_folder_output5" returnvariable="download_folder_output5" />
		<cfoutput>#download_folder_output5#<br /></cfoutput>
		<cfflush>
		<cfif !directoryexists("#arguments.thestruct.newpath#/originals")>
			<cfdirectory action="create" directory="#arguments.thestruct.newpath#/originals" mode="775">
		</cfif>
		<!--- Download originals --->
		<cfinvoke method="download_selected" dl_originals="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Renditions --->
	<cfif arguments.thestruct.download_renditions>
		<!--- Feedback --->
		<cfinvoke component="defaults" method="trans" transid="download_folder_output6" returnvariable="download_folder_output6" />
		<cfoutput>#download_folder_output6#<br /></cfoutput>
		<cfflush>
		<cfif !directoryexists("#arguments.thestruct.newpath#/renditions")>
			<cfdirectory action="create" directory="#arguments.thestruct.newpath#/renditions" mode="775">
		</cfif>
		<!--- Download renditions --->
		<cfinvoke method="download_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
		<!--- Download additional renditions --->
		<cfinvoke method="download_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath##parentfoldersname#" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" rend_av="t" />
	</cfif>
	<!--- RAZ-2831 : Move metadata export into folder --->
	<cfif arguments.thestruct.prefs.set2_meta_export EQ 't'>
		<!--- Feedback --->
		<cfflush>
		<cfif isdefined("arguments.thestruct.exportname")>
			<cfset var suffix = "#arguments.thestruct.exportname#">
		<cfelse>
			<cfset var suffix = "#session.hostid#-#session.theuserid#">
		</cfif>
		<cfif fileExists("#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv")>
			<cffile action="move" destination="#arguments.thestruct.newpath#/#parentfoldersname#" source="#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv">
		</cfif>
	</cfif>
	<!--- Feedback --->
	<cfinvoke component="defaults" method="trans" transid="download_folder_output2" returnvariable="download_folder_output2" />
	<cfoutput>#download_folder_output2#<br /></cfoutput>
	<cfflush>

	<!--- Put zip in a thread. This will force page to wait insted of timing out while zipping large files --->
	<cfset var tt=createUUID()>
	<!--- All done. ZIP and finish --->
	<cfthread action="run" intvar="#arguments.thestruct#" name="#tt#">
		<cfzip action="create" ZIPFILE="#attributes.intvar.thepath#/outgoing/folder_#attributes.intvar.folder_id#.zip" source="#attributes.intvar.newpath#" recurse="true"/>
	</cfthread>
	<!--- Get thread status --->
	<cfset var thethread=cfthread["#tt#"]>
	<!--- Output to page to prevent it from timing out while thread is running --->
	<cfloop condition="#thethread.status# EQ 'RUNNING' OR thethread.Status EQ 'NOT_STARTED' "> <!--- Wait till thread is finished --->
		<cfoutput> . </cfoutput>
		<cfset sleep(3000) >
		<cfflush>
	</cfloop>
	<cfthread action="join" name="#tt#"/>

	<!--- Zip path for download --->
	<cfinvoke component="defaults" method="trans" transid="download_folder_output3" returnvariable="download_folder_output3" />
	<cfoutput><p><a href="outgoing/folder_#arguments.thestruct.folder_id#.zip"><strong style="color:green;">#download_folder_output3#</strong></a></p></cfoutput>
	<cfflush>
	<!--- Remove the temp folder --->
	<cfdirectory action="delete" directory="#arguments.thestruct.newpath#" recurse="yes" />
</cffunction>


<cffunction name="getchildfolders" access="public" returntype="string" hint="Returns all children/subfolders for a given folder">
    <cfargument name="parentid" type="string" required="yes" default=0 hint="folder_id of parent folder for which to get subfolders">
    <cfargument name="level" type="numeric" required="no" default=0>
    <!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
    <!--- scoping the variables that need to have their values kept private
    to a particular instance of the function call... --->
    <cfset var checkforkids = ""><!--- used to hold temporary check for children --->
    <cfset var objnav = ""><!--- used to hold temporary subqueries --->

    <!--- On our initial call to this function, we will purge the subfolderlist  --->
    <cfif arguments.level eq 0>
        <cfset variables.subfolderlist = "">
    </cfif>
    <!--- retrieve children of our current parent folder --->
    <cfquery name="objnav" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
        SELECT /* #variables.cachetoken#getchildfoldersobjnav */ folder_id, folder_name
        FROM #session.hostdbprefix#folders
        WHERE folder_id_r = <cfqueryparam value="#arguments.parentid#" cfsqltype="cf_sql_varchar">
        AND folder_id <> <cfqueryparam value="#arguments.parentid#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <!--- loop through this parent's children... --->
    <cfloop query="objnav">
        <!--- check for children. if there are any, call this function recursively --->
        <cfquery name="checkforkids" datasource="#application.razuna.datasource#" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getchildfolderscheckforkids*/ folder_id, folder_name
		FROM  #session.hostdbprefix#folders
		WHERE folder_id_r  = <cfqueryparam value="#objnav.folder_id#" cfsqltype="cf_sql_varchar">
		AND folder_id <> <cfqueryparam value="#objnav.folder_id#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfif checkforkids.recordcount gt 0><!--- this child has kids too! add it to the subfolderlist, then make the recursive call... --->
			<cfset variables.subfolderlist = listappend(variables.subfolderlist, objnav.folder_id) >
			<cfset getchildfolders(parentid = objnav.folder_id, level = arguments.level + 1) >
        <cfelse><!--- this child is childless...just add it to the subfolderlist... --->
			<cfset variables.subfolderlist = listappend(variables.subfolderlist, objnav.folder_id)  >
        </cfif>
    </cfloop>
    <!--- return final variable to the caller... --->
    <cfif arguments.level eq 0>
        <cfreturn variables.subfolderlist>
    </cfif>
</cffunction>

<!--- Get folders which are in search selection --->
<cffunction name="getInSearchSelection" output="false" returntype="query">
	<!--- Var --->
	<cfset var qry = ''>
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Subscribe folder details --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getInSearchSelection */ folder_id, folder_name
	FROM (
			SELECT f.folder_id, f.folder_name, f.folder_owner,
			<!--- Permission follow but not for sysadmin and admin --->
			<cfif not session.is_system_admin and not session.is_administrator>
				CASE
					<!--- Check permission on this folder --->
					WHEN EXISTS(
						SELECT fg.folder_id_r
						FROM #session.hostdbprefix#folders_groups fg
						WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND fg.folder_id_r = f.folder_id
						AND fg.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
						) THEN 'unlocked'
					<!--- When folder is shared for everyone --->
					WHEN EXISTS(
						SELECT fg2.folder_id_r
						FROM #session.hostdbprefix#folders_groups fg2
						WHERE fg2.grp_id_r = '0'
						AND fg2.folder_id_r = f.folder_id
						AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						AND fg2.grp_permission IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						) THEN 'unlocked'
					<!--- If this is the user folder or he is the owner --->
					WHEN f.folder_owner = '#Session.theUserID#' THEN 'unlocked'
					<!--- If this is the upload bin --->
					WHEN f.folder_id = '1' THEN 'unlocked'
					ELSE 'locked'
				END AS perm
			<cfelse>
				'unlocked' AS perm
			</cfif>
			FROM #session.hostdbprefix#folders f LEFT JOIN users u ON u.user_id = f.folder_owner
			WHERE f.in_search_selection = <cfqueryparam cfsqltype="cf_sql_varchar" value="true">
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		) as itb
	WHERE itb.perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
	ORDER BY folder_name
	</cfquery>
	<!--- Return --->
	<cfreturn qry />
</cffunction>


<cffunction name="GetTotalAllAssets" output="false" returntype="query" hint="Totals of asset counts in folder including subfolders">
	<cfargument name ="folder_id" required="true" type="string">
	<cfset var qry = ''>
	<cfset var qry_sf = ''>
	<!--- Get list of all subfolders --->
	<cfset var subfolderslist = getchildfolders(arguments.folder_id)>
	<!--- Get file totals for main folder. Create clone of variable else original variable is modified when its value is changed. --->
	<cfset qry  = duplicate(filetotalalltypes(arguments.folder_id,'','scr'))>
	<!--- Loop over all subfolders, get totals and add to main folder total --->
	<cfloop list="#subfolderslist#" index="i">
		<cfset qry_sf  = filetotalalltypes(i,'','scr')>
		<cfloop query = "qry_sf">
			<cfset var tmp = querySetCell(qry,"cnt",qry["cnt"][currentrow] + qry_sf["cnt"][currentrow],currentrow)>
		</cfloop>
	</cfloop>
	<!--- Return --->
	<cfreturn qry />
</cffunction>

<cffunction name="checkfolder" output="false" returntype="boolean" hint="Checks that folder exists, user has access and it is not in trash">
	<cfargument name ="folder_id" required="true" type="string">
	<cfset var folder_check = "">
	<cfset var fldr_perm = "">
	<cfset var folder_check_pass = false>
	<!--- Check to see if redirect folder exists and is not in trash and that user has access permissions for it --->
	<cfinvoke component="global.cfc.folders" method="setaccess" folder_id ="#arguments.folder_id#" returnvariable="fldr_perm">
	<cfquery dataSource="#application.razuna.datasource#" name="folder_check">
		SELECT 1 FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.folder_id#" CFSQLType="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
		AND in_trash = <cfqueryparam value="f" CFSQLType="CF_SQL_VARCHAR">
	</cfquery>
	<cfif folder_check.recordcount NEQ 0 AND listfindnocase('r,w,x',fldr_perm)>
		<cfset folder_check_pass = true>
	</cfif>
	<cfreturn folder_check_pass/>
</cffunction>


<cffunction name="getFlatFolderList" output="false" returntype="query">
	<!--- Cache --->
	<cfset var cachetoken = getcachetoken("folders")>
	<!--- Param --->
	<cfset var qry = "" >
	<!--- Query folder on root level --->
	<cfquery dataSource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #cachetoken#getFlatFolderList */ f.folder_of_user, f.folder_id, f.folder_name, '0' as folder_level, f.folder_name as folder_path, <cfif application.razuna.thedatabase EQ "h2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username
	FROM #session.hostdbprefix#folders f LEFT JOIN users u ON u.user_id = f.folder_owner
	WHERE f.folder_id = f.folder_id_r
	AND f.host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
	AND f.in_trash = <cfqueryparam value="f" CFSQLType="CF_SQL_VARCHAR">
	AND (f.folder_is_collection IS NULL OR f.folder_is_collection = '')
	</cfquery>
	<!--- Pass query to recursive function to get child folders --->
	<cfinvoke method="recfoldername" returnvariable="_qry">
		<cfinvokeargument name="theqry" value="#qry#">
		<cfinvokeargument name="theoverallqry" value="#qry#">
	</cfinvoke>
	<!--- Sort query --->
	<cfset QuerySort( _qry, 'folder_path', 'textnocase' )>
	<!--- Return --->
	<cfreturn _qry>
</cffunction>

<!--- RECURSIVE SUBQUERY TO READ FOLDERS --->
<cffunction name="recfoldername" output="false" access="public" returntype="query">
	<cfargument name="theqry" required="yes">
	<cfargument name="theoverallqry" required="no" default="#querynew('folder_of_user, folder_id, folder_name, folder_level, folder_path, username')#">
	<cfargument name="thelevel" required="no" default="0">
	<!--- Increase folder level --->
	<cfset thelevel = arguments.thelevel + 1>
	<!--- Cache --->
	<cfset var cachetoken = getcachetoken("folders")>
	<!--- Loop over the given query --->
	<cfloop query="arguments.theqry">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="local_query" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#recfolder */ f.folder_of_user, f.folder_id, f.folder_name, '#thelevel#' as folder_level, <cfif application.razuna.thedatabase EQ "mssql">'#folder_path# / ' + f.folder_name<cfelse>concat('#folder_path# / ',f.folder_name)</cfif> as folder_path, <cfif application.razuna.thedatabase EQ "h2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username
		FROM #session.hostdbprefix#folders f LEFT JOIN users u ON u.user_id = f.folder_owner
		WHERE f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#folder_id#">
		AND f.folder_id <cfif application.razuna.thedatabase EQ "mysql"><><cfelse>!=</cfif> f.folder_id_r
		AND f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Add the found records to the general query --->
		<cfif local_query.RecordCount NEQ 0>
			<cfquery dbtype="query" name="arguments.theoverallqry">
			SELECT * FROM arguments.theqry
			UNION
			SELECT * FROM local_query
			UNION
			SELECT * FROM arguments.theoverallqry
			</cfquery>
			<!--- get child-folders of next level but only if this is not the same folder_id. This fixes a bug some experiences where folders would not get removed --->
			<cfinvoke method="recfoldername" returnvariable="sub_query">
				<cfinvokeargument name="theqry" value="#local_query#">
				<cfinvokeargument name="theoverallqry" value="#arguments.theoverallqry#">
				<cfinvokeargument name="thelevel" value="#thelevel#">
			</cfinvoke>
			<cfif sub_query.RecordCount NEQ 0>
				<cfquery dbtype="query" name="arguments.theoverallqry">
				SELECT * FROM arguments.theqry
				UNION
				SELECT * FROM sub_query
				UNION
				SELECT * FROM arguments.theoverallqry
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn arguments.theoverallqry>
</cffunction>


</cfcomponent>
