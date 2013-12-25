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
	<!--- Section Chooser --->
	<div id="leftchooser" style="text-decoration:none;font-weight:bold;font-size:15px;padding-bottom:20px;">
		<div style="float:left;padding-left:10px;">
			<a href="##" id="mainsectionchooser" onclick="$('##mainselection').toggle();" class="ddicon" style="text-decoration:none;">
				<!---RAZ-2267 Load the default explorer based on the admin customization --->
				<cfif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 1>
					#myFusebox.getApplicationData().defaults.trans("log_header_folders")#
				<cfelseif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 2>
					Collections
				<cfelseif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 3>
					Smart Folders
				<cfelseif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 4>
					Labels
				</cfif>
			</a>
		</div>
		<div style="float:left;padding-top:3px;">
			<img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##mainselection').toggle();" class="ddicon">
		</div>
		<div id="mainselection" class="ddselection_header" style="display:none;top:17px;margin-left:10px;">
			<p><a href="##" onclick="switchmainselection('folders','Folders');"><div id="section_folders" style="float:left;padding-right:2px;padding-top:3px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0"></div>#myFusebox.getApplicationData().defaults.trans("log_header_folders")#</a></p>
			<p><a href="##" onclick="switchmainselection('smart_folders','Smart Folders');"><div id="section_smart_folders" style="float:left;padding-right:14px;">&nbsp;</div>Smart Folders</a></p>
			<cfif cs.tab_collections>
				<p><a href="##" onclick="switchmainselection('collections','Collections');"><div id="section_collections" style="float:left;padding-right:14px;">&nbsp;</div>Collections</a></p>
			</cfif>
			<cfif cs.tab_labels>
				<p><a href="##" onclick="switchmainselection('labels','Labels');"><div id="section_labels" style="float:left;padding-right:14px;">&nbsp;</div>Labels</a></p>
			</cfif>
		</div>
	</div>
	<br />
	<!--- Explorer --->
	<div id="explorer" style="margin-left:0;padding-left:0;"></div>
	<!--- JS --->
	<script language="JavaScript" type="text/javascript">
		//RAZ-2267 Load the default explorer based on the admin customization 
		<cfif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 1>
		$('##explorer').load('#myself#c.explorer');
		<cfelseif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 2>
			$('##explorer').load('#myself#c.explorer_col');
		<cfelseif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 3>
			$('##explorer').load('#myself#c.smart_folders');
		<cfelseif structKeyExists(cs,"tab_explorer_default") AND cs.tab_explorer_default EQ 4>
			$('##explorer').load('#myself#c.labels_list');
		</cfif>
		
		// Show or hide left side
		function hideshow(state){
			if (state == "off"){
				$('##leftchooser').css('display','none');
				$('##slide_off').css('display','none');
				$('##slide_on').css('display','');
				$('##explorer').css({'display':'none'});
				$('##apDiv3').css({'margin-left':'0px','border':'none'});
				$('##apDiv4').css({'left':'10px','width':'97%'});
			}
			else {
				$('##leftchooser').css('display','');
				$('##slide_off').css('display','');
				$('##slide_on').css('display','none');
				$('##explorer').css({'display':''});
				$('##apDiv3').css({'margin-left':'13px','border-right':'1px dotted grey'});
				$('##apDiv4').css({'left':'280px','width':'75%'});
			}
		}
	</script>
</cfoutput>
