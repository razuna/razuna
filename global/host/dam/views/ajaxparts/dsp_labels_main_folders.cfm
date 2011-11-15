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
	<cfif qry_labels_folders.recordcount NEQ 0>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<th>#defaultsObj.trans("label")#: #qry_labels_text#</th>
			</tr>
			<tr>
				<td style="border:0px;">
					<!--- Show Subfolders --->
					<cfloop query="qry_labels_folders">
						<div class="assetbox" style="text-align:center;">
							<cfif perm EQ "unlocked">
								<a href="##" onclick="$.tree.focused().open_branch('###folder_id_r#');$.tree.focused().select_branch('###folder_id#');loadcontent('rightside','index.cfm?fa=c.folder&folder_id=#folder_id#');">
									<div class="theimg">
										<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
									</div>
									<strong>#folder_name#</strong>
								</a>
							<cfelse>
								<div class="theimg">
									<img src="#dynpath#/global/host/dam/images/folder-locked.png" border="0"><br />
								</div>
								<strong>#folder_name#</strong>
							</cfif>
						</div>
					</cfloop>
				</td>
			</tr>
		</table>
	</cfif>
</cfoutput>
