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
<!--- Turn expiry date input into a jQuery datepicker --->
  <script>
	  $(function() {
	    $( "#expiry_date" ).datepicker();
	  });
  </script>
<cfoutput>
	<cfset uniqueid = createuuid()>
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#"<cfif attributes.folderaccess NEQ "R"> onsubmit="if (formchecks())filesubmit();return false;"</cfif>>
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#qry_detail.detail.folder_id_r#">
	<input type="hidden" name="file_id" id="file_id" value="#attributes.file_id#">
	<input type="hidden" name="theorgname" id="theorgname" value="#qry_detail.detail.img_filename#">
	<input type="hidden" name="thepath" id="thepath" value="#thisPath#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.img_filename_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="extension" value="#qry_detail.detail.img_extension#">
	<input type="hidden" name="thumbextension" value="#qry_detail.detail.thumb_extension#">
	<input type="hidden" name="link_kind" id="link_kind" value="#qry_detail.detail.link_kind#">
	<input type="hidden" name="link_path_url" id="link_path_url" value="#qry_detail.detail.link_path_url#">
	<!--- Show next and back within detail view --->
	<cfinclude template="inc_detail_next_back.cfm">
	<!--- Format size --->
	<cfif isnumeric(qry_detail.thesize)><cfset qry_detail.thesize = numberformat(qry_detail.thesize,'_.__')></cfif>

	<!--- Show tabs --->
	<div id="tab_detail#attributes.file_id#">
		<!--- Tabs --->
		<ul>
			<!--- Info --->
			<li><a href="##detailinfo">#myFusebox.getApplicationData().defaults.trans("asset_information")#</a></li>
			<!--- Renditions --->
			<!--- RAZ-549: Added in condition to not show renditions, versions and sharing tabs when asset has expired --->
			<cfif qry_detail.detail.link_kind NEQ "url" AND cs.tab_convert_files AND iif(isdate(qry_detail.detail.expiry_date) AND qry_detail.detail.expiry_date LT now(), false, true)>
				<li><a href="##convertt" onclick="loadren();return false;">#myFusebox.getApplicationData().defaults.trans("convert")#</a></li>
			</cfif>
			<!--- Metadata tabs  --->
			<cfif cs.tab_metadata>
				<li><a href="##meta">Meta Data</a></li>
			</cfif>
			<!--- Comments --->
			<cfif cs.tab_comments>
				<li><a href="##divcomments" onclick="loadcontent('divcomments','#myself#c.comments&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#qry_detail.detail.folder_id_r#');">#myFusebox.getApplicationData().defaults.trans("comments")# (#qry_comments_total#)</a></li>
			</cfif>
			<!--- Versions  --->
			<!--- attributes.folderaccess NEQ "R" AND condition removed for RAZ-2905 --->
			<cfif qry_detail.detail.link_kind EQ "" AND iif(isdate(qry_detail.detail.expiry_date) AND qry_detail.detail.expiry_date LT now(), false, true)>
				<cfif cs.tab_versions>
					<li><a href="##divversions" onclick="loadcontent('divversions','#myself#c.versions&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#attributes.folder_id#');">#myFusebox.getApplicationData().defaults.trans("versions_header")#</a></li>
				</cfif>
			</cfif>
			<!--- Sharing options should be hidden if asset has expired --->
			<cfif attributes.folderaccess NEQ "R" AND iif(isdate(qry_detail.detail.expiry_date) AND qry_detail.detail.expiry_date LT now(), false, true)>
				<cfif cs.tab_sharing_options>
					<li><a href="##shareoptions" onclick="loadcontent('shareoptions','#myself#c.share_options&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#myFusebox.getApplicationData().defaults.trans("tab_sharing_options")#</a></li>
				</cfif>
			</cfif>
			<!--- Hide these for R-groups --->
			<cfif attributes.folderaccess NEQ "R">
				<!--- History --->
				<cfif cs.tab_history>
					<li><a href="##history" onclick="loadcontent('history','#myself#c.log_history&id=#attributes.file_id#&folder_id=#attributes.folder_id#');">History</a></li>
				</cfif>
				<!--- Aliases'd --->
				<cfif qry_aliases.recordcount NEQ 0>
					<li><a href="##alias" onclick="loadcontent('alias','#myself#c.usage_alias&id=#attributes.file_id#&folder_id=#attributes.folder_id#');">Alias</a></li>
				</cfif>
				<!--- Plugin being shows with add_tab_detail_wx  --->
				<cfif structKeyExists(plwx,"pview")>
					<cfloop list="#plwx.pview#" delimiters="," index="i">
						#evaluate(i)#
					</cfloop>
				</cfif>
			</cfif>
		</ul>
		<!--- Info --->
		<div id="detailinfo">
			<!--- The Buttons --->
			<cfset what = "images">
			<cfinclude template="inc_detail_buttons.cfm" />
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<!--- Description when url is a link --->
				<cfif qry_detail.detail.link_kind NEQ "">
					<tr>
						<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("link_url_desc")#</strong></td>
					</tr>
				</cfif>
				<!--- If cloud url is empty --->
				<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND qry_detail.detail.cloud_url_org EQ "" AND qry_detail.detail.link_kind NEQ "url">
					<tr>
						<td colspan="3"><h2 style="color:red;">It looks like this file could not be added to the system properly. Please delete it and add it again!</h2></td>
					</tr>
				</cfif>
				<!--- URL to files --->
				<tr>
					<!--- show image according to extension --->
					<td align="center" style="padding-top:20px;padding-right:10px;" valign="top">
						<cfif qry_detail.detail.link_kind NEQ "url">
							<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
							<!--- </cfif> --->
							<cfif qry_detail.detail.link_kind NEQ "lan">
								<a href="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.si&f=#attributes.file_id#&v=p" target="_blank">
							</cfif>
							<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
								<img src="#qry_detail.detail.cloud_url#" border="0">
							<cfelse>
								<img src="#thestorage##qry_detail.detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.detail.thumb_extension#?#qry_detail.detail.hashtag#&#uniqueid#" border="0">
							</cfif>
							<cfif qry_detail.detail.link_kind NEQ "lan"></a></cfif>
							<cfif qry_detail.detail.link_kind NEQ "">
								<br />#qry_detail.detail.link_path_url#
								<br />#myFusebox.getApplicationData().defaults.trans("link_images_desc")#
							</cfif>
						<cfelse>
							<a href="#qry_detail.detail.link_path_url#" target="_blank" border="0"><img src="#qry_detail.detail.link_path_url#" border="0"></a><br /><a href="#qry_detail.detail.link_path_url#" target="_blank" border="0">#qry_detail.detail.link_path_url#</a>
						</cfif>
					</td>
					<td width="100%" valign="top" colspan="2" style="padding-top:20px;" valign="top">
						<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
							<!--- Filename --->
							<tr>
								<td width="1%" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("file_name")#</td>
								<td width="100%" nowrap="true"><input type="text" style="width:400px;" name="fname" id="fname" value="#qry_detail.detail.img_filename#" onchange="document.form#attributes.file_id#.file_name.value = document.form#attributes.file_id#.fname.value; <cfif prefs.set2_upc_enabled>if (!isNaN(document.form#attributes.file_id#.fname.value.substr(0,6))) {document.form#attributes.file_id#.img_upc.value = document.form#attributes.file_id#.fname.value.split('.')[0];}</cfif>"> <cfif cs.show_favorites_part><a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=img');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif></td>
							</tr>
							<!--- Description & Keywords --->
							<cfloop query="qry_langs">
								<cfif lang_id EQ 1>
									<cfset thisid = lang_id>
									<tr>
										<td valign="top" width="1%" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("description")#</td>
										<td ><textarea name="img_desc_#thisid#" id="img_desc_#thisid#" class="text" style="width:400px;height:60px;" <cfif cs.tab_metadata>onchange="document.form#attributes.file_id#.desc_#thisid#.value = document.form#attributes.file_id#.img_desc_#thisid#.value;
										<cfif qry_detail.detail.link_kind EQ ''>document.form#attributes.file_id#.iptc_content_description_#thisid#.value = document.form#attributes.file_id#.desc_#thisid#.value;</cfif>"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_description#</cfif></cfloop></textarea></td>
									</tr>
									<tr>
										<td valign="top" width="1%" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("keywords")#</td>
										<td><textarea name="img_keywords_#thisid#" id="img_keywords_#thisid#" class="text" style="width:400px;height:30px;" <cfif cs.tab_metadata>onchange="document.form#attributes.file_id#.keywords_#thisid#.value = document.form#attributes.file_id#.img_keywords_#thisid#.value;
										<cfif qry_detail.detail.link_kind EQ ''>document.form#attributes.file_id#.iptc_content_keywords_#thisid#.value = document.form#attributes.file_id#.img_keywords_#thisid#.value;</cfif>"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_keywords#</cfif></cfloop></textarea></td>
									</tr>
								</cfif>
							</cfloop>
							<!--- Labels --->
							<cfif cs.tab_labels>
								<tr>
									<td style="font-weight:bold;" valign="top">#myFusebox.getApplicationData().defaults.trans("labels")#</td>
									<td width="100%" colspan="5">
										<cfif attributes.folderaccess EQ "R">
											<cfloop query="attributes.thelabelsqry"><cfif ListFind(qry_labels,'#label_id#') NEQ 0><button class="awesome greylight small" onclick="return false;" disabled="disabled">#label_path#</button> </cfif></cfloop>
										<cfelse>
											<!--- RAZ-2207 Check Group/Users Permissions --->
											<cfset flag = 0>
											<cfif  qry_label_set.set2_labels_users EQ ''>
												<cfset flag=1>
											<cfelse>
												<cfif qry_GroupsOfUser.recordcount NEQ 0>
												<cfloop list = '#valuelist(qry_GroupsOfUser.grp_id)#' index="i" >
													<cfif listfindnocase(qry_label_set.set2_labels_users,i,',') OR listfindnocase(qry_label_set.set2_labels_users,session.theuserid,',')>
														<cfset flag=1>
													</cfif>
												</cfloop>
												<cfelse>
													<cfif listfindnocase(qry_label_set.set2_labels_users,session.theuserid,',')>
														<cfset flag = 1>
													</cfif>	
												</cfif>	
											</cfif>
											<cfif attributes.thelabelsqry.recordcount lte 200>
												<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_img" onchange="razaddlabels('tags_img','#attributes.file_id#','img');" multiple="multiple">
													<option value=""></option>
													<cfloop query="attributes.thelabelsqry">
														<option value="#label_id#"<cfif ListFind(qry_labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
													</cfloop>
												</select>
												<cfif flag EQ 1 OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
													<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false;"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
												</cfif>
											<cfelse>
												<!--- Label text area --->
												<div style="width:450px;">
													<div id="select_lables_#attributes.file_id#" class="labelContainer" style="float:left;width:400px;" >
														<cfloop query="attributes.thelabelsqry">
															<cfif ListFind(qry_labels,'#label_id#') NEQ 0>
															<div class='singleLabel' id="#label_id#">
																<span>#label_path#</span>
																<a class='labelRemove'  onclick="removeLabel('#attributes.file_id#','img', '#label_id#',this)" >X</a>
															</div>
															</cfif>
														</cfloop>
													</div>
													<cfif flag EQ 1 OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
														<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false;" style="float:left;"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
													</cfif>
													<!--- Select label button --->
													<br /><br /><a onclick="showwindow('#myself#c.select_label_popup&file_id=#attributes.file_id#&file_type=img&closewin=2','Choose Labels',600,2);return false;" href="##"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("select_labels")#</button></a>
												</div>
											</cfif>
										</cfif>
									</td>
								</tr>
							</cfif>
							<!--- Expiry date for asset--->
							<tr>
								<td width="1%" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("expiry_date")#</td>
								<td width="100%" nowrap="true"><input type="text" style="width:70px;" name="expiry_date" id="expiry_date" value="#dateformat(qry_detail.detail.expiry_date,'mm/dd/yyyy')#"></td>
							</tr>
							<!--- UPC Number --->
							<cfif prefs.set2_upc_enabled>
							<tr>
								<td width="1%" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("cs_img_upc_number")#</td>
								<td width="100%" nowrap="true"><input type="text" style="width:400px;" name="img_upc" id="img_upc" value="#qry_detail.detail.img_upc_number#"></td>
							</tr>
							</cfif>
							<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields >
								<!--- RAZ-2834 : Displays Custom field of All and Images --->
								<cfif (structKeyExists(cs,'customfield_all_metadata') AND cs.customfield_all_metadata NEQ '') OR (structKeyExists(cs,'customfield_images_metadata') AND cs.customfield_images_metadata NEQ '')>
									<tr>
										<td colspan="2"><cfinclude template="inc_custom_meta_fields.cfm"></td>	
									</tr>
								</cfif>
							</cfif>
							<tr>
								<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("file_size")#</td>
								<td><cfif qry_detail.detail.link_kind EQ "url">n/a<cfelse>#qry_detail.thesize# MB</cfif></td>
							</tr>
							<tr>
								<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("date_created")#</td>
								<td>#dateformat(qry_detail.detail.img_create_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
								<td valign="top">#dateformat(qry_detail.detail.img_change_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
							</tr>
							<tr>
								<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("located_in")#</td>
								<td nowrap="true" valign="top"><a href="##" onclick="loadcontent('rightside','index.cfm?fa=c.folder&col=F&folder_id=#qry_detail.detail.folder_id_r#');destroywindow(1);">#qry_detail.detail.folder_name#</a> <cfif cs.show_favorites_part><a href="" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#qry_detail.detail.folder_id_r#&favtype=folder&favkind=');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" style="padding-top:3px;" /></a></cfif></td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("created_by")#</td>
								<td valign="top" nowrap="nowrap">#qry_detail.detail.user_first_name# #qry_detail.detail.user_last_name#</td>
							</tr>
							<tr>
								<td nowrap="true" valign="top">ID</td>
								<td nowrap="true" valign="top" colspan="5">#attributes.file_id#</td>
							</tr>
						</table>
					</td>
				</tr>
				<cfif attributes.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
					<tr>
						<td><a href="##" onclick="showwindow('#myself#c.previewimage&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#','#myFusebox.getApplicationData().defaults.trans("header_preview_image")#',550,2);return false;">#myFusebox.getApplicationData().defaults.trans("header_preview_image_title")#</a> or <a href="##" onclick="recreatepreview();return false;">#myFusebox.getApplicationData().defaults.trans("header_preview_image_title_recreate")#</a></td>
					</tr>
				</cfif>
			</table>
			<!--- Submit Button --->
			<cfif attributes.folderaccess NEQ "R">
				<div style="float:right;padding:20px 0px 20px 0px;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
			<cfelse>
				<div style="float:right;padding:20px;"></div>
			</cfif>
		</div>
		<!--- Div for hidden window for recreating the thumbnail --->
		<div id="dialog-confirm-recreatepreview" style="display:none;">
			<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 100px 0;"></span>#myFusebox.getApplicationData().defaults.trans("header_preview_image_recreate_desc")#</p>
		</div>
		<!--- Convert Image --->
		<cfif qry_detail.detail.link_kind NEQ "url" AND cs.tab_convert_files AND iif(isdate(qry_detail.detail.expiry_date) AND qry_detail.detail.expiry_date LT now(), false, true)>
			<div id="convertt">
				<cfif session.hosttype EQ 0>
					<cfinclude template="dsp_host_upgrade.cfm">
				<cfelse>
					<cfinclude template="dsp_asset_images_convert.cfm">
				</cfif>
			</div>
		</cfif>
		<!--- Meta Data --->
		<cfif cs.tab_metadata>
			<div id="meta" class="collapsable">
				<!--- Description & Keywords --->
				<a href="##" onclick="$('##detaildesc').slideToggle('slow');return false;"><div class="headers">&gt; #myFusebox.getApplicationData().defaults.trans("asset_desc")#</div></a>
				<div id="detaildesc" style="padding-top:10px;">
					<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
						<!--- Filename --->
						<tr>
							<td width="1%" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("file_name")#</td>
							<td width="100%" nowrap="true">
								<input type="text" style="width:400px;" name="file_name" value="#qry_detail.detail.img_filename#" onchange="document.form#attributes.file_id#.fname.value = document.form#attributes.file_id#.file_name.value;"> <cfif cs.show_favorites_part><a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=img');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif>
							</td>
						</tr>
						<!--- Desc --->
						<cfloop query="qry_langs">
							<cfset thisid = lang_id>
							<tr>
								<td class="td2" valign="top" width="1%" nowrap="true"><strong><cfif qry_langs.recordcount NEQ 1>#lang_name#: </cfif>#myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
								<td class="td2" width="100%"><textarea name="<cfif lang_id NEQ 1>img_</cfif>desc_#thisid#" class="text" style="width:400px;height:50px;" <cfif lang_id EQ 1>onchange="<cfif qry_detail.detail.link_kind EQ ''>document.form#attributes.file_id#.iptc_content_description_#thisid#.value = document.form#attributes.file_id#.<cfif lang_id NEQ 1>img_</cfif>desc_#thisid#.value;</cfif>document.form#attributes.file_id#.img_desc_#thisid#.value = document.form#attributes.file_id#.<cfif lang_id NEQ 1>img_</cfif>desc_#thisid#.value"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_description#</cfif></cfloop></textarea></td>
							</tr>
							<tr>
								<td class="td2" valign="top" width="1%" nowrap="true"><strong><cfif qry_langs.recordcount NEQ 1>#lang_name#: </cfif>#myFusebox.getApplicationData().defaults.trans("keywords")#</strong></td>
								<td class="td2" width="100%"><textarea name="<cfif lang_id NEQ 1>img_</cfif>keywords_#thisid#" class="text" style="width:400px;height:50px;" <cfif lang_id EQ 1>onchange="<cfif qry_detail.detail.link_kind EQ ''>document.form#attributes.file_id#.iptc_content_keywords_#thisid#.value = document.form#attributes.file_id#.<cfif lang_id NEQ 1>img_</cfif>keywords_#thisid#.value;</cfif>document.form#attributes.file_id#.img_keywords_#thisid#.value = document.form#attributes.file_id#.<cfif lang_id NEQ 1>img_</cfif>keywords_#thisid#.value"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_keywords#</cfif></cfloop></textarea></td>
							</tr>
						</cfloop>
						<tr>
							<td class="td2"></td>
							<td class="td2">#myFusebox.getApplicationData().defaults.trans("comma_seperated")#</td>
						</tr>
					</table>
				</div>
				<div stlye="clear:both;"></div>
				<!--- Custom fields --->
				<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields>
					<br />
					<a href="##" onclick="$('##customfields').slideToggle('slow');return false;"><div class="headers">&gt; #myFusebox.getApplicationData().defaults.trans("custom_fields_asset")#</div></a>
					<div id="customfields" style="padding-top:10px;">
						<cfinclude template="inc_custom_fields.cfm">
					</div>
					<div stlye="clear:both;"></div>
				</cfif>
				<cfif qry_detail.detail.link_kind NEQ "url">
					<!--- XMP Description --->
					<cfif cs.tab_xmp_description>
						<br />
						<a href="##" onclick="$('##xmpdesc').slideToggle('slow');return false;"><div class="headers">&gt; XMP Description</div></a>
						<div id="xmpdesc" style="display:none;padding-top:10px;">
							<cfinclude template="dsp_asset_images_xmp.cfm">
						</div>
						<div stlye="clear:both;"></div>
					</cfif>
					<!--- IPTC Contact --->
					<cfif cs.tab_iptc_contact>
						<br />
						<a href="##" onclick="$('##iptccontact').slideToggle('slow');return false;"><div class="headers">&gt; IPTC Contact</div></a>
						<div id="iptccontact" style="display:none;padding-top:10px;">
							<cfinclude template="dsp_asset_images_iptc_contact.cfm">
						</div>
						<div stlye="clear:both;"></div>
					</cfif>
					<!--- IPTC Image --->
					<cfif cs.tab_iptc_image>
						<br />
						<a href="##" onclick="$('##iptcimage').slideToggle('slow');return false;"><div class="headers">&gt; IPTC Image</div></a>
						<div id="iptcimage" style="display:none;padding-top:10px;">
							<cfinclude template="dsp_asset_images_iptc_image.cfm">
						</div>
						<div stlye="clear:both;"></div>
					</cfif>
					<!--- IPTC Content --->
					<cfif cs.tab_iptc_content>
						<br />
						<a href="##" onclick="$('##iptccontent').slideToggle('slow');return false;"><div class="headers">&gt; IPTC Content</div></a>
						<div id="iptccontent" style="display:none;padding-top:10px;">
							<cfinclude template="dsp_asset_images_iptc_content.cfm">
						</div>
						<div stlye="clear:both;"></div>
					</cfif>
					<!--- IPTC Status --->
					<cfif cs.tab_iptc_status>
						<br />
						<a href="##" onclick="$('##iptcstatus').slideToggle('slow');return false;"><div class="headers">&gt; IPTC Status</div></a>
						<div id="iptcstatus" style="display:none;padding-top:10px;">
							<cfinclude template="dsp_asset_images_iptc_status.cfm">
						</div>
						<div stlye="clear:both;"></div>
					</cfif>
					<!--- Origin --->
					<cfif cs.tab_origin>
						<br />
						<a href="##" onclick="$('##origin').slideToggle('slow');return false;"><div class="headers">&gt; IPTC Origin</div></a>
						<div id="origin" style="display:none;padding-top:10px;">
							<cfinclude template="dsp_asset_images_origin.cfm">
						</div>
						<div stlye="clear:both;"></div>
					</cfif>
					<!--- Raw Metadata --->
					<br />
					<a href="##" onclick="$('##rawmetadata').slideToggle('slow');return false;"><div class="headers">&gt; Raw Metadata</div></a>
					<div id="rawmetadata" style="display:none;padding-top:10px;">
						<div style="height:400px;overflow:auto;">#ParagraphFormat(qry_detail.detail.img_meta)#</div>
					</div>
				</cfif>
				<!--- Submit Button --->
				<cfif attributes.folderaccess NEQ "R">
					<!--- copy metadata link --->
					<div style="float:left;padding-top:25px;">
						<button onclick="showwindow('#myself#c.copy_metaData&what=#attributes.what#&file_id=#attributes.file_id#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;" class="button">#myFusebox.getApplicationData().defaults.trans("copy_meta_data")#</button>
					</div>
					<div style="float:right;padding-top:25px;">
						<input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button">
					</div>
				</cfif>
			</div>
		</cfif>
		<!--- Comments --->
		<div id="divcomments"></div>
		<!--- VERSIONS --->
		<!--- attributes.folderaccess NEQ "R" AND condition removed for RAZ-2905 --->
		<cfif qry_detail.detail.link_kind NEQ "url">
			<div id="divversions"></div>
		</cfif>
		<!--- SHARING OPTIONS --->
		<cfif attributes.folderaccess NEQ "R">
			<div id="shareoptions"></div>
			<div id="history"></div>
			<div id="alias"></div>
			<!--- Plugin being shows with add_tab_detail_wx  --->
			<cfif structKeyExists(plwx,"pcfc")>
				<cfloop list="#plwx.pcfc#" delimiters="," index="i">
					<div id="#listlast(i,".")#"></div>
				</cfloop>
			</cfif>
		</cfif>
	</div>
	<!--- Submit Button --->
	<cfif attributes.folderaccess NEQ "R">
		<div id="updatefile" style="float:left;padding:10px;color:green;font-weight:bold;display:none;"></div>
	</cfif>
	</form>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
	jqtabs("tab_detail#attributes.file_id#");
	// Load renditions
	function loadren(){
		<cfif qry_detail.detail.link_kind NEQ "url">
			$('##relatedimages').load('#myself#c.images_detail_related&file_id=#attributes.file_id#&what=images&loaddiv=#attributes.loaddiv#&folder_id=#qry_detail.detail.folder_id_r#&s=#qry_detail.detail.shared#');
		</cfif>
		$('##additionalversions').load('#myself#c.av_load&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#');
		<cfif cs.tab_additional_renditions>
			$('##moreversions').load('#myself#c.adi_versions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');
		</cfif>
	}

	function formchecks()
	{
		<cfif cs.req_filename OR cs.req_description OR cs.req_keywords OR prefs.set2_upc_enabled>
			var reqfield = false;
			var isNumericField = false;
			var str = '';
			<cfif cs.req_filename>
				var val_filename = $('##fname').val();
				if (val_filename == '') reqfield = true;
			</cfif>
			<cfif cs.req_description>
				var val_desc = $('##img_desc_1').val();
				if (val_desc == '') reqfield = true;
			</cfif>
			<cfif cs.req_keywords>
				var val_keys = $('##img_keywords_1').val();
				if (val_keys == '') reqfield = true;
			</cfif>
			if (reqfield == true){
				str = str +'#myFusebox.getApplicationData().defaults.trans("req_fields_error")#\n';
			}
			// UPC number checks
			<cfif prefs.set2_upc_enabled AND qry_GroupsOfUser.recordcount NEQ 0 AND qry_GroupsOfUser.upc_size NEQ "">
				var val_upc = $('##img_upc').val();
				if(!$.isNumeric(val_upc) && val_upc!='') isNumericField = true;
			
				if(isNumericField == true){
					str = str +'Only numeric values are allowed in UPC\n';
				}
				else if (val_upc.trim() !='' && val_upc.length <6){
				 	str = str +'Incorrect UPC size. Please check UPC and try again.';
				 }
				// <cfif qry_GroupsOfUser.recordcount NEQ 0 AND qry_GroupsOfUser.upc_size NEQ "">
				// if ('#qry_GroupsOfUser.upc_size#' != val_upc.length && val_upc != ''){
				// 	str = str +'Enter the correct size of the UPC.The size of UPC is '+'#qry_GroupsOfUser.upc_size#';
				// }
				// </cfif>
			</cfif>
			if(str != ''){
				alert(str);
				return false;
			}
		</cfif>
		// Check expiry date is a valid date
		var expirydate= $('##expiry_date').val();
		if (expirydate !='')
		{
			var isdate = Date.parse(expirydate);
			if (isNaN(isdate)) {
			      alert('Please enter a valid expiry date.');
			      return false;
			}
		}
		return true;
	}
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
				$("##updatefile").html("#myFusebox.getApplicationData().defaults.trans("success")#");
				$("##updatefile").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
		   	}
		});
        return false; 
	}
	// Recreate window confirm dialog
	function recreatepreview(){
		$( "##dialog-confirm-recreatepreview" ).dialog({
			resizable: false,
			height:250,
			modal: true,
			buttons: {
				"#myFusebox.getApplicationData().defaults.trans("header_preview_image_recreate_button")#": function() {
					$( this ).dialog( "close" );
					$('##div_forall').load('#myself#c.recreatepreview&file_id=#attributes.file_id#-img&thetype=img');
				},
				Cancel: function() {
					$( this ).dialog( "close" );
				}
			}
		});
	};
	// Activate Chosen
	$(".chzn-select").chosen({search_contains: true});
	</script>
</cfoutput>
