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
	<!---
<cfif application.razuna.storage EQ "nirvanix">
		<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
	<cfelse>
--->
		<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- </cfif> --->

	<!--- Search Results --->
	<div id="loading_searchagain"></div>
	<div style="min-width:850px;">
		<div style="float:right;margin:0;padding:0;">
			<form action="#self#" method="post" id="form_searchsearch">
			<input type="hidden" name="#theaction#" value="c.search_simple">
			<input type="hidden" name="folder_id" value="#attributes.folder_id#">
			<input type="hidden" name="searchtext" id="s_searchtext" value="">
			<cfif structkeyexists(variables,"qry_results_files")>
				<cfset docrec = qry_results_files.recordcount>
				<input type="hidden" name="listdocid" id="s_listdocid" value="#valuelist(qry_results_files.file_id)#">
			<cfelse>
				<cfset docrec = 0>
				<input type="hidden" name="listdocid" id="s_listdocid" value="">
			</cfif>
			<cfif structkeyexists(variables,"qry_results_images")>
				<cfset imgrec = qry_results_images.recordcount>
				<input type="hidden" name="listimgid" id="s_listimgid" value="#valuelist(qry_results_images.img_id)#">
			<cfelse>
				<cfset imgrec = 0>
				<input type="hidden" name="listimgid" id="s_listimgid" value="">
			</cfif>
			<cfif structkeyexists(variables,"qry_results_videos")>
				<cfset vidrec = qry_results_videos.recordcount>
				<input type="hidden" name="listvidid" id="s_listvidid" value="#valuelist(qry_results_videos.vid_id)#">
			<cfelse>
				<cfset vidrec = 0>
				<input type="hidden" name="listvidid" id="s_listvidid" value="">
			</cfif>
			<cfif structkeyexists(variables,"qry_results_audios")>
				<cfset audrec = qry_results_audios.recordcount>
				<input type="hidden" name="listaudid" id="s_listaudid" value="#valuelist(qry_results_audios.aud_id)#">
			<cfelse>
				<cfset audrec = 0>
				<input type="hidden" name="listaudid" id="s_listaudid" value="">
			</cfif>
			<table border="0" width="100%" cellspacing="0" cellpadding="0" class="tablepanel">
				<tr>
					<th>#defaultsObj.trans("refine_search")#</th>
				</tr>
				<tr>
					<td colspan="4" style="padding:5px 2px 5px 5px;">
					<input type="radio" id="s_newsearch" name="newsearch" value="t" checked="true"> <a href="##" onclick="clickcbk('form_searchsearch','newsearch',1)" style="text-decoration:none;">#defaultsObj.trans("new_search")#</a>
					<br />
					<input type="radio" name="newsearch" id="s_newsearch" value="f"> <a href="##" onclick="clickcbk('form_searchsearch','newsearch',0)" style="text-decoration:none;">#defaultsObj.trans("search_within")#</a></td>
				</tr>
				<tr>
					<td style="padding-bottom:0px;">#defaultsObj.trans("search_term")# (<a href="http://wiki.razuna.com/display/ecp/Search+and+Find+Assets" target="_blank">Help</a>)
					<br />
					<input name="searchfor" type="text" class="textbold" style="width:190px;">
					<br />
					Keywords
					<br />
					<input type="text" name="keywords" style="width:190px;" class="textbold">
					<br />
					Description
					<br />
					<input type="text" name="description" style="width:190px;" class="textbold">
					<br />
					Filename
					<br />
					<input type="text" name="filename" style="width:190px;" class="textbold">
					<br />
					Extension
					<br /><input type="text" name="extension" style="width:190px;" class="textbold">
					<br />
					All Metadata
					<br /><input type="text" name="rawmetadata" style="width:190px;" class="textbold">
					<br />
					<cfloop query="qry_cf_fields">
						<cfset cfid = replace(cf_id,"-","","all")>
						#cf_text#
						<br />
						<input type="text" name="cf#cfid#" style="width:190px;" class="textbold">
						<br />
					</cfloop>
					</td>
				</tr>
				<tr>
					<td>
						#defaultsObj.trans("search_for_type")#
						<br />
						<select name="thetype" id="s_type">
							<option value="all"<cfif attributes.thetype EQ "all"> selected="true"</cfif>>#defaultsObj.trans("search_for_allassets")#</option>
							<option value="img"<cfif attributes.thetype EQ "img"> selected="true"</cfif>>#defaultsObj.trans("search_for_images")#</option>
							<option value="doc"<cfif attributes.thetype EQ "doc"> selected="true"</cfif>>#defaultsObj.trans("search_for_documents")#</option>
							<option value="vid"<cfif attributes.thetype EQ "vid"> selected="true"</cfif>>#defaultsObj.trans("search_for_videos")#</option>
							<option value="aud"<cfif attributes.thetype EQ "aud"> selected="true"</cfif>>#defaultsObj.trans("search_for_audios")#</option>
						</select>
				</tr>
				<tr>
					<td>
						#defaultsObj.trans("date_created")#
						<br />
						<cfset lastyear = #year(now())# - 10>
						<cfset newyear = #year(now())# + 3>
						<select name="on_day" id="s_on_day" class="text"><option value="">#defaultsObj.trans("day")#</option><cfloop from="1" to="31" index="theday"><option value="#theday#">#theday#</option></cfloop></select> <select name="on_month" id="s_on_month" class="text"><option value="">#defaultsObj.trans("month")#</option><cfloop from="01" to="12" index="themonth"><option value="#themonth#">#themonth#</option></cfloop></select> <select name="on_year" id="s_on_year" class="text"><option value="">#defaultsObj.trans("year")#</option><cfloop from="#lastyear#" to="#newyear#" index="theyear"><option value="#theyear#">#theyear#</option></cfloop></select> <a href="##" onclick="settoday('form_searchsearch');">#defaultsObj.trans("today")#</a>
				</tr>
				<tr>
					<td>And/Or
						<br /><select name="andor" id="andor">
							<option value="AND" selected="true">AND</option>
							<option value="OR">OR</option>
						</select>
					</td>
				</tr>
				<tr>
					<td style="padding-top:0px;" width="100%" nowrap="true" id="submitrefinesearch"><input type="submit" name="submit" value="#defaultsObj.trans("button_find")#" class="button"></td>
				</tr>
			</table>
			</form>
		</div>
		<div style="width:70%;float:left;padding:0;margin:0;">
			<form name="allform">
			<input type="hidden" name="kind" value="all">
			<input type="hidden" name="thetype" value="all">
			<cfif session.fromshare EQ "F" AND (docrec NEQ 0 OR imgrec NEQ 0 OR vidrec NEQ 0 OR audrec NEQ 0)>
				<!--- Top Bar --->
				<table border="0" width="100%" cellspacing="0" cellpadding="0">
					<tr>
						<!--- Check/Uncheck all --->
						<td align="left" width="1%" nowrap="true"><a href="##" onClick="CheckAll('allform');">#defaultsObj.trans("toggle_selection")#</a></td>
						<!--- Put in basket button / Action Menu --->
						<td width="1%" nowrap="true" align="right"><div id="folderselectionallform" style="display:none;"><a href="##" onclick="sendtobasket('allform');">#defaultsObj.trans("put_in_basket")#</a> | <a href="##" onclick="sendtocol('allform');">#defaultsObj.trans("add_to_collection")#</a></div></td>
					</tr>
				</table>
			</cfif>
			<!--- Files --->
			<cfif isdefined("qry_results_files") AND qry_results_files.recordcount NEQ 0>
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<th width="100%" colspan="5">
						<div style="float:left;">#defaultsObj.trans("results_files")# (#qry_results_files.howmany#)</div>
						<div style="float:right;">
							<cfif session.fromshare EQ "F">
								<cfif qry_results_files.howmany GT 10 AND fa NEQ "c.search_files_do"><a href="##" onclick="loadcontent('rightside','#myself#c.search_files_do&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_files.howmany#&thetype=#attributes.thetype#');return false;">#defaultsObj.trans("show_remaining")# >>></a></cfif><cfif fa EQ "c.search_files_do" AND attributes.searchtype NEQ "adv" AND attributes.folder_id EQ 0><a href="##" onclick="loadcontent('rightside','#myself#c.search_simple&searchtext=#URLEncodedFormat(attributes.searchtext)#&thetype=#attributes.thetype#');return false;"><<< #defaultsObj.trans("back")#</a></cfif><cfif attributes.folder_id NEQ 0><a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back_to_folder")#</a></cfif>
							<cfelse>
								<cfif qry_results_files.howmany GT 10><a href="##" onclick="loadcontent('rightside','#myself#c.share_search&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_files.howmany#&thetype=#attributes.thetype#');return false;">#defaultsObj.trans("show_remaining")# >>></a> | </cfif><a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back")#</a>
							</cfif>
						</div>
					</th>
				</tr>
				<tr>
					<td>
						<cfloop query="qry_results_files">
							<script type="text/javascript">
							$(function() {
								$("##draggable#file_id#-doc").draggable({
									appendTo: 'body',
									cursor: 'move',
									addClasses: false,
									iframeFix: true,
									opacity: 0.25,
									zIndex: 5000,
									helper: 'clone',
									start: function() {
										//$('##dropbaskettrash').css('display','none');
										//$('##dropfavtrash').css('display','none');
									},
									stop: function() {
										//$('##dropbaskettrash').css('display','');
										//$('##dropfavtrash').css('display','');
									}
								});
								
							});
							</script>
							<div class="assetbox" style="height:260px;">
								<div id="draggable#file_id#-doc" type="#file_id#-doc-all" class="theimg">
									<cfif session.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.filedetail#&file_id=#file_id#&what=files&folder_id=#folder_id_r#&loaddiv=all','#Jsstringformat(file_name)#',1000,1);return false;"></cfif>
									<!--- If it is a PDF we show the thumbnail --->
									<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND file_extension EQ "PDF">
										<img src="#cloud_url#" border="0">
									<cfelseif application.razuna.storage EQ "local" AND file_extension EQ "PDF">
										<cfset thethumb = replacenocase(file_name_org, ".pdf", ".jpg", "all")>
										<cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
											<img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" border="0">
										<cfelse>
											<img src="#thestorage#/#path_to_asset#/#thethumb#" border="0">
										</cfif>
									<cfelse>
										<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#file_extension#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" border="0"></cfif>
									</cfif>
									<cfif session.fromshare EQ "F"></a></cfif>
								</div>
								<br>
								<cfif session.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.filedetail#&file_id=#file_id#&what=files&folder_id=#folder_id_r#&loaddiv=all','#Jsstringformat(file_name)#',1000,1);return false;">#file_name#</a><cfelse>#file_name#</cfif>
								<cfif session.fromshare EQ "F">
									<br>
									#defaultsObj.trans("folder")#: <a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#folder_id_r#');return false;">#folder_name#</a> <input type="checkbox" name="file_id" value="#file_id#-doc" onclick="enablesub('allform');">
									<!--- Show description --->
									<cfif description NEQ "">
										<br>
										Description:<br />#description#
									</cfif>
									<!--- Show Keywords --->
									<cfif keywords NEQ "">
										<br>Keywords:<br /><cfloop list="#keywords#" delimiter="," index="i"><a href="##" onclick="searchkeywords('#attributes.folder_id#','#URLEncodedFormat(trim(i))#','#attributes.thetype#');">#trim(i)#</a> </cfloop>
									</cfif>
								</cfif>
							</div>
						</cfloop>
					</td>
				</tr>
				</table>
			<!--- <cfelseif isdefined("qry_results_files")>
				<h2>No documents could be found with your search criteria</h2> --->
			</cfif>
			<!--- Images --->
			<cfif isdefined("qry_results_images") AND qry_results_images.recordcount NEQ 0>
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<tr>
					<th width="100%" colspan="6">
						<div style="float:left;">#defaultsObj.trans("results_images")# (#qry_results_images.howmany#)</div>
						<div style="float:right;">
							<cfif session.fromshare EQ "F">
								<cfif qry_results_images.howmany GT 10 AND fa NEQ "c.search_images_do"><a href="##" onclick="loadcontent('rightside','#myself#c.search_images_do&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_images.howmany#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#');return false;">#defaultsObj.trans("show_remaining")# >>></a></cfif><cfif fa EQ "c.search_images_do" AND attributes.folder_id EQ 0><a href="##" onclick="loadcontent('rightside','#myself#c.search_simple&searchtext=#URLEncodedFormat(attributes.searchtext)#&thetype=#attributes.thetype#');return false;"><<< #defaultsObj.trans("back")#</a></cfif><cfif attributes.folder_id NEQ 0><a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back_to_folder")#</a></cfif>
							<cfelse>
								<cfif qry_results_images.howmany GT 10><a href="##" onclick="loadcontent('rightside','#myself#c.share_search&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_images.howmany#&thetype=#attributes.thetype#&folder_id=#attributes.folder_id#');return false;">#defaultsObj.trans("show_remaining")# >>></a> |Ê</cfif><a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back")#</a>
							</cfif>
						</div>
					</th>
				</tr>
				<tr>
					<td>
						<cfloop query="qry_results_images">
							<script type="text/javascript">
							$(function() {
								$("##draggable#img_id#-img").draggable({
									appendTo: 'body',
									cursor: 'move',
									addClasses: false,
									iframeFix: true,
									opacity: 0.25,
									zIndex: 5000,
									helper: 'clone',
									start: function() {
										//$('##dropbaskettrash').css('display','none');
										//$('##dropfavtrash').css('display','none');
									},
									stop: function() {
										//$('##dropbaskettrash').css('display','');
										//$('##dropfavtrash').css('display','');
									}
								});
								
							});
							</script>
							<div class="assetbox" style="height:260px;">
								<div id="draggable#img_id#-img" type="#img_id#-img-all" class="theimg">
									<cfif session.fromshare EQ "F">
										<a href="##" onclick="showwindow('#myself##xfa.imagedetail#&file_id=#img_id#&what=images&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(img_filename)#',1000,1);return false;">
									</cfif>
									<cfif link_kind NEQ "url">
										<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
											<img src="#cloud_url#" border="0">
										<cfelse>
											<img src="#thestorage##path_to_asset#/thumb_#img_id#.#thumb_extension#" border="0">
										</cfif>
									<cfelse>
										<img src="#link_path_url#" border="0">
									</cfif>
									<cfif session.fromshare EQ "F"></a></cfif>
								</div>
								<cfif session.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.imagedetail#&file_id=#img_id#&what=images&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(img_filename)#',1000,1);return false;">#img_filename#</a><cfelse>#img_filename#</cfif>
								<cfif session.fromshare EQ "F">
									<br>
									#defaultsObj.trans("folder")#: <a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#folder_id_r#');return false;">#folder_name#</a> <input type="checkbox" name="file_id" value="#img_id#-img" onclick="enablesub('allform');">
									<!--- Show description --->
									<cfif description NEQ "">
										<br>Description:<br />#description#
									</cfif>
									<!--- Show Keywords --->
									<cfif keywords NEQ "">
										<br>Keywords:<br /><cfloop list="#keywords#" delimiter="," index="i"><a href="##" onclick="searchkeywords('#attributes.folder_id#','#URLEncodedFormat(trim(i))#','#attributes.thetype#');">#trim(i)#</a> </cfloop>
									</cfif>
								</cfif>
							</div>
						</cfloop>
					</td>
				</tr>
				</table>
			<!--- <cfelseif isdefined("qry_results_images")>
				<h2>No images could be found with your search criteria</h2> --->
			</cfif>
			<!--- Videos --->
			<cfif isdefined("qry_results_videos") AND qry_results_videos.recordcount NEQ 0>
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th width="100%" colspan="5">
							<div style="float:left;">#defaultsObj.trans("results_videos")# (#qry_results_videos.howmany#)</div>
							<div style="float:right;">
								<cfif session.fromshare EQ "F">
									<cfif qry_results_videos.howmany GT 10 AND fa NEQ "c.search_videos_do"><a href="##" onclick="loadcontent('rightside','#myself#c.search_videos_do&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_videos.howmany#&thetype=#attributes.thetype#');return false;">#defaultsObj.trans("show_remaining")# >>></a></cfif><cfif fa EQ "c.search_videos_do" AND attributes.folder_id EQ 0><a href="##" onclick="loadcontent('rightside','#myself#c.search_simple&searchtext=#URLEncodedFormat(attributes.searchtext)#&thetype=#attributes.thetype#');return false;"><<< #defaultsObj.trans("back")#</a></cfif><cfif attributes.folder_id NEQ 0><a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back_to_folder")#</a></cfif>
								<cfelse>
									<cfif qry_results_videos.howmany GT 10><a href="##" onclick="loadcontent('rightside','#myself#c.share_search&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_videos.howmany#&thetype=#attributes.thetype#');return false;">#defaultsObj.trans("show_remaining")# >>></a> | </cfif><a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back")#</a>
								</cfif>
							</div>
						</th>
					</tr>
					<tr>
						<td>
							<cfloop query="qry_results_videos">
								<script type="text/javascript">
								$(function() {
									$("##draggable#vid_id#-vid").draggable({
										appendTo: 'body',
										cursor: 'move',
										addClasses: false,
										iframeFix: true,
										opacity: 0.25,
										zIndex: 5000,
										helper: 'clone',
										start: function() {
											//$('##dropbaskettrash').css('display','none');
											//$('##dropfavtrash').css('display','none');
										},
										stop: function() {
											//$('##dropbaskettrash').css('display','');
											//$('##dropfavtrash').css('display','');
										}
									});

								});
								</script>
								<div class="assetbox" style="height:260px;">
									<div id="draggable#vid_id#-vid" type="#vid_id#-vid-all" class="theimg">
										<!--- Show video --->
										<cfif session.fromshare EQ "F">
											<a href="##" onclick="showwindow('#myself##xfa.videodetail#&file_id=#vid_id#&what=videos&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(vid_filename)#',1000,1);return false;">
										</cfif>
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/#vid_name_image#" border="0">
											</cfif>
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
										</cfif>
										<cfif session.fromshare EQ "F"></a></cfif>
									</div>
									<br>
									<cfif session.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.videodetail#&file_id=#vid_id#&what=videos&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(vid_filename)#',1000,1);return false;">#vid_filename#</a><cfelse>#vid_filename#</cfif>
									<cfif session.fromshare EQ "F">
										<br>#defaultsObj.trans("folder")#: <a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#folder_id_r#');return false;">#folder_name#</a> <input type="checkbox" name="file_id" value="#vid_id#-vid" onclick="enablesub('allform');">
										<!--- Show description --->
										<cfif description NEQ "">
											<br>Description:<br />#description#
										</cfif>
										<!--- Show Keywords --->
										<cfif keywords NEQ "">
											<br>Keywords:<br /><cfloop list="#keywords#" delimiter="," index="i"><a href="##" onclick="searchkeywords('#attributes.folder_id#','#URLEncodedFormat(trim(i))#','#attributes.thetype#');">#trim(i)#</a> </cfloop>
										</cfif>
									</cfif>
								</div>
							</cfloop>
						</td>
					</tr>
				</table>
			<!--- <cfelseif isdefined("qry_results_videos")>
				<h2>No videos could be found with your search criteria</h2> --->
			</cfif>
			<!--- Audios --->
			<cfif isdefined("qry_results_audios") AND qry_results_audios.recordcount NEQ 0>
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th width="100%" colspan="2">
							<div style="float:left;">#defaultsObj.trans("results_audios")# (#qry_results_audios.howmany#)</div>
							<div style="float:right;">
								<cfif session.fromshare EQ "F">
									<cfif qry_results_audios.howmany GT 10 AND fa NEQ "c.search_audios_do"><a href="##" onclick="loadcontent('rightside','#myself#c.search_audios_do&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_audios.howmany#&thetype=#attributes.thetype#');return false;">#defaultsObj.trans("show_remaining")# >>></a></cfif><cfif fa EQ "c.search_audios_do" AND attributes.folder_id EQ 0><a href="##" onclick="loadcontent('rightside','#myself#c.search_simple&searchtext=#URLEncodedFormat(attributes.searchtext)#&thetype=#attributes.thetype#');return false;"><<< #defaultsObj.trans("back")#</a></cfif><cfif attributes.folder_id NEQ 0><a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back_to_folder")#</a></cfif>
								<cfelse>
									<cfif qry_results_audios.howmany GT 10><a href="##" onclick="loadcontent('rightside','#myself#c.share_search&searchtext=#URLEncodedFormat(attributes.searchtext)#&rowmax=#qry_results_audios.howmany#&thetype=#attributes.thetype#');return false;">#defaultsObj.trans("show_remaining")# >>></a> | </cfif><a href="##" onclick="loadcontent('rightside','#myself#c.share_content&fid=#attributes.folder_id#');return false;"><<< #defaultsObj.trans("back")#</a>
								</cfif>
							</div>
						</th>
					</tr>
					<tr>
						<td>
							<cfloop query="qry_results_audios">
								<div class="assetbox" style="height:260px;">
									<script type="text/javascript">
									$(function() {
										$("##draggable#aud_id#-aud").draggable({
											appendTo: 'body',
											cursor: 'move',
											addClasses: false,
											iframeFix: true,
											opacity: 0.25,
											zIndex: 5000,
											helper: 'clone',
											start: function() {
												//$('##dropbaskettrash').css('display','none');
												//$('##dropfavtrash').css('display','none');
											},
											stop: function() {
												//$('##dropbaskettrash').css('display','');
												//$('##dropfavtrash').css('display','');
											}
										});

									});
									</script>
									<div id="draggable#aud_id#-aud" type="#aud_id#-aud-all" class="theimg">
										<!--- Show audio --->
										<cfif session.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.audiodetail#&file_id=#aud_id#&what=audios&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(aud_name)#',1000,1);return false;"></cfif><img src="#dynpath#/global/host/dam/images/icons/icon_<cfif aud_extension EQ "mp3" OR aud_extension EQ "wav">#aud_extension#<cfelse>aud</cfif>.png" border="0"><cfif session.fromshare EQ "F"></a></cfif>
									</div>
									<br>
									<cfif session.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.audiodetail#&file_id=#aud_id#&what=audios&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(aud_name)#',1000,1);return false;">#aud_name#</a><cfelse>#aud_name#</cfif>
									<cfif session.fromshare EQ "F">
										<br>#defaultsObj.trans("folder")#: <a href="##" onclick="loadcontent('rightside','#myself##xfa.folder#&folder_id=#folder_id_r#');return false;">#folder_name#</a> <input type="checkbox" name="file_id" value="#aud_id#-aud" onclick="enablesub('allform');">
										<!--- Show description --->
										<cfif description NEQ "">
											<br>Description:<br />#description#
										</cfif>
										<!--- Show Keywords --->
										<cfif keywords NEQ "">
											<br>Keywords:<br /><cfloop list="#keywords#" delimiter="," index="i"><a href="##" onclick="searchkeywords('#attributes.folder_id#','#URLEncodedFormat(trim(i))#','#attributes.thetype#');">#trim(i)#</a> </cfloop>
										</cfif>
									</cfif>
								</div>
							</cfloop>
						</td>
					</tr>
				</table>
			<!--- <cfelseif isdefined("qry_results_audios")>
				<h2>No audios could be found with your search criteria</h2> --->
			</cfif>
			<!--- If nothing could be found at all --->
			<cfif 
			isdefined("qry_results_files") AND qry_results_files.recordcount EQ 0 
			AND isdefined("qry_results_images") AND qry_results_images.recordcount EQ 0
			AND isdefined("qry_results_videos") AND qry_results_videos.recordcount EQ 0
			AND isdefined("qry_results_audios") AND qry_results_audios.recordcount EQ 0>
				<h2>Nothing could be found with your search criteria. Try the <a href="##" onclick="showwindow('#myself#c.search_advanced','#defaultsObj.trans("link_adv_search")#',500,1);$('##searchselection').toggle();return false;">Advanced search</a> or another search term.</h2>
			</cfif>
			<!--- <div style="clear:both;padding:20px;"></div> --->
			</form>
		</div>
	</div>
</cfoutput>

<script language="javascript">
	$("#form_searchsearch").submit(function(e){
		// Call subfunction to get fields
		var searchtext = subadvfields('form_searchsearch');
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// Parse the entry
		var thetype = $('#thetype').val();
		// get the first position
		var p1 = searchtext.substr(searchtext,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else if (searchtext == "") {
			alert('Please enter a search term!');
		}
		else {
			// Get values
			var newsearch = $('#s_newsearch:checked').val();
			var thetype = $('#s_type option:selected').val();
			var listaudid = $('#s_listaudid').val();
			var listvidid = $('#s_listvidid').val();
			var listimgid = $('#s_listimgid').val();
			var listdocid = $('#s_listdocid').val();
			var on_day = $('#s_on_day option:selected').val();
			var on_month = $('#s_on_month option:selected').val();
			var on_year = $('#s_on_year option:selected').val();
			var andor = $('#andor option:selected').val();
			// some design stuff
			$('#submitrefinesearch').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading.gif" border="0" style="padding:0px;">');
			// Post the search
			$('#rightside').load('<cfoutput>#myself#</cfoutput>c.search_simple', {searchtext: searchtext, newsearch: newsearch, folder_id: <cfoutput>#attributes.folder_id#</cfoutput>, thetype: thetype, listaudid: listaudid, listvidid: listvidid, listimgid: listimgid, listdocid: listdocid, andor: andor, on_day: on_day, on_month: on_month, on_year: on_year} );
		}
		return false;
	});
	
	// Function can be called with: var query = JSON.stringify($('#form_searchsearch').serializeObject());
	
/*
	$.fn.serializeObject = function()
	{
	    var o = {};
	    var a = this.serializeArray();
	    $.each(a, function() {
	        if (o[this.name] !== undefined) {
	            if (!o[this.name].push) {
	                o[this.name] = [o[this.name]];
	            }
	            o[this.name].push(this.value);
	        } else {
	            o[this.name] = this.value;
	        }
	    });
	    return o;
	};
*/
	
	// Show Subsearch
	function showsubsearch(){
		$('#searchsearch').toggle('blind','slow');
	}
	// Search for keywords
	function searchkeywords(folderid,searchtext,thetype){
		$('#loading_searchagain').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
		loadcontent('rightside','<cfoutput>#myself#</cfoutput>c.search_simple&folder_id=' + folderid + '&searchtext=keywords:' + searchtext + '&thetype=' + thetype);
	}
</script>
