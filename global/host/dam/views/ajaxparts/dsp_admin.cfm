<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfoutput>
	<div id="tab_admin">
		<ul>
			<li><a href="##admin_users" onclick="loadcontent('admin_users','#myself#c.users');">#myFusebox.getApplicationData().defaults.trans("users")#</a></li>
			<li><a href="##admin_groups" onclick="loadcontent('admin_groups','#myself#c.groups_list&kind=ecp&loaddiv=admin_groups');">#myFusebox.getApplicationData().defaults.trans("groups")#</a></li>
			<li><a href="##custom_fields" onclick="loadcontent('custom_fields','#myself#c.custom_fields');">#myFusebox.getApplicationData().defaults.trans("custom_fields_header")#</a></li>
			<li><a href="##admin_labels" onclick="loadcontent('admin_labels','#myself#c.admin_labels');">#myFusebox.getApplicationData().defaults.trans("labels")#</a></li>
			<li><a href="##admin_schedules" onclick="loadcontent('admin_schedules','#myself#c.scheduler_list');">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads")#</a></li>
			<li><a href="##admin_upl_templates" onclick="loadcontent('admin_upl_templates','#myself#c.upl_templates');">#myFusebox.getApplicationData().defaults.trans("admin_upload_templates")#</a></li>
			<li><a href="##admin_imp_templates" onclick="loadcontent('admin_imp_templates','#myself#c.imp_templates');">#myFusebox.getApplicationData().defaults.trans("import_templates")#</a></li>
			<li><a href="##admin_watermark_templates" onclick="loadcontent('admin_watermark_templates','#myself#c.admin_watermark_templates');">#myFusebox.getApplicationData().defaults.trans("watermark_templates")#</a></li>
			<li><a href="##admin_logs_all" onclick="loadcontent('log_show','#myself#c.log_assets');">#myFusebox.getApplicationData().defaults.trans("log_search_header")#</a></li>
			<!--- <li><a href="##admin_logs_users" onclick="loadcontent('log_users_show','#myself#c.log_users');">#myFusebox.getApplicationData().defaults.trans("log_users_header")#</a></li> --->
			<li><a href="##admin_settings" onclick="loadcontent('admin_settings','#myself#c.isp_settings');">#myFusebox.getApplicationData().defaults.trans("settings")#</a></li>
			<li><a href="##admin_maintenance" onclick="loadcontent('admin_maintenance','#myself#c.admin_maintenance');">#myFusebox.getApplicationData().defaults.trans("admin_maintenance")#</a></li>
			<li><a href="##admin_customization" onclick="loadcontent('admin_customization','#myself#c.admin_customization');">#myFusebox.getApplicationData().defaults.trans("header_customization")#</a></li>
			<li><a href="##admin_integration" onclick="loadcontent('admin_integration','#myself#c.admin_integration');">#myFusebox.getApplicationData().defaults.trans("header_integration")#</a></li>
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				<li><a href="##admin_maintenance_cloud" onclick="loadcontent('admin_maintenance_cloud','#myself#c.admin_maintenance_cloud');">Cloud #myFusebox.getApplicationData().defaults.trans("admin_maintenance")#</a></li>
			</cfif>
			<!--- <li><a href="##admin_api" onclick="loadcontent('admin_api','#myself#c.admin_api');">API</a></li> --->
			<li><a href="##admin_system" onclick="loadcontent('admin_system','#myself#c.admin_system');">#myFusebox.getApplicationData().defaults.trans("system_information")#</a></li>
			<li><a href="##ad_Services" onclick="loadcontent('ad_Services','#myself#c.ad_Services');">AD Services</a></li>
			<!--- Plugins --->
			<cfif qry_plugins.recordcount NEQ 0>
				<li><a href="##admin_plugins">#myFusebox.getApplicationData().defaults.trans("plugins")#</a></li>
			</cfif>
		</ul>
		<!--- Users --->
		<div id="admin_users">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Groups --->
		<div id="admin_groups">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Labels --->
		<div id="admin_labels">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Schedules --->
		<div id="custom_fields">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Schedules --->
		<div id="admin_schedules">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Upload Templates --->
		<div id="admin_upl_templates">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Import Templates --->
		<div id="admin_imp_templates">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Watermark Templates --->
		<div id="admin_watermark_templates">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Logs Searches --->
		<div id="admin_logs_all">
			<cfif session.hosttype EQ 0>
				<cfinclude template="dsp_host_upgrade.cfm">
			<cfelse>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
					<tr>
						<th colspan="2">#myFusebox.getApplicationData().defaults.trans("select_log")#: <a href="##" onclick="loadcontent('log_show','#myself#c.log_assets');">#myFusebox.getApplicationData().defaults.trans("log_header_assets")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_sum');">#myFusebox.getApplicationData().defaults.trans("log_header_searches_sum")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches');">#myFusebox.getApplicationData().defaults.trans("log_header_searches")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_folders');">#myFusebox.getApplicationData().defaults.trans("log_header_folders")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_users');">#myFusebox.getApplicationData().defaults.trans("log_users_header")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_errors');">Errors</a></th>
					</tr>
				</table>
				<div id="log_show">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
			</cfif>
		</div>
		<!--- Settings --->
		<div id="admin_settings">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Maintenance --->
		<div id="admin_maintenance">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Customization --->
		<div id="admin_customization">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Integration --->
		<div id="admin_integration">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!--- Maintenance Cloud --->
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			<div id="admin_maintenance_cloud">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		</cfif>
		<!--- API --->
		<!--- <div id="admin_api">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div> --->
		<!--- System Information --->
		<div id="admin_system">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<div id="ad_Services">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<!---<div id="admin_system">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>--->
		<!--- Plugins --->
		<cfif qry_plugins.recordcount NEQ 0>
			<div id="admin_plugins">
				<div>#myFusebox.getApplicationData().defaults.trans("plugins_installed")#</div>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("plugin")#</th>
						<th>#myFusebox.getApplicationData().defaults.trans("description")#</th>
					</tr>
					<cfloop query="qry_plugins">
						<tr>
							<td valign="top" nowrap="nowrap"><strong>#p_name#</strong><br /><div style="padding-top:5px;"><a href="##" onclick="loadcontent('rightside','#myself#c.plugin_settings&p_id=#p_id#');return false;">#myFusebox.getApplicationData().defaults.trans("settings")#</a> | <a href="##" onclick="showwindow('#myself#c.admin_plugin_one&p_id=#p_id#','Information about this plugin',450,1);return false;">#myFusebox.getApplicationData().defaults.trans("plugin_information")#</a></div></td>
							<td valign="top">#p_description#<br />#myFusebox.getApplicationData().defaults.trans("plugin_version")#: #p_version# | #myFusebox.getApplicationData().defaults.trans("plugin_author")#: #p_author#</td>
						</tr>
					</cfloop>
				</table>
			</div>
		</cfif>
	</div>
	<!--- <div style="float:right;"><a href="##" onclick="destroywindow(1);return false;">#myFusebox.getApplicationData().defaults.trans("scheduler_close_cap")#</a></div> --->
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		jqtabs("tab_admin");
		loadcontent('admin_users','#myself#c.users');
	</script>	
</cfoutput>

