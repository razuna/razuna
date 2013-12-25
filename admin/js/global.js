// 
// NEW JQuery JS
//
$.ajaxSetup({
	cache: false
});
// Show Window
function showwindow(theurl,thetitle,thew,thewin) {
	destroywindow(thewin);
	// Clear the content of the window and show the loading gif
	$('#thewindowcontent' + thewin).html('<img src="images/loading.gif" border="0" style="padding:10px;">');
	// Load Content into Dialog
	$('#thewindowcontent' + thewin).load(theurl).dialog({
		// RAZ-2718 Decode User's first and last name for title
		title: decodeURI(thetitle),
		modal: true,
		autoOpen: false,
		width: thew,
		position: 'top',
		height: 'auto',
		//minHeight: 300,
		overlay: {
			backgroundColor: '#000',
			opacity: 0.5
		}
	});
	// Open window
	$('#thewindowcontent' + thewin).dialog('open');
}

// Destroy Window
function destroywindow(numb) {
	try{
		$('#thewindowcontent' + numb).dialog('destroy');
	}
	catch(e) {};
}

// Load Tabs
function jqtabs(tabs){
	$(function() {
		$("#" + tabs).tabs();
	});
}

// Load Content with JQuery
function loadcontent(ele,url){
	// Load the page
	$("body").append('<div id="bodyoverlay"><img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
	// Load the page
	$("#" + ele).load(url, function() {
  		$("#bodyoverlay").remove();
	});
}

// Form: Get Action URL
function formaction(theid) {
	var theaction = $('#' + theid).attr("action");
	return theaction;
} 

// Form: Serialize Data
function formserialize(theid) {
	var theser = $('#' + theid).serialize();
	return theser;
} 

 




/*
 * Trim a string
 */
function trim(iString)	{
	return iString.replace (/^\s+/, '').replace (/\s+$/, '');
}

function loadinggif(whatdiv){
	$('#' + whatdiv).html('<img src="images/loading.gif" border="0" style="padding:10px;">');
}

function removerecord(what,id){
	alert(what);
	Spry.Utils.setInnerHTML('thewindowContent', '');
	thewindow.hide();
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

// Change Host and submit form
function changehostform(hostform){
	document.hostform.submit();
}

// Jump to different section within admin
function gotos(gotourl){
	var URL4 = document.gotourl.gotosec.options[document.gotourl.gotosec.selectedIndex].value;
	if (URL4 != '') {
		window.open(URL4);
	}
}

function toggleDiv(mydiv){
	//alert(document.getElementById(mydiv));
	var t = document.getElementById(mydiv);
	
	if(t.style.display == "none"){
		t.style.display = "";
	}else{
		t.style.display = "none";
	}
}

function hidethis(mydiv){
	var t = document.getElementById(mydiv);
	t.style.display = "none";
}

function FormInfo() {
	var info = "";
	for(var i=0;i<document.forms.length;i++)	{
		var oForm = document.forms[i];
		info += oForm.name + "\n";
		for(var j=0;j<oForm.elements.length;j++){
			info += oForm.elements[j].name + "(" + oForm.elements[j].type + ")"  + " : " + oForm.elements[j].value + "\n";
		}
	}
	return info;
}

// Copy the content from one select box top the second select box

function deleteOption(object,index) {
    object.options[index] = null;
}

function addOption(object,text,value) {
    var defaultSelected = true;
    var selected = true;
    var optionName = new Option(text, value, defaultSelected, selected)
    object.options[object.length] = optionName;
}

function copySelected(fromObject,toObject) {
    for (var i=0, l=fromObject.options.length;i<l;i++) {
        if (fromObject.options[i].selected)
            addOption(toObject,fromObject.options[i].text,fromObject.options[i].value);
    }
    for (var i=fromObject.options.length-1;i>-1;i--) {
        if (fromObject.options[i].selected)
            deleteOption(fromObject,i);
    }
}

function copyAll(fromObject,toObject) {
    for (var i=0, l=fromObject.options.length;i<l;i++) {
        addOption(toObject,fromObject.options[i].text,fromObject.options[i].value);
    }
    for (var i=fromObject.options.length-1;i>-1;i--) {
        deleteOption(fromObject,i);
    }
}

function populateHidden(fromObject,toObject) {
    var output = '';
    for (var i=0, l=fromObject.options.length;i<l;i++) {
            output += escape(fromObject.options[i].value) + ',';
    }
    //alert(output);
    toObject.value = output;
}

<!-- disable submit-buttons & preserve their values -->
function page_disableSubmits(elForm)	{
	<!-- disable submit buttons & preserve their captions -->
	var aPage_save_submitvalue = new Array();
	for(var i=0;i<elForm.elements.length;i++)	{
		if(elForm.elements[i].type=='submit')	{
			aPage_save_submitvalue.push(elForm.elements[i].value);
			elForm.elements[i].value="...";
			elForm.elements[i].disabled = true;
		}
	}
	<!-- return preserved values -->
	return aPage_save_submitvalue;
}
<!-- re-enable submit-buttons & reset their values -->
function page_reenableSubmits(elForm, aPage_save_submitvalue)	{
	<!-- re-enable submit buttons & reset their captions -->
	for(var i=0;i<elForm.elements.length;i++)	{
		if(elForm.elements[i].type=='submit')	{
			elForm.elements[i].value=aPage_save_submitvalue.shift();	<!-- .shift() : returns first array element and deletes first element in remaining array -->
			elForm.elements[i].disabled = false;
		}
	}
}