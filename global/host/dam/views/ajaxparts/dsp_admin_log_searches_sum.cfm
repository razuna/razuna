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
			<td colspan="2">
				<div style="float:left;padding-top:3px;">#myFusebox.getApplicationData().defaults.trans("assets_type")#: <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_sum');">#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_sum&what=img');">#myFusebox.getApplicationData().defaults.trans("search_for_images")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_sum&what=doc');">#myFusebox.getApplicationData().defaults.trans("search_for_documents")#</a> | <a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_sum&what=vid');">#myFusebox.getApplicationData().defaults.trans("search_for_videos")#</a></div>
				<div style="float:right;"><a href="##" onclick="loadcontent('log_show','#myself#c.log_searches_remove');">#myFusebox.getApplicationData().defaults.trans("delete_log")#</a></div>
			</td>
		</tr>
		<tr>
			<th width="100%">#myFusebox.getApplicationData().defaults.trans("searched_for")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("assets_found")#</th>
		</tr>
		<!--- Loop over all scheduled log entries in database table --->
		<cfloop query="qry_log_searches">
			<tr class="list">
				<td>#log_search_for#</td>
				<td nowrap="true" align="center">#found#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>