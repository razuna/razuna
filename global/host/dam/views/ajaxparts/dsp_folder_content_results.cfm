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
<cfif session.is_system_admin OR session.is_administrator>
	<cfset isadmin = true>
<cfelse>
	<cfset isadmin = false>
</cfif>
<cfoutput>
	<cfset uniqueid = createuuid()>
	<!--- Set count for UPC or not --->
	<cfif structKeyExists(qry_files,"searchcount")>
		<cfset _count = qry_files.searchcount>
	<!--- <cfelseif structKeyExists(qry_files,"qall") AND isQuery(qry_files.qall)>
		<cfset _count = qry_files.qall.recordcount> --->
	<cfelse>
		<cfset _count = attributes.qry_filecount>
	</cfif>
	<cfif _count LTE session.rowmaxpage>
		<cfset session.offset = 0>
	</cfif>
	<!--- Div decider for below --->
	<cfif attributes.folder_id EQ 0>
		<cfset attributes.thediv = "content_search_#attributes.thetype#">
	<cfelse>
		<cfset attributes.thediv = "content_search_all">
	</cfif>
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- If no record is in this folder --->
	<cfif _count EQ 0>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<td>
					<div style="float:left;color:red;font-weight:bold;">No assets found!</div>
					<div style="float:left;padding-left:10px;"><cfif session.fromshare><a href="#cgi.http_referer#">Go back to the share</cfif></div>
				</td>
			</tr>
		</table>
	<!--- Show content of this folder --->
	<cfelse>
		<cfif structkeyexists(attributes,"share") AND attributes.share EQ "T">
			<div id="#attributes.thediv#">
		</cfif>
		<form name="searchform#attributes.thetype#" id="searchform#attributes.thetype#" action="#self#">
		<input type="hidden" name="thetype" value="all">
		<input type="hidden" name="#theaction#" value="c.folder_combined_save">
		<!--- Set count for UPC or not --->
		<!--- <cfif structKeyExists(qry_files,"listid")>
			<input type="hidden" name="listids" id="searchlistids" value="#valuelist(qry_files.listid)#">
		<cfelse>
			<input type="hidden" name="listids" id="searchlistids" value="#valuelist(qry_files.qall.listid)#">
		</cfif> --->
		<input type="hidden" name="listids" id="searchlistids" value="#session.search.search_file_ids#">
		<input type="hidden" name="editids" id="editids" value="#session.search.edit_ids#">
		<input type="hidden" name="folder_id" id="folder_id" value="#attributes.folder_id#">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<!--- Header --->
		<cfif attributes.folder_id NEQ 0>
			<tr>
				<th colspan="6">
					<!--- Show notification of folder is being shared --->
					<cfinclude template="inc_folder_header.cfm">
					<!--- Folder Navigation (add file/tools/view) --->
					<div style="float:right;">
						<div style="float:right;padding-top:3px;">
							<!---<div style="float:left;" id="tooltip">
								<a href="##" onclick="loadviewsearch('');return false;" title="Thumbnail View"><img src="#dynpath#/global/host/dam/images/view-list-icons.png" border="0" width="24" height="24"></a>
								<a href="##" onclick="loadviewsearch('list');return false;" title="List View"><img src="#dynpath#/global/host/dam/images/view-list-text-3.png" border="0" width="24" height="24"></a>
								<a href="##" onclick="loadviewsearch('combined');return false;" title="Combined/Quick Edit View"><img src="#dynpath#/global/host/dam/images/view-list-details-4.png" border="0" width="24" height="24"></a>
							</div>--->
						</div>
						<script type="text/javascript">
							function loadviewsearch(theview){
								
								// Show loading bar
								$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
								<cfif !structKeyExists(attributes,'search_upc')>
									$('###attributes.thediv#').load('#myself#c.search_simple', { view: theview, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "view">#lcase(i)#:"#evaluate(i)#", </cfif></cfloop> }, function(){
										$("##bodyoverlay").remove();
									});
								</cfif>
							}
						</script>
					</div>
				</th>
			</tr>
		</cfif>
		
		<!--- Icon Bar --->
		<tr>
			<td colspan="6" style="border:0px;"><cfinclude template="dsp_icon_bar_search.cfm"></td>
		</tr>
	
		<!--- Thumbnail --->
		<cfset mysqloffset = session.offset * session.rowmaxpage>
		<!--- If we come from UPC we have another query object (duh?) --->
		<cfif structKeyExists(qry_files,"qall") AND isQuery(qry_files.qall)>
			<cfset the_query = qry_files.qall>
		<cfelse>
			<cfset the_query = qry_files>
		</cfif>
		<!--- <cfdump var="#the_query#"> --->
		<cfif session.view EQ "">
			<tr>
				<td style="border:0px;">
					<div class="grid-masonry">
						<cfoutput query="the_query">
							<cfif groupid NEQ "">
								<cfset theid = groupid>
							<cfelse>
								<cfset theid = id>
							</cfif>
							<!--- Images --->
							<cfif kind EQ "img">
								<div class="assetbox grid-masonry-item" id="#theid#-#kind##iif(isalias EQ 1,de('_alias'),de(''))#">
									<cfif is_available>
										<div id="draggable-s#theid#-#kind#" type="#theid#-#kind#" class="theimg">
											<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#theid#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
												<!--- Show assets --->
												<cfif link_kind NEQ "url">
													<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
														<cfif cloud_url NEQ "">
															<img src="#cloud_url#" border="0" img-tt="img-tt">
														<cfelse>
															<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
														</cfif>
													<cfelse>
														<!--- Check if filename format follows UPC renditions naming and if thumb exists for it --->
														<cfif refind('\.[0-9]',filename) AND !fileexists("#thestorage##path_to_asset#/thumb_#theid#.#ext#")>
															<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#?_v=#hashtag#" border="0" img-tt="img-tt">
														<cfelse>
															<img src="#thestorage##path_to_asset#/thumb_#theid#.#ext#?_v=#hashtag#" border="0" img-tt="img-tt">
														</cfif>
													</cfif>
												<cfelse>
													<img src="#link_path_url#" border="0" style="max-width=400px;" img-tt="img-tt">
												</cfif>
											</a>
										</div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											</a>
										</cfif>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<div style="float:left;padding:6px 0px 3px 0px;">
												<input type="checkbox" name="file_id" value="#theid#-img" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#theid#-img") NEQ 0> checked="checked"</cfif>>
											</div>
											<div style="float:right;padding:6px 0px 0px 0px;">
												<div id="iconbar_search_#uniqueid#_#id#" style="display:inline">
													<cfif permfolder EQ "R" OR permfolder EQ "n">
														<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
													</cfif>
													<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#theid#&kind=img&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
													<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#theid#-img&thetype=#theid#-img');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
													<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
														<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#theid#&thetype=img','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',700,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
													</cfif>
													<cfif cs.show_favorites_part>
														<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#theid#&favtype=file&favkind=img');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_favorite")#');return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
													</cfif>
												</div>
												<cfif permfolder NEQ "R">
													<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
														<cfif isalias>
															<a href="##" onclick="storeone('#theid#-img');showwindow('#myself#ajax.trash_alias&id=#theid#&what=images&loaddiv=search&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("alias_remove_button"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("alias_remove_button")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														<cfelse>
															<a href="##" onclick="storeone('#theid#-img');showwindow('#myself#ajax.trash_record&id=#theid#&what=images&loaddiv=search&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														</cfif>
													</cfif>
												</cfif>
											</div>
										</cfif>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "T">
											<cfif cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<div>
													<a href="##" onclick="loadcontent('loaddummy','#myself#c.basket_put_include&file_id=#theid#-img&thetype=#theid#-img&jsessionid=#session.SessionID#');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
												</div>
											</cfif>
										</cfif>
										<div style="clear:left;"></div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<!--- custom metadata fields to show --->
											<cfif attributes.cs.images_metadata EQ "" OR ( NOT prefs.set2_upc_enabled AND attributes.cs.images_metadata EQ "img_upc_number AS cs_img_upc_number" )>
												<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#theid#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,30)#</strong></a>
											<cfelse>
												<br />
												<cfloop list="#attributes.cs_place.bottom.image#" index="m" delimiters=",">
													<cfif m CONTAINS "_filename">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#theid#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(evaluate(listlast(m," ")),150)#</strong></a>
													<cfelseif m CONTAINS "_size">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#myFusebox.getApplicationData().global.converttomb('#left(evaluate(listlast(m," ")),150)#')# MB
													<cfelseif m CONTAINS "_time">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
													<cfelseif m CONTAINS "expiry_date">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
													<cfelse>
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#left(evaluate(listlast(m," ")),150)#
													</cfif>
													<br />
												</cfloop>
											</cfif>
										<cfelse>
											<strong>#left(filename,50)#</strong>
										</cfif>
										<cfif isalias>
											<div style="float:right">
												<em>(Alias)</em>
											</div>
											<div style="clear:both;"></div>
										</cfif>
										<cfif ! session.fromshare>
											<br>
											<br>
											<cfset folderpath = "">
											<cfset crumbs = myFusebox.getApplicationData().folders.getbreadcrumb(folder_id_r)>
											<cfloop list="#crumbs#" delimiters=";" index="i">
												<cfset flid = ListGetAt(i,2,'|')>
												<cfset folderpath = folderpath & " / <a href='##' onclick=goToFolder('#flid#');>#ListGetAt(i,1,'|')#</a>">
											</cfloop>
											Folder: #replace(folderpath,'/','','ONE')#
										</cfif>
									<cfelse>
										The upload of "#filename#" is still in progress!
										<br /><br>
										#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
										#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<br><br>
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#theid#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
									</cfif>
								</div>
							<!--- Videos --->
							<cfelseif kind EQ "vid">
								<div class="assetbox grid-masonry-item" id="#theid#-#kind##iif(isalias EQ 1,de('_alias'),de(''))#">
									<cfif is_available>
										<script type="text/javascript">
										$(function() {
											$("##draggable-s#theid#-#kind#").draggable({
												appendTo: 'body',
												cursor: 'move',
												addClasses: false,
												iframeFix: true,
												opacity: 0.25,
												zIndex: 6,
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
											<cfif isdate(expiry_date_actual) AND expiry_date_actual LT now()>
												$('##iconbar_search_#uniqueid#_#id#').css('display','none');
											</cfif>
										});
										</script>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<cfloop list="#attributes.cs_place.top.video#" index="m" delimiters=",">
												<cfif m CONTAINS "_filename">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#theid#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
												<cfelseif m CONTAINS "_size">
													<cfif evaluate(listlast(m," ")) NEQ "">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#myFusebox.getApplicationData().global.converttomb('#left(evaluate(listlast(m," ")),150)#')# MB
													</cfif>
												<cfelseif m CONTAINS "_time">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
												<cfelseif m CONTAINS "expiry_date">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
												<cfelse>
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#left(evaluate(listlast(m," ")),150)#
												</cfif>
												<br />
											</cfloop>
											<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#theid#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
										</cfif>
										<div id="draggable-s#theid#-#kind#" type="#theid#-#kind#" class="theimg">
											<cfif link_kind NEQ "url">
												<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
													<cfif cloud_url NEQ "">
														<img src="#cloud_url#" border="0">
													<cfelse>
														<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
													</cfif>
												<cfelse>
													<img src="#thestorage##path_to_asset#/#filename_org#" border="0">
												</cfif>
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
											</cfif>
										</div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											</a>
										</cfif>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<div style="float:left;padding:6px 0px 3px 0px;">
												<input type="checkbox" name="file_id" value="#theid#-vid" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#theid#-vid") NEQ 0> checked="checked"</cfif>>
											</div>
											<div style="float:right;padding:6px 0px 0px 0px;">
												<div id="iconbar_search_#uniqueid#_#id#" style="display:inline">
													<cfif permfolder EQ "R" OR permfolder EQ "n">
														<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
													</cfif>
													<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#theid#&kind=vid&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
													<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#theid#-vid&thetype=#theid#-vid');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
													<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
														<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#theid#&thetype=vid','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',700,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
													</cfif>
													<cfif cs.show_favorites_part>
														<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#theid#&favtype=file&favkind=vid');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_favorite")#');return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
													</cfif>
													
												</div>
												<cfif permfolder NEQ "R">
													<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>

														<!--- If alias the remove is different --->
														<cfif isalias>
															<a href="##" onclick="storeone('#theid#-vid');showwindow('#myself#ajax.trash_alias&id=#theid#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("alias_remove_button"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("alias_remove_button")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														<cfelse>

															<a href="##" onclick="storeone('#theid#-vid');showwindow('#myself#ajax.trash_record&id=#theid#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														</cfif>
													</cfif>
												</cfif>
											</div>
										</cfif>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "T">
											<cfif cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<div>
													<a href="##" onclick="loadcontent('loaddummy','#myself#c.basket_put_include&file_id=#theid#-vid&thetype=#theid#-vid&jsessionid=#session.SessionID#');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
												</div>
											</cfif>
										</cfif>
										<div style="clear:left;"></div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<!--- custom metadata fields to show --->
											<cfif attributes.cs.videos_metadata EQ "" OR ( NOT prefs.set2_upc_enabled AND attributes.cs.videos_metadata EQ "vid_upc_number AS cs_vid_upc_number")>
												<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#theid#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
											<cfelse>
												<br />
												<cfloop list="#attributes.cs_place.bottom.video#" index="m" delimiters=",">
													<cfif m CONTAINS "_filename">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#theid#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
													<cfelseif m CONTAINS "_size">
														<cfif evaluate(listlast(m," ")) NEQ "">
															<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
															#myFusebox.getApplicationData().global.converttomb('#left(evaluate(listlast(m," ")),150)#')# MB
														</cfif>
													<cfelseif m CONTAINS "_time">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
													<cfelseif m CONTAINS "expiry_date">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
													<cfelse>
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#left(evaluate(listlast(m," ")),150)#
													</cfif>
													<br />
												</cfloop>
											</cfif>
										<cfelse>
											<strong>#left(filename,50)#</strong>
										</cfif>
										<cfif isalias>
											<div style="float:right">
												<em>(Alias)</em>
											</div>
											<div style="clear:both;"></div>
										</cfif>
										<cfif ! session.fromshare>
											<br>
											<br>
											<cfset folderpath = "">
											<cfset crumbs = myFusebox.getApplicationData().folders.getbreadcrumb(folder_id_r)>
											<cfloop list="#crumbs#" delimiters=";" index="i">
												<cfset flid = ListGetAt(i,2,'|')>
												<cfset folderpath = folderpath & " / <a href='##' onclick=goToFolder('#flid#');>#ListGetAt(i,1,'|')#</a>">
											</cfloop>
											Folder: #replace(folderpath,'/','','ONE')#
										</cfif>
									<cfelse>					
										The upload of "#filename#" is still in progress!
										<br /><br>
										#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
										#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<br><br>
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#theid#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
									</cfif>
								</div>
							<!--- Audios --->
							<cfelseif kind EQ "aud">
								<div class="assetbox grid-masonry-item" id="#theid#-#kind##iif(isalias EQ 1,de('_alias'),de(''))#">
									<cfif is_available>
										<script type="text/javascript">
										$(function() {
											$("##draggable-s#theid#-#kind#").draggable({
												appendTo: 'body',
												cursor: 'move',
												addClasses: false,
												iframeFix: true,
												opacity: 0.25,
												zIndex: 6,
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
											<cfif isdate(expiry_date_actual) AND expiry_date_actual LT now()>
												$('##iconbar_search_#uniqueid#_#id#').css('display','none');
											</cfif>
										});
										</script>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<cfloop list="#attributes.cs_place.top.audio#" index="m" delimiters=",">
												<cfif m CONTAINS "_filename">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#theid#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
												<cfelseif m CONTAINS "_size">
													<cfif evaluate(listlast(m," ")) NEQ "">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#myFusebox.getApplicationData().global.converttomb('#left(evaluate(listlast(m," ")),150)#')# MB
													</cfif>
												<cfelseif m CONTAINS "_time">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
												<cfelseif m CONTAINS "expiry_date">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
												<cfelse>
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#left(evaluate(listlast(m," ")),150)#
												</cfif>
												<br />
											</cfloop>
											<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#theid#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
										</cfif>
										<div id="draggable-s#theid#-#kind#" type="#theid#-#kind#" class="theimg">
											<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0">
										</div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											</a>
										</cfif>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<div style="float:left;padding:6px 0px 3px 0px;">
												<input type="checkbox" name="file_id" value="#theid#-aud" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#theid#-aud") NEQ 0> checked="checked"</cfif>>
											</div>
											<div style="float:right;padding:6px 0px 0px 0px;">
												<div id="iconbar_search_#uniqueid#_#id#" style="display:inline">
													<cfif permfolder EQ "R" OR permfolder EQ "n">
														<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
													</cfif>
													<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#theid#&kind=aud&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
													<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#theid#-aud&thetype=#theid#-aud');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
													<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
														<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#theid#&thetype=aud','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',700,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
													</cfif>
													<cfif cs.show_favorites_part>
														<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#theid#&favtype=file&favkind=aud');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_favorite")#');return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
													</cfif>
													
												</div>
												<cfif permfolder NEQ "R">
													<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
														<cfif isalias>
															<a href="##" onclick="storeone('#theid#-aud');showwindow('#myself#ajax.trash_alias&id=#theid#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("alias_remove_button"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("alias_remove_button")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														<cfelse>
															<a href="##" onclick="storeone('#theid#-aud');showwindow('#myself#ajax.trash_record&id=#theid#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														</cfif>
													</cfif>
												</cfif>
											</div>
										</cfif>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "T">
											<cfif cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<div>
													<a href="##" onclick="loadcontent('loaddummy','#myself#c.basket_put_include&file_id=#theid#-aud&thetype=#theid#-aud&jsessionid=#session.SessionID#');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
												</div>
											</cfif>
										</cfif>
										<div style="clear:left;"></div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<!--- custom metadata fields to show --->
											<cfif attributes.cs.audios_metadata EQ "" OR (NOT prefs.set2_upc_enabled AND attributes.cs.audios_metadata EQ "aud_upc_number AS cs_aud_upc_number")>
												<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#theid#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
											<cfelse>
												<br />
												<cfloop list="#attributes.cs_place.bottom.audio#" index="m" delimiters=",">
													<cfif m CONTAINS "_filename">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#theid#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
													<cfelseif m CONTAINS "_size">
														<cfif evaluate(listlast(m," ")) NEQ "">
															<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
															#myFusebox.getApplicationData().global.converttomb('#left(evaluate(listlast(m," ")),150)#')# MB
														</cfif>
													<cfelseif m CONTAINS "_time">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
													<cfelseif m CONTAINS "expiry_date">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
													<cfelse>
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#left(evaluate(listlast(m," ")),150)#
													</cfif>
													<br />
												</cfloop>
											</cfif>
										<cfelse>
											<strong>#left(filename,50)#</strong>
										</cfif>
										<cfif isalias>
											<div style="float:right">
												<em>(Alias)</em>
											</div>
											<div style="clear:both;"></div>
										</cfif>
										<cfif ! session.fromshare>
											<br>
											<br>
											<cfset folderpath = "">
											<cfset crumbs = myFusebox.getApplicationData().folders.getbreadcrumb(folder_id_r)>
											<cfloop list="#crumbs#" delimiters=";" index="i">
												<cfset flid = ListGetAt(i,2,'|')>
												<cfset folderpath = folderpath & " / <a href='##' onclick=goToFolder('#flid#');>#ListGetAt(i,1,'|')#</a>">
											</cfloop>
											Folder: #replace(folderpath,'/','','ONE')#
										</cfif>
									<cfelse>
										The upload of "#filename#" is still in progress!
										<br /><br>
										#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
										#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<br><br>
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#theid#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
									</cfif>
								</div>
							<!--- All other files --->
							<cfelse>
								<div class="assetbox grid-masonry-item" id="#theid#-#kind##iif(isalias EQ 1,de('_alias'),de(''))#">
									<cfif is_available>
										<script type="text/javascript">
										$(function() {
											$("##draggable-s#theid#-doc").draggable({
												appendTo: 'body',
												cursor: 'move',
												addClasses: false,
												iframeFix: true,
												opacity: 0.25,
												zIndex: 6,
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
											<cfif isdate(expiry_date_actual) AND expiry_date_actual LT now()>
												$('##iconbar_search_#uniqueid#_#id#').css('display','none');
											</cfif>
										});
										</script>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<cfloop list="#attributes.cs_place.top.file#" index="m" delimiters=",">
												<cfif m CONTAINS "_filename">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#theid#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
												<cfelseif m CONTAINS "_size">
													<cfif evaluate(listlast(m," ")) NEQ "">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#myFusebox.getApplicationData().global.converttomb('#left(evaluate(listlast(m," ")),150)#')# MB
													</cfif>
												<cfelseif m CONTAINS "_time">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
												<cfelseif m CONTAINS "expiry_date">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
												<cfelse>
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#left(evaluate(listlast(m," ")),150)#
												</cfif>
												<br />
											</cfloop>
											<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#theid#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
										</cfif>
										<div id="draggable-s#theid#-doc" type="#theid#-doc" class="theimg">
											<!--- If it is a PDF we show the thumbnail --->
											<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
											<cfif application.razuna.storage EQ "amazon" AND cloud_url NEQ "">
												<img src="#cloud_url#" border="0" img-tt="img-tt">
											<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
												<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#" border="0" img-tt="img-tt">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0" width="128" height="128" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
											</cfif>
										</div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											</a>
											<div style="float:left;padding:6px 0px 3px 0px;">
												<input type="checkbox" name="file_id" value="#theid#-doc" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#theid#-doc") NEQ 0> checked="checked"</cfif>>
											</div>
											<div style="float:right;padding:6px 0px 0px 0px;">
												<div id="iconbar_search_#uniqueid#_#id#" style="display:inline">
													<cfif permfolder EQ "R" OR permfolder EQ "n">
														<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
													</cfif>
													<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#theid#&kind=doc&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
													<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#theid#-doc&thetype=#theid#-doc');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
													<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
														<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#theid#&thetype=doc','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',700,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
													</cfif>
													<cfif cs.show_favorites_part>
														<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#theid#&favtype=file&favkind=doc');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_favorite")#');return false;" timeformatle="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
													</cfif>
												</div>
												<cfif permfolder NEQ "R">
													<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
														<cfif isalias>
															<a href="##" onclick="storeone('#theid#-doc');showwindow('#myself#ajax.trash_alias&id=#theid#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("alias_remove_button"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("alias_remove_button")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														<cfelse>
															<a href="##" onclick="storeone('#theid#-doc');showwindow('#myself#ajax.trash_record&id=#theid#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
														</cfif>
													</cfif>
												</cfif>
											</div>
										</cfif>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "T">
											<cfif cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<div>
													<a href="##" onclick="loadcontent('loaddummy','#myself#c.basket_put_include&file_id=#theid#-doc&thetype=#theid#-doc&jsessionid=#session.SessionID#');flash_footer('#myFusebox.getApplicationData().defaults.trans("item_basket")#');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#">#myFusebox.getApplicationData().defaults.trans("put_in_basket")#</a>
												</div>
											</cfif>
										</cfif>
										<div style="clear:left;"></div>
										<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
											<!--- custom metadata fields to show --->
											<cfif attributes.cs.files_metadata EQ "" OR (NOT prefs.set2_upc_enabled AND attributes.cs.files_metadata EQ "file_upc_number AS cs_file_upc_number")>
												<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#theid#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
											<cfelse>
												<br />
												<cfloop list="#attributes.cs_place.bottom.file#" index="m" delimiters=",">
													<cfif m CONTAINS "_filename">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#theid#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
													<cfelseif m CONTAINS "_size">
														<cfif evaluate(listlast(m," ")) NEQ "">
															<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
															#myFusebox.getApplicationData().global.converttomb('#left(evaluate(listlast(m," ")),150)#')# MB
														</cfif>
													<cfelseif m CONTAINS "_time">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
													<cfelseif m CONTAINS "expiry_date">
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
													<cfelse>
														<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
														#left(evaluate(listlast(m," ")),150)#
													</cfif>
													<br />
												</cfloop>
											</cfif>
										<cfelse>
											<strong>#left(filename,50)#</strong>
										</cfif>
										<cfif isalias>
											<div style="float:right">
												<em>(Alias)</em>
											</div>
											<div style="clear:both;"></div>
										</cfif>
										<cfif ! session.fromshare>
											<br>
											<br>
											<cfset folderpath = "">
											<cfset crumbs = myFusebox.getApplicationData().folders.getbreadcrumb(folder_id_r)>
											<cfloop list="#crumbs#" delimiters=";" index="i">
												<cfset flid = ListGetAt(i,2,'|')>
												<cfset folderpath = folderpath & " / <a href='##' onclick=goToFolder('#flid#');>#ListGetAt(i,1,'|')#</a>">
											</cfloop>
											Folder: #replace(folderpath,'/','','ONE')#
										</cfif>
									<cfelse>
										The upload of "#filename#" is still in progress!
										<br /><br>
										#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
										#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<br><br>
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#theid#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
									</cfif>
								</div>
							</cfif>
						</cfoutput>
					</div>
			</td>
		</tr>
		</cfif>
		<!--- Icon Bar --->
		<cfif structkeyexists(attributes,"share") AND attributes.share EQ "F">
			<tr>
				<td colspan="6" style="border:0px;"><cfset attributes.bot = true><cfinclude template="dsp_icon_bar_search.cfm"></td>
			</tr>
		</cfif>
	</table>

	</form>
	<cfif structkeyexists(attributes,"share") AND attributes.share EQ "T">
		</div>
	</cfif>
	</cfif>
	<!--- JS for the combined view --->
	<script type="text/javascript">
		// Call for Masonry
		callMasonry();
		<cfif session.file_id NEQ "" AND fa NEQ "c.search_simple">
			enablesub('searchform#attributes.thetype#');
		</cfif>
		// Submit form
		function combinedsaveall(){
			loadinggif('updatestatusall');
			loadinggif('updatestatusall2');
			$("##updatestatusall").fadeTo("fast", 100);
			$("##updatestatusall2").fadeTo("fast", 100);
			var url = formaction("searchform#attributes.thetype#");
			var items = formserialize("searchform#attributes.thetype#");
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
					// Update Text
					$("##updatestatusall").css('color','green');
					$("##updatestatusall2").css('color','green');
					$("##updatestatusall").css('font-weight','bold');
					$("##updatestatusall2").css('font-weight','bold');
					$("##updatestatusall").html("#myFusebox.getApplicationData().defaults.trans("success")#");
					$("##updatestatusall2").html("#myFusebox.getApplicationData().defaults.trans("success")#");
					$("##updatestatusall").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
					$("##updatestatusall2").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
			   	}
			});
	        return false; 
		};
		// Change the pagelist
		function switchsearchtab(thetab){
			// Show loading bar
			$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
			// Load
			<cfif !structKeyExists(attributes,'search_upc')> 
				$('##content_search' + '_' + thetab).load('index.cfm?fa=c.search_simple', { thetype: thetab, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "thetype"><cfoutput>#lcase(i)#:"#evaluate(i)#"</cfoutput>, </cfif></cfloop> }, function(){
					$("##bodyoverlay").remove();
				});
			<cfelse>
				$('##content_search' + '_' + thetab).load('index.cfm?fa=c.searchupc', { thetype: thetab, fcall: true, search_upc:'#attributes.search_upc#' }, function(){
					$("##bodyoverlay").remove();
				});	
			</cfif>	
		}
		<cfif session.view EQ "combined">
			// Activate Chosen
			$(".chzn-select").chosen({search_contains: true});
		</cfif>
	</script>
</cfoutput>
