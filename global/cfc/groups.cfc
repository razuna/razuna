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
	SELECT grp_name
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
	(grp_id, grp_name, grp_host_id, grp_mod_id)
	VALUES(
	<cfqueryparam value="#newgrpid#" cfsqltype="CF_SQL_VARCHAR">,
	<cfqueryparam value="#arguments.thestruct.newgrp#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
	<cfqueryparam value="#arguments.thestruct.modules_dam_id#" cfsqltype="cf_sql_numeric">
	)
	</cfquery>
	<cfreturn newgrpid>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Update one record --->
<cffunction hint="Update one record" name="update" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#variables.dsn#">
		UPDATE groups
		SET	grp_name = <cfqueryparam value="#arguments.thestruct.grpname#" cfsqltype="cf_sql_varchar">
		WHERE grp_id = <cfqueryparam value="#arguments.thestruct.grp_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfreturn />
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