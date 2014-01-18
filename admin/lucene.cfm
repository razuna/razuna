<!--- File is only invoked when you run Razuna in a hosted setting --->
<cfset contextpath = "">
<cfif cgi.CONTEXT_PATH NEQ "">
	<cfset contextpath = cgi.CONTEXT_PATH>
</cfif>
<cflocation url="#contextpath#/raz1/dam/index.cfm?fa=c.req_index_update_hosted" />