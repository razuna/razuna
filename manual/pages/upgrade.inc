<cfset request.page.title = "Upgrade"><cfset request.page.section = "support">
<cfset request.page.desc	= "Upgrading OpenBD">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
    	<li><a href="./?/support">Support</li>
      <li class="active"><a href="./?upgrade"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Upgrade</h1>

		<cfinclude template="pages/sidebar_support.inc" />
				
		<div class="section">

			<p>Discover how to upgrade your various versions of OpenBD between versions.</p>
			
			<h2>from 1.4 to 2.0</h2>
			
			<p>From a CFML point of view there are no changes to code required. All functions/tags work as expected.</p>
			
			<p>It is advised to completely replace all your JAR files in the standard /WEB-INF/lib/ location with all the JAR
			files shipped with standard WAR release.  If you were using the SpreadSheet Plugin, CronTab PlugIn or CFSMTP
			PlugIn in 1.4 you no longer need to include these JAR files. These are part of the core build.</p>
			
			<p>If you were using the MongoDB CFC from 1.4 then you can continue to do so.  However, you do not need to include
			the JAR file as this is now included in the core build along with specific MongoDB functions.</p>
			
			<p>Many 3rd party JARs got updated with this release, so please start fresh, and if you are using any custom JAR files
			then copy them back in again.</p>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->