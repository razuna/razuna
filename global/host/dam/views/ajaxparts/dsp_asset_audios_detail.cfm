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
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#" onsubmit="filesubmit();return false;">
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#qry_detail.detail.folder_id_r#">
	<input type="hidden" name="file_id" id="file_id" value="#attributes.file_id#">
	<input type="hidden" name="theorgname" id="theorgname" value="#qry_detail.detail.aud_name#">
	<input type="hidden" name="theorgext" id="theorgext" value="#qry_detail.detail.aud_extension#">
	<input type="hidden" name="thepath" id="thepath" value="#thisPath#">
	<input type="hidden" name="theos" value="#server.os.name#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.aud_name_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="convert_width_3gp" value="">
	<input type="hidden" name="convert_height_3gp" value="">
	<input type="hidden" name="link_kind" id="link_kind" value="#qry_detail.detail.link_kind#">
	<div id="tab_detail#file_id#">
		<ul>
			<li><a href="##detailinfo" onclick="loadcontent('relatedaudios','#myself#c.audios_detail_related&file_id=#attributes.file_id#&what=audios&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#');">#myFusebox.getApplicationData().defaults.trans("asset_information")#</a></li>
			<cfif cs.tab_description_keywords>
				<li><a href="##detaildesc">#myFusebox.getApplicationData().defaults.trans("asset_desc")#</a></li>
			</cfif>
			<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields>
				<li><a href="##customfields">#myFusebox.getApplicationData().defaults.trans("custom_fields_asset")#</a></li>
			</cfif>
			<cfif attributes.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
				<!--- Convert --->
				<cfif cs.tab_convert_files>
					<li><a href="##convert">#myFusebox.getApplicationData().defaults.trans("convert")#</a></li>
				</cfif>
				<cfif qry_detail.detail.link_kind NEQ "lan">
					<cfif cs.tab_versions>
						<li><a href="##divversions" onclick="loadcontent('divversions','#myself#c.versions&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#attributes.folder_id#');">#myFusebox.getApplicationData().defaults.trans("versions_header")#</a></li>
					</cfif>
				</cfif>
			</cfif>
			<!--- Comments --->
			<cfif cs.tab_comments>
				<li><a href="##divcomments" onclick="loadcontent('divcomments','#myself#c.comments&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#qry_detail.detail.folder_id_r#');">#myFusebox.getApplicationData().defaults.trans("comments")# (#qry_comments_total#)</a></li>
			</cfif>
			<cfif qry_detail.detail.link_kind NEQ "url" AND cs.tab_metadata>
				<li><a href="##audmeta">Meta Data</a></li>
			</cfif>
			<cfif attributes.folderaccess NEQ "R">
				<cfif cs.tab_sharing_options>
					<li><a href="##shareoptions" onclick="loadcontent('shareoptions','#myself#c.share_options&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#myFusebox.getApplicationData().defaults.trans("tab_sharing_options")#</a></li>
				</cfif>
				<cfif cs.tab_additional_renditions>
					<li><a href="##moreversions" onclick="loadcontent('moreversions','#myself#c.adi_versions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#myFusebox.getApplicationData().defaults.trans("adiver_header")#</a></li>
				</cfif>
				<cfif cs.tab_history>
					<li><a href="##history" onclick="loadcontent('history','#myself#c.log_history&id=#attributes.file_id#');">History</a></li>
				</cfif>
			</cfif>
		</ul>
		<div id="detailinfo">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<!--- The Buttons --->
				<cfset what = "audios">
				<cfinclude template="inc_detail_buttons.cfm" />
				<!--- Description when url is a link --->
				<cfif qry_detail.detail.link_kind NEQ "">
					<tr>
						<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("link_url_desc")#</strong></td>
					</tr>
				</cfif>
				<!--- If cloud url is empty --->
				<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND qry_detail.detail.cloud_url_org EQ "">
					<tr>
						<td colspan="2"><h2 style="color:red;">It looks like this file could not be added to the system properly. Please delete it and add it again!</h2></td>
					</tr>
				</cfif>
				<tr>
					<!--- show video according to extension --->
					<td width="1%" valign="top" style="padding-top:20px;">
						<table border="0" width="300" cellpadding="0" cellspacing="0" class="grid">
							<tr>
								<td width="100%" nowrap="true">
									<cfif qry_detail.detail.link_kind NEQ "url">
										<cfif qry_detail.detail.shared EQ "F"><a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sa&f=#attributes.file_id#" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.aud_name_org#" target="_blank"></cfif>Original #myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.aud_extension)#</a> <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=aud" target="_blank"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
										<a href="##" onclick="toggleslide('divo#attributes.file_id#','inputo#attributes.file_id#');"><img src="#dynpath#/global/host/dam/images/emblem-symbolic-link.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
										<div id="divo#attributes.file_id#" style="display:none;">Link: <input type="text" id="inputo#attributes.file_id#" style="width:270px;" value="http://#cgi.http_host##cgi.script_name#?#theaction#=c.sa&f=#attributes.file_id#&v=o" /></div>
									<cfelse>
										<a href="#qry_detail.detail.link_path_url#" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_to_original")#</a>
									</cfif>
								</td>
							</tr>
							<!--- Show related audios (if any) --->
							<tr>
								<td style="padding:0;margin:0;">
									<div id="relatedaudios"></div>
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
						<iframe src="#myself#ajax.audios_detail_flash&file_id=#attributes.file_id#&path_to_asset=#qry_detail.detail.path_to_asset#&aud_name=#qry_detail.detail.aud_name_org#&aud_extension=#qry_detail.detail.aud_extension#&link_kind=#qry_detail.detail.link_kind#&link_path_url=#URLEncodedFormat(qry_detail.detail.link_path_url)#&fromdetail=T<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">&cloud_url=#urlencodedformat(qry_detail.detail.cloud_url)#&cloud_url_org=#urlencodedformat(qry_detail.detail.cloud_url_org)#</cfif>" frameborder="false" scrolling="false" style="border:0px;width:500px;height:150px;" id="ifupload"></iframe>
						<cfif qry_detail.detail.link_kind EQ "url">
							<br /><a href="#qry_detail.detail.link_path_url#" target="_blank">#qry_detail.detail.link_path_url#</a>
						<cfelseif qry_detail.detail.link_kind EQ "lan">
							<br />#qry_detail.detail.link_path_url#
						</cfif>
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-top:20px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
							<cfif cs.tab_labels>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("labels")#</td>
									<td width="100%" nowrap="true" colspan="5">
										<select data-placeholder="Choose a label" class="chzn-select" style="width:400px;" id="tags_aud" onchange="razaddlabels('tags_aud','#attributes.file_id#','aud');" multiple="multiple">
											<option value=""></option>
											<cfloop query="attributes.thelabelsqry">
												<option value="#label_id#"<cfif ListFind(qry_labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
											</cfloop>
										</select>
										<cfif qry_label_set.set2_labels_users EQ "t" OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
											<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
										</cfif>
									</td>
								</tr>
							</cfif>
							<tr>
								<td width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("file_name")#</td>
								<td width="1%" nowrap="true"><input type="text" style="width:400px;" name="file_name" value="#qry_detail.detail.aud_name#"> <a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=aud');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_created")#</td>
								<td width="1%" nowrap="true">#dateformat(qry_detail.detail.aud_create_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
								<td width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("file_size")#</td>
								<td width="1%" nowrap="true"><cfif qry_detail.detail.link_kind NEQ "url">#qry_detail.thesize# MB<cfelse>n/a</cfif></td>
							</tr>
							<tr>
								<td width="1%" nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("located_in")#</td>
								<td width="1%" nowrap="true" valign="top">#qry_detail.detail.folder_name# <a href="" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#qry_detail.detail.folder_id_r#&favtype=folder&favkind=');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td width="1%" nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
								<td width="1%" nowrap="true" valign="top">#dateformat(qry_detail.detail.aud_change_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
								<td width="1%" nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("created_by")#</td>
								<td width="1%" nowrap="nowrap">#qry_detail.detail.user_first_name# #qry_detail.detail.user_last_name#</td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">ID</td>
								<td  nowrap="true" valign="top" colspan="5">#attributes.file_id#</td>
							</tr>
							<!---
<tr>
								<td width="1%" nowrap="true"><b>Status</b></td>
								<td colspan="5" width="100%" nowrap="true"><input type="radio" name="aud_online" value="F"<cfif qry_detail.detail.aud_online EQ "F"> checked="true"</cfif>>Offline <input type="radio" name="aud_online" value="T"<cfif qry_detail.detail.aud_online EQ "T"> checked="true"</cfif>>Online</td>
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
									<td class="td2"><b>#myFusebox.getApplicationData().defaults.trans("share_header")#</b></td>
								</tr>
								<tr>
									<td class="td2">#myFusebox.getApplicationData().defaults.trans("share_desc")#</td>
								</tr>
								<tr>
									<td class="td2"><input type="radio" name="shared" value="F"<cfif qry_detail.detail.shared EQ "F"> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")# <input type="radio" name="shared" value="T"<cfif qry_detail.detail.shared EQ "T"> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")#</td>
								</tr>
							</table>
						</td>
					</tr>
				</cfif>
--->
				<!--- Submit Button --->
				<tr>
					<td colspan="2">
						<cfif attributes.folderaccess NEQ "R">
							<div style="float:right;padding:10px;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
						<cfelse>
							<div style="float:right;padding:20px;"></div>
						</cfif>
					</td>
				</tr>
			</table>
		</div>
		<!--- Comments --->
		<div id="divcomments"></div>
		<!--- Description & Keywords --->
		<cfif cs.tab_description_keywords>
			<div id="detaildesc">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<cfloop query="qry_langs">
						<cfset thisid = lang_id>
						<tr>
							<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
							<td class="td2" width="100%"><textarea name="aud_desc_#thisid#" class="text" rows="2" cols="50"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#aud_description#</cfif></cfloop></textarea></td>
						</tr>
						<tr>
							<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("keywords")#</strong></td>
							<td class="td2" width="100%"><textarea name="aud_keywords_#thisid#" class="text" rows="2" cols="50"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#aud_keywords#</cfif></cfloop></textarea></td>
						</tr>
					</cfloop>
					<!--- Submit Button --->
					<cfif attributes.folderaccess NEQ "R">
						<tr>
							<td colspan="2">
								<div style="float:right;padding:10px;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
							</td>
						</tr>
					</cfif>
				</table>
			</div>
		</cfif>
		<!--- Meta Data --->
		<cfif qry_detail.detail.link_kind NEQ "url" AND cs.tab_metadata>
			<div id="audmeta">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<td class="td2" width="100%"><textarea class="text" style="width:700px;height:400px;">#qry_detail.detail.aud_meta#</textarea></td>
					</tr>
				</table>
			</div>
		</cfif>
		<!--- CUSTOM FIELDS --->
		<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields>
			<div id="customfields">
				<cfinclude template="inc_custom_fields.cfm">
			</div>
		</cfif>
		<!--- Convert Audios --->
		<cfif attributes.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
			<cfif cs.tab_convert_files>
				<div id="convert">
					<cfif session.hosttype EQ 0>
						<cfinclude template="dsp_host_upgrade.cfm">
					<cfelse>
						<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
							<tr>
								<td colspan="4">#myFusebox.getApplicationData().defaults.trans("audios_conversion_desc")#</td>
							</tr>
							<tr>
								<th colspan="4">#myFusebox.getApplicationData().defaults.trans("audio_original")#</th>
							</tr>
							<tr>
								<td width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("file_name")#</td>
								<td width="100%" colspan="3">#qry_detail.detail.aud_name#</td>
							</tr>
							<tr>
								<td width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("format")#</td>
								<td width="100%" colspan="3">#ucase(qry_detail.detail.aud_extension)#</td>
							</tr>
							<tr>
								<td width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("data_size")#</td>
								<td width="100%" colspan="3">#qry_detail.thesize# MB</td>
							</tr>
							<tr>
								<th colspan="2" nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("video_convert_to")#</th>
								<th>BitRate</th>
								<th></th>
							</tr>
							<tr class="list">
								<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="mp3"></td>
								<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',0)" style="text-decoration:none;">MP3</a></td>
								<td width="1%" nowrap="true"><select name="convert_bitrate_mp3" id="convert_bitrate_mp3">
								<option value="32">32</option>
								<option value="48">48</option>
								<option value="64">64</option>
								<option value="96">96</option>
								<option value="128">128</option>
								<option value="160">160</option>
								<option value="192" selected="true">192</option>
								<option value="256">256</option>
								<option value="320">320</option>
								</select></td>
								<td></td>
							</tr>
							<tr class="list">
								<td align="center"><input type="checkbox" name="convert_to" value="wav"></td>
								<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1)" style="text-decoration:none;">WAV</a></td>
								<td></td>
								<td></td>
							</tr>
							<tr class="list">
								<td align="center"><input type="checkbox" name="convert_to" value="ogg"></td>
								<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',2)" style="text-decoration:none;">OGG</a></td>
								<td><select name="convert_bitrate_ogg" id="convert_bitrate_ogg">
								<option value="10">82</option>
								<option value="20">102</option>
								<option value="30">115</option>
								<option value="40">137</option>
								<option value="50">147</option>
								<option value="60" selected="true">176</option>
								<option value="70">192</option>
								<option value="80">224</option>
								<option value="90">290</option>
								<option value="100">434</option>
								</select></td>
								<td>OGG has a much better compression, thus you don't need a high bitrate to achieve good quality.</td>
							</tr>
							<tr class="list">
								<td align="center"><input type="checkbox" name="convert_to" value="flac"></td>
								<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',3)">FLAC</a></td>
								<td></td>
								<td></td>
							</tr>
							<tr>
								<td colspan="4"><input type="button" name="convertbutton" value="#myFusebox.getApplicationData().defaults.trans("convert_button")#" class="button" onclick="convertaudios('form#attributes.file_id#');"> <div id="statusconvert" style="padding:10px;color:green;background-color:##FFFFE0;display:none;"></div><div id="statusconvertdummy"></div></td>
							</tr>
						</table>
					</cfif>
				</div>
			</cfif>
			<!--- VERSIONS --->
			<cfif qry_detail.detail.link_kind NEQ "lan">
				<div id="divversions"></div>
			</cfif>
		</cfif>
		<!--- SHARING OPTIONS --->
		<cfif attributes.folderaccess NEQ "R">
			<div id="shareoptions"></div>
			<div id="moreversions"></div>
			<div id="history"></div>
		</cfif>
		</div>
		<cfif attributes.folderaccess NEQ "R">
			<div id="updatefile" style="float:left;padding:10px;color:green;font-weight:bold;display:none;"></div>
		</cfif>
	</form>
	<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tab_detail#attributes.file_id#");
	loadcontent('relatedaudios','#myself#c.audios_detail_related&file_id=#attributes.file_id#&what=audios&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">&cloud_url_org=#urlencodedformat(qry_detail.detail.cloud_url_org)#</cfif>');
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
				// loadcontent('relatedaudios','#myself#c.audios_detail_related&file_id=#attributes.file_id#&what=audios&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');
				// Update Text
				$("##updatefile").html("#myFusebox.getApplicationData().defaults.trans("success")#");
				$("##updatefile").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
		   	}
		});
        return false; 
	};
	// Activate Chosen
	$(".chzn-select").chosen();
</script>
</cfoutput>