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
<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
	<cfset isadmin = true>
<cfelse>
	<cfset isadmin = false>
</cfif>
<cfoutput>
	<div id="tab_admin">
		<ul>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"users_access") AND tabaccess_struct.users_access)>
				<li><a href="##admin_users" onclick="loadcontent('admin_users','#myself#c.users');">#myFusebox.getApplicationData().defaults.trans("users")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"groups_access") AND tabaccess_struct.groups_access)>
				<li><a href="##admin_groups" onclick="loadcontent('admin_groups','#myself#c.groups_list&kind=ecp&loaddiv=admin_groups');">#myFusebox.getApplicationData().defaults.trans("groups")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"customfields_access") AND tabaccess_struct.customfields_access)>
				<li><a href="##custom_fields" onclick="loadcontent('custom_fields','#myself#c.custom_fields');">#myFusebox.getApplicationData().defaults.trans("custom_fields_header")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"labels_access") AND tabaccess_struct.labels_access)>
				<li><a href="##admin_labels" onclick="loadcontent('admin_labels','#myself#c.admin_labels');">#myFusebox.getApplicationData().defaults.trans("labels")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"schedules_access") AND tabaccess_struct.schedules_access)>
				<li><a href="##admin_schedules" onclick="loadcontent('admin_schedules','#myself#c.scheduler_list&offset_sched=0');">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"renditiontemplates_access") AND tabaccess_struct.renditiontemplates_access)>
				<li><a href="##admin_upl_templates" onclick="loadcontent('admin_upl_templates','#myself#c.upl_templates');">#myFusebox.getApplicationData().defaults.trans("admin_upload_templates")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"importtemplates_access") AND tabaccess_struct.importtemplates_access)>
				<li><a href="##admin_imp_templates" onclick="loadcontent('admin_imp_templates','#myself#c.imp_templates');">#myFusebox.getApplicationData().defaults.trans("import_templates")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"exporttemplate_access") AND tabaccess_struct.exporttemplate_access)>
				<li><a href="##admin_export_template" onclick="loadcontent('admin_export_template','#myself#c.admin_export_template');">#myFusebox.getApplicationData().defaults.trans("export_template")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"watermarktemplates_access") AND tabaccess_struct.watermarktemplates_access)>
				<li><a href="##admin_watermark_templates" onclick="loadcontent('admin_watermark_templates','#myself#c.admin_watermark_templates');">#myFusebox.getApplicationData().defaults.trans("watermark_templates")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"logs_access") AND tabaccess_struct.logs_access)>
				<li><a href="##admin_logs_all" onclick="loadcontent('log_show','#myself#c.log_assets&offset_log=0');">#myFusebox.getApplicationData().defaults.trans("log_search_header")#</a></li>
				<!--- <li><a href="##admin_logs_users" onclick="loadcontent('log_users_show','#myself#c.log_users');">#myFusebox.getApplicationData().defaults.trans("log_users_header")#</a></li> --->
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"settings_access") AND tabaccess_struct.settings_access)>
				<li><a href="##admin_settings" onclick="loadcontent('admin_settings','#myself#c.isp_settings');">#myFusebox.getApplicationData().defaults.trans("settings")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"maintenance_access") AND tabaccess_struct.maintenance_access)>
				<li><a href="##admin_maintenance" onclick="loadcontent('admin_maintenance','#myself#c.admin_maintenance');">#myFusebox.getApplicationData().defaults.trans("admin_maintenance")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"customization_access") AND tabaccess_struct.customization_access)>
				<li><a href="##admin_customization" onclick="loadcontent('admin_customization','#myself#c.admin_customization');">#myFusebox.getApplicationData().defaults.trans("header_customization")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"emailsetup_access") AND tabaccess_struct.emailsetup_access)>
				<li><a href="##admin_notification" onclick="loadcontent('admin_notification','#myself#c.admin_notification');">#myFusebox.getApplicationData().defaults.trans("header_notification")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"serviceaccounts_access") AND tabaccess_struct.serviceaccounts_access)>
				<li><a href="##admin_integration" onclick="loadcontent('admin_integration','#myself#c.admin_integration');">#myFusebox.getApplicationData().defaults.trans("header_integration")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"cloud_access") AND tabaccess_struct.cloud_access)>
				<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
					<li><a href="##admin_maintenance_cloud" onclick="loadcontent('admin_maintenance_cloud','#myself#c.admin_maintenance_cloud');">Cloud #myFusebox.getApplicationData().defaults.trans("admin_maintenance")#</a></li>
				</cfif>
			</cfif>
			<!--- Only show the Access Control tab to admins --->
			<cfif isadmin>
				<li><a href="##admin_access" onclick="loadcontent('admin_access','#myself#c.admin_access');">#myFusebox.getApplicationData().defaults.trans("header_access")#</a></li>
			</cfif>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"plugins_access") AND tabaccess_struct.plugins_access)>
				<!--- Plugins --->
				<cfif qry_plugins.recordcount NEQ 0>
					<li><a href="##admin_plugins">#myFusebox.getApplicationData().defaults.trans("plugins")#</a></li>
				</cfif>
			</cfif>
			<!--- <cfif isadmin OR (structkeyexists(tabaccess_struct,"systeminformation_access") AND tabaccess_struct.systeminformation_access)>
				<li><a href="##admin_system" onclick="loadcontent('admin_system','#myself#c.admin_system');">#myFusebox.getApplicationData().defaults.trans("system_information")#</a></li>
			</cfif> --->
			<!--- AD --->
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"adservices_access") AND tabaccess_struct.adservices_access)>
				<li><a href="##ad_Services" onclick="loadcontent('ad_Services','#myself#c.ad_Services');">#myFusebox.getApplicationData().defaults.trans("ad_services")#</a></li>
			</cfif>
			<!--- While Label News --->
			<cfif application.razuna.whitelabel>
				<cfif isadmin OR (structkeyexists(tabaccess_struct,"whitelabelling_access") AND tabaccess_struct.whitelabelling_access)>
					<li><a href="##wl" onclick="loadcontent('wl','#myself#c.wl_host');">White-Labelling</a></li>
				</cfif>
			</cfif>
		</ul>
		
		<!--- Users --->
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"users_access") AND tabaccess_struct.users_access)>
			<div id="admin_users"></div>
		</cfif>
		<!--- Groups --->
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"groups_access") AND tabaccess_struct.groups_access)>
			<div id="admin_groups"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"customfields_access") AND tabaccess_struct.customfields_access)>
			<!--- Schedules --->
			<div id="custom_fields"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"labels_access") AND tabaccess_struct.labels_access)>
			<!--- Labels --->
			<div id="admin_labels"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"schedules_access") AND tabaccess_struct.schedules_access)>
			<!--- Schedules --->
			<div id="admin_schedules"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"renditiontemplates_access") AND tabaccess_struct.renditiontemplates_access)>
			<!--- Upload Templates --->
			<div id="admin_upl_templates"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"importtemplates_access") AND tabaccess_struct.importtemplates_access)>
			<!--- Import Templates --->
			<div id="admin_imp_templates"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"exporttemplate_access") AND tabaccess_struct.exporttemplate_access)>
			<div id="admin_export_template"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"watermarktemplates_access") AND tabaccess_struct.watermarktemplates_access)>
			<!--- Watermark Templates --->
			<div id="admin_watermark_templates"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"logs_access") AND tabaccess_struct.logs_access)>
			<!--- Logs Searches --->
			<div id="admin_logs_all">
				<cfif session.hosttype EQ 0>
					<cfinclude template="dsp_host_upgrade.cfm">
				<cfelse>
					<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
						<tr>
							<th colspan="2">#myFusebox.getApplicationData().defaults.trans("select_log")#: <a href="##" onclick="loadcontent('log_show','#myself#c.log_assets&offset_log=0');">#myFusebox.getApplicationData().defaults.trans("log_header_assets")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_sum&offset_log=0');">#myFusebox.getApplicationData().defaults.trans("log_header_searches_sum")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches&offset_log=0');">#myFusebox.getApplicationData().defaults.trans("log_header_searches")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_folders&offset_log=0');">#myFusebox.getApplicationData().defaults.trans("log_header_folders")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_users&offset_log=0');">#myFusebox.getApplicationData().defaults.trans("log_users_header")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_errors&offset_log=0');">Errors</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_folder_summary&folder_id=0');">Folder Summary</a></th>
						</tr>
					</table>
					<div id="log_show"></div>
				</cfif>
			</div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"settings_access") AND tabaccess_struct.settings_access)>
			<!--- Settings --->
			<div id="admin_settings"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"maintenance_access") AND tabaccess_struct.maintenance_access)>
			<!--- Maintenance --->
			<div id="admin_maintenance"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"customization_access") AND tabaccess_struct.customization_access)>
			<!--- Customization --->
			<div id="admin_customization"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"emailsetup_access") AND tabaccess_struct.emailsetup_access)>
			<!--- Notification --->
			<div id="admin_notification"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"serviceaccounts_access") AND tabaccess_struct.serviceaccounts_access)>
			<!--- Integration --->
			<div id="admin_integration"></div>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"cloud_access") AND tabaccess_struct.cloud_access)>
			<!--- Maintenance Cloud --->
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				<div id="admin_maintenance_cloud"></div>
			</cfif>
		</cfif>
			<!--- Access Control --->
			<cfif isadmin>
				<div id="admin_access"></div>
			</cfif>
			<!--- API --->
			<!--- <div id="admin_api"></div> --->
			<!--- System Information --->
		<!--- <cfif isadmin OR (structkeyexists(tabaccess_struct,"systeminformation_access") AND tabaccess_struct.systeminformation_access)>
			<div id="admin_system"></div>
		</cfif> --->
		<!--- AD --->
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"adservices_access") AND tabaccess_struct.adservices_access)>
			<div id="ad_Services"></div>
		</cfif>
		<!--- WL News --->
		<cfif application.razuna.whitelabel>
			<cfif isadmin OR (structkeyexists(tabaccess_struct,"whitelabelling_access") AND tabaccess_struct.whitelabelling_access)>
				<div id="wl"></div>
			</cfif>
		</cfif>
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"plugins_access") AND tabaccess_struct.plugins_access)>
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
		</cfif>
		<div id="msg" style="text-align:center;display:none;">
			<h4>
				<cfif NOT isadmin AND structisempty(tabaccess_struct)>
					No administrative features available for user
				</cfif>
			</h4>
		</div>
	</div>
	<!--- <div style="float:right;"><a href="##" onclick="destroywindow(1);return false;">#myFusebox.getApplicationData().defaults.trans("scheduler_close_cap")#</a></div> --->
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		$("##tab_admin").tabs();
		
		<cfif isadmin OR (structkeyexists(tabaccess_struct,"users_access") AND tabaccess_struct.users_access)>
			loadcontent('admin_users','#myself#c.users'); 
		<cfelseif structisempty(tabaccess_struct)>
			 $('##msg').css('display','');
		<cfelseif structkeyexists(tabaccess_struct,"groups_access") AND tabaccess_struct.groups_access>
			loadcontent('admin_groups','#myself#c.groups_list&kind=ecp&loaddiv=admin_groups');
		<cfelseif structkeyexists(tabaccess_struct,"customfields_access") AND tabaccess_struct.customfields_access>
			loadcontent('custom_fields','#myself#c.custom_fields');
		<cfelseif structkeyexists(tabaccess_struct,"labels_access") AND tabaccess_struct.labels_access>
			loadcontent('admin_labels','#myself#c.admin_labels');
		<cfelseif structkeyexists(tabaccess_struct,"schedules_access") AND tabaccess_struct.schedules_access>
			loadcontent('admin_schedules','#myself#c.scheduler_list&offset_sched=0');
		<cfelseif structkeyexists(tabaccess_struct,"renditiontemplates_access") AND tabaccess_struct.renditiontemplates_access>
			loadcontent('admin_upl_templates','#myself#c.upl_templates');
		<cfelseif structkeyexists(tabaccess_struct,"importtemplates_access") AND tabaccess_struct.importtemplates_access>
			loadcontent('admin_imp_templates','#myself#c.imp_templates');
		<cfelseif structkeyexists(tabaccess_struct,"exporttemplate_access") AND tabaccess_struct.exporttemplate_access>
			loadcontent('admin_export_template','#myself#c.admin_export_template');
		<cfelseif structkeyexists(tabaccess_struct,"watermarktemplates_access") AND tabaccess_struct.watermarktemplates_access>
			loadcontent('admin_watermark_templates','#myself#c.admin_watermark_templates');
		<cfelseif structkeyexists(tabaccess_struct,"logs_access") AND tabaccess_struct.logs_access>
			loadcontent('log_show','#myself#c.log_assets&offset_log=0');
		<cfelseif structkeyexists(tabaccess_struct,"settings_access") AND tabaccess_struct.settings_access>
			loadcontent('admin_settings','#myself#c.isp_settings');
		<cfelseif structkeyexists(tabaccess_struct,"maintenance_access") AND tabaccess_struct.maintenance_access>
			loadcontent('admin_maintenance','#myself#c.admin_maintenance');
		<cfelseif structkeyexists(tabaccess_struct,"customization_access") AND tabaccess_struct.customization_access>
			loadcontent('admin_customization','#myself#c.admin_customization');
		<cfelseif structkeyexists(tabaccess_struct,"emailsetup_access") AND tabaccess_struct.emailsetup_access>
			loadcontent('admin_notification','#myself#c.admin_notification');
		<cfelseif structkeyexists(tabaccess_struct,"serviceaccounts_access") AND tabaccess_struct.serviceaccounts_access>
			loadcontent('admin_integration','#myself#c.admin_integration');
		<cfelseif structkeyexists(tabaccess_struct,"cloud_access") AND tabaccess_struct.cloud_access>
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				loadcontent('admin_maintenance_cloud','#myself#c.admin_maintenance_cloud');
			</cfif>
		<cfelseif structkeyexists(tabaccess_struct,"systeminformation_access") AND tabaccess_struct.systeminformation_access>
			loadcontent('admin_system','#myself#c.admin_system');
		<cfelseif structkeyexists(tabaccess_struct,"adservices_access") AND tabaccess_struct.adservices_access>
			loadcontent('ad_Services','#myself#c.ad_Services');
		</cfif>
		
	</script>	
</cfoutput>

