<cfsilent>
	<cfset request.page.section = "basic">
	<cfset request.page.title 	= "Basic CFML">
	<cfset request.page.desc		= "CFML has a rich array of functions and rich variable types within the language to use">
</cfsilent>


<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li class="active"><a href="./?/basic_cfml">Basic CFML</a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">
	
		<h1>Basic CFML</h1>
	
		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">

			<p>We've collected some primer documents for you to get to grips with the basics of CFML.</p>
	
			<h4><a href="./?/language_tagsfunctions">Getting Started</a></h4>
			<p>If you are completely new to CFML then this is page will get you started very quickly showing you the basics of the language and how it is constructed</p>

			<h4><a href="./?/language_creation">Using Variables</a></h4>
			<p>Discover how wonderfully rich and simple variables are to use in CFML</p>

			<h4><a href="./?/language_scopes">Variable Scopes</a></h4>
			<p>CFML has special language name spaces that let you get quickly at various types of data.</p>

			<h4><a href="./?/language_operators">Data Operators</a></h4>
			<p>While CFML is a typeless language, that does not mean you can't use standard operators on them.  This overviews them all.</p>

			<h4><a href="./?/cfscript">Using CFSCRIPT</a></h4>
			<p>CFSCRIPT is a powerful server side scripting language, not dissimilar to Javascript, that lets you code without using tags.</p>

			<h4><a href="./?/cfc_introduction">CFML Objects</a></h4>
			<p>CFML has a very power object model, that come in the form of CFC's.  Learn how to harness this power with little effort.</p>

			<h4><a href="./?/app_application">CFML Application</a></h4>
			<td>CFML can arrange your web apps in a special concept called an 'Application'.  These are powerful and can save you a lot of hassle.</p>

			<h4><a href="./?/app_application_cfm">Application.cfm</a></h4>
			<p>The Application.cfm concept is the template based version of the 'Application' that gets rendered before any other template.</p>

			<h4><a href="./?/app_application_cfc">Application.cfc</a></h4>
			<p>The Application.cfc is the more popular object orientated approach to handling applications, with callback methods on each type of event that happens.</p>

			<h4><a href="./?/app_onrequestend_cfm">OnRequestEnd.cfm</a></h4>
			<p>This is a special template that gets rendered on the end of each request.</p>

			<h4><a href="./?/app_server_cfc">Server.cfc</a></h4>
			<p>This template lets you hook into the startup of the server, initializing various settings that need to be done before you start servicing requests.</p>
		
		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->