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
	<form name="form_folder#attributes.theid#" action="#self#" method="post" id="form_folder#attributes.theid#" onsubmit="foldersubmit('#attributes.theid#','#attributes.isdetail#','<cfif qry_folder.folder_is_collection EQ "T" OR attributes.iscol EQ "T">T<cfelse>F</cfif>');return false;">
	<input type="hidden" name="#theaction#" value="#xfa.submitfolderform#">
	<input type="hidden" name="theid" value="#attributes.theid#">
	<input type="hidden" name="level" value="#attributes.level#">
	<input type="hidden" name="rid" value="#attributes.rid#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<cfif qry_folder.folder_is_collection EQ "T" OR attributes.iscol EQ "T">
		<input type="hidden" name="coll_folder" value="T">
	</cfif>
	<div id="folder#attributes.theid#-#attributes.isdetail#" style="width:<cfif attributes.isdetail EQ "T">660px<cfelse>690px</cfif>;padding-bottom:60px;">
		<cfif attributes.isdetail NEQ "T" AND NOT application.razuna.isp AND attributes.iscol NEQ "T">
			<ul>
				<li><a href="##folder_new#attributes.theid#">#defaultsObj.trans("folder_new")#</a></li>
				<cfif NOT application.razuna.isp><li><a href="##folder_link#attributes.theid#">#defaultsObj.trans("link_folder_header")#</a></li></cfif>
			</ul>
		</cfif>
		<div id="folder_new#attributes.theid#">
			<table border="0" cellpadding="0" cellspacing="0" class="grid" style="width:660px;">
				<!---
<tr>
					<th colspan="2">
						<div style="float:left;"><cfif attributes.isdetail EQ "T">#defaultsObj.trans("folder_properties")#<cfelse>#defaultsObj.trans("folder_new")#</cfif></div>
					</th>
				</tr>
--->
				<tr>
					<td><strong>#defaultsObj.trans("folder_name")#</strong></td>
					<td>
						<cfif qry_folder.folder_name EQ "My Folder" OR qry_folder.folder_id EQ 1>
							<input type="hidden" name="folder_name" id="folder_name" value="#qry_folder.folder_name#">
							#qry_folder.folder_name#
						<cfelse>
							<input type="text" id="folder_name" name="folder_name" style="width:400px;" value="#qry_folder.folder_name#">
						</cfif>
					</td>
				</tr>
				<cfloop query="qry_langs">
					<cfset thisid = lang_id>
					<tr>
						<td valign="top" width="1%" nowrap="true" class="td2">#defaultsObj.trans("description")# #lang_name#</td>
						<td width="100%" class="td2"><textarea name="folder_desc_#thisid#" class="text" style="width:400px;height:50px;"><cfloop query="qry_folder_desc"><cfif thisid EQ #lang_id_r#><cfif folder_desc NEQ "">#folder_desc#</cfif></cfif></cfloop></textarea></td>
					</tr>
				</cfloop>
				<!--- Labels --->
				<cfif attributes.isdetail EQ "T">
					<tr>
						<td>#defaultsObj.trans("labels")#</td>
						<td width="100%" nowrap="true" colspan="5"><input name="tags" id="tags_folder" value="#qry_labels#"></td>
					</tr>
					<tr>
						<td></td>
						<td colspan="5" style="padding-bottom:10px;"><em>(<cfif settingsobj.get_label_set().set2_labels_users EQ "f">You can only choose from available labels. Simply start typing to select from available labels.<cfelse>Simple start typing to choose from available labels or add a new one by entering above and hit ",".</cfif>)</em></td>
					</tr>
				</cfif>
				<tr>
					<td colspan="2" class="list"></td>
				</tr>
				<tr>
					<td class="td2" valign="top"><strong>Permissions</strong></td>
					<td valign="top" class="td2" style="padding:0;margin:0;">
						<table width="420" cellpadding="0" cellspacing="0" border="0" class="grid">
							<tr>
								<th width="100%" colspan="2">#defaultsObj.trans("access_for")#</th>
								<th width="1%" nowrap align="center">#defaultsObj.trans("per_read")#</th>
								<th width="1%" nowrap align="center">#defaultsObj.trans("per_read_write")#</th>
								<th width="1%" nowrap align="center">#defaultsObj.trans("per_all")#</th>
							</tr>
							<tr class="list">
								<td width="1%" align="center" style="padding:4px;"><input type="checkbox" name="grp_0" value="0" <cfif qry_folder_groups_zero.grp_id_r EQ 0> checked</cfif> onclick="checkradio(0);"></td>
								<td width="100%" nowrap class="textbold" style="padding:4px;">#defaultsObj.trans("everybody")#</td>
								<td width="1%" nowrap align="center" style="padding:4px;"><input type="radio" value="R" name="per_0" id="per_0"<cfif (qry_folder_groups_zero.grp_permission EQ "R") OR (qry_folder_groups_zero.grp_permission EQ "")> checked</cfif>></td>
								<td width="1%" nowrap align="center" style="padding:4px;"><input type="radio" value="W" name="per_0"<cfif qry_folder_groups_zero.grp_permission EQ "W"> checked</cfif>></td>
								<td width="1%" nowrap align="center" style="padding:4px;"><input type="radio" value="X" name="per_0"<cfif qry_folder_groups_zero.grp_permission EQ "X"> checked</cfif>></td>
							</tr>
							<cfloop query="qry_groups">
								<cfset grpidnodash = replace(grp_id,"-","","all")>
								<tr class="list">
									<td width="1%" align="center" style="padding:4px;"><input type="checkbox" name="grp_#grp_id#" value="#grp_id#"<cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id#> checked</cfif></cfloop> onclick="checkradio('#grpidnodash#');"></td>
									<td width="1%" nowrap style="padding:4px;">#grp_name#</td>
									<td align="center" style="padding:4px;"><input type="radio" value="R" name="per_#grpidnodash#" id="per_#grpidnodash#"<cfif attributes.isdetail EQ "T"><cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id# AND grp_permission EQ "R"> checked<cfelseif grp_id_r NEQ #qry_groups.grp_id#> checked</cfif></cfloop><cfelse> checked</cfif>></td>
									<td align="center" style="padding:4px;"><input type="radio" value="W" name="per_#grpidnodash#"<cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id# AND grp_permission EQ "W"> checked</cfif></cfloop>></td>
									<td align="center" style="padding:4px;"><input type="radio" value="X" name="per_#grpidnodash#"<cfloop query="qry_folder_groups"><cfif grp_id_r EQ #qry_groups.grp_id# AND grp_permission EQ "X"> checked</cfif></cfloop>></td>
								</tr>
							</cfloop>
						</table>
					</td>
				</tr>
				<tr>
					<td width="1%" nowrap="true" class="td2" style="padding-bottom:7px;">#defaultsObj.trans("group_inherit")#</td>
					<td width="100%" class="td2" style="padding-bottom:7px;"><input type="checkbox" name="perm_inherit" value="T"></td>
				</tr>
			</table>
			<!--- Sharing Options --->
			<cfif attributes.isdetail EQ "T">
				<br>
				<table border="0" cellpadding="0" cellspacing="0" class="grid" style="width:660px;">
					<!--- Share Options --->
					<cfif qry_folder.folder_id NEQ 1 AND (qry_folder.folder_is_collection EQ "F" OR qry_folder.folder_is_collection EQ "")>
						<tr>
							<td colspan="2" class="list"></td>
						</tr>
						<tr>
							<th colspan="2">#defaultsObj.trans("share_folder")#</th>
						</tr>
						<tr>
							<td colspan="2">#defaultsObj.trans("share_folder_desc")#</td>
						</tr>
						<tr>
							<td class="td2">#defaultsObj.trans("share_folder_boolean")#</td>
							<td class="td2"><input type="radio" value="T" name="folder_shared"<cfif qry_folder.folder_shared EQ "T"> checked="true"</cfif>>#defaultsObj.trans("yes")# <input type="radio" value="F" name="folder_shared"<cfif qry_folder.folder_shared EQ "F" OR qry_folder.folder_shared EQ ""> checked="true"</cfif>>#defaultsObj.trans("no")#</td>
						</tr>
						<tr>
							<td class="td2" valign="top">#defaultsObj.trans("folder")# URL</td>
							<td class="td2"><!--- http://#cgi.http_host##replacenocase(cgi.script_name,"/index.cfm","","ALL")#/share/#attributes.theid#/<input type="text" id="folder_name_shared" name="folder_name_shared" size="20" value="#qry_folder.folder_name_shared#"><br /> ---><a href="http://#cgi.http_host##cgi.script_name#?fa=c.share&fid=#attributes.theid#&v=#createuuid()#" target="_blank">http://#cgi.http_host##cgi.script_name#?fa=c.share&fid=#attributes.theid#</a></td>
						</tr>
						<!--- Download Original --->
						<tr>
							<td colspan="2" class="list"></td>
						</tr>
						<tr>
							<th colspan="2">#defaultsObj.trans("share_allow_download_original")#</th>
						</tr>
						<tr>
							<td colspan="2" class="td2">#defaultsObj.trans("share_allow_download_desc")#</td>
						</tr>
						<tr>
							<td class="td2" nowrap="nowrap" valign="top">#defaultsObj.trans("share_allow_download_original")#</td>
							<td class="td2"><input type="radio" value="T" name="share_dl_org" id="share_dl_org"<cfif qry_folder.share_dl_org EQ "T"> checked="true"</cfif>>#defaultsObj.trans("yes")# <input type="radio" value="F" name="share_dl_org" id="share_dl_org"<cfif qry_folder.share_dl_org EQ "F"> checked="true"</cfif>>#defaultsObj.trans("no")#
							<br><br>
							<a href="##" onclick="resetdl();return false;">#defaultsObj.trans("share_folder_download_reset")#</a>
							<div id="reset_dl" style="color:green;font-weight:bold;padding-top:5px;"></div>
							</td>
						</tr>
						<!--- Comments --->
						<tr>
							<td colspan="2" class="list"></td>
						</tr>
						<tr>
							<th colspan="2">#defaultsObj.trans("share_allow_commenting")#</th>
						</tr>
						<tr>
							<td class="td2">#defaultsObj.trans("share_allow_commenting")#</td>
							<td class="td2"><input type="radio" value="T" name="share_comments"<cfif qry_folder.share_comments EQ "T"> checked="true"</cfif>>#defaultsObj.trans("yes")# <input type="radio" value="F" name="share_comments"<cfif qry_folder.share_comments EQ "F"> checked="true"</cfif>>#defaultsObj.trans("no")#</td>
						</tr>
						<!--- Upload --->
						<tr>
							<td colspan="2" class="list"></td>
						</tr>
						<tr>
							<th colspan="2">#defaultsObj.trans("share_allow_upload")#</th>
						</tr>
						<tr>
							<td colspan="2" class="td2">#defaultsObj.trans("share_allow_upload_desc")#</td>
						</tr>
						<tr>
							<td class="td2">#defaultsObj.trans("share_allow_upload")#</td>
							<td class="td2"><input type="radio" value="T" name="share_upload"<cfif qry_folder.share_upload EQ "T"> checked="true"</cfif>>#defaultsObj.trans("yes")# <input type="radio" value="F" name="share_upload"<cfif qry_folder.share_upload EQ "F"> checked="true"</cfif>>#defaultsObj.trans("no")#</td>
						</tr>
						<!--- Order --->
						<tr>
							<td colspan="2" class="list"></td>
						</tr>
						<tr>
							<th colspan="2">#defaultsObj.trans("share_allow_order")#</th>
						</tr>
						<tr>
							<td colspan="2" class="td2">#defaultsObj.trans("share_allow_order_desc")#</td>
						</tr>
						<tr>
							<td class="td2">#defaultsObj.trans("share_allow_order")#</td>
							<td class="td2"><input type="radio" value="T" name="share_order"<cfif qry_folder.share_order EQ "T"> checked="true"</cfif>>#defaultsObj.trans("yes")# <input type="radio" value="F" name="share_order"<cfif qry_folder.share_order EQ "F"> checked="true"</cfif>>#defaultsObj.trans("no")#</td>
						</tr>
						<tr>
							<td colspan="2" class="td2">#defaultsObj.trans("share_allow_order_email_desc")#</td>
						</tr>
						<tr>
							<td class="td2">#defaultsObj.trans("share_allow_order_email")#</td>
							<td class="td2">
								<select name="share_order_user">
									<cfloop query="qry_users">
										<option value="#user_id#"<cfif qry_folder.share_order_user EQ user_id> selected</cfif>>#user_first_name# #user_last_name#</option>
									</cfloop>
								</select>
							</td>
						</tr>
					</cfif>
				</table>
			</cfif>
		</div>
		<!--- Link to Folder --->
		<cfif attributes.isdetail NEQ "T" AND NOT application.razuna.isp AND attributes.iscol NEQ "T">
			<div id="folder_link#attributes.theid#">
				<table border="0" cellpadding="0" cellspacing="0" class="grid" style="width:660px;">
					<tr>
						<td>#defaultsObj.trans("link_folder_desc")#</td>
					</tr>
					<tr>
						<td class="td2"><hr></td>
					</tr>
					<tr>
						<td class="td2" width="1%" nowrap="true" style="padding-top:7px;"><strong>#defaultsObj.trans("link_folder_path_header")#</strong></td>
					</tr>
					<tr>
						<td class="td2" width="100%">
							<input name="link_path" id="link_path" type="text" style="width:450px;"> <a href="##" onclick="jschecklink();">Check Folder</a>
							<div id="foldercheck"></div>
						</td>
					</tr>
				</table>
				<div id="addlinkstatus" style="display:none;"></div>
			</div>
		</cfif>
		<div style="float:left;padding-top:10px;padding-bottom:10px;">
			<cfif attributes.isdetail EQ "T" AND (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()) AND NOT (qry_folder.folder_owner EQ session.theuserid AND qry_folder.folder_name EQ "my folder") AND qry_folder.folder_id NEQ 1 AND qry_folder.folder_id NEQ 2>
				<input type="button" name="movefolder" value="#defaultsObj.trans("move_folder")#" class="button" onclick="showwindow('#myself#c.move_file&file_id=0&type=movefolder&thetype=folder&folder_id=#attributes.folder_id#&folder_level=#qry_folder.folder_level#&iscol=#qry_folder.folder_is_collection#','#defaultsObj.trans("move_folder")#',600,1);"> 
			</cfif>
			<cfif attributes.isdetail EQ "T">
				<cfif (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()) AND qry_folder.folder_id NEQ 1>
					<input type="button" name="removefolder" value="#defaultsObj.trans("remove_folder")#" class="button" onclick="showwindow('#myself#ajax.remove_folder&folder_id=#attributes.folder_id#&iscol=#qry_folder.folder_is_collection#','#defaultsObj.trans("remove_folder")#',400,1);" style="margin-right:20px;">
				<cfelseif qry_folder.folder_name NEQ "my folder" AND qry_folder.folder_owner EQ session.theuserid>
					<input type="button" name="removefolder" value="#defaultsObj.trans("remove_folder")#" class="button" onclick="showwindow('#myself#ajax.remove_folder&folder_id=#attributes.folder_id#&iscol=#qry_folder.folder_is_collection#','#defaultsObj.trans("remove_folder")#',400,1);" style="margin-right:20px;">
				</cfif>
			</cfif>
			<cfif attributes.isdetail NEQ "T">
				<input type="button" name="cancel" value="#defaultsObj.trans("cancel")#" onclick="destroywindow(1);return false;" class="button"> 
			</cfif>
		</div>
		<div style="float:right;padding-top:10px;padding-bottom:10px;">
			<input type="submit" name="submit" value="<cfif attributes.isdetail EQ "T">#defaultsObj.trans("button_update")#<cfelse>#defaultsObj.trans("button_add")#</cfif>" class="button">
			<div id="updatetext" style="float:left;color:green;padding-right:10px;padding-top:4px;font-weight:bold;"></div>
		</div>
	</div>
	</form>

	<!--- JS --->
	<cfif attributes.isdetail NEQ "T">
		<script language="JavaScript" type="text/javascript">
			// Initialize Tabs
			jqtabs("folder#attributes.theid#-#attributes.isdetail#");
			// Check link
			function jschecklink(){
				// Loading gif
				
				// Check link
				loadcontent('foldercheck','#myself#c.folder_link_check&link_path=' + escape($('##link_path').val()));
			}
		</script>
	</cfif>
	<script language="JavaScript" type="text/javascript">
		// Reset DL
		function resetdl(){
			var thevalue = $('##share_dl_org:checked').val();
			if (thevalue){
				thevalue = 1;
			}
			else{
				thevalue = 0;
			}
			loadcontent('updatetext','#myself#c.share_reset_dl&folder_id=#attributes.folder_id#&setto=' + thevalue);
			$('##reset_dl').html('Reset all individual download setting successfully');
		}
		<cfif attributes.isdetail EQ "T">
			// TAG IT
			var raztags = #attributes.thelabels#;
			// Global Tagit function
			// div, fileid, type, tags
			raztagit('tags_folder','#attributes.folder_id#','folder',raztags,'#settingsobj.get_label_set().set2_labels_users#');
		</cfif>
	</script>
</cfoutput>