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
	<cfinclude template="inc_images_links.cfm">
	<br />
	<cfif attributes.folderaccess NEQ "R">
		<div class="collapsable"><div class="headers">&gt; Create new renditions</div></div>
		<br />
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<cftry>
				<cfset theaspectratio = #qry_detail.detail.orgwidth# / #qry_detail.detail.orgheight#>
				<cfcatch type="any">
					<cfset theaspectratio = 0>
				</cfcatch>
			</cftry>
			<tr class="list">
				<td width="1%" nowrap="true"><input type="checkbox" name="convert_to" value="jpg"></td>
				<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',0)" style="text-decoration:none;">JPEG (Joint Photographic Experts Group)</a></td>
				<td width="1%" nowrap="true"><input type="text" size="4" name="convert_width_jpg" id="convert_width_jpg" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" onchange="aspectheight(this,'convert_height_jpg','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" size="4" name="convert_height_jpg" id="convert_height_jpg" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" onchange="aspectwidth(this,'convert_width_jpg','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> or <input type="text" size="4" name="convert_dpi_jpg" id="convert_dpi_jpg" maxlength="3"> dpi</td>
				<!--- Watermark --->
				<cfif attributes.wmtemplates.recordcount NEQ 0>
					<td width="1%" nowrap="true">
						<select name="convert_wm_jpg" id="convert_wm_jpg">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<option value="#wm_temp_id#">#wm_name#</option>
							</cfloop>
						</select>
					</td>
				</cfif>
				<td rowspan="6" width="100%" nowrap="true" valign="top" style="padding-left:20px;">
					<strong>#myFusebox.getApplicationData().defaults.trans("images_original")#</strong>
					<br />
					#myFusebox.getApplicationData().defaults.trans("file_name")#: #qry_detail.detail.img_filename#
					<br />
					#myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.img_extension)#
					<br />
					#myFusebox.getApplicationData().defaults.trans("size")#: #qry_detail.detail.orgwidth#x#qry_detail.detail.orgheight# pixel
					<br />
					#myFusebox.getApplicationData().defaults.trans("data_size")#: #qry_detail.thesize# MB
					<br />
					ColorSpace: <cfif qry_xmp.colorspace EQ "">could not be read properly for this file<cfelse>#qry_xmp.colorspace#</cfif>
					<br />
					<cfif qry_xmp.resunit EQ "inches">
						X Resolution: #qry_xmp.xres# dpi
						<br />
						Y Resolution: #qry_xmp.yres# dpi
						<br />
						Resolution Unit: #qry_xmp.resunit#
					</cfif>
				</td>
			</tr>
			<tr class="list">
				<td><input type="checkbox" name="convert_to" value="gif"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1)" style="text-decoration:none;">GIF (Graphic Interchange Format)</a></td>
				<td><input type="text" size="4" name="convert_width_gif" id="convert_width_gif" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" onchange="aspectheight(this,'convert_height_gif','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" size="4" name="convert_height_gif" id="convert_height_gif" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" onchange="aspectwidth(this,'convert_width_gif','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> or <input type="text" size="4" name="convert_dpi_gif" id="convert_dpi_gif" maxlength="3"> dpi</td>
				<!--- Watermark --->
				<cfif attributes.wmtemplates.recordcount NEQ 0>
					<td width="1%" nowrap="true">
						<select name="convert_wm_gif" id="convert_wm_gif">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<option value="#wm_temp_id#">#wm_name#</option>
							</cfloop>
						</select>
					</td>
				</cfif>
			</tr>
			<tr class="list">
				<td><input type="checkbox" name="convert_to" value="png"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',2)" style="text-decoration:none;">PNG (Portable (Public) Network Graphic)</a></td>
				<td><input type="text" size="4" name="convert_width_png" id="convert_width_png" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" onchange="aspectheight(this,'convert_height_png','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" size="4" name="convert_height_png" id="convert_height_png" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" onchange="aspectwidth(this,'convert_width_png','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> or <input type="text" size="4" name="convert_dpi_png" id="convert_dpi_png" maxlength="3"> dpi</td>
				<!--- Watermark --->
				<cfif attributes.wmtemplates.recordcount NEQ 0>
					<td width="1%" nowrap="true">
						<select name="convert_wm_png" id="convert_wm_png">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<option value="#wm_temp_id#">#wm_name#</option>
							</cfloop>
						</select>
					</td>
				</cfif>
			</tr>
			<tr class="list">
				<td><input type="checkbox" name="convert_to" value="tif"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',3)" style="text-decoration:none;">TIFF (Tagged Image Format File)</a></td>
				<td><input type="text" size="4" name="convert_width_tif" id="convert_width_tif" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" onchange="aspectheight(this,'convert_height_tif','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" size="4" name="convert_height_tif" id="convert_height_tif" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" onchange="aspectwidth(this,'convert_width_tif','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> or <input type="text" size="4" name="convert_dpi_tif" id="convert_dpi_tif" maxlength="3"> dpi</td>
				<!--- Watermark --->
				<cfif attributes.wmtemplates.recordcount NEQ 0>
					<td width="1%" nowrap="true">
						<select name="convert_wm_tif" id="convert_wm_tif">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<option value="#wm_temp_id#">#wm_name#</option>
							</cfloop>
						</select>
					</td>
				</cfif>
			</tr>
			<tr class="list">
				<td><input type="checkbox" name="convert_to" value="bmp"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',4)" style="text-decoration:none;">BMP (Windows OS/2 Bitmap Graphics)</a></td>
				<td><input type="text" size="4" name="convert_width_bmp" id="convert_width_bmp" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" onchange="aspectheight(this,'convert_height_bmp','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" size="4" name="convert_height_bmp" id="convert_height_bmp" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" onchange="aspectwidth(this,'convert_width_bmp','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> or <input type="text" size="4" name="convert_dpi_bmp" id="convert_dpi_bmp" maxlength="3"> dpi</td>
				<!--- Watermark --->
				<cfif attributes.wmtemplates.recordcount NEQ 0>
					<td width="1%" nowrap="true">
						<select name="convert_wm_bmp" id="convert_wm_bmp">
							<option value="" selected="selected">Apply watermark</option>
							<option value="">---</option>
							<cfloop query="attributes.wmtemplates">
								<option value="#wm_temp_id#">#wm_name#</option>
							</cfloop>
						</select>
					</td>
				</cfif>
			</tr>
			<tr>
				<td colspan="4"><input type="button" name="convertbutton" value="#myFusebox.getApplicationData().defaults.trans("convert_button")#" class="button" onclick="convertimages('form#attributes.file_id#');"> <div id="statusconvert" style="padding:10px;color:green;background-color:##FFFFE0;visibility:hidden;"></div><div id="statusconvertdummy"></div></td>
			</tr>
		</table>
		<!--- Additional Renditions --->
		<cfif cs.tab_additional_renditions>
			<div class="collapsable">
				<a href="##" onclick="$('##moreversions').slideToggle('slow');return false;"><div class="headers">&gt; #myFusebox.getApplicationData().defaults.trans("adiver_header")#</div></a>
				<div id="moreversions" style="display:none;padding-top:10px;"></div>
			</div>
		</cfif>
	</cfif>
</cfoutput>
