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
	<form name="assetemail" id="assetemail">
	<table border="0" cellpadding="0" cellspacing="0" width="600" class="tablepanel">
		<tr>
			<th colspan="2">eMails</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("email_desc")#</td>
		</tr>
		<tr>
			<td class="td2" width="1%" nowrap="true">#defaultsObj.trans("email_mail_server")#</td>
			<td class="td2" width="100%"><input name="email_server" type="text" size="40" tabindex="1" value="<cfif structkeyexists(session,"email_server")>#session.email_server#</cfif>"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="true">#defaultsObj.trans("email_address")#</td>
			<td class="td2"><input name="email_address" type="text" size="40" tabindex="2" value="<cfif structkeyexists(session,"email_address")>#session.email_address#</cfif>"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="true">#defaultsObj.trans("password")#</td>
			<td class="td2"><input name="email_pass" type="password" size="40" tabindex="3"></td>
		</tr>
		<tr>
			<td nowrap="true" class="td2" style="padding-bottom:15px;">#defaultsObj.trans("email_subject")#</td>
			<td class="td2" style="padding-bottom:15px;"><input name="email_subject" type="text" size="40" tabindex="4" value="<cfif structkeyexists(session,"email_subject")>#session.email_subject#</cfif>"></td>
		</tr>
		<tr>
			<td colspan="2"><div style="float:left;"><input type="button" name="cancel" value="#defaultsObj.trans("back_to_folder")#" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#attributes.folder_id#');return false;" class="button"></div><div style="float:right;"><input type="button" name="submit" value="#defaultsObj.trans("button_show_emails")#" class="button" onclick="submitassetemailshow();"></div></td>
		</tr>
	</table>
	</form>
	<!--- JS for form --->
	<script language="javascript">
		function submitassetemailshow() {
			var items = formserialize("assetemail");
			loadcontent('addemail','#myself#c.asset_add_email_show&folder_id=#attributes.folder_id#&' + items);
		}
	</script>
</cfoutput>