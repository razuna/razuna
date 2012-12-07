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
<!--- For the preset include below --->
<cfset incval = structnew()>
<cfset incval.theform = "formupltemp">
<form action="#self#" method="post" name="formupltemp" id="formupltemp">
<input type="hidden" name="#theaction#" value="c.upl_template_save">
<input type="hidden" name="upl_temp_id" value="#attributes.upl_temp_id#">
<div id="tab_upl_temp">
	<ul>
		<li><a href="##tab_upl_temp_all">#myFusebox.getApplicationData().defaults.trans("settings")#</a></li>
		<li><a href="##tab_upl_temp_img">#myFusebox.getApplicationData().defaults.trans("header_img")#</a></li>
		<li><a href="##tab_upl_temp_vid">#myFusebox.getApplicationData().defaults.trans("header_vid")#</a></li>
		<li><a href="##tab_upl_temp_aud">#myFusebox.getApplicationData().defaults.trans("header_aud")#</a></li>
	</ul>
	<!--- User --->
	<div id="tab_upl_temp_all">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("settings")#</td>
			</tr>
			<tr>
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_active")#</td>
				<td><input type="checkbox" name="upl_active" value="1"<cfif qry_detail.upl.upl_active EQ 1> checked="checked"</cfif>></td>
			</tr>
			<tr>
				<td>ID</td>
				<td>#attributes.upl_temp_id#</td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_name")#*</td>
				<td><input type="text" name="upl_name" id="upl_name" class="text" value="#qry_detail.upl.upl_name#" style="width:300px;"><label for="upl_name" class="error" style="color:red;"><br>Enter a name for the template!</label></td>
			</tr>
			<tr>
				<td nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("description")#</td>
				<td><textarea name="upl_description" style="width:300px;height:60px;">#qry_detail.upl.upl_description#</textarea></td>
			</tr>
		</table>
	</div>
	<!--- Images --->
	<div id="tab_upl_temp_img">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="3">#myFusebox.getApplicationData().defaults.trans("header_img")#</td>
			</tr>
			<tr>
				<td colspan="3">#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_desc")#</td>
			</tr>
			<tr>
				<td width="1%" nowrap="true" valign="top">
					<input type="checkbox" name="convert_to" value="img-jpg"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',0)" style="text-decoration:none;">JPG</a>
					<input type="text" size="4" name="convert_width_jpg" id="convert_width_jpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg','convert_height_jpg');"> x <input type="text" size="4" name="convert_height_jpg" id="convert_height_jpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg','convert_width_jpg');"> <a href="##" onclick="$('##jpg_more').slideToggle('slow');return false;">Additional JPG conversions</a>
					<!--- The Div --->
					<div id="jpg_more" style="padding-left:10px;display:none;">
						<br />
						<input type="checkbox" name="convert_to" value="img-jpg_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_2"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',1)" style="text-decoration:none;">JPEG</a>
						<input type="text" size="4" name="convert_width_jpg_2" id="convert_width_jpg_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_2','convert_height_jpg_2');"> x <input type="text" size="4" name="convert_height_jpg_2" id="convert_height_jpg_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_2','convert_width_jpg_2');">
						<br />
						<input type="checkbox" name="convert_to" value="img-jpg_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_3"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',2)" style="text-decoration:none;">JPEG</a>
						<input type="text" size="4" name="convert_width_jpg_3" id="convert_width_jpg_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_3','convert_height_jpg_3');"> x <input type="text" size="4" name="convert_height_jpg_3" id="convert_height_jpg_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_3','convert_width_jpg_3');">
						<br />
						<input type="checkbox" name="convert_to" value="img-jpg_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_4"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',3)" style="text-decoration:none;">JPEG</a>
						<input type="text" size="4" name="convert_width_jpg_4" id="convert_width_jpg_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_4','convert_height_jpg_4');"> x <input type="text" size="4" name="convert_height_jpg_4" id="convert_height_jpg_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_4','convert_width_jpg_4');">
						<br />
						<input type="checkbox" name="convert_to" value="img-jpg_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_5"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',4)" style="text-decoration:none;">JPEG</a>
						<input type="text" size="4" name="convert_width_jpg_5" id="convert_width_jpg_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_5','convert_height_jpg_5');"> x <input type="text" size="4" name="convert_height_jpg_5" id="convert_height_jpg_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_5','convert_width_jpg_5');">
						<br />
						<input type="checkbox" name="convert_to" value="img-jpg_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_6"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',5)" style="text-decoration:none;">JPEG</a>
						<input type="text" size="4" name="convert_width_jpg_6" id="convert_width_jpg_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_6','convert_height_jpg_6');"> x <input type="text" size="4" name="convert_height_jpg_6" id="convert_height_jpg_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_6','convert_width_jpg_6');">
						<br />
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<input type="checkbox" name="convert_to" value="img-gif"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif"> checked="checked"</cfif></cfloop>>
					<a href="##" onclick="clickcbk('formupltemp','convert_to',6)" style="text-decoration:none;">GIF </a>
					<input type="text" size="4" name="convert_width_gif" id="convert_width_gif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif','convert_height_gif');"> x <input type="text" size="4" name="convert_height_gif" id="convert_height_gif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif','convert_width_gif');"> <a href="##" onclick="$('##gif_more').slideToggle('slow');return false;">Additional GIF conversions</a>
					<!--- The Div --->
					<div id="gif_more" style="padding-left:10px;display:none;">
						<br />
						<input type="checkbox" name="convert_to" value="img-gif_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_2"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',7)" style="text-decoration:none;">GIF </a>
						<input type="text" size="4" name="convert_width_gif_2" id="convert_width_gif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_2','convert_height_gif_2');"> x <input type="text" size="4" name="convert_height_gif_2" id="convert_height_gif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_2','convert_width_gif_2');">
						<br />
						<input type="checkbox" name="convert_to" value="img-gif_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_3"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',8)" style="text-decoration:none;">GIF </a>
						<input type="text" size="4" name="convert_width_gif_3" id="convert_width_gif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_3','convert_height_gif_3');"> x <input type="text" size="4" name="convert_height_gif_3" id="convert_height_gif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_3','convert_width_gif_3');">
						<br />
						<input type="checkbox" name="convert_to" value="img-gif_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_4"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',9)" style="text-decoration:none;">GIF </a>
						<input type="text" size="4" name="convert_width_gif_4" id="convert_width_gif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_4','convert_height_gif_4');"> x <input type="text" size="4" name="convert_height_gif_4" id="convert_height_gif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_4','convert_width_gif_4');">
						<br />
						<input type="checkbox" name="convert_to" value="img-gif_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_5"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',10)" style="text-decoration:none;">GIF </a>
						<input type="text" size="4" name="convert_width_gif_5" id="convert_width_gif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_5','convert_height_gif_5');"> x <input type="text" size="4" name="convert_height_gif_5" id="convert_height_gif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_5','convert_width_gif_5');">
						<br />
						<input type="checkbox" name="convert_to" value="img-gif_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_6"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',11)" style="text-decoration:none;">GIF </a>
						<input type="text" size="4" name="convert_width_gif_6" id="convert_width_gif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_6','convert_height_gif_6');"> x <input type="text" size="4" name="convert_height_gif_6" id="convert_height_gif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_6','convert_width_gif_6');">
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<input type="checkbox" name="convert_to" value="img-png"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png"> checked="checked"</cfif></cfloop>>
					<a href="##" onclick="clickcbk('formupltemp','convert_to',12)" style="text-decoration:none;">PNG</a>
					<input type="text" size="4" name="convert_width_png" id="convert_width_png" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png','convert_height_png');"> x <input type="text" size="4" name="convert_height_png" id="convert_height_png" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png','convert_width_png');"> <a href="##" onclick="$('##png_more').slideToggle('slow');return false;">Additional PNG conversions</a>
					<!--- The Div --->
					<div id="png_more" style="padding-left:10px;display:none;">
						<br />
						<input type="checkbox" name="convert_to" value="img-png_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_2"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',13)" style="text-decoration:none;">PNG</a>
						<input type="text" size="4" name="convert_width_png_2" id="convert_width_png_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_2','convert_height_png_2');"> x <input type="text" size="4" name="convert_height_png_2" id="convert_height_png_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_2','convert_width_png_2');">
						<br />
						<input type="checkbox" name="convert_to" value="img-png_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_3"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',14)" style="text-decoration:none;">PNG</a>
						<input type="text" size="4" name="convert_width_png_3" id="convert_width_png_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_3','convert_height_png_3');"> x <input type="text" size="4" name="convert_height_png_3" id="convert_height_png_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_3','convert_width_png_3');">
						<br />
						<input type="checkbox" name="convert_to" value="img-png_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_4"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',15)" style="text-decoration:none;">PNG</a>
						<input type="text" size="4" name="convert_width_png_4" id="convert_width_png_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_4','convert_height_png_4');"> x <input type="text" size="4" name="convert_height_png_4" id="convert_height_png_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_4','convert_width_png_4');">
						<br />
						<input type="checkbox" name="convert_to" value="img-png_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_5"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',16)" style="text-decoration:none;">PNG</a>
						<input type="text" size="4" name="convert_width_png_5" id="convert_width_png_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_5','convert_height_png_5');"> x <input type="text" size="4" name="convert_height_png_5" id="convert_height_png_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_5','convert_width_png_5');">
						<br />
						<input type="checkbox" name="convert_to" value="img-png_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_6"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',17)" style="text-decoration:none;">PNG</a>
						<input type="text" size="4" name="convert_width_png_6" id="convert_width_png_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_6','convert_height_png_6');"> x <input type="text" size="4" name="convert_height_png_6" id="convert_height_png_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_6','convert_width_png_6');">
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<input type="checkbox" name="convert_to" value="img-tif"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif"> checked="checked"</cfif></cfloop>>
					<a href="##" onclick="clickcbk('formupltemp','convert_to',18)" style="text-decoration:none;">TIFF</a>
					<input type="text" size="4" name="convert_width_tif" id="convert_width_tif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif','convert_height_tif');"> x <input type="text" size="4" name="convert_height_tif" id="convert_height_tif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif','convert_width_tif');"> <a href="##" onclick="$('##tif_more').slideToggle('slow');return false;">Additional TIF conversions</a>
					<!--- The Div --->
					<div id="tif_more" style="padding-left:10px;display:none;">
						<br />
						<input type="checkbox" name="convert_to" value="img-tif_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_2"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',19)" style="text-decoration:none;">TIFF</a>
						<input type="text" size="4" name="convert_width_tif_2" id="convert_width_tif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_2','convert_height_tif_2');"> x <input type="text" size="4" name="convert_height_tif_2" id="convert_height_tif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_2','convert_width_tif_2');">
						<br />
						<input type="checkbox" name="convert_to" value="img-tif_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_3"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',20)" style="text-decoration:none;">TIFF</a>
						<input type="text" size="4" name="convert_width_tif_3" id="convert_width_tif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_3','convert_height_tif_3');"> x <input type="text" size="4" name="convert_height_tif_3" id="convert_height_tif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_3','convert_width_tif_3');">
						<br />
						<input type="checkbox" name="convert_to" value="img-tif_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_4"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',21)" style="text-decoration:none;">TIFF</a>
						<input type="text" size="4" name="convert_width_tif_4" id="convert_width_tif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_4','convert_height_tif_4');"> x <input type="text" size="4" name="convert_height_tif_4" id="convert_height_tif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_4','convert_width_tif_4');">
						<br />
						<input type="checkbox" name="convert_to" value="img-tif_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_5"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',22)" style="text-decoration:none;">TIFF</a>
						<input type="text" size="4" name="convert_width_tif_5" id="convert_width_tif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_5','convert_height_tif_5');"> x <input type="text" size="4" name="convert_height_tif_5" id="convert_height_tif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_5','convert_width_tif_5');">
						<br />
						<input type="checkbox" name="convert_to" value="img-tif_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_6"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',23)" style="text-decoration:none;">TIFF</a>
						<input type="text" size="4" name="convert_width_tif_6" id="convert_width_tif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_6','convert_height_tif_6');"> x <input type="text" size="4" name="convert_height_tif_6" id="convert_height_tif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_6','convert_width_tif_6');">
					</div>
				</td>
			</tr>
			<tr>
				<td>
					<input type="checkbox" name="convert_to" value="img-bmp"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp"> checked="checked"</cfif></cfloop>>
					<a href="##" onclick="clickcbk('formupltemp','convert_to',24)" style="text-decoration:none;">BMP</a>
					<input type="text" size="4" name="convert_width_bmp" id="convert_width_bmp" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp','convert_height_bmp');"> x <input type="text" size="4" name="convert_height_bmp" id="convert_height_bmp" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp','convert_width_bmp');"> <a href="##" onclick="$('##bmp_more').slideToggle('slow');return false;">Additional BMP conversions</a>
					<!--- The Div --->
					<div id="bmp_more" style="padding-left:10px;display:none;">
						<br />
						<input type="checkbox" name="convert_to" value="img-bmp_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_2"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',25)" style="text-decoration:none;">BMP</a>
						<input type="text" size="4" name="convert_width_bmp_2" id="convert_width_bmp_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_2','convert_height_bmp_2');"> x <input type="text" size="4" name="convert_height_bmp_2" id="convert_height_bmp_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_2','convert_width_bmp_2');">
						<br />
						<input type="checkbox" name="convert_to" value="img-bmp_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_3"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',26)" style="text-decoration:none;">BMP</a>
						<input type="text" size="4" name="convert_width_bmp_3" id="convert_width_bmp_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_3','convert_height_bmp_3');"> x <input type="text" size="4" name="convert_height_bmp_3" id="convert_height_bmp_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_3','convert_width_bmp_3');">
						<br />
						<input type="checkbox" name="convert_to" value="img-bmp_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_4"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',27)" style="text-decoration:none;">BMP</a>
						<input type="text" size="4" name="convert_width_bmp_4" id="convert_width_bmp_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_4','convert_height_bmp_4');"> x <input type="text" size="4" name="convert_height_bmp_4" id="convert_height_bmp_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_4','convert_width_bmp_4');">
						<br />
						<input type="checkbox" name="convert_to" value="img-bmp_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_5"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',28)" style="text-decoration:none;">BMP</a>
						<input type="text" size="4" name="convert_width_bmp_5" id="convert_width_bmp_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_5','convert_height_bmp_5');"> x <input type="text" size="4" name="convert_height_bmp_5" id="convert_height_bmp_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_5','convert_width_bmp_5');">
						<br />
						<input type="checkbox" name="convert_to" value="img-bmp_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_6"> checked="checked"</cfif></cfloop>>
						<a href="##" onclick="clickcbk('formupltemp','convert_to',29)" style="text-decoration:none;">BMP</a>
						<input type="text" size="4" name="convert_width_bmp_6" id="convert_width_bmp_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_6','convert_height_bmp_6');"> x <input type="text" size="4" name="convert_height_bmp_6" id="convert_height_bmp_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_6','convert_width_bmp_6');">
					</div>
				</td>
			</tr>
		</table>
	</div>
	<!--- Videos --->
	<div id="tab_upl_temp_vid">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="4">#myFusebox.getApplicationData().defaults.trans("header_vid")#</td>
			</tr>
			<tr>
				<td colspan="4">#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_vid_desc")#</td>
			</tr>
			<tr>
				<td></td>
				<td></td>
				<td><strong>Choose Preset</strong></td>
				<td><strong>#myFusebox.getApplicationData().defaults.trans("size")#</strong></td>
				<!--- <td><strong>BitRate</strong></td> --->
			</tr>
			<!--- OGV --->
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-ogv"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogv"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',5);return false;" style="text-decoration:none;">OGG (OGV)*</a></td>
				<td>
					<cfset incval.theformat = "ogv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_ogv" id="convert_width_ogv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_ogv">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_ogv" id="convert_height_ogv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_ogv">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogv"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_ogv" value="#bit#">kb/s</td> --->
			</tr>
			<!--- WebM --->
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-webm"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "webm"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',6);return false;" style="text-decoration:none;">WebM (WebM)*</a></td>
				<td>
					<cfset incval.theformat = "webm">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_webm" id="convert_width_webm" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_webm">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_webm" id="convert_height_webm" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_webm">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_webm"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_webm" value="#bit#">kb/s</td> --->
			</tr>
			<!--- Flash --->
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-flv"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flv"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',7);return false;" style="text-decoration:none;">Flash (FLV)</a></td>
				<td>
					<cfset incval.theformat = "flv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_flv" id="convert_width_flv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_flv">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_flv" id="convert_height_flv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_flv">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_flv"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_flv" value="#bit#">kb/s</td> --->
			</tr>
			<!--- MP4 --->
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-mp4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp4"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',8);return false;" style="text-decoration:none;">Mpeg4 (MP4)</a></td>
				<td>
					<cfset incval.theformat = "mp4">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_mp4" id="convert_width_mp4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mp4">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_mp4" id="convert_height_mp4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mp4">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp4"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mp4" value="#bit#">kb/s</td> --->
			</tr>
			<cfset bit = 600>
			<tr>
				<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="vid-wmv"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wmv"> checked="checked"</cfif></cfloop>></td>
				<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('formupltemp','convert_to',9);return false;" style="text-decoration:none;">Windows Media Video (WMV)</a></td>
				<td>
					<cfset incval.theformat = "wmv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td width="1%" nowrap="true"><input type="text" size="3" name="convert_width_wmv" id="convert_width_wmv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_wmv">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_wmv" id="convert_height_wmv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_wmv">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_wmv"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td width="100%" nowrap="true"><input type="text" size="4" name="convert_bitrate_wmv" value="#bit#">kb/s</td> --->
			</tr>
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-avi"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "avi"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',10);return false;" style="text-decoration:none;">Audio Video Interlaced (AVI)</a></td>
				<td>
					<cfset incval.theformat = "avi">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_avi" id="convert_width_avi" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_avi">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_avi" id="convert_height_avi" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_avi">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_avi"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_avi" value="#bit#">kb/s</td> --->
			</tr>
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-mov"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mov"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',11);return false;" style="text-decoration:none;">Quicktime (MOV)</a></td>
				<td>
					<cfset incval.theformat = "mov">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_mov" id="convert_width_mov" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mov">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_mov" id="convert_height_mov" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mov">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mov"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mov" value="#bit#">kb/s</td> --->
			</tr>
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-mpg"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mpg"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',12)" style="text-decoration:none;">Mpeg1 Mpeg2 (MPG)</a></td>
				<td>
					<cfset incval.theformat = "mpg">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_mpg" id="convert_width_mpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mpg">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_mpg" id="convert_height_mpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mpg">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mpg"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mpg" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-3gp" onclick="clickset3gp('formupltemp');"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "3gp"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',13);clickset3gp('form');return false;" style="text-decoration:none;">3GP (3GP)</a></td>
				<td nowrap="true">
				<select name="convert_wh_3gp" onChange="javascript:set3gp('form');">
				<option value="0"></option>
				<option value="1" selected="true">128x96 (MMS 64K)</option>
				<option value="2">128x96 (MMS 95K)</option>
				<option value="3">176x144 (MMS 95K)</option>
				<option value="4">128x96 (200K)</option>
				<option value="5">176x144 (200K)</option>
				<option value="6">128x96 (300K)</option>
				<option value="7">176x144 (300K)</option>
				<option value="8">128x96 (No size limit)</option>
				<option value="9">176x144 (No size limit)</option>
				<option value="10">352x288 (No size limit)</option>
				<option value="11">704x576 (No size limit)</option>
				<option value="12">1408x1152 (No size limit)</option>
				</select>
				</td>
				<cfset b3gp = 64>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_3gp"><cfset b3gp = upl_temp_value></cfif></cfloop>
				<td nowrap="true"><input type="text" size="4" name="convert_bitrate_3gp" value="#b3gp#">kb/s</td>
			</tr>
			<cfset bit = 600>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-rm"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "rm"> checked="checked"</cfif></cfloop>></td>
				<td nowrap="true"><a href="##" onclick="clickcbk('formupltemp','convert_to',14);return false;" style="text-decoration:none;">RealNetwork Video Data (RM)</a></td>
				<td>
					<cfset incval.theformat = "rm">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_rm" id="convert_width_rm" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_rm">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_rm" id="convert_height_rm" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_rm">#upl_temp_value#</cfif></cfloop>"></td>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_rm"><cfset bit = upl_temp_value></cfif></cfloop>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_rm" value="#bit#">kb/s</td> --->
			</tr>
		</table>
	</div>
	<!--- Audios --->
	<div id="tab_upl_temp_aud">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="4">#myFusebox.getApplicationData().defaults.trans("header_aud")#</td>
			</tr>
			<tr>
				<td colspan="4">#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_desc")#</td>
			</tr>
			<tr>
				<td></td>
				<td></td>
				<td><strong>BitRate</strong></td>
				<td></td>
			</tr>
			<cfset bitrate_mp3 = 192>
			<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp3"><cfset bitrate_mp3 = upl_temp_value></cfif></cfloop>
			<tr>
				<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="aud-mp3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp3"> checked="checked"</cfif></cfloop>></td>
				<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('formupltemp','convert_to',15)" style="text-decoration:none;">MP3</a></td>
				<td width="1%" nowrap="true"><select name="convert_bitrate_mp3" id="convert_bitrate_mp3">
				<option value="32"<cfif bitrate_mp3 EQ 32> selected="true"</cfif>>32</option>
				<option value="48"<cfif bitrate_mp3 EQ 48> selected="true"</cfif>>48</option>
				<option value="64"<cfif bitrate_mp3 EQ 64> selected="true"</cfif>>64</option>
				<option value="96"<cfif bitrate_mp3 EQ 96> selected="true"</cfif>>96</option>
				<option value="128"<cfif bitrate_mp3 EQ 128> selected="true"</cfif>>128</option>
				<option value="160"<cfif bitrate_mp3 EQ 160> selected="true"</cfif>>160</option>
				<option value="192"<cfif bitrate_mp3 EQ 192> selected="true"</cfif>>192</option>
				<option value="256"<cfif bitrate_mp3 EQ 256> selected="true"</cfif>>256</option>
				<option value="320"<cfif bitrate_mp3 EQ 320> selected="true"</cfif>>320</option>
				</select></td>
				<td></td>
			</tr>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="aud-wav"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wav"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',16)" style="text-decoration:none;">WAV</a></td>
				<td></td>
				<td></td>
			</tr>
			<cfset bitrate_ogg = 60>
			<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogg"><cfset bitrate_ogg = upl_temp_value></cfif></cfloop>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="aud-ogg"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogg"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',17)" style="text-decoration:none;">OGG</a></td>
				<td><select name="convert_bitrate_ogg" id="convert_bitrate_ogg">
				<option value="10"<cfif bitrate_ogg EQ 10> selected="true"</cfif>>82</option>
				<option value="20"<cfif bitrate_ogg EQ 20> selected="true"</cfif>>102</option>
				<option value="30"<cfif bitrate_ogg EQ 30> selected="true"</cfif>>115</option>
				<option value="40"<cfif bitrate_ogg EQ 40> selected="true"</cfif>>137</option>
				<option value="50"<cfif bitrate_ogg EQ 50> selected="true"</cfif>>147</option>
				<option value="60"<cfif bitrate_ogg EQ 60> selected="true"</cfif>>176</option>
				<option value="70"<cfif bitrate_ogg EQ 70> selected="true"</cfif>>192</option>
				<option value="80"<cfif bitrate_ogg EQ 80> selected="true"</cfif>>224</option>
				<option value="90"<cfif bitrate_ogg EQ 90> selected="true"</cfif>>290</option>
				<option value="100"<cfif bitrate_ogg EQ 100> selected="true"</cfif>>434</option>
				</select></td>
				<td>OGG has a much better compression, thus you don't need a high bitrate to achieve good quality.</td>
			</tr>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="aud-flac"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flac"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',18)" style="text-decoration:none;">FLAC</a></td>
				<td></td>
				<td></td>
			</tr>
		</table>
	</div>
</div>
<div id="submit" style="float:right;padding:10px;">
	<div id="upltempfeedback" style="color:green;padding:10px;display:none;float:left;font-weight:bold;"></div>
	<input type="submit" name="SubmitUser" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" style="float:right;">
</div>

</form>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	// Initialize Tabs
	jqtabs("tab_upl_temp");
	// Fire the form submit for new or update
	$(document).ready(function(){
		$("##formupltemp").validate({
			submitHandler: function(form) {
				jQuery(form).ajaxSubmit({
					success: formupltempfeedback
				});
			},
			rules: {
				upl_name: "required"			   
			 }
		});
	});
	// Feedback when saving form
	function formupltempfeedback() {
		$("##upltempfeedback").css("display","");
		$("##upltempfeedback").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("success"))#");
		loadcontent('admin_upl_templates', '#myself#c.upl_templates');
	}
	// Emtpy the width or the height and make it read only
	function whr(thethis,thefield) {
		// Get value of current field
		var currentval = $('##' + thethis).val();
		// If both fields are empty enable both
		if (currentval == '') {
			$('##' + thethis).css('display', '');
			$('##' + thefield).css('display', '');
		}
		else {
			// clear the value from the other field
			$('##' + thefield).val('');
			// Make it read only
			$('##' + thefield).css('display', 'none');
		}
	}
</script>

</cfoutput>