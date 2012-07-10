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
<cfif qry_related.recordcount NEQ 0>
	<table boder="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("converted_videos")#</th>
		</tr>
		<tr>
			<td width="100%" nowrap="true" valign="top" colspan="2">
				<cfloop query="qry_related">
					<cfif attributes.s EQ "F"><a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sa&f=#aud_id#" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#aud_name#" target="_blank"></cfif>#ucase(aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)</a> <a href="#myself#c.serve_file&file_id=#aud_id#&type=aud"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a> 
					<a href="##" onclick="toggleslide('divo#aud_id#','inputo#aud_id#');"><img src="#dynpath#/global/host/dam/images/emblem-symbolic-link.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
					<cfif attributes.folderaccess NEQ "R">
						<a href="##" onclick="loadcontent('relatedaudios','#myself#c.audios_remove_related&id=#aud_id#&file_id=#attributes.file_id#&what=audios&loaddiv=#attributes.loaddiv#&folder_id=#attributes.folder_id#&s=#attributes.s#');"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
					</cfif>
					<div id="divo#aud_id#" style="display:none;">Link: <input type="text" id="inputo#aud_id#" style="width:270px;" value="http://#cgi.http_host##cgi.script_name#?#theaction#=c.sa&f=#aud_id#&v=o" /></div>
					<br>
					<!--- Nirvanix --->
					<cfif application.razuna.storage EQ "nirvanix" AND attributes.s EQ "T">
						<i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#aud_name#</i>
						<br>
					</cfif>
				</cfloop>
			</td>
		</tr>
	</table>
</cfif>
</cfoutput>