<cfset request.simple = true>
<cfinclude template="../inc/header.inc">

<cfset array = DebuggerInspectQueryStack( url.id )>

<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div id="varname" class="filename">Query History</div></th>
</tr>
<cfoutput>
<cfloop index="x" from="1" to="#ArrayLen( array )#">
<tr class="<cfif x mod 2 == 0>rowHi</cfif>">
	<td title="click for more detail"><pre><a onclick="display(#x#,'#array[x].f#');" href="javascript:void(null);">#Wrap(array[x].name, 15)#</a></pre></td>
	<td align="right" nowrap>#array[x].time# ms &nbsp;</td>
</tr>
</cfloop>
</cfoutput>
</table>


<div style="display:none;">
<cfoutput><cfloop index="x" from="1" to="#ArrayLen( array )#">
<div id="table#x#">
<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<cfif array[x].querytype == "query">
	<tr><td width="20%" nowrap><pre>SQL</pre></td><td>#array[x].sql#</td></tr>
	<tr><td width="20%" nowrap><pre>Columns</pre></td><td>#Replace(array[x].columns, ",", ", ", "ALL")#</td></tr>
	<tr><td width="20%" nowrap><pre>Returned Rows</pre></td><td>#array[x].rows#</td></tr>
	<tr><td width="20%" nowrap><pre>name=""</pre></td><td>#array[x].name#</td></tr>
	<tr><td width="20%" nowrap><pre>Execution Time</pre></td><td>#array[x].time# ms</td></tr>
	<tr><td width="20%" nowrap><pre>Datasource</pre></td><td>#array[x].ds#</td></tr>
	<tr><td width="20%" nowrap><pre>DataType</pre></td><td>#array[x].dstype#</td></tr>
	<tr><td width="20%" nowrap><pre>Params</pre></td><td>#array[x].prepared#</td></tr>
<cfelse>
	<tr><td width="20%" nowrap><pre>procName</pre></td><td>#array[x].name#</td></tr>
	<tr><td width="20%" nowrap><pre>Execution Time</pre></td><td>#array[x].time# ms</td></tr>
	<tr><td width="20%" nowrap><pre>Datasource</pre></td><td>#array[x].ds#</td></tr>
	<tr><td width="20%" nowrap><pre>Params</pre></td><td>#array[x].prepared#</td></tr>
</cfif>
</table>
</div>
</cfloop></cfoutput>
</div>

<script>
display = function( v, m ){
	parent.valueframe.document.getElementById("varname").innerHTML = "Query @ " + m;
	parent.valueframe.document.getElementById("vardump").innerHTML = document.getElementById( "table" + v ).innerHTML;
}
</script>

<cfinclude template="../inc/footer.inc">