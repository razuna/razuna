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
	<cfif NOT qry_ftp.ftp.Succeeded>
		Error: #qry_ftp.ftp.errortext#
	<cfelse>
		<div id="ftpuploadstatus" style="padding:10px;color:green;display:none;"></div>
		<form name="assetftpform" id="assetftpform" method="post" action="#self#">
		<cfif session.frombasket EQ "F">
			<input type="hidden" name="#theaction#" value="#xfa.submitassetftp#">
		<cfelse>
			<input type="hidden" name="#theaction#" value="c.basket_ftp_put">
		</cfif>
		<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
		<input type="hidden" name="thepath" value="#thisPath#">
		<cfif structkeyexists(attributes,"folderpath")>
			<input type="hidden" name="folderpath" value="#attributes.folderpath#">
		<cfelse>
			<input type="hidden" name="folderpath" value="#qry_ftp.ftplist.path#">
		</cfif>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("ftp_server")#</th>
			</tr>
			<!--- Back --->
			<cfif structkeyexists(attributes,"folderpath")>
				<tr>
					<td colspan="2"><a href="##" onclick="loadcontent('thewindowcontent<cfif session.frombasket EQ "F">2<cfelseif session.frombasket EQ "S">3<cfelse>1</cfif>','#myself##xfa.reloadftp#&folderpath=#qry_ftp.backpath#&foldername=#attributes.foldername#');">#myFusebox.getApplicationData().defaults.trans("back")#</a></td>
				</tr>
			</cfif>
			<!--- output directory name --->
			<tr>
				<td width="1%" nowrap="true" class="td2"><img src="#dynpath#/global/host/dam/images/folder_open.png" width="16" height="16" border="0"></td>
				<td width="100%" nowrap="true" class="td2">#qry_ftp.dirname#</td>
			</tr>
			<!--- list the files --->
			<cfloop query="qry_ftp.ftplist">
				<tr>
					<cfif isdirectory>
						<cfif left(path,1) EQ "/">
							<cfset thepath = mid(path,2,1000)>
						<cfelse>
							<cfset thepath = path>
						</cfif>
						<td width="1%" nowrap class="td2" style="padding-left:10px;padding-right:2px;"><a href="##" onclick="loadcontent('thewindowcontent<cfif session.frombasket EQ "F">2<cfelseif session.frombasket EQ "S">3<cfelse>1</cfif>','#myself##xfa.reloadftp#&folderpath=#thepath#&foldername=#name#');"><img src="#dynpath#/global/host/dam/images/folder.png" width="16" height="16" border="0"></a></td>
						<td width="100%" nowrap class="td2" style="padding-left:2px;"><a href="##" onclick="loadcontent('thewindowcontent<cfif session.frombasket EQ "F">2<cfelseif session.frombasket EQ "S">3<cfelse>1</cfif>','#myself##xfa.reloadftp#&folderpath=#thepath#&foldername=#name#');">#name#</a></td>
					</cfif>
					<cfif NOT isdirectory AND session.frombasket NEQ "S">
						<td class="td2"></td>
						<td width="100%" nowrap class="td2">#name#</td>
					</cfif>
				</tr>
			</cfloop>
				<tr>
					<td colspan="2">
						<cfif session.frombasket EQ "S">
							<input type="button" name="submit" value="#myFusebox.getApplicationData().defaults.trans("scheduler_folder_select_cap")# (#attributes.foldername#)" class="button" onclick="document.schedulerform.ftpFolder.value='#attributes.folderpath#';destroywindow(3);">
						<cfelse>
							<input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("ftp_upload_here")#" class="button">
						</cfif>
					</td>
				</tr>
			</table>
		</form>
	</cfif>
	<script>
	// Submit Form
	$("##assetftpform").submit(function(e){
		$("##ftpuploadstatus").css("display","");
		loadinggif('ftpuploadstatus');
		// Submit Form
		// Get values
		var url = formaction("assetftpform");
		var items = formserialize("assetftpform");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: ftpfeedback
		});
		return false;
	})
	// Feedback	
	function ftpfeedback(responseText){
		// alert(responseText);
		var trimmed = responseText.replace(/^\s+|\s+$/g, '') ;
		if(trimmed == 'success'){
			$("##ftpuploadstatus").css("display","");
			$("##ftpuploadstatus").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("ftp_message_sent"))#</cfoutput>');
			$("##ftpuploadstatus").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
		}
		else{
			// alert(trimmed);
			$("##ftpuploadstatus").css("display","");
			$("##ftpuploadstatus").html('Error:' + responseText);
		}
	}
	</script>
	
	
	
</cfoutput>