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
<span class="loginform_header">#defaultsObj.trans("choosehost")#</span>
<br />
<br />
<form name="hostform" action="#self#" method="post">
<input type="hidden" name="#theaction#" value="c.sethost">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><select name="host_id" onChange="javascript:changehostform('hostform');">
			<option value="javascript:void();" selected="true"></option>
			<cfloop query="qry_allhosts">
				<option value="#host_id#">#ucase(host_name)#</option>
			</cfloop></select></td>
	</tr>
	</table>
</form>
</cfoutput>
