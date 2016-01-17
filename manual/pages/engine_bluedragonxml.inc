<cfsilent>
<cfset request.page.section = "engine">
<cfsavecontent variable="b"><nocfml><?xml version="1.0" encoding="UTF-8"?>
<server>
  <system>
    <a href="#buffersize" class="anc"><buffersize>0</buffersize></a>
    <a href="#assert" class="anc"><assert>true</assert></a>
    <a href="#missingtemplatehandler" class="anc"><missingtemplatehandler>/missingTemplateHandler.cfm</missingtemplatehandler></a>
    <a href="#tempdirectory" class="anc"><tempdirectory>/WEB-INF/work/temp</tempdirectory></a>
    <a href="#runtimelogging" class="anc"><runtimelogging>true</runtimelogging></a>
    <a href="#runtimeloggingmax" class="anc"><runtimeloggingmax>100</runtimeloggingmax></a>
    <a href="#defaultcharset" class="anc"><defaultcharset>UTF-8</defaultcharset></a>
    <a href="#component-cfc" class="anc"><component-cfc>/WEB-INF/bluedragon/component.cfc</component-cfc></a>
    <a href="#scriptsrc" class="anc"><scriptsrc>/bluedragon/scripts/</scriptsrc></a>
    <a href="#debug" class="anc"><debug>true</debug></a>
    <a href="#scriptprotect" class="anc"><scriptprotect>true</scriptprotect></a>
		<a href="#scriptprotectregex" class="anc"><scriptprotectregex>&lt;(\s*)(object|embed|script|applet|meta)</scriptprotectregex></a>
    <a href="#nativelibdir" class="anc"><nativelibdir>/WEB-INF/bin</nativelibdir></a>
    <a href="#errorhandler" class="anc"><errorhandler>/defaultErrorHandler.cfm</errorhandler></a>
    <a href="#whitespacecomp" class="anc"><whitespacecomp>false</whitespacecomp></a>
    <a href="#formurlcombined" class="anc"><formurlcombined>false</formurlcombined></a>
    <a href="#formurlmaintaincase" class="anc"><formurlmaintaincase>false</formurlmaintaincase></a>
    <a href="#strictarraypassbyreference" class="anc"><strictarraypassbyreference>false</strictarraypassbyreference></a>
    <a href="#legacyformvalidation" class="anc"><legacyformvalidation>true</legacyformvalidation></a>
    <a href="#functionscopedvariables" class="anc"><functionscopedvariables>false</functionscopedvariables></a>
    <a href="#rewritebluedragonxml" class="anc"><rewritebluedragonxml>true</rewritebluedragonxml></a>
    <a href="#libpath" class="anc"><libpath>/diff/path/for/jar/files/</libpath></a>
    <a href="#jsoncase" class="anc"><jsoncase>maintain</jsoncase></a>
    <a href="#jsondate" class="anc"><jsondate>long</jsondate></a>
	<a href="#cfoutputshorthand" class="anc"><cfoutputshorthand>true</cfoutputshorthand></a>
	<a href="#journal" class="anc"><journal>youruniquetoken</journal></a>
	<a href="#journalmb" class="anc"><journalmb>50</journalmb></a>
	<a href="#journalignoreuri" class="anc"><journalignoreuri>/journal</journalignoreuri></a>
  </system>

  <a href="#mappings" class="anc"><cfmappings>
    <mapping name="/test">
      <directory>C:\test</directory>
      <name>/test</name>
    </mapping>
    <mapping name="/machii">
      <directory>/WEB-INF/MachII</directory>
      <name>/machii</name>
    </mapping>
  </cfmappings></a>

  <a href="#file" class="anc"><file>
    <maxfiles>1000</maxfiles>
    <trustcache>true</trustcache>
  </file></a>

  <a href="#javacustomtags" class="anc"><javacustomtags>
    <classes>/WEB-INF/classes</classes>
    <mapping name="cfx_javabluedragonhello">
      <name>cfx_javabluedragonhello</name>
      <displayname>CFX_JavaBlueDragonHello</displayname>
      <description>A simple Java CFX tag example</description>
      <class>com.newatlanta.BlueDragonHello</class>
    </mapping>
  </javacustomtags></a>

  <a href="#nativecustomtags" class="anc"><nativecustomtags>
    <mapping name="cfx_nativebluedragonhello">
      <function>ProcessTagRequest</function>
      <keeploaded>true</keeploaded>
      <name>cfx_nativebluedragonhello</name>
      <module>/WEB-INF/customtags/BlueDragonHello.dll</module>
      <displayname>CFX_NativeBlueDragonHello</displayname>
      <description>A simple C++ CFX tag example</description>
    </mapping>
  </nativecustomtags></a>

  <a href="#cfchart" class="anc"><cfchart>
    <cachesize>100</cachesize>
    <storage>file</storage>
  </cfchart></a>

  <cfquery>
    <a href="#cfquery-cachecount" class="anc"><cachecount>1000</cachecount></a>
    <a href="#cfquery-validate" class="anc"><validate>true</validate></a>
    <a href="#cfquery-autoconfig-odbc" class="anc"><autoconfig-odbc>true</autoconfig-odbc></a>
    <a href="#cfquery-slowlog" class="anc"><slowlog>-1</slowlog></a>

    <a href="#cfquery-mysql" class="anc"><datasource name="mysql">
      <password></password>
      <connectionretries>0</connectionretries>
      <sqlupdate>true</sqlupdate>
      <sqldelete>true</sqldelete>
      <username></username>
      <drivername>com.mysql.jdbc.Driver</drivername>
      <sqlstoredprocedures>true</sqlstoredprocedures>
      <perrequestconnections>true</perrequestconnections>
      <sqlinsert>true</sqlinsert>
      <sqlselect>true</sqlselect>
      <connectiontimeout>120</connectiontimeout>
      <databasename>myDatabaseName</databasename>
      <initstring></initstring>
      <logintimeout>120</logintimeout>
      <hoststring>jdbc:mysql://localhost:3306/myDatabaseName?useUnicode=true</hoststring>
      <maxconnections>24</maxconnections>
      <connectionperpage>false</connectionperpage>
      <name>mysql</name>
    </datasource></a>

    <a href="#cfquery-sqlserver" class="anc"><datasource name="sqlserver">
      <password></password>
      <connectionretries>0</connectionretries>
      <sqlupdate>true</sqlupdate>
      <sqldelete>true</sqldelete>
      <username></username>
      <drivername>com.microsoft.sqlserver.jdbc.SQLServerDriver</drivername>
      <sqlstoredprocedures>true</sqlstoredprocedures>
      <perrequestconnections>false</perrequestconnections>
      <sqlinsert>true</sqlinsert>
      <sqlselect>true</sqlselect>
      <connectiontimeout>120</connectiontimeout>
      <databasename>myDatabaseName</databasename>
      <initstring></initstring>
      <logintimeout>120</logintimeout>
      <hoststring>jdbc:sqlserver://localhost:1433;databaseName=myDatabaseName</hoststring>
      <maxconnections>24</maxconnections>
      <name>sqlserver</name>
    </datasource></a>
  </cfquery>

  <debugoutput>
    <enabled>true</enabled>
    <executiontimes>
      <show>true</show>
      <highlight>250</highlight>
    </executiontimes>
    <exceptions>
      <show>true</show>
    </exceptions>
    <tracepoints>
      <show>true</show>
    </tracepoints>
    <database>
      <show>true</show>
    </database>
    <ipaddresses>127.0.0.1,192.168.200.16</ipaddresses>
    <variables>
      <url>true</url>
      <form>true</form>
      <cookie>true</cookie>
      <cgi>true</cgi>
      <client>true</client>
      <server>true</server>
      <request>true</request>
      <application>true</application>
      <session>true</session>
      <show>true</show>
      <variables>true</variables>
    </variables>
    <timer>
      <show>true</show>
    </timer>
  </debugoutput>

  <cfapplication>
    <j2eesession>true</j2eesession>
    <applicationtimeout>#CreateTimeSpan(2,0,0,0)#</applicationtimeout>
    <clientpurgeenabled>true</clientpurgeenabled>
    <sessiontimeout>#CreateTimeSpan(0,0,20,0)#</sessiontimeout>
    <cf5clientdata>false</cf5clientdata>
    <clientexpiry>90</clientexpiry>
    <enabled>true</enabled>
    <clientstorage>cookie</clientstorage>
    <clientGlobalUpdatesDisabled>true</clientGlobalUpdatesDisabled>
  </cfapplication>

  <a href="#cfmail" class="anc"><cfmail>
    <smtpserver>127.0.0.1,backup.smtp.com,[user:password@]server[:port],[user:password@]server2[:port</smtpserver>
    <threads>1</threads>
    <timeout>60</timeout>
    <charset>UTF-8</charset>
    <smtpport>25</smtpport>
    <catchemail></catchemail>
    <ratedelay>-1</ratedelay>
  </cfmail></a>

  <a href="#customtags" class="anc"><cfmlcustomtags>
    <mapping name="cf">
      <directory>/WEB-INF/customtags;C:\custom\tag\path</directory>
      <name>cf</name>
    </mapping>
  </cfmlcustomtags></a>
</server></nocfml>
</cfsavecontent>


<cfset b = Replace( b, "<", "&lt;", "ALL" ) >
<cfset b = Replace( b, "&lt;a ", "<a ", "ALL" ) >
<cfset b = Replace( b, "&lt;/a>", "</a>", "ALL" ) >

<cfset request.page.title = "OpenBD Engine: bluedragon.xml">
<cfset request.page.desc	= "OpenBD derives all its settings from the bluedragon.xml file">

</cfsilent>


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/engine">Server</a></li>
      <li class="active"><a href="./?/engine_bluedragonxml"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">OpenBD bluedragon.xml</h1>

		<cfinclude template="pages/sidebar_server.inc" />
		
		<div class="section">

<p>
The bluedragon.xml is the main configuration file for OpenBD.  The location of this file can be anywhere.  You specify the location of this file in the /WEB-INF/web.xml file with the BLUEDRAGON_XML parameter
to the cfmServlet servlet.  In addition, you can specify a remote URL in this parameter to load the XML file from a remote location.
</p>
		
<p>
The following is a sample bluedragon.xml file that ships with each installation.  Click on the various elements for a more
detailed explanation.
</p>

<style>a.anc { color: blue; text-decoration: none; }</style>

<pre><cfoutput>#b#</cfoutput></pre>


<a name="buffersize"></a><h3>buffersize</h3>
<p>Controls the size of the BlueDragon internal buffer used to store the rendered CFML page before handing the response to the J2EE server to be sent to the browser. After the response is given to the J2EE server, it's not possible to modify the response body using the CFHTMLHEAD or CFFORM tags; however, it may still be possible to set headers and cookies, to or modify the response content type. That is, giving the response to the J2EE server is not the same as flushing the response to the browser.</p>
<p>Using the smallest possible value for buffersize can significantly increase the performance of your web application because it eliminates the overhead needed to copy the response from BlueDragon's internal buffer to the J2EE server response buffers.</p>
<p>This configuration setting can be overridden dynamically using the CFFLUSH tag. Set buffersize to 0 to have BlueDragon buffer the entire response (this is the default).</p>

<a name="assert"></a><h3>assert</h3>
<p>Enables the CFASSERT tag and Assert() function. When disabled, the CFASSERT tag and Assert() function are not executed and do not produce any output. Accepts values "true/false"; the default is "false".</p>

<a name="missingtemplatehandler"></a><h3>missingtemplatehandler</h3>
<p>missingtemplatehandler: specifies the CFML template to be used to process "file-not-found" errors in place of the BlueDragon default file-not-found error page.</p>
<p>May be specified as a full physical path or a relative path from the web application root directory. When specifying full physical paths on Linux/UNIX, prepend a "$" to the path to distinguish these from relative paths; paths starting with "/" are interpreted as relative paths.</p>

<a name="tempdirectory"></a><h3>tempdirectory</h3>
<p>Specifies the location of BlueDragon temporary directory. If not specified, defaults to "work/temp", with the location of BlueDragon's "work" directory specified in web.xml via the BLUEDRAGON_WORKING_DIRECTORY servlet init parameter.</p>
<p>May be specified as a full physical path or a relative path from the web application root directory. When specifying full physical paths on Linux/UNIX, prepend a "$" to the path to distinguish these from relative paths; paths starting with "/" are interpreted as relative paths.</p>

<a name="runtimelogging"></a><h3>runtimelogging</h3>
<p>If "true", BlueDragon will create a log file containing extended error information whenever an error occurs. The error log file will be created regardless of whether the error is handled by a user-defined error handler. The information displayed in the error log file will include CFDUMP output of the variable scopes selected in the "debugoutput" section of this file (see below).  Accepts values "true/false"; the default is "true".</p>

<a name="runtimeloggingmax"></a><h3>runtimeloggingmax</h3>
<p>The maximum number of error files that the engine will produce.  This reduces the overhead on the disk system, particularly if you are limited to only a certain amount of files.   BlueDragon will always log to the file <strong>bderror-latest.html</strong>.</p>

<a name="defaultcharset"></a><h3>defaultcharset</h3>
<p>The default character set used by BlueDragon for reading incoming request data (URL and Form data), and is the default character set specified by BlueDragon in the outgoing response header. The default is "UTF-8".</p>

<a name="component-cfc"></a><h3>component-cfc</h3>
<p>The location of the "component.cfc" file that is the superclass of all CFCs. Must be specified.
<p>May be specified as a full physical path or a relative path from the web application root directory. When specifying full physical paths on Linux/UNIX, prepend a "$" to the path to distinguish these from relative paths; paths starting with "/" are interpreted as relative paths.</p>

<a name="scriptsrc"></a><h3>scriptsrc</h3>
<p>scriptsrc: the default path to the directory containing the JavaScript files used by CFFORM. Must be specified as a relative path from the web application root directory.</p>

<a name="debug"></a><h3>debug</h3>
<p>Also known as "Extended Error Reporting", if "false", the BlueDragon built-in error page only displays a descriptive message when reporting errors. If "true", then in addition to the descriptive error message, the BlueDragon built-in error page will display the following information:</p>
<ul>
<li>the URI of the request</li>
<li>the physical path to the template that caused the error</li>
<li>detailed error information, including a snippet of the source code that produced the error</li>
<li>CFDUMP output of all CFML variable scopes selected in the "debugoutput" section of this document (see below)</li>
</ul>
<p>Setting this to "true" will provide useful information during development and testing. For security reasons, this setting should be disabled on production systems.  Accepts values "true/false"; the default is "true".</p>

<a name="scriptprotect"></a><h3>scriptprotect</h3>
<p>Set to "true" to enable protection of variables from cross-site scripting attacks.	 Accepts values "true/false"; the default is "false".</p>

<a name="scriptprotectregex"></a><h3>scriptprotectregex</h3>
<p>This is the regex pattern that will be used to detect the milicious scripts coming in through the URL, FORM, COOKIE and CGI scopes.</p>

<a name="nativelibdir"></a><h3>nativelibdir</h3>
<p>Specifies the location of native libraries required by BlueDragon.</p>

<a name="errorhandler"></a><h3>errorhandler</h3>
<p>Specify the CFML template to be used to process runtime errors in place of the BlueDragon default runtime error page.</p>
<p>May be specified as a full physical path or a relative path from the web application root directory. When specifying full physical paths on Linux/UNIX, prepend a "$" to the path to distinguish these from relative paths; paths starting with "/" are interpreted as relative paths.</p>

<a name="whitespacecomp"></a><h3>whitespacecomp</h3>
<p>If "true", BlueDragon compresses all runs of whitespace characters into a single whitespace character when generating HTML output from CFML pages.  Accepts values "true/false"; the default is "false".</p>

<a name="formurlcombined"></a><h3>formurlcombined</h3>
<p>If "true", BlueDragon will combine both the <strong>url</strong> and <strong>form</strong> scopes into one.  No matter how the variable came in, the CFML developer can pick them up from either scope.  Uses less memory.</p>

<a name="formurlmaintaincase"></a><h3>formurlmaintaincase</h3>
<p>If "true", then the FORM/URL scopes case will be maintained.  It defaults to 'false' which OpenBD uppercases all the keys, combining them where
appropriate.</p>

<a name="strictarraypassbyreference"></a><h3>strictarraypassbyreference</h3>
<p>If "true", then any array objects being passed around in and out of UDF or CFC functions will not be copied (the default action), but instead pass references around.   This does not effect core built-in functions, that always pass arrays around by reference.  Turning this flag will increase the performance and reduce the memory overhead.</p>

<a name="functionscopedvariables"></a><h3>functionscopedvariables</h3>
<p>If "true", then any variables declared inside a CFFUNCTION/function will be only available inside the scope of that function.   This makes CFML work like many other languages by locally scoping variables.  The default is to have to any variable declared assigned to the 'variables' scope of the CFC.  Think of this flag like an automatic "var" insertion when declaring variables.</p>

<a name="rewritebluedragonxml"></a><h3>rewritebluedragonxml</h3>
<p>If "true", on startup and initialization, the engine will rewrite a clean/formatted copy of the bluedragon.xml configuration file.  This may not be desirable in production systems where this is getting rewritten everytime.</p>


<a name="cfoutputshorthand"></a><h3>cfoutputshorthand</h3>
<p>If "true", then the engine will parse out &lt;%= #now()# %&gt; as a shorthand for CFOUTPUT (with no attributes).</p>


<a name="legacyformvalidation"></a><h3>legacyformvalidation</h3>
<p>If "false", then BlueDragon will not automatically look for incoming FORM variables and attempt to do any form validation on them.  Turning this to "false" makes a performance gain for applications that pass a lot of URL/FORM parameters around but never use the inbuilt CFML form validation functionality.</p>

<a name="mappings"></a><h3>mappings</h3>
<p>Specify CFML mappings within individual "mapping" subelements.</p>
<p>The "name" attribute of the "mapping" element must match the "name" subelement of the "mapping" element. This is equivalent to the "logical path" as defined via the BlueDragon admin console.</p>
<p>The "directory" element specifies the physical path; it may be specified as a full physical path or a relative path from the web application root directory. When specifying full physical  paths on Linux/UNIX, prepend a "$" to the path to distinguish these from relative paths; paths  starting with "/" are interpreted as relative paths.</p>

<a name="file"></a><h3>file</h3>
<p>Configuration of the BlueDragon file cache.</p>
<p>The "maxfiles" subelement specifies the maximum number of files (CFML templates, CFC files, and custom tag files) to be stored in the file cache. When the file cache becomes full, files are removed from the cache using a least-recently used (LRU) algorithm to make room for newer files.</p>
<p>If "trustcache" is set to "true", BlueDragon does not check the file system for newer versions of CFML or CFC source files after they're loaded into the file cache, which can have a modest performance benefit. If "trustcache" is set to "false", BlueDragon replaces the cached file with the newer file system version, if a newer version exists.</p>

<a name="javacustomtags"></a><h3>javacustomtags</h3>
<p>This lets you register custom tags written in Java, that can be accessed using the &lt;cfx_&gt; notation.   For each tag, you specify a
new 'mapping' block detailing each one.   The classes for these custom tags can be put into the standard '/WEB-INF/classes/' or if in a JAR file
inside the '/WEB-INF/lib/' folder from the document root.  Otherwise, you specify a custom classpath.</p>

<a name="nativecustomtags"></a><h3>nativecustomtags</h3>
<p>This lets you register custom tags written in non-Java language, that can be accessed using the &lt;cfx_&gt; notation.   For each tag, you specify a
new 'mapping' block detailing each one.   You specify the 'module' to where the native code can be found.</p>

<a name="cfchart"></a><h3>cfchart</h3>
<p>Configuration for how cfchart handles and manages the dynamic production of charts.   The 'cachesize' controls how many images it will keep in memory.   Where the image is
stored can be either: <strong>file</strong>, <strong>session</strong>, or <strong><em>datasource name</em></strong>.  If it is a datasource name
then BlueDragon will automatically try to create and use <strong>BDCHARTDATA</strong> table.   Make sure the user for this datasource has create
permission.</p>

<a name="cfquery-cachecount"></a><h3>cfquery-cachecount</h3>
<p>The query cache stores result sets that are cached when using the CFQUERY attributes CACHEDWITHIN and CACHEDAFTER, and CACHEDUNTILCHANGE. The "cachecount" element specifies the maximimum number of queries that will be stored in the cache. When the query cache becomes full, queries are removed from the cache using a least-recently used (LRU) algorithm to make room for newer queries.</p>

<a name="cfquery-validate"></a><h3>cfquery-validate</h3>
<p>If "true", validation queries are used to verify the state of database connections before they're used (to render a CFQUERY tag, for example). Accepts values "true/false"; the default is "true".</p>

<a name="cfquery-autoconfig-odbc"></a><h3>cfquery-autoconfig-odbc</h3>
<p>If "true" on Windows, will attempt to automatically configure ODBC datasources in this configuration file when BlueDragon initializes. Note that the username and password values are never automatically configured, but must be entered manually. Accepts values "true/false"; the default is "true".</p>

<a name="cfquery-slowlog"></a><h3>cfquery-slowlog</h3>
<p>If this value is a non-zero, then any query taking longer than this number of seconds will be automatically logged to the slow log file.</p>

<a name="cfquery-mysql"></a><h3>cfquery-mysql</h3>
<p>Following is a sample datasource for MySQL. The "name" attribute for the "datasource" element, and the "name" subelement must have same value; this is the name of the datasource to be specified within CFQUERY and other database tags.</p>
<p>Within the "hoststring" element, edit "localhost" to be the domain name or IP address of the server on which the MySQL database is running; edit "myDatabaseName" to be the name of the MySQL database to which this datasource will connect.</p>
<p>The engine will attempt to verify the network port before making a connection.  This is basically a TCP/IP lookup.  If it fails it will throw a "failed to verify remote server/socket @".  You can disable this check if you add in the "<strong>openbdnocheck</strong>" as a paramter to the connection URL.  For example: <strong>jdbc:mysql://localhost:3306/myDatabaseName?useUnicode=true&openbdnocheck</strong></p>
<p>The "connectionperpage" flag, disables the system connection pooling, but enables the per-page pooling.  This means for every page request the 
connection to the database will be established and then once the page is completed, the connection closed again.  The connection will be pooled for that
page request.
</p>

<a name="cfquery-sqlserver"></a><h3>cfquery-sqlserver</h3>
<p>Following is a sample datasource for Microsoft SQL Server. The "name" attribute for the "datasource" element, and the "name" subelement must have same value; this is the name of the datasource to be specified within CFQUERY and other database tags.</p>
<p>Within the "hoststring" element, edit "localhost" to be the domain name or IP address of the server on which the SQL Server database is running; edit "myDatabaseName" to be the name of the SQL Server database to which this datasource will connect.</p>
<p>The engine will attempt to verify the network port before making a connection.  This is basically a TCP/IP lookup.  If it fails it will throw a "failed to verify remote server/socket @".  You can disable this check if you add in the "<strong>openbdnocheck</strong>" as a paramter to the connection URL.  For example: <strong>jdbc:sqlserver://localhost:1433;databaseName=myDatabaseName;openbdnocheck</strong></p>

<a name="cfmail"></a><h3>cfmail</h3>
<p>This is the default spooling server that will be used for outgoing email.  You can specify a list of servers, using comma to delimit, that BlueDragon will attempt to deliver to in the event of a failure.   If you are looking to send a large number
of outgoing emails, then you can control the amount of threads that BlueDragon will dedicate.  Do not make this any higher than the number of concurrent connections your upstream MTA can handle.</p>
<p>catchemail feature is a way to stop all CFMAIL from going to their original intended recipients but instead go to a given set of mail boxes.  This is very handy
in development when you do not want to change all your CFMAIL calls for development vs. production mode.  The original receipient will be available in X-openbd-to/cc/bcc flags.</p>
<p>The ratedelay, in milliseconds, allows you to throttle the rate of the internal mail spooler when sending to the upstream mail provider.  Some mail hosts do not have the ability
to accept email as quickly as OpenBD can give it.  -1 disables this feature.</p>

<a name="customtags"></a><h3>customtags</h3>
<p>This is where the engine knows how to deal with custom tags and the prefix that will be used for them.  By default, the prefix <strong>cf_</strong> is set to '/WEB-INF/customtags/'.</p>
<p>The directories specified here, will also be used by the engine to search for CFC files.</p>

<a name="libpath"></a><h3>libpath</h3>
<p>This is an alternative path where JAR files are available instead of /WEB-INF/lib/.  Particularly useful for custom installations where the standard JAR files may
not be available.  This is for web services.</p>

<a name="jsoncase"></a><h3>jsoncase</h3>
<p>Controls the default casing of encoded JSon keys when using SerializeJSon() and returning JSON on remmote RESTlet calls.  Defaults to 'maintain'.  Possible values are: maintain, upper or lower</p>

<a name="jsoncase"></a><h3>jsondate</h3>
<p>Controls how dates are encoded in JSon when using SerializeJSon() and returning JSON on remmote RESTlet calls.  Defaults to 'long'.  Possible values are: long, html, cfml or json</p>

<a name="journal"></a><h3>journal</h3>
<p>
The unique token that will enable the request to be journaled.  This is the _openbdjournal URI, HTTP header, or cookie value that will be looked for.  See <a href="./?/journal">Journaling OpenBD Requests</a> for more information.
</p>

<a name="journalmb"></a><h3>journalmb</h3>
<p>
The maximum size in megabytes, of disk space, the journal feature will utilise.  Files will be deleted to make space for new ones.  See <a href="./?/journal">Journaling OpenBD Requests</a> for more information.
</p>
<a name="journalignoreuri"></a><h3>journalignoreuri</h3>
<p>
This is the uri to which the journal will not create any files for even though a cookie or URI is present.  This is to stop the actual journal app from journaling itself.  defaults to '/journal'  See <a href="./?/journal">Journaling OpenBD Requests</a> for more information.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->