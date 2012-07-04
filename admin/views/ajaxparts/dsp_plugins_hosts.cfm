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
		<tr>
			<td colspan="2">#defaultsObj.trans("plugins_hosts_tab_desc")#</td>
		</tr>
		<tr>
			<th>Host Name</th>
			<th>All</th>
			<cfloop query="qry_plugins">
				<th>#p_name#</th>
			</cfloop>
		</tr>
		<cfloop query="qry_allhosts">
			<tr>
				<td>#host_name#</td>
				<td><input type="checkbox" name="all" value="true" /></td>
				<cfloop query="qry_plugins">
					<td><input type="checkbox" name="all" value="true" /></td>
				</cfloop>
			</tr>
		</cfloop>
		<cfdump var="#qry_plugins#">
		<cfdump var="#qry_allhosts#">
	</table>
</cfoutput>
