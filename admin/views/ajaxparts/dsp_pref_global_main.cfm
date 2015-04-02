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
<div id="settingsfeedback" style="display:none;float:left;font-weight:bold;color:green;height:20px;"></div>
<div style="clear:both;"></div>
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
			<!--- Task Server --->
			<li><a href="##taskserver" onclick="savesettings();">Indexing</a></li>
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
		<!--- Rendering Farm --->
		<div id="taskserver">
			<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
				<tr>
					<td colspan="2">
						<h2>Indexing and Search</h2>
						<p>Razuna features a dedicates Indexing and Search application. This application comes bundled with Razuna and lives as a web application on the same server as Razuna. However, you might wish to install this application on another server (this can improve performance as it does not use the same server resources as the main Razuna server). If you choose to do so, please edit the settings below.</p>
						<p style="color:green;">In order to switch to a dedicated Index and Search Server please <a href="http://wiki.razuna.com/display/ecp/Index+and+Search+Server" target="_blank">read our instructions FIRST!</a></p>
					</td>
				</tr>
				<tr>
					<td colspan="2"><hr /></td>
				</tr>
				<!--- Local Storage --->
				<tr>
					<td colspan="2"><h3>Application Settings</h3></td>
				</tr>
				<tr>
					<th class="textbold" colspan="2">On this server</th>
				</tr>
				<tr>
					<td align="center" valign="top"><input type="radio" name="taskserver_location" value="local"<cfif qry_taskserver.taskserver_location EQ "local"> checked="checked"</cfif>></td>
					<td>The index and Search application is installed on this server.</td>
				</tr>
				<tr>
					<td align="center" valign="top"></td>
					<td>
						This means it runs on the same install as Razuna and lives as its own web application. This is the default installation.
						<input type="hidden" name="taskserver_local_url" value="#qry_taskserver.taskserver_local_url#">
					</td>
				</tr>
				<tr>
					<th class="textbold" colspan="2">Dedicated Server</th>
				</tr>
				<tr>
					<td align="center" valign="top"><input type="radio" name="taskserver_location" value="remote"<cfif qry_taskserver.taskserver_location EQ "remote"> checked="checked"</cfif>></td>
					<td>I run the Index and Search application on a dedicated server and I have followed the instructions to the point.</td>
				</tr>
				<tr>
					<td align="center" valign="top"></td>
					<td>
						Please enter the servers <strong>full address</strong> location, e.g. http://searchserver.domain.com:8080.
						<br />
						<input type="text" name="taskserver_remote_url" style="width:300px;" value="#qry_taskserver.taskserver_remote_url#">
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</th>
				</tr>
				<tr>
					<th class="textbold" colspan="2">Secret Key</th>
				</tr>
				<tr>
					<td colspan="2">Secret key that identifies connections coming from this server.</td>
				</tr>
				<tr>
					<td colspan="2"><input type="text" name="taskserver_secret" style="width:300px;" value="#qry_taskserver.taskserver_secret#"></td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</th>
				</tr>
				<tr>
					<th class="textbold" colspan="2">Search Server Database Connection</th>
				</tr>
				<tr>
					<td colspan="2">The search server is its own application. However, it shares the same database connection as Razuna. If you are upgrading Razuna or feel that the connection is not properly established you can configure the database connection with the link below.</th>
				</tr>
				<tr>
					<td colspan="2"><a href="##" onclick="showwindow('#myself#c.prefs_indexing_db','Database Connection',550,1);">Configure Search Server Database Connection</a></td>
				</tr>
			</table>
			<div style="text-align:right;padding-top:5px;padding-bottom:10px;float:right;">
				<input type="submit" name="save" value="#defaultsObj.trans("save")#" class="button" /> 
			</div>
			<div style="clear:both;"></div>

		</div>
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
	<!--- <div style="text-align:right;padding-top:5px;padding-bottom:10px;float:right;">
		<input type="submit" name="save" value="#defaultsObj.trans("save")#" class="button" /> 
	</div> --->
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
		$("##settingsfeedback").html('#defaultsObj.trans("saved_changes")#');
		$("##settingsfeedback").animate({opacity: 1.0}, 3000).fadeTo("slow", 0, function() {
			$("##settingsfeedback").css("display","none");
		});
		return false;
	});
</script>

</cfoutput>