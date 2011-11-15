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
<cfparam name="attributes.offset" default="">
<cfparam name="attributes.rowmaxpage" default="">
<cfparam name="attributes.showsubfolders" default="F">
<cfoutput>
	<table border="0" cellpadding="5" cellspacing="5" width="100%">
		<tr>
			<td style="padding-top:10px;"><cfif attributes.many NEQ "T">#defaultsObj.trans("delete_record_desc")#<cfelse>#defaultsObj.trans("delete_record_desc_many")#</cfif></td>
		</tr>
		<tr>
			<td align="right" style="padding-top:10px;"><input type="button" name="remove" value="#defaultsObj.trans("remove")#" onclick="<cfif attributes.what EQ "files" OR attributes.what EQ "images" OR attributes.what EQ "videos" OR attributes.what EQ "audios" OR attributes.what EQ "doc" OR attributes.what EQ "img" OR attributes.what EQ "vid" OR attributes.what EQ "aud" OR attributes.what EQ "all">loadinggif('feedback_delete_<cfif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>');</cfif><cfif attributes.iswin EQ "two">destroywindow(2);<cfelseif attributes.iswin EQ "">destroywindow(2);destroywindow(1);</cfif>loadcontent('<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>','#myself#c.#attributes.what#_remove<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=<cfif attributes.what EQ "groups">ecp<cfelseif attributes.loaddiv EQ "content">all<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&loaddiv=<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>&order=#attributes.order#&offset=#attributes.offset#&rowmaxpage=#attributes.rowmaxpage#&showsubfolders=#attributes.showsubfolders#');" class="button"></td>
		</tr>
	</table>
</cfoutput>
