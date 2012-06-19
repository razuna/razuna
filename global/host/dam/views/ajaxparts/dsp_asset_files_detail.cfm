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
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#"<cfif attributes.folderaccess NEQ "R"> onsubmit="filesubmit();return false;"</cfif>>
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="file_id" value="#attributes.file_id#">
	<input type="hidden" name="thepath" value="#thisPath#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.file_name_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="link_kind" value="#qry_detail.detail.link_kind#">
	<input type="hidden" name="file_extension" value="#qry_detail.detail.file_extension#">
	<div id="tab_detail#file_id#">
		<ul>
			<li><a href="##detailinfo" onclick="loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#');">#defaultsObj.trans("asset_information")#</a></li>
			<cfif cs.tab_description_keywords>
				<li><a href="##detaildesc">#defaultsObj.trans("asset_desc")#</a></li>
			</cfif>
			<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields>
				<li><a href="##customfields">#defaultsObj.trans("custom_fields_asset")#</a></li>
			</cfif>
			<!--- Comments --->
			<cfif cs.tab_comments>
				<li><a href="##divcomments" onclick="loadcontent('divcomments','#myself#c.comments&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#qry_detail.detail.folder_id_r#');">#defaultsObj.trans("comments")# (#qry_comments_total#)</a></li>
			</cfif>
			<cfif qry_detail.detail.link_kind NEQ "url" AND cs.tab_metadata>
				<li><a href="##filemeta">Meta Data</a></li>
			</cfif>
			<cfif attributes.folderaccess NEQ "R" AND qry_detail.detail.link_kind EQ "">
				<cfif cs.tab_versions>
					<li><a href="##divversions" onclick="loadcontent('divversions','#myself#c.versions&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#attributes.folder_id#');">#defaultsObj.trans("versions_header")#</a></li>
				</cfif>
			</cfif>
			<cfif attributes.folderaccess NEQ "R">
				<cfif cs.tab_sharing_options>
					<li><a href="##shareoptions" onclick="loadcontent('shareoptions','#myself#c.share_options&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("tab_sharing_options")#</a></li>
				</cfif>
				<cfif cs.tab_additional_renditions>
					<li><a href="##moreversions" onclick="loadcontent('moreversions','#myself#c.adi_versions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#defaultsObj.trans("adiver_header")#</a></li>
				</cfif>
				<cfif cs.tab_history>
					<li><a href="##history" onclick="loadcontent('history','#myself#c.log_history&id=#attributes.file_id#');">History</a></li>
				</cfif>
			</cfif>
		</ul>
		<div class="TabbedPanelsContent" id="detailinfo">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<!--- The Buttons --->
				<cfset what = "files">
				<cfinclude template="inc_detail_buttons.cfm" />
				<!--- Description when url is a link --->
				<cfif qry_detail.detail.link_kind NEQ "">
					<tr>
						<td colspan="2"><strong>#defaultsObj.trans("link_url_desc")#</strong></td>
					</tr>
				</cfif>
				<!--- If cloud url is empty --->
				<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND qry_detail.detail.cloud_url_org EQ "">
					<tr>
						<td colspan="2"><h2 style="color:red;">It looks like this file could not be added to the system properly. Please delete it and add it again!</h2></td>
					</tr>
				</cfif>
				<tr>
					<td width="1%" nowrap="true" valign="top" style="padding-top:20px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<td colspan="2">
									<cfif qry_detail.detail.link_kind NEQ "url">
										<cfif qry_detail.detail.shared EQ "F"><a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sf&f=#attributes.file_id#" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.file_name_org#" target="_blank"></cfif>Show Document</a> <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=doc" target="_blank"><img src="#dynpath#/global/host/dam/images/down_16.png" width="16" height="16" border="0" style="padding-bottom: 2px; vertical-align: middle;" /></a>
										<!--- Nirvanix --->
										<cfif application.razuna.storage EQ "nirvanix" AND qry_detail.detail.shared EQ "T">
											<br><i>#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.file_name_org#</i>
										</cfif>
										<cfif application.razuna.storage NEQ "amazon" AND qry_detail.detail.file_extension EQ "PDF" AND qry_detail.detail.link_kind NEQ "url">
											<br />
											<a href="http://#cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sp&f=#file_id#" target="_blank">#defaultsObj.trans("pdf_image_desc")#</a></strong>
										</cfif>
									<cfelse>
										<a href="#qry_detail.detail.link_path_url#" target="_blank">#defaultsObj.trans("link_to_original")#</a>
									</cfif>
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
						<!--- If it is a PDF we show the thumbnail --->
						<cfif application.razuna.storage EQ "nirvanix" AND qry_detail.detail.file_extension EQ "PDF">
							<!--- <cfset thethumb = replacenocase(qry_detail.detail.file_name_org, ".pdf", ".jpg", "all")> --->
							<img src="#qry_detail.detail.cloud_url#" border="0">
						<cfelseif application.razuna.storage EQ "local" AND qry_detail.detail.file_extension EQ "PDF">
							<cfset thethumb = replacenocase(qry_detail.detail.file_name_org, ".pdf", ".jpg", "all")>
							<cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#") IS "no">
								<img src="#dynpath#/global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png" width="128" height="128" border="0">
							<cfelse>
								<img src="#cgi.context_path#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#" width="128" border="0">
							</cfif>
						<cfelseif application.razuna.storage EQ "amazon">
							<img src="#qry_detail.detail.cloud_url#" border="0">
						<cfelse>
							<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="128" height="128" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png" width="128" height="128" border="0"></cfif>
						</cfif>
						<cfif qry_detail.detail.link_kind EQ "url">
							<br /><a href="#qry_detail.detail.link_path_url#" target="_blank">#qry_detail.detail.link_path_url#</a>
						<cfelseif qry_detail.detail.link_kind EQ "lan">
							<br />#qry_detail.detail.link_path_url#
						</cfif>
					</td>
				</tr>
				<tr>
					<td width="1%" nowrap="true" valign="top" colspan="2" style="padding-top:20px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
							<cfif cs.tab_labels>
								<tr>
									<td>#defaultsObj.trans("labels")#</td>
									<td width="100%" nowrap="true" colspan="5">
										<select data-placeholder="Choose a label" class="chzn-select" style="width:400px;" id="tags_doc" onchange="razaddlabels('tags_doc','#attributes.file_id#','doc');" multiple="multiple">
											<option value=""></option>
											<cfloop query="attributes.thelabelsqry">
												<option value="#label_id#"<cfif ListFind(qry_labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
											</cfloop>
										</select>
										<cfif settingsobj.get_label_set().set2_labels_users EQ "t" OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
											<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
										</cfif>
									</td>
								</tr>
							</cfif>
							<tr>
								<td width="1%" nowrap="true">#defaultsObj.trans("file_name")#</td>
								<td width="100%"><input type="text" style="width:400px;" name="file_name" value="#qry_detail.detail.file_name#"> <a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=doc');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td nowrap="true">#defaultsObj.trans("date_created")#</td>
								<td>#dateformat(qry_detail.detail.file_create_date, "#defaultsObj.getdateformat()#")#</td>
								<td nowrap="true">#defaultsObj.trans("file_size")#</td>
								<td><cfif qry_detail.detail.link_kind EQ "url">n/a<cfelse>#qry_detail.thesize# MB</cfif></td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">#defaultsObj.trans("located_in")#</td>
								<td valign="top">#qry_detail.detail.folder_name# <a href="" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#qry_detail.detail.folder_id_r#&favtype=folder&favkind=');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></td>
								<td nowrap="true" valign="top">#defaultsObj.trans("date_changed")#</td>
								<td valign="top">#dateformat(qry_detail.detail.file_change_date, "#defaultsObj.getdateformat()#")#</td>
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
				<!--- Submit Button --->
				<tr>
					<td colspan="2">
						<cfif attributes.folderaccess NEQ "R">
							<div style="float:right;padding:10px;"><input type="submit" name="submit" value="#defaultsObj.trans("button_save")#" class="button"></div>
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
					<tr>
						<td>
							<div style="float:left;">
								<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
									<cfloop query="qry_langs">
										<cfset thisid = lang_id>
										<tr>
											<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #defaultsObj.trans("description")#</strong></td>
											<td class="td2" width="100%"><textarea name="file_desc_#thisid#" class="text" style="width:300px;height:40px;"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_desc#</cfif></cfloop></textarea></td>
										</tr>
										<tr>
											<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #defaultsObj.trans("keywords")#</strong></td>
											<td class="td2" width="100%"><textarea name="file_keywords_#thisid#" class="text" style="width:300px;height:40px;"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_keywords#</cfif></cfloop></textarea></td>
										</tr>
									</cfloop>
								</table>
							</div>
							<!--- If we are a PDF we show additional XMP fields --->
							<cfif qry_detail.detail.file_extension EQ "PDF">
								<div style="float:right;">
									<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
										<tr>
											<td><strong>Author</strong></td>
											<td><input type="text" style="width:330px;" name="author" value="#qry_detail.pdfxmp.author#"></td>
										</tr>
										<tr>
											<td><strong>Author Title</strong></td>
											<td><input type="text" style="width:330px;" name="authorsposition" value="#qry_detail.pdfxmp.authorsposition#"></td>
										</tr>
										<tr>
											<td nowrap="nowrap"><strong>Description Writer</strong></td>
											<td><input type="text" style="width:330px;" name="captionwriter" value="#qry_detail.pdfxmp.captionwriter#"></td>
										</tr>
										<tr>
											<td nowrap="nowrap"><strong>Copyright Status</strong></td>
											<td>
											<select name="rightsmarked">
												<option value=""<cfif qry_detail.pdfxmp.rightsmarked EQ ""> selected="selected"</cfif>>Unknown</option>
												<option value="true"<cfif qry_detail.pdfxmp.rightsmarked EQ "true"> selected="selected"</cfif>>Copyrighted</option>
												<option value="false"<cfif qry_detail.pdfxmp.rightsmarked EQ "false"> selected="selected"</cfif>>Public Domain</option>
											</select>
											</td>
										</tr>
										<tr>
											<td nowrap="nowrap" valign="top"><strong>Copyright Notice</strong></td>
											<td><textarea name="rights" class="text" style="width:330px;height:40px;">#qry_detail.pdfxmp.rights#</textarea></td>
										</tr>
										<tr>
											<td nowrap="nowrap"><strong>Copyright URL</strong></td>
											<td><input type="text" style="width:330px;" name="webstatement" value="#qry_detail.pdfxmp.webstatement#"></td>
										</tr>
									</table>
								</div>
							</cfif>
						</td>
					</tr>
					<!--- Submit Button --->
					<cfif attributes.folderaccess NEQ "R">
						<tr>
							<td>
								<div style="float:right;padding:10px;"><input type="submit" name="submit" value="#defaultsObj.trans("button_save")#" class="button"></div>
							</td>
						</tr>
					</cfif>
				</table>
			</div>
		</cfif>
		<!--- CUSTOM FIELDS --->
		<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields>
			<div id="customfields">
				<cfinclude template="inc_custom_fields.cfm">
			</div>
		</cfif>
		<!--- Meta Data --->
		<cfif qry_detail.detail.link_kind NEQ "url" AND cs.tab_metadata>
			<div id="filemeta">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<td class="td2" width="100%"><textarea class="text" style="width:700px;height:400px;">#qry_detail.detail.file_meta#</textarea></td>
					</tr>
				</table>
			</div>
		</cfif>
		<cfif attributes.folderaccess NEQ "R">
			<!--- VERSIONS --->
			<div id="divversions"></div>
			<!--- SHARING OPTIONS --->
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
	// Initialize Tabs
	jqtabs("tab_detail#file_id#");
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
				$("##updatefile").html("#defaultsObj.trans("success")#");
				$("##updatefile").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
		   	}
		});
        return false; 
	};
	// Activate Chosen
	$(".chzn-select").chosen();
</script>
</cfoutput>