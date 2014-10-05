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
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gridlist">
		<!--- <tr>
			<td width="100%" style="padding:5px;">#myFusebox.getApplicationData().defaults.trans("folder_count_total")#</td>
			<td width="1%" nowrap style="padding:5px;">#totalcount.thetotal#</td>
		</tr> --->
		<cfif !application.razuna.isp>
			<cfcachecontent name="damsysteminfo" cachedwithin="#CreateTimeSpan(1,0,0,0)#">
				<tr>
					<td width="100%" style="padding:5px;">#myFusebox.getApplicationData().defaults.trans("database_in_use")#</td>
					<td width="1%" nowrap style="padding:5px;">#application.razuna.thedatabase#</td>
				</tr>
				<tr>
					<td width="100%" style="padding:5px;">#myFusebox.getApplicationData().defaults.trans("server_platform")#</td>
					<td width="1%" nowrap style="padding:5px;">#server.OS.Name#</td>
				</tr>
				<tr>
					<td width="100%" style="padding:5px;">#myFusebox.getApplicationData().defaults.trans("server_platform_version")#</td>
					<td width="1%" nowrap style="padding:5px;">#server.os.version#</td>
				</tr>
				<tr>
					<td width="100%" style="padding:5px;">#myFusebox.getApplicationData().defaults.trans("coldfusion_product")#</td>
					<td width="1%" nowrap style="padding:5px;">#server.ColdFusion.ProductName#</td>
				</tr>
				<tr>
					<td width="100%" style="padding:5px;">#myFusebox.getApplicationData().defaults.trans("coldfusion_version")#</td>
					<td width="1%" nowrap style="padding:5px;"><cfif server.ColdFusion.ProductName CONTAINS "bluedragon">#server.bluedragon.edition#<cfelse>#server.ColdFusion.ProductVersion#</cfif></td>
				</tr>
			</cfcachecontent>
		</cfif>
		<tr>
			<td width="100%" style="padding:5px;">#myFusebox.getApplicationData().defaults.trans("server_url")#</td>
			<td width="1%" nowrap style="padding:5px;">#cgi.HTTP_HOST#</td>
		</tr>
	</table>
</cfoutput>