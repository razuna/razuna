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
<cfif session.hosttype EQ 0>
	<cfinclude template="dsp_host_upgrade.cfm">
<cfelse>
	<!--- Add new group --->
	<form name="grpdamadd" onsubmit="addgrp();return false;">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("groupnumber_header_new")#</strong></td>
				<td ><strong>#myFusebox.getApplicationData().defaults.trans("group_folder_notify_text")#</strong></td>
				<cfif prefs.set2_upc_enabled>
				<td ><strong>#myFusebox.getApplicationData().defaults.trans("group_upc_size_text")#</strong></td>
				<td ><strong>#myFusebox.getApplicationData().defaults.trans("group_upc_folder_text")#</strong></td>
				</cfif>
				<td >
				</td>
			</tr>
			<tr>
				<td colspan="2" width="20%">
					<input type="text" size="40" name="grpnew" id="grpnew" /> 
				</td>
				<td width="27%" colspan="">
					<input type="radio" name="folder_subscribe" value="true" > #myFusebox.getApplicationData().defaults.trans("yes")# 
					<input type="radio" name="folder_subscribe" value="false" checked="true"> #myFusebox.getApplicationData().defaults.trans("no")#
				</td>
				<!---RAZ-2824 :: UPC folder structure download option enabled--->
				<cfif prefs.set2_upc_enabled>
				<td width="1%" colspan="">	
					<select name="sizeofupc" id="sizeofupc" style="width:90px;">
						<option value="">None</option>
						<option value="10">10</option>
						<option value="11">11</option>
						<option value="12">12</option>
						<option value="13">13</option>
						<option value="14">14</option>
					</select>
				</td>
				<td width="27%" colspan="">
					<input type="radio" name="upc_folder_structure" value="true" > #myFusebox.getApplicationData().defaults.trans("yes")# 
					<input type="radio" name="upc_folder_structure" value="false" checked="true"> #myFusebox.getApplicationData().defaults.trans("no")#
				</td>
				<cfelse>
					<input type = "hidden" name="sizeofupc" id="sizeofupc" value="">
					<input type = "hidden" name="upc_folder_structure" id="upc_folder_structure" value="false">
				</cfif>	
				<td>	
					<input type="Button" name="Button" value="#myFusebox.getApplicationData().defaults.trans("button_add")#" class="button" onclick="javascript:addgrp('ecp');" />
				</td>
			</tr>
		</table>
	</form>
	<!--- Load list of groups here --->
	<div id="grpdamlist">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("group_list")#</th>
			</tr>
			<!--- Administrator Group --->
			<tr class="list">
				<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.groups_detail&grp_id=2&kind=ecp&loaddiv=#loaddiv#','Administrator',700,1);return false;">Administrators</a> (#qry_admin.usercount# members) <em>(ID: 2)</em></td>
				<td align="center" valign="top" nowrap width="1%"></td>
			</tr>
		<!--- Groups of tenant --->
			<cfloop query="qry_groups">
				<tr class="list">
					<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.groups_detail&grp_id=#grp_id#&kind=#kind#&loaddiv=#loaddiv#','#grp_name#',700,1);return false;">#grp_name#</a> (#usercount# members) <em>(ID: #grp_id#)</em></td>
					<td align="center" valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=groups&id=#grp_id#&kind=#kind#&loaddiv=#loaddiv#','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
				</tr>
			</cfloop>
		</table>
	</div>
</cfif>
</cfoutput>