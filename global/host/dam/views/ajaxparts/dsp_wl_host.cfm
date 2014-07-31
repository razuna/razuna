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
	<!--- Tabs --->
	<div id="tab_wl">
		<ul>
			<!--- Options --->
			<li><a href="##wl_options">Options</a></li>
			<!--- CSS --->
			<li><a href="##wl_css">CSS</a></li>
			<!--- News --->
			<li><a href="##wl_news" onclick="loadcontent('wl_news','#myself#c.wl_news');">News</a></li>
			<!--- Most recently updates --->
			<li><a href="##wl_show_recent_updates">This goes into options</a></li>
		</ul>
		<!--- Content --->
		<div id="one"></div>
		<div id="two"></div>
	</div>
	
</cfoutput>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	$("#tab_wl").tabs();
</script>