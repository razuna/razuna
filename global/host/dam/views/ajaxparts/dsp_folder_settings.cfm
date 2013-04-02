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
	<div id="tabfoldersettings">
		<ul>
			<li><a href="##properties" onclick="$('##properties').load('#myself#c.folder_edit&folder_id=#attributes.folder_id#&theid=#attributes.folder_id#');savefolderforms();" rel="prefetch"><cfif attributes.iscol EQ "f">#myFusebox.getApplicationData().defaults.trans("folder_properties")#<cfelse>Collection Settings</cfif></a></li>
			<cfif attributes.iscol EQ "F">
				<!--- Sharing --->
				<li><a href="##sharing" onclick="$('##sharing').load('#myself#c.folder_sharing&folder_id=#attributes.folder_id#&theid=#attributes.folder_id#');savefolderforms();" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("tab_sharing_options")#</a></li>
				<!--- Widgets --->
				<li><a href="##widgets" onclick="$('##widgets').load('#myself#c.widgets&col_id=&folder_id=#attributes.folder_id#');savefolderforms();" rel="prefetch">#myFusebox.getApplicationData().defaults.trans("header_widget")#</a></li>
				<!--- Thumbnail --->
				<li><a href="##thumbnail" >#myFusebox.getApplicationData().defaults.trans("header_thumbnail")#</a></li>
			</cfif>
		</ul>
		<!--- Properties --->
		<div id="properties">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<cfif attributes.iscol EQ "F">
			<!--- Sharing --->
			<div id="sharing">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
			<div id="widgets">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
			
			<div id="thumbnail">
				<div><strong>#myFusebox.getApplicationData().defaults.trans("header_thumbnail")#</strong></div>
				<div id="folderThumbload"></div>
				<div>
					<a href="##" id="refresh" onclick="loadcontent('folderThumbload','#myself#ajax.prefs_floderThumb&folder_id=#attributes.folder_id#');return false;">Refresh</a>
				</div>
				
				<iframe src="#myself#c.folder_thumbnail&folder_id=#attributes.folder_id#" frameborder="false" scrolling="false" style="border:0px;width:100%;height:300px;overflow:hidden;"></iframe>
			
			</div>
		</cfif>
	</div>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		// Set tabs
		jqtabs("tabfoldersettings");
		// Load folder properties
		$('##properties').load('#myself#c.folder_edit&folder_id=#attributes.folder_id#&theid=#attributes.folder_id#');
		
		// Save form in the folder edit window
		<cfif attributes.iscol EQ "F">
			function savefolderforms(){
				foldersubmit('#attributes.folder_id#','T','F',true);
				savesharing('#attributes.folder_id#','F');
			}
		</cfif>
	</script>	
</cfoutput>
	
