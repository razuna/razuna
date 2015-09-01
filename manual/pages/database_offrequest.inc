<cfset request.page.section = "adv">
<cfset request.page.title = "Off-Request Queries">
<cfset request.page.desc	= "You can easily have queries run after the user has finished with the request">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/database_offrequest"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Off-Request/Background Query</h1>

		<cfinclude template="pages/sidebar_advanced.inc" />

		<div class="section">
			<p>
			When you invoke a query, the request will be held up for the length of time it takes to perform the query.  For the vast majority
			of applications this is the usual way of servicing a request.   However there are situations where you may not wish to hold up the
			client request, waiting, for the query to complete.  For example, performing some logging operations.
			</p>
			
			<p>
			OpenBD offers a facility to manage these, off-request, query operations in a structured manner using what is known as background processing.
			</p>
			
			<p>
			To utilise this functionality, you simply add the <strong>background="yes"</strong> attribute to the <a href="./?/tag/CFQUERY">CFQUERY</a> tag.
			</p>
			
<cfsavecontent variable="cfml"><nocfml>
<cfquery datasource="#application.ds#" background="yes">
  insert into tablex (a,b,c) values (1,2,<cfqueryparam value="#Day(now())#">)
</cfquery>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>
			
			<p>
			What this attribute does, is to collect all the data for the query to run, and then adds it to the background query spooling engine for execution at
			a later time.  The tag returns immediately without any interaction to the database you looking to the query against.
			</p>
			
			<p>
			The spooling engine, executes the query in a serialized manner, one after another, using the same connection pooling contention as any other normal
			query tag. This is done in a completely separate thread managed by the OpenBD application server.   The queries are saved to disk to ensure no
			loss even in the event of a server restart.
			</p>
			
			<p>
			The main advantage of this mechanism, over say pushing it to a <a href="./?/tag/CFTHREAD">CFTHREAD</a> block, is that there is a lot less
			overhead.   Management of the queries, persistance and error reporting is all built-in without having to manually provide for that.
			</p>

			<h2>Tracking Off-Requests queries</h2>
			
			<p>
			Queries are spooled to the directory <code>/bluedragon/cfquerybatch/spool/</code>.   Every 5 minutes the engine comes along and picks up all the queries
			waiting for execution.   They are then run against the given datasource.   If the engine fails to execute the query, then the file is moved to the
			<code>/bluedragon/cfquerybatch/failed/</code> directory.
			</p>
			
			<p>
			If the query failed because of a connection error, then file name will be prefixed with "connection-YYYY.batchsql".   Any other error is marked as simply
			"failed-YYYY.batchsql".
			</p>
			
			<p>
			In addition to the renaming and moving of the files, you can look at the <code>/bluedragon/cfquerybatch/querybatch-error.log</code> for the precise reason it failed.
			The SQL that was attempted will be detailed in there.
			</p>
			
			<p>
			Once all the files have been processed, an entry is written to the main <code>/bluedragon/cfquerybatch/querybatch.log</code> log file detailing the number of queries
			it ran, how many failed and what the average time for execution was.
			</p>
			
<pre class="cfml">
17/09/10 01:21.37: -] runSQL: success=6; SQLFailed=0; ConnectedFailed=0; SQL=32ms; avg=5ms
17/09/10 01:26.37: -] runSQL: success=6; SQLFailed=0; ConnectedFailed=0; SQL=43ms; avg=7ms
</pre>

			<p>It is very easy to respool failed queries, by simply copying the files back into the spool directory, where they will be picked up within 5 minutes.   You can place
			the files anywhere inside the spool directory, the sub-directory does not matter.   OpenBD creates a number of sub-directories within the spool directory to allow for
			greater File I/O efficieny on operating systems by spreading the number of large files over a number of separate directories.</p>
			
			</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->