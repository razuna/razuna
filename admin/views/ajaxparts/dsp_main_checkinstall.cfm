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
<cfoutput><table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<td colspan="2">#defaultsObj.trans("complete_install_tasks_desc")#</td>
	</tr>
	<tr>
		<th width="100%">#defaultsObj.trans("installation_checklist_task")#</th>
		<th align="center" width="1%" nowrap>#defaultsObj.trans("installation_checklist_progress")#</th>
	</tr>
	<!--- IM --->
	<tr>
		<td<cfif tools.imagemagick EQ ""> class="alerttext"</cfif> style="border-right:none;"><a href="##" onclick="javascript:loadcontent('rightside','#myself#c.prefs_global_main');return false;">#defaultsObj.trans("installation_checklist_impath")#</a></td>
		<td align="center" style="border-left:none;"><cfif tools.imagemagick IS NOT ""><img src="images/men_ok.png" border="0"><cfelse><img src="images/men_nope.png" border="0"></cfif></td>
	</tr>
	<!--- FFMPEG --->
	<tr>
		<td<cfif tools.ffmpeg EQ ""> class="alerttext"</cfif> style="border-right:none;"><a href="##" onclick="javascript:loadcontent('rightside','#myself#c.prefs_global_main');return false;">#defaultsObj.trans("installation_checklist_ffmpeg")#</a></td>
		<td align="center" style="border-left:none;"><cfif tools.ffmpeg IS NOT ""><img src="images/men_ok.png" border="0"><cfelse><img src="images/men_nope.png" border="0"></cfif></td>
	</tr>
	<!--- Exiftool --->
	<tr>
		<td<cfif tools.exiftool EQ ""> class="alerttext"</cfif> style="border-right:none;"><a href="##" onclick="javascript:loadcontent('rightside','#myself#c.prefs_global_main');return false;">#defaultsObj.trans("installation_checklist_exiftool")#</a></td>
		<td align="center" style="border-left:none;"><cfif tools.exiftool IS NOT ""><img src="images/men_ok.png" border="0"><cfelse><img src="images/men_nope.png" border="0"></cfif></td>
	</tr>
	<!--- Path to assets --->
	<cfif application.razuna.thedatabase NEQ "oracle">
		<tr>
			<td<cfif chklist_settings.set2_path_to_assets EQ ""> class="alerttext"</cfif> style="border-right:none;"><a href="##" onclick="javascript:loadcontent('rightside','#myself#c.prefs');return false;">#defaultsObj.trans("installation_checklist_assetpath")#</a></td>
			<td align="center" style="border-left:none;"><cfif #chklist_settings.set2_path_to_assets# IS NOT ""><img src="images/men_ok.png" border="0"><cfelse><img src="images/men_nope.png" border="0"></cfif></td>
		</tr>
	</cfif>
	<tr>
		<td<cfif #chklist_settings.set2_email_from# EQ ""> class="alerttext"</cfif> style="border-right:none;"><a href="##" onclick="javascript:loadcontent('rightside','#myself#c.prefs');return false;">#defaultsObj.trans("installation_checklist_emailfrom")#</a></td>
		<td align="center" style="border-left:none;"><cfif #chklist_settings.set2_email_from# IS NOT ""><img src="images/men_ok.png" border="0"><cfelse><img src="images/men_nope.png" border="0"></cfif></td>
	</tr>
</table>
</cfoutput>
