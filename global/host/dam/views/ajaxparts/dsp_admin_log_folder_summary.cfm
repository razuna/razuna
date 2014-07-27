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
	<div style="float:right">
		<a href="#myself#c.log_folder_summary_report&folder_id=0" target="_blank"><img src="#dynpath#/global/host/dam/images/folder-download.png" border="0" width="16" style="vertical-align:middle;"/></a> <a href="#myself#c.log_folder_summary_report&folder_id=0" target="_blank">Download full report for all folders</a>
	</div>
	<br/><br/>
	Count of assets in Folders. Only assets present in the folder are counted. Assets in subfolders are not included in count. Click on a folder to get count of assets in its subfolders.
	<br/><br/>

	<cfif isDefined("showcrumbs")>
		<!--- Get entire folder path --->
		<cfset folderpath = "">
		<cfset crumbs = myFusebox.getApplicationData().folders.getbreadcrumb(folder_id)>
		<cfloop list="#crumbs#" delimiters=";" index="i">
			<cfset folderpath = folderpath & " / <a href='##' onclick=loadcontent('log_show','#myself#c.log_folder_summary&folder_id=#ListGetAt(i,2,'|')#&showcrumbs=yes');>#ListGetAt(i,1,'|')#</a>">
		</cfloop>
		<a href="##" onclick="loadcontent('log_show','/raz1/dam/index.cfm?fa=c.log_folder_summary&folder_id=0');">Home</a> #folderpath#
	</cfif>

	<table border="1" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<th>Folder</th><th>Audios</th><th>Excel</th><th>Images</th><th>Other</th><th>PDF</th><th>Videos</th><th>Word</th>
		<cfloop query ="folders">
			<!--- Get asset totals for folder that is sorted so we can display it properly --->
			<cfset totals = myFusebox.getApplicationData().folders.filetotalalltypes(folder_id,'','scr')>
			<tr>
				<td>
					<cfif sf_cnt GT 0><a href="##" onclick="loadcontent('log_show','#myself#c.log_folder_summary&folder_id=#folder_id#&showcrumbs=yes');"></cfif>
						#folder_name#<cfif folder_name EQ 'My Folder'> (#user#)</cfif>
					<cfif sf_cnt GT 0></a></cfif>
				</td>
				<cfloop query="totals">
					<td>#totals.cnt#</td>
				</cfloop>
			</tr>
		</cfloop>
	</table>
</cfoutput>