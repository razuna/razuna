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
<cfcomponent  output="false">

<!--- FUNCTION: INIT --->
<cffunction name="init" returntype="security" access="public" output="false">
	<cfreturn this />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!---
INIT-CONSTRUCTOR:
Make this cfc persisntent to request/session-scope for better performance.
The permissions and the users access to them must not be requested again every time.
--->
<cffunction name="initUser" returntype="security" access="public" output="false" >
	<cfargument name="host_id" type="numeric" required="yes">
	<cfargument name="user_id" type="string" required="yes">
	<cfargument name="mod_short" type="string" required="false" >
	<!--- component-variables --->
	<cfinvoke method="getPermissionsStruct" host_id="#Arguments.host_id#" user_id="#Arguments.user_id#" returnvariable="Variables.permissions">
		<cfif StructKeyExists(Arguments, "mod_short")>
			<cfinvokeargument name="mod_short" value="#Arguments.mod_short#">
		</cfif>
	</cfinvoke>
	<cfif StructKeyExists(Arguments, "mod_short")>
		<cfset Variables.mod_short = Arguments.mod_short>
	</cfif>
	<!--- store SystemAdmin-info of user --->
	<cfinvoke method="getIsAdminGroupMember" host_id="#Arguments.host_id#" user_id="#Arguments.user_id#" grp_name="SystemAdmin" returnvariable="Variables.isSystemAdmin" />
	<!--- store Administrator-info of user --->
	<cfinvoke method="getIsAdminGroupMember" host_id="#Arguments.host_id#" user_id="#Arguments.user_id#" grp_name="Administrator" returnvariable="Variables.isAdministrator" />
	<!--- store all SystemAdmin-groups --->
	<cfinvoke method="getSystemGroups" grp_name="SystemAdmin" returnvariable="Variables.listSystemAdmin" />
	<!--- store all Administrator-groups --->
	<cfinvoke method="getSystemGroups" grp_name="Administrator" returnvariable="Variables.listAdministrator" />
	<cfreturn this>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Check if an permission-key is permitted to the current user. --->
<cffunction name="CheckPermission" returntype="boolean"
						access="public" output="false"
						>
	<cfargument name="key" type="string" required="true" >
	<cfargument name="mod_short" type="string" required="false" default="#Variables.mod_short#"
							>
	<!--- function internal vars --->
	<!--- function body --->
	<!--- is the action(/subaction) un-protected? or does the use have permission? --->
	<cfif not StructKeyExists(Variables.permissions[Arguments.mod_short], Arguments.key)
				or
				Variables.permissions[Arguments.mod_short][Arguments.key]>
		<cfreturn true>
	</cfif>
	<cfreturn false>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Check if user is member of SystemAdmin-group --->
<cffunction name="CheckSystemAdminUser" returntype="boolean" access="public" output="false" >
	<!--- function internal vars --->
	<!--- function body --->
	<cfreturn Variables.isSystemAdmin>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Check if user is member of Administrator-group --->
<cffunction name="CheckAdministratorUser" returntype="boolean"
						access="public" output="false"
						>
	<!--- function internal vars --->
	<!--- function body --->
	<cfreturn Variables.isAdministrator>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Check if user is member of SystemAdmin-group --->
<cffunction name="CheckSystemAdminGroup" returntype="boolean" access="public" output="false" >
	<cfargument name="grp_id" type="string" required="true" >
	<!--- function internal vars --->
	<!--- function body --->
	<cfreturn YesNoFormat(ListFind(Variables.listSystemAdmin, Arguments.grp_id))>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Check if user is member of Administrator-group --->
<cffunction name="CheckAdministratorGroup" returntype="boolean"
						access="public" output="false"
						>
	<cfargument name="grp_id" type="string" required="true" >
	<!--- function internal vars --->
	<!--- function body --->
	<cfreturn YesNoFormat(ListFind(Variables.listAdministrator, Arguments.grp_id))>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get protected keys in a struct --->
<cffunction name="getPermissionsStruct" returntype="struct" access="private" output="false" >
	<cfargument name="host_id" type="numeric" required="yes">
	<cfargument  name="user_id" type="string" required="true" >
	<cfargument name="mod_short" type="string" required="false">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfset var returnstruct = StructNew()>
	<!--- function body --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
	SELECT m.mod_short, p.per_key,
		CASE
			WHEN EXISTS(
				SELECT ct.ct_g_p_per_id
				FROM ct_groups_permissions ct
				INNER JOIN groups g ON ct.ct_g_p_grp_id = g.grp_id
				INNER JOIN ct_groups_users ctg ON ctg.ct_g_u_grp_id = g.grp_id
				WHERE (
				g.grp_host_id = <cfqueryparam value="#Arguments.host_id#" cfsqltype="cf_sql_numeric">
				OR g.grp_host_id IS NULL
				)
				AND	ct.ct_g_p_per_id = p.per_id
				AND	ctg.ct_g_u_user_id = <cfqueryparam value="#Arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
				)
			THEN 1
			ELSE 0
		END as permitted
	FROM modules m
	LEFT JOIN permissions p ON p.per_mod_id = m.mod_id 
	WHERE (
		m.mod_host_id = <cfqueryparam value="#Arguments.host_id#" cfsqltype="cf_sql_numeric">
		OR (m.mod_host_id IS NULL)
		)
	<cfif StructKeyExists(Arguments, "mod_short")>
		AND m.mod_short = <cfqueryparam value="#Arguments.mod_short#" cfsqltype="cf_sql_varchar">
	</cfif>
	AND (
		p.per_host_id = <cfqueryparam value="#Arguments.host_id#" cfsqltype="cf_sql_numeric">
		OR (p.per_host_id IS NULL)
		)
	AND p.per_active = 1
	ORDER BY m.mod_short, p.per_key
	</cfquery>
	<cfoutput query="localquery" group="mod_short">
		<cfset StructInsert(returnstruct, localquery.mod_short, StructNew())>
		<cfoutput>
			<cfset StructInsert(returnstruct[localquery.mod_short], localquery.per_key, localquery.permitted)>
		</cfoutput>
	</cfoutput>
	<cfreturn returnstruct>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- query if user is member of SystemAdmin-group --->
<cffunction name="getIsAdminGroupMember" returntype="boolean" access="private" output="false" >
	<cfargument name="host_id" type="numeric" required="yes">
	<cfargument name="user_id" type="string" required="true" >
	<cfargument name="grp_name" type="string" required="yes">
	<!--- <cfdump var="#arguments#">
	<cfabort> --->
	<cfset var localquery = 0>
	<!--- function body --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
		SELECT CASE
					WHEN EXISTS(
						SELECT groups.grp_id
						FROM groups
						INNER JOIN
						ct_groups_users
						ON	ct_groups_users.ct_g_u_grp_id = groups.grp_id
						INNER JOIN
						modules
						ON	modules.mod_id = groups.grp_mod_id
						WHERE groups.grp_name = <cfqueryparam value="#Arguments.grp_name#" cfsqltype="cf_sql_varchar">
						AND modules.mod_short = 'adm'
						AND	ct_groups_users.ct_g_u_user_id = <cfqueryparam value="#Arguments.user_id#" cfsqltype="CF_SQL_VARCHAR">
					) THEN 1
					ELSE 0
				END AS isSystemAdmin
		<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">
			FROM sysibm.sysdummy1
		<cfelseif arguments.thestruct.razuna.application.thedatabase NEQ "mssql">
			FROM dual
		</cfif>
	</cfquery>
	<!--- <cfdump var="#localquery#">
	<cfabort> --->
	<cfreturn Val(localquery.isSystemAdmin)>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- query all SystemAdmin/Administrator-groups --->
<cffunction name="getSystemGroups" returntype="string"
						access="private" output="false"
						>
	<cfargument name="grp_name" type="string" required="yes">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<!--- function body --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
		SELECT grp_id
		FROM groups
		WHERE grp_host_id IS NULL
		AND	grp_name = <cfqueryparam value="#Arguments.grp_name#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn ValueList(localquery.grp_id)>
</cffunction>

<cffunction name="isuser" returntype="boolean" output="false" >
	<cfargument name="user_id" type="string" required="yes">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<!--- function body --->
	<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="localquery">
		SELECT 1
		FROM users
		WHERE user_id = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfif localquery.recordcount neq 0>
		<cfset var userexists = true>
	<cfelse>
		<cfset var userexists = false>
	</cfif>
	<cfreturn userexists>
</cffunction>

<cffunction name="encrypt" returntype="String" >
		<cfargument name="str2encrypt" required="true">
		<cfargument name="key" required="true">
		<cfreturn encrypt(arguments.str2encrypt,arguments.key)>
	</cffunction>

<cffunction name="decrypt" returntype="String" >
	<cfargument name="str2decrypt" required="true">
	<cfargument name="key" required="true">
	<cftry>
		<cfset var decstr = decrypt(arguments.str2decrypt,arguments.key)>
		<cfcatch><cfset var decstr = "false"></cfcatch>
	</cftry>
	<cfreturn decstr>
</cffunction>

</cfcomponent>