<cfset request.page.title 	= "Bootstrap CFML Application">
<cfset request.page.desc		= "This is a very simple 2 page application showing you to get started with a secure site">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
    	<li><a href="./?/support">Support</li>
      <li class="active"><a href="./?/bootstrap"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Bootstrap CFML Application</h1>

		<cfinclude template="pages/sidebar_support.inc" />
				
		<div class="section">

			<p>Getting started is sometimes the hardest thing you can do. That first step always seems to be the biggest. It needn't be that way. Let us help.</p>
			
			<p>We've pulled together a very simple 'structure' that you can use to get started with an application that simply authenticates users. There is a public section and a secure section.  You can't get to the secure section unless you are logged in.  Easy eh?</p>
			
			<p>We have all the CFML code laid out in a clean, documentated and easy to read manner so you can understand exactly what happens at each stage. This uses
				the well known <a href="./?/app_application_cfc"><code>Application.cfc</code></a> concepts to achieve this.</p>
			
			<p>You can try it for yourself here by visiting the link below, or download the .ZIP file and get up and running yourself. Feel free to use this as your
				basis for your own CFML applications.</p>
			
			<p><a href="./bootstrap-cfml/" class="btn bstrap">visit the bootstrap app</a></p>
			<p><a href="./bootstrap-cfml.zip" class="btn dload">download bootstrap app</a></p>
			
			<h2>Bootstrap CFML Snippets</h2>
			
			<p>The following is collection of small snippets of CFML code that shows some techniques that are often used.</p>
			
			<ul>
				<li><a href="./?/snippet_html2spreadsheet">Export an HTML table to a Spreadsheet (XLS)</a></li>
			</ul>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->