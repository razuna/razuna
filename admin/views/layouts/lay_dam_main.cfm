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

<cfcontent reset="true">
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >

<head>
<title>Razuna - Enterprise Digital Asset Management</title>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />

<cfparam name="fck" default="F">
<!--- Below is only needed if we call this window within FCK --->
<cfif fck EQ "T">
<!--- Globals JS --->
<script type="text/javascript" src="js/global.js"></script>
<!--- SPRY --->
<cfoutput><script language="JavaScript" type="text/javascript" src="#dynpath#/global/spry/widgets/tabbedpanels/SpryTabbedPanels.js"></script>
<script language="javascript" type="text/javascript" src="#dynpath#/global/spry/includes/SpryData.js"></script>
<script language="javascript" type="text/javascript" src="#dynpath#/global/spry/includes/SpryUtils.js"></script>
<script language="javascript" type="text/javascript" src="#dynpath#/global/spry/includes/SpryEffects.js"></script>
<!--- Load the dtree for the tree --->
<script type="text/javascript" src="#dynpath#/global/js/dtree.js"></script></cfoutput>
<!--- CSS --->
<style type="text/css">
#damcontainer {
	min-height: 100%;
	height: 100%;
	height: auto;
	font-size:12px;
    font-family: 'Helvetica Neue',Helvetica,Arial,"Nimbus Sans L",sans-serif;
}
/* ------------ DAM FILE SELECT ------------ */
#damDivLeft {
color:Red;
	position:absolute;
	left:0px;
	top:0px;
	width:250px;
	height:auto;
	z-index:3;
}
#damDivTop {
	position:absolute;
	left:250px;
	top:0px;
	width:auto;
	height:40px;
	z-index:3;
	margin-left: 13px;
}
#damDivBottom {
	position:absolute;
	left:250px;
	top:40px;
	width:auto;
	height:auto;
	z-index:3;
	margin-left: 13px;
}
.grid {
	margin: 2px 0px 5px 0px;
	border-collapse: collapse;
}
.grid th {
	border: 1px solid #ccc;
	padding: 2px 4px 2px 4px;
	background: #E2E2E2;
	font-weight: bold;
	text-align:left;
}
.grid td  {
	border: 1px solid #BEBEBE;
	padding: 3px 4px 3px 4px;
}
.gridno td  {
	border: 0px;
	padding: 0px;
	padding-right: 2px;
	padding-left: 2px;
}
.gridno .td2 {
	padding: 0;
	border: none;
}
.TabbedPanels {
	margin: 0px;
	padding: 0px;
	float: left;
	clear: none;
	width: 100%; /* IE Hack to force proper layout when preceded by a paragraph. (hasLayout Bug)*/
}
.TabbedPanelsTabGroup {
	margin: 0px;
	padding: 0px;
}
.TabbedPanelsTab {
	position: relative;
	top: 1px;
	float: left;
	padding: 4px 10px;
	margin: 0px 1px 0px 0px;
	font-weight: bold;
	background-color: #DDD;
	list-style: none;
	border-left: solid 1px #CCC;
	border-bottom: solid 1px #999;
	border-top: solid 1px #999;
	border-right: solid 1px #999;
	-moz-user-select: none;
	-khtml-user-select: none;
	cursor: pointer;
}
.TabbedPanelsTabHover {
	background-color: #CCC;
}
.TabbedPanelsTabSelected {
	background-color: #EEE;
	border-bottom: 1px solid #EEE;
}
.TabbedPanelsTab a {
	color: black;
	text-decoration: none;
}
.TabbedPanelsContentGroup {
	clear: both;
	border-left: solid 1px #CCC;
	border-bottom: solid 1px #CCC;
	border-top: solid 1px #999;
	border-right: solid 1px #999;
	background-color: #FFFFFF //#EEE;
}
.TabbedPanelsContent {
	padding: 4px;
}
.TabbedPanelsContentVisible {
}
.VTabbedPanels .TabbedPanelsTabGroup {
	float: left;
	width: 10em;
	height: 20em;
	background-color: #EEE;
	position: relative;
	border-top: solid 1px #999;
	border-right: solid 1px #999;
	border-left: solid 1px #CCC;
	border-bottom: solid 1px #CCC;
}
.VTabbedPanels .TabbedPanelsTab {
	float: none;
	margin: 0px;
	border-top: none;
	border-left: none;
	border-right: none;
}
.VTabbedPanels .TabbedPanelsTabSelected {
	background-color: #EEE;
	border-bottom: solid 1px #999;
}
.VTabbedPanels .TabbedPanelsContentGroup {
	clear: none;
	float: left;
	padding: 0px;
	width: 30em;
	height: 20em;
}
</style>
<script language="javascript">
	function fckinsert(thefile){
		window.top.opener.SetUrl( thefile ) ;
		window.top.close() ;
		window.top.opener.focus() ;
	}
</script>

</cfif>

</head>
<body>

<cfoutput>
<div id="damContainer">
<div id="damDivLeft"></div>
<div id="damDivTop"></div>
<div id="damDivBottom"></div>
</div>
<script type="text/javascript" language="javascript">
	loadcontent('damDivTop', '#myself##xfa.dam_top#&fck=#fck#');
	loadcontent('damDivLeft', '#myself##xfa.dam_left#&fck=#fck#');
</script>
</cfoutput>

</body>
</html>
