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
	<cfloop query="qry_comments">
		<tr>
			<td>
				<div style="width:500px;">
					<div style="float:left;"><b>#user_login_name#</b></div>
					<div style="width:400px;float:right;">
						<b>#dateformat(com_date,"mmmm dd yyyy")# #timeformat(com_date,"hh:mm:ss")#</b><br />
						#com_text#<br />
						<cfif attributes.folderaccess NEQ "R">
							<a href="##" onclick="showwindow('#myself#c.comments_edit&com_id=#com_id#&file_id=#attributes.file_id#&type=#attributes.type#&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("edit")#',500,2);return false;">#myFusebox.getApplicationData().defaults.trans("edit")#</a> | <a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#com_id#&what=comments&loaddiv=comlist&file_id=#attributes.file_id#&iswin=two&type=#attributes.type#&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("remove")#',400,2);return false;">#myFusebox.getApplicationData().defaults.trans("remove")#</a>
						</cfif>
					</div>
				</div>
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>