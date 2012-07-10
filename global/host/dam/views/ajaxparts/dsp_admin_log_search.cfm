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
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("date")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("time")#</th>
			<th width="100%">#myFusebox.getApplicationData().defaults.trans("searched_for")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("assets_found")#</th>
			<cfif attributes.logtype EQ "log_assets">
				<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("assets_type")#</th>
			</cfif>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("theuser")#</th>
		</tr>
		<!--- Loop over all found log records --->
		<cfloop query="qry_log">
			<tr class="list">
				<td nowrap="true" valign="top">#dateformat(log_timestamp, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
				<td nowrap="true" valign="top">#timeFormat(log_timestamp, 'HH:mm:ss')#</td>
				<td valign="top">#log_desc#</td>
				<td nowrap="true" align="center" valign="top">#log_action#</td>
				<cfif attributes.logtype EQ "log_assets">
					<td nowrap="true" align="center" valign="top">#log_file_type#</td>
				</cfif>
				<td nowrap="true" align="center" valign="top">#user_first_name# #user_last_name#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>