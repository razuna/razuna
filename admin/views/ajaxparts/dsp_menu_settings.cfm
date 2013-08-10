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
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="##FFFFFF">
		<td>
			<!--- Settings --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_40"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/applications-system-4.png" alt="" width="24" height="24" border="0" align="left" style="padding-left:10px;"></td><td width="212" class="textbold" style="padding-left:5px;"><strong>System</strong></td></tr></table></td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
				<tr>
					<td valign="top" style="padding-top:10px;"><a href="##" onclick="loadcontent('rightside','#myself#c.prefs_global_main');return false;">&raquo; #defaultsObj.trans("settings_global")#</a></td>
				</tr>
				<tr>
					<td valign="top" style="padding-top:10px;"><a href="##" onclick="loadcontent('rightside','#myself#c.plugins');return false;">&raquo; #defaultsObj.trans("link_plugins")#</a></td>
				</tr>
				<cfif application.razuna.whitelabel>
					<tr>
						<td valign="top" style="padding-top:10px;"><a href="##" onclick="loadcontent('rightside','#myself#c.pref_global_wl');return false;">&raquo; #defaultsObj.trans("link_white_labelling")#</a></td>
					</tr>
				</cfif>
			</table>
			<!--- Users --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
				<tr>
					<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_60"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/user-group-properties.png" alt="" width="24" height="24" border="0" align="left" style="padding-left:10px;"></td><td width="212" class="textbold" style="padding-left:5px;"><strong>#defaultsObj.trans("users")#</strong></td></tr></table></td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<!--- User Links --->
			<tr>
				<td valign="top"><a href="##" onclick="loadcontent('rightside','#myself#c.users');return false;">&raquo; #defaultsObj.trans("user_list")#</a></td>
			</tr>
			<!--- Groups --->
			<!--- <tr>
				<td valign="top" style="padding-top:10px;"><a href="##" onclick="loadcontent('rightside','#myself#c.groups');return false;">&raquo; #defaultsObj.trans("groups_link")#</a></td>
			</tr> --->
			</table>
			<!--- Hosts --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
				<tr>
					<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_61"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/go-home-7.png" alt="" width="24" height="24" border="0" align="left" style="padding-left:10px;"></td><td width="212" class="textbold" style="padding-left:5px;"><strong>#defaultsObj.trans("hosts")#</strong></td></tr></table></td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
				<tr>
					<td valign="top"><a href="##" onclick="loadcontent('rightside','#myself#c.hosts');return false;">&raquo; #defaultsObj.trans("host_menue")#</a></td>
				</tr>
				<tr>
					<td valign="top" style="padding-top:10px;"><a href="##" onclick="loadcontent('rightside','#myself#c.prefs');return false;">&raquo; #defaultsObj.trans("settings_host")#</a></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</cfoutput>