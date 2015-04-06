<cfset request.page.section = "basic">
<cfset request.page.title = "CFML scopes">
<cfset request.page.desc	= "CFML has a variety of pre-defined scopes associated with it">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/language_scopes"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Standard Variable Scopes</h1>
		
		<cfinclude template="pages/sidebar_basic.inc" />

		<div class="section">

		<p>CFML defines a number of variable scopes that it places certain data in. While it is always advisable to use full variables paths when addressing data, it is not
		necessary as the engine will search scopes looking for the variable asked</p>

			<ul>
				<li><strong>server</strong>
				<br/>This scope contains information pertaining to the server as a whole.  You can set data into this scope with no problems.
				</li>
				<li class="padtop"><strong>cgi</strong>
				<br/>The CGI scope contains all the HTTP headers set by the web server and client detailing information about the request itself.  For example the
				the user agent, remote IP address.  This scope will never throw a not found exception, but instead will return a blank string.  This is READ ONLY scope.
				</li>
				<li class="padtop"><strong>cookie</strong>
				<br/>The cookie scope contains all the incoming HTTP cookies that were sent with the request.
				</li>
				<li class="padtop"><strong>request</strong>
				<br/>This scope is unique per request and is accessible by any template, custom tag or component that is processing this request.  Certain J2EE engines may prefill
				in some keys here detailing the context root of the request.
				</li>
				<li class="padtop"><strong>form</strong>
				<br/>Any data sent to the server using an HTTP POST is available in this scope.  This scope is writable, enabling you to add and change variables here.
				</li>
				<li class="padtop"><strong>url</strong>
				<br/>Any data encoded in the URL will be decoded and placed inside this variable scope.  This is scope is writable, enabling you to add and change variables here.
				</li>
				<li class="padtop"><strong>variables</strong>
				<br/>This is the default scope where all variables are stored.  All variables within CFML belong to at least one scope, and this is the one that is
				</li>
				<li class="padtop"><strong>locals</strong>
				<br/>Available only within a CFFUNCTION/function()
				</li>
				<li class="padtop"><strong>arguments</strong>
				<br/>This scope contains all the parameters that were passed into a defined CFFUNCTION/function() tag, and is only accessible in those situations.
				</li>
				<li class="padtop"><strong>attributes</strong>
				<br/>For use only inside custom tags, this scope lets you get at all the tag attributes that was used to call the custom tag.
				</li>
				<li class="padtop"><strong>application</strong>
				<br/>When used with CFAPPLICATION or Application.cfc, this global scope contains all the variables for that given application.  This is writable.  It contains a number
				of pre-defined variables about the application.
				</li>
				<li class="padtop"><strong>client</strong>
				<br/>When enabled (through CFAPPLICATION/Application.cfc) this scope is available for each request and will be saved between requests (and server restarts) in
				one of the storage methods specified.  It determines the same user by using CFID/CFTOKEN cookies/URL parameters.  Storage can be saved inside a user cookie,
				removing any load away from the server.  Be careful relying on this, as a user can simply delete/clear their cookies and you will have lost everything.
				</li>
				<li class="padtop"><strong>session</strong>
				<br/>When enabled (through CFAPPLICATION/Application.cfc) this scope is available for each user.  The session scope can contain rich objects (CFC references for
				example).
				</li>
				<li class="padtop"><strong>cfthread</strong>
				<br/>When inside a thread, this scope contains all the variables associated with this thread.
				</li>
				<li class="padtop"><strong>cffile</strong>
				<br/>Used after a CFFILE call which process an upload, this scope will contain all the information associated with the file that was uploaded
				</li>
				<li class="padtop"><strong>this</strong>
				<br/>Used within a CFC, it is a reference to the current object and lets you get at variables and functions.
				</li>
				<li class="padtop"><strong>super</strong>
				<br/>Used within a CFC, this scope lets you get at the base methods of a CFC if inherited.
				</li>
				<li class="padtop"><strong>cfcatch</strong>
				<br/>Used when an exception is thrown and is only available inside a CFCATCH block.  It contains as much information about the error as possible including tag and file traces.
				</li>
			</ul>
			
			<h2>Example Usage</h2>
			
			The majority of the scopes are structures and can be accessed in the standard way using the . (dot) or [] notation.
			
<pre class="cfml">
&lt;cfdump var=#cgi#>
&lt;cfoutput>#cgi.HTTP_USER_AGENT#&lt;/cfoutput>
&lt;cfoutput>#cgi['HTTP_USER_AGENT']#&lt;/cfoutput>

&lt;cfif StructKeyExists( form, "name" )>
  &lt;cfoutput>Your Name: #form.name#&lt;/cfoutput>
&lt;/cfif></pre>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->