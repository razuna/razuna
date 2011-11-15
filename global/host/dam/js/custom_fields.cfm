<script language="javascript">
	// Add a new field
	function customfieldadd(){
		// Get values
		var url = formaction("form_cf_add");
		var items = formserialize("form_cf_add");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: reloadfields
		});
		return false;
	}
	// Update field
	function customfieldupdate(){
		// Get values
		var url = formaction("form_cf_detail");
		var items = formserialize("form_cf_detail");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		destroywindow(1);
		   		reloadfields();
		   	}
		});
		return false;
	}
	// Reload the fields div
	function reloadfields(){
		loadcontent('thefields','<cfoutput>#myself#c.custom_fields_existing</cfoutput>');	
	}
</script>