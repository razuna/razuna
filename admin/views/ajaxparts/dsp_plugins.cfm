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
	<form name="form_plugins" id="form_plugins" method="post" action="#self#">
		<input type="hidden" name="#theaction#" value="c.prefs_global_save">
		<div id="tabs_plugins">
			<ul>
				<!--- Page --->
				<li><a href="##plugins">Plugins</a></li>
				<!--- Host Plugins --->
				<li><a href="##plugins_hosts" onclick="loadcontent('plugins_hosts','#myself#c.plugins_hosts');">#defaultsObj.trans("plugins_hosts_tab")#</a></li>
			</ul>
			<!--- Plugins Main page --->
			<div id="plugins">
				<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
					<tr>
						<td colspan="2" align="right"><a href="##" onclick="$('##plugin_upload').slideToggle('slow');return false;">#defaultsObj.trans("add_new")#</a></td>
					</tr>
					<tr>
						<td colspan="2">
							<div id="plugin_upload" style="display:none;">
								Plugins extend and expand the functionality of Razuna. If you have a plugin in a .zip format, you may install it by uploading it here.<br /><br />
								<iframe src="#myself#ajax.plugins_upload" frameborder="false" scrolling="false" style="border:0px;width:500px;height:80px;"></iframe>
							</div>
						</td>
					</tr>
					<tr>
						<th>Plugin</th>
						<th>#defaultsObj.trans("desc")#</th>
					</tr>
					<cfloop query="qry_plugins">
						<tr>
							<td nowrap="nowrap" valign="top"><strong>#p_name#</strong><br /><cfif p_active><a href="##" onclick="loadcontent('rightside','#myself#c.plugins_onoff&active=false&pid=#p_id#');">#defaultsObj.trans("deactivate")#</a><cfelse><a href="##" onclick="loadcontent('rightside','#myself#c.plugins_onoff&active=true&pid=#p_id#');">#defaultsObj.trans("activate")#</a> | <a href="##" onclick="showwindow('#myself#ajax.remove_record&what=plugins&id=#p_id#&loaddiv=rightside','#defaultsObj.trans("remove_selected")#',400,1);return false">Delete</a></cfif></td>
							<td valign="top">#p_description#</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<!--- Plugin activate per tenant list --->
			<div id="plugins_hosts"><img src="images/loading.gif" border="0" style="padding:10px;"></div>	
		</div>
	</form>

	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		jqtabs("tabs_plugins");
	</script>
</cfoutput>