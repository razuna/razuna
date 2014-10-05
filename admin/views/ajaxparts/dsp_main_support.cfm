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
<cfcachecontent name="razunaadminsupport" cachedwithin="#CreateTimeSpan(1,0,0,0)#" region="razcache">
	<cfoutput>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
			<tr>
				<th>Razuna Support</th>
			</tr>
			<tr>
				<td>#defaultsObj.trans("support_desc")#</td>
			</tr>
			<tr>
				<th>Online Support Tools</th>
			</tr>
			<tr>
				<td><a href="http://wiki.razuna.com/">Razuna #defaultsObj.trans("online_help_link")#</a></td>
			</tr>
			<tr>
				<td><a href="https://help.razuna.com" target="_blank">Join our Customer Community</a></td>
			</tr>
			<tr>
				<td><a href="http://issues.razuna.com" target="_blank">Razuna Bug Tracking/Knowledge Base</a></td>
			</tr>
		</table>
	</cfoutput>
</cfcachecontent>