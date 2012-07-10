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
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<th colspan="7"><div align="left" style="float:left;">#myFusebox.getApplicationData().defaults.trans("searchresults_header")#</div><div align="right"><a href="##" onclick="loadcontent('admin_users','#myself#c.users');return false;">#myFusebox.getApplicationData().defaults.trans("clear_search")#</a></div></th>
	</tr>
	<tr>
		<td></td>
		<td>#myFusebox.getApplicationData().defaults.trans("username")#</td>
		<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("user_first_name")# #myFusebox.getApplicationData().defaults.trans("user_last_name")#</td>
		<td>#myFusebox.getApplicationData().defaults.trans("user_company")#</td>
		<td>eMail</td>
		<td colspan="2"></td>
	</tr>
	<cfloop query="qry_users">
	<tr>
		<td valign="top" nowrap width="1%"><input type="checkbox" name="theuserid" value="#user_id#" /></td>
		<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_login_name#</a></td>
		<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_first_name# #user_last_name#</a></td>
		<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_company#</a></td>
		<td valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_email#</a></td>
		<td valign="top" nowrap width="1%"><cfif #user_active# EQ "T"><img src="#dynpath#/global/host/dam/images/im-user.png" width="16" height="16" border="0" /><cfelse><img src="#dynpath#/global/host/dam/images/im-user-busy.png" width="16" height="16" border="0" /></cfif></td>
		<td align="center" valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=users&id=#user_id#&loaddiv=admin_users','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
	</tr>
	</cfloop>
</table>
</cfoutput>