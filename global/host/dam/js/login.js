$.ajaxSetup({
	cache: false
});
$(document).ready(function(){
    // Form: Login
	$("#form_login").validate({
		// When the form is being submited
		submitHandler: function(form) {
			// Show login_loading (if it is hidden due to a error before)
			$("#login_loading").css("display","");
			// Hide login_div
			/* $("#login_div").css("display","none"); */
			// Hide alert
			$("#alertbox").css("display","none");
			// Show loading message in upload window
			//$("#login_loading").html('<div style="padding:10px"><img src="' + dynpath + '/global/host/dam/images/loading.gif" width="16" height="16" border="0"> Loading Razuna</div>');
			// Submit
			form.submit();
		},
		rules: {
			name: "required",
			pass: "required"
		 }
	})
	// Form_ Login Shared
	$("#form_login_share").validate({
		// When the form is being submited
		submitHandler: function(form) {
			// Submit
			form.submit();
		},
		rules: {
			name: "required",
			pass: "required"
		 }
	})
	// Form_ Login Widget
	$("#form_login_widget").validate({
		// When the form is being submited
		submitHandler: function(form) {
			// Submit
			form.submit();
		},
		rules: {
			name: "required",
			pass: "required"
		 }
	})
});
// global load command
function loadcontent(ele,url){
	// Load the page
	$("#" + ele).load(url);
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
// Switch Language and redirect to the value that the option has
// Parameter is the form name
function changelang(theform){
	var URL2 = document.forms[theform].app_lang.options[document.forms[theform].app_lang.selectedIndex].value;
	if(URL2 != '') {
		window.top.location.href = URL2;
	}
}