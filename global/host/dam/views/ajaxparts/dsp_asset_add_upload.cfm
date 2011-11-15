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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
<cfoutput>
<title>Plupload</title>
<cfparam name="attributes.file_id" default="0">
<!-- Load Queue widget CSS and jQuery -->
<cfif application.razuna.isp>
<link rel="stylesheet" href="//d3jcwo7gahoav9.cloudfront.net/razuna/js/plupload/jquery.plupload.queue/css/jquery.plupload.queue.css" type="text/css" media="screen" />
<script type="text/javascript" src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/jquery-1.6.4.min.js"></script>
<script type="text/javascript" src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/plupload/plupload.full.js"></script>
<script type="text/javascript" src="//d3jcwo7gahoav9.cloudfront.net/razuna/js/plupload/jquery.plupload.queue/jquery.plupload.queue.js"></script>
<cfelse>
<link rel="stylesheet" href="#dynpath#/global/js/plupload/jquery.plupload.queue/css/jquery.plupload.queue.css" type="text/css" media="screen" />
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.6.4.min.js"></script>
<!-- Thirdparty intialization scripts, needed for the Google Gears and BrowserPlus runtimes -->
<!--- <script type="text/javascript" src="#dynpath#/global/js/plupload/gears_init.js"></script> --->
<!-- Load plupload and all it's runtimes and finally the jQuery queue widget -->
<script type="text/javascript" src="#dynpath#/global/js/plupload/plupload.full.js"></script>
<script type="text/javascript" src="#dynpath#/global/js/plupload/jquery.plupload.queue/jquery.plupload.queue.js"></script>
</cfif>
<style type="text/css">
body {
	background: white;
	font-size:12px;
    font-family: 'Helvetica Neue',Helvetica,Arial,"Nimbus Sans L",sans-serif;
}
</style>
<script type="text/javascript">
// Convert divs to queue widgets when the DOM is ready
$(function() {
	$("##uploader").pluploadQueue({
		// General settings
		runtimes : '#session.pluploadruntimes#',
		url : '#myself#c.apiupload&isbinary=false&plupload=true&folder_id=#attributes.folder_id#&sessiontoken=#attributes.sessiontoken#&nopreview=#attributes.nopreview#&av=#attributes.av#',
		max_file_size : '2000mb',
		unique_names : false,
		multipart : true,
		//chunk_size : '1mb',
		required_features : 'multipart',
		//multipart_params : {param1: 12345, param2:  },
		
		// Resize images on clientside if we can
		// resize : {width : 320, height : 240, quality : 90},

		// Specify what files to browse for
		/* 
		filters : [
			{title : "Image files", extensions : "jpg,gif,png"},
			{title : "Zip files", extensions : "zip"}
		],
		*/

		// Flash settings
		flash_swf_url : '#dynpath#/global/js/plupload/plupload.flash.swf',

		// Silverlight settings
		silverlight_xap_url : '#dynpath#/global/js/plupload/plupload.silverlight.xap'
		<cfif attributes.nopreview EQ 0>
			,		
			preinit : function(up) {
				up.bind('UploadFile', function() {
					up.settings.multipart_params = { zip_extract: $('##zip_extract_plupl:checked').val(), upl_template: $('##upl_template_chooser').val() };
				});
			}
		</cfif>
		
	});
	
	// Extend global multipart_params for each UploadFile dynamically
	/*
$('##uploader').pluploadQueue().bind('QueueChanged',
    function() { 
        $('##uploader').pluploadQueue().settings.multipart_params = { zip_extract: $('##zip_extract_plupl').attr('checked') };
    });
*/
	
	
   /*
 $("##uploader").pluploadQueue().bind('UploadFile', function(up) {
    	alert($('##zip_extract_plupl').attr('checked'));
    	$('##uploader').extend(up.settings.multipart_params, { param1 : $('##zip_extract_plupl').attr('checked') });
    });
*/
    	
	// Client side form validation
	/*
	$('form').submit(function(e) {
			var uploader = $('##uploader').pluploadQueue();
	
			// Validate number of uploaded files
			if (uploader.total.uploaded == 0) {
				// Files in queue upload them first
				if (uploader.files.length > 0) {
					// When all files are uploaded submit form
					uploader.bind('UploadProgress', function() {
						if (uploader.total.uploaded == uploader.files.length)
							alert('done');
					});
	
					uploader.start();
				} else
					alert('You must at least upload one file.');
	
				e.preventDefault();
			}
		});
	*/
});
</script>
<body>
<div id="uploader">
	<p>You browser doesn't have Flash, Silverlight or HTML5 support.</p>
</div>
<cfif attributes.nopreview EQ 0>
<div>
	<div style="float:left;">
		<input type="checkbox" name="zip_extract_plupl" id="zip_extract_plupl" value="1" checked="checked"> #defaultsObj.trans("header_zip_desc")#
	</div>
	<!--- Load upload templates here --->
	<cfif qry_templates.recordcount NEQ 0>
		<div style="float:right;">
			<select id="upl_template_chooser">
				<option value="0" selected="selected">Choose Upload Template</option>
				<option value="0">---</option>
				<cfloop query="qry_templates">
					<option value="#upl_temp_id#">#upl_name#</option>
				</cfloop>
			</select>
		</div>
	</cfif>
</div>
</cfif>
<div id="test"></div>
</cfoutput>
</body>
</html>
