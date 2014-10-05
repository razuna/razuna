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
<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
	<cfset isadmin = true>
<cfelse>
	<cfset isadmin = false>
</cfif>
<cfoutput>
	<!--- Folders --->
	<!--- <div style="padding-left:10px;font-weight:bold;float:left;">Folders</div> --->
	<cfif cs.show_manage_part AND (isadmin OR  cs.show_manage_part_slct EQ "" OR listfind(cs.show_manage_part_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_manage_part_slct,session.thegroupofuser) NEQ "")>
		<!--- Drop down menu --->
		<div style="width:60px;float:right;position:absolute;left:190px;top:3px;">
			<div style="float:left;"><a href="##" onclick="$('##explorertools').toggle();" style="text-decoration:none;" class="ddicon">Manage</a></div>
			<div style="float:right;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##explorertools').toggle();" class="ddicon"></div>
			<div id="explorertools" class="ddselection_header" style="top:18px;width:200px;z-index:6;">
				<cfif isadmin>
					<p><a href="##" onclick="$('##rightside').load('#myself##xfa.foldernew#&theid=0&level=0&rid=0&iscol=F');$('##explorertools').toggle();return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_folder_desc")#">#myFusebox.getApplicationData().defaults.trans("folder_new")# (#myFusebox.getApplicationData().defaults.trans("on_root_level")#)</a></p>
					<p><hr></p>
				</cfif>
				<p><a href="##" onclick="loadcontent('explorer','#myself#c.explorer');return false;" title="#myFusebox.getApplicationData().defaults.trans("tooltip_refresh_tree")#">#myFusebox.getApplicationData().defaults.trans("reload")#</a></p>
				<cfif isadmin>
					<p><hr></p>
					<cfif session.showmyfolder EQ "F">
						<p><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=T');return false;" title="Click here to show the personal folders of your users">#myFusebox.getApplicationData().defaults.trans("show_all_folders")#</a></p>
					<cfelse>
						<p><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=F');return false;" title="Click here to hide the personal folders of your users">#myFusebox.getApplicationData().defaults.trans("show_my_folders")#</a></p>
					</cfif>
					<!--- <p><hr></p> --->
				</cfif>
				<!--- <p><a href="##" onclick="javascript:PicLensLite.start({feedUrl:'#myself#c.cooliris_folder&folder_id=0'});$('##explorertools').toggle();return false;">#myFusebox.getApplicationData().defaults.trans("tooltip_cooliris")#</a></p> --->
			</div>
		</div>
	</cfif>
	<div style="clear:both;"></div>
	<!--- Load folders --->
	<div id="treeBox" style="width:200;height:200;float:left;"></div>
	
	<cfif cs.show_trash_icon AND (isadmin OR  cs.show_trash_icon_slct EQ "" OR listfind(cs.show_trash_icon_slct,session.theuserid) OR myFusebox.getApplicationData().global.comparelists(cs.show_trash_icon_slct,session.thegroupofuser) NEQ "")>
		<div style="clear:both;"></div>
		<!--- Trash --->
		<div style="padding:15px 0px 10px 8px;">
			<div style="float:left;padding-right:5px;">
				<img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0" />
			</div>
			<div style="float:left;">
				<a href="##" onclick="$('##rightside').load('#myself#c.folder_explorer_trash&trashkind=assets&offset=0&rowmaxpage=25');">#myFusebox.getApplicationData().defaults.trans("trash_folder_header")#</a>
			</div>
		</div>
	</cfif>
	<div style="clear:both;"></div>
	<!--- Show folder selection --->
	<!--- <cfif isadmin>
		<cfif session.showmyfolder EQ "F">
			<p style="padding-left:10px;"><strong>You only see your folders now.</strong><br /><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=T');return false;" title="Click here to show the personal folders of your users">Click here to show all folders.</a></p>
		<cfelse>
			<p style="padding-left:10px;"><strong>You see ALL folders now.</strong><br /><em>Tip: Roll over the folder to see who owns the folder.</em><br /><a href="##" onclick="loadcontent('explorer','#myself#c.explorer&showmyfolder=F');return false;" title="Click here to hide the personal folders of your users">Click here to show your folders only.</a></p>
		</cfif>
	</cfif> --->
	<!--- Show link back to main page --->
	<cfif !cs.show_top_part OR session.do_folder_redirect>
		<div style="clear:both;"></div>
		<p style="padding-left:10px;"><a href="#myself#c.main&redirectmain=true&_v=#createuuid('')#" title="Click here to get to the main page">#myFusebox.getApplicationData().defaults.trans("go_to_main_page")#</a></p>
	</cfif>
		
<script language="javascript" type="text/javascript">
	// Load Folders
	$(function () { 
		$("##treeBox").tree({
			plugins : {
				cookie : { prefix : "cookietreebox_", keep_selected : false, keep_opened: true }
			},
			types : {
				"default"  : {
					deletable : false,
					renameable : false,
					draggable : false,
					icon : { 
						image : "#dynpath#/global/host/dam/images/folder-blue-mini.png"
					}
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
	
