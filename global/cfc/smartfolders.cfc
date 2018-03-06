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
<cfcomponent output="false" output="false" extends="extQueryCaching">

	<!--- Get All --->
	<cffunction name="getall" access="Public" output="false">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Params --->
		<cfset var qry = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#sfgetall */ sf_id, sf_name, sf_type, '' AS shared
		FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
		WHERE sf_type <cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="saved_search">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		UNION ALL
		SELECT /* #cachetoken#sfgetall */ sf_id, sf_name, sf_type, '' AS shared
		FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
		WHERE sf_who = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.razuna.session.theuserid#">
		AND sf_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="saved_search">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		UNION ALL
		SELECT sf_id, sf_name, sf_type, 'true' AS shared
		FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders sf JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg ON sf.sf_id = fg.folder_id_r
		AND sf.sf_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="saved_search">
		AND fg.grp_permission = <cfqueryparam cfsqltype="cf_sql_varchar" value="r">
		AND sf.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		ORDER BY sf_type DESC, sf_name
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Get One --->
	<cffunction name="getone" access="Public" output="false">
		<cfargument name="sf_id" required="false" default="0">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Params --->
		<cfset var qry = structnew()>
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry.sf" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#sfgetone */ sf_id, sf_name, sf_type, sf_description, sf_zipextract
		FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
		WHERE sf_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<!--- Query properties --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry.sfprop" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#sfgetoneprop */ sf_prop_id, sf_prop_value
		FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders_prop
		WHERE sf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Update --->
	<cffunction name="update" access="Public" output="false" returntype="void">
		<cfargument name="thestruct" required="true" type="struct">
		<!--- Param --->
		<cfparam name="arguments.thestruct.sf_description" default="">
		<cfparam name="arguments.thestruct.sf_zipextract" default="0">
		<!--- If the ID is 0 = new folder --->
		<cfif arguments.thestruct.sf_id EQ 0>
			<!--- Create ID --->
			<cfset arguments.thestruct.sf_id = createUUID("")>
			<!--- Insert --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
			(sf_id, host_id, sf_who)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_id#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.razuna.session.theuserid#">
			)
			</cfquery>
			<!--- Insert Properties --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#smart_folders_prop
			(sf_id_r, host_id)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_id#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			)
			</cfquery>
		</cfif>
		<!--- Update --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		UPDATE #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
		SET
		sf_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_name#">,
		sf_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_description#">,
		sf_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_type#">,
		sf_date_create = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		sf_date_update = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		sf_zipextract = <cfqueryparam cfsqltype="cf_sql_varchar" value="#iif(arguments.thestruct.sf_zipextract EQ 'on',1,0)#">
		WHERE sf_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_id#">
		</cfquery>
		<!--- Save to properties for search --->
		<cfif arguments.thestruct.sf_type EQ "saved_search" AND arguments.thestruct.searchtext NEQ "">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#smart_folders_prop
			SET
			sf_prop_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="searchtext">,
			sf_prop_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.searchtext#">
			WHERE sf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_id#">
			</cfquery>
		</cfif>
		<!--- Save to properties for S3 --->
		<cfif arguments.thestruct.sf_type EQ "amazon">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#smart_folders_prop
			SET
			sf_prop_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="bucket">,
			sf_prop_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_s3_bucket#">
			WHERE sf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_id#">
			</cfquery>
		</cfif>
		<!--- First delete all the groups --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups
		WHERE folder_id_r = <cfqueryparam value="#arguments.thestruct.sf_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<!--- Insert the Group and Permission --->
		<cfloop collection="#arguments.thestruct#" item="myform">
			<cfif myform CONTAINS "grp_">
				<cfset var grpid = ReplaceNoCase(myform, "grp_", "")>
				<cfset var grpidno = Replace(grpid, "-", "", "all")>
				<cfset var theper = "per_" & "#grpidno#">
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#folders_groups
				(folder_id_r, grp_id_r, grp_permission, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#arguments.thestruct.sf_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#grpid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#evaluate(theper)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Reset cache --->
		<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Remove --->
	<cffunction name="remove" access="Public" output="false" returntype="void">
		<cfargument name="sf_id" required="false" default="0">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Remove in master record --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
		WHERE sf_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_id#">
		</cfquery>
		<!--- Remove in properties --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders_prop
		WHERE sf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_id#">
		</cfquery>
		<!--- Reset cache --->
		<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Remove --->
	<cffunction name="removeWithName" access="Public" output="false" returntype="void">
		<cfargument name="sf_account" required="false" default="0">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Select record in order for us to delete --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry_sf">
		SELECT sf_id
		FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
		WHERE sf_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_account#">
		</cfquery>
		<cfloop query="qry_sf">
			<!--- Remove in master record --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders
			WHERE sf_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sf_id#">
			</cfquery>
			<!--- Remove in properties --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders_prop
			WHERE sf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sf_id#">
			</cfquery>
		</cfloop>
		<!--- Reset cache --->
		<cfset resetcachetoken(type="folders", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>
