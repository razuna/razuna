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
<cfcomponent extends="extQueryCaching" output="false">

	<!--- Account --->
	<cfset this.account = "dropbox">
	
	<!--- Retrieves file and folder metadata --->
	<cffunction name="metadata">
		<cfargument name="path" required="false" default="/">
		<!--- Will Return: (example)
		bytes	692297
		client_mtime	Mon, 05 Dec 2011 10:15:42 +0000
		icon	page_white_picture
		is_dir	NO
		mime_type	image/jpeg
		modified	Thu, 18 Apr 2013 14:41:16 +0000
		path	/2011-12-05_11-04-38_806.jpg
		rev	b3c01f117a1
		revision	2876
		root	dropbox
		size	676.1 KB
		thumb_exists	YES
		 --->
		<!--- Set API vars --->
		<cfset var a = structNew()>
		<cfset structInsert(a, "apiurl", "metadata/dropbox")>
		<cfset structInsert(a, "path", arguments.path)>
		<!--- Call API --->
		<cfset var apicall = apicall(a)>
		<!--- Grab result and convert --->
		<cfset var apiresult = deserializeJSON(apicall.filecontent)>
		<!--- Return --->
		<cfreturn apiresult />
	</cffunction>

	<!--- Retrieves file and folder metadata --->
	<cffunction name="metadata_and_thumbnails">
		<cfargument name="path" required="false" default="/">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Set API vars --->
		<cfset var a = structNew()>
		<cfset structInsert(a, "apiurl", "metadata/dropbox")>
		<cfset structInsert(a, "path", arguments.path)>
		<!--- Call API --->
		<cfset var getcontent = apicall(a)>
		<!--- Grab result and convert --->
		<cfset var apiresult = deserializeJSON(getcontent.filecontent)>
		<!--- Set result into struct for thread --->
		<cfset arguments.apiresult = apiresult>
		<!--- Start downloading of thumbnails in thread --->
		<cfthread intstruct="#arguments#">
			<!--- Set path to store thumbnails --->
			<cfset dbstorage = "#expandpath("../../")#/global/host/dropbox">
			<cfif !directoryExists(dbstorage)>
				<cfdirectory action="create" directory="#dbstorage#" mode="775" />
			</cfif>
			<!--- Set path to store thumbnails --->
			<cfset dbstoragefinal = "#expandpath("../../")#/global/host/dropbox/#arguments.thestruct.razuna.session.hostid#">
			<cfif !directoryExists(dbstoragefinal)>
				<cfdirectory action="create" directory="#dbstoragefinal#" mode="775" />
			</cfif>
			
			<!--- The contents contains the array --->
			<cfloop array="#attributes.intstruct.apiresult.contents#" index="arrcontent">
				<!--- If thumbnail exists we call the API to get the thumbnail --->
				<cfif arrcontent.thumb_exists AND !fileExists("#dbstoragefinal##arrcontent.path#")>
					<cftry>
					<cfhttp url="https://api-content.dropbox.com/1/thumbnails/dropbox" method="get" getasbinary="yes" path="#dbstoragefinal#" file="#listlast(arrcontent.path,"/")#">
						<cfhttpparam type="url" name="path" value="#arrcontent.path#"/>
						<cfhttpparam type="url" name="oauth_version" value="1.0"/>
						<cfhttpparam type="url" name="oauth_signature_method" value="PLAINTEXT"/>
						<cfhttpparam type="url" name="oauth_consumer_key" value="#attributes.intstruct.razuna.session.dropbox.appkey#"/>
						<cfhttpparam type="url" name="oauth_token" value="#attributes.intstruct.razuna.session.dropbox.oauth_token#"/>
						<cfhttpparam type="url" name="oauth_signature" value="#attributes.intstruct.razuna.session.dropbox.appsecret#&#attributes.intstruct.razuna.session.dropbox.oauth_token_secret#"/>
					</cfhttp>
					<cfcatch type="any">
					</cfcatch>
				</cftry>
				</cfif>
			</cfloop>
		</cfthread>
		<!--- Return --->
		<cfreturn apiresult />
	</cffunction>
	
	<!--- Streams file to browser --->
	<cffunction name="media">
		<cfargument name="path" required="false" default="/">
		<cfargument name="download" required="false" default="false" />
		<!--- Set API vars --->
		<cfset var a = structNew()>
		<cfset structInsert(a, "apiurl", "media/dropbox")>
		<cfset structInsert(a, "path", arguments.path)>
		<!--- Call API --->
		<cfset var apicall = apicall(a)>
		<!--- Grab result and convert --->
		<cfset var apiresult = deserializeJSON(apicall.filecontent)>
		<cfif !arguments.download>
			<cflocation url="#apiresult.url#" />
		</cfif>
		<!--- Return --->
		<cfreturn apiresult />
	</cffunction>

	<!--- Download --->
	<cffunction name="downloadfiles" access="public">
		<cfargument name="path" required="true" type="string">
		<cfargument name="thestruct" required="true" type="struct">
		<!--- Call function --->
		<cfthread intstruct="#arguments#">
			<cfinvoke method="downloadfilesthread" path="#attributes.intstruct.path#" thestruct="#attributes.intstruct.thestruct#" />
		</cfthread>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Download --->
	<cffunction name="downloadfilesthread" access="private" returntype="void">
		<cfargument name="path" required="true" type="string">
		<cfargument name="thestruct" required="true" type="struct">
		<!--- Param --->
		<cfset var thefile = "">
		<cfset var td = getTempDirectory()>
		<!--- Check if dropbox dir is there --->
		<cfif !directoryExists("#td#dropbox")>
			<cfdirectory action="create" directory="#td#dropbox" mode="775" />
		</cfif>
		<!--- Loop over path list --->
		<cfloop list="#arguments.path#" index="f" delimiters=",">
			<!--- Call API --->
			<cfinvoke method="media" path="#f#" download="true" returnvariable="media_result" thestruct="#arguments.thestruct#" />
			<!--- Now download file --->
			<cftry>
				<cfhttp url="#media_result.url#" method="get" getasbinary="yes" path="#td#dropbox" file="#listlast(f,"/")#" />
				<!--- Set the filename. We need this is the asset function for the server add --->
				<cfset arguments.thestruct.thefile = listlast(f,"/")>
				<!--- Call internal function to add the file --->
				<cfinvoke component="assets" method="addassetserver" thestruct="#arguments.thestruct#" />
				<cfcatch type="any">
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Call API --->
	<cffunction name="apicall" access="private">
		<cfargument name="apistruct" type="struct" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Get stored tokens --->
		<cfinvoke component="oauth" method="getstoredtokens" account="#this.account#" thestruct="#arguments.thestruct#" />
		<!--- API Call --->
		<cfhttp url="#arguments.thestruct.razuna.application.dropbox.url_api#/#arguments.apistruct.apiurl#">
			<cfloop collection="#arguments.apistruct#" item="i">
				<cfif i NEQ "apiurl">
					<cfhttpparam type="url" name="#i#" value="#arguments.apistruct[i]#" />
				</cfif>
			</cfloop>
			<cfhttpparam type="url" name="oauth_version" value="1.0"/>
			<cfhttpparam type="url" name="oauth_signature_method" value="PLAINTEXT"/>
			<cfhttpparam type="url" name="oauth_consumer_key" value="#arguments.thestruct.razuna.session.dropbox.appkey#"/>
			<cfhttpparam type="url" name="oauth_token" value="#arguments.thestruct.razuna.session.dropbox.oauth_token#"/>
			<cfhttpparam type="url" name="oauth_signature" value="#arguments.thestruct.razuna.session.dropbox.appsecret#&#arguments.thestruct.razuna.session.dropbox.oauth_token_secret#"/>
		</cfhttp>
		<!--- Return --->
		<cfreturn cfhttp>
	</cffunction>

</cfcomponent>