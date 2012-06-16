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
<head>
<cfoutput>
<link rel="stylesheet" href="#dynpath#/global/host/dam/views/layouts/main.css" type="text/css" />
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/upload/swfupload.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/upload/jquery-asyncUpload-0.1.js"></script>
<script>
    $(function() {
        $("##yourID").makeAsyncUploader({
        	flash_url: '#dynpath#/global/js/upload/swfupload.swf',
            upload_url: "#myself#c.meta_imp_upload_do&tempid=#attributes.tempid#&thefieldname=filedata&cfid=#cfid#&cftoken=#cftoken#",
            button_image_url: '#dynpath#/global/js/upload/blankButton.png',
            file_size_limit: "2000 MB",
            file_types: "*.csv;*.xls;*.xlsx",
            file_upload_limit: 100,
			file_queue_limit: 0,
			debug: false
        });
    });  
</script>
<style type="text/css">
DIV.ProgressBar { width: 100px; padding: 0; border: 1px solid black; margin-right: 1em; height:.75em; margin-left:1em; display:-moz-inline-stack; display:inline-block; zoom:1; *display:inline; }
DIV.ProgressBar DIV { background-color: Green; font-size: 1pt; height:100%; float:left; }
SPAN.asyncUploader OBJECT { position: relative; top: 5px; left: 10px; z-index: 7000;}
</style>
</head>
<body>
<form action="#self#" name="upme" method="post" enctype="multipart/form-data">
<input type="file" id="yourID" name="yourID" />
</form>
</cfoutput>
</body>
</html>
