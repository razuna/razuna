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
	<table border="0" cellpadding="0" cellspacing="0" width="600" class="tablepanel">
		<tr>
			<th colspan="2">FTP</th>
		</tr>
		<tr>
			<td colspan="2">#defaultsObj.trans("ftp_desc")#</td>
		</tr>
		<tr>
			<td class="td2" width="1%" nowrap="true">#defaultsObj.trans("ftp_server")#</td>
			<td class="td2" width="100%"><input name="ftp_server" type="text" size="40" tabindex="1" value="<cfif structkeyexists(session,"ftp_server")>#session.ftp_server#</cfif>"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="true">#defaultsObj.trans("username")#</td>
			<td class="td2"><input name="ftp_user" type="text" size="40" tabindex="2" value="<cfif structkeyexists(session,"ftp_user")>#session.ftp_user#</cfif>"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="true">#defaultsObj.trans("password")#</td>
			<td class="td2"><input name="ftp_pass" type="password" size="40" tabindex="3"></td>
		</tr>
		<tr>
			<td nowrap="true" class="td2" style="padding-bottom:15px;">#defaultsObj.trans("ftp_passive")#</td>
			<td class="td2" style="padding-bottom:15px;"><input name="ftp_passive" type="radio" value="no" checked="true">#defaultsObj.trans("no")# <input name="ftp_passive" type="radio" value="yes">#defaultsObj.trans("yes")#</td>
		</tr>
		<tr>
			<td colspan="2"><div style="float:left;"><input type="button" name="cancel" value="#defaultsObj.trans("back_to_folder")#" onclick="loadcontent('rightside','#myself#c.folder&folder_id=#attributes.folder_id#');return false;" class="button"></div><div style="float:right;"><div id="ftplogin" style="float:left;padding-right:10px;padding-top:4px;"></div><input type="button" name="submitbutton" id="submitbutton" value="#defaultsObj.trans("button_show_ftp")#" class="button" onclick="submitassetftpshow();"></div></td>
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
	    	var items = formserialize("assetftp");
	    	// Change Button
		   	$('##ftplogin').html('#defaultsObj.trans("please_wait")#...(sometimes minutes)');
	    	// Load the FTP site
	    	loadcontent('addftp','#myself#c.asset_add_ftp_show&folder_id=#attributes.folder_id#&' + items);
	    	return false;
		}
	</script>
</cfoutput>
