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
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr">
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
<cfoutput>
<title>Plupload</title>
<cfheader name="Expires" value="#GetHttpTimeString(Now())#">
<cfheader name="CACHE-CONTROL" value="NO-CACHE, no-store, must-revalidate">
<cfheader name="PRAGMA" value="#GetHttpTimeString(Now())#">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<cfparam name="attributes.file_id" default="0">
<!-- Load Queue widget CSS and jQuery -->
<link rel="stylesheet" href="#dynpath#/global/js/plupload/jquery.plupload.queue/css/jquery.plupload.queue.css?_v=#attributes.cachetag#" type="text/css" media="screen" />
<script type="text/javascript" src="#dynpath#/global/js/jquery-1.10.2.min.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/plupload/plupload.full.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/plupload/jquery.plupload.queue/jquery.plupload.queue.js?_v=#attributes.cachetag#"></script>
<script type="text/javascript" src="#dynpath#/global/js/jquery-ui-1.10.3.custom/js/jquery-ui-1.10.3.custom.min.js?_v=#attributes.cachetag#"></script>
<style type="text/css">
body {
	background: white;
	font-size:12px;
    font-family: 'Helvetica Neue',Helvetica,Arial,"Nimbus Sans L",sans-serif;
}
</style>
<script type="text/javascript">
function S4() {
   return Math.random();
}
// Convert divs to queue widgets when the DOM is ready
$(function() {
	$("##uploader").pluploadQueue({
		// General settings
		runtimes : '#session.pluploadruntimes#',
		// RAZ-2907 check the condition for bulk upload versions
		<cfif structKeyExists(attributes,'file_id') AND attributes.file_id EQ 0>
			url : '#myself#c.apiupload&isbinary=false&plupload=true&folder_id=#attributes.folder_id#&nopreview=#attributes.nopreview#&av=#attributes.av#',
		<cfelse>
			url : '#myself#c.asset_upload&folder_id=#attributes.folder_id#&file_id=#attributes.file_id#&extjs=T&tempid=#attributes.tempid#&nopreview=#attributes.nopreview#&type=#attributes.type#&thefieldname=file',
		</cfif>
		// max_file_size : '2000mb',
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
				up.bind('UploadFile', function(up, file) {
					// RAZ-2907 check the condition for bulk upload versions
					<cfif structKeyExists(attributes,'file_id') AND attributes.file_id EQ 0>
						up.settings.url = '#myself#c.apiupload&isbinary=false&plupload=true&folder_id=#attributes.folder_id#&nopreview=#attributes.nopreview#&av=#attributes.av#&_v=' + S4();
						up.settings.multipart_params = { zip_extract: $('##zip_extract_plupl:checked').val(), upl_template: $('##upl_template_chooser').val(), file_size:file.size};
					<cfelse>
						up.settings.url = '#myself#c.asset_upload&folder_id=#attributes.folder_id#&file_id=#attributes.file_id#&extjs=T&tempid=#attributes.tempid#&nopreview=#attributes.nopreview#&type=#attributes.type#&thefieldname=file&_v=' + S4();
						up.settings.multipart_params = { zip_extract: $('##zip_extract_plupl:checked').val(), preview: false, file_size:file.size};
					</cfif>
					
				});
				<cfif !session.fromshare AND (!structKeyExists(attributes,'extjs'))>
					up.bind('UploadComplete', function() {
						<cfif !pl_return.cfc.pl.loadform.active>
							parent.$('##rightside').load('#myself#c.folder&col=F&folder_id=#attributes.folder_id#');
						<cfelse>
							// This is for the metaform plugin
							try {
								setTimeout(function() {
							    	delayloadingplugin();
								}, 1250)
							}
							catch(e) {};
							// parent.$('##tab_addassets').load('#myself#c.plugin_direct&comp=metaform.cfc.settings&func=loadForm');
						</cfif>
					});
				</cfif>
			}
		</cfif>
		
	});
	
	function delayloadingplugin(){
		// close window
		parent.$('##thewindowcontent1').dialog('close');
		// load metaform
		parent.$('##rightside').load('#myself#c.plugin_direct&comp=metaform.cfc.settings&func=loadForm');
	}

	$("##uploader").pluploadQueue.bind('UploadFile', function(up, file){
	    uploader.settings.url = uploader.settings.url.split('&filename')[0] + '&filename='+file.name;
	    return true;
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
		<input type="checkbox" name="zip_extract_plupl" id="zip_extract_plupl" value="1" checked="checked"> #myFusebox.getApplicationData().defaults.trans("header_zip_desc")#
	</div>
	<!--- Load upload templates here --->
	<cfif qry_templates.recordcount NEQ 0>
		<div style="float:right;">
			<select id="upl_template_chooser">
				<option value="0" selected="selected">Choose Rendition Template</option>
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
