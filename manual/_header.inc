<cfsilent>

	<cfparam name="request.page.title" 		default="Official">
	<cfparam name="request.page.section" 	default="">
	<cfparam name="request.page.desc" 		default="Official OpenBD CFML Manual">


	<cfset tagArray = GetEngineTagCategories()>

</cfsilent><!DOCTYPE html>
<html lang="en">
	<head>
		<title><cfoutput>#request.page.title#</cfoutput> / OpenBD CFML Manual</title>
		<meta charset="utf-8">
		<meta name="description" content="<cfoutput>#request.page.desc#</cfoutput>" />
		<meta name="keywords" content="cfml, bluedragon, openbd, open bluedragon, j2ee, open source, web, application, cfsmtp, cfimap, amazon simpledb, amazon s3, free server, cfml engine, cfvideoplayer, coldfusion" />
		<meta name="author" content="OpenBD" />

		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<meta itemprop="name" content="<cfoutput>#request.page.title#</cfoutput> / OpenBD">
		<meta itemprop="description" content="<cfoutput>#request.page.desc#</cfoutput>">
		
		<cfset commonCss = [
			"./css/reset.css",
			"./css/style.css",
			"./css/snippet.css"
		]>
		
		<cfstylesheet src="#commonCss#" path="/" media="screen,projection" minimize="true" />
		
		<cfset commonJs = [
			"./js/jquery-1.6.4.min.js",
			"./js/jquery.autocomplete.js",
			"./js/bootstrap-dropdown.js",
			"./js/jquery.snippet.min.js",
			"./js/manual.js"
		]>
		
		<cfjavascript src="#commonJs#" path="/js/" minimize="true" /> 

		<!-- Le fav and touch icons -->
		<link rel="shortcut icon" href="./favicon.ico" />
	</head>

	<body>
	
	<div class="wrap"><!-- ends in _footer.inc -->

	<div class="topbar">

		<div class="container cf">
			
			<a class="brand" href="http://openbd.org"><img src="/manual/images/logo.png" /></a>
			
			<form action="" class="search">
				<input id="searchbox" class="input-medium" type="text" placeholder="tag/function search">
			</form>
			
			<div id="show_menu" class="menu_btn" title="show menu"><span></span></div>

			<ul class="nav">
				<li class="<cfif request.page.section == "basic">active</cfif>"><a href="./?/basic_cfml">Basic CFML</a></li>
				<li class="<cfif request.page.section == "adv">active</cfif>"><a href="./?/advanced">Advanced</a></li>
				<li class="<cfif request.page.section == "tags">active</cfif>"><a href="./?/tag/">Tags</a></li>
				<li class="<cfif request.page.section == "functions">active</cfif>"><a href="./?/function/">Functions</a></li>
				<li class="<cfif request.page.section == "plugins">active</cfif>"><a href="./?/plugin/">Plugins</a></li>
				<li class="<cfif request.page.section == "engine">active</cfif>"><a href="./?/engine/">Server</a></li>
				<li class="<cfif request.page.section == "support">active</cfif>"><a href="./?/support/">Support</a></li>
			</ul>

		</div><!-- .container -->

	</div><!-- .topbar -->