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
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<cfoutput>
<link rel="stylesheet" href="#dynpath#/global/host/dam/views/layouts/main.css" type="text/css" />
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js"></script>
</head>
<body>
<cfif structKeyExists(form,"fieldnames")>
   Your file is uploaded. Please press the import button now.
<cfelse>
    <form action="#self#" name="upme" id="upme" method="post" enctype="multipart/form-data">
        <input type="hidden" name="fa" value="c.users_upload_do">
        <input type="hidden" name="tempid" value="#attributes.tempid#">
        <input type="hidden" name="thefieldname" value="filedata">
        <input type="file" id="filedata" name="filedata" class="button" />
    </form>
</cfif>
</cfoutput>
</body>
<!--- JS --->
<script type="text/javascript">
    $('#filedata').change(function() { 
        // select the form and submit
        $('#upme').submit();
    });
</script>
</html>
