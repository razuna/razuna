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
				<th>#myFusebox.getApplicationData().defaults.trans("label")#: #qry_labels_text#</th>
			</tr>
			<tr>
				<td style="border:0px;">
					<!--- Show Subfolders --->
					<cfloop query="qry_labels_folders">
						<div class="assetbox" style="text-align:center;">
							<cfif perm NEQ "R">
								<cfif folder_is_collection EQ "T">
									<cfset thef = "c.collections&folder_id=col-#folder_id#">
								<cfelse>
									<cfset thef = "c.folder&folder_id=#folder_id#">
								</cfif>
								<a href="##" onclick="razunatreefocusbranch('#folder_id_r#','#folder_id#');loadcontent('rightside','index.cfm?fa=#thef#');">
									<div class="theimg">
										<cfif directoryexists("#ExpandPath("../..")#global/host/folderthumbnail/#session.hostid#/#folder_id#")>
											<cfdirectory name="myDir" action="list" directory="#ExpandPath("../../")#global/host/folderthumbnail/#session.hostid#/#folder_id#/" type="file">
											<cfif myDir.RecordCount>
												<img src="#dynpath#/global/host/folderthumbnail/#session.hostid#/#folder_id#/#myDir.name#" border="0"><br />
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
											</cfif>
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
										</cfif>
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
