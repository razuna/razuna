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
	<div style="padding-bottom:10px;float:right;">
		<div style="padding-top:4px;"><a href="##" onclick="showwindow('#myself#c.users_detail&add=T&user_id=0','#myFusebox.getApplicationData().defaults.trans("user_add")#',600,1);" style="text-decoration:underline;padding-right:5px;">#myFusebox.getApplicationData().defaults.trans("user_add")#</a> | <a href="##" onclick="showwindow('#myself#ajax.users_import','Import',600,1);" style="text-decoration:underline;padding-right:5px;padding-left:5px;">Import</a> | <a href="##" onclick="showwindow('#myself#ajax.users_export','Export',600,1);" style="text-decoration:underline;padding-right:5px;padding-left:5px;">Export</a></div>
	</div>
	<table border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("quicksearch")#</th>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("username")#</td>
			<td>#myFusebox.getApplicationData().defaults.trans("user_company")#</td>
			<td colspan="2">eMail</td>
		</tr>
		<tr>
			<td><input type="text" size="25" name="user_login_name" id="user_login_name2" /></td>
			<td><input type="text" size="25" name="user_company" id="user_company2" /></td>
			<td><input type="text" size="25" name="user_email" id="user_email2" /></td>
			<td><input type="submit" name="Button" value="#myFusebox.getApplicationData().defaults.trans("user_search")#" class="button" onclick="javascript:usersearch();" /></td>
		</tr>
	</table>
	</form>
	<!--- The results --->
	<div id="uresults">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<td colspan="6" align="right"><a href="##" onclick="loadcontent('admin_users','#myself#c.users');">#myFusebox.getApplicationData().defaults.trans("reload_list")#</a></td>
			</tr>
			<tr>
				<!--- <th></th> --->
				<th>#myFusebox.getApplicationData().defaults.trans("username")#</th>
				<th nowrap="true">#myFusebox.getApplicationData().defaults.trans("user_first_name")# #myFusebox.getApplicationData().defaults.trans("user_last_name")#</th>
				<th>#myFusebox.getApplicationData().defaults.trans("user_company")#</th>
				<th>eMail</th>
				<th colspan="2"></th>
			</tr>
			<cfoutput query="qry_users" group="user_id">
				<tr class="list">
					<!--- <td valign="top" nowrap width="1%"><input type="checkbox" name="theuserid" value="#user_id#" /></td> --->
					<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_login_name#</a></td>
					<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_first_name# #user_last_name#</a></td>
					<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_company#</a></td>
					<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_email#</a></td>
					<td valign="top" nowrap width="1%"><cfif #user_active# EQ "T"><img src="#dynpath#/global/host/dam/images/im-user.png" width="16" height="16" border="0" /><cfelse><img src="#dynpath#/global/host/dam/images/im-user-busy.png" width="16" height="16" border="0" /></cfif></td>
					<!--- If we are admins we don't enable the trash function --->
					<td align="center" valign="top" nowrap width="1%"><cfif ct_g_u_grp_id NEQ 2><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=users&id=#user_id#&loaddiv=admin_users','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></cfif></td>
				</tr>
			</cfoutput>
		</table>
	</div>
</cfoutput>