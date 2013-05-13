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
<cfparam name="attributes.order" default=	"">
<cfparam name="attributes.many" default="F">
<cfparam name="attributes.file_id" default="0">
<cfparam name="attributes.col_id" default="0">
<cfparam name="attributes.type" default="">
<cfparam name="attributes.rowmaxpage" default="">
<cfparam name="attributes.showsubfolders" default="F">
<cfparam name="attributes.iscol" default="F">
<cfparam name="attributes.released" default="false">
<cfparam name="attributes.view" default="">
<cfoutput>
		<table border="0" cellpadding="5" cellspacing="5" width="100%">
			<tr>
				<cfif attributes.in_collection>
					<td style="padding-top:10px;">#myFusebox.getApplicationData().defaults.trans("alert_folder_desc")#</td>
				<cfelse>
					<td style="padding-top:10px;">#myFusebox.getApplicationData().defaults.trans("remove_folder_desc")#</td>
				</cfif>
			</tr>
			<tr>
				<td align="right" style="padding-top:10px;">
				<cfif attributes.in_collection>
					<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("yes")#" onclick="<cfif attributes.iswin EQ "two">destroywindow(2);<cfelseif attributes.iswin EQ "">destroywindow(2);destroywindow(1);</cfif>loadcontent('<cfif attributes.loaddiv EQ "all">rightside<cfelse>#attributes.loaddiv#</cfif>','#myself#c.#attributes.what#_remove<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=<cfif attributes.what EQ "groups">ecp<cfelseif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&loaddiv=<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>&order=#attributes.order#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#&released=#attributes.released#&view=#attributes.view#');" class="button">
					<input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("no")#" onclick="destroywindow(2);destroywindow(1);" class="button">
				<cfelse>
					<input type="button" name="remove" value="#myFusebox.getApplicationData().defaults.trans("remove_folder")#" onclick="<cfif attributes.iswin EQ "two">destroywindow(2);<cfelseif attributes.iswin EQ "">destroywindow(2);destroywindow(1);</cfif>loadcontent('<cfif attributes.loaddiv EQ "all">rightside<cfelse>#attributes.loaddiv#</cfif>','#myself#c.#attributes.what#_remove<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=<cfif attributes.what EQ "groups">ecp<cfelseif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&loaddiv=<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>&order=#attributes.order#&showsubfolders=#attributes.showsubfolders#&iscol=#attributes.iscol#&released=#attributes.released#&view=#attributes.view#');" class="button">
				</cfif>	
				</td>
			</tr>
		</table>
</cfoutput>