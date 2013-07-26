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
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#"<cfif attributes.folderaccess NEQ "R"> onsubmit="filesubmit();return false;"</cfif>>
	<input type="hidden" name="#theaction#" value="#xfa.save#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<input type="hidden" name="folder_id" value="#qry_detail.detail.folder_id_r#">
	<input type="hidden" name="file_id" value="#attributes.file_id#">
	<input type="hidden" name="vid_group_id" id="vid_group_id" value="#attributes.vid_group_id#">
	<input type="hidden" name="theorgname" value="#qry_detail.detail.vid_filename#">
	<input type="hidden" name="theorgext" value="#qry_detail.detail.vid_extension#">
	<input type="hidden" name="thepath" value="#thisPath#">
	<input type="hidden" name="theos" value="#server.os.name#">
	<input type="hidden" name="filenameorg" value="#qry_detail.detail.vid_name_org#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<input type="hidden" name="convert_width_3gp" value="">
	<input type="hidden" name="convert_height_3gp" value="">
	<input type="hidden" name="convert_bitrate_3gp" value="">
	<input type="hidden" name="link_kind" value="#qry_detail.detail.link_kind#">
	<cfset fi = find("iframe",qry_detail.detail.link_path_url)>
	<cfset fp = find("param",qry_detail.detail.link_path_url)>
	<cfset fo = find("object",qry_detail.detail.link_path_url)>
	<cfset foundit = fi + fp + fo>
	<cfif foundit EQ 0>
		<input type="hidden" name="link_path_url" value="#qry_detail.detail.link_path_url#">
	</cfif>
	<div class="collapsable"><div class="headers">Create new renditions</div></div>
		<br />
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<cfset theaspectratio = #qry_detail.detail.vwidth# / #qry_detail.detail.vheight#>
			<!--- For the preset include below --->
			<cfset incval = structnew()>
			<cfset incval.theform = "form#attributes.file_id#">
			<!--- OGV --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="ogv"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',0);return false;" style="text-decoration:none;">OGG (OGV)*</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "ogv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td nowrap="nowrap"><input type="text" style="width:35px" name="convert_width_ogv" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_ogv','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_ogv" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_ogv','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td rowspan="11" width="100%" nowrap="true" valign="top" style="padding-left:20px;">
					<strong>#myFusebox.getApplicationData().defaults.trans("video_original")#</strong>
					<br />
					#myFusebox.getApplicationData().defaults.trans("file_name")#: #qry_detail.detail.vid_filename#
					<br />
					#myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.vid_extension)#
					<br />
					#myFusebox.getApplicationData().defaults.trans("size")#: #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel
					<br />
					#myFusebox.getApplicationData().defaults.trans("data_size")#: #qry_detail.thesize# MB
				</td> --->
			</tr>
			<!--- WebM --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="webm"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1);return false;" style="text-decoration:none;">WebM (WebM)*</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "webm">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_webm" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_webm','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_webm" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_webm','form#attributes.file_id#',#theaspectratio#);"></td>
			</tr>
			<!--- Flash --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="flv"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',2);return false;" style="text-decoration:none;">Flash (FLV)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "flv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_flv" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_flv','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_flv" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_flv','form#attributes.file_id#',#theaspectratio#);"></td>
			</tr>
			<!--- MP4 --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="mp4"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',3);return false;" style="text-decoration:none;">Mpeg4 (MP4)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "mp4">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_mp4" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mp4','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_mp4" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mp4','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mp4" value="600">kb/s</td> --->
			</tr>
			<tr class="list">
				<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="wmv"></td>
				<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',4);return false;" style="text-decoration:none;">Windows Media Video (WMV)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "wmv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td width="1%" nowrap="true"><input type="text" style="width:35px" name="convert_width_wmv" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_wmv','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_wmv" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_wmv','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td width="100%" nowrap="true"><input type="text" size="4" name="convert_bitrate_wmv" value="600">kb/s</td> --->
			</tr>
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="avi"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',5);return false;" style="text-decoration:none;">Audio Video Interlaced (AVI)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "avi">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_avi" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_avi','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_avi" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_avi','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_avi" value="600">kb/s</td> --->
			</tr>
			<!--- MOV --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="mov"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',6);return false;" style="text-decoration:none;">Quicktime (MOV)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "mov">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_mov" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mov','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_mov" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mov','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mov" value="600">kb/s</td> --->
			</tr>
			<!--- MXF --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="mxf"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',6);return false;" style="text-decoration:none;">MXF (MXF)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "mxf">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_mxf" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mxf','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_mxf" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mxf','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mov" value="600">kb/s</td> --->
			</tr>
			<!--- MPG --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="mpg"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',7)" style="text-decoration:none;">Mpeg1 Mpeg2 (MPG)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "mpg">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_mpg" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mpg','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_mpg" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mpg','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mpg" value="600">kb/s</td> --->
			</tr>
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="3gp" onclick="clickset3gp('form#attributes.file_id#');"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',8);clickset3gp('form#attributes.file_id#');return false;" style="text-decoration:none;">3GP (3GP)</a></td>
				<td nowrap="true">
				<select name="convert_wh_3gp" onChange="javascript:set3gp('form#attributes.file_id#');">
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
				<td nowrap="true"></td>
			</tr>
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="rm"></td>
				<td nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',9);return false;" style="text-decoration:none;">RealNetwork Video Data (RM)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "rm">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td>
					<input type="text" style="width:35px" name="convert_width_rm" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_rm','form#attributes.file_id#',#theaspectratio#);"> x <input type="text" style="width:35px" name="convert_height_rm" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_rm','form#attributes.file_id#',#theaspectratio#);"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_rm" value="600">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="5"><input type="button" name="convertbutton" value="#myFusebox.getApplicationData().defaults.trans("convert_button")#" class="button" onclick="convertexistvidrenditions('form#attributes.file_id#');"> <div id="statusconvertreditions" style="padding:10px;color:green;background-color:##FFFFE0;visibility:hidden;"></div><div id="statusrenditionconvertdummy"></div></td>
			</tr>
		</table>
	</form>
</cfoutput>