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
	<form name="assetftp" id="assetftp">
	<table border="0" cellpadding="0" cellspacing="0" width="600">
		<tr>
			<td colspan="2">#myFusebox.getApplicationData().defaults.trans("ftp_desc")#</td>
		</tr>
		<tr>
			<td colspan="2" style="padding-top:15px;"></td>
		</tr>
		<tr>
			<td nowrap="true" width="120">#myFusebox.getApplicationData().defaults.trans("ftp_server")#</td>
			<td width="480"><input id="ftp_server" name="ftp_server" type="text" size="40" tabindex="1" value="<cfif structkeyexists(session,"ftp_server")>#session.ftp_server#</cfif>"></td>
		</tr>
		<tr>
			<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("username")#</td>
			<td><input id="ftp_user" name="ftp_user" type="text" size="40" tabindex="2" value="<cfif structkeyexists(session,"ftp_user")>#session.ftp_user#</cfif>"></td>
		</tr>
		<tr>
			<td nowrap="true">#myFusebox.getApplicationData().defaults.trans("password")#</td>
			<td><input id="ftp_pass" name="ftp_pass" type="password" size="40" tabindex="3"></td>
		</tr>
		<tr>
			<td nowrap="true" style="padding-bottom:15px;">#myFusebox.getApplicationData().defaults.trans("ftp_passive")#</td>
			<td style="padding-bottom:15px;"><input id="ftp_passive" name="ftp_passive" type="radio" value="no" checked="true">#myFusebox.getApplicationData().defaults.trans("no")# <input id="ftp_passive" name="ftp_passive" type="radio" value="yes">#myFusebox.getApplicationData().defaults.trans("yes")#</td>
		</tr>
		<tr>
			<td colspan="2"><div style="float:left;"><input type="button" name="cancel" value="#myFusebox.getApplicationData().defaults.trans("back_to_folder")#" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#attributes.folder_id#');return false;" class="button"></div><div style="float:right;"><div id="ftplogin" style="float:left;padding-right:10px;padding-top:4px;"></div><input type="button" name="submitbutton" id="submitbutton" value="#myFusebox.getApplicationData().defaults.trans("button_show_ftp")#" class="button" onclick="submitassetftpshow();"></div></td>
		</tr>
	</table>
	</form>
	<script language="javascript">
		function submitassetftpshow(){
			// Get passive selection
			for (var i = 0; i<document.assetftp.elements.length; i++) {
	        if ((document.assetftp.elements[i].name.indexOf('ftp_passive') > -1)) {
	            if (document.assetftp.elements[i].checked) {
	                var passive = document.assetftp.elements[i].value;
	            	}
	        	}
	    	}
	    	// Get Values
	    	var server = $('##ftp_server').val();
	    	var user = $('##ftp_user').val();
	    	var pass = $('##ftp_pass').val();
	    	var passive = $('##ftp_passive:checked').val();
	    	// Change Button
		   	$('##ftplogin').html('#myFusebox.getApplicationData().defaults.trans("please_wait")#...(sometimes minutes)');
	    	// Load the FTP site
	    	$('##addftp').load('#myself#c.asset_add_ftp_show', { folder_id:"#attributes.folder_id#", ftp_server: server, ftp_user: user, ftp_pass: pass, ftp_passive: passive } );
	    	return false;
		}
	</script>
</cfoutput>
