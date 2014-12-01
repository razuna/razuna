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
<!--- Define variables --->
<cfparam name="attributes.offset" default="0">
<cfoutput>
	<table border="0" cellpadding="5" cellspacing="5" width="100%">
		<tr>
			<td style="padding-top:10px;">#myFusebox.getApplicationData().defaults.trans("alias_remove")#</td>
		</tr>
		<tr>
			<td align="right" style="padding-top:10px;">
				<cfif attributes.loaddiv contains "search">
						<input type="button" name="trash" value="#myFusebox.getApplicationData().defaults.trans("alias_remove_button")#" onclick="$('##div_forall').load('#myself#c.alias_remove&id=#attributes.id#&kind=<cfif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&iscol=F&offset=#attributes.offset#');replacewinalias();destroywindow(1);" class="button">
				<cfelse>

					<input type="button" name="trash" value="#myFusebox.getApplicationData().defaults.trans("alias_remove_button")#" onclick="loadcontent('#attributes.loaddiv#','#myself#c.alias_remove&id=#attributes.id#&kind=<cfif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&iscol=F&folder_id=#attributes.folder_id#&loaddiv=#attributes.loaddiv#&offset=#attributes.offset#');destroywindow(1);" class="button">
				</cfif>

			</td>
		</tr>
	</table>
	<script type="text/javascript">
		// This is for search results
		function replacewinalias(){
			// Loop over file_ids and remove div
			<cfloop list="#session.file_id#" index="i">
				// Remove the div
				$('div[id*=#i#_alias]').remove();
				// Get the value in hidden field and convert to array
				var theval = $('##searchlistids').val().split(',');
				// Remove the id from hidden input field
				var theids = $.grep(theval, function (theid){
					return theid !== '#i#_alias';
				});
				// Save back to hidden filed as string
				$('##searchlistids').val(theids);
			</cfloop>
			// Deselect all
			CheckAllNot('searchformall');
			// Close Windows
			destroywindow(2);
			destroywindow(1);
			// $('##div_win_trash_record').html('<div style="padding:10px;">The asset(s) have been successfully trashed! The updated search results will appear the next time you search.<br /><br /><input type="button" name="close" value="Close window" onclick="destroywindow(1);" class="button"></div>');
		}
	</script>
</cfoutput>