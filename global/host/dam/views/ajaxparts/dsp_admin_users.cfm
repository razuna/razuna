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
	<!--- Set sorting options used for username and email sorting --->
	<cfparam name="sortorder" default="desc">
	<cfif isdefined("qry_users.sorted") AND qry_users.sorted EQ 'yes'>
		<cfif sortorder EQ 'asc'>
			<cfset sortorder = 'desc'>
		<cfelse>
			<cfset sortorder = 'asc'>
		</cfif>
	</cfif>

	<div style="padding-bottom:10px;float:left;">
		<strong>Total: #qry_users.recordcount# users</strong>
	</div>
	<div style="padding-bottom:10px;float:right;">
		<div style="padding-top:4px;"><a href="##" onclick="$('##theusersearch').toggle('slow');" style="text-decoration:underline;padding-right:5px;">Search</a> | <a href="##" onclick="showwindow('#myself#c.users_detail&add=T&user_id=0','#myFusebox.getApplicationData().defaults.trans("user_add")#',600,1);" style="text-decoration:underline;padding-right:5px;padding-left:5px;">#myFusebox.getApplicationData().defaults.trans("user_add")#</a> | <a href="##" onclick="showwindow('#myself#c.users_import','Import',600,1);" style="text-decoration:underline;padding-right:5px;padding-left:5px;">Import</a> | <a href="##" onclick="showwindow('#myself#ajax.users_export','Export',600,1);" style="text-decoration:underline;padding-right:5px;padding-left:5px;">Export</a></div>
	</div>
	<!--- The search --->
	<div id="theusersearch" style="display:none;clear:both;float:right;">
		<form name="usearch" onsubmit="usersearch();return false;">
			<table border="0" cellspacing="0" cellpadding="0" class="grid">
				<tr>
					<td>#myFusebox.getApplicationData().defaults.trans("username")#</td>
					<td>#myFusebox.getApplicationData().defaults.trans("user_company")#</td>
					<td colspan="2">eMail</td>
				</tr>
				<tr>
					<td><input type="text" size="25" name="user_login_name" id="user_login_name2" /></td>
					<td><input type="text" size="25" name="user_company" id="user_company2" /></td>
					<td><input type="text" size="25" name="user_email" id="user_email2" /></td>
					<td><input type="submit" name="Button" value="#myFusebox.getApplicationData().defaults.trans("user_search")#" class="button" /></td>
				</tr>
			</table>
		</form>
	</div>
	<!--- Clear --->
	<div style="clear:both;"></div>
	<div>#myFusebox.getApplicationData().defaults.trans("admin_user_note")#</div>

	<!--- The results --->
	<div id="uresults">
		<form id="form_users_list" name="form_users_list" action="#self#" method="post">
		<input type="hidden" name="fa" id="fa" value="c.users_remove_select">
		<input type="hidden" name="allusers" id="allusers" value="false">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
				<tr>
					<td colspan="7" style="padding-left:0px;margin-left:0px;">
						<!--- Select all link --->
						<div style="float:left;">
							<a href="##" onclick="selectusers();return false;" id="selectalluserslink">#myFusebox.getApplicationData().defaults.trans("select_all")#</a>
							<a href="##" id="selectdelete" style="display:none;padding-left:15px;" onclick="$('##form_users_list').submit();">Delete</a>
							<a href="##" id="selectwelcome" style="display:none;padding-left:15px;" onclick="sendemails();">Send welcome email</a>
						</div>
						<!--- Next and back --->
						<div style="float:right;">
							<cfif session.offset GTE 1>
								<!--- For Back --->
								<cfset newoffset = session.offset - 1>
								<a href="##" onclick="backforthusers(#newoffset#);">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
							</cfif>
							<cfset showoffset = session.offset * session.rowmaxpage>
							<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
							<cfif qry_users.recordcount GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
							<cfif qry_users.recordcount GT session.rowmaxpage AND NOT shownextrecord GTE qry_users.recordcount> | 
								<!--- For Next --->
								<cfset newoffset = session.offset + 1>
								<a href="##" onclick="backforthusers(#newoffset#);">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
							</cfif>
						</div>
					</td>
				</tr>
				<!--- The div to show selection --->
				<div id="showuserselect" style="display:none;"></div>
				<!--- Set sorting vars --->
				<cfif sortorder EQ 'asc'><cfset direction  = 'up'><cfset align  = 'top'><cfelse><cfset direction  = 'down'><cfset align  = 'middle'></cfif> 
				<!--- User list below --->
		 		<tr>
					<th></th>
					<th><a href="##" onclick="loadcontent('admin_users','#myself#c.users&sortby=user_login_name&sortorder=#sortorder#');return false;">#myFusebox.getApplicationData().defaults.trans("username")#</a> <cfif qry_users.sortby EQ 'user_login_name' OR qry_users.sortby EQ ''><img src="#dynpath#/global/host/dam/images/arrow_#direction#.gif" width="10" height="10" border="0" valign="#align#"></cfif></th>
					<th nowrap="true">#myFusebox.getApplicationData().defaults.trans("ad_user")#</th>
					<th nowrap="true">#myFusebox.getApplicationData().defaults.trans("user_first_name")# #myFusebox.getApplicationData().defaults.trans("user_last_name")#</th>
					<th>#myFusebox.getApplicationData().defaults.trans("user_company")#</th>
					<th><a href="##" onclick="loadcontent('admin_users','#myself#c.users&sortby=user_email&sortorder=#sortorder#');return false;">eMail</a> <cfif qry_users.sortby eq 'user_email'><img src="#dynpath#/global/host/dam/images/arrow_#direction#.gif" width="10" height="10" border="0" valign="#align#"></cfif></th>
					<th colspan="2"></th>
				</tr>
				<!--- For paging --->
				<cfset mysqloffset = session.offset * session.rowmaxpage>
				<!--- Output --->
				<cfoutput query="qry_users" group="user_id" startrow="#mysqloffset#" maxrows="#session.rowmaxpage#">
					<tr class="list">
						<td valign="top" nowrap width="1%"><cfif listfind(ct_g_u_grp_id,"2") EQ 0><input type="checkbox" name="theuserid" value="#user_id#" onclick="showhidedelete();" /></cfif></td>
						<!--- RAZ-2718 Encode User's first and last name for title--->
						<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_login_name#</a></td>
						<td valign="top" nowrap width="1%"><cfif #user_pass# EQ ""><img src="#dynpath#/global/host/dam/images/dialog-ok-apply-4.png" width="16" height="16" border="0" style="margin-left:16px;"/></cfif></td>
						<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_first_name# #user_last_name#</a></td>
						<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_company#</a></td>
						<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_email#</a></td>
						<td valign="top" nowrap width="1%"><cfif #user_active# EQ "T"><img src="#dynpath#/global/host/dam/images/im-user.png" width="16" height="16" border="0" /><cfelse><img src="#dynpath#/global/host/dam/images/im-user-busy.png" width="16" height="16" border="0" /></cfif></td>
						<!--- If we are admins we don't enable the trash function --->
						<td align="center" valign="top" nowrap width="1%"><cfif listfind(ct_g_u_grp_id,"2") EQ 0><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=users&id=#user_id#&loaddiv=admin_users','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></cfif></td>
					</tr>
				</cfoutput>
			</table>
		</form>
	</div>
	<!--- Div for hidden window for deleting --->
	<div id="dialog-confirm-delete" style="display:none;">
		<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 100px 0;"></span>#myFusebox.getApplicationData().defaults.trans("user_delete_warning")#</p>
	</div>
	<!--- Div for hidden window for sending email --->
	<div id="dialog-confirm-send" style="display:none;">
		<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 100px 0;"></span>#myFusebox.getApplicationData().defaults.trans("user_send_email_warning")#</p>
	</div>
	<script type="text/javascript">
		$(document).ready(function() {
			// If there are no checkboxes (meaning only admin users) then hide the select all
			if ( $('input[type=checkbox]').length == 0 ){
				$('##selectalluserslink').css('display','none');
			}
		});
		// Select users
		function selectusers(){
			// Select current page
			if ($('##selectalluserslink').text() == 'Select all')
			{
				$('input[type=checkbox]').each( function(){ 
					
						// select all
						$(this).prop('checked','checked');
						// Change link
						$('##selectalluserslink').text('Select none');
				});
			}
			else
			{
				$('input[type=checkbox]').each( function(){ 
					// select none
					$(this).prop('checked',false);
					// Change link
					$('##selectalluserslink').text('Select all');
				});
			}
			// Set the div correct
			$('##showuserselect').html('<strong>All users on this page are selected</strong><br /><a href="##" onclick="selectallusers();return false;">Select all of your #qry_users.recordcount# users</a> (Note: Users in group "Administrator" are never selected!)');
			// Show select all div
			$('##showuserselect').toggle('slow');
			// Hide / show delete
			$('##selectdelete').toggle();
			$('##selectwelcome').toggle();
			// Set selectall input field to false
			$('##allusers').val('false');
		}
		// show / hide delete link
		function showhidedelete(){
			// Var
			var isselected = false;
			// Check if any other checkbox is selected if so this var holds true
			var isselected = $('input[type=checkbox]:checked').length > 0;
			// Show or hide link
			if (isselected){
				$('##selectdelete').css('display','');
				$('##selectwelcome').css('display','');
			}
			else{
				$('##selectdelete').css('display','none');
				$('##selectwelcome').css('display','none');
			}

		}
		// Change the pagelist
		function backforthusers(theoffset){
			// Show loading bar
			// $("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
			// Load
			$('##admin_users').load('#myself#c.users&offset=' + theoffset);
		}
		// Delete the selected records
		$('##form_users_list').submit(function(){

			$( "##dialog-confirm-delete" ).dialog({
				resizable: false,
				height:250,
				modal: true,
				buttons: {
					"I understand. Delete users": function() {
						// Show loading bar
						$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
						// Get values
						var url = formaction("form_users_list");
						var items = formserialize("form_users_list");
						// Submit Form
						$.ajax({
							type: "POST",
							url: url,
						   	data: items,
						   	success: function(){
						   		$("##bodyoverlay").remove();
						   		$('##admin_users').load('#myself#c.users');
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
		});

		function sendemails(){
			$("##fa").val('c.send_useremails');
			$( "##dialog-confirm-send" ).dialog({
				resizable: false,
				height:250,
				modal: true,
				title:'Warning!',
				buttons: {
					"Send Emails": function() {
						// Show loading bar
						$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
						// Get values
						var url = '#myself#c.users';
						var items = formserialize("form_users_list");
						// Submit Form
						$.ajax({
							type: "POST",
							url: url,
						   	data: items,
						   	success: function(){
						   		$("##bodyoverlay").remove();
						   		$('##admin_users').load('#myself#c.users');
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


		// Select all users
		function selectallusers(){
			$('##allusers').val('true');
			$('##showuserselect').html('All #qry_users.recordcount# users have been selected!');
		}
	</script>
	
</cfoutput>