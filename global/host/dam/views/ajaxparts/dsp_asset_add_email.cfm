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
	<table border="0" cellpadding="0" cellspacing="0" width="600">
		<input type="hidden" name="fa" value="c.asset_add_email_show">
		<input type="hidden" name="folder_id" value="#attributes.folder_id#">
		<tr>
			<td colspan="2">#myFusebox.getApplicationData().defaults.trans("email_desc")#</td>
		</tr>
		<tr>
			<td colspan="2" style="padding-top:15px;"></td>
		</tr>
		<tr>
			<td nowrap="true" width="120">#myFusebox.getApplicationData().defaults.trans("email_mail_server")#</td>
			<td width="480"><input name="email_server" id="email_server" type="text" size="40" tabindex="1" value="<cfif structkeyexists(session,"email_server")>#session.email_server#</cfif>"></td>
		</tr>
		<tr>
			<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("email_address")#</td>
			<td><input name="email_address" id="email_address" type="text" size="40" tabindex="2" value="<cfif structkeyexists(session,"email_address")>#session.email_address#</cfif>"></td>
		</tr>
		<tr>
			<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("password")#</td>
			<td><input name="email_pass" id="email_pass" type="password" size="40" tabindex="3"></td>
		</tr>
		<tr>
			<td nowrap="true" style="padding-bottom:15px;">#myFusebox.getApplicationData().defaults.trans("email_subject")#</td>
			<td style="padding-bottom:15px;"><input name="email_subject" id="email_subject" type="text" size="40" tabindex="4" value="<cfif structkeyexists(session,"email_subject")>#session.email_subject#</cfif>"></td>
		</tr>
		<tr>
			<td colspan="2"><div style="float:left;"><input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("back_to_folder")#" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#attributes.folder_id#');return false;" class="button"></div><div id="subemail" style="float:right;"><input type="button" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_show_emails")#" class="button" onclick="submitassetemailshow();"></div></td>
		</tr>
	</table>
	</form>
	<!--- JS for form --->
	<script language="javascript">
		function submitassetemailshow() {
			// Waiting gif
			$('##subemail').html('<img src="#dynpath#/global/host/dam/images/loading-bars.gif" alt="loading-bars" width="128" height="15" />');
			// Get values
			var params = $('##assetemail').formParams();
			// send it off
			$('##addemail').load('#self#', params );
			
		}
	</script>
</cfoutput>