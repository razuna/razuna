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
<cfcomponent hint="CFC for Modules" output="false">

<!--- FUNCTION: INIT --->
<cffunction name="init" returntype="modules" access="public" output="false">
	<cfargument name="dsn" type="string" required="yes" />
	<cfargument name="database" type="string" required="yes" />
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.database = arguments.database />
	<cfreturn this />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get ids in struct --->
<cffunction hint="Get ids in struct" name="getIdStruct" returntype="struct">
	<!--- function internal vars --->
	<cfset var localquery = getall()>
	<cfset var returnStruct = StructNew()>
	<cfloop query="localquery">
		<cfset returnStruct[localquery.mod_short] = localquery.mod_id>
	</cfloop>
	<cfreturn returnStruct />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get all the records --->
<cffunction hint="Get all records" name="getall" returntype="query">
	<cfargument name="orderBy" type="string" required="false" default="mod_short, mod_name" hint="""ORDER BY #yourtext#""">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#variables.dsn#" name="localquery">
		SELECT mod_id, mod_name, mod_short, mod_host_id
		FROM modules
		WHERE (
			mod_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			OR mod_host_id IS NULL
			OR mod_host_id = ''
			)
		ORDER BY #arguments.orderBy#
	</cfquery>
	<cfreturn localquery>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get id from short --->
<cffunction hint="Get id from short" name="getid" returntype="numeric">
	<cfargument name="mod_short" type="string" required="yes">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#variables.dsn#" name="localquery">
		SELECT mod_id
		FROM modules
		WHERE mod_short = <cfqueryparam value="#arguments.mod_short#" cfsqltype="cf_sql_varchar">
		AND (
			mod_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			OR mod_host_id IS NULL
			OR mod_host_id = ''
			)
	</cfquery>
	<cfreturn Val(localquery.mod_id)>
</cffunction>








<!--- NOT USED --->



<!--- ------------------------------------------------------------------------------------- --->
<!--- Get one detailled record --->
<cffunction hint="Get one record" name="getdetail" returntype="query">
	<cfargument name="func_dsn" type="string" required="yes">
	<cfargument name="func_id" type="numeric" required="yes">
	<!--- function internal vars --->
	<cfset var localquery = 0>
	<cfquery datasource="#arguments.func_dsn#" name="localquery">
		SELECT		*
		FROM			modules
		WHERE			mod_id = <cfqueryparam value="#arguments.func_id#" cfsqltype="cf_sql_numeric">
							AND
							(
								mod_host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
								OR
								mod_host_id IS NULL
								OR 
								mod_host_id = ''
							)
	</cfquery>
	<cfreturn localquery>
</cffunction>




</cfcomponent>