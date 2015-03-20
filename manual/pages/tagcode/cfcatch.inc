<pre class="cfml">
<cftry>

	<!--- This will cause an error --->
	<cfset a = variableDoesNotExist>

	<cfcatch type="application">

		<!--- Enters here upon application error --->
		<cfdump var="#cfcatch#">

	</cfcatch>
	<cfcatch type="any">

		<!--- Enters here upon any other error --->
		<cfdump var="#cfcatch#">

	</cfcatch>
</cftry>
</pre>