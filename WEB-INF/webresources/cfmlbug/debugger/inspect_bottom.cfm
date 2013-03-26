<cfsilent>

	<cfset request.simple = true>

	<cfif StructKeyExists( url, "v" )>
		<cfset url.v = CreateObject("component","inspect").decode( url.v )>
	</cfif>

</cfsilent><cfinclude template="../inc/header.inc">

<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div id="varname" class="filename"><cfif StructKeyExists( url, "v" )><cfoutput>#url.v#</cfoutput><cfelse>Inspection Panel</cfif></div></th>
</tr>
</table>

<div style="margin: 10px;">
<cfif StructKeyExists( url, "v" )>
	<cfdump var="#DebuggerInspect( url.sid, url.v )#">
</cfif>
</div>


<cfinclude template="../inc/footer.inc">