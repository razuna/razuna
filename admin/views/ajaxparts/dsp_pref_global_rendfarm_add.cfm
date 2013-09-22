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
<input type="hidden" name="rfs_add" id="rfs_add" value="#attributes.rfs_add#">
<div id="rfstab">
	<ul>
		<li><a href="##serversetup">#defaultsObj.trans("header_server_setup")#</a></li>
		<li><a href="##servertools">Tools</a></li>
		<!--- <li><a href="##encodingsetup">Encoding Parameters</a></li> --->
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
			<!--- Server Location --->
			<tr>
				<th colspan="2">#defaultsObj.trans("header_location")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_location_desc")#</td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="rfs_location" id="rfs_location" style="width:300px;" value="#qry_rfs.rfs_location#" /></td>
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
				<td><input type="text" name="rfs_imagemagick" id="rfs_imagemagick" value="#qry_rfs.rfs_imagemagick#" class="text" style="width:300px;"></td>
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
				<td><input type="text" name="rfs_ffmpeg" id="rfs_ffmpeg" value="#qry_rfs.rfs_ffmpeg#" style="width:300px;" class="text"></td>
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
				<td><input type="text" name="rfs_exiftool" id="rfs_exiftool" value="#qry_rfs.rfs_exiftool#" style="width:300px;" class="text"></td>
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
				<td><input type="text" name="rfs_dcraw" id="rfs_dcraw" value="#qry_rfs.rfs_dcraw#" style="width:300px;" class="text"></td>
			</tr>
			<!--- MP4Box Paths --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("header_mp4box")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_mp4box_desc")#</td>
			</tr>
			<tr>
				<td nowrap="true">#defaultsObj.trans("header_mp4box")#</td>
				<td><input type="text" name="rfs_mp4box" id="rfs_mp4box" value="#qry_rfs.rfs_mp4box#" style="width:300px;" class="text"></td>
			</tr>
		</table>
	</div>
	<!--- Encoding Params --->
	<!---
<div id="encodingsetup">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		
		
		</table>
	</div>
--->
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
		$('##rfs_add').val('false');
		loadcontent('renf', '#myself#c.prefs_renf');
	}
	// Validate Server
	function valserver(){
		var thehttp = $('##rfs_server_name').val();
		$('##div_valserver').css('display','');
		$('##div_valserver').load('#myself#ajax.prefs_rendf_valserver', { server_name: thehttp } );
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
</script>
</cfoutput>