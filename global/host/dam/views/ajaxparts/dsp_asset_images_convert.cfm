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
			<td width="1%" nowrap="true"><input type="text" size="4" name="convert_width_jpg" value="#qry_detail.detail.orgwidth#" onchange="aspectheight(this,'convert_height_jpg','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="4" name="convert_height_jpg" value="#qry_detail.detail.orgheight#" onchange="aspectwidth(this,'convert_width_jpg','form#attributes.file_id#',#theaspectratio#);"></td>
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
				ColorSpace: #qry_xmp.colorspace#
				<br />
				X Resolution: #qry_xmp.xres#
				<br />
				Y Resolution: #qry_xmp.yres#
				<br />
				Resolution Unit: #qry_xmp.resunit#
			</td>
		</tr>
		<tr class="list">
			<td><input type="checkbox" name="convert_to" value="gif"></td>
			<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1)" style="text-decoration:none;">GIF (Graphic Interchange Format)</a></td>
			<td><input type="text" size="4" name="convert_width_gif" value="#qry_detail.detail.orgwidth#" onchange="aspectheight(this,'convert_height_gif','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="4" name="convert_height_gif" value="#qry_detail.detail.orgheight#" onchange="aspectwidth(this,'convert_width_gif','form#attributes.file_id#',#theaspectratio#);"></td>
		</tr>
		<tr class="list">
			<td><input type="checkbox" name="convert_to" value="png"></td>
			<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',2)" style="text-decoration:none;">PNG (Portable (Public) Network Graphic)</a></td>
			<td><input type="text" size="4" name="convert_width_png" value="#qry_detail.detail.orgwidth#" onchange="aspectheight(this,'convert_height_png','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="4" name="convert_height_png" value="#qry_detail.detail.orgheight#" onchange="aspectwidth(this,'convert_width_png','form#attributes.file_id#',#theaspectratio#);"></td>
		</tr>
		<tr class="list">
			<td><input type="checkbox" name="convert_to" value="tif"></td>
			<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',3)" style="text-decoration:none;">TIFF (Tagged Image Format File)</a></td>
			<td><input type="text" size="4" name="convert_width_tif" value="#qry_detail.detail.orgwidth#" onchange="aspectheight(this,'convert_height_tif','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="4" name="convert_height_tif" value="#qry_detail.detail.orgheight#" onchange="aspectwidth(this,'convert_width_tif','form#attributes.file_id#',#theaspectratio#);"></td>
		</tr>
		<tr class="list">
			<td><input type="checkbox" name="convert_to" value="bmp"></td>
			<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',4)" style="text-decoration:none;">BMP (Windows OS/2 Bitmap Graphics)</a></td>
			<td><input type="text" size="4" name="convert_width_bmp" value="#qry_detail.detail.orgwidth#" onchange="aspectheight(this,'convert_height_bmp','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" size="4" name="convert_height_bmp" value="#qry_detail.detail.orgheight#" onchange="aspectwidth(this,'convert_width_bmp','form#attributes.file_id#',#theaspectratio#);"></td>
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
</cfoutput>
