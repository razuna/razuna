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
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<td style="border:0px;" id="selectme">
				<!--- Show the images from trash --->
					<cfloop query="imggetrash">
						<cfloop query="trash_images">
							<cfif imggetrash.id EQ trash_images.name>
								<div class="assetbox">
									<div class="theimg">
										<img src="#dynpath#/assets/#session.hostid#/#imggetrash.path_to_asset#/thumb_#imggetrash.id#.#imggetrash.ext#">	
									</div>
									<div>
										#imggetrash.filename#
									</div>
									<div>
										<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#imggetrash.id#&what=images&loaddiv=content&folder_id=#imggetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
									</div>
									<div>
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#imggetrash.id#&what=images&loaddiv=content&folder_id=#imggetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
									</div>
								</div>
							</cfif> 
						</cfloop>
					</cfloop>
					<!--- Show the audios from trash --->
					<cfloop query="audgetrash">
						<cfloop query="trash_audios">
							<cfif audgetrash.id EQ trash_audios.name>
								<div class="assetbox">
									<div class="theimg">
										<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif audgetrash.ext EQ "mp3" OR audgetrash.ext EQ "wav">#audgetrash.ext#<cfelse>aud</cfif>.png" border="0">	
									</div>
									<div>
										#audgetrash.filename#
									</div>
									<div>
										<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#audgetrash.id#&what=audios&loaddiv=content&folder_id=#audgetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
									</div>
									<div>
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#audgetrash.id#&what=audios&loaddiv=content&audgetrash.folder_id=#audgetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
									</div>
								</div>
							</cfif> 
						</cfloop>
					</cfloop>
					<!--- Show the files from trash  --->
					<cfloop query="filegetrash">
						<cfloop query="trash_files">
							<cfif filegetrash.id EQ trash_files.name>
								<div class="assetbox">
									<div class="theimg">
										<cfif application.razuna.storage EQ "local" AND filegetrash.ext EQ "PDF">
											<cfset var thethumb = replacenocase(filegetrash.filename_org, ".pdf", ".jpg", "all")>
											<cfif FileExists("#attributes.assetpath#/#session.hostid#/#filegetrash.path_to_asset#/#filegetrash.thethumb#") IS "no">
												<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
											<cfelse>
												<img src="#dynpath#/assets/#session.hostid#/#filegetrash.path_to_asset#/#filegetrash.thethumb#" width="120" border="0">
											</cfif>
										<cfelse>
											<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#filegetrash.ext#.png") IS "no">
												<img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/icon_#filegetrash.ext#.png" width="120" height="120" border="0">
											</cfif>
										</cfif>
									</div>
									<div>
										#filegetrash.filename#
									</div>
									<div>
										<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#filegetrash.id#&what=files&loaddiv=content&folder_id=#filegetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
									</div>
									<div>
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#filegetrash.id#&what=files&loaddiv=content&folder_id=#filegetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
									</div>
								</div>
							</cfif>
						</cfloop>
					</cfloop>
					<!--- Show the videos from trash --->
					<cfloop query="videosgetrash">
						<cfloop query="trash_videos">
							<div class="assetbox">
								<div class="theimg">
									<img src="#thestorage##videosgetrash.path_to_asset#/#videosgetrash.filename_org#?#videosgetrash.hashtag#" border="0">	
								</div>
								<div>
									#videosgetrash.filename#
								</div>
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#videosgetrash.id#&what=videos&loaddiv=content&folder_id=#videosgetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
								</div>
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#videosgetrash.id#&what=videos&loaddiv=content&folder_id=#videosgetrash.folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#">Delete Permanently</a>
								</div>
							</div>
						</cfloop>
					</cfloop>
					<!--- Show the folder from trash --->
					<cfloop query="foldergettrash">
						<cfloop query="trash_folder">
							<cfif foldergettrash.folder_id EQ trash_folder.name>
								<div class="assetbox">
									<div class="theimg">
										<img src=" #dynpath#/global/host/dam/images/folder-yellow.png">	
									</div>
									<div>
										<a href="##" onclick="">Restore</a><br/><br/>
									</div>
									<div>
										<a href="##" onclick="">Delete Permanently</a>
									</div>
								</div>
							</cfif>
						</cfloop>
					</cfloop>
				</td>
			</tr>
	</table><cfabort>
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
	<tr>
		<td style="border:0px;" id="selectme">
			<cfloop query="trashfolder">
				<div class="assetbox">
					<div class="theimg">
						<img src=" #dynpath#/global/host/dam/images/folder-yellow.png">	
					</div>
					<div>
						<a href="##" onclick="">Restore</a><br/><br/>
					</div>
					<div>
						<a href="##" onclick="">Delete Permanently</a>
					</div>
				</div>
			</cfloop>
			<cfloop query="Alltrash">
				<cfif kind EQ "img">
					<div class="assetbox">
						<div class="theimg">
							<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#id#.#ext#">	
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
						</div>
					</div>
				<cfelseif kind EQ "aud">
					<div class="assetbox">
						<div class="theimg">
							<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">	
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=audios&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
						</div>
					</div>
				<cfelseif kind EQ "vid">
					<div class="assetbox">
						<div class="theimg">
							<!---<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">--->
							<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">	
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#">Delete Permanently</a>
						</div>
					</div>
				<cfelse>
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
							<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">Restore</a><br/><br/>
						</div>
						<div>
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">Delete Permanently</a>
						</div>
					</div>
				</cfif>
			</cfloop>
		</td>
	</tr>
</table>
</cfoutput>
