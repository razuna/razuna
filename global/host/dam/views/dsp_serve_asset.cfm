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

<!--- Clean filename to make it suitable for download and encode with utf-8 --->
<cfset filenamefordownload_clean =myFusebox.getApplicationData().global.cleanfilename(qry_binary.thefilename)>
<!--- Urlencode filename while preserving the '.' --->
<cfset filenamefordownload = replace(urlencodedformat(replace(filenamefordownload_clean,'.','@DOT@','ALL'),'utf-8'),'%40DOT%40','.','ALL')>
<!--- Storage Decision --->
<cfset thestorage = "#attributes.assetpath#/#session.hostid#/">

<!--- This is for additional versions --->
<cfif attributes.av>
	<!--- Grab theurl and get filename --->
	<cfset theext = listlast(listfirst(listlast(qry_binary.qfile.path_to_asset,'/'),'?'),'.')>
	<!--- RAZ-2519 users download with their custom filename --->
	<cfif structKeyExists(attributes,"set2_custom_file_ext") AND attributes.set2_custom_file_ext EQ "false">
		<cfheader name="content-disposition" value='attachment; filename="#filenamefordownload#"' />
	<cfelse>
		<!--- Default file name when prompted to download --->
		<cfif qry_binary.thefilename does not contain ".#theext#">
			<cfheader name="content-disposition" value='attachment; filename="#filenamefordownload#.#theext#"' />
		<cfelse>
			<cfheader name="content-disposition" value='attachment; filename="#filenamefordownload#"' />
		</cfif>
	</cfif>
	<cfset remote = structnew()>
	<cfset remote.type = "http">
	<cfset remote.url = qry_binary.theurl>
	<!--- Get file --->
	<!--- <cfif application.razuna.storage NEQ "amazon">
		<cfhttp url="#qry_binary.theurl#" getasbinary="yes" />
	<cfelse>
		<cfhttp url="#qry_binary.qfile.cloud_url#" getasbinary="yes" />
	</cfif> --->
	<!--- Serve the file --->
	<!--- <cfcontent type="application/force-download" variable="#cfhttp.FileContent#"> --->
	<cfcontent remote="#remote#" />
<!--- File is external --->
<cfelseif qry_binary.qfile.link_kind EQ "url">
	<!--- Default file name when prompted to download, send as utf which modern browsers will honor and older ones will fallback to the filename witbout utf value which is also passed in --->
	<cfheader name="content-disposition" value="attachment; filename=""#filenamefordownload_clean#""; filename*=UTF-8''#filenamefordownload#" />
	<!--- Get file --->
	<cfhttp url="#qry_binary.qfile.link_path_url#" getasbinary="yes" />
	<!--- Serve the file --->
	<cfcontent type="application/force-download" variable="#cfhttp.FileContent#">
<cfelse>
	<!--- Nirvanix --->
	<cfif application.razuna.storage EQ "amazon">
		<!--- Default file name when prompted to download, send as utf which modern browsers will honor and older ones will fallback to the filename witbout utf value which is also passed in --->
		<cfheader name="content-disposition" value="attachment; filename=""#filenamefordownload_clean#""; filename*=UTF-8''#filenamefordownload#" />
		<!--- Decide on original or preview --->
		<cfif attributes.v EQ "o">
			<cfset theurl = qry_binary.qfile.cloud_url_org>
		<cfelse>
			<cfset theurl = qry_binary.qfile.cloud_url>
		</cfif>
		<!--- This is for basket or direct downloads --->
		<cfif attributes.download EQ "T">
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfcontent type="#qry_binary.qfile.file_contenttype#/#qry_binary.qfile.file_contentsubtype#" file="#attributes.thepath#/outgoing/#qry_binary.thefilename#" deletefile="false">
		<cfelse>
			<!--- Struct for remote --->
			<cfset remote = structnew()>
			<cfset remote.type = "http">
			<cfset remote.url = theurl>
			<!--- Serve file --->
			<cfcontent remote="#remote#" />
		</cfif>
	<!--- Local --->
	<cfelse>
		<!--- This is for basket or direct downloads --->
		<cfif attributes.download EQ "T">
			<!--- Default file name when prompted to download, send as utf which modern browsers will honor and older ones will fallback to the filename witbout utf value which is also passed in --->
			<cfheader name="content-disposition" value="attachment; filename=""#filenamefordownload_clean#""; filename*=UTF-8''#filenamefordownload#" />
			<!--- Set the MIME content encoding header and send the contents of as the page output. --->
			<cfcontent type="application/force-download" file="#attributes.thepath#/outgoing/#qry_binary.thefilename#" deletefile="false">
		<cfelse>
			<!--- Different file location for assets stored on lan --->
			<cfif qry_binary.qfile.link_kind EQ "lan">
				<!--- Default file name when prompted to download, send as utf which modern browsers will honor and older ones will fallback to the filename witbout utf value which is also passed in --->
				<cfheader name="content-disposition" value="attachment; filename=""#filenamefordownload_clean#""; filename*=UTF-8''#filenamefordownload#" />
				<cfset thefileloc = "#replace(qry_binary.qfile.link_path_url,"\ "," ","ALL")#">
				<!--- Serve the file --->
				<cfcontent type="application/force-download" file="#thefileloc#" deletefile="false">
			<cfelse>
				<cfif qry_binary.theurl NEQ ''>
					<!--- Default file name when prompted to download, send as utf which modern browsers will honor and older ones will fallback to the filename witbout utf value which is also passed in --->
					<cfheader name="content-disposition" value="attachment; filename=""#filenamefordownload_clean#""; filename*=UTF-8''#filenamefordownload#" />
					<!--- Struct for remote --->
					<!--- <cfset remote = structnew()>
					<cfset remote.type = "http">
					<cfset remote.url = qry_binary.theurl>
					<cfdump var="#remote#"> --->
					<!--- Get file --->
					<cfhttp url="#qry_binary.theurl#" getasbinary="yes" />
					<!--- Serve the file --->
					<cfcontent type="application/force-download" variable="#cfhttp.FileContent#">
					<!--- <cfabort> --->
					<!--- Serve file --->
					<!--- <cfcontent remote="#remote#" /> --->
				<cfelse>
					<h1>Something's wrong. We could not fetch the file for you!</h1>
					<h2>We received the following variables:</h2>
					<cfdump var="#qry_binary#">
				</cfif>
			</cfif>
		</cfif>
	</cfif>
</cfif>