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
	<div style="padding-top:5px;">
		<a href="##" onclick="loadcontent('thedroporders','#myself#c.orders');">Refresh</a> | <a href="##" onclick="loadcontent('thedroporders','#myself#c.orders_reset');">Reset CartID</a>
	</div>
	<div style="overflow:auto;font-weight:normal;">
		<table border="0">
			<cfloop query="qry_orders">
				<tr>
					<td><strong>OrderID:</strong> <a href="##" onclick="tooglefooter('2');loadcontent('rightside','#myself#c.order_show&cart_id=#cart_id#');$('##footer_drop').css('height','30px');">#cart_id#</a></td>
					<td><strong>Date:</strong> #cart_order_date#</td>
					<td><strong>Status:</strong> <cfif cart_order_done EQ 0><span style="color:red;">Pending</span><cfelse><span style="color:green;">Done</span></cfif></td>
					<td><a href="##" onclick="loadcontent('thedroporders','#myself#c.order_remove&cart_id=#cart_id#');">Remove</a></td>
				<tr>
			</cfloop>
		</table>
	</div>
</cfoutput>