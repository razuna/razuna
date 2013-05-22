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
<form action="#self#" method="post" name="formimptemp" id="formimptemp">
<input type="hidden" name="#theaction#" value="c.imp_template_save">
<input type="hidden" name="imp_temp_id" value="#attributes.imp_temp_id#">
<!--- Set first field as the key --->
<input type="hidden" name="radio_key" id="radio_1" value="1" />
<!--- Output --->
<div id="tab_imp_temp">
	<ul>
		<li><a href="##tab_imp_temp_all">#myFusebox.getApplicationData().defaults.trans("settings")#</a></li>
		<li><a href="##tab_imp_temp_fields">#myFusebox.getApplicationData().defaults.trans("mapping")#</a></li>
	</ul>
	<!--- Settings --->
	<div id="tab_imp_temp_all">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("settings")#</td>
			</tr>
			<tr>
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("admin_import_templates_active")#</td>
				<td><input type="checkbox" name="imp_active" value="1"<cfif qry_detail.imp.imp_active EQ 1> checked="checked"</cfif>></td>
			</tr>
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("admin_upload_templates_name")#*</td>
				<td><input type="text" name="imp_name" id="imp_name" class="text" value="#qry_detail.imp.imp_name#" style="width:300px;"><label for="imp_name" class="error" style="color:red;"><br>Enter a name for the template!</label></td>
			</tr>
			<tr>
				<td nowrap="nowrap" valign="top">#myFusebox.getApplicationData().defaults.trans("description")#</td>
				<td><textarea name="imp_description" style="width:300px;height:60px;">#qry_detail.imp.imp_description#</textarea></td>
			</tr>
		</table>
	</div>
	<!--- Fields --->
	<div id="tab_imp_temp_fields">
		<div>#myFusebox.getApplicationData().defaults.trans("admin_import_templates_desc")#</div>
		<br />
		<!--- List the mapped fields --->
		<cfloop query="qry_detail.impval">
			<cfset theimpmap = imp_map>
			<div id="input#currentRow#" style="margin-bottom:4px;" class="clonedInput">
		        <input type="text" name="field_#currentRow#" id="field_#currentRow#" style="width:250px;" value="#imp_field#" />
		        <select id="select_#currentRow#" name="select_#currentRow#" style="width:250px;">
		        	<option selected="selected">Map to ...</option>
		        	<option>--- Key fields ---</option>
		        	<cfloop list="#attributes.meta_keys#" index="i" delimiters=","><option value="#i#"<cfif i EQ imp_map> selected="selected"</cfif>>#i#</option></cfloop>
		        	<option>--- Default ---</option>
		        	<cfloop list="#attributes.meta_default#" index="i" delimiters=","><option value="#i#"<cfif i EQ imp_map> selected="selected"</cfif>>#i#</option></cfloop>
		        	<option>--- Custom Fields ---</option>
		        	<cfloop query="attributes.meta_cf">#theimpmap#<option value="#cf_id#"<cfif cf_id EQ theimpmap> selected="selected"</cfif>>#cf_text#</option></cfloop>
		        	<option>--- For Images ---</option>
		        	<cfloop list="#attributes.meta_img#" index="i" delimiters=","><option value="#i#"<cfif i EQ imp_map> selected="selected"</cfif>>#i#</option></cfloop>
		        	<option>--- For Documents (PDF) ---</option>
		        	<cfloop list="#attributes.meta_doc#" index="i" delimiters=","><option value="#i#"<cfif i EQ imp_map> selected="selected"</cfif>>#i#</option></cfloop>
		        </select>
		    </div>
		</cfloop>
		<!--- Add one to the recodcount --->
		<cfif qry_detail.impval.recordcount EQ 0>
		    <div id="input1" style="margin-bottom:4px;" class="clonedInput">
		        <input type="text" name="field_1" id="field_1" style="width:250px;" />
		        <select id="select_1" name="select_1" style="width:250px;">
		        	<option selected="selected">Map to ...</option>
		        	<option>--- Key fields ---</option>
		        	<cfloop list="#attributes.meta_keys#" index="i" delimiters=","><option value="#i#">#i#</option></cfloop>
		        	<option>--- Default ---</option>
		        	<cfloop list="#attributes.meta_default#" index="i" delimiters=","><option value="#i#">#i#</option></cfloop>
		        	<option>--- Custom Fields ---</option>
		        	<cfloop query="attributes.meta_cf"><option value="#cf_id#">#cf_text#</option></cfloop>
		        	<option>--- For Images ---</option>
		        	<cfloop list="#attributes.meta_img#" index="i" delimiters=","><option value="#i#">#i#</option></cfloop>
		        	<option>--- For Documents (PDF) ---</option>
		        	<cfloop list="#attributes.meta_doc#" index="i" delimiters=","><option value="#i#">#i#</option></cfloop>
		        </select>
		    </div>
	    </cfif>
	    <div style="width:50px;height:40px;">
	 		<img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" align="left" id="btnAdd" />
	    	<img src="#dynpath#/global/host/dam/images/list-remove-3.png" width="24" height="24" border="0" align="right" id="btnDel" />
		</div>
	</div>
</div>
<div id="submit" style="float:right;padding:10px;">
	<div id="imptempfeedback" style="color:green;padding:10px;display:none;float:left;font-weight:bold;"></div>
	<input type="submit" name="SubmitUser" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" style="float:right;">
</div>

</form>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	// Initialize Tabs
	jqtabs("tab_imp_temp");
	// Init Chosen
	//$(".chzn-select").chosen({no_results_text: "No results matched"});
	// Fire the form submit for new or update
	$(document).ready(function(){
		$("##formimptemp").validate({
			submitHandler: function(form) {
				jQuery(form).ajaxSubmit({
					success: formimptempfeedback
				});
			},
			rules: {
				imp_name: "required"			   
			 }
		});
	});
	// Feedback when saving form
	function formimptempfeedback() {
		$("##imptempfeedback").css("display","");
		$("##imptempfeedback").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("success"))#");
		$('##admin_imp_templates').load('#myself#c.imp_templates');
	}
	$(document).ready(function() {
		<cfif qry_detail.impval.recordcount EQ 0>
			$('##btnDel').css('display','none');
		</cfif>
		$('##btnAdd').click(function() {
	        var num     = $('.clonedInput').length; // how many "duplicatable" input fields we currently have
	        var newNum  = new Number(num + 1);      // the numeric ID of the new input field being added
			
	        // create the new element via clone(), and manipulate it's ID using newNum value
	        var newElem = $('##input' + num).clone().attr('id', 'input' + newNum);
	
	        // manipulate the name/id values of the input inside the new element
	        newElem.children(':first').attr('id', 'field_' + newNum).attr('name', 'field_' + newNum);
	        newElem.children(':nth-child(2)').attr('id', 'select_' + newNum).attr('name', 'select_' + newNum);
	        /* newElem.children(':nth-child(3)').attr('id', 'radio_' + newNum); */
	      	
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
