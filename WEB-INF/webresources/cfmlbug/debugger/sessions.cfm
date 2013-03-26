<cfset request.simple = true>
<cfinclude template="../inc/header.inc">

<table id="sessionTable" width="100%" class="fileList" cellpadding="0" cellspacing="0">
<tr>
	<th colspan="5"><div class="filename">Active Client Sessions
			<span style="float:right; "><a href="cfmlbug.cfres?_f=debugger/sessions.cfm&_cfmlbug" title="refresh" class="refresh">refresh</a></span></div>
	</th>
</tr>
</table>

<script src="<cfoutput>#request.staticroot#</cfoutput>debugger.js"></script>
<script>
$(function() {
	SessionManager.refresh();
});
</script>

<cfinclude template="../inc/footer.inc">