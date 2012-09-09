<script language="javascript" type="text/javascript">

// Create Version
// function vercreate(fileid, type, tempid){
// 	$("#status").css("display","");
// 	$("#status").html('<cfoutput>#myFusebox.getApplicationData().defaults.trans("versions_create_progress")#</cfoutput>');
// 	$("#status").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
// 	// Submit Form
// 	loadcontent('versionlist','index.cfm?fa=c.versions_add&file_id=' + fileid + '&type=' + type + '&tempid=' + tempid);
// }
// Playback Version
function verplayback(fileid, type, version){
	$("#status").css("display","");
	$("#status").html('<cfoutput>#myFusebox.getApplicationData().defaults.trans("versions_playback_progress")#</cfoutput>');
	$("#status").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Submit Form
	loadcontent('versionlist','index.cfm?fa=c.versions_playback&file_id=' + fileid + '&type=' + type + '&version=' + version);
}
function reloadfilelisting(theid){
	if(theid == ""){
		theid = 0;
	}
	// Reload Explorer
	loadcontent('explorer','index.cfm?fa=c.explorer&folder_id=' + theid);
}

// Batch Actions

// Selected to Basket
function sendtobasket(theform){
   	// Send it to the basket
   	// Get values
	var url = 'index.cfm?fa=c.basket_put_include';
	// var items = '&file_id=' + fileids + '&thetype=' + filetypes;
	// Submit Form
	$.ajax({
		type: "POST",
		url: url,
	   	success: sendtobasket_feedback
	});
}

// Feedback on putting assets in basket
function sendtobasket_feedback(){
	// Flash the Basket
	flash_footer();
	// Reload Basket
	loadcontent('thedropbasket','index.cfm?fa=c.basket');
}

// General Batch Actions
function batchaction(theform, what, kind, folder_id, theaction){
	// Decide the what
	if(what == 'files')what = 'doc';
	if(what == 'images')what = 'img';
	if(what == 'videos')what = 'vid';
	if(what == 'audios')what = 'aud';
	if(what == 'all')what = 'all';
   	// Check what we have to do
   	//var theaction = $('#' + theid).val();
	// Get to work
	switch (theaction){
		case "move":
			showwindow('index.cfm?fa=c.move_file&type=movefile&thetype=' + what + '&folder_id=' + folder_id + '&kind=' + kind, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("move_file")#</cfoutput>', 550, 1);
			break;
		case "batch":
			showwindow('index.cfm?fa=c.batch_form&file_id=0&what=' + what + '&folder_id=' + folder_id, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("batch_selected_header")#</cfoutput>', 650, 1);
		  	break;
		case "delete":
			//alert('delete');
			showwindow('index.cfm?fa=ajax.remove_record&many=T&what=' + what + '&loaddiv=' + kind + '&folder_id=' + folder_id, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("remove")#</cfoutput>', 400, 1);
			break;
		case "chcoll":
			showwindow('index.cfm?fa=c.choose_collection&artofimage=list&artofvideo=&artofaudio=&artoffile=&thetype=' + what, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("add_to_collection")#</cfoutput>', 550, 1);
			break;
		case "exportmeta":
			showwindow('index.cfm?fa=c.meta_export&what=&thetype=' + what, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("header_export_metadata")#</cfoutput>', 600, 1);
			break;
		case "shareon":
			// Show loading gif
			loadinggif("feedback_delete_" + kind);
			// Do the action
			$("#dummy_" + kind).load('index.cfm?fa=c.batch_sharing&state=t&file_ids=' + fileids + '&folder_id=' + folder_id);
			// Show feedback
			$("#feedback_delete_" + kind).html('<div style="width:200px;">Sharing enabled</div>');
			break;
		case "shareoff":
			// Show loading gif
			loadinggif("feedback_delete_" + kind);
			// Do the action
			$("#dummy_" + kind).load('index.cfm?fa=c.batch_sharing&state=f&file_ids=' + fileids + '&folder_id=' + folder_id);
			// Show feedback
			$("#feedback_delete_" + kind).html('<div style="width:200px;">Sharing disabled</div>');
			break;
		case "prev":
			showwindow('index.cfm?fa=ajax.recreate_previews&thetype=' + what, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("batch_recreate_preview")#</cfoutput>', 550, 1);
			break;
	}
}
// For Image Coversion
function convertimages(theform){
	// Loop over the convert_to checkboxes
	var convertto = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('convert_to') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           		convertto += document.forms[theform].elements[i].value + ',';
           	}
      	}
   	}
	// Send Feedback to Div
   	document.getElementById('statusconvert').style.visibility = "visible";
	$("#statusconvert").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvert").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Call the Action
	loadcontent('statusconvertdummy','index.cfm?fa=c.images_convert&file_id=' + document.forms[theform].file_id.value + '&theorgname=' + escape(document.forms[theform].theorgname.value) + '&thepath=' + document.forms[theform].thepath.value + '&convert_width_jpg=' + document.forms[theform].convert_width_jpg.value + '&convert_height_jpg=' + document.forms[theform].convert_height_jpg.value + '&convert_width_gif=' + document.forms[theform].convert_width_gif.value + '&convert_height_gif=' + document.forms[theform].convert_height_gif.value + '&convert_width_png=' + document.forms[theform].convert_width_png.value + '&convert_height_png=' + document.forms[theform].convert_height_png.value + '&convert_width_tif=' + document.forms[theform].convert_width_tif.value + '&convert_height_tif=' + document.forms[theform].convert_height_tif.value + '&convert_width_bmp=' + document.forms[theform].convert_width_bmp.value + '&convert_height_bmp=' + document.forms[theform].convert_height_bmp.value + '&convert_to=' + convertto + '&link_kind=' + document.forms[theform].link_kind.value + '&link_path_url=' + escape(document.forms[theform].link_path_url.value));
}

// For Video Coversion
function convertvideos(theform){
	// Loop over the convert_to checkboxes
	var convertto = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('convert_to') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           		convertto += document.forms[theform].elements[i].value + ',';
           	}
      	}
   	}
	// Send Feedback to Div
   	document.getElementById('statusconvert').style.visibility = "visible";
	$("#statusconvert").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvert").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Call the Action
	loadcontent('statusconvertdummy','index.cfm?fa=c.videos_convert&file_id=' + document.forms[theform].file_id.value + '&theorgname=' + escape(document.forms[theform].theorgname.value) + '&thepath=' + document.forms[theform].thepath.value + '&convert_width_wmv=' + document.forms[theform].convert_width_wmv.value + '&convert_height_wmv=' + document.forms[theform].convert_height_wmv.value + '&convert_width_avi=' + document.forms[theform].convert_width_avi.value + '&convert_height_avi=' + document.forms[theform].convert_height_avi.value + '&convert_width_mov=' + document.forms[theform].convert_width_mov.value + '&convert_height_mov=' + document.forms[theform].convert_height_mov.value + '&convert_width_mpg=' + document.forms[theform].convert_width_mpg.value + '&convert_height_mpg=' + document.forms[theform].convert_height_mpg.value + '&convert_width_mp4=' + document.forms[theform].convert_width_mp4.value + '&convert_height_mp4=' + document.forms[theform].convert_height_mp4.value + '&convert_wh_3gp=' + document.forms[theform].convert_wh_3gp.value + '&convert_width_flv=' + document.forms[theform].convert_width_flv.value + '&convert_height_flv=' + document.forms[theform].convert_height_flv.value + '&convert_width_rm=' + document.forms[theform].convert_width_rm.value + '&convert_height_rm=' + document.forms[theform].convert_height_rm.value  + '&convert_width_ogv=' + document.forms[theform].convert_width_ogv.value + '&convert_height_ogv=' + document.forms[theform].convert_height_ogv.value  + '&convert_width_webm=' + document.forms[theform].convert_width_webm.value + '&convert_height_webm=' + document.forms[theform].convert_height_webm.value + '&convert_to=' + convertto + '&convert_width_3gp=' + document.forms[theform].convert_width_3gp.value + '&convert_height_3gp=' + document.forms[theform].convert_height_3gp.value + '&theorgext=' + document.forms[theform].theorgext.value + '&link_kind=' + document.forms[theform].link_kind.value + '&link_path_url=' + escape(document.forms[theform].link_path_url.value));
}

// For Audio Coversion
function convertaudios(theform){
	// Loop over the convert_to checkboxes
	var convertto = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('convert_to') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           		convertto += document.forms[theform].elements[i].value + ',';
           	}
      	}
   	}
	// Send Feedback to Div
   	$("#statusconvert").css("display","");
	$("#statusconvert").fadeTo("fast", 100);
	$("#statusconvert").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvert").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Get values
	var bitmp3 = $('#convert_bitrate_mp3').val();
	var bitogg = $('#convert_bitrate_ogg').val();
	var orgext = $('#theorgext').val();
	var orgname = escape($('#theorgname').val());
	var fileid = $('#file_id').val();
	var thepath = escape($('#thepath').val());
	var link_kind = $('#link_kind').val();
	// Call the Action
	loadcontent('statusconvertdummy','index.cfm?fa=c.audios_convert&convert_to=' + convertto + '&file_id=' + fileid + '&theorgname=' + orgname + '&thepath=' + thepath + '&convert_bitrate_mp3=' + bitmp3 + '&convert_bitrate_ogg=' + bitogg + '&theorgext=' + orgext + '&link_kind=' + link_kind);
}
</script>