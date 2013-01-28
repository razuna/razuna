<cfsilent>

	<cfparam name="url.l" default="1">

	<cfset fileBody	= FileRead( url.f )>
	<cfset fileBody	= CreateObject("component","formatter").syntaxHighlight( fileBody )>
	<cfset fileBody	= FixEOL( fileBody, "CRLF" )>
	<cfset fileBody	= ListToArray( fileBody, Chr(13) & Chr(10), true )>

	<cfset lineNo = 1>

</cfsilent>



<cfoutput>
<div id="j-code-src-view-port">
<table class="j-code fileList">
<cfloop array="#fileBody#" index="line">
<tr>
	<th width="1%"><pre>#LineNo#</pre></th>
	<td nowrap class="code"><pre>#line#</pre></td><cfset LineNo = LineNo + 1>
</tr></cfloop>
</table>
</div>
</cfoutput>