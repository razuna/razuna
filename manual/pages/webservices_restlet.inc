<cfsilent>
	<cfset request.page.title = "Webservices RESTlet support">
	<cfset request.page.section = "adv">
	<cfset request.page.desc	= "CFML can easily answer basic RESTlet calls from any ajax enabled web application">
</cfsilent>

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/advanced">Advanced</a></li>
      <li class="active"><a href="./?/webservices_restlet"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>

<div class="content" id="content">
	<div class="container cf">
	
	<h1>Web Services RESTlet support</h1>
	
	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">

<p>Any CFC can be made into a remote RESTlet service endpoint by simply enabling the <strong>access="remote"</strong> attribute on a function within a component.  Once enabled, this function
can be called directly using standard HTTP protocols without first binding it to a CFML page.   Even though it is not bound to a specific CFML page, it still obeys the rules of
a CFML application in that the <a href="./?/app_application">Application.cfc/.cfm</a> will still be sought and run prior to any call.</p>

<pre class="cfml">
&lt;cfcomponent>
  &lt;!--- assume this is saved @ /rpc/mycfc.cfc --->

  &lt;cffunction name="run" access="remote" returntype="string">
    &lt;cfreturn "from a remote">
  &lt;/cffunction>

&lt;/cfcomponent>
</pre>

<p>This method is now available for consumption through a simple RESTlet call using the following endpoint:</p>

<ul>
  <li>http://myhost.com/rpc/mycfc.cfc?method=run</li>
</ul>

<p>The RESTlet call is most useful for Javascript based applications, allowing you to consume and trigger CFC from within any
web page running on your server.   A CFC called in this manner can have a number of different return formats using
the <strong>returnformat="wddx|plain|json|jsonp"</strong> attribute of a function.</p>

<h2>Passing parameters to a RESTlet endpoint</h2>

<p>The only pre-defined parameter that must be present in every RESTlet call is the <strong>method</strong> which designates which function within the CFC will be invoked.   Any other
parameter passed in the URI string is assumed to be an argument to the function.</p>

<p>There are two options for retreiving the parameters within the CFC that is acting as the RESTlet endpoint.</p>

<ul>
  <li>Use the standard <strong>url</strong> scope</li>
  <li>Define the <a href="./?/tag/CFARGUMENT">CFARGUMENT</a> for each parameter</li>
</ul>

<p>The advantage of using the <a href="./?/tag/CFARGUMENT">CFARGUMENT</a> technique allows you to keep your CFC object generic as possible, allowing it to be used internally within your
application without having to setup the <strong>url</strong> scope to simulate a remote call.   The main selling point, is that it allows your CFC to advertise the parameters it requires
and if not present, the engine will do all the work for you in terms of validation and defaulting.</p>

<pre class="cfml">
&lt;cfcomponent>

  &lt;cffunction name="run" access="remote" returntype="string">
    &lt;cfargument name="param1" required="true" />
    &lt;cfargument name="param2" required="false" default="true" />
    &lt;cfreturn arguments.param1 & arguments.param2>
  &lt;/cffunction>

&lt;/cfcomponent>
</pre>

<p>Having defined your parameters/arguments for your CFC function, this then allows you to pass in data to the CFC using the following syntax.</p>

<ul>
  <li>http://myhost.com/rpc/mycfc.cfc?method=run&amp;param1=TestParam</li>
</ul>

<h2>Returning rich objects back</h2>

<p>Web services are usually designed to return raw data, and leave the formatting or UI to some other process.  This is the core reason to offer Web Services to your application, freeing
up your data, permits 3rd parties to innovate with your service.   CFC's called in this manner are not limited to returning simple plain text - it can manage rich objects (structures, arrays,
queries) using WDDX or JSON.</p>

<p>The good news is that you do not have to manually encode the output; the underlying OpenBD engine will do all the transformations for you.  All you have to do is to simply set the
<strong>returnformat="json|plain|wddx|jsonp"</strong> attribute of the function in question, and the engine will do everything for you (note only simple types can be returned if PLAIN|JSONP)</p>

<pre class="cfml">
&lt;cfcomponent>

  &lt;cffunction name="run" access="remote" returntype="struct" returnformat="json">
    &lt;cfargument name="param1" required="true" />
    &lt;cfargument name="param2" required="false" default="true" />

    &lt;cfset myStruct = StructNew()>
    &lt;cfset myStruct.param1 = arguments.param1>

    &lt;cfreturn myStruct>
  &lt;/cffunction>

&lt;/cfcomponent>
</pre>

<p>When invoked internally by another CFC or page this function will return a standard struct object.  If, however, called via a RESTlet remote call, this function will return the same
structure but encoded as JSON text <strong>{"param1":"TestParam"}</strong>.</p>

<p>The remote caller can override the return format, by specifying the desired encoding method using <strong>__BDRETURNFORMAT</strong> in the calling parameter. For example, to encode
the structure as an XML packet you could use:</p>

<ul>
  <li>http://myhost.com/rpc/mycfc.cfc?method=run&amp;param1=TestParam&amp;__BDRETURNFORMAT=wddx</li>
</ul>

<h2>Pre-defined parameters</h2>

<p>Remotely calling CFC's can support a number of other directives that lets the calling party control its execution.</p>

<ul>
	<li><strong>method=myFunction</strong>
	<br/>This determines which function of the CFC will be called (required)
	</li>

	<li class="padtop"><strong>__BDRETURNFORMAT=wddx|plain|json|jsonp</strong>
	<br/>This determines how the function will format its return content (note only simple types can be returned if PLAIN|JSONP).
	</li>

	<li class="padtop"><strong>__BDNODEBUG</strong>
	<br/>If this parameter exists, any error the CFC throws will be surpressed.  This stops the full error stack page to be sent to the remote caller.
	</li>

	<li class="padtop"><strong>__BDJSONCASE</strong>
	<br/>If this parameter exists and the return format is JSON, then this controls the case of the keys of the resulting JSON (lower, upper or maintain [default])
	</li>

	<li class="padtop"><strong>__BDQUERYFORMAT=column|row</strong>
	<br/>If the CFC is returning back a CFML Query object, then this controls how the data is represented, either as an array of rows, or array of columns.
	</li>

</ul>


<h2>Cross-Domain Support</h2>

<p>RESTlet calls are very powerful mechanisms for providing a very simple straight forward web service facility to your applications.   Any server will be able to talk to your endpoint
and interact with your application.</p>

<p>However, what if you wish your services to be consumed by a Javascript function outside of your own domain?  Cross-domain scripting will prevent this.   So how do the likes of <a href="http://delicious.com/help/json">delicious.com</a> offer such Javascript integrations for their services?</p>

<p>You achieve this by using <a href="http://bob.pythonmac.org/archives/2005/12/05/remote-json-jsonp/">JSONP (JSON with Padding)</a> and this lets you achieve cross-domain data fetching.  Fortunately, OpenBD supports this protocol straight out of the box.  <a href="./?/webservices_json">Discover about JSONP support</a>.</p>

		</div><!--- .section --->
		
	</div><!--- .container --->
</div><!--- .content --->