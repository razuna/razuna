<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html lang="en">
<head>
	<title><cfoutput>#url.id#</cfoutput> CFMLBug: Debugger Inspection</title>
</head>

<cfif DebuggerIsSession(url.id)>

<frameset rows="40px,*,200px" title="" frameborder="no">
	<frame src="cfmlbug.cfres?_f=debugger/inspect_top.cfm&_cfmlbug&id=<cfoutput>#url.id#</cfoutput>" name="topframe" title="" scrolling="no" noresize="true">
	<frameset cols="*,20%" title="">
		<frame src="cfmlbug.cfres?_f=debugger/inspect_middle.cfm&_cfmlbug&id=<cfoutput>#url.id#</cfoutput>" name="inspectframe" scrolling="yes">
		<frameset rows="25%,25%,25%" title="">
			<frame src="cfmlbug.cfres?_f=debugger/inspect_file.cfm&_cfmlbug&id=<cfoutput>#url.id#</cfoutput>" name="fileframe" scrolling="yes">
			<frame src="cfmlbug.cfres?_f=debugger/inspect_tag.cfm&_cfmlbug&id=<cfoutput>#url.id#</cfoutput>" name="tagframe" scrolling="yes">
			<frame src="cfmlbug.cfres?_f=debugger/inspect_query.cfm&_cfmlbug&id=<cfoutput>#url.id#</cfoutput>" name="queryframe" scrolling="yes">
		</frameset>
	</frameset>
	<frame src="cfmlbug.cfres?_f=debugger/inspect_bottom.cfm&_cfmlbug" name="valueframe" scrolling="yes">
	<noframes></noframes>
</frameset>

<cfelse>

<p>This session is no longer active; please close</p>

</cfif>

</html>