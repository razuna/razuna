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
<cfcomponent hint="CFC for Groups" output="false">

<!--- ----------------------------------------------- --->
<!--- Init --->
<!--- Added this during FuseBox integration of DSC --->
<!--- Name: nitai, Date: 12/27/2007 --->
<!--- ----------------------------------------------- --->
<cffunction name="init" returntype="groups" access="public" output="false">
	<cfargument name="dsn" type="string" required="yes" />
	<cfargument name="database" type="string" required="yes" />
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.database = arguments.database />
	<cfreturn this />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get one detailled record --->
<cffunction hint="Get one record" name="getdetail" returntype="query">
	<cfargument name="grp_name" type="string" required="false">
	<cfargument name="grp_id" type="string" required="false">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#application.razuna.datasource#" name="localquery">
	SELECT grp_id, grp_name, grp_host_id, grp_mod_id, grp_translation_key,
		(
			SELECT count(*)
			FROM ct_groups_users gu, users u, ct_users_hosts uh
			WHERE gu.ct_g_u_grp_id = groups.grp_id
			AND gu.ct_g_u_user_id = u.user_id
			AND uh.ct_u_h_user_id = u.user_id
			AND uh.ct_u_h_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
		) AS usercount
	FROM groups
	WHERE (
		grp_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
		OR grp_host_id IS NULL
		)
	<cfif StructKeyExists(Arguments, "grp_id")>
		AND grp_id = <cfqueryparam value="#arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfif>
	<cfif StructKeyExists(Arguments, "grp_name")>
		AND lower(grp_name) = <cfqueryparam value="#lcase(arguments.grp_name)#" cfsqltype="cf_sql_varchar">
	</cfif>
	</cfquery>
	<cfreturn localquery>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get one detailled record --->
<cffunction hint="Get one record" name="getdetailedit" returntype="query">
	<cfargument name="thestruct" type="Struct">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#variables.dsn#" name="localquery">
	SELECT grp_name, upc_size, upc_folder_format, folder_subscribe, folder_redirect
	FROM groups
	WHERE grp_id = <cfqueryparam value="#arguments.thestruct.grp_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfreturn localquery>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get all the records --->
<cffunction hint="Get all records" name="getall" returntype="query">
	<cfargument name="thestruct" type="Struct" required="false">
	<cfargument name="host_id" default="#session.hostid#" type="numeric" required="false">
	<cfargument name="mod_id" type="numeric" required="false">
	<cfargument name="mod_short" type="string" required="false" hint="modules.mod_short">
	<cfargument name="orderBy" type="string" required="false" default="grp_mod_id, grp_name" hint="""ORDER BY #yourtext#""">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#application.razuna.datasource#" name="localquery">
	SELECT grp_id, grp_name, grp_host_id, grp_mod_id, grp_translation_key,
		(
			SELECT count(*)
			FROM ct_groups_users
			WHERE ct_g_u_grp_id = groups.grp_id
		) AS usercount
	FROM groups
	WHERE (
		grp_host_id = <cfqueryparam value="#arguments.host_id#" cfsqltype="cf_sql_numeric">
		OR grp_host_id IS NULL
		)
	<cfif StructKeyExists(Arguments, "mod_id")>
		AND grp_mod_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#Arguments.mod_id#">
	</cfif>
	<cfif StructKeyExists(Arguments, "mod_short")>
		AND
		EXISTS(
			SELECT mod_id, mod_name, mod_short, mod_host_id
			FROM modules
			WHERE modules.mod_short = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mod_short#">
			AND modules.mod_id = groups.grp_mod_id
		)
	</cfif>
	ORDER BY <!--- <cfif variables.database EQ "oracle" OR variables.database EQ "h2">NVL<cfelseif variables.database EQ "mysql">ifnull</cfif>(grp_host_id, 0),  --->#arguments.orderBy#
	</cfquery>
	<cfreturn localquery>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Insert new record --->
<cffunction hint="Insert one record" name="insertRecord" returntype="string">
	<cfargument name="thestruct" type="Struct">
	<!--- get next id --->
	<cfset var newgrpid = createuuid()>
	<cfquery datasource="#variables.dsn#">
	INSERT INTO	groups
	(grp_id, grp_name, grp_host_id, grp_mod_id, upc_size, upc_folder_format, folder_subscribe)
	VALUES(
	<cfqueryparam value="#newgrpid#" cfsqltype="CF_SQL_VARCHAR">,
	<cfqueryparam value="#arguments.thestruct.newgrp#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
	<cfqueryparam value="#arguments.thestruct.modules_dam_id#" cfsqltype="cf_sql_numeric">,
	<cfqueryparam value="#arguments.thestruct.sizeofupc#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam value="#arguments.thestruct.upc_folder_structure#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam value="#arguments.thestruct.folder_subscribe#" cfsqltype="cf_sql_varchar">
	)
	</cfquery>
	<cfreturn newgrpid>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Update one record --->
<cffunction hint="Update one record" name="update" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#variables.dsn#" name="getfolder_subscribe_bef_change">
		SELECT folder_subscribe FROM groups WHERE  grp_id = <cfqueryparam value="#arguments.thestruct.grp_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfquery datasource="#variables.dsn#">
		UPDATE groups
		SET	grp_name = <cfqueryparam value="#arguments.thestruct.grpname#" cfsqltype="cf_sql_varchar">
			,folder_subscribe = <cfqueryparam value="#arguments.thestruct.folder_subscribe#" cfsqltype="cf_sql_varchar">
			,folder_redirect = <cfif trim(arguments.thestruct.folder_redirect) EQ "">null<cfelse><cfqueryparam value="#arguments.thestruct.folder_redirect#" cfsqltype="cf_sql_varchar"></cfif>
		<cfif structKeyExists(arguments.thestruct,'sizeofupc') AND arguments.thestruct.sizeofupc NEQ 0>
			,upc_size = <cfqueryparam value="#arguments.thestruct.sizeofupc#" cfsqltype="CF_SQL_VARCHAR">
			,upc_folder_format = <cfqueryparam value="#arguments.thestruct.upc_folder_structure#" cfsqltype="cf_sql_varchar">
		</cfif>
		WHERE grp_id = <cfqueryparam value="#arguments.thestruct.grp_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- If folder subscribe setting for group is being changed to true then add all users in the group to get folder notifications --->
	<cfif arguments.thestruct.folder_subscribe EQ 'true' AND getfolder_subscribe_bef_change.folder_subscribe EQ 'false'>
		<cfinvoke method="add_grp_users2notify" group_id='#arguments.thestruct.grp_id#'>
	</cfif>
	<cfreturn />
</cffunction>
<!--- ------------------------------------------------------------------------------------- --->
<cffunction hint="Add users of a group to receive folder notifications" name="add_grp_users2notify" returntype="void">
	<cfargument name="group_id" type="string" required="true">
	<cfargument name="user_id" type="string" required="false" hint="optional userid to pass in">
	<cfset var getusers_fs = "">
	<cfset var getgroups_fs = "">
	<!--- Check if folder_subscribe for group is set to true --->
	<cfquery datasource="#application.razuna.datasource#" name="checkgrpsettings">
		SELECT folder_subscribe FROM groups WHERE  grp_id = <cfqueryparam value="#arguments.group_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- If folder_subscribe is set to true for group then add all users in group to receive folder notifications --->
	<cfif checkgrpsettings.folder_subscribe EQ 'true'>
		<cfquery datasource="#application.razuna.datasource#" name="getusers_fs">
			SELECT fg.folder_id_r, cu.ct_g_u_user_id user_id 
			FROM ct_groups_users cu, #session.hostdbprefix#folders_groups fg, #session.hostdbprefix#folders f
			WHERE cu.ct_g_u_grp_id = fg.grp_id_r
			AND f.folder_id = fg.folder_id_r
			AND cu.ct_g_u_grp_id = <cfqueryparam value="#arguments.group_id#" cfsqltype="CF_SQL_VARCHAR">
			AND fg.grp_id_r <>'0'
			AND (f.folder_is_collection <>'T' OR f.folder_is_collection is null OR f.folder_is_collection ='')
			AND f.in_trash ='F'
			AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#folder_subscribe fs WHERE fs.folder_id = fg.folder_id_r AND fs.user_id = cu.ct_g_u_user_id)
			<cfif isDefined("arguments.user_id")>
				AND cu.ct_g_u_user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			GROUP BY fg.folder_id_r, cu.ct_g_u_user_id 
		</cfquery>
		<cfloop query = "getusers_fs">
			<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#folder_subscribe
				(fs_id, host_id, folder_id, user_id, mail_interval_in_hours, last_mail_notification_time, asset_keywords, asset_description, auto_entry)
				VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getusers_fs.folder_id_r#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getusers_fs.user_id#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="1">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="F">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="F">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="true">
				)
			</cfquery>
		</cfloop>
		<!--- Add entries for group in folder_subscribe_groups table --->
		<cfquery datasource="#application.razuna.datasource#" name="getgroups_fs">
			SELECT fs.folder_id folder_id,  cu.ct_g_u_grp_id group_id
			FROM ct_groups_users cu, #session.hostdbprefix#folder_subscribe fs,#session.hostdbprefix#folders_groups fg
			WHERE cu.ct_g_u_user_id = fs.user_id
			AND cu.ct_g_u_grp_id = fg.grp_id_r
			AND cu.ct_g_u_grp_id = <cfqueryparam value="#arguments.group_id#" cfsqltype="CF_SQL_VARCHAR">
			AND fg.folder_id_r = fs.folder_id
			AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#folder_subscribe_groups fsg WHERE fsg.folder_id = fs.folder_id AND fsg.group_id= fg.grp_id_r)
			GROUP BY fs.folder_id,  cu.ct_g_u_grp_id
		</cfquery>
		<cfloop query="getgroups_fs">
			<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#folder_subscribe_groups (folder_id, group_id)
				VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#getgroups_fs.folder_id#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group_id#">
				)
			</cfquery>
		</cfloop>
	</cfif>
</cffunction>
<!--- ------------------------------------------------------------------------------------- --->
<cffunction hint="Remove users of a group from receiving folder notifications" name="notifications_unsubscribe" returntype="void">
	<cfargument name="group_id" type="string" required="true">
	<cfset var get_unsubscribe_items = "">
	<cfset var get_letover_items = "">
	<cfquery datasource="#application.razuna.datasource#" name="get_unsubscribe_items">
		SELECT fs.fs_id
		FROM ct_groups_users cu, #session.hostdbprefix#folder_subscribe fs
		WHERE fs.user_id = cu.ct_g_u_user_id
		AND cu.ct_g_u_grp_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group_id#">
		<!--- Exclude users that are subscribed to that folder via another group --->
		AND NOT EXISTS (SELECT 1 FROM raz1_folder_subscribe_groups gs WHERE gs.folder_id = fs.folder_id AND gs.group_id <> cu.ct_g_u_grp_id)
		<!--- Only get users that were subscribed automatically to folder notifications --->
		AND fs.auto_entry='true'
	</cfquery>
	<!--- Remove users from notifications --->
	<cfloop query = "get_unsubscribe_items">
		<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#folder_subscribe WHERE fs_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_unsubscribe_items.fs_id#">
		</cfquery>
	</cfloop>
	<!--- Remove group subscription --->
	<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#folder_subscribe_groups WHERE group_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.group_id#">
	</cfquery>

	<!--- Delete left over users that are no longer subscribed to any groups--->
	<cfquery datasource="#application.razuna.datasource#" name="get_leftover_items">
		SELECT fs.fs_id
		FROM #session.hostdbprefix#folder_subscribe fs
		WHERE NOT EXISTS (SELECT 1 FROM raz1_folder_subscribe_groups gs WHERE gs.folder_id = fs.folder_id)
		AND fs.auto_entry='true'
	</cfquery>
	<cfloop query = "get_leftover_items">
		<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#folder_subscribe WHERE fs_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#get_leftover_items.fs_id#">
		</cfquery>
	</cfloop>
</cffunction>
<!--- ------------------------------------------------------------------------------------- --->
<!--- Delete one record --->
<cffunction hint="Delete one record" name="remove" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<!--- Remove the group --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM	groups
	WHERE grp_id = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<!--- Remove within the folder groups db --->
	<cfquery datasource="#variables.dsn#">
	DELETE FROM	#session.hostdbprefix#folders_groups
	WHERE grp_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn />
</cffunction>

</cfcomponent>