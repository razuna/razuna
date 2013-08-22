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
	<!--- Show this when user clicks on empty trash --->
	<cfif attributes.trashall>
		<span style="font-weight:bold;color:green;">#myFusebox.getApplicationData().defaults.trans("empty_trash_all_feedback")#</span>
	<!--- Show this when user clicks on restore all --->
	<cfelseif attributes.restoreall>
		<span style="font-weight:bold;color:green;">#myFusebox.getApplicationData().defaults.trans("Restore_trash_all_feedback")#</span>
	<!--- Show this when remove selected items --->
	<cfelseif attributes.removeselecteditems>
		<span style="font-weight:bold;color:green;">#myFusebox.getApplicationData().defaults.trans("Remove_selected_items_feedback")#</span>
	<!--- Show trash --->
	<cfelse>
		<div id="tabsfolder_tab">
			<cfif attributes.trashkind EQ "folders">
				<cfif arraySum(folder_trash_count['cnt']) MOD session.trash_folder_rowmaxpage EQ 0>
					<cfset session.trash_folder_offset = ceiling(arraySum(folder_trash_count['cnt']) / session.trash_folder_rowmaxpage) - 1>
				</cfif>
			<cfelse>
				<cfif arraySum(file_trash_count['cnt']) MOD session.trash_rowmaxpage EQ 0>
					<cfset session.trash_offset = ceiling(arraySum(file_trash_count['cnt']) / session.trash_rowmaxpage) - 1>
				</cfif> 
			</cfif> 
			<ul>
				<!--- Show the trash asset and folder content--->
				<li><a href="##assets" onclick="loadcontent('assets','#myself#c.trash_assets&trashkind=assets');" rel="prefetch prerender">#myFusebox.getApplicationData().defaults.trans("trash_files")# (#arraySum(file_trash_count['cnt'])#)</a></li>
				<li><a href="##folders" onclick="loadcontent('folders','#myself#c.trash_folder_all&trashkind=folders');" rel="prefetch prerender">#myFusebox.getApplicationData().defaults.trans("trash_folders")# (#arraySum(folder_trash_count['cnt'])#)</a></li>
			</ul>
			<!--- For assets  --->
			<div id="assets"></div>
			<!--- For folders --->
			<div id="folders"></div>
		</div>
			
		<script type="text/javascript">
			jqtabs("tabsfolder_tab");
				<cfif attributes.trashkind EQ "folders">
					$('##folders').load('#myself#c.trash_folder_all&trashkind=folders');
					//$('##tabsfolder_tab').tabs('select','##folders');
					var index = $('##tabsfolder_tab div.ui-tabs-panel').length-1;
					$('##tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
				<cfelse>
					$('##assets').load('#myself#c.trash_assets&trashkind=assets');
				</cfif>
		</script>
	</cfif>
</cfoutput>
