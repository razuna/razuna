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
<div style="float:right;padding-right:10px;">
	<!--- Drop down menu --->
	<div>
		<div style="float:left;"><a href="##" onclick="$('##foldertools_#attributes.folder_id#').toggle();" style="text-decoration:none;" class="ddicon">#myFusebox.getApplicationData().defaults.trans("manage")#</a></div>
		<div style="float:right;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##foldertools_#attributes.folder_id#').toggle();" class="ddicon"></div>
		<div id="foldertools_#attributes.folder_id#" class="ddselection_header" style="top:70px;width:137px;z-index:6;right:10px;">
			<cfif attributes.iscol EQ "f">
				<p><a href="##" onclick="showwindow('#myself#c.folder_subscribe&theid=#attributes.folder_id#','#myFusebox.getApplicationData().defaults.trans("folder_subscribe")#',800,1);$('##foldertools').toggle();return false;">
				#myFusebox.getApplicationData().defaults.trans("folder_subscribe")#</a></p>
			</cfif>
			<cfif attributes.folderaccess EQ "x">
				<p><a href="##" onclick="showwindow('#myself#ajax.folder_settings&folder_id=#attributes.folder_id#&iscol=#attributes.iscol#','<cfif attributes.iscol EQ "f">#myFusebox.getApplicationData().defaults.trans("folder_properties")#<cfelse>Collection Settings</cfif>',800,1);$('##foldertools').toggle();return false;">
				<cfif attributes.iscol EQ "f">#myFusebox.getApplicationData().defaults.trans("folder_properties")#<cfelse>Collection Settings</cfif></a></p>
			</cfif>
		</div>
	</div>

</div>
</cfoutput>