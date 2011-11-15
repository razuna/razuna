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
	<!---
<form name="hostedit" id="hostedit" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.hosts_update">
	<input type="hidden" name="host_id" value="#attributes.host_id#">
--->
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th colspan="2">#defaultsObj.trans("hosts_edit")#</th>
		</tr>
		<!---
<tr>
			<td>#defaultsObj.trans("how_many_lang")#</td>
			<td><input type="text" name="thishost_lang" id="thishost_lang" size="10" class="text" value="#qry_hostsdetail.host_lang#"></td>
		</tr>
--->
		<tr>
			<td width="1%">#defaultsObj.trans("hosts_name")#</td>
			<td width="100%">#qry_hostsdetail.host_name#</td>
		</tr>
		<tr>
			<td nowrap="true">#defaultsObj.trans("hosts_path")#</td>
			<td>#qry_hostsdetail.host_path#</td>
		</tr>
		<tr>
			<td>#defaultsObj.trans("db_prefix")#</td>
			<td>#qry_hostsdetail.host_db_prefix#</td>
		</tr>
		<!---
<tr>
			<td colspan="2"><div id="feedback" style="display:none;font-weight:bold;color:red;float:left;"></div><div style="float:right;"><input type="submit" name="Submit" value="#defaultsObj.trans("save")#" class="button"></div></td>
		</tr>
--->
	</table>
	<!--- </form> --->
	</div>
	<div id="dummy" style="display:none"></div>
	<script language="javascript">
		$("##hostedit").submit(function(e){
			// Get values
			var item = escape($("##thishost_lang").val());
			// Submit Form
			loadcontent('dummy', '#myself#c.hosts_update&host_id=#attributes.host_id#&host_lang=' + item);
			$("##feedback").css("display","");
			$("##feedback").html('#defaultsObj.trans("success")#');
			return false;
		});
	</script>
</cfoutput>