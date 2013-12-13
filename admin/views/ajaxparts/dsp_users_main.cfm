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
		<!--- The results --->
			<div id="uresults">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
					<tr>
						<th nowrap="nowrap">#defaultsObj.trans("username")#</th>
						<th nowrap="nowrap">#defaultsObj.trans("user_first_name")# #defaultsObj.trans("user_last_name")#</th>
						<th nowrap="nowrap">#defaultsObj.trans("user_company")#</th>
						<th nowrap="nowrap">eMail</th>
						<th colspan="2"></th>
					</tr>
					<cfoutput query="qry_users" group="user_id">
						<tr>
							<!--- <td valign="top" nowrap width="1%"><input type="checkbox" name="theuserid" value="#user_id#" /></td> --->
							<!--- RAZ-2718 Encode User's first and last name for title --->
							<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;"<cfif listfind(ct_g_u_grp_id,"1")> style="font-weight:bold;color:green;"</cfif>>#user_login_name#</a></td>
							<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_first_name# #user_last_name#</a></td>
							<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_company#</a></td>
							<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#urlEncodedFormat(qry_users.user_first_name&' '&qry_users.user_last_name)#',600,1);return false;">#user_email#</a></td>
							<td valign="top" nowrap width="1%"><cfif #user_active# EQ "T"><img src="images/im-user.png" width="16" height="16" border="0" /><cfelse><img src="images/im-user-busy.png" width="16" height="16" border="0" /></cfif></td>
							<cfif qry_users.recordcount NEQ 1>
								<td align="center" valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=users&id=#user_id#&loaddiv=rightside','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="images/trash.gif" width="16" height="16" border="0"></a></td>
							</cfif>
						</tr>
					</cfoutput>
					<tr>
						<td colspan="6" style="padding-top:20px;"><em>(Users in green are in the SystemAdministrator group)</em></td>
					</tr>
				</table>
			</div>
		</div>
		<div id="tadd"></div>
	</div>
</cfoutput>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_users");
	// Search
	function searchme() {
		if ($('#user_login_name2').val() == "" && $('#user_company2').val() == "" && $('#user_email2').val() == ""){
			alert('<cfoutput>#defaultsObj.trans("one_field_fill")#</cfoutput>');
			return false;
		}
		else {
		// Update the content
		loadcontent('uresults', '<cfoutput>#myself#</cfoutput>c.users_search&user_login_name=' + escape($('#user_login_name2').val()) + '&user_company=' + escape($('#user_company2').val()) + '&user_email=' + escape($('#user_email2').val()));
		return false;
		}
	};
</script>
