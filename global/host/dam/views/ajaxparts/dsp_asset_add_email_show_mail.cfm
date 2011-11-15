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
	<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
		<tr>
			<th colspan="5">eMail Messages</th>
		</tr>
		<cfloop query="qry_emailmessage">
		<tr>
			<td width="1%">From</td>
			<td width="100%">#from#</td>
		</tr>
		<tr>
			<td>Subject</td>
			<td>#subject#</td>
		</tr>
		<tr>
			<td>Date</td>
			<td>#date#</td>
		</tr>
		<cfset numattachments = listlen(attachments)>
		<cfif numattachments GT 0>
		<tr>
			<td valign="top">Attachment</td>
			<td>
				<cfloop list="#attachmentfiles#" delimiters="," index="i">
				<cfif NOT i CONTAINS "smime">
				<cfset thename = listlast(#i#, "/")>
				<cfset thisurl = "incoming/emails/#URLEncodedFormat("#thename#","utf-8")#">
				<a href="#thisurl#" target="_blank">#thename#</a><br>
				</cfif>
				</cfloop>
			</td>
		</tr>
		</cfif>
		<tr>
			<td valign="top">Body</td>
			<td><cfif #header# CONTAINS "Content Type: Text/html">
			#body#
			<cfelse>
			#htmlcodeformat(body)#
			</cfif></td>
		</tr>
		<!--- <tr>
			<td valign="top">Header</td>
			<td>#htmlcodeformat(Header)#</td>
		</tr> --->
		</cfloop>
		
	</table>
</cfoutput>