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
<cfoutput>
	<div id="div_win_restore_record">
		<table border="0" cellpadding="5" cellspacing="5" width="100%">
			<tr>
				<td style="padding-top:10px;"><cfif attributes.many NEQ "T">#myFusebox.getApplicationData().defaults.trans("restore_record_desc")#<cfelse>#myFusebox.getApplicationData().defaults.trans("restore_record_desc_many")#</cfif></td>
			</tr>
			<tr>
				<td align="right" style="padding-top:10px;">
					<input type="button" name="restore" value="#myFusebox.getApplicationData().defaults.trans("restore")#" onclick="destroywindow(1);$('##<cfif attributes.loaddiv EQ "all">rightside<cfelse>#attributes.loaddiv#</cfif>').load('#myself#c.#attributes.what#_restore<cfif attributes.many EQ "T">_many</cfif>&id=#attributes.id#&kind=<cfif attributes.what EQ "groups">ecp<cfelseif attributes.loaddiv EQ "content">all<cfelseif attributes.kind EQ "folder">folder<cfelse>#attributes.loaddiv#</cfif>&folder_id=#attributes.folder_id#&col_id=#attributes.col_id#&file_id=#attributes.file_id#&type=#attributes.type#&loaddiv=<cfif attributes.loaddiv EQ "all">content<cfelse>#attributes.loaddiv#</cfif>&iscol=#attributes.iscol#<cfif attributes.kind EQ "folder">&folder_level=#attributes.folder_level#</cfif>&fromtrash=true');loadtrashdelay();" class="button">
				</td>
			</tr>
		</table>
	</div>
	<!--- JS --->
	<script type="text/javascript">
		function loadtrashdelay(){
			try {
				setTimeout(function() {
			    	delayfolderload();
				}, 2000)
			}
			catch(e) {};
		};
		function delayfolderload(){
			$('##rightside').load('#myself#c.folder_explorer_trash&trashkind=assets');
		};
	</script>
</cfoutput>