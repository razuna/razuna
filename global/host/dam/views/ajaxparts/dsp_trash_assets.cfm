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
	<!---<cfif isDefined('attributes.trash.is_trash') AND attributes.trash.is_trash EQ "intrash">--->
		<cfif isDefined('attributes.type') AND attributes.type EQ 'movefolder'>
			<!--- Open choose folder window automatically --->
			<script type="text/javascript">
				showwindow('#myself#c.move_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&folder_level=#attributes.folder_level#&fromtrash=true','#myFusebox.getApplicationData().defaults.trans("restore_folder")#', 550, 1);
			</script>
		</cfif>
	<cfif structKeyExists(attributes,'is_trash') AND attributes.is_trash EQ "intrash">
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
		</cfif>
	</cfif>
	<!--- Show button and next back --->
	<cfif qry_trash.recordcount NEQ 0>
		<div style="float:left;">
			<button class="button" onclick="$('##rightside').load('#myself#c.trash_remove_all&col=false');">#myFusebox.getApplicationData().defaults.trans("empty_trash")#</button>
		</div>
		<div style="float:right;">
			<cfif session.offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.offset - 1>
				<a href="##" onclick="backnexttrash(#newoffset#);">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
			</cfif>
			<cfset showoffset = session.offset * session.rowmaxpage>
			<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
			<cfif qry_trash.recordcount GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_trash.recordcount GT session.rowmaxpage AND NOT shownextrecord GTE qry_trash.recordcount> | 
				<!--- For Next --->
				<cfset newoffset = session.offset + 1>
				<a href="##" onclick="backnexttrash(#newoffset#);">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
			</cfif>
		</div>
	</cfif>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<td style="border:0px;" id="selectme">
				<!--- For paging --->
				<cfset mysqloffset = session.offset * session.rowmaxpage>
				<!--- Show trash images --->
				<cfoutput query="qry_trash" startrow="#mysqloffset#" maxrows="#session.rowmaxpage#">
					<div class="assetbox">
						<div class="theimg">
							<!--- Images --->
							<cfif kind EQ "img">
								<cfif application.razuna.storage EQ 'local' OR application.razuna.storage EQ 'akamai'> 
									<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#id#.#ext#">
								<cfelse>
									<img src="#cloud_url#">
								</cfif>
							<!--- Audios --->
							<cfelseif kind EQ "aud">
								<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR audgetrash.ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">
							<!--- Files --->
							<cfelseif kind EQ "doc">
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
		                    <!--- Videos --->
							<cfelseif kind EQ "vid">
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
							<!--- Folder --->
							<cfelseif kind EQ "folder">
								<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0">
							</cfif>
						</div>
						<div>
							<strong>#left(filename,25)#</strong>
						</div>
						<!--- Only if we have at least write permission --->
						<cfif permfolder NEQ "R">
							<div>
								<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=#what#&loaddiv=assets&folder_id=#folder_id_r#&kind=#kind#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
							</div>
							<div>
								<cfif kind EQ "folder">
									<cfset url_id = "ajax.remove_folder&folder_id=#id#">
								<cfelse>
									<cfset url_id = "ajax.remove_record&id=#id#">
								</cfif>
								<a href="##" onclick="showwindow('#myself##url_id#&in_collection=#in_collection#&what=#what#&loaddiv=assets&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
							</div>
						</cfif>
					</div>
				</cfoutput>
			</td>
		</tr>
	</table>
	<!--- JS --->
	<script type="text/javascript">
		// Change the pagelist
		function backnexttrash(theoffset){
			// Load
			$('##rightside').load('#myself#c.folder_explorer_trash&offset=' + theoffset);
		}
	</script>
</cfoutput>
