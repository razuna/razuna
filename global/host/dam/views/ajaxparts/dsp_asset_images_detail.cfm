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
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#"<cfif session.folderaccess NEQ "R"> onsubmit="filesubmit();return false;"</cfif>>
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#qry_detail.detail.folder_id_r#">
	<input type="hidden" name="file_id" value="#attributes.file_id#">
	<input type="hidden" name="theorgname" value="#qry_detail.detail.img_filename#">
	<input type="hidden" name="thepath" value="#thisPath#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.img_filename_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="extension" value="#qry_detail.detail.img_extension#">
	<input type="hidden" name="thumbextension" value="#qry_detail.detail.thumb_extension#">
	<input type="hidden" name="link_kind" value="#qry_detail.detail.link_kind#">
	<input type="hidden" name="link_path_url" value="#qry_detail.detail.link_path_url#">
	<div id="tab_detail#file_id#">
		<!--- Tabs --->
		<ul>
			<li><a href="##detailinfo" onclick="loadcontent('relatedimages','#myself#c.images_detail_related&file_id=#attributes.file_id#&what=images&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#');">#defaultsObj.trans("asset_information")#</a></li>
			<li><a href="##divcomments" onclick="loadcontent('divcomments','#myself#c.comments&file_id=#attributes.file_id#&type=#attributes.cf_show#');">#defaultsObj.trans("comments")# (#qry_comments_total#)</a></li>
			<li><a href="##detaildesc">#defaultsObj.trans("asset_desc")#</a></li>
			<cfif qry_cf.recordcount NEQ 0>
				<li><a href="##customfields">#defaultsObj.trans("custom_fields_asset")#</a></li>
			</cfif>
			<cfif session.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
				<li><a href="##convert">#defaultsObj.trans("convert")#</a></li>
			</cfif>
			<!--- (qry_detail.detail.img_extension EQ "jpg" OR qry_detail.detail.img_extension EQ "jpeg") AND  --->
			<cfif qry_detail.detail.link_kind NEQ "url">
				<li><a href="##imgmeta">Meta Data</a></li>
				<li><a href="##xmpdesc">XMP Description</a></li>
				<li><a href="##iptccontact">IPTC Contact</a></li>
				<li><a href="##iptcimage">IPTC Image</a></li>
				<li><a href="##iptccontent">IPTC Content</a></li>
				<li><a href="##iptcstatus">IPTC Status</a></li>
				<li><a href="##origin">Origin</a></li>
			</cfif>
			<cfif session.folderaccess NEQ "R" AND qry_detail.detail.link_kind EQ "">
				<li><a href="##divversions" onclick="loadcontent('divversions','#myself#c.versions&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#attributes.folder_id#');">#defaultsObj.trans("versions_header")#</a></li>
			</cfif>
			<cfif session.folderaccess NEQ "R">
				<li><a href="##shareoptions" onclick="loadcontent('shareoptions','#myself#c.share_options&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("tab_sharing_options")#</a></li>
				<li><a href="##previewimage" onclick="loadcontent('previewimage','#myself#c.previewimage&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("header_preview_image")#</a></li>
				<li><a href="##moreversions" onclick="loadcontent('moreversions','#myself#c.adi_versions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("adiver_header")#</a></li>
			</cfif>
		</ul>
		<!--- Content Starts here --->
		<div id="detailinfo">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<!--- The Buttons --->
				<tr>
					<td colspan="2">
						<input type="button" name="sendemail" value="#defaultsObj.trans("send_with_email")#" class="button" onclick="showwindow('#myself##xfa.sendemail#&file_id=#attributes.file_id#&thetype=img','#defaultsObj.trans("send_with_email")#',600,2);return false;">
						<cfif qry_detail.detail.link_path_url NEQ "url">
							<input type="button" name="sendftp" value="#defaultsObj.trans("send_with_ftp")#" class="button" onclick="showwindow('#myself##xfa.sendftp#&file_id=#attributes.file_id#&thetype=img','#defaultsObj.trans("send_with_ftp")#',600,2);return false;">
						</cfif>
						<input type="button" name="inbasket" value="#defaultsObj.trans("put_in_basket")#" class="button" onclick="loadcontent('thedropbasket','#myself##xfa.tobasket#&file_id=#attributes.file_id#&thetype=#attributes.file_id#-img');flash_footer();"> 
						<input type="button" name="tocollection" value="#defaultsObj.trans("add_to_collection")#" class="button" onclick="showwindow('#myself#c.choose_collection&file_id=#attributes.file_id#-img&thetype=img&artofimage=list&artofvideo=&artofaudio=&artoffile=','#defaultsObj.trans("add_to_collection")#',600,2);">
						<!--- Only users with full access can do the following --->
						<cfif #session.folderaccess# EQ "X">
							<input type="button" name="move" value="#defaultsObj.trans("move_file")#" class="button" onclick="showwindow('#myself#c.move_file&file_id=#attributes.file_id#&type=movefile&thetype=img&folder_id=#qry_detail.detail.folder_id_r#','#defaultsObj.trans("move_file")#',600,2);"> 
							<input type="button" name="remove" value="#defaultsObj.trans("delete_asset")#" class="button" onclick="showwindow('#myself#ajax.remove_record&id=#attributes.file_id#&what=images&loaddiv=#loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&offset=#attributes.offset#&rowmaxpage=#attributes.rowmaxpage#&showsubfolders=#session.showsubfolders#','#defaultsObj.trans("remove")#',400,2);return false;"> 
						</cfif>
						<input type="button" name="print" value="#defaultsObj.trans("tooltip_print")#" class="button" onclick="showwindow('#myself#ajax.topdf_window&folder_id=#qry_detail.detail.folder_id_r#&kind=detail&thetype=img&file_id=#attributes.file_id#','#defaultsObj.trans("pdf_window_title")#',500,2);return false;">
					</td>
				</tr>
				<!--- Description when url is a link --->
				<cfif qry_detail.detail.link_kind NEQ "">
					<tr>
						<td colspan="2"><strong>#defaultsObj.trans("link_url_desc")#</strong></td>
					</tr>
				</cfif>
				<!--- URL to files --->
				<tr>
					<td width="1%" nowrap="true" valign="top" style="padding-top:20px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
							<tr>
								<th colspan="2">Your Asset</th>
							</tr>
							<tr>
								<td colspan="2">
									<cfif qry_detail.detail.link_kind NEQ "url">
										<cfif qry_detail.detail.shared EQ "F">
											<a href="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=p" target="_blank">
										<cfelse>
											<a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#" target="_blank">
										</cfif>
										#defaultsObj.trans("preview")# (#qry_detail.theprevsize# MB) #defaultsObj.trans("format")#: #ucase(qry_detail.detail.thumb_extension)# #defaultsObj.trans("size")#: #qry_detail.detail.thumbwidth#x#qry_detail.detail.thumbheight# pixel</a> <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=p"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
										<!--- Nirvanix --->
										<cfif application.razuna.storage EQ "nirvanix" AND qry_detail.detail.shared EQ "T">
											<br><i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#</i>
										</cfif>
										<br>
										<cfif qry_detail.detail.link_kind NEQ "lan"><cfif qry_detail.detail.shared EQ "F"><a href="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=o" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.img_filename_org#"></cfif></cfif>Original (#qry_detail.thesize# MB) #defaultsObj.trans("format")#: #ucase(qry_detail.detail.img_extension)# #defaultsObj.trans("size")#: #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel<cfif qry_detail.detail.link_kind NEQ "lan"></a></cfif> <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=img&v=o" target="_blank"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
										<!--- Nirvanix --->
										<cfif application.razuna.storage EQ "nirvanix" AND qry_detail.detail.shared EQ "T">
											<br><i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.img_filename_org#</i>
										</cfif>
									<cfelse>
										<a href="#qry_detail.detail.link_path_url#" target="_blank">#defaultsObj.trans("link_to_original")#</a>
									</cfif>
								</td>
							</tr>
							<!--- Show related images (if any) --->
							<tr>
								<td colspan="2" style="padding:0;margin:0;">
									<div id="relatedimages"></div>
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
					<!--- show image according to extension --->
					<td align="center" style="padding-top:20px;">
						<cfif qry_detail.detail.link_kind NEQ "url">
							<!--- Storage Decision --->
							<!---
<cfif application.razuna.storage EQ "nirvanix">
								<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
							<cfelse>
--->
								<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
							<!--- </cfif> --->
							<cfif qry_detail.detail.link_kind NEQ "lan">
								<a href="http://#cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=o" target="_blank">
							</cfif>
							<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
								<img src="#qry_detail.detail.cloud_url#" border="0">
							<cfelse>
								<img src="#thestorage##qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#" border="0">
							</cfif>
							<cfif qry_detail.detail.link_kind NEQ "lan"></a></cfif>
							<cfif qry_detail.detail.link_kind NEQ "">
								<br />#qry_detail.detail.link_path_url#
								<br />#defaultsObj.trans("link_images_desc")#
							</cfif>
						<cfelse>
							<a href="#qry_detail.detail.link_path_url#" target="_blank" border="0"><img src="#qry_detail.detail.link_path_url#" border="0" width="120"></a><br /><a href="#qry_detail.detail.link_path_url#" target="_blank" border="0">#qry_detail.detail.link_path_url#</a>
						</cfif>
					</td>
				</tr>
				<tr>
					<td width="100%" valign="top" colspan="2" style="padding-top:20px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
							<tr>
								<td valign="top">#defaultsObj.trans("labels")#</td>
								<td width="100%" nowrap="true" colspan="5" valign="top"><input name="tags" id="tags_img" value="#qry_labels#"></td>
							</tr>
							<tr>
								<td></td>
								<td colspan="5" style="padding-bottom:10px;"><em>(<cfif settingsobj.get_label_set().set2_labels_users EQ "f">You can only choose from available labels. Simply start typing to select from available labels.<cfelse>Simple start typing to choose from available labels or add a new one by entering above and hit ",".</cfif>)</em></td>
							</tr>
							<tr>
								<td width="1%" nowrap="true">#defaultsObj.trans("file_name")#</td>
								<td width="100%" nowrap="true"><input type="text" style="width:400px;" name="file_name" value="#qry_detail.detail.img_filename#"> <a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=img');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td nowrap="true">#defaultsObj.trans("date_created")#</td>
								<td>#dateformat(qry_detail.detail.img_create_date, "#defaultsObj.getdateformat()#")#</td>
								<td nowrap="true">#defaultsObj.trans("file_size")#</td>
								<td><cfif qry_detail.detail.link_kind EQ "url">n/a<cfelse>#qry_detail.thesize# MB</cfif></td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">#defaultsObj.trans("located_in")#</td>
								<td nowrap="true" valign="top">#qry_detail.detail.folder_name# <a href="" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#qry_detail.detail.folder_id_r#&favtype=folder&favkind=');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td nowrap="true" valign="top">#defaultsObj.trans("date_changed")#</td>
								<td valign="top">#dateformat(qry_detail.detail.img_change_date, "#defaultsObj.getdateformat()#")#</td>
								<td nowrap="true" valign="top">#defaultsObj.trans("created_by")#</td>
								<td valign="top" nowrap="nowrap">#qry_detail.detail.user_first_name# #qry_detail.detail.user_last_name#</td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">ID</td>
								<td  nowrap="true" valign="top" colspan="5">#attributes.file_id#</td>
							</tr>
						</table>
					</td>
				</tr>
				<!--- Nirvanix: Sharing --->
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
						<td class="td2" width="100%"><textarea name="img_desc_#thisid#" class="text" rows="2" cols="50" onchange="javascript:document.form#attributes.file_id#.iptc_content_description_#thisid#.value = document.form#attributes.file_id#.img_desc_#thisid#.value"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_description#</cfif></cfloop></textarea></td>
					</tr>
					<tr>
						<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #defaultsObj.trans("keywords")#</strong></td>
						<td class="td2" width="100%"><textarea name="img_keywords_#thisid#" class="text" rows="2" cols="50" onchange="javascript:document.form#attributes.file_id#.iptc_content_keywords_#thisid#.value = document.form#attributes.file_id#.img_keywords_#thisid#.value"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_keywords#</cfif></cfloop></textarea></td>
					</tr>
				</cfloop>
				<tr>
					<td class="td2"></td>
					<td class="td2">#defaultsObj.trans("comma_seperated")#</td>
				</tr>
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
		<!--- Convert Image --->
		<cfif session.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
			<div id="convert">
				<cfif session.hosttype EQ "F">
					<cfinclude template="dsp_host_upgrade.cfm">
				<cfelse>
					<cfinclude template="dsp_asset_images_convert.cfm">
				</cfif>
			</div>
		</cfif>
		<cfif qry_detail.detail.link_kind NEQ "url">
			<!--- Meta Data --->
			<div id="imgmeta">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<td class="td2" width="100%"><textarea class="text" style="width:700px;height:400px;">#qry_detail.detail.img_meta#</textarea></td>
					</tr>
				</table>
			</div>
			<!--- XMP Description --->
			<div id="xmpdesc">
				<cfinclude template="dsp_asset_images_xmp.cfm">
			</div>
			<!--- IPTC Contact --->
			<div id="iptccontact">
				<cfinclude template="dsp_asset_images_iptc_contact.cfm">
			</div>
			<!--- IPTC Image --->
			<div id="iptcimage">
				<cfinclude template="dsp_asset_images_iptc_image.cfm">
			</div>
			<!--- IPTC Content --->
			<div id="iptccontent">
				<cfinclude template="dsp_asset_images_iptc_content.cfm">
			</div>
			<!--- IPTC Status --->
			<div id="iptcstatus">
				<cfinclude template="dsp_asset_images_iptc_status.cfm">
			</div>
			<!--- Origin --->
			<div id="origin">
				<cfinclude template="dsp_asset_images_origin.cfm">
			</div>
		</cfif>
		<!--- VERSIONS --->
		<cfif session.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
			<div id="divversions"></div>
		</cfif>
		<!--- SHARING OPTIONS --->
		<cfif session.folderaccess NEQ "R">
			<div id="shareoptions"></div>
			<div id="previewimage"></div>
			<div id="moreversions"></div>
		</cfif>
	</div>
	<!--- Submit Button --->
	<cfif session.folderaccess NEQ "R">
		<div id="updatefile" style="float:left;padding:10px;color:green;font-weight:bold;display:none;"></div><div style="float:right;padding:10px;"><input type="submit" name="submit" value="#defaultsObj.trans("button_save")#" class="button"></div>
	</cfif>
	</form>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		jqtabs("tab_detail#attributes.file_id#");
		<cfif qry_detail.detail.link_kind NEQ "url">
			loadcontent('relatedimages','#myself#c.images_detail_related&file_id=#attributes.file_id#&what=images&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');
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
					// Update Text
					// $("##updatefile").css("display","");
					$("##updatefile").html("#defaultsObj.trans("success")#");
					// Reload Related
					// loadcontent('relatedimages','#myself#c.images_detail_related&file_id=#attributes.file_id#&what=images&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');
					$("##updatefile").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
			   	}
			});
	        return false; 
		}
		// TAG IT
		var raztags = #attributes.thelabels#;
		// Global Tagit function
		// div, fileid, type, tags
		raztagit('tags_img','#attributes.file_id#','img',raztags,'#settingsobj.get_label_set().set2_labels_users#');
	</script>
</cfoutput>