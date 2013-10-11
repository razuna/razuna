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
	<cffunction name="onRequestStart">
		<cfargument name = "request" required="true"/>
		<!--- Get information about user database from user configuration stored in razuna_default H2 databse --->
		<cfquery datasource="razuna_default" name="conf" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
		SELECT conf_database, conf_datasource, conf_storage
		FROM razuna_config
		</cfquery>
		<!--- Get hosts information from user database --->
		<cfquery datasource="#conf.conf_datasource#" name="hosts" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
		SELECT host_id, host_shard_group
		FROM hosts
		WHERE ( host_shard_group IS NOT NULL OR host_shard_group <cfif conf.conf_database EQ "oracle" OR conf.conf_database EQ "db2"><><cfelse>!=</cfif> '' )
		</cfquery>
		<!--- Get database update version, ony version 15 and above are compatible with this applicaiton --->
		<cfquery datasource="#conf.conf_datasource#" name="dbver">
		SELECT opt_value
		FROM options
		WHERE lower(opt_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="dbupdate">
		</cfquery>
		<cfif dbver.opt_value LT 15>
			<cfset session.dbuptodate = false>
		<cfelse>
			<cfset session.dbuptodate = true>
		</cfif>
		<cfset session.dbver = dbver.opt_value>
		<cfset session.datasource = conf.conf_datasource>
		<cfset session.shard_group = "#hosts.host_shard_group#"> 
		<!--- Check if database is up to date. 'Dbupdate' flag in 'options' table must be on version 15 or higher as it contains the err_header column change. --->
		<cfif !session.dbuptodate>
			<h4 style="color:indianred">Database is not up to date. It must be on version 15 or above. It is currently on version <cfoutput>#session.dbver#</cfoutput>.<br>
			Please login to Razuna and update your database.</h4>
			<cfabort>
		</cfif>	
		<!--- Include global styles --->
		<link rel="stylesheet" type="text/css" href="css/styles.css">
	    <!--- Begin authentication code --->
	    <cfif IsDefined("Form.logout")> 
	        <cflogout> 
	    </cfif> 
	 
	    <cflogin> 
	        <cfif NOT IsDefined("cflogin")> 
	            <cfinclude template="loginform.cfm"> 
	            <cfabort> 
	        <cfelse> 
	            <cfif cflogin.name IS "" OR cflogin.password IS ""> 
	                <cfoutput> 
	                    <h3 class="error">You must enter text in both the User Name and Password fields.</h3> 
	                </cfoutput> 
	                <cfinclude template="loginform.cfm"> 
	                <cfabort> 
	            <cfelse> 
	                <cfset var thepass = hash(cflogin.password, "MD5", "UTF-8")>
	                <!--- Check user login information against database and only allow admins to login --->
					<cfquery datasource="#session.datasource#" name="loginQuery">
						SELECT u.user_login_name, u.user_email, u.user_id, u.user_first_name, u.user_last_name, 'admin' roles
						FROM users u, ct_groups_users ctg
						WHERE (
							lower(u.user_login_name) = <cfqueryparam value="#lcase(cflogin.name)#" cfsqltype="cf_sql_varchar"> 
							OR lower(u.user_email) = <cfqueryparam value="#lcase(cflogin.name)#" cfsqltype="cf_sql_varchar">
							)
						AND u.user_pass = <cfqueryparam value="#thepass#" cfsqltype="cf_sql_varchar">
						AND ctg.ct_g_u_grp_id = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
						AND ctg.ct_g_u_user_id = u.user_id			
						AND lower(u.user_active) = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
					</cfquery>
	                <cfif loginQuery.Roles NEQ ""> 
	                    <cfloginuser name="#cflogin.name#" Password = "#cflogin.password#" 
	                        roles="#loginQuery.Roles#"> 
	                <cfelse> 
	                    <cfoutput> 
	                        <h3 class="error">Your login information is not valid. 
	                        <br/>Note that only admins are authorized to login.<br/> 
	                        Please Try again</h3> 
	                    </cfoutput>     
	                    <cfinclude template="loginform.cfm"> 
	                    <cfabort> 
	                </cfif> 
	            </cfif>     
	        </cfif> 
	    </cflogin> 
	 
	    <cfif GetAuthUser() NEQ ""> 
	        <cfoutput> 
	        		<div style="float:right">
	                <form action="index.cfm" method="Post"> 
	                <input type="submit" Name="Logout" value="Logout">
	                </div> 
	            </form> 
	        </cfoutput> 
	    </cfif>  
	   <!--- End authentication code --->
	</cffunction>

	<!--- Runs at end of request --->
	<cffunction name="onRequestEnd" returnType="void" output="false">
		<cfargument name="thePage" type="string" required="true">
	</cffunction>

	<!--- Runs when your session starts --->
	<cffunction name="onSessionStart" returnType="void" output="false">
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