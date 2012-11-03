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
<form name="form_settings_global" id="form_settings_global" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.prefs_global_save">
	<div id="tabs_prefs_global">
		<ul>
			<!--- Storage --->
			<li><a href="##gstorage" onclick="savesettings();loadcontent('gstorage','#myself#c.prefs_global_storage');">Storage</a></li>
			<!--- Storage --->
			<li><a href="##gdb" onclick="savesettings();loadcontent('gdb','#myself#c.prefs_global_db');">#defaultsObj.trans("database_settings")#</a></li>
			<!--- File Types --->
			<li><a href="##ptypes" onclick="savesettings();loadcontent('ptypes','#myself#c.prefs_types');">#defaultsObj.trans("pref_types_header")#</a></li>
			<!--- Backup/Import --->
			<li><a href="##backrest" onclick="savesettings();loadcontent('backrest','#myself#c.prefs_backup_restore');">#defaultsObj.trans("header_backup_restore")#</a></li>
			<!--- Tools --->
			<li><a href="##tools" onclick="savesettings();loadcontent('tools','#myself#c.prefs_global_tools');">Tools</a></li>
			<!--- Rendering Farm --->
			<li><a href="##renf" onclick="savesettings();loadcontent('renf','#myself#c.prefs_renf');">#defaultsObj.trans("header_rf")#</a></li>
			<!--- System Info --->
			<li><a href="##systeminfo">System Information</a></li>
		</ul>
		<!--- Storage --->
		<div id="gstorage"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
		<!--- Database --->
		<div id="gdb"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
		<!--- File Types --->
		<div id="ptypes"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
		<!--- Backup --->
		<div id="backrest"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
		<!--- Tools --->
		<div id="tools"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
		<!--- Rendering Farm --->
		<div id="renf"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
		<!--- System Info --->
		<div id="systeminfo">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
				<tr>
					<th colspan="2">Your Razuna Setup</th>
				</tr>
				<tr>
					<td width="100%">#defaultsObj.trans("database_in_use")#</td>
					<td width="1%" nowrap>#application.razuna.thedatabase#</td>
				</tr>
				<tr>
					<td width="100%">#defaultsObj.trans("storage_container")#</td>
					<td width="1%" nowrap>#application.razuna.storage#</td>
				</tr>
				<tr>
					<td width="100%">#defaultsObj.trans("server_platform")#</td>
					<td width="1%" nowrap>#server.OS.Name#</td>
				</tr>
				<tr>
					<td width="100%">#defaultsObj.trans("server_platform_version")#</td>
					<td width="1%" nowrap>#server.os.version#</td>
				</tr>
				<tr>
					<td width="100%">#defaultsObj.trans("coldfusion_product")#</td>
					<td width="1%" nowrap>#server.ColdFusion.ProductName#</td>
				</tr>
				<tr>
					<td width="100%">#defaultsObj.trans("coldfusion_version")#</td>
					<td width="1%" nowrap><cfif server.ColdFusion.ProductName CONTAINS "bluedragon">#server.bluedragon.edition#<cfelse>#server.ColdFusion.ProductVersion#</cfif></td>
				</tr>
				<tr>
					<td width="100%">#defaultsObj.trans("server_url")#</td>
					<td width="1%" nowrap>#cgi.HTTP_HOST#</td>
				</tr>
				<tr>
					<td width="100%">Server ID</td>
					<td width="1%" nowrap>#application.razuna.serverid#</td>
				</tr>
				<tr>
					<td class="list" colspan="2"></td>
				</tr>
			</table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
					<cfset variables.mem = systemmemory()>
				<tr>
					<th colspan="2">Memory Allocation</th>
				</tr>
				<tr>
					<td width="100%">Memory Total</td>
					<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.total))# MB</td>
				</tr>
				<tr>
					<td width="100%">Memory Free</td>
					<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.free))# MB</td>
				</tr>
				<tr>
					<td width="100%">Memory Max</td>
					<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.max))# MB</td>
				</tr>
				<tr>
					<td width="100%">Memory Used</td>
					<td width="1%" nowrap>#int(defaultsObj.converttomb(variables.mem.used))# MB</td>
				</tr>
			</table>
		</div>
	</div>
	<br>
	<div id="settingsfeedback" style="display:none;float:left;font-weight:bold;color:green;"></div>
	<div style="text-align:right;padding-top:5px;padding-bottom:10px;float:right;">
		<input type="submit" name="save" value="#defaultsObj.trans("save")#" class="button" /> 
	</div>
</form>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_prefs_global");
	loadcontent('gstorage','#myself#c.prefs_global_storage');
	// Save this form
	function savesettings() {
		// Get values
		var url = formaction("form_settings_global");
		var items = formserialize("form_settings_global");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items
		});
		return false;
	}
	$("##form_settings_global").submit(function(e){
		// save with the function above
		savesettings();
		// Display saved message
		$("##settingsfeedback").css("display","");
		$("##settingsfeedback").html('#defaultsObj.trans("saved_changes")#');
		return false;
	});
</script>

</cfoutput>