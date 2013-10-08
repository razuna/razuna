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
		<!--- Back and Forth --->
		<cfinclude template="dsp_admin_log_backnext.cfm">
		<tr>
			<th width="1%" nowrap="true">Detail</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("date")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("time")#</th>
			<th width="1%" nowrap="true">eMail to Razuna</th>
		</tr>
		<!--- Loop over all scheduled log entries in database table --->
		<cfloop query="qry_log">
			<tr class="list">
				<td nowrap="true"><a href="#myself#c.log_errors_detail&id=#id#" target="_blank">View Detail</a></td>
				<td nowrap="true">#dateformat(err_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
				<td nowrap="true">#TimeFormat(err_date, 'HH:mm:ss')#</td>
				<td nowrap="true" align="center"><a href="##" onclick="showwindow('#myself#c.log_errors_win&id=#id#','Send Report',450,1);return false;">Send report to Razuna</a></td>
			</tr>
		</cfloop>
		<!--- Back and Forth --->
		<cfset attributes.bot = "true">
		<cfinclude template="dsp_admin_log_backnext.cfm">
	</table>
</cfoutput>