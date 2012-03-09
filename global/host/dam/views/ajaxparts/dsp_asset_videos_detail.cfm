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
<cfoutput>
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#"<cfif session.folderaccess NEQ "R"> onsubmit="filesubmit();return false;"</cfif>>
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#qry_detail.detail.folder_id_r#">
	<input type="hidden" name="file_id" value="#attributes.file_id#">
	<input type="hidden" name="theorgname" value="#qry_detail.detail.vid_filename#">
	<input type="hidden" name="theorgext" value="#qry_detail.detail.vid_extension#">
	<input type="hidden" name="thepath" value="#thisPath#">
	<input type="hidden" name="theos" value="#server.os.name#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.vid_name_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="convert_width_3gp" value="">
	<input type="hidden" name="convert_height_3gp" value="">
	<input type="hidden" name="link_kind" value="#qry_detail.detail.link_kind#">
	<cfset fi = find("iframe",qry_detail.detail.link_path_url)>
	<cfset fp = find("param",qry_detail.detail.link_path_url)>
	<cfset fo = find("object",qry_detail.detail.link_path_url)>
	<cfset foundit = fi + fp + fo>
	<cfif foundit EQ 0>
		<input type="hidden" name="link_path_url" value="#qry_detail.detail.link_path_url#">
	</cfif>
	<div id="tab_detail#file_id#">
		<ul>
			<li><a href="##detailinfo" onclick="loadcontent('relatedvideos','#myself#c.videos_detail_related&file_id=#attributes.file_id#&what=videos&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#');">#defaultsObj.trans("asset_information")#</a></li>
			<li><a href="##detaildesc">#defaultsObj.trans("asset_desc")#</a></li>
			<cfif qry_cf.recordcount NEQ 0>
				<li><a href="##customfields">#defaultsObj.trans("custom_fields_asset")#</a></li>
			</cfif>
			<cfif session.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
				<li><a href="##convert">#defaultsObj.trans("convert")#</a></li>
				<cfif qry_detail.detail.link_kind NEQ "lan">
					<li><a href="##divversions" onclick="loadcontent('divversions','#myself#c.versions&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#attributes.folder_id#');">#defaultsObj.trans("versions_header")#</a></li>
				</cfif>
			</cfif>
			<!--- Comments --->
			<li><a href="##divcomments" onclick="loadcontent('divcomments','#myself#c.comments&file_id=#attributes.file_id#&type=#attributes.cf_show#');">#defaultsObj.trans("comments")# (#qry_comments_total#)</a></li>
			<cfif qry_detail.detail.link_kind NEQ "url">
				<li><a href="##vidmeta">Meta Data</a></li>
			</cfif>
			<cfif session.folderaccess NEQ "R">
				<li><a href="##shareoptions" onclick="loadcontent('shareoptions','#myself#c.share_options&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("tab_sharing_options")#</a></li>
				<li><a href="##previewimage" onclick="loadcontent('previewimage','#myself#c.previewimage&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("header_preview_image")#</a></li>
				<li><a href="##moreversions" onclick="loadcontent('moreversions','#myself#c.adi_versions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("adiver_header")#</a></li>
				<li><a href="##history" onclick="loadcontent('history','#myself#c.log_history&id=#attributes.file_id#');">History</a></li>
			</cfif>
		</ul>
		<div id="detailinfo">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td width="100%" nowrap="true" colspan="2">
						<input type="button" name="sendemail" value="#defaultsObj.trans("send_with_email")#" class="button" onclick="showwindow('#myself##xfa.sendemail#&file_id=#attributes.file_id#&thetype=vid','#defaultsObj.trans("send_with_email")#',600,2);return false;"> 
						<cfif qry_detail.detail.link_kind NEQ "url"><input type="button" name="sendftp" value="#defaultsObj.trans("send_with_ftp")#" class="button" onclick="showwindow('#myself##xfa.sendftp#&file_id=#attributes.file_id#&thetype=vid','#defaultsObj.trans("send_with_ftp")#',600,2);return false;"></cfif>
						<input type="button" name="inbasket" value="#defaultsObj.trans("put_in_basket")#" class="button" onclick="loadcontent('thedropbasket','#myself##xfa.tobasket#&file_id=#attributes.file_id#&thetype=#attributes.file_id#-vid');flash_footer();"> 
						<input type="button" name="tocollection" value="#defaultsObj.trans("add_to_collection")#" class="button" onclick="showwindow('#myself#c.choose_collection&file_id=#attributes.file_id#-vid&thetype=vid&artofimage=list&artofvideo=&artofaudio=&artoffile=','#defaultsObj.trans("add_to_collection")#',600,2);">
						<cfif #session.folderaccess# EQ "X">
							<input type="button" name="move" value="#defaultsObj.trans("move_file")#" class="button" onclick="showwindow('#myself#c.move_file&file_id=#attributes.file_id#&type=movefile&thetype=vid&folder_id=#folder_id#','#defaultsObj.trans("move_file")#',600,2);"> 
							<input type="button" name="remove" value="#defaultsObj.trans("delete_asset")#" class="button" onclick="showwindow('#myself#ajax.remove_record&id=#attributes.file_id#&what=videos&loaddiv=#loaddiv#&folder_id=#folder_id#&showsubfolders=#session.showsubfolders#','#defaultsObj.trans("remove")#',400,2);return false;"> 
						</cfif>
						<input type="button" name="print" value="#defaultsObj.trans("tooltip_print")#" class="button" onclick="showwindow('#myself#ajax.topdf_window&folder_id=#qry_detail.detail.folder_id_r#&kind=detail&thetype=vid&file_id=#attributes.file_id#','#defaultsObj.trans("pdf_window_title")#',500,2);return false;"></td>
				</tr>
				<cfif qry_detail.detail.link_kind NEQ "">
					<tr>
						<td colspan="2"><strong>#defaultsObj.trans("link_url_desc")#</strong></td>
					</tr>
				</cfif>
				<!--- If cloud url is empty --->
				<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix" AND qry_detail.detail.cloud_url_org EQ "">
					<tr>
						<td colspan="2"><h2 style="color:red;">It looks like this file could not be added to the system properly. Please delete it and add it again!</h2></td>
					</tr>
				</cfif>
				<tr>
					<!--- show video according to extension --->
					<td width="1%" valign="top" style="padding-top:20px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0">
							<cfif qry_detail.detail.link_kind NEQ "url">
								<tr>
									<td width="100%" nowrap="true">
										<cfif qry_detail.detail.link_kind EQ "lan">
											Original (#qry_detail.thesize# MB) #defaultsObj.trans("format")#: #ucase(qry_detail.detail.vid_extension)# #defaultsObj.trans("size")#: #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel</a> <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
											<br />#qry_detail.detail.link_path_url#
										<cfelse>
											<cfif qry_detail.detail.shared EQ "F"><a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#attributes.file_id#&v=o" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_org#" target="_blank"></cfif>Original (#qry_detail.thesize# MB) #defaultsObj.trans("format")#: #ucase(qry_detail.detail.vid_extension)# #defaultsObj.trans("size")#: #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel</a> <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
											<!--- Nirvanix --->
											<cfif application.razuna.storage EQ "nirvanix" AND qry_detail.detail.shared EQ "T">
												<br><i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_org#</i>
											</cfif>
										</cfif>
									</td>
								</tr>
							<cfelse>
								<cfset lpu = mid(qry_detail.detail.link_path_url,1,5)>
								<cfif lpu CONTAINS "http">
									<tr>
										<td width="100%" nowrap="true">
										<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank">#defaultsObj.trans("link_to_original")#</a>
										</td>
									</tr>
								</cfif>
							</cfif>
							<!--- Show related videos (if any) --->
							<tr>
								<td style="padding:0;margin:0;">
									<div id="relatedvideos"></div>
								</td>
							</tr>
							<!--- Show additional version --->
							<tr>
								<td colspan="2" style="padding:0;margin:0;">
									<div id="additionalversions"></div>
								</td>
							</tr>
						</table>
					</td>
					<td width="100%" nowrap="true" valign="top" align="center" style="padding-top:20px;">
						<cfif qry_detail.detail.link_kind NEQ "lan">
							<div id="thevideodetail"><a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#attributes.file_id#&v=o" target="_blank"><img src="<cfif application.razuna.storage EQ "local">#cgi.context_path#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_image#<cfelse>#qry_detail.detail.cloud_url#</cfif>" width="400"></a><cfif qry_detail.detail.link_kind EQ "url">#qry_detail.detail.link_path_url#</cfif></div>
						<cfelse>
							<img src="#thestorage##qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_image#" border="0" width="420" height="230"><br />
							#qry_detail.detail.link_path_url#<br />
							#defaultsObj.trans("link_videos_desc")#
						</cfif>
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-top:20px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
							<cfif settingsobj.get_label_set().set2_labels_users EQ "f">
								<tr>
									<td>#defaultsObj.trans("labels")#</td>
									<td width="100%" nowrap="true" colspan="5">
										<select data-placeholder="Choose a label" class="chzn-select" style="width:400px;" id="tags_vid" onchange="razaddlabels('tags_vid','#attributes.file_id#','vid');" multiple="multiple">
											<option value=""></option>
											<cfloop query="attributes.thelabelsqry">
												<option value="#label_text#"<cfif ListFindNoCase(qry_labels,'#label_text#') NEQ 0> selected="selected"</cfif>>#label_text#</option>
											</cfloop>
										</select>
									</td>
								</tr>
							<cfelse>
								<tr>
									<td>#defaultsObj.trans("labels")#</td>
									<td width="100%" nowrap="true" colspan="5"><input name="tags" id="tags_vid" value="#qry_labels#"></td>
								</tr>
								<tr>
									<td></td>
									<td colspan="5" style="padding-bottom:10px;"><em>(Simple start typing to choose from available labels or add a new one by entering above and hit ",".)</em></td>
								</tr>
							</cfif>
							<tr>
								<td width="1%" nowrap="true">#defaultsObj.trans("file_name")#</td>
								<td width="1%" nowrap="true"><input type="text" style="width:400px;" name="file_name" value="#qry_detail.detail.vid_filename#"> <a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=vid');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td width="1%" nowrap="true">#defaultsObj.trans("date_created")#</td>
								<td width="1%" nowrap="true">#dateformat(qry_detail.detail.vid_create_date, "#defaultsObj.getdateformat()#")#</td>
								<td width="1%" nowrap="true">#defaultsObj.trans("file_size")#</td>
								<td width="1%" nowrap="true"><cfif qry_detail.detail.link_kind EQ "url">n/a<cfelse>#qry_detail.thesize# MB</cfif></td>
							</tr>
							<tr>
								<td width="1%" nowrap="true" valign="top">#defaultsObj.trans("located_in")#</td>
								<td width="1%" nowrap="true" valign="top">#qry_detail.detail.folder_name# <a href="" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#qry_detail.detail.folder_id_r#&favtype=folder&favkind=');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td width="1%" nowrap="true" valign="top">#defaultsObj.trans("date_changed")#</td>
								<td width="1%" nowrap="true" valign="top">#dateformat(qry_detail.detail.vid_change_date, "#defaultsObj.getdateformat()#")#</td>
								<td width="1%" nowrap="true" valign="top">#defaultsObj.trans("created_by")#</td>
								<td width="1%" nowrap="nowrap">#qry_detail.detail.user_first_name# #qry_detail.detail.user_last_name#</td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">ID</td>
								<td  nowrap="true" valign="top" colspan="5">#attributes.file_id#</td>
							</tr>
							<!---
<tr>
								<td width="1%" nowrap="true"><b>Status</b></td>
								<td colspan="5" width="100%" nowrap="true"><input type="radio" name="vid_online" value="F"<cfif qry_detail.detail.vid_online EQ "F"> checked="true"</cfif>>Offline <input type="radio" name="vid_online" value="T"<cfif qry_detail.detail.vid_online EQ "T"> checked="true"</cfif>>Online</td>
							</tr>
--->
						</table>
					</td>
				</tr>
				<!--- Nirvanix Sharing --->
				<!---
<cfif application.razuna.storage EQ "nirvanix">
					<tr>
						<td colspan="2" class="td2">
							<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
								<tr>
									<td class="td2"><b>#defaultsObj.trans("share_header")#</b></td>
								</tr>
								<tr>
									<td class="td2">#defaultsObj.trans("share_desc")#</td>
								</tr>
								<tr>
									<td class="td2"><input type="radio" name="shared" value="F"<cfif qry_detail.detail.shared EQ "F"> checked="true"</cfif>> #defaultsObj.trans("no")# <input type="radio" name="shared" value="T"<cfif qry_detail.detail.shared EQ "T"> checked="true"</cfif>> #defaultsObj.trans("yes")#</td>
								</tr>
							</table>
						</td>
					</tr>
				</cfif>
--->
			</table>
		</div>
		<!--- Comments --->
		<div id="divcomments"></div>
		<!--- Description & Keywords --->
		<div id="detaildesc">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
				<cfloop query="qry_langs">
					<cfset thisid = lang_id>
					<tr>
						<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #defaultsObj.trans("description")#</strong></td>
						<td class="td2" width="100%"><textarea name="vid_desc_#thisid#" class="text" rows="2" cols="50"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#vid_description#</cfif></cfloop></textarea></td>
					</tr>
					<tr>
						<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #defaultsObj.trans("keywords")#</strong></td>
						<td class="td2" width="100%"><textarea name="vid_keywords_#thisid#" class="text" rows="2" cols="50"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#vid_keywords#</cfif></cfloop></textarea></td>
					</tr>
				</cfloop>
			</table>
		</div>
		<!--- CUSTOM FIELDS --->
		<cfif qry_cf.recordcount NEQ 0>
			<div id="customfields">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<cfloop query="qry_cf">
						<tr>
							<td class="td2" valign="top"><strong>#cf_text#</strong></td>
							<td class="td2">
								<!--- For text --->
								<cfif cf_type EQ "text">
									<input type="text" size="40" id="cf_#cf_id#" name="cf_#cf_id#" value="#cf_value#">
								<cfelseif cf_type EQ "radio">
									<input type="radio" name="cf_#cf_id#" value="T"<cfif cf_value EQ "T"> checked="true"</cfif>>#defaultsObj.trans("yes")# <input type="radio" name="cf_#cf_id#" value="F"<cfif cf_value EQ "F" OR cf_value EQ ""> checked="true"</cfif>>#defaultsObj.trans("no")#
								<cfelseif cf_type EQ "textarea">
									<textarea name="cf_#cf_id#" style="width:400px;height:60px;">#cf_value#</textarea>
								</cfif>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
		</cfif>
		<!--- Meta Data --->
		<cfif qry_detail.detail.link_kind NEQ "url">
			<div id="vidmeta">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<td class="td2" width="100%"><textarea class="text" style="width:700px;height:400px;">#qry_detail.detail.vid_meta#</textarea></td>
					</tr>
				</table>
			</div>
		</cfif>
		<cfif session.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
			<!--- Convert Videos --->
			<div id="convert">
				<cfif session.hosttype EQ 0>
					<cfinclude template="dsp_host_upgrade.cfm">
				<cfelse>
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
						<tr>
							<td colspan="4">#defaultsObj.trans("videos_conversion_desc")#</td>
						</tr>
						<tr>
							<th colspan="4">#defaultsObj.trans("video_original")#</th>
						</tr>
						<tr>
							<td width="1%" nowrap="true">#defaultsObj.trans("file_name")#</td>
							<td width="100%" colspan="3">#qry_detail.detail.vid_filename#</td>
						</tr>
						<tr>
							<td width="1%" nowrap="true">#defaultsObj.trans("format")#</td>
							<td width="100%" colspan="3">#ucase(qry_detail.detail.vid_extension)#</td>
						</tr>
						<tr>
							<td width="1%" nowrap="true">#defaultsObj.trans("size")#</td>
							<td width="100%" colspan="3">#qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel</td>
						</tr>
						<tr>
							<td width="1%" nowrap="true">#defaultsObj.trans("data_size")#</td>
							<td width="100%" colspan="3">#qry_detail.thesize# MB</td>
						</tr>
						<!--- <cfif server.os.name CONTAINS "Mac">
							<tr>
								<td colspan="4" style="color:##FF0000;">#defaultsObj.trans("videos_conversion_mac")#</td>
							</tr>
						</cfif> --->
						<tr>
							<th colspan="2">#defaultsObj.trans("video_convert_to")#</th>
							<th>#defaultsObj.trans("size")#</th>
							<!--- <th>BitRate</th> --->
						</tr>
						<cfset theaspectratio = #qry_detail.detail.vwidth# / #qry_detail.detail.vheight#>
						<!--- OGV --->
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="ogv"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',0);return false;" style="text-decoration:none;">OGG (OGV)*</a></td>
							<td><input type="text" size="3" name="convert_width_ogv" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_ogv','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_ogv" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_ogv','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_ogv" value="600">kb/s</td> --->
						</tr>
						<!--- WebM --->
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="webm"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1);return false;" style="text-decoration:none;">WebM (WebM)*</a></td>
							<td><input type="text" size="3" name="convert_width_webm" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_webm','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_webm" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_webm','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_webm" value="600">kb/s</td> --->
						</tr>
						<!--- Flash --->
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="flv"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',2);return false;" style="text-decoration:none;">Flash (FLV)</a></td>
							<td><input type="text" size="3" name="convert_width_flv" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_flv','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_flv" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_flv','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_flv" value="600">kb/s</td> --->
						</tr>
						<!--- MP4 --->
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="mp4"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',3);return false;" style="text-decoration:none;">Mpeg4 (MP4)</a></td>
							<td><input type="text" size="3" name="convert_width_mp4" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_mp4','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_mp4" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_mp4','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mp4" value="600">kb/s</td> --->
						</tr>
						<tr class="list">
							<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="wmv"></td>
							<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',4);return false;" style="text-decoration:none;">Windows Media Video (WMV)</a></td>
							<td width="1%" nowrap="true"><input type="text" size="3" name="convert_width_wmv" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_wmv','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_wmv" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_wmv','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td width="100%" nowrap="true"><input type="text" size="4" name="convert_bitrate_wmv" value="600">kb/s</td> --->
						</tr>
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="avi"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',5);return false;" style="text-decoration:none;">Audio Video Interlaced (AVI)</a></td>
							<td><input type="text" size="3" name="convert_width_avi" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_avi','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_avi" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_avi','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_avi" value="600">kb/s</td> --->
						</tr>
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="mov"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',6);return false;" style="text-decoration:none;">Quicktime (MOV)</a></td>
							<td><input type="text" size="3" name="convert_width_mov" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_mov','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_mov" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_mov','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mov" value="600">kb/s</td> --->
						</tr>
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="mpg"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',7)" style="text-decoration:none;">Mpeg1 Mpeg2 (MPG)</a></td>
							<td><input type="text" size="3" name="convert_width_mpg" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_mpg','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_mpg" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_mpg','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mpg" value="600">kb/s</td> --->
						</tr>
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="3gp" onclick="clickset3gp('form#attributes.file_id#');"></td>
							<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',8);clickset3gp('form#attributes.file_id#');return false;" style="text-decoration:none;">3GP (3GP)</a></td>
							<td nowrap="true">
							<select name="convert_wh_3gp" onChange="javascript:set3gp('form#attributes.file_id#');">
							<option value="0"></option>
							<option value="1" selected="true">128x96 (MMS 64K)</option>
							<option value="2">128x96 (MMS 95K)</option>
							<option value="3">176x144 (MMS 95K)</option>
							<option value="4">128x96 (200K)</option>
							<option value="5">176x144 (200K)</option>
							<option value="6">128x96 (300K)</option>
							<option value="7">176x144 (300K)</option>
							<option value="8">128x96 (No size limit)</option>
							<option value="9">176x144 (No size limit)</option>
							<option value="10">352x288 (No size limit)</option>
							<option value="11">704x576 (No size limit)</option>
							<option value="12">1408x1152 (No size limit)</option>
							</select>
							</td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_3gp" value="64">kb/s</td> --->
						</tr>
						<tr class="list">
							<td align="center"><input type="checkbox" name="convert_to" value="rm"></td>
							<td nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',9);return false;" style="text-decoration:none;">RealNetwork Video Data (RM)</a></td>
							<td><input type="text" size="3" name="convert_width_rm" value="#qry_detail.detail.vwidth#" onchange="aspectheight(this,'convert_height_rm','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="3" name="convert_height_rm" value="#qry_detail.detail.vheight#" onchange="aspectwidth(this,'convert_width_rm','form#attributes.file_id#',#theaspectratio#);"></td>
							<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_rm" value="600">kb/s</td> --->
						</tr>
						<tr>
							<td colspan="4"><input type="button" name="convertbutton" value="#defaultsObj.trans("convert_button")#" class="button" onclick="convertvideos('form#attributes.file_id#');"> <div id="statusconvert" style="padding:10px;color:green;background-color:##FFFFE0;visibility:hidden;"></div><div id="statusconvertdummy"></div></td>
						</tr>
					</table>
				</cfif>
			</div>
				<!--- VERSIONS --->
				<cfif qry_detail.detail.link_kind NEQ "lan">
					<div id="divversions"></div>
				</cfif>
			</cfif>
			<!--- SHARING OPTIONS & previewimage --->
			<cfif session.folderaccess NEQ "R">
				<div id="shareoptions"></div>
				<div id="previewimage"></div>
				<div id="moreversions"></div>
				<div id="history"></div>
			</cfif>
		</div>
		<cfif session.folderaccess NEQ "R">
			<div id="updatefile" style="float:left;padding:10px;color:green;font-weight:bold;display:none;"></div><div style="float:right;padding:10px;"><input type="submit" name="submit" value="#defaultsObj.trans("button_save")#" class="button"></div>
		</cfif>
	</form>
	<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tab_detail#attributes.file_id#");
	<cfif qry_detail.detail.link_kind NEQ "url">
		loadcontent('relatedvideos','#myself#c.videos_detail_related&file_id=#attributes.file_id#&what=videos&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');
		<cfif qry_detail.detail.link_kind NEQ "lan">
			//loadcontent('thevideodetail','#myself#ajax.videos_detail_flash&file_id=#attributes.file_id#&path_to_asset=#urlencodedformat(qry_detail.detail.path_to_asset)#&vid_name_image=#urlencodedformat(qry_detail.detail.vid_name_image)#&vid_filename=#urlencodedformat(qry_detail.detail.vid_name_org)#&vid_extension=#qry_detail.detail.vid_extension#&vw=#qry_detail.detail.vwidth#&vh=#qry_detail.detail.vheight#<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">&cloud_url=#urlencodedformat(qry_detail.detail.cloud_url)#&cloud_url_org=#urlencodedformat(qry_detail.detail.cloud_url_org)#</cfif>');
		</cfif>
	</cfif>
	loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#');
	// Submit form
	function filesubmit(){
		$("##updatefile").css("display","");
		loadinggif('updatefile');
		$("##updatefile").fadeTo("fast", 100);
		var url = formaction("form#attributes.file_id#");
		var items = formserialize("form#attributes.file_id#");
		// Submit Form
       	$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		// Reload Related
				// loadcontent('relatedvideos','#myself#c.videos_detail_related&file_id=#attributes.file_id#&what=videos&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');
				// Update Text
				$("##updatefile").html("#defaultsObj.trans("success")#");
				$("##updatefile").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
		   	}
		});
        return false; 
	};
	<cfif settingsobj.get_label_set().set2_labels_users EQ "T">
		// TAG IT
		var raztags = #attributes.thelabels#;
		// Global Tagit function
		// div, fileid, type, tags
		raztagit('tags_vid','#attributes.file_id#','vid',raztags,'#settingsobj.get_label_set().set2_labels_users#');
	<cfelse>
		// Activate Chosen
		$(".chzn-select").chosen();
	</cfif>
</script>
</cfoutput>