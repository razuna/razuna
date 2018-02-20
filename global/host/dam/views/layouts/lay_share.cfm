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
		<title><cfif application.razuna.whitelabel>#wl_html_title#<cfelse>Razuna Enterprise Digital Asset Management</cfif></title>
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<!--- Control the cache --->
		<!--- <cfheader name="Expires" value="#GetHttpTimeString(Now())#">
		<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
		<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#"> --->
		<cfheader name="P3P" value="CP=\\\"IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\\\"">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<script type="text/javascript">var dynpath = '#dynpath#';</script>
		<!--- CSS --->
		<link rel="stylesheet" type="text/css" href="#dynpath#/global/dist/app_#attributes.cachetag#.min.css" />
		<!--- JS --->
		<script type="text/javascript" src="#dynpath#/global/js/jquery-3.3.1.min.js"></script>
		<script type="text/javascript" src="#dynpath#/global/dist/app_#attributes.cachetag#.min.js"></script>
		<script type="text/javascript" src="#dynpath#/global/dist/vendors_#attributes.cachetag#.min.js"></script>
		<!--- Favicon --->
		<cfif fileexists("#ExpandPath("../../")#global/host/favicon/#session.hostid#/favicon.ico")>
			<link rel="SHORTCUT ICON" href="#dynpath#/global/host/favicon/#session.hostid#/favicon.ico" />
		<cfelse>
			<link rel="SHORTCUT ICON" href="#dynpath#/global/host/dam/images/favicon.ico" />
		</cfif>
		<link rel="apple-touch-icon" href="#dynpath#/global/host/dam/images/razuna_icon_114.png" />

		<style>
		##apDiv4 {
			position: absolute;
			margin-left:20px;
			top:50px;
			height: auto;
			width: 95%;
			min-width: 680px;
			z-index:4;
			padding-left: 10px;
			padding-right: 10px;
			padding-bottom: 10px;
		}
		.ui-widget { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 12px; }
		.ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 1em; }
		</style>
		<!--- Custom CSS --->
		<cfif fileexists("#ExpandPath("../..")#global/host/dam/views/layouts/custom/custom.css")>
			<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/custom/custom.css?_v=#attributes.cachetag#" />
		</cfif>
	</head>
	<body>
		<div id="container">
			<div id="apDiv1">#trim( headercontent )#</div>
			<!--- <div id="apDiv3">#trim( leftcontent )#</div> --->
			<div id="apDiv4">#trim( maincontent )#</div>
		</div>
		<div id="footer">#trim( footercontent )#</div>
		<div id="thewindowcontent1" style="padding:10px;display:none;"></div>
		<div id="thewindowcontent2" style="padding:10px;display:none;"></div>
		<!--- Dummy div --->
		<div id="loaddummy" style="display:none;"></div>
		<!--- JS: FOLDERS --->
		<cfinclude template="../../js/folders.cfm" runonce="true">
		<!--- JS: BASKET --->
		<cfinclude template="../../js/basket.cfm">
	</body>
</html>
</cfoutput>