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
	<cfif structKeyExists(attributes,'is_trash') AND attributes.is_trash EQ "intrash">
		<cfif structKeyExists(attributes,'file_id') AND attributes.file_id NEQ 0>
			<!--- collection for restore files--->
			<b>#myFusebox.getApplicationData().defaults.trans("parent_collection_not_available")#</b><br />
			<a href="##" onclick="showwindow('#myself#c.restore_choose_collection&file_id=#attributes.file_id#&col_id=#attributes.col_id#&loaddiv=#attributes.loaddiv#&artofimage=#attributes.artofimage#&artofaudio=#attributes.artofaudio#&artoffile=#attributes.artoffile#&artofvideo=#attributes.artofvideo#','#myFusebox.getApplicationData().defaults.trans("add_to_collection")#',600,2);"><b>#myFusebox.getApplicationData().defaults.trans("select_collection")#</b></a>
		<cfelseif structKeyExists(attributes,'kind') AND attributes.kind EQ "collection">
			<!--- directory for restore collection --->
			<b>#myFusebox.getApplicationData().defaults.trans("parent_directory_not_available")#</b><br />
			<a href="##" onclick="showwindow('#myself#c.restore_trash_collection&col_id=#attributes.col_id#&loaddiv=#attributes.loaddiv#&artofimage=#attributes.artofimage#&artofaudio=#attributes.artofaudio#&artoffile=#attributes.artoffile#&artofvideo=#attributes.artofvideo#','#myFusebox.getApplicationData().defaults.trans("add_to_collection")#',600,2);"><b>#myFusebox.getApplicationData().defaults.trans("select_directory")#</b></a>
		<cfelseif structKeyExists(attributes,'kind') AND attributes.kind EQ "folder">
			<!--- directory for restore folder--->
			<b>#myFusebox.getApplicationData().defaults.trans("parent_directory_not_available")#</b><br />
			<a href="##" onclick="showwindow('#myself#c.move_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&folder_level=#attributes.folder_level#&iscol=T','#myFusebox.getApplicationData().defaults.trans("move_file")#', 550, 1);">#myFusebox.getApplicationData().defaults.trans("select_directory")#</a>
		</cfif>
	</cfif>
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
							<a href="##" onclick="showwindow('#myself#ajax.restore_collection&id=#id#&what=collection_file&loaddiv=collection&col_id=#col_id#&many=F&kind=#kind#&file_id=#id#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
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
								<a href="##" onclick="showwindow('#myself#ajax.restore_collection&id=#id#&what=collection_file&loaddiv=collection&col_id=#col_id#&many=F&kind=#kind#&file_id=#id#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
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
								<a href="##" onclick="showwindow('#myself#ajax.restore_collection&id=#id#&what=collection_file&loaddiv=collection&col_id=#col_id#&many=F&kind=#kind#&file_id=#id#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
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
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_collection&id=#id#&what=collection_file&loaddiv=collection&col_id=#col_id#&many=F&kind=#kind#&file_id=#id#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_order#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
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
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&folder_id=#folder_id#&what=folder&loaddiv=collection&id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#&kind=folder&iscol=T','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore_folder")#</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.remove_folder&loaddiv=collection&folder_id=#folder_id#&iscol=T&what=folder','#Jsstringformat(myFusebox.getApplicationData().defaults.trans('remove_folder'))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans('remove')#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
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
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_collection&folder_id=#folder_id#&what=collection&col_id=#col_id#&loaddiv=collection&showsubfolders=F&kind=collection','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore_collection")#</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#col_id#&what=col&folder_id=#folder_id#&loaddiv=collection','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
							</div>
						</div>
					</cfloop>
				</td>
			</tr>
	</table>
</cfoutput>
