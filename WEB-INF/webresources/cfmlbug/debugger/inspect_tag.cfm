<cfsilent>

	<cfset request.simple = true>
	<cfset tagQry	= DebuggerInspectTagStack( url.id )>
	<cfset tagQry = ArrayReverse( tagQry )>

</cfsilent><cfinclude template="../inc/header.inc">

<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div id="varname" class="filename">Current Tag Stack</div></th>
</tr>
<cfoutput>
<cfloop index="x" from="1" to="#ArrayLen( tagQry )#">
<tr>
	<td><pre><a title="#tagQry[x].pf#" onclick="display( #x#, '#tagQry[x].id#' );" href="javascript:void(null);">#tagQry[x].id#</a></pre></td>
	<td align="right">Line'#tagQry[x].line#&nbsp;</td>
</tr>
</cfloop>
</cfoutput>
<tr>
	<td><pre style="color:silver"><em>request start</em></pre></td>
</tr>
</table>


<div style="display:none;">
<cfoutput>

<cfloop index="x" from="1" to="#ArrayLen( tagQry )#">
<div id="table#x#">
<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr><td><pre>Tag</pre></td><td><pre>#tagQry[x].id#</pre></td></tr>
<tr><td><pre>Line</pre></td><td><pre>#tagQry[x].line#</pre></td></tr>
<tr><td><pre>Column</pre></td><td><pre>#tagQry[x].column#</pre></td></tr>
<tr><td><pre>Template</pre></td><td><pre>#tagQry[x].pf#</pre></td></tr>
</table>
</div>
</cfloop>
</cfoutput>
</div>


<script>
display = function( v, m ){
	parent.valueframe.document.getElementById("varname").innerHTML = "Tag @ " + m;
	parent.valueframe.document.getElementById("vardump").innerHTML = document.getElementById( "table" + v ).innerHTML;
}
</script>

<cfinclude template="../inc/footer.inc">