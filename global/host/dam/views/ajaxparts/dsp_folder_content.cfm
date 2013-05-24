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
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
	<!--- If no record is in this folder --->
	<cfif qry_files.recordcount EQ 0>
		<form id="#kind#form"></form>
		
		<div style="float:left;">
			<cfloop list="#qry_breadcrumb#" delimiters=";" index="i">/ <a href="##" onclick="razunatreefocusbranch('#ListGetAt(i,3,"|")#','#ListGetAt(i,2,"|")#');loadcontent('rightside','#myself#c.folder&folder_id=#ListGetAt(i,2,"|")#');">#ListGetAt(i,1,"|")#</a> </cfloop>
		</div>
		<cfif attributes.folderaccess EQ "x">
			<cfinclude template="dsp_folder_navigation.cfm">
		</cfif>
		<br />
		<div class="panelsnew">
			<cfif qry_subfolders.recordcount EQ 0>
				<h1>#myFusebox.getApplicationData().defaults.trans("folder_is_empty")#</h1>
			<cfelse>
				<h1>#qry_foldername#</h1>
			</cfif>
			<cfif attributes.folderaccess NEQ "R">
				<cfif !(qry_user.folder_owner EQ session.theuserid AND trim(qry_foldername) EQ "my folder") OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
					<a href="##" onclick="showwindow('#myself##xfa.assetadd#&folder_id=#folder_id#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("add_your_files")#</button></a>
				<cfelseif cs.myfolder_upload>
					<a href="##" onclick="showwindow('#myself##xfa.assetadd#&folder_id=#folder_id#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("add_file"))#',650,1);return false;"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("add_your_files")#</button></a>
				</cfif>
			</cfif>
			<cfif attributes.folderaccess NEQ "R">
				<a href="##" onclick="$('##rightside').load('#myself#c.folder_new&from=list&theid=#url.folder_id#&iscol=F');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_folder_desc")#"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("create_subfolder")#</button></a>
			</cfif>
		</div>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<td style="border:0px;">
					<!--- Show Subfolders --->
					<cfloop query="qry_subfolders">
						<div class="assetbox" style="text-align:center;">
							<a href="##" onclick="razunatreefocusbranch('#folder_id_r#','#folder_id#');loadcontent('rightside','index.cfm?fa=c.folder&folder_id=#folder_id#');">
								<div class="theimg">
									<cfif directoryexists("#ExpandPath("../..")#global/host/folderthumbnail/#session.hostid#/#folder_id#")>
										<cfdirectory name="myDir" action="list" directory="#ExpandPath("../../")#global/host/folderthumbnail/#session.hostid#/#folder_id#/" type="file">
										<cfif myDir.RecordCount>
											<img src="#dynpath#/global/host/folderthumbnail/#session.hostid#/#folder_id#/#myDir.name#" border="0"><br />
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
										</cfif>
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/folder-yellow.png" border="0"><br />
									</cfif>
								</div>
								<strong>#folder_name#</strong>
							</a>
						</div>
					</cfloop>
				</td>
			</tr>
		</table>
	<!--- Show content of this folder --->
	<cfelse>
		<form name="#kind#form" id="#kind#form" action="#self#" onsubmit="combinedsaveall();return false;">
		<input type="hidden" name="kind" value="#kind#">
		<input type="hidden" name="thetype" value="all">
		<input type="hidden" name="#theaction#" value="c.folder_combined_save">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<!--- Header --->
		<tr>
			<td colspan="6">
				<!--- Show notification of folder is being shared --->
				<cfinclude template="inc_folder_header.cfm">
				<!--- If user or admin has folderaccess x --->
				<cfif attributes.folderaccess EQ "x">
					<cfinclude template="dsp_folder_navigation.cfm">
				</cfif>
			</td>
		</tr>
		<!--- Icon Bar --->
		<tr>
			<td colspan="6" style="border:0px;">
				<cfset thetype = "all">
				<cfset thexfa = "c.folder_content">
				<cfset thediv = "content">
				<cfinclude template="dsp_icon_bar.cfm">
			</td>
		</tr>
		<!--- Thumbnail --->
		<cfif session.view EQ "">
			<tr>
				<td style="border:0px;" id="selectme">
				<!--- Show Subfolders --->
				<cfinclude template="inc_folder_thumbnail.cfm">
				<cfloop query="qry_files">
					<!--- Images --->
					<cfif kind EQ "img">
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
								<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-#kind#" type="#id#-#kind#" class="theimg">
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
									<input type="checkbox" name="file_id" value="#id#-img" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-img") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=img&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-img&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=img','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=img');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<div style="clear:left;"></div>
								<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					<!--- Videos --->
					<cfelseif kind EQ "vid">
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
								});
								</script>
								<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-#kind#" type="#id#-#kind#" class="theimg">
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<cfif cloud_url NEQ "">
													<img src="#cloud_url#" border="0">
												<cfelse>
													<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
												</cfif>
											<cfelse>
												<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">
											</cfif>
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
										</cfif>
									</div>
								</a>
							<!--- <br><a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#kind#&folder_id=#attributes.folder_id#','#filename#',800,600);return false;">#myFusebox.getApplicationData().defaults.trans("file_detail")#</a> --->
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#id#-vid" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-vid") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=vid&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-vid&thetype=#id#-vid');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=vid','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=vid');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<div style="clear:left;"></div>
								<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					<!--- Audios --->
					<cfelseif kind EQ "aud">
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
								});
								</script>
								<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><div id="draggable#id#-#kind#" type="#id#-#kind#" class="theimg"><img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0"></div></a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#id#-aud" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-aud") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=aud&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-aud&thetype=#id#-aud');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=aud','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=aud');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<div style="clear:left;"></div>
								<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					<!--- All other files --->
					<cfelse>
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
								});
								</script>
								<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
								<div id="draggable#id#-doc" type="#id#-doc" class="theimg">
									<!--- If it is a PDF we show the thumbnail --->
									<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND (ext EQ "PDF" OR ext EQ "indd")>
										<cfif cloud_url NEQ "">
											<img src="#cloud_url#" border="0">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
										</cfif>
									<cfelseif application.razuna.storage EQ "local" AND (ext EQ "PDF" OR ext EQ "indd")>
										<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
										<cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
											<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
										<cfelse>
											<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/#thethumb#" border="0">
										</cfif>
									<cfelse>
										<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="120" height="120" border="0"></cfif>
									</cfif>
								</div>
								</a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#id#-doc" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-doc") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-doc&thetype=#id#-doc');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=doc','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=doc');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
								</cfif>
								</div>
								<div style="clear:left;"></div>
								<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#left(filename,50)#</strong></a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					</cfif>
				</cfloop>
			</td>
		</tr>
		<!--- Combined View --->
		<cfelseif session.view EQ "combined">
			<tr>
				<td colspan="3" align="right" style="border:0px;"><div id="updatestatusall" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveall();return false;" class="button"></td>
			</tr>
			<cfloop query="qry_files">
				<cfset labels = labels>
				<!--- Images --->
				<cfif kind EQ "img">
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
					});
					</script>
					<tr class="list thumbview">
						<td valign="top" width="1%" nowrap="true" align="center">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<!--- Show assets --->
									<div id="draggable#id#-#kind#" type="#id#-#kind#">
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
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br>
							</cfif>
							<!--- Icons --->
							<div style="padding-top:5px;width:130px;white-space:nowrap;">
								<div style="float:left;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<!--- Keywords, etc --->
						<td valign="top" width="100%">
							<div style="float:left;padding-right:10px;">
								#myFusebox.getApplicationData().defaults.trans("file_name")#<br />
								<input type="text" name="#id#_img_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#<br />
								<textarea name="#id#_img_desc_1" style="width:300px;height:30px;">#description#</textarea>
							</div>
							<div style="float:left;">
								#myFusebox.getApplicationData().defaults.trans("labels")#<br />
								<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_img#id#" onchange="razaddlabels('tags_img#id#','#id#','img');" multiple="multiple">
									<option value=""></option>
									<cfloop query="attributes.thelabelsqry">
										<option value="#label_id#"<cfif ListFind(labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
									</cfloop>
								</select>
								<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#<br />
								<textarea name="#id#_img_keywords_1" style="width:400px;height:30px;">#keywords#</textarea>
							</div>
						</td>
					</tr>
				<!--- Videos --->
				<cfelseif kind EQ "vid">
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
					});
					</script>
					<tr class="list thumbview">
						<td valign="top" width="1%" nowrap="true" align="center">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-#kind#" type="#id#-#kind#">
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<cfif cloud_url NEQ "">
													<img src="#cloud_url#" border="0">
												<cfelse>
													<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
												</cfif>
											<cfelse>
												<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">
											</cfif>
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
										</cfif>
									</div>
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br>
							</cfif>
							<!--- Icons --->
							<div style="padding-top:5px;width:130px;white-space:nowrap;">
								<div style="float:left;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<!--- Keywords, etc --->
						<td valign="top" width="100%">
							<div style="float:left;padding-right:10px;">
								#myFusebox.getApplicationData().defaults.trans("file_name")#<br />
								<input type="text" name="#id#_vid_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#<br />
								<textarea name="#id#_vid_desc_1" style="width:300px;height:30px;">#description#</textarea>
							</div>
							<div style="float:left;">
								#myFusebox.getApplicationData().defaults.trans("labels")#<br />
								<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_vid#id#" onchange="razaddlabels('tags_vid#id#','#id#','vid');" multiple="multiple">
									<option value=""></option>
									<cfloop query="attributes.thelabelsqry">
										<option value="#label_id#"<cfif ListFind(labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
									</cfloop>
								</select>
								<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#<br />
								<textarea name="#id#_vid_keywords_1" style="width:400px;height:30px;">#keywords#</textarea>	
							</div>
						</td>
					</tr>
				<!--- Audios --->
				<cfelseif kind EQ "aud">
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
					});
					</script>
					<tr class="list thumbview">
						<td valign="top" width="1%" nowrap="true" align="center">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-#kind#" type="#id#-#kind#">
										<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" width="128" height="128" border="0">
									</div>
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br>
							</cfif>
							<!--- Icons --->
							<div style="padding-top:5px;width:130px;white-space:nowrap;">
								<div style="float:left;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<!--- Keywords, etc --->
						<td valign="top" width="100%">
							<div style="float:left;padding-right:10px;">
								#myFusebox.getApplicationData().defaults.trans("file_name")#<br />
								<input type="text" name="#id#_aud_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#<br />
								<textarea name="#id#_aud_desc_1" style="width:300px;height:30px;">#description#</textarea>
							</div>
							<div style="float:left;">
								#myFusebox.getApplicationData().defaults.trans("labels")#<br />
								<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_aud#id#" onchange="razaddlabels('tags_aud#id#','#id#','aud');" multiple="multiple">
									<option value=""></option>
									<cfloop query="attributes.thelabelsqry">
										<option value="#label_id#"<cfif ListFind(labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
									</cfloop>
								</select>
								<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#<br />
								<textarea name="#id#_aud_keywords_1" style="width:400px;height:30px;">#keywords#</textarea>
							</div>
						</td>
					</tr>
				<!--- All other files --->
				<cfelse>
					<script type="text/javascript">
					$(function() {
						$("##draggable#id#-doc").draggable({
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
						<td valign="top" width="1%" nowrap="true" align="center">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-doc" type="#id#-doc">
										<!--- If it is a PDF we show the thumbnail --->
										<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND (ext EQ "PDF" OR ext EQ "indd")>
											<cfif cloud_url NEQ "">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
											</cfif>
										<cfelseif application.razuna.storage EQ "local" AND (ext EQ "PDF" OR ext EQ "indd")>
											<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
											<cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
												<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/#thethumb#" width="128" border="0">
											</cfif>
										<cfelse>
											<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="128" height="128" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0"></cfif>
										</cfif>
									</div>
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(date_create, "HH:mm")#
								<br>
							</cfif>
							<!--- Icons --->
							<div style="padding-top:5px;width:130px;white-space:nowrap;">
								<div style="float:left;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-doc');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<!--- Keywords, etc --->
						<td valign="top" width="100%">
							<div style="float:left;padding-right:10px;">
								#myFusebox.getApplicationData().defaults.trans("file_name")#<br />
								<input type="text" name="#id#_doc_filename" value="#filename#" style="width:300px;"><br />
								#myFusebox.getApplicationData().defaults.trans("description")#<br />
								<textarea name="#id#_doc_desc_1" style="width:300px;height:30px;">#description#</textarea>
							</div>
							<div style="float:left;">
								#myFusebox.getApplicationData().defaults.trans("labels")#<br />
								<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_doc#id#" onchange="razaddlabels('tags_doc#id#','#id#','doc');" multiple="multiple">
									<option value=""></option>
									<cfloop query="attributes.thelabelsqry">
										<option value="#label_id#"<cfif ListFind(labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
									</cfloop>
								</select>
								<br />
								#myFusebox.getApplicationData().defaults.trans("keywords")#<br />
								<textarea name="#id#_doc_keywords_1" style="width:400px;height:30px;">#keywords#</textarea>
							</div>
						</td>
					</tr>
				</cfif>
			</cfloop>
			<tr>
				<td colspan="4" align="right" style="border:0px;"><div id="updatestatusall2" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveall();return false;" class="button"></td>
			</tr>
		<!--- List view --->
		<cfelseif session.view EQ "list">
			<tr>
				<td></td>
				<td nowrap="true"></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("assets_type")#</b></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_created")#</b></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_changed")#</b></td>
			</tr>
			<!--- Show Subfolders --->
			<cfinclude template="inc_folder_list.cfm">
			<cfloop query="qry_files">
				<!--- Images --->
				<cfif kind EQ "img">
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
					});
					</script>
					<tr class="list thumbview">
						<td align="center">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<!--- Show assets --->
									<div id="draggable#id#-#kind#" type="#id#-#kind#">
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
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br />
							</cfif>
						</td>
						<td valign="top" width="100%">
							<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
							<br />
							<!--- Icons --->
							<div style="float:left;padding-top:5px;">
								<div style="float:left;padding-top:2px;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=images&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=list','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<td nowrap="true" width="1%" align="center" valign="top">Image</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
					</tr>
				<!--- Videos --->
				<cfelseif kind EQ "vid">
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
					});
					</script>
					<tr class="list thumbview">
						<td valign="top" width="1%" nowrap="true">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-#kind#" type="#id#-#kind#">
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<cfif cloud_url NEQ "">
													<img src="#cloud_url#" border="0">
												<cfelse>
													<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
												</cfif>
											<cfelse>
												<img src="#thestorage##path_to_asset#/#filename_org#?#hashtag#" border="0">
											</cfif>
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
										</cfif>
									</div>
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br />
							</cfif>
						</td>
						<td width="100%" valign="top">
							<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
							<br />
							<!--- Icons --->
							<div style="float:left;padding-top:5px;">
								<div style="float:left;padding-top:2px;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=videos&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=list','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<td nowrap="true" width="1%" align="center" valign="top">Video</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
					</tr>
				<!--- Audios --->
				<cfelseif kind EQ "aud">
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
					});
					</script>
					<tr class="list thumbview">
						<td valign="top" width="1%" nowrap="true">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-#kind#" type="#id#-#kind#">
										<img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" width="128" height="128" border="0">
									</div>
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br />
							</cfif>
						</td>
						<td width="100%" valign="top">
							<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
							<br />
							<!--- Icons --->
							<div style="float:left;padding-top:5px;">
								<div style="float:left;padding-top:2px;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=audios&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=list','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<td nowrap="true" width="1%" align="center" valign="top">Audio</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
					</tr>
				<!--- All other files --->
				<cfelse>
					<script type="text/javascript">
					$(function() {
						$("##draggable#id#-doc").draggable({
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
						<td valign="center">
							<cfif is_available>
								<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-doc" type="#id#-doc">
										<!--- If it is a PDF we show the thumbnail --->
										<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND (ext EQ "PDF" OR ext EQ "indd")>
											<cfif cloud_url NEQ "">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
											</cfif>
										<cfelseif application.razuna.storage EQ "local" AND (ext EQ "PDF" OR ext EQ "indd")>
											<cfset thethumb = replacenocase(filename_org, ".#ext#", ".jpg", "all")>
											<cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
												<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0">
											<cfelse>
												<img src="#thestorage##path_to_asset#/#thethumb#" width="128" border="0">
											</cfif>
										<cfelse>
											<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="128" height="128" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="128" height="128" border="0"></cfif>
										</cfif>
									</div>
								</a>
							<cfelse>
								The upload of "#filename#" is still in progress!
								<br />
							</cfif>
						</td>
						<td width="100%" valign="top">
							<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
							<br />
							<!--- Icons --->
							<div style="float:left;padding-top:5px;">
								<div style="float:left;padding-top:2px;">
									<input type="checkbox" name="file_id" value="#id#-#kind#" onclick="enablesub('allform');"<cfif listfindnocase(session.file_id,"#id#-#kind#") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding-top:2px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=#kind#&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-#kind#&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#id#&thetype=#kind#','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=#kind#');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#id#&what=files&loaddiv=content&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=list','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
							</div>
						</td>
						<td nowrap="true" width="1%" align="center" valign="top">Document</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_create, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
						<td nowrap="true" width="1%" align="center" valign="top">#dateformat(date_change, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
					</tr>
				</cfif>
			</cfloop>
		</cfif>
		<!--- Icon Bar --->
		<tr>
			<td colspan="6" style="border:0px;"><cfset attributes.bot = true><cfinclude template="dsp_icon_bar.cfm"></td>
		</tr>
	</table>
	</form>
	</cfif>
	<!--- JS for the combined view --->
	<script language="JavaScript" type="text/javascript">
		// Focus tree
		razunatreefocus('#attributes.folder_id#');
		<cfif session.file_id NEQ "">
			enablesub('#kind#form', true);
		</cfif>
		// Submit form
		function combinedsaveall(){
			loadinggif('updatestatusall');
			loadinggif('updatestatusall2');
			$("##updatestatusall").fadeTo("fast", 100);
			$("##updatestatusall2").fadeTo("fast", 100);
			var url = formaction("#kind#form");
			var items = formserialize("#kind#form");
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
		<cfif session.view EQ "combined">
			// Activate Chosen
			$(".chzn-select").chosen();
		</cfif>
		$(document).ready(function() {
			$("###kind#form ##selectme").selectable({
				cancel: 'a,:input',
				stop: function(event, ui) {
					var fileids = '';
					$( ".ui-selected input[name='file_id']", this ).each(function() {
						fileids += $(this).val() + ',';
					});
					getselected#kind#(fileids);
					// Now uncheck all
					$('###kind#form :checkbox').attr('checked', false);
				}
			});
		});
		function getselected#kind#(fileids){
			// Get all that are selected
			// alert(fileids);
			$('##div_forall').load('index.cfm?fa=c.store_file_values',{file_id:fileids});
			enablefromselectable('#kind#form');
		}
	</script>
</cfoutput>