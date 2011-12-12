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
<!--- 
Page output starts here
 --->
<cfoutput>
#application.razuna.trans.getString('HomePage', 'username')#
<div id="logindiv">
	<span class="loginform_header">
		<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="200" height="29" border="0" style="padding:3px 0px 0px 5px;">
	</span>
	<br />
	<br />
	<div id="login_feedback">
		<form action="#self#" method="post" name="form_login" id="form_login">
		<input type="hidden" name="#theaction#" value="#xfa.submitform#">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		    <tr>
		        <td width="100%" nowrap>#defaultsObj.trans("username")#</td>
			</tr>
			<tr>
		        <td width="100%" nowrap style="padding-bottom:10px;">
			        <label for="name" class="error" style="display:none;">Enter a username!</label>
			        <div id="login_name"><input type="text" name="name" id="name" style="width:250px;" value="#cookie.loginnameadmin#" /></div>
				</td>
		    </tr>
		    <tr>
		        <td>#defaultsObj.trans("password")#</td>
			</tr>
			<tr>
		        <td>
			        <label for="pass" class="error" style="display:none;">Enter a password!</label>
			        <div id="login_password"><input type="password" name="pass" id="pass" style="width:250px;" value="#cookie.loginpassadmin#" /></div>
				</td>
		    </tr>
		    <tr>
				<td><input type="checkbox" name="rem_login" id="rem_login" value="T"<cfif structkeyexists(cookie,"loginadminrem") AND cookie.loginadminrem EQ "t"> checked="checked"</cfif>> <a href="##" onclick="clickcbk('form_login','rem_login',0);return false;" style="color:##000000;text-decoration:none;">#defaultsObj.trans("remember_login")#</a></td>
			</tr>
		    <tr>
		        <td align="right" style="padding-bottom:10px;padding-top:10px;"><input type="submit" name="submitbutton" value="#defaultsObj.trans("button_login")#" class="button" /></td>
		    </tr>
			<tr>
		        <td align="right" style="padding-bottom:10px;">
			        <cfset thelangs = #defaultsObj.getlangsadmin(thispath)#>
					<select name="app_lang" onChange="javascript:changelang('loginform');">
						<option value="javascript:void();" selected>#defaultsObj.trans("changelang")#</option>
						<cfloop query="thelangs">
						<cfset thislang = replacenocase("#name#", ".xml", "", "ALL")>
						<option value="#myself##xfa.switchlang#&to=index&thelang=#thislang#">#ucase(left(thislang,1))##mid(thislang,2,20)#</option>
						</cfloop>
					</select>
				</td>
		    </tr>
		    <tr>
				<td align="right" nowrap="true"><a href="##" onclick="loadcontent('login_feedback','#myself##xfa.forgotpass#&firsttime=#attributes.firsttime#');return false;">#defaultsObj.trans("forgot_password")#</a></td>
			</tr>
		</table>
		</form>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<cfif attributes.loginerror EQ "T">
				<tr>
			        <td class="alert">#defaultsObj.trans("login_error")#</td>
				</tr>
			</cfif>
			<cfif attributes.nohost EQ "T">
				<tr>
			        <td class="alert">No host to choose from. Please contact your System Administrator to create a host!</td>
				</tr>
			</cfif>
		</table>
	</div>
</div>
<div id="login_loading"></div>
<div id="alertbox" style="padding-top:10px;display:none;" class="alert">#defaultsObj.trans("login_error")#</div>
</cfoutput>
<script type="text/javascript">
	$('#name').focus();
</script>
