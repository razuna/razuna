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
		<div style="width:60px;float:right;position:absolute;left:190px;">
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
	<div id="smartfolders" style="width:200;height:200;float:left;">
		<cfif qry_sf.recordcount EQ 0>
			<a href="##" onclick="$('##rightside').load('#myself#c.smart_folders_settings&sf_id=0');$('##sfmanage').toggle();return false;"><button class="awesome big green">#myFusebox.getApplicationData().defaults.trans("smart_folder_new_tooltip")#</button></a>
		<cfelse>
			<cfloop query="qry_sf">
				<a href="##" onclick="$('##rightside').load('#myself#c.smart_folders_content&sf_id=#sf_id#');">#sf_name#</a> <br />
			</cfloop>
		</cfif>
	</div>
	<div style="clear:both;"></div>
	<!--- Show link back to main page --->
	<cfif !cs.show_top_part OR cs.folder_redirect NEQ "0">
		<div style="clear:both;"></div>
		<p style="padding-left:10px;"><a href="#myself#c.main&redirectmain=true&_v=#createuuid('')#" title="Click here to get to the main page">Go to main page</a></p>
	</cfif>

</cfoutput>
	
