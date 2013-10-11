<cfcomponent>
	<cfsetting showdebugoutput="false">
	<cffunction name="delete_err" returnformat="plain" access="remote">
		<cfargument name="id" hint="id of the record to delete">
		<cfif not isDefined("arguments.id")>
			<cfreturn "No record found to remove.">
		</cfif>
		<cftry>
		<cfquery name="delete" datasource="#session.datasource#">
			delete from #session.shard_group#errors
			where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer"> 
		</cfquery>
		<cfcatch type="database">
			<cfreturn "Database Error: #cfcatch.detail#">
		</cfcatch>
		</cftry>
		<cfreturn "ok">
	</cffunction>

	<cffunction name="update_err" returnformat="plain" access="remote">
		<cfargument name="id" required="true" hint="id of the record to update">
		<cfargument name="value" required="true" hint="value to set for record">		
		<cftry>
		<cfquery name="update" datasource="#session.datasource#">
			update #session.shard_group#errors
			set err_header = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">
			where id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer"> 
		</cfquery>
		<cfcatch type="database">
			<cfreturn "Database Error: #cfcatch.detail#">
		</cfcatch>
		</cftry>
		<cfreturn arguments.value>
	</cffunction>

	<cffunction name="delete_log" returnformat="plain" access="remote">
		<cfargument name="id" hint="name of bluedragon logfile to delete">
		<cfif not isDefined("arguments.id")>
			<cfreturn "No record found to remove.">
		</cfif>
		<cftry>
			<cffile action="delete" file="#expandpath('./temp')#/#arguments.id#"/>
			<cffile action="delete" file="#expandpath(session.BDlogdir)#/#arguments.id#"/>
		<cfcatch type="any">
			<cfreturn "Error: #cfcatch.detail#">
		</cfcatch>
		</cftry>
		<cfreturn "ok">
	</cffunction>

</cfcomponent>