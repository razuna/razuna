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
				<th class="textbold" colspan="2">Check for duplicate assets</th>
			</tr>
			<tr>
				<td colspan="2">It is good practice to let Razuna check for the same file, but in case you want or even need to have duplicate records within Razuna you have the option to turn this functionality off below.</td>
			</tr>
			<tr>
				<td colspan="2"><input type="radio" name="set2_md5check" value="true"<cfif prefs.set2_md5check> checked="checked"</cfif> />Check for duplicate assets (recommended)<br /><input type="radio" name="set2_md5check" value="false"<cfif !prefs.set2_md5check> checked="checked"</cfif> />Do not check for duplicate records (allow to store the same asset within Razuna, even multiple times)</td>
			</tr>
			<!--- Image Formats --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("header_img_format")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_img_format_desc")#</td>
			</tr>
			<tr>
				<td colspan="2"><select name="set2_img_format" class="text">
				<option value="jpg"<cfif prefs.set2_img_format EQ "jpg"> selected</cfif>>JPG</option>
				<option value="gif"<cfif prefs.set2_img_format EQ "gif"> selected</cfif>>GIF</option>
				<option value="png"<cfif prefs.set2_img_format EQ "PNG"> selected</cfif>>PNG</option>
				</select></td>
			</tr>
			<!--- Image Sizes --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("header_img_size")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("header_thumbnail_size_desc")#</td>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("width")# <input type="text" name="set2_img_thumb_width" size="4" maxlength="3" value="#prefs.set2_img_thumb_width#" /> #defaultsObj.trans("heigth")# <input type="text" name="set2_img_thumb_heigth" size="4" maxlength="3" value="#prefs.set2_img_thumb_heigth#" /></td>
			</tr>
			<!--- Date --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("date")#</th>
			</tr>
			<tr>
				<td nowrap="nowrap">#defaultsObj.trans("date_format")#</td>
				<td colspan="2"><select name="set2_date_format" class="text">
				<option value="euro"<cfif #prefs.set2_date_format# EQ "euro"> selected</cfif>>#defaultsObj.trans("date_euro")#</option>
				<option value="us"<cfif #prefs.set2_date_format# EQ "us"> selected</cfif>>#defaultsObj.trans("date_us")#</option>
				<option value="sql"<cfif #prefs.set2_date_format# EQ "sql"> selected</cfif>>#defaultsObj.trans("date_sql")#</option>
				</select></td>
			</tr>
			<tr>
				<td nowrap="nowrap">#defaultsObj.trans("date_delimiter")#</td>
				<td colspan="2"><select name="set2_date_format_del" class="text">
				<option value="/"<cfif #prefs.set2_date_format_del# EQ "/"> selected</cfif>>/</option>
				<option value="."<cfif #prefs.set2_date_format_del# EQ "."> selected</cfif>>.</option>
				<option value=","<cfif #prefs.set2_date_format_del# EQ ","> selected</cfif>>,</option>
				<option value="-"<cfif #prefs.set2_date_format_del# EQ "-"> selected</cfif>>-</option>
				<option value=":"<cfif #prefs.set2_date_format_del# EQ ":"> selected</cfif>>:</option>
				</select></td>
			</tr>
			<!--- email settings for new registration from site --->
			<tr>
				<th colspan="2" class="textbold">#defaultsObj.trans("intranet_new_registration")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("intranet_new_registration_desc")#</td>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("intranet_new_registration_emails")#</td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="set2_intranet_reg_emails" size="60" value="#prefs.set2_intranet_reg_emails#" /><br /><i>#defaultsObj.trans("multiple_emails")#</i></td>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("intranet_new_registration_email_subject")#</td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="set2_intranet_reg_emails_sub" size="60" value="#prefs.set2_intranet_reg_emails_sub#" /></td>
			</tr>
			<!--- Languages --->
			<tr>
				<th colspan="2">#defaultsObj.trans("choose_language")# - <a href="##" onclick="loadcontent('admin_settings','#myself#c.isp_settings_updatelang');">#defaultsObj.trans("language_update")#</a></th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("language_update_desc")#</td>
			</tr>
			<cfloop query="qry_langs">
				<tr>
					<td width="1%" nowrap="true" aling="center"><input type="checkbox" name="lang_active_#lang_id#" value="t"<cfif lang_active EQ "t"> checked</cfif>></td>
					<td width="100%">#lang_name#</td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="2" align="right"><div id="form_admin_settings_status" style="float:left;font-weight:bold;color:green;"></div><input type="submit" name="submit" value="#defaultsObj.trans("button_save")#" class="button"></td>
			</tr>
			<tr class="list">
				<td colspan="2"><br /></td>
			</tr>
		</table>
	</form>
	<br />
	<!--- Upload Logo --->
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th>#defaultsObj.trans("logo_header")#</th>
		</tr>
		<tr>
			<td>#defaultsObj.trans("logo_desc")#</td>
		</tr>
		<tr>
			<td>
				<div id="iframe">
					<iframe src="#myself#ajax.isp_settings_upload" frameborder="false" scrolling="false" style="border:0px;width:550px;height:50px;"></iframe>
		       	</div>
			</td>
		</tr>
		<tr>
			<td><div id="loadlogo"></div></td>
		</tr>
		<tr>
			<td valign="top"><a href="##" onclick="loadcontent('loadlogo','#myself#ajax.prefs_loadlogo');">Refresh</a> | <a href="##" onclick="loadcontent('loadlogo','#myself#ajax.prefs_loadlogo&remove=t');">Remove Logo</a></td>
		</tr>
	</table>
	<!--- Load Logo --->
	<script language="JavaScript" type="text/javascript">
		// Load Logo
		loadcontent('loadlogo','#myself#ajax.prefs_loadlogo');
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
			   		$('##form_admin_settings_status').html('#defaultsObj.trans("success")#').animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
			return false;
		});
	</script>	
</cfoutput>