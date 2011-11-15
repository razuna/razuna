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
	<form name="form_#theform#">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<th colspan="4">#thetitle# Records<th>
			</tr>
			<tr style="font-weight:bold;">
				<td><a href="##" onClick="CheckAll('form_#theform#');">Select All</a></td>
				<td>ID</td>
				<td>Filename</td>
				<td></td>
			</tr>
			<cfloop query="theqry">
				<tr>
					<td style="border-bottom:1px solid grey;"><input type="checkbox" name="id" value="#id#"></td>
					<td style="border-bottom:1px solid grey;">#id# &nbsp;</td>
					<td style="border-bottom:1px solid grey;">#filenameorg# &nbsp;</td>
					<td style="border-bottom:1px solid grey;"><a href="##" onClick="show_confirm_one('#id#','#theform#');">Delete</a></td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="4"><a href="##" onClick="show_confirm('form_#theform#','#theform#');">Delete selected records</a></td>
			</tr>
		</table>
	</form>
</cfoutput>