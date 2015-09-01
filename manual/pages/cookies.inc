<cfset request.page.section = "adv">
<cfset request.page.title = "Working with HTTP Cookies">
<cfset request.page.desc	= "HTTP Cookies can easily be set, read and deleted using CFML applications">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/cookies"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

	<h1>Working with Cookies</h1>
	
	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">
	
<blockquote>
<a href="http://en.wikipedia.org/wiki/HTTP_cookie">From WikiPedia:</a> A cookie, also known as a web cookie, browser cookie, and HTTP cookie, is a piece of text stored by a user's web browser. A
cookie can be used for authentication, storing site preferences, shopping cart contents, the identifier for a server-based session,
or anything else that can be accomplished through storing text data.  A cookie consists of one or more name-value pairs containing bits of
information, which may be encrypted  for information privacy and data security purposes. The cookie is sent as an HTTP header by a web
server to a web browser and then sent back unchanged by the browser each time it accesses that server.
</blockquote>

<p>
Reading and writing cookies within a CFML application couldn't be easier.  Through either the base language, a tag or a function, you have access to the cookie functionality quickly and easily.
</p>

<h2>Reading HTTP Cookie's</h2>

<p>
Any cookies sent to the server by the browser can easily be read using the <strong>cookie</strong> scope.   This is a standard CFML
structure that holds all the values of the incoming cookies.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfdump var="#cookie#">

<cfif StructKeyExists( cookie, "mycookie" )>
  <cfoutput>#cookie.mycookie#</cfoutput>
</cfif>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>


<h2>Creating/Setting HTTP Cookies</h2>

<p>
Creating a new HTTP cookie is just as easy as reading them.  You can set a minimal cookie by simply setting a value to the <strong>cookie</strong>
structure.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset cookie.mycookie = "This is a value">
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>
CFML doesn't stop there though when it comes to controlling the properties of an outgoing HTTP cookie.  Using either the
<a href="./?/tag/CFCOOKIE">CFCOOKIE</a> or the <a href="./?/function/setcookie">SetCookie()</a> function you can control all aspects of
the HTTP cookie.   From properties such as the domain, path and security settings, these can be controlled on an individual basis.
</p>

<cfsavecontent variable="cfml"><nocfml>
<!--- Using the tag to set a cookie --->
<cfcookie name="mycookie" value="This is a value" expires="60" httponly="true">

<!--- Using the function to set a cookie --->
<cfset SetCookie( name="mycookie", value="This is a value", expires="60", httponly="true" )>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>
The value of the cookie can only be a maximum of 4KB, and you are only permitted to have at most 20 cookies per request.  If you set the <strong>httponly</strong> flag,
this directs the browser to make sure the cookie is not accessible via Javascript.   Although it is not a full proof system and should only be seen as a precautionary mechanism.
</p>

<p>
A cookie can be set anywhere in your CFML application.  However, if your request has already been flushed, or any content sent to the client, then the cookie will fail to set.
</p>

<h2>Deleting HTTP Cookies</h2>

<p>
By default, if you do not specify any <strong>expires</strong> attribute the cookie will be deleted as soon as the user closes their browser window.   If you wish to delete the cookie
immediately then you can use the <strong>EXPIRES="NOW"</strong> directive.
</p>

<cfsavecontent variable="cfml"><nocfml>
<!--- Using the tag to set a cookie --->
<cfcookie name="mycookie" expires="now">

<!--- Using the function to set a cookie --->
<cfset SetCookie( name="mycookie", expires="now" )>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>
This will direct the browser to delete the cookie from the browser.
</p>

<h2>CFML Engine Cookies</h2>

<p>If you have session tracking enabled through the use of the CFML application functionality, then two cookies will automatically be set; CFID and CFTOKEN.  These cookies are automatically
handled by the engine.  They have HTTPONLY enabled to ensure Javascript applications are not permitted access to them.</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->