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
	
	<!--- INIT --->
	<cffunction name="init" returntype="approval" access="public" output="false">
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<!--- Admin: Save --->
	<cffunction name="admin_save" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- If enabled is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_enabled" default="false" />
		<!--- If approval_group_1_all is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_group_1_all" default="false" />
		<!--- If approval_group_1_all is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_group_2_all" default="false" />
		<!--- If approval_folders_all is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_folders_all" default="false" />


		<!--- Set other fields in case user doesn't enter them --->
		<cfparam name="arguments.thestruct.approval_group_1" default="" />
		<cfparam name="arguments.thestruct.approval_group_2" default="" />
		<cfparam name="arguments.thestruct.approval_folders" default="" />

		<!--- Delete record in DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#approval
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Save to DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#approval
		(approval_enabled, approval_folders, approval_folders_all, approval_group_1, approval_group_2, approval_group_1_all, approval_group_2_all, host_id)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_enabled#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.approval_folders#">,
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_folders_all#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.approval_group_1#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.approval_group_2#">,
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_group_1_all#">,
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_group_2_all#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>

		<cfreturn />
	</cffunction>

	<!--- Admin: Get --->
	<cffunction name="admin_get" access="public" output="true">
		<cfset var qry = "">
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT approval_enabled, approval_folders, approval_folders_all, approval_group_1, approval_group_2, approval_group_1_all, approval_group_2_all
		FROM #session.hostdbprefix#approval
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif qry.recordcount EQ 0>
			<cfset _qry.approval_enabled = false>
			<cfset _qry.approval_folders_all = false>
			<cfset _qry.approval_group_1_all = false>
			<cfset _qry.approval_group_2_all = false>
			<cfset QueryAddrow( query=qry, data=_qry )>
		</cfif>
		<cfreturn qry>
	</cffunction>
	
</cfcomponent>
