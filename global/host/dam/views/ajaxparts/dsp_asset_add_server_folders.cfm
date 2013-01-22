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
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
	<tr>
		<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_serverfolders")#</th>
	</tr>
	<cfif attributes.folderpath NEQ thispath>
		<cfset thef = listlast("#attributes.folderpath#","/\")>
		<cfset backpath = replacenocase("#attributes.folderpath#","/#thef#","","ALL")>
		<tr>
			<td colspan="2"><a href="##" onclick="loadcontent('browse','#myself##xfa.serverfolders#&folder_id=#attributes.folder_id#&folderpath=#urlencodedformat(backpath)#');return false;">#myFusebox.getApplicationData().defaults.trans("back")#</a></td>
		</tr>
	</cfif>
	<cfloop query="qry_filefolders">
		<!--- Bad code habit. Move this into recursive or better function some day --->
		<cfdirectory action="list" directory="#thispath#/#name#" name="thedirs" sort="name ASC">
		<cfquery name="subf" dbtype="query">SELECT * FROM thedirs WHERE type = 'Dir' AND attributes != 'H' AND name NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value=".svn,.DS_Store,bluedragon,global,incoming,web-inf,.git,backup">)</cfquery>
		<tr>
			<td width="1%" nowrap="true" class="td2"><cfif subf.recordcount NEQ 0><a href="##" onclick="loadcontent('browse','#myself##xfa.serverfolders#&folder_id=#attributes.folder_id#&folderpath=#urlencodedformat(directory)#/#urlencodedformat(name)#');return false;"><img src="#dynpath#/global/host/dam/images/folder_open.png" width="16" height="16" border="0"></a><cfelse><img src="#dynpath#/global/host/dam/images/folder.png" width="16" height="16" border="0"></cfif></td>
			<td width="100%" class="td2" style="padding-left:0px;"><a href="##" onclick="loadcontent('serverfoldercontent','#myself##xfa.servercontent#&folder_id=#attributes.folder_id#&folderpath=#urlencodedformat(directory)#/#urlencodedformat(name)#');return false;">#name#</a></td>
		</tr>
	</cfloop>
	<tr>
		<td colspan="2">#myFusebox.getApplicationData().defaults.trans("header_serverfolders_desc")#</td>
	</tr>
	<tr>
		<td colspan="2"><a href="##" onclick="destroywindow(2);return false;">#myFusebox.getApplicationData().defaults.trans("scheduler_close_cap")#</a></td>
	</tr>
</table>
</cfoutput>

