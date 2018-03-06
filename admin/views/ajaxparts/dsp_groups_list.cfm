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
<table width="600" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<th colspan="2">#myFusebox.getApplicationData().defaults.trans("group_list")#</th>
	</tr>
	<cfloop query="qry_groups">
		<tr>
			<td valign="top" nowrap width="100%"><a href="##" onclick="showwindow('#myself#c.groups_detail&grp_id=#grp_id#&kind=#kind#&loaddiv=#loaddiv#','#Encodeforjavascript(grp_name)#',500,1);return false;">#grp_name#</a></td>
			<td align="center" valign="top" nowrap width="1%">
				<cfif attributes.kind EQ "ecp" OR attributes.kind EQ "adm" AND grp_id NEQ 1 AND grp_id NEQ 2>
					<a href="##" onclick="showwindow('#myself#ajax.remove_record&what=groups&id=#grp_id#&kind=#kind#&loaddiv=#loaddiv#','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="images/trash.gif" width="16" height="16" border="0"></a>
				</cfif>
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>