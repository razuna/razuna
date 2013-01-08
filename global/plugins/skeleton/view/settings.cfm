<cfoutput>
	<!--- Create the div with the tabs --->
	<!--- Set optional width with: style="width:720px;" --->
	<div id="tab_workflow_settings" style="width:720px;">
		<!--- Tabs --->
		<ul>
			<li><a href="##tab1">My Setting</a></li>
			<li><a href="##tab2">Tab 2</a></li>
		</ul>
		<!--- Divs --->
		<div id="tab1">
			This is a result from the CFC you called: #result.cfc.pl.getSettings#
			<br />
			Let's save:
			<form action="index.cfm" id="mySettingsForm" onsubmit="return false;">
				<input type="hidden" name="fa" value="c.plugin_save">
				<input type="hidden" name="p_action" value="settings_save">
				<input type="hidden" name="p_id" value="#p_id#">
				<input type="text" name="mytext" size="40" />
				<input type="text" name="myid" size="40" />
				<input type="submit" name="submitme" value="Save" />
				<input type="button" name"mybutton" value="SaveButton" onclick="savethis();" />
			</form>
			<div id="mysave"></div>
		</div>
		<div id="tab2">Content of Tab 2</div>
	</div>
	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		// Create Tabs
		jqtabs("tab_workflow_settings");
		// Save from Button
		function savethis(){
			$('##mysave').load('/global/plugins/workflow/cfc/settings.cfc?method=setSettingsRemote&args=tests');
		}
		// Submit form
		<!--- Load Progress --->
		$("##mySettingsForm").submit(function(e){
			// Get values
			var url = formaction("mySettingsForm");
			var items = formserialize("mySettingsForm");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			// Feedback
			// $('##status_custom_1').fadeTo("fast", 100);
			// $('##status_custom_1').html('<span style="font-weight:bold;color:green;">We saved the change successfully!</span>');
			// $('##status_custom_1').fadeTo(5000, 0);
			// $('##status_custom_2').fadeTo("fast", 100);
			// $('##status_custom_2').html('<span style="font-weight:bold;color:green;">We saved the change successfully!</span>');
			// $('##status_custom_2').fadeTo(5000, 0);
			return false;
		});
	</script>
</cfoutput>