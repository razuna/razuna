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
<cfparam name="attributes.id" default="">
<cfparam name="attributes.col_id" default="">
<cfparam name="attributes.folder_id" default="">
<cfparam name="attributes.order" default="0">
<cfoutput>
	<table border="0" cellpadding="5" cellspacing="5" width="100%">
		<tr>
			<td style="padding-top:10px;">#myFusebox.getApplicationData().defaults.trans("collection_trash_desc")#</td>
		</tr>
		<tr>
			<td align="right" style="padding-top:10px;"><input type="button" name="trash" value="#myFusebox.getApplicationData().defaults.trans("collection_trash_button")#" onclick="loadcontent('rightside','#myself#c.#attributes.what#_trash&id=#attributes.id#&col_id=#attributes.col_id#&folder_id=#attributes.folder_id#&order=#attributes.order#');destroywindow(1);" class="button"></td>
		</tr>
	</table>
</cfoutput>