<!---
	$Id: _requests_session.cfm 2121 2012-06-22 10:29:03Z alan $

	Returns the session
	--->

<cfset s = debuggerinspectprofilesession(url.id)>

<cfif !StructKeyExists(s, "type")>
	<cfabort>
</cfif>

<cfif s.type == "sql">

	<table>
	<tr>
		<th>SQL</th>
		<td><pre><cfoutput>#XmlFormat(s.sql)#</cfoutput></pre></td>
	</tr>
	<tr>
		<th>Time</th>
		<td><cfoutput>#NumberFormat(s.time)# ms</cfoutput></td>
	</tr>
	<cfif StructKeyExists(s,"params")>
	<cfoutput><cfloop array="#s.params#" index="param">
	<tr>
		<th>Parameter</th>
		<td>#XmlFormat(param)#</td>
	</tr>
	</cfloop></cfoutput>
	</cfif>
	</table>

<cfelseif s.type == "http">


</cfif>