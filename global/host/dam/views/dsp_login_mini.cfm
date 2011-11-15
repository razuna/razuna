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
<div id="login_div">
	<cfif fileexists("#ExpandPath("../..")#global/host/logo/#session.hostid#/logo.jpg")>
		<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" border="0" />
	<cfelse>
		<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="200" height="29" border="0" style="padding:3px 0px 0px 5px;">
	</cfif>
	<br />
	<br />
	<div style="padding-left:10px;">
		<form action="#self#" method="post" name="form_login_mini" id="form_login_mini">
		<input type="hidden" name="#theaction#" value="#xfa.submitform#">
		<input type="hidden" name="mini" value="T">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		    <tr>
		        <td width="100%" nowrap>#defaultsObj.trans("email_address")#</td>
			</tr>
			<tr>
				<td width="100%" nowrap style="padding-bottom:10px;">
					<label for="name" class="error">Enter a username!</label>
		       	 	<div id="login_name"><input type="text" name="theemail" id="theemail" size="30" value="#cookie.loginname#" /></div>
				</td>
		    </tr>
		    <tr>
		        <td>#defaultsObj.trans("password")#</td>
			</tr>
			<tr>
		        <td>
			        <label for="pass" class="error">Enter a password!</label>
			    	<div id="login_password"><input type="password" name="pass" id="pass" size="30" value="#cookie.loginpass#" /></div>
				</td>
		    </tr>
		     <tr>
				<td><input type="checkbox" name="rem_login" id="rem_login" value="T" checked="true"> <a href="##" onclick="clickcbk('form_login','rem_login',0);return false;" style="color:##000000;text-decoration:none;">#defaultsObj.trans("remember_login")#</a></td>
			</tr>
		    <tr>
		        <td style="padding-bottom:10px;padding-top:10px;"><input type="submit" name="submitbutton" value="#defaultsObj.trans("button_login")#" class="button" /></td>
		    </tr>
			<cfif qry_langs.recordcount NEQ 1>
				<tr>
			        <td style="padding-bottom:10px;">
						<select name="app_lang" onChange="javascript:changelang('form_login_share');">
							<option value="javascript:void();" selected>#defaultsObj.trans("changelang")#</option>
							<cfloop query="qry_langs">
							<option value="#myself##xfa.switchlang#&thelang=#lang_name#&to=mini">#lang_name#</option>
							</cfloop>
						</select>
					</td>
			    </tr>
			</cfif>
		</table>
		</form>
	</div>
</div>
<cfif structkeyexists(attributes,"e")>
	<div style="padding-top:10px;" class="alert">#defaultsObj.trans("login_error")#</div>
</cfif>
<div id="login_loading"></div>
<div id="alertbox" style="padding-top:10px;display:none;" class="alert">#defaultsObj.trans("login_error")#</div>
<div id="alertgroupbox" style="padding-top:10px;display:none;" class="alert">#defaultsObj.trans("share_error_group")#</div>
</cfoutput>

<script type="text/javascript">
function clickcbk(theform,thefield,which) {
	var curval = $('#rem_login:checked').val();
	if(curval == false){
		$('#rem_login').attr('checked','checked');
	}
	else{
		$('#rem_login').attr('checked','');
	}
}
</script>

