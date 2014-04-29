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
			<td>Below is your API Key. With it you can use the Razuna Desktop Uploader application and the Razuna API. Please refer to the <a href="http://wiki.razuna.com/" target="_blank">API documentation</a>. Please note, that currently we only support access by API from an account within the administrator group.</td>
		</tr>
		<tr>
			<td width="100%" style="padding:20px;text-align:center;">
				<span style="color:green;font-weight:bold;border:1px solid green;padding:10px;background-color:yellow;">#qry_api_key#</span>
			</td>
		</tr>
		<tr>
			<td style="padding-top:20px;">In case your key has been tempered with or has become otherwise insecure <a href="##" onclick="loadcontent('tab_api','#myself#c.users_api&user_id=#attributes.user_id#&reset=true');">you can reset the API key</a>. <strong>NOTE: You will need to use the new API key with your application. The reset takes effect immediately!</strong></td>
		</tr>
	</table>
</cfoutput>