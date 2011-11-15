<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    David C. Epler - dcepler@dcepler.net
    Matt Woodward - matt@mattwoodward.com

    This file is part of the Open BlueDragon Admin API.

    The Open BlueDragon Admin API is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Admin API is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Admin API.  If not, see 
    <http://www.gnu.org/licenses/>.
    --->
<cfcomponent displayname="Datasource" 
	     output="false" 
	     extends="Base" 
	     hint="Manages datasources - OpenBD Admin API">
  
  <!--- PUBLIC METHODS --->
  <cffunction name="setDatasource" access="public" output="false" returntype="void" 
	      hint="Creates or updates a datasource">
    <cfargument name="name" type="string" required="true" hint="OpenBD Datasource Name" />
    <cfargument name="databasename" type="string" required="false" default="" hint="Database name on the database server" />
    <cfargument name="server" type="string" required="false" default="" hint="Database server host name or IP address" />
    <cfargument name="port" type="numeric" required="false" default="0" hint="Port that is used to access the database server" />
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
    <cfset var defaultSettings = {} />
    <cfset var datasourceSettings = {} />
    <cfset var driver = 0 />
    <cfset var datasourceVerified = false />

    <cfset checkLoginStatus() />
    
    <!--- make sure configuration structure exists, otherwise build it --->
    <cfif !StructKeyExists(localConfig, "cfquery") || !StructKeyExists(localConfig.cfquery, "datasource")>
      <cfset localConfig.cfquery.datasource = [] />
    </cfif>
    
    <!--- register the driver--this will tell us whether or not openbd can hit the driver --->
    <cftry>
      <cfset registerDriver(arguments.drivername) />
      <cfcatch type="bluedragon.adminapi.datasource">
	<cfrethrow />
      </cfcatch>
    </cftry>
    
    <!--- if the datasource already exists and this isn't an update, throw an error --->
    <cfif arguments.action == "create" && datasourceExists(arguments.name)>
      <cfthrow message="The datasource already exists" type="bluedragon.adminapi.datasource" />
    </cfif>
    
    <!--- if this is an update, delete the existing datasource --->
    <cfif arguments.action == "update">
      <cfset deleteDatasource(arguments.existingDatasourceName) />
      <cfset localConfig = getConfig() />
      
      <!--- if we're editing the only remaining datasource, need to recreate the datasource struture --->
      <cfif !StructKeyExists(localConfig, "cfquery") || !StructKeyExists(localConfig.cfquery, "datasource")>
	<cfset localConfig.cfquery.datasource = [] />
      </cfif>
    </cfif>
    
    <cfif arguments.hoststring == "">
      <!--- if we don't have a port, use the defaults for the database type --->
      <cfif arguments.port == 0>
	<cfset defaultSettings = getDriverInfo(arguments.drivername) />
	
	<cfif StructKeyExists(defaultSettings, "port")>
	  <cfset arguments.port = defaultSettings.port />
	</cfif>
      </cfif>
      
      <cfset datasourceSettings.hoststring = formatJDBCURL(Trim(arguments.drivername), Trim(arguments.server), 
	     Trim(arguments.port), Trim(arguments.databasename), arguments.connectstring, 
	     arguments.filepath, Trim(arguments.username), Trim(arguments.password), 
	     arguments.cacheResultSetMetadata, arguments.h2Mode, arguments.h2IgnoreCase) />
      <cfelse>
	<cfset arguments.port = "" />
	<cfset datasourceSettings.hoststring = Trim(arguments.hoststring) />
	
	<cfif Trim(arguments.connectstring) != "">
	  <cfset datasourceSettings.hoststring &= Trim(arguments.connectstring) />
	</cfif>
	
	<cfset datasourceSettings.verificationquery = Trim(arguments.verificationQuery) />
    </cfif>
    
    <!--- build up the universal datasource settings (even though some of these aren't used for file-based databases) --->
    <cfscript>
      datasourceSettings.name = Trim(lcase(arguments.name));
      datasourceSettings.displayname = arguments.name;
      datasourceSettings.databasename = Trim(arguments.databasename);
      datasourceSettings.server = Trim(arguments.server);
      datasourceSettings.port = Trim(ToString(arguments.port));
      datasourceSettings.username = Trim(arguments.username);
      datasourceSettings.password = Trim(arguments.password);
      datasourceSettings.description = Trim(arguments.description);
      datasourceSettings.drivername = Trim(arguments.drivername);
      datasourceSettings.connectstring = Trim(arguments.connectstring);
      datasourceSettings.initstring = Trim(arguments.initstring);
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
      ArrayPrepend(localConfig.cfquery.datasource, StructCopy(datasourceSettings));
      
      // update the config
      setConfig(localConfig);
    </cfscript>
    
    <cftry>
      <cfset datasourceVerified = verifyDatasource(Trim(arguments.name)) />
      <cfcatch type="any">
	<cfrethrow />
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="getDatasources" access="public" output="false" returntype="array" 
	      hint="Returns an array containing all the data sources or a specified data source">
    <cfargument name="dsn" type="string" required="false" default="" hint="The name of the datasource to return" />
    
    <cfset var localConfig = getConfig() />
    <cfset var returnArray = "" />
    <cfset var dsnIndex = "" />
    <cfset var sortKeys = [] />
    <cfset var sortKey = {} />

    <cfset checkLoginStatus() />
    
    <!--- Make sure there are datasources --->
    <cfif !StructKeyExists(localConfig, "cfquery") || !StructKeyExists(localConfig.cfquery, "datasource")>
      <cfthrow message="No registered datasources" type="bluedragon.adminapi.datasource" />
    </cfif>
    
    <!--- Return entire data source array, unless a data source name is specified --->
    <cfif !StructKeyExists(arguments, "dsn") || arguments.dsn == "">
      <!--- set the sorting information --->
      <cfset sortKey.keyName = "name" />
      <cfset sortKey.sortOrder = "ascending" />
      <cfset ArrayAppend(sortKeys, sortKey) />
      
      <cfreturn variables.udfs.sortArrayOfObjects(localConfig.cfquery.datasource, sortKeys, false, false) />
      <cfelse>
	<cfset returnArray = [] />
	<cfloop index="dsnIndex" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
	  <cfif localConfig.cfquery.datasource[dsnIndex].name == arguments.dsn>
	    <cfset returnArray[1] = Duplicate(localConfig.cfquery.datasource[dsnIndex]) />
	    <cfreturn returnArray />
	  </cfif>
	</cfloop>
	<cfthrow message="#arguments.dsn# not registered as a datasource" type="bluedragon.adminapi.datasource" />
    </cfif>
  </cffunction>
  
  <cffunction name="datasourceExists" access="public" output="false" returntype="boolean" 
	      hint="Returns a boolean indicating whether or not a datasource with the specified name exists">
    <cfargument name="dsn" type="string" required="true" hint="The datasource name to check" />
    
    <cfset var dsnExists = true />
    <cfset var localConfig = getConfig() />
    <cfset var i = 0 />

    <cfset checkLoginStatus() />
    
    <cfif !StructKeyExists(localConfig, "cfquery") || !StructKeyExists(localConfig.cfquery, "datasource")>
      <!--- no datasources at all, so this one doesn't exist ---->
      <cfset dsnExists = false />
      <cfelse>
	<cfloop index="i" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
	  <cfif localConfig.cfquery.datasource[i].name == arguments.dsn>
	    <cfset dsnExists = true />
	    <cfbreak />
	    <cfelse>
	      <cfset dsnExists = false />
	  </cfif>
	</cfloop>
    </cfif>
    
    <cfreturn dsnExists />
  </cffunction>
  
  <cffunction name="deleteDatasource" access="public" output="false" returntype="void" 
	      hint="Delete the specified data source">
    <cfargument name="dsn" required="true" type="string" hint="The name of the data source to be deleted" />
    
    <cfset var localConfig = getConfig() />
    <cfset var dsnIndex = 0 />

    <cfset checkLoginStatus() />

    <!--- Make sure there are datasources --->
    <cfif !StructKeyExists(localConfig, "cfquery") || !StructKeyExists(localConfig.cfquery, "datasource")>
      <cfthrow message="No datasources defined" type="bluedragon.adminapi.datasource" />		
    </cfif>

    <cfloop index="dsnIndex" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
      <cfif localConfig.cfquery.datasource[dsnIndex].name == arguments.dsn>
	<cfset ArrayDeleteAt(localConfig.cfquery.datasource, dsnIndex) />
	<cfset setConfig(localConfig) />
	<cfreturn />
      </cfif>
    </cfloop>
    
    <cfthrow message="#arguments.dsn# not registered as a datasource" type="bluedragon.adminapi.datasource" />
  </cffunction>
  
  <cffunction name="getRegisteredDrivers" access="public" output="false" returntype="array" 
	      hint="Returns an array containing all the database drivers that are 'known' to OpenBD. If the node doesn't exist in the XML it is created and populated with the standard driver information. Note this does not guarantee the user will have the drivers installed in their classpath but an error will be thrown if they try to add a datasource that uses a driver that is not in the classpath.">
    <cfargument name="resetDrivers" type="boolean" required="false" default="false" />
    
    <cfset var localConfig = getConfig() />
    <cfset var dbDriverInfo = {} />
    <cfset var sortKeys = arrayNew(1) />
    <cfset var sortKey = {} />

    <cfset checkLoginStatus() />
    
    <cfif !StructKeyExists(localConfig, "cfquery")>
      <cfset localConfig.cfquery = {} />
    </cfif>
    
    <cfif arguments.resetDrivers>
      <cfif StructKeyExists(localConfig.cfquery, "dbdrivers")>
	<cfset StructDelete(localConfig.cfquery, "dbdrivers", false) />
      </cfif>
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfquery, "dbdrivers")>
      <!--- add the dbdrivers node with the default drivers that should be shipping with OpenBD --->
      <cfscript>
	localConfig.cfquery.dbdrivers = {};
	localConfig.cfquery.dbdrivers.driver = [];
	
	// h2 (provider: h2)
	dbDriverInfo.name = "h2 embedded (h2)";
	dbDriverInfo.datasourceconfigpage = "h2-embedded.cfm";
	dbDriverInfo.version = "1.2.134";
	dbDriverInfo.drivername = "org.h2.Driver";
	dbDriverInfo.driverdescription = "H2 Embedded (H2)";
	dbDriverInfo.jdbctype = "4";
	dbDriverInfo.provider = "H2";
	dbDriverInfo.defaultport = "";
	
	ArrayAppend(localConfig.cfquery.dbdrivers.driver, StructCopy(dbDriverInfo));
	
	// mysql (provider: mysql)
	dbDriverInfo.name = "mysql 4/5";
	dbDriverInfo.datasourceconfigpage = "mysql5.cfm";
	dbDriverInfo.version = "5.1.12";
	dbDriverInfo.drivername = "com.mysql.jdbc.Driver";
	dbDriverInfo.driverdescription = "MySQL 4/5 (MySQL)";
	dbDriverInfo.jdbctype = "4";
	dbDriverInfo.provider = "MySQL";
	dbDriverInfo.defaultport = "3306";
	
	ArrayAppend(localConfig.cfquery.dbdrivers.driver, StructCopy(dbDriverInfo));
	
	// mssql (provider: ms)
	dbDriverInfo.name = "microsoft sql server (microsoft)";
	dbDriverInfo.datasourceconfigpage = "sqlserver-ms.cfm";
	dbDriverInfo.version = "2.0";
	dbDriverInfo.drivername = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
	dbDriverInfo.driverdescription = "Microsoft SQL Server (Microsoft)";
	dbDriverInfo.jdbctype = "4";
	dbDriverInfo.provider = "Microsoft";
	dbDriverInfo.defaultport = "1433";
	
	ArrayAppend(localConfig.cfquery.dbdrivers.driver, StructCopy(dbDriverInfo));
	
	// mssql (provider: jtds)
	dbDriverInfo.name = "microsoft sql server (jtds)";
	dbDriverInfo.datasourceconfigpage = "sqlserver-jtds.cfm";
	dbDriverInfo.version = "1.2.5";
	dbDriverInfo.drivername = "net.sourceforge.jtds.jdbc.Driver";
	dbDriverInfo.driverdescription = "Microsoft SQL Server (jTDS)";
	dbDriverInfo.jdbctype = "4";
	dbDriverInfo.provider = "jTDS";
	dbDriverInfo.defaultport = "1433";
	
	ArrayAppend(localConfig.cfquery.dbdrivers.driver, StructCopy(dbDriverInfo));
	
	// postgresql (provider: postgres)
	dbDriverInfo.name = "postgresql (postgresql)";
	dbDriverInfo.datasourceconfigpage = "postgresql.cfm";
	dbDriverInfo.version = "8.4-701";
	dbDriverInfo.drivername = "org.postgresql.Driver";
	dbDriverInfo.driverdescription = "PostgreSQL (PostgreSQL)";
	dbDriverInfo.jdbctype = "4";
	dbDriverInfo.provider = "PostgreSQL";
	dbDriverInfo.defaultport = "5432";
	
	ArrayAppend(localConfig.cfquery.dbdrivers.driver, StructCopy(dbDriverInfo));
	
	// oracle (provider: oracle)
	dbDriverInfo.name = "oracle (oracle)";
	dbDriverInfo.datasourceconfigpage = "oracle.cfm";
	dbDriverInfo.version = "10.2.0.4";
	dbDriverInfo.drivername = "oracle.jdbc.OracleDriver";
	dbDriverInfo.driverdescription = "Oracle (Oracle)";
	dbDriverInfo.jdbctype = "4";
	dbDriverInfo.provider = "Oracle";
	dbDriverInfo.defaultport = "1521";
	
	ArrayAppend(localConfig.cfquery.dbdrivers.driver, StructCopy(dbDriverInfo));
	
	// "other" (user-configured jdbc)
	dbDriverInfo.name = "other";
	dbDriverInfo.datasourceconfigpage = "other.cfm";
	dbDriverInfo.version = "";
	dbDriverInfo.drivername = "";
	dbDriverInfo.driverdescription = "Other JDBC Driver";
	dbDriverInfo.jdbctype = "";
	dbDriverInfo.provider = "";
	dbDriverInfo.defaultport = "";
	
	ArrayAppend(localConfig.cfquery.dbdrivers.driver, StructCopy(dbDriverInfo));
	
	setConfig(localConfig);
      </cfscript>
    </cfif>
    
    <!--- set the sorting information --->
    <cfset sortKey.keyName = "driverdescription" />
    <cfset sortKey.sortOrder = "ascending" />
    <cfset ArrayAppend(sortKeys, sortKey) />

    <cfreturn variables.udfs.sortArrayOfObjects(getConfig().cfquery.dbdrivers.driver, sortKeys, false, false) />
  </cffunction>
  
  <cffunction name="getDriverInfo" access="public" output="false" returntype="struct" 
	      hint="Returns a struct containing the information for a particular driver. Currently this is pulled by the driver config page but this can be expanded to get the driver info by other attributes.">
    <cfargument name="datasourceconfigpage" type="string" required="false" default="" />
    <cfargument name="drivername" type="string" required="false" default="" />
    
    <cfset var dbdrivers = getConfig().cfquery.dbdrivers.driver />
    <cfset var driverInfo = {} />
    <cfset var i = 0 />

    <cfset checkLoginStatus() />
    
    <cfif arguments.datasourceconfigpage != "">
      <cfloop index="i" from="1" to="#ArrayLen(dbdrivers)#" step="1">
	<cfif dbdrivers[i].datasourceconfigpage == arguments.datasourceconfigpage>
	  <cfset driverInfo = dbdrivers[i] />
	  <cfbreak />
	</cfif>
      </cfloop>
      <cfelseif arguments.drivername != "">
	<cfloop index="i" from="1" to="#ArrayLen(dbdrivers)#" step="1">
	  <cfif dbdrivers[i].drivername == arguments.drivername>
	    <cfset driverInfo = dbdrivers[i] />
	    <cfbreak />
	  </cfif>
	</cfloop>
    </cfif>
    
    <cfreturn driverInfo />
  </cffunction>
  
  <cffunction name="verifyDatasource" access="public" output="false" returntype="boolean" 
	      hint="Verifies a datasource">
    <cfargument name="dsn" type="string" required="true" hint="Datasource name to verify" />
    
    <cfset var verified = false />
    <cfset var datasource = getDatasources(arguments.dsn).get(0) />
    <cfset var driverManager = CreateObject("java", "java.sql.DriverManager") />
    <cfset var dbcon = 0 />
    <cfset var stmt = 0 />
    <cfset var rs = 0 />

    <cfset checkLoginStatus() />
    
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
	    <cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
		     type="bluedragon.adminapi.datasource" />
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
	    <cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
		     type="bluedragon.adminapi.datasource" />
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
	    <cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
		     type="bluedragon.adminapi.datasource" />
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
	    <cfthrow message="Could not verify datasource: #CFCATCH.Message#" 
		     type="bluedragon.adminapi.datasource" />
	  </cfcatch>
	</cftry>
      </cfcase>
      
      <!--- 'other' database types --->
      <cfdefaultcase>
	<!---try to use the custom verification query; otherwise throw an error --->
	<cfif StructKeyExists(datasource, "verificationquery") && datasource.verificationquery != "">
	  <cftry>
	    <cfset dbcon = driverManager.getConnection(datasource.hoststring, datasource.username, datasource.password) />
	    <cfset stmt = dbcon.createStatement() />
	    <cfset rs = stmt.executeQuery(datasource.verificationquery) />
	    
	    <cfif rs.next()>
	      <cfset verified = true />
	    </cfif>
	    <cfcatch type="any">
	      <cfthrow message="Could not verify datasource using driver #datasource.drivername#: #CFCATCH.Message#" 
		       type="bluedragon.adminapi.datasource" />
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
  
  <cffunction name="getDefaultH2DatabasePath" access="public" output="false" returntype="string" 
	      hint="Returns the default H2 database path">
    <cfset var h2DatabasePath = "" />
    
    <cfset checkLoginStatus() />
    
    <cfif variables.isMultiContextJetty>
      <cfset h2DatabasePath = 
	     "#getJVMProperty('jetty.home')##variables.separator.file#etc#variables.separator.file#openbd#variables.separator.file#h2databases" />
      <cfelse>
	<cfset h2DatabasePath = expandPath("/WEB-INF/bluedragon/h2databases") />
    </cfif>
    
    <cfreturn h2DatabasePath />
  </cffunction>
  
  <cffunction name="setAutoConfigODBC" access="public" output="false" returntype="void" 
	      hint="Sets the autoconfig-odbc setting">
    <cfargument name="autoconfigodbc" type="boolean" required="true" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    
    <cfset localConfig.cfquery["autoconfig-odbc"] = ToString(arguments.autoconfigodbc) />
    
    <cfset setConfig(StructCopy(localConfig)) />
  </cffunction>
  
  <cffunction name="getAutoConfigODBC" access="public" output="false" returntype="boolean" 
	      hint="Returns a boolean indicating the setting of autoconfig-odbc in the XML config file">
    <cfset var localConfig = getConfig() />
    <cfset var autoConfigODBC = false />

    <cfset checkLoginStatus() />
    
    <cfif !StructKeyExists(localConfig.cfquery, "autoconfig-odbc")>
      <cfset localConfig.cfquery["autoconfig-odbc"] = "false" />
      <cfset setConfig(structCopy(localConfig)) />
      <cfelse>
	<cfset autoConfigODBC = localConfig.cfquery["autoconfig-odbc"] />
    </cfif>
    
    <cfreturn autoConfigODBC />
  </cffunction>
  
  <cffunction name="refreshODBCDatasources" access="public" output="false" returntype="void" 
	      hint="Refreshes ODBC datasources on Windows">
    <cfset checkLoginStatus() />
    
    <cfset CreateObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").autoConfigOdbcDataSources(true, getAutoConfigODBC()) />
  </cffunction>
  
  <!--- PRIVATE METHODS --->
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

    <cfset checkLoginStatus() />
    
    <cfswitch expression="#arguments.drivername#">
      <!--- h2 embedded --->
      <cfcase value="org.h2.Driver">
	<!--- if the filepath is "" then use the default, and create it if it doesn't exist --->
	<cfif arguments.filepath == "">
	  <cfif variables.isMultiContextJetty>
	    <cfset arguments.filepath = 
		   "#getJVMProperty('jetty.home')##variables.separator.file#etc#variables.separator.file#openbd#variables.separator.file#h2databases" />
	    <cfelse>
	      <cfset arguments.filepath = ExpandPath("/WEB-INF/bluedragon/h2databases") />
	  </cfif>
	  
	  <cfif !DirectoryExists(arguments.filepath)>
	    <cfdirectory action="create" directory="#arguments.filepath#" />
	  </cfif>
	  <cfelse>
	    <!--- make sure the directory provided exists and throw an error if it doesn't; 
		probably best not to create it automatically in case it was just a typo, etc. --->
	    <cfif !DirectoryExists(arguments.filepath)>
	      <cfthrow message="The file path provided does not exist" type="bluedragon.adminapi.datasource" />
	    </cfif>
	</cfif>

	<cfif Right(arguments.filepath, 1) == "/" || Right(arguments.filepath, 1) == "\">
	  <cfset arguments.filepath = Left(arguments.filepath, Len(arguments.filepath) - 1) />
	</cfif>

	<!--- url format: jdbc:h2:/path_to_database;AUTO_SERVER=TRUE ... --->
	<!--- note that AUTO_SERVER=TRUE is necessary in order for the embedded database to respond to multiple threads --->
	<cfset jdbcURL = "jdbc:h2:#arguments.filepath##getFileSeparator()##arguments.database#;AUTO_SERVER=TRUE;IGNORECASE=#arguments.h2IgnoreCase#" />
	
	<cfif arguments.h2Mode != "H2Native">
	  <cfset jdbcURL &= ";MODE=#arguments.h2Mode#" />
	</cfif>
	
	<cfif arguments.connectstring != "">
	  <cfset jdbcURL &= ";" & arguments.connectstring />
	</cfif>
      </cfcase>
      
      <!--- sql server -- microsoft driver --->
      <cfcase value="com.microsoft.sqlserver.jdbc.SQLServerDriver">
	<!--- url format: jdbc:sqlserver://[serverName[\instanceName][:portNumber]][;property=value[;property=value]] --->
	<cfset jdbcURL = "jdbc:sqlserver://#arguments.server#:#arguments.port#;databaseName=#arguments.database#" />
	
	<cfif arguments.connectstring != "">
	  <cfset jdbcURL &= ";" & arguments.connectstring />
	</cfif>
      </cfcase>
      
      <!--- sql server -- jtds driver --->
      <cfcase value="net.sourceforge.jtds.jdbc.Driver">
	<!--- url format: jdbc:jtds:<server_type>://<server>[:<port>][/<database>][;<property>=<value>[;...]] --->
	<cfset jdbcURL = "jdbc:jtds:sqlserver://#arguments.server#:#arguments.port#/#arguments.database#" />
	
	<cfif arguments.connectstring != "">
	  <cfset jdbcURL &= ";" & arguments.connectstring />
	</cfif>
      </cfcase>
      
      <!--- mysql --->
      <cfcase value="com.mysql.jdbc.Driver">
	<!--- url format: jdbc:mysql://[host][,failoverhost...][:port]/[database][?propertyName1][=propertyValue1][&propertyName2][=propertyValue2] --->
	<cfset jdbcURL = "jdbc:mysql://#arguments.server#:#arguments.port#/#arguments.database#?cacheResultSetMetadata=#arguments.cacheResultSetMetadata#&autoReconnect=true" />
	
	<cfif arguments.connectstring != "">
	  <cfset jdbcURL &= "&" & arguments.connectstring />
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
  
  <cffunction name="registerDriver" access="private" output="false" returntype="boolean" 
	      hint="Registers a driver class to make sure it exists and is available in the classpath">
    <cfargument name="class" type="string" required="true" hint="JDBC class name" />
    
    <cfset var javaClass = "" />
    <cfset var registerJDBCDriver = "" />

    <cfset checkLoginStatus() />
    
    <cftry>
      <cfset registerJDBCDriver = CreateObject("java", "java.lang.Class").forName(arguments.class) />
      
      <cfcatch type="any">
	<cfthrow message="Could not register database driver #arguments.class#. Please make sure this driver is in your classpath." 
		 type="bluedragon.adminapi.datasource" />
      </cfcatch>
    </cftry>

    <cfreturn true />
  </cffunction>
</cfcomponent>
