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
		<form name="grpedit" id="grpedit">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#defaultsObj.trans("groups_edit")#</th>
			</tr>
			<tr>
				<td width="100%"><input type="text" size="40" name="grpname" id="grpname" value="#qry_detail.grp_name#" /></td>
				<td width="1%" nowrap="true"><input type="Submit" name="Saveme" value="#defaultsObj.trans("save")#" class="button" /></td>
			</tr>
			<tr>
				<td colspan="2"><div id="grp_feedback" style="color:green;font-weight:bold;"></td>
			</tr>
			</div>
		</table>
		</form>
	</div>
	
	<cfif attributes.kind EQ "ecp">
		<cfset thelist = "grpdamlist">
	<cfelse>
		<cfset thelist = "grpadmlist">
	</cfif>
	<script language="JavaScript" type="text/javascript">
		$("##grpedit").submit(function(e){
		// Get values
		var item = encodeURIComponent($("##grpname").val());
		// Submit Form
		loadcontent('#thelist#', '#myself#c.groups_update&grp_id=#attributes.grp_id#&kind=#attributes.kind#&loaddiv=#thelist#&grpname=' + item);
		// Feedback
		$('##grp_feedback').html('Updated group successfully!');
		return false;
	});
	</script>
	
</cfoutput>
