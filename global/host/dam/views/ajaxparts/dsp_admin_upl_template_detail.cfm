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
<input type="hidden" name="convert_width_3gp" value="">
<input type="hidden" name="convert_height_3gp" value="">
<input type="hidden" name="convert_bitrate_3gp" value="">
<cfloop from="2" to="6" index="idx" >
	<input type="hidden" name="convert_width_3gp_#idx#" value="">
	<input type="hidden" name="convert_height_3gp_#idx#" value="">
	<input type="hidden" name="convert_bitrate_3gp_#idx#" value="">
</cfloop>
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
				<td nowrap="nowrap">
					<input type="checkbox" name="convert_to" value="img-jpg"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',0);return false;" style="text-decoration:none;">JPG</a>
				</td>
				<td width="100%">
					<input type="text" size="4" name="convert_width_jpg" id="convert_width_jpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg','convert_height_jpg');" maxlength="4"> x <input type="text" size="4" name="convert_height_jpg" id="convert_height_jpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg','convert_width_jpg');" maxlength="4">  or <input type="text" size="4" name="convert_dpi_jpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_jpg">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
					<!--- Watermark --->
					<cfif attributes.wmtemplates.recordcount NEQ 0>
						<select name="convert_wm_jpg" id="convert_wm_jpg">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<cfset wm_temp_id = wm_temp_id>
								<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_jpg" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
							</cfloop>
						</select>
					</cfif>
					<a href="##" onclick="$('##jpg_more').slideToggle('slow');return false;">Additional JPG conversions</a>
				</td>
			</tr>
			<!--- The Div --->
			<tr>
				<td colspan="3">		
					<div id="jpg_more" style="padding-left:10px;display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td nowrap="nowrap">
									<input type="checkbox" name="convert_to" value="img-jpg_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_2"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',1);return false;" style="text-decoration:none;">JPG</a>
								</td>
								<td width="100%">
									<input type="text" size="4" name="convert_width_jpg_2" id="convert_width_jpg_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_2','convert_height_jpg_2');" maxlength="4"> x <input type="text" size="4" name="convert_height_jpg_2" id="convert_height_jpg_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_2','convert_width_jpg_2');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_jpg_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_jpg_2">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_jpg_2" id="convert_wm_jpg_2">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_jpg_2" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-jpg_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_3"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',2);return false;" style="text-decoration:none;">JPG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_jpg_3" id="convert_width_jpg_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_3','convert_height_jpg_3');" maxlength="4"> x <input type="text" size="4" name="convert_height_jpg_3" id="convert_height_jpg_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_3','convert_width_jpg_3');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_jpg_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_jpg_3">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_jpg_3" id="convert_wm_jpg_3">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_jpg_3" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-jpg_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_4"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',3);return false;" style="text-decoration:none;">JPG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_jpg_4" id="convert_width_jpg_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_4','convert_height_jpg_4');" maxlength="4"> x <input type="text" size="4" name="convert_height_jpg_4" id="convert_height_jpg_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_4','convert_width_jpg_4');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_jpg_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_jpg_4">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_jpg_4" id="convert_wm_jpg_4">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_jpg_4" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-jpg_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_5"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',4);return false;" style="text-decoration:none;">JPG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_jpg_5" id="convert_width_jpg_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_5','convert_height_jpg_5');" maxlength="4"> x <input type="text" size="4" name="convert_height_jpg_5" id="convert_height_jpg_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_5','convert_width_jpg_5');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_jpg_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_jpg_5">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_jpg_5" id="convert_wm_jpg_5">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_jpg_5" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-jpg_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "jpg_6"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',5);return false;" style="text-decoration:none;">JPG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_jpg_6" id="convert_width_jpg_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_jpg_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_jpg_6','convert_height_jpg_6');" maxlength="4"> x <input type="text" size="4" name="convert_height_jpg_6" id="convert_height_jpg_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_jpg_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_jpg_6','convert_width_jpg_6');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_jpg_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_jpg_6">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_jpg_6" id="convert_wm_jpg_6">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_jpg_6" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td nowrap="nowrap">
					<input type="checkbox" name="convert_to" value="img-gif"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',6);return false;" style="text-decoration:none;">GIF </a>
				</td>
				<td>
					<input type="text" size="4" name="convert_width_gif" id="convert_width_gif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif','convert_height_gif');" maxlength="4"> x <input type="text" size="4" name="convert_height_gif" id="convert_height_gif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif','convert_width_gif');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_gif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_gif">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
					<!--- Watermark --->
					<cfif attributes.wmtemplates.recordcount NEQ 0>
						<select name="convert_wm_gif" id="convert_wm_gif">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<cfset wm_temp_id = wm_temp_id>
								<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_gif" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
							</cfloop>
						</select>
					</cfif>
					<a href="##" onclick="$('##gif_more').slideToggle('slow');return false;">Additional GIF conversions</a>
				</td>
			</tr>
			<!--- The Div --->
			<tr>
				<td colspan="3">
					<div id="gif_more" style="padding-left:10px;display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td nowrap="nowrap">
									<input type="checkbox" name="convert_to" value="img-gif_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_2"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',7);return false;" style="text-decoration:none;">GIF </a>
								</td>
								<td width="100%">
									<input type="text" size="4" name="convert_width_gif_2" id="convert_width_gif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_2','convert_height_gif_2');" maxlength="4"> x <input type="text" size="4" name="convert_height_gif_2" id="convert_height_gif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_2','convert_width_gif_2');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_gif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_gif_2">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_gif_2" id="convert_wm_gif_2">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_gif_2" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-gif_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_3"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',8);return false;" style="text-decoration:none;">GIF </a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_gif_3" id="convert_width_gif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_3','convert_height_gif_3');" maxlength="4"> x <input type="text" size="4" name="convert_height_gif_3" id="convert_height_gif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_3','convert_width_gif_3');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_gif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_gif_3">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_gif_3" id="convert_wm_gif_3">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_gif_3" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-gif_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_4"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',9);return false;" style="text-decoration:none;">GIF </a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_gif_4" id="convert_width_gif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_4','convert_height_gif_4');" maxlength="4"> x <input type="text" size="4" name="convert_height_gif_4" id="convert_height_gif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_4','convert_width_gif_4');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_gif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_gif_4">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_gif_4" id="convert_wm_gif_4">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_gif_4" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-gif_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_5"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',10);return false;" style="text-decoration:none;">GIF </a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_gif_5" id="convert_width_gif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_5','convert_height_gif_5');" maxlength="4"> x <input type="text" size="4" name="convert_height_gif_5" id="convert_height_gif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_5','convert_width_gif_5');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_gif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_gif_5">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_gif_5" id="convert_wm_gif_5">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_gif_5" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-gif_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "gif_6"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',11);return false;" style="text-decoration:none;">GIF </a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_gif_6" id="convert_width_gif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_gif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_gif_6','convert_height_gif_6');" maxlength="4"> x <input type="text" size="4" name="convert_height_gif_6" id="convert_height_gif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_gif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_gif_6','convert_width_gif_6');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_gif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_gif_6">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_gif_6" id="convert_wm_gif_6">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_gif_6" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td nowrap="nowrap">
					<input type="checkbox" name="convert_to" value="img-png"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',12);return false;" style="text-decoration:none;">PNG</a>
				</td>
				<td>
					<input type="text" size="4" name="convert_width_png" id="convert_width_png" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png','convert_height_png');" maxlength="4"> x <input type="text" size="4" name="convert_height_png" id="convert_height_png" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png','convert_width_png');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_png" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_png_2">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
					<!--- Watermark --->
					<cfif attributes.wmtemplates.recordcount NEQ 0>
						<select name="convert_wm_png" id="convert_wm_png">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<cfset wm_temp_id = wm_temp_id>
								<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_png" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
							</cfloop>
						</select>
					</cfif>
					<a href="##" onclick="$('##png_more').slideToggle('slow');return false;">Additional PNG conversions</a>
				</td>
			</tr>
			<!--- The Div --->
			<tr>
				<td colspan="3">
					<div id="png_more" style="padding-left:10px;display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td nowrap="nowrap">
									<input type="checkbox" name="convert_to" value="img-png_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_2"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',13);return false;" style="text-decoration:none;">PNG</a>
								</td>
								<td width="100%">
									<input type="text" size="4" name="convert_width_png_2" id="convert_width_png_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_2','convert_height_png_2');" maxlength="4"> x <input type="text" size="4" name="convert_height_png_2" id="convert_height_png_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_2','convert_width_png_2');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_png_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_png_2">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_png_2" id="convert_wm_png_2">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_png_2" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-png_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_3"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',14);return false;" style="text-decoration:none;">PNG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_png_3" id="convert_width_png_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_3','convert_height_png_3');" maxlength="4"> x <input type="text" size="4" name="convert_height_png_3" id="convert_height_png_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_3','convert_width_png_3');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_png_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_png_3">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_png_3" id="convert_wm_png_3">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_png_3" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-png_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_4"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',15);return false;" style="text-decoration:none;">PNG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_png_4" id="convert_width_png_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_4','convert_height_png_4');" maxlength="4"> x <input type="text" size="4" name="convert_height_png_4" id="convert_height_png_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_4','convert_width_png_4');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_png_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_png_4">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_png_4" id="convert_wm_png_4">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_png_4" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-png_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_5"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',16);return false;" style="text-decoration:none;">PNG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_png_5" id="convert_width_png_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_5','convert_height_png_5');" maxlength="4"> x <input type="text" size="4" name="convert_height_png_5" id="convert_height_png_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_5','convert_width_png_5');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_png_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_png_5">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_png_5" id="convert_wm_png_5">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_png_5" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-png_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "png_6"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',17);return false;" style="text-decoration:none;">PNG</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_png_6" id="convert_width_png_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_png_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_png_6','convert_height_png_6');" maxlength="4"> x <input type="text" size="4" name="convert_height_png_6" id="convert_height_png_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_png_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_png_6','convert_width_png_6');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_png_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_png_6">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_png_6" id="convert_wm_png_6">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_png_6" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td nowrap="nowrap">
					<input type="checkbox" name="convert_to" value="img-tif"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',18);return false;" style="text-decoration:none;">TIFF</a>
				</td>
				<td>
					<input type="text" size="4" name="convert_width_tif" id="convert_width_tif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif','convert_height_tif');" maxlength="4"> x <input type="text" size="4" name="convert_height_tif" id="convert_height_tif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif','convert_width_tif');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_tif" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_tif">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
					<!--- Watermark --->
					<cfif attributes.wmtemplates.recordcount NEQ 0>
						<select name="convert_wm_tif" id="convert_wm_tif">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<cfset wm_temp_id = wm_temp_id>
								<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_tif" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
							</cfloop>
						</select>
					</cfif>
					<a href="##" onclick="$('##tif_more').slideToggle('slow');return false;">Additional TIF conversions</a>
				</td>
			</tr>
			<!--- The Div --->
			<tr>
				<td colspan="3">
					<div id="tif_more" style="padding-left:10px;display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td nowrap="nowrap">
									<input type="checkbox" name="convert_to" value="img-tif_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_2"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',19);return false;" style="text-decoration:none;">TIFF</a>
								</td>
								<td width="100%">
									<input type="text" size="4" name="convert_width_tif_2" id="convert_width_tif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_2','convert_height_tif_2');" maxlength="4"> x <input type="text" size="4" name="convert_height_tif_2" id="convert_height_tif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_2','convert_width_tif_2');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_tif_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_tif_2">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_tif_2" id="convert_wm_tif_2">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_tif_2" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-tif_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_3"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',20);return false;" style="text-decoration:none;">TIFF</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_tif_3" id="convert_width_tif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_3','convert_height_tif_3');" maxlength="4"> x <input type="text" size="4" name="convert_height_tif_3" id="convert_height_tif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_3','convert_width_tif_3');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_tif_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_tif_3">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_tif_3" id="convert_wm_tif_3">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_tif_3" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-tif_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_4"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',21);return false;" style="text-decoration:none;">TIFF</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_tif_4" id="convert_width_tif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_4','convert_height_tif_4');" maxlength="4"> x <input type="text" size="4" name="convert_height_tif_4" id="convert_height_tif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_4','convert_width_tif_4');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_tif_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_tif_4">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_tif_4" id="convert_wm_tif_4">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_tif_4" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-tif_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_5"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',22);return false;" style="text-decoration:none;">TIFF</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_tif_5" id="convert_width_tif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_5','convert_height_tif_5');" maxlength="4"> x <input type="text" size="4" name="convert_height_tif_5" id="convert_height_tif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_5','convert_width_tif_5');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_tif_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_tif_5">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_tif_5" id="convert_wm_tif_5">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_tif_5" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-tif_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "tif_6"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',23);return false;" style="text-decoration:none;">TIFF</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_tif_6" id="convert_width_tif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_tif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_tif_6','convert_height_tif_6');" maxlength="4"> x <input type="text" size="4" name="convert_height_tif_6" id="convert_height_tif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_tif_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_tif_6','convert_width_tif_6');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_tif_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_tif_6">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_tif_6" id="convert_wm_tif_6">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_tif_6" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td nowrap="nowrap">
					<input type="checkbox" name="convert_to" value="img-bmp"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',24);return false;" style="text-decoration:none;">BMP</a>
				</td>
				<td>
					<input type="text" size="4" name="convert_width_bmp" id="convert_width_bmp" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp','convert_height_bmp');" maxlength="4"> x <input type="text" size="4" name="convert_height_bmp" id="convert_height_bmp" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp','convert_width_bmp');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_bmp" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_bmp">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
					<!--- Watermark --->
					<cfif attributes.wmtemplates.recordcount NEQ 0>
						<select name="convert_wm_bmp" id="convert_wm_bmp">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<cfset wm_temp_id = wm_temp_id>
								<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_bmp" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
							</cfloop>
						</select>
					</cfif>
					<a href="##" onclick="$('##bmp_more').slideToggle('slow');return false;">Additional BMP conversions</a>
				</td>
			</tr>
			<!--- The Div --->
			<tr>
				<td colspan="3">		
					<div id="bmp_more" style="padding-left:10px;display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td nowrap="nowrap">
									<input type="checkbox" name="convert_to" value="img-bmp_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_2"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',25);return false;" style="text-decoration:none;">BMP</a>
								</td>
								<td width="100%">
									<input type="text" size="4" name="convert_width_bmp_2" id="convert_width_bmp_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_2','convert_height_bmp_2');" maxlength="4"> x <input type="text" size="4" name="convert_height_bmp_2" id="convert_height_bmp_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_2">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_2','convert_width_bmp_2');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_bmp_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_bmp_2">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_bmp_2" id="convert_wm_bmp_2">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_bmp_2" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-bmp_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_3"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',26);return false;" style="text-decoration:none;">BMP</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_bmp_3" id="convert_width_bmp_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_3','convert_height_bmp_3');" maxlength="4"> x <input type="text" size="4" name="convert_height_bmp_3" id="convert_height_bmp_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_3">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_3','convert_width_bmp_3');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_bmp_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_bmp_3">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_bmp_3" id="convert_wm_bmp_3">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_bmp_3" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-bmp_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_4"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',27);return false;" style="text-decoration:none;">BMP</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_bmp_4" id="convert_width_bmp_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_4','convert_height_bmp_4');" maxlength="4"> x <input type="text" size="4" name="convert_height_bmp_4" id="convert_height_bmp_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_4">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_4','convert_width_bmp_4');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_bmp_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_bmp_4">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_bmp_4" id="convert_wm_bmp_4">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_bmp_4" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-bmp_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_5"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',28);return false;" style="text-decoration:none;">BMP</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_bmp_5" id="convert_width_bmp_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_5','convert_height_bmp_5');" maxlength="4"> x <input type="text" size="4" name="convert_height_bmp_5" id="convert_height_bmp_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_5">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_5','convert_width_bmp_5');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_bmp_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_bmp_5">#upl_temp_value#</cfif></cfloop>" maxlength="3"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_bmp_5" id="convert_wm_bmp_5">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_bmp_5" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
							<tr>
								<td>
									<input type="checkbox" name="convert_to" value="img-bmp_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "bmp_6"> checked="checked"</cfif></cfloop>> <a href="##" onclick="clickcbk('formupltemp','convert_to',29);return false;" style="text-decoration:none;">BMP</a>
								</td>
								<td>
									<input type="text" size="4" name="convert_width_bmp_6" id="convert_width_bmp_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_bmp_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_width_bmp_6','convert_height_bmp_6');" maxlength="4"> x <input type="text" size="4" name="convert_height_bmp_6" id="convert_height_bmp_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_bmp_6">#upl_temp_value#</cfif></cfloop>" onkeyup="whr('convert_height_bmp_6','convert_width_bmp_6');" maxlength="4"> or <input type="text" size="4" name="convert_dpi_bmp_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_dpi_bmp_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> dpi 
									<!--- Watermark --->
									<cfif attributes.wmtemplates.recordcount NEQ 0>
										<select name="convert_wm_bmp_6" id="convert_wm_bmp_6">
											<option value="" selected="selected">Apply watermark</option>
											<option value="">---</option>
											<cfloop query="attributes.wmtemplates">
												<cfset wm_temp_id = wm_temp_id>
												<option value="#wm_temp_id#"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_wm_bmp_6" AND upl_temp_value EQ wm_temp_id> selected="selected"</cfif></cfloop>>#wm_name#</option>
											</cfloop>
										</select>
									</cfif>
								</td>
							</tr>
						</table>
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
			<!--- <cfset bit = 600> --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-ogv"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogv"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',30);return false;" style="text-decoration:none;">OGG</a></td>
				<td>
					<cfset incval.theformat = "ogv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td width="100%"><input type="text" size="3" name="convert_width_ogv" id="convert_width_ogv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_ogv">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_ogv" id="convert_height_ogv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_ogv">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##ogv_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogv"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_ogv" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="ogv_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-ogv_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogv_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',31);return false;" style="text-decoration:none;">OGG</a></td>
								<td>
									<cfset incval.theformat = "ogv_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_ogv_2" id="convert_width_ogv_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_ogv_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_ogv_2" id="convert_height_ogv_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_ogv_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-ogv_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogv_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',32);return false;" style="text-decoration:none;">OGV</a></td>
								<td>
									<cfset incval.theformat = "ogv_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_ogv_3" id="convert_width_ogv_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_ogv_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_ogv_3" id="convert_height_ogv_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_ogv_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-ogv_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogv_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',33);return false;" style="text-decoration:none;">OGG</a></td>
								<td>
									<cfset incval.theformat = "ogv_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_ogv_4" id="convert_width_ogv_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_ogv_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_ogv_4" id="convert_height_ogv_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_ogv_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-ogv_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogv_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',34);return false;" style="text-decoration:none;">OGG</a></td>
								<td>
									<cfset incval.theformat = "ogv_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_ogv_5" id="convert_width_ogv_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_ogv_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_ogv_5" id="convert_height_ogv_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_ogv_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-ogv_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogv_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',35);return false;" style="text-decoration:none;">OGG</a></td>
								<td>
									<cfset incval.theformat = "ogv_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_ogv_6" id="convert_width_ogv_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_ogv_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_ogv_6" id="convert_height_ogv_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_ogv_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- WebM --->
			<!--- <cfset bit = 600> --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-webm"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "webm"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',36);return false;" style="text-decoration:none;">WebM</a></td>
				<td>
					<cfset incval.theformat = "webm">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_webm" id="convert_width_webm" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_webm">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_webm" id="convert_height_webm" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_webm">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##webm_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_webm"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_webm" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="webm_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-webm_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "webm_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',37);return false;" style="text-decoration:none;">WebM</a></td>
								<td>
									<cfset incval.theformat = "webm_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_webm_2" id="convert_width_webm_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_webm_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_webm_2" id="convert_height_webm_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_webm_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-webm_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "webm_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',38);return false;" style="text-decoration:none;">WebM</a></td>
								<td>
									<cfset incval.theformat = "webm_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_webm_3" id="convert_width_webm_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_webm_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_webm_3" id="convert_height_webm_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_webm_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-webm_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "webm_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',39);return false;" style="text-decoration:none;">WebM</a></td>
								<td>
									<cfset incval.theformat = "webm_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_webm_4" id="convert_width_webm_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_webm_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_webm_4" id="convert_height_webm_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_webm_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-webm_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "webm_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',40);return false;" style="text-decoration:none;">WebM</a></td>
								<td>
									<cfset incval.theformat = "webm_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_webm_5" id="convert_width_webm_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_webm_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_webm_5" id="convert_height_webm_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_webm_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-webm_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "webm_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',41);return false;" style="text-decoration:none;">WebM</a></td>
								<td>
									<cfset incval.theformat = "webm_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_webm_6" id="convert_width_webm_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_webm_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_webm_6" id="convert_height_webm_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_webm_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- Flash --->
			<!--- <cfset bit = 600> --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-flv"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flv"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',42);return false;" style="text-decoration:none;">Flash (FLV)</a></td>
				<td>
					<cfset incval.theformat = "flv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_flv" id="convert_width_flv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_flv">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_flv" id="convert_height_flv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_flv">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##flv_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_flv"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_flv" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="flv_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-flv_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flv_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',43);return false;" style="text-decoration:none;">FLV</a></td>
								<td>
									<cfset incval.theformat = "flv_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_flv_2" id="convert_width_flv_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_flv_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_flv_2" id="convert_height_flv_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_flv_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-flv_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flv_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',44);return false;" style="text-decoration:none;">FLV</a></td>
								<td>
									<cfset incval.theformat = "flv_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_flv_3" id="convert_width_flv_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_flv_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_flv_3" id="convert_height_flv_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_flv_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-flv_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flv_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',45);return false;" style="text-decoration:none;">FLV</a></td>
								<td>
									<cfset incval.theformat = "flv_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_flv_4" id="convert_width_flv_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_flv_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_flv_4" id="convert_height_flv_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_flv_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-flv_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flv_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',46);return false;" style="text-decoration:none;">FLV</a></td>
								<td>
									<cfset incval.theformat = "flv_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_flv_5" id="convert_width_flv_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_flv_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_flv_5" id="convert_height_flv_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_flv_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-flv_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flv_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',47);return false;" style="text-decoration:none;">FLV</a></td>
								<td>
									<cfset incval.theformat = "flv_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_flv_6" id="convert_width_flv_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_flv_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_flv_6" id="convert_height_flv_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_flv_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- MP4 --->
			<!--- <cfset bit = 600> --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-mp4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp4"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',48);return false;" style="text-decoration:none;">Mpeg4 (MP4)</a></td>
				<td>
					<cfset incval.theformat = "mp4">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_mp4" id="convert_width_mp4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mp4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mp4" id="convert_height_mp4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mp4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##mp4_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp4"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mp4" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="mp4_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mp4_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp4_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',49);return false;" style="text-decoration:none;">MP4</a></td>
								<td>
									<cfset incval.theformat = "mp4_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_mp4_2" id="convert_width_mp4_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mp4_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mp4_2" id="convert_height_mp4_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mp4_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mp4_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp4_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',50);return false;" style="text-decoration:none;">MP4</a></td>
								<td>
									<cfset incval.theformat = "mp4_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mp4_3" id="convert_width_mp4_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mp4_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mp4_3" id="convert_height_mp4_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mp4_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mp4_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp4_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',51);return false;" style="text-decoration:none;">MP4</a></td>
								<td>
									<cfset incval.theformat = "mp4_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mp4_4" id="convert_width_mp4_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mp4_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mp4_4" id="convert_height_mp4_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mp4_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mp4_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp4_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',52);return false;" style="text-decoration:none;">MP4</a></td>
								<td>
									<cfset incval.theformat = "mp4_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mp4_5" id="convert_width_mp4_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mp4_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mp4_5" id="convert_height_mp4_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mp4_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mp4_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp4_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',53);return false;" style="text-decoration:none;">MP4</a></td>
								<td>
									<cfset incval.theformat = "mp4_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mp4_6" id="convert_width_mp4_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mp4_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mp4_6" id="convert_height_mp4_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mp4_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- WMV --->
			<!--- <cfset bit = 600> --->
			<tr>
				<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="vid-wmv"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wmv"> checked="checked"</cfif></cfloop>></td>
				<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('formupltemp','convert_to',54);return false;" style="text-decoration:none;">Windows Media Video (WMV)</a></td>
				<td>
					<cfset incval.theformat = "wmv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td width="1%" nowrap="true"><input type="text" size="3" name="convert_width_wmv" id="convert_width_wmv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_wmv">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_wmv" id="convert_height_wmv" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_wmv">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##wmv_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_wmv"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td width="100%" nowrap="true"><input type="text" size="4" name="convert_bitrate_wmv" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="wmv_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-wmv_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wmv_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',55);return false;" style="text-decoration:none;">WMV</a></td>
								<td>
									<cfset incval.theformat = "wmv_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_wmv_2" id="convert_width_wmv_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_wmv_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_wmv_2" id="convert_height_wmv_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_wmv_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-wmv_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wmv_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',56);return false;" style="text-decoration:none;">WMV</a></td>
								<td>
									<cfset incval.theformat = "wmv_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_wmv_3" id="convert_width_wmv_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_wmv_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_wmv_3" id="convert_height_wmv_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_wmv_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-wmv_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wmv_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',57);return false;" style="text-decoration:none;">WMV</a></td>
								<td>
									<cfset incval.theformat = "wmv_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_wmv_4" id="convert_width_wmv_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_wmv_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_wmv_4" id="convert_height_wmv_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_wmv_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-wmv_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wmv_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',58);return false;" style="text-decoration:none;">WMV</a></td>
								<td>
									<cfset incval.theformat = "wmv_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_wmv_5" id="convert_width_wmv_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_wmv_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_wmv_5" id="convert_height_wmv_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_wmv_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-wmv_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wmv_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',59);return false;" style="text-decoration:none;">WMV</a></td>
								<td>
									<cfset incval.theformat = "wmv_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_wmv_6" id="convert_width_wmv_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_wmv_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_wmv_6" id="convert_height_wmv_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_wmv_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- AVI --->
			<!--- <cfset bit = 600> --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-avi"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "avi"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',60);return false;" style="text-decoration:none;">Audio Video Interlaced (AVI)</a></td>
				<td>
					<cfset incval.theformat = "avi">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_avi" id="convert_width_avi" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_avi">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_avi" id="convert_height_avi" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_avi">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##avi_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_avi"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_avi" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="avi_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-avi_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "avi_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',61);return false;" style="text-decoration:none;">AVI</a></td>
								<td>
									<cfset incval.theformat = "avi_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_avi_2" id="convert_width_avi_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_avi_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_avi_2" id="convert_height_avi_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_avi_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-avi_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "avi_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',62);return false;" style="text-decoration:none;">AVI</a></td>
								<td>
									<cfset incval.theformat = "avi_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_avi_3" id="convert_width_avi_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_avi_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_avi_3" id="convert_height_avi_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_avi_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-avi_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "avi_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',63);return false;" style="text-decoration:none;">AVI</a></td>
								<td>
									<cfset incval.theformat = "avi_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_avi_4" id="convert_width_avi_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_avi_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_avi_4" id="convert_height_avi_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_avi_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-avi_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "avi_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',64);return false;" style="text-decoration:none;">AVI</a></td>
								<td>
									<cfset incval.theformat = "avi_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_avi_5" id="convert_width_avi_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_avi_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_avi_5" id="convert_height_avi_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_avi_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-avi_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "avi_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',65);return false;" style="text-decoration:none;">AVI</a></td>
								<td>
									<cfset incval.theformat = "avi_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_avi_6" id="convert_width_avi_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_avi_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_avi_6" id="convert_height_avi_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_avi_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- MOV --->
			<!--- <cfset bit = 600> --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-mov"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mov"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',66);return false;" style="text-decoration:none;">Quicktime (MOV)</a></td>
				<td>
					<cfset incval.theformat = "mov">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_mov" id="convert_width_mov" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mov">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mov" id="convert_height_mov" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mov">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##mov_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mov"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mov" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="mov_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mov_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mov_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',67);return false;" style="text-decoration:none;">MOV</a></td>
								<td>
									<cfset incval.theformat = "mov_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_mov_2" id="convert_width_mov_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mov_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mov_2" id="convert_height_mov_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mov_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mov_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mov_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',68);return false;" style="text-decoration:none;">MOV</a></td>
								<td>
									<cfset incval.theformat = "mov_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mov_3" id="convert_width_mov_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mov_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mov_3" id="convert_height_mov_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mov_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mov_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mov_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',69);return false;" style="text-decoration:none;">MOV</a></td>
								<td>
									<cfset incval.theformat = "mov_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mov_4" id="convert_width_mov_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mov_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mov_4" id="convert_height_mov_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mov_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mov_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mov_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',70);return false;" style="text-decoration:none;">MOV</a></td>
								<td>
									<cfset incval.theformat = "mov_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mov_5" id="convert_width_mov_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mov_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mov_5" id="convert_height_mov_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mov_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mov_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mov_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',71);return false;" style="text-decoration:none;">MOV</a></td>
								<td>
									<cfset incval.theformat = "mov_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mov_6" id="convert_width_mov_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mov_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mov_6" id="convert_height_mov_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mov_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- MPEG --->
			<!--- <cfset bit = 600> --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-mpg"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mpg"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',72);return false;" style="text-decoration:none;">Mpeg1 Mpeg2 (MPG)</a></td>
				<td>
					<cfset incval.theformat = "mpg">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" size="3" name="convert_width_mpg" id="convert_width_mpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mpg">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mpg" id="convert_height_mpg" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mpg">#upl_temp_value#</cfif></cfloop>" maxlength="4"> <a href="##" onclick="$('##mpg_more').slideToggle('slow');return false;">additional conversions</a></td>
				<!--- <cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mpg"><cfset bit = upl_temp_value></cfif></cfloop> --->
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mpg" value="#bit#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="mpg_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mpg_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mpg_2"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',73);return false;" style="text-decoration:none;">MPG</a></td>
								<td>
									<cfset incval.theformat = "mpg_2">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td width="100%"><input type="text" size="3" name="convert_width_mpg_2" id="convert_width_mpg_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mpg_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mpg_2" id="convert_height_mpg_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mpg_2">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mpg_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mpg_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',74);return false;" style="text-decoration:none;">MPG</a></td>
								<td>
									<cfset incval.theformat = "mpg_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mpg_3" id="convert_width_mpg_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mpg_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mpg_3" id="convert_height_mpg_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mpg_3">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mpg_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mpg_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',75);return false;" style="text-decoration:none;">MPG</a></td>
								<td>
									<cfset incval.theformat = "mpg_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mpg_4" id="convert_width_mpg_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mpg_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mpg_4" id="convert_height_mpg_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mpg_4">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mpg_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mpg_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',76);return false;" style="text-decoration:none;">MPG</a></td>
								<td>
									<cfset incval.theformat = "mpg_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mpg_5" id="convert_width_mpg_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mpg_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mpg_5" id="convert_height_mpg_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mpg_5">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-mpg_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mpg_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',77);return false;" style="text-decoration:none;">MPG</a></td>
								<td>
									<cfset incval.theformat = "mpg_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_mpg_6" id="convert_width_mpg_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_mpg_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"> x <input type="text" size="3" name="convert_height_mpg_6" id="convert_height_mpg_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_mpg_6">#upl_temp_value#</cfif></cfloop>" maxlength="4"></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- 3GP --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="vid-3gp" onclick="clickset3gp('formupltemp');"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "3gp"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',78);return false;" style="text-decoration:none;">3GP</a><br /></td>
				<td nowrap="true">
				<select name="convert_wh_3gp" onChange="javascript:set3gp('formupltemp');">
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
				<td>
					<a href="##" onclick="$('##3gp_more').slideToggle('slow');return false;">additional conversions</a>
				</td>
				<!--- <cfset b3gp = 64>
				<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_3gp"><cfset b3gp = upl_temp_value></cfif></cfloop>
				<td nowrap="true"><input type="text" size="4" name="convert_bitrate_3gp" value="#b3gp#">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="4">
					<div id="3gp_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<cfloop from="2" to="6" index="i" >
							<tr>
								<cfset incval.theformat = "3gp_#i#">
									<td align="center" style="width:20px;"><input type="checkbox" name="convert_to" value="vid-3gp_#i#" onclick="clickset3gp_additional('formupltemp','#i#');"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "3gp_#i#"> checked="checked"</cfif></cfloop>></td>
									<td style="width:55px;"><a href="##" onclick="clickcbk('formupltemp','convert_to',79);return false;" style="text-decoration:none;">3GP</a><br /></td>
									<td nowrap="true">
									<select name="convert_wh_3gp_#i#" onChange="javascript:set3gp_additional('formupltemp','#i#');">
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
								<!---<td><input type="text" size="3" name="convert_width_3gp_2" id="convert_width_3gp_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_3gp_2">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_3gp_2" id="convert_height_3gp_2" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_3gp_2">#upl_temp_value#</cfif></cfloop>"></td>--->
							</tr>
							</cfloop>
							<!---<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-3gp_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "3gp_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',80);return false;" style="text-decoration:none;">3GP</a></td>
								<td>
									<cfset incval.theformat = "3gp_3">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_3gp_3" id="convert_width_3gp_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_3gp_3">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_3gp_3" id="convert_height_3gp_3" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_3gp_3">#upl_temp_value#</cfif></cfloop>"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-3gp_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "3gp_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',81);return false;" style="text-decoration:none;">3GP</a></td>
								<td>
									<cfset incval.theformat = "3gp_4">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_3gp_4" id="convert_width_3gp_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_3gp_4">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_3gp_4" id="convert_height_3gp_4" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_3gp_4">#upl_temp_value#</cfif></cfloop>"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-3gp_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "3gp_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',82);return false;" style="text-decoration:none;">3GP</a></td>
								<td>
									<cfset incval.theformat = "3gp_5">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_3gp_5" id="convert_width_3gp_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_3gp_5">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_3gp_5" id="convert_height_3gp_5" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_3gp_5">#upl_temp_value#</cfif></cfloop>"></td>
							</tr>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="vid-3gp_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "3gp_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',83);return false;" style="text-decoration:none;">3GP</a></td>
								<td>
									<cfset incval.theformat = "3gp_6">
									<cfinclude template="inc_video_presets.cfm" />
								</td>
								<td><input type="text" size="3" name="convert_width_3gp_6" id="convert_width_3gp_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_width_3gp_6">#upl_temp_value#</cfif></cfloop>"> x <input type="text" size="3" name="convert_height_3gp_6" id="convert_height_3gp_6" value="<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_height_3gp_6">#upl_temp_value#</cfif></cfloop>"></td>
							</tr>--->
						</table>
					</div>
				</td>
			</tr>
			<!--- RM
			<!--- <cfset bit = 600> --->
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
			</tr> --->
		</table>
	</div>
	<!--- Audios --->
	<div id="tab_upl_temp_aud">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="3">#myFusebox.getApplicationData().defaults.trans("header_aud")#</td>
			</tr>
			<tr>
				<td colspan="3">#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_desc")#</td>
			</tr>
			<tr>
				<td></td>
				<td></td>
				<td><strong>BitRate</strong></td>
			</tr>
			<cfset bitrate_mp3 = 192>
			<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp3"><cfset bitrate_mp3 = upl_temp_value></cfif></cfloop>
			<tr>
				<td width="1%" nowrap="nowrap" align="center"><input type="checkbox" name="convert_to" value="aud-mp3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp3"> checked="checked"</cfif></cfloop>></td>
				<td width="1%" nowrap="nowrap"><a href="##" onclick="clickcbk('formupltemp','convert_to',78);return false;" style="text-decoration:none;">MP3</a></td>
				<td width="100%" nowrap="nowrap">
					<select name="convert_bitrate_mp3" id="convert_bitrate_mp3">
						<option value="32"<cfif bitrate_mp3 EQ 32> selected="true"</cfif>>32</option>
						<option value="48"<cfif bitrate_mp3 EQ 48> selected="true"</cfif>>48</option>
						<option value="64"<cfif bitrate_mp3 EQ 64> selected="true"</cfif>>64</option>
						<option value="96"<cfif bitrate_mp3 EQ 96> selected="true"</cfif>>96</option>
						<option value="128"<cfif bitrate_mp3 EQ 128> selected="true"</cfif>>128</option>
						<option value="160"<cfif bitrate_mp3 EQ 160> selected="true"</cfif>>160</option>
						<option value="192"<cfif bitrate_mp3 EQ 192> selected="true"</cfif>>192</option>
						<option value="256"<cfif bitrate_mp3 EQ 256> selected="true"</cfif>>256</option>
						<option value="320"<cfif bitrate_mp3 EQ 320> selected="true"</cfif>>320</option>
					</select>
					 <a href="##" onclick="$('##mp3_more').slideToggle('slow');return false;">additional conversions</a>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<div id="mp3_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<cfset bitrate_mp3_2 = 192>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp3_2"><cfset bitrate_mp3_2 = upl_temp_value></cfif></cfloop>
							<tr>
								<td width="1%" nowrap="nowrap" align="center"><input type="checkbox" name="convert_to" value="aud-mp3_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp3_2"> checked="checked"</cfif></cfloop>></td>
								<td width="1%" nowrap="nowrap"><a href="##" onclick="clickcbk('formupltemp','convert_to',79);return false;" style="text-decoration:none;">MP3</a></td>
								<td width="100%" nowrap="nowrap">
									<select name="convert_bitrate_mp3_2" id="convert_bitrate_mp3_2">
										<option value="32"<cfif bitrate_mp3_2 EQ 32> selected="true"</cfif>>32</option>
										<option value="48"<cfif bitrate_mp3_2 EQ 48> selected="true"</cfif>>48</option>
										<option value="64"<cfif bitrate_mp3_2 EQ 64> selected="true"</cfif>>64</option>
										<option value="96"<cfif bitrate_mp3_2 EQ 96> selected="true"</cfif>>96</option>
										<option value="128"<cfif bitrate_mp3_2 EQ 128> selected="true"</cfif>>128</option>
										<option value="160"<cfif bitrate_mp3_2 EQ 160> selected="true"</cfif>>160</option>
										<option value="192"<cfif bitrate_mp3_2 EQ 192> selected="true"</cfif>>192</option>
										<option value="256"<cfif bitrate_mp3_2 EQ 256> selected="true"</cfif>>256</option>
										<option value="320"<cfif bitrate_mp3_2 EQ 320> selected="true"</cfif>>320</option>
									</select>
								</td>
							</tr>
							<cfset bitrate_mp3_3 = 192>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp3_3"><cfset bitrate_mp3_3 = upl_temp_value></cfif></cfloop>
							<tr>
								<td width="1%" nowrap="nowrap" align="center"><input type="checkbox" name="convert_to" value="aud-mp3_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp3_3"> checked="checked"</cfif></cfloop>></td>
								<td width="1%" nowrap="nowrap"><a href="##" onclick="clickcbk('formupltemp','convert_to',80);return false;" style="text-decoration:none;">MP3</a></td>
								<td width="100%" nowrap="nowrap">
									<select name="convert_bitrate_mp3_3" id="convert_bitrate_mp3_3">
										<option value="32"<cfif bitrate_mp3_3 EQ 32> selected="true"</cfif>>32</option>
										<option value="48"<cfif bitrate_mp3_3 EQ 48> selected="true"</cfif>>48</option>
										<option value="64"<cfif bitrate_mp3_3 EQ 64> selected="true"</cfif>>64</option>
										<option value="96"<cfif bitrate_mp3_3 EQ 96> selected="true"</cfif>>96</option>
										<option value="128"<cfif bitrate_mp3_3 EQ 128> selected="true"</cfif>>128</option>
										<option value="160"<cfif bitrate_mp3_3 EQ 160> selected="true"</cfif>>160</option>
										<option value="192"<cfif bitrate_mp3_3 EQ 192> selected="true"</cfif>>192</option>
										<option value="256"<cfif bitrate_mp3_3 EQ 256> selected="true"</cfif>>256</option>
										<option value="320"<cfif bitrate_mp3_3 EQ 320> selected="true"</cfif>>320</option>
									</select>
								</td>
							</tr>
							<cfset bitrate_mp3_4 = 192>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp3_4"><cfset bitrate_mp3_4 = upl_temp_value></cfif></cfloop>
							<tr>
								<td width="1%" nowrap="nowrap" align="center"><input type="checkbox" name="convert_to" value="aud-mp3_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp3_4"> checked="checked"</cfif></cfloop>></td>
								<td width="1%" nowrap="nowrap"><a href="##" onclick="clickcbk('formupltemp','convert_to',81);return false;" style="text-decoration:none;">MP3</a></td>
								<td width="100%" nowrap="nowrap">
									<select name="convert_bitrate_mp3_4" id="convert_bitrate_mp3_4">
										<option value="32"<cfif bitrate_mp3_4 EQ 32> selected="true"</cfif>>32</option>
										<option value="48"<cfif bitrate_mp3_4 EQ 48> selected="true"</cfif>>48</option>
										<option value="64"<cfif bitrate_mp3_4 EQ 64> selected="true"</cfif>>64</option>
										<option value="96"<cfif bitrate_mp3_4 EQ 96> selected="true"</cfif>>96</option>
										<option value="128"<cfif bitrate_mp3_4 EQ 128> selected="true"</cfif>>128</option>
										<option value="160"<cfif bitrate_mp3_4 EQ 160> selected="true"</cfif>>160</option>
										<option value="192"<cfif bitrate_mp3_4 EQ 192> selected="true"</cfif>>192</option>
										<option value="256"<cfif bitrate_mp3_4 EQ 256> selected="true"</cfif>>256</option>
										<option value="320"<cfif bitrate_mp3_4 EQ 320> selected="true"</cfif>>320</option>
									</select>
								</td>
							</tr>
							<cfset bitrate_mp3_5 = 192>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp3_5"><cfset bitrate_mp3_5 = upl_temp_value></cfif></cfloop>
							<tr>
								<td width="1%" nowrap="nowrap" align="center"><input type="checkbox" name="convert_to" value="aud-mp3_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp3_5"> checked="checked"</cfif></cfloop>></td>
								<td width="1%" nowrap="nowrap"><a href="##" onclick="clickcbk('formupltemp','convert_to',82);return false;" style="text-decoration:none;">MP3</a></td>
								<td width="100%" nowrap="nowrap">
									<select name="convert_bitrate_mp3_5" id="convert_bitrate_mp3_5">
										<option value="32"<cfif bitrate_mp3_5 EQ 32> selected="true"</cfif>>32</option>
										<option value="48"<cfif bitrate_mp3_5 EQ 48> selected="true"</cfif>>48</option>
										<option value="64"<cfif bitrate_mp3_5 EQ 64> selected="true"</cfif>>64</option>
										<option value="96"<cfif bitrate_mp3_5 EQ 96> selected="true"</cfif>>96</option>
										<option value="128"<cfif bitrate_mp3_5 EQ 128> selected="true"</cfif>>128</option>
										<option value="160"<cfif bitrate_mp3_5 EQ 160> selected="true"</cfif>>160</option>
										<option value="192"<cfif bitrate_mp3_5 EQ 192> selected="true"</cfif>>192</option>
										<option value="256"<cfif bitrate_mp3_5 EQ 256> selected="true"</cfif>>256</option>
										<option value="320"<cfif bitrate_mp3_5 EQ 320> selected="true"</cfif>>320</option>
									</select>
								</td>
							</tr>
							<cfset bitrate_mp3_6 = 192>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_mp3_6"><cfset bitrate_mp3_6 = upl_temp_value></cfif></cfloop>
							<tr>
								<td width="1%" nowrap="nowrap" align="center"><input type="checkbox" name="convert_to" value="aud-mp3_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "mp3_6"> checked="checked"</cfif></cfloop>></td>
								<td width="1%" nowrap="nowrap"><a href="##" onclick="clickcbk('formupltemp','convert_to',83);return false;" style="text-decoration:none;">MP3</a></td>
								<td width="100%" nowrap="nowrap">
									<select name="convert_bitrate_mp3_6" id="convert_bitrate_mp3_6">
										<option value="32"<cfif bitrate_mp3_6 EQ 32> selected="true"</cfif>>32</option>
										<option value="48"<cfif bitrate_mp3_6 EQ 48> selected="true"</cfif>>48</option>
										<option value="64"<cfif bitrate_mp3_6 EQ 64> selected="true"</cfif>>64</option>
										<option value="96"<cfif bitrate_mp3_6 EQ 96> selected="true"</cfif>>96</option>
										<option value="128"<cfif bitrate_mp3_6 EQ 128> selected="true"</cfif>>128</option>
										<option value="160"<cfif bitrate_mp3_6 EQ 160> selected="true"</cfif>>160</option>
										<option value="192"<cfif bitrate_mp3_6 EQ 192> selected="true"</cfif>>192</option>
										<option value="256"<cfif bitrate_mp3_6 EQ 256> selected="true"</cfif>>256</option>
										<option value="320"<cfif bitrate_mp3_6 EQ 320> selected="true"</cfif>>320</option>
									</select>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- WAV --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="aud-wav"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "wav"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',84);return false;" style="text-decoration:none;">WAV</a></td>
				<td></td>
			</tr>
			<!--- OGG --->
			<cfset bitrate_ogg = 60>
			<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogg"><cfset bitrate_ogg = upl_temp_value></cfif></cfloop>
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="aud-ogg"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogg"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',85);return false;" style="text-decoration:none;">OGG</a></td>
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
				</select> <a href="##" onclick="$('##ogg_more').slideToggle('slow');return false;">additional conversions</a></td>
			</tr>
			<tr>
				<td colspan="3">
					<div id="ogg_more" style="display:none;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
							<cfset bitrate_ogg_2 = 60>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogg_2"><cfset bitrate_ogg_2 = upl_temp_value></cfif></cfloop>
							<tr>
								<td align="center" nowrap="nowrap"><input type="checkbox" name="convert_to" value="aud-ogg_2"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogg_2"> checked="checked"</cfif></cfloop>></td>
								<td nowrap="nowrap"><a href="##" onclick="clickcbk('formupltemp','convert_to',86);return false;" style="text-decoration:none;">OGG</a></td>
								<td width="100%"><select name="convert_bitrate_ogg_2" id="convert_bitrate_ogg_2">
								<option value="10"<cfif bitrate_ogg_2 EQ 10> selected="true"</cfif>>82</option>
								<option value="20"<cfif bitrate_ogg_2 EQ 20> selected="true"</cfif>>102</option>
								<option value="30"<cfif bitrate_ogg_2 EQ 30> selected="true"</cfif>>115</option>
								<option value="40"<cfif bitrate_ogg_2 EQ 40> selected="true"</cfif>>137</option>
								<option value="50"<cfif bitrate_ogg_2 EQ 50> selected="true"</cfif>>147</option>
								<option value="60"<cfif bitrate_ogg_2 EQ 60> selected="true"</cfif>>176</option>
								<option value="70"<cfif bitrate_ogg_2 EQ 70> selected="true"</cfif>>192</option>
								<option value="80"<cfif bitrate_ogg_2 EQ 80> selected="true"</cfif>>224</option>
								<option value="90"<cfif bitrate_ogg_2 EQ 90> selected="true"</cfif>>290</option>
								<option value="100"<cfif bitrate_ogg_2 EQ 100> selected="true"</cfif>>434</option>
								</select></td>
							</tr>
							<cfset bitrate_ogg_3 = 60>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogg_3"><cfset bitrate_ogg_3 = upl_temp_value></cfif></cfloop>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="aud-ogg_3"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogg_3"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',87);return false;" style="text-decoration:none;">OGG</a></td>
								<td><select name="convert_bitrate_ogg_3" id="convert_bitrate_ogg_3">
								<option value="10"<cfif bitrate_ogg_3 EQ 10> selected="true"</cfif>>82</option>
								<option value="20"<cfif bitrate_ogg_3 EQ 20> selected="true"</cfif>>102</option>
								<option value="30"<cfif bitrate_ogg_3 EQ 30> selected="true"</cfif>>115</option>
								<option value="40"<cfif bitrate_ogg_3 EQ 40> selected="true"</cfif>>137</option>
								<option value="50"<cfif bitrate_ogg_3 EQ 50> selected="true"</cfif>>147</option>
								<option value="60"<cfif bitrate_ogg_3 EQ 60> selected="true"</cfif>>176</option>
								<option value="70"<cfif bitrate_ogg_3 EQ 70> selected="true"</cfif>>192</option>
								<option value="80"<cfif bitrate_ogg_3 EQ 80> selected="true"</cfif>>224</option>
								<option value="90"<cfif bitrate_ogg_3 EQ 90> selected="true"</cfif>>290</option>
								<option value="100"<cfif bitrate_ogg_3 EQ 100> selected="true"</cfif>>434</option>
								</select></td>
							</tr>
							<cfset bitrate_ogg_4 = 60>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogg_4"><cfset bitrate_ogg_4 = upl_temp_value></cfif></cfloop>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="aud-ogg_4"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogg_4"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',88);return false;" style="text-decoration:none;">OGG</a></td>
								<td><select name="convert_bitrate_ogg_4" id="convert_bitrate_ogg_4">
								<option value="10"<cfif bitrate_ogg_4 EQ 10> selected="true"</cfif>>82</option>
								<option value="20"<cfif bitrate_ogg_4 EQ 20> selected="true"</cfif>>102</option>
								<option value="30"<cfif bitrate_ogg_4 EQ 30> selected="true"</cfif>>115</option>
								<option value="40"<cfif bitrate_ogg_4 EQ 40> selected="true"</cfif>>137</option>
								<option value="50"<cfif bitrate_ogg_4 EQ 50> selected="true"</cfif>>147</option>
								<option value="60"<cfif bitrate_ogg_4 EQ 60> selected="true"</cfif>>176</option>
								<option value="70"<cfif bitrate_ogg_4 EQ 70> selected="true"</cfif>>192</option>
								<option value="80"<cfif bitrate_ogg_4 EQ 80> selected="true"</cfif>>224</option>
								<option value="90"<cfif bitrate_ogg_4 EQ 90> selected="true"</cfif>>290</option>
								<option value="100"<cfif bitrate_ogg_4 EQ 100> selected="true"</cfif>>434</option>
								</select></td>
							</tr>
							<cfset bitrate_ogg_5 = 60>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogg_5"><cfset bitrate_ogg_5 = upl_temp_value></cfif></cfloop>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="aud-ogg_5"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogg_5"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',89);return false;" style="text-decoration:none;">OGG</a></td>
								<td><select name="convert_bitrate_ogg_5" id="convert_bitrate_ogg_5">
								<option value="10"<cfif bitrate_ogg_5 EQ 10> selected="true"</cfif>>82</option>
								<option value="20"<cfif bitrate_ogg_5 EQ 20> selected="true"</cfif>>102</option>
								<option value="30"<cfif bitrate_ogg_5 EQ 30> selected="true"</cfif>>115</option>
								<option value="40"<cfif bitrate_ogg_5 EQ 40> selected="true"</cfif>>137</option>
								<option value="50"<cfif bitrate_ogg_5 EQ 50> selected="true"</cfif>>147</option>
								<option value="60"<cfif bitrate_ogg_5 EQ 60> selected="true"</cfif>>176</option>
								<option value="70"<cfif bitrate_ogg_5 EQ 70> selected="true"</cfif>>192</option>
								<option value="80"<cfif bitrate_ogg_5 EQ 80> selected="true"</cfif>>224</option>
								<option value="90"<cfif bitrate_ogg_5 EQ 90> selected="true"</cfif>>290</option>
								<option value="100"<cfif bitrate_ogg_5 EQ 100> selected="true"</cfif>>434</option>
								</select></td>
							</tr>
							<cfset bitrate_ogg_6 = 60>
							<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_bitrate_ogg_6"><cfset bitrate_ogg_6 = upl_temp_value></cfif></cfloop>
							<tr>
								<td align="center"><input type="checkbox" name="convert_to" value="aud-ogg_6"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "ogg_6"> checked="checked"</cfif></cfloop>></td>
								<td><a href="##" onclick="clickcbk('formupltemp','convert_to',90);return false;" style="text-decoration:none;">OGG</a></td>
								<td><select name="convert_bitrate_ogg_6" id="convert_bitrate_ogg_6">
								<option value="10"<cfif bitrate_ogg_6 EQ 10> selected="true"</cfif>>82</option>
								<option value="20"<cfif bitrate_ogg_6 EQ 20> selected="true"</cfif>>102</option>
								<option value="30"<cfif bitrate_ogg_6 EQ 30> selected="true"</cfif>>115</option>
								<option value="40"<cfif bitrate_ogg_6 EQ 40> selected="true"</cfif>>137</option>
								<option value="50"<cfif bitrate_ogg_6 EQ 50> selected="true"</cfif>>147</option>
								<option value="60"<cfif bitrate_ogg_6 EQ 60> selected="true"</cfif>>176</option>
								<option value="70"<cfif bitrate_ogg_6 EQ 70> selected="true"</cfif>>192</option>
								<option value="80"<cfif bitrate_ogg_6 EQ 80> selected="true"</cfif>>224</option>
								<option value="90"<cfif bitrate_ogg_6 EQ 90> selected="true"</cfif>>290</option>
								<option value="100"<cfif bitrate_ogg_6 EQ 100> selected="true"</cfif>>434</option>
								</select></td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<!--- FLAC --->
			<tr>
				<td align="center"><input type="checkbox" name="convert_to" value="aud-flac"<cfloop query="qry_detail.uplval"><cfif upl_temp_field EQ "convert_to" AND upl_temp_value EQ "flac"> checked="checked"</cfif></cfloop>></td>
				<td><a href="##" onclick="clickcbk('formupltemp','convert_to',91);return false;" style="text-decoration:none;">FLAC</a></td>
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