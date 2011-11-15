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
	<!--- Set Languages --->
	<form name="form_admin_settings" id="form_admin_settings" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.isp_settings_langsave">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="2">#defaultsObj.trans("choose_language")# - <a href="##" onclick="loadcontent('admin_settings','#myself#c.isp_settings_updatelang');">#defaultsObj.trans("language_update")#</a></th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("language_update_desc")#</td>
		</tr>
		<cfloop query="qry_langs">
			<tr class="list">
				<td width="1%" nowrap="true"><input type="checkbox" name="lang_active_#lang_id#" value="t"<cfif lang_active EQ "t"> checked</cfif>></td>
				<td width="100%">#lang_name#</td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="2" align="right"><input type="submit" name="submit" value="#defaultsObj.trans("button_save")#" class="button"></td>
		</tr>
	</table>
	</form>
	<!--- Upload Logo --->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="2">#defaultsObj.trans("logo_header")#</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("logo_desc")#</td>
		</tr>
		<tr>
			<td valign="top">#defaultsObj.trans("upload")#</td>
			<td>
				<div id="iframe">
					<iframe src="#myself#ajax.isp_settings_upload" frameborder="false" scrolling="false" style="border:0px;width:550px;height:50px;"></iframe>
		       	</div>
			</td>
		</tr>
		<tr>
			<td valign="top"><a href="##" onclick="loadcontent('loadlogo','#myself#ajax.prefs_loadlogo');">Refresh</a><br /><a href="##" onclick="loadcontent('loadlogo','#myself#ajax.prefs_loadlogo&remove=t');">Remove Logo</a></td>
			<td><div id="loadlogo"></div></td>
		</tr>
	</table>
	<!--- Load Logo --->
	<script language="JavaScript" type="text/javascript">
		loadcontent('loadlogo','#myself#ajax.prefs_loadlogo');
		$("##form_admin_settings").submit(function(e){
			// Get values
			var url = formaction("form_admin_settings");
			var items = formserialize("form_admin_settings");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			return false;
		});
	</script>	
</cfoutput>