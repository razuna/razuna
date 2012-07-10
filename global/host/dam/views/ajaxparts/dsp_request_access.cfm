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
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	    <tr>
	        <td>#myFusebox.getApplicationData().defaults.trans("email")#</td>
		</tr>
		<tr>
	        <td><input type="text" name="user_email" id="user_email" size="40" /><br><label for="user_email" class="error" style="display:none;">Enter a valid eMail address!</label></td>
	    </tr>
	    <tr>
			<td>#myFusebox.getApplicationData().defaults.trans("user_first_name")#*</td>
		</tr>
		<tr>
			<td><input type="text" name="user_first_name" id="user_first_name" size="40" class="text"><br><label for="user_first_name" class="error">Enter your Firstname!</label></td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("user_last_name")#*</td>
		</tr>
		<tr>
			<td><input type="text" name="user_last_name" id="user_last_name" size="40" class="text"><br><label for="user_last_name" class="error">Enter your Lastname!</label></td>
		</tr>
	    <tr>
			<td>#myFusebox.getApplicationData().defaults.trans("password")#*</td>
		</tr>
		<tr>
			<td><input type="password" name="user_pass" id="user_pass" size="40" class="text"><br><label for="user_pass" class="error">Enter Password!</label></td>
		</tr>
		<tr>
			<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("password_confirm")#*</td>
		</tr>
		<tr>
			<td><input type="password" name="user_pass_confirm" id="user_pass_confirm" size="40" class="text"><br><label for="user_pass_confirm" class="error">Enter password or password does not match!</label></td>
		</tr>
	    
	    <tr>
	        <td align="right" style="padding:10px 0px 10px 0px;"><input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("cancel")#" onclick="location.href='#myself##xfa.linkback#'" class="button" /> <input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("request_access")#" class="button" /></td>
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