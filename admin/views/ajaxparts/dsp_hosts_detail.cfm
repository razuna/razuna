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
	<div style="padding:10px;">
	<form name="form_hostedit" id="form_hostedit" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.hosts_update">
	<input type="hidden" name="host_id" value="#attributes.host_id#">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<!---
		<tr>
			<td>#defaultsObj.trans("how_many_lang")#</td>
			<td><input type="text" name="thishost_lang" id="thishost_lang" size="10" class="text" value="#qry_hostsdetail.host_lang#"></td>
		</tr>
		--->
		<tr>
			<td nowrap="true" width="1%" nowrap="true"><cfif application.razuna.isp>Subdomain<cfelse>#defaultsObj.trans("hosts_name")#</cfif></td>
			<td width="100%"><input type="text" name="host_name" id="host_name" style="width:200px;" value="#qry_hostsdetail.host_name#"><cfif application.razuna.isp>.yourdomain.com</cfif></td>
		</tr>
		<cfif application.razuna.isp>
			<tr>
				<td valign="top" nowrap="true">Custom hostname</td>
				<td><input type="text" name="host_name_custom" id="host_name_custom" style="width:200px;" value="#qry_hostsdetail.host_name_custom#"><br /><em>(If you want to let your customer use his own domain. He needs to setup a CNAME to his subdomain!)</em></td>
			</tr>
		</cfif>
		<cfif !application.razuna.isp>
			<tr>
				<td nowrap="true">#defaultsObj.trans("hosts_path")#</td>
				<td>#qry_hostsdetail.host_path#</td>
			</tr>
		</cfif>
		<tr>
			<td nowrap="true">#defaultsObj.trans("hosts_size")#</td>
			<td>#hostsize#</td>
		</tr>
		<!--- <tr>
			<td nowrap="true">#defaultsObj.trans("db_prefix")#</td>
			<td>#qry_hostsdetail.host_db_prefix#</td>
		</tr> --->
		<tr>
			<td colspan="2"><div id="feedback" style="display:none;font-weight:bold;color:green;float:left;"></div><div style="float:right;"><input type="submit" name="Submitform_hostedit" value="#defaultsObj.trans("save")#" class="button"></div></td>
		</tr>

	</table>
	</form>
	</div>
	<script language="javascript">
		$("##form_hostedit").submit(function(e){
			// Get values
			var url = formaction("form_hostedit");
			var items = formserialize("form_hostedit");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			// Feedback
			$("##feedback").css("display","");
			$("##feedback").html('#defaultsObj.trans("success")#');
			loadcontent('hostslist', '#myself#c.hosts_list');
			return false;
		});
	</script>
</cfoutput>