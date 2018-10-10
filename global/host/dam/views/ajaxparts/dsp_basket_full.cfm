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

<cfheader name="Content-Type"  value="text/octet-stream">
<!--- <cfheader name="Cache-Control" value="no-cache"> --->
<cfparam name="session.user_os" default="unknown">
<cfif !isdefined("qry_customization.#session.user_os#_netpath2asset") >
	<cfparam name= "qry_customization.#session.user_os#_netpath2asset" default="">
</cfif>
<!--- Storage Decision --->
<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
<cfif session.is_system_admin OR session.is_administrator>
	<cfset isadmin = true>
<cfelse>
	<cfset isadmin = false>
</cfif>
<!--- <cfset uniqueid = createuuid()> --->
<!--- Show network path var if present --->
<cfif evaluate("qry_customization.#session.user_os#_netpath2asset") NEQ "" AND attributes.fromshare EQ "F" AND session.user_os NEQ "unknown">
	<cfset show_netpath = true>
<cfelse>
	<cfset show_netpath = false>
</cfif>

<script type="text/javascript">
      function copyToClipboard(text) {
      	 text = decodeURIComponent(text);
	  window.prompt("Copy to clipboard: Ctrl+C (CMD+C on Macs), Enter", text);
	}
</script>

<cfoutput>
	<!--- If more than 100 we disable checkboxes --->
	<cfset _chk_disabled = qry_basket.total GT 100 ? 'disabled' : ''>
	<!--- Get network path --->
	<cfsavecontent variable="netpath">
		#evaluate("qry_customization.#session.user_os#_netpath2asset")#
	</cfsavecontent>
	<div id="basketstatus" style="display:none;padding:10px;font-weight:bold;"></div>
	<form name="thebasket" id="thebasket" method="post" action="#self#" target="_blank">
	<input type="hidden" name="#theaction#" id="#theaction#" value="c.basket_download">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid thumbview">

		<tr>
			<th colspan="4">
				<cfif attributes.fromshare EQ "F">
                    <cfif qry_basket.recordcount NEQ 0>
                    	<cfif _chk_disabled EQ "disabled">
	                    	<div style="padding:15px;background-color:cornsilk;">As you have more than 100 assets in the basket we only show the first 100 assets. Though, actions will apply to all assets in your basket.</div>
	                    	<div style="padding-top:15px"></div>
	                    </cfif>
                    	<!--- Buttons --->
                    	<div style="float:left;">
                    		<!--- Show buttons only if user is an admin OR no users/groups access defined OR if access if defined then user must have access or be part of a group that has access --->
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("download")#" onclick="$('##thebasket').submit();return false;" class="awesome large green">
                    		<cfif isadmin OR qry_customization.publish_btn_basket EQ "" OR listfindnocase(qry_customization.publish_btn_basket, session.theuserid) OR myFusebox.getApplicationData().global.comparelists(qry_customization.publish_btn_basket, session.thegroupofuser) NEQ "">
                    			<input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_basket")#" onclick="basketsave();return false;" class="awesome large grey">
                    		</cfif>

                    		<cfif isadmin OR qry_customization.email_btn_basket EQ "" OR listfindnocase(qry_customization.email_btn_basket, session.theuserid) OR myFusebox.getApplicationData().global.comparelists(qry_customization.email_btn_basket, session.thegroupofuser) NEQ "">
                    			<input type="button" value="#myFusebox.getApplicationData().defaults.trans("send_basket_email")#" onclick="basketemail('#qry_basket.cart_order_email#');return false;" class="awesome large grey">
                    		</cfif>

                    		<cfif isadmin OR qry_customization.ftp_btn_basket EQ "" OR listfindnocase(qry_customization.ftp_btn_basket, session.theuserid) OR myFusebox.getApplicationData().global.comparelists(qry_customization.ftp_btn_basket, session.thegroupofuser) NEQ "">
                    			<input type="button" value="#myFusebox.getApplicationData().defaults.trans("send_basket_ftp")#" onclick="basketftp();return false;" class="awesome large grey">
                    		</cfif>
                    		<cfif isadmin OR qry_customization.metadata_btn_basket EQ "" OR listfindnocase(qry_customization.metadata_btn_basket, session.theuserid) OR myFusebox.getApplicationData().global.comparelists(qry_customization.metadata_btn_basket, session.thegroupofuser) NEQ "">
                    			<input type="button" value="#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#" onclick="showwindow('#myself#c.meta_export&what=basket','#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#',600,1);return false;" class="awesome large grey">
                    		</cfif>
                    		<!--- Create renditions --->
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("create_renditions")#" onclick="batchaction('form','all','all','','renditions');return false;" class="awesome large grey">
                    		<!--- Delete basket --->
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("delete_basket")#" onclick="showwindow('#myself#ajax.remove_basket','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("delete_basket"))#',400,1);return false;" class="awesome large greylight">
                    	</div>
                    	<div style="clear:both;"></div>
					</cfif>
				<cfelse>
					<div style="float:left;">
						<cfif qry_basket.recordcount NEQ 0>
							<cfif qry_folder.share_order EQ "F">
								<input type="button" value="#myFusebox.getApplicationData().defaults.trans("download")#" onclick="$('##thebasket').submit();return false;" class="button">
								<input type="button" value="#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#" onclick="showwindow('#myself#c.meta_export&what=basket','#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#',600,1);return false;" class="button">
							<cfelse>
								<input type="button" value="Order the selected files below" onclick="orderSelectedFiles();" class="button">
							</cfif>
						</div>
						<div style="float:right;">
							<input type="button" value="#myFusebox.getApplicationData().defaults.trans("delete_basket")#" onclick="loadcontent('shared_basket','#myself#c.share_remove_basket_all');" class="button">
						</cfif>
					</div>
				</cfif>
			</th>
		</tr>
		<cfif qry_basket.recordcount EQ 0>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("empty_basket")#</td>
			</tr>
		<cfelse>
			<cfif !qry_customization.hide_select_links>
				<!--- Select All --->
				<tr>
					<td colspan="4" style="padding-top:15px;">
						<a href="##" id="checkall" style="text-decoration:underline;padding-right:10px;" class="ddicon">#myFusebox.getApplicationData().defaults.trans('select_deselect')# #myFusebox.getApplicationData().defaults.trans('all')#</a>
						<a href="##" id="checkorg" style="text-decoration:underline;padding-right:10px;" class="ddicon">#myFusebox.getApplicationData().defaults.trans('select_deselect')# #myFusebox.getApplicationData().defaults.trans("originals")#</a>
						<a href="##" id="checkthumb" style="text-decoration:underline;padding-right:10px" class="ddicon">#myFusebox.getApplicationData().defaults.trans('select_deselect')# #myFusebox.getApplicationData().defaults.trans('thumbnails')#</a>
						<a href="##" id="checkrend" style="text-decoration:underline;padding-right:10px" class="ddicon">#myFusebox.getApplicationData().defaults.trans('select_deselect')# #myFusebox.getApplicationData().defaults.trans('image_settings_rendition_header')#</a>
						<a href="##" id="checkvers" style="text-decoration:underline;" class="ddicon">#myFusebox.getApplicationData().defaults.trans('select_deselect')# Additional versions</a>
					</td>
				</tr>
			</cfif>
			<cfif attributes.fromshare EQ "T" AND qry_folder.share_order EQ "T">
				<tr>
					<td colspan="4">#myFusebox.getApplicationData().defaults.trans("basket_order")#</td>
				</tr>
			</cfif>
			<!--- Show order desc --->
			<cfif attributes.fromshare EQ "F" AND qry_basket.cart_order_done NEQ "">
				<tr>
					<td colspan="4"><h2>This is an order from the email address: #qry_basket.cart_order_email#</h2> You can remove, add or modify the basket. You can choose what you want to do with this order with the button above, e.g. if you want to send the order to the user, simply choose the "eMail Basket" action.
					<cfif qry_basket.cart_order_message NEQ "">
						<br><br>
						The user wrote the below message with this order:
						<br><br>
						#qry_basket.cart_order_message#
						<br><br>
					</cfif>
					</td>
				</tr>
				<tr>
					<td colspan="4">If you have finished processing the order <a href="##" onclick="loadcontent('order_done','#myself#c.order_done&cart_id=#session.thecart#');">please click here to close the order.</a><div id="order_done"></div></td>
				</tr>
			</cfif>
			<tr>
				<td colspan="4" style="padding:10px;"></td>
			</tr>
			<cfloop query="qry_basket">
				<cfset myid = cart_product_id>
				<cfset order = cart_order_done>
				<cfset artofimage = cart_order_artofimage>
				<cfset artofvideo = cart_order_artofvideo>
				<cfset artofaudio = cart_order_artofaudio>
				<cfswitch expression="#cart_file_type#">
					<!--- IMAGES --->
					<cfcase value="img">
						<tr class="list">
							<td width="1%" nowrap="true">
								<cfquery name="getimg" dbtype="query">
									SELECT img_id, thumb_extension, path_to_asset, cloud_url, folder_id_r, filename, link_kind, link_path_url, share_dl_org, share_dl_thumb FROM qry_theimage WHERE img_id= '#myid#'
								</cfquery>
								<!--- Display all thumbs first--->
								<cfloop query="getimg">
									<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.imagedetail#&file_id=#img_id#&what=images&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/thumb_#img_id#.#thumb_extension#" border="0">
											</cfif>
										<cfelse>
											<img src="#link_path_url#" border="0">
										</cfif>
									<cfif attributes.fromshare EQ "F"></a></cfif>
								</cfloop>
							</td>
							<td width="100%" colspan="2" valign="top" class="gridno">
								<table border="0" cellpadding="0" cellspacing="0" width="100%">
									<cfloop query="qry_theimage">
										<cfif myid EQ img_id>
											<tr>
												<td colspan="2" style="padding-bottom:7px;">
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.imagedetail#&file_id=#img_id#&what=images&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
													<span style="padding-left:30px">
														<cfif attributes.fromshare EQ "F">
															<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#myid#&what=basket_full&loaddiv=rightside','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove_basket"))#',400,1);return false;" style="text-decoration:none">
														<cfelse>
															<a href="##" onclick="loadcontent('shared_basket','#myself#c.share_remove_basket&id=#myid#&fromshare=T');" style="text-decoration:none">
														</cfif>
															<span class="smallfont ltgrey">#myFusebox.getApplicationData().defaults.trans("basket_remove")#</span>
														</a>
													</span>
												</td>
											</tr>
											<!--- Original --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_theimage.share_dl_org EQ "T" OR qry_share_options CONTAINS "#img_id#-org-1">
													<tr>
														<td><input type="checkbox" name="artofimage" id="imgorg#myid#" value="#myid#-original" onchange="checksel('#myid#','imgorg#myid#','img');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('imgorg#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind EQ ""> #ucase(img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB) (#orgwidth#x#orgheight# pixel)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#img_id#-org-1" OR qry_theimage.share_dl_org EQ "T">
													<tr>
														<td><input type="checkbox" #_chk_disabled# name="artofimage" id="imgorg#myid#" value="#myid#-original" onchange="checksel('#myid#','imgorg#myid#','img');"></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('imgorg#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind EQ ""> #ucase(img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB) (#orgwidth#x#orgheight# pixel)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														<cfif show_netpath>
															<!--- Format the netwrk path variable --->
															<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\#filename_org#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
															<!--- Remove line breaks --->
															<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
															<a href="##" onclick="copyToClipboard ('#thepath#')";>
															Get Local Path
															</a>
														</cfif>
														</td>
													</tr>
												</cfif>
											</cfif>
											<!--- Thumbnail --->
											<cfif link_kind EQ "">
												<cfif attributes.fromshare EQ "T">
													<cfif qry_theimage.share_dl_thumb EQ "T" OR qry_share_options CONTAINS "#myid#-thumb-1">
														<tr>
															<td width="1%"><input type="checkbox" name="artofimage" id="imgt#myid#" value="#myid#-thumb" onchange="checksel('#myid#','imgt#myid#','img');" /></td>
															<td width="100%">
																<a href="##" onclick="clickcbk2('imgt#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																	#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(thumb_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#thumblength#")# MB) (#thumbwidth#x#thumbheight# pixel)
																</a>
															</td>
														</tr>
													</cfif>
												<cfelse>
													<cfif perm NEQ "R" OR qry_share_options CONTAINS "#myid#-thumb-1" OR qry_theimage.share_dl_thumb EQ "T">
														<tr>
															<td width="1%"><input type="checkbox" #_chk_disabled# name="artofimage" id="imgt#myid#" value="#myid#-thumb" onchange="checksel('#myid#','imgt#myid#','img');" /></td>
															<td width="100%">
																<a href="##" onclick="clickcbk2('imgt#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																	#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(thumb_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#thumblength#")# MB) (#thumbwidth#x#thumbheight# pixel)
																</a>
															<cfif show_netpath>
																<!--- Format the netwrk path variable --->
																<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\thumb_#img_id#.#thumb_extension#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
																<!--- Remove line breaks --->
																<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
																<a href="##" onclick="copyToClipboard ('#thepath#')";>
																Get Local Path
																</a>
															</cfif>
															</td>
														</tr>
													</cfif>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
									<!--- List the converted formats --->
									<cfloop query="qry_theimage_related">
										<cfif myid EQ img_group>
											<cfif attributes.fromshare EQ "T">
												<cfif qry_share_options CONTAINS "#img_id#-#img_id#-1" OR qry_share_options DOES NOT CONTAIN "#img_id#-#img_id#">
													<tr>
														<td><input type="checkbox" name="artofimage" id="#myid#-#img_id#" value="#myid#-#img_id#" onchange="checksel('#myid#','#myid#-#img_id#','img');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('#myid#-#img_id#');basketStoreAll('all-not');" style="text-decoration: none;">
																#ucase(img_extension)# #myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel) [#filename#]
															</a>
														</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#img_id#-#img_id#-1">
													<tr>
														<td><input type="checkbox" #_chk_disabled# name="artofimage" id="rend-#myid#-#img_id#" value="#myid#-#img_id#" onchange="checksel('#myid#','#myid#-#img_id#','img');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('rend-#myid#-#img_id#');basketStoreAll('all-not');" style="text-decoration: none;">
																#ucase(img_extension)# #myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel) [#filename#]
															</a>
														<cfif show_netpath>
															<!--- Format the netwrk path variable --->
															<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\#filename_org#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
															<!--- Remove line breaks --->
															<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
															<a href="##" onclick="copyToClipboard ('#thepath#')";>
															Get Local Path
															</a>
														</cfif>
													</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
									<!--- List the Additional Renditions --->
									<cfloop query="qry_addition_version.assets">
										<cfif isnumeric(thesize)><cfset thesize = numberformat(thesize,'_.__')></cfif>
										<!--- check the file id --->
										<cfif qry_basket.cart_product_id EQ asset_id_r>
											<cfif qry_share_options CONTAINS "#av_id#-av-1">
												<tr>
													<td><input type="checkbox" #_chk_disabled# name="artofimage" id="imgv#myid#" value="#myid#-#av_id#-versions" onchange="checksel('#myid#','imgv#myid#','img');" /></td>
													<td width="100%">
														<a href="##" onclick="clickcbk2('imgv#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
															#ucase(av_link_title)# #myFusebox.getApplicationData().defaults.converttomb("#thesize#")# MB (#thewidth#x# theheight# pixel)
														</a>
													<cfif show_netpath>
														<!--- Format the netwrk path variable --->
														<cfset thepath = trim(replace(replace('#netpath#\#session.hostid##av_link_url#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
														<!--- Remove line breaks --->
														<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
														<a href="##" onclick="copyToClipboard ('#thepath#')";>
														Get Local Path
														</a>
													</cfif>
													</td>
												</tr>
											</cfif>
										</cfif>
									</cfloop>
								</table>
							</td>
					</cfcase>
					<!--- VIDEOS --->
					<cfcase value="vid">
						<tr class="list">
							<td width="1%" nowrap="true" valign="top">
								<cfloop query="qry_thevideo">
									<cfif myid EQ vid_id>
										<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.videodetail#&file_id=#vid_id#&what=files&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
											<cfif link_kind NEQ "url">
												<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
													<img src="#cloud_url#" border="0" width="120">
												<cfelse>
													<img src="#thestorage##path_to_asset#/#vid_name_image#" border="0">
												</cfif>
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0" width="128" height="128">
											</cfif>
										<cfif attributes.fromshare EQ "F"></a></cfif>
									</cfif>
								</cfloop>
							</td>
							<td width="100%" colspan="2" valign="top" class="gridno">
								<table border="0" cellpadding="0" cellspacing="0" width="100%">
									<cfloop query="qry_thevideo">
										<cfif myid EQ vid_id>
											<tr>
												<td colspan="2" style="padding-bottom:7px;">
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.videodetail#&file_id=#vid_id#&what=files&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
													<span style="padding-left:30px">
														<cfif attributes.fromshare EQ "F">
															<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#myid#&what=basket_full&loaddiv=rightside','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove_basket"))#',400,1);return false;" style="text-decoration:none">
														<cfelse>
															<a href="##" onclick="loadcontent('shared_basket','#myself#c.share_remove_basket&id=#myid#&fromshare=T');" style="text-decoration:none">
														</cfif>
															<span class="smallfont ltgrey">#myFusebox.getApplicationData().defaults.trans("basket_remove")#</span>
														</a>
													</span>
												</td>
											</tr>
											<!--- The Original video --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_thevideo.share_dl_org EQ "T" OR qry_share_options CONTAINS "#vid_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofvideo" id="vid#myid#" value="#myid#-video" onchange="checksel('#myid#','vid#myid#','vid');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('vid#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind NEQ "url"> #ucase(vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB) (#vwidth#x#vheight# pixel)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#vid_id#-org-1" OR qry_thevideo.share_dl_org EQ "T">
													<tr>
														<td width="1%"><input type="checkbox" #_chk_disabled# name="artofvideo" id="vid#myid#" value="#myid#-video" onchange="checksel('#myid#','vid#myid#','vid');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('vid#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind NEQ "url"> #ucase(vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB) (#vwidth#x#vheight# pixel)</cfif>
																<cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														<cfif show_netpath>
															<!--- Format the netwrk path variable --->
															<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\#filename_org#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
															<!--- Remove line breaks --->
															<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
															<a href="##" onclick="copyToClipboard ('#thepath#')";>
															Get Local Path
															</a>
														</cfif>
													</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
									<!--- List the converted formats --->
									<cfloop query="qry_thevideo_related">
										<cfif myid EQ vid_group>
											<cfif attributes.fromshare EQ "T">
												<cfif qry_share_options CONTAINS "#vid_id#-#vid_extension#-1" OR qry_share_options DOES NOT CONTAIN "#vid_id#-#vid_extension#">
													<tr>
														<td width="1%"><input type="checkbox" name="artofvideo" id="#myid#-#vid_id#" value="#myid#-#vid_id#" onchange="checksel('#myid#','#myid#-#vid_id#','vid');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('#myid#-#vid_id#');basketStoreAll('all-not');" style="text-decoration: none;">
																#ucase(vid_extension)# #myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB (#vid_preview_width#x#vid_preview_heigth# pixel) [#filename#]
															</a>
														</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#vid_id#-#vid_id#-1">
													<tr>
														<td width="1%"><input type="checkbox" #_chk_disabled# name="artofvideo" id="rend-#myid#-#vid_id#" value="#myid#-#vid_id#" onchange="checksel('#myid#','#myid#-#vid_id#','vid');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('rend-#myid#-#vid_id#');basketStoreAll('all-not');" style="text-decoration: none;">
																#ucase(vid_extension)# #myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB (#vid_preview_width#x#vid_preview_heigth# pixel) [#filename#]
															</a>
														<cfif show_netpath>
															<!--- Format the netwrk path variable --->
															<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\#filename_org#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
															<!--- Remove line breaks --->
															<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
															<a href="##" onclick="copyToClipboard ('#thepath#')";>
															Get Local Path
															</a>
														</cfif>
														</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
									<!--- List the Additional Renditions --->
									<cfloop query="qry_addition_version.assets">
										<cfif isnumeric(thesize)><cfset thesize = numberformat(thesize,'_.__')></cfif>
										<!--- check the file id --->
										<cfif qry_basket.cart_product_id EQ asset_id_r>
											<cfif qry_share_options CONTAINS "#av_id#-av-1">
												<tr>
													<td><input type="checkbox" #_chk_disabled# name="artofvideo" id="vidv#myid#" value="#myid#-#av_id#-versions" onchange="checksel('#myid#','vidv#myid#','vid');" /></td>
													<td width="100%">
														<a href="##" onclick="clickcbk2('vidv#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
															#ucase(av_link_title)# #myFusebox.getApplicationData().defaults.converttomb("#thesize#")# MB (#thewidth#x#theheight# pixel)
														</a>
													<cfif show_netpath>
														<!--- Format the netwrk path variable --->
														<cfset thepath = trim(replace(replace('#netpath#\#session.hostid##av_link_url#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
														<!--- Remove line breaks --->
														<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
														<a href="##" onclick="copyToClipboard ('#thepath#')";>
														Get Local Path
														</a>
													</cfif>
													</td>
												</tr>
											</cfif>
										</cfif>
									</cfloop>
								</table>
							</td>
					</cfcase>
					<!--- AUDIOS --->
					<cfcase value="aud">
						<tr class="list">
							<td width="1%" nowrap="true" valign="top">
								<cfloop query="qry_theaudio">
									<cfif myid EQ aud_id>
										<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.audiodetail#&file_id=#aud_id#&what=audios&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
											<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif aud_extension EQ "mp3" OR aud_extension EQ "wav">#aud_extension#<cfelse>aud</cfif>.png" width="120" border="0">
										<cfif attributes.fromshare EQ "F"></a></cfif>
									</cfif>
								</cfloop>
							</td>
							<td width="100%" colspan="2" valign="top" class="gridno">
								<table border="0" cellpadding="0" cellspacing="0" width="100%">
									<cfloop query="qry_theaudio">
										<cfif myid EQ aud_id>
											<tr>
												<td colspan="2" style="padding-bottom:7px;">
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.audiodetail#&file_id=#aud_id#&what=audios&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
													<span style="padding-left:30px">
														<cfif attributes.fromshare EQ "F">
															<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#myid#&what=basket_full&loaddiv=rightside','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove_basket"))#',400,1);return false;" style="text-decoration:none">
														<cfelse>
															<a href="##" onclick="loadcontent('shared_basket','#myself#c.share_remove_basket&id=#myid#&fromshare=T');" style="text-decoration:none">
														</cfif>
															<span class="smallfont ltgrey">#myFusebox.getApplicationData().defaults.trans("basket_remove")#</span>
														</a>
													</span>
												</td>
											</tr>
											<!--- The Original audio --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_theaudio.share_dl_org EQ "T" OR qry_share_options CONTAINS "#aud_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofaudio" id="aud#myid#" value="#myid#-audio" onchange="checksel('#myid#','aud#myid#','aud');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('aud#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind NEQ "url"> #ucase(aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#aud_id#-org-1" OR qry_theaudio.share_dl_org EQ "T">
													<tr>
														<td width="1%"><input type="checkbox" #_chk_disabled# name="artofaudio" id="aud#myid#" value="#myid#-audio" onchange="checksel('#myid#','aud#myid#','aud');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('aud#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind NEQ "url"> #ucase(aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														<cfif show_netpath>
															<!--- Format the netwrk path variable --->
															<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\#filename_org#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
															<!--- Remove line breaks --->
															<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
															<a href="##" onclick="copyToClipboard ('#thepath#')";>
															Get Local Path
															</a>
														</cfif>
														</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
									<!--- List the converted formats --->
									<cfloop query="qry_theaudio_related">
										<cfif myid EQ aud_group>
											<cfif attributes.fromshare EQ "T">
												<cfif qry_share_options CONTAINS "#aud_id#-#aud_extension#-1" OR qry_share_options DOES NOT CONTAIN "#aud_id#-#aud_extension#">
													<tr>
														<td width="1%"><input type="checkbox" name="artofaudio" id="#myid#-#aud_id#" value="#myid#-#aud_id#" onchange="checksel('#myid#','#myid#-#aud_id#','aud');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('#myid#-#aud_id#');basketStoreAll('all-not');" style="text-decoration: none;">
																#ucase(aud_extension)# #myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB [#filename#]
															</a>
														</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#aud_id#-#aud_id#-1">
													<tr>
														<td width="1%"><input type="checkbox" #_chk_disabled# name="artofaudio" id="rend-#myid#-#aud_id#" value="#myid#-#aud_id#" onchange="checksel('#myid#','#myid#-#aud_id#','aud');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('rend-#myid#-#aud_id#');basketStoreAll('all-not');" style="text-decoration: none;">
																#ucase(aud_extension)# #myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB [#filename#]
															</a>
														<cfif show_netpath>
															<!--- Format the netwrk path variable --->
															<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\#filename_org#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
															<!--- Remove line breaks --->
															<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
															<a href="##" onclick="copyToClipboard ('#thepath#')";>
															Get Local Path
															</a>
														</cfif>
														</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
									<!--- List the Additional Renditions --->
									<cfloop query="qry_addition_version.assets">
										<cfif isnumeric(thesize)><cfset thesize = numberformat(thesize,'_.__')></cfif>
										<!--- check the file id --->
										<cfif qry_basket.cart_product_id EQ asset_id_r>
											<cfif qry_share_options CONTAINS "#av_id#-av-1">
												<tr>
													<td><input type="checkbox" #_chk_disabled# name="artofaudio" id="audv#myid#" value="#myid#-#av_id#-versions" onchange="checksel('#myid#','audv#myid#','aud');" /></td>
													<td width="100%">
														<a href="##" onclick="clickcbk2('audv#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
															#ucase(av_link_title)# #myFusebox.getApplicationData().defaults.converttomb("#thesize#")# MB (#thewidth#x#theheight# pixel)
														</a>
													<cfif show_netpath>
														<!--- Format the netwrk path variable --->
														<cfset thepath = trim(replace(replace('#netpath#\#session.hostid##av_link_url#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
														<!--- Remove line breaks --->
														<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
														<a href="##" onclick="copyToClipboard ('#thepath#')";>
														Get Local Path
														</a>
													</cfif>
												</td>
												</tr>
											</cfif>
										</cfif>
									</cfloop>
								</table>
							</td>
					</cfcase>
					<!--- FILES --->
					<cfdefaultcase>
						<tr class="list">
							<td width="1%" nowrap="true" valign="top" align="center">
								<cfloop query="qry_thefile">
									<cfif myid EQ file_id>
										<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.filedetail#&file_id=#file_id#&what=files&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
											<!---Show the thumbnail --->
											<cfset thethumb = replacenocase(file_name_org, ".#file_extension#", ".jpg", "all")>
											<cfif application.razuna.storage EQ "amazon" AND cloud_url NEQ "">
												<img src="#cloud_url#" border="0" img-tt="img-tt">
											<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
												<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#" border="0" img-tt="img-tt">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" border="0" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
											</cfif>
										<cfif attributes.fromshare EQ "F"></a></cfif>
									</cfif>
								</cfloop>
							</td>
							<td width="100%" colspan="2" valign="top" class="gridno">
								<table border="0" cellpadding="0" cellspacing="0" width="100%">
									<cfloop query="qry_thefile">
										<cfif myid EQ file_id>
											<tr>
												<td width="100%" colspan="2" valign="top">
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.filedetail#&file_id=#file_id#&what=files&loaddiv=&folder_id=#folder_id_r#&basketview=yes','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
													<span style="padding-left:30px">
														<cfif attributes.fromshare EQ "F">
															<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#myid#&what=basket_full&loaddiv=rightside','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove_basket"))#',400,1);return false;" style="text-decoration:none">
														<cfelse>
															<a href="##" onclick="loadcontent('shared_basket','#myself#c.share_remove_basket&id=#myid#&fromshare=T');" style="text-decoration:none">
														</cfif>
															<span class="smallfont ltgrey">#myFusebox.getApplicationData().defaults.trans("basket_remove")#</span>
														</a>
													</span>
												</td>
											</tr>
											<!--- The Original --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_thefile.share_dl_org EQ "T" OR qry_share_options CONTAINS "#file_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artoffile" id="doc#myid#" value="#myid#-doc" onchange="checksel('#myid#','doc#myid#','doc');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('doc#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind NEQ "url"> #ucase(file_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#file_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#file_id#-org-1" OR qry_thefile.share_dl_org EQ "T">
													<tr>
														<td width="1%"><input type="checkbox" #_chk_disabled# name="artoffile" id="doc#myid#" value="#myid#-doc" onchange="checksel('#myid#','doc#myid#','doc');" /></td>
														<td width="100%">
															<a href="##" onclick="clickcbk2('doc#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
																#myFusebox.getApplicationData().defaults.trans("original")#<cfif link_kind NEQ "url"> #ucase(file_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#file_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif>
															</a>
														<cfif show_netpath>
															<!--- Format the netwrk path variable --->
															<cfset thepath = trim(replace(replace('#netpath#\#session.hostid#\#path_to_asset#\#filename_org#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
															<!--- Remove line breaks --->
															<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
															<a href="##" onclick="copyToClipboard ('#thepath#')";>
															Get Local Path
															</a>
														</cfif>
													</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
									<!--- List the Additional Renditions --->
									<cfloop query="qry_addition_version.assets">
										<cfif isnumeric(thesize)><cfset thesize = numberformat(thesize,'_.__')></cfif>
										<!--- check the file id --->
										<cfif qry_basket.cart_product_id EQ asset_id_r>
											<cfif qry_share_options CONTAINS "#av_id#-av-1">
												<tr>
													<td><input type="checkbox" #_chk_disabled# name="artoffile" id="docv#myid#" value="#myid#-#av_id#-versions" onchange="checksel('#myid#','docv#myid#','doc');" /></td>
													<td width="100%">
														<a href="##" onclick="clickcbk2('docv#myid#');basketStoreAll('all-not');" style="text-decoration: none;">
															#ucase(av_link_title)# #myFusebox.getApplicationData().defaults.converttomb("#thesize#")# MB (#thewidth#x#theheight# pixel)
														</a>
													<cfif show_netpath>
														<!--- Format the netwrk path variable --->
														<cfset thepath = trim(replace(replace('#netpath#\#session.hostid##av_link_url#','\','#fileseparator()#','ALL'),'/','#fileseparator()#','ALL'))>
														<!--- Remove line breaks --->
														<cfset thepath = URLEncodedFormat(REReplace(thepath ,'#chr(13)#|#chr(9)#|\n|\r','','ALL'))>
														<a href="##" onclick="copyToClipboard ('#thepath#')";>
														Get Local Path
														</a>
													</cfif>
													</td>
												</tr>
											</cfif>
										</cfif>
									</cfloop>
								</table>
							</td>
					</cfdefaultcase>
				</cfswitch>
			</tr>
			</cfloop>
		</cfif>
	</table>
	<cfif !application.razuna.isp AND attributes.fromshare EQ "F" AND qry_basket.recordcount NEQ 0>
		<table border="0">
		<tr>
			<td colspan="3">
				<!--- Copy basket to local folder --->
				<strong>#myFusebox.getApplicationData().defaults.trans("basket_upload2local")#</strong>
			<td>
		</tr>
		<tr>
			<td><input type="text" style="width:400px;" name="uploaddir" id="uploaddir" /> </td>
			<td><input type="button" value="#myFusebox.getApplicationData().defaults.trans("validate")#" onclick="importfoldercheck();" class="button" /></td>
			<td><button name="upload_local" id="upload_local" class="button" type="button" onclick="basket_upload('local');">#myFusebox.getApplicationData().defaults.trans("basket_localbutton")#</button></td>
		</tr>
		<tr>
			<td colspan="3"><div id="path_validate"></div></td>
		</tr>

		<!--- Copy basket to amazon --->
		<cfif application.razuna.storage NEQ "amazon">
			<tr>
				<td colspan="3"><strong>#myFusebox.getApplicationData().defaults.trans("basket_upload2aws")#</strong></td>
			</tr>
			<tr>
				<cfif qry_s3_buckets.recordcount NEQ 0>
					<td colspan="3">
						#myFusebox.getApplicationData().defaults.trans("basket_awsbuckets")#
						<select name = "bucket_aws" id = "bucket_aws">
							<cfloop query="qry_s3_buckets">
								<option value="#set_id#">#set_pref#</option>
							</cfloop>
						</select>
						<button name="upload_aws" id="upload_aws" class="button" type="button" onclick="basket_upload('aws');">#myFusebox.getApplicationData().defaults.trans("basket_awsbutton")#</button>
					</td>
				<cfelse>
					<td colspan="3">#myFusebox.getApplicationData().defaults.trans("basket_upload2aws_desc")#</td>
				</cfif>
			</tr>
		</cfif>
	</table>
		<br /><br />
		#myFusebox.getApplicationData().defaults.trans("basket_results")#
		<br />
		<div style="border:1px solid ##000; width:95%; height:200px; overflow:auto; background:##eee;" id="divProgress"></div>
		<br />
		<div style="border:1px solid ##ccc; width:95%; height:20px; overflow:auto; background:##eee;">
		    <div id="progressor" style="background:##07c; width:0%; height:100%;"></div>
		</div>
		<hr>
	</cfif>
</form>

	<cfif qry_basket.recordcount NEQ 0><div>* <em>#myFusebox.getApplicationData().defaults.trans("link_url_basket")#</em></div></cfif>

	<input type="hidden" id="basket_disabled" value="#_chk_disabled#">

</cfoutput>

<script type="text/javascript">

	$(document).ready(function() {

		// On load store all
		basketStoreAll('first');

		// Submit Form
		$("#thebasket").submit(function(e) {
			// If disabled
			// var _disabled = $('#basket_disabled').val();
			// Get values
			var url = formaction("thebasket");
			var items = formserialize("thebasket");
			// If nothing is selected
			if ( (items.indexOf('artofvideo') == -1) && (items.indexOf('artofimage') == -1) && (items.indexOf('artofaudio') == -1) && (items.indexOf('artoffile') == -1) ){
				alert('No assets have been selected for downloading. You need to selected at least one asset!');
				$("#basketstatus").css("display","none");
				$("#basketstatus").html('');
				return false;
			}
			// Get values for fields
			createTarget();
			// Show
			// $("#basketstatus").fadeTo("fast", 100);
			// $("#basketstatus").css("display","");
			// $("#basketstatus").html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading.gif" border="0" width="16" height="16"> <cfoutput>#myFusebox.getApplicationData().defaults.trans("please_wait")#</cfoutput>... (this can take some time with large assets). You can either wait for it to finish or continue working. We will send you an email with the download link once the basket is complete.');
			// Submit Form
			// $.ajax({
			// 	type: "POST",
			// 	url: url,
			//    	data: items
			  //  	success: function(data){
			  //  		$("#basketstatus").html('<span style="color:green;">Your basket is ready.</span> <a href="'+ trim(data) +'">Click on this link to download the basket now!</a>');
					// // $("#basketstatus").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
			  //  	}
			// });
			return true;
		})
		// If we come from basket_full_remove
		<cfif fa EQ "c.basket_full_remove">
			$('#basket').load('<cfoutput>#myself#</cfoutput>c.basket');
		</cfif>

		// Initialize global variables to store selection statuses
		if (window.checkall_global==undefined)
			checkall_global= false;
		if (window.checkorg_global==undefined)
			checkorg_global= false;
		if (window.checkthumb_global==undefined)
			checkthumb_global= false;
		if (window.checkrend_global==undefined)
			checkrend_global= false;
		if (window.checkvers_global==undefined)
			checkvers_global= false;
		// Select All
		$('#checkall').click(function () {
			$('#thebasket :checkbox').each( function() {
				if(!checkall_global){
					$(this).prop('checked', false);
				}
				else{
					$(this).prop('checked', true);
				}
			})
			if (checkall_global)
			{
				checkall_global = false;
				checkorg_global = false;
				checkthumb_global = false;
				checkrend_global = false;
				checkvers_global = false;
				basketStoreAll('all');
			}
			else
			{
				checkall_global= true;
				checkorg_global = true;
				checkthumb_global = true;
				checkrend_global = true;
				checkvers_global = true;
				basketStoreAll('all-not');
			}
			return false;
		});

		// Select Originals
		$('#checkorg').click(function() {
			$('#thebasket').find('[id*="imgorg"],[id*="vid"],[id*="aud"],[id*="doc"]').each( function() {
				if(!checkorg_global){
					$(this).prop('checked', false);
				}
				else{
					$(this).prop('checked', true);
				}
			})
			if (checkorg_global) {
				checkorg_global = false;
				basketStoreOrg(true);
			}
			else {
				checkorg_global= true;
				basketStoreOrg(false);
			}
			return false;
		});

		// Select Thumbnails
		$('#checkthumb').click(function() {
			$('#thebasket').find('[id*="imgt"]').each( function() {
				if(!checkthumb_global){
					$(this).prop('checked', false);
				}
				else{
					$(this).prop('checked', true);
				}
			})
			if (checkthumb_global) {
				checkthumb_global = false;
				basketStoreThumb(true);
			}
			else {
				checkthumb_global= true;
				basketStoreThumb(false);
			}
			return false;
		});

		// Select Renditions
		$('#checkrend').click(function() {
			$('#thebasket').find('[id*="rend-"]').each( function() {
				if(!checkrend_global){
					$(this).prop('checked', true);
				}
				else{
					$(this).prop('checked', false);
				}
			})
			if (!checkrend_global) {
				checkrend_global = true;
				basketStoreRend(true);
			}
			else {
				checkrend_global= false;
				basketStoreRend(false);
			}
			return false;
		});

		// Select Renditions
		$('#checkvers').click(function() {
			$('#thebasket').find('[id*="imgv"],[id*="vidv"],[id*="audv"],[id*="docv"]').each( function() {
				if(!checkvers_global){
					$(this).prop('checked', true);
				}
				else{
					$(this).prop('checked', false);
				}
			})
			if (!checkvers_global) {
				checkvers_global = true;
				basketStoreVers(true);
			}
			else {
				checkvers_global= false;
				basketStoreVers(false);
			}
			return false;
		});

	});

	// Store all
	function basketStoreAll(the_value) {
		// Var
		var _type = '';
		var _type_org = false;
		var _type_thumb = false;
		var _type_rend = false;
		var _type_vers = false;
		// Switch
		switch(the_value) {
			case 'all':
				_type = 'all';
				_type_org = true;
				_type_thumb = true;
				_type_rend = true;
				_type_vers = true;
				break;
			case 'all-not':
				_type = '';
				_type_org = false;
				_type_thumb = false;
				_type_rend = false;
				_type_vers = false;
				break;
		}
		// If disabled
		// var _disabled = $('#basket_disabled').val();
		// if ( _disabled === '' ) {
		// 	_type_org = false;
		// 	_type_thumb = false;
		// 	_type_rend = false;
		// 	_type_vers = false;
		// }
		// Submit the values so we put them into sessions
		var url = 'index.cfm?fa=c.store_art_values';
		var items = '&artofimage=' + _type + '&artofvideo=' + _type + '&artofaudio=' + _type + '&artoffile=' + _type + '&allorg=' + _type_org + '&allthumb=' + _type_thumb + '&allrend=' + _type_rend + '&allvers=' + _type_vers;
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
			data: items
		});
	}

	// Store org
	function basketStoreOrg(the_value) {
		// Submit the values so we put them into sessions
		var url = 'index.cfm?fa=c.store_art_values_org_basket';
		var items = 'allorg=' + the_value;
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
			data: items
		});
	}

	// Store org
	function basketStoreThumb(the_value) {
		// Submit the values so we put them into sessions
		var url = 'index.cfm?fa=c.store_art_values_thumb_basket';
		var items = 'allthumb=' + the_value;
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
			data: items
		});
	}

	// Store renditions
	function basketStoreRend(the_value) {
		// Submit the values so we put them into sessions
		var url = 'index.cfm?fa=c.store_art_values_rend_basket';
		var items = 'allrend=' + the_value;
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
			data: items
		});
	}

	// Store renditions
	function basketStoreVers(the_value) {
		// Submit the values so we put them into sessions
		var url = 'index.cfm?fa=c.store_art_values_vers_basket';
		var items = 'allvers=' + the_value;
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
			data: items
		});
	}


	// New function to first get all the selected files
	function orderSelectedFiles() {
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
		// For URL
		var items = '&artofimage=' + artimage + '&artofvideo=' + artvideo + '&artofaudio=' + artaudio + '&artoffile=' + artfile;
		// Show window
		showwindow('index.cfm?fa=ajax.share_order' + items,'Order',500,1);
	}

  	function resetLog()
    {
         document.getElementById("divProgress").innerHTML = "";
         document.getElementById('progressor').style.width = 0 + "%";
    }

    function log_message(message)
    {
        document.getElementById("divProgress").innerHTML += message + '<br />';
    }


	    function basket_upload(type)
	    {
	        resetLog();
	        if (!window.XMLHttpRequest)
	        {
	            log_message("Your browser does not support the native XMLHttpRequest object.");
	            return;
	        }

	        try
	        {
	            var xhr = new XMLHttpRequest();
	            xhr.previous_text = '';
	            xhr.onerror = function() { log_message("[XHR] Fatal Error."); };
	            xhr.onreadystatechange = function()
	            {
	                try
	                {
	                    if (xhr.readyState > 2)
	                    {
	                        var new_response = xhr.responseText.substring(xhr.previous_text.length);
	                        var resparr = new_response.split('{');
	                        for (var i=1;i<resparr.length;i++)
	                        {
	                        new_response =  '{' + resparr[i];
	                        var result = $.parseJSON( new_response );
	                        if (result.message !='')
	                        	log_message(result.message);
	                        //update the progressbar
	                       document.getElementById('progressor').style.width = result.progress + "%";
	                       }
	                       xhr.previous_text = xhr.responseText;
	                    }
	                    // If request has completed
	                   if (xhr.readyState==4)
	                   {
	                    	$("#upload_aws").prop("disabled",false);
	                    	$("#upload_local").prop("disabled",false);
	                    }
	                }
	                catch (e)
	                {
	                   //log_message("<b>[XHR] Exception: " + e + "</b>");
	                }


	            };
	            // Set proper fuseaction
	            <cfoutput>
	            if (type=='aws')
	            {
	            	$("###theaction#").prop("value", "c.basket_upload2aws");
	            	// Disable aws upload button to prevent users from hitting it again and initiating multiple requests
	            	$("##upload_aws").prop("disabled",true);
	            }
	            else
	            {
			$("###theaction#").prop("value", "c.basket_upload2local");
			$("##upload_local").prop("disabled",true);
		}
		</cfoutput>
	            // Get values
		var items = formserialize("thebasket");
		// Get values for fields
		createTarget();
	            xhr.open("POST", " ", true);
	            xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded"); // set form encoding for params
	            xhr.send(items);
	            // Set fuseaction back to download
		<cfoutput>$("###theaction#").prop("value", "c.basket_download");</cfoutput>
	        }
	        catch (e)
	        {
	            log_message("<b>[XHR] Exception: " + e + "</b>");
	        }
	    }

	// Check folder path
	function importfoldercheck(){
		// Check link
		<cfoutput>loadcontent('path_validate','#myself#c.folder_link_check&link_path=' + escape($('##uploaddir').val()));</cfoutput>
	}

</script>

