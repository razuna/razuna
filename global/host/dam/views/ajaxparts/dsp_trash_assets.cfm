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
	<cfset uniqueid = createuuid()>
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
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
			<!--- Select All --->
			<a href="##" onClick="CheckAll('allform_assets','0','storeall','trashfiles');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_select_desc")#">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("select_all")#</div>
			</a>
			<!--- Remove all files in the trash --->
			<a href="##" onclick="$('##rightside').load('#myself#c.trash_remove_all&col=false');">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("empty_trash")#</div>
			</a>
			<!--- Restore all files in the trash --->
			<a href="##" onclick="showwindow('#myself#c.trash_restore_all&type=restorefileall&restoreall=true&loaddiv=assets','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("trash_restoreall"))#',650,1);return false;">
				<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("trash_restoreall")#</div>
			</a>
		</div>
		<div style="float:right;">
			<cfif session.trash_offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.trash_offset - 1>
				<!---<cfset session.trash_offsetCount =  newoffset >--->
				<a href="##" onclick="loadcontent('assets', '#myself#c.trash_assets&offset=#newoffset#');">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
			</cfif>
			<cfset showoffset = session.trash_offset * session.trash_rowmaxpage>
			<cfset shownextrecord = (session.trash_offset + 1) * session.trash_rowmaxpage>
			<cfif qry_trash.recordcount GT session.trash_rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_trash.recordcount GT session.trash_rowmaxpage AND NOT shownextrecord GTE qry_trash.recordcount> | 
				<!--- For Next --->
				<cfset newoffset = session.trash_offset + 1>
				<!---<cfset session.trash_offsetCount =  newoffset >--->
				<a href="##" onclick="loadcontent('assets', '#myself#c.trash_assets&offset=#newoffset#');">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
			</cfif>
			<cfif qry_trash.recordcount GT session.trash_rowmaxpage>
				<span style="padding-left:10px;">
					<cfset thepage = ceiling(qry_trash.recordcount / session.trash_rowmaxpage)>
					Page: 
					<select class="thepagelist_assets"  onChange="loadcontent('assets', $('.thepagelist_assets :selected').val());">
						<cfloop from="1" to="#thepage#" index="i">
							<cfset loopoffset = i - 1>
							<option value="#myself#c.trash_assets&offset=#newoffset#"<cfif (session.trash_offset + 1) EQ i> selected</cfif>>#i#</option>
						</cfloop>
					</select>
				</span>
			</cfif>
			<span style="padding-left:10px;">
				<cfif qry_trash.recordcount GT session.trash_rowmaxpage OR qry_trash.recordcount GT 25> 
					<select name="selectrowperpage_assets" id="selectrowperpage_assets" onChange="changerow('assets','selectrowperpage_assets')" style="width:80px;">
						<option value="javascript:return false;">Show how many...</option>
						<option value="javascript:return false;">---</option>
						<option value="#myself#c.trash_assets&offset=0&rowmaxpage=25"<cfif session.trash_rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
						<option value="#myself#c.trash_assets&offset=0&rowmaxpage=50"<cfif session.trash_rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
						<option value="#myself#c.trash_assets&offset=0&rowmaxpage=75"<cfif session.trash_rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
						<option value="#myself#c.trash_assets&offset=0&rowmaxpage=100"<cfif session.trash_rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
					</select>
				</cfif>
			</span>
		</div>
	</cfif>
	<div style="clear:both;">
		<!--- If all is selected show the description --->
		<div id="selectstoreallform_assets" style="display:none;width:100%;text-align:center;">
			<strong>All files in this section have been selected</strong> <a href="##" onclick="CheckAllNot('allform_assets');return false;">Deselect all</a>
		</div>
		<!---<div id="folderselection" class="actiondropdown">
			<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("batch")#</div>
		</div>--->
		<form name="allform_assets" id="allform_assets" action="#self#" onsubmit="">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<td colspan="6" style="border:0px;">
						<div id="folderselectionallform_assets" class="actiondropdown">
							<!--- Restore selected files in the trash ---> 
							<a href="##" onclick="showwindow('#myself#c.restore_selected_files&type=restoreselectedfiles','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;">
								<div style="float:left;">
									<img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0" style="padding-right:3px;" />
								</div>
								<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("restore_selected_items")#</div>
							</a>
							<!--- Remove selected files in the trash --->
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&loaddiv=assets&what=trashfiles&selected=true&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">
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
						<cfset mysqloffset = session.trash_offset * session.trash_rowmaxpage + 1>
						<!--- Show trash images --->
						<cfoutput query="qry_trash" startrow="#mysqloffset#" maxrows="#session.trash_rowmaxpage#">
							<div class="assetbox">
								<div class="theimg">
									<!--- Images --->
									<cfif kind EQ "img">
										<cfif application.razuna.storage EQ 'local' OR application.razuna.storage EQ 'akamai'> 
											<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/thumb_#id#.#ext#?#uniqueid#">
										<cfelse>
											<img src="#cloud_url#">
										</cfif>
									<!--- Audios --->
									<cfelseif kind EQ "aud">
										<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ 'mp3' OR ext EQ 'wav'>#ext#<cfelse>aud</cfif>.png" border="0">
									<!--- Files --->
									<cfelseif kind EQ "doc">
										<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
										<cfif application.razuna.storage EQ "amazon" AND cloud_url NEQ "">
											<img src="#cloud_url#" border="0" img-tt="img-tt">
										<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
											<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#?#uniqueid#" border="0" img-tt="img-tt">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
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
										  	 <img src="#thestorage##path_to_asset#/#filename_org#?#uniqueid#" border="0">
											 </cfif>
										<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
										 </cfif>
									</cfif>
								</div>
								<div style="padding-top:5px;">
									<!--- Only if we have at least write permission --->
									<cfif permfolder NEQ "R">
										<div style="float:left;padding-top:2px;">
											<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform_assets');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
										</div>
										<div style="float:right;padding-top:2px;">
											<!--- restore the file --->
											<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=#what#&loaddiv=assets&folder_id=#folder_id_r#&kind=#kind#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#"><img src="#dynpath#/global/host/dam/images/icon_restore.png" width="16" height="16" border="0"  /></a>
											<!--- remove the file --->
											<cfset url_id = "ajax.remove_record&id=#id#&folder_id=#folder_id_r#">
											<a href="##" onclick="showwindow('#myself##url_id#&in_collection=#in_collection#&what=#what#&loaddiv=assets&showsubfolders=#attributes.showsubfolders#&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/cross_big_new.png" width="16" height="16" border="0" /></a>
										</div>
									</cfif>
								</div>
								<div style="clear:both;">
									<strong>#left(filename,25)#</strong>
								</div>
								<!--- Only if we have at least write permission --->
								<!---<cfif permfolder NEQ "R">
									<div>
										<a href="##" onclick="showwindow('#myself#ajax.restore_record&id=#id#&what=#what#&loaddiv=assets&folder_id=#folder_id_r#&kind=#kind#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("restore"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("restore")#">#myFusebox.getApplicationData().defaults.trans("restore")#</a><br/><br/>
									</div>
									<div>
										<cfset url_id = "ajax.remove_record&id=#id#&folder_id=#folder_id_r#">
										<a href="##" onclick="showwindow('#myself##url_id#&in_collection=#in_collection#&what=#what#&loaddiv=assets&showsubfolders=#attributes.showsubfolders#&fromtrash=true','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#">#myFusebox.getApplicationData().defaults.trans("delete_permanently")#</a>
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
            enablesub('allform_assets', true);
        </cfif>
	</script>
</cfoutput>
