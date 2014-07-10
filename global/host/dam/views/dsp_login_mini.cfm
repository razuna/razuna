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
	<div id="outer-container">
		<div id="inner-container">
			<form action="#self#" method="post" name="form_login_mini" id="form_login_mini">
				<input type="hidden" name="#theaction#" value="#xfa.submitform#">
				<input type="hidden" name="mini" value="T">
			    <h1>SIGN IN</h1>
			    <input type="text" name="theemail" id="theemail" value="#cookie.loginname#" placeholder="Username" />
			    <input type="password" name="pass" id="pass" value="#cookie.loginpass#" placeholder="Password" />
			    <p>
			    	<input type="submit" name="submitbutton" id="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("button_login")#" class="awesome big green" style="width:300px;height:50px;font-size:22px;" />
			    </p>
				<p id="footer-login">
					<input type="checkbox" name="rem_login" id="rem_login" value="T" checked="true"> <a href="##" onclick="clickcbk('form_login','rem_login',0);return false;" style="text-decoration:none;">#myFusebox.getApplicationData().defaults.trans("remember_login")#</a>
					<br /><br />
					<cfif qry_langs.recordcount NEQ 1>
						<select name="app_lang" id="app_lang" onChange="changelang();">
							<option value="javascript:void();" selected>#myFusebox.getApplicationData().defaults.trans("changelang")#</option>
							<cfloop query="qry_langs">
								<option value="#myself##xfa.switchlang#&thelang=#lang_name#&to=mini">#lang_name#</option>
							</cfloop>
						</select>
					</cfif>
					<br /><br />
					<a href="//#cgi.http_host##cgi.script_name#" target="_blank" style="text-decoration:underline">I forgot my password</a> | <a href="//#cgi.http_host##cgi.script_name#" target="_blank" style="text-decoration:underline">Standard View</a>
				</p>
			</form>
		</div>
	</div>
	<cfif structkeyexists(attributes,"e")>
		<p id="footer-login" class="alert">#myFusebox.getApplicationData().defaults.trans("login_error")#</p>
	</cfif>
	<div id="login_loading"></div>
	<div id="alertbox" style="padding-top:10px;display:none;" class="alert">#myFusebox.getApplicationData().defaults.trans("login_error")#</div>
	<div id="alertgroupbox" style="padding-top:10px;display:none;" class="alert">#myFusebox.getApplicationData().defaults.trans("share_error_group")#</div>
</cfoutput>