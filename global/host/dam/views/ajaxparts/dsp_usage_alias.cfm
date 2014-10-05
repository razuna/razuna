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
	<p>
		#myFusebox.getApplicationData().defaults.trans("alias_usage_desc")#
	</p>
	<div id="remove_alias_detail" style="display:none;font-weight:bold;color:green;">
		<p>
			#myFusebox.getApplicationData().defaults.trans("alias_remove_success")#
		</p>
	</div>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<!--- Loop over all scheduled log entries in database table --->
		<cfloop query="qry_alias">
			<tr class="list">
				<td nowrap="true" valign="top"><a href="##" onclick="loadcontent('rightside','#myself#c.folder&col=F&folder_id=#folder_id_r#');destroywindow(1);"><strong>#folder_name#</strong></a></td>
				<td nowrap="true" align="center" valign="top"><a href="##" onclick="removeAlias('#attributes.id#','#folder_id_r#')">#myFusebox.getApplicationData().defaults.trans("alias_remove_button")#</a></td>
			</tr>
		</cfloop>
	</table>
</cfoutput>

<script type="text/javascript">
	function removeAlias(asset_id, folder_id) {
		// Do the show and hide
		$('#remove_alias_detail').fadeTo("fast", 100);
		$('#remove_alias_detail').css('display','');
		$('#remove_alias_detail').fadeTo(5000, 0, function() {
			$('#remove_alias_detail').css('display','none');
		});
		// Call function to remove alias
		loadcontent('div_forall','index.cfm?fa=c.alias_remove&loaddiv=null&id=' + asset_id + '&folder_id=' + folder_id );
	};
</script>