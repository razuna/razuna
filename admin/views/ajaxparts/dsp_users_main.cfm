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
	<!--- Host form --->
	<cfinclude template="dsp_host_chooser_include.cfm">
	<div id="tabs_users">
		<ul>
			<li><a href="##tsearch">#defaultsObj.trans("user_list")#</a></li>
			<li><a href="##tsearch" onclick="showwindow('#myself#c.users_detail&add=T&user_id=0','#defaultsObj.trans("user_add")#',550,1);">#defaultsObj.trans("user_add")#</a></li>
		</ul>
		<!--- Search Panel --->
		<div id="tsearch">
			<form name="usearch" id="usearch" onsubmit="searchme();return false;">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="4">#defaultsObj.trans("quicksearch")#</th>
			</tr>
			<tr>
				<td>#defaultsObj.trans("username")#</td>
				<td>#defaultsObj.trans("user_company")#</td>
				<td colspan="2">eMail</td>
			</tr>
			<tr>
				<td><input type="text" size="25" name="user_login_name" id="user_login_name2" /></td>
				<td><input type="text" size="25" name="user_company" id="user_company2" /></td>
				<td><input type="text" size="25" name="user_email" id="user_email2" /></td>
				<td><input type="submit" name="Button" value="#defaultsObj.trans("user_search")#" class="button" /></td>
			</tr>
			</table>
			</form>

			<form id="form_users_list" name="form_users_list" action="#self#" method="post">
			<input type="hidden" name="fa" id="fa" value="c.users_remove_select">
			<input type="hidden" name="allusers" id="allusers" value="false">
			<!--- Select all link --->
			<div style="float:left;">
				<a href="##" onclick="selectusers();return false;" id="selectalluserslink">Select all</a>
				<a href="##" id="selectdelete" style="display:none;padding-left:15px;" onclick="$('##form_users_list').submit();">Delete</a>
				<a href="##" id="selectwelcome" style="display:none;padding-left:15px;" onclick="sendemails();">Send welcome email</a>
			</div>
		<!--- The results --->
			<div id="uresults">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
					<tr>
						<th></th>
						<th nowrap="nowrap">#defaultsObj.trans("username")#</th>
						<th nowrap="nowrap">#defaultsObj.trans("user_first_name")# #defaultsObj.trans("user_last_name")#</th>
						<th nowrap="nowrap">#defaultsObj.trans("user_company")#</th>
						<th nowrap="nowrap">eMail</th>
						<th nowrap="nowrap">#defaultsObj.trans("tenant_access")#</th>
						<th colspan="2"></th>
					</tr>
					<cfset thestruct = structnew()>
					<cfoutput query="qry_users" group="user_id">
						<cfset thestruct.user_id = user_id>
						<cfinvoke component="global.cfc.users" method="userhosts"  thestruct="#thestruct#" returnvariable="hosts">
						<cfset host_list = valuelist(hosts.host_name)>
						<tr>
							<td valign="top" nowrap width="1%"><cfif qry_users.recordcount NEQ 1><input type="checkbox" name="theuserid" value="#user_id#" onclick="showhidedelete();" /></cfif></td>
							<td valign="top" nowrap><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;"<cfif listfind(ct_g_u_grp_id,"1")> style="font-weight:bold;color:green;"</cfif>>#user_login_name#</a></td>
							<td valign="top" nowrap width="25%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_first_name# #user_last_name#</a></td>
							<td valign="top" nowrap width="15%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_company#</a></td>
							<td valign="top" nowrap width="15%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_email#</a></td>
							<td valign="top" width="15%">#host_list#</td>
							<td valign="top" nowrap width="1%"><cfif #user_active# EQ "T"><img src="images/im-user.png" width="16" height="16" border="0" /><cfelse><img src="images/im-user-busy.png" width="16" height="16" border="0" /></cfif></td>
							<cfif qry_users.recordcount NEQ 1>
								<td align="center" valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=users&id=#user_id#&loaddiv=rightside','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="images/trash.gif" width="16" height="16" border="0"></a></td>
							</cfif>
						</tr>
					</cfoutput>
					<tr>
						<td colspan="8" style="padding-top:20px;"><em>(Users in green are in the SystemAdministrator group)</em></td>
					</tr>
				</table>
			</div>
			</form>
		</div>
		<div id="tadd"></div>
	</div>

<!--- Div for hidden window for deleting --->
<div id="dialog-confirm-delete" style="display:none;">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 100px 0;"></span>#defaultsObj.trans("user_delete_warning")#
	</p>
</div>
<!--- Div for hidden window for sending email --->
<div id="dialog-confirm-send" style="display:none;">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 100px 0;"></span>#defaultsObj.trans("user_send_email_warning")#</p>
</div>
<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_users");
	// Search
	function searchme() {
		if ($('##user_login_name2').val() == "" && $('##user_company2').val() == "" && $('##user_email2').val() == ""){
			alert('<cfoutput>#defaultsObj.trans("one_field_fill")#</cfoutput>');
			return false;
		}
		else {
		// Update the content
		loadcontent('uresults', '<cfoutput>#myself#</cfoutput>c.users_search&user_login_name=' + escape($('##user_login_name2').val()) + '&user_company=' + escape($('##user_company2').val()) + '&user_email=' + escape($('##user_email2').val()));
		return false;
		}
	};

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
		// Show select all div
		$('##showuserselect').toggle('slow');
		$('##selectdelete').toggle();
		$('##selectwelcome').toggle();
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
					   		$('##rightside').load('#myself#c.users');
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
					   		$('##rightside').load('#myself#c.users');
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