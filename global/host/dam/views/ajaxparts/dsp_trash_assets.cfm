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
	<!--- Ask to select the directory if parent directory is not available --->
	<!--- show the available folder list for restoring --->
	<cfif isDefined('attributes.trash.is_trash') AND attributes.trash.is_trash EQ "intrash">
		<cfif attributes.type EQ 'movefolder'>
			<!--- Open choose folder window automatically --->
			<script type="text/javascript">
				showwindow('#myself#c.move_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&folder_level=#attributes.folder_level#&fromtrash=true','#myFusebox.getApplicationData().defaults.trans("restore_folder")#', 550, 1);
			</script>
			<!--- <b>#myFusebox.getApplicationData().defaults.trans("restore_directory")#</b><br />
			<a href="##" onclick="showwindow('#myself#c.move_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&folder_level=#attributes.folder_level#','#myFusebox.getApplicationData().defaults.trans("move_file")#', 550, 1);"><b>#myFusebox.getApplicationData().defaults.trans("select_directory")#</b></a> --->
		</cfif>
	<cfelseif structKeyExists(attributes,'is_trash') AND attributes.is_trash EQ "intrash">
		<!--- set session file id --->
		<cfif attributes.thetype EQ 'img'>
			<cfset session.thefileid = ",#attributes.id#-img,">
		<cfelseif attributes.thetype EQ 'aud'>
			<cfset session.thefileid = ",#attributes.id#-aud,">
		<cfelseif attributes.thetype EQ 'vid'>
			<cfset session.thefileid = ",#attributes.id#-vid,">
		<cfelseif attributes.thetype EQ 'doc'>
			<cfset session.thefileid = ",#attributes.id#-file,">	
		</cfif>
		<cfif attributes.type EQ 'restorefile'>
			<!--- Open choose folder window automatically --->
			<script type="text/javascript">
				showwindow('#myself#c.restore_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&fromtrash=true','#myFusebox.getApplicationData().defaults.trans("restore_file")#', 550, 1);
			</script>
			<!--- directory for restore files --->
			<!--- <b>#myFusebox.getApplicationData().defaults.trans("parent_directory_not_available")#</b><br />
			<a href="##" onclick="showwindow('#myself#c.restore_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("move_file")#', 550, 1);"><b>#myFusebox.getApplicationData().defaults.trans("select_directory")#</b></a> --->
		</cfif>
	</cfif>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<td style="border:0px;" id="selectme">
				<!--- Show trash images --->
					<cfloop query="imagetrash">
						<div class="assetbox">
							<div class="theimg">
								<cfif application.razuna.storage EQ 'local'> 
									<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#id#.#ext#">
								<cfelse>
									<img src="#cloud_url#">
								</cfif>	
							</div>
							<div>
								<strong>#filename#</strong>
							</div>
							<!--- Only if we have at least write permission --->
							<cfif permfolder NEQ "R">
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=images&loaddiv=assets&folder_id=#folder_id_r#&kind=#kind#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
								</div>
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=assets&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
								</div>
							</cfif>
						</div>
					</cfloop>
					<!--- Show the audios from trash --->
					<cfloop query="audiotrash">
						<div class="assetbox">
							<div class="theimg">
								<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR audgetrash.ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">	
							</div>
							<div>
								<strong>#filename#</strong>
							</div>
							<!--- Only if we have at least write permission --->
							<cfif permfolder NEQ "R">
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=audios&loaddiv=assets&folder_id=#folder_id_r#&kind=#kind#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
								</div>
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=assets&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
								</div>
							</cfif>
						</div>
					</cfloop>
					<!--- Show the files from trash  --->
					<cfloop query="filetrash">
						<div class="assetbox">
							<div class="theimg">
								<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND ext EQ "PDF">
		                           <cfif cloud_url NEQ "">
		                                   <img src="#cloud_url#" border="0">
		                           <cfelse>
		                                   <img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
		                           </cfif>
		                       	<cfelseif application.razuna.storage EQ "local" AND ext EQ "PDF">
		                           <cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
		                           <cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
		                                   <img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
		                           <cfelse>
		                                   <img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/#thethumb#" width="120" border="0">
		                           </cfif>
		                       	<cfelse>
		                            <cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="120" height="120" border="0"></cfif>
		                       </cfif>
		                     </div>
							 <div>
								<strong>#filename#</strong>
							</div>
							<!--- Only if we have at least write permission --->
							<cfif permfolder NEQ "R">
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=files&loaddiv=assets&folder_id=#folder_id_r#&kind=#kind#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
								</div>
								<div>
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=assets&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
								</div>
							</cfif>
						</div>
					</cfloop>
				<!--- Show the videos from trash --->
				<cfloop query="videotrash">
					<div class="assetbox">
						<div class="theimg">
							 <cfif link_kind NEQ "url">
                           		<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
                                   <cfif cloud_url NEQ "">
                                           <img src="#cloud_url#" border="0">
                                   <cfelse>
                                           <img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
                                   </cfif>
                          		 <cfelse>
                                  	 <img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">
                           		 </cfif>
                   			<cfelse>
                           			<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
                  			 </cfif>
						</div>
						<div>
							<strong>#filename#</strong>
						</div>
						<!--- Only if we have at least write permission --->
						<cfif permfolder NEQ "R">
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=videos&loaddiv=assets&folder_id=#folder_id_r#&kind=#kind#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=assets&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
							</div>
						</cfif>
					</div>
				</cfloop>
				<!--- Show the folder from trash --->
				<cfloop query="foldertrash">
					<div class="assetbox">
						<div class="theimg">
							<img src=" #dynpath#/global/host/dam/images/folder-yellow.png">	
						</div>
						<div>
							<strong>#folder_name#</strong>
						</div>
						<!--- Only if we have at least write permission --->
						<cfif permfolder NEQ "R">
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&folder_id=#folder_id#&what=folder&loaddiv=assets&id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#&kind=folder','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore_folder")#</a><br/><br/>
							</div>
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.remove_folder&folder_id=#folder_id#&what=folder&loaddiv=assets','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove_folder"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove_folder")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
							</div>
						</cfif>
					</div>
				</cfloop>
			</td>
		</tr>
	</table>
</cfoutput>
