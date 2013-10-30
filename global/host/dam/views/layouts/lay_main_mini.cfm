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
<cfheader name="Expires" value="#GetHttpTimeString(Now())#">
<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#">
<cfheader name="P3P" value="CP=\\\"IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\\\"">
<script language="JavaScript" type="text/javascript">var dynpath = '#dynpath#';</script>
<!--- CSS --->
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/jquery-ui-1.10.3.custom/css/smoothness/jquery-ui-1.10.3.custom.css?_v=#attributes.cachetag#" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/host/dam/views/layouts/mini.css?_v=#attributes.cachetag#" />
<!--- JS --->
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-migrate-1.2.1.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-ui-1.10.3.custom/js/jquery-ui-1.10.3.custom.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/host/dam/js/mini.js?_v=#attributes.cachetag#"></script>
<!--- Favicon --->
<cfif fileexists("#ExpandPath("../..")#global/host/favicon/#session.hostid#/favicon.ico")>
	<link rel="SHORTCUT ICON" href="#dynpath#/global/host/favicon/#session.hostid#/favicon.ico" />
<cfelse>
	<link rel="SHORTCUT ICON" href="#dynpath#/global/host/dam/images/favicon.ico" />
</cfif>
<link rel="apple-touch-icon" href="#dynpath#/global/host/dam/images/razuna_icon_114.png" />
</head>
<body>
<div id="container">
	<div id="outer">
		<div style="float:left;">
			<cfif fileexists("#ExpandPath("../..")#global/host/logo/#session.hostid#/logo.jpg")>
				<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" border="0" />
			<cfelse>
				<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="220" height="34" border="0" style="padding:3px 0px 0px 5px;">
			</cfif>
		</div>
		<div style="float:right;padding-top:10px;">
			<a href="#myself#c.mini_logoff">Sign out (#session.firstlastname#)</a>
		</div>
		<div style="clear:both;"></div>
		<br />
		<br />
		<div style="padding-left:10px;">
			#trim( thecontent )#
		</div>
		<br />
	</div>
</div>
</body>
</html>
</cfoutput>