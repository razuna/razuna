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
	<!--- Location of Image Folders
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("publisher_folder")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("publisher_folder_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("chose_location")#</td>
	<td>
		<select name="thisfolder_vid" class="text">
		<option value="0"<cfif prefs.set2_create_vidfolders_where EQ "" OR prefs.set2_create_vidfolders_where EQ 0> selected</cfif>></option>
		<cfloop query="qry_thefolders">
		<option value="#folder_id#"<cfif prefs.set2_create_vidfolders_where EQ #folder_id#> selected</cfif>><cfswitch expression="#folder_level#"><cfcase value="2">-</cfcase><cfcase value="3">--</cfcase><cfcase value="4">---</cfcase><cfcase value="5">----</cfcase><cfcase value="6">-----</cfcase><cfcase value="7">------</cfcase><cfcase value="8">-------</cfcase><cfcase value="9">--------</cfcase></cfswitch>#folder_name# (#defaultsObj.trans("level")#: #folder_level#)</option>
		</cfloop>
		</select>
	</td>
	</tr>
	 --->
	<!--- Categories / Rubrics
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("img_set_categories")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("img_set_categories_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("show_in_intranet")#</td>
	<td><input type="radio" name="set2_cat_vid_intra" value="T"<cfif #prefs.set2_cat_vid_intra# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="set2_cat_vid_intra" value="F"<cfif #prefs.set2_cat_vid_intra# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("show_in_website")#</td>
	<td><input type="radio" name="set2_cat_vid_web" value="T"<cfif #prefs.set2_cat_vid_web# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="set2_cat_vid_web" value="F"<cfif #prefs.set2_cat_vid_web# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
	</tr>
	 --->
	<!--- Video preview settings
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("header_video_preview_size")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_video_preview_size_desc")#</td>
	</tr>
	<tr>
	<td nowrap="true">#defaultsObj.trans("header_video_preview_size_text")#</td>
	<td><input type="text" name="set2_vid_preview_width" id="set2_vid_preview_width" size="4" maxlength="3" value="#prefs.set2_vid_preview_width#" onchange="aspectheight(this,'set2_vid_preview_heigth');"> #defaultsObj.trans("header_img_width")# <input type="text" name="set2_vid_preview_heigth" id="set2_vid_preview_heigth" size="4" maxlength="3" value="#prefs.set2_vid_preview_heigth#" onchange="aspectwidth(this,'set2_vid_preview_width');"> #defaultsObj.trans("header_img_height")#</td>
	</tr>
	<tr>
	<td nowrap="true">#defaultsObj.trans("header_video_preview_sec_text")#</td>
	<td><input type="text" name="set2_vid_preview_time" size="8" maxlength="8" value="#prefs.set2_vid_preview_time#" /> <i>#defaultsObj.trans("header_video_preview_timeframe")#</i></td>
	</tr>
	<tr>
	<td nowrap="true" valign="top">#defaultsObj.trans("header_video_preview_sec_start")#</td>
	<td valign="top"><input type="text" name="set2_vid_preview_start" size="8" maxlength="8" value="#prefs.set2_vid_preview_start#" /><br><i>#defaultsObj.trans("header_video_preview_timeframe_start")#</i></td>
	</tr> --->
	<tr>
	<th class="textbold" colspan="2">Copyright Tags</th>
	</tr>
	<tr>
	<td nowrap="true" valign="top">#defaultsObj.trans("header_video_preview_author")#</td>
	<td><input type="text" name="set2_vid_preview_author" size="40" value="#prefs.set2_vid_preview_author#" /><br><i>#defaultsObj.trans("header_video_preview_tag")#</i></td>
	</tr>
	<tr>
	<td nowrap="true" valign="top">#defaultsObj.trans("header_video_preview_copyright")#</td>
	<td><input type="text" name="set2_vid_preview_copyright" size="40" value="#prefs.set2_vid_preview_copyright#" /><br><i>#defaultsObj.trans("header_video_preview_tag")#</i></td>
	</tr>
	<!--- Image Magick Paths --->
	<!---
<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("header_ffmpeg")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_ffmpeg_desc")#</td>
	</tr>
	<tr>
	<td nowrap="true">#defaultsObj.trans("header_ffmpeg")#</td>
	<td><input type="text" name="set2_path_ffmpeg" value="#prefs.set2_path_ffmpeg#" size="40" class="text"></td>
	</tr>
--->
	</table>
</cfoutput>


