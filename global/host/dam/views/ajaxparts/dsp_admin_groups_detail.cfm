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
	<!--- Unsubscribe success div--->
	<div id="unsubscribe_success" style="display:none;height:0;color:green;">
	</div>
	<div style="min-height:300px;margin-top:0;">
		<!--- Group --->
		<form name="grpedit" id="grpedit" onsubmit="updategrp(#attributes.grp_id#,'#attributes.kind#','#attributes.loaddiv#');return false;">
			<input type="hidden" name="folder_redirect" id="folder_redirect" value="#qry_detail.folder_redirect#">
			<table width="100%" border="0" cellspacing="0" cellpadding="5">
				<tr>
					<td width="100%">
						<strong>#myFusebox.getApplicationData().defaults.trans("groups_edit")#</strong><br/>
						<cfif attributes.grp_id EQ 2>
							#qry_detail.grp_name#
							<input type = 'hidden' name="grpname" id="grpname" value="#qry_detail.grp_name#">
						<cfelse>
							<input type="text" size="40" name="grpname" id="grpname" value="#qry_detail.grp_name#" tabindex="1" />
						</cfif>
					</td>
				</tr>
				<tr>	
					<td >
						<strong>#myFusebox.getApplicationData().defaults.trans("group_folder_notify_text")#</strong><br/>
						#myFusebox.getApplicationData().defaults.trans("group_folder_notify_desc")#<br/>
						<input type="radio" name="edit_folder_subscribe" value="true" <cfif qry_detail.folder_subscribe EQ 'true'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")# 
						<input type="radio" name="edit_folder_subscribe" value="false" <cfif qry_detail.folder_subscribe EQ 'false'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")#
						<br/>
						<a href="##"  onclick="unsubscribe();">#myFusebox.getApplicationData().defaults.trans("group_notifications_current_users")# </a>
					</td>
				</tr>
				<!--- RAZ-2824 :: UPC folder structure download option and UPC size  ---> 
				<cfif prefs.set2_upc_enabled>
					<tr>
						<td><strong>#myFusebox.getApplicationData().defaults.trans("group_upc_folder_text")#</strong><br/>
							<input type="radio" name="edit_upc_folder_structure" value="true" <cfif qry_detail.upc_folder_format EQ 'true'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")# 
							<input type="radio" name="edit_upc_folder_structure" value="false" <cfif qry_detail.upc_folder_format EQ 'false'> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")#
						</td>
					</tr>
					<tr>
						<td>
							<strong>#myFusebox.getApplicationData().defaults.trans("group_upc_size_text")#</strong><br/>
							<select name="editupcsize" id="editupcsize" style="width:50px;">
								<option value="">None</option>
								<option value="10" <cfif qry_detail.upc_size EQ 10 >selected=selected</cfif>>10</option>
								<option value="11" <cfif qry_detail.upc_size EQ 11 >selected=selected</cfif>>11</option>
								<option value="12" <cfif qry_detail.upc_size EQ 12 >selected=selected</cfif>>12</option>
								<option value="13" <cfif qry_detail.upc_size EQ 13 >selected=selected</cfif>>13</option>
								<option value="14" <cfif qry_detail.upc_size EQ 14 >selected=selected</cfif>>14</option>
							</select>
						</td>
					</tr>
				<cfelse>
					<input type = 'hidden' name="edit_upc_folder_structure" value="false">
					<input type = "hidden" name="editupcsize" id="editupcsize" value="">
				</cfif>
				<!--- Select re-direction folder --->
				<tr>
					<td>
						<strong>#myFusebox.getApplicationData().defaults.trans("grp_detail_folder_redirect_header")#</strong><br/>
						#myFusebox.getApplicationData().defaults.trans("grp_detail_folder_redirect_desc")#<br/>
						<input type="text" name="folder_name" size="25" disabled="true" value="#qry_foldername#" /> 
						<button class="button" onclick="showwindow('#myself#c.groups_choose_folder','#myFusebox.getApplicationData().defaults.trans("choose_location")#',600,2);return false;">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_task_folder_cap")#</button>
						<button onclick="folder_name.value='';folder_redirect.value='';return false;">#myFusebox.getApplicationData().defaults.trans("grp_detail_folder_redirect_btn")#</button>
					</td>
				</tr>
				<tr><td></td></tr>
				<tr>
					<td width="1%" nowrap="true" align="center"><input type="Button" name="Button" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" onclick="javascript:updategrp('#attributes.grp_id#','#attributes.kind#','#attributes.loaddiv#');" /></td>
				</tr>
			</table>
	</form>
	<hr/>
	<table>
		<tr style="height:300px;vertical-align:top">
			<td>
				<!--- Add User --->
				<div>
					<strong>Add Users to Group</strong>
					<br />
					<cfif listfind('1,2', attributes.grp_id) >
						#myFusebox.getApplicationData().defaults.trans("admin_user_assign_warn")#
						<br/>
					</cfif>
					<div style="clear:both;padding-top:5px;"></div>
					<select data-placeholder="Choose a User" class="chzn-select" style="width:350px;" tabindex="2" id="selectuser" onchange="userselected();">
		          		<option value=""></option>
		          		<cfoutput query="qry_users" group="user_id">
		          			<!--- Exclude admins from being selected as admins have all access and can not be part of any groups. Exception is when this is the 'Administrators' group then admin users can be shown --->
		          			<cfif listfind('1,2', attributes.grp_id) OR !listfind('1,2', qry_users.ct_g_u_grp_id)>
		          				<option value="#user_id#">#user_first_name# #user_last_name# (#user_email#)</option>
		          			</cfif>
		          		</cfoutput>
		          	</select>
				</div>
			</td>
			<td style="width:10px"></td>
			<td style="width:400px">
				<!--- List Users --->
				<div id="listusers"></div>
			</td>
		</tr>
	</table>
	</div>
	<!--- Unsubscribe Confirmation div--->
	<div id="dialog-confirm-unsubscribe" style="display:none;">
		<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 100px 0;"></span>#myFusebox.getApplicationData().defaults.trans("group_notifications_unsubscribe")#</p>
	</div>
	<!--- JS --->
	<script type="text/javascript">
		// Activate Chosen
		$(".chzn-select").chosen({search_contains: true});
		// Load existing users
		loadcontent('listusers','#myself#c.groups_list_users&grp_id=#attributes.grp_id#');
		// When user is selected
		function userselected(){
			$("##selectuser").chosen().change( 
				loadcontent('listusers','#myself#c.groups_list_users_add&grp_id=#attributes.grp_id#&user_id=' + $('##selectuser option:selected').val())
			);
		}
		function unsubscribe(){
			$("##fa").val('c.group_unsubscribe');
			$( "##dialog-confirm-unsubscribe" ).dialog({
				resizable: true,
				height:450,
				width:350,
				modal: true,
				title:'Warning!',
				buttons: {
					"Ok": function() {
						// Show loading bar
						$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
						// Get values
						var url = '#myself#c.group_notifications_unsubscribe';
						// Submit Form
						$.ajax({
							type: "POST",
							url: url,
							data : {group_id: '#attributes.grp_id#'},
						   	success: function(){
						   		$("##bodyoverlay").remove();
						   		$("##unsubscribe_success").css('height','20px');
						   		$("##unsubscribe_success").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("group_notifications_unsubscribe_success"))#</cfoutput>');
								$("##unsubscribe_success").animate({opacity: 1.0}, 3000).fadeTo("slow", 0).slideUp("slow",0);
						   	}

						});
						$( this ).dialog( "close" );	
					},
					Cancel: function() {
						$( this ).dialog( "close" );
					}
				}
			});
			return false;
		}


	</script>
</cfoutput>