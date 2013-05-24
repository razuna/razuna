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
	<!--- Search --->
	<div id="divsearch" style="display:none;">
		<form action="#self#" method="post" id="form_search">
		<input type="hidden" name="#theaction#" value="c.log_search">
		<input type="hidden" name="logtype" id="logtype" value="log_assets">
			<table border="0" width="100%" cellspacing="0" cellpadding="0" class="tablepanel">
				<tr>
					<th>Search Log</th>
				</tr>
				<tr>
					<td><input type="text" name="searchtext" id="searchtext" style="width:300px"> <input type="submit" name="search" value="Search"> <div id="submitsearch"></div></td>
				</tr>
			</table>
		</form>
	</div>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<!--- Selection --->
		<tr>
			<td colspan="6">
				<div style="float:left;padding-top:3px;">
					#myFusebox.getApplicationData().defaults.trans("show_only")#
					<select id="actionsassets" onchange="loadcontent('log_show','#myself#c.log_assets&logaction=' + document.getElementById('actionsassets').options[document.getElementById('actionsassets').selectedIndex].value);">
						<option selected="true" value="0">#myFusebox.getApplicationData().defaults.trans("action")#</option>
						<option value="0">-------</option>
						<option value="add">Add</option>
						<option value="update">Update</option>
						<option value="delete">Delete</option>
						<option value="move">Move</option>
						<option value="convert">Renditions</option>
					</select>
					<a href="##" onclick="loadcontent('log_show','#myself#c.log_assets');">#myFusebox.getApplicationData().defaults.trans("reset")#</a>
				</div>
				<div style="float:right;padding-top:9px;">
					<a href="##" onclick="showsearch();">#myFusebox.getApplicationData().defaults.trans("header_search")#</a>
				</div>
			</td>
		</tr>
		<!--- Back and Forth --->
		<cfinclude template="dsp_admin_log_backnext.cfm">
		<tr>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("date")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("time")#</th>
			<th width="100%">#myFusebox.getApplicationData().defaults.trans("description")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("action")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("log_type_of_file")#</th>
			<th width="1%" nowrap="true">#myFusebox.getApplicationData().defaults.trans("theuser")#</th>
		</tr>
		<!--- Loop over all scheduled log entries in database table --->
		<cfloop query="qry_log">
			<tr class="list">
				<td nowrap="true" valign="top">#dateformat(log_timestamp, "#myFusebox.getApplicationData().defaults.getdateformat()#")#</td>
				<td nowrap="true" valign="top">#timeFormat(log_timestamp, 'HH:mm:ss')#</td>
				<td valign="top">#log_desc#</td>
				<td nowrap="true" align="center" valign="top">#log_action#</td>
				<td nowrap="true" align="center" valign="top">#log_file_type#</td>
				<td nowrap="true" align="center" valign="top">#user_first_name# #user_last_name#</td>
			</tr>
		</cfloop>
		<cfinclude template="dsp_admin_log_backnext.cfm">
	</table>
	<script type="text/javascript">
		// Show Search
		function showsearch(){
			$('##divsearch').toggle('blind','slow');
		}
		$("##form_search").submit(function(e){
			// Only allow chars
			var illegalChars = /(\*|\?)/;
			// Parse the entry
			var theentry = $('##searchtext').val();
			var thetype = $('##logtype').val();
			// get the first position
			var p1 = theentry.substr(theentry,1);
			// Now check
			if (illegalChars.test(p1)){
				alert('The first character of your search string is an illegal one. Please remove it!');
			}
			else if (theentry == "") {
				alert('Please enter a search term!');
			}
			else {
				// Get values
				var url = formaction("form_search");
				var items = formserialize("form_search");
				// Submit Form
				$('##submitsearch').html('<img src="#dynpath#/global/host/dam/images/loading.gif" width="16" height="16" border="0" style="padding:0px;">');
				loadcontent('log_show','#self#?' + items);
			}
			return false;
		});
	</script>
</cfoutput>