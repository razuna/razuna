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
<!--- Storage Decision --->
<!---
<cfif application.razuna.storage EQ "nirvanix">
	<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
<cfelse>
--->
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
<!--- </cfif> --->
<cfif session.iscol EQ "F">
	<cfset thefid = attributes.folder_id>
<cfelse>
	<cfset thefid = 1>
</cfif>
<cfoutput>
<div id="tabs_shared">
	<ul>
		<li><a href="##shared_thumbs">Thumbnails</a></li>
		<cfif qry_folder.share_comments EQ "T"><li><a href="##shared_list">List</a></li></cfif>
		<li><a href="##shared_basket" id="tabs_shared_basket" onclick="loadcontent('shared_basket','#myself#c.share_basket');">Basket</a></li>
	</ul>
	<div id="shared_thumbs">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="5">
					<div style="float:left;">
						<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#');"><img src="#dynpath#/global/host/dam/images/view-refresh-3.png" width="16" height="16" border="0" /></a>
						<a href="#myself#c.view_rss&folder_id=#session.fid#&kind=all&col=#session.iscol#" target="_blank" title="#defaultsObj.trans("view_rss_desc")#"><img src="#dynpath#/global/host/dam/images/application-rss+xml.png" border="0" width="16" height="16" style="padding-left:2px;" /></a>
						<a href="#myself#c.view_xls&folder_id=#session.fid#&kind=all&col=#session.iscol#" target="_blank" title="#defaultsObj.trans("view_xls_desc")#"><img src="#dynpath#/global/host/dam/images/page-excel.png" border="0" style="margin-left:2px;" width="16" height="16" /></a>
						<a href="#myself#c.view_doc&folder_id=#session.fid#&kind=all&col=#session.iscol#" target="_blank" title="#defaultsObj.trans("view_doc_desc")#"><img src="#dynpath#/global/host/dam/images/page-word.png" border="0" style="margin-left:2px;" width="16" height="16" /></a>
						<!--- BreadCrumb --->
						<cfif structkeyexists(url,"folder_id_r")>
							Folder: <cfloop list="#qry_breadcrumb#" delimiters=";" index="i"> / <a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#&folder_id=#ListGetAt(i,2,"|")#&folder_id_r=#ListGetAt(i,3,"|")#');">#ListGetAt(i,1,"|")#</a> </cfloop>
						</cfif>
						<div style="padding-left:50px;float:right;">
							<cfif session.offset GTE 1>
								<!--- For Back --->
								<cfset newoffset = session.offset - 1>
								<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#newoffset#');"><<< #defaultsObj.trans("back")#</a> |
							</cfif>
							<cfset showoffset = session.offset * session.rowmaxpage>
							<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
							<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
							<cfif qry.qry_filecount.thetotal GT session.rowmaxpage AND NOT shownextrecord GTE qry.qry_filecount.thetotal> | 
								<!--- For Next --->
								<cfset newoffset = session.offset + 1>
								<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#newoffset#');">#defaultsObj.trans("next")# >>></a>
							</cfif>
						</div>
						<!--- Pages --->
						<div style="float:right;">
							<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>
								<span style="padding-left:30px;">
								<cfset thepage = ceiling(qry.qry_filecount.thetotal / session.rowmaxpage)>
								Pages: 
									<select id="thepagelist" onChange="loadcontent('rightside', $('##thepagelist').val());">
									<cfloop from="1" to="#thepage#" index="i">
										<cfset loopoffset = i - 1>
										<option value="#myself#c.share_content&folder_id=#attributes.folder_id#&fid=#attributes.fid#<cfif structkeyexists(attributes,"folder_id_r")>&folder_id_r=#attributes.folder_id_r#</cfif>&offset=#loopoffset#"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
									</cfloop>
									</select>
							</span>
							</cfif>
						</div>
					</div>
					<div style="float:right;">
						<cfif qry_folder.share_upload EQ "T"><a href="##" onclick="showwindow('#myself#c.asset_add_single&folder_id=#thefid#','#JSStringFormat(defaultsObj.trans("add_file"))#',650,1);return false;">#defaultsObj.trans("add_file")#</a> | </cfif>
						#qry.qry_filecount.thetotal# #defaultsObj.trans("share_content_count")#
					</div>
				</th>
			</tr>
			<tr>
				<td valign="top" align="center">
					<!--- Show Subfolders --->
					<cfif session.iscol EQ "F">
						<cfloop query="qry_subfolders">
							<div class="assetbox" style="text-align:center;">
								<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#&folder_id=#folder_id#&folder_id_r=#folder_id_r#');">
									<div class="theimg">
										<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
									</div>
								<strong>#folder_name#</strong></a>
							</div>
						</cfloop>
					</cfif>
					<cfoutput query="qry.qry_files" group="id"> <!--- We need this here since the SQL can not be smplified otherwise --->
						<div class="assetbox">
							<!--- Images --->
							<cfif kind EQ "img">
								<cfif is_available>
									<div class="theimg">
										<!--- Show assets --->
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#" border="0">
											</cfif>
										<cfelse>
											<img src="#link_path_url#" border="0">
										</cfif>
									</div>
									<div>
										<!--- <img src="#dynpath#/global/host/dam/images/icons/icon_tiff.png" width="16" height="16" border="0" /> --->
										<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-img');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a><!--- <img src="#dynpath#/global/host/dam/images/go-down-7.png" width="16" height="16" border="0" /> --->
									</div>
									<br>
									<strong>#filename#</strong>
								<cfelse>
									We are still working on the asset "#filename#"...
								</cfif>
							<!--- Videos --->
							<cfelseif kind EQ "vid">
								<cfif is_available>
									<div class="theimg">
										<cfif link_kind NEQ "url"><cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix"><img src="#cloud_url#" border="0"><cfelse><img src="#thestorage##path_to_asset#/#filename_org#" border="0" width="160"></cfif><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0"></cfif>
									</div>
									<div>
<!--- 										<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" width="16" height="16" border="0" /> --->
										<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-vid');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
									</div>
									<br>
									<strong>#filename#</strong>
								<cfelse>
									We are still working on the asset "#filename#"...
								</cfif>
							<!--- Audios --->
							<cfelseif kind EQ "aud">
								<cfif is_available>
									<div class="theimg">
										<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">
									</div>
									<div>
<!--- 										<img src="#dynpath#/global/host/dam/images/icons/icon_aud.png" width="16" height="16" border="0" /> --->
										<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-aud');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
									</div>
									<br>
									<strong>#filename#</strong>
								<cfelse>
									We are still working on the asset "#filename#"...
								</cfif>
							<!--- All other files --->
							<cfelse>
								<cfif is_available>
									<div class="theimg">
										<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND ext EQ "PDF">
											<img src="#cloud_url#" border="0">
										<cfelseif application.razuna.storage EQ "local" AND ext EQ "PDF">
											<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
											<cfif FileExists("#ExpandPath("../../")##thestorage##path_to_asset#/#thethumb#") IS "no">
												-#filename_org#-<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/#thethumb#" border="0">
											</cfif>
										<cfelse>
											<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0"></cfif>
										</cfif>
									</div>
									<div>
<!--- 										<img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="16" height="16" border="0" /> --->
										<a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-doc');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
									</div>
									<br>
									<strong>#filename#</strong>
								<cfelse>
									We are still working on the asset "#filename#"...
								</cfif>
							</cfif>
						</div>
					</cfoutput>
				</td>
			</tr>
		</table>
	</div>
	<!--- List View --->
	<cfif qry_folder.share_comments EQ "T">
		<div id="shared_list">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
				<!--- Header --->
				<tr>
					<th colspan="2">
						<div style="float:left;">
							<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#');"><img src="#dynpath#/global/host/dam/images/view-refresh-3.png" width="16" height="16" border="0" /></a>
						<a href="#myself#c.view_rss&folder_id=#session.fid#&kind=all&col=#session.iscol#" target="_blank" title="#defaultsObj.trans("view_rss_desc")#"><img src="#dynpath#/global/host/dam/images/application-rss+xml.png" border="0" width="16" height="16" style="padding-left:2px;" /></a>
						<a href="#myself#c.view_xls&folder_id=#session.fid#&kind=all&col=#session.iscol#" target="_blank" title="#defaultsObj.trans("view_xls_desc")#"><img src="#dynpath#/global/host/dam/images/page-excel.png" border="0" style="margin-left:2px;" width="16" height="16" /></a>
						<a href="#myself#c.view_doc&folder_id=#session.fid#&kind=all&col=#session.iscol#" target="_blank" title="#defaultsObj.trans("view_doc_desc")#"><img src="#dynpath#/global/host/dam/images/page-word.png" border="0" style="margin-left:2px;" width="16" height="16" /></a>
							<div style="padding-left:50px;float:right;">
								<cfif session.offset GTE 1>
									<!--- For Back --->
									<cfset newoffset = session.offset - 1>
									<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#session.fid#&fid=#session.fid#&offset=#newoffset#&tab=1');"><<< #defaultsObj.trans("back")#</a> |
								</cfif>
								<cfset showoffset = session.offset * session.rowmaxpage>
								<cfset shownextrecord = (session.offset + 1) * session.rowmaxpage>
								<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>#showoffset# - #shownextrecord#</cfif>
								<cfif qry.qry_filecount.thetotal GT session.rowmaxpage AND NOT shownextrecord GTE qry.qry_filecount.thetotal> | 
									<!--- For Next --->
									<cfset newoffset = session.offset + 1>
									<a href="##" onclick="loadcontent('rightside','#myself#c.share_content&folder_id=#session.fid#&fid=#session.fid#&offset=#newoffset#&tab=1');">#defaultsObj.trans("next")# >>></a>
								</cfif>
							</div>
							<!--- Pages --->
							<div style="float:right;">
								<cfif qry.qry_filecount.thetotal GT session.rowmaxpage>
									<span style="padding-left:30px;">
									<cfset thepage = ceiling(qry.qry_filecount.thetotal / session.rowmaxpage)>
									Pages: 
										<select>
										<cfloop from="1" to="#thepage#" index="i">
											<cfset loopoffset = i - 1>
											<option onclick="loadcontent('rightside','#myself#c.share_content&fid=#session.fid#&offset=#loopoffset#');"<cfif (session.offset + 1) EQ i> selected</cfif>>#i#</option>
										</cfloop>
										</select>
								</span>
								</cfif>
							</div>
						</div>
						<div style="float:right;"><cfif qry_folder.share_upload EQ "T"><a href="##" onclick="showwindow('#myself#c.asset_add_single&folder_id=#thefid#','#JSStringFormat(defaultsObj.trans("add_file"))#',650,1);return false;">#defaultsObj.trans("add_file")#</a> | </cfif>#qry.qry_filecount.thetotal# #defaultsObj.trans("share_content_count")#</div>
					</th>
				</tr>
				<!--- List assets --->
				<cfoutput query="qry.qry_files" group="id">
					<tr class="thumbview">
						<td valign="top" style="width:200px;">
							<!--- Images --->
							<cfif kind EQ "img">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#" border="0">
									</cfif>
								<cfelseif link_kind EQ "url">
									<img src="#link_path_url#" border="0" width="120">
								</cfif>
								<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-img');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#">
							<!--- Videos --->
							<cfelseif kind EQ "vid">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<img src="#cloud_url#" border="0" width="160">
									<cfelse>
										<img src="#thestorage##path_to_asset#/#filename_org#" border="0" width="160">
									</cfif>
								<cfelseif link_kind EQ "url">
									<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0" width="128" height="128">
								</cfif>
								<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-vid');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#">
							<!--- Audios --->
							<cfelseif kind EQ "aud">
								<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" width="120" border="0">
								<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-aud');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#">
							<!--- All other files --->
							<cfelse>
								<!--- If it is a PDF we show the thumbnail --->
								<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND ext EQ "PDF">
									<img src="#cloud_url#" border="0">
								<cfelseif application.razuna.storage EQ "local" AND ext EQ "PDF">
									<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
									<cfif FileExists("#ExpandPath("../../")##thestorage##path_to_asset#/#thethumb#") IS "no">
										<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0">
									<cfelse>
										<img src="#thestorage##path_to_asset#/#thethumb#" width="128" border="0">
									</cfif>
								<cfelse>
									<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="128" height="128" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0"></cfif>
								</cfif>
								<br><a href="##" onclick="loadcontent('shared_basket','#myself#c.basket_put_include&file_id=#id#&thetype=#id#-doc');flash_basket_tab();return false;" title="#defaultsObj.trans("put_in_basket")#">
							</cfif>
							<img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" style="padding-top:5px;" /></a>
						</td>
						<td valign="top"><b>#filename#</b><cfif description NEQ ""><br />#description#</cfif><br />
							<div style="width:300px;">
								<!--- Load latest comment and links --->
								<div id="divlatcomment#id#"></div>
								<br />
								#defaultsObj.trans("comments_title")#<br />
								<textarea id="comment#id#" style="width:300px;height:40px;"></textarea><br />
								<div style="float:right;"><a href="##" onclick="addcomment('#id#','#kind#');return false;" style="text-decoration:underline;">#defaultsObj.trans("comments_submit")#</a></div>
								<div style="clear:right;padding-top:10px;" />
								<div id="div#id#" style="display:none;background-color:##CCC;height:200px;overflow:scroll;"><p></p></div>
							</div>
							<!--- JS for Slide Effects --->
							<script type="text/javascript">
								// Load latest comment
								loadcontent('divlatcomment#id#','#myself#c.share_comments_latest&file_id=#id#&type=#kind#');
							</script>
						</td>
					</tr>
				</cfoutput>
			</table>
		</div>
	</cfif>
	<!--- Basket --->
	<div id="shared_basket"></div>
</div>
<script type="text/javascript">
	jqtabs("tabs_shared");
	function flash_basket_tab(){
		$('##tabs_shared_basket').effect('pulsate');
	}
	<cfif structkeyexists(attributes,"tab")>
		$('##tabs_shared').tabs('select',1);
	</cfif>
</script>
</cfoutput>