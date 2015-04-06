<cfsilent>
	<cfset request.page.section = "plugins">
	<cfset request.page.title = "CronTab Plugin">
	<cfset request.page.desc	= "CronTab Plugin makes the management and scheduling of tasks much easier within OpenBD">
</cfsilent>

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/plugin">Plugins</a></li>
      <li class="active"><a href="./?/plugin_cron"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>CronTab Scheduler</h1>
		
		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">

<p>The CronPlugin makes the management and scheduling of tasks much easier within OpenBD.</p>

<p>
Inspired from the simplicity of the popular *nix based system of /etc/cron.d/ subdirectories, this plugin
brings the ease of that method to the CFML developer by allowing them to simply drop files into pre-defined
folders that will be automatically run, without needing to wrestle with external scheduling jobs or CFSCHEDULE.
</p>

<p>
The plugin will automatically create the necessary directories if they do not already exist.  You set this
directory by making a call to <a href="./?/function/cronsetdirectory">CronSetDirectory()</a>.  This directory location will persist over server restarts.
</p>

<p>For example making a call with:

<pre class="cfml">&lt;cfset CronSetDirectory(&quot;/cron.d&quot;)&gt;</pre>

will create the following directory structure within the web app directory.</p>

<pre class="cfml">
/&lt;webapproot&gt;/
/&lt;webapproot&gt;/cron.d/cron.5min/
                    /cron.15min/
                    /cron.hourly/
                    /cron.daily/
                    /cron.weekly/
                    /cron.monthly/</pre>

<p>
After this, you can simply drop .cfm files into each of these directories and they will be run at the allocated
time.   There is no need to restart the engine, or re-call the <a href="./?/function/cronsetdirectory">CronSetDirectory()</a>; it will automatically be picked up.
</p>

<p>
Each time the plugin executes one of these files at the desired time, a copy of the output is retained.
Within the OpenBD working directory, a similiar structure is created but under the <b>plugin-cron</b> directory,
where you can view the results of each file.   In addition, the attempt to execute the file is recorded in the main bluedragon.log file.
</p>

<p>
This plugin triggers the main OpenBD CFML engine directly, without having to go out and back in via HTTP.
This makes it highly efficient and removes a lot of the overhead associated with other schedule methods.
</p>

<p>
You may disable/enable the crontab scheduler using <a href="./?/function/cronenable">CronEnable()</a> function, passing in true/false
accordingly.
</p>

<p>
The plugin trigger will honor all Application.cfc/.cfm files that are in any directories or parent directories.
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->