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
<cfif qry_av.assets.recordcount NEQ 0 OR qry_av.links.recordcount NEQ 0>
	<table boder="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<th colspan="2">#defaultsObj.trans("adiver_header")#</th>
		</tr>
		<tr>
			<td width="100%" nowrap="true" valign="top" colspan="2">
				<cfloop query="qry_av.links">
					<a href="#av_link_url#" target="_blank">#av_link_title#</a><br />
				</cfloop>
				<cfloop query="qry_av.assets">
					<a href="<cfif application.razuna.storage EQ "local">http://#cgi.http_host##dynpath#/assets/#session.hostid#<cfelse>#av_link_url#</cfif>" target="_blank">#av_link_title#</a><br />
				</cfloop>
			</td>
		</tr>
	</table>
</cfif>
</cfoutput>