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
<cfcomponent output="false" extends="extQueryCaching"><!---  implements="intTrees" --->

<!--- FUNCTION: INIT --->
<!--- in parent-cfc --->

<!--- GET THE CATEGORIES AND SUBCATEGORIES OF THIS HOST --->
<!--- *IMPLEMENT THE INTERFACE* --->
<cffunction hint="GET THE CATEGORIES AND SUBCATEGORIES OF THIS HOST" name="getTree" output="false" access="public" returntype="query">
	<cfargument name="id" required="yes" type="string" hint="folder_id">
	<cfargument name="max_level_depth" default="0" required="false" type="numeric" hint="0 or negative numbers stand for all levels">
	<cfargument name="ColumnList" required="false" type="string" default="c.cat_id, c.cat_order, c.cat_online, c.cat_level, c.cat_id_r, cn.cat_name">
	<!--- this function implements only the interface & uses getTreeBy...()  --->
	<cfreturn getTreeByLang(id=Arguments.id, max_level_depth=Arguments.max_level_depth, ColumnList=Arguments.ColumnList, lang=1) />
</cffunction>

<!--- getTreeByLang : GET THE CATEGORIES AND SUBCATEGORIES OF THIS HOST --->
<!--- *IMPLEMENT INTERFACE* --->
<cffunction hint="GET THE CATEGORIES AND SUBCATEGORIES OF THIS HOST" name="getTreeByLang" output="false" access="public" returntype="query">
	<cfargument name="id" required="yes" type="string" hint="cat_id">
	<cfargument name="max_level_depth" default="0" required="false" type="numeric" hint="0 or negative numbers stand for all levels">
	<cfargument name="ColumnList" required="false" type="string" default="c.cat_id, c.cat_order, c.cat_online, c.cat_level, c.cat_id_r, cn.cat_name">
	<cfargument name="lang" required="yes" type="numeric">
	<cfargument name="cat_type" required="no" type="string" default="img">
	<!--- init internal vars --->
	<cfset var f_1 = 0>
	<cfset var qSub = 0>
	<cfset var qRet = 0>
	<!--- Do the select --->
	<cfquery datasource="#variables.dsn#" name="f_1">
		SELECT #Arguments.ColumnList#
		FROM #session.hostdbprefix#img_categories c
		INNER JOIN #session.hostdbprefix#img_categories_names cn ON c.cat_id = cn.cat_id_r
		WHERE <cfif Arguments.id gt 0>
						c.cat_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
						AND
						c.cat_id_r != c.cat_id
					<!--- root level --->
					<cfelse>
						c.cat_id_r = c.cat_id
					</cfif>
					<cfswitch expression="#arguments.cat_type#">
						<cfcase value="img">
							AND c.cat_for_img = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
						</cfcase>
						<cfcase value="vid">
							AND c.cat_for_vid = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
						</cfcase>
						</cfswitch>
					AND c.cat_online = <cfqueryparam cfsqltype="cf_sql_varchar" value="T">
					AND cn.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#Arguments.lang#">
		ORDER BY cn.cat_name
	</cfquery>
	<!--- dummy QoQ to get corect datatypes --->
	<cfquery dbtype="query" name="qRet">
		SELECT *
		FROM f_1
		WHERE cat_id = 0
	</cfquery>
	<!--- Construct the Queries together --->
	<cfloop query="f_1">
		<!--- Invoke this function again --->
		<cfif Arguments.max_level_depth neq 1>
			<cfinvoke method="getTreeByLang" returnvariable="qSub">
				<cfinvokeargument name="id" value="#f_1.cat_id#">
				<cfinvokeargument name="max_level_depth" value="#Val(Arguments.max_level_depth-1)#">
				<cfinvokeargument name="ColumnList" value="#Arguments.ColumnList#">
				<cfinvokeargument name="lang" value="#Arguments.lang#">
				<cfinvokeargument name="cat_type" value="#Arguments.cat_type#">
			</cfinvoke>
		</cfif>
		<!--- Put together the query --->
		<cfquery dbtype="query" name="qRet">
			SELECT *
			FROM qRet

			UNION ALL

			SELECT *
			FROM f_1
			WHERE cat_id = #f_1.cat_id#

			<cfif Arguments.max_level_depth neq 1>
				UNION ALL

				SELECT *
				FROM qSub
			</cfif>
		</cfquery>
	</cfloop>
	<cfreturn qRet>
</cffunction>

<!-- EVERYTHING BELOW THIS LINE IS NOT USED -->
<!---

--->

</cfcomponent>