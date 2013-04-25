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
	
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("folders")>

	<!--- Get All --->
	<cffunction name="getall" access="Public" output="false">
		<!--- Params --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#sfgetall */ sf_id, sf_name
		FROM #session.hostdbprefix#smart_folders
		ORDER BY lower(sf_name)
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Get One --->
	<cffunction name="getone" access="Public" output="false">
		<cfargument name="sf_id" required="false" default="0">
		<!--- Params --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#sfgetone */ sf_id, sf_name, sf_type, sf_description
		FROM #session.hostdbprefix#smart_folders
		WHERE sf_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_id#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Update --->
	<cffunction name="update" access="Public" output="false" returntype="void">
		<cfargument name="thestruct" required="true" type="struct">
		<!--- If the ID is 0 = new folder --->
		<cfif arguments.thestruct.sf_id EQ 0>
			<!--- Create ID --->
			<cfset arguments.thestruct.sf_id = createUUID("")>
			<!--- Insert --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#smart_folders
			(sf_id)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_id#">
			)
			</cfquery>
		</cfif>
		<!--- Update --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#smart_folders
		SET 
		sf_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_name#">,
		sf_description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_description#">
		WHERE sf_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.sf_id#">
		</cfquery>
		<!--- Reset cache --->
		<cfset variables.cachetoken = resetcachetoken("folders")>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	
</cfcomponent>
