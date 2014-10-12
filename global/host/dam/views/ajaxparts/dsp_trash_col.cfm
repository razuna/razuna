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
		<cfif structKeyExists(attributes,'kind') AND attributes.kind EQ "collection">
			<!--- Open choose folder window automatically --->
			<script type="text/javascript">
				showwindow('#myself#c.restore_trash_collection&col_id=#attributes.col_id#&loaddiv=#attributes.loaddiv#&artofimage=#attributes.artofimage#&artofaudio=#attributes.artofaudio#&artoffile=#attributes.artoffile#&artofvideo=#attributes.artofvideo#&fromtrash=true','#myFusebox.getApplicationData().defaults.trans("add_to_collection")#',600,1);
			</script>
		</cfif>
	</cfif>
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- Show button and next back --->
	<cfif qry_trash.recordcount NEQ 0>
		<div style="float:left;">
			<!--- Select All --->
			<a href="##" onClick="CheckAll('allform_collection','0','storeall','collections');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_select_desc")#">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("select_all")#</div>
			</a>
			<!--- Remove all folders in the trash --->
			<a href="##" onclick="$('##rightside').load('#myself#c.remove_collection_trash_all&trashkind=collections');">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("empty_trash")#</div>
			</a>
			<!--- Restore all folders in the trash --->
			<a href="##" onclick="showwindow('#myself#c.restore_all_collections&type=restoreallcollections&iscol=T&fromtrash=true','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("trash_restoreall"))#',650,1);return false;">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("trash_restoreall")#</div>
			</a>
		</div>
		<div style="float:right;">
			<cfif session.trash_collection_offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.trash_collection_offset - 1>
				<a href="##" onclick="loadcontent('collections','#myself#c.col_get_trash&trashkind=collections&offset=#newoffset#&page=#newoffset+1#');">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
			</cfif>
			<cfset showoffset = session.trash_collection_offset * session.trash_collection_rowmaxpage>
			<cfset shownextrecord = (session.trash_collection_offset + 1) * session.trash_collection_rowmaxpage>
			<cfif qry_trash.recordcount GT session.trash_collection_rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_trash.recordcount GT session.trash_collection_rowmaxpage AND NOT shownextrecord GTE qry_trash.recordcount> | 
				<!--- For Next --->
				<cfset newoffset = session.trash_collection_offset + 1>
				<a href="##" onclick="loadcontent('collections','#myself#c.col_get_trash&trashkind=collections&offset=#newoffset#&page=#newoffset+1#');">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
			</cfif>
			<cfif qry_trash.recordcount GT session.trash_collection_rowmaxpage>
				<span style="padding-left:10px;">
					<cfset thepage = ceiling(qry_trash.recordcount / session.trash_collection_rowmaxpage)>
					Page: 
					<select class="thepagelist_collection"  onChange="loadcontent('collections', $('.thepagelist_collection :selected').val());">
						<cfloop from="1" to="#thepage#" index="i">
							<cfset loopoffset = i - 1>
							<option value="#myself#c.col_get_trash&trashkind=collections&offset=#loopoffset#"<cfif (session.trash_collection_offset + 1) EQ i> selected</cfif>>#i#</option>
						</cfloop>
					</select>
				</span>
			</cfif>
			<span style="padding-left:10px;">
				<cfif qry_trash.recordcount GT session.trash_collection_rowmaxpage OR qry_trash.recordcount GT 25> 
					<select name="selectrowperpage_collection" id="selectrowperpage_collection" onChange="changerow('collections','selectrowperpage_collection')" style="width:80px;">
						<option value="javascript:return false;">Show how many...</option>
						<option value="javascript:return false;">---</option>
						<option value="#myself#c.col_get_trash&trashkind=collections&offset=0&rowmaxpage=25"<cfif session.trash_collection_rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
						<option value="#myself#c.col_get_trash&trashkind=collections&offset=0&rowmaxpage=50"<cfif session.trash_collection_rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
						<option value="#myself#c.col_get_trash&trashkind=collections&offset=0&rowmaxpage=75"<cfif session.trash_collection_rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
						<option value="#myself#c.col_get_trash&trashkind=collections&offset=0&rowmaxpage=100"<cfif session.trash_collection_rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
					</select>
				</cfif>
			</span>
		</div>
	</cfif>
	<div style="clear:both;">
		<!--- If all is selected show the description --->
		<div id="selectstoreallform_collection" style="display:none;width:100%;text-align:center;">
			<strong>All files in this section have been selected</strong> <a href="##" onclick="CheckAllNot('allform_collection');return false;">Deselect all</a>
		</div>
		<!--- show the available folder list for restoring --->
		<form name="allform_collection" id="allform_collection" action="#self#" onsubmit="">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<td colspan="6" style="border:0px;">
						<div id="folderselectionallform_collection" class="actiondropdown">
							<!--- Restore selected  collections--->
							<a href="##" onclick="showwindow('#myself#c.restore_selected_collection&type=restoreselectedcollection&iscol=T&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;">
								<div style="float:left;">
									<img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0" style="padding-right:3px;" />
								</div>
								<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("restore_selected_items")#</div>
							</a>
							<!--- Remove selected collections --->
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&what=selected_collection&iscol=T&kind=collection&loaddiv=collection&selected=true&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">
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
						<cfset mysqloffset = session.trash_collection_offset * session.trash_collection_rowmaxpage + 1>
						<!--- Show trash collections --->
						<cfoutput query="qry_trash" startrow="#mysqloffset#" maxrows="#session.trash_collection_rowmaxpage#">
							<div class="assetbox">
								<div class="theimg">
									<img src="#dynpath#/global/host/dam/images/folder-blue.png" border="0">
								</div>
								<div style="padding-top:5px;">
									<!--- Only if we have at least write permission --->
									<cfif permfolder NEQ "R">
										<div style="float:left;padding-top:2px;">
											<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform_collection');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
										</div>
										<!--- Set vars for kind --->
										<cfset url_restore = "ajax.restore_collection&folder_id=#folder_id#&what=collection&col_id=#col_id#&loaddiv=collections&showsubfolders=F&kind=collection">
										<cfset url_remove = "ajax.remove_record&id=#col_id#&what=col&folder_id=#folder_id#&loaddiv=collections&fromtrash=true">
										<div style="float:right;padding-top:2px;">
											<!--- restore the collection --->
											<a href="##" onclick="showwindow('#myself##url_restore#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#"><img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0"  /></a>
											<!--- remove the collection --->
											<a href="##" onclick="showwindow('#myself##url_remove#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/cross_big_new.png" width="16" height="16" border="0" /></a>
										</div>
									</cfif>
								</div>
								<div style="clear:both;">
									<strong>#filename#</strong>
								</div>
								<!--- Only if we have at least write permission --->
								<!---<cfif permfolder NEQ "R">
									<!--- Set vars for kind --->
									<!--- Folder --->
									<cfif kind EQ "folder">
										<cfset url_restore = "ajax.restore_record&folder_id=#folder_id#&what=folder&loaddiv=collection&id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#&kind=folder&iscol=T">
										<cfset url_remove = "ajax.remove_folder&loaddiv=collection&folder_id=#folder_id#&iscol=T&what=folder">
									<!--- Collection --->
									<cfelseif kind EQ "collection">
										<cfset url_restore = "ajax.restore_collection&folder_id=#folder_id#&what=collection&col_id=#col_id#&loaddiv=collection&showsubfolders=F&kind=collection">
										<cfset url_remove = "ajax.remove_record&id=#col_id#&what=col&folder_id=#folder_id#&loaddiv=collection&fromtrash=true">
									<!--- Files --->
									<cfelse>
										<cfset url_restore = "ajax.restore_collection&id=#id#&what=collection_file&loaddiv=collection&col_id=#col_id#&many=F&kind=#kind#&file_id=#id#">
										<cfset url_remove = "ajax.collections_del_item&id=#file_id#&what=collection_item&loaddiv=collection&col_id=#col_id#&folder_id=#folder_id#&order=#col_item_order#&showsubfolders=#attributes.showsubfolders#">
									</cfif>
									<!--- Restore --->
									<div>
										<a href="##" onclick="showwindow('#myself##url_restore#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
									</div>
									<!--- Remove --->
									<div>
										<a href="##" onclick="showwindow('#myself##url_remove#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
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
            enablesub('allform_collection', true);
        </cfif>
	</script>
</cfoutput>
