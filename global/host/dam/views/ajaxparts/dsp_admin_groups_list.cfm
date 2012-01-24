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
<cfif session.hosttype EQ "F">
	<cfinclude template="dsp_host_upgrade.cfm">
<cfelse>
	<form name="grpdamadd" onsubmit="addgrp();return false;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th colspan="2">#defaultsObj.trans("groupnumber_header_new")#</th>
		</tr>
		<tr>
			<td width="100%"><input type="text" size="40" name="grpnew" id="grpnew" /></td>
			<td width="1%" nowrap="true"><input type="Button" name="Button" value="#defaultsObj.trans("button_add")#" class="button" onclick="javascript:addgrp('ecp');" /></td>
		</tr>
	</table>
	</form>
	<!--- Load list of groups here --->
	<div id="grpdamlist">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#defaultsObj.trans("group_list")#</th>
			</tr>
			<cfloop query="qry_groups">
				<tr class="list">
					<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.groups_detail&grp_id=#grp_id#&kind=#kind#&loaddiv=#loaddiv#','#grp_name#',500,1);return false;">#grp_name#</a> (#usercount# members)</td>
					<td align="center" valign="top" nowrap width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=groups&id=#grp_id#&kind=#kind#&loaddiv=#loaddiv#','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
				</tr>
			</cfloop>
		</table>
	</div>
</cfif>
</cfoutput>