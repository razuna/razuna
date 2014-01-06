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
<cfparam default="F" name="attributes.download">
<cfoutput>
	<!--- Any kind of files (doc) --->
	<cfif attributes.type EQ "doc">
		<cfset thefilename = listlast(qry_binary.qfile.file_name, ".") & "." & qry_binary.qfile.file_extension>
		<cfif application.razuna.thedatabase EQ "oracle">
			<!--- Default file name when prompted to download --->
			<cfheader name="content-disposition" value='attachment; filename="#thefilename#"'>
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfif attributes.download EQ "T">
				<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#thispath#/outgoing/#qry_binary.qfile.file_binary#" deleteFile="true">
			<cfelse>
				<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" variable="#qry_binary.qfile.file_binary#">
			</cfif>
		<cfelse>
			<cfif attributes.download EQ "T">
				<!--- Default file name when prompted to download --->
				<cfheader name="content-disposition" value='attachment; filename="#attributes.zipname#"'>
				<!--- Set the MIME content encoding header and send the contents of as the page output. --->
				<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#attributes.thepath#/outgoing/#attributes.zipname#" deletefile="true">
			<cfelse>
				<!--- Set the MIME content encoding header and send the contents of as the page output. --->
				<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#attributes.assetpath#/#session.hostid#/#qry_binary.qfile.folder_id_r#/doc/#attributes.file_id#/#qry_binary.qfile.file_name_org#">
			</cfif>
		</cfif>
	</cfif>
</cfoutput>