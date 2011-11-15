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
		<td>#defaultsObj.trans("comment")#<br />
			<textarea id="assetComment" name="assetComment" style="width:400px;height:50px;"></textarea> <br />
			#defaultsObj.trans("labels")#
			<input name="tags" id="tags_com" value="">
			<br />
			<em>(<cfif settingsobj.get_label_set().set2_labels_users EQ "f">You can only choose from available labels. Simply start typing to select from available labels.<cfelse>Simple start typing to choose from available labels or add a new one by entering above and hit ",".</cfif>)</em>
			<br />
			<input type="button" class="button" onclick="addcomment('#attributes.file_id#','#attributes.type#');" value="#defaultsObj.trans("comments_submit")#" />
		</td>
	</tr>
</table>
<div id="comlist"></div>
<div id="status_com"></div>
<!--- Load Comment list --->
<script language="JavaScript" type="text/javascript">
	loadcontent('comlist','#myself##xfa.comlist#&file_id=#attributes.file_id#&type=#attributes.type#');
	// TAG IT
	var raztags = #attributes.thelabels#;
	// Global Tagit function
	// div, fileid, type, tags
	raztagit('tags_com','#session.newcommentid#','comment',raztags,'#settingsobj.get_label_set().set2_labels_users#');
</script>
</cfoutput>