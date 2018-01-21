<cfset request.page.title = "Plugin Overview and Installation">
<cfset request.page.desc	= "Plugins add extra functionality to the core engine by simply dropping in files">
<cfset request.page.section = "plugins" >

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/plugin">Plugins</a></li>
			<li class="active"><a href=""><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>PlugIn Overview</h1>
		
		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">
		
			<p>Plugin functionality is a factor of any modern day software package. From the humble desktop apps, right through to powerful scalable
			enterprise sysems, they all offer the ability to extend their core functionality by adding small pieces of functionality. OpenBD offers
			this powerful paradiagm to the CFML developer.</p>
			
			<p>Plugins allow us to develop custom features that would not necessarily have a broad appeal to every one. These targetted small chunks of
			functionality allow you to custom build your web application setup without all the bloat that is usually associated with mature software.</p>
			
			<h2>Installation</h2>
			
			<p>Installation of a plugin could not be easier. Simply drop the plugin JAR file into the <strong>/WEB-INF/lib/</strong> folder and
			restart the web server.  No complicated configuration files to wrestle with. If you need to remove a plugin simply delete the file and
			restart.</p>
			
			<p>You can validate the loading of any plugin by looking at the <strong>bluedragon.log</strong> and you will see a line to note it was loaded.</p>
			
			<p>If you have a custom setup for your J2EE application server, then it is generally recommended to place the plugin JAR in the same directory
			as the main <strong>OpenBlueDragon.jar</strong> file.</p>
			
			<h2>Official PlugIns</h2>
			
			<p>The following plugins are available from the main <a href="http://openbd.org/download/">OpenBD website</a>.</p>
			
			<table class="zebra-striped">
			<thead>
				<tr>
					<th>Plugin Name</th>
					<th>Description</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td><a href="./?/plugin_cron">CronTab - Scheduler</a></td>
					<td>Provides a Linux 'cron' like directory structure of pre-defined intervals, where templates can simply be dropped into for execution at a specific interval. <em>please note this plugin is part of the core distribution</em></td>
				</tr>
				<tr>
					<td><a href="./?/plugin_cfsmtp">SMTP Processing Incoming Email</a></td>
					<td>Build sophiscated email applications that receive email.  Catch incoming emails through CFC's that can then be processed just like a web request.  <em>please note this plugin is part of the core distribution</em></td>
				</tr>
				<tr>
					<td><a href="./?/plugin_debugger">Debugger</a></td>
					<td>A web based CFML Debugger that lets you step into CFC's and functions, set breakpoints, inspect variables and pause execution</td>
				</tr>
				<!---
				<tr>
					<td><a href="./?/plugin_cflib">CFML Packager</a></td>
					<td>Package up your CFML apps in a 'jar' like format, including auto-remote update features</td>
				</tr>
				--->
				<tr>
					<td><a href="./?/plugin_message">JMS Messaging</a></td>
					<td>Integrate your CFML application into the full Java Messaging Service system, including sending and receiving messages from topics and queues.  Alternatively, use it as
					a complete event based system internal to your CFML app</td>
				</tr>
				<tr>
					<td><a href="./?/plugin_salesforce">SalesForce</a></td>
					<td>Quickly and easily utilise <a href="http://www.salesforce.com/">SalesForce</a> connectivity without the overhead and complexity of webservices</td>
				</tr>
				<tr>
					<td><a href="./?/plugin_exchange">Microsoft Exchange</a></td>
					<td>Interact with Microsoft Exchange server, including tasks, events, contacts etc</td>
				</tr>
			</tbody>
			</table>
			
		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->