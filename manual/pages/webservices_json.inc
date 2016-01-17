<cfset request.page.title = "Webservices JSONP support">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "CFML can easily answer JSONP calls from any ajax enabled web application">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/webservices_json"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Web Services JSONP support</h1>
		
		<cfinclude template="pages/sidebar_advanced.inc" />
	
		<div class="section">

<p><a href="http://bob.pythonmac.org/archives/2005/12/05/remote-json-jsonp/">JSONP (JSON with Padding)</a> lets you achieve cross-domain data fetching from any Javascript function running inside a browser.</p>

<p>JSONP requires a little assistance from both the server and the client inorder for it to work.  JSONP works by wrapping the returning JSON packet in () and prepending a name to make it into a Javascript document.</p>

<p>The majority of Javascript libraries support JSON from their native core.  <a href="http://docs.jquery.com/Ajax/jQuery.getJSON#urldatacallback">JQuery</a> supports it using <strong>$.getJSON</strong> method, which simply asks that you append the URI parameter "callback=?" to the end of the remote URL and it will do all the marshalling of data for you.</p>

<h2>Enabling JSONP in OpenBD</h2>

<p>Before you do that, you have to tell OpenBD that this is a JSONP request and allow it the opportunity to post-process the packet for you.   You do this using the existing <strong>__BDRETURNFORMAT</strong> parameter flag and setting it to "jsonp".    OpenBD will look for the "callback" parameter and the take the necessary action for you accordingly.</p>

<p>An example of this in action from standard JQuery:</p>

<pre class="cfml">
$.getJSON(
  "http://myhost/rpc/mycfc.cfc?method=run&__BDRETURNFORMAT=jsonp&callback=?",
  function(json){
    // do something with the 'json' object
  }
);
</pre>

<p>The advantage of this, is that you do not need to modify your existing CFC's inorder for them to be consumed using JSONP methods.  There is also huge memory and performance gains to be had, letting the core engine do all the heavy lifting instead of the existing workarounds written in CFML.</p>

<h2>Controlling incoming data</h2>

<p>OpenBD has enabled a number of flags that the remote REST client can use to help format the data coming back from the server without having to touch your CFC.</p>

<ul>
	<li><strong>method=myFunction</strong>
	<br/>This determines which function of the CFC will be called (required)
	</li>

	<li class="padtop"><strong>__BDRETURNFORMAT=wddx|plain|json|jsonp</strong>
	<br/>This determines how the function will format its return content.
	</li>

	<li class="padtop"><strong>__BDNODEBUG</strong>
	<br/>If this parameter exists, any error the CFC throws will be surpressed.  This stops the full error stack page to be sent to the remote caller.
	</li>

	<li class="padtop"><strong>__BDQUERYFORMAT=column|row</strong>
	<br/>If the CFC is returning back a CFML Query object, then this controls how the data is represented, either as an array of rows, or array of columns.
	</li>

</ul>

<p>Through the use of these (case insensitive) flags you can control how you wish the data to be presented by the client instead of having to modify any server-side code, making it easier for you to offer greater flexibility to your web services clients.</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->