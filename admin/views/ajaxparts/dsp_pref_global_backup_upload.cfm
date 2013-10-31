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
<script language="JavaScript" type="text/javascript">var dynpath = '#dynpath#';</script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/host/dam/js/global.js"></script>
<link rel="stylesheet" href="#dynpath#/admin/views/layouts/main.css" type="text/css" />
<head>
<body>
<cfform action="#myself##xfa.uploadto#" name="upme" method="post" enctype="multipart/form-data" target="foo" onSubmit="window.open('','foo','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');">
<cfinput type="hidden" name="thefield" value="thefile">
<cfinput type="file" name="thefile" validate="regular_expression" pattern="[a-zA-Z0-9_-]+.raz.zip" validateat="onSubmit" required="true" message="File must be a valid ZIP archive!" style="width:250px;" /> 
<cfinput type="submit" name="save" value="Upload & Restore" class="button"> 
</cfform>
<!---
<div id="upprogress" style="float:left;"></div>
<script language="JavaScript" type="text/javascript">
	function setprogress(){
		// Set div to waiting
		$("##upprogress").html('Working...');
		loadinggif('upprogressgif');
	}
</script>
--->

</cfoutput>
</body>
</html>
