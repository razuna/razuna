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
			<!--- Icons --->			
			<div id="tooltip" style="float:left;">
				<!--- Upload --->
				<cfif session.folderaccess NEQ "R">
					<a href="##" onclick="showwindow('#myself##xfa.assetadd#&folder_id=#folder_id#','#JSStringFormat(defaultsObj.trans("add_file"))#',650,1);return false;" title="#defaultsObj.trans("add_file")#">
						<div style="float:left;">
							<img src="#dynpath#/global/host/dam/images/go-up-7.png" width="16" border="0" style="padding-right:2px;" />
						</div>
						<div style="float:left;padding-right:15px;">#defaultsObj.trans("add_file")#</div>
					</a>
				</cfif>
				<!--- Select --->
				<cfif cs.icon_select><a href="##" onClick="CheckAll('#kind#form');" title="#defaultsObj.trans("tooltip_select_desc")#"><img src="#dynpath#/global/host/dam/images/checkbox.png" width="16" name="edit_1" border="0" /></a></cfif>
				<!--- Refresh --->
				<cfif cs.icon_refresh><a href="##" onclick="showloadinggif();loadcontent('dummy_#kind#','#myself#c.flushcache');loadcontent('#thediv#','#myself##thefa#&folder_id=#url.folder_id#&kind=#url.kind#');return false;" title="#defaultsObj.trans("tooltip_refresh_desc")#"><img src="#dynpath#/global/host/dam/images/view-refresh-3.png" width="16" height="16" border="0" style="padding-left:3px;" /></a></cfif>
				<!--- Add Subfolder --->
				<cfif session.folderaccess NEQ "R" AND cs.icon_create_subfolder><a href="##" onclick="showwindow('#myself#c.folder_new&from=list&theid=#url.folder_id#&iscol=F','#defaultsObj.trans("folder_new")#',750,1);return false;" title="#defaultsObj.trans("tooltip_folder_desc")#"><img src="#dynpath#/global/host/dam/images/folder-new-7.png" width="16" height="16" border="0" style="padding-left:3px;"></a></cfif>
				<!--- Search --->
				<cfif cs.icon_search><a href="##" onclick="showwindow('#myself#c.search_advanced&folder_id=#attributes.folder_id#','#defaultsObj.trans("folder_search")#',500,1);" title="#defaultsObj.trans("folder_search")#"><img src="#dynpath#/global/host/dam/images/system-search-3.png" width="16" height="16" border="0" style="padding-left:3px;" /></a></cfif>
			</div>
			<!--- More actions menu --->	
			<div style="width:300px;">
				<div style="float:left;padding-left:10px;"><a href="##" onclick="$('##drop#thediv#').toggle();" style="text-decoration:none;" class="ddicon">More actions</a></div>
				<div style="float:left;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" class="ddicon" onclick="$('##drop#thediv#').toggle();"></div>
				<div id="drop#thediv#" class="ddselection_header" style="width:200px;position:absolute;top:105px;left:<cfif session.folderaccess NEQ "R">205<cfelse>98</cfif>px;">
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
							<a href="##" onclick="loadcontent('#thediv#','#myself##thefa#&folder_id=#url.folder_id#&kind=#url.kind#&showsubfolders=<cfif session.showsubfolders EQ "F">T<cfelse>F</cfif>');$('##drop#thediv#').toggle();return false;">
								<div style="float:left;padding-right:5px;">
									<img src="#dynpath#/global/host/dam/images/link.png" width="16" height="16" border="0" />
								</div>
								<div style="padding-top:2px;">Show Assets from Sub-Folders</div>
							</a>
						</p>
						<p><hr></p>
					</cfif>
					<!--- Exporting icons --->
					<cfif cs.icon_print>
						<p>
							<a href="##" target="_blank" onclick="showwindow('#myself#ajax.topdf_window&folder_id=#url.folder_id#&kind=#url.kind#','#defaultsObj.trans("pdf_window_title")#',500,1);$('##drop#thediv#').toggle();return false;">
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
					<!--- Import Metadata --->
					<cfif session.folderaccess NEQ "R" AND cs.icon_metadata_import>
						<p>
							<a href="##" onclick="showwindow('#myself#c.meta_imp&folder_id=#url.folder_id#&isfolder=t','#defaultsObj.trans("header_import_metadata")#',500,1);$('##drop#thediv#').toggle();return false;" title="#defaultsObj.trans("header_import_metadata_desc")#">
								<div style="float:left;padding-right:5px;">
									<img src="#dynpath#/global/host/dam/images/package-add.png" border="0" width="16" height="16" />
								</div>
								<div style="padding-top:2px;">#defaultsObj.trans("header_import_metadata")#</div>
							</a>
						</p>
					</cfif>
					<!--- Export Metadata --->
					<cfif cs.icon_metadata_export>
						<p>
							<a href="##" onclick="showwindow('#myself#c.meta_export&folder_id=#url.folder_id#&what=folder','#defaultsObj.trans("header_export_metadata")#',500,1);$('##drop#thediv#').toggle();return false;">
								<div style="float:left;padding-right:5px;">
									<img src="#dynpath#/global/host/dam/images/document-export-4.png" border="0" width="16" height="16" />
								</div>
								<div style="padding-top:2px;">#defaultsObj.trans("header_export_metadata")#</div>
							</a>
						</p>
					</cfif>
					<!--- Download Folder --->
					<cfif session.folderaccess NEQ "R" AND cs.icon_download_folder>
						<p><hr></p>
						<p>
							<a href="##" onclick="showwindow('#myself#ajax.download_folder&folder_id=#url.folder_id#','#defaultsObj.trans("header_download_folder")#',500,1);$('##drop#thediv#').toggle();return false;">
								<div style="float:left;padding-right:5px;">
									<img src="#dynpath#/global/host/dam/images/folder-download.png" border="0" width="16" />
								</div>
								<div style="padding-top:2px;">Download assets in this folder</div>
							</a>
						</p>
					</cfif>
				</div>
			</div>
		</td>
		<div id="feedback_delete_#kind#" style="white-space:no-wrap;"></div><div id="dummy_#kind#" style="display:none;"></div>
		<!--- Next and Back --->
		<td align="right" width="100%" nowrap="true">
			<cfif session.offset GTE 1>
				<!--- For Back --->
				<cfset newoffset = session.offset - 1>
				<a href="##" onclick="showloadinggif();loadcontent('#thediv#','#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=#newoffset#');"><<< #defaultsObj.trans("back")#</a> |
			</cfif>
			<cfset showoffset = session.offset * session.rowmaxpage>
			<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
			<cfif qry_filecount.thetotal GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
			<cfif qry_filecount.thetotal GT session.rowmaxpage AND NOT shownextrecord GTE qry_filecount.thetotal> | 
				<!--- For Next --->
				<cfset newoffset = session.offset + 1>
				<a href="##" onclick="showloadinggif();loadcontent('#thediv#','#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=#newoffset#');">#defaultsObj.trans("next")# >>></a>
			</cfif>
			<!--- Pages --->
			<cfif qry_filecount.thetotal GT session.rowmaxpage>
				<span style="padding-left:10px;">
					<cfset thepage = ceiling(qry_filecount.thetotal / session.rowmaxpage)>
					Pages: 
						<select id="thepagelist#kind#" onChange="showloadinggif();loadcontent('#thediv#', $('##thepagelist#kind# :selected').val());">
						<cfloop from="1" to="#thepage#" index="i">
							<cfset loopoffset = i - 1>
							<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&offset=#loopoffset#&showsubfolders=#attributes.showsubfolders#"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
						</cfloop>
						</select>
				</span>
			</cfif>
		</td>
		<!--- Sort by --->
		<td align="right" width="1%" nowrap="true">
			Sort by: 
			 <select name="selectsortby#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="selectsortby#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="showloadinggif();changerow('#thediv#','selectsortby#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>')" style="width:80px;">
			 	<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&sortby=name"<cfif session.sortby EQ "name"> selected="selected"</cfif>>Name</option>
			 	<cfif kind EQ "all"><option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&sortby=kind"<cfif session.sortby EQ "kind"> selected="selected"</cfif>>Type of Asset</option></cfif>
			 	<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&sortby=sizedesc"<cfif session.sortby EQ "sizedesc"> selected="selected"</cfif>>Size (Descending)</option>
			 	<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&sortby=sizeasc"<cfif session.sortby EQ "sizeasc"> selected="selected"</cfif>>Size (Ascending)</option>
			 	<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&sortby=dateadd"<cfif session.sortby EQ "dateadd"> selected="selected"</cfif>>Date Added</option>
			 	<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&sortby=datechanged"<cfif session.sortby EQ "datechanged"> selected="selected"</cfif>>Last Changed</option>
			 	<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&sortby=hashtag"<cfif session.sortby EQ "hashtag"> selected="selected"</cfif>>Same file</option>
			 </select>
		</td>
		<!--- Change the amount of images shown --->
		<td align="right" width="1%" nowrap="true"><cfif qry_filecount.thetotal GT session.rowmaxpage OR qry_filecount.thetotal GT 25> <select name="selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="showloadinggif();changerow('#thediv#','selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>')" style="width:80px;">
			<option value="javascript:return false;">Show how many...</option>
			<option value="javascript:return false;">---</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=25"<cfif session.rowmaxpage EQ 25> selected="selected"</cfif>>25</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=50"<cfif session.rowmaxpage EQ 50> selected="selected"</cfif>>50</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=75"<cfif session.rowmaxpage EQ 75> selected="selected"</cfif>>75</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=100"<cfif session.rowmaxpage EQ 100> selected="selected"</cfif>>100</option>
		</select></cfif>
		</td>
	</tr>
</table>

<!--- Put in basket button / Action Menu --->
<div id="folderselection<cfif structkeyexists(attributes,"bot")>b</cfif>#kind#form" style="display:none;padding-top:10px;">		
	<cfif cs.show_bottom_part>
		<button onclick="sendtobasket('#kind#form');" class="button">#defaultsObj.trans("put_in_basket")#</button>
	</cfif>
	<cfif StructKeyExists(Session, "folderaccess") and #session.folderaccess# IS NOT "R"> 
		<button onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','btn_move#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" class="button" value="move" id="btn_move#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>">#defaultsObj.trans("move")#</button>
		<button onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','btn_batch#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" class="button" value="batch" id="btn_batch#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>">#defaultsObj.trans("batch")#</button>
		<cfif cs.tab_collections>
			<button onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','btn_chcoll#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" class="button" value="chcoll" id="btn_chcoll#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>">#defaultsObj.trans("add_to_collection")#</button>
		</cfif>
		<button onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','btn_exportmeta#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" class="button" value="exportmeta" id="btn_exportmeta#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>">#defaultsObj.trans("header_export_metadata")#</button>
		<cfif kind EQ "img" OR kind EQ "vid">
			<button onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','btn_prev#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" class="button" value="prev" id="btn_prev#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>">#defaultsObj.trans("batch_recreate_preview")#</button>
		</cfif>
		<cfif session.folderaccess EQ "X">
			<button onclick="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','btn_delete#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" class="button" value="delete" id="btn_delete#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>">#defaultsObj.trans("delete")#</button>
		</cfif>
	<!---
<select name="fileaction#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="fileaction#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','fileaction#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" style="width:130px;">
		<option value="javascript:return false;" selected="true">#defaultsObj.trans("action_with_selection")#</option>
		<option value="javascript:return false;">---</option>
		<option value="move">#defaultsObj.trans("move")#</option>
		<option value="batch">#defaultsObj.trans("batch")#</option>
		<cfif cs.tab_collections><option value="chcoll">#defaultsObj.trans("add_to_collection")#</option></cfif>
		<option value="exportmeta">#defaultsObj.trans("header_export_metadata")#</option>
		<cfif kind EQ "img" OR kind EQ "vid">
			<option value="prev">#defaultsObj.trans("batch_recreate_preview")#</option>
		</cfif>
		<cfif session.folderaccess EQ "X">
			<option value="delete">#defaultsObj.trans("delete")#</option>
		</cfif>
	</select>
--->
	</cfif>
</div>
		

<script language="javascript">
	function showloadinggif(){
		$('##dummy_#kind#').css('display','');
		loadinggif('dummy_#kind#');
	}
</script>

</cfoutput>
