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
<cfif isdefined("qry_detail.expiry_date_actual") AND isdate(qry_detail.expiry_date_actual) AND qry_detail.expiry_date_actual lt now()>
	Asset has expired. Please contact administrator to gain access to this asset.<cfabort>
</cfif>

<cfset thestorage = "#attributes.assetpath#/#session.hostid#/">
<cfif cgi.context_path EQ "">
	<cfset thestorageurl = "//#cgi.http_host#/assets/#session.hostid#/">
<cfelse>
	<cfset thestorageurl = "//#cgi.http_host#/#cgi.context_path#/assets/#session.hostid#/">
</cfif>
<!--- Decide on extensions --->
<cfif attributes.v EQ "o">
	<cfset theext = qry_detail.img_extension>
	<cfset thew = qry_detail.img_width>
	<cfset theh = qry_detail.img_height>
<cfelse>
	<cfset theext = qry_detail.thumb_extension>
	<cfset thew = qry_detail.thumb_width>
	<cfset theh = qry_detail.thumb_height>
</cfif>
<cfoutput>
	<!--- Serve directly for PSD, AI and EPS --->
	<cfswitch expression="#theext#">
		<cfcase value="jpg,gif,png">
			<!DOCTYPE html>
			<html><head><title></title></head>
			<body>
				<div style="padding-top:20px;">
					<cfif attributes.v EQ "o">
						<!--- Amazon / Nirvanix --->
						<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
							<img src="#qry_detail.cloud_url_org#" border="0">
						<!--- Akamai --->
						<cfelseif application.razuna.storage EQ "akamai">
							<img src="#attributes.akaurl##attributes.akaimg#/#qry_detail.img_filename_org#?#qry_detail.hashtag#" border="0">
						<cfelse>
							<img src="#thestorageurl##qry_detail.path_to_asset#/#qry_detail.img_filename_org#?#qry_detail.hashtag#" border="0">
						</cfif>
					<cfelse>	
						<!--- Thumbnail --->
						<cfif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
							<img src="#qry_detail.cloud_url#" border="0">
						<cfelse>
							<img src="#thestorageurl##qry_detail.path_to_asset#/thumb_#attributes.file_id#.#qry_detail.thumb_extension#?#qry_detail.hashtag#" border="0">
						</cfif>
					</cfif>
				</div>
			</body>
			</html>
		</cfcase>
		<cfdefaultcase>
			<!--- Default file name when prompted to download --->
			<cfheader name="content-disposition" value='attachment; filename="#qry_detail.img_filename#"' />
			<!--- Nirvanix--->
			<cfif application.razuna.storage EQ "nirvanix">
				<!--- Get file --->
				<cflocation url="#qry_detail.cloud_url_org#?disposition=attachment">
			<!--- Amazon --->
			<cfelseif application.razuna.storage EQ "amazon">
				<!--- Get file --->
				<cflocation url="#qry_detail.cloud_url_org#">
			<!--- Akamai --->
			<cfelseif application.razuna.storage EQ "akamai">
				<cflocation url="#attributes.akaurl##attributes.akaimg#/#qry_detail.img_filename_org#">
			<!--- Local --->
			<cfelse>
				<cffile action="readbinary" file="#thestorage##qry_detail.path_to_asset#/#qry_detail.img_filename_org#" variable="readb">
				<!--- Serve the file --->
				<cfcontent variable="#readb#">
			</cfif>
		</cfdefaultcase>
	</cfswitch>
</cfoutput>

