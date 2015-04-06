<div class="sidebar cf">
	<div id="side_menu" class="show_cats">Show Categories <span><b></b></span></div>
	<ul class="categories">
		<li <cfif request.page.title == "Support">class="active"</cfif> ><a href="./?/support">Support</a></li>
		<li <cfif request.page.title == "Support Professional">class="active"</cfif> ><a href="./?/support_professional">Support Professional</a></li>
		<li <cfif request.page.title == "Bootstrap CFML Application">class="active"</cfif> ><a href="./?/bootstrap">Bootstrap Application</a></li>
		<li <cfif request.page.title == "Engine Releases">class="active"</cfif> ><a href="./?/releases">Releases Notes</a></li>
		<li <cfif request.page.title == "Upgrade">class="active"</cfif> ><a href="./?/upgrade">Upgrade Details</a></li>
		<li><a href="http://openbd.org/downloads/">Download Site</a></li>
		<li <cfif request.page.title == "chrome extension">class="active"</cfif> ><a href="./?/extension">Chrome Extension</a></li>
		<li <cfif request.page.title == "SVN">class="active"</cfif> ><a href="./?/svn">SVN Repository</a></li>
		<li <cfif request.page.title == "Acknowledgements">class="active"</cfif> ><a href="./?/acknowledgement">Acknowledgements</a></li>
	</ul>
</div><!--- .sidebar --->
