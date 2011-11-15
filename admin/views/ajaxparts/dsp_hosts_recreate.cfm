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
	<table border="0" cellpadding="5" cellspacing="5" width="100%">
		<tr>
			<td style="padding-top:10px;">#defaultsObj.trans("update_host_manually")#</td>
		</tr>
		<tr>
			<td align="right" style="padding-top:10px;"><input type="button" name="remove" value="#defaultsObj.trans("update_host_manually_desc")#" onclick="destroywindow(1);loadinggif('hostslist');loadcontent('hostslist','#myself#c.hosts_recreate&host_id=#attributes.host_id#&pathoneup=#urlencodedformat(pathoneup)#&pathhere=#urlencodedformat(thisPath)#');" class="button"></td>
		</tr>
	</table>
</cfoutput>

