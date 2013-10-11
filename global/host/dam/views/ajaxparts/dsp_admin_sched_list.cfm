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
		#myFusebox.getApplicationData().defaults.trans("sched_task_intro")#<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="4">
					<div style="float:right;"><a href="##" onclick="showwindow('#myself#c.scheduler_detail&add=T&sched_id=0','#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_new")#',650,1);">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_new")#</a></div>
				</th>
			</tr>
			<tr>
				<td colspan="4">#myFusebox.getApplicationData().defaults.trans("sched_task_intro")#</td>
			</tr>
			<!--- Back and Forth --->
			<cfinclude template="dsp_admin_sched_backnext.cfm">
			<cfif qry_schedules.recordcount NEQ 0>
				<tr>
					<th width="100%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_task_name")#</th>
					<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_method")#</th>
					<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("log")#</th>
					<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_actions")#</th>
				</tr>
			</cfif>
			<!--- Loop over all scheduled events in database table --->
			<cfloop query="qry_sched">
				<tr class="list">
					<td nowrap="true"><a href="##" onclick="showwindow('#myself#c.scheduler_detail&sched_id=#sched_id#','#sched_name#',650,1);">#sched_name#</a></td>
					<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_#sched_method#")#</td>
					<td nowrap="true" align="center"><a href="##" onclick="showwindow('#myself#c.scheduler_log&sched_id=#sched_id#','#myFusebox.getApplicationData().defaults.trans("log")#: #sched_name#',650,1);">#myFusebox.getApplicationData().defaults.trans("log")#</a></td>
					<td nowrap="true">
						<a href="##" onclick="loadcontent('sched_status','#myself#c.scheduler_run&sched_id=#sched_id#');document.getElementById('sched_status').style.visibility = 'visible';"><img src="#dynpath#/global/host/dam/images/run.png" border="0" /></a>
						<!--- <cfif sched_status>
							<a href=""><img src="#dynpath#/global/host/dam/images/pause.png" border="0" /></a>
						<cfelse>
							<a href=""><img src="#dynpath#/global/host/dam/images/resume.png" border="0" /></a>
						</cfif>
						<a href="##" onclick="showwindow('#myself#c.scheduler_detail&sched_id=#sched_id#','#sched_name#',650,1);"><img src="#dynpath#/global/host/dam/images/edit.png" border="0" /></a> --->
						<a href="##" onclick="showwindow('#myself#ajax.remove_record&what=scheduler&id=#sched_id#&loaddiv=admin_schedules','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" border="0" /></a>
					</td>
				</tr>
			</cfloop>
			<!--- Back and Forth --->
			<cfset attributes.bot = "true">
			<cfinclude template="dsp_admin_sched_backnext.cfm">
		</table>
		<div id="sched_status" style="float:left;margin:10px;color:green;visibility:hidden;"></div>
	</cfif>
</cfoutput>