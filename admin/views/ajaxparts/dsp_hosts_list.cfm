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
<table width="600" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<th><cfoutput>#defaultsObj.trans("hosts")#</cfoutput></th>
		<th></th>
		<th></th>
	</tr>
	<cfloop query="qry_hostslist">
		<tr>
			<td width="100%" nowrap><a href="##" onclick="showwindow('#myself#c.hosts_detail&host_id=#host_id#','#host_name#',500,1);return false;">#qry_hostslist.host_name# (ID: #host_id#)</a></td>
			<td width="1%" nowrap><a href="##" onclick="showwindow('#myself#ajax.hosts_recreate&host_id=#host_id#','#host_name#',500,1);return false;">Upgrade Host Settings</a></td>
			<td width="1%" nowrap><a href="http://#cgi.http_host##dynpath#/raz#host_id#/dam/index.cfm?fusebox.loadclean=true&fusebox.password=#application.fusebox.password#&fusebox.parseall=true&v=#createuuid()#" target="_blank">Reset Host Caching</a></td>
			<cfif qry_hostslist.recordcount NEQ 1 AND session.hostid NEQ host_id>
				<td width="1%" nowrap>
					<a href="##" onclick="showwindow('#myself#ajax.remove_record&what=hosts&id=#host_id#&pathoneup=#urlencodedformat(pathoneup)#&loaddiv=hostslist','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="images/trash.gif" width="16" height="16" border="0"></a>
				</td>
			</cfif>
		</tr>
	</cfloop>
</table>
</cfoutput>
