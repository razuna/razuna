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
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
<title>Razuna - the open source alternative to Digital Asset Management</title>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<!--- Control the cache. If we have to switch language then reset the cache
<cfheader name="Expires" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#">
<cfheader name="PRAGMA" value="#GetHttpTimeString(DateAdd('d', 1, Now()))#"> --->
<meta http-equiv="X-UA-Compatible" content="chrome=1">
<cfheader name="Expires" value="#GetHttpTimeString(Now())#">
<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#">
<script language="JavaScript" type="text/javascript">var dynpath = '#dynpath#';</script>
<!--- CSS --->
<!--- <link rel="stylesheet" type="text/css" href="#dynpath#/global/js/jquery-ui-1.8.21.custom/css/smoothness/jquery-ui-1.8.21.custom.css" /> --->
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/jquery-ui-1.10.3.custom/css/smoothness/jquery-ui-1.10.3.custom.css" />
<link rel="stylesheet" type="text/css" href="views/layouts/main.css" />
<link rel="stylesheet" type="text/css" href="views/layouts/error.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/markitup/markitup/skins/simple/style.css" />
<link rel="stylesheet" type="text/css" href="#dynpath#/global/js/markitup/markitup/sets/html/style.css" />
<!--- Cache JS --->
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-ui-1.10.3.custom/js/jquery-ui-1.10.3.custom.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.validate.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery.form.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/markitup/markitup/jquery.markitup.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/markitup/markitup/sets/html/set.js"></script>
<script type="text/javascript" src="js/global.js"></script>
<link rel="SHORTCUT ICON" href="favicon.ico" />
<style>
.ui-widget { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 12px; }
.ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button { font-family: Helvetica Neue,Helvetica,Arial,Nimbus Sans L,sans-serif; font-size: 1em; }
</style>
</head>
<body>
<div id="container">
<div id="apDiv1">#trim( headercontent )#</div>
<div id="apDiv3">#trim( leftcontent )#</div>
<div id="apDiv4">#trim( maincontent )#</div>
<div id="apDiv5">#trim( showcontent )#</div>
</div>
<div id="footer">#trim( footercontent )#</div>
<!--- Window Div --->
<div id="thewindowcontent1" style="padding:10px;display:none;"></div>
<!--- Dummy div --->
<div id="loaddummy" style="display:none;"></div>
</body>
</html>
</cfoutput>