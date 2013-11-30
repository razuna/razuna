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
	<div id="container">
		<!--- Search labels --->
		<p>#myFusebox.getApplicationData().defaults.trans("choose_label_content")#</p>
		<div style="width:auto;float:right;">
			<div style="float:left;padding:4px;">
				<div style="float:left;">
					<input name="searchtext" id="searchtext" type="text" class="textbold" style="width:250px;" value="">
				</div>
				<div style="float:left;padding-left:2px;padding-top:1px;">
					<button class="awesome big green" onclick="choose_label();">Search</button>
				</div>
			</div>
		</div>
		
		<!--- Loop over letters as a list. --->
		<div style="clear:both;float:left;padding:5px;text-align:center;width:100%;">
			<cfloop	index="strLetter" list="#valuelist(qry_search_label_index.label_text_index)#" delimiters=",">
				<a herf="##" onclick="loadcontent('show_labels','index.cfm?fa=c.search_label_for_asset&file_id=#attributes.file_id#&file_type=#attributes.file_type#&show=search&strLetter=#strLetter#');" style="padding-right:5px;font-weight:bold;cursor:pointer;">#strLetter#</a>
			</cfloop>
			<p><hr></p>
			<div id="show_labels"></div>
		</div>
	</div>
</cfoutput>
<script language="javascript" type="text/javascript">
	$(document).ready(function(){
		loadcontent('show_labels','<cfoutput>index.cfm?fa=c.search_label_for_asset&file_id=#attributes.file_id#&file_type=#attributes.file_type#&show=default</cfoutput>');
	});
	//Search the label
	function choose_label(){
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// Parse the entry
		var theentry = $('#searchtext').val();
		var thetype = '<cfoutput>#attributes.file_type#</cfoutput>';
		var thefid = '<cfoutput>#attributes.file_id#</cfoutput>';
		var show_view = 'search';
		if (theentry == "" | theentry == "Quick Search") {
			return false;
		}
		else {
			// get the first position
			var p1 = theentry.substr(theentry, 1);
			// Now check
			if (illegalChars.test(p1)) {
				alert('The first character of your search string is an illegal one. Please remove it!');
			}
			else {
				$('#show_labels').load('<cfoutput>#myself#</cfoutput>c.search_label_for_asset', { strLetter: theentry, file_type: thetype, file_id: thefid,show: show_view}, function(){
				});
			}
		return false;
		}
	}
</script>
