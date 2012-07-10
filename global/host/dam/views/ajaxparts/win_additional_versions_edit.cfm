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
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<th>#myFusebox.getApplicationData().defaults.trans("title")#</th>
		</tr>
		<tr>
			<td><input type="text" style="width:500px;" name="av_link_title" id="ave_link_title" value="#qry_av.av_link_title#" /></td>
		</tr>
		<cfif qry_av.av_link EQ 1>
			<tr>
				<th>URL</th>
			</tr>
			<tr>
				<td><input type="text" style="width:500px;" name="av_link_url" id="ave_link_url" value="#qry_av.av_link_url#" /></td>
			</tr>
		</cfif>
		<tr>
			<td style="padding-top:15px;"><input type="button" value="#myFusebox.getApplicationData().defaults.trans("button_update")#" name="savecomment" class="button" onclick="updateav();"></td>
		</tr>
	</table>
	<script type="text/javascript">
	// Update Comment
	function updateav(){
		// Get values
		var thetitle = escape($("##ave_link_title").val());
		var theurl = escape($("##ave_link_url").val());
		// Load
		loadcontent('thewindowcontent2','#myself#c.av_update&av_id=#attributes.av_id#&av_link=#qry_av.av_link#&av_link_title=' + thetitle + '&av_link_url=' + theurl);
		// Reload versions view
		loadcontent('moreversions','#myself#c.adi_versions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#');
		// Hide Window
		destroywindow(2);
	}
	</script>
</cfoutput>