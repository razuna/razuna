// 
// NEW JQuery JS
//
$.ajaxSetup({
	cache: false
});
// Show Window
function showwindow(theurl,thetitle,thew,thewin) {
	destroywindow(thewin);
	//Get the screen height and width  
	//var maskHeight = $(document).height();  
	// var maskWidth = $(window).width();
	//Get the window height and width
	// var winH = $(window).height();
	//var winW = $(window).width();
	//var t = winH/2-$('#thewindowcontent' + thewin).height()/2-200;
	//var w = winW/2-$('#thewindowcontent' + thewin).width()/2;
	//Set the popup window to center
	//$('#thewindowcontent' + thewin).css('top',  winH/2-$('#thewindowcontent' + thewin).height()/2);
	//$('#thewindowcontent' + thewin).css('left', winW/2-$('#thewindowcontent' + thewin).width()/2);
	// Clear the content of the window and show the loading gif
	$('#thewindowcontent' + thewin).html('<img src="' + dynpath + '/global/host/dam/images/loading.gif" width="16" height="16" border="0" style="padding:10px;">');
	// Load Content into Dialog
	$('#thewindowcontent' + thewin).load(theurl).dialog({
		title: thetitle,
		modal: true,
		autoOpen: false,
		width: thew,
		height: 'auto',
		position: 'top',
		//minHeight: 600,
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
	$('#thewindowcontent' + numb).dialog('destroy');
}
// Load Tabs
function jqtabs(tabs){
	$(function() {
		$("#" + tabs).tabs();
	});
}
// Load Content with JQuery
function loadcontent(ele,url){
	$("body").append('<div id="bodyoverlay"><img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
	// Load the page
	$("#" + ele).load(url, function() {
  		$("#bodyoverlay").remove();
	});
}
// Tooltip
function mytooltip(){
	//$("#tooltip a[title]").tooltip('#demotip');
	$(document).ready(function() {
		// initialize tooltip
		$("#tooltip a[title]").tooltip({
			// use single tooltip element for all tips
			tip: '#demotip', 
			// tweak the position
			offset: [2, 10],
			// use "slide" effect
			//effect: 'slide'
		// add dynamic plugin 
		}).dynamic( {
			// customized configuration on bottom edge
			right: {
				// slide downwards
				direction: 'right',
				// bounce back when closed
				bounce: true
			}
		});
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
// Loading Gif
function loadinggif(whatdiv){
	$('#' + whatdiv).html('<img src="' + dynpath + '/global/host/dam/images/loading.gif" border="0" style="padding:10px;" width="16" height="16">');
}
// JS to be able to click on the text link and have the checkbox checked
// This should be called like: <a href="##" onclick="clickcbk('theform','convert_to',0)"> where
// the "0" is the number of the first checkbox fields.
function clickcbk(theform,thefield,which) {
	if(document.forms[theform].elements[thefield][which].checked == false){
		document.forms[theform].elements[thefield][which].checked = true;
	}
	else{
		document.forms[theform].elements[thefield][which].checked = false;
	}
}
// Remove Record
function removerecord(what,id){
	//alert(what);
	$("#thewindowcontent1").html("");
	destroywindow(1);
}
// Switch Language and redirect to the value that the option has
// Parameter is the form name
function changelang(theform){
	var URL2 = document.forms[theform].app_lang.options[document.forms[theform].app_lang.selectedIndex].value;
	if(URL2 != '') {
	window.top.location.href = URL2 + '&v=' + parseInt((Math.random() * 99999999)) ;
	}
}
// Change Host
function changehost(hostform){
	var URL3 = document.hostform.host.options[document.hostform.host.selectedIndex].value;
	window.top.location.href = URL3;
}
// Change Row per Page
function changerow(ele,theid){
	var theurl = $('#' + theid).val();
	loadcontent(ele,theurl);
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
// Will convert the value given in the width and set it in the heigth
function aspectheight(inp,out,theform){
		//Check that the input value is mod, if not correct it
		if (inp.value%2 == 1){
			inp.value = inp.value - 1;
		}
		var theaspect = inp.value / document.forms[theform].elements[out].value;
		if (theaspect != 2){
			var bytwo = inp.value / 2;
			if (bytwo%2 == 1){
			bytwo = bytwo - 1;
			}
			document.forms[theform].elements[out].value = bytwo;
		}
}
// Will convert the value given in the heigth and set it in the width
function aspectwidth(inp,out,theform){
		//Check that the input value is mod, if not correct it
		if (inp.value%2 == 1){
			inp.value = inp.value - 1;
		}
		var theaspect = inp.value / document.forms[theform].elements[out].value;
		if (theaspect != 2){
			var bytwo = inp.value * 2;
			if (bytwo%2 == 1){
			bytwo = bytwo - 1;
			}
			document.forms[theform].elements[out].value = bytwo;
		}
}
// Enable folderselection in list
function enablesub(myform) {
    var valid = true;   
    var checkBoxes = false;
    var checkboxChecked = false;
    
    for (var i=0, j=document.forms[myform].elements.length; i<j; i++) {
        myType = document.forms[myform].elements[i].type;
        
	if (myType == 'checkbox') {
            checkBoxes = true;
            if (document.forms[myform].elements[i].checked) checkboxChecked = true;
        }
    }

    if (checkboxChecked == false) {
		$("#folderselection" + myform).css("display","none");
		$("#folderselectionb" + myform).css("display","none");
		
	}
	if (checkboxChecked == true) {
		$("#folderselection" + myform).css("display","");
		$("#folderselectionb" + myform).css("display","");
	}
}
function enablesubserver(myform) {
    var valid = true;   
    var checkBoxes = false;
    var checkboxChecked = false;
    
    for (var i=0, j=document.forms[myform].elements.length; i<j; i++) {
        myType = document.forms[myform].elements[i].type;
        
	if (myType == 'checkbox') {
            checkBoxes = true;
            if (document.forms[myform].elements[i].checked) checkboxChecked = true;
        }
    }

    if (checkboxChecked == false) {
	document.forms[myform].submitbutton.disabled = true;
	}
	if (checkboxChecked == true) {
	document.forms[myform].submitbutton.disabled = false;
	}
}
function validateValues() {
    var valid = true;
        
    var checkBoxes = false;
    var checkboxChecked = false;
    
    for (var i=0, j=document.forms[myform].elements.length; i<j; i++) {
        myType = document.forms[myform].elements[i].type;
        
        if (myType == 'checkbox') {
            checkBoxes = true;
            if (document.forms[myform].elements[i].checked) checkboxChecked = true;
        }
        
    }

    if (checkBoxes && !checkboxChecked) valid = false;

    if (!valid)
    return valid;    
}
// If clicked in the document then close any dropdown menu with the class ddicon
$(document).bind('click', function(e) {
	var $clicked=$(e.target);
	/* if($clicked.is('.ddselection_header') || $clicked.parents().is('.ddselection_header') || $clicked.is('.ddicon')) */
	if($clicked.is('.ddicon') || $clicked.parents().is('.ddselection_header')) {
		//alert('inside');
    }
	else {
		//alert('outside');
		$('.ddselection_header').hide();
	}
});
// Simply JS to check radio button for group permissions
// Check radio box
	function checkradio(thisid){
		$('#per_' + thisid).attr('checked','checked');
	}
// Flash footer_tabs
function flash_footer(){
	$("#tabs_footer").effect('pulsate');
	//$("#tabs_footer").effect('highlight',{'color':'orange'},1000);
	//$('#tabs_footer').tabs('select','#thedropfav');
}
// Global Tagit events
function raztagit(thediv,fileid,thetype,raztags,perm){
    var tags = $('#' + thediv);
    tags.tagit({
		singleField: true,
        singleFieldNode: $('#' + thediv),
        availableTags: raztags,
		caseSensitive: false,
		allowSpaces: true
	});
	// If user adds a new tag (but only if he is allowed to)
	tags.tagit({
 		onTagAdded: function(evt, tag) {
			var v = tags.tagit('tagLabel', tag);
			loadcontent('div_forall','index.cfm?fa=c.label_update&id=' + fileid + '&type=' + thetype + '&thelab=' + encodeURIComponent(v));
			if (perm == 't'){
				$.sticky('<span style="color:green;font-Weight:bold;">The label has been saved!</span>');
			}
		}
	});
	// If user removed it from here
	tags.tagit({
		onTagRemoved: function(evt, tag) {
        	var v = tags.tagit('tagLabel', tag);
        	loadcontent('div_forall','index.cfm?fa=c.label_remove&id=' + fileid + '&type=' + thetype + '&thelab=' + encodeURIComponent(v));
			$.sticky('The label has been removed!');
        }
	});
}
// Global Loading Status
$(document).ready(function()
	{
    	$(this).ajaxStart(function()
       	{
        	$("body").append('<div id="bodyoverlay"><img src="' + dynpath + '/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>');
		});
 
       	$(this).ajaxStop(function()
       	{
        	$("#bodyoverlay").remove();
       	});
	});
// Adding labels for users who can not edit
function razaddlabels(thediv,fileid,thetype){
	$('#' + thediv).chosen().change(
		loadcontent('div_forall','index.cfm?fa=c.label_add_all&fileid=' + fileid + '&thetype=' + thetype + '&labels=' + $('#' + thediv).val())
	);
	$.sticky('<span style="color:green;font-Weight:bold;">Your change has been saved!</span>');
};

// For the Quick Search
$(document).ready(function() {
	// Store the value of the input field
	var theval = $('#simplesearchtext').val();
	// If user click on the quick search field we hide the text
	$('#simplesearchtext').click(function(){
		// Get the value of the entry field
		var theentrynow = $('#simplesearchtext').val();
		if (theentrynow == 'Quick Search'){
			$('#simplesearchtext').val('');
		}
	})
	// If the value field is empty restore the value field
	$('#simplesearchtext').blur(function(){
		// Get the current value of the field
		var thevalnow = $('#simplesearchtext').val();
		// If the current value is empty then restore it with the default value
		if ( thevalnow == ''){
			$('#simplesearchtext').val(theval);
		}
	})
})
function checkentry(){
	// Only allow chars
	var illegalChars = /(\*|\?)/;
	// Parse the entry
	var theentry = $('#simplesearchtext').val();
	var thetype = $('#simplesearchthetype').val();
	if (theentry == "" | theentry == "Quick Search"){
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
			$('#searchicon').html('<img src="' + dynpath + '/global/host/dam/images/loading.gif" border="0" style="padding:0px;" width="16" height="16">');
			//loadcontent('rightside','<cfoutput>#myself#</cfoutput>c.search_simple&folder_id=0&searchtext=' + escape(theentry) + '&thetype=' + thetype);
			// We are now using POST for the search field (much more compatible then a simple laod for foreign chars)
			$('#rightside').load('index.cfm?fa=c.search_simple', { searchtext: theentry, folder_id: 0, thetype: thetype }, function(){
				$('#searchicon').html('<img src="' + dynpath + '/global/host/dam/images/search_16.png" width="16" height="16" border="0" onclick="checkentry();" class="ddicon">');
			});
		}
		return false;
	}
}
// When a search selection is clicked
function selectsearchtype(thetype){
	$('#simplesearchthetype').val(thetype);
	$('#searchselection').toggle();
	// Remove the image in all marks
	$('#markall').html('&nbsp;');
	$('#markimg').html('&nbsp;');
	$('#markvid').html('&nbsp;');
	$('#markaud').html('&nbsp;');
	$('#markdoc').html('&nbsp;');
	// Now set the correct CSS
	$('#markall').css({'float':'left','padding-right':'14px'});
	$('#markimg').css({'float':'left','padding-right':'14px'});
	$('#markvid').css({'float':'left','padding-right':'14px'});
	$('#markaud').css({'float':'left','padding-right':'14px'});
	$('#markdoc').css({'float':'left','padding-right':'14px'});
	// Now mark the div
	$('#mark' + thetype).css({'float':'left','padding-right':'3px'});
	$('#mark' + thetype).html('<img src="' + dynpath + '/global/host/dam/images/arrow_selected.jpg" width="14" height="14" border="0">');
}