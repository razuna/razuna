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
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("adiver_header")#</th>
		</tr>
		<tr>
			<td colspan="2">#myFusebox.getApplicationData().defaults.trans("adiver_header_desc")#</td>
		</tr>
	</table>
<cfif session.hosttype EQ 0>
	<cfinclude template="dsp_host_upgrade.cfm">
<cfelse>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="4">#myFusebox.getApplicationData().defaults.trans("adiver_link_header")#</th>
		</tr>
		<tr>
			<td colspan="4">#myFusebox.getApplicationData().defaults.trans("adiver_link_header_desc")#</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("title")#</td>
			<td colspan="3">URL</td>
		</tr>
		<tr class="list">
			<td width="1%"><input type="text" style="width:300px" name="av_link_title" id="av_link_title"></td>
			<td width="1%"><input type="text" style="width:300px" name="av_link_url" id="av_link_url"></td>
			<td colspan="2" width="100%"><input type="button" value="#myFusebox.getApplicationData().defaults.trans("button_add")#" class="button" onclick="av_add_link()";></td>
		</tr>
		<!--- Show exsiting --->
		<cfloop query="qry_av.links">
			<tr class="list">
				<td valign="top">#av_link_title#</td>
				<td><a href="#av_link_url#" target="_blank">#av_link_url#</a></td>
				<td><a href="##" onclick="showwindow('#myself#c.av_edit&av_id=#av_id#&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#','#myFusebox.getApplicationData().defaults.trans("edit")#',550,2);return false" style="text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("edit")#</a></td>
				<td valign="top"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=av_link&id=#av_id#&loaddiv=moreversions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#&iswin=two','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,2);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
			</tr>
		</cfloop>
	</table>
	
	<hr class="theline" />
	
	<!--- Additional Renditions / Uploaded --->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="4">#myFusebox.getApplicationData().defaults.trans("adiver_asset_header")#</th>
		</tr>
		<tr>
			<td colspan="4">#myFusebox.getApplicationData().defaults.trans("adiver_asset_header_desc")#</td>
		</tr>
		<tr>
			<td colspan="4">
				<table>
					<tr>
						<td>
							<strong>Add by uploading files</strong><br />
							<input type="button" value="#myFusebox.getApplicationData().defaults.trans("adiver_asset_header")#" class="button" onclick="showwindow('#myself#c.asset_add_single&folder_id=#attributes.folder_id#&nopreview=1&av=1','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("adiver_asset_header"))#',650,2);return false;";>
						</td>
						<td style="padding-left:15px;">
							<cfif !application.razuna.isp>
								<strong>... or add from an absolute path on your server (getting files from one folder).</strong><br />
								<input type="text" style="width:300px;" id="folder_path" /> <input type="button" value="#myFusebox.getApplicationData().defaults.trans("import_from_folder_button")#" onclick="importfiles();" class="button" />
							</cfif>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<!--- Show existing --->
		<cfif qry_av.assets.recordcount NEQ 0>
			<tr>
				<cfif qry_av.assets.av_type eq 'img'><th>Thumb</th></cfif>
				<th>#myFusebox.getApplicationData().defaults.trans("title")#</th>
				<th colspan="2">URL</th>
			</tr>
		</cfif>
		<cfloop query="qry_av.assets">
			<tr class="list">
				<cfif av_type eq 'img'>
					<td>
						<cfif application.razuna.storage EQ 'local'>
							<cfset thumb_url = '#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid##qry_av.assets.av_thumb_url#'>
						<cfelse>
							<cfset thumb_url = '#qry_av.assets.av_thumb_url#'>
						</cfif>
						<cfif qry_av.assets.av_thumb_url NEQ ""><a href="#thumb_url#" target="_blank"><img src="#thumb_url#" height="50"></a></cfif>
					</td>
				</cfif>
				<td valign="top" nowrap="nowrap" style="width:400px"><a href="<cfif application.razuna.storage EQ "local">#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid##av_link_url#<cfelse>#av_link_url#</cfif>" target="_blank">#av_link_title#</a> <em>(#myFusebox.getApplicationData().global.converttomb('#thesize#')#MB<cfif av_type EQ "img" OR av_type EQ "vid">, #thewidth#x#theheight# pixel</cfif>)</em></td>
				<td valign="top" nowrap="nowrap" style="width:400px;text-decoration:underline;"><a href="<cfif application.razuna.storage EQ "local">#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid##av_link_url#<cfelse>#av_link_url#</cfif>" target="_blank">Click here to view the asset</a></td>
				<td valign="top"><a href="##" onclick="showwindow('#myself#c.av_edit&av_id=#av_id#&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#','#myFusebox.getApplicationData().defaults.trans("edit")#',550,2);return false" style="text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("edit")#</a></td>
				<td valign="top"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=av_link&id=#av_id#&loaddiv=moreversions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#&iswin=two','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,2);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
			</tr>
		</cfloop>

	</table>
	
	<div id="previewimage_prev"></div>
	<div id="status" style="display:none;"></div>
	<script type="text/javascript">
		function av_add_link(){
			// Get fields
			var t = $('##av_link_title').val();
			var u = $('##av_link_url').val();
			// Save new link
			if (t == "" || u == ""){
				alert('#myFusebox.getApplicationData().defaults.trans("adiver_link_error")#');
				return false;
			}
			else {
				loadcontent('moreversions','#myself#c.adi_versions_add&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#&av_link_title=' + escape(t) + '&av_link_url=' + escape(u));
				<cfif attributes.type EQ "img">
					loadren();
				<cfelseif attributes.type EQ "vid">
					loadrenvid();
				<cfelseif attributes.type EQ "aud">
					loadrenaud();
				</cfif>
			}
		}
		// Submit path
		function importfiles(){
			// Get values
			var thepath = $('##folder_path').val();
			// Open window
			window.open('#myself#c.asset_add_path&theid=#attributes.folder_id#&v=#createuuid("")#&av=true&folder_path=' + escape(thepath) );
		}
	</script>

</cfif>

</cfoutput>