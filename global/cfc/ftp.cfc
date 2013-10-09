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
    <cfset var o = ftpopen(server=session.ftp_server,username=session.ftp_user,password=session.ftp_pass,passive=session.ftp_passive,stoponerror=false)>
    <!--- Set the response form the connection into scope --->
    <cfset qry.ftp = o>
    <!--- Try to connect to the FTP server --->
    <cfif o.succeeded>    
        <cfif NOT structkeyexists(arguments.thestruct,"folderpath")>
            <!--- Get the current directory name --->
            <cfset thedirname = ftpgetcurrentdir(o)>
            <!--- Get a listing of the directory --->
            <cfset dirlist = ftplist(o,thedirname,session.ftp_passive)>
        <cfelse>
        	<cftry>
                <cfset dirlist = ftplist(o,arguments.thestruct.folderpath,session.ftp_passive)>
            	<cfcatch type="any">
            		<cfparam name="folder_id" default="0" />
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
    <cfset ftpclose(o)>
	<!--- Return --->
    <cfreturn qry>
</cffunction>

<!--- PUT THE FILE ON THE FTP SITE --------------------------------------------------------------->
<cffunction hint="PUT THE FILE ON THE FTP SITE" name="putfile" output="true">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<!--- Open ftp connection --->
        <cfset var o = ftpopen(server=session.ftp_server,username=session.ftp_user,password=session.ftp_pass,passive=session.ftp_passive)>
		<!--- Put the file on the FTP Site --->
        <cfset Ftpputfile(ftpdata=o, remotefile="#arguments.thestruct.folderpath#/#arguments.thestruct.thefile#", localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#", passive=session.ftp_passive)>
		<!--- Delete the file in the outgoing folder --->
		<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#">
		<!--- Close FTP --->
		<cfset ftpclose(o)>
		<cfoutput>success</cfoutput>
		<cfcatch type="any">
            <cfoutput>#cfcatch.Detail#</cfoutput>
        </cfcatch>
	</cftry>
</cffunction>

</cfcomponent>
