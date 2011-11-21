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
<form action="#self#" method="post" name="rfsdetail" id="rfsdetail">
<input type="hidden" name="#theaction#" value="c.prefs_renf_add">
<input type="hidden" name="rfs_id" value="#attributes.rfs_id#">
<input type="hidden" name="rfs_add" value="#attributes.rfs_add#">
<div id="rfstab">
	<ul>
		<li><a href="##serversetup">#defaultsObj.trans("header_server_setup")#</a></li>
		<li><a href="##servertools">Tools</a></li>
		<li><a href="##encodingsetup">Encoding Parameters</a></li>
	</ul>
	<!--- Server --->
	<div id="serversetup">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<!--- Enable Server --->
			<tr>
				<th colspan="2">#defaultsObj.trans("header_server_enable")#</th>
			</tr>
			<tr>
				<td colspan="2"><input type="radio" name="rfs_active" id="rfs_active" value="true"<cfif qry_rfs.rfs_active EQ true> checked="checked"</cfif>> #defaultsObj.trans("yes")# <input type="radio" name="rfs_active" id="rfs_active" value="false"<cfif qry_rfs.rfs_active EQ false OR qry_rfs.recordcount EQ 0> checked="checked"</cfif>> #defaultsObj.trans("no")#</td>
			</tr>
			<!--- Server Name --->
			<tr>
				<th colspan="2">#defaultsObj.trans("header_server_name")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_server_name_desc")#</td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="rfs_server_name" id="rfs_server_name" style="width:300px;" value="#qry_rfs.rfs_server_name#" /> <input type="button" class="button" value="#defaultsObj.trans("validate")#" onclick="valserver();" /><div id="div_valserver" style="display:none;"></div></td>
			</tr>
			<tr>
				<th colspan="2">#defaultsObj.trans("header_server_watchfolder")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_server_watchfolder_desc")#</td>
			</tr>
			<tr class="list">
				<td colspan="2"><input type="text" name="rfs_watchfolder" id="rfs_watchfolder" style="width:300px;" value="#qry_rfs.rfs_watchfolder#"></td>
			</tr>

			<tr>
				<th colspan="2">#defaultsObj.trans("header_server_connection")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_server_connection_desc")#</td>
			</tr>
			<tr>
				<td valign="top" align="center"><input type="radio" name="rfs_connection" id="rfs_connection" value="ftp"<cfif qry_rfs.rfs_connection EQ "ftp" OR qry_rfs.recordcount EQ 0> checked="checked"</cfif>></td>
				<td>#defaultsObj.trans("header_server_connection_ftp")#
					<br /><br />
					FTP Server<br />
					<input type="text" name="rfs_ftp_server" id="rfs_ftp_server" style="width:300px;" value="#qry_rfs.rfs_ftp_server#"> <input type="button" class="button" value="#defaultsObj.trans("validate")#" onclick="valftp();" /><div id="div_valftp" style="display:none;"></div><br />
					#defaultsObj.trans("scheduled_uploads_ftp_user")#<br />
					<input type="text" name="rfs_ftp_user" id="rfs_ftp_user" style="width:300px;" value="#qry_rfs.rfs_ftp_user#"><br />
					#defaultsObj.trans("scheduled_uploads_ftp_pass")#<br />
					<input type="password" name="rfs_ftp_pass" id="rfs_ftp_pass" style="width:300px;" value="#qry_rfs.rfs_ftp_pass#"><br />
					#defaultsObj.trans("scheduled_uploads_ftp_passive")#<br />
					<input type="radio" name="rfs_ftp_passive" id="rfs_ftp_passive" value="true"<cfif qry_rfs.rfs_ftp_passive EQ true> checked="checked"</cfif>> #defaultsObj.trans("yes")# <input type="radio" name="rfs_ftp_passive" id="rfs_ftp_passive" value="false"<cfif qry_rfs.rfs_ftp_passive EQ false OR qry_rfs.recordcount EQ 0> checked="checked"</cfif>> #defaultsObj.trans("no")#
					<br /><br />
				</td>
			</tr>
			<tr>
				<td valign="top" align="center"><input type="radio" name="rfs_connection" id="rfs_connection" value="scp"<cfif qry_rfs.rfs_connection EQ "scp"> checked="checked"</cfif>></td>
				<td>#defaultsObj.trans("header_server_connection_scp")#
					<br /><br />
					#defaultsObj.trans("header_server_connection_scp_account")#<br />
					<input type="text" name="rfs_scp_login" id="rfs_scp_login" style="width:300px;" value="#qry_rfs.rfs_scp_login#"><br />
					<em>(#defaultsObj.trans("header_server_connection_scp_account_desc")#)</em>
					
					<br /><br />
				</td>
			</tr>
			<tr>
				<td valign="top" align="center"><input type="radio" name="rfs_connection" id="rfs_connection" value="http"<cfif qry_rfs.rfs_connection EQ "http"> checked="checked"</cfif>></td>
				<td>#defaultsObj.trans("header_server_connection_http")#</td>
			</tr>
			
			
		</table>
	</div>
	<!--- Tools --->
	<div id="servertools">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<!--- Tools header --->
			<tr>
				<th class="textbold" colspan="2">Tools #defaultsObj.trans("settings")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("tools_desc")#</td>
			</tr>
			<!--- ImageMagick --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("header_imagemagick")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_imagemagick_desc")#</td>
			</tr>
			<tr>
				<td nowrap="nowrap">#defaultsObj.trans("imagemagick_path")#</td>
				<td><input type="text" name="rfs_imagemagick" id="rfs_imagemagick" value="#qry_rfs.rfs_imagemagick#" class="text" onkeyup="rfs_checkpath('rfs_imagemagick');" style="width:300px;">
				<div id="checkrfs_imagemagick" style="display:none;"></div></td>
			</tr>
			<!--- Exiftool Path --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("header_exiftool")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_exiftool_desc")#</td>
			</tr>
			<tr>
				<td>#defaultsObj.trans("exiftool_path")#</td>
				<td><input type="text" name="rfs_exiftool" id="rfs_exiftool" value="#qry_rfs.rfs_exiftool#" style="width:300px;" class="text" onkeyup="rfs_checkpath('rfs_exiftool');">
				<div id="checkrfs_exiftool" style="display:none;"></div></td>
			</tr>
			<!--- DCRAW Paths --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("header_dcraw")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_dcraw_desc")#</td>
			</tr>
			<tr>
				<td nowrap="true">#defaultsObj.trans("header_dcraw")#</td>
				<td><input type="text" name="rfs_dcraw" id="rfs_dcraw" value="#qry_rfs.rfs_dcraw#" style="width:300px;" class="text" onkeyup="rfs_checkpath('rfs_dcraw');">
				<div id="checkrfs_dcraw" style="display:none;"></div></td>
			</tr>
			<!--- FFmpeg Paths --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("header_ffmpeg")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_ffmpeg_desc")#</td>
			</tr>
			<tr>
				<td nowrap="true">#defaultsObj.trans("header_ffmpeg")#</td>
				<td><input type="text" name="rfs_ffmpeg" id="rfs_ffmpeg" value="#qry_rfs.rfs_ffmpeg#" style="width:300px;" class="text" onkeyup="rfs_checkpath('rfs_ffmpeg');">
				<div id="checkrfs_ffmpeg" style="display:none;"></div></td>
			</tr>
		</table>
	</div>
	<!--- Encoding Params --->
	<div id="encodingsetup">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		
		
		</table>
	</div>
	<div id="submit" style="float:right;padding:10px;"><div id="updatetext" style="color:green;padding:10px;display:none;float:left;"></div><input type="submit" name="Submit" value="#defaultsObj.trans("save")#" class="button"></div>
</div>
</form>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("rfstab");
	// Fire the form submit for new or update user
	$(document).ready(function(){
		$("##rfsdetail").validate({
			submitHandler: function(form) {
				jQuery(form).ajaxSubmit({
					success: rfs_feedback
				});
			},
			rules: {
				rfs_server_name: "required",
				rfs_watchfolder: "required",
			   	rfs_connection: "required",
			   	rfs_ffmpeg: "required",
			   	rfs_dcraw: "required",
			   	rfs_exiftool: "required",
			   	rfs_imagemagick: "required"
			 }
		});
	});
	// Feedback when saving form
	function rfs_feedback() {
		$('##updatetext').css('display','');
		$('##updatetext').html('#defaultsObj.trans("success")#');
		loadcontent('renf', '#myself#c.prefs_renf');
	}
	// Validate Server
	function valserver(){
		$("##div_valserver").css("display","");
		loadcontent('div_valserver', '#myself#ajax.prefs_rendf_valserver&server_name=' + $('##rfs_server_name').val());
	}
	// Validate FTP
	function valftp(){
		// Get values
		var server = $('##rfs_ftp_server').val();
		var user = $('##rfs_ftp_user').val();
		var pass = $('##rfs_ftp_pass').val();
		var passive = $('##rfs_ftp_passive:checked').val();
		$("##div_valftp").css("display","");
		loadcontent('div_valftp', '#myself#ajax.prefs_rendf_valftp&server=' + server + '&user=' + user + '&pass=' + pass + '&passive=' + passive);
	}
	// Check paths
	function rfs_checkpath(theapp){
		// Get path
		var thepath = $('##' + theapp).val();
		// Enable div
		$('##check' + theapp).css('display','');
		// Load page in div
		loadcontent('check' + theapp,'<cfoutput>#myself#</cfoutput>c.check_paths&theapp=' + theapp + '&thepath=' + escape(thepath));
	}
</script>
</cfoutput>