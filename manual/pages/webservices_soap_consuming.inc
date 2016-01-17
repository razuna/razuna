<cfset request.page.title = "Webservices SOAP consuming">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "CFML can easily consume any SOAP endpoint">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/advanced">Advanced</a></li>
      <li class="active"><a href="./?/webservices_soap_consuming"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Web Services: Consuming SOAP endpoints</h1>
		
		<cfinclude template="pages/sidebar_advanced.inc" />
	
		<div class="section">

<p>
CFML makes it extremely easy to consume and use SOAP within CFML applications.   There are two primary ways to consume a remote SOAP endpoint; tag based and function based.
</p>

<p>
What is common between both methods is that you will need access to the remote WSDL that describes the SOAP endpoint you are attempting to communicate to.  The WSDL describes
how the client can interact and what methods and types are required.
</p>


<h2>CFINVOKE</h2>

<p>
You can use the <a href="./?/tag/CFINVOKE">CFINVOKE</a> tag to remotely execute code against a SOAP server.   For example, let us assume we have the WSDL for a remote
object (in our case another CFC), that we can invoke commands on.   The tag, requires the <strong>webservice</strong> attribute that describes the URL to the WSDL object.
Next, we need to tell the CFINVOKE command which function we wish to execute, using the <strong>method</strong> attribute.  Finally we use the <strong>returnvariable</strong>
to store any result the function will return.
</p>

<pre class="cfml">
&lt;cfinvoke webservice="http://myhost.com/rpc/mycfc.cfc?wsdl"
          method="run"
          returnvariable="result"/>

&lt;cfdump var="#result#">
</pre>

<p>
Passing in paramaters is simply done by adding in the attributes for each of the parameters the function requires.
</p>

<pre class="cfml">
&lt;cfset myStruct = {
  key1:"data",
  key2:"sample data"
  }>

&lt;cfinvoke webservice="http://myhost.com/rpc/mycfc.cfc?wsdl"
          method="run"
          param1="this is a parameter"
          param2="#myStruct#"
          returnvariable="result"/>

&lt;cfdump var="#result#">
</pre>

<p>
Alternatively you can use the <a href="./?/tag/CFINVOKEARGUMENT">CFINVOKEARGUMENT</a> embedded tag to pass in arguments to the remote object.
</p>

<pre class="cfml">
&lt;cfinvoke webservice="http://myhost.com/rpc/mycfc.cfc?wsdl"
          method="run"
          returnvariable="result">
  &lt;cfinvokeargument name="param1" value="this is a parameter"/>
  &lt;cfinvokeargument name="param1" value="this is a parameter"/>
&lt;/cfinvoke>

&lt;cfdump var="#result#">
</pre>


<h2>CreateComponent</h2>

<p>
The alternative to <a href="./?/tag/CFINVOKE">CFINVOKE</a> is to use the function <a href="./?/function/createobject">CreateObject</a> which lets you create the remote
object and use this a first class object within your CFML application.
</p>

<pre class="cfml">
remoteObj = CreateObject("webservice", "http://myhost.com/rpc/mycfc.cfc?wsdl");
returnResult = remoteObj.run("param1", "param2");
</pre>

<p>
Once you make the call to <a href="./?/function/createobject">CreateObject</a>, the OpenBD engine creates the local object stubs that lets this object exist within the local
environment.  After that, any call to a method on this function will invoke the function over the wire, remotely to the SOAP endpoint.   If you dump this object, you will see
all the properties and methods available to this object that you are able to call.
</p>

<p>
If the network or the server becomes unavailable between the creation and the invocation of a method, then a remote exception will be thrown.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->