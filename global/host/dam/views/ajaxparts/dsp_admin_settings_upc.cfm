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
	<!--- <cfdump var="#qry_upc#"> --->
	<!--- <cfabort> --->
	<div style="float:left;">
		<h2>UPC</h2>
	</div>
	<div style="float:right;padding-top:20px;">
		<a href="##" onclick="showwindow('#myself#c.admin_upc_template&upc_temp_id=0','New UPC settings',650,1);" class="awesome button green small">Add a new UPC template</a>
	</div>
	<cfmodule template="../../modules/clearfix.cfm" padding="0" />
	<div style="float:left;">Razuna also works with UPC (Universal Product Code)...</div>
	<cfmodule template="../../modules/clearfix.cfm" padding="10" />
	<!--- <hr> --->

	<!--- <hr> --->



	<!--- Table with upc settings --->
	<cfif qry_upc.templates.recordcount>
		<h3>#myFusebox.getApplicationData().defaults.trans("templates")#</h3>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th width="20%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("template")#</th>
				<th width="80%">#myFusebox.getApplicationData().defaults.trans("description")#</th>
				<th width="1%" nowrap="true"></th>
				<th width="1%" nowrap="true"></th>
			</tr>
			<!--- Loop over all scheduled events in database table --->
			<cfloop query="qry_upc.templates">
				<tr class="list">
					<td nowrap="true" valign="top"><a href="##" onclick="showwindow('#myself#c.admin_upc_template&upc_temp_id=#upc_temp_id#','#upc_name#',650,1);">#upc_name#</a></td>
					<td valign="top">#upc_description#</td>
					<td nowrap="true" valign="top" align="center"><cfif upc_active EQ 1><img src="#dynpath#/global/host/dam/images/checked.png" width="16" height="16" border="0"></cfif></td>
					<td nowrap="true" valign="top" align="center"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=admin_upc_template&id=#upc_temp_id#&loaddiv=upc','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
				</tr>
			</cfloop>
		</table>
	</cfif>

	<cfmodule template="../../modules/clearfix.cfm" padding="20" />

	<!--- Set upc --->
	<form name="form_admin_settings_upc" id="form_admin_settings_upc" method="post" action="#self#">
		<input type="hidden" name="#theaction#" value="c.admin_upc_save">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<!--- UPC Enabled --->
			<tr>
				<th class="textbold" colspan="2">#myFusebox.getApplicationData().defaults.trans("upc_enabled")#</th>
				<th></th>
			</tr>
			<tr>
				<td width="10%" nowrap="nowrap">
					<input type="radio" name="set2_upc_enabled" value="true" <cfif qry_upc.settings.set2_upc_enabled>checked="checked"</cfif> >#myFusebox.getApplicationData().defaults.trans("yes")#
					<input type="radio" name="set2_upc_enabled" value="false" <cfif !qry_upc.settings.set2_upc_enabled>checked="checked"</cfif> >#myFusebox.getApplicationData().defaults.trans("no")#
				</td>
				<td width="80%" nowrap="nowrap">
					<input type="submit" name="submit_upc" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button">
				</td>
			</tr>
		</table>
	</form>

	<!--- Status --->
	<cfmodule template="../../modules/clearfix.cfm" padding="10" />
	<div id="form_admin_settings_upc_status" style="float:left;font-weight:bold;color:green;"></div>
	<cfmodule template="../../modules/clearfix.cfm" padding="20" />

	<!--- JS --->
	<script type="text/javascript">
		// Submit Form
		$("##form_admin_settings_upc").submit(function(e){
			// Get values
			var url = formaction("form_admin_settings_upc");
			var items = formserialize("form_admin_settings_upc");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
			   		$('##form_admin_settings_upc_status').html('#myFusebox.getApplicationData().defaults.trans("success")#').animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
			return false;
		});
	</script>
</cfoutput>