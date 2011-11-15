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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" >
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
<title>Razuna - Enterprise Digital Asset Management</title>
<meta http-equiv="content-type" content="text/html;charset=utf-8" />
<!--- Control the cache --->
<cfheader name="Expires" value="#GetHttpTimeString(Now())#">
<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#">
<cfset dynpath = cgi.context_path>
<link rel="SHORTCUT ICON" href="favicon.ico" />
<script language="JavaScript" type="text/javascript">var dynpath = '';</script>
<!--- JS --->
<script type="text/javascript" src="jquery-1.4.4.min.js"></script>
<script type="text/javascript" src="../global/host/dam/js/global.js"></script>
<!--- CSS --->
<link rel="stylesheet" type="text/css" href="../global/host/dam/views/layouts/main.css" />
</head>
<body>
<div id="container" style="padding-left:20%;">
	<h1>Update & Export Script for a Razuna 1.4.x installation</h1>
	<p>You should follow the <a href="http://wiki.razuna.com/display/ecp/Upgrade+Guide" target="_blank">Update Guide on our Razuna Wiki pages</a> in order to know what you are doing here!</p>
	<p style="font-weight:bold;color:red;">Caution: Please make a backup of you database first in order to be on the save side!</p>
	<h2>Update current database</h2>
	<p>This step will update your 1.4.x database to the new 1.4.2 structure (You are using the #ucase(application.razuna.thedatabase)# database for Razuna).</p>
	<p>Click the button below to update now!</p>
	<p><input type="button" class="button" value="Update DB!" onclick="updatethedb();return false;"></p>
	<div id="updatedb"></div>
	<h2>Export Data</h2>
	<p>In this step we will export your data to a "Razuna format backup". This backup can be used to import your setup to the new Razuna 1.4.2 installation.</p>
	<p><input type="button" class="button" value="Create Export Now!" onclick="dobackup();return false;"></p>
	<div id="dummy" style="display:none;"></div>
</div>
</body>
</html>
</cfoutput>
<script type="text/javascript">
	function updatethedb(){
		//$('#updatedb').html('<div style="font-weight:bold;">Please wait. We are updating your database.</div>');
		//loadcontent('dummy','action.cfm?a=update_db');
		//$('#updatedb').html('<div style="font-weight:bold;color:green;">The update to your database has been successful. Please continue!</div>');
		window.open('action.cfm?a=update_db', 'winbackup', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
	}
	function dobackup(){
		window.open('action.cfm?a=export_db', 'winbackup', 'toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
	}
</script>