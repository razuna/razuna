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
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
		// Open email Window
		showwindow('<cfoutput>#myself#c.basket_email_form&artofimage=' + artimage + '&artofvideo=' + artvideo + '&artofaudio=' + artaudio + '&artoffile=' + artfile + '&email=' + email,'#JSStringFormat(defaultsObj.trans("send_with_email"))#</cfoutput>',600,1);
	}
	// Popup windows for FTP
	function basketftp(){
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
		// Open email Window
		showwindow('<cfoutput>#myself#c.basket_ftp_form&artofimage=' + artimage + '&artofvideo=' + artvideo + '&artofaudio=' + artaudio + '&artoffile=' + artfile,'#JSStringFormat(defaultsObj.trans("send_basket_ftp"))#</cfoutput>',600,1);
	}
	// Popup windows for Saving Basket
	function basketsave(){
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
		// Open email Window
		showwindow('<cfoutput>#myself#ajax.basket_save&artofimage=' + artimage + '&artofvideo=' + artvideo + '&artofaudio=' + artaudio + '&artoffile=' + artfile,'#JSStringFormat(defaultsObj.trans("save_basket"))#</cfoutput>',600,1);
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