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
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!--- Tools header --->
		<tr>
			<th class="textbold" colspan="2">Tools #defaultsObj.trans("settings")#</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("tools_desc")#</td>
		</tr>
		<tr>
			<td class="list" colspan="2"></td>
		</tr>
		<!--- ImageMagick --->
		<tr>
			<th class="textbold" colspan="3">#defaultsObj.trans("header_imagemagick")#</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("header_imagemagick_desc")#</td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("imagemagick_path")#</td>
			<td><input type="text" name="imagemagick" id="imagemagick" value="#thetools.imagemagick#" size="60" class="text" onkeyup="checkpath('imagemagick');">
			<div id="checkimagemagick" style="display:none;"></div></td>
		</tr>
		<tr>
			<td class="list" colspan="2"></td>
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
			<td><input type="text" name="ffmpeg" id="ffmpeg" value="#thetools.ffmpeg#" size="60" class="text" onkeyup="checkpath('ffmpeg');">
			<div id="checkffmpeg" style="display:none;"></div></td>
		</tr>
		<tr>
			<td class="list" colspan="2"></td>
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
			<td><input type="text" name="exiftool" id="exiftool" value="#thetools.exiftool#" size="60" class="text" onkeyup="checkpath('exiftool');">
			<div id="checkexiftool" style="display:none;"></div></td>
		</tr>
		<tr>
			<td class="list" colspan="2"></td>
		</tr>
		<!--- DCRAW Paths --->
		<tr>
			<th class="textbold" colspan="2">#defaultsObj.trans("header_dcraw")# (optional)</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("header_dcraw_desc")#</td>
		</tr>
		<tr>
			<td nowrap="true">#defaultsObj.trans("header_dcraw")#</td>
			<td><input type="text" name="dcraw" id="dcraw" value="#thetools.dcraw#" size="60" class="text" onkeyup="checkpath('dcraw');">
			<div id="checkdcraw" style="display:none;"></div></td>
		</tr>
		<tr>
			<td class="list" colspan="2"></td>
		</tr>
		<!--- MP4Box Paths --->
		<tr>
			<th class="textbold" colspan="2">#defaultsObj.trans("header_mp4box")# (optional)</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("header_mp4box_desc")#</td>
		</tr>
		<tr>
			<td nowrap="true">#defaultsObj.trans("header_mp4box")#</td>
			<td><input type="text" name="mp4box" id="MP4Box" value="#thetools.mp4box#" size="60" class="text" onkeyup="checkpath('MP4Box');">
			<div id="checkMP4Box" style="display:none;"></div></td>
		</tr>
	</table>
</cfoutput>
<script language="javascript">
	// Check paths
	function checkpath(theapp){
		// Get path
		var thepath = $('#' + theapp).val();
		// Enable div
		$('#check' + theapp).css('display','');
		// Load page in div
		loadcontent('check' + theapp,'<cfoutput>#myself#</cfoutput>c.check_paths&theapp=' + theapp + '&thepath=' + escape(thepath));
	}
</script>