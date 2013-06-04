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
	<!--- Drop down menu --->
	<cfif qry_sf.recordcount NEQ 0>
		<div style="width:60px;float:right;position:absolute;left:190px;top:3px;">
			<div style="float:left;"><a href="##" onclick="$('##sfmanage').toggle();" style="text-decoration:none;" class="ddicon">Manage</a></div>
			<div style="float:right;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##sfmanage').toggle();" class="ddicon"></div>
			<div id="sfmanage" class="ddselection_header" style="top:18px;width:200px;z-index:6;">
				<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
					<p><a href="##" onclick="$('##rightside').load('#myself#c.smart_folders_settings&sf_id=0');$('##sfmanage').toggle();return false;" title="#myFusebox.getApplicationData().defaults.trans("smart_folder_new_tooltip")#">#myFusebox.getApplicationData().defaults.trans("smart_folder_new")#</a></p>
					<p><hr></p>
				</cfif>
				<p><a href="##" onclick="loadcontent('explorer','#myself#c.smart_folders');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_refresh_tree")#">#myFusebox.getApplicationData().defaults.trans("reload")#</a></p>
			</div>
		</div>
	</cfif>
	<div style="clear:both;"></div>
	<!--- Load smart folders --->
	<div id="smartfolders" style="width:200;height:200;float:left;padding-left:10px;">
		<cfif qry_sf.recordcount EQ 0>
			<a href="##" onclick="$('##rightside').load('#myself#c.smart_folders_settings&sf_id=0');$('##sfmanage').toggle();return false;"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("smart_folder_new_tooltip")#</button></a>
		<cfelse>
			<cfset sf_search_found = false>
			<cfset sf_cloud_found = false>
			<cfoutput query="qry_sf" group="sf_id">
				<cfif sf_type EQ "saved_search">
					<cfif !sf_search_found>
						<h1>#myFusebox.getApplicationData().defaults.trans("saved_searches")#</h1>
					</cfif>
					<a href="##" onclick="$('##rightside').load('#myself#c.smart_folders_content&sf_id=#sf_id#&root=true');">
						<div style="float:left;padding-right:5px;padding-bottom:5px;">
							<img src="#dynpath#/global/host/dam/images/search_16.png" border="0" width="16px" />
						</div>
						<div style="float:left;text-decoration:none;padding-top:2px;">
							#sf_name#<cfif shared EQ "true">*</cfif>
						</div>
					</a>
					<cfset sf_search_found = true>
				<cfelse>
					<cfif !sf_cloud_found>
						<h1>#myFusebox.getApplicationData().defaults.trans("cloud_accounts")#</h1>
					</cfif>
					<a href="##" onclick="$('##rightside').load('#myself#c.smart_folders_content&sf_id=#sf_id#&root=true');">
						<div style="float:left;padding-right:5px;padding-bottom:5px;">
							<cfif sf_type EQ "dropbox">
								<img src="#dynpath#/global/host/dam/images/dropbox_25.png" border="0" width="18px" />
							<cfelseif sf_type EQ "amazon">
								<img src="#dynpath#/global/host/dam/images/amazon-s3.gif" border="0" width="18px" />
							</cfif>
						</div>
						<div style="float:left;text-decoration:none;padding-top:2px;">
							#sf_name#
						</div>
					</a>
					<cfset sf_cloud_found = true>
				</cfif>
				
				<div style="clear:both;"></div>
			</cfoutput>
			<div style="padding-top:20px;font-size:11px;">
				<em>(#myFusebox.getApplicationData().defaults.trans("saved_searches_shared")#)</em>
			</div>
		</cfif>
	</div>
	<div style="clear:both;"></div>
	<!--- Show link back to main page --->
	<cfif !cs.show_top_part OR cs.folder_redirect NEQ "0">
		<div style="clear:both;"></div>
		<p style="padding-left:10px;"><a href="#myself#c.main&redirectmain=true&_v=#createuuid('')#" title="Click here to get to the main page">Go to main page</a></p>
	</cfif>

</cfoutput>
	
