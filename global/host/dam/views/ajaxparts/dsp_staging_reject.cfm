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
	<div id="reject_#attributes.file_id#">
		<h1>Reject file</h1>
		<h3>You opted to reject this file. Please state why you rejected this file. This message will be sent to the person who uploaded the file and to all group members who are in the approval process.</h3>
		<form id="form_reject_file" name="form_reject_file" method="post">
			<input type="hidden" name="file_id" id="file_id" value="#attributes.file_id#">
			<input type="hidden" name="file_type" value="#attributes.file_type#">
			<input type="hidden" name="file_owner" value="#attributes.file_owner#">
			<strong>Message</strong>
			<textarea name="reject_message" id="reject_message" style="height:400px;width:95%" placeholder="Type your reason for the rejection here..."></textarea>
			<br>
			<input type="submit" name="submit" value="Reject file now and send message" class="awesome big green">
			<a href="##" onclick="destroywindow(1);return false;" style="padding-left:10px">Close</a>
		</form>
	</div>
	<!--- Submit --->
	<script type="text/javascript">
	// On submit
	$('##form_reject_file').on('submit', function() {
		// Get message value
		var _message = $('##reject_message').val();
		// If message is empty prompt the user
		if (_message === '') {
			if (confirm("Are you sure you don't want to write a reason for the rejection?") == true) {
				finalSubmit();
			}
		}
		else {
			finalSubmit();
		}
		
		return false;
	});
	// Internal submit
	function finalSubmit() {
		// Get ID
		var id = $('##file_id').val();
		// Get values
		var items = formserialize("form_reject_file");
		// Submit 
		$.ajax({
			type: "POST",
			url: '#myself#c.approval_reject',
			data: items
		})
		.done( function() {
			$('##reject_' + id).html("<h2>Your message has been sent and the file has been rejected! <br><br><a href='##'' onclick='destroywindow(1);return false;'>You can close this window now</a></h2>");
		})
		.fail( function() {
			alert('fail!!!!!!!')
		});
	}
	</script>
</cfoutput>