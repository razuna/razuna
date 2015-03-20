<cfset request.page.title 	= "Journaling OpenBD CFML">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "OpenBD ships with a powerful journal utility that lets you determine code coverage for testing or profiling">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/journal"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>

<div class="content" id="content">
	<div class="container cf">
	<h1>Journaling OpenBD CFML</h1>
	<cfinclude template="pages/sidebar_advanced.inc" />
	<div class="section">
	
	<p>
	OpenBD has a powerful profiling and code coverage tool built in that is called the Journal.  The Journal can be enabled on a per-request basis that 
	will record each file, tag and expression line executed and dump that into an easy to consume CSV file for analysis.
	</p>
	
	<p>
	If you are running automated or unit testing this will give you the details as to how much code your tests are reaching.  In addition, you can determine
	the most hit files, tags and functions and the average execution time for blocks of code.   All the raw data is produced by the journal to be consumed.
	</p>
	
	<h2>Enable Journal</h2>
	
	<p>
	The journal is not enabled by default, you must edit the bluedragon.xml file adding in the line to the server system XML component and restart.
	</p>
	
<cfsavecontent variable="cfml"><nocfml><journal>password1234</journal>
<journalmb>50</journalmb>
<journalignoreuri>/journal</journalignoreuri>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
	
	<p>
	The value here is the password/token that will be used to enable the journaling of a given request.   This allows you to control the security
	of the journal request, easily allowing to be added into testing environments.   The journalmb is the maximum size that this directory will become.  This ensures
	you don't fill up the disk.  It will delete the oldest files until the space allocation is down to 90% of the value specified.  Defaults to 50MB.
	The journalignoreuri lets you specify a URI path to which the journal will not happen, even if a cookie/uri/header exists.  This stops you from having
	to journal the journal app itself.
	</p>
	
	<p>
	Once enabled you can enable a request to be journaled in one of three ways:
	</p>
	
	<ul>
	 <li>URI Param: _openbdjournal=<i>value-you-had-in-the-bluedragon.xml</i></li>
	 <li>HTTP header: _openbdjournal: <i>value-you-had-in-the-bluedragon.xml</i></li>
	 <li>Cookie: _openbdjournal=<i>value-you-had-in-the-bluedragon.xml</i></li>
	</ul>
	
	<p>
	Should any of these be detected, then the request will be journaled, which will result in a file be written in the <strong>[OpenBD working directory]/journal/</strong>
	directory.   This will be a text file dated the time of the request as per the server clock, for example "2015-01-19_13.29.29-0.txt".   A directory structure mirroring the request path, will be created
	underneath this folder.
	</p>
	
	<p>
	Journal has a powerful feature which can be enabled with each request.  That is, it can take a snapshot of the state of the variables at the time when a file
	is entered/left and function started/exited.  This is saved in a file along side the journal with the .session extension.  Each session state is saved one after
	another and you can read it back using <a href="./?/function/journalreadsession">JournalReadSession()</a>.   You enable this by add "-1" to the end of the 
	password passed in via the uri/header/cookie.
	</p>
	
	<cfsavecontent variable="cfml"><nocfml><cfset jDir = GetJournalDirectory()></nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
	
	<p>
	You can get a handle to this directory using the <a href="./?/function/getjournaldirectory">GetJournalDirectory()</a> function.
	</p>
	
	<h2>Journal File Format</h2>
	
	<p>
	The first line of the journal file is a JSON encoded structure that has a variety of keys about the request.   Any key that is prefixed with an underscore (_) is a 
	system key.   An example of this includes: _uri (the original request), _bytes (the number of bytes sent), _timems (time for request), _querycount (number of queries ran), _querytime (time the queries took), _method (the HTTP method of the request).   All the other keys are the full path names of the files that this particular
	request read.  This includes all CFC's, include's, template's etc.  The key is pointed to a unique number that is referenced in the remaining lines.
	</p>
	
	<p>
	The remaining lines of the journal are the execution trace of the request.
	</p>
	
	<p>
	You can easily read this journal file using the <a href="./?/function/journalread">JournalRead()</a> function.   Alternatively, you can push this
	data into a database, using <a href="./?/function/journalreadtodatasource">JournalReadToDataSource()</a>
	</p>
	
	
<cfsavecontent variable="cfml"><nocfml>142,TE,4,3,3,CFCOMPONENT,423,-397
142,TT,3,3,4,CFSET,39,2
142,MS,3,3,5,CFFUNCTION,52,-52,initProperties
142,TT,3,3,6,CFPARAM,44,3
142,TT,3,3,6,CFPARAM,45,3
146,TT,3,3,6,CFPARAM,46,3
174,TS,6,3,7,CFCOMPONENT,1,1
174,FS,6,4,7
174,TS,5,4,8,CFCOMPONENT,1,1
174,FS,5,5,8
174,FE,5,4,8
174,TE,5,4,7,CFCOMPONENT,3,1
174,TT,6,4,8,CFPARAM,2,2
175,TT,6,4,8,CFPARAM,3,2
175,TT,6,4,8,CFPARAM,4,2
175,TT,6,4,8,CFPARAM,5,2
175,TT,6,4,8,CFPARAM,6,2
175,TT,6,4,8,CFPARAM,7,2
176,TT,6,4,8,CFPARAM,8,2
176,TT,6,4,8,CFPARAM,9,2
176,TT,6,4,8,CFPARAM,10,2
176,TT,6,4,8,CFPARAM,11,2
177,TT,6,4,8,CFPARAM,12,2

...
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
	
	<p>
	The table below shows the possible values for each line type.
	</p>

	<table>
	<tr>
		<th>Description</th>
		<th>#1</th>
		<th>#2</th>
		<th>#3</th>
		<th>#4</th>
		<th>#5</th>
		<th>#6</th>
		<th>#7</th>
		<th>#8</th>
		<th>#9</th>
		<th>#10</th>
	</tr>
	<tr>
		<td>File Start</td>
		<td>time</td>
		<td>FS</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>File End</td>
		<td>time</td>
		<td>FE</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>Tag Start</td>
		<td>time</td>
		<td>TS</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>Tag Name</td>
		<td>Line Number</td>
		<td>Column Number</td>
		<td></td>
	</tr>
	<tr>
		<td>Tag (with no end tag)</td>
		<td>time</td>
		<td>TT</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>Tag Name</td>
		<td>Line Number</td>
		<td>Column Number</td>
		<td></td>
	</tr>
	<tr>
		<td>Tag End</td>
		<td>time</td>
		<td>TE</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>Tag Name</td>
		<td>Line Number</td>
		<td>Column Number</td>
		<td></td>
	</tr>
	<tr>
		<td>cfFunction start</td>
		<td>time</td>
		<td>MS</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>Tag Name</td>
		<td>Line Number</td>
		<td>Column Number</td>
		<td>cfFunction name</td>
	</tr>
	<tr>
		<td>cfFunction End</td>
		<td>time</td>
		<td>ME</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>Tag Name</td>
		<td>Line Number</td>
		<td>Column Number</td>
		<td>cfFunction name</td>
	</tr>
	<tr>
		<td>Script Statement</td>
		<td>time</td>
		<td>SS</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>reserved</td>
		<td>Line Number</td>
		<td>Column Number</td>
		<td>Line Number from CFSCRIPT tag</td>
	</tr>
	<tr>
		<td>Script Function Start</td>
		<td>time</td>
		<td>SF</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>function name</td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>Script Function End</td>
		<td>time</td>
		<td>SE</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td>function name</td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>Expression Run</td>
		<td>time</td>
		<td>HE</td>
		<td>File ID</td>
		<td>Session</td>
		<td>File Depth</td>
		<td>Tag Depth</td>
		<td></td>
		<td></td>
		<td></td>
		<td>expression</td>
	</tr>
	<tr>
		<td>Runtime Exception</td>
		<td>time</td>
		<td>ER</td>
		<td>Error message</td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td>BadFile Exception</td>
		<td>time</td>
		<td>EF</td>
		<td>Error message</td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	</table>
	
	<p>
	The third column is the file index that this operation happened in.  Refer to the structure from the first line to determine the precise file it was in.
	</p>

	<p>
	The 'session' column is a numeric page number of the state of the variables if the session tracking was enabled with the request.  You get at this
	<a href="./?/function/journalreadsession">JournalReadSession()</a> function, passing in the page you want to read.  This will return a struct that 
	represents the state of the variables at that time.
	</p>
	
	<p>
	The purpose of this feature is to collect the raw data for later processing.  Future releases of OpenBD will see tooling around the analysis of Journal files.
	</p>
	
	</div><!--- .section --->
	</div><!--- .container --->
</div><!--- .content --->