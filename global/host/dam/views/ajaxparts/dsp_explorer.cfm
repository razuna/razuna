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
	<!--- Folders --->
	<div style="padding-left:10px;font-weight:bold;float:left;">Folders</div>
	<!--- Drop down menu --->
	<div style="width:60px;float:right;position:absolute;left:190px;">
		<div style="float:left;"><a href="##" onclick="$('##explorertools').toggle();" style="text-decoration:none;" class="ddicon">Manage</a></div>
		<div style="float:right;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##explorertools').toggle();" class="ddicon"></div>
		<div id="explorertools" class="ddselection_header" style="top:18px;width:200px;z-index:6;">
			<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
				<p><a href="##" onclick="showwindow('#myself##xfa.foldernew#&theid=0&level=0&rid=0&iscol=F','#defaultsObj.trans("folder_new")#',750,1);$('##explorertools').toggle();return false;" title="#defaultsObj.trans("tooltip_folder_desc")#">#defaultsObj.trans("folder_new")# (on root level)</a></p>
				<p><hr></p>
			</cfif>
			<p><a href="##" onclick="loadcontent('explorer','#myself#c.explorer');return false;" title="#defaultsObj.trans("tooltip_refresh_tree")#">#defaultsObj.trans("reload")#</a></p>
			<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
				<p><hr></p>
				<cfif session.showmyfolder EQ "F">
					<p><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=T');return false;" title="Click here to show the personal folders of your users">Show folders from all users</a></p>
				<cfelse>
					<p><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=F');return false;" title="Click here to hide the personal folders of your users">Only show my folders</a></p>
				</cfif>
				<!--- <p><hr></p> --->
			</cfif>
			<!--- <p><a href="##" onclick="javascript:PicLensLite.start({feedUrl:'#myself#c.cooliris_folder&folder_id=0'});$('##explorertools').toggle();return false;">#defaultsObj.trans("tooltip_cooliris")#</a></p> --->
		</div>
	</div>
	<div style="clear:both;"></div>
	<!--- Load folders --->
	<div id="treeBox" style="width:200;height:200;float:left;"></div>
	<div style="clear:both;"></div>
	<!--- Show folder selection --->
	<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
		<cfif session.showmyfolder EQ "F">
			<p style="padding-left:10px;"><strong>You only see your folders now.</strong><br /><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=T');return false;" title="Click here to show the personal folders of your users">Click here to show all folders.</a></p>
		<cfelse>
			<p style="padding-left:10px;"><strong>You see ALL folders now.</strong><br /><em>Tip: Roll over the folder to see who owns the folder.</em><br /><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=F');return false;" title="Click here to hide the personal folders of your users">Click here to show your folders only.</a></p>
		</cfif>
	</cfif>
	<!--- Show link back to main page --->
	<cfif application.razuna.custom.enabled AND !application.razuna.custom.show_top_part>
		<div style="clear:both;"></div>
		<p style="padding-left:10px;"><a href="#myself#c.main" title="Click here to get to the main page">Go to main page</p>
	</cfif>
		
<script language="javascript" type="text/javascript">
	// Load our tooltips
	//mytooltip();
	// Load Folders
	$(function () { 
		$("##treeBox").tree({
			plugins : {
				cookie : { prefix : "cookietreebox_" }
			},
			types : {
				"default"  : {
					deletable : false,
					renameable : false,
					draggable : false
				}
			},
			data : { 
				async : true,
				opts : {
					url : "#myself#c.getfolderfortree&col=F"
				}
			}
		});
	});
</script>

</cfoutput>
	
