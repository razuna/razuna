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
	<!--- Format size --->
	<cfif isnumeric(qry_detail.thesize)><cfset qry_detail.thesize = numberformat(qry_detail.thesize,'_.__')></cfif>
	<cfquery name="org_share_setting" dbtype="query">
		SELECT * FROM qry_share_options WHERE asset_format= 'org'
	</cfquery>
	<div class="collapsable"><div class="headers">&gt; Existing Renditions - <a href="##" onclick="loadrenvid();return false;">Refresh</a></div></div>
	<br />
	<table border="0" width="100%" cellpadding="0" cellspacing="0" class="grid">
		<cfif attributes.folderaccess NEQ "R" OR (org_share_setting.recordcount EQ 1 AND org_share_setting.asset_dl EQ 1)>
			<cfif qry_detail.detail.link_kind NEQ "url">
				<tr>
					<td width="65" align="center">
						<cfif qry_detail.detail.link_kind NEQ "lan">
							<cfif qry_detail.detail.link_kind EQ "url">
								<cfif qry_detail.detail.link_path_url contains "http">
									<a href="#qry_detail.detail.link_path_url#" target="_blank">#qry_detail.detail.link_path_url#</a>
								<cfelse>
									#qry_detail.detail.link_path_url#
								</cfif>
							<cfelse>
								<a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#attributes.file_id#&v=o" target="_blank"><img src="<cfif application.razuna.storage EQ "local">#cgi.context_path#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_image#?#qry_detail.detail.hashtag#<cfelse>#qry_detail.detail.cloud_url#</cfif>" style="max-height:50px;max-width:100px;"></a>
							</cfif>
						<cfelse>
							<cfif qry_detail.detail.shared EQ "F"><a href="#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#?#theaction#=c.sv&f=#attributes.file_id#&v=o" target="_blank"><cfelse><a href="#application.razuna.nvxurlservices#/razuna/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_org#" target="_blank"></cfif>
								<img src="#cgi.context_path#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_image#?#qry_detail.detail.hashtag#" border="0" style="max-height:50px;max-width:100px;">
							</a>
							<br />
						</cfif>
					</td>
					<td nowrap="true">
						<cfif qry_detail.detail.link_kind EQ "lan">
							<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> (#ucase(qry_detail.detail.vid_extension)#, #qry_detail.thesize# MB, #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel)<br />
							<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
							<br />
						<cfelse>
							<strong>#myFusebox.getApplicationData().defaults.trans("original")#</strong> (#ucase(qry_detail.detail.vid_extension)#, #qry_detail.thesize# MB, #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel)
							<br />
							<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank" style="color:white;text-decoration:none;"><button type="button" class="awesome small green">#myFusebox.getApplicationData().defaults.trans("download")#</button></a>
							<a href="##" onclick="toggleslide('divo#attributes.file_id#','inputo#attributes.file_id#');return false;" style="padding-left:20px;">Direct Link</a>
							| <a href="##" onclick="toggleslide('dive#attributes.file_id#','inpute#attributes.file_id#');return false;">Embed</a>
							<!--- Direct link --->
							<div id="divo#attributes.file_id#" style="display:none;">
								<input type="text" id="inputo#attributes.file_id#" style="width:100%;" value="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.sv&f=#attributes.file_id#&v=o" />
								<br />
								<cfif application.razuna.storage EQ "local">
									<input type="text" id="inputo#attributes.file_id#d" style="width:100%;" value="#session.thehttp##cgi.http_host##dynpath#/assets/#session.hostid#/#qry_detail.detail.path_to_asset#/#qry_detail.detail.vid_name_org#" />
								<cfelse>
									<input type="text" id="inputo#attributes.file_id#d" style="width:100%;" value="#qry_detail.detail.cloud_url_org#" />
								</cfif>
								<!--- Plugin --->
								<cfset args = structNew()>
								<cfset args.detail = qry_detail.detail>
								<cfset args.thefiletype = "vid">
								<cfinvoke component="global.cfc.plugins" method="getactions" theaction="show_in_direct_link" args="#args#" returnvariable="pl">
								<!--- Show plugin --->
								<cfloop list="#pl.pview#" delimiters="," index="i">
									<br />
									#evaluate(i)#
								</cfloop>
							</div>
							<!--- Embed Code --->
							<div id="dive#attributes.file_id#" style="display:none;">
								<cfset eh = qry_detail.detail.vheight + 40>
								<textarea id="inpute#attributes.file_id#" style="width:500px;height:60px;" readonly="readonly"><iframe frameborder="0" src="#session.thehttp##cgi.http_host##cgi.script_name#?#theaction#=c.sv&f=#attributes.file_id#&v=o" scrolling="auto" width="100%" height="#eh#"></iframe></textarea>
							</div>
						</cfif>
					</td>
				</tr>
			<cfelse>
				<cfset lpu = mid(qry_detail.detail.link_path_url,1,5)>
				<cfif lpu CONTAINS "http">
					<tr>
						<td width="100%" nowrap="true">
						<a href="#myself#c.serve_file&file_id=#attributes.file_id#&type=vid" target="_blank">#myFusebox.getApplicationData().defaults.trans("link_to_original")#</a>
						</td>
					</tr>
				</cfif>
			</cfif>
		<!--- Original file not available --->
		<cfelse>
			<tr>
				<td>
					The original file has not been made available
				</td>
			</tr>
		</cfif>
		<!--- Show related videos (if any) --->
		<tr>
			<td colspan="2" style="padding:0;margin:0;">
				<div id="relatedvideos"></div>
			</td>
		</tr>
		<!--- Show additional version --->
		<tr>
			<td colspan="2" style="padding:0;margin:0;">
				<div id="additionalversions"></div>
			</td>
		</tr>
	</table>
	<br />
	<cfif attributes.folderaccess NEQ "R">
		<div class="collapsable"><div class="headers">&gt; Create new renditions</div></div>
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
				<td nowrap="nowrap"><input type="text" style="width:35px" name="convert_width_ogv" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_ogv','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_ogv" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_ogv','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
				<td rowspan="11" width="100%" nowrap="true" valign="top" style="padding-left:20px;">
					<strong>#myFusebox.getApplicationData().defaults.trans("video_original")#</strong>
					<br />
					#myFusebox.getApplicationData().defaults.trans("file_name")#: #qry_detail.detail.vid_filename#
					<br />
					#myFusebox.getApplicationData().defaults.trans("format")#: #ucase(qry_detail.detail.vid_extension)#
					<br />
					#myFusebox.getApplicationData().defaults.trans("size")#: #qry_detail.detail.vwidth#x#qry_detail.detail.vheight# pixel
					<br />
					#myFusebox.getApplicationData().defaults.trans("data_size")#: #qry_detail.thesize# MB
				</td>
			</tr>
			<!--- WebM --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="webm"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',1);return false;" style="text-decoration:none;">WebM (WebM)*</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "webm">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_webm" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_webm','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_webm" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_webm','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
			</tr>
			<!--- Flash --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="flv"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',2);return false;" style="text-decoration:none;">Flash (FLV)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "flv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_flv" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_flv','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_flv" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_flv','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
			</tr>
			<!--- MP4 --->
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="mp4"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',3);return false;" style="text-decoration:none;">Mpeg4 (MP4)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "mp4">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_mp4" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mp4','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_mp4" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mp4','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_mp4" value="600">kb/s</td> --->
			</tr>
			<tr class="list">
				<td width="1%" nowrap="true" align="center"><input type="checkbox" name="convert_to" value="wmv"></td>
				<td width="1%" nowrap="true"><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',4);return false;" style="text-decoration:none;">Windows Media Video (WMV)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "wmv">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td width="1%" nowrap="true"><input type="text" style="width:35px" name="convert_width_wmv" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_wmv','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_wmv" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_wmv','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
				<!--- <td width="100%" nowrap="true"><input type="text" size="4" name="convert_bitrate_wmv" value="600">kb/s</td> --->
			</tr>
			<tr class="list">
				<td align="center"><input type="checkbox" name="convert_to" value="avi"></td>
				<td><a href="##" onclick="clickcbk('form#attributes.file_id#','convert_to',5);return false;" style="text-decoration:none;">Audio Video Interlaced (AVI)</a></td>
				<td nowrap="true">
					<cfset incval.theformat = "avi">
					<cfinclude template="inc_video_presets.cfm" />
				</td>
				<td><input type="text" style="width:35px" name="convert_width_avi" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_avi','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_avi" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_avi','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
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
				<td><input type="text" style="width:35px" name="convert_width_mov" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mov','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_mov" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mov','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
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
				<td><input type="text" style="width:35px" name="convert_width_mxf" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mxf','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_mxf" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mxf','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
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
				<td><input type="text" style="width:35px" name="convert_width_mpg" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_mpg','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_mpg" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_mpg','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
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
				<td><input type="text" style="width:35px" name="convert_width_rm" value="<cfif qry_detail.detail.vwidth EQ 0>1280<cfelse>#qry_detail.detail.vwidth#</cfif>" onchange="aspectheight(this,'convert_height_rm','form#attributes.file_id#',#theaspectratio#);" maxlength="4"> x <input type="text" style="width:35px" name="convert_height_rm" value="<cfif qry_detail.detail.vheight EQ 0>720<cfelse>#qry_detail.detail.vheight#</cfif>" onchange="aspectwidth(this,'convert_width_rm','form#attributes.file_id#',#theaspectratio#);" maxlength="4"></td>
				<!--- <td nowrap="true"><input type="text" size="4" name="convert_bitrate_rm" value="600">kb/s</td> --->
			</tr>
			<tr>
				<td colspan="5"><input type="button" name="convertbutton" value="#myFusebox.getApplicationData().defaults.trans("convert_button")#" class="button" onclick="convertvideos('form#attributes.file_id#');"> <div id="statusconvert" style="padding:10px;color:green;background-color:##FFFFE0;visibility:hidden;"></div><div id="statusconvertdummy"></div></td>
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
