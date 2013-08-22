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
<cfparam name="attributes.file_id_r" default="0">
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
<cfparam name="attributes.in_collection" default="false">
<cfparam name="attributes.fromtrash" default="false">
<cfparam name="attributes.selected" default="false">
<cfoutput>
	<div id="div_win_remove_record">
		<table border="0" cellpadding="5" cellspacing="5" width="100%">
			<tr>
			<cfif attributes.in_collection>
				<td style="padding-top:10px;"><cfif attributes.many NEQ "T">#myFusebox.getApplicationData().defaults.trans("alert_record_desc")#<cfelse>#myFusebox.getApplicationData().defaults.trans("delete_record_desc_many")#</cfif></td>
			<cfelse>
				<td style="padding-top:10px;"><cfif attributes.many NEQ "T">#myFusebox.getApplicationData().defaults.trans("delete_record_desc")#<cfelse>#myFusebox.getApplicationData().defaults.trans("delete_record_desc_many")#</cfif></td>
			</cfif>
			</tr>
			<tr>
				<td align="right" style="padding-top:10px;">
					<cfif attributes.loaddiv CONTAINS "content_search_" OR attributes.loaddiv EQ "search">
						<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("remove")#" onclick="$('##div_forall').load('#myself#c.#attributes.what#_remove<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=all&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&order=#attributes.order#&showsubfolders=#attributes.showsubfolders#&loaddiv=&iscol=#attributes.iscol#');replacewin();" class="button">
					<cfelse>
						<cfif attributes.in_collection>
							<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("yes")#" onclick="<cfif attributes.iswin EQ "two">destroywindow(2);<cfelseif attributes.iswin EQ "">destroywindow(2);destroywindow(1);</cfif>loadcontent('<cfif attributes.loaddiv EQ "all">rightside<cfelse>#attributes.loaddiv#</cfif>','#myself#c.#attributes.what#_remove<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=<cfif attributes.what EQ "groups">ecp<cfelseif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&loaddiv=<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>&order=#attributes.order#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#&released=#attributes.released#&view=#attributes.view#');$('##rightside').load('#myself#c.<cfif loaddiv EQ "assets">folder_explorer_trash&trashkind=assets<cfelse>collection_explorer_trash&trashkind=files</cfif>');" class="button">
							<input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("no")#" onclick="destroywindow(2);destroywindow(1);" class="button">
						<cfelse>
							<cfif attributes.selected>
								<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("remove")#" onclick="destroywindow(1);$('##rightside').load('#myself#c.<cfif attributes.loaddiv EQ "collection">collection_explorer_trash&selected=collection<cfelse>folder_explorer_trash&selected=assets</cfif>');" class="button">
							<cfelse>
								<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("remove")#" onclick="<cfif attributes.iswin EQ "two">destroywindow(2);<cfelseif attributes.iswin EQ "">destroywindow(2);destroywindow(1);</cfif>loadcontent('<cfif attributes.loaddiv EQ "all">rightside<cfelse>#attributes.loaddiv#</cfif>','#myself#c.#attributes.what#_remove<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=<cfif attributes.what EQ "groups">ecp<cfelseif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&loaddiv=<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>&order=#attributes.order#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#&released=#attributes.released#&view=#attributes.view#');<cfif attributes.fromtrash>$('##rightside').load('#myself#c.<cfif attributes.loaddiv EQ 'collections'>collection_explorer_trash&trashkind=collections<cfelse>folder_explorer_trash&trashkind=assets</cfif>');</cfif>" class="button">
							</cfif>
						</cfif>
					</cfif>
				</td>
			</tr>
		</table>
	</div>
	<script type="text/javascript">
		function replacewin(){
			$('##div_win_remove_record').html('<div style="padding:10px;">The asset(s) have been successfully removed! The updated search results will appear the next time you search.<br /><br /><input type="button" name="close" value="Close window" onclick="destroywindow(1);" class="button"></div>');
		}
	</script>
</cfoutput>
