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
			<li><a href="##detailinfo" onclick="loadcontent('additionalversions','#myself#c.av_load&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#');">#myFusebox.getApplicationData().defaults.trans("asset_information")#</a></li>
			<cfif cs.tab_metadata>
				<li><a href="##meta">Metadata</a></li>
			</cfif>
			<!--- Comments --->
			<cfif cs.tab_comments>
				<li><a href="##divcomments" onclick="loadcontent('divcomments','#myself#c.comments&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#qry_detail.detail.folder_id_r#');">#myFusebox.getApplicationData().defaults.trans("comments")# (#qry_comments_total#)</a></li>
			</cfif>
			<cfif attributes.folderaccess NEQ "R" AND qry_detail.detail.link_kind EQ "">
				<cfif cs.tab_versions>
					<li><a href="##divversions" onclick="loadcontent('divversions','#myself#c.versions&file_id=#attributes.file_id#&type=#attributes.cf_show#&folder_id=#attributes.folder_id#');">#myFusebox.getApplicationData().defaults.trans("versions_header")#</a></li>
				</cfif>
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
					<td width="1%" nowrap="true" valign="top" style="padding-top:20px;padding-right:10px;">
						<table border="0" width="100%" cellpadding="0" cellspacing="0">
							<tr>
								<!--- show image according to extension --->
								<td align="center" style="padding-top:20px;width:400px;" valign="top">
									<!--- If it is a PDF we show the thumbnail --->
									<cfif application.razuna.storage EQ "nirvanix" AND (qry_detail.detail.file_extension EQ "PDF" OR qry_detail.detail.file_extension EQ "indd")>
										<img src="#qry_detail.detail.cloud_url#" border="0">
									<cfelseif application.razuna.storage EQ "local" AND (qry_detail.detail.file_extension EQ "PDF" OR qry_detail.detail.file_extension EQ "indd")>
										<cfset thethumb = replacenocase(qry_detail.detail.file_name_org, ".#qry_detail.detail.file_extension#", ".jpg", "all")>
										<cfif FileExists("#attributes.assetpath#/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#") IS "no">
											<img src="#dynpath#/global/host/dam/images/icons/icon_#qry_detail.detail.file_extension#.png" border="0">
										<cfelse>
											<img src="#cgi.context_path#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#thethumb#" border="0">
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
								<td colspan="2" valign="top">
									<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
										<tr>
											<td colspan="2">
												<cfif attributes.folderaccess EQ "R">
													<strong>Original</strong> (not made available as download)<br />
													<cfif application.razuna.storage NEQ "amazon" AND qry_detail.detail.file_extension EQ "PDF" AND qry_detail.detail.link_kind NEQ "url"><a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sp&f=#file_id#" target="_blank">PDF as image(s)</a>
													</cfif>
												<cfelse>
													<cfif qry_detail.detail.link_kind NEQ "url">
														<strong>Original</strong><br />
														<cfif qry_detail.detail.shared EQ "F"><a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sf&f=#attributes.file_id#" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.file_name_org#" target="_blank"></cfif>View</a> | <a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=doc" target="_blank">Download</a> | 
														<a href="##" onclick="toggleslide('divo#attributes.file_id#','inputo#attributes.file_id#');return false;">Direct Link</a>
														<cfif application.razuna.storage NEQ "amazon" AND qry_detail.detail.file_extension EQ "PDF" AND qry_detail.detail.link_kind NEQ "url"> | <a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sp&f=#file_id#" target="_blank">PDF as image(s)</a>
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
												<br />
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
											<td width="100%"><input type="text" style="width:400px;" name="fname" value="#qry_detail.detail.file_name#" onchange="document.form#attributes.file_id#.file_name.value = document.form#attributes.file_id#.fname.value;"> <cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=doc');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif></td>
										</tr>
										<!--- Description & Keywords --->
										<cfloop query="qry_langs">
											<cfif lang_id EQ 1>
												<cfset thisid = lang_id>
												<tr>
													<td valign="top" width="1%" nowrap="true"><strong>#myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
													<td width="100%"><textarea name="file_desc_#thisid#" class="text" style="width:400px;height:30px;" <cfif cs.tab_metadata>onchange="document.form#attributes.file_id#.desc_#thisid#.value = document.form#attributes.file_id#.file_desc_#thisid#.value;"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_desc#</cfif></cfloop></textarea></td>
												</tr>
												<tr>
													<td valign="top" width="1%" nowrap="true"><strong>#myFusebox.getApplicationData().defaults.trans("keywords")#</strong></td>
													<td width="100%"><textarea name="file_keywords_#thisid#" class="text" style="width:400px;height:30px;" <cfif cs.tab_metadata>onchange="document.form#attributes.file_id#.keywords_#thisid#.value = document.form#attributes.file_id#.file_keywords_#thisid#.value;"</cfif>><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#file_keywords#</cfif></cfloop></textarea></td>
												</tr>
											</cfif>
										</cfloop>
										<!--- Labels --->
										<cfif cs.tab_labels>
											<tr>
												<td><strong>#myFusebox.getApplicationData().defaults.trans("labels")#</strong></td>
												<td width="100%" nowrap="true">
													<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_doc" onchange="razaddlabels('tags_doc','#attributes.file_id#','doc');" multiple="multiple">
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
											<td valign="top">#qry_detail.detail.folder_name# <cfif cs.show_bottom_part><a href="" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#qry_detail.detail.folder_id_r#&favtype=folder&favkind=');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif></td>
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
												<td width="100%"><input type="text" style="width:280px;" name="file_name" value="#qry_detail.detail.file_name#" onchange="document.form#attributes.file_id#.fname.value = document.form#attributes.file_id#.file_name.value;"> <cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropfav','#myself##xfa.tofavorites#&favid=#attributes.file_id#&favtype=file&favkind=doc');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a></cfif>
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
						<textarea class="text" style="width:700px;height:400px;">#qry_detail.detail.file_meta#</textarea>
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
		<cfif attributes.folderaccess NEQ "R">
			<!--- VERSIONS --->
			<div id="divversions"></div>
			<!--- SHARING OPTIONS --->
			<div id="shareoptions"></div>
			<div id="moreversions"></div>
			<div id="history"></div>
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
		$('##additionalversions').load('#myself#c.av_load&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#');
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
		$(".chzn-select").chosen();
	</script>
</cfoutput>