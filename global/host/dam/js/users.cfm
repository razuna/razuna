<script language="javascript">
	function usersearch(){
		if (document.getElementById('user_login_name2').value == "" && document.getElementById('user_company2').value == "" && document.getElementById('user_email2').value == ""){
			alert('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("one_field_fill"))#</cfoutput>');
			return false;
		}
		else {
		// Disable Button
		parent.document.usearch.Button.value = "<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("please_wait"))#...</cfoutput>";
		parent.document.usearch.Button.disabled = true;
		// Show the div
		// document.getElementById('uresults').style.visibility = "visible";
		// Update the content
		loadcontent('uresults', '<cfoutput>#myself#</cfoutput>c.users_search&user_login_name=' + escape(document.getElementById('user_login_name2').value) + '&user_company=' + escape(document.getElementById('user_company2').value) + '&user_email=' + escape(document.getElementById('user_email2').value));
		// Enable Button
		setTimeout("thedelay()", 1250);
		}
	}
	function thedelay(){
		parent.document.usearch.Button.value = "<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("user_search"))#</cfoutput>";
        parent.document.usearch.Button.disabled = false;
	}
	// Check eMail
	function checkemail(){
		$('#checkemaildiv').load('<cfoutput>#myself#</cfoutput>c.checkemail&user_email=' + escape(document.userdetailadd.user_email.value) + '&user_id=' + document.userdetailadd.user_id.value);
	}
	// Check Username
	function checkusername(){
		$('#checkusernamediv').load('<cfoutput>#myself#</cfoutput>c.checkusername&user_login_name=' + escape(document.userdetailadd.user_login_name.value) + '&user_id=' + document.userdetailadd.user_id.value);
	}
</script>

