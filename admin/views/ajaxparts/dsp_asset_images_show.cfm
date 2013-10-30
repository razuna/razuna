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
<head>
<body>
<cfoutput>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
	<td align="center" style="padding-top:20px;">
		<cfif attributes.v EQ "o">
			<!--- Original file --->
			<cfif application.razuna.thedatabase EQ "oracle">
				<img src="#sUrlOracle.org#?id=#attributes.file_id#&tabname=#session.imgtable#&review=#randomvalue#" border="0">
			<cfelse>
				<img src="#cgi.context_path#/assets/#session.hostid#/#qry_detail.folder_id_r#/img/#attributes.file_id#/#qry_detail.img_filename_org#" border="0" width="#qry_detail.img_width#" height="#qry_detail.img_height#">
			</cfif>
		<cfelse>
			<!--- Thumbnail --->
			<cfif application.razuna.thedatabase EQ "oracle">
				<img src="#sUrlOracle.thumb#?id=#attributes.file_id#&tabname=#session.imgtable#&review=#randomvalue#" border="0">
			<cfelse>
				<img src="#cgi.context_path#/assets/#session.hostid#/#qry_detail.folder_id_r#/img/#attributes.file_id#/thumb_#attributes.file_id#.#qry_detail.thumb_extension#" border="0" width="#qry_detail.thumb_width#" height="#qry_detail.thumb_height#">
			</cfif>
		</cfif>
	</td>
</tr>
</table>
</cfoutput>
</body>
</html>
