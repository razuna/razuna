<cfset request.page.section = "plugins">
<cfset request.page.title = "CFML Debugger Plugin">
<cfset request.page.desc	= "cfDebugger Plugin makes the development and debugging of CFML apps much quicker and easier">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/plugin">Plugins</a></li>
      <li class="active"><a href="./?/plugin_debugger"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>cfDebugger Plugin</h1>

		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">
		
<p>The OpenBD Debugger is an official plugin for use with the OpenBlueDragon engine that delivers a full CFML debugging environment through any web browser.</p>
<p>No additional sofware is required, simply drop the JAR file, restart the server and start putting breakpoints, step through code and inspect variables.</p>

<p align="center"><img src="./pages/debugger.jpg" style="border: 1px solid silver;" /></p>

<ul><li> Multiple session tracking</li>
<li> Set break points in any CFML page, custom tag or CFC by simply clicking on any line</li>
<li> Conditionally Break on Exceptions</li>
<li> Step through CFML tags and statements within CFSCRIPT blocks</li>
<li> Step over files</li>
<li> Run to end</li>
<li> Run to break points</li>
<li> Fully Variable Inspection
<ul><li> Easy to use tree navigation of all variables</li>
<li> Search your variables; complete with search history</li>
<li> Runtime statistics - tag/statement usage, variable type usage</li>
<li> Current Tag and File stack</li>
<li> Fully query history, including execution times, input vars, and row count</li>
</ul>
</li>
<li> No complicated setup; simply drop the JAR file in, restart and then surf to <a href="http://127.0.0.1/openbddebugger/" class="external free" title="http://127.0.0.1/openbddebugger/" rel="nofollow">http://127.0.0.1/openbddebugger/</a></li>
</ul>

<p>YouTube demo of the Debugger in action: <a href="http://www.youtube.com/watch?v=7Ww_er9QGw8">http://www.youtube.com/watch?v=7Ww_er9QGw8</a></p>

<p><a class="btn dload" href="http://openbd.org/downloads/" title="head over to the download area to get the debugger plugin" rel="nofollow">download the plugin</a></p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->