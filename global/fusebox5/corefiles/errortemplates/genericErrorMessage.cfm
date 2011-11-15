<cfmail to="support@razuna.com" from="server@razuna.com" subject="Fusebox error message">
	<cfdump var="#cfcatch#">
</cfmail>
<cfoutput>
<h3>This is the template "errortemplates/#cfcatch.type#.cfm"</h3>
<h2>An Error of type "#cfcatch.type#" has occured</h2>
<h4>#cfcatch.message#</h4>
<p>
#cfcatch.detail#
</p>
</cfoutput>
