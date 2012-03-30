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
	<!--- Host form --->
	<cfinclude template="dsp_host_chooser_include.cfm">
	<div id="tabs_groups">
		<ul>
			<li><a href="##grpdam">#defaultsObj.trans("groups_link")# (DAM)</a></li>
			<!--- <li><a href="##grpcms">#defaultsObj.trans("groups_link")# (Administration)</a></li> --->
		</ul>
		<!--- This is DAM Groups Tab --->
		<div id="grpdam">
			<form name="grpdamadd" id="grpdamadd">
			<table width="600" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#defaultsObj.trans("groupnumber_header_new")#</th>
			</tr>
			<tr>
				<td width="100%"><input type="text" size="40" name="damgrpnew" id="damgrpnew" /></td>
				<td width="1%" nowrap="true"><input type="submit" name="Button" value="#defaultsObj.trans("add")#" class="button" /></td>
			</tr>
			</table>
			</form>
			<!--- Load list of groups here --->
			<div id="grpdamlist"></div>
		</div>
		<!--- This is Administration Groups Tab --->
		<!---
<div id="grpcms">
			<form name="grpadmadd" id="grpadmadd">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#defaultsObj.trans("groupnumber_header_new")#</th>
			</tr>
			<tr>
				<td width="100%"><input type="text" size="40" name="admgrpnew" id="admgrpnew" /></td>
				<td width="1%" nowrap="true"><input type="submit" name="Buttonadm" value="#defaultsObj.trans("add")#" class="button" /></td>
			</tr>
			</table>
			</form>
			<!--- Load list of groups here --->
			<div id="grpadmlist"></div>
		</div>
--->
	</div>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_groups");
	loadcontent('grpdamlist', '#myself#c.groups_list&kind=ecp&loaddiv=grpdamlist');
	/* loadcontent('grpadmlist', '#myself#c.groups_list&kind=adm&loaddiv=grpadmlist'); */
	// Add DAM group
	$("##grpdamadd").submit(function(e){
		// Get values
		var g = encodeURIComponent($("##damgrpnew").val());
		// Submit Form
		loadcontent('grpdamlist', '#myself#c.groups_add&kind=ecp&loaddiv=grpdamlist&newgrp=' + g);
		return false;
	});
	// Add ADM group
	/*
$("##grpadmadd").submit(function(e){
		// Get values
		var g = encodeURIComponent($("##admgrpnew").val());
		// Submit Form
		loadcontent('grpadmlist', '#myself#c.groups_add&kind=adm&loaddiv=grpadmlist&newgrp=' + g);
		return false;
	});
*/
</script>

</cfoutput>