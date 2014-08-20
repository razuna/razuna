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
	<!--- Set Languages --->
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("api_key_header")#</td>
		</tr>
		<tr>
			<td width="100%" style="padding:20px;text-align:center;">
				<span style="color:green;font-weight:bold;border:1px solid green;padding:10px;background-color:yellow;">#qry_api_key#</span>
			</td>
		</tr>
		<tr>
			<td style="padding-top:20px;">
				<cfset transvalues = arraynew()>
				<cfset transvalues[1] = "<a href='##' onclick=loadcontent('tab_api','#myself#c.admin_user_api&user_id=#attributes.user_id#&reset=true');>Reset Key</a>">
	 			<cfinvoke component="global.cfc.defaults" method="trans" transid="api_key_desc" values="#transvalues#" returnvariable="api_key_description" />
				#api_key_description#
			</td>
		</tr>
	</table>
</cfoutput>