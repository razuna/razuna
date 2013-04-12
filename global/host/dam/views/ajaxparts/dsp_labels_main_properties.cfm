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
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th>#myFusebox.getApplicationData().defaults.trans("edit")#</th>
		</tr>
		<!--- Edit --->
		<tr>
			<td style="border:0px;">
				<input type="text" name="label_text" id="label_text_update" style="width:200px;" value="#qry_label.label_text#"> <input type="button" value="#myFusebox.getApplicationData().defaults.trans("button_update")#" class="button" onclick="updatelabel();">
				<br /><br />
				Nest label under:<br />
				<select name="sublabelofedit" id="sublabelofedit" style="width:240px;">
					<option value="0">Please select a parent...</option>
					<option value="0">---</option>
					<option value="0">Move to root</option>
					<option value="0">---</option>
					<cfloop query="list_labels_dropdown">
						<cfif qry_label.label_id NEQ label_id AND label_id_r NEQ qry_label.label_id>
							<option value="#label_id#"<cfif qry_label.label_id_r EQ label_id> selected="selected"</cfif>>#label_path#</option>
						</cfif>
					</cfloop>
				</select>
				<br /><br />
				ID: #attributes.label_id#
				<br />
				<div id="label_feedback" style="font-weight:bold;color:green;padding-top:20px;"></div>
			</td>
		</tr>
		<!--- Remove --->
		<tr>
			<td class="list"></td>
		</tr>
		<tr>
			<th>Remove</th>
		</tr>
		<tr>
			<td>Removing this label, will remove the label itself and/or any sub-labels. It will not remove any assets that have been labeled.</td>
		</tr>
		<tr>
			<td><input type="button" value="Remove Label" name="remlabel" class="button" onclick="labrem();" /></td>
		</tr>
	</table>
	<div id="label_dummy" style="display:none;"></div>
	<script type="text/javascript">
		// Update Label
		function updatelabel(){
			// Get value
			var thelab = $("##label_text_update").val();
			var theparent = $("##sublabelofedit option:selected").val();
			// Submit
			if (thelab != "") {
				$('##label_dummy').load('#myself#c.admin_labels_update', {label_id:'#attributes.label_id#', label_text: thelab, label_parent: theparent});
				$('##label_feedback').html('#myFusebox.getApplicationData().defaults.trans("success")#');
				loadcontent('explorer','#myself#c.labels_list');
			}
			else {
				return false;
			}
		}
		// Remove Label
		function labrem(){
			$('##label_dummy').load('#myself#c.labels_remove', {id:'#attributes.label_id#'});
			loadcontent('explorer','#myself#c.labels_list');
		}
	</script>	
</cfoutput>
