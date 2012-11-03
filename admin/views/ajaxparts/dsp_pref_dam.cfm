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
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
	<!--- Path to assets but only if we are not on Oracle --->
	<tr>
		<th colspan="2">#defaultsObj.trans("path_to_assets")#</th>
	</tr>
	<tr>
		<td colspan="2">#defaultsObj.trans("path_to_assets_desc")#</td>
	</tr>
	<tr>
		<td>#defaultsObj.trans("path_to_assets")#</td>
		<td><input type="text" name="set2_path_to_assets" size="60" class="text" value="#prefs.set2_path_to_assets#"></td>
	</tr>
		<!---
<tr>
			<td>#defaultsObj.trans("admin_prefs_asset_path_webroot")#</td>
			<td valign="top"><input type="radio" name="set2_path_to_assets_webroot" value="t"<cfif prefs.set2_path_to_assets_webroot EQ "t"> checked="checked"</cfif>> #defaultsObj.trans("yes")# <input type="radio" name="set2_path_to_assets_webroot" value="f"<cfif prefs.set2_path_to_assets_webroot EQ "f"> checked="checked"</cfif>> #defaultsObj.trans("no")#</td>
		</tr>
--->
	<!--- Logo for Intranet --->
	<!--- <tr>
	<th colspan="2" class="textbold">#defaultsObj.trans("intranet_logo")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("intranet_logo_desc")#</td>
	</tr>
	<tr>
		<td valign="top">Logo</td>
		<td>
			<div id="iframe">
				<iframe src="#myself#c.prefs_imgupload&thefield=set2_intranet_logo" frameborder="false" scrolling="false" style="border:0px;width:550px;height:40px;"></iframe>
	       	</div>
		</td>
	</tr>
	<tr>
		<td valign="top"><a href="##" onclick="loadcontent('loadlogo','#myself#ajax.prefs_loadlogo');">Refresh</a><br /><a href="##" onclick="loadcontent('loadlogo','#myself#ajax.prefs_loadlogo&remove=t');">Remove Logo</a></td>
		<td><div id="loadlogo"></div></td>
	</tr> --->
	<!--- Directories
	<tr>
	<th colspan="2">#defaultsObj.trans("directories")#</th>
	</tr>
	<tr>
	<td valign="top" colspan="2">#defaultsObj.trans("directories_desc")#</td>
	</tr>
	<tr>
	<td valign="top">#defaultsObj.trans("path_incoming")#</td>
	<td valign="top"><input type="text" name="folder_in" size="60" class="text" value="#prefs.set2_ora_path_incoming#"><br /><em>#defaultsObj.trans("path_incoming_desc")#</em></td>
	</tr>
	<tr>
	<td valign="top">#defaultsObj.trans("path_incoming")# BATCH</td>
	<td valign="top"><input type="text" name="folder_in_batch" size="60" class="text" value="#prefs.set2_ora_path_incoming_batch#"><br /><em>#defaultsObj.trans("path_incoming_batch_desc")#</em></td>
	</tr>
	<tr>
	<td valign="top">#defaultsObj.trans("path_outgoing")#</td>
	<td valign="top"><input type="text" name="folder_out" size="60" class="text" value="#prefs.set2_ora_path_outgoing#"><br /><em>#defaultsObj.trans("path_outgoing_desc")#</em></td>
	</tr>
	 --->
	<!--- ORDER BEFORE DOWNLOAD
	<tr>
	<th colspan="2" class="textbold">#defaultsObj.trans("intranet_download_general")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("intranet_download_general_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("intranet_download_general_radio")#</td>
	<td><input type="radio" name="set2_intranet_gen_download" value="T"<cfif #prefs.set2_intranet_gen_download# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="set2_intranet_gen_download" value="F"<cfif #prefs.set2_intranet_gen_download# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
	</tr>
	 --->
	<!--- Download Permissions
	<tr>
	<th colspan="2" class="textbold">#defaultsObj.trans("intranet_download_doc")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("intranet_download_doc_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("intranet_download_doc_radio")#</td>
	<td><input type="radio" name="set2_doc_download" value="T"<cfif #prefs.set2_doc_download# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="set2_doc_download" value="F"<cfif #prefs.set2_doc_download# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
	</tr>
	<tr>
	<th colspan="2" class="textbold">#defaultsObj.trans("intranet_download_img")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("intranet_download_img_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("intranet_download_img_radio")#</td>
	<td><input type="radio" name="set2_img_download_org" value="T"<cfif #prefs.set2_img_download_org# EQ "T"> checked</cfif> /> #defaultsObj.trans("yes")# <input type="radio" name="set2_img_download_org" value="F"<cfif #prefs.set2_img_download_org# EQ "F"> checked</cfif> /> #defaultsObj.trans("no")#</td>
	</tr>
	 --->
	<!--- email settings for new registration from site --->
	<!--- <tr>
	<th colspan="2" class="textbold">#defaultsObj.trans("intranet_new_registration")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("intranet_new_registration_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("intranet_new_registration_emails")#</td>
	<td valign="top"><input type="text" name="set2_intranet_reg_emails" size="60" value="#prefs.set2_intranet_reg_emails#" /><br /><i>#defaultsObj.trans("multiple_emails")#</i></td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("intranet_new_registration_email_subject")#</td>
	<td><input type="text" name="set2_intranet_reg_emails_sub" size="60" value="#prefs.set2_intranet_reg_emails_sub#" /></td>
	</tr>
	</table> --->
	<!--- Load the Logo
	<script language="JavaScript" type="text/javascript">
		loadcontent('loadlogo','#myself#ajax.prefs_loadlogo');
	</script> --->
</cfoutput>