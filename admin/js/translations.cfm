<script language="javascript">
	function transsearch(){
		if (document.getElementById('trans_id').value == "" && document.getElementById('trans_text').value == ""){
			alert('<cfoutput>#defaultsObj.trans("one_field_fill")#</cfoutput>');
			return false;
		}
		else {
		// Disable Button
		document.tsearch.Button.value = "<cfoutput>#defaultsObj.trans("please_wait")#...</cfoutput>";
		document.tsearch.Button.disabled = true;
		// Show the div
		document.getElementById('tresults').style.visibility = "visible";
		// Update the content
		Spry.Utils.updateContent('tresults', '<cfoutput>#myself#</cfoutput>c.translation_search&trans_id=' + document.getElementById('trans_id').value + '&trans_text=' + document.getElementById('trans_text').value);
		// Enable Button
		setTimeout("thedelaytrans()", 1250);
		}
	}

	function thedelaytrans(){
		document.tsearch.Button.value = "<cfoutput>#defaultsObj.trans("user_search")#</cfoutput>";
        document.tsearch.Button.disabled = false;
	}
</script>

<script language="javascript">
	function updatetransdiv(){
		// Show the div
		document.getElementById('updatetext').style.visibility = "visible";
		document.getElementById('updatetext').innerHTML='<cfoutput>#defaultsObj.trans("success")#</cfoutput>';
	}
</script>

<script language="javascript">
	function gotosearch(req){
		// Grab the trans_id
		var thetransid = document.translationnew.trans_id.value;
		// Hide the window
		thewindow.hide();
		// Show the div
		document.getElementById('tresults').style.visibility = "visible";
		// Update the content
		Spry.Utils.updateContent('tresults', '<cfoutput>#myself#</cfoutput>c.translation_search&trans_text=&trans_id=' + thetransid);
	}
</script>