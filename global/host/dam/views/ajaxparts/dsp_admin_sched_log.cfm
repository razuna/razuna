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
			<td colspan="4" align="right"><input type="button" name="button" value="#myFusebox.getApplicationData().defaults.trans("delete_log")#" onclick="loadcontent('thewindowcontent1','#myself#c.scheduler_log_remove&sched_id=#attributes.sched_id#');" class="button"></td>
		</tr>
		<tr>
			<th width="150">#myFusebox.getApplicationData().defaults.trans("date")#</th>
			<th width="150">#myFusebox.getApplicationData().defaults.trans("time")#</th>
			<th width="100%">#myFusebox.getApplicationData().defaults.trans("description")#</th>
			<th width="300">#myFusebox.getApplicationData().defaults.trans("action")#</th>
		</tr>
		<!--- Loop over all scheduled log entries in database table --->
		<cfloop query="qry_sched_log">
			<tr>
				<td nowrap="true">#dateformat(sched_log_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
				<td nowrap="true">#LSTimeFormat(sched_log_time, 'HH:mm:ss')#</td>
				<td>#sched_log_desc# <cfif user_login_name NEQ "">(User #user_login_name#)</cfif></td>
				<td nowrap="true">#sched_log_action#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>