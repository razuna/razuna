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
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="##FFFFFF">
		<td>
			<!--- Reports --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
			<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_20"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/chart_24.png" alt="" width="24" height="24" border="0" align="left"></td><td width="212" class="textbold">#defaultsObj.trans("reports")#</td></tr></table></td>
			</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("report_stats")# (Website)</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="">&raquo; #defaultsObj.trans("report_stats")# (Media Center)</a></td>
			</tr>
			</table>
			<!--- General Settings --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
			<tr>
			<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_21"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/settings_24.png" alt="" width="24" height="24" border="0" align="left"></td><td width="212" class="textbold">#defaultsObj.trans("general_settings")#</td></tr></table></td>
			</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<tr>
			<td valign="top"><a href="dsp_frame_main_split.cfm?show=ks" target="mainFrame">&raquo; #defaultsObj.trans("keywords")#</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="dsp_frame_main_split.cfm?show=cat" target="mainFrame">&raquo; #defaultsObj.trans("img_set_categories")#</a></td>
			</tr>
			<tr>
			<td valign="top" style="padding-top:10px;"><a href="dsp_frame_main.cfm?show=scheduler" target="mainFrame">&raquo; #defaultsObj.trans("scheduled_uploads")#</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="dsp_frame_main.cfm?show=remoteusers" target="mainFrame">&raquo; #defaultsObj.trans("img_set_remoteusers")#</a></td>
			</tr>
			</table>
			<!--- Image Settings --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
			<tr>
			<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_22"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/filemanager_24.png" alt="" width="24" height="24" border="0" align="left"></td><td width="212" class="textbold">#defaultsObj.trans("image_settings")#</td></tr></table></td>
			</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<tr>
			<td valign="top"><a href="dsp_frame_main.cfm?show=imgset_pub" target="mainFrame">&raquo; #defaultsObj.trans("img_set_publishers")#</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="dsp_frame_main.cfm?show=imgset_vlist" target="mainFrame">&raquo; #defaultsObj.trans("img_set_valuelists")#</a></td>
			</tr>
			</table>
			<!--- Video Settings --->
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding-top:15px;">
			<tr>
			<td height="30" nowrap background="images/button_menu/bggrey.gif" id="divlink_23"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="27"><img src="images/button_menu/movie.png" alt="" width="24" height="24" border="0" align="left"></td><td width="212" class="textbold">#defaultsObj.trans("video_settings_global")#</td></tr></table></td>
			</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="table_border">
			<tr>
			<td valign="top"><a href="dsp_frame_main.cfm?show=vidset_pub" target="mainFrame">&raquo; #defaultsObj.trans("img_set_publishers")#</a></td>
			</tr>
			<tr>
			<td valign="top"><a href="dsp_frame_main.cfm?show=vidset_vlist" target="mainFrame">&raquo; #defaultsObj.trans("img_set_valuelists")#</a></td>
			</tr>
			</table>


		</td>
	</tr>




</table>
</cfoutput>