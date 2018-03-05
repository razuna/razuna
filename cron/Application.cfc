<cfcomponent displayname="Application" output="true" hint="Handle the application.">

	<!--- Set up the application. --->
	<cfset THIS.Name = "RazunaCron" />
	<cfset THIS.ApplicationTimeout = CreateTimeSpan( 0, 0, 1, 0 ) />
	<cfset this.sessionManagement = true>
	<cfset THIS.SetClientCookies = false />

	<!--- Define the page request properties. --->
	<!--- <cfsetting requesttimeout="20" showdebugoutput="false" enablecfoutputonly="false" /> --->

	<cffunction	name="OnApplicationStart" access="public" returntype="boolean" output="false" hint="Fires when the application is first created.">

		<cfset consoleoutput(true, true)>
		<cfset console('============================ START')>

		<cfset cacheregionnew(
			region="razcache",
			props=
				{
					type : 'memorydisk'
				}
		)>

		<cfinvoke component="global.cfc.ResourceManager" method="init" resourcePackagePath="translations" returnvariable="application.razuna.trans" />

		<!--- Return out. --->
		<cfreturn true />
	</cffunction>

	<!--- On Request start --->
	<cffunction name="OnRequestStart" access="public" output="false">
		<cfset var _config = "">
		<!--- Get database --->
		<cfquery datasource="razuna_default" name="_config">
		SELECT conf_database, conf_datasource, conf_storage, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_aws_tenant_in_one_bucket_name, conf_aws_tenant_in_one_bucket_enable
		FROM razuna_config
		</cfquery>
		<!--- Put into request scope --->
		<cfset request.razuna = structnew()>
		<cfset request.razuna.application.datasource = _config.conf_datasource>
		<cfset request.razuna.application.storage = _config.conf_storage>
		<cfset request.razuna.application.thedatabase = _config.conf_database>


	</cffunction>

	<!--- <cffunction	name="OnSessionStart" access="public" returntype="void"	output="false" hint="Fires when the session is first created.">

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false" hint="Fires at first part of page processing.">

		<!--- Define arguments. --->
		<!--- <cfargument	name="TargetPage" type="string"	required="true"	/> --->

		<!--- Return out. --->
		<cfreturn true />
	</cffunction>


	<cffunction	name="OnRequest" access="public" returntype="void" output="true" hint="Fires after pre page processing is complete.">

		<!--- Define arguments. --->
		<!--- <cfargument name="TargetPage" type="string"	required="true"	/> --->

		<!--- Include the requested page. --->
		<!--- <cfinclude template="#ARGUMENTS.TargetPage#" /> --->

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction	name="OnRequestEnd"	access="public"	returntype="void" output="true" hint="Fires after the page processing is complete.">

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction	name="OnSessionEnd"	access="public"	returntype="void" output="false" hint="Fires when the session is terminated.">

		<!--- Define arguments. --->
		<cfargument	name="SessionScope"	type="struct" required="true" />
		<cfargument name="ApplicationScope"	type="struct" required="false" default="#StructNew()#" />

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction	name="OnApplicationEnd"	access="public"	returntype="void" output="false" hint="Fires when the application is terminated.">

		<!--- Define arguments. --->
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

		<!--- Return out. --->
		<cfreturn />
	</cffunction> --->


	<cffunction	name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">

		<!--- Define arguments. --->
		<cfargument	name="Exception" type="any"	required="true"	/>
		<cfargument	name="EventName" type="string" required="false" default="" />

		<!--- Return out. --->
		<cfreturn />
	</cffunction>

</cfcomponent>