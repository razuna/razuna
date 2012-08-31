// Switch Language and redirect to the value that the option has
// Parameter is the form name
function changelang(theform){
	var URL2 = $('#app_lang option:selected').val();
	if(URL2 != '') {
		window.top.location.href = URL2;
	}
}
// Click on link to check box
function clickcbk(theform,thefield,which) {
	var curval = $('#rem_login:checked').val();
	if(curval == false){
		$('#rem_login').attr('checked','checked');
	}
	else{
		$('#rem_login').attr('checked','');
	}
}
// For search
function checkentry(){
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// Parse the entry
	var theentry = $('#searchtext').val();
	var thetype = $('#searchthetype').val();
	if (theentry == ""){
		return false;
	}
	else {
		// get the first position
		var p1 = theentry.substr(theentry,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else {
			// Show loading bar
			$('#minisearchstatus').css('display','').html('<img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;">');
			// We are now using POST for the search field (much more compatible then a simple load for foreign chars)
			$('#minisearchresults').load('index.cfm?fa=c.mini_search', { searchtext: theentry, folder_id: 0, thetype: thetype }, function(){
				$("#minisearchstatus").css('display','none');
			});
		}
		return false;
	}
}
// Show Window
function showwindow(folderid) {
	window.open('index.cfm?fa=c.asset_add_single&_w=true&folder_id=' + folderid, 'uploadWin', 'toolbar=no,location=0,directories=no,status=no,menubar=0,scrollbars=1,resizable=1,copyhistory=no,width=500,height=500');
}
