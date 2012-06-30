<cfsilent>

	<cfparam name="url.l" default="1">

	<cfset fileBody	= FileRead( url.f )>
	<cfset fileBody	= CreateObject("component","formatter").syntaxHighlight( fileBody )>
	<cfset fileBody	= FixEOL( fileBody, "CRLF" )>
	<cfset fileBody	= ListToArray( fileBody, Chr(13) & Chr(10), true )>

	<cfset lineNo = 1>

</cfsilent>

<style>
.fileList th{
	font-weight: normal;
	text-align: right;
	border-right: 3px solid #00bf30;
	padding-right: 3px;
}

.fileList th pre {
	margin-right: 3px;
	color: #AFAFAF !important;
}

.fileList pre {
	margin: 0px;
	margin-top: 1px;
	margin-bottom: 1px;
	margin-left: 10px;
}

.fileList pre .cf { /* cf tags */
	color: maroon;
}

.fileList pre .n { /* numbers */
	color: blue;
}

.fileList pre .h { /* html tags */
	color: navy;
}

.fileList pre .q { /* quotes */
	color: blue;
}

.fileList pre .f { /* form elements */
	color: #FF8000
}

.fileList pre .t { /* table elements */
	color: teal
}

.fileList pre .c { /* comments elements */
	color: gray
}

.fileList pre .i { /* image */
	color: purple
}

.fileList pre .a { /* a tags */
	color: green
}

.fileList td.code {
	cursor: pointer;
}

#j-code-src-view-port{
	height:200px;
	overflow:auto
}
</style>

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