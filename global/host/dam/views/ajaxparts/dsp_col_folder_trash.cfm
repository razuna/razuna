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
	<!---<cfif isDefined('attributes.trash.is_trash') AND attributes.trash.is_trash EQ "intrash">--->
		<cfif structKeyExists(attributes,'kind') AND attributes.kind EQ "folder">
			<!--- Open choose folder window automatically --->
			<script type="text/javascript">
				showwindow('#myself#c.move_file&type=#attributes.type#&loaddiv=#attributes.loaddiv#&kind=#attributes.kind#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#&folder_level=#attributes.folder_level#&iscol=T&fromtrash=true','#myFusebox.getApplicationData().defaults.trans("move_file")#', 550, 1);
			</script>
		</cfif>
	<!---</cfif>--->
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- Show button and next back --->
	<cfif qry_trash.recordcount NEQ 0>
		<div style="float:left;">
			<!--- Select All --->
			<a href="##" onClick="CheckAll('allform_folders','0','storeall','colfolders');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_select_desc")#">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("select_all")#</div>
			</a>
			<!--- Remove all folders in the trash --->
			<a href="##" onclick="$('##rightside').load('#myself#c.remove_collection_trash_all&trashkind=folders');">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("empty_trash")#</div>
			</a>
			<!--- Restore all folders in the trash --->
			<a href="##" onclick="showwindow('#myself#c.restore_col_folder_all&type=restorecolfolderall&restoreall=true&fromtrash=true&iscol=T&trashkind=folders','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("trash_restoreall"))#',650,1);return false;">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("trash_restoreall")#</div>
			</a>
		</div>
		<div style="float:right;">
			<cfif session.col_trash_folder_offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.col_trash_folder_offset - 1>
				<a href="##" onclick="loadcontent('folders','#myself#c.get_collection_trash_folders&trashkind=folders&offset=#newoffset#&page=#newoffset+1#');">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
			</cfif>
			<cfset showoffset = session.col_trash_folder_offset * session.col_trash_folder_rowmaxpage>
			<cfset shownextrecord = (session.col_trash_folder_offset + 1) * session.col_trash_folder_rowmaxpage>
			<cfif qry_trash.recordcount GT session.col_trash_folder_rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_trash.recordcount GT session.col_trash_folder_rowmaxpage AND NOT shownextrecord GTE qry_trash.recordcount> | 
				<!--- For Next --->
				<cfset newoffset = session.col_trash_folder_offset + 1>
				<a href="##" onclick="loadcontent('folders','#myself#c.get_collection_trash_folders&trashkind=folders&offset=#newoffset#&page=#newoffset+1#');">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
			</cfif>
			<cfif qry_trash.recordcount GT session.col_trash_folder_rowmaxpage>
				<span style="padding-left:10px;">
					<cfset thepage = ceiling(qry_trash.recordcount / session.col_trash_folder_rowmaxpage)>
					Page: 
					<select class="thepagelist_folders"  onChange="loadcontent('folders', $('.thepagelist_folders :selected').val());">
						<cfloop from="1" to="#thepage#" index="i">
							<cfset loopoffset = i - 1>
							<option value="#myself#c.get_collection_trash_folders&trashkind=folders&offset=#loopoffset#"<cfif (session.col_trash_folder_offset + 1) EQ i> selected</cfif>>#i#</option>
						</cfloop>
					</select>
				</span>
			</cfif>
			<span style="padding-left:10px;">
				<cfif qry_trash.recordcount GT session.col_trash_folder_rowmaxpage OR qry_trash.recordcount GT 25> 
					<select name="selectrowperpage_folders" id="selectrowperpage_folders" onChange="changerow('folders','selectrowperpage_folders')" style="width:80px;">
						<option value="javascript:return false;">Show how many...</option>
						<option value="javascript:return false;">---</option>
						<option value="#myself#c.get_collection_trash_folders&trashkind=folders&offset=0&rowmaxpage=25"<cfif session.col_trash_folder_rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
						<option value="#myself#c.get_collection_trash_folders&trashkind=folders&offset=0&rowmaxpage=50"<cfif session.col_trash_folder_rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
						<option value="#myself#c.get_collection_trash_folders&trashkind=folders&offset=0&rowmaxpage=75"<cfif session.col_trash_folder_rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
						<option value="#myself#c.get_collection_trash_folders&trashkind=folders&offset=0&rowmaxpage=100"<cfif session.col_trash_folder_rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
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
			<!--- show the available folder list for restoring --->
			<form name="allform_folders" id="allform_folders" action="#self#" onsubmit="">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<td colspan="6" style="border:0px;">
						<div id="folderselectionallform_folders" class="actiondropdown">
							<!--- Restore selected folders --->
							<a href="##" onclick="showwindow('#myself#c.restore_selected_col_folder&type=restoreselectedcolfolder&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;">
								<div style="float:left;">
									<img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0" style="padding-right:3px;" />
								</div>
								<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("restore_selected_items")#</div>
							</a>
							<!--- Remove selected folders --->
							<a href="##" onclick="showwindow('#myself#ajax.remove_folder&what=selected_col_folder&loaddiv=collection&selected=true&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">
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
						<cfset mysqloffset = session.col_trash_folder_offset * session.col_trash_folder_rowmaxpage + 1>
						<!--- Show trash folders --->
						<cfoutput query="qry_trash" startrow="#mysqloffset#" maxrows="#session.col_trash_folder_rowmaxpage#">
							<div class="assetbox">
								<div class="theimg">
									<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0">
								</div>
								<div style="padding-top:5px;">
									<!--- Only if we have at least write permission --->
									<cfif permfolder NEQ "R">
										<div style="float:left;padding-top:2px;">
											<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform_folders');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
										</div>
										<!--- Set vars for kind --->
										<!--- Folder --->
											<cfset url_remove = "ajax.remove_folder&loaddiv=folders&folder_id=#folder_id#&iscol=T&what=folder">
										<div style="float:right;padding-top:2px;">
											<!--- restore the folder --->
											<a href="##" onclick="showwindow('#myself#c.restore_col_folder&type=restorecolfolder&folder_id=#folder_id#&folder_level=#folder_level#&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#"><img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0"  /></a>
											<!--- remove the folder --->
											<a href="##" onclick="showwindow('#myself##url_remove#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/cross_big_new.png" width="16" height="16" border="0" /></a>
										</div>
									</cfif>
								</div>
								<div style="clear:both;">
									<strong>#filename#</strong>
								</div>
							</div>
						</cfoutput>
					</td>
				</tr>
			</table>
			</form>
		</div>
		<script type="text/javascript">
			<cfif session.file_id NEQ "">
	            enablesub('allform_folders', true);
	        </cfif>
		</script>
</cfoutput>

