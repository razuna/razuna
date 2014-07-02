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
 <style>
/* Do not wrap in this view */
div.folders .tree li a, 
.tree li span {
	white-space: nowrap !important;
}
</style>
<cfoutput>
	<div class="folders">
		<div ><strong><cfif attributes.iscol EQ "T">Choose a collection folder first...<cfelse>Choose from the folder list below:</cfif></strong></div>
		<div id="win_choosefolder"></div>
		<!--- For different kind of folder action --->
		<cfif session.type EQ "movefolder" AND session.thefolderorglevel NEQ 1 OR session.type EQ "restorefolder" OR session.type EQ "restoreselectedfolders" OR session.type EQ "restorefolderall" OR session.type EQ "restorecolfolder" OR session.type EQ 'restorecolfolderall' OR session.type EQ 'restoreselectedcolfolder' AND (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())>
			<div style="clear:both;padding-top:15px;" />
			<div><a href="##" onclick="movethisfolder();return false;">Move the folder to the top level</a></div>
		</cfif>
		<!--- For copy folder --->
		<cfif session.type EQ "copyfolder" AND session.thefolderorglevel NEQ 1 AND (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())>
			<div style="clear:both;padding-top:15px;" />
			<div><a href="##" onclick="copythisfolder();return false;">Copy the folder to the top level</a></div>
		</cfif>
		<!--- RAZ-273 Inherit permissions of parent folder for copy folder--->
		<cfif session.type EQ "copyfolder" AND (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())>
			<div style="clear:both;padding-top:15px;"><input type="checkbox" name="perm_inherit" id="perm_inherit" value="">Inherit permissions of parent folder</div>
		</cfif>
		<div id="div_choosecol"></div>
		<div style="clear:both;padding-top:15px;" />
		<div id="div_choosefolder_status" style="color:green;font-weight:bold;"></div>
	</div>
	<!--- <cfif session.type EQ "choosecollection" OR session.type EQ "saveascollection">
		<cfset iscol = "T">
	<cfelse>
		<cfset iscol = "F">
	</cfif> --->
	<script language="javascript" type="text/javascript">
		// Load Folders
		$(function () { 
			$("##win_choosefolder").tree({
				// plugins : {
				// 	cookie : { prefix : "treemovebox_" }
				// },
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
						url : "#myself#c.getfolderfortree&col=#attributes.iscol#&actionismove=T&kind=#attributes.kind#&fromtrash=#attributes.fromtrash#"
					}
				}
			});
		});
		// Move folder call
		function movethisfolder(){
			$('##div_forall').load('#myself##session.savehere#&intofolderid=#session.thefolderorg#&intolevel=1&iscol=#attributes.iscol#');
			// Destroy window
			destroywindow(1);
			// Delay load of list
			delayloadingoflist();
		}
		
		function copythisfolder(){
			loadcontent('div_forall','#myself##session.savehere#&intofolderid=#session.thefolderorg#&intolevel=1&iscol=f');
			$('##explorer').load('#myself#c.explorer<cfif attributes.iscol EQ "T">_col</cfif>');
			destroywindow(1);
			try {
				setTimeout(function() {
			    	delayfolderload();
				}, 1500)
			}
			catch(e) {};
		}
		
		function delayfolderload(){
			$('##explorer').load('#myself#c.explorer<cfif attributes.iscol EQ "T">_col</cfif>');
			<cfif structKeyExists(attributes,"fromtrash") AND attributes.fromtrash>
				<cfif structKeyExists(attributes,"restoreall") AND attributes.restoreall>
					$('##rightside').load('#myself#c.<cfif attributes.iscol EQ "T">collection_explorer_trash&restoreall=true&trashkind=folders<cfelse>folder_explorer_trash<cfif attributes.restoreall>&restorefolderall=#attributes.restoreall#</cfif>&trashkind=#attributes.loaddiv#</cfif>');
				<cfelse>
					$('##rightside').load('#myself#c.<cfif attributes.iscol EQ "T">collection_explorer_trash&trashkind=folders<cfelse>folder_explorer_trash&trashkind=#attributes.loaddiv#</cfif>');
				</cfif>
			</cfif>
		}
		function delayloadingoflist(){
			try {
				setTimeout(function() {
			    	delayfolderload();
				}, 1500)
			}
			catch(e) {};
		}
	</script>
</cfoutput>
