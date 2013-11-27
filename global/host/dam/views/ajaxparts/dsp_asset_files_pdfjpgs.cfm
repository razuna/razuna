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
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" >
<head>
<body>
<cfoutput>
<!--- Storage Decision --->
<cfif application.razuna.storage EQ "nirvanix">
	<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
<cfelse>
	<cfset thestorage = "#cgi.context_path#/assets/#session.hostid#/">
</cfif>
<table width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="80%">
				<tr>
					<td align="center"><a name="top"></a>#myFusebox.getApplicationData().defaults.trans("pages")#: #qry_pdfjpgs.qry_pdfjpgs.recordcount#</td>
				</tr>
				<cfif qry_pdfjpgs.qry_pdfjpgs.recordcount NEQ 1>
					<tr>
						<td align="center"><cfloop from="1" to="#qry_pdfjpgs.qry_pdfjpgs.recordcount#" index="i"><a href="###i#">#i#</a> <cfif i NEQ qry_pdfjpgs.qry_pdfjpgs.recordcount>|</cfif> </cfloop></td>
					</tr>
				</cfif>
			
				<tr>
					<td align="center" style="padding-top:10px;">
						<cfloop list="#qry_pdfjpgs.thepdfjpgslist#" delimiters="," index="i">
							<cfset thenr = replacenocase(i,".jpg","","all")>
							<cfset thenr = listlast(thenr,"-")>
							<a name="#val(thenr)+1#"><img src="#thestorage##qry_detail.detail.path_to_asset#/razuna_pdf_images/#i#" border="0" width="60%"></a><a href="##top">Top</a>
						</cfloop>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</cfoutput>
</body>
</html>
