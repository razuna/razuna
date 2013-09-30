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
<!--- Application Paths --->
<cfif server.os.name CONTAINS "Mac">
	<cfset im = "/usr/local/bin">
	<cfset ff = "/usr/local/bin">
	<cfset dc = "/usr/local/bin">
	<cfset mp = "/usr/local/bin">
	<cfset ex = "/usr/local/bin">
<cfelseif server.os.name CONTAINS "Windows">
	<cfset im = "C:\ImageMagick">
	<cfset ff = "C:\FFMpeg\bin">
	<cfset ex = "C:\Exiftool">
	<cfset dc = "C:\dcraw">
	<cfset mp = "C:\gpac">
<cfelse>
	<cfset im = "/usr/bin">
	<cfset ff = "/usr/local/bin">
	<cfset ex = "/usr/local/bin">
	<cfset dc = "/usr/bin">
	<cfset mp = "/usr/bin">
</cfif>
<!--- If sessions exists then use the session values --->
<cfif structkeyexists(session.firsttime,"path_im") AND session.firsttime.path_im NEQ "">
	<cfset im = session.firsttime.path_im>
</cfif>
<cfif structkeyexists(session.firsttime,"path_ffmpeg") AND session.firsttime.path_ffmpeg NEQ "">
	<cfset ff = session.firsttime.path_ffmpeg>
</cfif>
<cfif structkeyexists(session.firsttime,"path_exiftool") AND session.firsttime.path_exiftool NEQ "">
	<cfset ex = session.firsttime.path_exiftool>
</cfif>
<cfif structkeyexists(session.firsttime,"path_dcraw") AND session.firsttime.path_dcraw NEQ "">
	<cfset dc = session.firsttime.path_dcraw>
</cfif>
<cfif structkeyexists(session.firsttime,"path_mp4box") AND session.firsttime.path_mp4box NEQ "">
	<cfset mp = session.firsttime.path_mp4box>
</cfif>
<cfoutput>
	<form id="form_paths">
		<span class="loginform_header">#defaultsObj.trans("application_paths")#</span>
		<br />
		#defaultsObj.trans("application_paths_desc")#
		<br />
		<br />
		<span class="loginform_header">#defaultsObj.trans("header_imagemagick")#</span>
		<br />
		#defaultsObj.trans("header_imagemagick_desc_short")#
		<br />
		<input type="text" name="path_imagemagick" id="path_imagemagick" size="60" class="text" value="#im#" onkeyup="checkpath('imagemagick');">
		<br />
		<div id="checkimagemagick" style="display:none;"></div>
		<br />
		<span class="loginform_header">#defaultsObj.trans("header_ffmpeg")#</span>
		<br />
		#defaultsObj.trans("header_ffmpeg_desc_short")#
		<br />
		<input type="text" name="path_ffmpeg" id="path_ffmpeg" size="60" class="text" value="#ff#" onkeyup="checkpath('ffmpeg');">
		<br />
		<div id="checkffmpeg" style="display:none;"></div>
		<br />
		<span class="loginform_header">#defaultsObj.trans("header_exiftool")#</span>
		<br />
		#defaultsObj.trans("header_exiftool_desc_short")#
		<br />
		<input type="text" name="path_exiftool" id="path_exiftool" size="60" class="text" value="#ex#" onkeyup="checkpath('exiftool');">
		<br />
		<div id="checkexiftool" style="display:none;"></div>
		<br />
		<span class="loginform_header">#defaultsObj.trans("header_dcraw")# (optional)</span>
		<br />
		#defaultsObj.trans("header_dcraw_desc")#
		<br />
		<input type="text" name="path_dcraw" id="path_dcraw" size="60" class="text" value="#dc#" onkeyup="checkpath('dcraw');">
		<br />
		<div id="checkdcraw" style="display:none;"></div>
		<br />
		<span class="loginform_header">#defaultsObj.trans("header_mp4box")# (optional)</span>
		<br />
		#defaultsObj.trans("header_mp4box_desc")#
		<br />
		<input type="text" name="path_mp4box" id="path_MP4Box" size="60" class="text" value="#mp#" onkeyup="checkpath('MP4Box');">
		<br />
		<div id="checkMP4Box" style="display:none;"></div>
		<br />
		<div>
			<div style="float:left;padding:20px 0px 0px 0px;">
				<input type="button" id="next" value="#defaultsObj.trans("back")#" onclick="location.href=('/');" class="button"> 
			</div>
			<div style="float:right;padding:20px 0px 0px 0px;">
				<input type="button" id="next" value="#defaultsObj.trans("continue")#" class="button" onclick="checkform();">
			</div>
		</div>
	</form>
</cfoutput>
<script language="javascript">
	// Check paths
	function checkpath(theapp) {
		// Get path
		var thepath = $('#path_' + theapp).val();
		// Enable div
		$('#check' + theapp).css('display','');
		// Load page in div
		loadcontent('check' + theapp,'<cfoutput>#myself#</cfoutput>c.check_paths&theapp=' + theapp + '&thepath=' + escape(thepath));
	}
	// Submit form
	function checkform() {
		// Get path values
		var pathim = $('#path_imagemagick').val();
		var pathff = $('#path_ffmpeg').val();
		var pathex = $('#path_exiftool').val();
		// Check value or else inform user
		if ((pathim == "") | (pathex == "") | (pathff == "")){
			alert('Please fill in all required form fields!');
		}
		else {
			// Get values
			var items = formserialize("form_paths");
			// Submit Form
			loadcontent('load_steps','<cfoutput>#myself#</cfoutput>c.first_time_account&' + items);
		}
	}
</script>
