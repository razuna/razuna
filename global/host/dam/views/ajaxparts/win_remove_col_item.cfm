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
<cfparam name="attributes.selected" default="false">
<cfoutput>
	<table border="0" cellpadding="5" cellspacing="5" width="100%">
		<tr>
			<td style="padding-top:10px;">#myFusebox.getApplicationData().defaults.trans("collection_remove_desc")#</td>
		</tr>
		<tr>
			<td align="right" style="padding-top:10px;">
				<cfif attributes.selected>
					<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("collection_remove_button")#" onclick="destroywindow(1);$('##rightside').load('#myself#c.collection_explorer_trash&selected=files');" class="button">
				<cfelse>
					<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("collection_remove_button")#" onclick="loadcontent('rightside','#myself#c.#attributes.what#_remove<cfif #attributes.what# EQ "collection_item">&id=#attributes.id#&col_id=#attributes.col_id#&folder_id=#attributes.folder_id#&order=#attributes.order#</cfif>');destroywindow(1);$('##rightside').load('#myself#c.collection_explorer_trash<cfif attributes.loaddiv EQ 'collection'>&trashkind=collections<cfelse>&trashkind=files</cfif>');" class="button">
				</cfif>
			</td>
		</tr>
	</table>
</cfoutput>