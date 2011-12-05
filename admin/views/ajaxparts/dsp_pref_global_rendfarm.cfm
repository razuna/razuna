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
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- Header --->
		<tr>
			<th class="textbold" colspan="2">#defaultsObj.trans("header_rf")#</th>
		</tr>
		<tr class="list">
			<td colspan="3">#defaultsObj.trans("header_rf_desc")#</td>
		</tr>
		<!--- Enable/Disable --->
		<tr>
			<th class="textbold" colspan="2">#defaultsObj.trans("header_rf_enable")#</th>
		</tr>
		<tr>
			<td colspan="3">#defaultsObj.trans("header_rf_enable_desc")#</td>
		</tr>
		<tr class="list">
			<td><input type="radio" name="conf_rendering_farm" id="conf_rendering_farm" value="true"<cfif gprefs.conf_rendering_farm> checked="checked"</cfif>> #defaultsObj.trans("enable")# <input type="radio" name="conf_rendering_farm" id="conf_rendering_farm" value="false"<cfif !gprefs.conf_rendering_farm> checked="checked"</cfif>> #defaultsObj.trans("disable")#</td>
		</tr>
		<!--- List --->
		<tr>
			<th class="textbold" colspan="2" style="padding-bottom:20px;">
				<div style="float:left;padding-top:10px;">#defaultsObj.trans("header_rf_servers")#</div>
				<div style="float:right;"><input type="button" class="button" value="Add Server" onclick="showwindow('#myself#c.prefs_renf_detail&rfs_id=0&rfs_add=true','#defaultsObj.trans("header_rf_server")#',550,1);" /></div>
			</th>
		</tr>
		<!--- List of servers --->
		<cfloop query="qry_rfs">
			<tr class="list">
				<td width="100%"><a href="##" onclick="showwindow('#myself#c.prefs_renf_detail&rfs_id=#rfs_id#&rfs_add=false','#defaultsObj.trans("header_rf_server")#',550,1);">#rfs_server_name#</a></td>
				<td nowrap="nowrap"><a href="##" onclick="showwindow('#myself#c.prefs_renf_detail&rfs_id=#rfs_id#&rfs_add=false','#defaultsObj.trans("header_rf_server")#',550,1);"><cfif rfs_active><img src="images/online_16.png" width="16" height="16" border="0"/><cfelse><img src="images/offline_16.png" width="16" height="16" border="0"/></cfif></a></td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
