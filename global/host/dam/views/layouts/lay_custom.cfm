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
<cfcontent reset="true">
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US">
<head>
<title>Razuna Enterprise Digital Asset Management</title>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<!---
<cfheader name="Expires" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#">
<cfheader name="PRAGMA" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#">
--->
<!---
<cfheader name="Expires" value="#GetHttpTimeString(Now())#">
<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#">
--->
<cfset cacheTimeSeconds = 60*60*24>
<cfheader name="Expires" value="#GetHttpTimeString(DateAdd('s', cacheTimeSeconds, Now()))#">
<cfheader name="CACHE-CONTROL" value="max-age=#cacheTimeSeconds#">
<cfheader name="PRAGMA" value="public">
<cfheader name="P3P" value="CP=\\\"IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\\\"">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<script language="JavaScript" type="text/javascript">var dynpath = '#dynpath#';</script>
<!--- CSS --->
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/jquery-ui-1.10.3.custom/css/smoothness/jquery-ui-1.10.3.custom.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/main.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/videoplayer/css/multiple-instances.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/tag/css/jquery.tagit.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/tagit.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/notification/sticky.min.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/chosen/chosen.css" />
<!--- JS --->
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.validate.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.form.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-ui-1.10.3.custom/js/jquery-ui-1.10.3.custom.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/videoplayer/js/flowplayer-3.2.6.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/AC_QuickTime.js"></script>
<script type="text/javascript" src="#dynpath#/global/host/dam/js/global.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/tag/js/tag-it.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/notification/sticky.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/chosen/chosen.jquery.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.formparams.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jqtree/jquery.tree.min.js"></script>
<!--- Favicon --->
<cfif fileexists("#ExpandPath("../..")#global/host/favicon/#session.hostid#/favicon.ico")>
	<link rel="SHORTCUT ICON" href="#dynpath#/global/host/favicon/#session.hostid#/favicon.ico" />
<cfelse>
	<link rel="SHORTCUT ICON" href="#dynpath#/global/host/dam/images/favicon.ico" />
</cfif>
<!--- tooltip styling --->
<style>
##demotip {
	display:none;
	background:url(#dynpath#/global/js/tooltip_images/black.png);
	font-size:12px;
	height:60px;
	width:160px;
	padding:25px 25px 27px 25px;
	color:##fff;
	z-index: 10000;
}
.ui-widget { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 12px; }
.ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 1em; }
.ui-autocomplete {
	max-height: 300px;
	overflow-y: auto;
	/* prevent horizontal scrollbar */
	overflow-x: hidden;
	/* add padding to account for vertical scrollbar */
	padding-right: 20px;
}
/* IE 6 doesn't support max-height
 * we use height instead, but this forces the menu to always be this tall
 */
* html .ui-autocomplete {
	height: 300px;
}
.ui-autocomplete-loading { background: white url('#dynpath#/global/host/dam/images/ui-anim_basic_16x16.gif') right center no-repeat; }
##chromebar {
	height:30px;
	width:100%;
	background-color:yellow;
	font-family:'Lucida Grande', Helvetica, Arial, sans-serif;
	font-size:13px;
	color:grey;
}
.chzn-container .chzn-drop .chzn-results {
	overflow: auto;
	max-height: 75px;
}
</style>
<!--- Custom CSS --->
<cfif fileexists("#ExpandPath("../..")#global/host/dam/views/layouts/custom/custom.css")>
	<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/custom/custom.css" />
</cfif>
</head>
<body>
<div id="container">#trim(maincontent)#
</div>
<!--- Window Div --->
<div id="thewindowcontent1" style="padding:10px;display:none;"></div>
<div id="thewindowcontent2" style="padding:10px;display:none;"></div>
<div id="div_forall" style="display:none;"></div>
</body>
</html>
</cfoutput>