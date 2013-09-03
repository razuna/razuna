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
	<!--- Show this when user remove selected items --->
	<cfelseif attributes.removeselecteditems>
		<span style="font-weight:bold;color:green;">#myFusebox.getApplicationData().defaults.trans("Remove_selected_items_feedback")#</span>	
	<!--- Show trash --->
	<cfelse>
		<div id="tabsfolder_tab">
			<cfif attributes.trashkind EQ "folders">
				<cfif arraySum(qry_folder_count['cnt']) MOD session.col_trash_folder_rowmaxpage EQ 0>
					<cfset session.col_trash_folder_offset = ceiling(arraySum(qry_folder_count['cnt']) / session.col_trash_folder_rowmaxpage) - 1>
				</cfif>
			<cfelseif attributes.trashkind EQ "files">
				<cfif arraySum(qry_file_count['cnt']) MOD session.col_trash_rowmaxpage EQ 0>
					<cfset session.col_trash_offset = ceiling(arraySum(qry_file_count['cnt']) / session.col_trash_rowmaxpage) - 1>
				</cfif>
			<cfelse>
				<cfif arraySum(col_count_trash['cnt']) MOD session.trash_collection_rowmaxpage EQ 0>
					<cfset session.trash_collection_offset = ceiling(arraySum(col_count_trash['cnt']) / session.trash_collection_rowmaxpage) - 1>
				</cfif> 
			</cfif> 
			<ul>
				<!--- Show the collection files in the trash --->
				<li><a href="##files" onclick="loadcontent('files','#myself#c.get_collection_trash_files&trashkind=files');" rel="prefetch prerender">#myFusebox.getApplicationData().defaults.trans("trash_files")# (#arraySum(qry_file_count['cnt'])#)</a></li>
				<!--- Show the collection folders in the trash --->
				<li><a href="##folders" onclick="loadcontent('folders','#myself#c.get_collection_trash_folders&trashkind=folders');" rel="prefetch prerender">#myFusebox.getApplicationData().defaults.trans("trash_folders")# (#arraySum(qry_folder_count['cnt'])#)</a></li>
				<!--- Show the collection in the trash --->
				<li><a href="##collections" onclick="loadcontent('collections','#myself#c.col_get_trash&trashkind=collections');" rel="prefetch prerender">#myFusebox.getApplicationData().defaults.trans("trash_collections")# (#arraySum(col_count_trash['cnt'])#)</a></li>
			</ul>
			<!--- for files --->
			<div id="files"></div>
			<!--- for folders --->
			<div id="folders"></div>
			<!--- for collection --->
			<div id="collections"></div>
		</div>
		<script type="text/javascript">
           jqtabs("tabsfolder_tab");
           <cfif attributes.trashkind EQ 'collections'>
               $('##collections').load('#myself#c.col_get_trash&trashkind=collections');
               //$('##tabsfolder_tab').tabs('select','##collections');
			    var index = $('##tabsfolder_tab div.ui-tabs-panel').length-1;
				$('##tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
           <cfelseif attributes.trashkind EQ 'folders'>
		   		$('##folders').load('#myself#c.get_collection_trash_folders&trashkind=folders');
               //loadcontent('folders','#myself#c.get_collection_trash_folders&trashkind=folders');
               //$('##tabsfolder_tab').tabs('select','##folders');
			    var index = $('##tabsfolder_tab div.ui-tabs-panel').length-2;
				$('##tabsfolder_tab').tabs({ active: index }).tabs( "refresh" );
           <cfelse>
               $('##files').load('#myself#c.get_collection_trash_files&trashkind=files');
           </cfif>
       </script>
	</cfif>
</cfoutput>
