// Log On
$(document).ready(function(){
    // Form: Login
	$("#form_login").validate({
		submitHandler: function(form) {
			// Show login_loading (if it is hidden due to a error before)
			$("#login_loading").css("display","");
			// Hide login_div
			$("#login_div").css("display","none");
			// Hide alert
			$("#alertbox").css("display","none");

			// Submit
			form.submit();
		},
		rules: {
			name: "required",
			pass: "required"
		 }
	})
});
// Change Host and submit form
function changehostform(hostform){
	$("#loading").css("display","");
	$("#loading").html('<img src="images/loading.gif" border="0">');
	$("#hostform").submit();
}
// global load command
function loadcontent(ele,url){
	// Load the page
	$("#" + ele).load(url);
}
function ftsubmitform() {
	document.ftform.submit();
	document.ftform.ftsubmit.disabled = true;
	document.ftform.ftsubmit.value = 'Please wait...';
	document.getElementById('ftfeedback').innerHTML='<img src=images/loading.gif border=0 style=padding:5px;>';
}
// Switch Language and redirect to the value that the option has
// Parameter is the form name
function changelang(theform){
	var URL2 = document.forms[theform].app_lang.options[document.forms[theform].app_lang.selectedIndex].value;
	if(URL2 != '') {
	window.top.location.href = URL2;
	}
}

// Change Host
function changehost(hostform){
	var URL3 = document.hostform.host.options[document.hostform.host.selectedIndex].value;
	window.top.location.href = URL3;
}
// JS to be able to click on the text link and have the checkbox checked
// This should be called like: <a href="##" onclick="clickcbk('theform','convert_to',0)"> where
// the "0" is the number of the first checkbox fields.
function clickcbk(theform,thefield,which) {
	if(document.forms[theform].rem_login.checked == false){
		document.forms[theform].rem_login.checked = true;
	}
	else{
		document.forms[theform].rem_login.checked = false;
	}
}
