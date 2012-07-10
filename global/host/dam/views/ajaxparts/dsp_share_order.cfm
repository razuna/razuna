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
	<form name="sendemailform" id="sendemailform" action="#self#" method="post">
	<input type="hidden" name="#theaction#" value="c.basket_order">
	<input type="hidden" name="basketid" value="#session.thecart#">
	<input type="hidden" name="fid" value="#session.fid#">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th>Order Assets</th>
			</tr>
			<tr>
				<td>In order for us to know who to send the order to, we require a valid eMail address. Therefore, please enter your eMail Address below.</td>
			</tr>
			<tr>
				<td><input type="text" name="cart_order_email" id="cart_order_email" style="width:450px;"></td>
			</tr>
			<!--- Message Box --->
			<tr>
				<td>Do you have anything to say to us?</td>
			</tr>
			<tr>
				<td><textarea name="cart_order_message" id="cart_order_message" style="width:450px;height:150px;"></textarea></td>
			</tr>
			<tr>
				<td align="right"><div id="successemail" style="float:left;color:green;font-weight:bold;"></div><input type="submit" name="send" value="Order Assets" class="button"></td>
			</tr>
		</table>
	</form>
	<script type="text/javascript">
	$("##sendemailform").submit(function(e){
		//$("##successemail").css("display","");
		//loadinggif('successemail');
		// Submit Form
		// Get values
		var url = formaction("sendemailform");
		var items = formserialize("sendemailform");
		// Submit Form
		$.ajax({
			type: "POST",
			url: url,
		   	data: items,
		   	success: function(){
		   		$("##successemail").html('#JSStringFormat(myFusebox.getApplicationData().defaults.trans("message_sent"))#');
		   		$("##successemail").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
		   	}
		});
		return false;
	})
	</script>

</cfoutput>