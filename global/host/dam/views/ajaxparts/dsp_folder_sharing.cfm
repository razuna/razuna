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
	<form name="form_folder_share#attributes.theid#" action="#self#" method="post" id="form_folder_share#attributes.theid#" onsubmit="savesharing('#attributes.theid#','<cfif qry_folder.folder_is_collection EQ "T" OR attributes.iscol EQ "T">T<cfelse>F</cfif>');return false;">
	<input type="hidden" name="#theaction#" value="#xfa.submitfolderform#">
	<input type="hidden" name="theid" value="#attributes.theid#">
	<cfif qry_folder.folder_is_collection EQ "T" OR attributes.iscol EQ "T">
		<input type="hidden" name="coll_folder" value="T">
	</cfif>
	<div id="folder#attributes.theid#-t" style="width:660px;padding-bottom:60px;">
		<div id="folder_new#attributes.theid#">
			<!--- Sharing Options --->
			<table border="0" cellpadding="0" cellspacing="0" class="grid" style="width:660px;">
				<!--- Share Options --->
				<cfif qry_folder.folder_is_collection EQ "F" OR qry_folder.folder_is_collection EQ "">
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
							<select data-placeholder="Choose a User" class="chzn-select" style="width:250px;" name="share_order_user">
								<option value=""></option>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif qry_folder.share_order_user EQ user_id> selected</cfif>>#user_first_name# #user_last_name#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</cfif>
			</table>
		</div>
		
		<div style="float:right;padding-top:10px;padding-bottom:10px;">
			<input type="submit" name="submit" value="#defaultsObj.trans("button_update")#" class="button">
			<div id="updatetextshare" style="float:left;color:green;padding-right:10px;padding-top:4px;font-weight:bold;"></div>
		</div>
	</div>
	</form>

	<!--- JS --->
	<script language="JavaScript" type="text/javascript">
		// Reset DL
		function resetdl(){
			var thevalue = $('##share_dl_org:checked').val();
			if (thevalue == 'T'){
				thevalue = 1;
			}
			else{
				thevalue = 0;
			}
			loadcontent('updatetextshare','#myself#c.share_reset_dl&folder_id=#attributes.folder_id#&setto=' + thevalue);
			$('##reset_dl').html('Reset all individual download setting successfully');
		}
		// Activate Chosen
		$(".chzn-select").chosen();
	</script>
</cfoutput>