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
	<div>#defaultsObj.trans("plugins_hosts_tab_desc")#</div>
	<br />
	<table border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th width="1%" nowrap="nowrap" style="padding-right:20px;">Host Name</th>
			<cfloop query="qry_plugins">
				<th width="1%" nowrap="nowrap" style="text-align:center;border-left:1px solid grey;padding-left:15px;">#p_name#</th>
			</cfloop>
			<th width="100%"></th>
		</tr>
		<tr>
			<td></td>
			<cfloop query="qry_plugins">
				<td align="center"><a href="##">Select all</a></td>
			</cfloop>
			<td></td>
		</tr>
		<cfloop query="qry_allhosts">
			<cfset hostid = host_id>
			<tr class="list">
				<td>#host_name#</td>
				<cfloop query="qry_plugins">
					<td align="center"><input type="checkbox" name="pl_host" value="#hostid#-#p_id#" /></td>
				</cfloop>
				<td></td>
			</tr>
		</cfloop>
	</table>
	<div style="clear:both;"></div>
	<div style="padding-top:5px;padding-bottom:10px;">
		<input type="button" name="savebutton" value="#defaultsObj.trans("save")#" class="button" /> 
	</div>
	<div id="plfeedback" style="display:none;float:left;font-weight:bold;color:green;"></div>
</cfoutput>