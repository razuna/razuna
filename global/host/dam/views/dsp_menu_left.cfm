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
<!--- Tabs --->
<div id="tabs_left">
	<ul>
		<li><a href="##explorer">Folders</a></li>
		<li><a href="##explorer_col" onclick="loadcontent('explorer_col','#myself#c.explorer_col');">Collections</a></li>
		<li><a href="##labels" onclick="loadcontent('labels','#myself#c.labels_list');">#defaultsObj.trans("labels")#</a></li>
		<!--- <li><a href="##favorites" onclick="loadcontent('favorites','#myself#c.favorites');">#defaultsObj.trans("header_favorites")#</a></li> ---> 
		<!--- <li><a href="##basket" onclick="loadcontent('basket','#myself#c.basket');">#defaultsObj.trans("header_basket")#</a></li> --->
	</ul>
	<div id="explorer" style="margin-left:0;padding-left:0;">#defaultsObj.loadinggif("#dynpath#")#</div>
	<div id="explorer_col" style="margin-left:0;padding-left:0;">#defaultsObj.loadinggif("#dynpath#")#</div>
	<div id="labels" style="margin-left:0;padding-left:0;">#defaultsObj.loadinggif("#dynpath#")#</div>
	<!--- <div id="favorites"></div>  --->
	<!--- <div id="basket"></div> --->
</div>
<div id="apMiddle"><div id="slide_off"><a href="##" onclick="hideshow('off');"><img src="#dynpath#/global/host/dam/images/arrow_slide_left.gif" border="0"></a></div><div id="slide_on" style="display:none;"><a href="##" onclick="hideshow('on');"><img src="#dynpath#/global/host/dam/images/arrow_slide_right.gif" border="0"></a></div></div>
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_left");
	loadcontent('explorer','#myself#c.explorer');
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
	//
	
</script>
</cfoutput>
