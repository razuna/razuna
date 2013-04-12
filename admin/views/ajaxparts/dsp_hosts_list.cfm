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
		<td nowrap="nowrap"><cfif application.razuna.isp><a href="##" onclick="showwindow('#myself#ajax.hosts_recreate&host_id=1','Upgrade Settings',500,1);return false;">Upgrade Settings</a></cfif></td>
		<td nowrap="nowrap"><cfif application.razuna.isp><a href="#session.thehttp##cgi.http_host##dynpath#/raz1/dam/index.cfm?v=#createuuid()#&fusebox.loadclean=true&fusebox.password=#application.fusebox.password#&fusebox.parseall=true" target="_blank">Reset Cache</a></cfif></td>
	</tr>
	<!--- Next and Back --->
	<tr>
		<td align="right" width="100%" nowrap="true" colspan="3">
			<cfif session.offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.offset - 1>
				<a href="##" onclick="loadcontent('hostslist','#myself#c.hosts_list&offset=#newoffset#');">&lt; Back</a> |
			</cfif>
			<cfset showoffset = session.offset * session.rowmaxpage>
			<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
			<cfif qry_hostslist.recordcount GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_hostslist.recordcount GT session.rowmaxpage AND NOT shownextrecord GTE qry_hostslist.recordcount> | 
				<!--- For Next --->
				<cfset newoffset = session.offset + 1>
				<a href="##" onclick="loadcontent('hostslist','#myself#c.hosts_list&offset=#newoffset#');">Next &gt;</a>
			</cfif>
		</td>
	</tr>
	<cfset mysqloffset = session.offset * session.rowmaxpage>
	<cfoutput query="qry_hostslist" startrow="#mysqloffset#" maxrows="#session.rowmaxpage#">
		<tr>
			<td width="100%" nowrap><a href="##" onclick="showwindow('#myself#c.hosts_detail&host_id=#host_id#','#defaultsObj.trans("hosts_edit")# #host_name#',500,1);return false;">#host_name#<cfif application.razuna.isp AND host_name_custom NEQ ""> &ndash; Custom Hostname: #host_name_custom#</cfif> (ID: #host_id#)</a></td>
			<td width="1%" nowrap><cfif !application.razuna.isp><a href="##" onclick="showwindow('#myself#ajax.hosts_recreate&host_id=#host_id#','#host_name#',500,1);return false;">Upgrade Settings</a></cfif></td>
			<td width="1%" nowrap><cfif !application.razuna.isp><a href="#session.thehttp##cgi.http_host##dynpath#/raz#host_id#/dam/index.cfm?fusebox.loadclean=true&fusebox.password=#application.fusebox.password#&fusebox.parseall=true&v=#createuuid()#" target="_blank">Reset Cache</a></cfif></td>
			<cfif qry_hostslist.recordcount NEQ 1 AND session.hostid NEQ host_id>
				<td width="1%" nowrap="nowrap" style="padding-left:50px;">
					<a href="##" onclick="showwindow('#myself#ajax.remove_record&what=hosts&id=#host_id#&pathoneup=#urlencodedformat(pathoneup)#&loaddiv=hostslist','#defaultsObj.trans("remove_selected")#',400,1);return false">Delete</a>
				</td>
			</cfif>
		</tr>
	</cfoutput>
</table>
</cfoutput>
