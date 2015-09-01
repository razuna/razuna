<cfset request.page.title = "Webservices">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "CFML can easily consume and produce webservices from a wide range of protocols.">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/webservices"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

	<h1>Web Services</h1>
	
	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">
	
<p>
CFML is more than just a web scripting language.  It is a full web services engine that makes building and consuming web services extremely easy and at the hands
of everyone.   Webservices are a means to which to allow other applications and servers to reach into your application and utilise your data or services as part of their
application.
</p>

<p>
Many of the web services protocols can be intimadating and confusing.   Complicated protocols such as <a href="http://en.wikipedia.org/wiki/SOAP">SOAP (Simple Object Access Protocol)</a>,
are difficult to setup and advertise on servers using other languages.  Not so with CFML.
</p>

<p>
People are often amazed at how little effort is required to consume a webservice, or even turn a CFC into a full blown first class SOAP citizen or RESTlet call.   This section will explain
how easy it is to produce a full blown web services end point, satisfying any protocol you desire.
</p>

<ul>
	<li><a href="./?/webservices_restlet">Simple RESTlet RPC call</a></li>
	<li><a href="./?/webservices_json">AJAX/JSON calls</a></li>
	<li><a href="./?/webservices_soap_producing">Creating SOAP endpoints</a></li>
	<li><a href="./?/webservices_soap_consuming">Using SOAP endpoints</a></li>
</ul>

<p>
Finally, one of the most complicated popular SOAP services available <a href="./?/webservices_salesforce">is that from SalesForce</a>.  We will show how OpenBD can
easily utilise this very rich API from <a href="http://www.salesforce.com/">SalesForce</a>, to build and extend full enterprise apps.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->