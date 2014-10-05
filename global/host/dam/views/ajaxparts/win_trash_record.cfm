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
<cfparam name="attributes.id" default="0">
<cfparam name="attributes.folder_id" default="0">
<cfparam name="attributes.iswin" default="">
<cfparam name="attributes.order" default="">
<cfparam name="attributes.many" default="F">
<cfparam name="attributes.file_id" default="0">
<cfparam name="attributes.col_id" default="0">
<cfparam name="attributes.type" default="">
<cfparam name="attributes.rowmaxpage" default="">
<cfparam name="attributes.showsubfolders" default="F">
<cfparam name="attributes.iscol" default="F">
<cfparam name="attributes.released" default="false">
<cfparam name="attributes.view" default="">
<cfparam name="attributes.label_id" default="">
<cfoutput>
	<div id="div_win_trash_record">
		<table border="0" cellpadding="5" cellspacing="5" width="100%">
			<tr>
				<td style="padding-top:10px;"><cfif attributes.many NEQ "T">#myFusebox.getApplicationData().defaults.trans("trash_record_desc")#<cfelse>#myFusebox.getApplicationData().defaults.trans("trash_record_desc_many")#</cfif></td>
			</tr>
			<tr>
				<td align="right" style="padding-top:10px;">
					<cfif attributes.loaddiv CONTAINS "content_search_" OR attributes.loaddiv EQ "search" OR attributes.loaddiv EQ "labels">
						<input type="button" name="trash" value="#myFusebox.getApplicationData().defaults.trans("trash")#" onclick="$('##div_forall').load('#myself#c.#attributes.what#_trash<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=all&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&label_id=#attributes.label_id#&order=#attributes.order#&showsubfolders=#attributes.showsubfolders#&loaddiv=&iscol=#attributes.iscol#');<cfif attributes.loaddiv EQ "search">replacewin();<cfelse>replacewinlabels();</cfif>" class="button">
					<cfelse>
						<input type="button" name="trash" value="#myFusebox.getApplicationData().defaults.trans("trash")#" onclick="<cfif attributes.iswin EQ "two">destroywindow(2);<cfelseif attributes.iswin EQ "">destroywindow(2);destroywindow(1);</cfif>loadcontent('<cfif attributes.loaddiv EQ "all">rightside<cfelse>#attributes.loaddiv#</cfif>','#myself#c.#attributes.what#_trash<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=<cfif attributes.what EQ "groups">ecp<cfelseif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&loaddiv=<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>&order=#attributes.order#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#&released=#attributes.released#&view=#attributes.view#');" class="button">
					</cfif>
				</td>
			</tr>
		</table>
	</div>
	<script type="text/javascript">
		// This is for search results
		function replacewin(){
			// Loop over file_ids and remove div
			<cfloop list="#session.file_id#" index="i">
				// Remove the div
				$('###i#').remove();
				// Get the value in hidden field and convert to array
				var theval = $('##searchlistids').val().split(',');
				// Remove the id from hidden input field
				var theids = $.grep(theval, function (theid){
					return theid !== '#i#';
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
		// This is when coming from labels
		function replacewinlabels(){
			// Loop over file_ids and remove div
			<cfloop list="#session.file_id#" index="i">
				// Remove the div
				$('###i#').remove();
				// Get the value in hidden field and convert to array
				var theval = $('##searchlistids').val().split(',');
				// Remove the id from hidden input field
				var theids = $.grep(theval, function (theid){
					return theid !== '#i#';
				});
				// Save back to hidden filed as string
				$('##searchlistids').val(theids);
			</cfloop>
			// Deselect all
			CheckAllNot('label_form');
			// Close Windows
			destroywindow(2);
			destroywindow(1);
		}
	</script>
</cfoutput>
