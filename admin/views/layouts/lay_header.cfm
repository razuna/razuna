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
<span class="loginheader">
	<a href="#myself#c.main">
		<!--- <cfif directoryexists("#pathoneup#global/host/logo/#session.hostid#")>
			<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" border="0" />
		<cfelse> --->
			<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="220" height="34" border="0" style="padding:3px 0px 0px 5px;">
		<!--- </cfif> --->
	</a>
</span>
<div id="navrighttop">
	<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td nowrap="true">
				<cfif application.razuna.isp>
					<cfset thename = cgi.http_host>
					<cfset thecount = findoneof(".",thename) - 1>
					<cfset thesubdomain = mid(cgi.http_host,1,thecount)>
					<cfset thehostpath = replaceNoCase(cgi.http_host,thesubdomain,"","one")>
				</cfif>
				<select name="gotodam" id="gotodam" onChange="javascript:gotodam_choose();" style="width:100px;">
					<option id="gotodamselect" value="0" selected="true">#defaultsObj.trans("goto")#</option>
					<cfloop query="qry_allhosts">
						<cfif application.razuna.isp>
							<option value="http://#host_name##thehostpath#/">
						<cfelse>
							<option value="../#host_path#/dam">
						</cfif>
						#ucase(host_name)#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap="true" style="padding-left:5px;padding-right:30px;"><form name="f_lang">
				<select name="app_lang" size=1 class="text" onChange="javascript:changelang('f_lang');">
					<option value="javascript:void();" selected>#defaultsObj.trans("changelang")#</option>
					<cfset thelangs = #defaultsObj.getlangsadmin(thispath)#>
					<cfloop query="thelangs">
					<cfset thislang = replacenocase("#name#", ".xml", "", "ALL")>
					<option value="#myself##xfa.switchlang#&thelang=#thislang#">#ucase(left(thislang,1))##mid(thislang,2,20)#</option>
					</cfloop>
				</select>
			</td>
			<td nowrap="true" style="padding-left:7px;"><a href="https://help.razuna.com" target="_blank">Feedback</a></td>
			<td nowrap="true" style="padding-left:7px;"><a href="http://wiki.razuna.com" target="_blank">Documentation</a></td>
			<td nowrap="true" style="padding-left:7px;"><a href="#myself#c.logoff">#defaultsObj.trans("logoff")#</a></td>
		</tr>
	</table>
</div>
</cfoutput>

<script language="JavaScript" type="text/javascript">
	function gotodam_choose(){
		// Select gotodam value
		var gotodam = $('#gotodam :selected').val();
		if (gotodam != 0){
			window.open(gotodam, '_blank');
			window.focus();
			$('#gotodamselect').attr('selected','selected');
		}
	}
</script>