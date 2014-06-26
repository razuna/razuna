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
	<div style="padding:10px;min-height:300px;">
		<!--- Group --->
		<form name="grpedit" onsubmit="updategrp(#attributes.grp_id#,'#attributes.kind#','#attributes.loaddiv#');return false;">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
				<tr>
					<th colspan="2">#myFusebox.getApplicationData().defaults.trans("groups_edit")#</th>
				</tr>
				<tr>
					<td width="100%">
						<cfif attributes.grp_id EQ 2>
							#qry_detail.grp_name#
							<input type = 'hidden' name="grpname" id="grpname" value="#qry_detail.grp_name#">
						<cfelse>
							<input type="text" size="40" name="grpname" id="grpname" value="#qry_detail.grp_name#" tabindex="1" />
						</cfif>
						<br/>
						<cfif prefs.set2_upc_enabled>
							<strong>#myFusebox.getApplicationData().defaults.trans("group_upc_size_text")#</strong>
							<select name="editupcsize" id="editupcsize" style="margin-left:10px;width:90px;">
								<option value="">None</option>
								<option value="10" <cfif qry_detail.upc_size EQ 10 >selected=selected</cfif>>10</option>
								<option value="11" <cfif qry_detail.upc_size EQ 11 >selected=selected</cfif>>11</option>
								<option value="12" <cfif qry_detail.upc_size EQ 12 >selected=selected</cfif>>12</option>
								<option value="13" <cfif qry_detail.upc_size EQ 13 >selected=selected</cfif>>13</option>
								<option value="14" <cfif qry_detail.upc_size EQ 14 >selected=selected</cfif>>14</option>
							</select>
						<cfelse>
							<input type = "hidden" name="editupcsize" id="editupcsize" value="">
						</cfif>
					</td>
					<td width="1%" nowrap="true"><cfif attributes.grp_id NEQ 2 OR prefs.set2_upc_enabled><input type="Button" name="Button" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" onclick="javascript:updategrp('#attributes.grp_id#','#attributes.kind#','#attributes.loaddiv#');" /></cfif></td>
					<td nowrap="true">
					<tr>	
					<td >
						<strong>#myFusebox.getApplicationData().defaults.trans("group_folder_notify_text")#</strong>
						<input type="radio" name="edit_folder_subscribe" value="true" <cfif qry_detail.folder_subscribe EQ 'true'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")# 
						<input type="radio" name="edit_folder_subscribe" value="false" <cfif qry_detail.folder_subscribe EQ 'false'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")#
					</td>
					</tr>
				</tr>
				<!--- RAZ-2824 :: UPC folder structure download option enabled. ---> 
				<cfif prefs.set2_upc_enabled>
				<tr>
					<td><strong>#myFusebox.getApplicationData().defaults.trans("group_upc_folder_text")#</strong>
						<input type="radio" name="edit_upc_folder_structure" value="true" <cfif qry_detail.upc_folder_format EQ 'true'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")# 
						<input type="radio" name="edit_upc_folder_structure" value="false" <cfif qry_detail.upc_folder_format EQ 'false'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")#
					</td>
				</tr>
				<cfelse>
					<input type = 'hidden' name="edit_upc_folder_structure" value="false">
				</cfif>
			</table>
		</form>
		<!--- Add User --->
		<div style="padding-left:5px;">
			<strong>Add Users</strong>
			<br />
			<div style="clear:both;padding-top:5px;"></div>
			<select data-placeholder="Choose a User" class="chzn-select" style="width:350px;" tabindex="2" id="selectuser" onchange="userselected();">
          		<option value=""></option>
          		<cfoutput query="qry_users" group="user_id">
          			<option value="#user_id#">#user_first_name# #user_last_name# (#user_email#)</option>
          		</cfoutput>
          	</select>
		</div>
		<!--- List Users --->
		<div id="listusers"></div>
	</div>
	<!--- JS --->
	<script type="text/javascript">
		// Activate Chosen
		$(".chzn-select").chosen();
		// Load existing users
		loadcontent('listusers','#myself#c.groups_list_users&grp_id=#attributes.grp_id#');
		// When user is selected
		function userselected(){
			$("##selectuser").chosen().change( 
				loadcontent('listusers','#myself#c.groups_list_users_add&grp_id=#attributes.grp_id#&user_id=' + $('##selectuser option:selected').val())
			);
		}
	</script>
</cfoutput>