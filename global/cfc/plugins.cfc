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

	<!--- Get all plugins --->
	<cffunction name="getall">
		<cfargument name="pathoneup" type="string" required="true">
		<!--- plugin path --->
		<cfset var pp = "#arguments.pathoneup#global/plugins">
		<!--- List plugins in this directory --->
		<cfdirectory action="list" directory="#pp#" name="plugindirs" recurse="false" type="dir" />
		<!--- Loop over directory list and add to db --->
		<cfloop query="plugindirs">
			<!--- If conf directory exists --->
			<cfif directoryExists("#directory#/#name#/config")>
				<!--- Put plugin ID into var --->
				<cfset plugID = getProfileString("#directory#/#name#/config/config.ini", "information", "id")>
				<!--- Query DB for existense --->
				<cfset qry = getone(plugID)>
				<!--- If NOT found in DB INSERT --->
				<cfif qry.recordcount EQ 0>
					<!--- Get rest of plugin information --->
					<cfset plugName = getProfileString("#directory#/#name#/config/config.ini", "information", "name")>
					<cfset plugURL = getProfileString("#directory#/#name#/config/config.ini", "information", "URL")>
					<cfset plugVersion = getProfileString("#directory#/#name#/config/config.ini", "information", "version")>
					<cfset plugAuthor = getProfileString("#directory#/#name#/config/config.ini", "information", "author")>
					<cfset plugAuthorURL = getProfileString("#directory#/#name#/config/config.ini", "information", "authorURL")>
					<cfset plugDesc = getProfileString("#directory#/#name#/config/config.ini", "information", "description")>
					<!--- Put path into var --->
					<cfset plugPath = "#name#">
					<!--- Insert into DB --->
					<cfset setplugin(plugID,plugName,plugURL,plugVersion,plugAuthor,plugAuthorURL,plugPath,plugDesc)>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Now query DB --->
		<cfset var qryall = getalldb()>
		<!--- Return --->
		<cfreturn qryall>
	</cffunction>
	
	<!--- Get one plugin --->
	<cffunction name="getalldb" returntype="query">
		<cfargument name="active" default="false" type="string" required="false">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT p_id,p_name,p_url,p_version,p_author,p_author_url,p_path,p_active,p_description
		FROM plugins
		<cfif arguments.active>
			WHERE p_active = <cfqueryparam cfsqltype="cf_sql_varchar" value="true">
		</cfif>
		ORDER BY p_name
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Get one plugin --->
	<cffunction name="getone" returntype="query">
		<cfargument name="p_id" type="string" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT p_id
		FROM plugins
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Get one plugin --->
	<cffunction name="setplugin" returntype="void">
		<cfargument name="p_id" type="string" required="true">
		<cfargument name="p_name" type="string" required="true">
		<cfargument name="p_url" type="string" required="true">
		<cfargument name="p_version" type="string" required="true">
		<cfargument name="p_author" type="string" required="true">
		<cfargument name="p_authorurl" type="string" required="true">
		<cfargument name="p_path" type="string" required="true">
		<cfargument name="p_desc" type="string" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		INSERT INTO plugins
		(p_id,p_name,p_url,p_version,p_author,p_author_url,p_path,p_description)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_name#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_url#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_version#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_author#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_authorurl#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_path#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_desc#">
		)
		</cfquery>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Set Active/Inactive --->
	<cffunction name="setactive" returntype="void">
		<cfargument name="p_id" type="string" required="true">
		<cfargument name="p_active" type="string" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		UPDATE plugins
		SET p_active = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_active#">
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
		</cfquery>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Set Active/Inactive --->
	<cffunction name="remove" returntype="void">
		<cfargument name="p_id" type="string" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM plugins
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
		</cfquery>
		<!--- Also delete plugin on the system here --->


		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>