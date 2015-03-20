<cfsilent>

	<cfif StructKeyExists(url,"_change")>
		<cfparam name="url.break" default="0">
		<cfif url.break == 1>
			<cfset DebuggerSetBreakPointOnException( true )>
		<cfelse>
			<cfset DebuggerSetBreakPointOnException( false )>
		</cfif>
	</cfif>
	
	<cfset breakpoints	= DebuggerGetBreakpoints()>
	<cfset QuerySort( breakpoints, "f", "TEXTNOCASE", "ASC" )>
	<cfset breakPointOnException 	= DebuggerGetBreakPointOnException()>

	<cfset request.simple = true>

</cfsilent><cfinclude template="../inc/header.inc">

<script src="<cfoutput>#request.staticroot#</cfoutput>debugger.js"></script>

<form action="cfmlbug.cfres" method="get">
<input type="hidden" name="_cfmlbug" value="0"/><input type="hidden" name="_change" value="0"/><input type="hidden" name="_f" value="debugger/breakpoints.cfm"/>
<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div class="filename">Active Breakpoints
	<span style="float:right">
	Break on Exception: <input onchange="this.form.submit();" type="checkbox" name="break" value="1" <cfif breakPointOnException>checked</cfif>/> &nbsp; &nbsp;
	<a href="javascript:void(null);" onclick="BreakPointManager.clearAll();" title="clear all" class="clearall">clear all</a></span></div>
	</th>
</tr>
<cfoutput query="breakpoints">
<tr class="<cfif currentrow mod 2 == 0>rowHi</cfif>">
	<td><pre><a href="cfmlbug.cfres?_f=debugger/loadFile.cfm&f=#UrlEncodedFormat(f)#&_cfmlbug" target="fileframe" style="text-decoration:none;">#formatFile(f)#</a></pre></td>
	<td>@ Line ## #line#</td>
	<td width="20" align="center"><a href="javascript:void(null);" onclick="BreakPointManager.clearBreakPoint('#f#', #line#);" title="clear" class="clear">clear</a></td>
</tr>
</cfoutput>
</table>
</form>

<cfinclude template="../inc/footer.inc">