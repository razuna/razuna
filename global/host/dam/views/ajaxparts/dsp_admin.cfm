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
			<li><a href="##admin_users" onclick="loadcontent('admin_users','#myself#c.users');">#defaultsObj.trans("users")#</a></li>
			<li><a href="##admin_groups" onclick="loadcontent('admin_groups','#myself#c.groups_list&kind=ecp&loaddiv=admin_groups');">#defaultsObj.trans("groups")#</a></li>
			<li><a href="##custom_fields" onclick="loadcontent('custom_fields','#myself#c.custom_fields');">#defaultsObj.trans("custom_fields_header")#</a></li>
			<li><a href="##admin_labels" onclick="loadcontent('admin_labels','#myself#c.admin_labels');">#defaultsObj.trans("labels")#</a></li>
			<li><a href="##admin_schedules" onclick="loadcontent('admin_schedules','#myself#c.scheduler_list');">#defaultsObj.trans("scheduled_uploads")#</a></li>
			<li><a href="##admin_upl_templates" onclick="loadcontent('admin_upl_templates','#myself#c.upl_templates');">#defaultsObj.trans("admin_upload_templates")#</a></li>
			<li><a href="##admin_imp_templates" onclick="loadcontent('admin_imp_templates','#myself#c.imp_templates');">#defaultsObj.trans("import_templates")#</a></li>
			<li><a href="##admin_logs_all" onclick="loadcontent('log_show','#myself#c.log_assets');">#defaultsObj.trans("log_search_header")#</a></li>
			<!--- <li><a href="##admin_logs_users" onclick="loadcontent('log_users_show','#myself#c.log_users');">#defaultsObj.trans("log_users_header")#</a></li> --->
			<li><a href="##admin_settings" onclick="loadcontent('admin_settings','#myself#c.isp_settings');">#defaultsObj.trans("settings")#</a></li>
			<li><a href="##admin_maintenance" onclick="loadcontent('admin_maintenance','#myself#c.admin_maintenance');">#defaultsObj.trans("admin_maintenance")#</a></li>
			<li><a href="##admin_customization" onclick="loadcontent('admin_customization','#myself#c.admin_customization');">#defaultsObj.trans("header_customization")#</a></li>
			<li><a href="##admin_integration" onclick="loadcontent('admin_integration','#myself#c.admin_integration');">#defaultsObj.trans("header_integration")#</a></li>
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				<li><a href="##admin_maintenance_cloud" onclick="loadcontent('admin_maintenance_cloud','#myself#c.admin_maintenance_cloud');">Cloud #defaultsObj.trans("admin_maintenance")#</a></li>
			</cfif>
			<!--- <li><a href="##admin_api" onclick="loadcontent('admin_api','#myself#c.admin_api');">API</a></li> --->
			<li><a href="##admin_system" onclick="loadcontent('admin_system','#myself#c.admin_system');">System Information</a></li>
		</ul>
		<!--- Users --->
		<div id="admin_users">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Groups --->
		<div id="admin_groups">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Labels --->
		<div id="admin_labels">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Schedules --->
		<div id="custom_fields">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Schedules --->
		<div id="admin_schedules">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Upload Templates --->
		<div id="admin_upl_templates">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Import Templates --->
		<div id="admin_imp_templates">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Logs Searches --->
		<div id="admin_logs_all">
			<cfif session.hosttype EQ 0>
				<cfinclude template="dsp_host_upgrade.cfm">
			<cfelse>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
					<tr>
						<th colspan="2">#defaultsObj.trans("select_log")#: <a href="##" onclick="loadcontent('log_show','#myself#c.log_assets');">#defaultsObj.trans("log_header_assets")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_sum');">#defaultsObj.trans("log_header_searches_sum")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches');">#defaultsObj.trans("log_header_searches")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_folders');">#defaultsObj.trans("log_header_folders")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_users');">#defaultsObj.trans("log_users_header")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_errors');">Errors</a></th>
					</tr>
				</table>
				<div id="log_show">#defaultsObj.loadinggif("#dynpath#")#</div>
			</cfif>
		</div>
		<!--- Settings --->
		<div id="admin_settings">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Maintenance --->
		<div id="admin_maintenance">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Customization --->
		<div id="admin_customization">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Integration --->
		<div id="admin_integration">#defaultsObj.loadinggif("#dynpath#")#</div>
		<!--- Maintenance Cloud --->
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			<div id="admin_maintenance_cloud">#defaultsObj.loadinggif("#dynpath#")#</div>
		</cfif>
		<!--- API --->
		<!--- <div id="admin_api">#defaultsObj.loadinggif("#dynpath#")#</div> --->
		<!--- System Information --->
		<div id="admin_system">#defaultsObj.loadinggif("#dynpath#")#</div>
	</div>
	<!--- <div style="float:right;"><a href="##" onclick="destroywindow(1);return false;">#defaultsObj.trans("scheduler_close_cap")#</a></div> --->
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		jqtabs("tab_admin");
		loadcontent('admin_users','#myself#c.users');
	</script>	
</cfoutput>
	
