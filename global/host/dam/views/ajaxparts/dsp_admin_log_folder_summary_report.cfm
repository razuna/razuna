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
	<!--- Set content type as excel ---> 
	<cfcontent type="application/vnd.ms-excel">
	<cfheader name="Content-Disposition" value="filename=Folder_Summary_Report.xls"> 

	<table border="1" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<th>Folder</th><th>Audios</th><th>Excel</th><th>Images</th><th>Other</th><th>PDF</th><th>Videos</th><th>Word</th>
		<cfloop query ="folders">
			<!--- Get asset totals for folder that is sorted so we can display it properly --->
			<cfif session.getallassets>
				<cfset totals = myFusebox.getApplicationData().folders.GetTotalAllAssets(folder_id)>
			<cfelse>
				<cfset totals = myFusebox.getApplicationData().folders.filetotalalltypes(folder_id,'','scr')>
			</cfif>
			<tr>
				<td>
					 <!--- Get entire folder path --->
					<cfset folderpath = "">
					<cfset crumbs = myFusebox.getApplicationData().folders.getbreadcrumb(folder_id)>
					<cfloop list="#crumbs#" delimiters=";" index="i">
						<cfset folderpath = folderpath & "/#ListGetAt(i,1,'|')#">
						<cfif ListGetAt(i,1,'|') EQ 'My Folder'>
							<cfset folderpath = folderpath & " (#username#)">
						</cfif>
					</cfloop>
					#folderpath#
				</td>
				<cfloop query="totals">
					<td>#totals.cnt#</td>
				</cfloop>
			</tr>
		</cfloop>
	</table>
</cfoutput>