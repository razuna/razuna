<cfsilent>

	<cfparam name="url.f" 		default="">
	<cfparam name="url.id" 		default="0">
	<cfparam name="url.line" 	default="0">

	<cfset fileBody	= FileRead( url.f )>
	<cfset fileBody	= CreateObject("component","formatter").syntaxHighlight( fileBody )>
	<cfset fileName	= ExpandPath( "./" & Hash( url.f ) & ".tmp.html" )>
	<cfset FileDelete( fileName )>
	<cfset FileWrite( fileName, fileBody )>
	<cfset LineNo 	= 1>

	<!--- Get the breakpoints --->
	<cfset breakpoints	= DebuggerGetBreakpoints()>
	<cfquery dbtype="query" name="breakpoints">select * from breakpoints where f=<cfqueryparam value="#url.f#"></cfquery>

	<cfset breakPointLines	= ValueList( breakpoints.line )>

</cfsilent><cfinclude template="../inc/header.inc">

<cfoutput>
<table width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="3"><div class="filename">#url.f# <span id="sessionid"></span>
	<span style="float:right"><a href="cfmlbug.cfres?_f=debugger/loadFile.cfm&f=#UrlEncodedFormat(url.f)#&_cfmlbug" title="reload" class="reload"></a></span>
	</div></th>
</tr>
<cfloop file="#fileName#" index="line">
<tr id="line#lineNo#" lineno="#lineNo#"<cfif lineNo mod 2 == 0> class="rowHi"</cfif>>
	<td width="21"><div class="line_img"><img src="cfmlbug-static.cfres?f=<cfif ListFind( breakPointLines, lineNo )>img/bp.png<cfelse>img/1x1t.gif</cfif>" width="13" height="13" /></div></td>
	<td><div class="line_num"><pre style="color: silver">#LineNo#</pre></div></td>
	<td nowrap class="line_code"><pre>#line#</pre></td><cfset LineNo = LineNo + 1>
</tr></cfloop></cfoutput>
</table>

<script src="<cfoutput>#request.staticroot#</cfoutput>debugger.js"></script>
<script type="text/javascript">
$(function() {
	BreakPointManager.init(<cfoutput>"#url.f#", "#url.id#"</cfoutput>);
	BreakPointManager.highlightLine(<cfoutput>"#url.id#", "#url.line#"</cfoutput>);
});
</script>

<cfinclude template="../inc/footer.inc"><cfsilent>

	<cfset FileDelete( fileName )>

</cfsilent>