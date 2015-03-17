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
	<h2>Current indexing status</h2>
	<cfif qry_status_lock_file>
		<p><strong>System Status:</strong> The system is currently indexing files! To see an updated list please <a href="##indexing" onclick="loadcontent('indexing','#myself#c.indexing');"><strong>refresh this page</strong></a>.</p>
	<cfelse>
		<p><strong>System Status:</strong> Your files are waiting to be indexed.</p>
	</cfif>
	<p></p>
	<p>Here is a list of files and their index status. The system is set to automatically index files. You can <a href="##indexing" onclick="loadcontent('indexing','#myself#c.indexing');"><strong>refresh this page again</strong></a> to get the current index status.</p>
	<table border="1" cellpadding="0" cellspacing="0" width="400" class="tablepanel">
		<tr>
			<th>Type</th>
			<th style="text-align:center;">Files to be indexed</th>
		</tr>
		<cfloop query="qry_status">
			<tr>
				<td>#type#</td>
				<td width="200" align="center">#count#</td>
			</tr>
		</cfloop>
	</table>
	<h3>Please note</h3>
	<cfif application.razuna.isp>
		<p>Files are being indexed every couple of minutes. Due to the large amount of data it can take some time until files are being indexed and available for searching.</p>
	<cfelse>
		<p>Files are being indexed every couple of minutes. Due to the large amount of data it can take some time until files are being indexed and available for searching. If you feel there is an error with this, please report this to your local Administrator.</p>
	</cfif>

</cfoutput>