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
		<th colspan="6"><div align="left" style="float:left;">#defaultsObj.trans("searchresults_header")#</div><div align="right"><a href="##" onclick="loadcontent('rightside','#myself#c.users');return false;">#defaultsObj.trans("clear_search")#</a></div></th>
	</tr>
	<tr>
		<th></th>
		<th>#defaultsObj.trans("username")#</th>
		<th nowrap="true">#defaultsObj.trans("user_first_name")# #defaultsObj.trans("user_last_name")#</th>
		<th>#defaultsObj.trans("user_company")#</th>
		<th>eMail</th>
		<th nowrap="nowrap">#defaultsObj.trans("tenant_access")#</th>
		<th colspan="2"></th>
	</tr>
	<cfset thestruct = structnew()>
	<cfloop query="qry_users">
		<cfset thestruct.user_id = user_id>
		<cfinvoke component="global.cfc.users" method="userhosts"  thestruct="#thestruct#" returnvariable="hosts">
		<cfset host_list = valuelist(hosts.host_name)>
		<tr>
			<td valign="top" nowrap width="1%"><cfif qry_users.recordcount NEQ 1><input type="checkbox" name="theuserid" value="#user_id#" onclick="showhidedelete();" /></cfif></td>
			<td valign="top" nowrap width="25%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_login_name#</a></td>
			<td valign="top" nowrap width="15%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_first_name# #user_last_name#</a></td>
			<td valign="top" nowrap width="15%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_company#</a></td>
			<td valign="top" nowrap width="15%"><a href="##" onclick="showwindow('#myself#c.users_detail&user_id=#user_id#','#user_first_name# #user_last_name#',600,1);return false;">#user_email#</a></td>
			<td valign="top" width="15%">#host_list#</td>
			<td valign="top" nowrap width="1%"><cfif #user_active# EQ "T"><a href=""><img src="images/im-user.png" width="16" height="16" border="0" /></a><cfelse><a href=""><img src="images/im-user-busy.png" width="16" height="16" border="0" /></a></cfif></td>
			<td align="center" valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=users&id=#user_id#&loaddiv=rightside','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="images/trash.gif" width="16" height="16" border="0"></a></td>
		</tr>
	</cfloop>
</table>
</cfoutput>