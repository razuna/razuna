<script language="javascript" type="text/javascript">

// Create Version
function vercreate(fileid, type, tempid){
	$("#status").css("display","");
	$("#status").html('<cfoutput>#defaultsObj.trans("versions_create_progress")#</cfoutput>');
	$("#status").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Submit Form
	loadcontent('versionlist','<cfoutput>#myself#</cfoutput>c.versions_add&file_id=' + fileid + '&type=' + type + '&tempid=' + tempid);
}

// Playback Version
function verplayback(fileid, type, version){
	$("#status").css("display","");
	$("#status").html('<cfoutput>#defaultsObj.trans("versions_playback_progress")#</cfoutput>');
	$("#status").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Submit Form
	loadcontent('versionlist','<cfoutput>#myself#</cfoutput>c.versions_playback&file_id=' + fileid + '&type=' + type + '&version=' + version);
}

// Save Comment
function addcomment(fileid,type){
	loadcontent('comlist','<cfoutput>#myself#</cfoutput>c.comments_add&file_id=' + fileid + '&type=' + type + '&comment=' + escape($('#assetComment').val()) );
	// Reload comment section to re-issue new id
	loadcontent('divcomments','<cfoutput>#myself#</cfoutput>c.comments&file_id=' + fileid + '&type=' + type);
}
// Update Comment
function updatecomment(fileid,comid,type){
	loadcontent('comlist','<cfoutput>#myself#</cfoutput>c.comments_update&file_id=' + fileid + '&com_id=' + comid + '&type=' + type + '&comment=' + escape($('#commentup').val()) );
	// Hide Window
	destroywindow(2);
}

// Check all checkboxes
function CheckAll(myform) {
	for (var i = 0; i < document.forms[myform].elements.length; i++) {
	if (document.forms[myform].elements[i].type == 'checkbox'){
		document.forms[myform].elements[i].checked =! (document.forms[myform].elements[i].checked);
		enablesub(myform);
		}
	}
}

function reloadfilelisting(theid){
	if(theid == ""){
		theid = 0;
	}
	// Reload Explorer
	loadcontent('explorer','<cfoutput>#myself#</cfoutput>c.explorer&folder_id=' + theid);
}

// Batch Actions

// Selected to Basket
function sendtobasket(theform){
	// Get the checked values (file id's)
	var fileids = '';
	var filetypes = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('file_id') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           	fileids += document.forms[theform].elements[i].value + ',';
           	filetypes += document.forms[theform].elements[i].value + '-' + document.forms[theform].thetype.value + ',';
           	}
      	}
   	}
   	// Send it to the basket
   	// Get values
	var url = '<cfoutput>#myself#</cfoutput>c.basket_put_include';
	var items = '&file_id=' + fileids + '&thetype=' + filetypes;
	// Submit Form
	$.ajax({
		type: "POST",
		url: url,
	   	data: items,
	   	success: sendtobasket_feedback
	});
}

// Feedback on putting assets in basket
function sendtobasket_feedback(){
	// Flash the Basket
	flash_footer();
	// Reload Basket
	loadcontent('thedropbasket','<cfoutput>#myself#</cfoutput>c.basket');
}

// Selected to Collection
function sendtocol(theform){
	// Get the checked values (file id's)
	var fileids = '';
	var filetypes = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('file_id') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           	fileids += document.forms[theform].elements[i].value + ',';
           	filetypes += document.forms[theform].elements[i].value + '-' + document.forms[theform].thetype.value + ',';
           	}
      	}
   	}
   	// Store values in sessions
	var url = '<cfoutput>#myself#</cfoutput>c.store_file_values';
	var items = '&file_id=' + fileids + '&thetype=' + filetypes;
	// Submit Form
	$.ajax({
		type: "POST",
		url: url,
	   	data: items
	});
   	// Send to Collection
   	showwindow('<cfoutput>#myself#</cfoutput>c.choose_collection&artofimage=list&artofvideo=&artofaudio=&artoffile=', '<cfoutput>#defaultsObj.trans("add_to_collection")#</cfoutput>', 550, 1);
}

// General Batch Actions
function batchaction(theform, what, kind, folder_id, theid){
	// Get the checked values (file id's)
	var fileids = '';
	var filetypes = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('file_id') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           	fileids += document.forms[theform].elements[i].value + ',';
           	}
      	}
   	}
   	// Only continue if there is something selected
   	if (fileids != ''){
   		// Store values in sessions
		var url = '<cfoutput>#myself#</cfoutput>c.store_file_values';
		var items = '&file_id=' + fileids;
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items
		});
   		// Decide the what
   		if(what == 'files')what = 'doc';
		if(what == 'images')what = 'img';
		if(what == 'videos')what = 'vid';
		if(what == 'audios')what = 'aud';
		if(what == 'all')what = 'all';
	   	// Check what we have to do
	   	var theaction = $('#' + theid).val();
		// Get to work
		switch (theaction){
			case "move":
				showwindow('<cfoutput>#myself#</cfoutput>c.move_file&type=movefile&thetype=' + what + '&folder_id=' + folder_id, '<cfoutput>#defaultsObj.trans("move_file")#</cfoutput>', 550, 1);
				break;
			case "batch":
				showwindow('<cfoutput>#myself#</cfoutput>c.batch_form&file_id=0&what=' + what + '&folder_id=' + folder_id, '<cfoutput>#defaultsObj.trans("batch_selected_header")#</cfoutput>', 650, 1);
			  	break;
			case "delete":
				//alert('delete');
				showwindow('<cfoutput>#myself#</cfoutput>ajax.remove_record&many=T&what=' + what + '&loaddiv=' + kind + '&folder_id=' + folder_id, '<cfoutput>#defaultsObj.trans("remove")#</cfoutput>', 400, 1);
				break;
			case "chcoll":
				showwindow('<cfoutput>#myself#</cfoutput>c.choose_collection&artofimage=list&artofvideo=&artofaudio=&artoffile=&thetype=' + what, '<cfoutput>#defaultsObj.trans("add_to_collection")#</cfoutput>', 550, 1);
				break;
			case "exportmeta":
				showwindow('<cfoutput>#myself#</cfoutput>c.meta_export&what=&thetype=' + what, '<cfoutput>#defaultsObj.trans("header_export_metadata")#</cfoutput>', 600, 1);
				break;
			case "shareon":
				// Show loading gif
				loadinggif("feedback_delete_" + kind);
				// Do the action
				$("#dummy_" + kind).load('<cfoutput>#myself#</cfoutput>c.batch_sharing&state=t&file_ids=' + fileids + '&folder_id=' + folder_id);
				// Show feedback
				$("#feedback_delete_" + kind).html('<div style="width:200px;">Sharing enabled</div>');
				break;
			case "shareoff":
				// Show loading gif
				loadinggif("feedback_delete_" + kind);
				// Do the action
				$("#dummy_" + kind).load('<cfoutput>#myself#</cfoutput>c.batch_sharing&state=f&file_ids=' + fileids + '&folder_id=' + folder_id);
				// Show feedback
				$("#feedback_delete_" + kind).html('<div style="width:200px;">Sharing disabled</div>');
				break;
			case "prev":
				showwindow('<cfoutput>#myself#</cfoutput>ajax.recreate_previews&thetype=' + what, '<cfoutput>#defaultsObj.trans("batch_recreate_preview")#</cfoutput>', 550, 1);
				break;
		}
		// Reset Selection
		$('#' + theid + ' option:first').attr('selected','selected');
   	};
}

// Site conversion

// Set values for the 3GP format correct
function clickset3gp(theform){
	document.forms[theform].convert_width_3gp.value = '128';
	document.forms[theform].convert_height_3gp.value = '96';
}
function set3gp(theform){
	var thissize = document.forms[theform].convert_wh_3gp.selectedIndex;
	switch(thissize){
		//all values which are 128x96
		case 1: case 2: case 4: case 6: case 8:
		document.forms[theform].convert_width_3gp.value = '128';
		document.forms[theform].convert_height_3gp.value = '96';
		break;
		//all values which are 176x144
		case 3: case 5: case 7: case 9:
		document.forms[theform].convert_width_3gp.value = '176';
		document.forms[theform].convert_height_3gp.value = '144';
		case 10:
		document.forms[theform].convert_width_3gp.value = '352';
		document.forms[theform].convert_height_3gp.value = '288';
		case 11:
		document.forms[theform].convert_width_3gp.value = '704';
		document.forms[theform].convert_height_3gp.value = '576';
		case 12:
		document.forms[theform].convert_width_3gp.value = '1408';
		document.forms[theform].convert_height_3gp.value = '1152';	
		break;
	}
	switch(thissize){
		case 1:
		document.forms[theform].convert_bitrate_3gp.value = '64';
		break;
		case 2: case 3:
		document.forms[theform].convert_bitrate_3gp.value = '95';
		break;
		case 4: case 5:
		document.forms[theform].convert_bitrate_3gp.value = '200';
		break;
		case 6: case 7:
		document.forms[theform].convert_bitrate_3gp.value = '300';
		break;
		case 8: case 9: case 10: case 11: case 12:
		document.forms[theform].convert_bitrate_3gp.value = '600';
		break;
	}
}
// Will convert the value given in the width and set it in the heigth
function aspectheight(inp,out,theform,theaspect){
	//Check that the input value is mod, if not correct it
	if (inp.value%2 == 1){
		inp.value = inp.value - 1;
	}
	var theheight = inp.value / theaspect;
	num = theheight + '';
	var mynum = parseInt(num);
	if (mynum%2 == 1){
		mynum = mynum - 1;
	}
	document.forms[theform].elements[out].value = mynum;
}
// Will convert the value given in the heigth and set it in the width
function aspectwidth(inp,out,theform,theaspect){
	//Check that the input value is mod, if not correct it
	if (inp.value%2 == 1){
		inp.value = inp.value - 1;
	}
	var theheight = inp.value * theaspect;
	num = theheight + '';
	var mynum = parseInt(num);
	if (mynum%2 == 1){
		mynum = mynum - 1;
	}
	document.forms[theform].elements[out].value = mynum;
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
	$("#statusconvert").html('<cfoutput>#JSStringFormat(defaultsObj.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvert").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Call the Action
	loadcontent('statusconvertdummy','<cfoutput>#myself#</cfoutput>c.images_convert&file_id=' + document.forms[theform].file_id.value + '&theorgname=' + escape(document.forms[theform].theorgname.value) + '&thepath=' + document.forms[theform].thepath.value + '&convert_width_jpg=' + document.forms[theform].convert_width_jpg.value + '&convert_height_jpg=' + document.forms[theform].convert_height_jpg.value + '&convert_width_gif=' + document.forms[theform].convert_width_gif.value + '&convert_height_gif=' + document.forms[theform].convert_height_gif.value + '&convert_width_png=' + document.forms[theform].convert_width_png.value + '&convert_height_png=' + document.forms[theform].convert_height_png.value + '&convert_width_tif=' + document.forms[theform].convert_width_tif.value + '&convert_height_tif=' + document.forms[theform].convert_height_tif.value + '&convert_width_bmp=' + document.forms[theform].convert_width_bmp.value + '&convert_height_bmp=' + document.forms[theform].convert_height_bmp.value + '&convert_to=' + convertto + '&link_kind=' + document.forms[theform].link_kind.value + '&link_path_url=' + escape(document.forms[theform].link_path_url.value));
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
	$("#statusconvert").html('<cfoutput>#JSStringFormat(defaultsObj.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvert").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Call the Action
	loadcontent('statusconvertdummy','<cfoutput>#myself#</cfoutput>c.videos_convert&file_id=' + document.forms[theform].file_id.value + '&theorgname=' + escape(document.forms[theform].theorgname.value) + '&thepath=' + document.forms[theform].thepath.value + '&convert_width_wmv=' + document.forms[theform].convert_width_wmv.value + '&convert_height_wmv=' + document.forms[theform].convert_height_wmv.value + '&convert_width_avi=' + document.forms[theform].convert_width_avi.value + '&convert_height_avi=' + document.forms[theform].convert_height_avi.value + '&convert_width_mov=' + document.forms[theform].convert_width_mov.value + '&convert_height_mov=' + document.forms[theform].convert_height_mov.value + '&convert_width_mpg=' + document.forms[theform].convert_width_mpg.value + '&convert_height_mpg=' + document.forms[theform].convert_height_mpg.value + '&convert_width_mp4=' + document.forms[theform].convert_width_mp4.value + '&convert_height_mp4=' + document.forms[theform].convert_height_mp4.value + '&convert_wh_3gp=' + document.forms[theform].convert_wh_3gp.value + '&convert_width_flv=' + document.forms[theform].convert_width_flv.value + '&convert_height_flv=' + document.forms[theform].convert_height_flv.value + '&convert_width_rm=' + document.forms[theform].convert_width_rm.value + '&convert_height_rm=' + document.forms[theform].convert_height_rm.value  + '&convert_width_ogv=' + document.forms[theform].convert_width_ogv.value + '&convert_height_ogv=' + document.forms[theform].convert_height_ogv.value  + '&convert_width_webm=' + document.forms[theform].convert_width_webm.value + '&convert_height_webm=' + document.forms[theform].convert_height_webm.value + '&convert_to=' + convertto + '&convert_width_3gp=' + document.forms[theform].convert_width_3gp.value + '&convert_height_3gp=' + document.forms[theform].convert_height_3gp.value + '&theorgext=' + document.forms[theform].theorgext.value + '&link_kind=' + document.forms[theform].link_kind.value + '&link_path_url=' + escape(document.forms[theform].link_path_url.value));
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
	$("#statusconvert").html('<cfoutput>#JSStringFormat(defaultsObj.trans("convert_feedback"))#</cfoutput>');
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
	loadcontent('statusconvertdummy','<cfoutput>#myself#</cfoutput>c.audios_convert&convert_to=' + convertto + '&file_id=' + fileid + '&theorgname=' + orgname + '&thepath=' + thepath + '&convert_bitrate_mp3=' + bitmp3 + '&convert_bitrate_ogg=' + bitogg + '&theorgext=' + orgext + '&link_kind=' + link_kind);
}
</script>