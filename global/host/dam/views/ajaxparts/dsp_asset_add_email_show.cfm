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
	<div id="uploadstatus"></div>
	<form name="assetemailform" id="assetemailform" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="#xfa.submitassetemail#">
	<!--- <input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#"> --->
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="thepath" value="#thisPath#">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
		<tr>
			<th colspan="5">eMail Messages</th>
		</tr>
		<cfif qry_emails.error NEQ "F">
			<tr>
				<td>#myFusebox.getApplicationData().defaults.trans("email_error")#<br /><br /><span style="color:red;font-weight:bold;">#qry_emails.error#</span></td>
			</tr>
			<tr>
				<td><a href="##" onclick="loadcontent('addemail','#myself#c.asset_add_email&folder_id=#folder_id#');return false;">#myFusebox.getApplicationData().defaults.trans("back")#</a></td>
			</tr>
		<cfelse>
			<cfloop query="qry_emails.qryheaders">
				<tr>
					<td width="1%" nowrap><input type="checkbox" name="emailid" value="#messagenumber#"></td>
					<td width="100%" nowrap><a href="##" onClick="showwindow('#myself#c.asset_add_email_show_mail&mailid=#messagenumber#&pathhere=#urlencodedformat(thispath)#','#myFusebox.getApplicationData().defaults.trans("header_add_asset_server")#',800,2);"><b><u>#subject#</u></b></a></td>
					<td width="1%" nowrap>#from#</td>
					<td width="1%" nowrap>#date#</td>
					<td width="1%" nowrap><a href="##" onClick="showwindow('#myself#ajax.remove_email&mailid=#messagenumber#&folder_id=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("header_add_asset_server")#',400,2);"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="5"><input type="button" name="back" value="#myFusebox.getApplicationData().defaults.trans("back")#" onclick="loadcontent('addemail','#myself#c.asset_add_email&folder_id=#folder_id#');return false;" class="button"> <input type="button" name="button" value="Refresh" class="button" onClick="loadcontent('addemail','#myself#c.asset_add_email_show&folder_id=#attributes.folder_id#&email_server=#attributes.email_server#&email_address=#attributes.email_address#&email_pass=#attributes.email_pass#&email_subject=#attributes.email_subject#');"> <input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_add_email_attachment")#" class="button"></td>
			</tr>
		</table>
		<br>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_zip")#</th>
			</tr>
			<tr>
				<td colspan="2" class="td2"><input type="checkbox" name="zip_extract" value="1" checked> #myFusebox.getApplicationData().defaults.trans("header_zip_desc")#</td>
			</tr>
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_thumbnail_size")#</th>
			</tr>
			<tr>
				<td colspan="2" class="td2">#myFusebox.getApplicationData().defaults.trans("header_thumbnail_size_desc")#</td>
			</tr>
			<tr>
				<td class="td2" colspan="2">#myFusebox.getApplicationData().defaults.trans("width")# <input type="text" name="img_thumb_width" size="4" maxlength="3" value="#settings_image.set2_img_thumb_width#"> #myFusebox.getApplicationData().defaults.trans("heigth")# <input type="text" name="img_thumb_heigth" size="4" maxlength="3" value="#settings_image.set2_img_thumb_heigth#"></td>
			</tr>
			<!--- <tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_video_preview_size")#</th>
			</tr>
			<tr>
				<td colspan="2" class="td2">#myFusebox.getApplicationData().defaults.trans("header_video_preview_size_desc")#</td>
			</tr>
			<tr>
				<td class="td2" colspan="2">#myFusebox.getApplicationData().defaults.trans("width")# <input type="text" name="vid_preview_width" size="4" maxlength="3" value="#settings_video.set2_vid_preview_width#" onchange="aspectheight(this,'vid_preview_heigth','assetemailform');"> #myFusebox.getApplicationData().defaults.trans("heigth")# <input type="text" name="vid_preview_heigth" size="4" maxlength="3" value="#settings_video.set2_vid_preview_heigth#" onchange="aspectwidth(this,'vid_preview_width','assetemailform');"></td>
			</tr> --->
		</cfif>
	</table>
	</form>
	<!--- JS form --->
	<script language="javascript">
		$("##assetemailform").submit(function(e) {
			// Check that a email has been selected
			var arehere = 'F';
				for (var i = 0; i<document.assetemailform.elements.length; i++) {
			        if ((document.assetemailform.elements[i].name.indexOf('emailid') > -1)) {
			            if (document.assetemailform.elements[i].checked) {
			                var arehere = 'T';
			            }
			        }
			    }
			// eMail is selected thus continue
			if (arehere == 'T'){
				// Show loading message in upload window
				$("##uploadstatus").html('<div style="padding:10px"><img src="#dynpath#/global/host/dam/images/loading.gif" border="0" width="16" height="16"><br><br>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("upload_wait_message"))#</div>');
				// Get values
				var url = formaction("assetemailform");
				var items = formserialize("assetemailform");
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: function(){
				   		$("##uploadstatus").html('<div style="padding:10px;font-weight:bold;color:##900;">#JSStringFormat(myFusebox.getApplicationData().defaults.trans("upload_success_email"))#</div>');
				   		$("##uploadstatus").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
				   		<cfif pl_return.cfc.pl.loadform.active>
		   		   			// This is for the metaform plugin
		   					// close window
		   					$('##thewindowcontent1').dialog('close');
		   					// load metaform
		   					$('##rightside').load('#myself#c.plugin_direct&comp=metaform.cfc.settings&func=loadForm');
		   		   		</cfif>
				   	}
				});
				return false;
			}
			// No email is selected
			else {
				alert('Please select a eMail message!');
				return false;
			}
		})
	</script>
</cfoutput>