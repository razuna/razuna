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
	<cfparam name="attributes.bot" default="false" />
	<cfif kind EQ "img">
		<cfset thefa = "c.folder_images">
		<cfset thediv = "img">
	<cfelseif kind EQ "vid">
		<cfset thefa = "c.folder_videos">
		<cfset thediv = "vid">
	<cfelseif kind EQ "aud">
		<cfset thefa = "c.folder_audios">
		<cfset thediv = "aud">
	<cfelseif kind EQ "all">
		<cfset thefa = "c.folder_content">
		<cfset thediv = "content">
	<cfelseif kind EQ "doc">
		<cfset thefa = "c.folder_files">
		<cfset thediv = "doc">
	<cfelseif kind EQ "pdf">
		<cfset thefa = "c.folder_files">
		<cfset thediv = "pdf">
	<cfelseif kind EQ "xls">
		<cfset thefa = "c.folder_files">
		<cfset thediv = "xls">
	<cfelse>
		<cfset thefa = "c.folder_files">
		<cfset thediv = "other">
	</cfif>
<table border="0" width="100%" cellspacing="0" cellpadding="0" class="gridno">
	<tr>
		<!--- Icons and drop down menu --->
		<td align="left" width="1%" nowrap="true">
			<div>
				<!--- Icons --->
				<div id="tooltip" style="float:left;width:490px;">
					<!--- Upload --->
					<cfif attributes.folderaccess NEQ "R"> 
						<cfif !(qry_user.folder_owner EQ session.theuserid AND trim(qry_foldername) EQ "my folder") OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
							<a href="##" onclick="showwindow('#myself##xfa.assetadd#&folder_id=#folder_id#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("add_file")#">
								<div style="float:left;padding-right:15px;"><button class="awesome medium green">#myFusebox.getApplicationData().defaults.trans("add_your_files")#</button></div>
							</a>
						<cfelseif cs.myfolder_upload>
							<a href="##" onclick="showwindow('#myself##xfa.assetadd#&folder_id=#folder_id#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("add_file")#">
								<div style="float:left;padding-right:15px;"><button class="awesome medium green">#myFusebox.getApplicationData().defaults.trans("add_your_files")#</button></div>
							</a>
						</cfif>
					</cfif>
					<cfif !attributes.bot AND !session.customview>
						<!--- Select --->
						<cfif cs.icon_select>
							<a href="##" onClick="CheckAll('#kind#form','#attributes.folder_id#','store#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>','#kind#');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_select_desc")#">
								<!--- <div style="float:left;padding-top:5px;">
									<img src="#dynpath#/global/host/dam/images/checkbox.png" width="16" height="16" name="edit_1" border="0" />
								</div> --->
								<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("select_all")#</div>
							</a>
						</cfif>
						<!--- Search --->
						<cfif cs.icon_search>
							<a href="##" onclick="showwindow('#myself#c.search_advanced&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("folder_search")#',500,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("folder_search")#">
								<!--- <div style="float:left;padding-top:5px;">
									<img src="#dynpath#/global/host/dam/images/system-search-3.png" width="16" height="16" border="0" />
								</div> --->
								<div style="float:left;padding-right:15px;padding-top:5px;text-decoration:underline;">#myFusebox.getApplicationData().defaults.trans("folder_search")#</div>
							</a>
						</cfif>
						<!--- More actions --->
						<div style="float:left;padding-top:5px;"><a href="##" onclick="$('##drop#thediv#').toggle();" style="text-decoration:none;" class="ddicon">More actions</a></div>
						<div style="float:left;padding-right:15px;padding-top:5px;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" class="ddicon" onclick="$('##drop#thediv#').toggle();"></div>
						<!--- Views --->
						<div style="float:left;padding-top:5px;"><a href="##" onclick="$('##dropviews#thediv#').toggle();" style="text-decoration:none;" class="ddicon">Views</a></div>
						<div style="float:left;;padding-top:5px;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" class="ddicon" onclick="$('##dropviews#thediv#').toggle();"></div>
					</cfif>
				</div>
				<!--- More actions menu --->	
				<div>
					<div id="drop#thediv#" class="ddselection_header" style="width:200px;z-index:100;position:absolute;top:100px;left:<cfif attributes.folderaccess NEQ "R">358<cfelse>251</cfif>px;">
						<!--- Add Subfolder --->
						<cfif attributes.folderaccess NEQ "R" AND cs.icon_create_subfolder>
							<p>
								<a href="##" onclick="$('##rightside').load('#myself#c.folder_new&from=list&theid=#url.folder_id#&iscol=F');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_folder_desc")#">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/folder-new-7.png" width="16" height="16" border="0" />
									</div>
									<div style="padding-top:2px;">#myFusebox.getApplicationData().defaults.trans("folder_new")#</div>
								</a>
							</p>
						</cfif>
						<!--- Favorite Folder --->
						<cfif cs.icon_favorite_folder>
							<p>
								<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#url.folder_id#&favtype=folder&favkind=');flash_footer();$('##drop#thediv#').toggle();return false;">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/folder-favorites.png" width="16" height="16" border="0" />
									</div>
									<div style="padding-top:2px;">Add folder to favorites</div>
								</a>
							</p>
						</cfif>
						<!--- Show sub assets --->
						<cfif cs.icon_show_subfolder>
							<p>
								<a href="##" onclick="loadcontent('#thediv#','#myself##thefa#&folder_id=#url.folder_id#&kind=#url.kind#&showsubfolders=<cfif session.showsubfolders EQ "F">T<cfelse>F</cfif>&iscol=#attributes.iscol#');$('##drop#thediv#').toggle();return false;">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/link.png" width="16" height="16" border="0" />
									</div>
									<div style="padding-top:2px;">Show assets from Sub-Folders</div>
								</a>
							</p>
							<p><hr></p>
						</cfif>
						<!--- Exporting icons --->
						<cfif cs.icon_print>
							<p>
								<a href="##" target="_blank" onclick="showwindow('#myself#ajax.topdf_window&folder_id=#url.folder_id#&kind=#url.kind#','#myFusebox.getApplicationData().defaults.trans("pdf_window_title")#',500,1);$('##drop#thediv#').toggle();return false;">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/preferences-desktop-printer-2.png" border="0" width="16" height="16" />
									</div>
									<div style="padding-top:2px;">Print</div>
								</a>
							</p>
						</cfif>
						<cfif cs.icon_rss>
							<p>
								<a href="#myself#c.view_rss&folder_id=#url.folder_id#&kind=#url.kind#&col=F" target="_blank" onclick="$('##drop#thediv#').toggle();">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/application-rss+xml.png" border="0" width="16" height="16" />
									</div>
									<div style="padding-top:2px;">RSS-Feed of this folder</div>
								</a>
							</p>
						</cfif>
						<cfif cs.icon_word>
							<p>
								<a href="#myself#c.view_doc&folder_id=#url.folder_id#&kind=#url.kind#&col=F" target="_blank" onclick="$('##drop#thediv#').toggle();">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/page-word.png" border="0" width="16" height="16" />
									</div>
									<div style="padding-top:2px;">Create a Word-Document</div>
								</a>
							</p>
						</cfif>
						<p><hr></p>
						<!--- Export Metadata --->
						<cfif cs.icon_metadata_export>
							<p>
								<a href="##" onclick="showwindow('#myself#c.meta_export&folder_id=#url.folder_id#&what=folder','#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#',500,1);$('##drop#thediv#').toggle();return false;">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/document-export-4.png" border="0" width="16" height="16" />
									</div>
									<div style="padding-top:2px;">#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#</div>
								</a>
							</p>
						</cfif>
						<!--- Import Metadata --->
						<cfif attributes.folderaccess NEQ "R" AND cs.icon_metadata_import>
							<p>
								<a href="##" onclick="showwindow('#myself#c.meta_imp&folder_id=#url.folder_id#&isfolder=t','#myFusebox.getApplicationData().defaults.trans("header_import_metadata")#',500,1);$('##drop#thediv#').toggle();return false;" title="#myFusebox.getApplicationData().defaults.trans("header_import_metadata_desc")#">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/package-add.png" border="0" width="16" height="16" />
									</div>
									<div style="padding-top:2px;">#myFusebox.getApplicationData().defaults.trans("header_import_metadata")#</div>
								</a>
							</p>
						</cfif>
						<!--- Download Folder --->
						<cfif attributes.folderaccess NEQ "R" AND cs.icon_download_folder>
							<p><hr></p>
							<p>
								<a href="##" onclick="showwindow('#myself#ajax.download_folder&folder_id=#url.folder_id#','#myFusebox.getApplicationData().defaults.trans("header_download_folder")#',500,1);$('##drop#thediv#').toggle();return false;">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/folder-download.png" border="0" width="16" />
									</div>
									<div style="padding-top:2px;">Download assets in this folder</div>
								</a>
							</p>
							<p><hr /></p>
						</cfif>
						<!--- Refresh --->
						<cfif cs.icon_refresh>
							<p>
								<a href="##" onclick="loadcontent('dummy_#kind#','#myself#c.flushcache');loadcontent('#thediv#','#myself##thefa#&folder_id=#url.folder_id#&kind=#url.kind#&iscol=#attributes.iscol#');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_refresh_desc")#">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/view-refresh-3.png" width="16" height="16" border="0" />
									</div>
									<div style="padding-top:2px;">#myFusebox.getApplicationData().defaults.trans("tooltip_refresh")#</div>
								</a>
							</p>
						</cfif>
					</div>
				</div>
				<!--- View menu --->	
				<div>
					<div id="dropviews#thediv#" class="ddselection_header" style="width:200px;z-index:100;position:absolute;top:100px;left:<cfif attributes.folderaccess NEQ "R">458<cfelse>351</cfif>px;">
						<p>
							<a href="##" onclick="loadcontent('#thediv#','#myself##thexfa#&folder_id=#folder_id#&kind=#thetype#&iscol=#attributes.iscol#&view=');$('##dropviews#thediv#').toggle();return false;" title="Thumbnail View">
								<div style="float:left;padding-right:5px;">
									<img src="#dynpath#/global/host/dam/images/view-list-icons.png" border="0" width="16" height="16">
								</div>
								<div style="padding-top:2px;">Thumbnail View</div>
							</a>
						</p>
						<p>
							<a href="##" onclick="loadcontent('#thediv#','#myself##thexfa#&folder_id=#folder_id#&kind=#thetype#&iscol=#attributes.iscol#&view=list');$('##dropviews#thediv#').toggle();return false;" title="List View">
								<div style="float:left;padding-right:5px;">
									<img src="#dynpath#/global/host/dam/images/view-list-text-3.png" border="0" width="16" height="16">
								</div>
								<div style="padding-top:2px;">List View</div>
							</a>
						</p>
						<cfif attributes.folderaccess NEQ "R">
							<p>
								<a href="##" onclick="loadcontent('#thediv#','#myself##thexfa#&folder_id=#folder_id#&kind=#thetype#&iscol=#attributes.iscol#&view=combined');$('##dropviews#thediv#').toggle();return false;" title="Combined/Quick Edit View">
									<div style="float:left;padding-right:5px;">
										<img src="#dynpath#/global/host/dam/images/view-list-details-4.png" border="0" width="16" height="16">
									</div>
									<div style="padding-top:2px;">Quick Edit View</div>
								</a>
							</p>
						</cfif>
					</div>
				</div>
			</div>
		</td>
		<div id="feedback_delete_#kind#" style="white-space:no-wrap;"></div><div id="dummy_#kind#" style="display:none;"></div>
		<!--- Next and Back --->
		<td align="right" width="100%" nowrap="true">
			<cfif session.offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.offset - 1>
				<a href="##" onclick="loadcontent('#thediv#','#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=#newoffset#&iscol=#attributes.iscol#');">&lt; #myFusebox.getApplicationData().defaults.trans("back")#</a> |
			</cfif>
			<cfset showoffset = session.offset * session.rowmaxpage>
			<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
			<cfif qry_filecount.thetotal GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_filecount.thetotal GT session.rowmaxpage AND NOT shownextrecord GTE qry_filecount.thetotal> | 
				<!--- For Next --->
				<cfset newoffset = session.offset + 1>
				<a href="##" onclick="loadcontent('#thediv#','#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=#newoffset#&iscol=#attributes.iscol#');">#myFusebox.getApplicationData().defaults.trans("next")# &gt;</a>
			</cfif>
			<!--- Pages --->
			<cfif attributes.bot eq "true">
				<cfif qry_filecount.thetotal GT session.rowmaxpage>
					<span style="padding-left:10px;">
						<cfset thepage = ceiling(qry_filecount.thetotal / session.rowmaxpage)>
						Page: 
							<select class="thepagelist#kind#"  onChange="loadcontent('#thediv#', $('.thepagelist#kind# :selected').val());">
							<cfloop from="1" to="#thepage#" index="i">
								<cfset loopoffset = i - 1>
								<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&offset=#loopoffset#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
							</cfloop>
							</select>
					</span>
				</cfif>
			<cfelse>
				<cfif qry_filecount.thetotal GT session.rowmaxpage>
					<span style="padding-left:10px;">
						<cfset thepage = ceiling(qry_filecount.thetotal / session.rowmaxpage)>
						Page: 
							<select id="thepagelist#kind#" onChange="loadcontent('#thediv#', $('##thepagelist#kind# :selected').val());">
							<cfloop from="1" to="#thepage#" index="i">
								<cfset loopoffset = i - 1>
								<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&offset=#loopoffset#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
							</cfloop>
							</select>
					</span>
				</cfif>
			</cfif>
		</td>
		<!--- Sort by --->
		<cfif attributes.bot eq "true">
			<td align="right" width="1%" nowrap="true">
				Sort by: 
				<select name="selectsortby#kind#" id="selectsortby#kind#" onChange="changesortby('selectsortby#kind#');" style="width:100px;">
					<option value="name"<cfif session.sortby EQ "name"> selected="selected"</cfif>>Name</option>
					<cfif kind EQ "all"><option value="kind"<cfif session.sortby EQ "kind"> selected="selected"</cfif>>Type of Asset</option></cfif>
					<option value="sizedesc"<cfif session.sortby EQ "sizedesc"> selected="selected"</cfif>>Size (Descending)</option>
				 	<option value="sizeasc"<cfif session.sortby EQ "sizeasc"> selected="selected"</cfif>>Size (Ascending)</option>
				 	<option value="dateadd"<cfif session.sortby EQ "dateadd"> selected="selected"</cfif>>Date Added</option>
				 	<option value="datechanged"<cfif session.sortby EQ "datechanged"> selected="selected"</cfif>>Last Changed</option>
				 	<option value="hashtag"<cfif session.sortby EQ "hashtag"> selected="selected"</cfif>>Same file</option>
				</select>
			</td>
		<cfelse>
			<td align="right" width="1%" nowrap="true">
				Sort by: 
				 <select name="selectsortby#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="selectsortby#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="changesortby('selectsortby#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" style="width:100px;">
				 	<option value="name"<cfif session.sortby EQ "name"> selected="selected"</cfif>>Name</option>
				 	<cfif kind EQ "all"><option value="kind"<cfif session.sortby EQ "kind"> selected="selected"</cfif>>Type of Asset</option></cfif>
				 	<option value="sizedesc"<cfif session.sortby EQ "sizedesc"> selected="selected"</cfif>>Size (Descending)</option>
				 	<option value="sizeasc"<cfif session.sortby EQ "sizeasc"> selected="selected"</cfif>>Size (Ascending)</option>
				 	<option value="dateadd"<cfif session.sortby EQ "dateadd"> selected="selected"</cfif>>Date Added</option>
				 	<option value="datechanged"<cfif session.sortby EQ "datechanged"> selected="selected"</cfif>>Last Changed</option>
				 	<option value="hashtag"<cfif session.sortby EQ "hashtag"> selected="selected"</cfif>>Same file</option>
				 </select>
			</td>
		</cfif>
		<!--- Change the amount of images shown --->
		<cfif attributes.bot eq "true">
			<td align="right" width="1%" nowrap="true"><cfif qry_filecount.thetotal GT session.rowmaxpage OR qry_filecount.thetotal GT 25> <select name="selectrowperpage#kind#" id="selectrowperpage#kind#" onChange="changerow('#thediv#','selectrowperpage#kind#')" style="width:80px;">
				<option value="javascript:return false;">Show how many...</option>
				<option value="javascript:return false;">---</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=25"<cfif session.rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=50"<cfif session.rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=75"<cfif session.rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=100"<cfif session.rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
			</select></cfif>
			</td>
		<cfelse>
			<td align="right" width="1%" nowrap="true"><cfif qry_filecount.thetotal GT session.rowmaxpage OR qry_filecount.thetotal GT 25> <select name="selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="changerow('#thediv#','selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>')" style="width:80px;">
				<option value="javascript:return false;">Show how many...</option>
				<option value="javascript:return false;">---</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=25"<cfif session.rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=50"<cfif session.rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=75"<cfif session.rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
				<option value="#myself##thefa#&iscol=#attributes.iscol#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=100"<cfif session.rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
			</select></cfif>
			</td>
		</cfif>
	</tr>
</table>
<!--- If all is selected show the description --->
<div id="selectstore<cfif structkeyexists(attributes,"bot")>b</cfif>#kind#form" style="display:none;width:100%;text-align:center;">
	<strong>All files in this <cfif kind EQ "all">folder<cfelse>section</cfif> have been selected</strong> <a href="##" onclick="CheckAllNot('#kind#form');return false;">Deselect all</a>
</div>
<!--- Put in basket button / Action Menu --->
<div id="folderselection#kind#form" class="actiondropdown">
	<!--- Select all link --->
	<!--- <div style="float:left;padding-right:15px;padding-bottom:5px;" id="selectstore<cfif structkeyexists(attributes,"bot")>b</cfif>#kind#form">
	 	<a href="##" onclick="CheckAllNot('#kind#form');return false;">Deselect all</a>
	</div> --->
	<!--- Actions with selection icons --->
	<!--- <div style="float:left;padding-right:5px;"><strong>#myFusebox.getApplicationData().defaults.trans("action_with_selection")#: </strong></div> --->
	<cfif cs.show_bottom_part>
		<a href="##" onclick="sendtobasket('#kind#form');return false;">
			<div style="float:left;">
				<img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</div>
		</a> 
	</cfif>
	<cfif attributes.folderaccess IS NOT "R">
		<a href="##" onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','move');return false;">
			<div style="float:left;padding-left:5px;">
				<img src="#dynpath#/global/host/dam/images/application-go.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("move")#</div>
		</a>
		<a href="##" onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','batch');return false;">
			<div style="float:left;padding-left:5px;">
				<img src="#dynpath#/global/host/dam/images/page-white_stack.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("batch")#</div>
		</a>
		<cfif cs.tab_collections>
			<a href="##" onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','chcoll');return false;">
				<div style="float:left;padding-left:5px;">
					<img src="#dynpath#/global/host/dam/images/picture-link.png" width="16" height="16" border="0" style="padding-right:3px;" />
				</div>
				<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("add_to_collection")#</div>
			</a>
		</cfif>
		<a href="##" onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','exportmeta');return false;">
			<div style="float:left;padding-left:5px;">
				<img src="#dynpath#/global/host/dam/images/report-go.png" width="16" height="16" border="0" style="padding-right:3px;" />
			</div>
			<div style="float:left;padding-right:5px;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#</div>
		</a>
		<cfif kind EQ "img" OR kind EQ "vid">
			<a href="##" onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','prev');return false;">
				<div style="float:left;padding-left:5px;">
					<img src="#dynpath#/global/host/dam/images/picture-go.png" width="16" height="16" border="0" style="padding-right:2px;" />
				</div>
				<div style="float:left;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("batch_recreate_preview")#</div>
			</a>
		</cfif>
		<cfif attributes.folderaccess EQ "X">
			<a href="##" onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','delete');return false;">
				<div style="float:left;padding-left:5px;">
					<img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" style="padding-right:2px;" />
				</div>
				<div style="float:left;padding-top:1px;">#myFusebox.getApplicationData().defaults.trans("delete")#</div>
			</a>
		</cfif>
		<!--- Plugin being shows with add_folderview_select_wx  --->
		<cfif structKeyExists(plwx,"pview")>
			<cfloop list="#plwx.pview#" delimiters="," index="i">
				#evaluate(i)#
			</cfloop>
		</cfif>
	</cfif>
	<!--- Plugin being shows with add_folderview_select_r  --->
	<cfif structKeyExists(plr,"pview")>
		<cfloop list="#plr.pview#" delimiters="," index="i">
			#evaluate(i)#
		</cfloop>
	</cfif>
</div>
		

<script language="javascript">
	// Change the sortby
	function changesortby(theselect){
		// Get selected option
		var thesortby = $('##' + theselect + ' option:selected').val();
		loadcontent('#thediv#','#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#&sortby=' + thesortby);
	}
</script>

</cfoutput>
