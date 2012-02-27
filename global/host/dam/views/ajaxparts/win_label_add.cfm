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
			<td>
				<input type="hidden" name="label_id" value="#attributes.label_id#">
				<input type="text" name="label_text_edit" id="label_text_edit" style="width:400px;" value="#qry_label.label_text#">
				<br /><br />
				<input type="button" value="#defaultsObj.trans("button_update")#" name="savecomment" class="button" onclick="updatelabel();">
			</td>
		</tr>
	</table>
<script>
// Update Comment
function updatelabel(){
	var thelab = encodeURIComponent($("##label_text_edit").val());
	if (thelab != "") {
		loadcontent('admin_labels','#myself#c.admin_labels_update&label_id=#attributes.label_id#&label_text=' + thelab);
		// Hide Window
		destroywindow(1);
	}
	else {
		return false;
	}
}
</script>
</cfoutput>