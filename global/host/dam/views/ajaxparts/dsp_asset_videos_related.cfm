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
	<br />
	<table boder="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td width="100%" nowrap="true" valign="top" colspan="2">
				<cfloop query="qry_related">
					<cfif attributes.s EQ "F">
						<strong>#ucase(vid_extension)#</strong> (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB, #vid_width#x#vid_height# pixel)<br />
						<a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#vid_id#&v=o" target="_blank">
					<cfelse>
						<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#vid_filename#" target="_blank">
					</cfif>
					View</a>
					 | <a href="#myself#c.serve_file&file_id=#vid_id#&type=vid">Download</a>
					 | <a href="##" onclick="toggleslide('divo#vid_id#','inputo#vid_id#');">Direct Link</a>
					<cfif attributes.folderaccess NEQ "R">
						 | <a href="##" onclick="remren('#vid_id#');">Remove</a>
					</cfif>
					<div id="divo#vid_id#" style="display:none;"><input type="text" id="inputo#vid_id#" style="width:400px;" value="http://#cgi.http_host##cgi.script_name#?#theaction#=c.sv&f=#vid_id#&v=o" /></div>
					<br>
					<!--- Nirvanix --->
					<cfif application.razuna.storage EQ "nirvanix" AND attributes.s EQ "T">
						<i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#path_to_asset#/#vid_filename#</i>
						<br>
					</cfif>
				</cfloop>
			</td>
		</tr>
	</table>
</cfif>
<div id="dialog-confirm-rendition" title="Really remove this rendition?" style="display:none;">
	<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>The rendition will be permanently deleted and cannot be recovered. Are you sure?</p>
</div>
<!--- Js --->
<script type="text/javascript">
function remren(id){
	$( "##dialog-confirm-rendition" ).dialog({
		resizable: false,
		height:140,
		modal: true,
		buttons: {
			"Yes, remove rendition": function() {
				$( this ).dialog( "close" );
				$('##relatedvideos').load('#myself#c.videos_remove_related&file_id=#attributes.file_id#&what=videos&loaddiv=#attributes.loaddiv#&folder_id=#attributes.folder_id#&s=#attributes.s#&id=' + id);
			},
			Cancel: function() {
				$( this ).dialog( "close" );
			}
		}
	});
};
</script>
</cfoutput>