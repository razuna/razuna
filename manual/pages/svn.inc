<cfset request.page.title = "SVN"><cfset request.page.section = "support">
<cfset request.page.desc = "Getting the source of OpenBD">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
    	<li><a href="./?/support">Support</li>
      <li class="active"><a href="./?/svn"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Building OpenBD from source</h1>

		<cfinclude template="pages/sidebar_support.inc" />
				
		<div class="section">

<p>
OpenBD is an open source project.  For the vast majority they don't really know what this means.  It basically allows you
to have all the ingredients of the cake and bake a new one for yourself without relying on a third party.  Building a project can sometimes seem daunting, especially if you are not use to maintaining source code.   This should not put you off from getting your sleeves rolled up and playing with the source code of open source projects.   This page will take you through the basics of what is required to allow you to build and modify OpenBD by yourself.
</p>

<p>
You can easily build your own version of OpenBD and run the code.  Included in the source tree is the complete
build scripts that lets you quickly build your own version.  This page will describe the steps for doing this.
</p>

<h2>Required Tools</h2>

<p>
To build OpenBD you need to have Java JDK 1.5+ and <a href="http://ant.apache.org/" class="external text" title="http://ant.apache.org/" rel="nofollow">Apache Ant</a> installed.   Ant will is the build project that will
let you execute the build.xml file.
</p>

<p>
To test that you have Ant installed properly, if you open up a console/terminal and type 'ant' if it returns a 'Buildfile: build.xml does not exist!' then you have installed it properly.  Do not advance beyond this stage until this does.
</p>

<h2>Getting the OpenBD source</h2>

<p>
The OpenBD source code can be accessed anonymously from the SVN repository.  This is the latest code and represents the
nightly build of OpenBD.  The SVN URL is:
</p>

<div style="margin: 20px; font-weight:bold;">svn://svn.openbluedragon.org/openbd/trunk/</div>

<p>
If you are not comfortable with using the svn command line version installed on most Linux systems, then you can use the popular
free <a href="http://www.syntevo.com/smartsvn/index.html" class="external text" title="http://www.syntevo.com/smartsvn/index.html" rel="nofollow">SmartSVN</a> client
that will run on any platform.  This is a graphical windows application that will make it easy for you to browse the project source.  The following screenshot shows how you can checkout the project using the 'Project' - 'Check Out...' 
</p>

<img src="./pages/smartsvn.png" style="margin: 20px;" />

<p>
This will checkout all the files required for building the site, including the files for the main web site.  This amounts
to approximately +3000 files.  Any further updates from this project will only download the files that have changed, not the full repository.  So while the initial download maybe large, it won't be if you keep uptodate.
</p>

<h2>Building OpenBD</h2>

<p>
Before we start editing any of the source files, let us first build the source from scratch as it.  As a rule, the latest SVN repository will always have buildable code.   To build the code is a simple matter of invoking the Ant script.
</p>

<p>
You do this by opening up a terminal/console window and navigating to the folder you checked out the SVN repository to.  Let us assume we checked out source to: 'e:\tmp\cleanopenbd\'.  Once there, you would issue the following command: 'ant jar'.  This will build all the JAR files.
</p>

<pre>
E:\tmp\cleanopenbd\>cd build
E:\tmp\cleanopenbd\build>ant jar
Buildfile: E:\tmp\cleanopenbd\build\build.xml

init:
    [mkdir] Created dir: E:\tmp\cleanopenbd\build\classes

compile:
    [javac] E:\tmp\cleanopenbd\build\build.xml:173: warning: 'includeantruntime' was not set, defaulting to build.sysclasspath=last; set to false for repeatable builds
    [javac] Compiling 1948 source files to E:\tmp\cleanopenbd\build\classes
    [javac] Note: Some input files use or override a deprecated API.
    [javac] Note: Recompile with -Xlint:deprecation for details.
    [javac] Note: Some input files use unchecked or unsafe operations.
    [javac] Note: Recompile with -Xlint:unchecked for details.

jar:
     [echo] Creating bluedragon jar file : OpenBlueDragon.jar
     [echo] Building version: 2.1
      [jar] Building jar: E:\tmp\cleanopenbd\build\targets\OpenBlueDragon.jar
   [delete] Deleting: E:\tmp\cleanopenbd\bluedragonmanifest.mf
     [echo] Completed jar creation.

BUILD SUCCESSFUL
Total time: 38 seconds
E:\tmp\cleanopenbd\build>.
</pre>

<p>
Once finished, the folder '<b>./build/targets/</b>' will contain the JAR files for OpenBD.  The main one you want to be
interested in, is the <b>OpenBlueDragon.jar</b> file.
</p>

<h2>Running your custom OpenBD</h2>

<p>
To run your customized OpenBD build, you must take the JAR files from the '<b>./webapp/WEB-INF/lib/</b>' folder and then
add in your custom build file from '<b>./build/targets/OpenBlueDragon.jar</b>'.  At this point you will be running your own
build of OpenBD.
</p>

<h2>OpenBD source</h2>

<p>
The main source code for OpenBD is located at '<b>./src/</b>'.  This source directory is where all the Java source files for OpenBD is located.  OpenBD is essentially a Java Servlet application.  As you look through the source code packages, it is laid out in a logical manner.
</p>

<h2>OpenBD with Eclipse</h2>

<p>
You can easily use OpenBD with the popular <a href="http://eclipse.org/">Eclipse</a> desktp Java IDE.  The necessary .project/.classpath files are already checked into SVN enabling you to simply 'File' - 'Import Project'.   OpenBD does not
ship (for legal reasons) with the tools.jar file (required for WebServices) you need to define the JDK_16_TOOLS project variable which points to your local location of tools.jar.  Once you have done that, then OpenBD will happily build under Eclipse with no errors.
</p>

<p>
You can run OpenBD under Eclipse very easily using the <a href="https://code.google.com/p/run-jetty-run/">Run-Jetty-Run</a> Eclipse plugin.   This lets you run up an embedded Jetty Server allowing you to insert breakpoints and watch points.
</p>

<p>
The OpenBD project contains a sample '<b>./webapp/</b>' which can be used for your Eclipse project.
</p>

<h2>Contributing back to OpenBD</h2>

<p>
We welcome all contributions to OpenBD.  This is the power of open source projects, taking the collective wisdom of the 
community and applying it for the greater good.  We welcome bug fixes, enhancements, new tags/functions.  In order to have
you contribution accepted you must create a patch.  This is basically a file of the differences/additions from the current SVN tree.  Your SVN client (SmartSVN makes this easy) will create a single .patch file for you by navigating through its menu options.
</p>

<p>
Send your .patch file to info@aw20.co.uk which it will be reviewed and if applicable, accepted into the main build. You will be attributed in the acknowledgement page.  <i>Legal stuff: by submitting a patch you are basically assigning the ownership/copyright to the OpenBD project, thus releasing it under the GPL license.</i>
</p>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->