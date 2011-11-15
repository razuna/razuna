<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfoutput>
<h2>Send Error Report</h2>
<p>Use the form below to let us know of this error. The error itself will be attached to your message.</p>
<form name="form_error" id="form_error" method="post" action="#self#">
<input type="hidden" name="#theaction#" value="c.log_errors_send">
<input type="hidden" name="id" value="#attributes.id#">
<label for="email">Email</label><br>
<input type="text" name="email" id="email" value="#qryuseremail#" class="rounded" style="width:400px;" /><br>
<label for="comment">Feedback</label><br>
<textarea name="comment" id="comment" class="rounded" style="width:400px;height:200px;"></textarea><br>
<input name="submitbutton" type="submit" id="submitbutton" class="button" value="Send Report" />
</form>
<br>
<div id="feedbackerr"></div>

<script>
	$("##form_error").submit(function(e){
		//$("##feedback").css("display","");
		// Submit Form
		// Get values
		var url = formaction("form_error");
		var items = formserialize("form_error");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		$("##feedbackerr").html("#JSStringFormat('<h3>The error report has been sent to the issue system over at <a href="http://issues.razuna.com" target="_blank">http://issues.razuna.com</a>.</h3><p>Our system has automatically registered you and you will get notified when we response to the report you are providing here.</p>')#");
		   	}
		});
		return false;
	})
</script>
</cfoutput>