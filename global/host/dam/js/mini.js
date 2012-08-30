// Switch Language and redirect to the value that the option has
// Parameter is the form name
function changelang(theform){
	var URL2 = $('#app_lang option:selected').val();
	if(URL2 != '') {
		window.top.location.href = URL2;
	}
}