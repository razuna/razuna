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
	<cfif qry_com_latest.recordcount EQ 1>
		<div style="float:left;">#myFusebox.getApplicationData().defaults.trans("comments_latest")#</div><div style="float:right;">
		<a href="##" onclick="showwindow('#myself#c.share_comments_list&file_id=#attributes.file_id#&type=#attributes.type#','#myFusebox.getApplicationData().defaults.trans("show_comments")#',500,1);return false;"><div id="text#attributes.file_id#" style="text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("show_comments")#</div></a></div>
		<br />
		<cfloop query="qry_com_latest">
			<div style="width:300px;">
				<i>#user_login_name# #myFusebox.getApplicationData().defaults.trans("wrote_on")# #dateformat(com_date,"mmmm dd yyyy")# #timeformat(com_date,"hh:mm:ss")#</i><br />
				#com_text#
			</div>
		</cfloop>
	</cfif>
</cfoutput>