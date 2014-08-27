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
<div>
	<strong>Existing Users</strong> <br />
	<div style="clear:both;padding-top:5px;"></div>
	<cfloop query="qry_groupusers">
		<div>
			<div style="float:left;">#user_first_name# #user_last_name# (#user_email#)</div>
			<!--- If this is the admin group and there is only one admin user left then disallow admin from being removed --->
			<cfif !(listfind('1,2', attributes.grp_id) AND qry_groupusers.recordcount EQ 1)>
				<div style="float:right;"><a href="##" onclick="loadcontent('listusers','#myself#c.groups_list_users_remove&grp_id=#attributes.grp_id#&user_id=#user_id#');"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></div>
			</cfif>
		</div>
		<div style="clear:both;padding-top:3px;"></div>
	</cfloop>
</div>
</cfoutput>