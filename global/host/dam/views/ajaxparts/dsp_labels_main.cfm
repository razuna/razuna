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
			<li><a href="##lab_content" onclick="loadcontent('lab_content','#myself#c.labels_main_assets&label_id=#attributes.label_id#&label_kind=assets');">#defaultsObj.trans("labels_content")# (#qry_labels_count.count_assets#)</a></li>
			<li><a href="##lab_folders" onclick="loadcontent('lab_folders','#myself#c.labels_main_folders&label_id=#attributes.label_id#&label_kind=folders');">#defaultsObj.trans("log_header_folders")# (#qry_labels_count.count_folders#)</a></li>
			<li><a href="##lab_collections" onclick="loadcontent('lab_collections','#myself#c.labels_main_collections&label_id=#attributes.label_id#&label_kind=collections');">#defaultsObj.trans("header_collections")# (#qry_labels_count.count_collections#)</a></li>
<!--- 			<li><a href="##lab_comments" onclick="loadcontent('lab_comments','#myself#c.labels_main_comments&label_id=#attributes.label_id#&label_kind=comments');">#defaultsObj.trans("comments")# (#qry_labels_count.count_comments#)</a></li> --->
		</ul>
		<!--- The divs loading the content		 --->
		<div id="lab_content">#defaultsObj.loadinggif("#dynpath#")#</div>
		<div id="lab_folders">#defaultsObj.loadinggif("#dynpath#")#</div>
		<div id="lab_collections">#defaultsObj.loadinggif("#dynpath#")#</div>
<!--- 		<div id="lab_comments">#defaultsObj.loadinggif("#dynpath#")#</div> --->
	</div>

	<script type="text/javascript">
		// The tabs
		jqtabs("labels_tab");
		// Initial load
		loadcontent('lab_content','#myself#c.labels_main_assets&label_id=#attributes.label_id#&label_kind=assets');
	</script>

</cfoutput>
	
