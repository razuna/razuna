<div class="sidebar cf">
	<div id="side_menu" class="show_cats">Categories <span><b></b></span></div>
	<ul class="categories">
		<li <cfif request.page.title == "OpenBD Engine">class="active"</cfif> ><a href="./?/engine">Overview</a></li>
		<li <cfif request.page.title == "OpenBD Engine: bluedragon.xml">class="active"</cfif> ><a href="./?/engine_bluedragonxml">bluedragon.xml</a></li>
		<li <cfif request.page.title == "OpenBD Log Files">class="active"</cfif> ><a href="./?/engine_logfiles">Log files</a></li>
		<li <cfif request.page.title == "OpenBD Outgoing Email">class="active"</cfif> ><a href="./?/engine_cfmail">Outgoing Email</a></li>
		<li <cfif request.page.title == "Microsoft Windows Service">class="active"</cfif> ><a href="./?/windows_server">Microsoft Windows</a></li>
		<li <cfif request.page.title == "Nullsoft Scriptable Install System and OpenBD Local">class="active"</cfif> ><a href="./?/local_nsis">NSIS + OpenBD Local</a></li>
	</ul>
</div><!--- .sidebar --->