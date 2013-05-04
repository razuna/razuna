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
	<cfif isDefined('attributes.is_trash') AND attributes.is_trash EQ "intrash">
		<b>The parent directory is not available.Please click "select directory" to restore</b><br />
		<cfif attributes.type EQ 'restorefile'>
			<a href="##" onclick="showwindow('#myself#c.restore_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("move_file")#', 550, 1);"><b>Select Directory</b></a>
		<cfelseif attributes.type EQ 'restorefolder'>
			<a href="##" onclick="showwindow('#myself#c.restore_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&folder_level=#attributes.folder_level#','#myFusebox.getApplicationData().defaults.trans("move_file")#', 550, 1);">move</a>
		</cfif>
	</cfif>
	<!---<input type="button" name="movefolder" value="#myFusebox.getApplicationData().defaults.trans("move_folder")#" class="button" onclick=showwindow('#myself#c.move_file&file_id=24195414D6434F379F6A2D1446A90877&folder_id=D6188097C9E2409993313FC9C1B22F30&thetype=img',600,1);>--->
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- show the available folder list for restoring --->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<td style="border:0px;" id="selectme">
				<!--- Show the images from collection trash --->
				<cfloop query="col_image">
					<div class="assetbox">
						<div class="theimg">
							<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#id#.#ext#">	
						</div>
						<div>
							#filename#
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=images&loaddiv=collection','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
						</div>
					</div>
				</cfloop>
				<!--- Show the audios from collection trash --->
					<cfloop query="col_audio">
						<div class="assetbox">
							<div class="theimg">
								<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">	
							</div>
							<div>
								#filename#
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=audios&loaddiv=assets&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
							</div>
						</div>
				 	</cfloop>
					<!--- Show the files from collection trash  --->
					<cfloop query="col_file">
						<div class="assetbox">
							<div class="theimg">
								<cfif application.razuna.storage EQ "local" AND ext EQ "PDF">
									<cfset var thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
									<cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
										<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
									<cfelse>
										<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/#thethumb#" width="120" border="0">
									</cfif>
								<cfelse>
									<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no">
										<img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="120" height="120" border="0">
									</cfif>
								</cfif>
							</div>
							<div>
								#filename#
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=files&loaddiv=collection&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
							</div>
						</div>
					</cfloop>
					<!--- Show the videos from collection trash --->
					<cfloop query="col_video">
						<div class="assetbox">
							<div class="theimg">
								<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">	
							</div>
							<div>
								#filename#
							</div>
							<!---<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=videos&loaddiv=collection&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
							</div>--->
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
							</div>
						</div>
					</cfloop>
					<!--- Show the folder from collection trash --->
					<cfloop query="col_folder">
						<div class="assetbox">
							<div class="theimg">
								<img src=" #dynpath#/global/host/dam/images/folder-yellow.png">	
							</div>
							<div>
								#folder_name#
							</div>
							<!---<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&folder_id=#folder_id#&what=folder&loaddiv=collection&id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
							</div>--->
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&what=col_folder&loaddiv=collection&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#">Delete Permanently</a>
							</div>
						</div>
					</cfloop>
					<!--- Show the collection trash --->
					<cfloop query="col_trash">
						<div class="assetbox">
							<div class="theimg">
							</div>
							<div>
								#col_name#
							</div>
							<!---<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&folder_id=#foldergettrash.folder_id#&what=collection&loaddiv=assets&id=#foldergettrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
							</div>--->
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#col_id#&what=col_folder&folder_id=#col_folder_id#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#">Delete Permanently</a>
							</div>
						</div>
					</cfloop>
				</td>
			</tr>
	</table>
</cfoutput>
