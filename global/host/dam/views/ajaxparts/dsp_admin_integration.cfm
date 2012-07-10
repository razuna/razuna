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
	<cfif session.hosttype EQ 0>
		This section allows you to integrate Razuna with other apps.<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		<!--- Integration --->
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_integration_social_login")#</th>
			</tr>
			<tr>
				<td colspan="2">#myFusebox.getApplicationData().defaults.trans("header_integration_social_login_desc")#<br /><br /></td>
			</tr>
			<tr>
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("header_integration_social_login_enable")#</td>
				<td width="100%"><input type="radio" name="janrain_enable" id="janrain_enable" value="true"<cfif jr_enable> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="janrain_enable" id="janrain_enable" value="false"<cfif !jr_enable> checked="true"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")#</td>
			</tr>
			<tr>
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("header_integration_social_login_apikey")#</td>
				<td width="100%"><input type="text" name="janrain_apikey" id="janrain_apikey" style="width:300px;" value="#jr_apikey#" /></td>
			</tr>
			<tr>
				<td nowrap="nowrap">JanRain APP URL</td>
				<td width="100%"><input type="text" name="janrain_appurl" id="janrain_appurl" style="width:300px;" value="#jr_appurl#" /></td>
			</tr>
		</table>
		<div id="status_integration" style="float:left;padding-top:5px;"></div><div style="float:right;"><input type="button" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" class="button" onclick="save_integr();" /></div>
		<div style="clear:both;"></div>
		<div id="dummy_integration" style="display:none;"></div>
	</cfif>
	<script type="text/javascript">
		function save_integr(){
			// Values
			var e = $("##janrain_enable:checked").val();
			var k = $("##janrain_apikey").val();
			var a = $("##janrain_appurl").val();
			// Save
			$('##dummy_integration').load('#myself#c.admin_integration_save', {janrain_enable: e, janrain_apikey: k, janrain_appurl: a});
			// Feedback
			$('##status_integration').fadeTo("fast", 100);
			$('##status_integration').html('<span style="font-weight:bold;color:green;">We saved the change successfully!</span>');
			$('##status_integration').fadeTo(5000, 0);
		}
	</script>
</cfoutput>