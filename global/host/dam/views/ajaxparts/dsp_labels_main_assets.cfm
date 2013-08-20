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
									<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;">
										<div id="draggable#id#-#kind#" type="#id#-#kind#-all" class="theimg">
										<!--- Show assets --->
										<cfif link_kind NEQ "url">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<img src="#cloud_url#" border="0" img-tt="img-tt">
											<cfelse>
												<img src="#thestorage##path_to_asset#/thumb_#id#.#ext#" border="0">
											</cfif>
										<cfelse>
											<img src="#link_path_url#" border="0" style="max-width=400px;" img-tt="img-tt">
										</cfif>
										</div>
									</a>
									<div style="float:right;padding:6px 0px 0px 0px;">
										<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=img&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=img');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-img&thetype=#id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
									</div>
									<br /><br />
									<a href="##" onclick="showwindow('#myself##xfa.detailimg#&file_id=#id#&what=images&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
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
									});
									</script>
									<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"><div id="draggable#id#-#kind#" type="#id#-#kind#-all" class="theimg"><cfif link_kind NEQ "url"><cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix"><img src="#cloud_url#" border="0"><cfelse><img src="#thestorage##path_to_asset#/#filename_org#" border="0"></cfif><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0"></cfif></div></a>								<div style="float:right;padding:6px 0px 0px 0px;">
										<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=vid&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=vid');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-vid&thetype=#id#-vid');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
									</div>
									<br /><br />
									<a href="##" onclick="showwindow('#myself##xfa.detailvid#&file_id=#id#&what=videos&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
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
									});
									</script>
									<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"><div id="draggable#id#-#kind#" type="#id#-#kind#-all" class="theimg"><img src="#dynpath#/global/host/dam/images/icons/icon_<cfif ext EQ "mp3" OR ext EQ "wav">#ext#<cfelse>aud</cfif>.png" border="0"></div></a>
									<div style="float:right;padding:6px 0px 0px 0px;">
										<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#id#&kind=aud&folderaccess=#permfolder#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=img');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-aud&thetype=#id#-aud');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
									</div>
									<br /><br />
									<a href="##" onclick="showwindow('#myself##xfa.detailaud#&file_id=#id#&what=audios&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
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
									});
									</script>
									<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;">
									<div id="draggable#id#-doc" type="#id#-doc-all" class="theimg">
									<!--- If it is a PDF we show the thumbnail --->
									<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND (ext EQ "PDF" OR ext EQ "indd")>
										<img src="#cloud_url#" border="0" img-tt="img-tt">
									<cfelseif application.razuna.storage EQ "local" AND (ext EQ "PDF" OR ext EQ "indd")>
										<cfset thethumb = replacenocase(filename_org, ".pdf", ".jpg", "all")>
										<cfif FileExists("#attributes.assetpath#/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
											<img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" border="0">
										<cfelse>
											<img src="#dynpath#/assets/#session.hostid#/#path_to_asset#/#thethumb#" border="0" img-tt="img-tt">
										</cfif>
									<cfelse>
										<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#ext#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#ext#.png" width="120" height="120" border="0"></cfif>
									</cfif>
									</div>
									</a>
									<div style="float:right;padding:6px 0px 0px 0px;">
										<a href="#myself#c.serve_file&file_id=#id#&type=doc" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#id#&favtype=file&favkind=img');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
										<a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#id#-doc&thetype=#id#-doc');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a>
									</div>
									<br /><br />
									<a href="##" onclick="showwindow('#myself##xfa.detaildoc#&file_id=#id#&what=files&loaddiv=content&folder_id=#folder_id_r#','#Jsstringformat(filename)#',1000,1);return false;"><strong>#filename#</strong></a>
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
</cfoutput>
