<!--- Set online and local db --->
<cfset mig = structnew()>
<cfset mig.db_hosted = "mysql-live">
<cfset mig.db_local = "mysql">
<!--- Set host id to migrate --->
<cfset mig.hostid = 0>


<cfparam name="url.action" default="" />
<cfquery datasource="#mig.db_local#" action="flushall" />
<!--- Migrate Database first --->
<cfif url.action EQ "db">
	<cfinvoke component="nirvanix-local" method="migrate_db" thestruct="#mig#" />
<cfelseif url.action EQ "files">
	<cfinvoke component="nirvanix-local" method="migrate_files" thestruct="#mig#" />
<cfelse>
	<h2>Nothing to do here. No action given.</h2>
</cfif>

