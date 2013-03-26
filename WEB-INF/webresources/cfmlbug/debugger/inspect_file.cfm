<cfsilent>

	<cfset request.simple = true>
	<cfset fileQry	= DebuggerInspectFileStack( url.id )>

</cfsilent><cfinclude template="../inc/header.inc">

<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div id="varname" class="filename">Current File Stack</div></th>
</tr>
<cfoutput>
<cfloop array="#ArrayReverse(fileQry)#" index="file">
<tr>
	<td><pre>#file.pf#</pre></td>
</tr>
</cfloop>
</cfoutput>
<tr>
	<td><pre style="color:silver"><em>request start</em></pre></td>
</tr>
</table>

<cfinclude template="../inc/footer.inc">