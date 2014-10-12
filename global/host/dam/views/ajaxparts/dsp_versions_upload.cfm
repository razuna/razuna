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
<cfparam name="attributes.file_id" default="0">
<cfparam name="attributes.preview" default="false">
<cfparam name="attributes.type" default="">
<cfoutput>
<head>
<link rel="stylesheet" href="#dynpath#/global/host/dam/views/layouts/main.css" type="text/css" />
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js"></script>
</head>
<body>
<cfif structKeyExists(form,"fieldnames")>
    <div id="updummy" style="display:none;"></div>
    <cfif isdefined("form.preview") AND form.preview>
        <script type="text/javascript">
            $('##updummy').load('#myself#c.previewimage_activate&tempid=#attributes.tempid#&type=#attributes.type#');
        </script>
        <span style="font-weight:bold;color:green;">New preview image has been uploaded.</span><br />In order to see it you most likely need to clear your cache!
    <cfelse>
        <span style="font-weight:bold;color:green;">We are processing your new version now.</span><br />You should be able to see the new version after a refresh of the list below. 
        <br />#myFusebox.getApplicationData().defaults.trans("versions_create_progress")#
        <script type="text/javascript">
            // Delay
            try {
                    setTimeout(function() {
                        callwithdelay();
                    }, 2000)
                }
            catch(e) {};
            function callwithdelay(){
                parent.$('##versionlist').load('index.cfm?fa=c.versions_add&file_id=#attributes.file_id#&folder_id=#attributes.folder_id#&type=#attributes.type#&tempid=#attributes.tempid#');
            }
        </script>
    </cfif>
<cfelse>
    <form action="#self#" name="upme" id="upme" method="post" enctype="multipart/form-data">
        <input type="hidden" name="fa" value="c.asset_upload">
        <input type="hidden" name="tempid" value="#attributes.tempid#">
        <input type="hidden" name="thepath" value="#thisPath#">
        <input type="hidden" name="thefieldname" value="filedata">
        <input type="hidden" name="folder_id" value="#attributes.folder_id#">
        <input type="hidden" name="file_id" value="#attributes.file_id#">
        <input type="hidden" name="preview" value="#attributes.preview#">
        <input type="hidden" name="type" value="#attributes.type#">
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