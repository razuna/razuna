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
	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border: 1px solid ##BEBEBE;">
		<tr>
			<td align="center" width="100%" style="padding:10px;background-color:##FFFFE0;">#defaultsObj.trans("warning_tenant_settings")#</td>
		</tr>
	</table>
	<br />
	<!--- Host form --->
	<cfinclude template="dsp_host_chooser_include.cfm">
	<form name="form_settings" id="form_settings" method="post" action="#self#">
		<input type="hidden" name="#theaction#" value="c.prefs_save">
		<div id="tabs_prefs">
			<ul>
				<li><a href="##pglobal" onclick="savesettings();">Mail Settings</a></li>
				<li><a href="##pmeta" onclick="savesettings();loadcontent('pmeta','#myself#c.prefs_meta');">#defaultsObj.trans("header_title_meta")#</a></li>
				<li><a href="##pdam" onclick="savesettings();loadcontent('pdam','#myself#c.prefs_dam');">#defaultsObj.trans("storage_location")#</a></li>
				<!--- <li><a href="##pimage" onclick="savesettings();loadcontent('pimage','#myself#c.prefs_image');">#defaultsObj.trans("image_settings")#</a></li>
				<li><a href="##pvideo" onclick="savesettings();loadcontent('pvideo','#myself#c.prefs_video');">#defaultsObj.trans("video_settings_global")#</a></li> --->
				<!--- If Nirvanix enabled --->
				<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "akamai">
					<li><a href="##pstorage" onclick="savesettings();loadcontent('pstorage','#myself#c.prefs_storage');">Cloud Storage</a></li>
				</cfif>
			</ul>
			<div id="pglobal"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
			<div id="pmeta"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
			<div id="pdam"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
			<!--- <div id="pimage"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
			<div id="pvideo"><img src="images/loading.gif" border="0" style="padding:10px;"></div> --->
			<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "akamai">
				<div id="pstorage"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
			</cfif>
		</div>
		<br>
		<div id="settingsfeedback" style="display:none;float:left;font-weight:bold;color:green;"></div>
		<div style="text-align:right;padding-top:5px;padding-bottom:10px;float:right;">
			<input type="submit" name="savebutton" value="#defaultsObj.trans("save")#" class="button" /> 
		</div>
	</form>

	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		jqtabs("tabs_prefs");
		loadcontent('pglobal','#myself#c.prefs_global');
		// Save this form
		function savesettings() {
			// Get values
			var url = formaction("form_settings");
			var items = formserialize("form_settings");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			return false;
		}
		$("##form_settings").submit(function(e){
			// save with the function above
			savesettings();
			// Display saved message
			$("##settingsfeedback").css("display","");
			$("##settingsfeedback").html('#defaultsObj.trans("saved_changes")#');
			$("##settingsfeedback").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			return false;
		});
	</script>

</cfoutput>