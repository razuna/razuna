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
				<div style="float:right;">
					<!--- Folder Navigation (add file/tools/view) --->
					<cfset thetype = "img">
					<cfset thexfa = "#xfa.fimages#">
					<cfset thediv = "img">
					<cfinclude template="dsp_folder_navigation.cfm">
				</div>
			</th>
		</tr>
		<tr>
			<td colspan="6" class="gridno"><cfinclude template="dsp_icon_bar.cfm"></td>
		</tr>
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
									<a href="##" onclick="showwindow('#myself#c.widget_download&file_id=#img_id#&kind=img','#JSStringFormat(myFusebox.getApplicationData().defaults.trans("download"))#',650,1);return false;"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<cfif cs.show_bottom_part><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#img_id#-img&thetype=#img_id#-img');flash_footer();return false;" title="#myFusebox.getApplicationData().defaults.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif cs.button_send_email>
										<a href="##" onclick="showwindow('#myself##xfa.sendemail#&file_id=#img_id#&thetype=img','#myFusebox.getApplicationData().defaults.trans("send_with_email")#',600,2);return false;" title="#myFusebox.getApplicationData().defaults.trans("send_with_email")#"><img src="#dynpath#/global/host/dam/images/mail-message-new-3.png" width="16" height="16" border="0" /></a>
									</cfif>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#img_id#&favtype=file&favkind=img');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									<cfif attributes.folderaccess EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<br>
								<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(img_filename)#',1000,1);return false;"><strong>#left(img_filename,50)#</strong></a>
							<cfelse>
								We are still working on the asset "#img_filename#"...
								<br /><br>
								#myFusebox.getApplicationData().defaults.trans("date_created")#:<br>
								#dateformat(img_create_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")# #timeformat(img_create_date, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					</cfloop>
				</td>
			</tr>
		<!--- View: Combined --->
		<cfelseif session.view EQ "combined">
			<cfif attributes.folderaccess NEQ "R">
				<tr>
					<td colspan="4" align="right"><div id="updatestatusimg" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveimg();return false;" class="button"></td>
				</tr>
			</cfif>
			<cfloop query="qry_files">
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
					<td valign="top" width="1%" nowrap="true"><input type="checkbox" name="file_id" value="#img_id#-img" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#img_id#-img") NEQ 0> checked="checked"</cfif>></td>
					<td valign="top" width="1%" nowrap="true">
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
						</a><br />
						#myFusebox.getApplicationData().defaults.trans("date_created")#: #dateformat(img_create_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#<!--- <br />
						#myFusebox.getApplicationData().defaults.trans("date_changed")#: #dateformat(img_change_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")# --->
					</td>
					<td valign="top" width="100%">
						<!--- User has Write access --->
						<cfif attributes.folderaccess NEQ "R">
							<input type="text" name="#img_id#_img_filename" value="#img_filename#" style="width:300px;"><br />
							#myFusebox.getApplicationData().defaults.trans("description")#:<br />
							<textarea name="#img_id#_img_desc_1" style="width:300px;height:30px;">#description#</textarea><br />
							#myFusebox.getApplicationData().defaults.trans("keywords")#:<br />
							<textarea name="#img_id#_img_keywords_1" style="width:300px;height:30px;">#keywords#</textarea>
						<cfelse>
							#myFusebox.getApplicationData().defaults.trans("file_name")#: #img_filename#<br />
							#myFusebox.getApplicationData().defaults.trans("description")#: #description#<br />
							#myFusebox.getApplicationData().defaults.trans("keywords")#: #keywords#
						</cfif>
					</td>
					<cfif attributes.folderaccess EQ "X">
						<td valign="top" width="1%" nowrap="true">
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
						</td>
					</cfif>
				</tr>
			</cfloop>
			<cfif attributes.folderaccess NEQ "R">
				<tr>
					<td colspan="4" align="right"><div id="updatestatusimg2" style="float:left;"></div><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" onclick="combinedsaveimg();return false;" class="button"></td>
				</tr>
			</cfif>
		<!--- List view --->
		<cfelseif session.view EQ "list">
			<tr>
				<td></td>
				<td width="100%"><b>#myFusebox.getApplicationData().defaults.trans("file_name")#</b></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_created")#</b></td>
				<td nowrap="true" align="center"><b>#myFusebox.getApplicationData().defaults.trans("date_changed")#</b></td>
				<cfif attributes.folderaccess EQ "X">
					<td></td>
				</cfif>
			</tr>
			<!--- Show Subfolders --->
			<cfinclude template="inc_folder_list.cfm">
			<cfloop query="qry_files">
				<tr class="list">
					<td align="center" nowrap="true" width="1%"><input type="checkbox" name="file_id" value="#img_id#-img" onclick="enablesub('#kind#form');"<cfif listfindnocase(session.file_id,"#img_id#-img") NEQ 0> checked="checked"</cfif>></td>
					<td width="100%"><a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(img_filename)#',1000,1);return false;"><strong>#img_filename#</strong></a></td>
					<td nowrap="true" width="1%" align="center">#dateformat(img_create_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
					<td nowrap="true" width="1%" align="center">#dateformat(img_change_date, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
					<cfif attributes.folderaccess EQ "X">
						<td align="center" width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#img_id#&what=images&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(myFusebox.getApplicationData().defaults.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
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
	</script>
</cfoutput>