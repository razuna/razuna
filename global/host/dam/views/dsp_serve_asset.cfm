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
<!--- If asset has expired then show appropriate message --->
<cfif isdefined("qry_binary.qfile.expiry_date_actual") AND isdate(qry_binary.qfile.expiry_date_actual) AND qry_binary.qfile.expiry_date_actual lt now()>
	Asset has expired. Please contact administrator to gain access to this asset.<cfabort>
</cfif>
<cfparam default="F" name="attributes.download">
<cfparam default="" name="qry_binary.qfile.link_kind">
<cfparam default="false" name="attributes.av">
<!--- This is for additional versions --->
<cfif attributes.av>
	<!--- Grab theurl and get filename --->
	<cfset theext = listlast(listfirst(listlast(qry_binary.qfile.path_to_asset,'/'),'?'),'.')>
	<!--- RAZ-2519 users download with their custom filename --->
	<cfif structKeyExists(attributes,"set2_custom_file_ext") AND attributes.set2_custom_file_ext EQ "false">
		<cfheader name="content-disposition" value='attachment; filename="#qry_binary.thefilename#"' />
	<cfelse>
		<!--- Default file name when prompted to download --->
		<cfif qry_binary.thefilename does not contain ".#theext#">
			<cfheader name="content-disposition" value='attachment; filename="#qry_binary.thefilename#.#theext#"' />
		<cfelse>
			<cfheader name="content-disposition" value='attachment; filename="#qry_binary.thefilename#"' />
		</cfif>
	</cfif> 
	<!--- Get file --->
	<cfif application.razuna.storage NEQ "amazon">
		<cfhttp url="#qry_binary.theurl#" getasbinary="yes" />
	<cfelse>
		<cfhttp url="#qry_binary.qfile.cloud_url#" getasbinary="yes" />
	</cfif>
	<!--- Serve the file --->
	<cfcontent type="application/force-download" variable="#cfhttp.FileContent#">
</cfif>
<!--- Storage Decision --->
<cfset thestorage = "#attributes.assetpath#/#session.hostid#/">
<!--- Default file name when prompted to download --->
<cfheader name="content-disposition" value='attachment; filename="#qry_binary.thefilename#"' />
<!--- Ignore content-length attribute for previews --->
<cfif isdefined("v") AND v neq "p">
	<cfheader name="content-length" value="#qry_binary.qfile.thesize#" />
</cfif>
<!--- File is external --->
<cfif qry_binary.qfile.link_kind EQ "url">
	<!--- Get file --->
	<cfhttp url="#qry_binary.qfile.link_path_url#" getasbinary="yes" />
	<!--- Serve the file --->
	<cfcontent type="application/force-download" variable="#cfhttp.FileContent#">
<cfelse>
	<!--- Nirvanix --->
	<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
		<!--- Decide on original or preview --->
		<cfif attributes.v EQ "o">
			<cfset theurl = qry_binary.qfile.cloud_url_org>
		<cfelse>
			<cfset theurl = qry_binary.qfile.cloud_url>
		</cfif>
		<!--- This is for basket or direct downloads --->
		<cfif attributes.download EQ "T">
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#attributes.thepath#/outgoing/#qry_binary.thefilename#" deletefile="true">
		<cfelse>
			<!--- Get file --->
			<cfif application.razuna.storage EQ "nirvanix">
				<cflocation url="#theurl#?disposition=attachment">
			<cfelse>
				<cflocation url="#theurl#">
			</cfif>
		</cfif>
	<cfelseif application.razuna.storage EQ "akamai">
		<cfif attributes.type EQ "img">
			<cfset akatype = attributes.akaimg>
		<cfelseif attributes.type EQ "vid">
			<cfset akatype = attributes.akavid>
		<cfelseif attributes.type EQ "aud">
			<cfset akatype = attributes.akaaud>
		<cfelse>
			<cfset akatype = attributes.akadoc>
		</cfif>
		<!--- This is for basket or direct downloads --->
		<cfif attributes.download EQ "T">
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#attributes.thepath#/outgoing/#qry_binary.thefilename#" deletefile="true">
		<cfelse>
			<!--- Decide on original or preview --->
			<cfif attributes.v EQ "o">
				<cfset theurl = "#attributes.akaurl##akatype#/#qry_binary.qfile.filenameorg#">
			<cfelse>
				<cfset theurl = "#session.thehttp##cgi.http_host#/assets/#session.hostid#/#qry_binary.qfile.path_to_asset#/thumb_#qry_binary.qfile.img_id#.#qry_binary.qfile.thumb_extension#">
			</cfif>
			<!--- Get file --->
			<cfhttp url="#theurl#" getasbinary="yes" />
			<!--- Serve the file --->
			<cfcontent type="application/force-download" variable="#cfhttp.FileContent#">
		</cfif>
	<!--- Local --->
	<cfelse>
		<!--- This is for basket or direct downloads --->
		<cfif attributes.download EQ "T">
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfcontent type="application/force-download" file="#attributes.thepath#/outgoing/#qry_binary.thefilename#" deletefile="true">
		<cfelse>
			<!--- Different file location for assets stored on lan --->
			<cfif qry_binary.qfile.link_kind EQ "lan">
				<cfset thefileloc = "#replace(qry_binary.qfile.link_path_url,"\ "," ","ALL")#">
			<cfelse>
				<!--- Decide on original or preview --->
				<cfif attributes.v EQ "o">
					<cfif qry_binary.av>
						<cfset thefileloc = "#thestorage##qry_binary.qfile.path_to_asset#">
					<cfelse>
						<cfset thefileloc = "#thestorage##qry_binary.qfile.path_to_asset#/#qry_binary.qfile.filenameorg#">
					</cfif>
				<cfelse>
					<cfset thefileloc = "#thestorage##qry_binary.qfile.path_to_asset#/thumb_#qry_binary.qfile.img_id#.#qry_binary.qfile.thumb_extension#">
				</cfif>
			</cfif>
			<!--- <cffile action="readbinary" file="#thefileloc#" variable="readb"> --->
			<!--- Serve the file --->
			<cfcontent type="application/force-download" file="#thefileloc#" deletefile="false">
		</cfif>
	</cfif>
</cfif>