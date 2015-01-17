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
    <cftry>
    	<cfset var o = ftpopen(server=session.ftp_server,username=session.ftp_user,password=session.ftp_pass,passive=session.ftp_passive,stoponerror=true)>
    	<cfcatch>
    		<cfset var transvalues = arraynew()>
	    	<cfset transvalues[1] = cfcatch.message>
	    	<cfinvoke component="defaults" method="trans" transid="ftp_error" values = "#transvalues#" returnvariable="ftp_error" />
	    	<cfoutput><font color="##cd5c5c">#ftp_error#</font></cfoutput><cfabort>
    	</cfcatch>
    </cftry>
    
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
        	     <!--- Append '/' to folderpath if nto present as some FTP servers will not return the directory listing properly without it --->
                <cfif left(arguments.thestruct.folderpath,1) NEQ '/'>
                	<cfset arguments.thestruct.folderpath  = '/' & arguments.thestruct.folderpath>
                </cfif>
                <cfset dirlist = ftplist(o,arguments.thestruct.folderpath,session.ftp_passive)>
            	<cfcatch type="any">
            		<cfparam name="folder_id" default="0" />
            		<cfinvoke component="defaults" method="trans" transid="ftp_read_error" returnvariable="ftp_read_error" />
            		<cfoutput>
            		<span style="color:red;font-weight:bold;">#ftp_read_error#</span>
            		<br />
        			<br />
        			<cfset l = listlast(arguments.thestruct.folderpath,"/")>
        			<cfset p = replacenocase(arguments.thestruct.folderpath,"/#l#","","one")>
        			<cfinvoke component="defaults" method="trans" transid="ftp_back_dir" returnvariable="ftp_back_dir" />
            		<a href="##" onclick="loadcontent('addftp','index.cfm?fa=c.asset_add_ftp_reload&folderpath=#URLEncodedFormat(p)#&folder_id=#folder_id#');">#ftp_back_dir#</a>
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
        <cfif isdefined("arguments.thestruct.filesonly") AND arguments.thestruct.filesonly>
        	WHERE isdirectory = 'NO'
        </cfif>
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
        <cfset var o = ftpopen(server=session.ftp_server,username=session.ftp_user,password=session.ftp_pass,passive=session.ftp_passive,stoponerror=false, timeout=3000)>
		<cfif structKeyExists(session,"createzip") AND session.createzip EQ 'no'>
			<!--- Get the directories --->
			<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#" name="myDir" type="dir">
			<cfif myDir.RecordCount>
				<cfloop query="myDir">
					<!--- Get the files --->
					<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#myDir.name#" name="myFile" type="file">
						<cfif !Ftpexistsfile(ftpdata=o, file="#arguments.thestruct.folderpath#/#myFile.name#", passive=session.ftp_passive, stoponerror=false)>
							<!--- Put the file on the FTP Site --->
							<cfset Ftpputfile(ftpdata=o, remotefile="#arguments.thestruct.folderpath#/#myFile.name#", localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#myDir.name#/#myFile.name#", passive=session.ftp_passive)>
						<cfelse>
							<cfset listftp = Ftplist(ftpdata=o, directory="#arguments.thestruct.folderpath#")>
							<cfquery name="q" dbtype="query" >
								SELECT * FROM listftp
								WHERE name LIKE '#listfirst(myFile.name,'.')#%' 
								AND name LIKE '%#listlast(myFile.name,'.')#%'
							</cfquery>
							<!--- set new name --->
							<cfset new_name = #listFirst(myFile.name,'.')#&"("&#q.RecordCount#+1&")"&"."&#listLast(myFile.name,'.')#>
							<cffile action="rename" destination="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#myDir.name#/#new_name#" source="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#myDir.name#/#myFile.name#">
							<!--- Put the file on the FTP Site --->
							<cfset Ftpputfile(ftpdata=o, remotefile="#arguments.thestruct.folderpath#/#new_name#", localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#myDir.name#/#new_name#", passive=session.ftp_passive)>
						</cfif>
				</cfloop>
				<!--- Delete the folder in the outgoing folder --->
				<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#" recurse="true">
			<cfelse>
				<!--- Get the files --->
				<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#" name="myFile" type="file">
				<cfif !Ftpexistsfile(ftpdata=o ,file="#arguments.thestruct.folderpath#/#myFile.name#", passive=session.ftp_passive, stoponerror=false)>
					<cfset Ftpputfile(ftpdata=o, remotefile="#arguments.thestruct.folderpath#/#myFile.name#", localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#myFile.name#", passive=session.ftp_passive)>
				<cfelse>
					<cfset listftp = Ftplist(ftpdata=o, directory="#arguments.thestruct.folderpath#")>
					<cfquery name="q" dbtype="query" >
						SELECT * FROM listftp
						WHERE name LIKE '#listfirst(myFile.name,'.')#%' 
						AND name LIKE '%#listlast(myFile.name,'.')#%'
					</cfquery>
					<!--- set new name --->
					<cfset new_name = #listFirst(myFile.name,'.')#&"("&#q.RecordCount#+1&")"&"."&#listLast(myFile.name,'.')#>
					<cffile action="rename" destination="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#new_name#" source="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#myFile.name#" >
					<cfset Ftpputfile(ftpdata=o, remotefile="#arguments.thestruct.folderpath#/#new_name#", localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#/#new_name#", passive=session.ftp_passive)>
				</cfif>	
				<!--- Delete the folder in the outgoing folder --->
				<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#" recurse="true">
			</cfif>
		<cfelse>
			<cfif !Ftpexistsfile(ftpdata=o ,file="#arguments.thestruct.folderpath#/#arguments.thestruct.thefile#", passive=session.ftp_passive, stoponerror=true)>
				<!--- Put the file on the FTP Site --->
				<cfset Ftpputfile(ftpdata=o, remotefile="#arguments.thestruct.folderpath#/#arguments.thestruct.thefile#", localfile="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#", passive=session.ftp_passive)>
				<!--- Delete the file in the outgoing folder --->
				<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#">
			<cfelse>
				<cfset listftp = Ftplist(ftpdata=o, directory="#arguments.thestruct.folderpath#")>
				<cfquery name="q" dbtype="query" >
					SELECT * FROM listftp
					WHERE name LIKE '#listfirst(arguments.thestruct.thefile,'.')#%' 
					AND name LIKE '%#listlast(arguments.thestruct.thefile,'.')#%'
				</cfquery>
				<!--- set new name --->
				<cfset new_name = #listFirst(arguments.thestruct.thefile,'.')#&"("&#q.RecordCount#+1&")"&"."&#listLast(arguments.thestruct.thefile,'.')#>
				<cffile action="rename" destination="#arguments.thestruct.thepath#/outgoing/#new_name#" source="#arguments.thestruct.thepath#/outgoing/#arguments.thestruct.thefile#" >
				<!--- Put the file on the FTP Site --->
				<cfset Ftpputfile(ftpdata=o, remotefile="#arguments.thestruct.folderpath#/#new_name#", localfile="#arguments.thestruct.thepath#/outgoing/#new_name#", passive=session.ftp_passive)>
				<!--- Delete the file in the outgoing folder --->
				<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#new_name#">
			</cfif>	
		</cfif>
		<!--- Close FTP --->
		<cfset ftpclose(o)>
		<cfoutput>success</cfoutput>
		<cfcatch type="any">
            <cfoutput>#cfcatch.Detail#</cfoutput>
        </cfcatch>
	</cftry>
</cffunction>

</cfcomponent>
