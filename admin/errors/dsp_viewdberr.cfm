<!--- Get errors stored in user database --->
<cfquery datasource="#session.datasource#" name="getdberr">
	select err_text
	from #session.shard_group#errors
	where id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer"> 
</cfquery> 

<cfoutput>#getdberr.err_text#</cfoutput>