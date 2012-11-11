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
<span class="loginform_header">#myFusebox.getApplicationData().defaults.trans("request_access")#</span>
<br />
<br />
<form action="#self#" method="post" id="form_reqaccess" id="form_reqaccess">
<input type="hidden" name="#theaction#" value="#xfa.submitform#">
<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="grid">
		<tr>
	        <td><input type="text" name="user_email" id="user_email" style="width:300px;" placeholder="#myFusebox.getApplicationData().defaults.trans("email")#" /><br><label for="user_email" class="error" style="display:none;">Enter a valid eMail address!</label></td>
	    </tr>
		<tr>
			<td><input type="text" name="user_first_name" id="user_first_name" style="width:300px;" placeholder="#myFusebox.getApplicationData().defaults.trans("user_first_name")#"><br><label for="user_first_name" class="error">Enter your Firstname!</label></td>
		</tr>
		<tr>
			<td><input type="text" name="user_last_name" id="user_last_name" style="width:300px;" placeholder="#myFusebox.getApplicationData().defaults.trans("user_last_name")#"><br><label for="user_last_name" class="error">Enter your Lastname!</label></td>
		</tr>
		<tr>
			<td><input type="password" name="user_pass" id="user_pass" style="width:300px;" placeholder="#myFusebox.getApplicationData().defaults.trans("password")#"><br><label for="user_pass" class="error">Enter Password!</label></td>
		</tr>
		<tr>
			<td><input type="password" name="user_pass_confirm" id="user_pass_confirm" style="width:300px;" placeholder="#myFusebox.getApplicationData().defaults.trans("password_confirm")#"><br><label for="user_pass_confirm" class="error">Enter password or password does not match!</label></td>
		</tr>
		<!--- Custom fields --->
		<cfif qry_cf.recordcount NEQ 0>
			<cfset cf_id = 0>
			<cfset variables.cf_inline = true>
			<cfinclude template="inc_custom_fields.cfm">
		</cfif>
	    <tr>
	        <td style="padding:10px 0px 10px 0px;">
	        	<input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("cancel")#" onclick="location.href='#myself##xfa.linkback#'" class="awesome medium grey" /> 
	        	<input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("request_access")#" class="awesome medium green" />
	        </td>
	    </tr>
	</table>
</form>

<div id="req_feedback"></div>

</cfoutput>

<script>
$(document).ready(function(){
	// Form: form_reqaccess
	$("#form_reqaccess").validate({
		// When the form is being submited
		submitHandler: function(form) {
			// Submit by Ajax
			jQuery(form).ajaxSubmit({
				target: '#req_feedback'
			});
		},
		rules: {
			user_first_name: "required",
			user_last_name: "required",
		   	user_email: {
		    	required: true,
		     	email: true
		   	},
		   	user_pass: {
				required: true
			},
			user_pass_confirm: {
				required: true,
				equalTo: "#user_pass"
			}
		 }
	})
});
</script>