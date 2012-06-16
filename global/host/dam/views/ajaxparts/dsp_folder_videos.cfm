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
	<form name="#kind#form" id="#kind#form" action="#self#" onsubmit="combinedsavevid();return false;">
	<input type="hidden" name="thetype" value="vid">
	<input type="hidden" name="#theaction#" value="c.folder_combined_save">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th width="100%" colspan="6">
				<!--- Show notification of folder is being shared --->
				<cfinclude template="inc_folder_header.cfm">
				<div style="float:right;">
					<!--- Folder Navigation (add file/tools/view) --->
					<cfset thetype = "vid">
					<cfset thexfa = "#xfa.fvideos#">
					<cfset thediv = "vid">
					<cfinclude template="dsp_folder_navigation.cfm">
				</div>
			</th>
		</tr>
		<tr>
			<td colspan="6" class="gridno"><cfinclude template="dsp_icon_bar.cfm"></td>
		</tr>
		<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
		<!--- Thubmail view --->
		<cfif session.view EQ "">
			<tr>
				<td>
					<!--- Show Subfolders --->
					<cfinclude template="inc_folder_thumbnail.cfm">
					<cfloop query="qry_files">
						<div class="assetbox">
							<cfif is_available>
								<script type="text/javascript">
								$(function() {
									$("##draggable#vid_id#").draggable({
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
								<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(vid_filename)#',1000,1);return false;">
								<div id="draggable#vid_id#" type="#vid_id#-vid" class="theimg">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<cfif cloud_url NEQ "">
											<img src="#cloud_url#" border="0">
										<cfelse>
											<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
										</cfif>
									<cfelse>
										<img src="#thestorage##path_to_asset#/#vid_name_image#?#hashtag#" border="0">
									</cfif>
								<cfelse>
									<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0">
								</cfif>
								</div>
								</a>
								<!--- 
								<!--- Show video if WMV only link to detail --->
								<cfswitch expression="#vid_extension#">
									<cfcase value="mov,3gp,mpg4,m4v,mp4,swf,flv,f4v">
										<cfif application.razuna.thedatabase EQ "oracle">
											<a class="flowplayer" href="#urlvideo#?id=#vid_id#&tabname=#session.hostdbprefix#videos&colname=video&review=#randomvalue#">
												<img src="#urlvideoimage#?id=#vid_id#&colname=video_image&tabname=#session.vidtable#&review=#randomvalue#" border="0">
											</a>
										<cfelse>
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<a class="flowplayer" href="#cloud_url_org#">
													<img src="#cloud_url#" border="0">
												</a>
											<cfelse>
												<a class="flowplayer" href="#thestorage##path_to_asset#/#vid_filename#">
													<img src="#thestorage##path_to_asset#/#vid_name_image#" border="0">
												</a>
											</cfif>
											
										</cfif>
										<script language="javascript" type="text/javascript">
											// this simple call does the magic
											flowplayer("a.flowplayer", "#dynpath#/global/videoplayer/flowplayer-3.2.7.swf", { 
											    clip: {
											    	autoBuffering: false, 
											    	autoPlay: false,
											    plugins: { 
											        controls: { 
											            all: false,  
											            play: true,  
											            scrubber: true,
											            volume: true,
											            mute: true,
											            time: true,
											            stop: true,
											            fullscreen: true
											        }
											    }
											}});
												<!--- $("a.flowplayer").flowembed("#dynpath#/global/videoplayer/flowplayer-3.2.7.swf",  {initialScale:'scale',protected:true,menuItems:[true,true,true,true,true,false],allowFullScreen:true,autoBuffering:false}); --->
										</script>
									</cfcase>
									<cfcase value="wmv,avi,mpeg,mpg,rm">
										<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#','#vid_filename#',800,600);return false;">
										<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
											<cfif cloud_url NEQ "">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
											</cfif>
										<cfelse>
											<img src="#thestorage##path_to_asset#/#vid_name_image#" border="0">
										</cfif>
										</a>
									</cfcase>
								</cfswitch> --->
								<!--- <br><a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#','#vid_filename#',800,600);return false;">#defaultsObj.trans("file_detail")#</a> --->
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#vid_id#-vid" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#vid_id#-vid") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.widget_download&file_id=#vid_id#&kind=vid','#JSStringFormat(defaultsObj.trans("download"))#',650,1);return false;"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#vid_id#-vid&thetype=#vid_id#-vid');flash_footer();return false;" title="#defaultsObj.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#vid_id#&thetype=vid','#defaultsObj.trans("send_with_email")#',600,2);return false;" title="#defaultsObj.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#vid_id#&favtype=file&favkind=vid');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<br>
								<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(vid_filename)#',1000,1);return false;"><strong>#left(vid_filename,50)#</strong></a>
							<cfelse>
								We are still working on the asset "#vid_filename#"...
								<br /><br>
								#defaultsObj.trans("date_created")#:<br>
								#dateformat(vid_create_date, "#defaultsObj.getdateformat()#")# #timeformat(vid_create_date, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					</cfloop>
				</td>
			</tr>
		<!--- View: Combined --->
		<cfelseif session.view EQ "combined">
			<cfif attributes.folderaccess NEQ "R">
				<tr>
					<td colspan="4" align="right"><div id="updatestatusvid" style="float:left;"></div><input type="button" value="#defaultsObj.trans("save_changes")#" onclick="combinedsavevid();return false;" class="button"></td>
				</tr>
			</cfif>
			<cfloop query="qry_files">
				<script type="text/javascript">
				$(function() {
					$("##draggable#vid_id#").draggable({
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
				<tr class="thumbview">
					<td valign="top" width="1%" nowrap="true"><input type="checkbox" name="file_id" value="#vid_id#-vid" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#vid_id#-vid") NEQ 0> checked="checked"</cfif>></td>
					<td valign="top" width="1%" nowrap="true">
						<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(vid_filename)#',1000,1);return false;">
							<div id="draggable#vid_id#" type="#vid_id#-vid">
								<cfif link_kind NEQ "url">
									<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
										<img src="#cloud_url#" border="0" width="160">
									<cfelse>		
										<img src="#thestorage##path_to_asset#/#vid_name_image#?#hashtag#" border="0" width="160">
									</cfif>
								<cfelse>
									<img src="#dynpath#/global/host/dam/images/icons/icon_movie.png" border="0" width="128" height="128">
								</cfif>
							</div>
						</a>
						<br />
						#defaultsObj.trans("date_created")#: #dateformat(vid_create_date, "#defaultsObj.getdateformat()#")#<!--- <br />
						#defaultsObj.trans("date_changed")#: #dateformat(vid_change_date, "#defaultsObj.getdateformat()#")# --->
					</td>
					<td valign="top" width="100%">
						<!--- User has Write access --->
						<cfif attributes.folderaccess NEQ "R">
							<input type="text" name="#vid_id#_vid_filename" value="#vid_filename#" style="width:300px;"><br />
							#defaultsObj.trans("description")#:<br />
							<textarea name="#vid_id#_vid_desc_1" style="width:300px;height:30px;">#description#</textarea><br />
							#defaultsObj.trans("keywords")#:<br />
							<textarea name="#vid_id#_vid_keywords_1" style="width:300px;height:30px;">#keywords#</textarea>
						<cfelse>
							#defaultsObj.trans("file_name")#: #vid_filename#<br />
							#defaultsObj.trans("description")#: #description#<br />
							#defaultsObj.trans("keywords")#: #keywords#
						</cfif>
					</td>
					<cfif attributes.folderaccess EQ "X">
						<td valign="top" width="1%" nowrap="true">
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#vid_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
						</td>
					</cfif>
				</tr>
			</cfloop>
			<cfif attributes.folderaccess NEQ "R">
				<tr>
					<td colspan="4" align="right"><div id="updatestatusvid2" style="float:left;"></div><input type="button" value="#defaultsObj.trans("save_changes")#" onclick="combinedsavevid();return false;" class="button"></td>
				</tr>
			</cfif>
		<!--- List view --->
		<cfelseif session.view EQ "list">
			<tr>
				<td></td>
				<td width="100%"><b>#defaultsObj.trans("file_name")#</b></td>
				<td nowrap="true" align="center"><b>#defaultsObj.trans("date_created")#</b></td>
				<td nowrap="true" align="center"><b>#defaultsObj.trans("date_changed")#</b></td>
				<cfif attributes.folderaccess EQ "X">
					<td></td>
				</cfif>
			</tr>
			<!--- Show Subfolders --->
			<cfinclude template="inc_folder_list.cfm">
			<cfloop query="qry_files">
			<tr class="list">
				<td align="center" nowrap="true" width="1%"><input type="checkbox" name="file_id" value="#vid_id#-vid" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#vid_id#-vid") NEQ 0> checked="checked"</cfif>></td>
				<td width="100%"><a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(vid_filename)#',1000,1);return false;"><strong>#vid_filename#</strong></a></td>
				<td nowrap="true" width="1%" align="center">#dateformat(vid_create_date, "#defaultsObj.getdateformat()#")#</td>
				<td nowrap="true" width="1%" align="center">#dateformat(vid_change_date, "#defaultsObj.getdateformat()#")#</td>
				<cfif attributes.folderaccess EQ "X">
					<td align="center" width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#vid_id#&what=videos&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
				</cfif>
			</tr>
			</cfloop>
		</cfif>
		<!--- Icon Bar --->
		<tr>
			<td colspan="6" class="gridno"><cfset attributes.bot = "T"><cfinclude template="dsp_icon_bar.cfm"></td>
		</tr>
	</table>
	</form>

	<!--- JS for the combined view --->
	<script language="JavaScript" type="text/javascript">
		<cfif session.file_id NEQ "">
			enablesub('#kind#form');
		</cfif>
		// Submit form
		function combinedsavevid(){
			loadinggif('updatestatusvid');
			loadinggif('updatestatusvid2');
			$("##updatestatusvid").fadeTo("fast", 100);
			$("##updatestatusvid2").fadeTo("fast", 100);
			var url = formaction("#kind#form");
			var items = formserialize("#kind#form");
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
					// Update Text
					$("##updatestatusvid").css('color','green');
					$("##updatestatusvid2").css('color','green');
					$("##updatestatusvid").css('font-weight','bold');
					$("##updatestatusvid2").css('font-weight','bold');
					$("##updatestatusvid").html("#defaultsObj.trans("success")#");
					$("##updatestatusvid2").html("#defaultsObj.trans("success")#");
					$("##updatestatusvid").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
					$("##updatestatusvid2").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
			   	}
			});
	        return false; 
		}
	</script>
</cfoutput>
