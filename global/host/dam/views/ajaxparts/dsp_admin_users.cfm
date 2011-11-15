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
	<form name="usearch" onsubmit="usersearch();return false;">
	<div style="padding-bottom:10px;">
		<div style="float:left;"><a href="##" onclick="showwindow('#myself#c.users_detail&add=T&user_id=0','#defaultsObj.trans("user_add")#',600,1);"><img src="#dynpath#/global/host/dam/images/user-new-3.png" width="22" height="22" border="0"></a></div>
		<div style="padding-top:4px;"><a href="##" onclick="showwindow('#myself#c.users_detail&add=T&user_id=0','#defaultsObj.trans("user_add")#',600,1);" style="text-decoration:none;font-weight:bold;padding-left:5px;">#defaultsObj.trans("user_add")#</a></div>
	</div>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<th colspan="4">
			<div style="float:left;">#defaultsObj.trans("quicksearch")#</div>
			<!--- <div style="float:right;"></div> --->
		</th>
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
		<td><input type="submit" name="Button" value="#defaultsObj.trans("user_search")#" class="button" onclick="javascript:usersearch();" /></td>
	</tr>
	</table>
	</form>
	<!--- The results --->
	<div id="uresults">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<td colspan="7">Users in the group "SystemAdministrator" are not being shown in the list below!</td>
			</tr>
			<tr>
				<th></th>
				<th>#defaultsObj.trans("username")#</th>
				<th nowrap="true">#defaultsObj.trans("user_first_name")# #defaultsObj.trans("user_last_name")#</th>
				<th>#defaultsObj.trans("user_company")#</th>
				<th>eMail</th>
				<th colspan="2"></th>
			</tr>
			<cfoutput query="qry_users" group="user_id">
				<tr class="list">
					<td valign="top" nowrap width="1%"><input type="checkbox" name="theuserid" value="#user_id#" /></td>
					<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_login_name#</a></td>
					<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_first_name# #user_last_name#</a></td>
					<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_company#</a></td>
					<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_email#</a></td>
					<td valign="top" nowrap width="1%"><cfif #user_active# EQ "T"><img src="#dynpath#/global/host/dam/images/im-user.png" width="16" height="16" border="0" /><cfelse><img src="#dynpath#/global/host/dam/images/im-user-busy.png" width="16" height="16" border="0" /></cfif></td>
					<!--- If we are admins we don't enable the trash function --->
					<td align="center" valign="top" nowrap width="1%"><cfif ct_g_u_grp_id NEQ 2><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=users&id=#user_id#&loaddiv=admin_users','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></cfif></td>
				</tr>
			</cfoutput>
		</table>
	</div>
</cfoutput>