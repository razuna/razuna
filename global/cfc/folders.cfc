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
		<cfif not Request.securityObj.CheckSystemAdminUser() and not Request.securityObj.CheckAdministratorUser()>
			CASE
				<!--- If this folder is protected with a group and this user belongs to this group --->
				WHEN EXISTS(
					SELECT fg.folder_id
					FROM #session.hostdbprefix#folders_groups fg, ct_groups_users gu
					WHERE fg.folder_id_r = f.folder_id
					AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
					AND gu.ct_g_u_grp_id = fg.grp_id_r
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2 LEFT JOIN ct_groups_users gu2 ON gu2.ct_g_u_grp_id = fg2.grp_id_r AND gu2.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
					WHERE fg2.folder_id_r = f.folder_id
					AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					) THEN 'unlocked'
				<!--- If this is the user folder or he is the owner --->
				WHEN ( lower(f.folder_of_user) = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
				<!--- If this is the upload bin
				WHEN f.folder_id = 1 THEN 'unlocked' --->
				<!--- If this is a collection --->
				-- WHEN lower(f.folder_is_collection) = 't' THEN 'unlocked'
				<!--- If nothing meets the above lock the folder --->
				ELSE 'locked'
			END AS perm
		<cfelse>
			CASE
				WHEN ( lower(f.folder_of_user) = 't' AND f.folder_owner = '#Session.theUserID#' AND lower(f.folder_name) = 'my folder') THEN 'unlocked'
				WHEN ( lower(f.folder_of_user) = 't' AND lower(f.folder_name) = 'my folder') THEN 'locked'
				ELSE 'unlocked'
			END AS perm
		</cfif>
	FROM #session.hostdbprefix#folders f
	WHERE 
	<cfif Arguments.id gt 0>
		f.folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
		AND
		f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.id#">
	<cfelse>
		f.folder_id = f.folder_id_r
	</cfif>
	<cfif Arguments.ignoreCollections>
		AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
	</cfif>
	<cfif Arguments.onlyCollections>
		AND lower(f.folder_is_collection) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
	</cfif>
	<!--- filter user folders --->
	<!--- Does not apply to SystemAdmin users --->
	<cfif not Request.securityObj.CheckSystemAdminUser()>
		AND
			(
			LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(f.folder_of_user,<cfqueryparam cfsqltype="cf_sql_varchar" value="f">)) <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			OR f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
			)
	</cfif>
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY lower(folder_name)
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
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery name="qLocal" datasource="#Variables.dsn#" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfolder */ f.folder_id, f.folder_id_r, f.folder_name, f.folder_level, f.folder_of_user,
	f.folder_is_collection, f.folder_owner, folder_main_id_r rid, f.folder_shared, f.folder_name_shared,
	share_dl_org, share_dl_thumb, share_comments, share_upload, share_order, share_order_user, share_dl_thumb
	FROM #session.hostdbprefix#folders f
	WHERE folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Arguments.folder_id#">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<!--- *** START SECURITY *** --->
	<!--- filter user folders
	AND (
		LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull</cfif>(f.folder_of_user,<cfqueryparam cfsqltype="cf_sql_varchar" value="f">)) != <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		OR f.folder_owner = <cfqueryparam cfsqltype="cf_sql_numeric" value="#Session.theUserID#">
	) --->
	<!--- filter folder permissions, not neccessary for SysAdmin or Admin --->
	<cfif not Request.securityObj.CheckSystemAdminUser() and not Request.securityObj.CheckAdministratorUser()>
		AND (
			<!--- R/W/X permission by group --->
			EXISTS(
				SELECT fg.GRP_ID_R,fg.GRP_PERMISSION
				FROM #session.hostdbprefix#folders_groups fg
				WHERE fg.folder_id_r = f.folder_id
				AND LOWER(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				AND fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND (
					<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(fg.grp_id_r, 0) = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">
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
				AND LOWER(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
			)
		)
	</cfif>
	<!--- *** END SECURITY *** --->
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
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfolderdesc */ folder_desc, lang_id_r
	FROM #session.hostdbprefix#folders_desc
	WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- GET THE GROUPS FOR THIS FOLDER --->
<cffunction hint="GET THE GROUPS FOR THIS FOLDER" name="getfoldergroups" output="false">
	<cfargument name="folder_id" default="" required="yes" type="string">
	<cfargument name="qrygroup" required="yes" type="query">
	<!--- Set --->
	<cfset var thegroups = 0>
	<!--- Query --->
	<cfif arguments.qrygroup.recordcount NEQ 0>
		<cfquery datasource="#variables.dsn#" name="thegroups" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getfoldergroups */ grp_id_r, grp_permission
		FROM #session.hostdbprefix#folders_groups
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND grp_id_r IN (
						<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ValueList(arguments.qrygroup.grp_id)#" list="true">
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
			<!--- Increase folder level --->
			<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
			<!--- Check for the same name --->
			<cfquery datasource="#variables.dsn#" name="samefolder">
			SELECT folder_id
			FROM #session.hostdbprefix#folders
			WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="cf_sql_varchar">
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
				<cfdump var="#cfcatch#">
				<cfabort>
			</cfcatch>
		</cftry>
	<!--- This is a link --->
	<cfelse>
		<!--- Param --->
		<cfset arguments.thestruct.link_kind = "lan">
		<cfset arguments.thestruct.dsn = variables.dsn>
		<cfset arguments.thestruct.setid = variables.setid>
		<cfset arguments.thestruct.database = variables.database>
		<!--- Increase folder level --->
		<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(arguments.thestruct.link_path,"/\")>
		<!--- Add the folder --->
		<cfinvoke method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="newfolderid">
		<cfoutput>#trim(newfolderid)#</cfoutput>
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
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="arguments.thestruct.thefiles" type="file">
		<!--- Filter out hidden files --->
		<cfquery dbtype="query" name="arguments.thestruct.thefiles">
		SELECT *
		FROM arguments.thestruct.thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Param --->
		<cfset arguments.thestruct.folder_id = newfolderid>
		<!--- Thread for adding files of this folder --->
		<cfthread intstruct="#arguments.thestruct#">
			<!--- Loop over the assets --->
			<cfloop query="attributes.intstruct.thefiles">
				<!--- Params --->
				<cfset attributes.intstruct.link_path_url = directory & "/" & name>
				<cfset attributes.intstruct.orgsize = size>
				<!--- Now add the asset --->
				<cfinvoke component="assets" method="addassetlink" thestruct="#attributes.intstruct#">
			</cfloop>
		</cfthread>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#arguments.thestruct.link_path#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<!--- Call rec function --->
		<cfif thesubdirs.recordcount NEQ 0>
			<!--- Put folderid into struct --->
			<cfset arguments.thestruct.theid = newfolderid>
			<!--- Call function --->
			<cfthread intstruct="#arguments.thestruct#">
				<cfinvoke method="folder_link_rec" thestruct="#attributes.intstruct#">
			</cfthread>
		</cfif>
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
	<cfqueryparam value="#arguments.thestruct.folder_name#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam value="#arguments.thestruct.level#" cfsqltype="cf_sql_numeric">,
	<cfif arguments.thestruct.level IS NOT 1>
		<cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
	<cfelse>
		<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>,
	<cfif Val(arguments.thestruct.rid)>
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
			<cfset var thisfield="arguments.thestruct.folder_desc_" & "#langindex#">
			<cfif #thisfield# CONTAINS "#langindex#">
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
	<!--- Apply custom setting to new folder --->
	<cfinvoke method="apply_custom_shared_setting" folder_id="#newfolderid#" />
	<!--- Log --->
	<cfset log_folders(theuserid=session.theuserid,logaction='Add',logdesc='Added: #arguments.thestruct.folder_name# (ID: #newfolderid#)')>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("folders")>
	<!--- Return --->
	<cfreturn newfolderid />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- REMOVE THIS FOLDER ALL SUBFOLDER AND FILES WITHIN --->
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
	<!--- Get custom settings --->
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
		<cfinvoke method="trash_folder_thread" thestruct="#arguments.thestruct#" returnvariable="parent_folder_id"/>
		
		<!---<cfset var tt = createuuid()>
		<cfthread name="#tt#" intstruct="#arguments.thestruct#">
			<cfinvoke method="trash_folder_thread" thestruct="#attributes.intstruct#" />
		</cfthread>
		<cfthread action="join" name="#tt#" /> --->
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
			<!--- Delete main folder --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM	#session.hostdbprefix#folders
			WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Log --->
			<cfset log_folders(theuserid=session.theuserid,logaction='Delete',logdesc='Deleted: #foldername.folder_name# (ID: #arguments.thestruct.folder_id#)')>
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("folders")>
			<!--- The rest goes in a thread since it can run in the background --->
			<cfthread intstruct="#arguments.thestruct#">
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
						<cfinvoke component="extQueryCaching" method="log_folders" theuserid="#session.theuserid#" logaction="Delete" logdesc="Deleted: #foldernamesub.folder_name# (ID: #thefolderid#)" />
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
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error removing folder - #cgi.http_host#">
				<cfdump var="#cfcatch#" />
				<cfdump var="#arguments.thestruct#" />
			</cfmail>
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn parentid.folder_id_r>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- THREAD : TRASH THIS FOLDER ALL SUBFOLDER AND FILES WITHIN --->
<cffunction name="trash_folder_thread" output="false">
	<cfargument name="thestruct" type="struct">
	<cfquery datasource="#application.razuna.datasource#" name="get_folder">
		SELECT * FROM #session.hostdbprefix#folders  
		WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Update the in_trash --->
	<cfquery datasource="#application.razuna.datasource#" name="thedetail">
		UPDATE #session.hostdbprefix#folders SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T"> 
		WHERE folder_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">	
	</cfquery>
	<!--- Set the parent folder id --->
	<cfif get_folder.folder_level EQ 1>
		<cfset var parent_folder_id_r = 0>
	<cfelse>
		<cfset var parent_folder_id_r = get_folder.folder_id_r>
	</cfif>
	<cfreturn parent_folder_id_r />
</cffunction>

<!--- Get All Folder Trash --->
<cffunction name="gettrashfolder" output="false" returntype="Query">
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
	<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
		, 'X' as permfolder
	<cfelse>
		,
		CASE
			WHEN (SELECT DISTINCT fg5.grp_permission
			FROM #session.hostdbprefix#folders_groups fg5
			WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fg5.folder_id_r = f.folder_id_r
			AND fg5.grp_id_r = '0') = 'R' THEN 'R'
			WHEN (SELECT DISTINCT fg5.grp_permission
			FROM #session.hostdbprefix#folders_groups fg5
			WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fg5.folder_id_r = f.folder_id_r
			AND fg5.grp_id_r = '0') = 'W' THEN 'W'
			WHEN (SELECT DISTINCT fg5.grp_permission
			FROM #session.hostdbprefix#folders_groups fg5
			WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND fg5.folder_id_r = f.folder_id_r
			AND fg5.grp_id_r = '0') = 'X' THEN 'X'
			<cfloop list="#session.thegroupofuser#" delimiters="," index="i">
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'R' THEN 'R'
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'W' THEN 'W'
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'X' THEN 'X'
			</cfloop>
			WHEN (f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">) THEN 'X'
			ELSE 'R'
		END as permfolder
	</cfif>
	FROM #session.hostdbprefix#folders f
	WHERE f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND f.folder_is_collection IS NULL
	</cfquery>
	<!--- Add "in_collection" Column --->
	<cfif qry.RecordCount NEQ 0>
		<cfset myArray = arrayNew( 1 )>
		<cfset temp= ArraySet(myArray, 1, qry.RecordCount, "False")>
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
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#images
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery>
					<!--- Flush cache --->
					<cfinvoke component="extQueryCaching" method="resetcachetoken" type="images" />
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="images" method="removeimage" thestruct="#attributes.instruct.thestruct#" />
				<!--- VIDEOS --->
				<cfelseif kind EQ "vid">
					<!--- Change db to have another in_trash flag --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#videos
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery>
					<!--- Flush cache --->
					<cfinvoke component="extQueryCaching" method="resetcachetoken" type="videos" />
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="videos" method="removevideo" thestruct="#attributes.instruct.thestruct#" />
				<!--- FILES --->
				<cfelseif kind EQ "doc">
					<!--- Change db to have another in_trash flag --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery>
					<!--- Flush cache --->
					<cfinvoke component="extQueryCaching" method="resetcachetoken" type="files" />
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="files" method="removefile" thestruct="#attributes.instruct.thestruct#" />
				<!--- AUDIOS --->
				<cfelseif kind EQ "aud">
					<!--- Change db to have another in_trash flag --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#audios
					SET in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="X">
					WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					</cfquery>
					<!--- Flush cache --->
					<cfinvoke component="extQueryCaching" method="resetcachetoken" type="audios" />
					<!--- Call remove function --->
					<cfset attributes.instruct.thestruct.id = id>
					<cfinvoke component="audios" method="removeaudio" thestruct="#attributes.instruct.thestruct#" />
				</cfif>
			</cfif>
		</cfloop>
	</cfthread>
	<!--- Flush Cache --->
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
				<cfset arguments.thestruct.folder_id = id>
				<cfinvoke component="extQueryCaching" method="resetcachetoken" type="folders" />
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
				<!--- Flush cache --->
				<cfinvoke component="extQueryCaching" method="resetcachetoken" type="images" />
			<cfelseif kind EQ "aud">
				<!--- Update the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#audios
					SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
						in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
					WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
				</cfquery>
				<!--- Flush cache --->
				<cfinvoke component="extQueryCaching" method="resetcachetoken" type="audios" />
			<cfelseif kind EQ "vid">
				<!--- Update the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#videos
					SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
						in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
					WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
				</cfquery>
				<!--- Flush cache --->
				<cfinvoke component="extQueryCaching" method="resetcachetoken" type="videos" />
			<cfelseif kind EQ "doc">
				<!--- Update the folder_id_r --->
				<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
						in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
					WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
				</cfquery>
				<!--- Flush cache --->
				<cfinvoke component="extQueryCaching" method="resetcachetoken" type="files" />
			</cfif>
		</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- store trash files ids in session --->
<cffunction name="trash_file_values" output="false">
	<!--- set ids --->
	<cfset var ids = "">
		<!--- trash images --->
		<cfinvoke component="images" method="gettrashimage" returnvariable="imagetrash" />
		<cfset var imageid = valueList(imagetrash.id)>
		<cfloop list="#imageid#" index="i">
			<!--- set ids --->
			<cfset var ids = listAppend(ids,"#i#-img")>
		</cfloop>
		<!--- Flush cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="images" />
		<!--- trash audios --->
		<cfinvoke component="audios" method="gettrashaudio" returnvariable="audiotrash" />
		<cfset var audioid = valueList(audiotrash.id)>
		<cfloop list="#audioid#" index="i">
			<!--- set ids --->
			<cfset var ids = listAppend(ids,"#i#-aud")>
		</cfloop>
		<!--- Flush cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="audios" />
		<!--- trash files --->
		<cfinvoke component="files" method="gettrashfile" returnvariable="filetrash" />
		<cfset var fileid = valueList(filetrash.id)>
		<cfloop list="#fileid#" index="i">
			<!--- set ids --->
			<cfset var ids = listAppend(ids,"#i#-doc")>
		</cfloop>
		<!--- Flush cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="files" />
		<!--- trash videos --->
		<cfinvoke component="videos" method="gettrashvideos" returnvariable="videotrash" />
		<cfset var videoid = valueList(videotrash.id)>
		<cfloop list="#videoid#" index="i">
			<!--- set ids --->
			<cfset var ids = listAppend(ids,"#i#-vid")>
		</cfloop>
		<!--- Flush cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="videos" />
	<!--- Set the sessions --->
	<cfset session.file_id = ids>
	<cfset session.thefileid = ids>
	<!--- Flush Cache --->
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
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
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imageid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> 
			</cfquery>
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="images" />
		<cfelseif i CONTAINS "-aud">
			<!--- set audio id --->
			<cfset var audioid = listFirst(i,'-')>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#audioid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="audios" />
		<cfelseif i CONTAINS "-vid">
			<!--- set video id --->
			<cfset var videoid = listFirst(i,'-')>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#videos
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#videoid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="videos" />
		<cfelseif i CONTAINS "-doc">
			<!--- set file id --->
			<cfset var fileid = listFirst(i,'-')>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">,
					in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="files" />
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfreturn />
</cffunction>

<!--- Remove selected files in trash --->
<cffunction name="trashfiles_remove" output="false">
	<cfargument name="thestruct" type="struct">
	<cfset arguments.thestruct.ids = arguments.thestruct.id>
	<cfloop list="#arguments.thestruct.ids#" index="i" delimiters=",">
		<!--- get images --->
		<cfif i CONTAINS "-img">
			<!--- set image id --->
			<cfset arguments.thestruct.id = listFirst(i,'-')>
			<cfinvoke component="images" method="removeimage"  thestruct="#arguments.thestruct#" />
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="images" />
		<cfelseif i CONTAINS "-aud">
			<!--- set audio id --->
			<cfset arguments.thestruct.id = listFirst(i,'-')>
			<cfinvoke component="audios" method="removeaudio" thestruct="#arguments.thestruct#" />
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="audios" />
		<cfelseif i CONTAINS "-vid">
			<!--- set video id --->
			<cfset arguments.thestruct.id = listFirst(i,'-')>
			<cfinvoke component="videos" method="removevideo" thestruct="#arguments.thestruct#" />
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="videos" />
		<cfelseif i CONTAINS "-doc">
			<!--- set file id --->
			<cfset arguments.thestruct.id = listFirst(i,'-')>
			<cfinvoke component="files" method="removefile" thestruct="#arguments.thestruct#" />
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="files" />
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfreturn />
</cffunction>

<!--- store trash folder ids in session --->
<cffunction name="trash_folder_values" output="false">
	<!--- set ids --->
	<cfset var ids = "">
	<!--- Get folders ids in the trash --->
	<cfinvoke component="folders" method="gettrashfolder" returnvariable="qry_trash" />
	<!--- Flush cache --->
	<cfinvoke component="extQueryCaching" method="resetcachetoken" type="folders" />
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
		<!--- Flush cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="folders" />
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
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
			<!--- Flush cache --->
			<cfinvoke component="extQueryCaching" method="resetcachetoken" type="folders" />
		</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
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
		<!--- Flush cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="folders" />
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("folders")>
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
			SET folder_id_r = <cfqueryparam value="#arguments.thestruct.intofolderid#" cfsqltype="CF_SQL_VARCHAR">, 
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
	  	<!--- Flush cache --->
		<cfinvoke component="extQueryCaching" method="resetcachetoken" type="folders" />
		<!--- Flush Cache --->
		<cfset resetcachetoken("folders")>
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
			<cfif directoryexists("#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thefolderid#")>
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
	share_order_user = <cfqueryparam value="#arguments.thestruct.share_order_user#" cfsqltype="CF_SQL_VARCHAR">
	WHERE folder_id = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("folders")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- SAVE FOLDER PROPERTIES --->
<cffunction name="update" output="true" returntype="string">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset arguments.thestruct.grpno = "T">
	<!--- Check for the same name --->
	<cfquery datasource="#variables.dsn#" name="samefolder">
	SELECT folder_name
	FROM #session.hostdbprefix#folders
	WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="cf_sql_varchar">
	AND folder_level = <cfqueryparam value="#arguments.thestruct.level#" cfsqltype="cf_sql_numeric">
	AND folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	AND lower(folder_of_user) <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
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
		SET folder_name = <cfqueryparam value="#arguments.thestruct.folder_name#" cfsqltype="cf_sql_varchar">
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Update the Desc --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<cfset var thisfield="arguments.thestruct.folder_desc_" & "#langindex#">
			<cfif #thisfield# CONTAINS "#langindex#">
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
			AND folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Call recursive function to inherit permissions --->
			<!--- If there are any then call this function again --->
			<cfif arguments.thestruct.qrysubfolder.recordcount NEQ 0>
				<cfinvoke method="folderinheritperm" thestruct="#arguments.thestruct#">
			</cfif>
		</cfif>
		<!--- Log --->
		<cfset log_folders(theuserid=session.theuserid,logaction='Update',logdesc='Updated: #arguments.thestruct.folder_name# (ID: #arguments.thestruct.folder_id#)')>
		<!--- Flush Cache --->
		<cfset resetcachetoken("search")>
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
	<!--- Call function for DOC --->
	<cfset arguments.thestruct.kind = "doc">
	<cfinvoke method="filetotaltype" thestruct="#arguments.thestruct#" returnvariable="totaldoc">
	<cfset totaltypes.doc = totaldoc.thetotal>
	<!--- Return --->
	<cfreturn totaltypes>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- HOW MANY FILES ARE IN TOTAL IN THIS FOLDER --->
<cffunction name="filetotalcount" output="false">
	<cfargument name="folder_id" default="" required="yes" type="string">
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
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="total" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#filetotalcount */
		(
		SELECT count(fi.file_id)
		FROM #session.hostdbprefix#files fi, #session.hostdbprefix#folders f
		WHERE fi.folder_id_r = f.folder_id 
		AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
		AND fi.folder_id_r IS NOT NULL
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND fi.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND fi.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<cfif arguments.theoverall EQ "f" AND arguments.folder_id NEQ "">
			AND fi.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND fi.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
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
		<cfif arguments.theoverall EQ "F" AND arguments.folder_id NEQ "">
			AND i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
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
		<cfif arguments.theoverall EQ "F" AND arguments.folder_id NEQ "">
			AND v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
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
		<cfif arguments.theoverall EQ "F" AND arguments.folder_id NEQ "">
			AND a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		</cfif>
		<!--- If coming from custom view and the session.customfileid is not empty --->
		<cfif session.customfileid NEQ "">
			AND a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
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
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		</cfquery>
	<!--- Files --->
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
			lower(file_extension) = <cfqueryparam value="#arguments.thestruct.kind#" cfsqltype="cf_sql_varchar">
			OR lower(file_extension) = <cfqueryparam value="#arguments.thestruct.kind#x" cfsqltype="cf_sql_varchar">
			)
		<cfelse>
			lower(file_extension) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
		</cfif>
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
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
		FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
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
	<!--- Params --->
	<cfparam name="session.customfileid" default="">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<cfquery datasource="#variables.dsn#" name="qTab" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#fileTotalAllTypes */ 'doc' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_word' as scr
		FROM #session.hostdbprefix#files
		WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND SUBSTR<cfif variables.database EQ "mssql">ING</cfif>(file_extension,1,3) = 'doc'
		AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif session.customfileid NEQ "">
			AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
		</cfif>
		UNION ALL
			SELECT 'xls' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_excel' as scr
			FROM #session.hostdbprefix#files
			WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND SUBSTR<cfif variables.database EQ "mssql">ING</cfif>(file_extension,1,3) = 'xls'
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif session.customfileid NEQ "">
				AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
		UNION ALL
			SELECT 'pdf' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_pdf' as scr
			FROM #session.hostdbprefix#files
			WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND SUBSTR<cfif variables.database EQ "mssql">ING</cfif>(file_extension,1,3) = 'pdf'
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif session.customfileid NEQ "">
				AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
		UNION ALL
			SELECT 'other' as ext, count(file_id) as cnt, 'doc' as typ, 'tab_others' as scr
			FROM #session.hostdbprefix#files
			WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND ((SUBSTR<cfif variables.database EQ "mssql">ING</cfif>(file_extension,1,3) <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> 'doc'
			AND SUBSTR<cfif variables.database EQ "mssql">ING</cfif>(file_extension,1,3) <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> 'xls'
			AND file_extension <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> 'pdf')
			OR  file_type = 'other')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif session.customfileid NEQ "">
				AND file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
		UNION ALL
			SELECT 'img' as ext, count(img_id) as cnt, 'img' as typ, 'tab_images' as scr
			FROM #session.hostdbprefix#images
			WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND (img_group IS NULL OR img_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<!--- If coming from custom view and the session.customfileid is not empty --->
			<cfif session.customfileid NEQ "">
				AND img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
		UNION ALL
			SELECT 'vid' as ext, count(vid_id) as cnt, 'vid' as typ, 'tab_videos' as scr
			FROM #session.hostdbprefix#videos
			WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND (vid_group IS NULL OR vid_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif session.customfileid NEQ "">
				AND vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
		UNION ALL
			SELECT 'aud' as ext, count(aud_id) as cnt, 'aud' as typ, 'tab_audios' as scr
			FROM #session.hostdbprefix#audios
			WHERE folder_id_r = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND (aud_group IS NULL OR aud_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif session.customfileid NEQ "">
				AND aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.customfileid#" list="true">)
			</cfif>
		ORDER BY cnt DESC, scr
	</cfquery>

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
	SELECT /* #variables.cachetoken#setaccess */ <cfif arguments.sf>'0' as folder_owner<cfelse>f.folder_owner</cfif>, fg.grp_id_r, fg.grp_permission
	<cfif arguments.sf>
		FROM #session.hostdbprefix#smart_folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.sf_id = fg.folder_id_r AND f.host_id = fg.host_id
		WHERE f.sf_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	<cfelse>
		FROM #session.hostdbprefix#folders f LEFT JOIN #session.hostdbprefix#folders_groups fg ON f.folder_id = fg.folder_id_r AND f.host_id = fg.host_id
		WHERE f.folder_id = <cfqueryparam value="#arguments.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND (
		fg.grp_id_r IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thegroupofuser#" list="true">)
		OR
		fg.grp_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		)
	</cfquery>
	<!--- Loop over results --->
	<cfloop query="fprop">
		<cfif grp_permission EQ "R" AND folderaccess NEQ "W" AND folderaccess NEQ "X">
			<cfset var folderaccess = grp_permission>
		<cfelseif grp_permission EQ "W" AND folderaccess NEQ "X">
			<cfset var folderaccess = grp_permission>
		<cfelseif grp_permission EQ "X">
			<cfset var folderaccess = grp_permission>
		</cfif>
	</cfloop>
	<!--- If the user is a sys or admin or the owner of the folder give full access --->
	<cfif structKeyExists(request,"securityObj") AND (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()) OR fprop.folder_owner EQ session.theuserid>
		<cfset var folderaccess = "x">
	</cfif>
	<!--- If session.customaccess is here and is not empty --->
	<cfif structKeyExists(session,"customaccess") AND session.customaccess NEQ "">
		<cfset var folderaccess = session.customaccess>
	</cfif>
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
	AND lower(name) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="outgoing,js,images,.svn,parsed,model,controller,translations,views,.DS_Store,bluedragon,global,incoming,web-inf,.git,backup">)
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
		<cfset log_folders(theuserid=session.theuserid,logaction='Move',logdesc='Moved: #foldername.folder_name# (ID: #arguments.thestruct.tomovefolderid#)')>
		<!--- Ups something went wrong --->
		<cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="error folder move - #cgi.HTTP_HOST#">
				<cfdump var="#arguments.thestruct#" />
				<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- RECURSIVE SUBQUERY TO READ FOLDERS --->
<cffunction name="recfolder" output="false" access="public" returntype="string">
	<cfargument name="thelist" required="yes" hint="list of parent folder-ids">
	<cfargument name="thelevel" required="false" hint="the level">
	<!--- function internal vars --->
	<cfset var local_query = 0>
	<cfset var local_list = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="local_query">
	SELECT folder_id, folder_level
	FROM #session.hostdbprefix#folders
	WHERE folder_id_r IN (<cfqueryparam value="#arguments.thelist#" cfsqltype="CF_SQL_VARCHAR" list="true">)
	AND folder_id != folder_id_r
	<!--- AND folder_level <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
	AND folder_level <cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thelevel#" cfsqltype="cf_sql_numeric"> --->
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
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getuserfolder */ folder_id
		FROM #session.hostdbprefix#folders
		WHERE lower(folder_of_user) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfreturn qry.folder_id>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get all assets of this folder --->
<cffunction name="getallassets" output="true" returnType="query">
	<cfargument name="thestruct" type="struct" required="true">
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
		<cfinvoke method="getfoldersinlist" dsn="#variables.dsn#" folder_id="#arguments.thestruct.folder_id#" database="#variables.database#" hostid="#session.hostid#" returnvariable="thefolders">
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
			<cfif variables.database EQ "db2">
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
	<!--- Oracle --->
	<cfif variables.database EQ "oracle">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getallassets */ rn, id, filename, folder_id_r, ext, filename_org, kind, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, vheight, vwidth, theformat, filename_forsort, size, hashtag, labels
		FROM (
			SELECT ROWNUM AS rn, id, filename, folder_id_r, ext, filename_org, kind, date_create, date_change, link_kind, 
			link_path_url, path_to_asset, cloud_url, cloud_url_org, description, keywords, vheight, vwidth, theformat, filename_forsort, size, hashtag, labels
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
				'' as labels
				FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
				WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND (i.img_group IS NULL OR i.img_group = '')
				AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				UNION ALL
				SELECT v.vid_id as id, v.vid_filename as filename, v.folder_id_r, v.vid_extension as ext, v.vid_name_image as filename_org,
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
				'' as labels
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
				'' as labels
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
				'' as labels
				FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
				WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
				AND a.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				ORDER BY #sortby#
				)
			WHERE ROWNUM <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#max#">
			)
		WHERE rn > <cfqueryparam cfsqltype="cf_sql_numeric" value="#min#">
		</cfquery>
	<!--- DB2 --->
	<cfelseif variables.database EQ "db2">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getallassets */ id, filename, folder_id_r, ext, filename_org, kind, is_available, date_create, date_change, link_kind, link_path_url,
		path_to_asset, cloud_url, cloud_url_org, description, keywords, theformat, filename_forsort, size, hashtag
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
			'' as labels
			FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
			WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND (i.img_group IS NULL OR i.img_group = '')
			AND i.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			UNION ALL
			SELECT row_number() over() as rownr, v.vid_id as id, v.vid_filename as filename, v.folder_id_r,
			v.vid_extension as ext, v.vid_name_image as filename_org, 'vid' as kind, v.is_available,
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
			'' as labels
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
			'' as labels
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
			lower(f.file_name) as filename_forsort, f.file_size as size, f.hashtag, '' as labels
			FROM #session.hostdbprefix#files f LEFT JOIN #session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
			WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
			AND f.in_trash = 'F'
			AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			ORDER BY #sortby#
		)
		<!--- Show the limit only if pages is null or current (from print) --->
		<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
			WHERE rownr between #min# AND #max#
		</cfif>
		</cfquery>
	<!--- Other DB's --->
	<cfelse>
		<!--- MySQL Offset --->
		<cfset var mysqloffset = session.offset * session.rowmaxpage>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		<!--- MSSQL --->
		<cfif application.razuna.thedatabase EQ "mssql">
			SELECT * FROM (
			SELECT ROW_NUMBER() OVER ( ORDER BY #sortby# ) AS RowNum,sorted_inline_view.* FROM (
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
		lower(i.img_filename) as filename_forsort,
		i.img_size as size,
		i.hashtag,
		'' as labels
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">it
				<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename">i
				<cfelse>x
				</cfif>.#m#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.videos_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.files_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#images i LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1 LEFT JOIN #session.hostdbprefix#xmp x ON x.id_r = i.img_id
		WHERE i.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (i.img_group IS NULL OR i.img_group = '')
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		UNION ALL
		SELECT v.vid_id as id, v.vid_filename as filename, v.in_trash,v.folder_id_r, 
		v.vid_extension as ext, v.vid_name_image as filename_org, 'vid' as kind, v.is_available,
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
		lower(v.vid_filename) as filename_forsort,
		v.vid_size as size,
		v.hashtag,
		'' as labels
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
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
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#videos v LEFT JOIN #session.hostdbprefix#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
		WHERE v.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (v.vid_group IS NULL OR v.vid_group = '')
		AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
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
		lower(a.aud_name) as filename_forsort,
		a.aud_size as size,
		a.hashtag,
		'' as labels
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.videos_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.files_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">aut
				<cfelse>a
				</cfif>.#m#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
		WHERE a.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND (a.aud_group IS NULL OR a.aud_group = '')
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		UNION ALL
		SELECT f.file_id as id, f.file_name as filename,f.in_trash, f.folder_id_r, 
		f.file_extension as ext, f.file_name_org as filename_org, f.file_type as kind, f.is_available,
		f.file_create_time as date_create, f.file_change_time as date_change, f.link_kind, f.link_path_url,
		f.path_to_asset, f.cloud_url, f.cloud_url_org, ft.file_desc as description, ft.file_keywords as keywords, '0' as vwidth, '0' as vheight, '0' as theformat,
		lower(f.file_name) as filename_forsort, f.file_size as size, f.hashtag, '' as labels
		<!--- custom metadata fields to show --->
		<cfif arguments.thestruct.cs.images_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.videos_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.files_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
				,<cfif m CONTAINS "keywords" OR m CONTAINS "description">ft
				<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename">f
				<cfelse>x
				</cfif>.#m#
			</cfloop>
		</cfif>
		<cfif arguments.thestruct.cs.audios_metadata NEQ "">
			<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
				,'' AS #listlast(m," ")#
			</cfloop>
		</cfif>
		FROM #session.hostdbprefix#files f LEFT JOIN #session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1 LEFT JOIN #session.hostdbprefix#files_xmp x ON x.asset_id_r = f.file_id
		WHERE f.folder_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#thefolderlist#" list="true">)
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
		<!--- MSSQL --->
		<cfif application.razuna.thedatabase EQ "mssql">
			) sorted_inline_view
			 ) resultSet
			  WHERE RowNum > #mysqloffset# AND RowNum <= #mysqloffset+session.rowmaxpage# 
		</cfif>
		<!--- Show the limit only if pages is null or current (from print) --->
		<cfif arguments.thestruct.pages EQ "" OR arguments.thestruct.pages EQ "current">
			<!--- MySQL / H2 --->
			<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
				ORDER BY #sortby# LIMIT #mysqloffset#,#session.rowmaxpage#
			</cfif>
		</cfif>
	</cfquery>
	</cfif>
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
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Trash all selected records. Mixed data types thus get them here --->
<cffunction name="trashall" output="true">
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
	<cfargument name="thestruct" type="struct" required="true">
	<cfargument name="id" type="string" required="true">
	<cfargument name="col" type="string" required="true">
	<!--- If col is T or the id contains col- --->
	<cfif arguments.col EQ "T" or arguments.id CONTAINS "col-">
		<cfset var iscol = "T">
		<cfset var theid = listlast(arguments.id, "-")>
	<cfelse>
		<cfset var iscol = "F">
		<cfset var theid = arguments.id>
	</cfif>
	<!--- If this use is not in the admin groups clear the showmyfolder session --->
	<cfif NOT Request.securityObj.CheckSystemAdminUser() AND NOT Request.securityObj.CheckAdministratorUser()>
		<cfset session.showmyfolder = "F">
	</cfif>
	<!--- Param --->
	<cfparam default="0" name="session.thefolderorg">
	<cfparam default="0" name="session.type">
	<cfparam default="F" name="arguments.thestruct.actionismove">
	<cfparam default="0" name="session.thegroupofuser">
	<cfset var qry = "">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken##session.theUserID#getfoldersfortree */ folder_id, folder_name, folder_id_r, folder_of_user, folder_owner, folder_level, in_trash, username, perm, subhere, permfolder
	FROM (
		SELECT f.folder_id, f.folder_name, f.folder_id_r, f.folder_of_user, f.folder_owner, f.folder_level,f.in_trash, 
		<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username,
		<!--- Permission follow but not for sysadmin and admin --->
		<cfif not Request.securityObj.CheckSystemAdminUser() and not Request.securityObj.CheckAdministratorUser()>
			CASE
				<!--- Check permission on this folder --->
				WHEN EXISTS(
					SELECT fg.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg
					WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg.folder_id_r = f.folder_id
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					) THEN 'unlocked'
				<!--- When folder is shared for everyone --->
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #session.hostdbprefix#folders_groups fg2
					WHERE fg2.grp_id_r = '0'
					AND fg2.folder_id_r = f.folder_id
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				<!--- If this is the user folder or he is the owner --->
				WHEN ( lower(f.folder_of_user) = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
				<!--- If this is the upload bin --->
				WHEN f.folder_id = '1' THEN 'unlocked'
				<!--- If this is a collection --->
				-- WHEN lower(f.folder_is_collection) = 't' THEN 'unlocked'
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
				SELECT <cfif variables.database EQ "mssql">TOP 1 </cfif>*
				FROM #session.hostdbprefix#folders s1 
				WHERE s1.folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> f.folder_id
				AND s1.folder_id_r = f.folder_id
				ANd s1.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND s1.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<!--- AND lower(s.folder_of_user) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">  --->
				<cfif not Request.securityObj.CheckSystemAdminUser() and not Request.securityObj.CheckAdministratorUser()>
					AND s1.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
				</cfif>
				<!--- If this is a move then dont show the folder that we are moving --->
				<cfif arguments.thestruct.actionismove EQ "T" AND session.type EQ "movefolder">
					AND s1.folder_id != <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thefolderorg#">
				</cfif>
				<cfif variables.database EQ "oracle">
					AND ROWNUM = 1
				<cfelseif  variables.database EQ "mysql" OR variables.database EQ "h2">
					LIMIT 1
				</cfif>
			) THEN 1
			<!--- Check permission on this folder --->
			WHEN EXISTS(
				SELECT <cfif variables.database EQ "mssql">TOP 1 </cfif>*
				FROM #session.hostdbprefix#folders s2, #session.hostdbprefix#folders_groups fg3
				WHERE s2.folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> f.folder_id
				AND s2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND s2.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND fg3.host_id = s2.host_id
				AND s2.folder_id_r = f.folder_id
				AND fg3.folder_id_r = s2.folder_id
				AND lower(fg3.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				AND fg3.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				<cfif variables.database EQ "oracle">
					AND ROWNUM = 1
				<cfelseif  variables.database EQ "mysql" OR variables.database EQ "h2">
					LIMIT 1
				</cfif>
			) THEN 1
			<!--- When folder is shared for everyone --->
			WHEN EXISTS(
				SELECT <cfif variables.database EQ "mssql">TOP 1 </cfif>*
				FROM #session.hostdbprefix#folders s3, #session.hostdbprefix#folders_groups fg4
				WHERE s3.folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> f.folder_id
				AND s3.folder_id_r = f.folder_id
				ANd s3.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
				AND fg4.grp_id_r = '0'
				AND fg4.folder_id_r = s3.folder_id
				AND lower(fg4.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				AND s3.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND s3.host_id = fg4.host_id
				<cfif variables.database EQ "oracle">
					AND ROWNUM = 1
				<cfelseif  variables.database EQ "mysql" OR variables.database EQ "h2">
					LIMIT 1
				</cfif>
			) THEN 1
			<!--- If nothing meets the above lock the folder --->
			ELSE 0
		END AS subhere
		<!--- Permfolder --->
		<cfif Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser()>
			, 'X' as permfolder
		<cfelse>
			,
			CASE
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND fg5.grp_id_r = '0') = 'R' THEN 'R'
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND fg5.grp_id_r = '0') = 'W' THEN 'W'
				WHEN (SELECT DISTINCT fg5.grp_permission
				FROM #session.hostdbprefix#folders_groups fg5
				WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg5.folder_id_r = f.folder_id_r
				AND fg5.grp_id_r = '0') = 'X' THEN 'X'
				<cfloop list="#session.thegroupofuser#" delimiters="," index="i">
					WHEN (SELECT DISTINCT fg5.grp_permission
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id_r
					AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'R' THEN 'R'
					WHEN (SELECT DISTINCT fg5.grp_permission
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id_r
					AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'W' THEN 'W'
					WHEN (SELECT DISTINCT fg5.grp_permission
					FROM #session.hostdbprefix#folders_groups fg5
					WHERE fg5.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					AND fg5.folder_id_r = f.folder_id_r
					AND fg5.grp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#i#">) = 'X' THEN 'X'
				</cfloop>
				WHEN (f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">) THEN 'X'
			END as permfolder
		</cfif>
		FROM #session.hostdbprefix#folders f LEFT JOIN users u ON u.user_id = f.folder_owner
		WHERE 
		<cfif theid gt 0>
			f.folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
			AND
			f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
		<cfelse>
			f.folder_id = f.folder_id_r
		</cfif>
		<cfif iscol EQ "F">
			AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
		<cfelse>
			AND lower(f.folder_is_collection) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		</cfif>
		<!--- filter user folders, but not for collections --->
		<cfif iscol EQ "F" AND (NOT Request.securityObj.CheckSystemAdminUser() AND NOT Request.securityObj.CheckAdministratorUser())>
			AND
				(
				LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(f.folder_of_user,<cfqueryparam cfsqltype="cf_sql_varchar" value="f">)) <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
				OR f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
				)
		</cfif>
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		) as itb
	WHERE itb.perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
	<!--- If this is a move then dont show the folder that we are moving --->
	<cfif session.type EQ "uploadinto" OR session.type EQ "movefolder" OR session.type EQ "movefile" OR session.type EQ "choosecollection">
		AND (itb.permfolder = 'W' OR itb.permfolder = 'X')
		<cfif session.type EQ "movefolder">
			AND itb.folder_id != <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.thefolderorg#">
		</cfif>
	</cfif>
	ORDER BY lower(folder_name)
	</cfquery>
	<!--- Create the XML --->
	<cfif theid EQ 0>
		<!--- This is the ROOT level  --->
		<cfif session.showmyfolder EQ "F" AND iscol NEQ "T">
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qry
			WHERE folder_of_user = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">
			OR (lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="my folder"> AND folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">)
			OR folder_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1">
			OR folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
			</cfquery>
		</cfif>
	</cfif>
	<!--- Tree for the Explorer --->
	<cfif arguments.thestruct.actionismove EQ "F">
		<cfoutput query="qry">
		<cfif qry.in_trash EQ 'F'>
		<li id="<cfif iscol EQ "T">col-</cfif>#folder_id#"<cfif subhere EQ "1"> class="closed"</cfif>><a href="##" onclick="loadcontent('rightside','index.cfm?fa=<cfif iscol EQ "T">c.collections<cfelse>c.folder</cfif>&col=F&folder_id=<cfif iscol EQ "T">col-</cfif>#folder_id#');" rel="prefetch" title="<cfif theid EQ 0><cfif iscol EQ "F"><cfif session.theuserid NEQ folder_owner AND folder_owner NEQ "">Folder of (#username#)</cfif></cfif></cfif>"><ins>&nbsp;</ins>#left(folder_name,40)#<cfif theid EQ 0><cfif iscol EQ "F"><cfif session.theuserid NEQ folder_owner AND folder_owner NEQ "">*<cfif folder_name EQ "my folder"> (#username#)</cfif></cfif></cfif></cfif>
		</a></li>
		</cfif>
		</cfoutput>
	<!--- If we come from a move action --->
	<cfelse>
		<cfoutput query="qry">
			<cfif qry.in_trash EQ 'F'>
				<li id="<cfif iscol EQ "T">col-</cfif>#folder_id#"<cfif subhere EQ "1"> class="closed"</cfif>>
					<!--- movefile --->
					<cfif session.type EQ "movefile">
						<cfif session.thefolderorg NEQ folder_id>
							<cfif arguments.thestruct.kind EQ "search">
								<a href="##" onclick="$('##div_choosefolder_status').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#&folder_name=#URLEncodedFormat(folder_name)#', function(){$('##div_choosefolder_status').html('The file(s) are being moved now.<br />Note: For a large batch of files this can take some time until it reflects in the system!<br />You can close this window.');});">
							<cfelse>
								<a href="##" onclick="$('##div_forall').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#', function(){$('##div_choosefolder_status').html('The file(s) are being moved now.<br />Note: For a large batch of files this can take some time until it reflects in the system!<br />You can close this window.');});">
							</cfif>
						</cfif>
					<!--- movefolder --->
					<cfelseif session.type EQ "movefolder">
						<cfif session.thefolderorg NEQ folder_id>
							<a href="##" onclick="$('##div_forall').load('index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#', function(){$('##explorer').load('index.cfm?fa=c.explorer<cfif iscol EQ "T">_col</cfif>');<cfif arguments.thestruct.fromtrash>$('##rightside').load('index.cfm?fa=c.<cfif iscol EQ "T">collection<cfelse>folder</cfif>_explorer_trash');</cfif>});destroywindow(1);return false;">
						</cfif>
					<!--- restorefolder --->
					<cfelseif session.type EQ "restorefolder">
						<cfif session.thefolderorg NEQ folder_id>
							<!---<a href="##" onclick="$('##rightside').load('index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#');destroywindow(1);return false;">--->
							<a href="##" onclick="loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#');$('##rightside').load('index.cfm?fa=c.folder_explorer_trash&trashkind=folders');destroywindow(1);return false;">
						</cfif>
					<!--- restoreselectedfolders --->
					<cfelseif session.type EQ "restoreselectedfolders">
						<cfif session.thefolderorg NEQ folder_id>
							<a href="##" onclick="loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#&iscol=#iscol#');destroywindow(1);return false;">
						</cfif>
					<!--- restorefile --->
					<cfelseif session.type EQ "restorefile">
						<cfif session.thefolderorg NEQ folder_id> 
							<a href="##" onclick="<cfif session.thefileid CONTAINS ",">loadoverlay();</cfif>$('##rightside').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#&intolevel=#folder_level#', function(){loadfolderwithdelay('#session.thefolderorg#');$('##bodyoverlay').remove();});destroywindow<cfif NOT session.thefileid CONTAINS ",">(2)<cfelse>(1)</cfif>;<cfif NOT session.thefileid CONTAINS ",">loadcontent('thewindowcontent1','index.cfm?fa=c.<cfif session.thetype EQ "doc">files<cfelseif session.thetype EQ "img">images<cfelseif session.thetype EQ "vid">videos<cfelseif session.thetype EQ "aud">audios</cfif>_detail&file_id=#session.thefileid#&what=<cfif session.thetype EQ "doc">files<cfelseif session.thetype EQ "img">images<cfelseif session.thetype EQ "vid">videos<cfelseif session.thetype EQ "aud">audios</cfif>&loaddiv=&folder_id=#folder_id#')</cfif>;">
						</cfif>
					<!--- restorefileall --->
					<cfelseif session.type EQ "restorefileall">
						<cfif session.thefolderorg NEQ folder_id>
							<a href="##" onclick="$('##rightside').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
						</cfif>
					<!--- restoreselectedfiles --->
					<cfelseif session.type EQ "restoreselectedfiles">
						<cfif session.thefolderorg NEQ folder_id>
							<a href="##" onclick="$('##rightside').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
						</cfif>
					<!--- restorefolderall --->
					<cfelseif session.type EQ "restorefolderall">
						<cfif session.thefolderorg NEQ folder_id>
							<a href="##" onclick="$('##rightside').load('index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
						</cfif> 
					<!--- saveaszip or as a collection --->
					<cfelseif session.type EQ "saveaszip" OR session.type EQ "saveascollection">
						<a href="##" onclick="loadcontent('win_choosefolder','index.cfm?fa=#session.savehere#&folder_id=#folder_id#&folder_name=#URLEncodedFormat(folder_name)#');">
					<!--- upload --->
					<cfelseif session.type EQ "uploadinto">
						<a href="##" onclick="showwindow('index.cfm?fa=c.asset_add&folder_id=#folder_id#','Add your files',650,1);return false;">
					<!--- customization --->
					<cfelseif session.type EQ "customization">
						<a href="##" onclick="javascript:document.form_admin_custom.folder_redirect.value = '#folder_id#'; document.form_admin_custom.folder_name.value = '#folder_name#';destroywindow(1);">
					<!--- scheduler --->
					<cfelseif session.type EQ "scheduler">
						<a href="##" onclick="javascript:document.schedulerform.folder_id.value = '#folder_id#'; document.schedulerform.folder_name.value = '#folder_name#';destroywindow(2);">
					<!--- choose a collection --->
					<cfelseif session.type EQ "choosecollection">
						<a href="##" onclick="loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
					<!--- choose a collection for restore file --->
					<cfelseif session.type EQ "restore_collection_file">
						<a href="##" onclick="loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
					<!--- Restore all collection files in the trash --->
					<cfelseif session.type EQ "restoreallcollectionfiles">
						<a href="##" onclick="loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
					<!--- Restore selected collection files in the trash --->
					<cfelseif session.type EQ "restoreselectedcolfiles">
						<a href="##" onclick="loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#folder_id#');">
					<!--- choose a folder for restore collection --->
					<cfelseif session.type EQ "restore_collection">
						<a href="##" onclick="loadcontent('collections','index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
					<!--- Restore all collections in the trash --->
					<cfelseif session.type EQ "restoreallcollections">
						<a href="##" onclick="$('##rightside').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
					<!--- Restore selected collections  --->
					<cfelseif session.type EQ "restoreselectedcollection">
						<a href="##" onclick="loadcontent('collections','index.cfm?fa=#session.savehere#&folder_id=#folder_id#');destroywindow(1);return false;">
					<!--- Restore collection folder in the trash --->
					<cfelseif session.type EQ "restorecolfolder">
						<a href="##" onclick="loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
					<!--- Restore all collection folder in the trash --->
					<cfelseif session.type EQ "restorecolfolderall">
						<a href="##" onclick="$('##rightside').load('index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
					<!--- Restore all collection folder in the trash --->
					<cfelseif session.type EQ "restoreselectedcolfolder">
						<a href="##" onclick="loadcontent('folders','index.cfm?fa=#session.savehere#&intofolderid=#folder_id#&intolevel=#folder_level#');destroywindow(1);return false;">
					<!--- Plugin --->
					<cfelseif session.type EQ "plugin">
						<a href="##" onclick="$('##wf_folder_id_2').val('#folder_id#'); $('##wf_folder_name_2').val('#folder_name#');destroywindow(1);">
					<!--- From Smart Folder --->
					<cfelseif session.type EQ "sf_download">
						<a href="##" onclick="$('##div_forall').load('index.cfm?fa=#session.savehere#&folder_id=#folder_id#');$('##div_choosefolder_status').html('All file(s) are going to be downloaded now and stored in the chosen folder!');return false;">
					</cfif>
					<ins>&nbsp;</ins>#folder_name#<cfif iscol EQ "F" AND folder_name EQ "my folder" AND (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())><cfif session.theuserid NEQ folder_owner AND folder_owner NEQ ""> (#username#)</cfif></cfif>
					<cfif session.thefolderorg NEQ folder_id></a></cfif>
				</li>
			</cfif>
		</cfoutput>
	</cfif>
	<cfreturn />
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
	<!--- Query --->
	<cfif session.iscol EQ "F">
		<cfquery datasource="#variables.dsn#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#sharecheckpermfolder */ folder_id,
			<!--- Permission follow but not for sysadmin and admin --->
			<cfif not Request.securityObj.CheckSystemAdminUser() and not Request.securityObj.CheckAdministratorUser()>
				CASE
					WHEN EXISTS(
						SELECT fg.folder_id_r
						FROM #session.hostdbprefix#folders_groups fg LEFT JOIN ct_groups_users gu ON gu.ct_g_u_grp_id = fg.grp_id_r AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
						WHERE fg.folder_id_r = f.folder_id
						AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
						) THEN 'unlocked'
					<!--- If this is the user folder or he is the owner --->
					WHEN ( lower(f.folder_of_user) = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
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
			<cfif not Request.securityObj.CheckSystemAdminUser() and not Request.securityObj.CheckAdministratorUser()>
				CASE
					WHEN EXISTS(
						SELECT fg.col_id_r
						FROM #session.hostdbprefix#collections_groups fg LEFT JOIN ct_groups_users gu ON gu.ct_g_u_grp_id = fg.grp_id_r AND gu.ct_g_u_user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#Session.theUserID#">
						WHERE fg.col_id_r = f.col_id
						AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
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
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Sharing for selected assets --->
<cffunction name="batch_sharing" output="true">
	<cfargument name="thestruct" type="struct" required="true">
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
	<cfset variables.cachetoken = resetcachetoken("folders")>
	<cfreturn />
</cffunction>

<!--- LINK: Check Folder --->
<cffunction name="link_check" output="false">
	<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfset var status = structnew()>
		<!--- Does the dir exists --->
		<cfset status.dir = directoryexists("#arguments.thestruct.link_path#")>
		<cfif status.dir>
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
	<!--- If there is no session for webgroups set --->
	<cfparam default="0" name="session.thegroupofuser">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getsubfolders */ f.folder_id, f.folder_name, f.folder_id_r, f.folder_of_user, f.folder_owner, f.folder_level, <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(u.user_login_name,'Obsolete') as username,
	<!--- Permission follow but not for sysadmin and admin --->
	<cfif structKeyExists(Request.securityObj,"CheckSystemAdminUser") AND structKeyExists(Request.securityObj,"CheckAdministratorUser") AND NOT Request.securityObj.CheckSystemAdminUser() AND NOT Request.securityObj.CheckAdministratorUser() AND NOT structkeyexists(arguments,"external")>
		CASE
			<!--- Check permission on this folder --->
			WHEN EXISTS(
				SELECT fg.folder_id_r
				FROM #session.hostdbprefix#folders_groups fg
				WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND fg.folder_id_r = f.folder_id
				AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
				) THEN 'unlocked'
			<!--- When folder is shared for everyone --->
			WHEN EXISTS(
				SELECT fg2.folder_id_r
				FROM #session.hostdbprefix#folders_groups fg2
				WHERE fg2.grp_id_r = '0'
				AND fg2.folder_id_r = f.folder_id
				AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
				) THEN 'unlocked'
			<!--- If this is the user folder or he is the owner --->
			WHEN ( lower(f.folder_of_user) = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
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
	FROM #session.hostdbprefix#folders f LEFT JOIN users u ON u.user_id = f.folder_owner
	WHERE 
	<cfif arguments.folder_id gt 0>
		f.folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> f.folder_id_r
		AND
		f.folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.folder_id#">
	<cfelse>
		f.folder_id = f.folder_id_r
	</cfif>
	<!--- <cfif iscol EQ "F"> --->
		AND (f.folder_is_collection IS NULL OR folder_is_collection = '')
	<!---
<cfelse>
		AND lower(f.folder_is_collection) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
	</cfif>
--->
	<!--- filter user folders, but not for collections --->
	<cfif (structKeyExists(Request.securityObj,"CheckSystemAdminUser") AND structKeyExists(Request.securityObj,"CheckAdministratorUser") AND NOT Request.securityObj.CheckSystemAdminUser() AND NOT Request.securityObj.CheckAdministratorUser()) AND NOT structkeyexists(arguments,"external")>
		AND
			(
			LOWER(<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(f.folder_of_user,<cfqueryparam cfsqltype="cf_sql_varchar" value="f">)) <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			OR f.folder_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
			)
	</cfif>
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	AND f.in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
	ORDER BY lower(folder_name)
	</cfquery>
	<!--- Query to get unlocked folders only --->
	<cfquery dbtype="query" name="qRet">
	SELECT *
	FROM qry
	WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
	</cfquery>
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
	<!--- Param --->
	<cfset var qry = "">
	<cfparam name="flist" default="">
	<!--- Query: Get current folder_id_r --->
	<cfquery datasource="#arguments.dsn#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getbreadcrumb */ f.folder_name, f.folder_id_r, f.folder_id
	<cfif arguments.fromshare>
		<!--- If there is no session for webgroups set --->
		<cfparam default="0" name="session.thegroupofuser">
		<cfif session.iscol EQ "F">
			,
			CASE
				<!--- Check permission on this folder --->
				WHEN EXISTS(
					SELECT fg.folder_id_r
					FROM #arguments.prefix#folders_groups fg
					WHERE fg.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
					AND fg.folder_id_r = f.folder_id
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					AND fg.grp_id_r IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.thegroupofuser#" list="true">)
					) THEN 'unlocked'
				<!--- When folder is shared for everyone --->
				WHEN EXISTS(
					SELECT fg2.folder_id_r
					FROM #arguments.prefix#folders_groups fg2
					WHERE fg2.grp_id_r = '0'
					AND fg2.folder_id_r = f.folder_id
					AND fg2.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.hostid#">
					AND lower(fg2.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
					) THEN 'unlocked'
				<!--- If this is the user folder or he is the owner --->
				WHEN ( lower(f.folder_of_user) = 't' AND f.folder_owner = '#Session.theUserID#' ) THEN 'unlocked'
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
					AND lower(fg.grp_permission) IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="r,w,x" list="true">)
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
	<!--- QoQ --->
	<cfif arguments.fromshare>
		<cfquery dbtype="query" name="qry">
		SELECT *
		FROM qry
		WHERE perm = <cfqueryparam cfsqltype="cf_sql_varchar" value="unlocked">
		</cfquery>
	</cfif>
	<cfif qry.recordcount NEQ 0>
		<!--- Set the current values into the list --->
		<cfset flist = qry.folder_name & "|" & qry.folder_id & "|" & qry.folder_id_r & ";" & arguments.folderlist>
		<!--- If the folder_id_r is not the same the passed one --->
		<cfif qry.folder_id_r NEQ arguments.folder_id_r>
			<!--- Call this function again --->
			<cfinvoke method="getbreadcrumb" folder_id_r="#qry.folder_id_r#" folderlist="#flist#" fromshare="#arguments.fromshare#" dsn="#arguments.dsn#" prefix="#arguments.prefix#" hostid="#arguments.hostid#" />
		</cfif>
	</cfif>
	<!--- Return --->	
	<cfreturn flist>
</cffunction>

<!--- Download Folder --->
<cffunction name="download_folder" output="false">
	<cfargument name="thestruct" required="yes" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>We are starting to prepare the folder. Please wait. Once done, you can find the file to download at the bottom of this page!</strong><br /></cfoutput>
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
			<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="error in removing outgoing folders" dump="#cfcatch#">
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
		<cfoutput>Grabbing all the thumbnails<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/thumbnails" mode="775">
		<!--- Download thumbnails --->
		<cfinvoke method="download_selected" dl_thumbnails="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#/thumbnails" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Originals --->
	<cfif arguments.thestruct.download_originals>
		<!--- Feedback --->
		<cfoutput>Grabbing all the originals<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/originals" mode="775">
		<!--- Download originals --->
		<cfinvoke method="download_selected" dl_originals="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#/originals" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Renditions --->
	<cfif arguments.thestruct.download_renditions>
		<!--- Feedback --->
		<cfoutput>Grabbing all the renditions<br /></cfoutput>
		<cfflush>
		<cfdirectory action="create" directory="#arguments.thestruct.newpath#/renditions" mode="775">
		<!--- Download renditions --->
		<cfinvoke method="download_selected" dl_renditions="true" dl_query="#arguments.thestruct.qry_files#" dl_folder="#arguments.thestruct.newpath#/renditions" assetpath="#arguments.thestruct.assetpath#" awsbucket="#arguments.thestruct.awsbucket#" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Feedback --->
	<cfoutput>Ok. All files are here. Creating a nice ZIP file for you now.<br /></cfoutput>
	<cfflush>
	<!--- All done. ZIP and finish --->
	<cfzip action="create" ZIPFILE="#arguments.thestruct.thepath#/outgoing/folder_#arguments.thestruct.folder_id#.zip" source="#arguments.thestruct.newpath#" recurse="true" timeout="300" />
	<!--- Zip path for download --->
	<cfoutput><p><a href="outgoing/folder_#arguments.thestruct.folder_id#.zip"><strong style="color:green;">All done. Here is your downloadable folder</strong></a></p></cfoutput>
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
	<cfargument name="thestruct" required="false" type="struct">
	<!--- Params --->
	<cfparam name="arguments.thestruct.akaimg" default="" />
	<cfparam name="arguments.thestruct.akavid" default="" />
	<cfparam name="arguments.thestruct.akaaud" default="" />
	<cfparam name="arguments.thestruct.akadoc" default="" />
	<!--- If we are renditions we query again and set some variables --->
	<cfif arguments.dl_renditions>
		<!--- Set original --->
		<cfset arguments.dl_originals = true>
		<!--- Query with group values --->
		<cfquery name="arguments.dl_query" datasource="#application.razuna.datasource#">
		SELECT img_filename filename, img_filename_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'img' as kind
		FROM #session.hostdbprefix#images
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND img_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(arguments.dl_query.id)#" list="Yes">)
		UNION ALL
		SELECT vid_filename filename, vid_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'vid' as kind
		FROM #session.hostdbprefix#videos
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND vid_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(arguments.dl_query.id)#" list="Yes">)
		UNION ALL
		SELECT aud_name filename, aud_name_org filename_org, link_kind, link_path_url, path_to_asset, cloud_url, cloud_url_org, 'aud' as kind
		FROM #session.hostdbprefix#audios
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND aud_group IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(arguments.dl_query.id)#" list="Yes">)
		</cfquery>
	</cfif>
	<!--- Loop over records --->
	<cfloop query="arguments.dl_query">
		<!--- Set var --->
		<cfset var theorgname = "">
		<!--- Feedback --->
		<cfoutput>. </cfoutput>
		<cfflush>
		<!--- If we have to get thumbnails then the name is different --->
		<cfif arguments.dl_thumbnails AND kind EQ "img">
			<cfset var theorgname = "thumb_#id#.#ext#">
			<cfset var thefinalname = theorgname>
			<cfset var thiscloudurl = cloud_url>
			<cfset var theorgext = ext>
		<cfelseif arguments.dl_originals>
			<cfset var theorgname = filename_org>
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
		<!--- Start download but only if theorgname is not empty --->
		<cfif theorgname NEQ "">
			<!--- Check if thefinalname has an extension. If not add the original one --->
			<cfif listlast(thefinalname,".") NEQ theorgext>
				<cfset var thefinalname = filename & "." & theorgext>
			</cfif>
			<!--- Local --->
			<cfif application.razuna.storage EQ "local" AND link_kind EQ "">
				<cffile action="copy" source="#arguments.assetpath#/#session.hostid#/#path_to_asset#/#theorgname#" destination="#arguments.dl_folder#/#thefinalname#" mode="775">
			<!--- Nirvanix --->
			<cfelseif application.razuna.storage EQ "nirvanix" AND link_kind EQ "">
				<cftry>
					<cfif thiscloudurl CONTAINS "http">
						<cfhttp url="#thiscloudurl#" file="#thefinalname#" path="#arguments.dl_folder#"></cfhttp>
					</cfif>
					<cfcatch type="any">
						<cfmail from="server@razuna.com" to="support@razuna.com" subject="Nirvanix error on download in folder download" type="html">
							<cfdump var="#cfcatch#">
							<cfdump var="#session#">
						</cfmail>
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
							<cfmail from="server@razuna.com" to="support@razuna.com" subject="Akamai error on download in folder download" type="html">
								<cfdump var="#cfcatch#">
								<cfdump var="#session#">
							</cfmail>
						</cfcatch>
					</cftry>
				</cfif>
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon" AND link_kind EQ "">
				<cfinvoke component="amazon" method="Download">
					<cfinvokeargument name="key" value="/#path_to_asset#/#theorgname#">
					<cfinvokeargument name="theasset" value="#arguments.dl_folder#/#thefinalname#">
					<cfinvokeargument name="awsbucket" value="#arguments.awsbucket#">
				</cfinvoke>
			<!--- If this is a URL we write a file in the directory with the PATH --->
			<cfelseif link_kind EQ "url">
				<cffile action="write" file="#arguments.dl_folder#/#thefinalname#.txt" output="This asset is located on a external source. Here is the direct link to the asset:
							
#link_path_url#" mode="775">
			<!--- If this is a linked asset --->
			<cfelseif link_kind EQ "lan">
				<cffile action="copy" source="#link_path_url#" destination="#arguments.dl_folder#/#thefinalname#" mode="775">
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
	<!--- Get ids --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	<cfif arguments.thestruct.thekind EQ "ALL" OR arguments.thestruct.thekind EQ "img">
		SELECT /* #variables.cachetoken#sv */ <cfif application.razuna.thedatabase EQ "mssql">img_id + '-img'<cfelse>concat(img_id,'-img')</cfif> as id
		FROM #session.hostdbprefix#images
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND (img_group IS NULL OR img_group = '')
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
	</cfif>
	<cfif arguments.thestruct.thekind EQ "ALL">
		UNION ALL
	</cfif>
	<cfif arguments.thestruct.thekind EQ "ALL" OR (arguments.thestruct.thekind NEQ "vid" AND arguments.thestruct.thekind NEQ "img" AND arguments.thestruct.thekind NEQ "aud")>
		SELECT <cfif application.razuna.thedatabase EQ "mssql">file_id + '-doc'<cfelse>concat(file_id,'-doc')</cfif> as id
		FROM #session.hostdbprefix#files
		WHERE folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.thestruct.thekind EQ "other">
			AND lower(file_extension) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
		<cfelseif arguments.thestruct.thekind NEQ "all">
			AND (
			lower(file_extension) = <cfqueryparam value="#arguments.thestruct.thekind#" cfsqltype="cf_sql_varchar">
			OR lower(file_extension) = <cfqueryparam value="#arguments.thestruct.thekind#x" cfsqltype="cf_sql_varchar">
			)
		</cfif>
	</Cfif>
	</cfquery>
	<!--- Set the valuelist   --->
	<cfset var l = valuelist(qry.id)>
	<!--- Set the sessions --->
	<cfset session.file_id = l>
	<cfset session.thefileid = l>
</cffunction>

<!--- Store selection --->
<cffunction name="store_selection" output="false" returntype="void">
	<cfargument name="thestruct" required="yes" type="struct">
	<!---<cfdump var="#arguments.thestruct.del_file_id#"><cfabort>--->
	<!--- session --->
	<cfparam name="session.file_id" default="">
	<cfparam name="arguments.thestruct.del_file_id" default="">
	<!--- Now simply add the selected fileids to the session --->
	<cfset session.file_id = session.file_id & "," & arguments.thestruct.file_id>
	<cfset session.thefileid = session.file_id>
	<cfif session.file_id NEQ "">
		<cfset list_file_ids = "">
		<cfloop index="idx" from="1" to="#listlen(session.file_id)#">
			<cfif !listFindNoCase(#arguments.thestruct.del_file_id#,#listGetAt(session.file_id,idx)#)>
				<cfset list_file_ids = listAppend(list_file_ids,#listGetAt(session.file_id,idx)#,',')>		
			</cfif>
		</cfloop>
		<cfset session.thefileid = list_file_ids>
		<cfset session.file_id = list_file_ids>
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
	WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.folder_name)#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	<cfif arguments.thestruct.folder_id_r EQ 0>
		AND folder_id_r = folder_id
	<cfelse>
		AND folder_id_r = <cfqueryparam value="#arguments.thestruct.folder_id_r#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	<cfif arguments.thestruct.folder_id NEQ 0>
		AND folder_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.thestruct.folder_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	</cfquery>
	<!--- Set to true if found --->
	<cfif qry.recordCount NEQ 0>
		<cfset var ishere = true>
	</cfif>
	<cfreturn ishere>
</cffunction>

<!--- Asset Trash Count --->
<cffunction name="trashcount" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="asset_count" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#trashcount */ COUNT(img_id) AS cnt FROM #session.hostdbprefix#images 
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	UNION ALL
	SELECT COUNT(aud_id) AS cnt  FROM #session.hostdbprefix#audios 
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	UNION ALL
	SELECT COUNT(vid_id) AS cnt FROM #session.hostdbprefix#videos 
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	UNION ALL
	SELECT COUNT(file_id) AS cnt FROM #session.hostdbprefix#files 
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush cache --->
	<cfinvoke component="extQueryCaching" method="resetcachetoken" type="images" />
	<cfinvoke component="extQueryCaching" method="resetcachetoken" type="audios" />
	<cfinvoke component="extQueryCaching" method="resetcachetoken" type="videos" />
	<cfinvoke component="extQueryCaching" method="resetcachetoken" type="files" />
	<cfset resetcachetoken("images")>
	<cfset resetcachetoken("videos")>
	<cfset resetcachetoken("files")>
	<cfset resetcachetoken("audios")>
	<cfreturn asset_count />
</cffunction>

<!--- Folder Trash Count --->
<cffunction name="folderTrashCount" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="folder_count" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#trashcount */ COUNT(folder_id) AS cnt FROM #session.hostdbprefix#folders 
	WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
	AND folder_is_collection IS NULL
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
			<cfset var thedatecreate = "img_create_date">
			<cfset var thedatechange = "img_change_date">
			<cfset var thehashtag = "hashtag">
			<cfset var thegroup = "img_group">
		<cfelseif arguments.thestruct.what EQ "videos">
			<cfset var thedb = "#session.hostdbprefix#videos">
			<cfset var theid = "vid_id">
			<cfset var thename = "vid_filename">
			<cfset var thetype = "videos">
			<cfset var thesize = "vid_size">
			<cfset var thedatecreate = "vid_create_date">
			<cfset var thedatechange = "vid_change_date">
			<cfset var thehashtag = "hashtag">
			<cfset var thegroup = "vid_group">
		<cfelseif arguments.thestruct.what EQ "audios">
			<cfset var thedb = "#session.hostdbprefix#audios">
			<cfset var theid = "aud_id">
			<cfset var thename = "aud_name">
			<cfset var thetype = "audios">
			<cfset var thesize = "aud_size"> 
			<cfset var thedatecreate = "aud_create_date">
			<cfset var thedatechange = "aud_change_date">
			<cfset var thehashtag = "hashtag">
			<cfset var thegroup = "aud_group">
		<cfelseif arguments.thestruct.what EQ "files">
			<cfset var thedb = "#session.hostdbprefix#files">
			<cfset var theid = "file_id">
			<cfset var thename = "file_name">
			<cfset var thetype = "files">
			<cfset var thesize = "file_size">
			<cfset var thedatecreate = "file_create_date">
			<cfset var thedatechange = "file_change_date">
			<cfset var thehashtag = "hashtag">
		</cfif>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
			<cfset var sortby = "lower(filename_forsort)">
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
		<!--- MySQL starts at 0 so we do -1 --->
		<cfset var detailrow = arguments.thestruct.row - 1>
		<!--- Query (if we come from the overall view we need to union all) --->
		<cfif arguments.thestruct.loaddiv EQ "content">
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- Oracle --->
			<cfif application.razuna.thedatabase EQ "oracle">
				SELECT * FROM (
					SELECT ROWNUM AS rn, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif>
			<!--- DB2 --->
			<cfif application.razuna.thedatabase EQ "db2">
				SELECT * FROM (
					SELECT row_number() over() as rownr, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif>
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				select * from (
				select ROW_NUMBER() OVER ( ORDER BY #sortby# ) AS RowNum,sorted_inline_view.* from (
			</cfif>
			SELECT /* #variables.cachetoken#getdetailnextback */
			img_id as file_id,
			img_filename as filename_forsort,
			img_size as size,
			img_create_date as date_create,
			img_change_date as date_change,
			hashtag,
			'images' as type
			FROM #session.hostdbprefix#images
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND (img_group IS NULL OR img_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">

			UNION ALL
			SELECT 
			vid_id as file_id,
			vid_filename as filename_forsort,
			vid_size as size,
			vid_create_date as date_create,
			vid_change_date as date_change,
			hashtag,
			'videos' as type
			FROM #session.hostdbprefix#videos
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND (vid_group IS NULL OR vid_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			
			UNION ALL
			SELECT 
			aud_id as file_id,
			aud_name as filename_forsort,
			aud_size as size,
			aud_create_date as date_create,
			aud_change_date as date_change,
			hashtag,
			'audios' as type
			FROM #session.hostdbprefix#audios
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND (aud_group IS NULL OR aud_group = '')
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			
			UNION ALL
			SELECT 
			file_id as file_id,
			file_name as filename_forsort,
			file_size as size,
			file_create_date as date_create,
			file_change_date as date_change,
			hashtag,
			'files' as type
			FROM #session.hostdbprefix#files
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			<!--- MySql OR H2 --->
			<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
				ORDER BY #sortby#  LIMIT #detailrow#,1
			</cfif>
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				) sorted_inline_view
				 ) resultSet
				  where RowNum = #detailrow+1#
			</cfif>
			<!--- DB2 --->
			<cfif application.razuna.thedatabase EQ "db2">
				ORDER BY #sortby#) sorted_inline_view )resultSet
				WHERE rownr = #detailrow+1#
			</cfif>
			<!--- Oracle --->
			<cfif application.razuna.thedatabase EQ "oracle">
				ORDER BY #sortby#) sorted_inline_view )resultSet
				WHERE ROWNUM = #detailrow+1#
			</cfif>
			</cfquery>
			
		<!--- We query below for within the same file type group --->
		<cfelse>
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			<!--- Oracle --->
			<cfif application.razuna.thedatabase EQ "oracle">
				SELECT * FROM (
					SELECT ROWNUM AS rn, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif>
			<!--- DB2 --->
			<cfif application.razuna.thedatabase EQ "db2">
				SELECT * FROM (
					SELECT row_number() over() as rownr, file_id, filename_forsort, size, date_create, date_change, hashtag, type
						FROM (
			</cfif>
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				SELECT * FROM (
				SELECT ROW_NUMBER() OVER ( ORDER BY #sortby# ) AS RowNum,sorted_inline_view.* FROM (
			</cfif>
			SELECT /* #variables.cachetoken#getdetailnextback */
			#theid# as file_id,
			#thename# as filename_forsort,
			#thesize# as size,
			#thedatecreate# as date_create,
			#thedatechange# as date_change,
			#thehashtag#,
			'#thetype#' as type
			FROM #thedb#
			WHERE folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_id#">
			<cfif Len(arguments.thestruct.loaddiv) AND arguments.thestruct.what EQ "files">
				AND
				<!--- if doc or xls also add office 2007 format to query --->
				<cfif arguments.thestruct.loaddiv EQ "doc" OR arguments.thestruct.loaddiv EQ "xls">
					(
					LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(arguments.thestruct.loaddiv)#">
					OR LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(arguments.thestruct.loaddiv)#x">
					)
				<!--- query all formats if not other --->
				<cfelseif arguments.thestruct.loaddiv neq "other">
					LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(arguments.thestruct.loaddiv)#">
				<!--- query all files except the ones in the list --->
				<cfelse>
					(
					LOWER(<cfif variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull<cfelseif variables.database EQ "mssql">isnull</cfif>(file_extension, '')) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="doc,xls,docx,xlsx,pdf" list="true">)
					OR (file_extension IS NULL OR file_extension = '')
					)
				</cfif>
			</cfif>
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			<cfif arguments.thestruct.what NEQ "files">
				AND (#thegroup# IS NULL OR #thegroup# = '')
			</cfif>
			AND in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="F">
			<!--- MySql --->
			<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
				ORDER BY #sortby# LIMIT #detailrow#,1
			</cfif>
			<!--- MSSQL --->
			<cfif application.razuna.thedatabase EQ "mssql">
				) sorted_inline_view
				 ) resultSet
				  where RowNum = #detailrow+1#
			</cfif>
			<!--- DB2 --->
			<cfif application.razuna.thedatabase EQ "db2">
				ORDER BY #sortby#) sorted_inline_view )resultSet
				WHERE rownr = #detailrow+1#
			</cfif>
			<!--- Oracle --->
			<cfif application.razuna.thedatabase EQ "oracle">
				ORDER BY #sortby#) sorted_inline_view )resultSet
				WHERE ROWNUM = #detailrow+1#
			</cfif>
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

</cfcomponent>
