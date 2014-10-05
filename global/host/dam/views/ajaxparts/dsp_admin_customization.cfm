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
		This section allows you to customize Razuna to your needs like hiding tabs, or other aspects of it.<br><br>
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
								<iframe src="#myself#ajax.isp_settings_upload&logoimg=true" frameborder="false" scrolling="false" style="border:0px;width:550px;height:70px;"></iframe>
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
							<input type="text" name="folder_name" size="25" disabled="true" value="#qry_foldername#" /> 
							<button class="button" onclick="showwindow('#myself#c.admin_customization_choose_folder','#myFusebox.getApplicationData().defaults.trans("choose_location")#',600,1);return false;">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_task_folder_cap")#</button>

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
			<a href="##" onclick="$('##designs').slideToggle('slow');$('.chzn4-select').chosen({search_contains: true});return false;"><div class="headers">&gt; Design</div></a>
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
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_design_basket_part")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_design_basket_part_desc")#
							<br />
							<div><input type="radio" name="show_basket_part" value="true"<cfif qry_customization.show_basket_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_basket_part" value="false"<cfif !qry_customization.show_basket_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />

							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_design_favorites_part")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_design_favorites_part_desc")#
							<br />
							<div><input type="radio" name="show_favorites_part" value="true"<cfif qry_customization.show_favorites_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_favorites_part" value="false"<cfif !qry_customization.show_favorites_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
	
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_manage_part")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_manage_part_desc")#
							<br />
							<div><input type="radio" name="show_manage_part" value="true"<cfif qry_customization.show_manage_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_manage_part" value="false"<cfif !qry_customization.show_manage_part> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_manage_part_desc2")#
							<br />
							<select data-placeholder="Choose a group or user" class="chzn4-select" style="width:500px;" name="show_manage_part_slct" id="show_manage_part_slct" multiple="multiple">
							<option value=""></option>
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif listfind(qry_customization.show_manage_part_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#"<cfif listfind(qry_customization.show_manage_part_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
							</select>
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
							<div>
								<input type="radio" name="tab_collections" value="true"<cfif qry_customization.tab_collections> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# 
								<input type="radio" name="tab_collections" value="false"<cfif !qry_customization.tab_collections> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
							</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_labels")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_labels_desc")#
							<br />
							<div>
								<input type="radio" name="tab_labels" value="true"<cfif qry_customization.tab_labels> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")#
								<input type="radio" name="tab_labels" value="false"<cfif !qry_customization.tab_labels> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
							</div>
							<br />
						</td>
					</tr>
					<!--- RAZ-2267 Set the default explorer section for folder, smart folders, labels or collections ---> 
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("header_customization_explorer_default")#</th>
					</tr>
					<tr>
						<td>
							<div>
								<input type="radio" name="tab_explorer_default" value="1" <cfif qry_customization.tab_explorer_default EQ 1> checked="checked"</cfif>/>#myFusebox.getApplicationData().defaults.trans("customization_explorer_folder")#<br />
							 	<input type="radio" name="tab_explorer_default" class="collection_tab"  value="2" <cfif qry_customization.tab_explorer_default EQ 2> checked="checked"</cfif>/>#myFusebox.getApplicationData().defaults.trans("customization_explorer_collections")#<br />
								<input type="radio" name="tab_explorer_default" value="3" <cfif qry_customization.tab_explorer_default EQ 3> checked="checked"</cfif>/>#myFusebox.getApplicationData().defaults.trans("customization_explorer_smartfolder")#<br />
								<input type="radio" name="tab_explorer_default" class="label_tab"  value="4" <cfif qry_customization.tab_explorer_default EQ 4> checked="checked"</cfif>/>#myFusebox.getApplicationData().defaults.trans("customization_explorer_label")#
							 </div>
							<br />
						</td>
					</tr>

					<tr>
						<td>
					<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_trash_icon")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_trash_icon_desc")#
							<br />
							<div><input type="radio" name="show_trash_icon" value="true"<cfif qry_customization.show_trash_icon> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_trash_icon" value="false"<cfif !qry_customization.show_trash_icon> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_trash_icon_desc2")#
							<br />
							<select data-placeholder="Choose a group or user" class="chzn4-select" style="width:500px;" name="show_trash_icon_slct" id="show_trash_icon_slct" multiple="multiple">
							<option value=""></option>
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif listfind(qry_customization.show_trash_icon_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#"<cfif listfind(qry_customization.show_trash_icon_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
							</select>
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
							<!--- <strong>#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_email")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_upload_from_email_desc")#
							<br />
							<div><input type="radio" name="tab_add_from_email" value="true"<cfif qry_customization.tab_add_from_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="tab_add_from_email" value="false"<cfif !qry_customization.tab_add_from_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br /> --->
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
			<a href="##" onclick="$('##folderview').slideToggle('slow');$('.chzn3-select').chosen({search_contains: true});return false;"><div class="headers">&gt; Folderview</div></a>
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
							<strong>Tabs</strong>
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
							<br /><br />
							<strong>Icons</strong>
							<br /><br />
							<!--- Create Alias Icon --->
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_alias")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_alias_desc")#
							<br />
							<div><input type="radio" name="icon_alias" value="true"<cfif qry_customization.icon_alias> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_alias" value="false"<cfif !qry_customization.icon_alias> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("folder_view_icon_desc")# 
							<br/>
							<select data-placeholder="Choose a group or user" class="chzn3-select" style="width:500px;" name="icon_alias_slct" id="icon_alias_slct" multiple="multiple">
							<option value=""></option>
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif listfind(qry_customization.icon_alias_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#"<cfif listfind(qry_customization.icon_alias_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
							</select>
							<br/><br/>

							<!--- Move Icon --->
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_move")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_move_desc")#
							<br />
							<div><input type="radio" name="icon_move" value="true"<cfif qry_customization.icon_move> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_move" value="false"<cfif !qry_customization.icon_move> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("folder_view_icon_desc")# 
							<br/>
							<select data-placeholder="Choose a group or user" class="chzn3-select" style="width:500px;" name="icon_move_slct" id="icon_move_slct" multiple="multiple">
							<option value=""></option>
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif listfind(qry_customization.icon_move_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#"<cfif listfind(qry_customization.icon_move_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
							</select>
							<br/><br/>

							<!--- Batch Icon --->
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_batch")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_batch_desc")#
							<br />
							<div><input type="radio" name="icon_batch" value="true"<cfif qry_customization.icon_batch> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_batch" value="false"<cfif !qry_customization.icon_batch> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("folder_view_icon_desc")# 
							<br/>
							<select data-placeholder="Choose a group or user" class="chzn3-select" style="width:500px;" name="icon_batch_slct" id="icon_batch_slct" multiple="multiple">
							<option value=""></option>
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif listfind(qry_customization.icon_batch_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#"<cfif listfind(qry_customization.icon_batch_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
							</select>
							<br/><br/>

							<!--- Export Metadata Icon --->
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_export")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_export_desc")#
							<br />

							<div><input type="radio" name="icon_metadata_export" value="true"<cfif qry_customization.icon_metadata_export> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_metadata_export" value="false"<cfif !qry_customization.icon_metadata_export> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />

							#myFusebox.getApplicationData().defaults.trans("folder_view_icon_desc")# 
							<br/>
							<select data-placeholder="Choose a group or user" class="chzn3-select" style="width:500px;" name="icon_metadata_export_slct" id="icon_metadata_export_slct" multiple="multiple">
							<option value=""></option>
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif listfind(qry_customization.icon_metadata_export_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#"<cfif listfind(qry_customization.icon_metadata_export_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
							</select>
							<br/><br/>

							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_import")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_metadata_import_desc")#
							<br />
							<div><input type="radio" name="icon_metadata_import" value="true"<cfif qry_customization.icon_metadata_import> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_metadata_import" value="false"<cfif !qry_customization.icon_metadata_import> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("folder_view_icon_desc")# 
							<br/>
							<select data-placeholder="Choose a group or user" class="chzn3-select" style="width:500px;" name="icon_metadata_import_slct" id="icon_metadata_import_slct" multiple="multiple">
							<option value=""></option>
							<cfloop query="qry_groups">
								<option value="#grp_id#"<cfif listfind(qry_customization.icon_metadata_import_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
							</cfloop>
							<cfloop query="qry_users">
								<option value="#user_id#"<cfif listfind(qry_customization.icon_metadata_import_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
							</cfloop>
							</select>
							<br/><br/>

							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_select")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_select_desc")#
							<br />
							<div><input type="radio" name="icon_select" value="true"<cfif qry_customization.icon_select> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_select" value="false"<cfif !qry_customization.icon_select> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<!--- <br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_refresh")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_refresh_desc")#
							<br />
							<div><input type="radio" name="icon_refresh" value="true"<cfif qry_customization.icon_refresh> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_refresh" value="false"<cfif !qry_customization.icon_refresh> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div> --->
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
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_download_folder")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_folderview_icon_download_folder_desc")#
							<br />
							<div><input type="radio" name="icon_download_folder" value="true"<cfif qry_customization.icon_download_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="icon_download_folder" value="false"<cfif !qry_customization.icon_download_folder> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#</div>
							<br />
						</td>
					</tr>
				</table>
				<!--- Select fields for folder view --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th colspan="2">#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_desc")#</th>
					</tr>
					<tr>
						<td colspan="2">
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_assetbox")#
							<br />
							#myFusebox.getApplicationData().defaults.trans("heigth")#: <input type="text" name="assetbox_height" value="#qry_customization.assetbox_height#" size="3" />px<br />
							#myFusebox.getApplicationData().defaults.trans("width")#: <input type="text" name="assetbox_width" value="#qry_customization.assetbox_width#" size="3" />px
							<br /><br />
						</td>
					</tr>

					<tr>
						<td colspan="2">
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_show_metadata_labels")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_show_metadata_labels_desc")#
							<br/>
							<input type="radio" name="show_metadata_labels" value="true"<cfif qry_customization.show_metadata_labels> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="show_metadata_labels" value="false"<cfif !qry_customization.show_metadata_labels> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
							<br /><br />
						</td>
					</tr>

					<tr>
						<td colspan="2">
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_metadata_header")#</strong>
							<br/><br/>
							<em>(#myFusebox.getApplicationData().defaults.trans("multiselect")#)</em>
							<br /><br />
							<!--- IMAGES --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_images")#
						</td>
					</tr>
					<tr>
						<td>
							<select name="images_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- Default values --->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<option value="img_id AS cs_img_id"<cfif listFind(qry_customization.images_metadata,"img_id AS cs_img_id")> selected="selected"</cfif>>ID</option>
								<option value="img_filename AS cs_img_filename"<cfif listFind(qry_customization.images_metadata,"img_filename AS cs_img_filename")> selected="selected"</cfif>>Filename</option>
								<option value="img_description AS cs_img_description"<cfif listFind(qry_customization.images_metadata,"img_description AS cs_img_description")> selected="selected"</cfif>>Description</option>
								<option value="img_keywords AS cs_img_keywords"<cfif listFind(qry_customization.images_metadata,"img_keywords AS cs_img_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="img_create_time AS cs_img_create_time"<cfif listFind(qry_customization.images_metadata,"img_create_time AS cs_img_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="img_change_time AS cs_img_change_time"<cfif listFind(qry_customization.images_metadata,"img_change_time AS cs_img_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="img_width AS cs_img_width"<cfif listFind(qry_customization.images_metadata,"img_width AS cs_img_width")> selected="selected"</cfif>>Width</option>
								<option value="img_height AS cs_img_height"<cfif listFind(qry_customization.images_metadata,"img_height AS cs_img_height")> selected="selected"</cfif>>Height</option>
								<option value="img_size AS cs_img_size"<cfif listFind(qry_customization.images_metadata,"img_size AS cs_img_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_img_expiry_date"<cfif listFind(qry_customization.images_metadata,"expiry_date AS cs_img_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="img_upc_number AS cs_img_upc_number"<cfif listFind(qry_customization.images_metadata,"img_upc_number AS cs_img_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
								<cfloop list="#attributes.meta_img#" index="i">
									<!--- Upper case the first char --->
									<cfset l = len(i) - 1>
									<option value="#i# AS cs_img_#i#"<cfif listFind(qry_customization.images_metadata,"#i# AS cs_img_#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="cf_images_metadata" multiple="multiple" style="width:400px;height:130px;">
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_images")# ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "img" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_images_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<!--- VIDEOS --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_videos")#
						<td>
					</tr>
					<tr>
						<td>
							<select name="videos_metadata" multiple="multiple" style="width:400px;height:130px;">
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<!--- Default values --->
								<option value="vid_id AS cs_vid_id"<cfif listFind(qry_customization.videos_metadata,"vid_id AS cs_vid_id")> selected="selected"</cfif>>ID</option>
								<option value="vid_filename AS cs_vid_filename"<cfif listFind(qry_customization.videos_metadata,"vid_filename AS cs_vid_filename")> selected="selected"</cfif>>Filename</option>
								<option value="vid_description AS cs_vid_description"<cfif listFind(qry_customization.videos_metadata,"vid_description AS cs_vid_description")> selected="selected"</cfif>>Description</option>
								<option value="vid_keywords AS cs_vid_keywords"<cfif listFind(qry_customization.videos_metadata,"vid_keywords AS cs_vid_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="vid_create_time AS cs_vid_create_time"<cfif listFind(qry_customization.videos_metadata,"vid_create_time AS cs_vid_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="vid_change_time AS cs_vid_change_time"<cfif listFind(qry_customization.videos_metadata,"vid_change_time AS cs_vid_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="vid_width AS cs_vid_width"<cfif listFind(qry_customization.videos_metadata,"vid_width AS cs_vid_width")> selected="selected"</cfif>>Width</option>
								<option value="vid_height AS cs_vid_height"<cfif listFind(qry_customization.videos_metadata,"vid_height AS cs_vid_height")> selected="selected"</cfif>>Height</option>
								<option value="vid_size AS cs_vid_size"<cfif listFind(qry_customization.videos_metadata,"vid_size AS cs_vid_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_vid_expiry_date"<cfif listFind(qry_customization.images_metadata,"expiry_date AS cs_vid_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="vid_upc_number AS cs_vid_upc_number"<cfif listFind(qry_customization.videos_metadata,"vid_upc_number AS cs_vid_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
							</select>
						</td>
						<td>
							<select name="cf_videos_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values of videos--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_videos")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "vid" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_videos_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<!--- FILES --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_files")#
						<td>
					</tr>
					<tr>
						<td>
							<select name="files_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- Default values --->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<option value="file_id AS cs_file_id"<cfif listFind(qry_customization.files_metadata,"file_id AS cs_file_id")> selected="selected"</cfif>>ID</option>
								<option value="file_name AS cs_file_filename"<cfif listFind(qry_customization.files_metadata,"file_name AS cs_file_filename")> selected="selected"</cfif>>Filename</option>
								<option value="file_desc AS cs_file_description"<cfif listFind(qry_customization.files_metadata,"file_desc AS cs_file_description")> selected="selected"</cfif>>Description</option>
								<option value="file_keywords AS cs_file_keywords"<cfif listFind(qry_customization.files_metadata,"file_keywords AS cs_file_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="file_create_time AS cs_file_create_time"<cfif listFind(qry_customization.files_metadata,"file_create_time AS cs_file_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="file_change_time AS cs_file_change_time"<cfif listFind(qry_customization.files_metadata,"file_change_time AS cs_file_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="file_size AS cs_file_size"<cfif listFind(qry_customization.files_metadata,"file_size AS cs_file_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_file_expiry_date"<cfif listFind(qry_customization.images_metadata,"expiry_date AS cs_file_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="file_upc_number AS cs_file_upc_number"<cfif listFind(qry_customization.files_metadata,"file_upc_number AS cs_file_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
								<cfloop list="#attributes.meta_doc#" index="i">
									<!--- Upper case the first char --->
									<cfset l = len(i) - 1>
									<option value="#i# AS cs_file_#i#"<cfif listFind(qry_customization.files_metadata,"#i# AS cs_file_#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="cf_files_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values for files--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_files")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "doc" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_files_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<!--- AUDIOS --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_audios")#
						</td>
					</tr>
					<tr>
						<td>
							<select name="audios_metadata" multiple="multiple" style="width:400px;height:130px;">
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<!--- Default values --->
								<option value="aud_id AS cs_aud_id"<cfif listFind(qry_customization.audios_metadata,"aud_id AS cs_aud_id")> selected="selected"</cfif>>ID</option>
								<option value="aud_name AS cs_aud_filename"<cfif listFind(qry_customization.audios_metadata,"aud_name AS cs_aud_filename")> selected="selected"</cfif>>Filename</option>
								<option value="aud_description AS cs_aud_description"<cfif listFind(qry_customization.audios_metadata,"aud_description AS cs_aud_description")> selected="selected"</cfif>>Description</option>
								<option value="aud_keywords AS cs_aud_keywords"<cfif listFind(qry_customization.audios_metadata,"aud_keywords AS cs_aud_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="aud_create_time AS cs_aud_create_time"<cfif listFind(qry_customization.audios_metadata,"aud_create_time AS cs_aud_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="aud_change_time AS cs_aud_change_time"<cfif listFind(qry_customization.audios_metadata,"aud_change_time AS cs_aud_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="aud_size AS cs_aud_size"<cfif listFind(qry_customization.audios_metadata,"aud_size AS cs_aud_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_aud_expiry_date"<cfif listFind(qry_customization.images_metadata,"expiry_date AS cs_aud_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="aud_upc_number AS cs_aud_upc_number"<cfif listFind(qry_customization.audios_metadata,"aud_upc_number AS cs_aud_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
							</select>
						</td>
						<td>
							<select name="cf_audios_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values for audios--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_audios")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "aud" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_audios_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>


					<tr>
						<td colspan="2"><strong>#myFusebox.getApplicationData().defaults.trans("field_placement_header")#</strong></td>
					</tr>

					<tr>
						<td colspan="2">
							<!--- IMAGES --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_images")#
						</td>
					</tr>
					<tr>
						<td>
							<select name="images_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<!--- Default values --->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<option value="img_id AS cs_img_id"<cfif listFind(qry_customization.images_metadata_top,"img_id AS cs_img_id")> selected="selected"</cfif>>ID</option>
								<option value="img_filename AS cs_img_filename"<cfif listFind(qry_customization.images_metadata_top,"img_filename AS cs_img_filename")> selected="selected"</cfif>>Filename</option>
								<option value="img_description AS cs_img_description"<cfif listFind(qry_customization.images_metadata_top,"img_description AS cs_img_description")> selected="selected"</cfif>>Description</option>
								<option value="img_keywords AS cs_img_keywords"<cfif listFind(qry_customization.images_metadata_top,"img_keywords AS cs_img_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="img_create_time AS cs_img_create_time"<cfif listFind(qry_customization.images_metadata_top,"img_create_time AS cs_img_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="img_change_time AS cs_img_change_time"<cfif listFind(qry_customization.images_metadata_top,"img_change_time AS cs_img_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="img_width AS cs_img_width"<cfif listFind(qry_customization.images_metadata_top,"img_width AS cs_img_width")> selected="selected"</cfif>>Width</option>
								<option value="img_height AS cs_img_height"<cfif listFind(qry_customization.images_metadata_top,"img_height AS cs_img_height")> selected="selected"</cfif>>Height</option>
								<option value="img_size AS cs_img_size"<cfif listFind(qry_customization.images_metadata_top,"img_size AS cs_img_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_img_expiry_date"<cfif listFind(qry_customization.images_metadata_top,"expiry_date AS cs_img_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="img_upc_number AS cs_img_upc_number"<cfif listFind(qry_customization.images_metadata_top,"img_upc_number AS cs_img_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
								<cfloop list="#attributes.meta_img#" index="i">
									<!--- Upper case the first char --->
									<cfset l = len(i) - 1>
									<option value="#i# AS cs_img_#i#"<cfif listFind(qry_customization.images_metadata_top,"#i# AS cs_img_#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="cf_images_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_images")# ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "img" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_images_metadata_top,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<!--- VIDEOS --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_videos")#
						<td>
					</tr>
					<tr>
						<td>
							<select name="videos_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<!--- Default values --->
								<option value="vid_id AS cs_vid_id"<cfif listFind(qry_customization.videos_metadata_top,"vid_id AS cs_vid_id")> selected="selected"</cfif>>ID</option>
								<option value="vid_filename AS cs_vid_filename"<cfif listFind(qry_customization.videos_metadata_top,"vid_filename AS cs_vid_filename")> selected="selected"</cfif>>Filename</option>
								<option value="vid_description AS cs_vid_description"<cfif listFind(qry_customization.videos_metadata_top,"vid_description AS cs_vid_description")> selected="selected"</cfif>>Description</option>
								<option value="vid_keywords AS cs_vid_keywords"<cfif listFind(qry_customization.videos_metadata_top,"vid_keywords AS cs_vid_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="vid_create_time AS cs_vid_create_time"<cfif listFind(qry_customization.videos_metadata_top,"vid_create_time AS cs_vid_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="vid_change_time AS cs_vid_change_time"<cfif listFind(qry_customization.videos_metadata_top,"vid_change_time AS cs_vid_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="vid_width AS cs_vid_width"<cfif listFind(qry_customization.videos_metadata_top,"vid_width AS cs_vid_width")> selected="selected"</cfif>>Width</option>
								<option value="vid_height AS cs_vid_height"<cfif listFind(qry_customization.videos_metadata_top,"vid_height AS cs_vid_height")> selected="selected"</cfif>>Height</option>
								<option value="vid_size AS cs_vid_size"<cfif listFind(qry_customization.videos_metadata_top,"vid_size AS cs_vid_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_vid_expiry_date"<cfif listFind(qry_customization.images_metadata_top,"expiry_date AS cs_vid_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="vid_upc_number AS cs_vid_upc_number"<cfif listFind(qry_customization.videos_metadata_top,"vid_upc_number AS cs_vid_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
							</select>
						</td>
						<td>
							<select name="cf_videos_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values of videos--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_videos")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "vid" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_videos_metadata_top,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<!--- FILES --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_files")#
						<td>
					</tr>
					<tr>
						<td>
							<select name="files_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<!--- Default values --->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<option value="file_id AS cs_file_id"<cfif listFind(qry_customization.files_metadata_top,"file_id AS cs_file_id")> selected="selected"</cfif>>ID</option>
								<option value="file_name AS cs_file_filename"<cfif listFind(qry_customization.files_metadata_top,"file_name AS cs_file_filename")> selected="selected"</cfif>>Filename</option>
								<option value="file_desc AS cs_file_description"<cfif listFind(qry_customization.files_metadata_top,"file_desc AS cs_file_description")> selected="selected"</cfif>>Description</option>
								<option value="file_keywords AS cs_file_keywords"<cfif listFind(qry_customization.files_metadata_top,"file_keywords AS cs_file_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="file_create_time AS cs_file_create_time"<cfif listFind(qry_customization.files_metadata_top,"file_create_time AS cs_file_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="file_change_time AS cs_file_change_time"<cfif listFind(qry_customization.files_metadata_top,"file_change_time AS cs_file_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="file_size AS cs_file_size"<cfif listFind(qry_customization.files_metadata_top,"file_size AS cs_file_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_file_expiry_date"<cfif listFind(qry_customization.images_metadata_top,"expiry_date AS cs_file_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="file_upc_number AS cs_file_upc_number"<cfif listFind(qry_customization.files_metadata_top,"file_upc_number AS cs_file_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
								<cfloop list="#attributes.meta_doc#" index="i">
									<!--- Upper case the first char --->
									<cfset l = len(i) - 1>
									<option value="#i# AS cs_file_#i#"<cfif listFind(qry_customization.files_metadata_top,"#i# AS cs_file_#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="cf_files_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values for files--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_files")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "doc" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_files_metadata_top,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>
							<!--- AUDIOS --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_audios")#
						</td>
					</tr>
					<tr>
						<td>
							<select name="audios_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
								<!--- Default values --->
								<option value="aud_id AS cs_aud_id"<cfif listFind(qry_customization.audios_metadata_top,"aud_id AS cs_aud_id")> selected="selected"</cfif>>ID</option>
								<option value="aud_name AS cs_aud_filename"<cfif listFind(qry_customization.audios_metadata_top,"aud_name AS cs_aud_filename")> selected="selected"</cfif>>Filename</option>
								<option value="aud_description AS cs_aud_description"<cfif listFind(qry_customization.audios_metadata_top,"aud_description AS cs_aud_description")> selected="selected"</cfif>>Description</option>
								<option value="aud_keywords AS cs_aud_keywords"<cfif listFind(qry_customization.audios_metadata_top,"aud_keywords AS cs_aud_keywords")> selected="selected"</cfif>>Keywords</option>
								<option value="aud_create_time AS cs_aud_create_time"<cfif listFind(qry_customization.audios_metadata_top,"aud_create_time AS cs_aud_create_time")> selected="selected"</cfif>>Create Date</option>
								<option value="aud_change_time AS cs_aud_change_time"<cfif listFind(qry_customization.audios_metadata_top,"aud_change_time AS cs_aud_change_time")> selected="selected"</cfif>>Change Date</option>
								<option value="aud_size AS cs_aud_size"<cfif listFind(qry_customization.audios_metadata_top,"aud_size AS cs_aud_size")> selected="selected"</cfif>>Size</option>
								<option value="expiry_date AS cs_aud_expiry_date"<cfif listFind(qry_customization.images_metadata_top,"expiry_date AS cs_aud_expiry_date")> selected="selected"</cfif>>Expiry Date</option>
								<cfif prefs.set2_upc_enabled>
								<option value="aud_upc_number AS cs_aud_upc_number"<cfif listFind(qry_customization.audios_metadata_top,"aud_upc_number AS cs_aud_upc_number")> selected="selected"</cfif>>UPC Number</option>
								</cfif>
							</select>
						</td>
						<td>
							<select name="cf_audios_metadata_top" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values for audios--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_audios")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "aud" OR cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.cf_audios_metadata_top,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					
				</table>

			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Detail View --->
			<a href="##" onclick="$('##detailview').slideToggle('slow');$('.chzn2-select').chosen({search_contains: true});return false;"><div class="headers">&gt; File Detail</div></a>
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
							<div>
								<input type="radio" name="button_send_email" value="true"<cfif qry_customization.button_send_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_send_email" value="false"<cfif !qry_customization.button_send_email> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
								<br/><br/>
								#myFusebox.getApplicationData().defaults.trans("file_detail_btn_desc")# 
								<br/>

								<select data-placeholder="Choose a group or user" class="chzn2-select" style="width:500px;" name="btn_email_slct" id="btn_email_slct" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.btn_email_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.btn_email_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
								</select>
							</div>

							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_send_ftp")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_send_ftp_desc")#
							<br />
							<div><input type="radio" name="button_send_ftp" value="true"<cfif qry_customization.button_send_ftp> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_send_ftp" value="false"<cfif !qry_customization.button_send_ftp> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
								<br/><br/>
								#myFusebox.getApplicationData().defaults.trans("file_detail_btn_desc")# 
								<br/>

								<select data-placeholder="Choose a group or user" class="chzn2-select" style="width:500px;" name="btn_ftp_slct" id="btn_ftp_slct" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.btn_ftp_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.btn_ftp_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
								</select>
							</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_basket")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_basket_desc")#
							<br />
							<div><input type="radio" name="button_basket" value="true"<cfif qry_customization.button_basket> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_basket" value="false"<cfif !qry_customization.button_basket> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
								<br/><br/>
								#myFusebox.getApplicationData().defaults.trans("file_detail_btn_desc")# 
								<br/>
								<select data-placeholder="Choose a group or user" class="chzn2-select" style="width:500px;" name="btn_basket_slct" id="btn_basket_slct" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.btn_basket_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.btn_basket_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
								</select>
							</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_add_to_collection")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_add_to_collection_desc")#
							<br />
							<div><input type="radio" name="button_add_to_collection" value="true"<cfif qry_customization.button_add_to_collection> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_add_to_collection" value="false"<cfif !qry_customization.button_add_to_collection> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
								<br/><br/>
								#myFusebox.getApplicationData().defaults.trans("file_detail_btn_desc")# 
								<br/>

								<select data-placeholder="Choose a group or user" class="chzn2-select" style="width:500px;" name="btn_collection_slct" id="btn_collection_slct" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.btn_collection_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.btn_collection_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
								</select>
							</div>
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_print")#</strong>
							<br />
							#myFusebox.getApplicationData().defaults.trans("header_customization_assetview_button_print_desc")#
							<br />
							<div><input type="radio" name="button_print" value="true"<cfif qry_customization.button_print> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("show")# <input type="radio" name="button_print" value="false"<cfif !qry_customization.button_print> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("hide")#
								<br/><br/>
								#myFusebox.getApplicationData().defaults.trans("file_detail_btn_desc")# 
								<br/>

								<select data-placeholder="Choose a group or user" class="chzn2-select" style="width:500px;" name="btn_print_slct" id="btn_print_slct" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.btn_print_slct,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.btn_print_slct,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
								</select>
							</div>
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
							<br />
							<strong>#myFusebox.getApplicationData().defaults.trans("req_fields_desc")#</strong>
							<br />
							<br />
							#myFusebox.getApplicationData().defaults.trans("req_filename")#
							<br />
							<div><input type="radio" name="req_filename" value="true"<cfif qry_customization.req_filename> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="req_filename" value="false"<cfif !qry_customization.req_filename> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("req_description")#
							<br />
							<div><input type="radio" name="req_description" value="true"<cfif qry_customization.req_description> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="req_description" value="false"<cfif !qry_customization.req_description> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
							#myFusebox.getApplicationData().defaults.trans("req_keywords")#
							<br />
							<div><input type="radio" name="req_keywords" value="true"<cfif qry_customization.req_keywords> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="req_keywords" value="false"<cfif !qry_customization.req_keywords> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
							<br />
						</td>
					</tr>
				</table>
				<!--- Select fields to show in info tab of detail view --->
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
					<tr>
						<th>#myFusebox.getApplicationData().defaults.trans("header_customization_customfield_desc")#</th>
					</tr>
					<tr>
						<td>
							<em>(#myFusebox.getApplicationData().defaults.trans("multiselect")#)</em>
							<br /><br />
							<!--- All asset type --->
							All 
							<br />
							<select name="customfield_all_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values for all --->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_all")# ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "all">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.customfield_all_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
							<br />
							<br />
							<!--- IMAGES --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_images")#
							<br />
							<select name="customfield_images_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values of images--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_images")# ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "img">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.customfield_images_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
							<br /><br />
							<!--- VIDEOS --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_videos")#
							<br />
							<select name="customfield_videos_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values of videos--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_videos")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "vid">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.customfield_videos_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
							<br /><br />
							<!--- AUDIOS --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_audios")#
							<br />
							<select name="customfield_audios_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values for audios--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_audios")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "aud">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.customfield_audios_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
							<br /><br />
							<!--- FILES --->
							#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_files")#
							<br />
							<select name="customfield_files_metadata" multiple="multiple" style="width:400px;height:130px;">
								<!--- customfield values for files--->
								<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields_files")#  ---</option>
								<cfloop query="qry_fields">
									<cfif cf_show EQ "doc">
										<option value="#cf_id#" <cfif listFindNoCase(qry_customization.customfield_files_metadata,"#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Basket View --->
			<a href="##" onclick="$('##basketview').slideToggle('slow');$('.chzn-select').chosen({search_contains: true});return false;"><div class="headers">&gt; #myFusebox.getApplicationData().defaults.trans("header_basket")#</div></a>
			<div id="basketview" style="display:none;padding-top:10px;">
				<strong>#myFusebox.getApplicationData().defaults.trans("basket_customize_header")#</strong><br/>
				#myFusebox.getApplicationData().defaults.trans("basket_customize_desc")#
				<table border="0">
					<tr>
						<td>#myFusebox.getApplicationData().defaults.trans("basket_customize_publish")#</td>
						<td>
							<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="publish_btn_basket" id="publish_btn_basket" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.publish_btn_basket,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.publish_btn_basket,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>#myFusebox.getApplicationData().defaults.trans("basket_customize_email")#</td>
						<td>
							<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="email_btn_basket" id="email_btn_basket" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.email_btn_basket,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.email_btn_basket,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>#myFusebox.getApplicationData().defaults.trans("basket_customize_ftp")#</td>
						<td>
							<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="ftp_btn_basket" id="ftp_btn_basket" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.ftp_btn_basket,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.ftp_btn_basket,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td>#myFusebox.getApplicationData().defaults.trans("basket_customize_export")#</td>
						<td>
							<select data-placeholder="Choose a group or user" class="chzn-select" style="width:500px;" name="metadata_btn_basket" id="metadata_btn_basket" multiple="multiple">
								<option value=""></option>
								<cfloop query="qry_groups">
									<option value="#grp_id#"<cfif listfind(qry_customization.metadata_btn_basket,grp_id)> selected="selected"</cfif>>#grp_name#</option>
								</cfloop>
								<cfloop query="qry_users">
									<option value="#user_id#"<cfif listfind(qry_customization.metadata_btn_basket,user_id)> selected="selected"</cfif>>#user_first_name# #user_last_name# (#user_email#)</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
				<cfif !application.razuna.isp>
					<table border="0">
						<tr>
							<td colspan="2">
								<strong>#myFusebox.getApplicationData().defaults.trans("basket_customize_networkpaths")#</strong><br/>
								#myFusebox.getApplicationData().defaults.trans("basket_customize_networkpaths_desc")#<br/>
							</td>
						</tr>
						<tr>
							<td width="150">Windows Network Path:</td><td><input type="text" name="windows_netpath2asset" value="#qry_customization.windows_netpath2asset#" size="70" placeholder="\\10.0.0.10\razuna\assets"></td>
						</tr>
						<tr>
							<td width="150">Mac Network Path:</td><td><input type="text" name="mac_netpath2asset" value="#qry_customization.mac_netpath2asset#" size="70" placeholder="afp://10.0.0.10/razuna/assets"></td>
						</tr>
						<tr>
							<td width="150">Unix Network Path:</td><td><input type="text" name="unix_netpath2asset" value="#qry_customization.unix_netpath2asset#" size="70" placeholder="\\10.0.0.10\razuna\assets"></td>
						</tr>
					</table>
					<cfif application.razuna.storage NEQ 'amazon'>
						<table border="0">
							<tr>
								<td colspan="2">
									<strong>#myFusebox.getApplicationData().defaults.trans("basket_customize_awsurl")#</strong><br/>
									#myFusebox.getApplicationData().defaults.trans("basket_customize_awsurl_desc")#<br/>
								</td>
							</tr>
							<tr>
								<td width="150">AWS URL:</td><td><input type="text" name="basket_awsurl" value="#qry_customization.basket_awsurl#" size="70" placeholder="https://s3.amazonaws.com"></td>
							</tr>
						</table>
					</cfif>
				</cfif>
			</div>
			<div stlye="clear:both;"><br /></div>
			<!--- Search --->
			<a href="##" onclick="$('##search').slideToggle('slow');return false;"><div class="headers">&gt; #myFusebox.getApplicationData().defaults.trans("header_search")# </div></a>
			<div id="search" style="display:none;padding-top:10px;">
				#myFusebox.getApplicationData().defaults.trans("search_customize_desc")#
				<br />
				<br />
				<!--- Choose folder selection --->
				<strong>#myFusebox.getApplicationData().defaults.trans("enable_search_selection")#</strong>
				<br />
				<div><input type="radio" name="search_selection" value="true"<cfif qry_customization.search_selection> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="search_selection" value="false"<cfif !qry_customization.search_selection> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
				<br />
				<!--- Hide advanced search tabs --->
				<strong>#myFusebox.getApplicationData().defaults.trans("hide_search_tabs")#</strong>
				<br />
				<div><input type="radio" name="hide_search_tabs" value="true"<cfif qry_customization.hide_search_tabs> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("yes")# <input type="radio" name="hide_search_tabs" value="false"<cfif !qry_customization.hide_search_tabs> checked="checked"</cfif> />#myFusebox.getApplicationData().defaults.trans("no")#</div>
				<br />
			</div>
		</div>

		<div style="clear:both;"></div>
		<div id="status_custom_2" style="float:left;padding-top:15px;"></div>
		<div style="float:right;padding-top:15px;"><cfif Request.securityobj.CheckSystemAdminUser()><input type="checkbox" name="apply_global" value="true"> <em style="padding-right:20px;">Apply to all tenants</em> </cfif><input type="submit" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" class="button" /></div>
		</form>
		<div style="clear:both;"></div>
		<div id="dummy_maintenance"></div>
		<!--- JS --->
		<script type="text/javascript">
			//RAZ-2267 Option to define the default explorer section.
			$(document).ready(function(){

				//set check if Collection tab is enabled or disabled
				 if($('input[name="tab_collections"]:checked' ).val()=='true'){
					$('.collection_tab').attr('disabled', false);
            	 }
				 else{
				 	$('.collection_tab').attr('disabled', true);
				 }
				//set check if Label tab is enabled or disabled
				 if($('input[name="tab_labels"]:checked' ).val()=='true'){
					$('.label_tab').attr('disabled', false);
            	 }
				 else {
				 	$('.label_tab').attr('disabled', true);
				 }
				 //show or Hide  collection tab will set default explorer collection disabled or enabled
				$("input[name$='tab_collections']").click(function() {
					if($(this).val()=='false'){
						$('.collection_tab').attr('disabled', true);
						//if the user select collection tab hide will set default as folder
						 if($("input:radio[name='tab_explorer_default'][value='2']").is(":checked")) {
						 	$("input:radio[name='tab_explorer_default'][value='1']").attr("checked",true);
						 }
					}
					else {
						$('.collection_tab').attr('disabled', false);
					}
			    });
				//show or Hide  label tab will set the default explorer label disabled or enabled
				$("input[name$='tab_labels']").click(function() {
					if($(this).val()=='false'){
						$('.label_tab').attr('disabled', true);
						//if the user select label tab hide will set default as folder  
						 if($("input:radio[name='tab_explorer_default'][value='4']").is(":checked")) {
						 	$("input:radio[name='tab_explorer_default'][value='1']").attr("checked",true);
						 }
					}
					else{
						$('.label_tab').attr('disabled', false);
					}
			    });
				
			});
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