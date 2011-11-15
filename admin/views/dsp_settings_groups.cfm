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
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
	<td>
	<cfdiv bind="url:#myself#c.getgrouplist" id="listgroups" tagName="div" />
	</td>
</tr>
</table>

<cfoutput>
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
<tr>
	<th colspan="2">#gobj.trans("head_newgroup")#</th>
</tr>
<tr>
	<td width="100%"><input type="text" name="newgroup" id="newgroup" size="30"></td>
	<td width="1%" nowrap="true"><input type="button" name="but" value="#gobj.trans("but_add")#" onclick="Javascript:ColdFusion.navigate('#myself##xfa.submitform#&newgroup='+ encodeURI(document.getElementById('newgroup').value), 'listgroups')" class="button"></td>
</tr>
</table>
</cfoutput>