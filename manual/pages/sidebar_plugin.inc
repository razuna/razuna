<div class="sidebar cf">
	<div id="side_menu" class="show_cats">Categories <span><b></b></span></div>
	<ul class="categories">
		<li <cfif request.page.title == "CronTab Plugin">class="active"</cfif> ><a href="./?/plugin_cron">CronTab - Scheduler</a></li>
		<li <cfif request.page.title == "SMTP Extension">class="active"</cfif> ><a href="./?/plugin_cfsmtp">SMTP Processing Incoming Email</a></li>
		<li <cfif request.page.title == "CFML Debugger Plugin">class="active"</cfif> ><a href="./?/plugin_debugger">Debugger</a></li>
		<li <cfif request.page.title == "Message Plugin">class="active"</cfif> ><a href="./?/plugin_message">JMS Messaging</a></li>
		<li <cfif request.page.title == "Salesforce Plugin">class="active"</cfif> ><a href="./?/plugin_salesforce">SalesForce</a></li>
		<li <cfif request.page.title == "Exchange Plugin">class="active"</cfif> ><a href="./?/plugin_exchange">Microsoft Exchange</a></li>
		<li <cfif request.page.title == "Login Extension">class="active"</cfif> ><a href="./?/plugin_login">Login &ndash; Security</a></li>
	</ul>
</div><!--- .sidebar --->