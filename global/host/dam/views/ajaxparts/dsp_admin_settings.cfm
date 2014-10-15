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
	<!--- Set Languages --->
	<form name="form_admin_settings" id="form_admin_settings" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.isp_settings_langsave">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<!--- Check duplicates --->
			<tr>
				<th class="textbold" colspan="2">#myFusebox.getApplicationData().defaults.trans("check_duplicates_header")#</th>
			</tr>
			<tr>
				<td colspan="2">#myFusebox.getApplicationData().defaults.trans("check_duplicates_desc")#</td>
			</tr>
			<tr>
				<td colspan="2"><input type="radio" name="set2_md5check" value="true"<cfif prefs.set2_md5check eq 'true'> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("check_duplicates_on")#<br /><input type="radio" name="set2_md5check" value="false"<cfif prefs.set2_md5check eq 'false' or prefs.set2_md5check eq ''> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("check_duplicates_off")#</td>
			</tr>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>
			<!--- Hide UPC settings if storage is not local --->
			 <cfif !application.razuna.storage eq 'local'>
			 	<cfset csshide= "style='display:none'">
			 <cfelse> 
			 	<cfset csshide= "">
			</cfif>
				<!--- UPC Enabled --->
				<tr #csshide#>
					<th class="textbold" colspan="2">#myFusebox.getApplicationData().defaults.trans("upc_enabled")#</th>
				</tr>
				<tr #csshide#>
					<td colspan="2">
						<input type="radio" name="set2_upc_enabled" value="true" <cfif prefs.set2_upc_enabled>checked="checked"</cfif> >#myFusebox.getApplicationData().defaults.trans("yes")#
						<input type="radio" name="set2_upc_enabled" value="false" <cfif !prefs.set2_upc_enabled>checked="checked"</cfif> >#myFusebox.getApplicationData().defaults.trans("no")#
					</td>
				</tr>
			
				<tr class="list" #csshide#>
					<td colspan="2"><br /></td>
				</tr>

			<!--- Image Settings --->
			<tr>
				<th class="textbold" colspan="2">#myFusebox.getApplicationData().defaults.trans("image_settings")#</th>
			</tr>
			<tr>
				<td colspan="2">
					<table border="0" width="100%">
						<!--- Image Formats --->
						<tr>
							<th class="textbold">#myFusebox.getApplicationData().defaults.trans("header_img_format")#</th>
							<th class="textbold">#myFusebox.getApplicationData().defaults.trans("header_img_size")#</th>
						</tr>
						<tr>
							<td>#myFusebox.getApplicationData().defaults.trans("header_img_format_desc")#</td>
							<td>#myFusebox.getApplicationData().defaults.trans("header_thumbnail_size_desc")#</td>
						</tr>
						<tr>
							<td>
								<select name="set2_img_format" class="text">
								<option value="jpg"<cfif prefs.set2_img_format EQ "jpg"> selected</cfif>>JPG</option>
								<option value="gif"<cfif prefs.set2_img_format EQ "gif"> selected</cfif>>GIF</option>
								<option value="png"<cfif prefs.set2_img_format EQ "PNG"> selected</cfif>>PNG</option>
								</select>
							</td>
							<td>
								#myFusebox.getApplicationData().defaults.trans("width")# <input type="text" name="set2_img_thumb_width" size="4" maxlength="3" value="#prefs.set2_img_thumb_width#" /> #myFusebox.getApplicationData().defaults.trans("heigth")# <input type="text" name="set2_img_thumb_heigth" size="4" maxlength="3" value="#prefs.set2_img_thumb_heigth#" />
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<strong>#myFusebox.getApplicationData().defaults.trans("image_settings_colorspace_header")#</strong>
					<br />
					#myFusebox.getApplicationData().defaults.trans("image_settings_colorspace_desc")#
					<br /><br />
					<input type="radio" name="set2_colorspace_RGB" value="false" <cfif prefs.set2_colorspace_rgb eq 'false' or prefs.set2_colorspace_rgb eq ''> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("image_settings_colorspace_off")#
					<br />
					<input type="radio" name="set2_colorspace_RGB" value="true" <cfif prefs.set2_colorspace_rgb eq 'true'> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("image_settings_colorspace_on")#
				</td>
			</tr>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>
			<tr>
				<td colspan="2">
					<strong>#myFusebox.getApplicationData().defaults.trans("meta_export_header")#</strong>
					<br />
					#myFusebox.getApplicationData().defaults.trans("meta_export_desc")#
					<br /><br />
					<input type="radio" name="set2_meta_export" value="t" <cfif prefs.set2_meta_export eq 't'> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("yes")#
					<br/>
					<input type="radio" name="set2_meta_export" value="f" <cfif prefs.set2_meta_export eq 'f' or prefs.set2_meta_export eq ''> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#
					
				</td>
			</tr>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>
			<!--- RAZ-2837 Adding additional rendition will copy the metadata from original file --->
			<tr>
				<td colspan="2">
					<strong>#myFusebox.getApplicationData().defaults.trans("image_settings_rendition_header")#</strong>
					<br /><br/>
					<strong>#myFusebox.getApplicationData().defaults.trans("image_settings_rendition_desc")#</strong>
					<br />
					#myFusebox.getApplicationData().defaults.trans("image_settings_rendition_subdesc")#
					<br /><br />
					<input type="radio" name="set2_rendition_metadata" value="false" <cfif prefs.set2_rendition_metadata eq 'false' or prefs.set2_rendition_metadata eq ''> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("image_settings_rendition_off")#
					<br />
					<input type="radio" name="set2_rendition_metadata" value="true" <cfif prefs.set2_rendition_metadata eq 'true'> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("image_settings_rendition_on")#
				</td>
			</tr>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>
			<!--- RAZ-2519 Download option with their custom filename --->
			<tr>
				<th class="textbold" colspan="2">#myFusebox.getApplicationData().defaults.trans("custom_filename_header")#</th>
			</tr>
			<tr>
				<td colspan="2">#myFusebox.getApplicationData().defaults.trans("custom_filename_desc")#</td>
			</tr>
			<tr>
				<td colspan="2">
					<input type="radio" name="set2_custom_file_ext" value="true" <cfif prefs.set2_custom_file_ext eq 'true'>checked="checked"</cfif><br />#myFusebox.getApplicationData().defaults.trans("custom_filename_off")#<br /> 
					<input type="radio" name="set2_custom_file_ext" value="false" <cfif prefs.set2_custom_file_ext eq 'false' or prefs.set2_custom_file_ext eq ''>checked="checked"</cfif><br />#myFusebox.getApplicationData().defaults.trans("custom_filename_on")#
				</td>
			</tr>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>

			<!--- Languages --->
			<tr>
				<th colspan="2">#myFusebox.getApplicationData().defaults.trans("choose_language")# - <a href="##" onclick="loadcontent('admin_settings','#myself#c.isp_settings_updatelang');return false;">#myFusebox.getApplicationData().defaults.trans("language_update")#</a></th>
			</tr>
			<tr>
				<td colspan="2">#myFusebox.getApplicationData().defaults.trans("language_update_desc")#</td>
			</tr>
			<cfloop query="qry_langs">
				<tr>
					<td colspan="2"><input type="checkbox" name="lang_active_#lang_id#" value="t"<cfif lang_active EQ "t"> checked</cfif>> #lang_name#</td>
				</tr>
			</cfloop>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>
			<!--- Date --->
			<tr>
				<th class="textbold" colspan="2">#myFusebox.getApplicationData().defaults.trans("date")#</th>
			</tr>
			<tr>
				<td width="80px">#myFusebox.getApplicationData().defaults.trans("date_format")#</td>
				<td><select name="set2_date_format" class="text">
				<option value="euro"<cfif #prefs.set2_date_format# EQ "euro"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("date_euro")#</option>
				<option value="us"<cfif #prefs.set2_date_format# EQ "us"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("date_us")#</option>
				<option value="sql"<cfif #prefs.set2_date_format# EQ "sql"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("date_sql")#</option>
				</select></td>
			</tr>
			<tr>
				<td width="80px">#myFusebox.getApplicationData().defaults.trans("date_delimiter")#</td>
				<td><select name="set2_date_format_del" class="text">
				<option value="/"<cfif #prefs.set2_date_format_del# EQ "/"> selected</cfif>>/</option>
				<option value="."<cfif #prefs.set2_date_format_del# EQ "."> selected</cfif>>.</option>
				<option value=","<cfif #prefs.set2_date_format_del# EQ ","> selected</cfif>>,</option>
				<option value="-"<cfif #prefs.set2_date_format_del# EQ "-"> selected</cfif>>-</option>
				<option value=":"<cfif #prefs.set2_date_format_del# EQ ":"> selected</cfif>>:</option>
				</select></td>
			</tr>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>
		</table>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr><th class="textbold" colspan="2">SAML SSO</th></tr>
			<tr><td colspan="2">#myFusebox.getApplicationData().defaults.trans("saml_desc")#</td></tr>
			<tr>
				<td width="120px">SAML Email Path</td>
				<td><input type="text" name="set2_saml_email" value="#prefs.set2_saml_xmlpath_email#" style="width:80%" placeholder="#myFusebox.getApplicationData().defaults.trans("saml_email_placeholder")#"></td>
			</tr>
			<tr>
				<td>SAML Password Path</td>
				<td><input type="text" name="set2_saml_password" value="#prefs.set2_saml_xmlpath_password#" style="width:80%"  placeholder="#myFusebox.getApplicationData().defaults.trans("saml_password_placeholder")#"></td>
			</tr>
			<tr>
				<td>SAML HTTP Re-direct</td>
				<td><input type="text" name="set2_saml_redirect" value="#prefs.set2_saml_httpredirect#" style="width:80%"  placeholder="#myFusebox.getApplicationData().defaults.trans("saml_http_placeholder")#"></td>
			</tr>
			<tr>
				<td colspan="2" align="right"><div id="form_admin_settings_status" style="float:left;font-weight:bold;color:green;"></div><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></td>
			</tr>
		</table>
	</form>
	<br />
	<!--- JS --->
	<script language="JavaScript" type="text/javascript">
		// Submit Form
		$("##form_admin_settings").submit(function(e){
			// Get values
			var url = formaction("form_admin_settings");
			var items = formserialize("form_admin_settings");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
			   		$('##form_admin_settings_status').html('#myFusebox.getApplicationData().defaults.trans("success")#').animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
			return false;
		});
	</script>	
</cfoutput>