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
	<td nowrap="true">#defaultsObj.trans("chose_location")#</td>
	<td>
		<select name="thisfolder_img" class="text">
		<option value="0"<cfif prefs.set2_create_imgfolders_where EQ "" OR prefs.set2_create_imgfolders_where EQ 0> selected</cfif>></option>
		<cfloop query="qry_thefolders">
		<option value="#folder_id#"<cfif prefs.set2_create_imgfolders_where EQ #folder_id#> selected</cfif>><cfswitch expression="#folder_level#"><cfcase value="2">-</cfcase><cfcase value="3">--</cfcase><cfcase value="4">---</cfcase><cfcase value="5">----</cfcase><cfcase value="6">-----</cfcase><cfcase value="7">------</cfcase><cfcase value="8">-------</cfcase><cfcase value="9">--------</cfcase></cfswitch>#folder_name# (#defaultsObj.trans("level")#: #folder_level#)</option>
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
	<td nowrap="true">#defaultsObj.trans("show_in_intranet")#</td>
	<td><input type="radio" name="set2_cat_intra" value="T"<cfif #prefs.set2_cat_intra# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="set2_cat_intra" value="F"<cfif #prefs.set2_cat_intra# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("show_in_website")#</td>
	<td><input type="radio" name="set2_cat_web" value="T"<cfif #prefs.set2_cat_web# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="set2_cat_web" value="F"<cfif #prefs.set2_cat_web# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
	</tr>
	 --->
	<!--- Image Formats --->
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("header_img_format")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_img_format_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("header_img_format")#</td>
	<td><select name="set2_img_format" class="text">
	<option value="jpg"<cfif #prefs.set2_img_format# EQ "jpg"> selected</cfif>>JPG</option>
	<option value="gif"<cfif #prefs.set2_img_format# EQ "gif"> selected</cfif>>GIF</option>
	<option value="png"<cfif #prefs.set2_img_format# EQ "PNG"> selected</cfif>>PNG</option>
	</select></td>
	</tr>
	<!--- Image Sizes --->
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("header_img_size")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_img_size_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("header_img_thumbnail")#</td>
	<td><input type="text" name="set2_img_thumb_width" size="4" maxlength="3" value="#prefs.set2_img_thumb_width#" /> #defaultsObj.trans("header_img_width")# <input type="text" name="set2_img_thumb_heigth" size="4" maxlength="3" value="#prefs.set2_img_thumb_heigth#" /> #defaultsObj.trans("header_img_height")#</td>
	</tr>
	<!--- <tr>
	<td>#defaultsObj.trans("header_img_comping")#</td>
	<td><input type="text" name="set2_img_comp_width" size="4" maxlength="3" value="#prefs.set2_img_comp_width#" /> #defaultsObj.trans("header_img_width")# <input type="text" name="set2_img_comp_heigth" size="4" maxlength="3" value="#prefs.set2_img_comp_heigth#" /> #defaultsObj.trans("header_img_height")#</td>
	</tr> --->
	<!--- Image Magick Path --->
	<!---
<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("header_imagemagick")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_imagemagick_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("imagemagick_path")#</td>
	<td><input type="text" name="set2_path_imagemagick" value="#prefs.set2_path_imagemagick#" size="60" class="text"></td>
	</tr>
--->
	<!--- Exiftool Path --->
<!---
	<tr>
		<th class="textbold" colspan="2">#defaultsObj.trans("header_exiftool")#</th>
	</tr>
	<tr>
		<td colspan="2">#defaultsObj.trans("header_exiftool_desc")#</td>
	</tr>
	<tr>
		<td>#defaultsObj.trans("exiftool_path")#</td>
		<td><input type="text" name="set2_path_to_exiftool" value="#prefs.set2_path_to_exiftool#" size="60" class="text"></td>
	</tr>
--->
	<!--- Watermark
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("header_watermark")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_watermark_desc")#</td>
	</tr>
	<tr>
	<td valign="top">#defaultsObj.trans("watermark_path")#</td>
	<td>
		<div id="iframe">
			<iframe src="#myself#c.prefs_imgupload&thefield=set2_watermark" frameborder="false" scrolling="false" style="border:0px;width:550px;height:40px;"></iframe>
       	</div>
	</td>
	</tr>
	<cfif #prefs.set2_path_imagemagick# IS NOT "">
	<tr>
	<td colspan="2"><a href="images/watermark_demo/demo_watermarked.jpg" target="_blank"><u>#defaultsObj.trans("show_example")#</u></a></td>
	</tr>
	</cfif>
	 --->
	</table>
</cfoutput>