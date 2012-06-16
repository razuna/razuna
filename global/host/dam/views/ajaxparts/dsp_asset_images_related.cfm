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
			<th colspan="2">#defaultsObj.trans("converted_videos")#</th>
		</tr>
		<tr>
			<td width="100%" nowrap="true" valign="top" colspan="2">
				<cfloop query="qry_related">
					<cfif attributes.s EQ "F"><a href="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#img_id#&v=o" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#img_filename#" target="_blank"></cfif>#ucase(img_extension)#<cfif ilength NEQ ""> (#defaultsObj.converttomb("#ilength#")# MB)</cfif> #defaultsObj.trans("size")#: #orgwidth#x#orgheight# pixel</a> <a href="#myself#c.serve_file&file_id=#img_id#&type=img&v=o"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a> 
					<cfif attributes.folderaccess NEQ "R">
						<a href="##" onclick="loadcontent('relatedimages','#myself#c.images_remove_related&id=#img_id#&file_id=#attributes.file_id#&what=images&loaddiv=#attributes.loaddiv#&folder_id=#attributes.folder_id#&s=#attributes.s#');"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
					</cfif>
					<br>
					<!--- Nirvanix --->
					<cfif application.razuna.storage EQ "nirvanix" AND attributes.s EQ "T">
						<i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#img_filename#</i>
						<br>
					</cfif>
				</cfloop>
			</td>
		</tr>
	</table>
</cfif>
</cfoutput>