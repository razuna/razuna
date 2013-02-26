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
<cfparam default="1" name="host_lang">
<cfoutput>
	<div id="tabs_hosts">
		<ul>
			<li><a href="##thost">#defaultsObj.trans("hosts")#</a></li>
			<li><a href="##tnewhost">#defaultsObj.trans("hosts_new")#</a></li>
		</ul>
		<div id="thost">
			<!--- Load list of groups here --->
			<div id="hostslist"></div>
		</div>
		<div id="tnewhost">
			<form name="thehost" id="thehost" action="#self#" method="post">
			<input type="hidden" name="#theaction#" value="c.hosts_add">
			<input type="hidden" name="pathhere" value="#thispath#">
			<input type="hidden" name="pathoneup" value="#pathoneup#">
			<input type="hidden" name="firsttime" value="F">
			<table width="600" border="0" cellspacing="0" cellpadding="0" class="grid">
			<!--- <tr>
				<th colspan="2">#defaultsObj.trans("hosts_new")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("newhost_desc")#</td>
			</tr> --->
			<tr>
				<th colspan="2">#defaultsObj.trans("host_setings")#</th>
			</tr>
			<tr>
				<td width="200">
					<cfif application.razuna.isp>
						Subdomain
					<cfelse>
						#defaultsObj.trans("hosts_name")#
					</cfif>
				</td>
				<td width="400"><div style="float:left;"><input type="text" name="host_name" id="host_name" style="width:200px;" onkeyup="checkhostname();"><cfif application.razuna.isp>.yourdomain.com</cfif></div><div id="checkhostname" style="float:right;"></div></td>
			</tr>
			<cfif application.razuna.isp>
				<tr>
					<td valign="top">Custom hostname</td>
					<td><input type="text" name="host_name_custom" id="host_name_custom" style="width:200px;"><br /><em>(If you want to let your customer use his own domain. He needs to setup a CNAME to his subdomain!)</em></td>
				</tr>
			</cfif>
			<!--- <tr>
				<td valign="top">#defaultsObj.trans("hosts_path")#*</td>
				<td><div style="float:left;"><input type="text" name="host_path" id="host_path" size="55" class="text" onchange="setpaths();" onkeyup="checkhostpath();"><br /><em>#defaultsObj.trans("no_space_umlauts")#</em></div><div id="checkhostpath" style="float:right;"></div></td>
			</tr>
			<tr>
				<td valign="top">#defaultsObj.trans("url_website")#*</td>
				<td><input type="text" name="url_website" id="url_website" size="60" class="text"></td>
			</tr> --->
			<tr>
				<th colspan="2">#defaultsObj.trans("settings_languages")#</th>
			</tr>
			<tr>
			<td colspan="2" style="padding-left:3px;">
			<div id="thelangs"></div>
			</td>
			</tr>
			<!--- <tr>
				<th colspan="2">#defaultsObj.trans("database_settings")#</th>
			</tr>
			<tr>
				<td>#defaultsObj.trans("db_prefix")#*</td>
				<td><div style="float:left;"><input type="text" name="host_db_prefix" id="host_db_prefix" size="4" maxlength="4" class="text" onkeyup="checkhostdb();"></div><div id="checkhostdb" style="float:right;"></div></td>
			</tr> --->
			<!--- If this is a Oracle database we need the Application Server URL --->
			<cfif application.razuna.thedatabase eq "oracle">
				<tr>
					<td valign="top">#defaultsObj.trans("header_url_app_server")#*</td>
					<td><input type="text" name="oracle_url" id="oracle_url" size="60" class="text" value="http://oracledb.mydomain.com:7777"><br /><em>#defaultsObj.trans("header_url_app_server_desc")#</em></td>
				</tr>
			<!--- For file system enter here the absolute paths to the assets --->
			<cfelseif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
				<tr>
					<th colspan="2">#defaultsObj.trans("path_to_assets")#</th>
				</tr>
				<tr>
					<td colspan="2">#defaultsObj.trans("path_to_assets_desc_create")#</td>
				</tr>
				<tr>
					<td>#defaultsObj.trans("path_to_assets")#</td>
					<td><input type="text" name="path_assets" size="60" class="text" value="#pathoneup#assets"></td>
				</tr>
				<cfif application.razuna.storage EQ "akamai">
					<tr>
						<th colspan="2">Cloud Storage Settings</th>
					</tr>
					<tr>
						<td colspan="2">You are using #ucase(application.razuna.storage)# as your Cloud Storage Provider. Please go into the host settings afterwards to define the individual settings.</td>
					</tr>
				</cfif>
			<cfelseif application.razuna.storage NEQ "local">
				<tr>
					<th colspan="2">Cloud Storage Settings</th>
				</tr>
				<tr>
					<td colspan="2">You are using #ucase(application.razuna.storage)# as your Cloud Storage Provider. Please go into the host settings afterwards to define the individual settings.</td>
				</tr>
			</cfif>
			<!--- Transfer Folder URLs
			<tr>
				<th colspan="2">#defaultsObj.trans("transfer_folder_urls")#</th>
			</tr>
			<tr>
				<td valign="top" colspan="2">#defaultsObj.trans("directories_desc")#</td>
			</tr>
			<tr>
				<td valign="top">#defaultsObj.trans("path_incoming")#*</td>
				<td valign="top"><input type="text" name="folder_in" id="folder_in" size="60" class="text"><br /><em>#defaultsObj.trans("path_incoming_desc")#</em></td>
			</tr>
			<tr>
				<td valign="top">#defaultsObj.trans("path_incoming")# BATCH*</td>
				<td valign="top"><input type="text" name="folder_in_batch" id="folder_in_batch" size="60" class="text" ><br /><em>#defaultsObj.trans("path_incoming_batch_desc")#</em></td>
			</tr>
			<tr>
				<td valign="top">#defaultsObj.trans("path_outgoing")#*</td>
				<td valign="top"><input type="text" name="folder_out" id="folder_out" size="60" class="text"><br /><em>#defaultsObj.trans("path_outgoing_desc")#</em></td>
			</tr>
			 --->
			<!--- Application Paths --->
			<!---

			<cfif server.os.name CONTAINS "Mac">
				<cfset im = "/opt/local/bin">
				<cfset ff = "/opt/local/bin">
				<cfset ex = "/usr/bin">
			<cfelseif server.os.name CONTAINS "Windows">
				<cfset im = "C:\ImageMagick">
				<cfset ff = "C:\FFMpeg">
				<cfset ex = "C:\Exiftool">
			<cfelse>
				<cfset im = "/usr/bin">
				<cfset ff = "/usr/bin">
				<cfset ex = "/usr/bin">
			</cfif>
			<tr>
				<th colspan="2">#defaultsObj.trans("application_paths")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("no_space")#</td>
			</tr>
			<tr>
				<td valign="top">#defaultsObj.trans("header_imagemagick")#*</td>
				<td valign="top"><input type="text" name="path_im" id="path_im" size="60" class="text" value="#im#"><br /><em>#defaultsObj.trans("header_imagemagick_desc_short")#</em></td>
			</tr>
			<tr>
				<td valign="top">#defaultsObj.trans("header_ffmpeg")#*</td>
				<td valign="top"><input type="text" name="path_ffmpeg" id="path_ffmpeg" size="60" class="text" value="#ff#"><br /><em>#defaultsObj.trans("header_ffmpeg_desc_short")#</em></td>
			</tr>
			<tr>
				<td valign="top">#defaultsObj.trans("header_exiftool")#*</td>
				<td valign="top"><input type="text" name="path_exiftool" id="path_exiftool" size="60" class="text" value="#ex#"><br /><em>#defaultsObj.trans("header_exiftool_desc")#</em></td>
			</tr>

			<tr>
				<td valign="top">#defaultsObj.trans("installation_checklist_emailfrom")#*</td>
				<td valign="top"><input type="text" name="email_from" id="email_from" size="60" class="text"><br /><em>#defaultsObj.trans("email_from_desc")#</em></td>
			</tr>
			--->
			<tr>
				<td colspan="2" align="right" style="padding-top:10px;padding-bottom:10px;"><input type="submit" name="Button" id="Button" value="#defaultsObj.trans("create_host")#" class="button"></td>
			</tr>
			
			</table>
			</form>
		</div>
	</div>
<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_hosts");
	loadcontent('hostslist', '#myself#c.hosts_list');
	loadcontent('thelangs', '#myself#c.hosts_languages');
</script>
</cfoutput>
<!--- JS: HOSTS --->
<cfinclude template="/admin/js/hosts.cfm" />