<cfcomponent output="false">
	
	<!--- Application name, should be unique --->
	<cfset this.name = "errorlog">
	<!--- How long application vars persist --->
	<cfset this.applicationTimeout = createTimeSpan(0,2,0,0)>
	<!--- Should we even use sessions? --->
	<cfset this.sessionManagement = true>
	<!--- How long do session vars persist? --->
	<cfset this.sessionTimeout = createTimeSpan(0,0,20,0)>
	<!--- Where should cflogin stuff persist --->
	<cfset this.loginStorage = "session">
	<!--- Should client vars be enabled? --->
	<cfset this.clientManagement = false>
	<!--- Should we set cookies on the browser? --->
	<cfset this.setClientCookies = false>
	<!--- Where should we store them, if enable? (cookie|registry|datasource) --->
	<cfset this.clientStorage = "cookie">
	<!--- should cookies be domain specific, ie, *.foo.com or www.foo.com --->
	<cfset this.setDomainCookies = false>
	<!--- should we try to block 'bad' input from users --->
	<cfset this.scriptProtect = "none">
	<!--- should we secure our JSON calls? --->
	<cfset this.secureJSON = false>
	
	<!--- Run when application starts up --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		<cfreturn true>
	</cffunction>

	<!--- Run when application stops --->
	<cffunction name="onApplicationEnd" returnType="void" output="false">
		<cfargument name="applicationScope" required="true">
	</cffunction>
	
	<!--- Run before the request is processed --->
	<cffunction name="onRequestStart" returnType="boolean" output="false">
		<cfargument name="thePage" type="string" required="true">
		<cfreturn true>
	</cffunction>

	<!--- Runs at end of request --->
	<cffunction name="onRequestEnd" returnType="void" output="false">
		<cfargument name="thePage" type="string" required="true">
	</cffunction>

	<!--- Runs when your session starts --->
	<cffunction name="onSessionStart" returnType="void" output="false">
		<!--- Get information about user database from user configuration stored in razuna_default H2 databse --->
		<cfquery datasource="razuna_default" name="conf" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
			select conf_database, conf_datasource, conf_storage
			from razuna_config
		</cfquery>
		<!--- Get hosts information from user database --->
		<cfquery datasource="#conf.conf_datasource#" name="hosts" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
			select host_id, host_shard_group
			from hosts
			WHERE ( host_shard_group IS NOT NULL OR host_shard_group <cfif conf.conf_database EQ "oracle" OR conf.conf_database EQ "db2"><><cfelse>!=</cfif> '' )
		</cfquery>
		<cfset session.datasource = conf.conf_datasource>
		<cfset session.shard_group = "#hosts.host_shard_group#"> 
	</cffunction>

	<!--- Runs when session ends --->
	<cffunction name="onSessionEnd" returnType="void" output="false">
		<cfargument name="sessionScope" type="struct" required="true">
		<cfargument name="appScope" type="struct" required="false">
	</cffunction>

	<!--- Runs on error --->
	<cffunction name="onError" returnType="void" output="false">
		<cfargument name="exception" required="true">
		<cfargument name="eventname" type="string" required="true">
		<cfdump var="#arguments#"><cfabort>
	</cffunction>

	<!--- Fired when user requests a CFM that doesn't exist. --->
	<cffunction name="onMissingTemplate" returnType="boolean" output="false">
		<cfargument name="targetpage" required="true" type="string">
		<cfreturn true>
	</cffunction>

</cfcomponent>