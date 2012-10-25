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
	<form id="form_account">
		<span class="loginform_header">#defaultsObj.trans("header_first_time_account")#</span>
		<br />
		#defaultsObj.trans("header_first_time_account_desc")#
		<br />
		<br />
		<strong>#defaultsObj.trans("username")#</strong> 
		<br />
		<input name="user_login_name" id="user_login_name" type="text" class="text" size="30" value="Administrator">
		<br />
		<strong>#defaultsObj.trans("user_first_name")#</strong>
		<br />
		<input name="user_first_name" id="user_first_name" type="text" class="text" size="30">
		<br />
		<strong>#defaultsObj.trans("user_last_name")#</strong>
		<br />
		<input name="user_last_name" id="user_last_name" type="text" class="text" size="30">
		<br />
		<strong>#defaultsObj.trans("email")#</strong>
		<br />
		<input name="user_email" id="user_email" type="text" class="text" size="30">
		<br />
		<br />
		<strong>#defaultsObj.trans("password")#</strong>
		<br />
		<input name="user_pass" id="user_pass" type="password" size="30" class="text">
		<br />
		<strong>#defaultsObj.trans("password_confirm")#</strong>
		<br />
		<input name="user_pass_confirm" id="user_pass_confirm" type="password" size="30" class="text">
		<br />
		<br />
		<div>
			<div style="float:left;padding:20px 0px 0px 0px;">
				<input type="button" id="next" value="#defaultsObj.trans("back")#" onclick="loadcontent('load_steps','#myself#c.first_time_paths&db=#session.firsttime.database#&schema=#session.firsttime.db_schema#&type=#session.firsttime.type#')" class="button">
			</div>
			<div style="float:right;padding:20px 0px 0px 0px;">
				<div id="firsttimestatus" style="color:green;font-weight:bold;float:left;padding:10px;" />
				<input type="button" id="next" value="Finalize Setup" onclick="checkform();" class="button">
			</div>
		</div>
	</form>
	<div id="ft_dummy" style="display:none;"></div>
</cfoutput>

<script language="javascript">
	// Submit form
	function checkform() {
		// Get path values
		var user_login_name = $('#user_login_name').val();
		var user_first_name = $('#user_first_name').val();
		var user_last_name = $('#user_last_name').val();
		var user_email = $('#user_email').val();
		var user_pass = $('#user_pass').val();
		var user_pass_confirm = $('#user_pass_confirm').val();
		// Check value or else inform user
		if ((user_login_name == "") | (user_first_name == "") | (user_last_name == "") | (user_email == "") | (user_pass == "") | (user_pass_confirm == "")){
			alert('Please fill in all required form fields!');
		}
		else if (user_pass != user_pass_confirm){
			alert('Your password does not match. Please check it!');
		}
		else {
			// Get values
			var items = formserialize("form_account");
			// Status Message
			$('#firsttimestatus').html('<img src="images/loading-bars.gif" border="0" align="right" />');
			// Submit Form
			$('#ft').load('index.cfm?fa=c.first_time_final', {user_login_name:user_login_name,user_first_name:user_first_name,user_last_name:user_last_name,user_email:user_email,user_pass:user_pass});
		}
	}
</script>
