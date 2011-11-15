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
<cfcomponent extends="extQueryCaching">

<!--- GET FTP DIRECTORY --->
<cffunction name="getdirectory" output="true">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = structnew()>
	<cfset qry.backpath = "">
	<cfset qry.dirname = "">
	<!--- Open Connection to FTP Server --->
	<cfftp connection="Myftp" server="#session.ftp_server#" username="#session.ftp_user#" password="#session.ftp_pass#" action="Open" stoponerror="no" timeout="20" retrycount="1">
	<!--- Set the response form the connection into scope --->
	<cfset qry.ftp = cfftp>
	<!--- Try to connect to the FTP server --->
	<cfif cfftp.succeeded>
		<cftry>
			<cfif NOT structkeyexists(arguments.thestruct,"folderpath")>
				<!--- Get the current directory name --->
				<cfftp connection="Myftp" action="GetCurrentDir" stoponerror="yes" timeout="30">
				<cfset thedirname="#cfftp.returnvalue#">
				<cfset wodirname="#thedirname#">
				<!--- Get a listing of the directory --->
				<cfftp connection="myftp" action="listdir" directory="#thedirname#/" name="dirlist" stoponerror="yes" timeout="20">
			<cfelse>
				<cfftp connection="myftp" action="listdir" directory="#arguments.thestruct.folderpath#/" name="dirlist" stoponerror="yes" timeout="30">
				<cfif findoneof(arguments.thestruct.folderpath,"/") EQ 0>
					<cfset qry.backpath = "">
				<cfelse>
					<cfset temp = listlast(arguments.thestruct.folderpath, "/\")>
					<cfset qry.backpath = replacenocase(arguments.thestruct.folderpath, "/#temp#", "", "ALL")>
				</cfif>
				<cfset thedirname="#arguments.thestruct.folderpath#">
			</cfif>			
			<!--- output dirlist results --->
			<cfquery dbtype="query" name="ftplist">
			SELECT *
			FROM dirlist
			ORDER BY isdirectory DESC, name
			</cfquery>
			<cfset qry.dirname = thedirname>
			<cfset qry.ftplist = ftplist>
			<!--- there is an error in the ftp connection thus redirect user and inform him --->
			<cfcatch type="any">
				<cfmail from="server@razuna.com" to="support@razuna.com" subject="ftp error" type="html"><cfdump var="#cfcatch#"></cfmail>
			</cfcatch>
		</cftry>
	</cfif>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- PUT THE FILE ON THE FTP SITE --------------------------------------------------------------->
<cffunction hint="PUT THE FILE ON THE FTP SITE" name="putfile" output="true">
	<cfargument name="thestruct" type="struct">
		<cftry>
			<!--- Open ftp connection --->
			<cfftp connection="myftp" server="#session.ftp_server#" username="#session.ftp_user#" password="#session.ftp_pass#" action="Open" stoponerror="yes">
			<!--- Put the file on the FTP Site --->
			<cfftp connection="myftp" action="putfile" server="#session.ftp_server#" passive="#session.ftp_passive#" stoponerror="yes" username="#session.ftp_user#" password="#session.ftp_pass#" localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#" remotefile="#arguments.thestruct.folderpath#/#arguments.thestruct.thefile#" transfermode="auto" timeout="3600">
			<!--- Delete the file in the outgoing folder --->
			<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#">
			<cfoutput>success</cfoutput>
		<cfcatch type="any"><cfoutput>#cfcatch.Detail#</cfoutput></cfcatch>
		</cftry>
</cffunction>

</cfcomponent>
