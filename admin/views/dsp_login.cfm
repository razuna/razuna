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
<!--- #application.razuna.trans.getString('HomePage', 'username')# --->
<div id="logindiv" style="text-align:center;">
	<span class="loginform_header">
		<img src="#dynpath#/global/host/dam/images/razuna-logo-blue-300.png" width="300" height="47" border="0" style="padding:5px 0px 5px 0px;">
	</span>
	<br />
	<div id="login_feedback">
		<form action="#self#" method="post" name="form_login" id="form_login">
		<input type="hidden" name="#theaction#" value="#xfa.submitform#">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		    <!--- <tr>
		        <td width="100%" nowrap>#defaultsObj.trans("username")#</td>
			</tr> --->
			<tr>
		        <td width="100%" nowrap style="padding-bottom:10px;">
			        <label for="name" class="error" style="display:none;">Enter a username!</label>
			        <div id="login_name"><input type="text" name="name" id="name" style="width:250px;" value="#cookie.loginnameadmin#" placeholder="Username" /></div>
				</td>
		    </tr>
		   <!---  <tr>
		        <td>#defaultsObj.trans("password")#</td>
			</tr> --->
			<tr>
		        <td>
			        <label for="pass" class="error" style="display:none;">Enter a password!</label>
			        <div id="login_password"><input type="password" name="pass" id="pass" style="width:250px;" value="#cookie.loginpassadmin#" placeholder="Password" /></div>
				</td>
		    </tr>
		    <tr>
				<td><input type="checkbox" name="rem_login" id="rem_login" value="T"<cfif structkeyexists(cookie,"loginadminrem") AND cookie.loginadminrem EQ "t"> checked="checked"</cfif>> <a href="##" onclick="clickcbk('form_login','rem_login',0);return false;" style="color:##000000;text-decoration:none;">#defaultsObj.trans("remember_login")#</a></td>
			</tr>
		    <tr>
		        <td style="padding-bottom:10px;padding-top:10px;"><input type="submit" name="submitbutton" value="#defaultsObj.trans("button_login")#" class="button" /></td>
		    </tr>
			<tr>
		        <td style="padding-bottom:10px;">
			        <cfset thelangs = #defaultsObj.getlangsadmin(thispath)#>
					<select name="app_lang" onChange="javascript:changelang('form_login');">
						<option value="javascript:void();" selected>#defaultsObj.trans("changelang")#</option>
						<cfloop query="thelangs">
						<cfset thislang = replacenocase("#name#", ".xml", "", "ALL")>
						<option value="#myself##xfa.switchlang#&to=index&thelang=#thislang#">#ucase(left(thislang,1))##mid(thislang,2,20)#</option>
						</cfloop>
					</select>
				</td>
		    </tr>
		    <tr>
				<td nowrap="true"><a href="##" onclick="loadcontent('login_feedback','#myself##xfa.forgotpass#&firsttime=#attributes.firsttime#');return false;">#defaultsObj.trans("forgot_password")#</a></td>
			</tr>
		</table>
		</form>
		
			<cfif attributes.loginerror EQ "T">
				<div id="alertbox" style="padding-top:10px;" class="alert">#defaultsObj.trans("login_error")#</div>
			</cfif>
			<cfif attributes.nohost EQ "T">
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
			        <td class="alert">No host to choose from. Please contact your System Administrator to create a host!</td>
				</tr>
				</table>
			</cfif>
		
	</div>
</div>
<div id="login_loading" style="display:none;text-align:center;padding-top:20px;"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" width="128" height="15" border="0" /></div>

</cfoutput>
<script type="text/javascript">
	$('#name').focus();
</script>
