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
	
	<cfset variables.cachetoken = getcachetoken("settings")>

	<!--- Get all plugins --->
	<cffunction name="getall">
		<cfargument name="pathoneup" type="string" required="true">
		<!--- plugin path --->
		<cfset var pp = "#arguments.pathoneup#global/plugins">
		<!--- List plugins in this directory --->
		<cfdirectory action="list" directory="#pp#" name="plugindirs" recurse="false" type="dir" />
		<!--- Filter out the skeleton --->
		<cfquery dbtype="query" name="plugindirs">
		SELECT *
		FROM plugindirs
		WHERE name != 'skeleton'
		</cfquery>
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
					<cfset plugLicense = getProfileString("#directory#/#name#/config/config.ini", "information", "license")>
					<!--- Put path into var --->
					<cfset plugPath = "#name#">
					<!--- Insert into DB --->
					<cfset setplugin(plugID,plugName,plugURL,plugVersion,plugAuthor,plugAuthorURL,plugPath,plugDesc,plugLicense)>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Now query DB --->
		<cfset var qryall = getalldb()>
		<!--- Return --->
		<cfreturn qryall>
	</cffunction>
	
	<!--- Get all plugins --->
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
		SELECT p_id,p_name,p_url,p_version,p_author,p_author_url,p_path,p_active,p_description,p_license
		FROM plugins
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Set plugin --->
	<cffunction name="setplugin" returntype="void">
		<cfargument name="p_id" type="string" required="true">
		<cfargument name="p_name" type="string" required="true">
		<cfargument name="p_url" type="string" required="true">
		<cfargument name="p_version" type="string" required="true">
		<cfargument name="p_author" type="string" required="true">
		<cfargument name="p_authorurl" type="string" required="true">
		<cfargument name="p_path" type="string" required="true">
		<cfargument name="p_desc" type="string" required="true">
		<cfargument name="p_license" type="string" required="true">
		<!--- Query --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			INSERT INTO plugins
			(p_id,p_name,p_url,p_version,p_author,p_author_url,p_path,p_description,p_license)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_name#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_url#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_version#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_author#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_authorurl#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_path#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_desc#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_license#">
			)
			</cfquery>
			<!--- Reset cache --->
			<!--- <cfset resetcachetoken("settings")> --->
			<cfcatch type="database">
				<cfset consoleoutput(true)>
				<cfset console(cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Set Active/Inactive --->
	<cffunction name="setactive" returntype="void">
		<cfargument name="p_id" type="string" required="true">
		<cfargument name="p_active" type="string" required="true">
		<cfargument name="pathup" type="string" required="true">
		<!--- Param --->
		<cfset var listCFC = "">
		<!--- Get path of plugin from db --->
		<cfset var qryPlugin = getone("#arguments.p_id#")>
		<cfset var pluginPathName = qryPlugin.p_path>
		<cfset var pluginDir = arguments.pathup & "global/plugins/" & pluginPathName & "/cfc/">
		<!--- First remove all actions for this plugin --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM plugins_actions
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
		</cfquery>
		<!--- Do below only on activate --->
		<cfif p_active>
			<!--- Execute table actions --->
			<cfinvoke component="global.plugins.#pluginPathName#.cfc.main" method="db" />
			<!--- Get all cfc and put into DB (not really needed for now)
			<cfif directoryExists(pluginDir)>
				<!--- List the CFC directory --->
				<cfdirectory directory="#pluginDir#" action="list" name="lCFC" type="file" recurse="false" />
				<!--- create a list --->
				<cfset listCFC = valuelist(lCFC.name)>
				<!--- Remove the .cfc from the name --->
				<cfset listCFC = replaceNoCase(listCFC, ".cfc", "", "all")>
			</cfif>
			 --->
		<cfelse>
			<!--- Remove from ct table for all hosts --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM ct_plugins_hosts
			WHERE ct_pl_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
			</cfquery>
		</cfif>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE plugins
		SET 
		p_active = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_active#">,
		p_cfc_list = <cfqueryparam cfsqltype="cf_sql_varchar" value="#listCFC#">
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
		</cfquery>
		<!--- Reset cache --->
		<!--- <cfset resetcachetoken("settings")> --->
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Upload --->
	<cffunction name="upload" returntype="void">
		<cfargument name="thestruct" required="true" type="struct">
		<!--- Set path for plugins --->
		<cfset var p = expandpath("../") & "global/plugins">
		<!--- Upload file into plugin directory (will fail if name is already there) --->
		<cffile action="upload" destination="#p#" nameconflict="error" filefield="thefile" result="thefile">
		<!--- Unzip the file --->
		<cfset unzip(destination="#p#", zipfile="#p#/#thefile.serverFile#")>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Remove plugin --->
	<cffunction name="remove" returntype="void">
		<cfargument name="p_id" type="string" required="true">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM plugins
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.p_id#">
		</cfquery>
		<!--- Also delete plugin on the system here --->

		<!--- Reset cache --->
		<!--- <cfset resetcachetoken("settings")> --->
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- setpluginshosts --->
	<cffunction name="setpluginshosts" returntype="void">
		<cfargument name="thestruct" type="struct" required="true">
			<!--- Set the remove colum to true for all --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE plugins_actions
			SET p_remove = 'true'
			</cfquery>
			<!--- Since this is the general list we remove all values first --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM ct_plugins_hosts
			</cfquery>
			<!--- Loop over the passed in list and add one by one --->
			<cfloop list="#arguments.thestruct.listpluginshost#" index="i" delimiters=",">
				<!--- Get the first value (host) --->
				<cfset hostid = listFirst(i,"-")>
				<!--- Get last value (pluginid) --->
				<cfset plid = listLast(i,"-")>
				<!--- And insert to DB --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO ct_plugins_hosts
				(ct_pl_id_r, ct_host_id_r, rec_uuid)
				VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#plid#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#hostid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">
				)
				</cfquery>
				<!--- Query the plugin so we know the path --->
				<cfset var qryPlugin = getone("#plid#")>
				<!--- Set the session for the hostid --->
				<cfset session.hostid = hostid>
				<!--- Execute the main.cfc which will add all the actions of the plugin to the DB --->
				<cfinvoke component="global.plugins.#qryPlugin.p_path#.cfc.main" method="load" />
				<!--- Set the remove to false --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE plugins_actions
				SET p_remove = 'false'
				WHERE host_id = #hostid#
				AND p_id = '#plid#'
				</cfquery>
			</cfloop>
			<!--- Now remove all actions where the remove is true --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM plugins_actions
			WHERE p_remove = 'true'
			</cfquery>
		<!--- Reset cache --->
		<!--- <cfset resetcachetoken("settings")> --->
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- getpluginshosts --->
	<cffunction name="getpluginshosts" returntype="query">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT ct_pl_id_r, ct_host_id_r
		FROM ct_plugins_hosts
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- getpluginactions --->
	<cffunction name="getactions" returntype="Struct">
		<cfargument name="theaction" required="true" />
		<cfargument name="args" default="#structnew()#" required="false" />
		<!--- Params --->
		<cfparam name="arguments.args.folder_action" default="false" />
		<cfparam name="arguments.args.nameOfVariable" default="pl" />
		<cfparam name="arguments.args.comingfrom" default="#cgi.http_referer#" />
		<cfset var result = structnew()>
		<cfset result.pcfc = "">
		<cfset result.pview = "">
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT pa.comp, pa.func, pa.args, p.p_path
		FROM plugins_actions pa, plugins p
		WHERE lower(pa.action) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theaction#">
		AND pa.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif structKeyExists(arguments.args, "p_id")>
			AND p.p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.args.p_id#">
		</cfif>
		AND pa.p_id = p.p_id
		<cfif arguments.args.folder_action>
			AND args LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%folderid:#arguments.args.folder_id#%">
		<cfelse>
			AND (args NOT LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%folderid:%"> OR args IS NULL)
		</cfif>
		</cfquery>
		<!--- Put query above into args struct so we have it in the plugin --->
		<cfset arguments.args.qry_plugins_actions = qry>
		<!--- Execute actions --->
		<cfloop query="qry">
			<!--- 1. CFC --->
			<cfinvoke component="global.plugins.#p_path#.cfc.#comp#" method="#func#" args="#arguments.args#" returnvariable="result.cfc.#arguments.args.nameOfVariable#.#func#" />
			<!--- Set the page value always to true if not defined --->
			<cfset s = evaluate("result.cfc.#arguments.args.nameOfVariable#.#func#")>
			<cfif !isStruct(s) OR !structKeyExists(s, "page")>
				<cfset var page = true>
			<cfelse>
				<cfset var page = false>
			</cfif>
			<!--- 2. include the page just not if dev set the page value to false (like coming from a save or alike) --->
			<cfif fileExists("#expandpath("../../")#global/plugins/#p_path#/view/#lcase(func)#.cfm") AND page>
				<!--- Parse view page --->
				<cfsavecontent variable="result.view.#arguments.args.nameOfVariable#.#func#"><cfsetting enablecfoutputonly="false" /><cfinclude template="/global/plugins/#p_path#/view/#lcase(func)#.cfm" /><cfsetting enablecfoutputonly="true" /></cfsavecontent>
				<!--- Put into variable --->
				<cfset result.pview = result.pview & "," & "#arguments.args.nameOfVariable#.view.#arguments.args.nameOfVariable#.#func#">
			</cfif>
			<!--- Put cfc path into list for easier retrieval --->
			<cfset result.pcfc = result.pcfc & "," & "cfc.#arguments.args.nameOfVariable#.#func#">
		</cfloop>
		<!--- Return --->
		<cfreturn result />
	</cffunction>

	<!--- callDirect --->
	<cffunction name="callDirect" returntype="Struct">
		<cfargument name="args" required="true" />
		<!--- Params --->
		<cfparam name="arguments.args.nameOfVariable" default="pl" />
		<cfset var result = structnew()>
		<cfset result.pcfc = "">
		<cfset result.pview = "">
		<!--- Take comp path apart --->
		<cfset var fcomp = listFirst(arguments.args.comp, ".")>
		<!--- Just invoke the cfc --->
		<cfinvoke component="global.plugins.#arguments.args.comp#" method="#arguments.args.func#" args="#arguments.args#" returnvariable="result.cfc.#arguments.args.nameOfVariable#.#arguments.args.func#" />
		<!--- Set the page value always to true if not defined --->
		<cfset s = evaluate("result.cfc.#arguments.args.nameOfVariable#.#arguments.args.func#")>
		<cfif !isStruct(s) OR !structKeyExists(s, "page")>
			<cfset var page = true>
		<cfelse>
			<cfset var page = false>
		</cfif>
		<!--- Include the page just not if dev set the page value to false (like coming from a save or alike) --->
		<cfif fileExists("#expandpath("../../")#global/plugins/#fcomp#/view/#lcase(arguments.args.func)#.cfm") AND page>
			<!--- Parse view page --->
			<cfsavecontent variable="result.view.#arguments.args.nameOfVariable#.#arguments.args.func#"><cfsetting enablecfoutputonly="false" /><cfinclude template="/global/plugins/#fcomp#/view/#lcase(arguments.args.func)#.cfm" /><cfsetting enablecfoutputonly="true" /></cfsavecontent>
			<!--- Put into variable --->
			<cfset result.pview = "#arguments.args.nameOfVariable#.view.#arguments.args.nameOfVariable#.#arguments.args.func#">
		</cfif>
		<!--- Return --->
		<cfreturn result />
	</cffunction>

	<!--- getpluginactions --->
	<cffunction name="mailme" returntype="Struct">
		<cfargument name="theaction" required="true" />
		<cfargument name="args" default="#structnew()#" required="false" />
		<!--- Params --->
		<cfparam name="arguments.args.folder_action" default="false" />
		<cfparam name="arguments.args.nameOfVariable" default="pl" />
		<cfparam name="arguments.args.comingfrom" default="#cgi.http_referer#" />
		<cfset var result = structnew()>
		<cfset result.pcfc = "">
		<cfset result.pview = "">
		<cfset var qry = "">
		<cfmail from="server@razuna.com" to="nitai@razuna.com" subject="debug" type="html"><cfdump var="#arguments#"></cfmail>

	</cffunction>

</cfcomponent>