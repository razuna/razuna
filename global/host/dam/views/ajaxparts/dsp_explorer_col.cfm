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
	<!--- Collections --->
	<div style="padding-left:10px;font-weight:bold;float:left;">Collections</div>
	<div style="width:60px;float:right;left:190px;position:absolute;">
		<div style="float:left;"><a href="##" onclick="$('##collectiontools').toggle();" style="text-decoration:none;" class="ddicon">Manage</a></div>
		<div style="float:right;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" border="0" onclick="$('##collectiontools').toggle();" class="ddicon"></div>
		<div id="collectiontools" class="ddselection_header" style="top:18px;width:200px;z-index:6;">
			<cfif Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser()>
				<p><a href="##" onclick="showwindow('#myself##xfa.foldernew#&theid=0&level=0&rid=0&iscol=T','#defaultsObj.trans("folder_new")#',750,1);$('##explorertools').toggle();return false;" title="#defaultsObj.trans("tooltip_folder_desc")#">Add Collection Folder</a></p>
				<p><hr></p>
			</cfif>
			<p><a href="##" onclick="loadcontent('explorer_col','#myself#c.explorer_col');return false;" title="#defaultsObj.trans("tooltip_refresh_tree")#">#defaultsObj.trans("reload")#</a></p>
		</div>
	</div>
	<div style="clear:both;"></div>
	<div id="colBox" style="width:200;height:200;float:left;"></div>
	<div style="clear:both;"></div>
	
<script language="javascript" type="text/javascript">
	// Load Collections
	$(function () { 
		$("##colBox").tree({
			plugins : {
				cookie : { prefix : "colbox_" }
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
					url : "#myself#c.getfolderfortree&col=T"
				}
			}/* ,
			ui : {
				theme_name : "apple"
			} */
		});
	});
</script>

</cfoutput>
	
