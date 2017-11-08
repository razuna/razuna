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
<cfcomponent>
	
	<cfset variables.api.version = "1.3" />
	<cfset variables.isMultiContextJetty = false />
	
	<cffunction name="getConfig" access="package" output="false" returntype="struct" 
			hint="Returns a struct representation of the OpenBD server configuration (bluedragon.xml)">
		<cfset var admin = 0 />
		
		<cflock scope="Server" type="readonly" timeout="5">
			<cfset admin = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").getConfig().getCFMLData() />
		</cflock>

		<cfreturn admin.server />
	</cffunction>
	

	<cffunction name="getDatasources" access="public" output="false" returntype="array" 
			hint="Returns an array containing all the data sources or a specified data source">
		<cfargument name="dsn" type="string" required="false" default="" hint="The name of the datasource to return" />
		
		<cfset var localConfig = getConfig() />
		<cfset var returnArray = "" />
		<cfset var dsnIndex = "" />
		<cfset var sortKeys = arrayNew(1) />
		<cfset var sortKey = structNew() />
		
		<!--- Make sure there are datasources --->
		<cfif NOT StructKeyExists(localConfig, "cfquery") OR NOT StructKeyExists(localConfig.cfquery, "datasource")>
			<cfthrow message="No registered datasources" type="bluedragon.adminapi.datasource" />
		</cfif>
		
		<!--- Return entire data source array, unless a data source name is specified --->
		<cfif NOT StructKeyExists(arguments, "dsn") or arguments.dsn is "">
			<!--- set the sorting information --->
			<cfset sortKey.keyName = "name" />
			<cfset sortKey.sortOrder = "ascending" />
			<cfset arrayAppend(sortKeys, sortKey) />
	
			<cfreturn variables.udfs.sortArrayOfObjects(localConfig.cfquery.datasource, sortKeys, false, false) />
		<cfelse>
			<cfset returnArray = ArrayNew(1) />
			<cfloop index="dsnIndex" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
				<cfif localConfig.cfquery.datasource[dsnIndex].name EQ arguments.dsn>
					<cfset returnArray[1] = Duplicate(localConfig.cfquery.datasource[dsnIndex]) />
					<cfreturn returnArray />
				</cfif>
			</cfloop>
			<cfreturn ArrayNew(1)>
		</cfif>
	</cffunction>

	<cffunction name="verifyDatasource" access="public" output="false" returntype="any" 
			hint="Verifies a datasource">
		<cfargument name="dsn" type="string" required="true" hint="Datasource name to verify" />
		
		<cfset var verified = false />
		<cfset var datasource = getDatasources(arguments.dsn).get(0) />
		<cfset var driverManager = createObject("java", "java.sql.DriverManager") />
		<cfset var dbcon = 0 />
		<cfset var stmt = 0 />
		<cfset var rs = 0 />
		
		<!--- check that we can hit the driver --->
		<cftry>
			<cfset registerDriver(datasource.drivername) />
			<cfcatch type="any">
				<cfrethrow />
			</cfcatch>
		</cftry>
		
		<!--- run a verification query based on the driver; need to do this in java so we get a clean connection, because 
				otherwise the connection from openbd may be cached/pooled so changes to things like server name don't 
				get picked up --->
		<cfswitch expression="#datasource.drivername#">
			<!--- mysql and postgres --->
			<cfcase value="com.mysql.jdbc.Driver,org.postgresql.Driver">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT NOW()") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---
<cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
								type="bluedragon.adminapi.datasource" />
--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- oracle --->
			<cfcase value="oracle.jdbc.OracleDriver">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT SYSDATE FROM DUAL") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---
<cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
								type="bluedragon.adminapi.datasource" />
--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- sql server, h2 --->
			<cfcase value="com.microsoft.sqlserver.jdbc.SQLServerDriver,net.sourceforge.jtds.jdbc.Driver,org.h2.Driver" delimiters=",">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT 1") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---
<cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
								type="bluedragon.adminapi.datasource" />
--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- odbc datasource --->
			<cfcase value="sun.jdbc.odbc.JdbcOdbcDriver">
				<cftry>
					<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
					<cfset stmt = dbcon.createStatement() />
					<cfset rs = stmt.executeQuery("SELECT 1") />
					
					<cfif rs.next()>
						<cfset verified = true />
					</cfif>
					<cfcatch type="any">
						<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
						<!---
<cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
								type="bluedragon.adminapi.datasource" />
--->
					</cfcatch>
				</cftry>
			</cfcase>
			
			<!--- 'other' database types --->
			<cfdefaultcase>
				<!---try to use the custom verification query; otherwise throw an error --->
				<cfif structKeyExists(datasource, "verificationquery") and datasource.verificationquery is not "">
					<cftry>
						<cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
						<cfset stmt = dbcon.createStatement() />
						<cfset rs = stmt.executeQuery(datasource.verificationquery) />
						
						<cfif rs.next()>
							<cfset verified = true />
						</cfif>
						<cfcatch type="any">
							<cfset verified = "Could not verify datasource: #CFCATCH.Message#" />
							<!---
<cfthrow message="Could not verify datasource using driver #datasource.drivername#: #CFCATCH.Message#" 
									type="bluedragon.adminapi.datasource" />
--->
						</cfcatch>
					</cftry>
				<cfelse>
					<cfthrow message="Cannot verify custom JDBC driver datasources without a verification query. Please add a verification query to this datasource and try again." 
							type="bluedragon.adminapi.datasource" />
				</cfif>
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn verified />
	</cffunction>
	
	<!--- Create or update the datasource --->
	<cffunction name="setDatasource" access="public" output="false" returntype="void" 
			hint="Creates or updates a datasource">
		<cfargument name="name" type="string" required="true" hint="OpenBD Datasource Name" />
		<cfargument name="databasename" type="string" required="false" default="" hint="Database name on the database server" />
		<cfargument name="server" type="string" required="false" default="" hint="Database server host name or IP address" />
		<cfargument name="port"	type="numeric" required="false" default="0" hint="Port that is used to access the database server" />
		<cfargument name="username" type="string" required="false" default="" hint="Database username" />
		<cfargument name="password" type="string" required="false" default="" hint="Database password" />
		<cfargument name="hoststring" type="string" required="false" default="" 
				hint="JDBC URL for 'other' database types. Databasename, server, and port arguments are ignored if a hoststring is provided." />
		<cfargument name="filepath" type="string" required="false" default="" hint="File path for file-based databases (H2, etc.)" />
		<cfargument name="description" type="string" required="false" default="" hint="A description of this data source" />
		<cfargument name="connectstring" type="string" required="false" default="" hint="Additional connection information" />
		<cfargument name="initstring" type="string" required="false" default="" hint="Additional initialization settings" />
		<cfargument name="connectiontimeout" type="numeric" required="false" default="120" 
				hint="Number of seconds OpenBD maintains an unused connection before it is destroyed" />
		<cfargument name="connectionretries" type="numeric" required="false" default="0" hint="Number of connection retry attempts to make" />
		<cfargument name="logintimeout" type="numeric" required="false" default="120" 
				hint="Number of seconds before OpenBD times out the data source connection login attempt" />
		<cfargument name="maxconnections" type="numeric" required="false" default="3" hint="Maximum number of simultaneous database connections" />
		<cfargument name="perrequestconnections" type="boolean" required="false" default="false" 
				hint="Indication of whether or not to pool connections" />
		<cfargument name="sqlselect" type="boolean" required="false" default="true" hint="Allow SQL SELECT statements from this datasource" />
		<cfargument name="sqlinsert" type="boolean" required="false" default="true" hint="Allow SQL INSERT statements from this datasource" />
		<cfargument name="sqlupdate" type="boolean" required="false" default="true" hint="Allow SQL UPDATE statements from this datasource" />
		<cfargument name="sqldelete" type="boolean" required="false" default="true" hint="Allow SQL DELETE statements from this datasource" />
		<cfargument name="sqlstoredprocedures" type="boolean" required="false" default="true" hint="Allow SQL stored procedure calls from this datasource" />
		<cfargument name="drivername" type="string" required="false" default="" hint="JDBC driver class to use" />
		<cfargument name="action" type="string" required="false" default="create" hint="Action to take on the datasource (create or update)" />
		<cfargument name="existingDatasourceName" type="string" required="false" default="" 
				hint="The existing (old) datasource name so we know what to delete if this is an update" />
		<cfargument name="cacheResultSetMetadata" type="boolean" required="false" default="false" hint="MySQL specific setting" />
		<cfargument name="verificationQuery" type="string" required="false" default="" hint="Custom verification query for 'other' driver types" />
		<cfargument name="h2Mode" type="string" required="false" default="" hint="Compatibility mode for H2 database" />
		<cfargument name="h2IgnoreCase" type="boolean" required="false" default="true" hint="Boolean indicating whether or not H2 ignores case" />
		
		<cfset var localConfig = getConfig() />
		<cfset var defaultSettings = structNew() />
		<cfset var datasourceSettings = structNew() />
		<cfset var driver = 0 />
		<cfset var datasourceVerified = false />
		
		<!--- make sure configuration structure exists, otherwise build it --->
		<cfif (NOT StructKeyExists(localConfig, "cfquery")) OR (NOT StructKeyExists(localConfig.cfquery, "datasource"))>
			<cfset localConfig.cfquery.datasource = ArrayNew(1) />
		</cfif>
		
		<!--- if the datasource already exists and this isn't an update, throw an error --->
		<cfif arguments.action is "create" and datasourceExists(arguments.name)>
			<cfthrow message="The datasource already exists" type="bluedragon.adminapi.datasource" />
		</cfif>
		
		<!--- if this is an update, delete the existing datasource --->
		<cfif arguments.action is "update">
			<cfset deleteDatasource(arguments.existingDatasourceName) />
			<cfset localConfig = getConfig() />
			
			<!--- if we're editing the only remaining datasource, need to recreate the datasource struture --->
			<cfif NOT StructKeyExists(localConfig, "cfquery") OR NOT StructKeyExists(localConfig.cfquery, "datasource")>
				<cfset localConfig.cfquery.datasource = ArrayNew(1) />
			</cfif>
		</cfif>
		
		<cfif arguments.hoststring is "">
			<!--- if we don't have a port, use the defaults for the database type --->
			<cfif arguments.port eq 0>
				<cfset defaultSettings = getDriverInfo(arguments.drivername) />
				
				<cfif structKeyExists(defaultSettings, "port")>
					<cfset arguments.port = defaultSettings.port />
				</cfif>
			</cfif>
	
			<cfset datasourceSettings.hoststring = formatJDBCURL(trim(arguments.drivername), trim(arguments.server), 
																trim(arguments.port), trim(arguments.databasename), arguments.connectstring, 
																arguments.filepath, trim(arguments.username), trim(arguments.password), 
																arguments.cacheResultSetMetadata, arguments.h2Mode, arguments.h2IgnoreCase) />
		<cfelse>
			<cfset arguments.port = "" />
			<cfset datasourceSettings.hoststring = trim(arguments.hoststring) />
			
			<cfif trim(arguments.connectstring) is not "">
				<cfset datasourceSettings.hoststring = datasourceSettings.hoststring & trim(arguments.connectstring) />
			</cfif>
			
			<cfset datasourceSettings.verificationquery = trim(arguments.verificationQuery) />
		</cfif>
		
		<!--- build up the universal datasource settings (even though some of these aren't used for file-based databases) --->
		<cfscript>
			datasourceSettings.name = trim(lcase(arguments.name));
			datasourceSettings.displayname = arguments.name;
			datasourceSettings.databasename = trim(arguments.databasename);
			datasourceSettings.server = trim(arguments.server);
			datasourceSettings.port = trim(ToString(arguments.port));
			datasourceSettings.username = trim(arguments.username);
			datasourceSettings.password = trim(arguments.password);
			datasourceSettings.description = trim(arguments.description);
			datasourceSettings.drivername = trim(arguments.drivername);
			datasourceSettings.connectstring = trim(arguments.connectstring);
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
			
			// prepend the new datasource to the localconfig array
			arrayPrepend(localConfig.cfquery.datasource, structCopy(datasourceSettings));
			
			// update the config
			setConfig(localConfig);
		</cfscript>
		
	</cffunction>
	
	
	
	<cffunction name="registerDriver" access="private" output="false" returntype="boolean" 
			hint="Registers a driver class to make sure it exists and is available in the classpath">
		<cfargument name="class" type="string" required="true" hint="JDBC class name" />
	
		<cfset var javaClass = "" />
		<cfset var registerJDBCDriver = "" />
		
		<cftry>
			<cfset registerJDBCDriver = createObject("java", "java.lang.Class").forName(arguments.class) />
			
			<cfcatch type="any">
				<cfthrow message="Could not register database driver #arguments.class#. Please make sure this driver is in your classpath." 
						type="bluedragon.adminapi.datasource" />
			</cfcatch>
		</cftry>

		<cfreturn true />
	</cffunction>
	
	<cffunction name="deleteDatasource" access="public" output="false" returntype="void" 
			hint="Delete the specified data source">
		<cfargument name="dsn" required="true" type="string" hint="The name of the data source to be deleted" />
		
		<cfset var localConfig = getConfig() />
		<cfset var dsnIndex = 0 />

		<!--- Make sure there are datasources --->
		<cfif (NOT StructKeyExists(localConfig, "cfquery")) OR (NOT StructKeyExists(localConfig.cfquery, "datasource"))>
			<cfthrow message="No datasources defined" type="bluedragon.adminapi.datasource" />		
		</cfif>

		<cfloop index="dsnIndex" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
			<cfif localConfig.cfquery.datasource[dsnIndex].name EQ arguments.dsn>
				<cfset ArrayDeleteAt(localConfig.cfquery.datasource, dsnIndex) />
				<cfset setConfig(localConfig) />
				<cfreturn />
			</cfif>
		</cfloop>
		
		<cfthrow message="#arguments.dsn# not registered as a datasource" type="bluedragon.adminapi.datasource" />
	</cffunction>
	
	<cffunction name="setConfig" access="package" output="false" returntype="void" 
			hint="Sets the server configuration and tells OpenBD to refresh its settings">
		<cfargument name="currentConfig" type="struct" required="true" 
				hint="The configuration struct, which is a struct representation of bluedragon.xml" />
		
		<cfset var admin = structNew() />
		<cfset var xmlConfig = "" />
		<cfset var success = false />
		
		<cflock scope="Server" type="exclusive" timeout="5">
			<cfset admin.server = duplicate(arguments.currentConfig) />
			<cfset admin.server.openbdadminapi.lastupdated = DateFormat(now(), "dd/mmm/yyyy") & " " & TimeFormat(now(), "HH:mm:ss") />
			<cfset admin.server.openbdadminapi.version = api.version />
			
			<cfset xmlConfig = createObject("java", "com.naryx.tagfusion.xmlConfig.xmlCFML").init(admin) />
			<cfset success = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").writeXmlFile(xmlConfig) />
		</cflock>
	</cffunction>
	
	<cffunction name="formatJDBCURL" access="private" output="false" returntype="string" 
			hint="Formats a JDBC URL for a specific database driver type">
		<cfargument name="drivername" type="string" required="true" hint="The name of the database driver class" />
		<cfargument name="server" type="string" required="true" hint="The database server name or IP address" />
		<cfargument name="port" type="numeric" required="true" hint="The database server port" />
		<cfargument name="database" type="string" required="true" hint="The database name" />
		<cfargument name="connectstring" type="string" required="false" hint="Additional conncetion information" />
		<cfargument name="filepath" type="string" required="false" default="" hint="The file path for a file-based database" />
		<cfargument name="username" type="string" required="false" default="" 
				hint="Database user name if one is to be included as part of the connection string. Mostly used for file-based databases." />
		<cfargument name="password" type="string" required="false" default="" 
				hint="Database password if one is to be included as part of the connection string. Mostly used for file-based databases." />
		<cfargument name="cacheResultSetMetadata" type="boolean" required="false" default="false" hint="MySQL specific setting" />
		<cfargument name="h2Mode" type="string" required="false" default="" hint="Compatibility mode for H2" />
		<cfargument name="h2IgnoreCase" type="boolean" required="false" default="true" 
				hint="Boolean indicating whether or not H2 should ignore case" />
		
		<cfset var jdbcURL = "" />
		
		<cfswitch expression="#arguments.drivername#">
			<!--- h2 embedded --->
			<cfcase value="org.h2.Driver">
				<!--- if the filepath is "" then use the default, and create it if it doesn't exist --->
				<cfif arguments.filepath is "">
					<cfif variables.isMultiContextJetty>
						<cfset arguments.filepath = 
								"#getJVMProperty('jetty.home')##variables.separator.file#etc#variables.separator.file#openbd#variables.separator.file#h2databases" />
					<cfelse>
						<cfset arguments.filepath = expandPath("/db") />
					</cfif>
					
					<cfif not directoryExists(arguments.filepath)>
						<cfdirectory action="create" directory="#arguments.filepath#" />
					</cfif>
				<cfelse>
					<!--- make sure the directory provided exists and throw an error if it doesn't; 
							probably best not to create it automatically in case it was just a typo, etc. --->
					<cfif not directoryExists(arguments.filepath)>
						<cfthrow message="The file path provided does not exist" type="bluedragon.adminapi.datasource" />
					</cfif>
				</cfif>

				<cfif right(arguments.filepath, 1) is "/" or right(arguments.filepath, 1) is "\">
					<cfset arguments.filepath = left(arguments.filepath, len(arguments.filepath) - 1) />
				</cfif>

				<!--- url format: jdbc:h2:/path_to_database;AUTO_SERVER=TRUE ... --->
				<!--- note that AUTO_SERVER=TRUE is necessary in order for the embedded database to respond to multiple threads --->
				<cfset jdbcURL = "jdbc:h2:#arguments.filepath##getFileSeparator()##arguments.database#;IGNORECASE=#arguments.h2IgnoreCase#" />
				
				<cfif arguments.h2Mode is not "H2Native">
					<cfset jdbcURL = jdbcURL & ";MODE=#arguments.h2Mode#" />
				</cfif>
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & ";" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- sql server -- microsoft driver --->
			<cfcase value="com.microsoft.sqlserver.jdbc.SQLServerDriver">
				<!--- url format: jdbc:sqlserver://[serverName[\instanceName][:portNumber]][;property=value[;property=value]] --->
				<cfset jdbcURL = "jdbc:sqlserver://#arguments.server#:#arguments.port#;databaseName=#arguments.database#" />
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & ";" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- sql server -- jtds driver --->
			<cfcase value="net.sourceforge.jtds.jdbc.Driver">
				<!--- url format: jdbc:jtds:<server_type>://<server>[:<port>][/<database>][;<property>=<value>[;...]] --->
				<cfset jdbcURL = "jdbc:jtds:sqlserver://#arguments.server#:#arguments.port#/#arguments.database#" />
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & ";" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- mysql --->
			<cfcase value="com.mysql.jdbc.Driver">
				<!--- url format: jdbc:mysql://[host][,failoverhost...][:port]/[database][?propertyName1][=propertyValue1][&propertyName2][=propertyValue2] --->
				<cfset jdbcURL = "jdbc:mysql://#arguments.server#:#arguments.port#/#arguments.database#?cacheResultSetMetadata=#arguments.cacheResultSetMetadata#&autoReconnect=true&useEncoding=true&characterEncoding=UTF-8" />
				
				<cfif arguments.connectstring is not "">
					<cfset jdbcURL = jdbcURL & "&" & arguments.connectstring />
				</cfif>
			</cfcase>
			
			<!--- oracle --->
			<cfcase value="oracle.jdbc.OracleDriver">
				<!--- url format: jdbc:oracle:thin:@server:port:SID --->
				<cfset jdbcURL = "jdbc:oracle:thin:@#arguments.server#:#arguments.port#:#arguments.database#" />
			</cfcase>
			
			<!--- postgres --->
			<cfcase value="org.postgresql.Driver">
				<!--- url format: jdbc:postgresql://host:port/database --->
				<cfset jdbcURL = "jdbc:postgresql://#arguments.server#:#arguments.port#/#arguments.database#" />
			</cfcase>
			
			<cfdefaultcase>
				<cfthrow message="Cannot format a JDBC URL for unknown driver types" type="bluedragon.adminapi.datasource" />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn jdbcURL />
	</cffunction>
	
	<cffunction name="datasourceExists" access="public" output="false" returntype="boolean" 
				hint="Returns a boolean indicating whether or not a datasource with the specified name exists">
		<cfargument name="dsn" type="string" required="true" hint="The datasource name to check" />
		
		<cfset var dsnExists = true />
		<cfset var localConfig = getConfig() />
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
	
	<cffunction name="getDriverInfo" access="public" output="false" returntype="struct" 
			hint="Returns a struct containing the information for a particular driver. Currently this is pulled by the driver config page but this can be expanded to get the driver info by other attributes.">
		<cfargument name="datasourceconfigpage" type="string" required="false" default="" />
		<cfargument name="drivername" type="string" required="false" default="" />
		
		<cfset var dbdrivers = getConfig().cfquery.dbdrivers.driver />
		<cfset var driverInfo = structNew() />
		<cfset var i = 0 />
		
		<cfif arguments.datasourceconfigpage is not "">
			<cfloop index="i" from="1" to="#arrayLen(dbdrivers)#" step="1">
				<cfif dbdrivers[i].datasourceconfigpage is arguments.datasourceconfigpage>
					<cfset driverInfo = dbdrivers[i] />
					<cfbreak />
				</cfif>
			</cfloop>
		<cfelseif arguments.drivername is not "">
			<cfloop index="i" from="1" to="#arrayLen(dbdrivers)#" step="1">
				<cfif dbdrivers[i].drivername is arguments.drivername>
					<cfset driverInfo = dbdrivers[i] />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn driverInfo />
	</cffunction>
	
	<cffunction name="getFileSeparator" access="public" output="false" returntype="string" 
			hint="Returns the platform-specific file separator">
		<cfreturn getJVMProperty("file.separator") />
	</cffunction>
	
	<cffunction name="getJVMProperty" access="public" output="false" returntype="any" 
			hint="Retrieves a specific JVM property">
		<cfargument name="propertyName" type="string" required="true" hint="The JVM property to return" />
		
		<cfreturn createObject("java", "java.lang.System").getProperty(arguments.propertyName) />
	</cffunction>

	<cffunction name="getJVMProperties" access="public" output="false" returntype="struct" 
			hint="Returns a struct containing the JVM properties">
		<cfreturn createObject("java", "java.lang.System").getProperties() />
	</cffunction>
	
</cfcomponent>