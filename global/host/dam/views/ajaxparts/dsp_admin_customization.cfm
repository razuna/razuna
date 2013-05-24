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
	<cfif session.hosttype EQ 0>
		This section allows you to customize Razuna to your needs like hiding tabs, or other aspects or it.<br><br>
		<cfinclude template="dsp_host_upgrade.cfm">
	<cfelse>
		<div>#myFusebox.getApplicationData().defaults.trans("header_customization_desc")#<br /><br /><a href="http://wiki.razuna.com/display/ecp/Tenant+Customization" target="_blank">Read the documentation!</a></div>
		<form name="form_admin_custom" id="form_admin_custom" method="post" action="#self#?#theaction#=c.admin_customization_save">
		<input type="hidden" name="folder_redirect" value="#qry_customization.folder_redirect#" >
		<div id="status_custom_1" style="float:left;padding-top:5px;"></div><div style="float:right;"><cfif Request.securityobj.CheckSystemAdminUser()><input type="checkbox" name="apply_global" value="true"> <em style="padding-right:20px;">Apply to all tenants</em> </cfif><input type="submit" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" class="button" /></div>
		<div style="clear:both;"><br /></div>
		<div id="customization" class="collapsable">
			<!--- Logo and images --->
			<a href="##" onclick="$('##logoimage').slideToggle('slow');return false;"><div class="headers">&gt; Logo and login image</div></a>
			<div id="logoimage" style="display:none;padding-top:10px;">
				<!--- Upload Logo --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th colspan="2">#myFusebox.getApplicationData().defaults.trans("logo_header")#</th>
					</tr>
					<tr>
						<td colspan="2">#myFusebox.getApplicationData().defaults.trans("logo_desc")#</td>
					</tr>
					<tr class="list">
						<td valign="top">
							<div id="iframe" valign="top">
								<iframe src="#myself#ajax.isp_settings_upload" frameborder="false" scrolling="false" style="border:0px;width:550px;height:70px;"></iframe>
					       	</div>
						</td>
						<td valign="top">
							<div id="loadlogo"></div>
						</td>
						<td valign="top" nowrap="nowrap">
							<a href="##" onclick="$('##loadlogo').load('#myself#ajax.prefs_loadlogo');return false;">Refresh</a> | <a href="##" onclick="$('##loadlogo').load('#myself#ajax.prefs_loadlogo&remove=t');">Remove</a>
						</td>
					</tr>
				</table>
				<!--- Upload Login Image --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th colspan="2">#myFusebox.getApplicationData().defaults.trans("login_image_header")#</th>
					</tr>
					<tr>
						<td colspan="2">#myFusebox.getApplicationData().defaults.trans("login_image_desc")#</td>
					</tr>
					<tr class="list">
						<td valign="top">
							<div id="iframeimg">
								<iframe src="#myself#ajax.isp_settings_upload&loginimg=true" frameborder="false" scrolling="false" style="border:0px;width:550px;height:70px;"></iframe>
					       	</div>
						</td>
						<td valign="top">
							<div id="loadloginimage"></div>
						</td>
						<td valign="top" nowrap="nowrap">
							<a href="##" onclick="$('##loadloginimage').load('#myself#ajax.prefs_loadloginimg');return false;">Refresh</a> | <a href="##" onclick="$('##loadloginimage').load('#myself#ajax.prefs_loadloginimg&remove=t');">Remove</a>
						</td>
					</tr>
				</table>
				<!--- Upload Favicon Image --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th colspan="2">#myFusebox.getApplicationData().defaults.trans("favicon_header")#</th>
					</tr>
					<tr>
						<td colspan="2">#myFusebox.getApplicationData().defaults.trans("favicon_desc")#</td>
					</tr>
					<tr>
						<td valign="top">
							<div id="iframe" valign="top">
								<iframe src="#myself#ajax.isp_settings_upload&favicon=true" frameborder="false" scrolling="false" style="border:0px;width:550px;height:70px;"></iframe>
					       	</div>
						</td>
						<td valign="top">
							<div id="loadfaviconimage"></div>
						</td>
						<td valign="top" nowrap="nowrap">
							<a href="##" onclick="$('##loadfaviconimage').load('#myself#ajax.prefs_loadfavicon');return false;">Refresh</a> | <a href="##" onclick="$('##loadfaviconimage').load('#myself#ajax.prefs_loadfavicon&remove=t');">Remove</a>
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
			
			<!--- User options --->
			<a href="##" onclick="$('##useroptions').slideToggle('slow');return false;"><div class="headers">&gt; User Options</div></a>
			<div id="useroptions" style="display:none;padding-top:10px;">
				<!--- User --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>User Options</th>
					</tr>
					<tr>
						<td>
							#myFusebox.getApplicationData().defaults.trans("custom_users_desc")#
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("custom_users_redirect")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_users_redirect_desc")#
							<br />
							<div>
							<input type="text" name="folder_name" size="25" disabled="true" value="#qry_foldername#" /> <a href="##" onclick="showwindow('#myself#c.admin_customization_choose_folder','#myFusebox.getApplicationData().defaults.trans("choose_location")#',600,1);return false;">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_task_folder_cap")#</a>
							<br />
							<input type="checkbox" name="folder_redirect_off" value="true"> #myFusebox.getApplicationData().defaults.trans("custom_users_redirect_off")#
							</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("custom_users_myfolder")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_users_myfolder_desc")#
							<br />
							<div><input type="radio" name="myfolder_create" value="true"<cfif qry_customization.myfolder_create> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("enabled")# <input type="radio" name="myfolder_create" value="false"<cfif !qry_customization.myfolder_create> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("disabled")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("custom_users_myfolder_upload")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_users_myfolder_upload_desc")#
							<br />
							<div><input type="radio" name="myfolder_upload" value="true"<cfif qry_customization.myfolder_upload> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("enabled")# <input type="radio" name="myfolder_upload" value="false"<cfif !qry_customization.myfolder_upload> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("disabled")#</div>
							<br />
							<!--- Request access --->
							<strong>#myFusebox.getApplicationData().defaults.trans("custom_users_request_access")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_users_request_access_desc")#
							<br />
							<div><input type="radio" name="request_access" value="true"<cfif qry_customization.request_access> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("enabled")# <input type="radio" name="request_access" value="false"<cfif !qry_customization.request_access> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("disabled")#</div>
							<br />
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Designs --->
			<a href="##" onclick="$('##designs').slideToggle('slow');return false;"><div class="headers">&gt; Design</div></a>
			<div id="designs" style="display:none;padding-top:10px;">
				<!--- Design --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>Design</th>
					</tr>
					<tr class="list">
						<td>
							#myFusebox.getApplicationData().defaults.trans("header_customization_design_desc")#
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_design_top_part")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_design_top_part_desc")#
							<br />
							<div><input type="radio" name="show_top_part" value="true"<cfif qry_customization.show_top_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_top_part" value="false"<cfif !qry_customization.show_top_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_design_bottom_part")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_design_bottom_part_desc")#
							<br />
							<div><input type="radio" name="show_bottom_part" value="true"<cfif qry_customization.show_bottom_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_bottom_part" value="false"<cfif !qry_customization.show_bottom_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
						</td>
					</tr>
				</table>
				<!--- General --->
				<!--- <table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("header_customization_general")#</th>
					</tr>
					<tr class="list">
						<td>
							#myFusebox.getApplicationData().defaults.trans("header_customization_general_desc")#
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_general_twitter")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_general_twitter_desc")#
							<br />
							<div><input type="radio" name="show_twitter" value="true"<cfif qry_customization.show_twitter> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_twitter" value="false"<cfif !qry_customization.show_twitter> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_general_twitter_tab")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_general_twitter_tab_desc")#
							<br />
							<div><input type="radio" name="tab_twitter" value="true"<cfif qry_customization.tab_twitter> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_twitter" value="false"<cfif !qry_customization.tab_twitter> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_general_fb")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_general_fb_desc")#
							<br />
							<div><input type="radio" name="show_facebook" value="true"<cfif qry_customization.show_facebook> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_facebook" value="false"<cfif !qry_customization.show_facebook> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_general_fb_tab")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_general_fb_tab_desc")#
							<br />
							<div><input type="radio" name="tab_facebook" value="true"<cfif qry_customization.tab_facebook> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_facebook" value="false"<cfif !qry_customization.tab_facebook> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_general_raz_blog")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_general_raz_blog_desc")#
							<br />
							<div><input type="radio" name="tab_razuna_blog" value="true"<cfif qry_customization.tab_razuna_blog> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_razuna_blog" value="false"<cfif !qry_customization.tab_razuna_blog> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_general_raz_support")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_general_raz_support_desc")#
							<br />
							<div><input type="radio" name="tab_razuna_support" value="true"<cfif qry_customization.tab_razuna_support> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_razuna_support" value="false"<cfif !qry_customization.tab_razuna_support> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
						</td>
					</tr>
				</table> --->
				<!--- Explorer --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("header_customization_explorer")#</th>
					</tr>
					<tr>
						<td>
							#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_desc")#
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_collections")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_collections_desc")#
							<br />
							<div><input type="radio" name="tab_collections" value="true"<cfif qry_customization.tab_collections> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_collections" value="false"<cfif !qry_customization.tab_collections> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_labels")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_labels_desc")#
							<br />
							<div><input type="radio" name="tab_labels" value="true"<cfif qry_customization.tab_labels> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_labels" value="false"<cfif !qry_customization.tab_labels> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Upload --->
			<a href="##" onclick="$('##uploadoptions').slideToggle('slow');return false;"><div class="headers">&gt; Upload</div></a>
			<div id="uploadoptions" style="display:none;padding-top:10px;">
				<!--- Upload --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("header_customization_upload")#</th>
					</tr>
					<tr>
						<td>
							#myFusebox.getApplicationData().defaults.trans("header_customization_upload_desc")#
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_server")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_server_desc")#
							<br />
							<div><input type="radio" name="tab_add_from_server" value="true"<cfif qry_customization.tab_add_from_server> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_add_from_server" value="false"<cfif !qry_customization.tab_add_from_server> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_email")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_email_desc")#
							<br />
							<div><input type="radio" name="tab_add_from_email" value="true"<cfif qry_customization.tab_add_from_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_add_from_email" value="false"<cfif !qry_customization.tab_add_from_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_ftp")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_ftp_desc")#
							<br />
							<div><input type="radio" name="tab_add_from_ftp" value="true"<cfif qry_customization.tab_add_from_ftp> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_add_from_ftp" value="false"<cfif !qry_customization.tab_add_from_ftp> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_link")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_link_desc")#
							<br />
							<div><input type="radio" name="tab_add_from_link" value="true"<cfif qry_customization.tab_add_from_link> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_add_from_link" value="false"<cfif !qry_customization.tab_add_from_link> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Shared settings --->
			<a href="##" onclick="$('##sharedoptions').slideToggle('slow');return false;"><div class="headers">&gt; Shared Folder/Collection Options</div></a>
			<div id="sharedoptions" style="display:none;padding-top:10px;">
				<!--- Share --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<td>
							#myFusebox.getApplicationData().defaults.trans("custom_sharedoptions_desc")#
							<br /><br />
							#myFusebox.getApplicationData().defaults.trans("custom_share_folder")#
							<br />
							<div><input type="radio" name="share_folder" value="true"<cfif qry_customization.share_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="share_folder" value="false"<cfif !qry_customization.share_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_share_download_thumb")#
							<br />
							<div><input type="radio" name="share_download_thumb" value="true"<cfif qry_customization.share_download_thumb> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="share_download_thumb" value="false"<cfif !qry_customization.share_download_thumb> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_share_download_originals")#
							<br />
							<div><input type="radio" name="share_download_original" value="true"<cfif qry_customization.share_download_original> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="share_download_original" value="false"<cfif !qry_customization.share_download_original> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_share_comments")#
							<br />
							<div><input type="radio" name="share_comments" value="true"<cfif qry_customization.share_comments> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="share_comments" value="false"<cfif !qry_customization.share_comments> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("custom_share_uploading")#
							<br />
							<div><input type="radio" name="share_uploading" value="true"<cfif qry_customization.share_uploading> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="share_uploading" value="false"<cfif !qry_customization.share_uploading> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Folder View --->
			<a href="##" onclick="$('##folderview').slideToggle('slow');return false;"><div class="headers">&gt; Folderview</div></a>
			<div id="folderview" style="display:none;padding-top:10px;">
				<!--- Folder View --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview")#</th>
					</tr>
					<tr>
						<td>
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_desc")#
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_images")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_images_desc")#
							<br />
							<div><input type="radio" name="tab_images" value="true"<cfif qry_customization.tab_images> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_images" value="false"<cfif !qry_customization.tab_images> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_videos")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_videos_desc")#
							<br />
							<div><input type="radio" name="tab_videos" value="true"<cfif qry_customization.tab_videos> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_videos" value="false"<cfif !qry_customization.tab_videos> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_audios")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_audios_desc")#
							<br />
							<div><input type="radio" name="tab_audios" value="true"<cfif qry_customization.tab_audios> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_audios" value="false"<cfif !qry_customization.tab_audios> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_other")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_other_desc")#
							<br />
							<div><input type="radio" name="tab_other" value="true"<cfif qry_customization.tab_other> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_other" value="false"<cfif !qry_customization.tab_other> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_pdf")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_pdf_desc")#
							<br />
							<div><input type="radio" name="tab_pdf" value="true"<cfif qry_customization.tab_pdf> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_pdf" value="false"<cfif !qry_customization.tab_pdf> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_doc")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_doc_desc")#
							<br />
							<div><input type="radio" name="tab_doc" value="true"<cfif qry_customization.tab_doc> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_doc" value="false"<cfif !qry_customization.tab_doc> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_xls")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_tab_xls_desc")#
							<br />
							<div><input type="radio" name="tab_xls" value="true"<cfif qry_customization.tab_xls> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_xls" value="false"<cfif !qry_customization.tab_xls> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_select")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_select_desc")#
							<br />
							<div><input type="radio" name="icon_select" value="true"<cfif qry_customization.icon_select> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_select" value="false"<cfif !qry_customization.icon_select> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_refresh")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_refresh_desc")#
							<br />
							<div><input type="radio" name="icon_refresh" value="true"<cfif qry_customization.icon_refresh> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_refresh" value="false"<cfif !qry_customization.icon_refresh> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_show_subfolder")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_show_subfolder_desc")#
							<br />
							<div><input type="radio" name="icon_show_subfolder" value="true"<cfif qry_customization.icon_show_subfolder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_show_subfolder" value="false"<cfif !qry_customization.icon_show_subfolder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_create_subfolder")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_create_subfolder_desc")#
							<br />
							<div><input type="radio" name="icon_create_subfolder" value="true"<cfif qry_customization.icon_create_subfolder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_create_subfolder" value="false"<cfif !qry_customization.icon_create_subfolder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_favorite_folder")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_favorite_folder_desc")#
							<br />
							<div><input type="radio" name="icon_favorite_folder" value="true"<cfif qry_customization.icon_favorite_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_favorite_folder" value="false"<cfif !qry_customization.icon_favorite_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_search")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_search_desc")#
							<br />
							<div><input type="radio" name="icon_search" value="true"<cfif qry_customization.icon_search> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_search" value="false"<cfif !qry_customization.icon_search> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_print")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_print_desc")#
							<br />
							<div><input type="radio" name="icon_print" value="true"<cfif qry_customization.icon_print> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_print" value="false"<cfif !qry_customization.icon_print> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_rss")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_rss_desc")#
							<br />
							<div><input type="radio" name="icon_rss" value="true"<cfif qry_customization.icon_rss> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_rss" value="false"<cfif !qry_customization.icon_rss> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_word")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_word_desc")#
							<br />
							<div><input type="radio" name="icon_word" value="true"<cfif qry_customization.icon_word> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_word" value="false"<cfif !qry_customization.icon_word> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_import")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_import_desc")#
							<br />
							<div><input type="radio" name="icon_metadata_import" value="true"<cfif qry_customization.icon_metadata_import> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_metadata_import" value="false"<cfif !qry_customization.icon_metadata_import> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_export")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_export_desc")#
							<br />
							<div><input type="radio" name="icon_metadata_export" value="true"<cfif qry_customization.icon_metadata_export> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_metadata_export" value="false"<cfif !qry_customization.icon_metadata_export> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_download_folder")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_download_folder_desc")#
							<br />
							<div><input type="radio" name="icon_download_folder" value="true"<cfif qry_customization.icon_download_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_download_folder" value="false"<cfif !qry_customization.icon_download_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Detail View --->
			<a href="##" onclick="$('##detailview').slideToggle('slow');return false;"><div class="headers">&gt; File Detail</div></a>
			<div id="detailview" style="display:none;padding-top:10px;">
				<!--- Asset View --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview")#</th>
					</tr>
					<tr>
						<td>
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_desc")#
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_metadata")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_metadata_desc")#
							<br />
							<div><input type="radio" name="tab_metadata" value="true"<cfif qry_customization.tab_metadata> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_metadata" value="false"<cfif !qry_customization.tab_metadata> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<!--- <br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_description_keywords")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_description_keywords_desc")#
							<br />
							<div><input type="radio" name="tab_description_keywords" value="true"<cfif qry_customization.tab_description_keywords> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_description_keywords" value="false"<cfif !qry_customization.tab_description_keywords> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_custom_fields")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_custom_fields_desc")#
							<br />
							<div><input type="radio" name="tab_custom_fields" value="true"<cfif qry_customization.tab_custom_fields> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_custom_fields" value="false"<cfif !qry_customization.tab_custom_fields> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div> --->
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_convert_files")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_convert_files_desc")#
							<br />
							<div><input type="radio" name="tab_convert_files" value="true"<cfif qry_customization.tab_convert_files> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_convert_files" value="false"<cfif !qry_customization.tab_convert_files> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_comments")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_comments_desc")#
							<br />
							<div><input type="radio" name="tab_comments" value="true"<cfif qry_customization.tab_comments> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_comments" value="false"<cfif !qry_customization.tab_comments> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<!--- <br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_metadata")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_metadata_desc")#
							<br />
							<div><input type="radio" name="tab_metadata" value="true"<cfif qry_customization.tab_metadata> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_metadata" value="false"<cfif !qry_customization.tab_metadata> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_xmp_description")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_xmp_description_desc")#
							<br />
							<div><input type="radio" name="tab_xmp_description" value="true"<cfif qry_customization.tab_xmp_description> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_xmp_description" value="false"<cfif !qry_customization.tab_xmp_description> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_contact")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_contact_desc")#
							<br />
							<div><input type="radio" name="tab_iptc_contact" value="true"<cfif qry_customization.tab_iptc_contact> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_iptc_contact" value="false"<cfif !qry_customization.tab_iptc_contact> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_contact")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_contact_desc")#
							<br />
							<div><input type="radio" name="tab_iptc_image" value="true"<cfif qry_customization.tab_iptc_image> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_iptc_image" value="false"<cfif !qry_customization.tab_iptc_image> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_content")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_content_desc")#
							<br />
							<div><input type="radio" name="tab_iptc_content" value="true"<cfif qry_customization.tab_iptc_content> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_iptc_content" value="false"<cfif !qry_customization.tab_iptc_content> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_content")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_iptc_content_desc")#
							<br />
							<div><input type="radio" name="tab_iptc_status" value="true"<cfif qry_customization.tab_iptc_status> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_iptc_status" value="false"<cfif !qry_customization.tab_iptc_status> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_origin")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_origin_desc")#
							<br />
							<div><input type="radio" name="tab_origin" value="true"<cfif qry_customization.tab_origin> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_origin" value="false"<cfif !qry_customization.tab_origin> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div> --->
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_versions")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_versions_desc")#
							<br />
							<div><input type="radio" name="tab_versions" value="true"<cfif qry_customization.tab_versions> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_versions" value="false"<cfif !qry_customization.tab_versions> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_sharing_options")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_sharing_options_desc")#
							<br />
							<div><input type="radio" name="tab_sharing_options" value="true"<cfif qry_customization.tab_sharing_options> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_sharing_options" value="false"<cfif !qry_customization.tab_sharing_options> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<!--- <br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_preview_images")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_preview_images_desc")#
							<br />
							<div><input type="radio" name="tab_preview_images" value="true"<cfif qry_customization.tab_preview_images> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_preview_images" value="false"<cfif !qry_customization.tab_preview_images> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_additional_renditions")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_additional_renditions_desc")#
							<br />
							<div><input type="radio" name="tab_additional_renditions" value="true"<cfif qry_customization.tab_additional_renditions> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_additional_renditions" value="false"<cfif !qry_customization.tab_additional_renditions> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div> --->
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_history")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_tab_history_desc")#
							<br />
							<div><input type="radio" name="tab_history" value="true"<cfif qry_customization.tab_history> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_history" value="false"<cfif !qry_customization.tab_history> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br /><br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_send_email")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_send_email_desc")#
							<br />
							<div><input type="radio" name="button_send_email" value="true"<cfif qry_customization.button_send_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_send_email" value="false"<cfif !qry_customization.button_send_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_send_ftp")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_send_ftp_desc")#
							<br />
							<div><input type="radio" name="button_send_ftp" value="true"<cfif qry_customization.button_send_ftp> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_send_ftp" value="false"<cfif !qry_customization.button_send_ftp> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_basket")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_basket_desc")#
							<br />
							<div><input type="radio" name="button_basket" value="true"<cfif qry_customization.button_basket> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_basket" value="false"<cfif !qry_customization.button_basket> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_add_to_collection")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_add_to_collection_desc")#
							<br />
							<div><input type="radio" name="button_add_to_collection" value="true"<cfif qry_customization.button_add_to_collection> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_add_to_collection" value="false"<cfif !qry_customization.button_add_to_collection> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_print")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_print_desc")#
							<br />
							<div><input type="radio" name="button_print" value="true"<cfif qry_customization.button_print> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_print" value="false"<cfif !qry_customization.button_print> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<!---
		<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_move")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_move_desc")#
							<br />
							<div><input type="radio" name="button_move" value="true"<cfif qry_customization.button_move> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_move" value="false"<cfif !qry_customization.button_move> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_delete")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_delete_desc")#
							<br />
							<div><input type="radio" name="button_delete" value="true"<cfif qry_customization.button_delete> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_delete" value="false"<cfif !qry_customization.button_delete> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
		--->
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
		</div>

		<div id="status_custom_2" style="float:left;padding-top:5px;"></div><div style="float:right;"><cfif Request.securityobj.CheckSystemAdminUser()><input type="checkbox" name="apply_global" value="true"> <em style="padding-right:20px;">Apply to all tenants</em> </cfif><input type="submit" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" class="button" /></div>
		</form>
		<div style="clear:both;"></div>
		<div id="dummy_maintenance"></div>
		<!--- JS --->
		<script type="text/javascript">
			// Load Logo
			$('##loadlogo').load('#myself#ajax.prefs_loadlogo');
			// Load Login Image
			$('##loadloginimage').load('#myself#ajax.prefs_loadloginimg');
			// Load Favicon Image
			$('##loadfaviconimage').load('#myself#ajax.prefs_loadfavicon');
			// Submit
			$("##form_admin_custom").submit(function(e){
				// Get values
				var url = formaction("form_admin_custom");
				var items = formserialize("form_admin_custom");
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items
				});
				// Feedback
				$('##status_custom_1').fadeTo("fast", 100);
				$('##status_custom_1').html('<span style="font-weight:bold;color:green;">We saved the change successfully!</span>');
				$('##status_custom_1').fadeTo(5000, 0);
				$('##status_custom_2').fadeTo("fast", 100);
				$('##status_custom_2').html('<span style="font-weight:bold;color:green;">We saved the change successfully!</span>');
				$('##status_custom_2').fadeTo(5000, 0);
				return false;
			});
		</script>
	</cfif>
</cfoutput>