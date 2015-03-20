<cfset request.page.title = "Webservices SOAP end point support">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "CFML can easily turn any CFC into a remote SOAP endpoint">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/advanced">Advanced</a></li>
      <li class="active"><a href="./?/webservices_soap_producing"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">
	
	<h1>Web Services: Creating SOAP endpoints</h1>
	
	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">
	
<p>
SOAP differs from the easier RESTlet based webservices in that they advertise and manage remote objects.   SOAP allows for the most complex of webservices to be designed
and built, by offering more than simple remote function calls.   A SOAP transaction permits the creation of remote objects, that can be passed around like local objects, but
when methods are called, they are executed on the remote server, not the local server.
</p>

<p>
SOAP objects are advertised to consumers using a <a href="http://en.wikipedia.org/wiki/Web_Services_Description_Language">WSDL (Web Services Description Language)</a>
definition file.   This WSDL file is an XML document that describes all the properties of the remote object, including how to call it and what object types are further
returned.   The WSDL file is the key to successful SOAP operation.   It is this XML document, that can be used locally, or loaded remotely via a URL on demand lets the
client know how to interact with the remote object.
</p>

<p>
As you know, CFML makes the creation of objects very easy using the <a href="./?/cfc_introduction">CFC model</a>.  Turning these objects into SOAP objects is done automatically,
by simply calling their URL's by adding in the ?WSDL param.   Take for example the following CFML CFC.  It has 3 methods, but yet we only expose 2 of them as remote methods.
</p>

<pre class="cfml">
&lt;cfcomponent>
  &lt;!--- assume this is saved @ /rpc/mycfc.cfc --->

  &lt;cffunction name="run" access="remote" returntype="string">
    &lt;cfreturn "from a remote">
  &lt;/cffunction>

  &lt;cffunction name="getTime" access="remote" returntype="string">
    &lt;cfreturn now()>
  &lt;/cffunction>

  &lt;cffunction name="internalMethod" access="private" returntype="string">
    &lt;cfreturn "from a internal method">
  &lt;/cffunction>

&lt;/cfcomponent>
</pre>

<p>
This method is now available for use by any SOAP client using the following WSDL:
</p>

<ul>
  <li>http://myhost.com/rpc/mycfc.cfc?WSDL</li>
</ul>

<p>
You can access this URL using any browser.  This will return the WSDL XML document that describes this CFC as a remote accessible SOAP object.   You can then use this WSDL
with any SOAP client for remote execution.
</p>

<p>
That is all you have to do - simply add <strong>?WSDL</strong> to any CFC endpoint and the SOAP container will automatically be created for you, ready for use.  Contrast this to
the complexity that is required by other languages, then you discover how quickly and powerful you can make your CFML applications work with webservices.
</p>

<p>
Next discover how to <a href="./?/webservices_soap_consuming">consume remote SOAP endpoints</a>.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->