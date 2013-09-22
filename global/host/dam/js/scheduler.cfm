<!--- ---------------------------------------------------------------------------------------- --->
<!--- JAVASCRIPT FOR UPLOAD SCHEDULER SETTINGS                                                 --->
<!--- ---------------------------------------------------------------------------------------- --->
<script language="JavaScript">

<!--- Final validation of mandatory method fiels --------------------------------------------- --->
function validateMethodInput(myform,kind) {

	// Check the a name has been given
	var taskName = $('#taskName').val();
	if (taskName == ""){
		alert('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("sched_msg_task_name"))#</cfoutput>');
		return false;
	}

	if (kind == "Upd") var nr = 1; 
	else var nr = 0;

	var method = document.getElementsByName("method")[nr].value;
	
	//----- No folder selected -----
	if (document.schedulerform.folder_id.value == ""){
		alert('<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("sched_msg_choose_folder"))#</cfoutput>');
		return false;
	}
	//----- Folder is selected -----
	else {
		//----- selected method: SERVER -----
		if (method == "server") {
			var folder = document.getElementsByName("serverFolder")[nr];
			var selected = folder[folder.selectedIndex].value;
			if (selected == "") {
				alert("<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("sched_msg_server"))#</cfoutput>");
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
				alert("<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("sched_msg_ftp"))#</cfoutput>");
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
				alert("<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("sched_msg_mail"))#</cfoutput>");
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
		//----- AD Server -----
		} else if (method == "ADServer") {
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
		// Rebuild search index
		} else if (method == "rebuild" || method == "indexing") {
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
<!--- Open window to select folder from Digital Asset Management-System ---------------------- --->
function doDelete() {
	var deleteTask = "<cfoutput>#JSStringFormat(myFusebox.getApplicationData().defaults.trans("delete"))#</cfoutput>";
	if (confirm(deleteTask))
		return true;
	else
		return false;
}

</script>