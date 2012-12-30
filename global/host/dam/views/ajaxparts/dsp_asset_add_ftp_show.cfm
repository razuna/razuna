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
		<h2>An error occured while connecting to your FTP site</h2>
		<p>Unfortunately, an error occured connecting to your FTP site. Please check your login and password. Below is the error the FTP site reported:</p>
		<p>Error: #qry_ftp.ftp.errortext#<br />Error Code: #qry_ftp.ftp.errorcode#</p>
	<cfelse>
		<cfparam default="/" name="folderpath">
		<form name="assetftpform" id="assetftpform" method="post" action="#self#">
		<input type="hidden" name="#theaction#" value="#xfa.submitassetftp#">
		<!--- <input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#"> --->
		<input type="hidden" name="folder_id" value="#attributes.folder_id#">
		<input type="hidden" name="thepath" value="#thisPath#">
		<input type="hidden" name="folderpath" value="#folderpath#">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
			<tr>
				<th colspan="3">#myFusebox.getApplicationData().defaults.trans("ftp_server")#</th>
			</tr>
			<!--- Back --->
			<cfif structkeyexists(attributes,"folderpath")>
				<tr>
					<td colspan="3"><a href="##" onclick="loadcontent('addftp','#myself##xfa.reloadftp#&folderpath=#URLEncodedFormat(qry_ftp.backpath)#&folder_id=#attributes.folder_id#');">#myFusebox.getApplicationData().defaults.trans("back")#</a></td>
				</tr>
			</cfif>
			<!--- output directory name --->
			<tr>
				<td width="1%" nowrap="true" class="td2"><img src="#dynpath#/global/host/dam/images/folder_open.png" width="16" height="16" border="0"></td>
				<td colspan="2" width="100%" nowrap="true" class="td2">#qry_ftp.dirname# - <a href="##" onClick="CheckAll('assetftpform');" title="#myFusebox.getApplicationData().defaults.trans("tooltip_select_desc")#">#myFusebox.getApplicationData().defaults.trans("tooltip_select")#</a></td>
			</tr>
			<!--- list the files --->
			<cfloop query="qry_ftp.ftplist">
				<tr>
					<td width="1%" nowrap class="td2"></td>
					<cfif isdirectory>
						<td width="1%" nowrap class="td2" style="padding-left:10px;padding-right:2px;"><img src="#dynpath#/global/host/dam/images/folder.png" width="16" height="16" border="0"></td>
						<td width="100%" nowrap class="td2" style="padding-left:2px;"><a href="##" onclick="loadcontent('addftp','#myself##xfa.reloadftp#&folderpath=#URLEncodedFormat(path)#&folder_id=#attributes.folder_id#');">#name#</a></td>
					</cfif>
					<cfif NOT isdirectory>
						<cfinvoke component="global.cfc.global" method="converttomb" thesize="#length#" returnvariable="thesize">
						<td width="100%" colspan="2" nowrap class="td2"><input type="checkbox" name="thefile" value="#name#"> #name# (#thesize#MB)</td>
					</cfif>
				</tr>
			</cfloop>
				<tr>
					<td colspan="3"><input type="button" name="back" value="#myFusebox.getApplicationData().defaults.trans("back")#" onclick="loadcontent('addftp','#myself#c.asset_add_ftp&folder_id=#attributes.folder_id#');return false;" class="button"> <input type="button" name="button" value="Refresh" class="button" onClick="loadcontent('addftp','#myself#c.asset_add_ftp_show&folder_id=#attributes.folder_id#&ftp_server=#URLEncodedFormat(session.ftp_server)#&ftp_user=#URLEncodedFormat(session.ftp_user)#&ftp_pass=#URLEncodedFormat(session.ftp_pass)#&ftp_passive=#session.ftp_passive#<cfif structkeyexists(attributes,'folderpath')>&folderpath=#URLEncodedFormat(attributes.folderpath)#</cfif>');"> <input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_add_selected")#" class="button"> <div id="ftpuploadstatus" style="background-color:##FFFFE0;display:none;"></div></td>
				</tr>
			</table>
			<br>
			<table border="0" cellpadding="0" cellspacing="0" width="100%" class="tablepanel">
				<tr>
					<th colspan="2">Options</th>
				</tr>
				<tr>
					<td colspan="2" class="td2"><input type="checkbox" name="zip_extract" value="1" checked> #myFusebox.getApplicationData().defaults.trans("header_zip_desc")#</td>
				</tr>
				<!--- <tr>
					<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_thumbnail_size")#</th>
				</tr> --->
				<tr>
					<td colspan="2" class="td2">#myFusebox.getApplicationData().defaults.trans("header_thumbnail_size_desc")#</td>
				</tr>
				<tr>
					<td class="td2" colspan="2">#myFusebox.getApplicationData().defaults.trans("width")# <input type="text" name="img_thumb_width" size="4" maxlength="3" value="#settings_image.set2_img_thumb_width#"> #myFusebox.getApplicationData().defaults.trans("heigth")# <input type="text" name="img_thumb_heigth" size="4" maxlength="3" value="#settings_image.set2_img_thumb_heigth#"></td>
				</tr>
				<tr>
					<td colspan="2">
						<!--- Load upload templates here --->
						<cfif qry_templates.recordcount NEQ 0>
							<div>
								<select name="upl_template">
									<option value="0" selected="selected">Choose Rendition Template</option>
									<option value="0">---</option>
									<cfloop query="qry_templates">
										<option value="#upl_temp_id#">#upl_name#</option>
									</cfloop>
								</select>
							</div>
						</cfif>
					</td>
				</tr>
				<!--- <tr>
					<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_video_preview_size")#</th>
				</tr>
				<tr>
					<td colspan="2" class="td2">#myFusebox.getApplicationData().defaults.trans("header_video_preview_size_desc")#</td>
				</tr>
				<tr>
					<td class="td2" colspan="2">#myFusebox.getApplicationData().defaults.trans("width")# <input type="text" name="vid_preview_width" size="4" maxlength="3" value="#settings_video.set2_vid_preview_width#" onchange="aspectheight(this,'vid_preview_heigth','assetftpform');"> #myFusebox.getApplicationData().defaults.trans("heigth")# <input type="text" name="vid_preview_heigth" size="4" maxlength="3" value="#settings_video.set2_vid_preview_heigth#" onchange="aspectwidth(this,'vid_preview_width','assetftpform');"></td>
				</tr> --->
		</table>
		</form>
		<script language="javascript">
			$("##assetftpform").submit(function(e) {
				// Check that a file has been selected
				var arehere = 'F';
					for (var i = 0; i<document.assetftpform.elements.length; i++) {
				        if ((document.assetftpform.elements[i].name.indexOf('thefile') > -1)) {
				            if (document.assetftpform.elements[i].checked) {
				                var arehere = 'T';
				            }
				        }
				    }
				// file is selected thus continue
				if (arehere == 'T'){
					// Show loading message in upload window
					$('##ftpuploadstatus').css("display","");
					$("##ftpuploadstatus").html('<div style="padding:10px"><img src="#dynpath#/global/host/dam/images/loading.gif" border="0" width="16" height="16"><br><br>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("upload_wait_message"))#</div>');
					// Get values
					var url = formaction("assetftpform");
					var items = formserialize("assetftpform");
					// Submit Form
					$.ajax({
						type: "POST",
						url: url,
					   	data: items,
					   	success: function(){
					   		$("##ftpuploadstatus").html('<div style="padding:10px;font-weight:bold;color:green;">#JSStringFormat(myFusebox.getApplicationData().defaults.trans("upload_success_email"))#</div>');
					   		$("##ftpuploadstatus").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
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
				// No file is selected
				else{
					alert('Please select a file for adding!');
					return false;
				}
			})
		</script>
	</cfif>
</cfoutput>