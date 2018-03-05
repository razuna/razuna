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

	<cffunction name="init" returntype="widgets" access="public" output="false">
		<cfreturn this />
	</cffunction>

	<!--- Get existing widgets --->
	<cffunction name="getwidgets" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<cfset var qry = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="general", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getwidgets */ widget_id, widget_name, widget_description
		FROM #arguments.thestruct.razuna.session.hostdbprefix#widgets
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		AND col_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Detail --->
	<cffunction name="detail" output="true" access="public" returnType="query">
		<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken(type="general", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Params --->
		<cfparam name="arguments.thestruct.external" default="f">
		<cfset var qry = "">
		<!--- Query --->
		<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#detailwidget */ widget_id, col_id_r, folder_id_r, widget_name, widget_description, widget_permission, widget_password, widget_style, widget_dl_org, widget_uploading, widget_dl_thumb
		FROM #arguments.thestruct.razuna.session.hostdbprefix#widgets
		WHERE widget_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		<cfif arguments.thestruct.external EQ "f">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
			AND col_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">
		</cfif>
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Save / Update Widget --->
	<cffunction name="update" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- If this is a new widget insert else update --->
		<cfif arguments.thestruct.widget_id EQ 0>
			<!--- Create new ID --->
			<cfset var newid = createuuid("")>
			<!--- Insert --->
			<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#widgets
			(widget_id, col_id_r, folder_id_r, widget_name, widget_description, widget_permission, widget_password, widget_style, widget_dl_org, widget_uploading, host_id, widget_dl_thumb)
			VALUES(
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#newid#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.col_id#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_name#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_description#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_permission#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_password#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_style#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_dl_org#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_uploading#">,
			<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">,
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_dl_thumb#">
			)
			</cfquery>
			<cfset arguments.thestruct.widget_id = newid>
		<cfelse>
			<!--- Update --->
			<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#widgets
			SET
			widget_name = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_name#">,
			widget_description = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_description#">,
			widget_permission = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_permission#">,
			widget_password = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_password#">,
			widget_style = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_style#">,
			widget_dl_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_dl_org#">,
			widget_dl_thumb = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_dl_thumb#">,
			widget_uploading = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_uploading#">
			WHERE widget_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_id#">
			AND host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.razuna.session.hostid#">
			</cfquery>
		</cfif>
		<!--- Flush Cache --->
		<cfset resetcachetoken(type="general", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfoutput>#arguments.thestruct.widget_id#</cfoutput>
		<cfreturn />
	</cffunction>

	<!--- Compare password --->
	<cffunction name="getpassword" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<cfset var qry = "">
		<!--- Query --->
		<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT widget_id
		FROM #arguments.thestruct.razuna.session.hostdbprefix#widgets
		WHERE widget_password = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.pass#">
		AND widget_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.widget_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<cfif qry.recordcount EQ 1>
			<cfset arguments.thestruct.razuna.session.widget_login = "T">
			<!--- <cfoutput>true</cfoutput> --->
			<cflocation url="index.cfm?fa=c.w_proxy" />
		<cfelse>
			<cfset arguments.thestruct.razuna.session.widget_login = "F">
			<!--- <cfoutput>false</cfoutput> --->
			<cflocation url="index.cfm?fa=c.w&le=t&wid=#arguments.thestruct.widget_id#" />
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Widget Remove --->
	<cffunction name="widget_remove" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<cfset var qry = "">
		<!--- Remove --->
		<cfquery dataSource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#widgets
		WHERE widget_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<!--- Flush Cache --->
		<cfset resetcachetoken(type="general", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn  />
	</cffunction>

</cfcomponent>