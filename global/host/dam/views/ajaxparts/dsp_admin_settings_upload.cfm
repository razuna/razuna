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
<cfoutput>
<head>
<link rel="stylesheet" href="#dynpath#/global/host/dam/views/layouts/main.css" type="text/css" />
<head>
<body>
<cfform action="#myself#c.prefs_imgupload" name="upme" method="post" enctype="multipart/form-data">
<cfinput type="hidden" name="thepathup" value="#ExpandPath("../../")#">
<cfinput type="hidden" name="uploadnow" value="T">
<cfinput type="hidden" name="thefield" value="thefile">
<cfif structKeyExists(attributes,"logoimg") AND attributes.logoimg EQ "true">
	<cfinput type="hidden" name="logoimg" value="true">
	<cfinput size="50" type="file" name="thefile" validate="regular_expression" pattern="logo.jpg" validateat="onSubmit" required="true" message="Name your file logo.jpg!" />
<cfelseif structKeyExists(attributes,"favicon") AND attributes.favicon eq "true">
	<cfinput type="hidden" name="favicon" value="true">
	<cfinput size="50" type="file" name="thefile" validate="regular_expression" pattern="favicon.ico" validateat="onSubmit" required="true" message="Name your file favicon.ico!" />
<cfelse>
	<cfinput type="hidden" name="loginimg" value="true">
	<cfinput size="50" type="file" name="thefile" validate="regular_expression" pattern="[*.jpg|*.gif|*.png]" validateat="onSubmit" required="true" message="Only jpg, gif and png formats please!" />
</cfif>
<cfinput type="submit" name="save" value="Upload" class="button"> 
</cfform>
<cfif structkeyexists(form,"fieldnames")>Image uploaded successfully. Please click on refresh.</cfif>
</cfoutput>
</body>
</html>
