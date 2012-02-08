<script language="javascript">
	// when saving sharing only
	function savesharing(theid,iscol){
		var url = formaction("form_folder_share" + theid);
		var items = formserialize("form_folder_share" + theid);
		// Submit Form
       	$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(theid,iscol){
				// Feedback
				$('#updatetextshare').html('<cfoutput>#JSStringFormat(defaultsObj.trans("success"))#</cfoutput>');
				$("#updatetextshare").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
		   	}
		});
	}
	// when saving folder
	function foldersubmit(theid,isdetail,iscol){
		var url = formaction("form_folder" + theid);
		var items = formserialize("form_folder" + theid);
		//alert(iscol);
		// If ID is empty
		if(theid == ""){
			theid = 0;
		}
		if(iscol == "F"){
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(theid,isdetail,iscol){
			   		// Reload Explorer
					loadcontent('explorer','<cfoutput>#myself#</cfoutput>c.explorer');
					// Hide Window
					destroywindow(1);
					// Feedback
					$('#updatetext').html('<cfoutput>#JSStringFormat(defaultsObj.trans("success"))#</cfoutput>');
					$("#updatetext").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
		}
		else {
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(theid,isdetail,iscol){
			   		// Reload Explorer
					loadcontent('explorer_col','<cfoutput>#myself#</cfoutput>c.explorer_col');
					// Hide Window
					destroywindow(1);
			   	}
			});
		}
        return false; 
	}
	function loadfolderpage(theid){
		loadcontent('properties','<cfoutput>#myself#</cfoutput>c.folder_edit&folder_id=' + theid + '&theid=' + theid);
	}
	function cbnewfolder(){
		// Reload Explorer
		reloadexplorer(theid,isdetail,iscol);
		// Hide Window
		destroywindow(1);
	}
	function reloadexplorer(theid,isdetail,iscol){
		// If ID is empty
		if(theid == ""){
			theid = 0;
		}
		// Reload Explorer
		loadcontent('explorer','<cfoutput>#myself#</cfoutput>c.explorer');
		// Show the update feedback
		document.getElementById('updatetext').style.visibility = "visible";
		$("#updatetext").html('<cfoutput>#JSStringFormat(defaultsObj.trans("success"))#</cfoutput>');
		$("#updatetext").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
	}
	// Set today date into form fields
	function settoday(theform) {
		document.forms[theform].on_day.value = <cfoutput>#day(now())#</cfoutput>;
		document.forms[theform].on_month.value = <cfoutput>#month(now())#</cfoutput>;
		document.forms[theform].on_year.value = <cfoutput>#year(now())#</cfoutput>;
	}
	// Fire off advanced document search
	function searchadv_files(theform, thefa, folderid) {
		// Call subfunction to get fields
		var searchtext = subadvfields(theform);
		// Put together the extend metadata
		var searchtext = subadvfieldsdoc(theform, searchtext);
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// get the first postion
		var p1 = searchtext.substr(searchtext,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else {
			// Fire search
			$('#loading_searchadv').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#loading_searchadv2').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#rightside').load('<cfoutput>#myself#</cfoutput>' + thefa + '&searchtype=adv&folder_id=' + folderid + '&searchtext=' + escape(searchtext) + '&doctype=' + document.forms[theform].doctype.options[document.forms[theform].doctype.selectedIndex].value + '&on_day=' + document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value + '&on_month=' + document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value + '&on_year=' + document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, function(){
				// Hide Window
				destroywindow(1);
			});
		}
	}
	// Fire off advanced videos search
	function searchadv_videos(theform, thefa, folderid) {
		// Call subfunction to get fields
		var searchtext = subadvfields(theform);
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// get the first postion
		var p1 = searchtext.substr(searchtext,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else {
			// Fire search
			$('#loading_searchadv').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#loading_searchadv2').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#rightside').load('<cfoutput>#myself#</cfoutput>' + thefa + '&searchtype=adv&folder_id=' + folderid + '&searchtext=' + escape(searchtext) + '&on_day=' + document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value + '&on_month=' + document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value + '&on_year=' + document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, function(){
				// Hide Window
				destroywindow(1);
			});
		}
	}
	// Fire off advanced images search
	function searchadv_images(theform, thefa, folderid) {
		// Call subfunction to get fields
		var searchtext = subadvfields(theform);
		// Put together the extend metadata
		var searchtext = subadvfieldsimg(theform, searchtext);
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// get the first postion
		var p1 = searchtext.substr(searchtext,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else {
			// Fire search
			$('#loading_searchadv').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#loading_searchadv2').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#rightside').load('<cfoutput>#myself#</cfoutput>' + thefa + '&searchtype=adv&folder_id=' + folderid + '&searchtext=' + escape(searchtext) + '&on_day=' + document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value + '&on_month=' + document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value + '&on_year=' + document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, function(){
				// Hide Window
				destroywindow(1);
			});
		}
	}
	// Fire off advanced images search
	function searchadv_audios(theform, thefa, folderid) {
		// Call subfunction to get fields
		var searchtext = subadvfields(theform);
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// get the first postion
		var p1 = searchtext.substr(searchtext,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else {
			// Fire search
			$('#loading_searchadv').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#loading_searchadv2').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#rightside').load('<cfoutput>#myself#</cfoutput>' + thefa + '&searchtype=aud&folder_id=' + folderid + '&searchtext=' + escape(searchtext) + '&on_day=' + document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value + '&on_month=' + document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value + '&on_year=' + document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, function(){
				// Hide Window
				destroywindow(1);
			});
		}
	}
	// Fire off search all
	function searchadv_all(theform, thefa, folderid) {
		// Call subfunction to get fields
		var searchtext = subadvfields(theform);
		// Only allow chars
		var illegalChars = /(\*|\?)/;
		// get the first postion
		var p1 = searchtext.substr(searchtext,1);
		// Now check
		if (illegalChars.test(p1)){
			alert('The first character of your search string is an illegal one. Please remove it!');
		}
		else {
			// Fire search
			$('#loading_searchadv').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#loading_searchadv2').html('<img src="<cfoutput>#dynpath#</cfoutput>/global/host/dam/images/loading-bars.gif" border="0" style="padding:0px;">');
			$('#rightside').load('<cfoutput>#myself#</cfoutput>' + thefa + '&thetype=all&folder_id=' + folderid + '&searchtext=' + escape(searchtext) + '&on_day=' + document.forms[theform].on_day.options[document.forms[theform].on_day.selectedIndex].value + '&on_month=' + document.forms[theform].on_month.options[document.forms[theform].on_month.selectedIndex].value + '&on_year=' + document.forms[theform].on_year.options[document.forms[theform].on_year.selectedIndex].value, function(){
				// Hide Window
				destroywindow(1);
			});
		}
	}
	function emptybasket(){
		loadcontent('rightside','<cfoutput>#myself#</cfoutput>c.basket_full_remove_all');
		setTimeout("loadbasket()", 1250);
		destroywindow(1);
	}
	function loadbasket(){
		loadcontent('basket','<cfoutput>#myself#</cfoutput>c.basket');
	}
	function subadvfields(theform){
		// Get values
		var searchtext = '';
		var searchfor = escape(document.forms[theform].searchfor.value);
		var keywords = escape(document.forms[theform].keywords.value);
		var description = escape(document.forms[theform].description.value);
		var filename = escape(document.forms[theform].filename.value);
		var extension = escape(document.forms[theform].extension.value);
		var rawmetadata = escape(document.forms[theform].rawmetadata.value);
		<cfloop query="qry_cf_fields"><cfset cfid = replace(cf_id,"-","","all")><cfoutput>
			var value_#cfid# = escape(document.forms[theform].cf#cfid#.value);
		</cfoutput></cfloop>
		var andor = document.forms[theform].andor.options[document.forms[theform].andor.selectedIndex].value;
		// Put together the search
		if (searchfor != '') var searchfor = searchfor;
		if (keywords != '') var keywords = 'keywords:' + keywords;
		if (description != '') var description = 'description:' + description;
		if (filename != '') var filename = 'filename:' + filename;
		if (extension != '') var extension = 'extension:' + extension;
		if (rawmetadata != '') var rawmetadata = 'rawmetadata:' + rawmetadata;
		<cfloop query="qry_cf_fields"><cfset cfid = replace(cf_id,"-","","all")><cfoutput>
			if (value_#cfid# != '') var value_#cfid# = 'cf_text:#cf_id# AND cf_value:' + value_#cfid#;
		</cfoutput></cfloop>
		// Create the searchtext
		var searchtext = searchfor;
		if (searchtext != '' && keywords != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + keywords;
		}
		else {
			var searchtext = searchtext + keywords;
		}
		if (searchtext != '' && description != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + description;
		}
		else {
			var searchtext = searchtext + description;
		}
		if (searchtext != '' && filename != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + filename;
		}
		else {
			var searchtext = searchtext + filename;
		}
		if (searchtext != '' && extension != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + extension;
		}
		else {
			var searchtext = searchtext + extension;
		}
		if (searchtext != '' && rawmetadata != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + rawmetadata;
		}
		else {
			var searchtext = searchtext + rawmetadata;
		}
		<cfloop query="qry_cf_fields"><cfset cfid = replace(cf_id,"-","","all")><cfoutput>
			if (searchtext != '' && value_#cfid# != '') {
				var searchtext = searchtext + ' ' + andor + ' ' + value_#cfid#;
			}
			else {
				var searchtext = searchtext + value_#cfid#;
			}
		</cfoutput></cfloop>
		return searchtext;
	}
	function subadvfieldsdoc(theform,searchtext){
		// Get values
		var author = escape(document.forms[theform].author.value);
		var authorsposition = escape(document.forms[theform].authorsposition.value);
		var captionwriter = escape(document.forms[theform].captionwriter.value);
		var webstatement = escape(document.forms[theform].webstatement.value);
		var rights = escape(document.forms[theform].rights.value);
		var rightsmarked = escape(document.forms[theform].rightsmarked.value);
		var andor = document.forms[theform].andor.options[document.forms[theform].andor.selectedIndex].value;
		// Put together the search
		if (author != '') var author = 'author:' + author;
		if (authorsposition != '') var authorsposition = 'authorsposition:' + authorsposition;
		if (captionwriter != '') var captionwriter = 'captionwriter:' + captionwriter;
		if (webstatement != '') var webstatement = 'webstatement:' + webstatement;
		if (rights != '') var rights = 'rights:' + rights;
		if (rightsmarked != '') var rightsmarked = 'rightsmarked:' + rightsmarked;
		// Create the searchtext
		if (searchtext != '' && author != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + author;
		}
		else {
			var searchtext = searchtext + author;
		}
		if (searchtext != '' && authorsposition != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + authorsposition;
		}
		else {
			var searchtext = searchtext + authorsposition;
		}
		if (searchtext != '' && captionwriter != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + captionwriter;
		}
		else {
			var searchtext = searchtext + captionwriter;
		}
		if (searchtext != '' && webstatement != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + webstatement;
		}
		else {
			var searchtext = searchtext + webstatement;
		}
		if (searchtext != '' && rights != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + rights;
		}
		else {
			var searchtext = searchtext + rights;
		}
		if (searchtext != '' && rightsmarked != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + rightsmarked;
		}
		else {
			var searchtext = searchtext + rightsmarked;
		}
		return searchtext;
	}
	function subadvfieldsimg(theform,searchtext){
		// Get values
		var subjectcode = escape(document.forms[theform].subjectcode.value);
		var creator = escape(document.forms[theform].creator.value);
		var title = escape(document.forms[theform].title.value);
		var authorsposition = escape(document.forms[theform].authorsposition.value);
		var captionwriter = escape(document.forms[theform].captionwriter.value);
		var ciadrextadr = escape(document.forms[theform].ciadrextadr.value);
		var category = escape(document.forms[theform].category.value);
		var supplementalcategories = escape(document.forms[theform].supplementalcategories.value);
		var urgency = escape(document.forms[theform].urgency.value);
		var ciadrcity = escape(document.forms[theform].ciadrcity.value);
		var ciadrctry = escape(document.forms[theform].ciadrctry.value);
		var location = escape(document.forms[theform].location.value);
		var ciadrpcode = escape(document.forms[theform].ciadrpcode.value);
		var ciemailwork = escape(document.forms[theform].ciemailwork.value);
		var ciurlwork = escape(document.forms[theform].ciurlwork.value);
		var citelwork = escape(document.forms[theform].citelwork.value);
		var intellectualgenre = escape(document.forms[theform].intellectualgenre.value);
		var instructions = escape(document.forms[theform].instructions.value);
		var source = escape(document.forms[theform].source.value);
		var usageterms = escape(document.forms[theform].usageterms.value);
		var copyrightstatus = escape(document.forms[theform].copyrightstatus.value);
		var transmissionreference = escape(document.forms[theform].transmissionreference.value);
		var webstatement = escape(document.forms[theform].webstatement.value);
		var headline = escape(document.forms[theform].headline.value);
		var datecreated = escape(document.forms[theform].datecreated.value);
		var city = escape(document.forms[theform].city.value);
		var ciadrregion = escape(document.forms[theform].ciadrregion.value);
		var country = escape(document.forms[theform].country.value);
		var countrycode = escape(document.forms[theform].countrycode.value);
		var scene = escape(document.forms[theform].scene.value);
		var state = escape(document.forms[theform].state.value);
		var credit = escape(document.forms[theform].credit.value);
		var rights = escape(document.forms[theform].rights.value);
		var andor = document.forms[theform].andor.options[document.forms[theform].andor.selectedIndex].value;
		// Put together the search
		if (subjectcode != '') var subjectcode = 'subjectcode:' + subjectcode;
		if (creator != '') var creator = 'creator:' + creator;
		if (title != '') var title = 'title:' + title;
		if (authorsposition != '') var authorsposition = 'authorsposition:' + authorsposition;
		if (captionwriter != '') var captionwriter = 'captionwriter:' + captionwriter;
		if (ciadrextadr != '') var ciadrextadr = 'ciadrextadr:' + ciadrextadr;
		if (category != '') var category = 'category:' + category;
		if (supplementalcategories != '') var supplementalcategories = 'supplementalcategories:' + supplementalcategories;
		if (urgency != '') var urgency = 'urgency:' + urgency;
		if (ciadrcity != '') var ciadrcity = 'ciadrcity:' + ciadrcity;
		if (ciadrctry != '') var ciadrctry = 'ciadrctry:' + ciadrctry;
		if (location != '') var location = 'location:' + location;
		if (ciadrpcode != '') var ciadrpcode = 'ciadrpcode:' + ciadrpcode;
		if (ciemailwork != '') var ciemailwork = 'ciemailwork:' + ciemailwork;
		if (ciurlwork != '') var ciurlwork = 'ciurlwork:' + ciurlwork;
		if (citelwork != '') var citelwork = 'citelwork:' + citelwork;
		if (intellectualgenre != '') var intellectualgenre = 'intellectualgenre:' + intellectualgenre;
		if (instructions != '') var instructions = 'instructions:' + instructions;
		if (source != '') var source = 'source:' + source;
		if (usageterms != '') var usageterms = 'usageterms:' + usageterms;
		if (copyrightstatus != '') var copyrightstatus = 'copyrightstatus:' + copyrightstatus;
		if (transmissionreference != '') var transmissionreference = 'transmissionreference:' + transmissionreference;
		if (webstatement != '') var webstatement = 'webstatement:' + webstatement;
		if (headline != '') var headline = 'headline:' + headline;
		if (datecreated != '') var datecreated = 'datecreated:' + datecreated;
		if (city != '') var city = 'city:' + city;
		if (ciadrregion != '') var ciadrregion = 'ciadrregion:' + ciadrregion;
		if (country != '') var country = 'country:' + country;
		if (countrycode != '') var countrycode = 'countrycode:' + countrycode;
		if (scene != '') var scene = 'scene:' + scene;
		if (state != '') var state = 'state:' + state;
		if (credit != '') var credit = 'credit:' + credit;
		if (rights != '') var rights = 'rights:' + rights;
		// Create the searchtext
		if (searchtext != '' && subjectcode != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + subjectcode;
		}
		else {
			var searchtext = searchtext + subjectcode;
		}
		if (searchtext != '' && creator != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + creator;
		}
		else {
			var searchtext = searchtext + creator;
		}
		if (searchtext != '' && title != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + title;
		}
		else {
			var searchtext = searchtext + title;
		}
		if (searchtext != '' && authorsposition != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + authorsposition;
		}
		else {
			var searchtext = searchtext + authorsposition;
		}
		if (searchtext != '' && captionwriter != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + captionwriter;
		}
		else {
			var searchtext = searchtext + captionwriter;
		}
		if (searchtext != '' && ciadrextadr != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + ciadrextadr;
		}
		else {
			var searchtext = searchtext + ciadrextadr;
		}
		if (searchtext != '' && category != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + category;
		}
		else {
			var searchtext = searchtext + category;
		}
		if (searchtext != '' && supplementalcategories != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + supplementalcategories;
		}
		else {
			var searchtext = searchtext + supplementalcategories;
		}
		if (searchtext != '' && urgency != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + urgency;
		}
		else {
			var searchtext = searchtext + urgency;
		}
		if (searchtext != '' && ciadrcity != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + ciadrcity;
		}
		else {
			var searchtext = searchtext + ciadrcity;
		}
		if (searchtext != '' && ciadrctry != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + ciadrctry;
		}
		else {
			var searchtext = searchtext + ciadrctry;
		}
		if (searchtext != '' && location != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + location;
		}
		else {
			var searchtext = searchtext + location;
		}
		if (searchtext != '' && ciadrpcode != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + ciadrpcode;
		}
		else {
			var searchtext = searchtext + ciadrpcode;
		}
		if (searchtext != '' && ciemailwork != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + ciemailwork;
		}
		else {
			var searchtext = searchtext + ciemailwork;
		}
		if (searchtext != '' && ciurlwork != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + ciurlwork;
		}
		else {
			var searchtext = searchtext + ciurlwork;
		}
		if (searchtext != '' && citelwork != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + citelwork;
		}
		else {
			var searchtext = searchtext + citelwork;
		}
		if (searchtext != '' && intellectualgenre != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + intellectualgenre;
		}
		else {
			var searchtext = searchtext + intellectualgenre;
		}
		if (searchtext != '' && instructions != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + instructions;
		}
		else {
			var searchtext = searchtext + intellectualgenre;
		}
		if (searchtext != '' && source != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + source;
		}
		else {
			var searchtext = searchtext + source;
		}
		if (searchtext != '' && usageterms != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + usageterms;
		}
		else {
			var searchtext = searchtext + usageterms;
		}
		if (searchtext != '' && copyrightstatus != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + copyrightstatus;
		}
		else {
			var searchtext = searchtext + copyrightstatus;
		}
		if (searchtext != '' && transmissionreference != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + transmissionreference;
		}
		else {
			var searchtext = searchtext + transmissionreference;
		}
		if (searchtext != '' && webstatement != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + webstatement;
		}
		else {
			var searchtext = searchtext + webstatement;
		}
		if (searchtext != '' && headline != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + headline;
		}
		else {
			var searchtext = searchtext + headline;
		}
		if (searchtext != '' && datecreated != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + datecreated;
		}
		else {
			var searchtext = searchtext + datecreated;
		}
		if (searchtext != '' && city != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + city;
		}
		else {
			var searchtext = searchtext + city;
		}
		if (searchtext != '' && ciadrregion != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + ciadrregion;
		}
		else {
			var searchtext = searchtext + ciadrregion;
		}
		if (searchtext != '' && country != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + country;
		}
		else {
			var searchtext = searchtext + country;
		}
		if (searchtext != '' && countrycode != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + countrycode;
		}
		else {
			var searchtext = searchtext + countrycode;
		}
		if (searchtext != '' && scene != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + scene;
		}
		else {
			var searchtext = searchtext + scene;
		}
		if (searchtext != '' && state != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + state;
		}
		else {
			var searchtext = searchtext + state;
		}
		if (searchtext != '' && credit != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + credit;
		}
		else {
			var searchtext = searchtext + credit;
		}
		if (searchtext != '' && rights != '') {
			var searchtext = searchtext + ' ' + andor + ' ' + rights;
		}
		else {
			var searchtext = searchtext + rights;
		}	
		return searchtext;
	}
</script>