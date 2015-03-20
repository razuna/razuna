<cfset request.page.section = "engine">
<cfset request.page.title = "Microsoft Windows Service">
<cfset request.page.desc	= "How to startup OpenBD Jetty when Windows starts">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/engine">Server</a></li>
      <li class="active"><a href="./?/windows_server"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">Microsoft Windows Service</h1>

		<cfinclude template="pages/sidebar_server.inc" />
		
		<div class="section">
		
			<p>
			OpenBD ships in many different flavours, but one of the most common bundles, is the Ready2Run OpenBD Jetty server.   Getting Jetty to
			start up, when Microsoft Windows starts up can be a little tricky as Windows does not provide any simple hooks for Java processes.
			</p>
			
			<p>
			Fortunately OpenBD+Jetty has solved this problem by integrating the <a href="http://commons.apache.org/daemon/procrun.html">Apache Daemon</a>
			process into the bundle.
			</p>
			
			
			<h2>Installation</h2>
			
			<p>
			These instructions assume you have unzipped the Ready2Run OpenBD Jetty server in the <code>c:\jetty-openbd\</code> folder.  If you have not,
			then update the paths here to match your installation.
			</p>
			
			<p>
			Open up a Command prompt and run <code>c:\jetty-openbd\bin\serviceRegister.cmd</code>.  This is a small script that setups the service.  The details
			of it are below.
			</p>
			
			<pre>
			cd c:\jetty-openbd\
			bin\prunsrv //IS//JettyService --DisplayName="Jetty Service" --Install=C:\jetty-openbd\bin\JettyService.exe --LogPath=C:\jetty-openbd\logs --LogLevel=Debug --StdOutput=auto --StdError=auto --StartMode=Java --StopMode=Java --Jvm=auto ++JvmOptions=-Djetty.home=C:\jetty-openbd ++JvmOptions=-DSTOP.PORT=8087 ++JvmOptions=-DSTOP.KEY=downB0y ++JvmOptions=-Djetty.logs=C:\jetty-openbd\logs ++JvmOptions=-Dorg.eclipse.jetty.util.log.SOURCE=true ++JvmOptions=-XX:MaxPermSize=128M ++JvmOptions=-XX:+CMSClassUnloadingEnabled ++JvmOptions=-XX:+CMSPermGenSweepingEnabled --Classpath=C:\jetty-openbd\start.jar --StartClass=org.eclipse.jetty.start.Main ++StartParams=OPTIONS=All ++StartParams=C:\jetty-openbd\etc\jetty.xml ++StartParams=C:\jetty-openbd\etc\jetty-deploy.xml ++StartParams=C:\jetty-openbd\etc\jetty-webapps.xml ++StartParams=C:\jetty-openbd\etc\jetty-contexts.xml --StopClass=org.eclipse.jetty.start.Main ++StopParams=--stop
			</pre>
			
			<p>
			This technique can be used for any Jetty installation.   Simply copy the <code>c:\jetty-openbd\bin\JettyService.exe</code> to your Jetty bundle
			and adjust the registration script accordingly.
			</p>

			<h2>Deleting the service</h2>
			
			<p>
			You can delete the service quickly by using <code>c:\jetty-openbd\bin\serviceRemove.cmd</code>
			</p>
			
			<pre>
			cd c:\jetty-openbd\
			bin\prunsrv //DS/JettyService
			</pre>
			
			
			<h2>Launch the Service Manager</h2>
			
			<p>
			You can launch the service manager, which is a GUI application by clicking here the <code>c:\jetty-openbd\bin\JettyService.exe</code>, but only after
			you have registered it.
			</p>

			<h2>Tips</h2>
			
			<ul>
				<li>Make sure you have tested the server runs up from the command line manually before registering it as a service</li>
				<li>If all goes wrong, then delete the service and try again</li>
				<li>Make sure the path matches the one you have installed OpenBD in</li>
				<li>Adjust the memory requirements of your server before you register the service.  The script assumes only 128MB</li>
				<li>If your Java VM is not in the path, then you can put the path in using the serviceRegister.cmd for <code>--Jvm="c:\program files\java\jre6\bin\server\jvm.dll"</code></li>
				<li>If you are on 64bit, or AMD platform, then you can use the versions of the register service in the <code>bin/daemon</code></li>
			</ul>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->