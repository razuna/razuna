<!--- ---------------------------------------------------------------------------------------- --->
<!--- JAVASCRIPT FOR UPLOAD SCHEDULER SETTINGS                                                 --->
<!--- ---------------------------------------------------------------------------------------- --->
<script language="JavaScript">

<!--- Upload method: Server, Mail, FTP ------------------------------------------------------- --->
function showConnectDetail(fld, kind) {
	var method = fld[fld.selectedIndex].value;
	if (method == "server") { 
		document.getElementById("detailsServer_"+kind).style.display = "block";
		document.getElementById("detailsMail_"+kind).style.display = "none"; 
		document.getElementById("detailsFtp_"+kind).style.display = "none"; 
	}
	else if (method == "mail") {
		document.getElementById("detailsServer_"+kind).style.display = "none"; 
		document.getElementById("detailsMail_"+kind).style.display = "block"; 
		document.getElementById("detailsFtp_"+kind).style.display = "none"; 
	}
	else if (method == "ftp") {
		document.getElementById("detailsServer_"+kind).style.display = "none"; 
		document.getElementById("detailsMail_"+kind).style.display = "none"; 
		document.getElementById("detailsFtp_"+kind).style.display = "block";
	}
}

<!--- Frequency: One-Time, Recurring, Daily -------------------------------------------------- --->
function showFrequencyDetail(fld, kind) {
	var frequency = fld[fld.selectedIndex].value;
	if (frequency == "1") { 
		document.getElementById("detailsOneTime_"+kind).style.display = "block"; 
		document.getElementById("detailsRecurring_"+kind).style.display = "none"; 
		document.getElementById("detailsDaily_"+kind).style.display = "none"; 
	}
	else if (frequency == "2") {
		document.getElementById("detailsOneTime_"+kind).style.display = "none"; 
		document.getElementById("detailsRecurring_"+kind).style.display = "block"; 
		document.getElementById("detailsDaily_"+kind).style.display = "none"; 
	}
	else if (frequency == "3") {
		document.getElementById("detailsOneTime_"+kind).style.display = "none"; 
		document.getElementById("detailsRecurring_"+kind).style.display = "none"; 
		document.getElementById("detailsDaily_"+kind).style.display = "block"; 
	}
}

<!--- Check and fix time --------------------------------------------------------------------- --->
function fixTime(fld) 
{ // tenacious time correction 
	if(!fld.value.length||fld.disabled) return true; // blank fields are the domain of requireValue 
	var hour= 0; 
	var mins= 0;
	val= fld.value;
	var dt= new Date('1/1/2000 ' + val);
	if(('9'+val) == parseInt('9'+val))
	{ hour= val; }
	else if(dt.valueOf())
	{ hour= dt.getHours(); mins= dt.getMinutes(); }
	else
	{
		val= val.replace(/\D+/g,':');
		hour= parseInt(val);
		mins= parseInt(val.substring(val.indexOf(':')+1,20));
		if(isNaN(hour)) hour= 0;
		if(isNaN(mins)) mins= 0;
		if(val.indexOf('pm') > -1) hour+= 12;
	}
	hour%= 24;
	mins%= 60;
	if(mins < 10) mins= '0' + mins;
	fld.value= hour + ':' + mins;
	return true;
}

<!--- Final validation of mandatory method fiels --------------------------------------------- --->
function validateMethodInput(myform,kind) {
	if (kind == "Upd") var nr = 1; 
	else var nr = 0;

	var method = document.getElementsByName("method")[nr].value;
	
	//----- No folder selected -----
	if (document.schedulerform.folder_id.value == ""){
		alert('<cfoutput>#JSStringFormat(defaultsObj.trans("sched_msg_choose_folder"))#</cfoutput>');
		return false;
	}
	//----- Folder is selected -----
	else {
		//----- selected method: SERVER -----
		if (method == "server") {
			var folder = document.getElementsByName("serverFolder")[nr];
			var selected = folder[folder.selectedIndex].value;
			if (selected == "") {
				alert("<cfoutput>#JSStringFormat(defaultsObj.trans("sched_msg_server"))#</cfoutput>");
				return false;
			} else {
				// Get values
				var url = formaction("schedulerform");
				var items = formserialize("schedulerform");
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: hidewinscheduler
				});
			}
		//----- selected method: FTP -----
		} else if (method == "ftp") {
			var ftpServer = document.getElementsByName("ftpServer")[nr].value;
			var ftpUser   = document.getElementsByName("ftpUser")[nr].value;
			var ftpPass   = document.getElementsByName("ftpPass")[nr].value;
			if (ftpServer == "" || ftpUser == "" || ftpPass == "") {
				alert("<cfoutput>#JSStringFormat(defaultsObj.trans("sched_msg_ftp"))#</cfoutput>");
				return false;
			} else {
				// Get values
				var url = formaction("schedulerform");
				var items = formserialize("schedulerform");
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: hidewinscheduler
				});
			}
		//----- selected method: MAIL -----
		} else if (method == "mail") {
			var mailPop  = document.getElementsByName("mailPop")[nr].value;
			var mailUser = document.getElementsByName("mailUser")[nr].value;
			var mailPass = document.getElementsByName("mailPass")[nr].value;
			if (mailPop == "" || mailUser == "" || mailPass == "") {
				alert("<cfoutput>#JSStringFormat(defaultsObj.trans("sched_msg_mail"))#</cfoutput>");
				return false;
			} else {
				// Get values
				var url = formaction("schedulerform");
				var items = formserialize("schedulerform");
				// Submit Form
				$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: hidewinscheduler
				});
			}
		}
	}
}

// Hide the window
function hidewinscheduler(){
	// Hide Window
	destroywindow(1);
	loadcontent('admin_schedules','<cfoutput>#myself#</cfoutput>c.scheduler_list');
}

<!--- Open FTP connection and show its folder structure -------------------------------------- --->
function openFtp(kind) {
	if (kind == "Upd") var nr = 1; 
	else var nr = 0;

	var ftpServer = document.getElementsByName("ftpServer")[nr].value;
	var ftpUser   = escape(document.getElementsByName("ftpUser")[nr].value);
	var ftpPass   = escape(document.getElementsByName("ftpPass")[nr].value);
	var ftpPath   = document.getElementsByName("ftpFolder")[nr].value;
	var ftppassive   = document.getElementsByName("ftpPassive")[nr].value;
	if (ftpServer == "" || ftpUser == "" || ftpPass == "") {
		alert("Please enter the required fields FTP Server, User and Password!");
	} else {
		showwindow('<cfoutput>#myself#</cfoutput>c.ftp_gologin&thetype=sched&ftp_server='+ftpServer+'&ftp_user='+ftpUser+'&ftp_pass='+ftpPass+'&ftp_passive='+ftppassive,'FTP',600,3);
	}
}

<!--- Open eMail connection and show possible messages --------------------------------------- --->
function openMail(kind) {
	if (kind == "Upd") var nr = 1; 
	else var nr = 0;

	var mailPop  = document.getElementsByName("mailPop")[nr].value;
	var mailUser = document.getElementsByName("mailUser")[nr].value;
	var mailPass = escape(document.getElementsByName("mailPass")[nr].value);
	var mailSubj = document.getElementsByName("mailSubject")[nr].value;
	if (mailPop == "" || mailUser == "" || mailPass == "") {
		alert("Please enter the required fields POP Server, User and Password!");
	} else {
		window.open('dsp_scheduler_email.cfm?pop='+mailPop+'&user='+mailUser+'&pass='+mailPass+'&subject='+mailSubj, 'mailWin', 'toolbar=no,location=0,directories=no,status=no,menubar=0,scrollbars=1,resizable=1,copyhistory=no,width=310,height=350');
	}
}

<!--- Open window to select folder from Digital Asset Management-System ---------------------- --->
function doDelete() {
	var deleteTask = "<cfoutput>#JSStringFormat(defaultsObj.trans("delete"))#</cfoutput>";
	if (confirm(deleteTask))
		return true;
	else
		return false;
}

</script>