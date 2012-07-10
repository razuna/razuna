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
	<div id="labels_tab">
		<ul>	
			<li><a href="##lab_content" onclick="loadcontent('lab_content','#myself#c.labels_main_assets&label_id=#attributes.label_id#&label_kind=assets');">#myFusebox.getApplicationData().defaults.trans("labels_content")# (#qry_labels_count.count_assets#)</a></li>
			<li><a href="##lab_folders" onclick="loadcontent('lab_folders','#myself#c.labels_main_folders&label_id=#attributes.label_id#&label_kind=folders');">#myFusebox.getApplicationData().defaults.trans("log_header_folders")# (#qry_labels_count.count_folders#)</a></li>
			<li><a href="##lab_collections" onclick="loadcontent('lab_collections','#myself#c.labels_main_collections&label_id=#attributes.label_id#&label_kind=collections');">#myFusebox.getApplicationData().defaults.trans("header_collections")# (#qry_labels_count.count_collections#)</a></li>
			<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
				<li><a href="##lab_prop" onclick="loadcontent('lab_prop','#myself#c.labels_main_properties&label_id=#attributes.label_id#');">Label #myFusebox.getApplicationData().defaults.trans("settings")#</a></li>
			</cfif>
		</ul>
		<!--- The divs loading the content		 --->
		<div id="lab_content">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<div id="lab_folders">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<div id="lab_collections">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div>
		<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()><div id="lab_prop">#myFusebox.getApplicationData().defaults.loadinggif("#dynpath#")#</div></cfif>
	</div>

	<script type="text/javascript">
		// The tabs
		jqtabs("labels_tab");
		// Initial load
		loadcontent('lab_content','#myself#c.labels_main_assets&label_id=#attributes.label_id#&label_kind=assets');
	</script>

</cfoutput>
	
