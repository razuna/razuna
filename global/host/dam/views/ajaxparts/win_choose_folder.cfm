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
	<div><strong>Choose from the folder list below in order to store the asset(s).</strong></div>
	<div id="win_choosefolder"></div>
	<cfif session.type EQ "movefolder" AND session.thefolderorglevel NEQ 1 AND (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())>
		<div style="clear:both;padding-top:15px;" />
		<div><a href="##" onclick="loadcontent('rightside','index.cfm?fa=#session.savehere#&intofolderid=#session.thefolderorg#&intolevel=1');destroywindow(1);loadcontent('explorer','index.cfm?fa=c.explorer');return false;">Move the folder to the top level</a></div>
	</cfif>
	<div id="div_choosecol"></div>
	<div style="clear:both;padding-top:15px;" />
	<div id="div_choosefolder_status" style="color:green;font-weight:bold;"></div>
	<cfif session.type EQ "choosecollection" OR session.type EQ "saveascollection">
		<cfset iscol = "T">
	<cfelse>
		<cfset iscol = "F">
	</cfif>
	<script language="javascript" type="text/javascript">
		// Load Folders
		$(function () { 
			$("##win_choosefolder").tree({
				plugins : {
					cookie : { prefix : "treemovebox_" }
				},
				types : {
					"default"  : {
						deletable : false,
						renameable : false,
						draggable : false,
						icon : { 
							image : "#dynpath#/global/host/dam/images/folder-blue-mini.png"
						}
					},
					"file" : {
						// the following three rules basically do the same
						valid_children : "none",
						max_children : 0,
						max_depth :0,
						icon : { 
							image : "file.png"
						}
					}
				},
				data : { 
					async : true,
					opts : {
						url : "#myself#c.getfolderfortree&col=#iscol#&actionismove=T&kind=#attributes.kind#"
					}
				}
			});
		});
	</script>
</cfoutput>
