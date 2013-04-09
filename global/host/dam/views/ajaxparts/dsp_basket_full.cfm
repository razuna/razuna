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
<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
<!--- </cfif> --->
<cfoutput>
	<div id="basketstatus" style="display:none;padding:10px;font-weight:bold;"></div>
	<form name="thebasket" id="thebasket" method="post" action="#self#" target="_blank">
	<input type="hidden" name="#theaction#" value="c.basket_download">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid thumbview">
		<tr>
			<th colspan="4">
				<cfif attributes.fromshare EQ "F">
					<!--- <div style="float:left;">#myFusebox.getApplicationData().defaults.trans("files_in_basket")#</div> --->
                    <cfif qry_basket.recordcount NEQ 0>
                    	<!--- Buttons --->
                    	<div style="float:left;">
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("download")#" onclick="$('##thebasket').submit();return false;" class="button">
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_basket")#" onclick="basketsave();return false;" class="button">
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("send_basket_email")#" onclick="basketemail('#qry_basket.cart_order_email#');return false;" class="button">
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("send_basket_ftp")#" onclick="basketftp();return false;" class="button">
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#" onclick="showwindow('#myself#c.meta_export&what=basket','#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#',600,1);return false;" class="button">
                    		<input type="button" value="#myFusebox.getApplicationData().defaults.trans("delete_basket")#" onclick="showwindow('#myself#ajax.remove_basket','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("delete_basket"))#',400,1);return false;" class="button">
                    	</div>
                    	<div style="clear:both;"></div>
                    	<!--- Select All --->
                    	<!--- <div style="float:left;padding:10px 0px 0px 0px;">
                            <a href="##" id="checkall" style="text-decoration:underline;" class="ddicon">#myFusebox.getApplicationData().defaults.trans("select_all")#</a>  
						</div> --->
						<!--- <div style="float:right;">
							<div style="float:left;">
                            <a href="##" onclick="$('##basketaction').toggle();" style="text-decoration:none;" class="ddicon">#myFusebox.getApplicationData().defaults.trans("basket_actions")#</a></div>
							<div style="float:right;padding-left:2px;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##basketaction').toggle();" class="ddicon"></div>
							<div id="basketaction" class="ddselection_header" style="top:22px;">
								<p><a href="##" onclick="$('##thebasket').submit();$('##basketaction').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("download")#</a></p>
								<p><a href="##" onclick="basketemail('#qry_basket.cart_order_email#');$('##basketaction').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("send_basket_email")#</a></p>
								<p><a href="##" onclick="basketftp();$('##basketaction').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("send_basket_ftp")#</a></p>
								<p><a href="##" onclick="basketsave();$('##basketaction').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("save_basket")#</a></p>
								<p><a href="##" onclick="showwindow('#myself#c.meta_export&what=basket','#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#',600,1);$('##basketaction').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#</a></p>
								<p><a href="##" onclick="showwindow('#myself#ajax.remove_basket','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("delete_basket"))#',400,1);$('##basketaction').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("delete_basket")#</a></p>
							</div>
						</div> --->
					</cfif>
				<cfelse>
					<div style="float:left;">
						<cfif qry_basket.recordcount NEQ 0>
							<cfif qry_folder.share_order EQ "F">
								<input type="button" value="#myFusebox.getApplicationData().defaults.trans("download")#" onclick="$('##thebasket').submit();return false;" class="button">
								<input type="button" value="#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#" onclick="showwindow('#myself#c.meta_export&what=basket','#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#',600,1);return false;" class="button">
							<cfelse>
								<input type="button" value="Order the selected files below" onclick="showwindow('#myself#ajax.share_order','Order',500,1);return false;" class="button">
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
			<!--- Select All --->
			<tr>
				<td colspan="4" style="padding-top:15px;">
					<a href="##" id="checkall" style="text-decoration:underline;padding-right:10px;" class="ddicon">#myFusebox.getApplicationData().defaults.trans("select_all")#</a>
					<a href="##" id="checkorg" style="text-decoration:underline;padding-right:10px;" class="ddicon">Select/Deselect Originals</a>
					<a href="##" id="checkthumb" style="text-decoration:underline;" class="ddicon">Select/Deselect Thumbnails</a>
				</td>
			</tr>
			<cfif attributes.fromshare EQ "T" AND qry_folder.share_order EQ "T">
				<tr>
					<td colspan="4">#myFusebox.getApplicationData().defaults.trans("basket_order")#</td>
				</tr>
			</cfif>
			<!--- Show order desc --->
			<cfif qry_basket.cart_order_done NEQ "">
				<tr>
					<td colspan="4"><strong>This is a order from a user.</strong> Actually, this basket has just become your basket. Meaning, it will act as your very own basket. You can remove, add or modify the basket. You can choose what you want to do with this order with the "Actions for the basket". If you want to send the order to the user, simply choose the "eMail Basket" action.
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
					<td colspan="4">If you have finished processing the order you can change the status here: <a href="##" onclick="loadcontent('order_done','#myself#c.order_done&cart_id=#session.thecart#');">This order has been processed.</a><div id="order_done"></div></td>
				</tr>
			</cfif>
			<tr>
				<td colspan="4" style="padding:10px;"></td>
			</tr>
			<cfloop query="qry_basket">
				<cfset myid = cart_product_id>
				<cfswitch expression="#cart_file_type#">
					<!--- IMAGES --->
					<cfcase value="img">
						<tr class="list">
							<td width="1%" nowrap="true">
								<cfloop query="qry_theimage">
									<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.imagedetail#&file_id=#img_id#&what=images&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
										<cfif myid EQ img_id>
											<cfif link_kind NEQ "url">
												<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
													<img src="#cloud_url#" border="0">
												<cfelse>
													<img src="#thestorage##path_to_asset#/thumb_#img_id#.#thumb_extension#" border="0">
												</cfif>
											<cfelse>
												<img src="#link_path_url#" border="0">
											</cfif>
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
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.imagedetail#&file_id=#img_id#&what=images&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
												</td>
											</tr>
											<!--- Original --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_folder.share_dl_org EQ "T" OR qry_share_options CONTAINS "#img_id#-org-1">
													<tr>
														<td><input type="checkbox" name="artofimage" id="imgorg#myid#" value="#myid#-original" checked="true" onchange="checksel('#myid#','imgorg#myid#','img');" /></td>
														<td width="100%">Original<cfif link_kind EQ ""> #ucase(img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB) (#orgwidth#x#orgheight# pixel)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#img_id#-org-1">
													<tr>
														<td><input type="checkbox" name="artofimage" id="imgorg#myid#" value="#myid#-original" checked="true" onchange="checksel('#myid#','imgorg#myid#','img');" /></td>
														<td width="100%">Original<cfif link_kind EQ ""> #ucase(img_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB) (#orgwidth#x#orgheight# pixel)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
													</tr>
												</cfif>
											</cfif>
											<!--- Thumbnail --->
											<cfif link_kind EQ "">
												<cfif attributes.fromshare EQ "T">
													<cfif qry_share_options CONTAINS "#myid#-thumb-1">
														<tr>
															<td width="1%"><input type="checkbox" name="artofimage" id="imgt#myid#" value="#myid#-thumb" onchange="checksel('#myid#','imgt#myid#','img');" checked="checked" /></td>
															<td width="100%">#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(thumb_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#thumblength#")# MB) (#thumbwidth#x#thumbheight# pixel)</td>
														</tr>
													</cfif>
												<cfelse>
													<tr>
														<td width="1%"><input type="checkbox" name="artofimage" id="imgt#myid#" value="#myid#-thumb" onchange="checksel('#myid#','imgt#myid#','img');" checked="checked" /></td>
														<td width="100%">#myFusebox.getApplicationData().defaults.trans("preview")# #ucase(thumb_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#thumblength#")# MB) (#thumbwidth#x#thumbheight# pixel)</td>
													</tr>
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
														<td width="100%">#ucase(img_extension)# #myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel)</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#img_id#-#img_id#-1">
													<tr>
														<td><input type="checkbox" name="artofimage" id="#myid#-#img_id#" value="#myid#-#img_id#" onchange="checksel('#myid#','#myid#-#img_id#','img');" /></td>
														<td width="100%">#ucase(img_extension)# #myFusebox.getApplicationData().defaults.converttomb("#ilength#")# MB (#orgwidth#x#orgheight# pixel)</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
								</table>
							</td>
					</cfcase>
					<!--- VIDEOS --->
					<cfcase value="vid">
						<tr class="list">
							<td width="1%" nowrap="true">
								<cfloop query="qry_thevideo">
									<cfif myid EQ vid_id>
										<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.videodetail#&file_id=#vid_id#&what=files&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
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
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.videodetail#&file_id=#vid_id#&what=files&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
												</td>
											</tr>
											<!--- The Original video --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_folder.share_dl_org EQ "T" OR qry_share_options CONTAINS "#vid_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofvideo" id="vid#myid#" value="#myid#-video" checked="true" onchange="checksel('#myid#','vid#myid#','vid');" /></td>
														<td width="100%">Original<cfif link_kind NEQ "url"> #ucase(vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB) (#vwidth#x#vheight# pixel)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
													</tr>
												</cfif>																					
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#vid_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofvideo" id="vid#myid#" value="#myid#-video" checked="true" onchange="checksel('#myid#','vid#myid#','vid');" /></td>
														<td width="100%">Original<cfif link_kind NEQ "url"> #ucase(vid_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB) (#vwidth#x#vheight# pixel)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
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
														<td width="100%">#ucase(vid_extension)# #myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB (#vid_preview_width#x#vid_preview_heigth# pixel)</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#vid_id#-#vid_id#-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofvideo" id="#myid#-#vid_id#" value="#myid#-#vid_id#" onchange="checksel('#myid#','#myid#-#vid_id#','vid');" /></td>
														<td width="100%">#ucase(vid_extension)# #myFusebox.getApplicationData().defaults.converttomb("#vlength#")# MB (#vid_preview_width#x#vid_preview_heigth# pixel)</td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
								</table>
							</td>
					</cfcase>
					<!--- AUDIOS --->
					<cfcase value="aud">
						<tr class="list">
							<td width="1%" nowrap="true">
								<cfloop query="qry_theaudio">
									<cfif myid EQ aud_id>
										<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.audiodetail#&file_id=#aud_id#&what=audios&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
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
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.audiodetail#&file_id=#aud_id#&what=audios&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
												</td>
											</tr>
											<!--- The Original audio --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_folder.share_dl_org EQ "T" OR qry_share_options CONTAINS "#aud_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofaudio" id="aud#myid#" value="#myid#-audio" checked="true" onchange="checksel('#myid#','aud#myid#','aud');" /></td>
														<td width="100%">Original<cfif link_kind NEQ "url"> #ucase(aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
													</tr>											
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#aud_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofaudio" id="aud#myid#" value="#myid#-audio" checked="true" onchange="checksel('#myid#','aud#myid#','aud');" /></td>
														<td width="100%">Original<cfif link_kind NEQ "url"> #ucase(aud_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
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
														<td width="1%"><input type="checkbox" name="artofaudio" id="#myid#-#aud_id#" value="#myid#-#aud_id#" onchange="checksel('#myid#','#myid#-#aud_id#','aud');" checked="checked" /></td>
														<td width="100%">#ucase(aud_extension)# #myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB</td>
													</tr>
												</cfif>
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#aud_id#-#aud_id#-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artofaudio" id="#myid#-#aud_id#" value="#myid#-#aud_id#" onchange="checksel('#myid#','#myid#-#aud_id#','aud');" checked="checked" /></td>
														<td width="100%">#ucase(aud_extension)# #myFusebox.getApplicationData().defaults.converttomb("#aud_size#")# MB</td>
													</tr>
												</cfif>
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
										<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.filedetail#&file_id=#file_id#&what=files&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
											<!--- If it is a PDF we show the thumbnail --->
											<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND file_extension EQ "PDF">
												<img src="#cloud_url#" border="0">
											<cfelseif application.razuna.storage EQ "local" AND file_extension EQ "PDF">
												<cfset thethumb = replacenocase(file_name_org, ".pdf", ".jpg", "all")>
												<cfif FileExists("#ExpandPath("../../")#assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
													<img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" width="128" height="128" border="0">
												<cfelse>
													<img src="#thestorage##path_to_asset#/#thethumb#" width="128" border="0">
												</cfif>
											<cfelse>
												<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#file_extension#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="128" height="128" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" width="128" height="128" border="0"></cfif>
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
													<cfif attributes.fromshare EQ "F"><a href="##" onclick="showwindow('#myself##xfa.filedetail#&file_id=#file_id#&what=files&loaddiv=&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"></cfif>
													<strong>#filename#</strong>
													<cfif attributes.fromshare EQ "F"></a></cfif>
												</td>
											</tr>
											<!--- The Original --->
											<cfif attributes.fromshare EQ "T">
												<cfif qry_folder.share_dl_org EQ "T" OR qry_share_options CONTAINS "#file_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artoffile" id="doc#myid#" value="#myid#-doc" checked="true" onchange="checksel('#myid#','doc#myid#','doc');" /></td>
														<td width="100%">Original<cfif link_kind NEQ "url"> #ucase(file_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#file_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
													</tr>
												</cfif>																					
											<cfelse>
												<cfif perm NEQ "R" OR qry_share_options CONTAINS "#file_id#-org-1">
													<tr>
														<td width="1%"><input type="checkbox" name="artoffile" id="doc#myid#" value="#myid#-doc" checked="true" onchange="checksel('#myid#','doc#myid#','doc');" /></td>
														<td width="100%">Original<cfif link_kind NEQ "url"> #ucase(file_extension)# (#myFusebox.getApplicationData().defaults.converttomb("#file_size#")# MB)</cfif><cfif link_kind EQ "url"> <em>(#myFusebox.getApplicationData().defaults.trans("link_is_url")#*)</em></cfif></td>
													</tr>
												</cfif>
											</cfif>
										</cfif>
									</cfloop>
								</table>
							</td>
					</cfdefaultcase>
				</cfswitch>
				<td width="1%" align="center" nowrap="nowrap" valign="top">
					<cfif attributes.fromshare EQ "F">
						<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#myid#&what=basket_full&loaddiv=rightside','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">
					<cfelse>
						<a href="##" onclick="loadcontent('shared_basket','#myself#c.share_remove_basket&id=#myid#&fromshare=T');">
					</cfif>	
					<img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" />
					</a>
				</td>
			</tr>
			</cfloop>
		</cfif>
	</table>
	<cfif qry_basket.recordcount NEQ 0><div>* <em>#myFusebox.getApplicationData().defaults.trans("link_url_basket")#</em></div></cfif>
	</form>
</cfoutput>

<!--- When download is clicked --->
<script language="JavaScript" type="text/javascript">
	// Submit Form
	$("#thebasket").submit(function(e){
		// Get values
		var url = formaction("thebasket");
		var items = formserialize("thebasket");
		// Get values for fields
		createTarget();
		// If nothing is selected
		if ( (items.indexOf('artofvideo') == -1) && (items.indexOf('artofimage') == -1) && (items.indexOf('artofaudio') == -1) && (items.indexOf('artoffile') == -1) ){
			alert('No assets have been selected for downloading. You need to selected at least one asset!');
			$("#basketstatus").css("display","none");
			$("#basketstatus").html('');
			return false;
		}
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

	// Select All
	$('#checkall').click(function () {
		$('#thebasket :checkbox').each( function() {
			if(this.checked){
				$(this).attr('checked', false);
			}
			else{
				$(this).attr('checked', true);
			}
		})
		return false;
	});

	// Select Originals
	$('#checkorg').click(function() {
		$('#thebasket').find('[id*="imgorg"],[id*="vid"],[id*="aud"],[id*="doc"]').each( function() {
			if(this.checked){
				$(this).attr('checked', false);
			}
			else{
				$(this).attr('checked', true);
			}
		})
		return false;
	});

	// Select Thumbnails
	$('#checkthumb').click(function() {
		$('#thebasket').find('[id*="imgt"]').each( function() {
			if(this.checked){
				$(this).attr('checked', false);
			}
			else{
				$(this).attr('checked', true);
			}
		})
		return false;
	});

</script>

	