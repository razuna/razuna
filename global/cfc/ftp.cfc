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
    <cfset var fc = "f" & randrange(1,100000000)>
    <!--- Open Connection to FTP Server --->
    <cfftp connection="#fc#" server="#session.ftp_server#" username="#session.ftp_user#" password="#session.ftp_pass#" action="Open" stoponerror="no" timeout="20" retrycount="1">
    <!--- Set the response form the connection into scope --->
    <cfset qry.ftp = cfftp>
    <!--- Try to connect to the FTP server --->
    <cfif cfftp.succeeded>                
        <cfif NOT structkeyexists(arguments.thestruct,"folderpath")>
                <!--- Get the current directory name --->
                <cfftp connection="#fc#" action="GetCurrentDir" stoponerror="no" timeout="30">
                <cfset thedirname="#cfftp.returnvalue#">
                <cfset wodirname="#thedirname#">
                <!--- Get a listing of the directory --->
                <cfftp connection="#fc#" action="listdir" directory="#thedirname#/" name="dirlist" stoponerror="no" timeout="20">
        <cfelse>
        	<cftry>
                <cfftp connection="#fc#" action="listdir" directory="#arguments.thestruct.folderpath#/" name="dirlist" stoponerror="yes" timeout="30">
            	<cfcatch type="any">
            		<cfoutput>
            		<span style="color:red;font-weight:bold;">Sorry, but somehow we can't read this directory!</span>
            		<br />
        			<br />
        			<cfset l = listlast(arguments.thestruct.folderpath,"/")>
        			<cfset p = replacenocase(arguments.thestruct.folderpath,"/#l#","","one")>
            		<a href="##" onclick="loadcontent('addftp','index.cfm?fa=c.asset_add_ftp_reload&folderpath=#URLEncodedFormat(p)#&folder_id=#folder_id#');">Take me back to the last directory</a>
            		</cfoutput>
            		<cfabort>
            	</cfcatch>
            </cftry>
                <!--- <cfdump var="#dirlist#"><cfabort> --->
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
    </cfif>
    <!--- Close FTP --->
    <cfftp connection="#fc#" action="close" />
	<!--- Return --->
    <cfreturn qry>
</cffunction>

<!--- PUT THE FILE ON THE FTP SITE --------------------------------------------------------------->
<cffunction hint="PUT THE FILE ON THE FTP SITE" name="putfile" output="true">
	<cfargument name="thestruct" type="struct">
		<cftry>
			<cfset var fc = "f" & randrange(1,100000000)>
			<!--- Open ftp connection --->
			<cfftp connection="#fc#" server="#session.ftp_server#" username="#session.ftp_user#" password="#session.ftp_pass#" action="Open" stoponerror="no">
			<!--- Put the file on the FTP Site --->
			<cfftp connection="#fc#" action="putfile" server="#session.ftp_server#" passive="#session.ftp_passive#" stoponerror="no" username="#session.ftp_user#" password="#session.ftp_pass#" localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#" remotefile="#arguments.thestruct.folderpath#/#arguments.thestruct.thefile#" transfermode="auto" timeout="3600">
			<!--- Delete the file in the outgoing folder --->
			<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#">
			<!--- Close FTP --->
   			<cfftp connection="#fc#" action="close" />
			<cfoutput>success</cfoutput>
			<cfcatch type="any"><cfoutput>#cfcatch.Detail#</cfoutput></cfcatch>
		</cftry>
</cffunction>

</cfcomponent>
