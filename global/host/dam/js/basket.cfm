<script language="javascript" type="text/javascript">
	// Popup window for download of the basket
	function createTarget(t){
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
	}
	// Popup windows for email
	function basketemail(email){
		// Open email Window
		showwindow('<cfoutput>#myself#c.basket_email_form&email=' + email,'#JSStringFormat(defaultsObj.trans("send_with_email"))#</cfoutput>',600,1);
		// Now populate the form fields
		setTimeout("loadform('sendemailform')", 1000);
	}
	// Popup windows for FTP
	function basketftp(){
		// Open email Window
		showwindow('<cfoutput>#myself#c.basket_ftp_form','#JSStringFormat(defaultsObj.trans("send_basket_ftp"))#</cfoutput>',600,1);
		// Now populate the form fields
		setTimeout("loadform('sendftpform')", 1000);
	}
	// Popup windows for Saving Basket
	function basketsave(){
		// Open email Window
		showwindow('<cfoutput>#myself#ajax.basket_save','#JSStringFormat(defaultsObj.trans("save_basket"))#</cfoutput>',600,1);
		// Submit art values
		storevalues();
	}
	// Populate form fields
	function loadform(theform){
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
		// Fill form fields
		$('#' + theform + '_artofimage').val(artimage);
		$('#' + theform + '_artvideo').val(artimage);
		$('#' + theform + '_artaudio').val(artimage);
		$('#' + theform + '_artfile').val(artimage);
	}
	// Store art values
	function storevalues(){
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
		// Submit the values so we put them into sessions
		var url = 'index.cfm?fa=c.store_art_values';
		var items = '&artofimage=' + artimage + '&artofvideo=' + artvideo + '&artofaudio=' + artaudio + '&artoffile=' + artfile;
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items
		});
	}
	// Get Image Selection
	function getimageselection(){
		var artofimage = '';
			// Loop trough the image selection
			for (var i = 0; i<document.thebasket.elements.length; i++) {
		       if ((document.thebasket.elements[i].name.indexOf('artofimage') > -1)) {
		           if (document.thebasket.elements[i].checked) {
		           	artofimage += document.thebasket.elements[i].value + ',';
		           	}
		      	}
		   	}
		return artofimage;
	}
	// Get Video Selection
	function getvideoselection(){
		var artofvideo = '';
		   	// Loop trough the video selection
			for (var i = 0; i<document.thebasket.elements.length; i++) {
		       if ((document.thebasket.elements[i].name.indexOf('artofvideo') > -1)) {
		           if (document.thebasket.elements[i].checked) {
		           	artofvideo += document.thebasket.elements[i].value + ',';
		           	}
		      	}
		   	}
		return artofvideo;
	}
	// Get Audio Selection
	function getaudioselection(){
		var artofaudio = '';
		   	// Loop trough the audio selection
			for (var i = 0; i<document.thebasket.elements.length; i++) {
		       if ((document.thebasket.elements[i].name.indexOf('artofaudio') > -1)) {
		           if (document.thebasket.elements[i].checked) {
		           	artofaudio += document.thebasket.elements[i].value + ',';
		           	}
		      	}
		   	}
		return artofaudio;
	}
	// Get File Selection
	function getfileselection(){
		var artoffile = '';
		   	// Loop trough the file selection
			for (var i = 0; i<document.thebasket.elements.length; i++) {
		       if ((document.thebasket.elements[i].name.indexOf('artoffile') > -1)) {
		           if (document.thebasket.elements[i].checked) {
		           	artoffile += document.thebasket.elements[i].value + ',';
		           	}
		      	}
		   	}
		return artoffile;
	}
	// Check selection for ID
	function checksel(theid,theckb,kind){
		// Select on the kind which function we load
		if (kind == 'img'){
			var theids = getimageselection();
		}
		if (kind == 'vid'){
			var theids = getvideoselection();
		}
		if (kind == 'aud'){
			var theids = getaudioselection();
		}
		if (kind == 'doc'){
			var theids = getfileselection();
		}
		// Get the ID's
		var ind = theids.indexOf(theid);
		// if the indexof return -1 we prompt and reset the checkbox
		if (ind == '-1'){
			alert('You need to select at least one kind of the asset, else remove it from the basket!');
			$('#' + theckb).attr('checked', true);
		}
	}
</script>