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
	<form action="#self#" method="post" name="form_s3" id="form_s3">
	<input type="hidden" name="#theaction#" value="c.admin_integration_s3_save">
		<!--- How many recordcounts --->
		<cfset countuntil = qry_s3.recordcount / 4>
		<!--- Show --->
		<cfloop from="1" to="#countuntil#" index="counter">
			<cfset counter = counter>
			<div id="input#counter#" style="margin-bottom:4px;" class="clonedInputsf">
				<input type="text" name="aws_access_key_id_#counter#" id="aws_access_key_id_#counter#" value="<cfloop query="qry_s3"><cfif set_id EQ "aws_access_key_id_#counter#">#set_pref#</cfif></cfloop>" style="width:180px;" placeholder="Access Key ID">
				<input type="text" name="aws_secret_access_key_#counter#" id="aws_secret_access_key_#counter#" value="<cfloop query="qry_s3"><cfif set_id EQ "aws_secret_access_key_#counter#">#set_pref#</cfif></cfloop>" style="width:290px;" placeholder="Secret Access Key">
				<input type="text" name="aws_bucket_name_#counter#" id="aws_bucket_name_#counter#" value="<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_name_#counter#">#set_pref#</cfif></cfloop>" style="width:150px;" placeholder="Bucket Name">
				<select name="aws_bucket_location_#counter#" id="aws_bucket_location_#counter#" style="width:200px;">
					<option value="us-east"<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_location_#counter#" AND set_pref EQ "us-east"> selected="selected"</cfif></cfloop>>US Standard</option>
					<option value="us-west-2"<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_location_#counter#" AND set_pref EQ "us-west-2"> selected="selected"</cfif></cfloop>>US West (Oregon)</option>
					<option value="us-west-1"<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_location_#counter#" AND set_pref EQ "us-west-1"> selected="selected"</cfif></cfloop>>US West (Northern California)</option>
					<option value="EU"<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_location_#counter#" AND set_pref EQ "eu"> selected="selected"</cfif></cfloop>>EU (Ireland)</option>
					<option value="ap-southeast-1"<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_location_#counter#" AND set_pref EQ "ap-southeast-1"> selected="selected"</cfif></cfloop>>Asia Pacific (Singapore)</option>
					<option value="ap-northeast-1"<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_location_#counter#" AND set_pref EQ "ap-northeast-1"> selected="selected"</cfif></cfloop>>Asia Pacific (Tokyo)</option>
					<option value="sa-east-1"<cfloop query="qry_s3"><cfif set_id EQ "aws_bucket_location_#counter#" AND set_pref EQ "sa-east-1"> selected="selected"</cfif></cfloop>>South America (Sao Paulo)</option>
				</select>
			</div>
		</cfloop>
		<!--- Add one to the recordcount --->
		<cfif qry_s3.recordcount EQ 0>
		    <div id="input1" style="margin-bottom:4px;" class="clonedInputsf">
		    	<input type="text" name="aws_access_key_id_1" id="aws_access_key_id_1" value="" style="width:180px;" placeholder="Access Key ID">
		    	<input type="text" name="aws_secret_access_key_1" id="aws_secret_access_key" value="" style="width:290px;" placeholder="Secret Access Key">
		    	<input type="text" name="aws_bucket_name_1" id="aws_bucket_name_1" value="" style="width:150px;" placeholder="Bucket Name">
		    	<select name="aws_bucket_location_1" id="aws_bucket_location_1" style="width:200px;">
		    		<option value="us-east" selected="selected">US Standard</option>
		    		<option value="us-west-2">US West (Oregon)</option>
		    		<option value="us-west-1">US West (Northern California)</option>
		    		<option value="EU">EU (Ireland)</option>
		    		<option value="ap-southeast-1">Asia Pacific (Singapore)</option>
		    		<option value="ap-northeast-1">Asia Pacific (Tokyo)</option>
		    		<option value="sa-east-1">South America (Sao Paulo)</option>
		    	</select>
		    </div>
		</cfif>
		<div style="width:50px;height:40px;">
			<img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" align="left" id="btnAdd" />
			<img src="#dynpath#/global/host/dam/images/list-remove-3.png" width="24" height="24" border="0" align="right" id="btnDel" />
		</div>
		<!--- Save --->
		<div style="float:left;"><input type="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save_s3")#" class="button" /></div>
		<div id="status_s3" style="float:left;padding-top:5px;padding-left:10px;font-weight:bold;color:green;"></div>
		<div style="clear:both;"></div>
	</form>
	<br /><br />
	<!--- JS --->
	<script type="text/javascript">
		$(document).ready(function() {
			<cfif countuntil LT 2>
				$('##btnDel').css('display','none');
			</cfif>
			// Add button click
			$('##btnAdd').click(function() {
				// how many "duplicatable" input fields we currently have
		        var num     = $('.clonedInputsf').length;
		        // the numeric ID of the new input field being added 
		        var newNum  = new Number(num + 1);      
		        // create the new element via clone(), and manipulate it's ID using newNum value
		        var newElem = $('##input' + num).clone().attr('id', 'input' + newNum);
		        // manipulate the name/id values of the input inside the new element
		        newElem.children(':first').attr('id', 'aws_access_key_id_' + newNum).attr('name', 'aws_access_key_id_' + newNum);
		        newElem.children(':nth-child(2)').attr('id', 'aws_secret_access_key_' + newNum).attr('name', 'aws_secret_access_key_' + newNum);
		        newElem.children(':nth-child(3)').attr('id', 'aws_bucket_name_' + newNum).attr('name', 'aws_bucket_name_' + newNum);
		        newElem.children(':nth-child(4)').attr('id', 'aws_bucket_location_' + newNum).attr('name', 'aws_bucket_location_' + newNum);
		        // Add the fields to the page
		        $('##input' + num).after(newElem)
		        // enable the "remove" button
		        $('##btnDel').css('display','');
		        // Reset Values
		        $('##aws_access_key_id_' + newNum).val('');
		        $('##aws_secret_access_key_' + newNum).val('');
		        $('##aws_bucket_location_' + newNum).val( $('option:first', this).val() );
		        $('##aws_bucket_name_' + newNum).val('');
		    });
			// Delete button click
		    $('##btnDel').click(function() {
		    	// how many "duplicatable" input fields we currently have
		        var num = $('.clonedInputsf').length;
		        // remove the last element 
		        $('##input' + num).remove();     
		        // enable the "add" button
		        $('##btnAdd').attr('disabled',false);
		        // if only one element remains, disable the "remove" button
		        if (num-1 == 1)
		            $('##btnDel').css('display','none');
		    });
		    // Save
	    	$("##form_s3").submit(function(e){
	    		// Get values
	    		var url = formaction("form_s3");
	    		var items = formserialize("form_s3");
	    		// Submit Form
	    		$.ajax({
	    			type: "POST",
	    			url: url,
	    		   	data: items,
	    		   	success: function(){
	    		   		$('##status_s3').html('#myFusebox.getApplicationData().defaults.trans("success")#').animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
	    		   	}
	    		});
	    		return false;
	    	});
		});
	</script>
</cfoutput>