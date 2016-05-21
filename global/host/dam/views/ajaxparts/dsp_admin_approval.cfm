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
	<form name="form_admin_approval" id="form_admin_approval" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.admin_approval_save">

		<h2>Approval</h2>
		<p>Configure your approval process below. Once the approval process is activated, it will execute *before* any workflow, i.e. if you have a workflow applied to a folder all workflow actions will execute *after* after the files have been aproved.</p>
		
		<hr>

		<!--- Activate --->
		<h3>Enable approval process</h3>
		<p>Check the checkbox below in order to have the approval process enabled. Once activated it will apply imemdiately to all (selected) folders.</p>
		<p>
			<input type="checkbox" value="true" name="approval_enabled"<cfif qry_approval.approval_enabled> checked="checked"</cfif>> Enable approval process
		</p>

		<!--- Folder selection --->
		<h3>Folder Selection</h3>
		<p>Select the folders that the approval process should apply to.</p>
		<table width="100%" border="0">
			<tr>
				<td style="width:450px;">
					<select data-placeholder="Choose folder(s)" class="chzn-select" style="width:450px;" id="selectfolder" name="approval_folders" multiple>
						<option value=""></option>
						<cfloop query="qry_folders">
							<option value="#folder_id#"<cfif ListFindnocase(qry_approval.approval_folders, folder_id)> selected="selected"</cfif>>#folder_path#<cfif folder_of_user EQ "t"> (#username#)</cfif></option>
						</cfloop>
					</select>
				</td>
				<td valign="top"><input type="checkbox" value="true" name="approval_folders_all"<cfif qry_approval.approval_folders_all> checked="checked"</cfif>> Apply approval process to all folders</td>
			</tr>
		</table>
		
		<!--- Approval Group 1 --->
		<h3>Approval Group 1</h3>
		<p>Select from the list which users/groups are responsible to approve uploads</p>
		<!--- <cfdump var="#qry_groups#"><cfabort>  --->
		<table width="100%" border="0">
			<tr>
				<td style="width:450px;">
					<select data-placeholder="Choose users/groups" class="chzn-select" style="width:450px;" id="selectuser" name="approval_group_1" multiple>
						<option value=""></option>
						<optgroup label="Groups">
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif ListFindnocase(qry_approval.approval_group_1, grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
						</optgroup>
						<optgroup label="Users">
							<cfoutput query="qry_users" group="user_id">
								<option value="#user_id#"<cfif ListFindnocase(qry_approval.approval_group_1, user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfoutput>
						</optgroup>
					</select>
				</td>
				<td valign="top">
					<input type="checkbox" value="true" name="approval_group_1_all"<cfif qry_approval.approval_group_1_all> checked="checked"</cfif>> All users/groups have to approve
				</td>
			</tr>
		</table>

		<br><br>

		<!--- Submit --->
		<div id="form_admin_approval_status" style="float:left;font-weight:bold;color:green;"></div>
		<div style="float:right;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>

	</form>

	<br><br>
	
	<!--- JS --->
	<script type="text/javascript">
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true, single_backstroke_delete : false });
		// Submit
		$("##form_admin_approval").submit(function(e) {
			// Get values
			var url = formaction("form_admin_approval");
			var items = formserialize("form_admin_approval");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
			   		$('##form_admin_approval_status').html('#myFusebox.getApplicationData().defaults.trans("success")#').animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
			return false;
		});
	</script>

</cfoutput>