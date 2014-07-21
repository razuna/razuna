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
function verplayback(fileid, type, version, folder_id){
	$("#status").css("display","");
	$("#status").html('<cfoutput>#myFusebox.getApplicationData().defaults.trans("versions_playback_progress")#</cfoutput>');
	$("#status").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Submit Form
	loadcontent('versionlist','index.cfm?fa=c.versions_playback&file_id=' + fileid + '&type=' + type + '&version=' + version + '&folder_id=' + folder_id);
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
function sendtobasket(theform, from){
	// Define empty theids var
	var theids = '';
	var thekind = '';
   	// If we come from search we need to get the searchids again since we overwrite it with editids
   	if (typeof from !== 'undefined' && from === 'search') {
   		theids = $('#searchlistids').val(); 
   		thekind = 'search';
   	};
   	// Get values
	var url = 'index.cfm?fa=c.basket_put_include';
	var items = '&thekind=' + thekind + '&edit_ids=' + theids;
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
	flash_footer('basket');
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
   	// If this comes from the search or labels we need to swap the session with the file ids since edit function is in session.editids
   	if (kind === 'search' || kind === 'labels') {
   		$('#div_forall').load('index.cfm?fa=c.swap_store_file_ids');
   	}
	// Get to work
	switch (theaction){
		case "alias":
			showwindow('index.cfm?fa=c.move_file&type=alias&thetype=' + what + '&folder_id=' + folder_id + '&kind=' + kind, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("alias_create")#</cfoutput>', 550, 1);
			break;
		case "move":
			showwindow('index.cfm?fa=c.move_file&type=movefile&thetype=' + what + '&folder_id=' + folder_id + '&kind=' + kind, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("move_file")#</cfoutput>', 550, 1);
			break;
		case "batch":
			showwindow('index.cfm?fa=c.batch_form&file_id=0&what=' + what + '&folder_id=' + folder_id, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("batch_selected_header")#</cfoutput>', 650, 1);
		  	break;
		case "delete":
			//alert('trash');
			showwindow('index.cfm?fa=ajax.trash_record&many=T&what=' + what + '&loaddiv=' + kind + '&folder_id=' + folder_id, '<cfoutput>#myFusebox.getApplicationData().defaults.trans("trash")#</cfoutput>', 400, 1);
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
   	if (convertto=='')
   	{
   		alert('Please select atleast one format to convert to.');
   		return;
   	}
	// Send Feedback to Div
   	document.getElementById('statusconvert').style.visibility = "visible";
	$("#statusconvert").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvert").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Get values
	var file_id = $('#' + theform + ' #file_id').val();
	var theorgname = $('#' + theform + ' #theorgname').val();
	var thepath = $('#' + theform + ' #thepath').val();
	var link_kind = $('#' + theform + ' #link_kind').val();
	var link_path_url = $('#' + theform + ' #link_path_url').val();
	var convert_width_jpg = $('#' + theform + ' #convert_width_jpg').val();
	var convert_height_jpg = $('#' + theform + ' #convert_height_jpg').val();
	var convert_dpi_jpg = $('#' + theform + ' #convert_dpi_jpg').val();
	var convert_width_gif = $('#' + theform + ' #convert_width_gif').val();
	var convert_height_gif = $('#' + theform + ' #convert_height_gif').val();
	var convert_dpi_gif = $('#' + theform + ' #convert_dpi_gif').val();
	var convert_width_png = $('#' + theform + ' #convert_width_png').val();
	var convert_height_png = $('#' + theform + ' #convert_height_png').val();
	var convert_dpi_png = $('#' + theform + ' #convert_dpi_png').val();
	var convert_width_tif = $('#' + theform + ' #convert_width_tif').val();
	var convert_height_tif = $('#' + theform + ' #convert_height_tif').val();
	var convert_dpi_tif = $('#' + theform + ' #convert_dpi_tif').val();
	var convert_width_bmp = $('#' + theform + ' #convert_width_bmp').val();
	var convert_height_bmp = $('#' + theform + ' #convert_height_bmp').val();
	var convert_dpi_bmp = $('#' + theform + ' #convert_dpi_bmp').val();
	var convert_wm_jpg = $('#' + theform + ' #convert_wm_jpg option:selected').val();
	var convert_wm_gif = $('#' + theform + ' #convert_wm_gif option:selected').val();
	var convert_wm_png = $('#' + theform + ' #convert_wm_png option:selected').val();
	var convert_wm_tif = $('#' + theform + ' #convert_wm_tif option:selected').val();
	var convert_wm_bmp = $('#' + theform + ' #convert_wm_bmp option:selected').val();
	
	var inch_width_jpg = $('#' + theform + ' #inch_width_jpg').val();
	var inch_height_jpg = $('#' + theform + ' #inch_height_jpg').val();
	var inch_width_gif = $('#' + theform + ' #inch_width_gif').val();
	var inch_height_gif = $('#' + theform + ' #inch_height_gif').val();
	var inch_width_png = $('#' + theform + ' #inch_width_png').val();
	var inch_height_png = $('#' + theform + ' #inch_height_png').val();
	var inch_width_tif = $('#' + theform + ' #inch_width_tif').val();
	var inch_height_tif = $('#' + theform + ' #inch_height_tif').val();
	var inch_width_bmp = $('#' + theform + ' #inch_width_bmp').val();
	var inch_height_bmp = $('#' + theform + ' #inch_height_bmp').val();

	var formatbox_jpg = $('#' + theform + ' #formatbox_jpg').val();
	var formatbox_gif = $('#' + theform + ' #formatbox_gif').val();
	var formatbox_png = $('#' + theform + ' #formatbox_png').val();
	var formatbox_bmp = $('#' + theform + ' #formatbox_bmp').val();
	var formatbox_tif = $('#' + theform + ' #formatbox_tif').val();

	var xres = $('#' + theform + ' #xres').val();
	var yres = $('#' + theform + ' #yres').val();
	var resunit = $('#' + theform + ' #resunit').val();

	// Call the Action
	$('#statusconvertdummy').load('index.cfm?fa=c.images_convert', { convert_to:convertto, file_id:file_id, theorgname:theorgname, thepath:thepath, link_kind:link_kind, link_path_url:link_path_url, convert_width_jpg:convert_width_jpg, convert_height_jpg:convert_height_jpg, convert_dpi_jpg:convert_dpi_jpg, convert_width_gif:convert_width_gif, convert_height_gif:convert_height_gif, convert_dpi_gif:convert_dpi_gif, convert_width_png:convert_width_png, convert_height_png:convert_height_png, convert_dpi_png:convert_dpi_png, convert_width_tif:convert_width_tif, convert_height_tif:convert_height_tif, convert_dpi_tif:convert_dpi_tif, convert_width_bmp:convert_width_bmp, convert_height_bmp:convert_height_bmp, convert_dpi_bmp:convert_dpi_bmp, convert_wm_jpg:convert_wm_jpg, convert_wm_gif:convert_wm_gif, convert_wm_png:convert_wm_png, convert_wm_tif:convert_wm_tif, convert_wm_bmp:convert_wm_bmp ,inch_width_jpg : inch_width_jpg,inch_height_jpg :  inch_height_jpg, inch_width_gif :  inch_width_gif, inch_height_gif :  inch_height_gif, inch_width_png :  inch_width_png,  inch_height_png :  inch_height_png,  inch_width_tif :  inch_width_tif, inch_height_tif : inch_height_tif,  inch_width_bmp :  inch_width_bmp, inch_height_bmp :  inch_height_bmp, formatbox_jpg:formatbox_jpg, formatbox_png:formatbox_png, formatbox_gif:formatbox_gif, formatbox_bmp:formatbox_bmp, formatbox_tif:formatbox_tif, xres:xres, yres:yres,resunit:resunit} );
}
// For Image Renditions
function convertexistimgrenditions(theform){
	// Loop over the convert_to checkboxes
	var convertto = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('convert_to') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           		convertto += document.forms[theform].elements[i].value + ',';
           	}
      	}
   	}
   	if (convertto=='')
   	{
   		alert('Please select atleast one format to convert to.');
   		return;
   	}
	// Send Feedback to Div
   	document.getElementById('statusconvertreditions').style.visibility = "visible";
	$("#statusconvertreditions").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvertreditions").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Get values
	var file_id = $('#' + theform + ' #file_id').val();
	var img_group_id = $('#' + theform + ' #img_group_id').val();
	var theorgname = $('#' + theform + ' #theorgname').val();
	var thepath = $('#' + theform + ' #thepath').val();
	var link_kind = $('#' + theform + ' #link_kind').val();
	var link_path_url = $('#' + theform + ' #link_path_url').val();
	var convert_width_jpg = $('#' + theform + ' #convert_width_jpg').val();
	var convert_height_jpg = $('#' + theform + ' #convert_height_jpg').val();
	var convert_dpi_jpg = $('#' + theform + ' #convert_dpi_jpg').val();
	var convert_width_gif = $('#' + theform + ' #convert_width_gif').val();
	var convert_height_gif = $('#' + theform + ' #convert_height_gif').val();
	var convert_dpi_gif = $('#' + theform + ' #convert_dpi_gif').val();
	var convert_width_png = $('#' + theform + ' #convert_width_png').val();
	var convert_height_png = $('#' + theform + ' #convert_height_png').val();
	var convert_dpi_png = $('#' + theform + ' #convert_dpi_png').val();
	var convert_width_tif = $('#' + theform + ' #convert_width_tif').val();
	var convert_height_tif = $('#' + theform + ' #convert_height_tif').val();
	var convert_dpi_tif = $('#' + theform + ' #convert_dpi_tif').val();
	var convert_width_bmp = $('#' + theform + ' #convert_width_bmp').val();
	var convert_height_bmp = $('#' + theform + ' #convert_height_bmp').val();
	var convert_dpi_bmp = $('#' + theform + ' #convert_dpi_bmp').val();
	var convert_wm_jpg = $('#' + theform + ' #convert_wm_jpg option:selected').val();
	var convert_wm_gif = $('#' + theform + ' #convert_wm_gif option:selected').val();
	var convert_wm_png = $('#' + theform + ' #convert_wm_png option:selected').val();
	var convert_wm_tif = $('#' + theform + ' #convert_wm_tif option:selected').val();
	var convert_wm_bmp = $('#' + theform + ' #convert_wm_bmp option:selected').val();

	var inch_width_jpg = $('#' + theform + ' #inch_width_jpg').val();
	var inch_height_jpg = $('#' + theform + ' #inch_height_jpg').val();
	var inch_width_gif = $('#' + theform + ' #inch_width_gif').val();
	var inch_height_gif = $('#' + theform + ' #inch_height_gif').val();
	var inch_width_png = $('#' + theform + ' #inch_width_png').val();
	var inch_height_png = $('#' + theform + ' #inch_height_png').val();
	var inch_width_tif = $('#' + theform + ' #inch_width_tif').val();
	var inch_height_tif = $('#' + theform + ' #inch_height_tif').val();
	var inch_width_bmp = $('#' + theform + ' #inch_width_bmp').val();
	var inch_height_bmp = $('#' + theform + ' #inch_height_bmp').val();

	var formatbox_jpg = $('#' + theform + ' #formatbox_jpg').val();
	var formatbox_gif = $('#' + theform + ' #formatbox_gif').val();
	var formatbox_png = $('#' + theform + ' #formatbox_png').val();
	var formatbox_bmp = $('#' + theform + ' #formatbox_bmp').val();
	var formatbox_tif = $('#' + theform + ' #formatbox_tif').val();

	var xres = $('#' + theform + ' #xres').val();
	var yres = $('#' + theform + ' #yres').val();
	var resunit = $('#' + theform + ' #resunit').val();
	// Call the Action
    $('#statusrenditionconvertdummy').load('index.cfm?fa=c.rendition_images_convert', { convert_to:convertto, file_id:file_id, img_group_id:img_group_id, theorgname:theorgname, thepath:thepath, link_kind:link_kind, link_path_url:link_path_url, convert_width_jpg:convert_width_jpg, convert_height_jpg:convert_height_jpg, convert_dpi_jpg:convert_dpi_jpg, convert_width_gif:convert_width_gif, convert_height_gif:convert_height_gif, convert_dpi_gif:convert_dpi_gif, convert_width_png:convert_width_png, convert_height_png:convert_height_png, convert_dpi_png:convert_dpi_png, convert_width_tif:convert_width_tif, convert_height_tif:convert_height_tif, convert_dpi_tif:convert_dpi_tif, convert_width_bmp:convert_width_bmp, convert_height_bmp:convert_height_bmp, convert_dpi_bmp:convert_dpi_bmp, convert_wm_jpg:convert_wm_jpg, convert_wm_gif:convert_wm_gif, convert_wm_png:convert_wm_png, convert_wm_tif:convert_wm_tif, convert_wm_bmp:convert_wm_bmp,inch_width_jpg : inch_width_jpg,inch_height_jpg :  inch_height_jpg, inch_width_gif :  inch_width_gif, inch_height_gif :  inch_height_gif, inch_width_png :  inch_width_png,  inch_height_png :  inch_height_png,  inch_width_tif :  inch_width_tif, inch_height_tif : inch_height_tif,  inch_width_bmp :  inch_width_bmp, inch_height_bmp :  inch_height_bmp, formatbox_jpg:formatbox_jpg, formatbox_png:formatbox_png, formatbox_gif:formatbox_gif, formatbox_bmp:formatbox_bmp, formatbox_tif:formatbox_tif, xres:xres, yres:yres, resunit:resunit} );
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
   	if (convertto=='')
   	{
   		alert('Please select atleast one format to convert to.');
   		return;
   	}
	// Send Feedback to Div
	document.getElementById('statusconvert').style.visibility = "visible";
	$("#statusconvert").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvert").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Call the Action
	loadcontent('statusconvertdummy','index.cfm?fa=c.videos_convert&file_id=' + document.forms[theform].file_id.value + '&theorgname=' + escape(document.forms[theform].theorgname.value) + '&thepath=' + document.forms[theform].thepath.value + '&convert_width_wmv=' + document.forms[theform].convert_width_wmv.value + '&convert_height_wmv=' + document.forms[theform].convert_height_wmv.value + '&convert_width_avi=' + document.forms[theform].convert_width_avi.value + '&convert_height_avi=' + document.forms[theform].convert_height_avi.value + '&convert_width_mov=' + document.forms[theform].convert_width_mov.value + '&convert_height_mov=' + document.forms[theform].convert_height_mov.value + '&convert_width_mxf=' + document.forms[theform].convert_width_mxf.value + '&convert_height_mxf=' + document.forms[theform].convert_height_mxf.value + '&convert_width_mpg=' + document.forms[theform].convert_width_mpg.value + '&convert_height_mpg=' + document.forms[theform].convert_height_mpg.value + '&convert_width_mp4=' + document.forms[theform].convert_width_mp4.value + '&convert_height_mp4=' + document.forms[theform].convert_height_mp4.value + '&convert_wh_3gp=' + document.forms[theform].convert_wh_3gp.value + '&convert_width_flv=' + document.forms[theform].convert_width_flv.value + '&convert_height_flv=' + document.forms[theform].convert_height_flv.value + '&convert_width_rm=' + document.forms[theform].convert_width_rm.value + '&convert_height_rm=' + document.forms[theform].convert_height_rm.value  + '&convert_width_ogv=' + document.forms[theform].convert_width_ogv.value + '&convert_height_ogv=' + document.forms[theform].convert_height_ogv.value  + '&convert_width_webm=' + document.forms[theform].convert_width_webm.value + '&convert_height_webm=' + document.forms[theform].convert_height_webm.value + '&convert_to=' + convertto + '&convert_width_3gp=' + document.forms[theform].convert_width_3gp.value + '&convert_height_3gp=' + document.forms[theform].convert_height_3gp.value + '&theorgext=' + document.forms[theform].theorgext.value + '&link_kind=' + document.forms[theform].link_kind.value + '&link_path_url=' + escape(document.forms[theform].link_path_url.value));
}
// For Video Renditions
function convertexistvidrenditions(theform){
	// Loop over the convert_to checkboxes
	var convertto = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('convert_to') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           		convertto += document.forms[theform].elements[i].value + ',';
           	}
      	}
   	}
   	if (convertto=='')
   	{
   		alert('Please select atleast one format to convert to.');
   		return;
   	}
	// Send Feedback to Div
   	document.getElementById('statusconvertreditions').style.visibility = "visible";
	$("#statusconvertreditions").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvertreditions").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Call the Action
	loadcontent('statusrenditionconvertdummy','index.cfm?fa=c.rendition_videos_convert&file_id=' + document.forms[theform].file_id.value + '&vid_group_id=' + escape(document.forms[theform].vid_group_id.value)+ '&theorgname=' + escape(document.forms[theform].theorgname.value) + '&thepath=' + document.forms[theform].thepath.value + '&convert_width_wmv=' + document.forms[theform].convert_width_wmv.value + '&convert_height_wmv=' + document.forms[theform].convert_height_wmv.value + '&convert_width_avi=' + document.forms[theform].convert_width_avi.value + '&convert_height_avi=' + document.forms[theform].convert_height_avi.value + '&convert_width_mov=' + document.forms[theform].convert_width_mov.value + '&convert_height_mov=' + document.forms[theform].convert_height_mov.value + '&convert_width_mxf=' + document.forms[theform].convert_width_mxf.value + '&convert_height_mxf=' + document.forms[theform].convert_height_mxf.value + '&convert_width_mpg=' + document.forms[theform].convert_width_mpg.value + '&convert_height_mpg=' + document.forms[theform].convert_height_mpg.value + '&convert_width_mp4=' + document.forms[theform].convert_width_mp4.value + '&convert_height_mp4=' + document.forms[theform].convert_height_mp4.value + '&convert_wh_3gp=' + document.forms[theform].convert_wh_3gp.value + '&convert_width_flv=' + document.forms[theform].convert_width_flv.value + '&convert_height_flv=' + document.forms[theform].convert_height_flv.value + '&convert_width_rm=' + document.forms[theform].convert_width_rm.value + '&convert_height_rm=' + document.forms[theform].convert_height_rm.value  + '&convert_width_ogv=' + document.forms[theform].convert_width_ogv.value + '&convert_height_ogv=' + document.forms[theform].convert_height_ogv.value  + '&convert_width_webm=' + document.forms[theform].convert_width_webm.value + '&convert_height_webm=' + document.forms[theform].convert_height_webm.value + '&convert_to=' + convertto + '&convert_width_3gp=' + document.forms[theform].convert_width_3gp.value + '&convert_height_3gp=' + document.forms[theform].convert_height_3gp.value + '&theorgext=' + document.forms[theform].theorgext.value + '&link_kind=' + document.forms[theform].link_kind.value + '&link_path_url=' + escape(document.forms[theform].link_path_url.value));
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
   	if (convertto=='')
   	{
   		alert('Please select atleast one format to convert to.');
   		return;
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
// For Audio Renditions
function convertexistaudrenditions(theform){
	// Loop over the convert_to checkboxes
	var convertto = '';
	for (var i = 0; i<document.forms[theform].elements.length; i++) {
       if ((document.forms[theform].elements[i].name.indexOf('convert_to') > -1)) {
           if (document.forms[theform].elements[i].checked) {
           		convertto += document.forms[theform].elements[i].value + ',';
           	}
      	}
   	}
   	if (convertto=='')
   	{
   		alert('Please select at least one format to convert to.');
   		return;
   	}
	// Send Feedback to Div
   	$("#statusconvertreditions").css("display","");
	$("#statusconvertreditions").fadeTo("fast", 100);
	$("#statusconvertreditions").html('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("convert_feedback"))#</cfoutput>');
	$("#statusconvertreditions").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
	// Get values
	var aud_group_id = $('#' + theform + ' #aud_group_id').val();
	var bitmp3 = $('#convert_bitrate_mp3').val();
	var bitogg = $('#convert_bitrate_ogg').val();
	var orgext = $('#theorgext').val();
	var orgname = escape($('#theorgname').val());
	var fileid = $('#file_id').val();
	var thepath = escape($('#thepath').val());
	var link_kind = $('#link_kind').val();
	// Call the Action
	loadcontent('statusrenditionconvertdummy','index.cfm?fa=c.rendition_audios_convert&convert_to=' + convertto + '&file_id=' + fileid + '&aud_group_id=' + aud_group_id + '&theorgname=' + orgname + '&thepath=' + thepath + '&convert_bitrate_mp3=' + bitmp3 + '&convert_bitrate_ogg=' + bitogg + '&theorgext=' + orgext + '&link_kind=' + link_kind);
}
</script>