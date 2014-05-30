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

	<!--- Errors Object --->
	<cfobject component="global.cfc.errors" name="errobj">
	
	<!--- Setup the DB if DB is not here --->
	<cffunction name="setup" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		<!--- params --->
		<cfset var thecounter = 1>
		<!--- CREATE BACKUP STATUS DB --->
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn#">
			CREATE TABLE backup_status 
			(
				back_id		VARCHAR(100), 
				back_date	timestamp,
				host_id		BIGINT
			) 
			</cfquery>
			<cfcatch type="database">
				<!--- <cfset cfcatch.custom_message = "Error while setting up database in function db_backup.setup">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/> --->
			</cfcatch>
		</cftry>
		<!--- Look into the information schema and get all the tables --->
		<cfquery datasource="#application.razuna.datasource#" name="raz_tables">
		SELECT table_name
		FROM information_schema.tables
		WHERE <cfif application.razuna.thedatabase EQ "h2">lower(table_catalog)<cfelse>lower(table_schema)</cfif> = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.razuna.theschema#">
		AND lower(table_name) != 'bddata'
		AND lower(table_name) != 'bdglobal'
		<cfif application.razuna.thedatabase EQ "h2">
			AND lower(table_type) = 'table'
		</cfif>
		</cfquery>
		<!--- Look into the column schema and get all the columns with types --->
		<cfloop query="raz_tables">
			<cfset thetablename = table_name>
			<!--- Query Columns --->
			<cfif application.razuna.thedatabase EQ "db2">
				<cfquery datasource="#application.razuna.datasource#" name="raz_columns">
				SELECT colname as column_name, typename as data_type, character_maximum_length
				FROM syscat.columns
				WHERE tabname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thetablename#">
				</cfquery>
			<cfelse>			
				<cfquery datasource="#application.razuna.datasource#" name="raz_columns">
				SELECT column_name, <cfif application.razuna.thedatabase EQ "h2">type_name as data_type<cfelse>data_type</cfif>
				, character_maximum_length
				FROM <cfif application.razuna.thedatabase EQ "oracle">all_tab_columns<cfelse>information_schema.columns</cfif>
				WHERE table_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thetablename#">
				<cfif application.razuna.thedatabase EQ "h2">
					AND lower(table_schema) = <cfqueryparam cfsqltype="cf_sql_varchar" value="public">
				<cfelseif application.razuna.thedatabase EQ "mysql">
					AND lower(table_schema) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.razuna.theschema#">
				</cfif>
				</cfquery>
			</cfif>
			<!--- Create table --->
			<cftry>
				<cfquery datasource="#arguments.thestruct.dsn#">
				CREATE TABLE #arguments.thestruct.tschema#.#thetablename#
				(
					<cfloop query="raz_columns">#column_name# <cfif character_maximum_length EQ "-1">CLOB<cfelse>#data_type#<cfif isnumeric(character_maximum_length)>(#character_maximum_length#)</cfif></cfif><cfif thecounter LT raz_columns.recordcount>,</cfif>
						<cfset thecounter = thecounter + 1>
					</cfloop>
				)
				</cfquery>
				<!--- Reset counter --->
				<cfset thecounter = 1>
				<!--- Catch --->
				<cfcatch type="any">
					<cfset cfcatch.custom_message = "Error while creating table in function db_backup.setup">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				</cfcatch>
			</cftry>
		</cfloop>
	</cffunction>
		
	<!--- OPENBD CONFIG INTERACTION --->
	
	<cffunction name="bdgetConfig" access="private" output="false" returntype="struct" hint="Returns a struct representation of the OpenBD server configuration (bluedragon.xml)">
		<cfset var admin = "" />
			<cflock scope="Server" type="readonly" timeout="5">
				<cfset admin = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").getConfig().getCFMLData() />
			</cflock>
		<cfreturn admin.server />
	</cffunction>
	
	<cffunction name="bdsetConfig" access="private" output="false" returntype="void" hint="Sets the server configuration and tells OpenBD to refresh its settings">
		<cfargument name="currentConfig" type="struct" required="true" hint="The configuration struct, which is a struct representation of bluedragon.xml" />
			<cflock scope="Server" type="exclusive" timeout="5">
				<cfset admin.server = duplicate(arguments.currentConfig) />
				<cfset admin.server.openbdadminapi.lastupdated = DateFormat(now(), "dd/mmm/yyyy") & " " & TimeFormat(now(), "HH:mm:ss") />
				<cfset admin.server.openbdadminapi.version = "1.0" />
				<cfset xmlConfig = createObject("java", "com.naryx.tagfusion.xmlConfig.xmlCFML").init(admin) />
				<cfset success = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").writeXmlFile(xmlConfig) />
			</cflock>
	</cffunction>
	
	<cffunction name="bddatasourceExists" access="public" output="false" returntype="boolean" hint="Returns a boolean indicating whether or not a datasource with the specified name exists">
		<cfargument name="dsn" type="string" required="true" hint="The datasource name to check" />
		<cfset var dsnExists = true />
		<cfset var localConfig = bdgetConfig() />
		<cfset var i = 0 />
		<cfif not StructKeyExists(localConfig, "cfquery") or not StructKeyExists(localConfig.cfquery, "datasource")>
			<!--- no datasources at all, so this one doesn't exist ---->
			<cfset dsnExists = false />
		<cfelse>
			<cfloop index="i" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
				<cfif localConfig.cfquery.datasource[i].name is arguments.dsn>
					<cfset dsnExists = true />
					<cfbreak />
				<cfelse>
					<cfset dsnExists = false />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn dsnExists />
	</cffunction>
	
	<cffunction name="BDsetDatasource" access="public" output="false" returntype="void" hint="Creates or updates a datasource">
		<cfargument name="name" type="string" required="true" hint="OpenBD Datasource Name" />
		<cfargument name="databasename" type="string" required="false" default="" hint="Database name on the database server" />
		<cfargument name="server" type="string" required="false" default="" hint="Database server host name or IP address" />
		<cfargument name="port"	type="numeric" required="false" default="0" hint="Port that is used to access the database server" />
		<cfargument name="username" type="string" required="false" default="" hint="Database username" />
		<cfargument name="password" type="string" required="false" default="" hint="Database password" />
		<cfargument name="hoststring" type="string" required="false" default="" hint="JDBC URL for 'other' database types. Databasename, server, and port arguments are ignored if a hoststring is provided." />
		<cfargument name="description" type="string" required="false" default="" hint="A description of this data source" />
		<cfargument name="initstring" type="string" required="false" default="" hint="Additional initialization settings" />
		<cfargument name="connectiontimeout" type="numeric" required="false" default="120" hint="Number of seconds OpenBD maintains an unused connection before it is destroyed" />
		<cfargument name="connectionretries" type="numeric" required="false" default="0" hint="Number of connection retry attempts to make" />
		<cfargument name="logintimeout" type="numeric" required="false" default="120" hint="Number of seconds before OpenBD times out the data source connection login attempt" />
		<cfargument name="maxconnections" type="numeric" required="false" default="3" hint="Maximum number of simultaneous database connections" />
		<cfargument name="perrequestconnections" type="boolean" required="false" default="false" hint="Indication of whether or not to pool connections" />
		<cfargument name="sqlselect" type="boolean" required="false" default="true" hint="Allow SQL SELECT statements from this datasource" />
		<cfargument name="sqlinsert" type="boolean" required="false" default="true" hint="Allow SQL INSERT statements from this datasource" />
		<cfargument name="sqlupdate" type="boolean" required="false" default="true" hint="Allow SQL UPDATE statements from this datasource" />
		<cfargument name="sqldelete" type="boolean" required="false" default="true" hint="Allow SQL DELETE statements from this datasource" />
		<cfargument name="sqlstoredprocedures" type="boolean" required="false" default="true" hint="Allow SQL stored procedure calls from this datasource" />
		<cfargument name="drivername" type="string" required="false" default="" hint="JDBC driver class to use" />
		<cfargument name="action" type="string" required="false" default="create" hint="Action to take on the datasource (create or update)" />
		<cfargument name="existingDatasourceName" type="string" required="false" default="" hint="The existing (old) datasource name so we know what to delete if this is an update" />
		<cfargument name="verificationQuery" type="string" required="false" default="" hint="Custom verification query for 'other' driver types" />
		
		<cfset var localConfig = bdgetConfig() />
		<cfset var datasourceSettings = structNew() />
		
		<!--- make sure configuration structure exists, otherwise build it --->
		<cfif (NOT StructKeyExists(localConfig, "cfquery")) OR (NOT StructKeyExists(localConfig.cfquery, "datasource"))>
			<cfset localConfig.cfquery.datasource = ArrayNew(1) />
		</cfif>
		
		<!--- if the datasource already exists and this isn't an update, throw an error --->
		<cfif bddatasourceExists(arguments.name) EQ "false">
			<!--- build up the universal datasource settings --->
			<cfscript>
				// Set the params
				datasourceSettings.name = trim(lcase(arguments.name));
				datasourceSettings.displayname = arguments.name;
				datasourceSettings.databasename = trim(arguments.databasename);
				datasourceSettings.username = trim(arguments.username);
				datasourceSettings.password = trim(arguments.password);
				datasourceSettings.drivername = trim(arguments.drivername);
				datasourceSettings.initstring = trim(arguments.initstring);
				datasourceSettings.sqlselect = ToString(arguments.sqlselect);
				datasourceSettings.sqlinsert = ToString(arguments.sqlinsert);
				datasourceSettings.sqlupdate = ToString(arguments.sqlupdate);
				datasourceSettings.sqldelete = ToString(arguments.sqldelete);
				datasourceSettings.sqlstoredprocedures = ToString(arguments.sqlstoredprocedures);
				datasourceSettings.logintimeout = ToString(arguments.logintimeout);
				datasourceSettings.connectiontimeout = ToString(arguments.connectiontimeout);
				datasourceSettings.connectionretries = ToString(arguments.connectionretries);
				datasourceSettings.maxconnections = ToString(arguments.maxconnections);
				datasourceSettings.perrequestconnections = ToString(arguments.perrequestconnections);
				datasourceSettings.hoststring = ToString(arguments.hoststring);
				// prepend the new datasource to the localconfig array
				arrayPrepend(localConfig.cfquery.datasource, structCopy(datasourceSettings));
				// update the config
				bdsetConfig(localConfig);
			</cfscript>
		</cfif>
	</cffunction>
		
</cfcomponent>