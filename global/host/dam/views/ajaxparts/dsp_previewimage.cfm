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
<cfif session.hosttype EQ 0>
	<cfinclude template="dsp_host_upgrade.cfm">
<cfelse>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="2">#defaultsObj.trans("header_preview_image_title")#</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("header_preview_image_desc")#</td>
		</tr>
		<tr>
			<td><iframe src="#myself#ajax.versions_upload&folder_id=#attributes.folder_id#&file_id=#attributes.file_id#&extjs=T&tempid=#attributes.tempid#" frameborder="false" scrolling="false" style="border:0px;width:500px;height:35px;" id="ifupload"></iframe></td>
			<td><a href="##" onclick="loadcontent('previewimage_prev','#myself#c.previewimage_prev&file_id=#attributes.file_id#&type=#attributes.type#&tempid=#attributes.tempid#');">Click here to preview upload</a><br>(if ok click the button below to activate the image)</td>
		</tr>
		<tr>
			<td colspan="2"><input type="button" value="#defaultsObj.trans("header_preview_image_button")#" class="button" onclick="activateme()";></td>
		</tr>
	</table>
	
	<hr class="theline" />
	
	<br />
	
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="2">#defaultsObj.trans("header_preview_image_title_recreate")#</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("header_preview_image_recreate_desc")#</td>
		</tr>
		<tr>
			<td colspan="2"><input type="button" value="#defaultsObj.trans("header_preview_image_recreate_button")#" class="button" onclick="recreatepreview()";></td>
		</tr>
	</table>
	
	<div id="previewimage_prev"></div>
	<div id="status" style="display:none;"></div>
	<script type="text/javascript">
		function activateme(){
			loadcontent('status','#myself#c.previewimage_activate&tempid=#attributes.tempid#&type=#attributes.type#');
			$('##previewimage').html('<div style="color:green;font-weight:bold;">#defaultsObj.trans("header_preview_image_status")#</div>');
		}
		function recreatepreview(){
			loadcontent('status','#myself#c.recreatepreview&file_id=#attributes.file_id#-#attributes.type#&thetype=#attributes.type#');
			$('##previewimage').html('<div style="color:green;font-weight:bold;">#defaultsObj.trans("header_preview_image_recreate_status")#</div>');
		}
	</script>

</cfif>

</cfoutput>