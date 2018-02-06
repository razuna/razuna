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
<form action="#self#" method="post" name="form_upc_template" id="form_upc_template">
<input type="hidden" name="#theaction#" value="c.admin_upc_template_save">
<input type="hidden" name="upc_temp_id" value="#attributes.upc_temp_id#">
<!--- Set first field as the key --->
<input type="hidden" name="radio_key" id="radio_1" value="1" />
<!--- Output --->
<div id="tab_upc_temp">
	<ul>
		<li><a href="##tab_upc_temp_all">#myFusebox.getApplicationData().defaults.trans("settings")#</a></li>
		<li><a href="##tab_upc_temp_fields">#myFusebox.getApplicationData().defaults.trans("mapping")#</a></li>
	</ul>
	<!--- Settings --->
	<div id="tab_upc_temp_all">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("settings")#</td>
			</tr>
			<tr>
				<td nowrap="nowrap">Template active</td>
				<td><input type="checkbox" name="upc_active" value="1"<cfif qry_detail.template.upc_active EQ 1> checked="checked"</cfif>></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_name")#*</td>
				<td><input type="text" name="upc_name" id="upc_name" class="text" value="#qry_detail.template.upc_name#" style="width:300px;"><label for="upc_name" class="error" style="color:red;"><br>Enter a name for the template!</label></td>
			</tr>
			<tr>
				<td nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("description")#</td>
				<td><textarea name="upc_description" style="width:300px;height:60px;">#qry_detail.template.upc_description#</textarea></td>
			</tr>
		</table>
	</div>
	<!--- Fields --->
	<div id="tab_upc_temp_fields">
		<div>Define your extension below which should follow the UPC guidelines. For each set you should add only ONE "Original" and all the others will be "Renditions", e.g. "filename.1.tga" (Original), "filename.2.tga" (Rendition), "filename.3.tga" (Rendition).<br><br>You can define as many extensions as you like per template. Remember that UPC only takes effect on folders that are also labeled as "UPC".</div>
		<cfmodule template="../../modules/clearfix.cfm" padding="20" />
		<!--- List the mapped fields --->
		<cfloop query="qry_detail.template_values">
			<div id="input#currentRow#" style="margin-bottom:4px;" class="clonedInput">
		        <div style="float:left">
		        	<input type="text" name="field_#currentRow#" id="field_#currentRow#" style="width:250px;" value="#upc_field#" />
		        </div>
		        <div style="float:left">
		        	<input type="radio" name="original_#currentRow#" id="original_#currentRow#" value="true"<cfif upc_is_original>checked="checked"</cfif>> Original
		        	<input type="radio" name="original_#currentRow#" id="original_#currentRow#" value="false"<cfif ! upc_is_original>checked="checked"</cfif>> Rendition
		        	<input type="checkbox" name="delete_#currentRow#" id="delete_#currentRow#" value="true"> Delete
		        </div>
		        <cfmodule template="../../modules/clearfix.cfm" padding="0" />
		    </div>
		</cfloop>
		<!--- Add one to the recordcount --->
		<cfif qry_detail.template_values.recordcount EQ 0>
		    <div id="input1" style="margin-bottom:4px;" class="clonedInput">
		        <div style="float:left">
   		        	<input type="text" name="field_1" id="field_1" style="width:250px;" value="" />
   		        </div>
   		        <div style="float:left;padding-top:5px;padding-left:10px;">
   		        	<input type="radio" name="original_1" id="original_1" value="true"> Original
   		        	<input type="radio" name="original_1" id="original_1" value="false" checked="checked"> Rendition
   		        	<input type="checkbox" name="delete_1" id="delete_1" value="true"> Delete
   		        </div>
   		       <cfmodule template="../../modules/clearfix.cfm" padding="0" />
		    </div>
	    </cfif>
	    <div style="width:50px;height:40px;">
	 		<img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" align="left" id="btnAdd" />
	    	<img src="#dynpath#/global/host/dam/images/list-remove-3.png" width="24" height="24" border="0" align="right" id="btnDel" />
		</div>
	</div>
</div>
<div id="submit" style="float:right;padding:10px;">
	<div id="upc_temp_feedback" style="color:green;padding:10px;display:none;float:left;font-weight:bold;"></div>
	<input type="submit" name="submit_upc" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" style="float:right;">
</div>

</form>

<!--- Activate the Tabs --->
<script type="text/javascript">
	// Initialize Tabs
	$("##tab_upc_temp").tabs();
	// Init Chosen
	//$(".chzn-select").chosen({no_results_text: "No results matched"});
	// Fire the form submit for new or update
	$(document).ready(function(){
		$("##form_upc_template").validate({
			submitHandler: function(form) {
				jQuery(form).ajaxSubmit({
					success: formupc_temp_feedback
				});
			},
			rules: {
				upc_name: "required"
			 }
		});
	});
	// Feedback when saving form
	function formupc_temp_feedback() {
		$("##upc_temp_feedback").css("display","");
		$("##upc_temp_feedback").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("success"))#");
		$('##upc').load('#myself#c.admin_upc');
	}
	$(document).ready(function() {
		<cfif qry_detail.template_values.recordcount EQ 0>
			$('##btnDel').css('display','none');
		</cfif>
		$('##btnAdd').click(function() {
	        var num     = $('.clonedInput').length; // how many "duplicatable" input fields we currently have
	        var newNum  = new Number(num + 1);      // the numeric ID of the new input field being added

	        // create the new element via clone(), and manipulate it's ID using newNum value
	        var newElem = $('##input' + num).clone().attr('id', 'input' + newNum);
	        // console.log('newElem', newElem);
	        // manipulate the name/id values of the input inside the new element
	        newElem.children(':first').children(':first').attr('id', 'field_' + newNum).attr('name', 'field_' + newNum);
	        newElem.children(':nth-child(2)').children(':first').attr('id', 'original_' + newNum).attr('name', 'original_' + newNum);
	        newElem.children(':nth-child(2)').children(':nth-child(2)').attr('id', 'original_' + newNum).attr('name', 'original_' + newNum);
	        newElem.children(':nth-child(2)').children(':nth-child(2)').prop('checked', 'checked');
	        newElem.children(':nth-child(2)').children(':nth-child(3)').attr('id', 'delete_' + newNum).attr('name', 'delete_' + newNum);

	        // Add the fields to the page
	        $('##input' + num).after(newElem)

	        // enable the "remove" button
	        $('##btnDel').css('display','');

			// Add the new num as the new radio value
	       /*  $('##radio_' + newNum).val(newNum); */
	         // Reset the values for the new field set
	        $('##field_' + newNum).val('');
	        $('##select_' + newNum).val($('option:first', this).val());
	        /* $('##radio_' + newNum).prop('checked',false); */

	        // business rule: you can only add 5 names
	        /*
	        	if (newNum == 5)
	            $('##btnAdd').attr('disabled','disabled');
	    	*/
	    });

	    $('##btnDel').click(function() {
	        var num = $('.clonedInput').length; // how many "duplicatable" input fields we currently have
	        $('##input' + num).remove();     // remove the last element

	        // enable the "add" button
	        $('##btnAdd').attr('disabled',false);

	        // if only one element remains, disable the "remove" button
	        if (num-1 == 1)
	            $('##btnDel').css('display','none');
	    });

	});
</script>
</cfoutput>
