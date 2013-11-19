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
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js"></script>
</head>
<body>
<cfif structKeyExists(form,"fieldnames")>
    <span style="font-weight:bold;color:green;">Uploaded successfully</span>
    <script type="text/javascript">
        parent.$('##thewmimg').html('<img src="../../#wmupload.imgpath#" border="0" width="200" />');
        parent.$('##wm_image_path').val('#wmupload.fordbpath#');
    </script>
<cfelse>
    <form action="#self#" name="upme" id="upme" method="post" enctype="multipart/form-data">
        <input type="hidden" name="fa" value="c.admin_watermark_upload">
        <input type="hidden" name="wm_temp_id" value="#attributes.wm_temp_id#">
        <input type="hidden" name="thepathup" value="#ExpandPath("../../")#">
        <input type="hidden" name="thefield" value="filedata">
        <input type="file" id="filedata" name="filedata" class="button" />
    </form>
</cfif>
</body>
</cfoutput>
</html>
<!--- JS --->
<script type="text/javascript">
    $('#filedata').change(function() { 
        // select the form and submit
        $('#upme').submit();
    });
</script>