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
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- File Types --->
		<tr>
			<th colspan="6" class="textbold">#defaultsObj.trans("pref_types_header")#</th>
		</tr>
		<tr>
			<td colspan="6">#defaultsObj.trans("pref_types_desc")#</td>
		</tr>
		<tr>
			<th>#defaultsObj.trans("extension")#</th>
			<th>#defaultsObj.trans("file_type")#</th>
			<th>Mime Content</th>
			<th colspan="3">Mime Sub-Content</th>
		</tr>
		<cfloop query="prefs">
			<tr>
				<td><input type="text" size="10" id="type_id_#type_id#" value="#type_id#"></td>
				<td><select id="type_type_#type_id#">
					<option value="doc"<cfif type_type EQ "doc"> selected</cfif>>Document</option>
					<option value="img"<cfif type_type EQ "img"> selected</cfif>>Image</option>
					<option value="vid"<cfif type_type EQ "vid"> selected</cfif>>Video</option>
					<option value="aud"<cfif type_type EQ "aud"> selected</cfif>>Audio</option>
				</select></td>
				<td><input type="text" size="25" id="type_mimecontent_#type_id#" value="#type_mimecontent#"></td>
				<td><input type="text" size="30" id="type_mimesubcontent_#type_id#" value="#type_mimesubcontent#"></td>
				<td align="center"><a href="##" onclick="if (confirm('#defaultsObj.trans("delete")#'))  loadcontent('ptypes','#myself#c.prefs_types_del&type_id=' + document.getElementById('type_id_#type_id#').value);return false;"><img src="images/trash.gif" width="16" height="16" border="0"></a></td>
				<td align="center"><a href="##" onclick="loadcontent('ptypes','#myself#c.prefs_types_up&type_id=' + $('##type_id_#type_id#').val() + '&type_type=' + $('##type_type_#type_id#').val() + '&type_mimecontent=' + $('##type_mimecontent_#type_id#').val() + '&type_mimesubcontent=' + $('##type_mimesubcontent_#type_id#').val());return false;"><img src="images/document-save-4.png" width="16" height="16" border="0"></a></td>
			</tr>
		</cfloop>
		<tr>
			<th colspan="6">#defaultsObj.trans("pref_types_header_add")#</th>
		</tr>
		<tr>
			<td><input type="text" size="10" id="new_type_id"></td>
			<td><select id="new_type_type">
				<option value="doc">Document</option>
				<option value="img">Image</option>
				<option value="vid">Video</option>
				<option value="aud">Audio</option>
			</select></td>
			<td><input type="text" size="25" id="new_type_mimecontent"></td>
			<td><input type="text" size="30" id="new_type_mimesubcontent"></td>
			<td colspan="2"><a href="##" onclick="loadcontent('ptypes','#myself#c.prefs_types_add&type_id=' + $('##new_type_id').val() + '&type_type=' + $('##new_type_type').val() + '&type_mimecontent=' + $('##new_type_mimecontent').val() + '&type_mimesubcontent=' + $('##new_type_mimesubcontent').val());return false;"><img src="images/save.gif" width="16" height="16" border="0"></a></td>
		</tr>
	</table>
</cfoutput>