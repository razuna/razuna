<cfset request.page.section = "adv">
<cfset request.page.title = "CFML Manipulation">
<cfset request.page.desc	= "CFML can be used to create CFML and process it either inline or at a later date">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/advanced">Advanced</a></li>
      <li class="active"><a href="./?/cfmlmanipulation"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>CFML Manipulation</h1>

		<cfinclude template="pages/sidebar_advanced.inc" />
	
		<div class="section">
	
<p>
Have you ever wanted to work with CFML as a language from within CFML?   For example, store a snippet of CFML code
for processing at a later date?  Possibly storing blocks of CFML code inside a database.
</p>

<p>
This power allows you to write plugin's for your applications without having to resort to ugly file writing and then
processing.   But even the file writing technique has its problems - have you ever tried to just store a block of CFML
code as text without the engine getting in the way and trying to be helpful and execute it for you?
</p>

<p>
OpenBD gives you a couple of very powerful additions that lets you build completely dynamic and customizable code that
can be manipulated and executed inline or at a later date.
</p>

<h2>&lt;nocfml&gt; ... &lt;/nocfml&gt;</h2>

<p>
Inspired from the NOWIKI tag from MediaWiki, that lets you quickly write up blocks of text without being processed by the
wiki engine, OpenBD introduces the NOCFML tag.
</p>
<p>
The &lt;nocfml&gt; tag lets you capture complete blocks of CFML code without first being processed by the underlying CFML
engine.  Simply wrap your CFML code in this tag and the OpenBD engine will ignore all CFML tags and directives.  CFML tags
will be treated as if they are normal HTML tags and be sent straight to the requester.
</p>

<pre class="cfml">
&lt;nocfml&gt;
  &lt;cfset myvar = "this will not be executed"&gt;
  &lt;cfabort&gt;
&lt;/nocfml&gt;
</pre>

<p>
If you were to run this code and view it from a browser, you would see the actual CFML tags displayed in the source of the HTML page.
These tags would not be executed.  So the <a href="./?/tag/CFABORT">CFABORT</a> tag wouldn't have any effect here as it would be simply
treated as a block of text.
To capture the CFML code to a variable for processing or storage, then you would simply wrap it in a
<a href="./?/tag/CFSAVECONTENT">CFSAVECONTENT</a> tag.
</p>

<pre class="cfml">
&lt;cfsavecontent variable="captureCfml"&gt;
  &lt;nocfml&gt;
    &lt;cfset myvar = "this will not be executed"&gt;
    &lt;cfabort&gt;
  &lt;/nocfml&gt;
&lt;/cfsavecontent&gt;

&lt;cfoutput&gt;#XmlFormat(captureCfml)#&lt;/cfoutput&gt;
</pre>

<h2>Rendering Dynamic CFML code</h2>

<p>
Now that you have a block of CFML code stored as a string, how can you now render the code, as if it appeared in the page?
</p>

<p>
Using the <a href="./?/function/render">render()</a> function, you can pass in a block of CFML code and it will be rendered as if it was imported
using a <a href="./?/tag/CFINCLUDE">CFINCLUDE</a> tag, inheriting all the scopes and variables from the calling page.
</p>

<pre class="cfml">
&lt;cfsavecontent variable="captureCfml"&gt;
  &lt;nocfml&gt;
    &lt;cfset myvar = "this will not be executed"&gt;
  &lt;/nocfml&gt;
&lt;/cfsavecontent&gt;

&lt;cfset render(captureCfml)&gt;
</pre>

<p>
This is a very powerful function that lets you build very complex applications from snippets of dynamically generated code or previously stored
CFML snippets.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->