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
			<!--- Set the FROM address for emails --->
			<tr>
				<th colspan="2" class="textbold">Set FROM address for eMail messages</th>
			</tr>
			<tr>
				<td colspan="2">Razuna will send out notification, statuses or other relevant eMails to you and your users. By default those message come from "server@razuna.com". If you need to change this you can do so below.</td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="set2_email_from" size="60" value="#prefs.set2_email_from#" /></td>
			</tr>
			<!--- email settings for new registration from site --->
			<tr>
				<th colspan="2" class="textbold">#myFusebox.getApplicationData().defaults.trans("intranet_new_registration")#</th>
			</tr>
			<tr>
				<td colspan="2">#myFusebox.getApplicationData().defaults.trans("intranet_new_registration_desc")#</td>
			</tr>
			<tr>
				<td colspan="2">#myFusebox.getApplicationData().defaults.trans("intranet_new_registration_emails")#</td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="set2_intranet_reg_emails" size="60" value="#prefs.set2_intranet_reg_emails#" /><br /><i>#myFusebox.getApplicationData().defaults.trans("multiple_emails")#</i></td>
			</tr>
			<tr>
				<td colspan="2">#myFusebox.getApplicationData().defaults.trans("intranet_new_registration_email_subject")#</td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="set2_intranet_reg_emails_sub" size="60" value="#prefs.set2_intranet_reg_emails_sub#" /></td>
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
					<td width="1%" nowrap="true" aling="center"><input type="checkbox" name="lang_active_#lang_id#" value="t"<cfif lang_active EQ "t"> checked</cfif>></td>
					<td width="100%">#lang_name#</td>
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
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("date_format")#</td>
				<td colspan="2"><select name="set2_date_format" class="text">
				<option value="euro"<cfif #prefs.set2_date_format# EQ "euro"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("date_euro")#</option>
				<option value="us"<cfif #prefs.set2_date_format# EQ "us"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("date_us")#</option>
				<option value="sql"<cfif #prefs.set2_date_format# EQ "sql"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("date_sql")#</option>
				</select></td>
			</tr>
			<tr>
				<td nowrap="nowrap">#myFusebox.getApplicationData().defaults.trans("date_delimiter")#</td>
				<td colspan="2"><select name="set2_date_format_del" class="text">
				<option value="/"<cfif #prefs.set2_date_format_del# EQ "/"> selected</cfif>>/</option>
				<option value="."<cfif #prefs.set2_date_format_del# EQ "."> selected</cfif>>.</option>
				<option value=","<cfif #prefs.set2_date_format_del# EQ ","> selected</cfif>>,</option>
				<option value="-"<cfif #prefs.set2_date_format_del# EQ "-"> selected</cfif>>-</option>
				<option value=":"<cfif #prefs.set2_date_format_del# EQ ":"> selected</cfif>>:</option>
				</select></td>
			</tr>
			<tr>
				<td colspan="2" align="right"><div id="form_admin_settings_status" style="float:left;font-weight:bold;color:green;"></div><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></td>
			</tr>
			<tr>
				<td colspan="2"><br /></td>
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