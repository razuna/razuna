<pre class="cfml">
<cftry>

	<!--- This will cause an error --->
	<cfset a = variableDoesNotExist>

	<cfcatch>

		<!--- Enters here upon error; you can do anything in here --->
		<cfdump var="#cfcatch#">

	</cfcatch>
</cftry>
</pre>