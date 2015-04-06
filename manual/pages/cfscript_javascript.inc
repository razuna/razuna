<cfset request.page.title = "CFSCRIPT language='javascript'">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "Extending CFSCRIPT with server side JavaScript">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/advanced">Advanced</a></li>
      <li class="active"><a href="./?/cfscript_javascript"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

	<h1 style="text-transform:none">&lt;CFSCRIPT language="javascript"&gt;</h1>

	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">
	
<p>
OpenBD ships with deep integration with JavaScript.   This lets you run write applications in pure Javascript and run them at the server side by
simply dropping your Javascript code inside the <code>&lt;CFSCRIPT language="javascript"&gt;</code> tag block.  This manual page will detail the
power that is available and how you integrate it with your CFML application.
</p>

<h2>JavaScript standard</h2>

<p>
OpenBD ships with its own version of the latest cutting edge <a href="http://www.mozilla.org/rhino/">Mozilla Rhino JavaScript</a> engine that provides <a href="http://en.wikipedia.org/wiki/ECMAScript">ECMAScript5</a> and partial <a href="https://developer.mozilla.org/en/JavaScript/New_in_JavaScript/1.8">JavaScript 1.8</a> support.
It has been optimized specifically for OpenBD to integrate it to the CFML language with minimal fuss.
</p>

<ul>
	<li style="color:black">Read/Write to CFML scopes from within JavaScript (varibles, form, url, cgi, session, client, application)</li>
	<li style="color:black">Define JavaScript functions that are callable from CFML</li>
	<li style="color:black">Call out to CFML functions from within JavaScript using <code>$cf</code></li>
	<li style="color:black">Load external JavaScript libraries into the scope</li>
</ul>

<p>
This powerful and deep integration gives you the best of both worlds, dropping in and out of either language depending on what you want to achieve.   This
deep relationship permits you to write your complete server side application in pure JavaScript.
</p>

<h2>Getting Started</h2>

<p>
To start embedding JavaScript into your pages, simply define the <code>&lt;CFSCRIPT language="javascript"&gt;</code>, making sure you have the language
attribute set to "javascript", and start writing JavaScript code.  No special setup, no restart, just write it.   Consider the following very simple
example, that defines a Javascript function, that takes in two parameters, adds them together and returns the result.
</p>

<cfsavecontent variable="t" trim="true"><nocfml>
<cfscript language="javascript">
function addNumbers( a, b ){
  return a+b;
}

var r = addNumbers(2,8);

$cf.print( r );
</cfscript>

<cfset result = addNumbers(1, 3)>
</nocfml>
</cfsavecontent>

<pre class="cfml"><cfoutput>#XmlFormat(t)#</cfoutput></pre>

<p>
As you can see, we are calling it inside the JavaScript block and assigning the result to <code>r</code>.  We are then printing out the value of <code>r</code>
to the output using the special helper JavaScript function <code>$cf</code>.  This is very similiar to how you think of the JQuery <code>$</code> global
variable.  In OpenBD, <code>$cf</code>, is always available and gives you a window into the CFML world.  More later.
</p>

<p>
In addition to calling the function inside the JavaScript block, any JavaScript function that is defined, is automatically exported to the CFML page as a whole
and made available to the the rest of the CFML processing.  The example shows us calling the JavaScript function from outside the JavaScript world.
</p>

<h2>CFML Variables</h2>

<p>
CFML has a number of <a href="./?/language_scopes">different scopes</a> of variables available.   The popular ones are available to the JavaScript block as top
level variables (varibles, form, url, cgi, session, client, application) which can be accessed directly.
</p>

<cfsavecontent variable="t" trim="true"><nocfml>
<cfscript language="javascript">
variables.person = {
  name : "Alan",
  location : "Scotland"
};

if ( variables.person.name == "Alan" ){
  $cf.print( variables.person.location );
}
</cfscript>
</nocfml>
</cfsavecontent>

<pre class="cfml"><cfoutput>#XmlFormat(t)#</cfoutput></pre>

<p>
This example illustrates getting access to the standard 'variables' scope and setting/reading elements.   In CFML the <code>variables</code> scope is implicit
and not necessary to define all the time in CFML code.  Inside JavaScript however, you have to specificaly reference it, other wise any variable you declare
inside the block will be localized to JavaScript and not available to the CFML application.
</p>

<h2>Global Functions</h2>

<p>
As discussed the <code>$cf</code> is a global variable that lets you interact with the CFML runtime world.  It provides a number of helper methods.
</p>

<table>
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td>print(.)</td>
		<td>This is similar to <a href="./?/function/writeoutput">WriteOutput()</a> function letting you quickly output to the browser window.</td>
	</tr>
	<tr>
		<td>console(.)</td>
		<td>This is similar to <a href="./?/function/console">Console()</a> function letting you quickly output to the debugging console.</td>
	</tr>
	<tr>
		<td>load(.)</td>
		<td>Loads in an external file that has JavaScript defined in it.  This is like the JavaScript version of <a href="./?/function/renderinclude">renderInclude</a></td>
	</tr>
	<tr>
		<td nowrap>$cf.tocfml(.)</td>
		<td>This is convience method to let you set a JavaScript variable into the CFML world.</td>
	</tr>
	<tr>
		<td>$cf.get(.)</td>
		<td>This lets you get at a complex CFML variable from inside JavaScript.</td>
	</tr>
	<tr>
		<td nowrap>$cf.XXXXX(.)</td>
		<td>This is how you get at core CFML functions from inside JavaScript.  You can call any core CFML function using this technique.   You cannot (yet) call user defined functions using this technique.</td>
	</tr>
</tbody>
</table>

<p>
An example of calling out to a core CFML function from inside JavaScript
</p>

<cfsavecontent variable="t" trim="true"><nocfml>
<cfscript language="javascript">
var g = $cf.left( "alan", 2 );
</cfscript>
</nocfml>
</cfsavecontent>

<pre class="cfml"><cfoutput>#XmlFormat(t)#</cfoutput></pre>

<h2>The future</h2>

<p>
The integration with JavaScript and CFML opens up some exciting possibilities.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->