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
<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
	<cfset isadmin = true>
<cfelse>
	<cfset isadmin = false>
</cfif>
<cfoutput>
	<cfset uniqueid = createuuid()>
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<form name="label_form" id="label_form">
	<input type="hidden" id="searchlistids" value="#valuelist(qry_labels_assets.fileidwithtype)#">
	<input type="hidden" name="editids" id="editids" value="#session.search.edit_ids#">
	
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th>#myFusebox.getApplicationData().defaults.trans("label")#: #qry_labels_text#</th>
		</tr>
		<tr>
			<td colspan="6" style="border:0px;">
				<cfset thetype = "all">
				<cfset thediv = "lab_content">
				<cfinclude template="dsp_label_pagination.cfm">
			</td>
		</tr>
		<tr>
			<td style="border:0px;">
				<cfloop query="qry_labels_assets">
					<!--- Images --->
					<cfif kind EQ "img">
						<cfif permfolder NEQ "">
							<div class="assetbox" id="#fileidwithtype#">
								<cfif is_available>
									<script type="text/javascript">
									$(function() {
										$("##draggable#id#-#kind#").draggable({
											appendTo: 'body',
											cursor: 'move',
											addClasses: false,
											iframeFix: true,
											opacity: 0.25,
											zIndex: 5000,
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
										<cfif isdate(expiry_date) AND expiry_date LT now()>
											$('##iconbar_#id#').css('display','none');
										</cfif>
									});
									</script>
									<!--- custom metadata fields to show --->
									<cfloop list="#attributes.cs_place.top.image#" index="m" delimiters=",">
										<cfif m CONTAINS "_filename">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','',1000,1);return false;"><strong>#evaluate(listlast(m," "))#</strong></a>
										<cfelseif m CONTAINS "_size">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
										<cfelseif m CONTAINS "_time">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<cfelseif m CONTAINS "expiry_date">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
										<cfelse>
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#evaluate(listlast(m," "))#
										</cfif>
										<br />
									</cfloop>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_top.image,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
									<br/><br/>
									<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','#Jsstringformat(filename)#',1000,1);return false;">
										<div id="draggable#id#-#kind#" type="#id#-#kind#" class="theimg">
										<!--- Show assets --->
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0" img-tt="img-tt">
											<cfelse>
												<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#?#uniqueid#" border="0">
											</cfif>
										<cfelse>
											<img src="#link_path_url#" border="0" style="max-width=400px;" img-tt="img-tt">
										</cfif>
										</div>
									</a>
									<!--- Icons --->
									<div style="float:left;padding:6px 0px 3px 0px;">
										<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('label_form');"<cfif structKeyExists(session,"file_id") AND listfindnocase(session.file_id,"#id#-img") NEQ 0> checked="checked"</cfif>>
									</div>	
									<div style="float:right;padding:6px 0px 0px 0px;">
										<div id="iconbar_#id#" style="display:inline">
											<cfif permfolder EQ "R" OR permfolder EQ "n">
												<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
											</cfif>
											<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=img&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
											<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-img&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=img','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.show_favorites_part>
												<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=img');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif permfolder NEQ "R">
												<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
													<a href="##" onclick="storeone('#id#-img');showwindow('#myself#ajax.trash_record&id=#id#&label_id=#attributes.label_id#&what=images&loaddiv=labels&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=#attributes.view#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
												</cfif>
											</cfif>
										</div>
									</div>
									<br /><br />
									<!--- custom metadata fields to show --->
									<cfif attributes.cs.images_metadata EQ "" OR ( NOT prefs.set2_upc_enabled AND attributes.cs.images_metadata EQ "img_upc_number AS cs_img_upc_number" )>
										<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
										<br /><br />
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
									<cfelse>
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
										<br /><br />
										<cfloop list="#attributes.cs_place.bottom.image#" index="m" delimiters=",">
											<cfif m CONTAINS "_filename">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','',1000,1);return false;"><strong>#evaluate(listlast(m," "))#</strong></a>
											<cfelseif m CONTAINS "_size">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
											<cfelseif m CONTAINS "_time">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
											<cfelseif m CONTAINS "expiry_date">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
											<cfelse>
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#evaluate(listlast(m," "))#
											</cfif>
											<br />
										</cfloop>
									</cfif>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_bottom.image,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
								</cfif>
							</div>
						</cfif>
					<!--- Videos --->
					<cfelseif kind EQ "vid">
						<cfif permfolder NEQ "">
							<div class="assetbox">
								<cfif is_available>
									<script type="text/javascript">
									$(function() {
										$("##draggable#id#-#kind#").draggable({
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
										<cfif isdate(expiry_date) AND expiry_date LT now()>
											$('##iconbar_#id#').css('display','none');
										</cfif>
									});
									</script>
									<cfloop list="#attributes.cs_place.top.video#" index="m" delimiters=",">
										<cfif m CONTAINS "_filename">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','',1000,1);return false;"><strong>#filename#</strong></a>
										<cfelseif m CONTAINS "_size">
											<cfif evaluate(listlast(m," ")) NEQ "">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
											</cfif>
										<cfelseif m CONTAINS "_time">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<cfelseif m CONTAINS "expiry_date">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
										<cfelse>
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#evaluate(listlast(m," "))#
										</cfif>
										<br />
									</cfloop>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_top.video,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
									<br/><br/>
									<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','#Jsstringformat(filename)#',1000,1);return false;"><div id="draggable#id#-#kind#" type="#id#-#kind#" class="theimg"><cfif link_kind NEQ "url"><cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix"><img src="#cloud_url#" border="0"><cfelse><img src="#thestorage##path_to_asset#/#filename_org#?#uniqueid#" border="0"></cfif><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0"></cfif></div></a>
									<!--- Icons --->
									<div style="float:left;padding:6px 0px 3px 0px;">
										<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('label_form');"<cfif structKeyExists(session,"file_id") AND listfindnocase(session.file_id,"#id#-vid") NEQ 0> checked="checked"</cfif>>
									</div>	
									<div style="float:right;padding:6px 0px 0px 0px;">
										<div id="iconbar_#id#" style="display:inline">
											<cfif permfolder EQ "R" OR permfolder EQ "n">
												<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
											</cfif>
											<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=vid&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
											<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-vid&thetype=#id#-vid');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=vid','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.show_favorites_part>
												<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=vid');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif permfolder NEQ "R">
												<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
													<a href="##" onclick="storeone('#id#-vid');showwindow('#myself#ajax.trash_record&id=#id#&label_id=#attributes.label_id#&what=videos&loaddiv=labels&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=#attributes.view#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
												</cfif>
											</cfif>
										</div>
									</div>
									<br /><br />
									<!--- custom metadata fields to show --->
									<cfif attributes.cs.videos_metadata EQ "" OR ( NOT prefs.set2_upc_enabled AND attributes.cs.videos_metadata EQ "vid_upc_number AS cs_vid_upc_number")>
										<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#','',1000,1);return false;"><strong>#filename#</strong></a>
										<br />
										<br />
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
									<cfelse>
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
										<br />
										<br />
										<cfloop list="#attributes.cs_place.bottom.video#" index="m" delimiters=",">
											<cfif m CONTAINS "_filename">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','',1000,1);return false;"><strong>#filename#</strong></a>
											<cfelseif m CONTAINS "_size">
												<cfif evaluate(listlast(m," ")) NEQ "">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
												</cfif>
											<cfelseif m CONTAINS "_time">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
											<cfelseif m CONTAINS "expiry_date">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
											<cfelse>
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#evaluate(listlast(m," "))#
											</cfif>
											<br />
										</cfloop>
									</cfif>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_bottom.video,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
								<cfelse>					
									The upload of "#filename#" is still in progress!
									<br /><br>
									#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
									#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
									<br><br>
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
								</cfif>
							</div>
						</cfif>
					<!--- Audios --->
					<cfelseif kind EQ "aud">
						<cfif permfolder NEQ "">
							<div class="assetbox">
								<cfif is_available>
									<script type="text/javascript">
									$(function() {
										$("##draggable#id#-#kind#").draggable({
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
										<cfif isdate(expiry_date) AND expiry_date LT now()>
											$('##iconbar_#id#').css('display','none');
										</cfif>
									});
									</script>
									<cfloop list="#attributes.cs_place.top.audio#" index="m" delimiters=",">
										<cfif m CONTAINS "_filename">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#','',1000,1);return false;"><strong>#filename#</strong></a>
										<cfelseif m CONTAINS "_size">
											<cfif evaluate(listlast(m," ")) NEQ "">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
											</cfif>
										<cfelseif m CONTAINS "_time">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<cfelseif m CONTAINS "expiry_date">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
										<cfelse>
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#evaluate(listlast(m," "))#
										</cfif>
										<br />
									</cfloop>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_top.audio,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
									<br/><br/>
									<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','#Jsstringformat(filename)#',1000,1);return false;"><div id="draggable#id#-#kind#" type="#id#-#kind#" class="theimg"><img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0"></div></a>
									<!--- Icons --->
									<div style="float:left;padding:6px 0px 3px 0px;">
										<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('label_form');"<cfif structKeyExists(session,"file_id") AND listfindnocase(session.file_id,"#id#-img") NEQ 0> checked="checked"</cfif>>
									</div>	
									<div style="float:right;padding:6px 0px 0px 0px;">
										<div id="iconbar_#id#" style="display:inline">
											<cfif permfolder EQ "R" OR permfolder EQ "n">
												<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
											</cfif>
											<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=aud&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
											<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-aud&thetype=#id#-aud');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=aud','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.show_favorites_part>
												<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=aud');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif permfolder NEQ "R">
												<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
													<a href="##" onclick="storeone('#id#-aud');showwindow('#myself#ajax.trash_record&id=#id#&label_id=#attributes.label_id#&what=audios&loaddiv=labels&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=#attributes.view#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
												</cfif>
											</cfif>
										</div>
									</div>
									<br /><br />
									<!--- custom metadata fields to show --->
									<cfif attributes.cs.audios_metadata EQ "" OR (NOT prefs.set2_upc_enabled AND attributes.cs.audios_metadata EQ "aud_upc_number AS cs_aud_upc_number")>
										<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=content&folder_id=#folder_id_r#','',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
										<br />
										<br />
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
									<cfelse>
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
										<br />
										<br />
										<cfloop list="#attributes.cs_place.bottom.audio#" index="m" delimiters=",">
											<cfif m CONTAINS "_filename">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#','',1000,1);return false;"><strong>#filename#</strong></a>
											<cfelseif m CONTAINS "_size">
												<cfif evaluate(listlast(m," ")) NEQ "">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
												</cfif>
											<cfelseif m CONTAINS "_time">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
											<cfelseif m CONTAINS "expiry_date">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
											<cfelse>
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#evaluate(listlast(m," "))#
											</cfif>
											<br />
										</cfloop>
									</cfif>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_bottom.audio,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
								<cfelse>
									The upload of "#filename#" is still in progress!
									<br /><br />
									#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
									#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
									<br><br>
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
								</cfif>
							</div>
						</cfif>
					<!--- All other files --->
					<cfelse>
						<cfif permfolder NEQ "">
							<div class="assetbox">
								<cfif is_available>
									<script type="text/javascript">
									$(function() {
										$("##draggable#id#-doc").draggable({
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
										<cfif isdate(expiry_date) AND expiry_date LT now()>
											$('##iconbar_#id#').css('display','none');
										</cfif>
									});
									</script>
									<cfloop list="#attributes.cs_place.top.file#" index="m" delimiters=",">
										<cfif m CONTAINS "_filename">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#','',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
										<cfelseif m CONTAINS "_size">
											<cfif evaluate(listlast(m," ")) NEQ "">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
											</cfif>
										<cfelseif m CONTAINS "_time">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
										<cfelseif m CONTAINS "expiry_date">
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
										<cfelse>
											<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
											#evaluate(listlast(m," "))#
										</cfif>
										<br />
									</cfloop>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_top.file,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
									<br/><br/>
									<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#&labelview=yes','#Jsstringformat(filename)#',1000,1);return false;">
										<div id="draggable#id#-doc" type="#id#-doc" class="theimg">
											<!--- Show the thumbnail --->											
											<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
											<cfif application.razuna.storage EQ "amazon" AND cloud_url NEQ "">
												<img src="#cloud_url#" border="0" img-tt="img-tt">
											<cfelseif application.razuna.storage EQ "local" AND FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") >
												<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#?#uniqueid#" border="0" img-tt="img-tt">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0" width="128" height="128" onerror = "this.src='#dynpath#/global/host/dam/images/icons/icon_txt.png'">
											</cfif>
										</div>
									</a>
									<!--- Icons --->
									<div style="float:left;padding:6px 0px 3px 0px;">
										<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('label_form');"<cfif structKeyExists(session,"file_id") AND listfindnocase(session.file_id,"#id#-doc") NEQ 0> checked="checked"</cfif>>
									</div>	
									<div style="float:right;padding:6px 0px 0px 0px;">
										<div id="iconbar_#id#" style="display:inline">
											<cfif permfolder EQ "R" OR permfolder EQ "n">
												<img src="#dynpath#/global/host/dam/images/eye.png" width="20" height="20" border="0" />
											</cfif>
											<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=doc&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
											<cfif cs.show_basket_part AND cs.button_basket AND (isadmin OR cs.btn_basket_slct EQ "" OR listfind(cs.btn_basket_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_basket_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-doc&thetype=#id#-doc');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.button_send_email AND (isadmin OR cs.btn_email_slct EQ "" OR listfind(cs.btn_email_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.btn_email_slct,session.thegroupofuser) NEQ "")>
												<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=doc','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif cs.show_favorites_part>
												<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=doc');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
											</cfif>
											<cfif permfolder NEQ "R">
												<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
													<a href="##" onclick="storeone('#id#-doc');showwindow('#myself#ajax.trash_record&id=#id#&label_id=#attributes.label_id#&what=files&loaddiv=labels&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=#attributes.view#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("trash"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("trash")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
												</cfif>
											</cfif>
										</div>
									</div>
									<br /><br />
									<!--- custom metadata fields to show --->
									<cfif attributes.cs.files_metadata EQ "" OR (NOT prefs.set2_upc_enabled AND attributes.cs.files_metadata EQ "file_upc_number AS cs_file_upc_number")>
										<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#','',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
										<br />
										<br />
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
									<cfelse>
										Folder: <a href="##" onclick="goToFolder('#folder_id_r#')">#folder_name#</a>
										<br />
										<br />
										<cfloop list="#attributes.cs_place.bottom.file#" index="m" delimiters=",">
											<cfif m CONTAINS "_filename">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#','',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
											<cfelseif m CONTAINS "_size">
												<cfif evaluate(listlast(m," ")) NEQ "">
													<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
													#myFusebox.getApplicationData().global.converttomb('#evaluate(listlast(m," "))#')# MB
												</cfif>
											<cfelseif m CONTAINS "_time">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
											<cfelseif m CONTAINS "expiry_date">
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#dateformat(evaluate(listlast(m," ")), "#myFusebox.getApplicationData().defaults.getdateformat()#")#
											<cfelse>
												<span class="assetbox_title">#myFusebox.getApplicationData().defaults.trans("#listlast(m," ")#")#</span>
												#evaluate(listlast(m," "))#
											</cfif>
											<br />
										</cfloop>
									</cfif>
									<!--- Show custom fields here (its a list) --->
									<cfloop list="#customfields#" index="i" delimiters=",">
										<cfif listfind (attributes.cs_place.cf_bottom.file,gettoken(i,2,"|"))>
											<br />
											<!--- Get label --->
											<cfset cflabel = listFirst(i,"|")>
											<!--- Get value --->
											<cfset cfvalue = listlast(i,"|")>
											<!--- Output --->
											<span class="assetbox_title">#cflabel#:</span>
											<cfif cflabel NEQ cfvalue>
												#cfvalue#
											</cfif>
										</cfif>
									</cfloop>
								<cfelse>
									The upload of "#filename#" is still in progress!
									<br /><br />
									#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
									#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
									<br /><br />
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
								</cfif>
							</div>
						</cfif>
					</cfif>
				</cfloop>
			</td>
		</tr>
		<tr>
			<td colspan="6" style="border:0px;"><cfset attributes.bot = true><cfinclude template="dsp_label_pagination.cfm"></td>
		</tr>
	</table>

	</form>
</cfoutput>