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
		#myFusebox.getApplicationData().defaults.trans("admin_watermark_templates_intro")#<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="4">
					<div style="float:right;"><a href="##" onclick="showwindow('#myself#c.admin_watermark_template_detail&wm_temp_id=0','#myFusebox.getApplicationData().defaults.trans("admin_watermark_templates_new")#',650,1);">#myFusebox.getApplicationData().defaults.trans("admin_watermark_templates_new")#</a></div>
				</th>
			</tr>
			<tr>
				<td colspan="4">#myFusebox.getApplicationData().defaults.trans("admin_watermark_templates_intro")#</td>
			</tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<cfif qry_templates.recordcount NEQ 0>
				<tr>
					<th width="50%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("import_templates")#</th>
					<th width="1%" nowrap="true"></th>
					<th width="1%" nowrap="true"></th>
				</tr>
			</cfif>
			<!--- Loop over all scheduled events in database table --->
			<cfloop query="qry_templates">
				<tr class="list">
					<td nowrap="true" valign="top"><a href="##" onclick="showwindow('#myself#c.admin_watermark_template_detail&wm_temp_id=#wm_temp_id#','#wm_name#',650,1);">#wm_name#</a></td>
					<td nowrap="true" valign="top" align="center"><cfif wm_active EQ 1><img src="#dynpath#/global/host/dam/images/checked.png" width="16" height="16" border="0"></cfif></td>
					<td nowrap="true" valign="top" align="center"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=wm_templates&id=#wm_temp_id#&loaddiv=admin_watermark_templates','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
				</tr>
			</cfloop>
		</table>
		<div id="imptempstatus" style="float:left;margin:10px;color:green;visibility:hidden;"></div>
	</cfif>
</cfoutput>