<cfset request.page.section = "basic">
<cfset request.page.title = "Application.cfc">
<cfset request.page.desc	= "Application.cfc is a richer alternative to Application.cfm">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/basic_cfml">Basic CFML</a></li>
			<li class="active"><a href="./?/app_application_cfc"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Application.cfc</h1>

		<cfinclude template="pages/sidebar_basic.inc" />
		
		<div class="section">
		
<p>
Application.cfc is a richer alternative to Application.cfm, giving you hooks into various states and life cycle points of an application and request.
Packaged as a standard CFC, you override the methods you wish to provide processing for and the engine will take care of the rest.
</p>

<p>
As with any other CFC, this component can be overridden, subclassed and reused.  There is very little restrictions as to what you can do with this particular
component.   The location of this file is the same as the Application.cfm, in that, OpenBD will look for it in the same directory as the requesting template
and continue up the parent directory stack until it finds one.  Please note the case of this file is very important - the capital "A" is required.
</p>

<p>
Application.cfc reduces the complexity of managing cfApplication's as you do not have to worry about complicated locking techniques to avoid initialization
duplicates at startup if multiple requests hit it at once.   By utilising the Application.cfc method, you do not require any CFAPPLICATION tag.
</p>

<h2>Method Hooks</h2>

<p>The following methods can be defined:</p>

<ul>
	<li><code>onApplicationStart()</code>
	<br/>Called when the application is first initialized.  This method will only be called once.
	</li>

	<li class="padtop"><code>onApplicationEnd()</code>
	<br/>Called when the application is being unloaded due to inactivity.  This method will only be called once.
	</li>

	<li class="padtop"><code>onClientStart()</code>
	<br/>Called when the client request is found not to previously exist and has just been freshly created.  This method is only valid if the client management has been enabled
	for this application.
	</li>

	<li class="padtop"><code>onSessionStart()</code>
	<br/>Called when the session request is found not to previously exist and has just been freshly created. This method is only valid if the session management has been enabled
	for this application.
	</li>

	<li class="padtop"><code>onSessionEnd( session, appdata )</code>
	<br/>Called when the session has ended, passing in the current session and application data that was part of this session
	</li>

	<li class="padtop"><code>onError( catchdata, eventname )</code>
	<br/>If an error occurs within the application, then this method is called passing in the catchdata and the eventname of the error.
	</li>

	<li class="padtop"><code>onRequest( pageuri )</code>
	<br/>Used when you want to replace the processing for a given template.  If this method is found then the calling template will not be called.
	</li>

	<li class="padtop"><code>onCFCRequest( cfcname, cfcmethod, args )</code>
	<br/>Used when you want to replace the processing for remote CFC methods.  If this method is found then the CFC will not be called but instead this method.
	</li>

	<li class="padtop"><code>onRequestStart( pageuri )</code>
	<br/>Called when a request has just come in and is ready for processing.  Called before the template.
	</li>

	<li class="padtop"><code>onRequestEnd( pageuri )</code>
	<br/>Called when a request has completed and is called after the requesting template has fininshed.
	</li>

	<li class="padtop"><code>onMissingTemplate( pageuri )</code>
	<br/>Called when a request for a missing template is made.
	</li>

	<li class="padtop"><code>onMissingMethod( methodName, methodArguments )</code>
	<br/>If a call is made to a method that is not found, then this method is then triggered passing in the relevant method arguments and name.
</ul>

<h2>Defining cfApplication Properties</h2>

<p>
The standard cfApplication has properties that are associated with it and these are historically defined using the attributes of the CFAPPLICATION tag.  This tag is not
required when using the Application.cfc method.   Instead, you define the properties of the cfApplication as top level object variables, using CFSCRIPT or CFSET.
</p>

<ul>
	<li><code>this.name</code>
	<br/>Defines the name of the cfApplication; this is just a plain string value
	</li>
	<li class="padtop"><code>this.scriptprotect</code>
	<br/>This boolean determines if the script protection layer is enabled
	</li>
	<li class="padtop"><code>this.mappings</code>
	<br/>This structure contains the mappings for this application
	</li>
	<li class="padtop"><code>this.customTagPaths</code>
	<br/>This is a string denoting the list of paths that will be searched before the standard custompath
	</li>
	<li class="padtop"><code>this.applicationtimeout</code>
	<br/>This is the length of time, defined as a factor of a date (use CreateTimeSpan()) that this application will be available in memory after no requests are made to it.
	</li>
	<li class="padtop"><code>this.sessiontimeout</code>
	<br/>This is the length of time, defined as a factor of a date (use CreateTimeSpan()) that this session will be available in memory after no requests are made to it.
	</li>
	<li class="padtop"><code>this.setclientcookies</code>
	<br/>This boolean controls whether or not client cookies will be used.
	</li>
	<li class="padtop"><code>this.sessionmanagement</code>
	<br/>This boolean controls whether or not session management is enabled.
	</li>
	<li class="padtop"><code>this.sessionstorage</code>
	<br/>This is the URI connection string to where the session data can be stored.  See the section below on the session storage
	</li>
	<li class="padtop"><code>this.setdomaincookies</code>
	<br/>This boolean controls whether domain cookies will be used instead of full server name cookies.
	</li>
	<li class="padtop"><code>this.clientmanagement</code>
	<br/>This boolean controls whether or not client management is used.
	</li>
	<li class="padtop"><code>this.clientstorage</code>
	<br/>This string controls the client storage method.  Valid values are: COOKIE, REGISTRY or DATASOURCE
	</li>
	<li class="padtop"><code>this.loginstorage</code>
	<br/>This string controls the login storage method.  For use with CFLOGIN
	</li>
	<li class="padtop"><code>this.securejson</code>
	<br/>This boolean controls whether or not SecureJSON feature is used in WebServices communications.
	</li>
	<li class="padtop"><code>this.securejsonprefix</code>
	<br/>If the secure JSON flag is set, this variable lets you define the prefix that will be used for the JSON prefix.
	</li>
	<li class="padtop"><code>this.datasource</code>
	<br/>The default datasource for this application that CFQUERY/CFSTOREDPROC/QueryRun() will use if one is not explicitly defined.
	</li>
</ul>


<h2>Session Storage - Cluster/Enterprise</h2>

<p>
	By default, session objects are stored within the server they are running.  If you have a cluster of machines, then sharing sessions across the servers is impossible
	unless you use the underlying J2EE session management facilities.  However, this has a number of problems.   Firstly the J2EE server you are running OpenBD upon may not
	easily or quicly support session sharing in a manner that would allow you to operate.  For example, some implementations rely on technologies (multicast) that are not
	able to run in certain cloud implementations (Rackspace/Amazon).  Secondly, the J2EE session management is not as powerful as that on offer, and you expect, from the CFML
	world.
</p>

<p>
	OpenBD makes it easy to make your applications run across multiple servers seemlessly without you have to worry about the logistics of moving the session scope around.
</p>

<p>
	You have the choice of using the following storage engines:
</p>

<ul>
	<li>Default in memory</li>
	<li>J2EE Session Management</li>
	<li>Memcached/CouchBase servers (this.sessionstorage = 'memcached://10.0.0.1:11211';)</li>
	<li>MongoDB servers (this.sessionstorage = 'mongo://10.0.0.1:27017';)</li>
</ul>

<p>
	<strong>Memcached/CouchBase Configuration</strong>
</p>

<p>
	You can easily use a remote farm of Memcached (or CounchBase) servers by specifying the connection URI: <strong>memcached://server1:27017 server1:27017</strong>
</p>

<p>
	<strong>MongoDB Configuration</strong>
</p>

<p>
	More efficient than Memcached is the MongoDB storage engine.  Sessions are loaded and saved to remote MongoDB servers (configured in a replic or sharded set).  Sessions that have
	not changed, are efficiently handled as to not incurr the overhead of always moving data around.  With the MongoDB connection URI, you can specify the Mongo database to use, though
	it defaults to 'openbd' with the collection 'sessions'.
</p>

<p>
	The connection string format is: <strong>mongo://[user@pass:]server1:port1 server2:port2[/db]</strong>.  Examples:
</p>

<ul>
	<li>mongo://10.0.0.1:27017</li>
	<li>mongo://user1@pass1:10.0.0.1:27017</li>
	<li>mongo://10.0.0.1:27017 10.0.0.2:27017</li>
	<li>mongo://10.0.0.1:27017 10.0.0.2:27017/CustomDB</li>
	<li>mongo://user1@pass1:10.0.0.1:27017 10.0.0.2:27017/CustomDB</li>
</ul>

<p>
	<strong>Notes</strong>
</p>

<ul>
	<li>The complete 'session' scope is stored in the remote storage</li>
	<li>All data types; simple, struct, queries, arrays and loaded objects are supported</li>
	<li>For the best performance keep the amount of data held in the session to a minimum</li>
	<li>The bluedragon.log file will detail any errors with connections that may happen; if a connection is loss, the session will be reset</li>
</ul>


<h2>Sample Application.cfc</h2>

<p>
The following is a short sample of a Application.cfc that may be used.
</p>

<pre class="cfml">
&lt;cfcomponent>

  &lt;cfset this.name = "myApplication">

  // alternatively you can do this inside a cfscript block
  &lt;cfscript>
    this.sessionmanagement = false;
    this.clientmanagement = false;
  &lt;/cfscript>

  &lt;cffunction name="onApplicationStart">
    // your code to initialise the variables that will go in "application" scope
    &lt;cfset application.datasource = "myDatasource">
  &lt;/cffunction>

  &lt;cffunction name="onRequestStart">
    &lt;cfargument name="requesturi" required="true"/>
  &lt;/cffunction>

&lt;/cfcomponent>
</pre>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->