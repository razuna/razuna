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
					<cfif attributes.s EQ "F">
						<strong>#ucase(aud_extension)#</strong> (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)<br />
						<a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sa&f=#aud_id#" target="_blank">
					<cfelse>
						<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#aud_name_org#" target="_blank">
					</cfif>
					View</a> 
					| <a href="#myself#c.serve_file&file_id=#aud_id#&type=aud">Download</a> 
					| <a href="##" onclick="toggleslide('divo#aud_id#','inputo#aud_id#');">Direct Link</a>
					| <a href="##" onclick="showwindow('#myself#c.rend_meta&file_id=#aud_id#&thetype=aud&cf_show=aud','Metadata',550,2);return false;">Metadata</a>
					<cfif attributes.folderaccess NEQ "R">
						 | <a href="##" onclick="loadcontent('relatedaudios','#myself#c.audios_remove_related&id=#aud_id#&file_id=#attributes.file_id#&what=audios&loaddiv=#attributes.loaddiv#&folder_id=#attributes.folder_id#&s=#attributes.s#');">Remove</a>
					</cfif>
					<div id="divo#aud_id#" style="display:none;">
						<input type="text" id="inputo#aud_id#" style="width:100%;" value="http://#cgi.http_host##cgi.script_name#?#theaction#=c.sa&f=#aud_id#&v=o" />
						<!--- Plugin --->
						<cfset args = structNew()>
						<cfset args.detail.aud_id = aud_id>
						<cfset args.detail.path_to_asset = path_to_asset>
						<cfset args.detail.aud_name_org = aud_name>
						<cfset args.thefiletype = "aud">
						<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
						<!--- Show plugin --->
						<cfif structKeyExists(pl,"pview")>
							<cfloop list="#pl.pview#" delimiters="," index="i">
								<br />
								#evaluate(i)#
							</cfloop>
						</cfif>
					</div>
					<br />
					<!--- Nirvanix --->
					<cfif application.razuna.storage EQ "nirvanix" AND attributes.s EQ "T">
						<i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#aud_name#</i>
						<br>
					</cfif>
					<br />
				</cfloop>
			</td>
		</tr>
	</table>
</cfif>
</cfoutput>