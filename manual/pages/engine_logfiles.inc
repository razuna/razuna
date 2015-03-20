<cfset request.page.section = "engine">
<cfset request.page.title = "OpenBD Log Files">
<cfset request.page.desc	= "A description of what log files OpenBD produces">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/engine">Server</a></li>
      <li class="active"><a href="./?/engine_logfiles"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">Log files</h1>

		<cfinclude template="pages/sidebar_server.inc" />
		
		<div class="section">
		
			<p>OpenBlueDragon produces a number of log files from various parts of the core-engine that are very useful to let know the
			running state of the engine.   The majority of the files are self-rolling (25MB) and will not keep consuming all the disk space.</p>
			
			<p>
			The following is the directory structure used from the <strong>working-directory</strong> variable.  By default this is "/WEB-INF/bluedragon/work/" but can be changed in the web.xml file.
			</p>
			
			<ul>
				<li><strong>bluedragon.log</strong><br/>This is the main engine log, detailing all major events.  Useful at startup to see what
				elements of the engine that were initalized and with what.</li>
				<li><strong>cfchart/</strong><br/>The directory where cfchart will use for its file cache</li>
				<li><strong>cfcollection/</strong><br/>Any collections (CFINDEX etc) will be created in here</li>
				<li><strong>cflog/</strong><br/>All logging to CFLOG will be produced in this folder</li>
				<li><strong>cfmail/</strong>
				<ul>
					<li><strong>spool/</strong><br/>The folder where all outgoing email is initially created.</li>
					<li><strong>undelivered/</strong><br/>Any email failed to be delivered will be moved to here.  If the problem was a problematic upstream MTA, then you can simply move the files from this directory into the spool directory, without having to restart the server.</li>
					<li><strong>mail.log</strong><br/>Logs all emails sent to the upstream MTA</li>
				</ul>
				</li>
				<li><strong>cfquerybatch/</strong>
				<ul>
					<li><strong>failed/</strong></br>This is where all the failed background queries will be placed.  If the problem has been resolved, you can simply move these files into the spool directory without restarting the server.</li>
					<li><strong>spool/</strong><br/>This is where all the scheduled background queries will be placed.</li>
					<li><strong>querybatch.log</strong><br/>A log of the status of each background run, detailing the successes and failure counts.</li>
					<li><strong>querybatch-error.log</strong><br/>This is a detailed log of what went wrong</li>
				</ul>
				</li>
				<li><strong>cfschedule/</strong>
				<ul>
					<li><strong>schedule.log</strong><br/>A log of all the CFSCHEDULE runs</li>
				</ul>
				</li>
				<li><strong>slowlog/</strong>
				<ul>
					<li><strong>slowlog.log</strong><br/>If enabled in the bluedragon.xml, this details all the queries that took over a specific amount of seconds</li>
				</ul>
				</li>
				<li><strong>temp/</strong>
				<ul>
					<li><strong>rtelogs/</strong><br/>This is where all the RunTimeException files are stored.  The file "bderror-latest.html" will always be the most recent bug.</li>
					<li><strong>ws/</strong><br/>This is the working folder for the WebServices dynamic generation</li>
				</ul>
				</li>
			</ul>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->