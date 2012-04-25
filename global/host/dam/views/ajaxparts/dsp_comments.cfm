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
			<!---
<cfif !application.razuna.custom.enabled OR (application.razuna.custom.enabled AND application.razuna.custom.tab_labels)>
				#defaultsObj.trans("labels")#<br />
				<select data-placeholder="Choose a label" class="chzn-select" style="width:400px;" id="tags_com" onchange="razaddlabels('tags_com','#session.newcommentid#','comment');" multiple="multiple">
					<option value=""></option>
					<cfloop query="attributes.thelabelsqry">
						<option value="#label_id#">#label_path#</option>
					</cfloop>
				</select>
				<cfif settingsobj.get_label_set().set2_labels_users EQ "t" OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
					<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
				</cfif>
			</cfif>
--->
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
	// Activate Chosen
	/* $(".chzn-select").chosen(); */
</script>
</cfoutput>