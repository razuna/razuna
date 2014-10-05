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
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="file_id" value="#attributes.file_id#">
	<input type="hidden" name="thepath" value="#thisPath#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.file_name_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="link_kind" value="#qry_detail.detail.link_kind#">
	<input type="hidden" name="file_extension" value="#qry_detail.detail.file_extension#">
	<!--- Show next and back within detail view --->
	<cfinclude template="inc_detail_next_back.cfm">
	<!--- Format size --->
	<cfif isnumeric(qry_detail.thesize)><cfset qry_detail.thesize = numberformat(qry_detail.thesize,'_.__')></cfif>

	<!--- Show tabs --->
	<div id="tab_detail#file_id#">
		<ul>
			<li><a href="##detailinfo" onclick="loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&isdoc=yes');">#myFusebox.getApplicationData().defaults.trans("asset_information")#</a></li>
			<cfif cs.tab_metadata>
				<li><a href="##meta">Metadata</a></li>
			</cfif>
			<!--- Comments --->
			<cfif cs.tab_comments>
				<li><a href="##divcomments" onclick="loadcontent('divcomments','#myself#c.comments&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#qry_detail.detail.folder_id_r#');">#myFusebox.getApplicationData().defaults.trans("comments")# (#qry_comments_total#)</a></li>
			</cfif>
			<!--- VERSIONS --->
			<!--- attributes.folderaccess NEQ "R" AND condition removed for RAZ-2905 --->
			<!--- RAZ-549: Added in condition to not show renditions, versions and sharing tabs when asset has expired --->
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
				<cfif cs.tab_additional_renditions>
					<li><a href="##moreversions" onclick="loadcontent('moreversions','#myself#c.adi_versions&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#');">#myFusebox.getApplicationData().defaults.trans("adiver_header")#</a></li>
				</cfif>
			</cfif>
			<!--- Hide these for R-groups --->
			<cfif attributes.folderaccess NEQ "R">
				<cfif cs.tab_history>
					<li><a href="##history" onclick="loadcontent('history','#myself#c.log_history&id=#attributes.file_id#');">History</a></li>
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
			<cfset what = "files">
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
						<td colspan="2"><h2 style="color:red;">It looks like this file could not be added to the system properly. Please delete it and add it again!</h2></td>
					</tr>
				</cfif>
				<tr>
					<td width="1%" valign="top" style="padding-top:20px;padding-right:10px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<!--- show image according to extension --->
								<td align="center" style="padding-top:20px;width:400px;" valign="top">
									<!--- Show the thumbnail --->
									<cfset thethumb = replacenocase(qry_detail.detail.file_name_org, ".#qry_detail.detail.file_extension#", ".jpg", "all")>
									<cfif application.razuna.storage EQ "amazon" AND qry_detail.detail.cloud_url NEQ "">
										<img src="#qry_detail.detail.cloud_url#" border="0" img-tt="img-tt">
									<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#") >
										<img src="#cgi.context_path#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#?#uniqueid#" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png" width="128" height="128" border="0" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
									</cfif>

									<cfif qry_detail.detail.link_kind EQ "url">
										<br /><a href="#qry_detail.detail.link_path_url#" target="_blank">#qry_detail.detail.link_path_url#</a>
									<cfelseif qry_detail.detail.link_kind EQ "lan">
										<br />#qry_detail.detail.link_path_url#
									</cfif>
								</td>
								<td colspan="2" valign="top">
									<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
										<tr>
											<td colspan="2">
												<table>
													<tr>
														<td>
															<cfif application.razuna.storage EQ "amazon" AND qry_detail.detail.cloud_url NEQ "">
																<img src="#qry_detail.detail.cloud_url#" border="0" img-tt="img-tt" style="max-height:50px;max-width:100px;">
															<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#") >
																<img src="#cgi.context_path#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#?#uniqueid#" border="0" style="max-height:50px;max-width:100px;">
															<cfelse>
																<img src="#dynpath#/global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png" border="0" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'" style="max-height:50px;max-width:100px;">
															</cfif>
														</td>
														<td>
															<cfif attributes.folderaccess EQ "R" AND qry_share_options.asset_dl NEQ 1>
																<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> (not made available as download)<br />
																<cfif application.razuna.storage NEQ "amazon" AND qry_detail.detail.file_extension EQ "PDF" AND qry_detail.detail.link_kind NEQ "url"><a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sp&f=#file_id#" target="_blank">PDF as image(s)</a>
																</cfif>
															<cfelse>
																<cfif qry_detail.detail.link_kind NEQ "url">
																	<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong><br />
																	<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=doc" target="_blank" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
																	<cfif qry_detail.detail.shared EQ "F"><a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sf&f=#attributes.file_id#" target="_blank" style="padding-left:20px;"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.file_name_org#" target="_blank"></cfif>View</a> | 
																	<a href="##" onclick="toggleslide('divo#attributes.file_id#','inputo#attributes.file_id#');return false;">Direct Link</a>
																	<cfif application.razuna.storage NEQ "amazon" AND qry_detail.detail.file_extension EQ "PDF" AND qry_detail.detail.link_kind NEQ "url"> | <a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sp&f=#attributes.file_id#" target="_blank">PDF as image(s)</a>
																	</cfif>
																	<div id="divo#attributes.file_id#" style="display:none;width:450px;">
																		<input type="text" id="inputo#attributes.file_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.sf&f=#attributes.file_id#&v=o" />
																		<!--- Plugin --->
																		<cfset args = structNew()>
																		<cfset args.detail = qry_detail.detail>
																		<cfset args.thefiletype = "doc">
																		<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
																		<!--- Show plugin --->
																		<cfif structKeyExists(pl,"pview")>
																			<cfloop list="#pl.pview#" delimiters="," index="i">
																				<br />
																				#evaluate(i)#
																			</cfloop>
																		</cfif>
																	</div>
																<cfelse>
																	<a href="#qry_detail.detail.link_path_url#" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_to_original")#</a>
																</cfif>
															</cfif>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<!--- Show additional version --->
										<tr>
											<td colspan="2">
												<div id="additionalversions"></div>
												<br />
											</td>
										</tr>
										<!--- Filename --->
										<tr>
											<td width="1%" nowrap="true"><strong>#myFusebox.getApplicationData().defaults.trans("file_name")#</strong></td>
											<td width="100%"><input type="text" style="width:400px;" name="fname" id="fname" value="#qry_detail.detail.file_name#" onchange="document.form#attributes.file_id#.file_name.value = document.form#attributes.file_id#.fname.value;<cfif prefs.set2_upc_enabled>if (!isNaN(document.form#attributes.file_id#.fname.value.substr(0,6))) {document.form#attributes.file_id#.file_upc.value = document.form#attributes.file_id#.file_name.value.split('.')[0];}</cfif>"> <cfif cs.show_favorites_part><a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=doc');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif></td>
										</tr>
										<!--- Description & Keywords --->
										<cfloop query="qry_langs">
											<cfif lang_id EQ 1>
												<cfset thisid = lang_id>
												<tr>
													<td valign="top" width="1%" nowrap="true"><strong>#myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
													<td width="100%"><textarea name="file_desc_#thisid#" id="file_desc_#thisid#" class="text" style="width:400px;height:60px;" <cfif cs.tab_metadata>onchange="document.form#attributes.file_id#.desc_#thisid#.value = document.form#attributes.file_id#.file_desc_#thisid#.value;"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_desc#</cfif></cfloop></textarea></td>
												</tr>
												<tr>
													<td valign="top" width="1%" nowrap="true"><strong>#myFusebox.getApplicationData().defaults.trans("keywords")#</strong></td>
													<td width="100%"><textarea name="file_keywords_#thisid#" id="file_keywords_#thisid#" class="text" style="width:400px;height:30px;" <cfif cs.tab_metadata>onchange="document.form#attributes.file_id#.keywords_#thisid#.value = document.form#attributes.file_id#.file_keywords_#thisid#.value;"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_keywords#</cfif></cfloop></textarea></td>
												</tr>
											</cfif>
										</cfloop>
										<!--- Labels --->
										<cfif cs.tab_labels>
											<tr>
												<td valign="top"><strong>#myFusebox.getApplicationData().defaults.trans("labels")#</strong></td>
												<td width="100%">
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
															<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_doc" onchange="razaddlabels('tags_doc','#attributes.file_id#','doc');" multiple="multiple">
															<option value=""></option>
															<cfloop query="attributes.thelabelsqry">
																<option value="#label_id#"<cfif ListFind(qry_labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
															</cfloop>
															</select>
															<cfif  flag EQ 1 OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
																<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
															</cfif>
														<cfelse>
															<!--- Label text area --->
															<div style="width:450px;">
																<div id="select_lables_#attributes.file_id#" class="labelContainer" style="float:left;width:400px;" >
																	<cfloop query="attributes.thelabelsqry">
																		<cfif ListFind(qry_labels,'#label_id#') NEQ 0>
																		<div class='singleLabel' id="#label_id#">
																			<span>#label_path#</span>
																			<a class='labelRemove'  onclick="removeLabel('#attributes.file_id#','doc', '#label_id#',this)" >X</a>
																		</div>
																		</cfif>
																	</cfloop>
																</div>
																
																<cfif flag EQ 1 OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
																	<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false" style="float:left;"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
																</cfif>
																<!--- Select label button --->
																<br /><br /><a onclick="showwindow('#myself#c.select_label_popup&file_id=#attributes.file_id#&file_type=doc&closewin=2','Choose Labels',600,2);return false;" href="##"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("select_labels")#</button></a>
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
											<td width="1%" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("cs_file_upc_number")#</td>
											<td width="100%" nowrap="true"><input type="text" style="width:400px;" name="file_upc" id="file_upc" value="#qry_detail.detail.file_upc_number#" ></td>
										</tr>
										</cfif>
										<cfif qry_cf.recordcount NEQ 0 AND cs.tab_custom_fields>
											<!--- RAZ-2834: Displays Custom field of files--->
											<cfif (structKeyExists(cs,'customfield_all_metadata') AND cs.customfield_all_metadata NEQ '') OR (structKeyExists(cs,'customfield_files_metadata') AND cs.customfield_files_metadata NEQ '')>
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
											<td>#dateformat(qry_detail.detail.file_create_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
										</tr>
										<tr>
											<td nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("date_changed")#</td>
											<td valign="top">#dateformat(qry_detail.detail.file_change_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
										</tr>
										<tr>
											<td nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("located_in")#</td>
											<td valign="top"><a href="##" onclick="loadcontent('rightside','index.cfm?fa=c.folder&col=F&folder_id=#qry_detail.detail.folder_id_r#');destroywindow(1);">#qry_detail.detail.folder_name#</a> <cfif cs.show_favorites_part><a href="" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#qry_detail.detail.folder_id_r#&favtype=folder&favkind=');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif></td>
										</tr>
										<tr>
											<td nowrap="true" valign="top">#myFusebox.getApplicationData().defaults.trans("created_by")#</td>
											<td valign="top" nowrap="nowrap">#qry_detail.detail.user_first_name# #qry_detail.detail.user_last_name#</td>
										</tr>
										<tr>
											<td nowrap="true" valign="top">ID</td>
											<td  nowrap="true" valign="top" colspan="5">#attributes.file_id#</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<cfif attributes.folderaccess NEQ "R" AND qry_detail.detail.link_kind NEQ "url">
					<tr>
						<td><a href="##" onclick="showwindow('#myself#c.previewimage&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.cf_show#','#myFusebox.getApplicationData().defaults.trans("header_preview_image")#',550,2);return false;">#myFusebox.getApplicationData().defaults.trans("header_preview_image_title")#</a></td>
					</tr>
				</cfif>
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
		<!--- Meta Data --->
		<cfif cs.tab_metadata>
			<div id="meta" class="collapsable">
				<!--- Description & Keywords --->
				<a href="##" onclick="$('##detaildesc').slideToggle('slow');return false;"><div class="headers">&gt; #myFusebox.getApplicationData().defaults.trans("asset_desc")#</div></a>
					<div id="detaildesc" style="padding-top:10px;">
						<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
							<tr>
								<td>
									<div style="float:left;">
										<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
											<!--- Filename --->
											<tr>
												<td width="1%" nowrap="true"><strong>#myFusebox.getApplicationData().defaults.trans("file_name")#</strong></td>
												<td width="100%"><input type="text" style="width:280px;" name="file_name" value="#qry_detail.detail.file_name#" onchange="document.form#attributes.file_id#.fname.value = document.form#attributes.file_id#.file_name.value;"> <cfif cs.show_favorites_part><a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=doc');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif>
												</td>
											</tr>
											<cfloop query="qry_langs">
												<cfset thisid = lang_id>
												<tr>
													<td class="td2" valign="top" width="1%" nowrap="true"><strong><cfif qry_langs.recordcount NEQ 1>#lang_name#: </cfif>#myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
													<td class="td2" width="100%"><textarea name="<cfif lang_id NEQ 1>file_</cfif>desc_#thisid#" class="text" style="width:300px;height:40px;" <cfif lang_id EQ 1>onchange="document.form#attributes.file_id#.file_desc_#thisid#.value = document.form#attributes.file_id#.desc_#thisid#.value;"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_desc#</cfif></cfloop></textarea></td>
												</tr>
												<tr>
													<td class="td2" valign="top" width="1%" nowrap="true"><strong><cfif qry_langs.recordcount NEQ 1>#lang_name#: </cfif>#myFusebox.getApplicationData().defaults.trans("keywords")#</strong></td>
													<td class="td2" width="100%"><textarea name="<cfif lang_id NEQ 1>file_</cfif>keywords_#thisid#" class="text" style="width:300px;height:40px;" <cfif lang_id EQ 1>onchange="document.form#attributes.file_id#.file_keywords_#thisid#.value = document.form#attributes.file_id#.keywords_#thisid#.value;"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_keywords#</cfif></cfloop></textarea></td>
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
				<!--- Raw Metadata --->
				<cfif qry_detail.detail.link_kind NEQ "url">
					<br />
					<a href="##" onclick="$('##rawmetadata').slideToggle('slow');return false;"><div class="headers">&gt; Raw Metadata</div></a>
					<div id="rawmetadata" style="display:none;padding-top:10px;">
						<div style="height:400px;overflow:auto;">#ParagraphFormat(qry_detail.detail.file_meta)#</div>
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
		
			<!--- VERSIONS --->
			<div id="divversions"></div>

		<cfif attributes.folderaccess NEQ "R">
			<!--- SHARING OPTIONS --->
			<div id="shareoptions"></div>
			<div id="moreversions"></div>
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
	<cfif attributes.folderaccess NEQ "R">
		<div id="updatefile" style="float:left;padding:10px;color:green;font-weight:bold;display:none;"></div>
	</cfif>
	</form>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
	// Initialize Tabs
	jqtabs("tab_detail#file_id#");
	$('##additionalversions').load('#myself#c.av_load&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&isdoc=yes');
	
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
				var val_desc = $('##file_desc_1').val();
				if (val_desc == '') reqfield = true;
			</cfif>
			<cfif cs.req_keywords>
				var val_keys = $('##file_keywords_1').val();
				if (val_keys == '') reqfield = true;
			</cfif>
			if (reqfield == true){
				str = str +'#myFusebox.getApplicationData().defaults.trans("req_fields_error")#\n';
			}
			// UPC number checks
			<cfif prefs.set2_upc_enabled AND qry_GroupsOfUser.recordcount NEQ 0 AND qry_GroupsOfUser.upc_size NEQ "">
				var val_upc = $('##file_upc').val();
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
	};
	// Activate Chosen
	$(".chzn-select").chosen({search_contains: true});
	</script>
</cfoutput>
