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
				showwindow('#myself#c.folder_restore&type=restorefolder&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&folder_level=#attributes.folder_level#&fromtrash=true','#myFusebox.getApplicationData().defaults.trans("restore_folder")#', 550, 1);
			</script>
		</cfif>
	<!--- Show button and next back --->
	<cfif qry_trash.recordcount NEQ 0>
			<div style="float:left;">
				<!--- Select All --->
				<a href="##" onClick="CheckAll('allform_folders','0','storeall','trashfolder');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_select_desc")#">
					<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("select_all")#</div>
				</a>
				<!--- Remove all folders in the trash --->
				<a href="##" onclick="$('##rightside').load('#myself#c.trash_remove_folder&col=false');">
					<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("empty_trash")#</div>
				</a>
				<!--- Restore all folders in the trash --->
				<a href="##" onclick="showwindow('#myself#c.trash_restore_folders&type=restorefolderall&fromtrash=true&restoreall=true&loaddiv=folders','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("trash_restoreall"))#',650,1);return false;">
					<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("trash_restoreall")#</div>
				</a>
			</div>
			
			<div style="float:right;">
				<cfif session.trash_folder_offset GTE 1>
					<!--- For Back --->
					<cfset newoffset = session.trash_folder_offset - 1>
					<a href="##" onclick="loadcontent('folders','#myself#c.trash_folder_all&trashkind=folders&offset=#newoffset#&page=#newoffset+1#');">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
				</cfif>
				<cfset showoffset = session.trash_folder_offset * session.trash_folder_rowmaxpage>
				<cfset shownextrecord = (session.trash_folder_offset + 1) * session.trash_folder_rowmaxpage>
				<cfif qry_trash.recordcount GT session.trash_folder_rowmaxpage>#showoffset# - #shownextrecord#</cfif>
				<cfif qry_trash.recordcount GT session.trash_folder_rowmaxpage AND NOT shownextrecord GTE qry_trash.recordcount> | 
					<!--- For Next --->
					<cfset newoffset = session.trash_folder_offset + 1>
					<a href="##" onclick="loadcontent('folders','#myself#c.trash_folder_all&trashkind=folders&offset=#newoffset#&page=#newoffset+1#');">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
				</cfif>
				<cfif qry_trash.recordcount GT session.trash_folder_rowmaxpage>
					<span style="padding-left:10px;">
						<cfset thepage = ceiling(qry_trash.recordcount / session.trash_folder_rowmaxpage)>
						Page: 
						<select class="thepagelist_folders"  onChange="loadcontent('folders', $('.thepagelist_folders :selected').val());">
							<cfloop from="1" to="#thepage#" index="i">
								<cfset loopoffset = i - 1>
								<option value="#myself#c.trash_folder_all&trashkind=folders&offset=#loopoffset#"<cfif (session.trash_folder_offset + 1) EQ i> selected</cfif>>#i#</option>
							</cfloop>
						</select>
					</span>
				</cfif>
				<span style="padding-left:10px;">
					<cfif qry_trash.recordcount GT session.trash_folder_rowmaxpage OR qry_trash.recordcount GT 25> 
						<select name="selectrowperpage_folders" id="selectrowperpage_folders" onChange="changerow('folders','selectrowperpage_folders')" style="width:80px;">
							<option value="javascript:return false;">Show how many...</option>
							<option value="javascript:return false;">---</option>
							<option value="#myself#c.trash_folder_all&trashkind=folders&offset=0&rowmaxpage=25"<cfif session.trash_folder_rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
							<option value="#myself#c.trash_folder_all&trashkind=folders&offset=0&rowmaxpage=50"<cfif session.trash_folder_rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
							<option value="#myself#c.trash_folder_all&trashkind=folders&offset=0&rowmaxpage=75"<cfif session.trash_folder_rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
							<option value="#myself#c.trash_folder_all&trashkind=folders&offset=0&rowmaxpage=100"<cfif session.trash_folder_rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
						</select>
					</cfif>
				</span>
			</div>
		</cfif>
		<div style="clear:both;">
			<!--- If all is selected show the description --->
			<div id="selectstoreallform_folders" style="display:none;width:100%;text-align:center;">
				<strong>All files in this section have been selected</strong> <a href="##" onclick="CheckAllNot('allform_folders');return false;">Deselect all</a>
			</div>
			<form name="allform_folders" id="allform_folders" action="#self#" onsubmit="">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<td colspan="6" style="border:0px;">
						<div id="folderselectionallform_folders" class="actiondropdown">
							<!--- Restore selected folders --->
							<a href="##" onclick="showwindow('#myself#c.restore_selected_folders&type=restoreselectedfolders','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;">
								<div style="float:left;">
									<img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0" style="padding-right:3px;" />
								</div>
								<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("restore_selected_items")#</div>
							</a>
							<!--- Remove selected folders --->
							<a href="##" onclick="showwindow('#myself#ajax.remove_folder&what=trashfolders&loaddiv=folders&selected=true&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">
								<div style="float:left;">
									<img src="#dynpath#/global/host/dam/images/cross_big_new.png" width="16" height="16" border="0" style="padding-right:3px;" />
								</div>
								<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("trash_Delete_Permanently")#</div>
							</a>
						</div>
					</td>
				</tr>
				<tr>
					<td style="border:0px;" id="selectme">
						<!--- For paging --->
						<cfset mysqloffset = session.trash_folder_offset * session.trash_folder_rowmaxpage + 1>
						<!--- Show trash folders --->
						<cfoutput query="qry_trash" startrow="#mysqloffset#" maxrows="#session.trash_folder_rowmaxpage#">
							<div class="assetbox">
								<div class="theimg">
									<!--- Folder --->
									<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0">
								</div>
								<div style="padding-top:5px;">
									<!--- Only if we have at least write permission --->
									<cfif permfolder NEQ "R">
										<div style="float:left;padding-top:2px;">
											<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform_folders');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
										</div>
										<div style="float:right;padding-top:2px;">
											<!--- restore the folder --->
											<a href="##" onclick="showwindow('#myself#c.folder_restore&type=restorefolder&id=#id#&what=#what#&loaddiv=folders&folder_id=#id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&folder_level=#folder_level#','#myFusebox.getApplicationData().defaults.trans("restore_folder")#', 550, 1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#"><img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0"  /></a>
											<!--- remove the folder --->
											<cfset url_id = "ajax.remove_folder&folder_id=#id#">
											<a href="##" onclick="showwindow('#myself##url_id#&what=#what#&loaddiv=folders&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/cross_big_new.png" width="16" height="16" border="0" /></a>
										</div>
									</cfif>
								</div>
								<div style="clear:both;">
									<strong>#left(filename,25)#</strong>
								</div>
								<!--- Only if we have at least write permission --->
								<!---<cfif permfolder NEQ "R">
									<div>
										<a href="##" onclick="showwindow('#myself#c.folder_restore&type=restorefolder&id=#id#&what=#what#&loaddiv=folders&folder_id=#id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&folder_level=#folder_level#&fromtrash=true','#myFusebox.getApplicationData().defaults.trans("restore_folder")#', 550, 1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
										<!---<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=#what#&loaddiv=folders&folder_id=#id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&folder_level=#folder_level#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>--->
									</div>
									<div>
										<cfset url_id = "ajax.remove_folder&folder_id=#id#">
										<a href="##" onclick="showwindow('#myself##url_id#&in_collection=#in_collection#&what=#what#&loaddiv=folders&showsubfolders=#attributes.showsubfolders#&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
									</div>
								</cfif>--->
							</div>
						</cfoutput>
					</td>
				</tr>
			</table>
			</form>
	</div>
	<!--- JS --->
	<script type="text/javascript">
		<cfif session.file_id NEQ "">
			enablesub('allform_folders', true);
		</cfif>
		// Change the pagelist
		function backnexttrash(theoffset){
			// Load
			$('##rightside').load('#myself#c.folder_explorer_trash&offset=' + theoffset);
		}
	</script>
</cfoutput>
