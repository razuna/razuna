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
	<form name="#kind#form" id="#kind#form" action="#self#" onsubmit="combinedsaveimg();return false;">
	<input type="hidden" name="thetype" value="img">
	<input type="hidden" name="#theaction#" value="c.folder_combined_save">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th width="100%" colspan="6">
				<!--- Show notification of folder is being shared --->
				<cfinclude template="inc_folder_header.cfm">
				<cfif attributes.folderaccess EQ "x">
					<cfinclude template="dsp_folder_navigation.cfm">
				</cfif>
			</th>
		</tr>
		<tr>
			<cfset thetype = "img">
			<cfset thexfa = "#xfa.fimages#">
			<cfset thediv = "img">
			<td colspan="6" class="gridno"><cfinclude template="dsp_icon_bar.cfm"></td>
		</tr>
		<!--- Thubmail view --->
		<cfif session.view EQ "">
			<tr>
				<td id="selectme">
					<!--- Show Subfolders --->
					<cfinclude template="inc_folder_thumbnail.cfm">
					<cfloop query="qry_files">
						<div class="assetbox">
							<cfif is_available>
								<script type="text/javascript">
								$(function() {
									$("##draggable#img_id#").draggable({
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
								<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(img_filename)#',1000,1);return false;">
									<div id="draggable#img_id#" type="#img_id#-img" class="theimg">
										<!--- Show assets --->
										<cfif link_kind EQ "">
											<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
												<cfif cloud_url NEQ "">
													<img src="#cloud_url#" border="0">
												<cfelse>
													<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
												</cfif>
											<cfelse>
												<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/thumb_#img_id#.#thumb_extension#?#hashtag#" border="0">
											</cfif>
										<cfelse>
											<img src="#link_path_url#" border="0">
										</cfif>
									</div>
								</a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#img_id#-img" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#img_id#-img") NEQ 0> checked="checked"</cfif>>
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#img_id#&kind=img&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#img_id#-img&thetype=#img_id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#img_id#&thetype=img','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif cs.show_bottom_part>
										<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#img_id#&favtype=file&favkind=img');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									</cfif>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=images&loaddiv=img&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<div style="clear:left;"></div>
								<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(img_filename)#',1000,1);return false;"><strong>#left(img_filename,50)#</strong></a>
							<cfelse>
								The upload of "#img_filename#" is still in progress!
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(img_create_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(img_create_time, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=images&loaddiv=img&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					</cfloop>
				</td>
			</tr>
		<!--- View: Combined --->
		<cfelseif session.view EQ "combined">
			<tr>
				<td colspan="4" align="right"><div id="updatestatusimg" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveimg();return false;" class="button"></td>
			</tr>
			<cfloop query="qry_files">
				<cfset labels = labels>
				<script type="text/javascript">
				$(function() {
					$("##draggable#img_id#").draggable({
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
					<td valign="top" width="1%" nowrap="true">
						<cfif is_available>
							<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(img_filename)#',1000,1);return false;">
								<div id="draggable#img_id#" type="#img_id#-img">
									<!--- Show assets --->
									<cfif link_kind EQ "">
										<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
											<cfif cloud_url NEQ "">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
											</cfif>
										<cfelse>
											<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/thumb_#img_id#.#thumb_extension#?#hashtag#" border="0">
										</cfif>
									<cfelse>
										<img src="#link_path_url#" border="0" width="120">
									</cfif>
								</div>
							</a>
						<cfelse>
							The upload of "#img_filename#" is still in progress!
							<br /><br>
							#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
							#dateformat(img_create_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(img_create_time, "HH:mm")#
							<br>
						</cfif>
						<!--- Icons --->
						<div style="padding-top:5px;width:130px;white-space:nowrap;">
							<div style="float:left;">
								<input type="checkbox" name="file_id" value="#img_id#-aud" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#img_id#-aud") NEQ 0> checked="checked"</cfif>>
							</div>
							<div style="float:right;padding-top:2px;">
								<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#img_id#&kind=aud&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
								<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#img_id#-aud&thetype=#img_id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
								<cfif cs.button_send_email>
									<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#img_id#&thetype=aud','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
								</cfif>
								<cfif cs.show_bottom_part>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#img_id#&favtype=file&favkind=aud');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
								</cfif>
								<cfif attributes.folderaccess EQ "X">
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=audios&loaddiv=img&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=combined','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
								</cfif>
							</div>
						</div>
					</td>
					<!--- Keywords, etc --->
					<td valign="top" width="100%">
						<div style="float:left;padding-right:10px;">
							#myFusebox.getApplicationData().defaults.trans("file_name")#<br />
							<input type="text" name="#img_id#_img_filename" value="#img_filename#" style="width:300px;"><br />
							#myFusebox.getApplicationData().defaults.trans("description")#<br />
							<textarea name="#img_id#_img_desc_1" style="width:300px;height:30px;">#description#</textarea>
						</div>
						<div style="float:left;">
							#myFusebox.getApplicationData().defaults.trans("labels")#<br />
							<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_img_qe_#img_id#" onchange="razaddlabels('tags_img_qe_#img_id#','#img_id#','img');" multiple="multiple">
								<option value=""></option>
								<cfloop query="attributes.thelabelsqry">
									<option value="#label_id#"<cfif ListFind(labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
								</cfloop>
							</select>
							<br />
							#myFusebox.getApplicationData().defaults.trans("keywords")#<br />
							<textarea name="#img_id#_img_keywords_1" style="width:400px;height:30px;">#keywords#</textarea>									
						</div>
					</td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="4" align="right"><div id="updatestatusimg2" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveimg();return false;" class="button"></td>
			</tr>
		<!--- List view --->
		<cfelseif session.view EQ "list">
			<tr>
				<td></td>
				<td nowrap="true"></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_created")#</b></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_changed")#</b></td>
			</tr>
			<!--- Show Subfolders --->
			<cfinclude template="inc_folder_list.cfm">
			<cfloop query="qry_files">
				<script type="text/javascript">
				$(function() {
					$("##draggable#img_id#-img").draggable({
						appendTo: 'body',
						cursor: 'move',
						addClasses: false,
						iframeFix: true,
						opacity: 0.25,
						zIndex: 5000,
						helper: 'clone',
						start: function() {
						},
						stop: function() {
						}
					});
				});
				</script>
				<tr class="list thumbview">
					<td align="center">
						<cfif is_available>
							<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(img_filename)#',1000,1);return false;">
								<!--- Show assets --->
								<div id="draggable#img_id#-img" type="#img_id#-img">
									<cfif link_kind NEQ "url">
										<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
											<cfif cloud_url NEQ "">
												<img src="#cloud_url#" border="0">
											<cfelse>
												<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
											</cfif>
										<cfelse>
											<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/thumb_#img_id#.#thumb_extension#?#hashtag#" border="0">
										</cfif>
									<cfelse>
										<img src="#link_path_url#" border="0" width="120">
									</cfif>
								</div>
							</a>
						<cfelse>
							The upload of "#img_filename#" is still in progress!
							<br />
						</cfif>
					</td>
					<td width="100%" valign="top">
						<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(img_filename)#',1000,1);return false;"><strong>#img_filename#</strong></a>
						<br />
						<!--- Icons --->
						<div style="float:left;padding-top:5px;">
							<div style="float:left;padding-top:2px;">
								<input type="checkbox" name="file_id" value="#img_id#-img" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#img_id#-img") NEQ 0> checked="checked"</cfif>> 
							</div>
							<div style="float:right;padding-top:2px;">
								<a href="##" onclick="showwindow('#myself#c.file_download&file_id=#img_id#&kind=img&folderaccess=#attributes.folderaccess#','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("download_to_desktop")#"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
								<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#img_id#-img&thetype=#img_id#-img');flash_footer('basket');return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
								<cfif cs.button_send_email>
									<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#img_id#&thetype=img','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
								</cfif>
								<cfif cs.show_bottom_part>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#img_id#&favtype=file&favkind=img');flash_footer();return false;" title="Add to favorites"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
								</cfif>
								<cfif attributes.folderaccess EQ "X">
									<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=images&loaddiv=img&folder_id=#attributes.folder_id#&showsubfolders=#attributes.showsubfolders#&view=list','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;" title="#myFusebox.getApplicationData().defaults.trans("remove")#"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
								</cfif>
							</div>
						</div>
					</td>
					<td nowrap="true" width="1%" align="center" valign="top">#dateformat(img_create_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
					<td nowrap="true" width="1%" align="center" valign="top">#dateformat(img_change_time, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
				</tr>
			</cfloop>
		</cfif>
		<!--- Icon Bar --->
		<tr>
			<td colspan="6" class="gridno"><cfset attributes.bot = true><cfinclude template="dsp_icon_bar.cfm"></td>
		</tr>
	</table>
	</form>

	<!--- JS for the combined view --->
	<script language="JavaScript" type="text/javascript">
		<cfif session.file_id NEQ "">
			enablesub('#kind#form');
		</cfif>
		// Submit form
		function combinedsaveimg(){
			loadinggif('updatestatusimg');
			loadinggif('updatestatusimg2');
			$("##updatestatusimg").fadeTo("fast", 100);
			$("##updatestatusimg2").fadeTo("fast", 100);
			var url = formaction("#kind#form");
			var items = formserialize("#kind#form");
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
					// Update Text
					$("##updatestatusimg").css('color','green');
					$("##updatestatusimg2").css('color','green');
					$("##updatestatusimg").css('font-weight','bold');
					$("##updatestatusimg2").css('font-weight','bold');
					$("##updatestatusimg").html("#myFusebox.getApplicationData().defaults.trans("success")#");
					$("##updatestatusimg2").html("#myFusebox.getApplicationData().defaults.trans("success")#");
					$("##updatestatusimg").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
					$("##updatestatusimg2").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
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
						fileids += $(this).val() + ','
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