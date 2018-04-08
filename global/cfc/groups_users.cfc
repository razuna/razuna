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
<cfcomponent  extends="extQueryCaching">

<cffunction name="init" returntype="groups_users" access="public" output="false">
	<cfreturn this />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- get groups of a user --->
<cffunction name="getGroupsOfUser" returntype="query" >
	<cfargument name="user_id" type="string" required="true">
	<cfargument name="mod_id" type="numeric" required="False" >
	<cfargument name="mod_short" type="string" required="False" >
	<cfargument name="host_id" type="numeric" required="false" default="0">
	<cfargument name="check_upc_size" type="string" required="false" default="false">
	<cfargument name="orderBy" type="string" required="false" default="groups.grp_mod_id, groups.grp_name, groups.grp_id" "ORDER BY #yourtext#""">
	<cfargument name="nosessionoverwrite" type="string" required="false" default="false" >
	<cfargument name="thestruct" type="struct" required="true" />
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
	SELECT groups.grp_id, groups.grp_name, groups.grp_host_id, groups.grp_mod_id, groups.grp_translation_key, groups.upc_size, groups.upc_folder_format
	FROM groups
	WHERE (
		groups.grp_host_id = <cfqueryparam value="#Arguments.host_id#" cfsqltype="cf_sql_numeric">
		OR groups.grp_host_id IS NULL
	)
	AND EXISTS(
		SELECT ct_groups_users.ct_g_u_grp_id, ct_groups_users.ct_g_u_user_id
		FROM ct_groups_users
		WHERE ct_groups_users.ct_g_u_grp_id = groups.grp_id
		AND ct_groups_users.ct_g_u_user_id = <cfqueryparam value="#Arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
	)
	<cfif StructKeyExists(Arguments, "mod_id")>
		AND	groups.grp_mod_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#Arguments.mod_id#">
	</cfif>
	<cfif StructKeyExists(Arguments, "mod_short")>
		AND EXISTS (
			SELECT mod_id, mod_name, mod_short, mod_host_id
			FROM modules
			WHERE modules.mod_id = groups.grp_mod_id AND modules.mod_short = <cfqueryparam value="#Arguments.mod_short#" cfsqltype="cf_sql_varchar">
		)
	</cfif>
	<cfif StructKeyExists(arguments, "check_upc_size") AND arguments.check_upc_size EQ 'true'>
		AND ( 
			upc_size <cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql"><><cfelse>!=</cfif> '' 
			OR upc_size is not null
		)
	</cfif>
	ORDER BY <cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle" OR arguments.thestruct.razuna.application.thedatabase EQ "h2" OR arguments.thestruct.razuna.application.thedatabase EQ "db2">NVL<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql">ifnull<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mssql">isnull</cfif>(groups.grp_host_id, 0), #Arguments.orderBy#
	</cfquery>
	<cfif arguments.check_upc_size NEQ 'true' AND arguments.nosessionoverwrite EQ 'false'>
		<!--- Put result into session --->
		<cfset arguments.thestruct.razuna.session.thegroupofuser = valuelist(localquery.grp_id)>
		<!--- If session is empty then fill it with 0 --->
		<cfif arguments.thestruct.razuna.session.thegroupofuser EQ "">
			<cfset arguments.thestruct.razuna.session.thegroupofuser = 0>
		</cfif>	
	</cfif>
	<!--- Return --->
	<cfreturn localquery />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- add user to groups --->
<cffunction name="addtogroups" output="true">
	<cfargument name="thestruct" type="Struct">
	<cfparam name="arguments.thestruct.grp_id_assigneds_ecp" type="string" default="">
	<cfparam name="arguments.thestruct.grp_id_assigneds_adm" type="string" default="">
	<cfinvoke method="deleteUser" thestruct="#arguments.thestruct#">
	<!--- Insert user to the group cross table --->
	<cfloop delimiters="," index="myform" list="#arguments.thestruct.fieldnames#">
		<cfif Left(myform, Len("webgroup_")) eq "webgroup_">
			<cfset arguments.thestruct.grp_id_assigneds_ecp = ListAppend(arguments.thestruct.grp_id_assigneds_ecp, Right(myForm, Len(myForm) - Len("webgroup_")))>
		</cfif>
	</cfloop>
	<!--- If we find group 1 or 2 in the list then reset the list to the found groupid --->
	<cfif StructKeyExists(arguments.thestruct,"admin_group_1")>
		<cfset arguments.thestruct.grp_id_assigneds_adm = 1>
		<cfset arguments.thestruct.grp_id_assigneds_ecp = "">
	<cfelseif StructKeyExists(arguments.thestruct,"admin_group_2")>
		<cfset arguments.thestruct.grp_id_assigneds_adm = 2>
		<cfset arguments.thestruct.grp_id_assigneds_ecp = "">
	</cfif>
	<!--- If there is no web group then dont go further --->
	<cfif arguments.thestruct.grp_id_assigneds_ecp NEQ "">
		<cfset arguments.thestruct.grp_id_assigneds = arguments.thestruct.grp_id_assigneds_ecp>
		<cfinvoke method="resetUser" thestruct="#arguments.thestruct#">
	</cfif>
	<!--- Insert the selected group to the admin group cross table --->
	<!--- <cfloop delimiters="," index="myform" list="#arguments.thestruct.fieldnames#">
		<cfif Left(myform, Len("admin_group_")) eq "admin_group_">
			<cfset arguments.thestruct.grp_id_assigneds_adm = ListAppend(arguments.thestruct.grp_id_assigneds_adm, Right(myForm, Len(myForm) - Len("admin_group_")))>
		</cfif>
	</cfloop> --->
	<!--- If there is no admin group then dont go further --->
	<cfif arguments.thestruct.grp_id_assigneds_adm NEQ "">
		<cfset arguments.thestruct.grp_id_assigneds = arguments.thestruct.grp_id_assigneds_adm>
		<cfinvoke method="resetUser" thestruct="#arguments.thestruct#">
	</cfif>
	<!--- Flush Cache --->
	<cfset resetcachetoken(type="search", nohost="true", thestruct=arguments.thestruct)>
	<cfset resetcachetoken(type="folders", nohost="true", thestruct=arguments.thestruct)>
	<cfset resetcachetoken(type="users", nohost="true", thestruct=arguments.thestruct)>
</cffunction>


!--- ------------------------------------------------------------------------------------- --->
<!--- Reset records of a user --->
<cffunction  name="resetUser" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<!--- function internal vars --->
	<cfset var grp_id = 0>
	<!--- reinsert new permissions --->
	<cfif Len(arguments.thestruct.grp_id_assigneds)>
		<cfinvoke method="insertBulk" thestruct="#arguments.thestruct#">
	</cfif>
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Delete records of a user --->
<cffunction  name="deleteUser" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<!--- Delete --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
	DELETE FROM	ct_groups_users
	WHERE ct_g_u_user_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
	<!--- correct host --->
	AND
	EXISTS(
		SELECT g.grp_id
		FROM groups g
		WHERE g.grp_id = ct_groups_users.ct_g_u_grp_id
		AND(
			g.grp_host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric">
			OR g.grp_host_id IS NULL
			)
		<cfif StructKeyExists(arguments.thestruct, "module_id_struct")>
			<!--- OpenBD Fix throws an error when using the struct as type numeric. With a var it works --->
			<cfset ecp=arguments.thestruct.module_id_struct.ecp>
			<cfset adm=arguments.thestruct.module_id_struct.adm>
			AND 
			(g.grp_mod_id = <cfqueryparam value="#ecp#" cfsqltype="cf_sql_numeric">
			OR g.grp_mod_id = <cfqueryparam value="#adm#" cfsqltype="cf_sql_numeric">)
		</cfif>
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken(type="users", nohost="true", thestruct=arguments.thestruct)>
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Insert bulk records --->
<cffunction  name="insertBulk" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<!--- insert --->
	<cfloop list="#arguments.thestruct.grp_id_assigneds#" delimiters="," index="i">
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		INSERT INTO	ct_groups_users
		(ct_g_u_grp_id, ct_g_u_user_id, rec_uuid)
		VALUES(
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
		)
		</cfquery>
		<!--- Check group 'folder_subscribe' setting and add this user to receive folder notifications if set to true --->
		<cfinvoke component="global.cfc.groups" method="add_grp_users2notify" group_id='#i#' user_id='#arguments.thestruct.newid#' thestruct="#arguments.thestruct#">
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken(type="users", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
	<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- get users of one or more groups by group-name --->
<!--- This is called while creating a new host --->
<cffunction name="searchUsersOfGroups" returntype="query" access="remote" >
	<cfargument name="func_dsn" type="string" required="false">
	<cfargument name="list_grp_id" type="string" required="false">
	<cfargument name="list_grp_name" type="string" required="false">
	<cfargument name="list_delim" type="string" required="false" default=",">
	<cfargument name="host_id" type="numeric" required="false" default="">
	<cfargument name="mod_id" type="numeric" required="false" >
	<cfargument name="orderBy" type="string" required="false" default="u.user_first_name, u.user_last_name, u.user_email, u.user_active, u.user_id" "ORDER BY #yourtext#""">
	<cfargument name="thestruct" type="struct" required="true" />
	<!--- Since this is also called from external we need to set some vars here --->
	<cfif structkeyexists(arguments.thestruct.razuna.session,"hostid") AND arguments.host_id EQ "">
		<cfset arguments.host_id = arguments.thestruct.razuna.session.hostid>
	</cfif>
	<cfif arguments.host_id EQ "">
		<cfset arguments.host_id = 0>
	</cfif>
	<cfif arguments.func_dsn NEQ "">
		<cfset arguments.thestruct.razuna.application.datasource = arguments.func_dsn>
	</cfif>
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
	SELECT u.*
	FROM users u
	WHERE EXISTS (
		SELECT ct.ct_g_u_user_id
		FROM ct_groups_users ct INNER JOIN groups g ON ct.ct_g_u_grp_id = g.grp_id
		WHERE g.grp_host_id = <cfqueryparam value="#arguments.host_id#" cfsqltype="cf_sql_numeric"> OR g.grp_host_id IS NULL
		<cfif StructKeyExists(Arguments, "mod_id")>
			AND g.grp_mod_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#Arguments.mod_id#">
		</cfif>
		<cfif StructKeyExists(Arguments, "list_grp_id")>
			AND g.grp_id IN (<cfqueryparam value="#Arguments.list_grp_id#" cfsqltype="CF_SQL_VARCHAR" list="true" separator="#Arguments.list_delim#">)
		</cfif>
		<cfif StructKeyExists(Arguments, "list_grp_name")>
			AND g.grp_name IN (<cfqueryparam value="#Arguments.list_grp_name#" cfsqltype="cf_sql_varchar" list="true" separator="#Arguments.list_delim#">)
		</cfif>
		AND ct.ct_g_u_user_id = u.user_id
	)
	ORDER BY #Arguments.orderBy#
	</cfquery>
	<cfreturn localquery />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- get users of a group --->
<cffunction name="getUsersOfGroup" returntype="query">
	<cfargument name="grp_id" type="string" required="true">
	<cfargument name="thestruct" type="struct" required="true" />
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
	SELECT u.user_id, u.user_first_name, u.user_last_name, u.user_email
	FROM users u, ct_users_hosts ct
	WHERE EXISTS(
		SELECT ct_groups_users.ct_g_u_user_id
		FROM ct_groups_users INNER JOIN groups ON ct_groups_users.ct_g_u_grp_id = groups.grp_id
		WHERE(
			groups.grp_host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric">
			OR groups.grp_host_id IS NULL
		)
		AND groups.grp_id = <cfqueryparam value="#Arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR">
		AND ct_groups_users.ct_g_u_user_id = u.user_id
	)
	AND ct.ct_u_h_host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric">
	AND u.user_id = ct.ct_u_h_user_id
	</cfquery>
	<cfreturn localquery />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- get users of a group --->
<cffunction name="getUsersOfGroups" returntype="query">
	<cfargument name="grp_id" type="string" required="true">
	<cfargument name="thestruct" type="struct" required="true" />
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
	SELECT u.user_id, u.user_first_name, u.user_last_name, u.user_email
	FROM users u, ct_users_hosts ct
	WHERE EXISTS(
		SELECT ct_groups_users.ct_g_u_user_id
		FROM ct_groups_users INNER JOIN groups ON ct_groups_users.ct_g_u_grp_id = groups.grp_id
		WHERE(
			groups.grp_host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric">
			OR groups.grp_host_id IS NULL
		)
		AND groups.grp_id IN (<cfqueryparam value="#Arguments.grp_id#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		AND ct_groups_users.ct_g_u_user_id = u.user_id
	)
	AND ct.ct_u_h_host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric">
	AND u.user_id = ct.ct_u_h_user_id
	</cfquery>
	<cfreturn localquery />
</cffunction>


<!--- get all admins or sysadmin of this host --->
<cffunction name="getadmins">
	<cfargument name="thestruct" type="struct" required="true" />
	<cfset var qry = "">
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
	SELECT u.user_email
	FROM users u, ct_groups_users ctg, ct_users_hosts cth
	WHERE ctg.CT_G_U_GRP_ID IN (<cfqueryparam value="1,2" cfsqltype="CF_SQL_VARCHAR" list="true" separator=",">)
	AND u.user_id = ctg.CT_G_U_USER_ID
	AND ctg.CT_G_U_USER_ID = cth.CT_U_H_USER_ID
	AND cth.CT_U_H_HOST_ID = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric">
	GROUP BY u.user_email
	</cfquery>
	<cfreturn qry />
</cffunction>

<!--- remove user from group --->
<cffunction name="removeuserfromgroup" returntype="void">
	<cfargument name="grp_id" type="string" required="true">
	<cfargument name="user_id" type="string" required="true">
	<cfargument name="thestruct" type="struct" required="true" />
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
	DELETE FROM ct_groups_users
	WHERE ct_g_u_grp_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.grp_id#">
	AND ct_g_u_user_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.user_id#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken(type="users", nohost="true", thestruct=arguments.thestruct)>
	<cfreturn />
</cffunction>

<!--- add user to group --->
<cffunction name="addusertogroup" returntype="void">
	<cfargument name="grp_id" type="string" required="true">
	<cfargument name="user_id" type="string" required="true">
	<cfargument name="thestruct" type="struct" required="true" />
	<!--- If the user is being added to the administrator group we remove all other groups first --->
	<cfif arguments.grp_id EQ 2>
		<cfset arguments.newid = arguments.user_id>
		<cfinvoke method="deleteUser" thestruct="#arguments#" />
	</cfif>
	<!--- Insert users --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
	INSERT INTO ct_groups_users
	(ct_g_u_grp_id, ct_g_u_user_id, rec_uuid)
	VALUES(
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.grp_id#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.user_id#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
	)
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken(type="users", nohost="true", thestruct=arguments.thestruct)>
	<cfreturn />
</cffunction>

<!--- Get re-direct folders for user --->
<cffunction name="getredirectfolders" returntype="string">
	<cfargument name="thestruct" type="struct" required="true" />
	<cfset var redirectfolders = "">
	<cfset var getfolders = "">
	<!--- Insert users --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="getfolders">
		SELECT folder_redirect FROM groups WHERE grp_id in (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.razuna.session.thegroupofuser#" list="true">)
	</cfquery>
	<cfset redirectfolders = valuelist(getfolders.folder_redirect)>
	<cfreturn redirectfolders/>
</cffunction>

</cfcomponent>
