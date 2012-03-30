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
	<form name="#kind#form" id="#kind#form" action="#self#" onsubmit="combinedsavedoc();return false;">
	<input type="hidden" name="kind" value="#kind#">
	<input type="hidden" name="thetype" value="doc">
	<input type="hidden" name="#theaction#" value="c.folder_combined_save">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th width="100%" colspan="6">
				<!--- Show notification of folder is being shared --->
				<cfinclude template="inc_folder_header.cfm">
				<div style="float:right;">
					<!--- Folder Navigation (add file/tools/view) --->
					<cfset thetype = "#kind#">
					<cfset thexfa = "c.folder_files">
					<cfset thediv = "#kind#">
					<cfinclude template="dsp_folder_navigation.cfm">
				</div>
			</th>
		</tr>
		<tr>
			<td colspan="6" class="gridno"><cfinclude template="dsp_icon_bar.cfm"></td>
		</tr>
		<!--- The Icon view --->
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
									$("##draggable#file_id#").draggable({
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
								<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(file_name)#',1000,1);return false;">
								<div id="draggable#file_id#" type="#file_id#-doc" class="theimg">
								<!--- If it is a PDF we show the thumbnail --->
								<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND file_extension EQ "PDF">
									<cfif cloud_url NEQ "">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
									</cfif>
								<cfelseif application.razuna.storage EQ "local" AND file_extension EQ "PDF">
									<cfset thethumb = replacenocase(file_name_org, ".pdf", ".jpg", "all")>
									<cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
										<img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" border="0">
									<cfelse>
										<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#" border="0">
									</cfif>
								<cfelse>
									<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#file_extension#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" border="0"></cfif>
								</cfif>
								</div>
								</a>
								<div style="float:left;padding:3px 0px 3px 0px;">
									<input type="checkbox" name="file_id" value="#file_id#-doc" onclick="enablesub('#kind#form');">
								</div>
								<div style="float:right;padding:6px 0px 0px 0px;">
									<img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="16" height="16" border="0" />
									<a href="#myself#c.serve_file&file_id=#file_id#&type=doc"><img src="#dynpath#/global/host/dam/images/go-down.png" width="16" height="16" border="0" /></a>
									<a href="##" onclick="loadcontent('thedropfav','#myself#c.favorites_put&favid=#file_id#&favtype=file&favkind=doc');flash_footer();return false;"><img src="#dynpath#/global/host/dam/images/favs_16.png" width="16" height="16" border="0" /></a>
									<cfif !application.razuna.custom.enabled OR (application.razuna.custom.enabled AND application.razuna.custom.show_bottom_part)><a href="##" onclick="loadcontent('thedropbasket','#myself#c.basket_put&file_id=#file_id#-doc&thetype=#file_id#-doc');flash_footer();return false;" title="#defaultsObj.trans("put_in_basket")#"><img src="#dynpath#/global/host/dam/images/basket-put.png" width="16" height="16" border="0" /></a></cfif>
									<cfif #session.folderaccess# EQ "X">
										<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
									</cfif>
								</div>
								<br>
								<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(file_name)#',1000,1);return false;"><strong>#left(file_name,50)#</strong></a>
							<cfelse>
								We are still working on the asset "#file_name#"...
								<br /><br>
								#defaultsObj.trans("date_created")#:<br>
								#dateformat(file_create_date, "#defaultsObj.getdateformat()#")# #timeformat(file_create_date, "HH:mm")#
								<br><br>
								<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;">Delete</a>
							</cfif>
						</div>
					</cfloop>
				</td>
			</tr>
		<!--- View: Combined --->
		<cfelseif session.view EQ "combined">
			<cfif #session.folderaccess# NEQ "R">
				<tr>
					<td colspan="4" align="right"><div id="updatestatusdoc" style="float:left;"></div><input type="button" value="#defaultsObj.trans("save_changes")#" onclick="combinedsavedoc();return false;" class="button"></td>
				</tr>
			</cfif>
			<cfloop query="qry_files">
				<script type="text/javascript">
				$(function() {
					$("##draggable#file_id#").draggable({
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
				<tr>
					<td valign="top" width="1%" nowrap="true"><input type="checkbox" name="file_id" value="#file_id#-doc" onclick="enablesub('#kind#form');"></td>
					<td valign="top" width="1%" nowrap="true">
						<a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(file_name)#',1000,1);return false;">
							<div id="draggable#file_id#" type="#file_id#-doc">
								<!--- If it is a PDF we show the thumbnail --->
								<cfif (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix") AND file_extension EQ "PDF">
									<cfif cloud_url NEQ "">
										<img src="#cloud_url#" border="0">
									<cfelse>
										<img src="#dynpath#/global/host/dam/images/icons/image_missing.png" border="0">
									</cfif>
								<cfelseif application.razuna.storage EQ "local" AND file_extension EQ "PDF">
									<cfset thethumb = replacenocase(file_name_org, ".pdf", ".jpg", "all")>
									<cfif FileExists("#ExpandPath("../../")#/assets/#session.hostid#/#path_to_asset#/#thethumb#") IS "no">
										<img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" width="128" height="128" border="0">
									<cfelse>
										<img src="#cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thethumb#" width="128" border="0">
									</cfif>
								<cfelse>
									<cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#file_extension#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="128" height="128" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" width="128" height="128" border="0"></cfif>
								</cfif>
							</div>
						</a>
						<br />
						#defaultsObj.trans("date_created")#: #dateformat(file_create_date, "#defaultsObj.getdateformat()#")#<!--- <br />
						#defaultsObj.trans("date_changed")#: #dateformat(file_change_date, "#defaultsObj.getdateformat()#")# --->
					</td>
					<td valign="top" width="100%">
						<!--- User has Write access --->
						<cfif #session.folderaccess# NEQ "R">
							<input type="text" name="#file_id#_doc_filename" value="#file_name#" style="width:300px;"><br />
							#defaultsObj.trans("description")#:<br />
							<textarea name="#file_id#_doc_desc_1" style="width:300px;height:30px;">#description#</textarea><br />
							#defaultsObj.trans("keywords")#:<br />
							<textarea name="#file_id#_doc_keywords_1" style="width:300px;height:30px;">#keywords#</textarea>
						<cfelse>
							#defaultsObj.trans("file_name")#: #file_name#<br />
							#defaultsObj.trans("description")#: #description#<br />
							#defaultsObj.trans("keywords")#: #keywords#
						</cfif>
					</td>
					<cfif #session.folderaccess# EQ "X">
						<td valign="top" width="1%" nowrap="true">
							<a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a>
						</td>
					</cfif>
				</tr>
			</cfloop>
			<cfif #session.folderaccess# NEQ "R">
				<tr>
					<td colspan="4" align="right"><div id="updatestatusdoc2" style="float:left;"></div><input type="button" value="#defaultsObj.trans("save_changes")#" onclick="combinedsavedoc();return false;" class="button"></td>
				</tr>
			</cfif>
		<!--- List view --->
		<cfelseif session.view EQ "list">
			<tr>
				<td></td>
				<!--- <td></td> --->
				<td width="100%"><b>#defaultsObj.trans("file_name")#</b></td>
				<td nowrap="true" align="center"><b>#defaultsObj.trans("date_created")#</b></td>
				<td nowrap="true" align="center"><b>#defaultsObj.trans("date_changed")#</b></td>
				<cfif #session.folderaccess# EQ "X">
					<td></td>
				</cfif>
			</tr>
			<!--- Show Subfolders --->
			<cfinclude template="inc_folder_list.cfm">
			<cfloop query="qry_files">
				<tr class="list">
					<td align="center" nowrap="true" width="1%"><input type="checkbox" name="file_id" value="#file_id#-doc" onclick="enablesub('#kind#form');"></td>
					<!--- <td align="center" nowrap="true" width="1%"><a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#file_name#',1000,1);return false;"><cfif FileExists("#ExpandPath("../../")#global/host/dam/images/icons/icon_#file_extension#.png") IS "no"><img src="#dynpath#/global/host/dam/images/icons/icon_txt.png" width="20" height="20" border="0"><cfelse><img src="#dynpath#/global/host/dam/images/icons/icon_#file_extension#.png" width="20" height="20" border="0"></cfif></a></td> --->
					<td width="100%"><a href="##" onclick="showwindow('#myself##xfa.assetdetail#&file_id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(file_name)#',1000,1);return false;"><strong>#file_name#</strong></a></td>
					<td nowrap="true" width="1%" align="center">#dateformat(file_create_date, "#defaultsObj.getdateformat()#")#</td>
					<td nowrap="true" width="1%" align="center">#dateformat(file_change_date, "#defaultsObj.getdateformat()#")#</td>
					<cfif #session.folderaccess# EQ "X">
						<td align="center" width="1%"><a href="##" onclick="showwindow('#myself#ajax.remove_record&id=#file_id#&what=files&loaddiv=#kind#&folder_id=#folder_id#&showsubfolders=#attributes.showsubfolders#','#Jsstringformat(defaultsObj.trans("remove"))#',400,1);return false;"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" /></a></td>
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
</cfoutput>

<!--- JS for the combined view --->
<script language="JavaScript" type="text/javascript">
	// Submit form
	function combinedsavedoc(){
		loadinggif('updatestatusdoc');
		loadinggif('updatestatusdoc2');
		$("#updatestatusdoc").fadeTo("fast", 100);
		$("#updatestatusdoc2").fadeTo("fast", 100);
		var url = formaction("<cfoutput>#kind#</cfoutput>form");
		var items = formserialize("<cfoutput>#kind#</cfoutput>form");
		// Submit Form
       	$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
				// Update Text
				$("#updatestatusdoc").css('color','green');
				$("#updatestatusdoc2").css('color','green');
				$("#updatestatusdoc").css('font-weight','bold');
				$("#updatestatusdoc2").css('font-weight','bold');
				$("#updatestatusdoc").html("<cfoutput>#defaultsObj.trans("success")#</cfoutput>");
				$("#updatestatusdoc2").html("<cfoutput>#defaultsObj.trans("success")#</cfoutput>");
				$("#updatestatusdoc").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
				$("#updatestatusdoc2").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
		   	}
		});
        return false; 
	}
</script>
