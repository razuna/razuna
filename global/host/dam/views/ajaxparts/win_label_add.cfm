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
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td>
				<input type="text" name="label_text_edit" id="label_text_edit_#attributes.label_id#" style="width:400px;" value="#qry_label.label_text#">
				<br /><br />
				Nest label under:<br />
				<select name="sublabelofedit" id="sublabelofedit" style="width:240px;">
					<option value="0">Please select a parent...</option>
					<option value="0">---</option>
					<option value="0">Move to root</option>
					<option value="0">---</option>
					<cfloop query="list_labels_dropdown">
						<cfif qry_label.label_id NEQ label_id>
							<option value="#label_id#"<cfif qry_label.label_id_r EQ label_id> selected="selected"</cfif>>#label_path#</option>
						</cfif>
					</cfloop>
				</select>
				<br /><br />
				<input type="button" value="#myFusebox.getApplicationData().defaults.trans("button_update")#" name="savecomment" class="button" onclick="updatelabel();">
			</td>
		</tr>
	</table>
	<div id="label_status_here" style="display:none;"></div>
<script>
// Update Comment
function updatelabel(){
	//check label for first char and letters
	if(!isValidLabel('label_text_edit_#attributes.label_id#')){
		alert('The first character has to be a number or letter!');
		return false;
	}
	// Get value
	var thelab = $("##label_text_edit_#attributes.label_id#").val();
	var theparent = $("##sublabelofedit option:selected").val();
	// Submit
	if (thelab != "") {
		$('##label_status_here').load('#myself#c.admin_labels_update', {label_id: '#attributes.label_id#', label_text: thelab, label_parent: theparent}, function() {
		  // Update chosen list
		  $('.chosen-multiple-select').each(function(){
		   $(this).trigger("liszt:updated");
		  });
		  $('.chosen-select').each(function(){
		   $(this).trigger("liszt:updated");
		  });
		  // Hide Window
		  destroywindow(#attributes.closewin#);
		  // Show labels
		  <cfif structKeyExists(attributes,'file_id')>
		  	loadcontent('show_labels','index.cfm?fa=c.search_label_for_asset&file_id=#attributes.file_id#&file_type=#attributes.file_type#&show=default');
		  </cfif>
			<cfif !structKeyExists(attributes,'file_id')>
				$('##admin_labels').load('#myself#c.admin_labels');
			</cfif>
		});
	}
	else {
		return false;
	}
}
</script>
</cfoutput>