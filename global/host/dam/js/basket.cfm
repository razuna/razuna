<script language="javascript" type="text/javascript">
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
</script>