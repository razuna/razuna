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
			<th colspan="2">#defaultsObj.trans("adiver_header")#</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("adiver_header_desc")#</td>
		</tr>
	</table>
	<hr class="theline" />
<cfif session.hosttype EQ 0>
	<cfinclude template="dsp_host_upgrade.cfm">
<cfelse>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="4">#defaultsObj.trans("adiver_link_header")#</th>
		</tr>
		<tr>
			<td colspan="4">#defaultsObj.trans("adiver_link_header_desc")#</td>
		</tr>
		<tr>
			<th>#defaultsObj.trans("title")#</th>
			<th colspan="3">URL</th>
		</tr>
		<tr class="list">
			<td><input type="text" style="width:300px" name="av_link_title" id="av_link_title"></td>
			<td><input type="text" style="width:300px" name="av_link_url" id="av_link_url"></td>
			<td colspan="2"><input type="button" value="#defaultsObj.trans("button_add")#" class="button" onclick="av_add_link()";></td>
		</tr>
		<!--- Show exsiting --->
		<cfloop query="qry_av.links">
			<tr class="list">
				<td valign="top">#av_link_title#</td>
				<td><a href="#av_link_url#" target="_blank">#av_link_url#</a></td>
				<td><a href="##" onclick="showwindow('#myself#c.av_edit&av_id=#av_id#&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#','#defaultsObj.trans("edit")#',550,2);return false"><img src="#dynpath#/global/host/dam/images/edit.png" width="16" height="16" border="0"></a></td>
				<td valign="top"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=av_link&id=#av_id#&loaddiv=moreversions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#&iswin=two','#defaultsObj.trans("remove_selected")#',400,2);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
			</tr>
		</cfloop>
	</table>
	
	<hr class="theline" />
	
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="4">#defaultsObj.trans("adiver_asset_header")#</th>
		</tr>
		<tr>
			<td colspan="4">#defaultsObj.trans("adiver_asset_header_desc")#</td>
		</tr>
		<tr>
			<td colspan="4" align="right"><input type="button" value="#defaultsObj.trans("adiver_asset_header")#" class="button" onclick="showwindow('#myself#c.asset_add_single&folder_id=#attributes.folder_id#&nopreview=1&av=1','#JSStringFormat(defaultsObj.trans("adiver_asset_header"))#',650,2);return false;";></td>
		</tr>
		<cfif qry_av.assets.recordcount NEQ 0>
			<tr>
				<th>#defaultsObj.trans("title")#</th>
				<th colspan="3">URL</th>
			</tr>
		</cfif>
		<!--- Show exsiting --->
		<cfloop query="qry_av.assets">
			<tr class="list">
				<td valign="top" nowrap="nowrap" style="width:400px"><a href="<cfif application.razuna.storage EQ "local">http://#cgi.http_host##dynpath#/assets/#session.hostid##av_link_url#<cfelse>#av_link_url#</cfif>" target="_blank">#av_link_title#</a></td>
				<td nowrap="nowrap" style="width:400px"><a href="<cfif application.razuna.storage EQ "local">http://#cgi.http_host##dynpath#/assets/#session.hostid##av_link_url#<cfelse>#av_link_url#</cfif>" target="_blank">Click here to view the asset</a></td>
				<td><a href="##" onclick="showwindow('#myself#c.av_edit&av_id=#av_id#&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#','#defaultsObj.trans("edit")#',550,2);return false"><img src="#dynpath#/global/host/dam/images/edit.png" width="16" height="16" border="0"></a></td>
				<td valign="top"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=av_link&id=#av_id#&loaddiv=moreversions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#&iswin=two','#defaultsObj.trans("remove_selected")#',400,2);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
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
				alert('#defaultsObj.trans("adiver_link_error")#');
				return false;
			}
			else {
				loadcontent('moreversions','#myself#c.adi_versions_add&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#&av_link_title=' + escape(t) + '&av_link_url=' + escape(u));
			}
		}
	</script>

</cfif>

</cfoutput>