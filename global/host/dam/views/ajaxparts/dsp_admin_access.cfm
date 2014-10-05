<cfoutput>
<p>#myFusebox.getApplicationData().defaults.trans("header_access_text")#</p>
<cfform name="form_access_control" id="form_access_control" method="post" action="#self#">
	<cfinput type="hidden" name="#theaction#" value="c.admin_access_save">
	<table border="0">
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("users")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="users_access" id="users_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"users_access") AND listfind(access_struct.users_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"users_access") AND listfind(access_struct.users_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("groups")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="groups_access" id="groups_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"groups_access") AND  listfind(access_struct.groups_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"groups_access") AND listfind(access_struct.groups_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("custom_fields_header")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="customfields_access" id="customfields_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"customfields_access") AND  listfind(access_struct.customfields_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"customfields_access") AND listfind(access_struct.customfields_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("labels")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="labels_access" id="labels_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"labels_access") AND  listfind(access_struct.labels_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"labels_access") AND listfind(access_struct.labels_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="schedules_access" id="schedules_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"schedules_access") AND  listfind(access_struct.schedules_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"schedules_access") AND listfind(access_struct.schedules_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("admin_upload_templates")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="renditiontemplates_access" id="renditiontemplates_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"renditiontemplates_access") AND  listfind(access_struct.renditiontemplates_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"renditiontemplates_access") AND listfind(access_struct.renditiontemplates_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("import_templates")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="importtemplates_access" id="importtemplates_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"importtemplates_access") AND  listfind(access_struct.importtemplates_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"importtemplates_access") AND listfind(access_struct.importtemplates_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("export_template")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="exporttemplate_access" id="exporttemplate_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"exporttemplate_access") AND  listfind(access_struct.exporttemplate_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"exporttemplate_access") AND listfind(access_struct.exporttemplate_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("watermark_templates")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="watermarktemplates_access" id="watermarktemplates_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"watermarktemplates_access") AND  listfind(access_struct.watermarktemplates_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"watermarktemplates_access") AND listfind(access_struct.watermarktemplates_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("log_search_header")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="logs_access" id="logs_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"logs_access") AND  listfind(access_struct.logs_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"logs_access") AND listfind(access_struct.logs_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("settings")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="settings_access" id="settings_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"settings_access") AND  listfind(access_struct.settings_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"settings_access") AND listfind(access_struct.settings_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("admin_maintenance")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="maintenance_access" id="maintenance_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"maintenance_access") AND  listfind(access_struct.maintenance_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"maintenance_access") AND listfind(access_struct.maintenance_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("header_customization")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="customization_access" id="customization_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"customization_access") AND  listfind(access_struct.customization_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"customization_access") AND listfind(access_struct.customization_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("header_notification")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="emailsetup_access" id="emailsetup_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"emailsetup_access") AND  listfind(access_struct.emailsetup_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"emailsetup_access") AND listfind(access_struct.emailsetup_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("header_integration")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="serviceaccounts_access" id="serviceaccounts_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"serviceaccounts_access") AND  listfind(access_struct.serviceaccounts_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"serviceaccounts_access") AND listfind(access_struct.serviceaccounts_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<!--- <tr>
			<td>#myFusebox.getApplicationData().defaults.trans("system_information")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="systeminformation_access" id="systeminformation_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"systeminformation_access") AND  listfind(access_struct.systeminformation_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"systeminformation_access") AND listfind(access_struct.systeminformation_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr> --->
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("ad_services")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="adservices_access" id="adservices_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"adservices_access") AND  listfind(access_struct.adservices_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"adservices_access") AND listfind(access_struct.adservices_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>Cloud #myFusebox.getApplicationData().defaults.trans("admin_maintenance")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="cloud_access" id="cloud_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"cloud_access") AND  listfind(access_struct.cloud_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"cloud_access") AND listfind(access_struct.cloud_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("plugins")# #myFusebox.getApplicationData().defaults.trans("tab")#</td>
			<td>
				<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="plugins_access" id="plugins_access" multiple="multiple">
					<option value=""></option>
					<cfloop query="qry_groups">
						<option value="#grp_id#"<cfif structkeyexists(access_struct,"plugins_access") AND  listfind(access_struct.plugins_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
					</cfloop>
					<cfloop query="qry_users">
						<option value="#user_id#"<cfif structkeyexists(access_struct,"plugins_access") AND listfind(access_struct.plugins_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<!--- For WhiteLabelling --->
		<cfif application.razuna.whitelabel>
			<tr>
				<td>White-Labelling #myFusebox.getApplicationData().defaults.trans("tab")#</td>
				<td>
					<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="whitelabelling_access" id="whitelabelling_access" multiple="multiple">
						<option value=""></option>
						<cfloop query="qry_groups">
							<option value="#grp_id#"<cfif structkeyexists(access_struct,"whitelabelling_access") AND  listfind(access_struct.whitelabelling_access,grp_id)> selected="selected"</cfif>>#grp_name#</option>
						</cfloop>
						<cfloop query="qry_users">
							<option value="#user_id#"<cfif structkeyexists(access_struct,"whitelabelling_access") AND listfind(access_struct.whitelabelling_access,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</cfif>
	</table>
	<div id="form_access_control_status" style="float:left;font-weight:bold;color:green;"></div>
	<div style="float:right;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
	<br/><br/>
</cfform>
<script type="text/javascript">
	// Activate Chosen
	$(".chzn-select").chosen({search_contains: true});

	// Submit Form
		$("##form_access_control").submit(function(e){
			// Get values
			var url = formaction("form_access_control");
			var items = formserialize("form_access_control");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
			   		$('##form_access_control_status').html('#myFusebox.getApplicationData().defaults.trans("success")#').animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
			return false;
		});

</script>

</cfoutput>