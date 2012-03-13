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
		<!--- Check/Uncheck all --->
		<td align="left" width="1%" nowrap="true">
			<div id="tooltip">
				<a href="##" onClick="CheckAll('#kind#form');" title="#defaultsObj.trans("tooltip_select_desc")#"><img src="#dynpath#/global/host/dam/images/checkbox.png" width="16" name="edit_1" hspace="5" border="0" style="margin-left:0;" /></a><a href="##" onclick="showloadinggif();loadcontent('dummy_#kind#','#myself#c.flushcache');loadcontent('#thediv#','#myself##thefa#&folder_id=#url.folder_id#&kind=#url.kind#');return false;" title="#defaultsObj.trans("tooltip_refresh_desc")#"><img src="#dynpath#/global/host/dam/images/view-refresh-3.png" width="16" height="16" hspace="5" border="0" style="margin-left:7px;" /></a><a href="##" onclick="loadcontent('#thediv#','#myself##thefa#&folder_id=#url.folder_id#&kind=#url.kind#&showsubfolders=<cfif session.showsubfolders EQ "F">T<cfelse>F</cfif>');return false;" title="#defaultsObj.trans("tooltip_subfolders_desc")#"><img src="#dynpath#/global/host/dam/images/link.png" width="16" height="16" hspace="5" border="0" style="margin-left:7px;" /></a><!--- Add Subfolder ---><cfif session.folderaccess NEQ "R"><a href="##" onclick="showwindow('#myself#c.folder_new&from=list&theid=#url.folder_id#&iscol=F','#defaultsObj.trans("folder_new")#',750,1);return false;" title="#defaultsObj.trans("tooltip_folder_desc")#"><img src="#dynpath#/global/host/dam/images/folder-new-7.png" width="16" height="16" border="0" hspace="5" style="margin-left:7px;"></a></cfif><a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#url.folder_id#&favtype=folder&favkind=');flash_footer();return false;" title="Add this folder to your favorites"><img src="#dynpath#/global/host/dam/images/folder-favorites.png" width="16" height="16" border="0" hspace="5" /></a><a href="##" onclick="showwindow('#myself#c.search_advanced&folder_id=#attributes.folder_id#','#defaultsObj.trans("folder_search")#',500,1);" title="#defaultsObj.trans("folder_search")#"><img src="#dynpath#/global/host/dam/images/system-search-3.png" width="16" height="16" border="0" hspace="5" /></a>
				<!--- Exporting icons --->
				<a href="##" target="_blank" onclick="showwindow('#myself#ajax.topdf_window&folder_id=#url.folder_id#&kind=#url.kind#','#defaultsObj.trans("pdf_window_title")#',500,1);return false;" title="#defaultsObj.trans("tooltip_print_desc")#"><img src="#dynpath#/global/host/dam/images/preferences-desktop-printer-2.png" hspace="5" border="0" style="margin-left:15px;" width="16" height="16" /></a>
				<a href="#myself#c.view_rss&folder_id=#url.folder_id#&kind=#url.kind#&col=F" target="_blank" title="#defaultsObj.trans("view_rss_desc")#"><img src="#dynpath#/global/host/dam/images/application-rss+xml.png" hspace="5" border="0" style="margin-left:7px;" width="16" height="16" /></a>
				<!--- <a href="#myself#c.view_xls&folder_id=#url.folder_id#&kind=#url.kind#&col=F" target="_blank" title="#defaultsObj.trans("view_xls_desc")#"><img src="#dynpath#/global/host/dam/images/page-excel.png" hspace="5" border="0" style="margin-left:7px;" width="16" height="16" /></a> --->
				<a href="#myself#c.view_doc&folder_id=#url.folder_id#&kind=#url.kind#&col=F" target="_blank" title="#defaultsObj.trans("view_doc_desc")#"><img src="#dynpath#/global/host/dam/images/page-word.png" hspace="5" border="0" style="margin-left:7px;" width="16" height="16" /></a>
				<!--- Import Metadata --->
				<cfif session.folderaccess NEQ "R">
					<a href="##" onclick="showwindow('#myself#c.meta_imp&folder_id=#url.folder_id#&isfolder=t','#defaultsObj.trans("header_import_metadata")#',500,1);return false;" title="#defaultsObj.trans("header_import_metadata_desc")#"><img src="#dynpath#/global/host/dam/images/package-add.png" hspace="5" border="0" style="margin-left:7px;" width="16" height="16" /></a>
				</cfif>
				<!--- Export Metadata --->
				<a href="##" onclick="showwindow('#myself#c.meta_export&folder_id=#url.folder_id#&what=folder','#defaultsObj.trans("header_export_metadata")#',500,1);return false;" title="#defaultsObj.trans("tooltip_export_metadata_desc")#"><img src="#dynpath#/global/host/dam/images/document-export-4.png" hspace="5" border="0" style="margin-left:7px;" width="16" height="16" /></a>
				<!--- Download Folder --->
				<cfif session.folderaccess NEQ "R">
					<a href="##" onclick="showwindow('#myself#ajax.download_folder&folder_id=#url.folder_id#','#defaultsObj.trans("header_download_folder")#',500,1);return false;" title="#defaultsObj.trans("header_download_folder_desc")#"><img src="#dynpath#/global/host/dam/images/folder-download.png" border="0" style="margin-left:7px;" width="18" /></a>
				</cfif>
			</div>
		</td>
		<div id="feedback_delete_#kind#" style="white-space:no-wrap;"></div><div id="dummy_#kind#" style="display:none;"></div>
		<!--- Next and Back --->
		<td align="center" width="100%" nowrap="true">
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
				<span style="padding-left:30px;">
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
		<!--- Put in basket button / Action Menu --->
		<td width="1%" nowrap="true">
			<div id="folderselection<cfif structkeyexists(attributes,"bot")>b</cfif>#kind#form" style="display:none;">		
				<a href="##" onclick="sendtobasket('#kind#form');">#defaultsObj.trans("put_in_basket")#</a>
				<cfif StructKeyExists(Session, "folderaccess") and #session.folderaccess# IS NOT "R"> 
				<select name="fileaction#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="fileaction#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="batchaction('#kind#form','<cfif kind EQ "img">images<cfelseif kind EQ "vid">videos<cfelseif kind EQ "aud">audios<cfelseif kind EQ "all">all<cfelse>files</cfif>','#kind#','#attributes.folder_id#','fileaction#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>');" style="width:130px;">
					<option value="javascript:return false;" selected="true">#defaultsObj.trans("action_with_selection")#</option>
					<option value="javascript:return false;">---</option>
					<option value="move">#defaultsObj.trans("move")#</option>
					<option value="batch">#defaultsObj.trans("batch")#</option>
					<option value="chcoll">#defaultsObj.trans("add_to_collection")#</option>
					<option value="exportmeta">#defaultsObj.trans("header_export_metadata")#</option>
					<cfif kind EQ "img" OR kind EQ "vid">
						<option value="prev">#defaultsObj.trans("batch_recreate_preview")#</option>
					</cfif>
					<cfif session.folderaccess EQ "X">
						<option value="delete">#defaultsObj.trans("delete")#</option>
					</cfif>
				</select>
				</cfif>
			</div>
		</td>
		<!--- Change the amount of images shown --->
		<td align="right" width="1%" nowrap="true"><cfif qry_filecount.thetotal GT session.rowmaxpage OR qry_filecount.thetotal GT 25> <select name="selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" id="selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>" onChange="showloadinggif();changerow('#thediv#','selectrowperpage#kind#<cfif structkeyexists(attributes,"bot")>b</cfif>')" style="width:80px;">
			<option value="javascript:return false;" selected="true">Show how many...</option>
			<option value="javascript:return false;">---</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=25">25</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=50">50</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=75">75</option>
			<option value="#myself##thefa#&folder_id=#attributes.folder_id#&kind=#kind#&showsubfolders=#attributes.showsubfolders#&offset=0&rowmaxpage=100">100</option>
		</select></cfif>
		</td>
	</tr>
</table>

<script language="javascript">
	function showloadinggif(){
		$('##dummy_#kind#').css('display','');
		loadinggif('dummy_#kind#');
	}
</script>

</cfoutput>
