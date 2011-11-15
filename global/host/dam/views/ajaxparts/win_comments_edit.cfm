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
				<div style="width:400px;">
				#defaultsObj.trans("comment")#
				<textarea id="commentup" name="commentup" style="width:400px;height:50px;">#qry_comment.com_text#</textarea>
				#defaultsObj.trans("labels")#
				<input name="tags" id="tags_com_edit" value="#qry_labels#">
				<br />
				(<cfif settingsobj.get_label_set().set2_labels_users EQ "f">You can only choose from available labels. Simply start typing to select from available labels.<cfelse>Simple start typing to choose from available labels or add a new one by entering above and hit ",".</cfif>)</em>
				<br />
				<div style="float:right;"><input type="button" value="#defaultsObj.trans("button_update")#" name="savecomment" class="button" onclick="updatecomment<cfif attributes.fa CONTAINS "share_">share</cfif>('#attributes.file_id#','#attributes.com_id#','#attributes.type#');"></div>
				</div>
			</td>
		</tr>
	</table>
<script>
// Update Comment
function updatecommentshare(fileid,comid,type){
	var thecom = escape($("##commentup").val());
	loadcontent('thewindowcontent1','#myself#c.share_comments_update&file_id=' + fileid + '&com_id=' + comid + '&type=' + type + '&comment=' + thecom );
	// Hide Window
	destroywindow(2);
}
// TAG IT
var raztags = #attributes.thelabels#;
// Global Tagit function
// div, fileid, type, tags
raztagit('tags_com_edit','#attributes.com_id#','comment',raztags,'#settingsobj.get_label_set().set2_labels_users#');
</script>
</cfoutput>