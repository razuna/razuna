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
	<cfif qry_filecount.thetotal LTE session.rowmaxpage>
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
	<cfif qry_filecount.thetotal EQ 0>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<td>
					<div style="float:left;color:red;font-weight:bold;">No assets found!</div>
					<div style="float:left;padding-left:10px;"><a href="##" onclick="showwindow('#myself#c.search_advanced&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("folder_search")#',500,1);" title="#myFusebox.getApplicationData().defaults.trans("folder_search")#">Try to search again</a></div>
				</td>
			</tr>
		</table>
	<!--- Show content of this folder --->
	<cfelse>
		<form name="searchform#attributes.thetype#" id="searchform#attributes.thetype#" action="#self#">
		<input type="hidden" name="thetype" value="all">
		<input type="hidden" name="#theaction#" value="c.folder_combined_save">
		<input type="hidden" name="listids" id="searchlistids" value="#valuelist(qry_files.qall.listid)#">
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
							<div style="float:left;" id="tooltip">
								<a href="##" onclick="loadviewsearch('');return false;" title="Thumbnail View"><img src="#dynpath#/global/host/dam/images/view-list-icons.png" border="0" width="24" height="24"></a>
								<a href="##" onclick="loadviewsearch('list');return false;" title="List View"><img src="#dynpath#/global/host/dam/images/view-list-text-3.png" border="0" width="24" height="24"></a>
								<a href="##" onclick="loadviewsearch('combined');return false;" title="Combined/Quick Edit View"><img src="#dynpath#/global/host/dam/images/view-list-details-4.png" border="0" width="24" height="24"></a>
							</div>
						</div>
						<script type="text/javascript">
							function loadviewsearch(theview){
								// Show loading bar
								$("body").append('<div id="bodyoverlay"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
								$('###attributes.thediv#').load('#myself#c.search_simple', { view: theview, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "view">#lcase(i)#:"#evaluate(i)#", </cfif></cfloop> }, function(){
									$("##bodyoverlay").remove();
								});
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
		<cfif session.view EQ "">
			<tr>
				<td style="border:0px;">
				<cfoutput query="qry_files.qall" startrow="#mysqloffset#" maxrows="#session.rowmaxpage#">
					<!--- Images --->
					<cfif kind EQ "img">
						<div class="assetbox"<cfif attributes.folder_id EQ 0> style="min-height:250px;"</cfif>>
							<cfif is_available>
								<script type="text/javascript">
								$(function() {
									$("##draggable-s#id#-#kind#").draggable({
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
									
								});
								</script>
								<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable-s#id#-#kind#" type="#id#-#kind#" class="theimg">
									<!--- Show assets --->
									<cfif link_kind NEQ "url">
										<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
											<cfif cloud_url NEQ "">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
											</cfif>
										<cfelse>
											<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#?#hashtag#" border="0">
										</cfif>
									<cfelse>
										<img src="#link_path_url#" border="0" width="120">
									</cfif>
									</div>
								</a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#id#-img" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#id#-img") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=img&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-img&thetype=#id#-img');flash_footer();return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=img','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=img');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									<cfif permfolder EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<br>
								<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
								<cfif attributes.folder_id EQ 0>
									<br>
									Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
								</cfif>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					<!--- Videos --->
					<cfelseif kind EQ "vid">
						<div class="assetbox"<cfif attributes.folder_id EQ 0> style="min-height:250px;"</cfif>>
							<cfif is_available>
								<script type="text/javascript">
								$(function() {
									$("##draggable-s#id#-#kind#").draggable({
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
								});
								</script>
								<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><div id="draggable-s#id#-#kind#" type="#id#-#kind#" class="theimg"><cfif link_kind NEQ "url"><cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix"><cfif cloud_url NEQ "">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
											</cfif><cfelse><img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0"></cfif><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0"></cfif></div></a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#id#-vid" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#id#-vid") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=vid&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-vid&thetype=#id#-vid');flash_footer();return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=vid','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=vid');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									<cfif permfolder EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<br /><br />
								<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
								<cfif attributes.folder_id EQ 0>
									<br>
									Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
								</cfif>
							<cfelse>					
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					<!--- Audios --->
					<cfelseif kind EQ "aud">
						<div class="assetbox"<cfif attributes.folder_id EQ 0> style="min-height:250px;"</cfif>>
							<cfif is_available>
								<script type="text/javascript">
								$(function() {
									$("##draggable-s#id#-#kind#").draggable({
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
								});
								</script>
								<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><div id="draggable-s#id#-#kind#" type="#id#-#kind#" class="theimg"><img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0"></div></a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#id#-aud" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#id#-aud") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=aud&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-aud&thetype=#id#-aud');flash_footer();return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=aud','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=aud');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									<cfif permfolder EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<br>
								<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
								<cfif attributes.folder_id EQ 0>
									<br>
									Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
								</cfif>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					<!--- All other files --->
					<cfelse>
						<div class="assetbox"<cfif attributes.folder_id EQ 0> style="min-height:250px;"</cfif>>
							<cfif is_available>
								<script type="text/javascript">
								$(function() {
									$("##draggable-s#id#-doc").draggable({
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
								});
								</script>
								<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
								<div id="draggable-s#id#-doc" type="#id#-doc" class="theimg">
								<!--- If it is a PDF we show the thumbnail --->
								<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND ext EQ "PDF">
									<cfif cloud_url NEQ "">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
									</cfif>
								<cfelseif application.razuna.storage EQ "local" AND ext EQ "PDF">
									<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
									<cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
										<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
									<cfelse>
										<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/#thethumb#" width="120" border="0">
									</cfif>
								<cfelse>
									<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="120" height="120" border="0"></cfif>
								</cfif>
								</div>
								</a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#id#-doc" onclick="enablesub('searchform#attributes.thetype#');"<cfif listfindnocase(session.file_id,"#id#-doc") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="#myself#c.serve_file&file_id=#id#&type=doc"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-doc&thetype=#id#-doc');flash_footer();return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=doc','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=doc');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									<cfif permfolder EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
								</cfif>
								</div>
								<br>
								<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
								<cfif attributes.folder_id EQ 0>
									<br>
									Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
								</cfif>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=#attributes.thediv#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					</cfif>
				</cfoutput>
			</td>
		</tr>
		<!--- Combined View --->
		<cfelseif session.view EQ "combined">
			<cfif attributes.folderaccess NEQ "R">
				<tr>
					<td colspan="4" align="right" style="border:0px;"><div id="updatestatusall" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveall();return false;" class="button"></td>
				</tr>
			</cfif>
			<cfoutput query="qry_files.qall" startrow="#mysqloffset#" maxrows="#session.rowmaxpage#">
				<!--- Images --->
				<cfif kind EQ "img">
					<script type="text/javascript">
					$(function() {
						$("##draggable-s#id#-#kind#").draggable({
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
					});
					</script>
					<tr class="list thumbview">
						<td valign="top" width="1%" nowrap="true"><input type="checkbox" name="file_id" value="#id#-img" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td valign="top" width="1%" nowrap="true">
							<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
							<!--- Show assets --->
							<div id="draggable-s#id#-#kind#" type="#id#-#kind#">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<cfif cloud_url NEQ "">
											<img src="#cloud_url#" border="0">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
										</cfif>
									<cfelse>
										<img src="#thestorage#/#path_to_asset#/thumb_#id#.#ext#?#hashtag#" border="0">
									</cfif>
								<cfelse>
									<img src="#link_path_url#" border="0" width="120">
								</cfif>
							</div>
							</a><br />
							#myFusebox.getApplicationData().defaults.trans("date_created")#: #dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#
							<cfif attributes.folder_id EQ 0>
								<br>
								Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
							</cfif>
						</td>
						<td valign="top" width="100%">
							<!--- User has Write access --->
							<cfif permfolder NEQ "R">
								<input type="text" name="#id#_img_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#:<br />
								<textarea name="#id#_img_desc_1" style="width:300px;height:30px;">#description#</textarea><br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#:<br />
								<textarea name="#id#_img_keywords_1" style="width:300px;height:30px;">#keywords#</textarea>
							<cfelse>
								#myFusebox.getApplicationData().defaults.trans("file_name")#: #filename#<br />
								#myFusebox.getApplicationData().defaults.trans("description")#: #description#<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#: #keywords#
							</cfif>
						</td>
						<cfif permfolder EQ "X">
							<td valign="top" width="1%" nowrap="true">
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
							</td>
						</cfif>
					</tr>
				<!--- Videos --->
				<cfelseif kind EQ "vid">
					<script type="text/javascript">
					$(function() {
						$("##draggable-s#id#-#kind#").draggable({
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
					});
					</script>
					<tr class="list">
						<td valign="top" width="1%" nowrap="true"><input type="checkbox" name="file_id" value="#id#-vid" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td valign="top" width="1%" nowrap="true">
							<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
								<div id="draggable-s#id#-#kind#" type="#id#-#kind#">
									<cfif link_kind NEQ "url">
										<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0" width="160">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0" width="128" height="128">
									</cfif>
								</div>
							</a>
							<br />
							#myFusebox.getApplicationData().defaults.trans("date_created")#: #dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#
							<cfif attributes.folder_id EQ 0>
								<br>
								Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
							</cfif>
						</td>
						<td valign="top" width="100%">
							<!--- User has Write access --->
							<cfif permfolder NEQ "R">
								<input type="text" name="#id#_vid_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#:<br />
								<textarea name="#id#_vid_desc_1" style="width:300px;height:30px;">#description#</textarea><br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#:<br />
								<textarea name="#id#_vid_keywords_1" style="width:300px;height:30px;">#keywords#</textarea>
							<cfelse>
								#myFusebox.getApplicationData().defaults.trans("file_name")#: #filename#<br />
								#myFusebox.getApplicationData().defaults.trans("description")#: #description#<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#: #keywords#
							</cfif>
						</td>
						<cfif permfolder EQ "X">
							<td valign="top" width="1%" nowrap="true">
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
							</td>
						</cfif>
					</tr>
				<!--- Audios --->
				<cfelseif kind EQ "aud">
					<script type="text/javascript">
					$(function() {
						$("##draggable-s#id#-#kind#").draggable({
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
					});
					</script>
					<tr class="list">
						<td valign="top" width="1%" nowrap="true"><input type="checkbox" name="file_id" value="#id#-aud" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td valign="top" width="1%" nowrap="true">
							<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
								<div id="draggable-s#id#-#kind#" type="#id#-#kind#">
									<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" width="128" height="128" border="0">
								</div>
							</a>
							<br />
							#myFusebox.getApplicationData().defaults.trans("date_created")#: #dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#
							<cfif attributes.folder_id EQ 0>
								<br>
								Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
							</cfif>
						</td>
						<td valign="top" width="100%">
							<!--- User has Write access --->
							<cfif permfolder NEQ "R">
								<input type="text" name="#id#_aud_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#:<br />
								<textarea name="#id#_aud_desc_1" style="width:300px;height:30px;">#description#</textarea><br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#:<br />
								<textarea name="#id#_aud_keywords_1" style="width:300px;height:30px;">#keywords#</textarea>
							<cfelse>
								#myFusebox.getApplicationData().defaults.trans("file_name")#: #filename#<br />
								#myFusebox.getApplicationData().defaults.trans("description")#: #description#<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#: #keywords#
							</cfif>
						</td>
						<cfif permfolder EQ "X">
							<td valign="top" width="1%" nowrap="true">
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
							</td>
						</cfif>
					</tr>
				<!--- All other files --->
				<cfelse>
					<script type="text/javascript">
					$(function() {
						$("##draggable-s#id#-doc").draggable({
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
					});
					</script>
					<tr class="list">
						<td valign="top" width="1%" nowrap="true"><input type="checkbox" name="file_id" value="#id#-doc" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td valign="top" width="1%" nowrap="true">
							<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
								<div id="draggable-s#id#-doc" type="#id#-doc">
									<!--- If it is a PDF we show the thumbnail --->
									<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND ext EQ "PDF">
										<cfif cloud_url NEQ "">
											<img src="#cloud_url#" border="0">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
										</cfif>
									<cfelseif application.razuna.storage EQ "local" AND ext EQ "PDF">
										<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
										<cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
											<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0">
										<cfelse>
											<img src="#thestorage##path_to_asset#/#thethumb#" width="128" border="0">
										</cfif>
									<cfelse>
										<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="128" height="128" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0"></cfif>
									</cfif>
								</div>
							</a>
							<br />
							#myFusebox.getApplicationData().defaults.trans("date_created")#: #dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#
							<cfif attributes.folder_id EQ 0>
								<br>
								Folder: <a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a>
							</cfif>
						</td>
						<td valign="top" width="100%">
							<!--- User has Write access --->
							<cfif permfolder NEQ "R">
								<input type="text" name="#id#_doc_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#:<br />
								<textarea name="#id#_doc_desc_1" style="width:300px;height:30px;">#description#</textarea><br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#:<br />
								<textarea name="#id#_doc_keywords_1" style="width:300px;height:30px;">#keywords#</textarea>
							<cfelse>
								#myFusebox.getApplicationData().defaults.trans("file_name")#: #filename#<br />
								#myFusebox.getApplicationData().defaults.trans("description")#: #description#<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#: #keywords#
							</cfif>
						</td>
						<cfif permfolder EQ "X">
							<td valign="top" width="1%" nowrap="true">
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
							</td>
						</cfif>
					</tr>
				</cfif>
			</cfoutput>
			<cfif attributes.folderaccess NEQ "R">
				<tr>
					<td colspan="4" align="right" style="border:0px;"><div id="updatestatusall2" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveall();return false;" class="button"></td>
				</tr>
			</cfif>
		<!--- List view --->
		<cfelseif session.view EQ "list">
			<tr>
				<td></td>
				<td width="100%"><b>#myFusebox.getApplicationData().defaults.trans("file_name")#</b></td>
				<cfif attributes.folder_id EQ 0>
					<td nowrap="true" align="center"><b>Folder</b></td>
				</cfif>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("assets_type")#</b></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_created")#</b></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_changed")#</b></td>
				<cfif attributes.folderaccess EQ "X">
					<td></td>
				</cfif>
			</tr>
			<cfoutput query="qry_files.qall" startrow="#mysqloffset#" maxrows="#session.rowmaxpage#">
				<!--- Images --->
				<cfif kind EQ "img">
					<tr class="list">
						<td align="center" nowrap="true" width="1%"><input type="checkbox" name="file_id" value="#id#-img" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td width="100%"><a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a></td>
						<cfif attributes.folder_id EQ 0>
							<td nowrap="true" width="1%" align="center" nowrap="nowrap"><a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a></td>
						</cfif>
						<td nowrap="true" width="1%" align="center">Image</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<cfif permfolder EQ "X">
							<td align="center" width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
						</cfif>
					</tr>
				<!--- Videos --->
				<cfelseif kind EQ "vid">
					<tr class="list">
						<td align="center" nowrap="true" width="1%"><input type="checkbox" name="file_id" value="#id#-vid" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td width="100%"><a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a></td>
						<cfif attributes.folder_id EQ 0>
							<td nowrap="true" width="1%" align="center" nowrap="nowrap"><a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a></td>
						</cfif>
						<td nowrap="true" width="1%" align="center">Video</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<cfif permfolder EQ "X">
							<td align="center" width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
						</cfif>
					</tr>
				<!--- Audios --->
				<cfelseif kind EQ "aud">
					<tr class="list">
						<td align="center" nowrap="true" width="1%"><input type="checkbox" name="file_id" value="#id#-aud" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td width="100%"><a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a></td>
						<cfif attributes.folder_id EQ 0>
							<td nowrap="true" width="1%" align="center" nowrap="nowrap"><a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a></td>
						</cfif>
						<td nowrap="true" width="1%" align="center">Audio</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<cfif permfolder EQ "X">
							<td align="center" width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
						</cfif>
					</tr>
				<!--- All other files --->
				<cfelse>
					<tr class="list">
						<td align="center" nowrap="true" width="1%"><input type="checkbox" name="file_id" value="#id#-doc" onclick="enablesub('searchform#attributes.thetype#');"></td>
						<td width="100%"><a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a></td>
						<cfif attributes.folder_id EQ 0>
							<td nowrap="true" width="1%" align="center" nowrap="nowrap"><a href="##" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#folder_id_r#&col=F');">#folder_name#</a></td>
						</cfif>
						<td nowrap="true" width="1%" align="center">Document</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<cfif permfolder EQ "X">
							<td align="center" width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=#kind#&folder_id=#folder_id_r#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
						</cfif>
					</tr>
				</cfif>
			</cfoutput>
		</cfif>
		<!--- Icon Bar --->
		<tr>
			<td colspan="6" style="border:0px;"><cfset attributes.bot = "T"><cfinclude template="dsp_icon_bar_search.cfm"></td>
		</tr>
	</table>

	</form>
	</cfif>
	<!--- JS for the combined view --->
	<script language="JavaScript" type="text/javascript">
		<cfif session.file_id NEQ "">
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
			$('##content_search' + '_' + thetab).load('index.cfm?fa=c.search_simple', { thetype: thetab, fcall: true, <cfloop list="#form.fieldnames#" index="i"><cfif i NEQ "thetype"><cfoutput>#lcase(i)#:"#evaluate(i)#"</cfoutput>, </cfif></cfloop> }, function(){
					$("##bodyoverlay").remove();
				});
		}
	</script>
</cfoutput>