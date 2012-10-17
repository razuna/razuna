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
<span class="loginform_header">#myFusebox.getApplicationData().defaults.trans("headerretrievepassword")#</span>
<br />
<br />
<form action="#self#" method="post" id="form_forgotpass" id="form_forgotpass">
<input type="hidden" name="#theaction#" value="#xfa.submitform#">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	    <!--- <tr>
	        <td>#myFusebox.getApplicationData().defaults.trans("youremail")#</td>
		</tr> --->
		<tr>
	        <td><label for="email" class="error" style="display:none;">Enter a valid eMail address!</label><div id="pf_email"><input type="text" name="email" id="email" style="width:280px;" placeholder="Your email address" /></div></td>
	    </tr>
	    <tr>
	        <td style="padding:10px 0px 10px 0px;">
	        	<input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("cancel")#" onclick="location.href='#myself##xfa.linkback#'" class="awesome medium green" /> 
	        	<input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("buttonsendpassword")#" class="awesome medium green" /></td>
	    </tr>
	</table>
</form>

<div id="pass_feedback"></div>

</cfoutput>

<script>
$(document).ready(function(){
	// Form: Forgotpass
	$("#form_forgotpass").validate({
		// When the form is being submited
		submitHandler: function(form) {
			// Submit by Ajax
			jQuery(form).ajaxSubmit({
				target: '#pass_feedback'
			});
		},
		rules: {
			email: {
		    	required: true,
		     	email: true
		   	}
		 }
	})
});
</script>