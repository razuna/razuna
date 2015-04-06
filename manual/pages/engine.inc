<cfset request.page.section = "engine">
<cfset request.page.title = "OpenBD Engine">
<cfset request.page.desc	= "OpenBD Engine">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li class="active"><a href="./?/engine">Engine</a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>OpenBD Engine</h1>
		
		<cfinclude template="pages/sidebar_server.inc" />
		
		<div class="section">
			
			<p>The OpenBlueDragon engine is shipped as a standard J2EE WAR (Web ARchive) application. This a standard packaging mechanism that is defined
			that allows any J2EE supporting application server to easily and quickly run.</p>
			
			<p>OpenBlueDragon is shipped in a number of formats, but they all derive from this standard WAR format. The most popular download
			is the pre-bundled Ready-To-Run Jetty installation, that has OpenBlueDragon already ready to run.</p>
			
			<p>This section describes some of the configuration parameters associated with the core engine</p>
			
			<ul>
				<li><a href="./?/engine_bluedragonxml">Configuration details of bluedragon.xml</a></li>
				<li><a href="./?/engine_logfiles">Explanation of all the working directories</a></li>
				<li><a href="./?/engine_cfmail">Handling outgoing email</a></li>
			</ul>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->