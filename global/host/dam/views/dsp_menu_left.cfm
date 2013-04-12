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
	<div style="text-decoration:none;font-weight:bold;font-size:15px;padding-bottom:20px;">
		<div style="float:left;"><a href="##" id="mainsectionchooser" onclick="$('##mainselection').toggle();" class="ddicon" style="text-decoration:none;">Folders</a></div>
		<div style="float:left;padding-top:3px;"><img src="#dynpath#/global/host/dam/images/arrow_dropdown.gif" width="16" height="16" border="0" onclick="$('##mainselection').toggle();" class="ddicon"></div>
		<div id="mainselection" class="ddselection_header" style="display:none;top:17px;">
			<p><a href="##" onclick="switchmainselection('folders','Folders');"><div id="section_folders" style="float:left;padding-right:2px;padding-top:3px;"><img src="#dynpath#/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0"></div>Folders</a></p>
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
	<br />
	<div>Collapse Menu</div>

	<div id="apMiddle" style="z-index:10;"><div id="slide_off"><a href="##" onclick="hideshow('off');"><img src="#dynpath#/global/host/dam/images/arrow_slide_left.gif" border="0" width="15" height="15"></a></div><div id="slide_on" style="display:none;"><a href="##" onclick="hideshow('on');"><img src="#dynpath#/global/host/dam/images/arrow_slide_right.gif" border="0" width="15" height="15"></a></div></div>
	<script language="JavaScript" type="text/javascript">
		// Load the folders by default
		$('##explorer').load('#myself#c.explorer');
		// Show or hide left side
		function hideshow(state){
			if (state == "off"){
				$('##tabs_left').css('display','none');
				$('##slide_off').css('display','none');
				$('##slide_on').css('display','');
				$('##apMiddle').css({'left':'3px'});
				$('##apDiv3').css({'margin-left':'0px'});
				$('##apDiv4').css({'left':'10px','width':'97%'});
			}
			else {
				$('##tabs_left').css('display','');
				$('##slide_off').css('display','');
				$('##slide_on').css('display','none');
				$('##apMiddle').css({'left':'261px'});
				$('##apDiv3').css({'margin-left':'13px'});
				$('##apDiv4').css({'left':'280px','width':'75%'});
			}
		}
	</script>
</cfoutput>
