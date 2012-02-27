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
	<!--- Labels --->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr class="list">
			<td colspan="2">#defaultsObj.trans("admin_labels_desc")#</td>
		</tr>
		<tr class="list">
			<td colspan="2" style="padding-top:15px;">#defaultsObj.trans("admin_labels_allow")#
			<br /><br />
			<input type="radio" name="labels_public" value="t" onclick="save_setting('t');"<cfif qry_labels_setting.set2_labels_users EQ "t"> checked="true"</cfif>> #defaultsObj.trans("yes")# <input type="radio" name="labels_public" value="f" onclick="save_setting('f');"<cfif qry_labels_setting.set2_labels_users EQ "f"> checked="true"</cfif>> #defaultsObj.trans("no")# <span id="save_status_label" style="padding:10px;color:green;display:none;"></span><div id="save_status_hidden_label" style="display:none;"></div>
			<br />
			</td>
		</tr>
		<tr>
			<th style="padding:18px 0 18px 0;" width="100%">Your Labels</th>
			<th nowrap="nowrap" style="padding:18px 0 18px 0;"><input type="text" name="label_text" id="label_text" style="width:200px;"><input type="button" value="#defaultsObj.trans("labels_add")#" class="button" onclick="addlabel();"></th>
		</tr>
		<cfloop query="qry_labels">
			<tr class="list">
				<td width="100%"><a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=#label_id#','#Jsstringformat(label_text)#',450,1);return false">#label_text#</a></td>
				<td width="1%" nowrap="true" align="right"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=labels&id=#label_id#&loaddiv=admin_labels','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
			</tr>
		</cfloop>
	</table>
<script>
// Update Comment
function addlabel(){
	var thelab = encodeURIComponent($("##label_text").val());
	if (thelab != "") {
		loadcontent('admin_labels','#myself#c.admin_labels_update&label_id=0&label_text=' + thelab);
	}
	else {
		return false;
	}
}
// Sve setting
function save_setting(labelset){
	// Save
	loadcontent('save_status_hidden_label','#myself#c.admin_labels_setting&label_users=' + labelset);
	// Feedback
	$('##save_status_label').fadeTo("slow", 100);
	$('##save_status_label').css('display','');
	$('##save_status_label').html('We saved the change successfully!');
	$('##save_status_label').fadeTo(2000, 0);
}
</script>
</cfoutput>