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
<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
	<cfset isadmin = true>
<cfelse>
	<cfset isadmin = false>
</cfif>
<cfoutput>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<cfif attributes.folderaccess NEQ "R">
			<tr>
				<th width="100%" colspan="6">
					<div style="float:left;height:30px;">
						<cfif attributes.folderaccess NEQ "R">
							<a href="##" onclick="showwindow('#myself#c.saveascollection_form&folder_id=#attributes.folder_id#&coladd=T','#myFusebox.getApplicationData().defaults.trans("collection_create")#',600,1);">#myFusebox.getApplicationData().defaults.trans("collection_create")#</a> | <a href="##" onclick="$('##rightside').load('#myself#c.folder_new&theid=#qry_folder.folder_id#&level=#qry_folder.folder_level#&rid=#qry_folder.rid#&iscol=#qry_folder.folder_is_collection#');return false;">#myFusebox.getApplicationData().defaults.trans("folder_new")#</a>
						</cfif>
					</div>
					<cfinclude template="dsp_folder_navigation.cfm">
				</th>
			</tr>
		</cfif>
		<tr>
			<td nowrap="true" width="50%"><b>#myFusebox.getApplicationData().defaults.trans("header_collection_name")#</b></td>
			<td nowrap="true" width="500%"><b>#myFusebox.getApplicationData().defaults.trans("description")#</b></td>
			<td nowrap="true" align="center" width="1%"><b>#myFusebox.getApplicationData().defaults.trans("date_changed")#</b></td>
			<cfif attributes.folderaccess NEQ "R">
				<td></td>
			</cfif>
		</tr>
		<cfloop query="qry_col_list.collist">
			<tr class="list">
				<td valign="top"><a href="##" onclick="loadcontent('rightside','#myself##xfa.collectiondetail#&col_id=#col_id#&folder_id=#folder_id#');">#col_name#</a></td>
				<td valign="top">
					<cfloop query="qry_col_list.collistdesc">
						<cfif col_id_r EQ qry_col_list.collist.col_id>
							#col_desc#<cfif qry_col_list.collistdesc.recordcount GT 1 AND col_desc NEQ ""><br></cfif>
						</cfif>
					</cfloop>
				</td>
				<td valign="top" align="center">#dateformat(change_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
				<cfif attributes.folderaccess NEQ "R">
					<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
						<td align="center" width="1%" valign="top"><a href="##" onclick="showwindow('#myself#ajax.trash_record&id=#col_id#&what=col_move&loaddiv=content&folder_id=#folder_id#&released=#attributes.released#','#myFusebox.getApplicationData().defaults.trans("trash")#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
					</cfif>
				</cfif>
			</tr>
		</cfloop>
	</table>
</cfoutput>