<cfsilent>
	<cfparam name="request.page.title" default="">
	<cfparam name="request.page.heading" default="">

	<cfset request.root			= "cfmlbug.cfres?_f=">
	<cfset request.staticroot	= "cfmlbug-static.cfres?f=">

	<cffunction name="formatFile" returntpe="string" hint="pretty up the file">
		<cfargument name="f" required="true" />

		<cfset var root	= Replace( ExpandPath("/"), "\", "/", "ALL" )>
		<cfif arguments.f.startsWith( root )>
			<cfreturn arguments.f.substring( root.length()-1 )>
		<cfelse>
			<cfreturn root>
		</cfif>
	</cffunction>

</cfsilent><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfoutput>#request.page.title#</cfoutput></title>
	<link rel="stylesheet" href="<cfoutput>#request.staticroot#css/style.css&r=#gettickcount()#</cfoutput>" type="text/css" media="screen" charset="utf-8" />
	<script>var requestStaticRoot="cfmlbug-static.cfres?f=/cfmlbug/"; var requestRoot="cfmlbug.cfres?_f=";</script>
	<script src="<cfoutput>#request.staticroot#</cfoutput>jquery-1.7.2.js"></script>
	<script src="<cfoutput>#request.staticroot#</cfoutput>aw20.filepaths.min.js"></script>
</head>
<body>