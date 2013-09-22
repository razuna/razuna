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
	<!--- For directories --->
	<cfif a.is_dir>
		<div style="padding:5px;border-bottom:1px solid grey;width:100%;" id="folder">
			<div style="float:left;padding-top:10px;">
				<a rel="prefetch" href="##" onclick="loadoverlay();$('##sf_account').load('#myself#c.sf_load_account', { path: '#a.path#', sf_type: '#session.sf_account#' }, function(){$('##bodyoverlay').remove();});">
					<div style="float:left;padding-right:15px;">
						<img src="#dynpath#/global/host/dam/images/folder-blue-old.png" border="0">
					</div>
					<div style="float:left;padding-top:8px;font-weight:bold;">
						#listlast(a.path,"/")#
					</div>
				</a>
			</div>
			<div style="clear:both;"></div>
		</div>
	<!--- For files --->
	<cfelse>
		<cfset show = true>
		<!--- For Amazon --->
		<cfif session.sf_account EQ "amazon">
			<cfset a.thumb_exists = false>
			<cfset a.mime_type = "aws">
			<cfset ext = listlast(key,".")>
			<cfif key EQ qry_sf_list.path>
				<cfset show = false>
			</cfif>
		<cfelse>
			<cfset ext = listlast(a.path,".")>
		</cfif>
		<cfif show>
			<div style="padding:5px;border-bottom:1px solid grey;width:100%;" id="#a.path#">
				<div style="float:left;padding-top:10px;">
					<div style="float:left;padding-right:15px;">
						<a href="#myself#c.sf_load_file&path=#urlencodedformat(a.path)#" target="_blank">
							<cfif a.thumb_exists>
								<cfset lp = listlast(a.path,"/")>
								<img class="lazy" src="#dynpath#/global/host/dam/images/grey.gif" data-original="#attributes.thumbpath#/#lp#" border="0" width="32" height="32">
							<cfelse>
								<cfif a.mime_type EQ "aws">
									<cfif fileExists("#expandpath("../../")#global/host/dam/images/icons/icon_#ext#.png")>
										<cfset thethumb = "#dynpath#/global/host/dam/images/icons/icon_#ext#.png">
									<cfelse>
										<cfset thethumb = "#dynpath#/global/host/dam/images/icons/icon_txt.png">
									</cfif>
								<cfelse>
									<cfif a.mime_type CONTAINS "photoshop">
										<cfset ext = "psd">
									</cfif>
									<cfif fileExists("#expandpath("../../")#global/host/dam/images/icons/icon_#ext#.png")>
										<cfset thethumb = "#dynpath#/global/host/dam/images/icons/icon_#ext#.png">
									<cfelse>
										<cfset thethumb = "#dynpath#/global/host/dam/images/icons/icon_txt.png">
									</cfif>
								</cfif>
								<img src="#thethumb#" border="0" width="32" height="32">
							</cfif>
						</a>
					</div>
					<div style="float:left;padding-top:10px;">
						<a href="#myself#c.sf_load_file&path=#urlencodedformat(a.path)#" target="_blank" style="text-decoration:none;">#listlast(a.path,"/")#</a>
					</div>
				</div>
				<cfif attributes.folderaccess NEQ "R">
					<div style="float:right;padding-top:20px;">
						<a href="##" onclick="showwindow('#myself#c.sf_load_download_folder&path=#urlencodedformat(a.path)#','#myFusebox.getApplicationData().defaults.trans("sf_choose_folder")#',600,1);" title="#myFusebox.getApplicationData().defaults.trans("sf_choose_folder")#">#myFusebox.getApplicationData().defaults.trans("sf_import_to_razuna")#</a>
					</div>
				</cfif>
				<div style="clear:both;"></div>
			</div>
		</cfif>
	</cfif>
</cfoutput>