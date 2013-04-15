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
			<th colspan="4">#myFusebox.getApplicationData().defaults.trans("header_widget")#</th>
		</tr>
		<tr>
			<td colspan="4">#myFusebox.getApplicationData().defaults.trans("widget_desc")#</td>
		</tr>
		<tr class="list">
			<td></td>
		</tr>
		<cfif session.hosttype EQ 0>
			<cfinclude template="dsp_host_upgrade.cfm">
		<cfelse>
			<tr>
				<td colspan="4" align="right"><input type="button" value="#myFusebox.getApplicationData().defaults.trans("widget_new")#" class="button" onclick="showwindow('#myself#c.widget_detail&widget_id=0&col_id=#attributes.col_id#&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("widget_new")#',600,2);return false;" /></td>
			</tr>
			<cfif qry_widgets.recordcount EQ 0>
				<tr>
					<td colspan="3">#myFusebox.getApplicationData().defaults.trans("widgets_not_found")#</td>
				</tr>
			<cfelse>
				<tr>
					<th nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("widget_name")#</th>
					<th width="40%">#myFusebox.getApplicationData().defaults.trans("description")#</th>
					<th width="100%" nowrap="nowrap"></th>
					<th></th>
				</tr>
				<cfloop query="qry_widgets">
					<tr class="list">
						<td valign="top" nowrap="nowrap"><a href="##" onclick="showwindow('#myself#c.widget_detail&widget_id=#widget_id#&col_id=#attributes.col_id#&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("widget_update")#',600,2);return false;">#widget_name#</a></td>
						<td>#widget_description#</td>
						<td valign="top"><a href="#session.thehttp##cgi.http_host##cgi.script_name#?fa=c.w&wid=#widget_id#" target="_blank">Show Widget</a></td>
						<!--- trash --->
						<td width="1%" align="center" nowrap="nowrap" valign="top"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#widget_id#&col_id=#attributes.col_id#&folder_id=#attributes.folder_id#&what=widget&loaddiv=widgets&iswin=two','#myFusebox.getApplicationData().defaults.trans("remove")#',400,2);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
					</tr>
				</cfloop>
			</cfif>
		</cfif>
	</table>	
</cfoutput>
