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
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<!--- Ad Server details --->
		<tr>
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("ad_server_details")#</th>
		</tr>
		<!--- Ad Server Or Domain Name --->
		<tr>
			<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("ad_server_name")#</td>
			<td width="100%"><input type="text" name="ad_server_name" id="ad_server_name" style="width:300px;" value="#ad_server_name#" ></td>
		</tr>
		<!--- Ad Server Port --->
		<tr>
			<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("ad_server_port")#</td>
			<td width="100%"><input type="text" name="ad_server_port" id="ad_server_port" style="width:300px;" value="#ad_server_port#" ></td>
		</tr>
		<!--- Ad User Name --->
		<tr>
			<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("ad_user_name")#</td>
			<td width="100%"><input type="text" name="ad_user_name" id="ad_user_name" style="width:300px;" value="#ad_server_username#"></td>
		</tr>
		<!--- Ad password --->
		<tr>
			<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("ad_user_pass")#</td>
			<td width="100%"><input type="password" name="ad_user_pass" id="ad_user_pass" style="width:300px;" value="#ad_server_password#" ></td>
		</tr>
		<!--- Filter --->
		<tr>
			<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("ad_filter")#</td>
			<td width="100%"><input type="text" name="ad_filter" id="ad_filter" style="width:300px;" value="#ad_server_filter#" ></td>
		</tr>
		<!--- Start --->
		<tr>
			<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("ad_start")#</td>
			<td width="100%"><input type="text" name="ad_start" id="ad_start" style="width:300px;" value="#ad_server_start#" ></td>
		</tr>
	</table>
	<div style="float:left;"><input type="button" value="#myFusebox.getApplicationData().defaults.trans("button_save_ad_server")#" class="button" onclick="save_ad_server();" /></div>
	<div id="status_integration" style="float:left;padding-top:5px;"></div>
	<div style="clear:both;"></div>
	<div id="updatetext" style="color:green;display:none;float:left;font-weight:bold;padding:15px 0px 0px 10px;"></div>
	<script type="text/javascript">
		// Save
		function save_ad_server(){
			// Values
			var server = $("##ad_server_name").val();
			var port = $("##ad_server_port").val();
			var un = $("##ad_user_name").val();
			var pwd = $("##ad_user_pass").val();
			var filter = $("##ad_filter").val();
			var start = $("##ad_start").val();
			// Save
			$('##div_forall').load('#myself#c.admin_ad_services_save', {ad_server_name: server, ad_server_port: port, ad_server_username: un, ad_server_password: pwd, ad_server_filter: filter, ad_server_start: start });
			// Feedback
			$('##status_integration').fadeTo("fast", 100);
			$('##status_integration').html('<span style="font-weight:bold;color:green;">#myFusebox.getApplicationData().defaults.trans("saved_change")#!</span>');
			$('##status_integration').fadeTo(5000, 0);
		}
	</script>
</cfoutput> 