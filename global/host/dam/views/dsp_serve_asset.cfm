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
<cfparam default="" name="qry_binary.qfile.link_kind">
<!--- Storage Decision --->
<!---
<cfif application.razuna.storage EQ "nirvanix">
	<cfset thestorage = "#application.razuna.nvxurlservices#/#attributes.nvxsession#/razuna/#session.hostid#/">
<cfelse>
--->
	<cfset thestorage = "#attributes.assetpath#/#session.hostid#/">
<!--- </cfif> --->
<!--- Default file name when prompted to download --->
<cfheader name="content-disposition" value="attachment; filename=#qry_binary.thefilename#" />
<!--- File is external --->
<cfif qry_binary.qfile.link_kind EQ "url">
	<!--- Get file --->
	<cfhttp url="#qry_binary.qfile.link_path_url#" getasbinary="yes" />
	<!--- Serve the file --->
	<cfcontent type="application/force-download" variable="#cfhttp.FileContent#">
<cfelse>
	<!--- Nirvanix --->
	<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
		<!--- This is for basket or direct downloads --->
		<cfif attributes.download EQ "T">
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#attributes.thepath#/outgoing/#qry_binary.thefilename#" deletefile="true">
		<cfelse>
			<!--- Get file --->
			<cfif application.razuna.storage EQ "nirvanix">
				<cflocation url="#qry_binary.qfile.cloud_url_org#?disposition=attachment">
			<cfelse>
				<cflocation url="#qry_binary.qfile.cloud_url_org#">
			</cfif>
		</cfif>
	<!--- Local --->
	<cfelse>
		<!--- This is for basket or direct downloads --->
		<cfif attributes.download EQ "T">
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#attributes.thepath#/outgoing/#qry_binary.thefilename#" deletefile="true">
		<cfelse>
			<!--- Different file location for assets stored on lan --->
			<cfif qry_binary.qfile.link_kind EQ "lan">
				<cfset thefileloc = "#qry_binary.qfile.link_path_url#">
			<cfelse>
				<cfset thefileloc = "#thestorage##qry_binary.qfile.path_to_asset#/#qry_binary.qfile.filenameorg#">
			</cfif>
			<cffile action="readbinary" file="#thefileloc#" variable="readb">
			<!--- Serve the file --->
			<cfcontent type="application/force-download" variable="#readb#">
		</cfif>
	</cfif>
</cfif>