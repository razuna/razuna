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
	<!--- Flag to specify whether to run javascript calculations on page or not --->
	<cfset docalcs = true>
	<cftry>
		<cfset theaspectratio = #qry_detail.detail.orgwidth# / #qry_detail.detail.orgheight#>
		<cfcatch type="any">
			<cfset theaspectratio = 0>
		</cfcatch>
	</cftry>
	<cfif qry_detail.detail.orgheight EQ 0 OR theaspectratio EQ 0 OR qry_xmp.xres EQ 0 OR qry_xmp.resunit NEQ "inches">
		<!--- Turn off javascript calculations on page because there is not enough data to support them --->
		<cfset docalcs = false>
	</cfif>
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#"<cfif attributes.folderaccess NEQ "R"> onsubmit="filesubmit();return false;"</cfif>>
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#qry_detail.detail.folder_id_r#">
	<input type="hidden" name="file_id" id="file_id" value="#attributes.file_id#">
	<input type="hidden" name="img_group_id" id="img_group_id" value="#attributes.img_group_id#">
	<input type="hidden" name="theorgname" id="theorgname" value="#qry_detail.detail.img_filename#">
	<input type="hidden" name="thepath" id="thepath" value="#thisPath#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.img_filename_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="extension" value="#qry_detail.detail.img_extension#">
	<input type="hidden" name="thumbextension" value="#qry_detail.detail.thumb_extension#">
	<input type="hidden" name="link_kind" id="link_kind" value="#qry_detail.detail.link_kind#">
	<input type="hidden" name="link_path_url" id="link_path_url" value="#qry_detail.detail.link_path_url#">
	<input type="hidden" name="xres" id="xres" value="#qry_xmp.xres#">
	<input type="hidden" name="yres" id="yres" value="#qry_xmp.yres#">
	<input type="hidden" name="resunit" id="resunit" value="#qry_xmp.resunit#">
	<div class="collapsable"><div class="headers">Create New Renditions For Existing Rendition</div></div>
			<br />
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid" id="newren">
				<tr class="list">
					<td width="1%" nowrap="true"><input type="checkbox" name="convert_to" value="jpg"></td>
					<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',0)" style="text-decoration:none;">JPEG (Joint Photographic Experts Group)</a></td>
					<td width="1%" nowrap="true"><input type="text" size="4" name="convert_width_jpg" id="convert_width_jpg" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" <cfif docalcs>onchange="aspectheight(this,'convert_height_jpg','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> 
				<input type="text" size="4" name="inch_width_jpg" id="inch_width_jpg" <cfif docalcs>onchange="aspectheightin(this,'inch_height_jpg','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_jpg,inch_width_jpg,'convert_height_jpg','convert_width_jpg',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> x <input type="text" size="4" name="convert_height_jpg" id="convert_height_jpg" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" <cfif docalcs>onchange="aspectwidth(this,'convert_width_jpg','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_height_jpg" id="inch_height_jpg" <cfif docalcs>onchange="aspectwidthin(this,'inch_width_jpg','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_jpg,inch_width_jpg,'convert_height_jpg','convert_width_jpg',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;">
				<select name="formatbox_jpg" id="formatbox_jpg" <cfif docalcs>onchange="changeFormat('form#attributes.file_id#',convert_height_jpg,convert_width_jpg,'convert_height_jpg','convert_width_jpg',#qry_xmp.xres#,#qry_xmp.yres#,'inch_height_jpg','inch_width_jpg','formatbox_jpg')"</cfif>>
					<option value="pixels">Pixels</option>
					<cfif docalcs><option value="inches">Inches</option></cfif>
				</select>
				or <input type="text" size="4" name="convert_dpi_jpg" id="convert_dpi_jpg" maxlength="3"> dpi harkirat
				</td>
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
					<!--- <td rowspan="6" width="100%" nowrap="true" valign="top" style="padding-left:20px;">
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
					</td> --->
				</tr>
				<tr class="list">
					<td><input type="checkbox" name="convert_to" value="gif"></td>
					<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1)" style="text-decoration:none;">GIF (Graphic Interchange Format)</a></td>
					<td><input type="text" size="4" name="convert_width_gif" id="convert_width_gif" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" <cfif docalcs>onchange="aspectheight(this,'convert_height_gif','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_width_gif" id="inch_width_gif" <cfif docalcs>onchange="aspectheightin(this,'inch_height_gif','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_gif,inch_width_gif,'convert_height_gif','convert_width_gif',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> x <input type="text" size="4" name="convert_height_gif" id="convert_height_gif" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" <cfif docalcs>onchange="aspectwidth(this,'convert_width_gif','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_height_gif" id="inch_height_gif" <cfif docalcs>onchange="aspectwidthin(this,'inch_width_gif','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_gif,inch_width_gif,'convert_height_gif','convert_width_gif',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> 

				<select name="formatbox_gif" id="formatbox_gif" <cfif docalcs>onchange="changeFormat('form#attributes.file_id#',convert_height_gif,convert_width_gif,'convert_height_gif','convert_width_gif',#qry_xmp.xres#,#qry_xmp.yres#,'inch_height_gif','inch_width_gif','formatbox_gif')"</cfif>>
					<option value="pixels">Pixels</option>
					<cfif docalcs><option value="inches">Inches</option></cfif>
				</select>

				or <input type="text" size="4" name="convert_dpi_gif" id="convert_dpi_gif" maxlength="3"> dpi</td>
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
					<td><input type="text" size="4" name="convert_width_png" id="convert_width_png" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" <cfif docalcs>onchange="aspectheight(this,'convert_height_png','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_width_png" id="inch_width_png" <cfif docalcs>onchange="aspectheightin(this,'inch_height_png','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_png,inch_width_png,'convert_height_png','convert_width_png',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> x <input type="text" size="4" name="convert_height_png" id="convert_height_png" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" <cfif docalcs>onchange="aspectwidth(this,'convert_width_png','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_height_png" id="inch_height_png" <cfif docalcs>onchange="aspectwidthin(this,'inch_width_png','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_png,inch_width_png,'convert_height_png','convert_width_png',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> 

				<select name="formatbox_png" id="formatbox_png" <cfif docalcs>onchange="changeFormat('form#attributes.file_id#',convert_height_png,convert_width_png,'convert_height_png','convert_width_png',#qry_xmp.xres#,#qry_xmp.yres#,'inch_height_png','inch_width_png','formatbox_png')"</cfif>>
					<option value="pixels">Pixels</option>
					<cfif docalcs><option value="inches">Inches</option></cfif>
				</select>

				or <input type="text" size="4" name="convert_dpi_png" id="convert_dpi_png" maxlength="3"> dpi</td>
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
					<td><input type="text" size="4" name="convert_width_tif" id="convert_width_tif" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" <cfif docalcs>onchange="aspectheight(this,'convert_height_tif','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_width_tif" id="inch_width_tif" <cfif docalcs>onchange="aspectheightin(this,'inch_height_tif','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_tif,inch_width_tif,'convert_height_tif','convert_width_tif',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> x <input type="text" size="4" name="convert_height_tif" id="convert_height_tif" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" <cfif docalcs>onchange="aspectwidth(this,'convert_width_tif','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_height_tif" id="inch_height_tif" <cfif docalcs>onchange="aspectwidthin(this,'inch_width_tif','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_tif,inch_width_tif,'convert_height_tif','convert_width_tif',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> 

				<select name="formatbox_tif" id="formatbox_tif" <cfif docalcs>onchange="changeFormat('form#attributes.file_id#',convert_height_tif,convert_width_tif,'convert_height_tif','convert_width_tif',#qry_xmp.xres#,#qry_xmp.yres#,'inch_height_tif','inch_width_tif','formatbox_tif')"</cfif>>
					<option value="pixels">Pixels</option>
					<cfif docalcs><option value="inches">Inches</option></cfif>
				</select>

				or <input type="text" size="4" name="convert_dpi_tif" id="convert_dpi_tif" maxlength="3"> dpi</td>
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
					<td><input type="text" size="4" name="convert_width_bmp" id="convert_width_bmp" value="<cfif qry_detail.detail.orgwidth EQ 0>500<cfelse>#qry_detail.detail.orgwidth#</cfif>" <cfif docalcs>onchange="aspectheight(this,'convert_height_bmp','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_width_bmp" id="inch_width_bmp" <cfif docalcs>onchange="aspectheightin(this,'inch_height_bmp','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_bmp,inch_width_bmp,'convert_height_bmp','convert_width_bmp',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> x <input type="text" size="4" name="convert_height_bmp" id="convert_height_bmp" value="<cfif qry_detail.detail.orgheight EQ 0>500<cfelse>#qry_detail.detail.orgheight#</cfif>" <cfif docalcs>onchange="aspectwidth(this,'convert_width_bmp','form#attributes.file_id#',#theaspectratio#);" </cfif>maxlength="4"> <input type="text" size="4" name="inch_height_bmp" id="inch_height_bmp" <cfif docalcs>onchange="aspectwidthin(this,'inch_width_bmp','form#attributes.file_id#',#theaspectratio#);updatePixels('form#attributes.file_id#',inch_height_bmp,inch_width_bmp,'convert_height_bmp','convert_width_bmp',#qry_xmp.yres#,#qry_xmp.xres#);" </cfif>maxlength="4" style="display: none;"> 

				<select name="formatbox_bmp" id="formatbox_bmp" <cfif docalcs>onchange="changeFormat('form#attributes.file_id#',convert_height_bmp,convert_width_bmp,'convert_height_bmp','convert_width_bmp',#qry_xmp.xres#,#qry_xmp.yres#,'inch_height_bmp','inch_width_bmp','formatbox_bmp')"</cfif>>
					<option value="pixels">Pixels</option>
					<cfif docalcs><option value="inches">Inches</option></cfif>
				</select>

				or <input type="text" size="4" name="convert_dpi_bmp" id="convert_dpi_bmp" maxlength="3"> dpi</td>
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
					<td colspan="4"><input type="button" name="convertbutton" value="#myFusebox.getApplicationData().defaults.trans("convert_button")#" class="button" onclick="convertexistimgrenditions('form#attributes.file_id#');"> <div id="statusconvertreditions" style="padding:10px;color:green;background-color:##FFFFE0;visibility:hidden;"></div><div id="statusrenditionconvertdummy"></div></td>
				</tr>
			</table>
			</form>
</cfoutput>