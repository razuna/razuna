<cfset request.page.title = "Chrome Extension"><cfset request.page.section = "support">
<cfset request.page.desc	= "OpenBD Google Chrome Extension">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li class="active"><a href="./?/support"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Support</h1>

		<cfinclude template="pages/sidebar_support.inc" />

		<div class="section">

			<p>The OpenBD Manual Google Chrome Extension. The extension provides a quick and easy way to access details of
			tags and functions available to you in OpenBD.</p>

			<p class="center">
				<img src="images/chrome-extension.png" title="Chrome Extension" />
			</p>

			<p class="center">
				<a href="https://chrome.google.com/webstore/detail/openbd/khcnhdehhgbmkncjefpifbfekmkhbgnf" class="btn google ext">Install Chrome Extension</a>
			</p>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->
