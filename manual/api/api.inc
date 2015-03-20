<cfsilent>

	<cfparam name="request.page.title" 		default="Chrome Extension - API ">
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
			"../css/reset.css",
			"../css/style.css",
			"../css/snippet.css"
		]>

		<cfstylesheet src="#commonCss#" path="/" media="screen,projection" minimize="true" />

		<cfset commonJs = [
			"../js/jquery-1.6.4.min.js",
			"../js/jquery.autocomplete.js",
			"../js/bootstrap-dropdown.js",
			"../js/jquery.snippet.min.js",
			"../js/manual.js"
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

			<div id="show_menu" class="menu_btn" title="show menu"><span></span></div>

			<ul class="nav">
				<li><a href="/">OpenBD.org</a></li>
				<li><a href="../">Manual</a></li>
			</ul>

		</div><!-- .container -->

	</div><!-- .topbar -->


	<div class="content" id="content">
		<div class="container cf">

			<h1>OpenBD Manual API</h1>

			<div class="sidebar cf">
				<div id="side_menu" class="show_cats">Categories <span><b></b></span></div>
				<ul class="categories">
					<li class="active"><a href="#" title="Overview">Overview</a></li>
					<li><a href="https://chrome.google.com/webstore/detail/openbd/khcnhdehhgbmkncjefpifbfekmkhbgnf" title="Chrome Extension">Get Chrome Extension</a></li>
				</ul>
			</div>


			<div class="section">

				<p>
					The OpenBD Manual API is used to power the OpenBD Chrome Extension. The extension provides a quick and easy
					way to access details of tags and functions available to you in OpenBD.
				</p>

				<p class="center">
					<img src="../images/chrome-extension.png" title="Chrome Extension" />
				</p>

				<p class="center">
					<a href="https://chrome.google.com/webstore/detail/openbd/khcnhdehhgbmkncjefpifbfekmkhbgnf" class="centerbtn btn">Download Chrome Extension</a>
				</p>

			</div><!--- .section --->

		</div><!--- .container --->
	</div><!--- #content --->

</div><!--- .wrap --->

</body>
</html>
