<cfset request.page.section = "basic">
<cfset request.page.title = "Server.cfc">
<cfset request.page.desc	= "Server.cfc is a file that is called once at startup">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/basic_cfml">Basic CFML</a></li>
      <li class="active"><a href="./?/app_server_cfc"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Server.cfc</h1>
		
		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">
		
<p>
If you find you need for some initialization to be performed when the server starts up you can hook into the <strong>Server.cfc</strong> functionality.
This is a CFC that OpenBD will look for and execute before it starts accepting requests from clients.
</p>

<p>
By default, OpenBD looks for the CFC in the root of the app folder <strong>/Server.cfc</strong> and like the Application/cfc/cfm the case of this file matters.
You can change the location of this file by setting it in the bluedragon.xml file.  For example, the following snippet from that bluedragon.xml is below:
</p>

<pre class="cfml">
&lt;server>
  &lt;system>
    &lt;servercfc>/WEB-INF/Server.cfc&lt;/servercfc>
    ...
  &lt;/system>
  ...
&lt;/server></pre>

<p>This CFC is a standard CFML component that obeys all the usual rules.  The only requirement is that you must provide an implementation for the
<strong>onServerStart</strong> method.  This is the method that OpenBD will locate and execute when the engine first starts up.</p>

<pre class="cfml">
&lt;cfcomponent>

  &lt;cffunction name="onServerStart">
    // you startup code here
  &lt;/cffunction>

&lt;/cfcomponent>
</pre>

<p>
Any errors that occur here will be logged in the bluedraogn.log with the corresponding error dump written out in the usual error folder.
</p>

<p>
There are very little restrictions as to what you can do in this file.  Naturally because the engine is calling this file, there is no output associated with it.
Also many of the tags/functions that are geared towards web processing (for example set status code) will have no effect.
</p>

<p>
This is a particular useful feature for setting up global objects that only need to initialised once and can be used throughout every application and page request.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->