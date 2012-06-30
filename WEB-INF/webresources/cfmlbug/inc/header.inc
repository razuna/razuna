<cfsilent>
<!---
 *  Copyright (C) 2000 - 2010 TagServlet Ltd
 *
 *  This file is part of Open BlueDragon (OpenBD) CFML Server Engine.
 *
 *  OpenBD is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  Free Software Foundation,version 3.
 *
 *  OpenBD is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with OpenBD.  If not, see http://www.gnu.org/licenses/
 *
 *  Additional permission under GNU GPL version 3 section 7
 *
 *  If you modify this Program, or any covered work, by linking or combining
 *  it with any of the JARS listed in the README.txt (or a modified version of
 *  (that library), containing parts covered by the terms of that JAR, the
 *  licensors of this Program grant you additional permission to convey the
 *  resulting work.
 *  README.txt @ http://www.openbluedragon.org/license/README.txt
 *
 *  http://openbd.org/
 * 	$Id: header.inc 2121 2012-06-22 10:29:03Z alan $
 --->
	<cfparam name="request.page.title" default="">
	<cfparam name="request.page.heading" default="">

	<cfset request.root				= "cfmlbug.cfres?_f=">
	<cfset request.staticroot	= "cfmlbug-static.cfres?f=">

</cfsilent><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><cfoutput>#request.page.title#</cfoutput></title>
	<link rel="stylesheet" href="<cfoutput>#request.staticroot#</cfoutput>css/style.css" type="text/css" media="screen" charset="utf-8" />
	<script>var requestStaticRoot	= "cfmlbug-static.cfres?f=/cfmlbug/"; var requestRoot	= "cfmlbug.cfres?_f=";</script>
	<script src="<cfoutput>#request.staticroot#</cfoutput>jquery-1.7.2.js"></script>
	<script src="<cfoutput>#request.staticroot#</cfoutput>aw20.filepaths.min.js"></script>
</head>
<body>