<!--- Get the URL of this CF Server --->
<cfscript>
	function GetCurrentURL() {
		var theURL = "http";
		theURL = theURL & "://#cgi.server_name#";
		if(cgi.server_port neq 80) theURL = theURL & ":#cgi.server_port#";
		return theURL;
	}
</cfscript>

<script language="javascript" type="text/javascript">
	// Check for existing host name
	function checkhostname() {
		loadcontent('checkhostname','<cfoutput>#myself#</cfoutput>c.hosts_checkhostname&host_name=' + escape($("#host_name").val()));
	}
	// Check for existing host path
	function checkhostpath() {
		loadcontent('checkhostpath','<cfoutput>#myself#</cfoutput>c.hosts_checkhostname&host_path=' + escape($("#host_path").val()));
	}
</script>

<!--- Escape the \ for the script below--->
<cfset jspath = "#replace("#pathoneup#/", "\", "/", "ALL")#">

<!--- JS for generating the paths --->
<script language="javascript">
	function setpaths() {
		var valid = '0123456780qwertzuioplkjhgfdsayxcvbnm_-'; // define valid characters
		var thefield = document.thehost.host_path.value;
		function isValid(string,allowed) {
		    for (var i=0; i< string.length; i++) {
		       if (allowed.indexOf(string.charAt(i)) == -1)
		          return false;
		    }
		    return true;
		}
		if (isValid(thefield,valid) == false) {
			alert('<cfoutput>#defaultsObj.trans("no_space_umlauts")#</cfoutput>');
			document.thehost.host_path.focus();
			return false;
			}
		else {
			thefield = thefield.substring(0,4);
			var dbprefix = thefield;
			document.thehost.host_db_prefix.value = dbprefix;
			return true;
		}
	}
</script>

<script language="javascript">
	$("#thehost").submit(function(e){
		// Get values
		var url = formaction("thehost");
		var items = formserialize("thehost");
		// Load content
		$("#tnewhost").html('<img src="images/loading.gif" border="0" style="padding:10px;"><br>Setting up a new host takes some time. We kindly ask you to wait until this page has finished loading!');
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items
		});
		loadcontent("rightside","<cfoutput>#myself#</cfoutput>c.hosts");
		return false;
	});
</script>

<script language="javascript">
	function updatehost(){
		thewindow.hide();
	}
</script>