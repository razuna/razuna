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
<cfcomponent output="false" extends="extQueryCaching">
 
<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("general")>

<!--- UPLOAD TEMP --->
<cffunction name="upload" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.file_id" default="0">
	<!--- Change tempid a bit --->
	<cfset arguments.thestruct.tempid = replace(arguments.thestruct.tempid,"-","","ALL")>
	<!--- Create a unique name for the temp directory to hold the file --->
	<cfset arguments.thestruct.thetempfolder   = "asset#arguments.thestruct.tempid#">
	<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
	<!--- Create a temp directory to hold the file --->
	<cfif !DirectoryExists(arguments.thestruct.theincomingtemppath)>
		<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
	</cfif>
	<!--- Upload file --->
	<cffile action="upload" destination="#arguments.thestruct.theincomingtemppath#" nameconflict="overwrite" filefield="#arguments.thestruct.thefieldname#" result="thefile">
	<cfset arguments.thestruct.thefile.serverFileExt = "#lcase(thefile.serverFileExt)#">
	<cfset arguments.thestruct.thefile = thefile>
	<cfset arguments.thestruct.dsn = variables.dsn>
	<cfset arguments.thestruct.hostid = session.hostid>
	<!--- If the extension is longer then 9 chars --->
	<cfif len(arguments.thestruct.thefile.serverFileExt) GT 9>
		<cfset arguments.thestruct.thefile.serverFileExt = "txt">
	</cfif>
	<!--- Put the rest into a thread --->
	<cfthread intstruct="#arguments.thestruct#" priority="HIGH">
		<cfset md5hash = "">
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global" method="convertname" returnvariable="thefilename" thename="#attributes.intstruct.thefile.serverFile#">
		<cfinvoke component="global" method="convertname" returnvariable="thefilenamenoext" thename="#attributes.intstruct.thefile.serverFileName#">
		<cffile action="rename" source="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.thefile.serverFile#" destination="#attributes.intstruct.theincomingtemppath#/#thefilename#">
		<!--- MD5 Hash --->
		<cfif FileExists("#attributes.intstruct.theincomingtemppath#/#thefilename#")>
			<cfset md5hash = hashbinary("#attributes.intstruct.theincomingtemppath#/#thefilename#")>
		</cfif>
		<!--- Check if we have to check for md5 records --->
		<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
		<!--- Check for the same MD5 hash in the existing records --->
		<cfif checkformd5>
			<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
		<cfelse>
			<cfset md5here = 0>
		</cfif>
		<!--- If file does not exsist continue else send user an eMail --->
		<cfif md5here EQ 0>
			<!--- Add to temp db --->
			<cfquery datasource="#attributes.intstruct.dsn#" name="qry">
			INSERT INTO #session.hostdbprefix#assets_temp
			(tempid,filename,extension,date_add,folder_id,who,filenamenoext,path<!--- ,mimetype --->,thesize,file_id,host_id,md5hash)
			VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.tempid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilename#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(attributes.intstruct.thefile.serverFileExt)#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#attributes.intstruct.folder_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#attributes.intstruct.user_id#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilenamenoext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.theincomingtemppath#">,
			<!--- <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.intstruct.thefile.contentType#/#attributes.intstruct.thefile.contentSubType#">, --->
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.intstruct.thefile.filesize#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#attributes.intstruct.file_id#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.intstruct.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#md5hash#">
			)
			</cfquery>
		<cfelse>
			<cfinvoke component="email" method="send_email" subject="Razuna: File #thefilename# already exists" themessage="Hi there. The file (#thefilename#) already exists in Razuna and thus was not added to the system!">
		</cfif>
	</cfthread>
	<cfset result = "T">
	<!--- Return --->
	<cfreturn result>
</cffunction>

<!--- INSERT FROM SERVER as thread --->
<cffunction name="addassetserver" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Thread --->
	<cfthread intstruct="#arguments.thestruct#" priority="HIGH">
		<cfinvoke method="addassetserverthread" thestruct="#attributes.intstruct#" />
	</cfthread>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM SERVER --->
<cffunction name="addassetserverthread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Add each file to the temp db, create temp dir and so on --->
	<cfloop list="#arguments.thestruct.thefile#" index="i" delimiters=",">
		<cfset md5hash = "">
		<!--- If we are coming from a scheduled task then... --->
		<cfif structkeyexists(arguments.thestruct,"sched")>
			<cfset x = i>
			<!--- Get the filename --->
			<cfset i = listlast(i, "/")>
			<!--- Get the folderpath --->
			<cfset arguments.thestruct.folderpath = replacenocase(x, "/#i#", "", "ALL")>
		</cfif>
		<!--- Create a unique name for the temp directory to hold the file --->
		<cfset arguments.thestruct.tempid = createuuid("")>
		<cfset arguments.thestruct.thetempfolder = "asset#arguments.thestruct.tempid#">
		<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
		<!--- Create a temp directory to hold the file --->
		<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
		<!--- Copy the file into the temp dir --->
		<cffile action="copy" source="#arguments.thestruct.folderpath#/#i#" destination="#arguments.thestruct.theincomingtemppath#/#i#" mode="775">
		<!--- Get file extension --->
		<cfset theextension = listlast("#i#",".")>
		<!--- If the extension is longer then 9 chars --->
		<cfif len(theextension) GT 9>
			<cfset theextension = "txt">
		</cfif>
		<cfset namenoext = replacenocase("#i#",".#theextension#","","All")>
		<!--- Store the original filename --->
		<cfset arguments.thestruct.thefilenameoriginal = i>
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#i#">
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#namenoext#">
		<!--- Do the rename action on the file --->
		<cffile action="rename" source="#arguments.thestruct.theincomingtemppath#/#i#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
		<!--- Get the filesize --->
		<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" returnvariable="orgsize">
		<!--- MD5 Hash --->
		<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
			<cfset md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
		</cfif>
		<!--- Check if we have to check for md5 records --->
		<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
		<!--- Check for the same MD5 hash in the existing records --->
		<cfif checkformd5>
			<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
		<cfelse>
			<cfset var md5here = 0>
		</cfif>
		<!--- If file does not exsist continue else send user an eMail --->
		<cfif md5here EQ 0>
			<!--- Add to temp db --->
			<cfquery datasource="#variables.dsn#">
			INSERT INTO #session.hostdbprefix#assets_temp
			(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path<cfif structkeyexists(arguments.thestruct,"sched")>, sched_id, sched_action</cfif>, file_id, host_id, thesize, md5hash)
			VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#namenoext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">
			<cfif structkeyexists(arguments.thestruct,"sched")>
				,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.sched_id#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.sched_action#">
			</cfif>
			,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#orgsize#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
			)
			</cfquery>
			<!--- We don't need to send an email --->
			<cfset arguments.thestruct.sendemail = false>
			<!--- Call the addasset function --->
			<cfthread intstruct="#arguments.thestruct#" priority="LOW">
				<cfinvoke method="addasset" thestruct="#attributes.intstruct#">
			</cfthread>
		<cfelse>
			<cfinvoke component="email" method="send_email" subject="Razuna: File #arguments.thestruct.thefilename# already exists" themessage="Hi there. The file (#arguments.thestruct.thefilename#) already exists in Razuna and thus was not added to the system!">
		</cfif>
	</cfloop>
</cffunction>

<!--- INSERT FROM EMAIL --->
<cffunction name="addassetemail" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Add each file to the temp db, create temp dir and so on --->
	<cfloop list="#arguments.thestruct.emailid#" index="i">
		<!--- Retrieve the message --->
		<cfpop action="getall" server="#session.email_server#" username="#session.email_address#" password="#session.email_pass#" name="qrymessage" messagenumber="#i#" attachmentpath="#arguments.thestruct.thepath#/incoming/emails" generateuniquefilenames="no" timeout="3600">
		<cfoutput query="qrymessage">
			<!--- Check that there is an attachment. If so loop over it --->
			<cfset numattachments = listlen(attachments)>
			<!--- If the number of attachments is greater then 0 continue --->
			<cfif numattachments GT 0>
				<!--- Loop over the attachments and get one by one --->
				<cfloop list="#attachmentfiles#" delimiters="," index="at">
					<!--- Sometimes attachments contain unwanted file --->
					<cfif NOT at CONTAINS "smime">
						<cfset md5hash = "">
						<!--- Set names --->
						<cfset arguments.thestruct.thefilename = listlast(#at#, "/\")>
						<cfset theextension = listlast("#arguments.thestruct.thefilename#",".")>
						<cfset arguments.thestruct.thefilenamenoext = replacenocase("#arguments.thestruct.thefilename#",".#theextension#","","All")>
						<!--- If the extension is longer then 9 chars --->
						<cfif len(theextension) GT 9>
							<cfset theextension = "txt">
						</cfif>
						<!--- Create a unique name for the temp directory to hold the file --->
						<cfset arguments.thestruct.tempid = createuuid("")>
						<cfset arguments.thestruct.thetempfolder = "asset#arguments.thestruct.tempid#">
						<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
						<!--- Create a temp directory to hold the file --->
						<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
						<!--- Copy the file into the temp dir --->
						<cffile action="copy" source="#arguments.thestruct.thepath#/incoming/emails/#arguments.thestruct.thefilename#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" mode="775">
						<!--- Get the filesize --->
						<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" returnvariable="orgsize">
						<!--- MD5 Hash --->
						<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
							<cfset md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
						</cfif>
						<!--- Check if we have to check for md5 records --->
						<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
						<!--- Check for the same MD5 hash in the existing records --->
						<cfif checkformd5>
							<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
						<cfelse>
							<cfset var md5here = 0>
						</cfif>
						<!--- If file does not exsist continue else send user an eMail --->
						<cfif md5here EQ 0>
							<!--- Add to temp db --->
							<cfquery datasource="#variables.dsn#">
							INSERT INTO #session.hostdbprefix#assets_temp
							(TEMPID,FILENAME,EXTENSION,DATE_ADD,FOLDER_ID,WHO,FILENAMENOEXT,PATH,file_id,host_id,thesize,md5hash)
							VALUES(
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
							<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#orgsize#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
							)
							</cfquery>
							<!--- We don't need to send an email --->
							<cfset arguments.thestruct.sendemail = false>
							<!--- Call the addasset function --->
							<cfthread intstruct="#arguments.thestruct#" priority="LOW">
								<cfinvoke method="addasset" thestruct="#attributes.intstruct#">
							</cfthread>
						<cfelse>
							<cfinvoke component="email" method="send_email" subject="Razuna: File #arguments.thestruct.thefilename# already exists" themessage="Hi there. The file (#arguments.thestruct.thefilename#) already exists in Razuna and thus was not added to the system!">
						</cfif>
					</cfif>
					<!--- Remove the attachment from the email folder. This is on purpose outside of the if so that we remove unwanted attachments as well --->
					<cftry>
						<cffile action="delete" file="#arguments.thestruct.thepath#/incoming/emails/#arguments.thestruct.thefilename#">
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfloop>
			</cfif>
		</cfoutput>
	</cfloop>
</cffunction>

<!--- INSERT FROM FTP IN THREAD --->
<cffunction name="addassetftpthread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Add to arguments --->
	<cfset arguments.thestruct.dsn = variables.dsn>
	<cfset arguments.thestruct.ftp_server = session.ftp_server>
	<cfset arguments.thestruct.ftp_passive = session.ftp_passive>
	<cfset arguments.thestruct.ftp_user = session.ftp_user>
	<cfset arguments.thestruct.ftp_pass = session.ftp_pass>
	<!--- <cfinvoke method="addassetftp" thestruct="#arguments.thestruct#" /> --->
	<!--- Start the thread for adding --->
	<cfthread intstruct="#arguments.thestruct#" priority="HIGH">
		<cfinvoke method="addassetftp" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- INSERT FROM FTP --->
<cffunction name="addassetftp" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Add each file to the temp db, create temp dir and so on --->
	<cfloop list="#arguments.thestruct.thefile#" index="i">
		<cftry>
			<cfset md5hash = "">
			<!--- Create a unique name for the temp directory to hold the file --->
			<cfset arguments.thestruct.tempid = createuuid("")>
			<cfset arguments.thestruct.thetempfolder = "ftp#arguments.thestruct.tempid#">
			<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
			<!--- Create a temp directory to hold the file --->
			<cfif !directoryExists(arguments.thestruct.theincomingtemppath)>
				<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
			</cfif>
			<!--- Get file extension --->
			<cfset theextension = listlast("#i#",".")>
			<cfset namenoext = replacenocase("#i#",".#theextension#","","All")>
			<!--- If the extension is longer then 9 chars --->
			<cfif len(theextension) GT 9>
				<cfset theextension = "txt">
			</cfif>
			<!--- Rename the file so that we can remove any spaces --->
			<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#i#">
			<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#namenoext#">
			<!--- Get the file from FTP --->
			
			<!--- If we are coming from a scheduled task then... --->
			<cfif structkeyexists(arguments.thestruct,"sched")>
				<cfset remote_file = arguments.thestruct.folderpath & "/" & i>
			<cfelse>
				<cfset remote_file = arguments.thestruct.folderpath & "/" & i>
			</cfif>
			<!--- Get file from FTP --->
			<cfset arguments.thestruct.remote_file = remote_file>
			<!--- Create uuid --->
			<cfset tt = createUUID("")>
			<cfthread name="#tt#" intstruct="#arguments.thestruct#">
				<cfset fc = "f" & randrange(1,10000000)>
				<!--- Get the file --->
				<cfftp action="getfile" connection="#fc#" server="#attributes.intstruct.ftp_server#" passive="#attributes.intstruct.ftp_passive#" stoponerror="no" username="#attributes.intstruct.ftp_user#" password="#attributes.intstruct.ftp_pass#" localfile="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.thefilename#" remotefile="#attributes.intstruct.remote_file#" transfermode="AUTO" failifexists="no" timeout="3600" />
				<!--- Close connection --->
				<cfftp action="close" connection="#fc#" />
			</cfthread>
			<!--- Wait for the download above to finish --->
			<cfthread action="join" name="#tt#" />
			<!--- Get the filesize --->
			<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" returnvariable="orgsize">
			<!--- MD5 Hash --->
			<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
				<cfset md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
			</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- Check for the same MD5 hash in the existing records --->
			<cfif checkformd5>
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
			<cfelse>
				<cfset var md5here = 0>
			</cfif>
			<!--- If file does not exsist continue else send user an eMail --->
			<cfif md5here EQ 0>
				<!--- Add to temp db --->
				<cfquery datasource="#variables.dsn#">
				INSERT INTO #session.hostdbprefix#assets_temp
				(TEMPID,FILENAME,EXTENSION,DATE_ADD,FOLDER_ID,WHO,FILENAMENOEXT,PATH,file_id,host_id,thesize,md5hash)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#orgsize#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
				)
				</cfquery>
				<!--- We don't need to send an email --->
				<cfset arguments.thestruct.sendemail = false>
				<!--- Call the addasset function --->
				<cfthread intstruct="#arguments.thestruct#" priority="LOW">
					<cfinvoke method="addasset" thestruct="#attributes.intstruct#">
				</cfthread>
			<cfelse>
				<cfinvoke component="email" method="send_email" subject="Razuna: File #arguments.thestruct.thefilename# already exists" themessage="Hi there. The file (#arguments.thestruct.thefilename#) already exists in Razuna and thus was not added to the system!">
			</cfif>
			<cfcatch type="any">
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="debug" dump="#cfcatch#">
			</cfcatch>
		</cftry>
	</cfloop>
</cffunction>

<!--- INSERT FROM API --->
<cffunction name="addassetapi" output="false" access="public" returntype="string">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam name="arguments.thestruct.debug" default="0">
	<cfparam name="arguments.thestruct.isbinary" default="false">
	<cfparam name="arguments.thestruct.plupload" default="false">
	<cfparam name="arguments.thestruct.zip_extract" default="1">
	<cfparam name="arguments.thestruct.upl_template" default="0">
	<cfparam name="arguments.thestruct.metadata" default="0">
	<cfparam name="arguments.thestruct.av" default="0">
	<cfparam name="arguments.thestruct.dam" default="false">
	<cfset var md5hash = "">
	<!--- If developer wants to debug  --->
	<cfif arguments.thestruct.debug>
		<cfinvoke component="debugme" method="email_dump" emailto="#arguments.thestruct.emailto#" emailfrom="server@razuna.com" emailsubject="debug apiupload" dump="#arguments.thestruct#">
	</cfif>
	<cftry>
		<!--- This is from the uploader in Razuna --->
		<cfif arguments.thestruct.plupload>
			<cfset var thesession = true>
			<cfset var theuserid = session.theuserid>
		<!--- Below is for API uploads --->
		<cfelse>
			<!--- Check if this API is still called with the old method if so, use the old authentication --->
			<cfif structkeyexists(arguments.thestruct,"sessiontoken")>
				<!--- Set application variables. Needed for the checkdb method in API --->
				<cfset application.razuna.api.dsn = variables.dsn>
				<cfset application.razuna.api.prefix[#arguments.thestruct.sessiontoken#] = session.hostdbprefix>
				<cfset application.razuna.api.hostid[#arguments.thestruct.sessiontoken#] = session.hostid>
				<!--- Check sessiontoken --->
				<cfinvoke component="global.api.authentication" method="checkdb" sessiontoken="#arguments.thestruct.sessiontoken#" returnvariable="thesession">
				<!--- Get the user id --->
				<cfquery datasource="#application.razuna.datasource#" name="qryuser">
				SELECT userid
				FROM webservices
				WHERE sessiontoken = <cfqueryparam value="#arguments.thestruct.sessiontoken#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset var theuserid = qryuser.userid>
			<!--- This is the new one with api_key --->
			<cfelse>		
				<cfparam name="thehostid" default="" />
				<!--- Check to see if api key has a hostid --->
				<cfif arguments.thestruct.api_key contains "-">
					<cfset var thehostid = listfirst(arguments.thestruct.api_key,"-")>
					<cfset var theapikey = listlast(arguments.thestruct.api_key,"-")>
				<cfelse>
					<cfset var theapikey = arguments.thestruct.api_key>
				</cfif>
				<!--- Set application variables. Needed for the checkdb method in API --->
				<cfset application.razuna.api.dsn = application.razuna.datasource>
				<cfset application.razuna.api.thedatabase = application.razuna.thedatabase>
				<cfset application.razuna.api.storage = application.razuna.storage>
				<cfset application.razuna.api.prefix[#theapikey#] = session.hostdbprefix>
				<cfset application.razuna.api.hostid[#theapikey#] = session.hostid>
				<cfset application.razuna.api.userid[#theapikey#] = session.theuserid>
				<!--- Query --->
				<cfquery datasource="#application.razuna.datasource#" name="qry">
				SELECT u.user_id, gu.ct_g_u_grp_id grpid, ct.ct_u_h_host_id hostid
				FROM users u, ct_users_hosts ct, ct_groups_users gu
				WHERE user_api_key = <cfqueryparam value="#theapikey#" cfsqltype="cf_sql_varchar"> 
				AND u.user_id = ct.ct_u_h_user_id
				<cfif thehostid NEQ "">
					AND ct.ct_u_h_host_id = <cfqueryparam value="#thehostid#" cfsqltype="cf_sql_numeric">
				</cfif>
				AND gu.ct_g_u_user_id = u.user_id
				AND (
					gu.ct_g_u_grp_id = <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">
					OR
					gu.ct_g_u_grp_id = <cfqueryparam value="2" cfsqltype="CF_SQL_VARCHAR">
				)
				GROUP BY user_id, ct_g_u_grp_id
				</cfquery>
				<cfif qry.recordcount EQ 0>
					<cfset var thesession = false>
				<cfelse>
					<cfset var thesession = true>
					<cfset var theuserid = qry.user_id>
				</cfif>
			</cfif>
		</cfif>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user wants to add metadata fields then collect them here --->
			<cfif arguments.thestruct.metadata EQ 1>
				<!--- Set array --->
				<cfset var metaarray = arraynew(2)>
				<cfset var metacounter = 1>
				<!--- Loop over the metadata fields, they all have a prefix of meta_ --->
				<cfloop collection="#arguments.thestruct#" item="thefield">
					<cfif thefield CONTAINS "meta_">
						<cfset metaarray[#metacounter#][1] = replacenocase(thefield,"meta_","","ONE")>
						<cfset metaarray[#metacounter#][2] = evaluate(thefield)>
						<!--- Increase the array --->
						<cfset metacounter = metacounter + 1>
					</cfif>
				</cfloop>
				<!--- Serialize it to JSON and put it into struct --->
				<cfset arguments.thestruct.assetmetadata = SerializeJSON(metaarray)>
			</cfif>
			<cfset arguments.thestruct.tempid = createuuid("")>
			<!--- Create a unique name for the temp directory to hold the file --->
			<cfset arguments.thestruct.thetempfolder = "api#arguments.thestruct.tempid#">
			<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
			<!--- Create a temp directory to hold the file --->
			<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
			<!--- If we come from plupload or the value isbinary is true then we look for the binary --->
			<cfif arguments.thestruct.isbinary>
				<!--- Set the file as struct --->
				<cfset thefile = structnew()>
				<!--- Set filename --->
				<cfset thefile.serverFile = arguments.thestruct.name>
				<cfset thefile.serverFileName = arguments.thestruct.name>
				<!--- Extension --->
				<cfset thefile.serverFileExt = lcase(listlast(thefile.serverFile,"."))>
				<!--- If the extension is longer then 9 chars --->
				<cfif len(thefile.serverFileExt) GT 9>
					<cfset thefile.serverFileExt = "txt">
				</cfif>
				<!--- Get Requestdata --->
				<cfset arguments.thestruct.thereqdata = GetHttpRequestData()>
				<!--- Get Content and write content to file --->
				<cfset var tt = arguments.thestruct.tempid>
				<cfthread name="#tt#" intstruct="#arguments.thestruct#">
					<cffile action="write" file="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.name#" output="#attributes.intstruct.thereqdata.content#">
				</cfthread>
				<!--- Join above thread --->
				<cfthread action="join" name="#tt#" />
				<!--- Get Size --->
				<cfset var thefileinfo = getfileinfo("#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#")>
				<cfset thefile.filesize = thefileinfo.size>
				<!--- Set mimetypes --->
				<cfquery dataSource="#variables.dsn#" name="qry_mime">
				SELECT type_mimecontent, type_mimesubcontent
				FROM file_types
				WHERE lower(type_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thefile.serverFileExt#">
				</cfquery>
				<!---
<cfset thefile.contentType = qry_mime.type_mimecontent>
				<cfset thefile.contentSubType = qry_mime.type_mimesubcontent>
--->
			<cfelse>
				<!--- If plupload --->
				<cfif arguments.thestruct.plupload>
					<cfset thefilefield = "file">
				<cfelse>
					<cfset thefilefield = "filedata">
				</cfif>
				<!--- Upload file --->
				<cffile action="upload" destination="#arguments.thestruct.theincomingtemppath#" nameconflict="overwrite" filefield="#thefilefield#" result="thefile">
				<cfset thefile.serverFileExt = "#lcase(thefile.serverFileExt)#">
				<!--- If the extension is longer then 9 chars --->
				<cfif len(thefile.serverFileExt) GT 9>
					<cfset thefile.serverFileExt = "txt">
				</cfif>	
			</cfif>
			<!--- Rename the file so that we can remove any spaces --->
			<cfinvoke component="global.cfc.global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#thefile.serverFile#">
			<cfinvoke component="global.cfc.global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#thefile.serverFileName#">
			<cffile action="rename" source="#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
			<!--- MD5 Hash --->
			<cfif FileExists("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
				<cfset md5hash = hashbinary("#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#")>
			</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- Check for the same MD5 hash in the existing records --->
			<cfif checkformd5>
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
			<cfelse>
				<cfset var md5here = 0>
			</cfif>
			<!--- If file does not exsist continue else send user an eMail --->
			<cfif md5here EQ 0>
				<!--- If we only have the folder_id as variable --->
				<cfif structkeyexists(arguments.thestruct,"folder_id")>
					<cfset arguments.thestruct.destfolderid = arguments.thestruct.folder_id>
				</cfif>
				<!--- Add to temp db --->
				<cftransaction>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #session.hostdbprefix#assets_temp
					(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path<!--- , mimetype --->, thesize, file_id, host_id, md5hash)
					VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefile.serverFileExt#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.destfolderid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theuserid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
					<!--- <cfqueryparam cfsqltype="cf_sql_varchar" value="#thefile.contentType#/#listfirst(thefile.contentSubType,";")#">, --->
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#thefile.filesize#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#md5hash#">
					)
					</cfquery>
				</cftransaction>
				<!--- Put user id into session for later on --->
				<cfset session.theuserid = theuserid>
				<!--- We don't need to send an email --->
				<cfset arguments.thestruct.sendemail = false>
				<!--- Add the original file name in a session since it is stored as lower case in the temp DB --->
				<cfset arguments.thestruct.theoriginalfilename = thefile.serverFile>
				<!--- Call the addasset function --->
				<cfthread intstruct="#arguments.thestruct#" priority="LOW">
					<cfinvoke method="addasset" thestruct="#attributes.intstruct#">
				</cfthread>
				<!--- Get file type so we can return the type --->
				<cfquery datasource="#variables.dsn#" name="fileType">
				SELECT type_type
				FROM file_types
				WHERE lower(type_id) = <cfqueryparam value="#lcase(thefile.serverFileExt)#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- set attributes of file structure --->
				<cfif fileType.recordCount GT 0>
					<cfset thefiletype = fileType.type_type>
				<cfelse>
					<cfset thefiletype = "other">
				</cfif>
				<!--- Return Message --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>success</message>
<assetid>#xmlformat(arguments.thestruct.tempid)#</assetid>
<filetype>#xmlformat(thefiletype)#</filetype>
</Response></cfoutput>
				</cfsavecontent>
				<!--- When the redirect param is here then --->
				<cfif structkeyexists(arguments.thestruct,"redirectto")>
					<!--- If additional params are passed --->
					<cfif structkeyexists(arguments.thestruct,"redirecttoparams")>
						<cfset redirvar = "#arguments.thestruct.redirectto#?responsecode=0&message=success&assetid=#arguments.thestruct.tempid#&filetype=#thefiletype#&#arguments.thestruct.redirecttoparams#">
					<cfelse>
						<cfset redirvar = "#arguments.thestruct.redirectto#?responsecode=0&message=success&assetid=#arguments.thestruct.tempid#&filetype=#thefiletype#">
					</cfif>
					<!--- Redirect --->
					<cflocation url="#redirvar#" addToken="yes">
				</cfif>
			<cfelse>
				<!--- Return Message --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>File already exists in Razuna</message>
<assetid>#xmlformat(arguments.thestruct.thefilename)#</assetid>
</Response></cfoutput>
				</cfsavecontent>
				<!--- Send email with the duplicate asset --->
				<cfinvoke component="email" method="send_email" subject="Razuna: File #arguments.thestruct.thefilename# already exists" themessage="Hi there. The file (#arguments.thestruct.thefilename#) already exists in Razuna and thus was not added to the system!">
			</cfif>
		<!--- No session found --->
		<cfelse>
			<!--- When the redirect param is here then --->
			<cfif structkeyexists(arguments.thestruct,"redirectto")>
				<cflocation url="#arguments.thestruct.redirectto#?responsecode=1&message=nosession" addToken="yes">
			<cfelse>
				<cfinvoke component="global.api.authentication" method="timeout" type="s" returnvariable="thexml">
			</cfif>
		</cfif>
		<!--- Catch --->
		<cfcatch type="any">
			<!--- When the redirect param is here then --->
			<cfif structkeyexists(arguments.thestruct,"redirectto")>
				<cflocation url="#arguments.thestruct.redirectto#?responsecode=1&message=htmleditformat(Upload failed #xmlformat(cfcatch.Detail)# #xmlformat(cfcatch.Message)#)" addToken="yes">
			<cfelse>
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error from API upload" dump="#cfcatch#">
				<!--- Return Message --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
	<Response>
	<responsecode>1</responsecode>
	<message>Upload failed #xmlformat(cfcatch.Detail)# #xmlformat(cfcatch.Message)#</message>
	</Response></cfoutput>
				</cfsavecontent>
			</cfif>
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn thexml />
</cffunction>

<!--- INSERT FROM LINK --->
<cffunction name="addassetlink" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfparam default="" name="arguments.thestruct.link_file_name">
	<!--- If variables do not exist --->
	<cfif NOT structkeyexists(variables,"dsn")>
		<cfset variables.dsn = arguments.thestruct.dsn>
	</cfif>
	<cfif NOT structkeyexists(variables,"setid")>
		<cfset variables.setid = arguments.thestruct.setid>
	</cfif>
	<cfif NOT structkeyexists(variables,"database")>
		<cfset variables.database = arguments.thestruct.database>
	</cfif>
	<cftry>
		<cfset var md5hash = "">
		<!--- Create temp ID --->
		<cfset arguments.thestruct.tempid = createuuid("")>
		<!--- Get the extension of the file --->
		<cfset var thefilename = listlast(arguments.thestruct.link_path_url,"/\")>
		<cfset var theext = listlast(thefilename,".")>
		<cfset var thefilenamenoext = listfirst(thefilename,".")>
		<!--- If the extension is longer then 9 chars --->
		<cfif len(theext) GT 9>
			<cfset theext = "txt">
		</cfif>
		<!--- If the user did not enter a filename we read the filename from the file --->
		<cfif arguments.thestruct.link_file_name NEQ "">
			<cfset thefilename = arguments.thestruct.link_file_name>
		</cfif>
		<!--- Replace any p or br in the textarea --->
		<cfset arguments.thestruct.link_path_url = Replace(arguments.thestruct.link_path_url, "#chr(10)##chr(13)#", "", "ALL")>
		<!--- If this is a video with embeeded player we set extension manually --->
		<cfif arguments.thestruct.link_kind EQ "urlvideo">
			<cfset arguments.thestruct.link_kind = "url">
			<cfset theext = "mov">
		</cfif>
		<!--- If this is a local link --->
		<cfif arguments.thestruct.link_kind EQ "lan">
			<!--- Get size --->
			<cfif NOT structkeyexists(arguments.thestruct,"orgsize")>
				<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.link_path_url#" returnvariable="orgsize">
			<cfelse>
				<cfset orgsize = arguments.thestruct.orgsize>
			</cfif>
			<cfset arguments.thestruct.lanorgname = listlast(arguments.thestruct.link_path_url,"/\")>
			<!--- MD5 Hash --->
			<cfif FileExists("#arguments.thestruct.link_path_url#")>
				<cfset md5hash = hashbinary("#arguments.thestruct.link_path_url#")>
			</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- Check for the same MD5 hash in the existing records --->
			<cfif checkformd5>
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
			<cfelse>
				<cfset var md5here = 0>
			</cfif>
		<!--- If a URL --->
		<cfelse>
			<cfset var orgsize = 0>
			<cfset var md5here = 0>
		</cfif>
		<!--- If file does not exsist continue else send user an eMail --->
		<cfif md5here EQ 0>
			<!--- Add to temp db --->
			<cfquery datasource="#variables.dsn#">
			INSERT INTO #session.hostdbprefix#assets_temp
			(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, mimetype, thesize, file_id, link_kind, host_id, md5hash)
			VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilename#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#theext#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#thefilenamenoext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.link_path_url#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#orgsize#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.link_kind#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
			)
			</cfquery>
			<!--- We don't need to send an email --->
			<cfset arguments.thestruct.sendemail = false>
			<!--- Call the addasset function --->
			<cfthread intstruct="#arguments.thestruct#" priority="LOW">
				<cfinvoke method="addasset" thestruct="#attributes.intstruct#">
			</cfthread>
		<cfelse>
			<cfinvoke component="email" method="send_email" subject="Razuna: File #thefilename# already exists" themessage="Hi there. The file (#thefilename#) already exists in Razuna and thus was not added to the system!">
		</cfif>
		<!--- Catch --->
		<cfcatch type="any">
			<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error from LINK upload" dump="#cfcatch#">
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn />
</cffunction>


<!--- This is the new threaded one --->
<cffunction name="addassetsendmail" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.sendemail" default="true">
	<cfparam name="arguments.thestruct.tempid" default="0">
	<cfset arguments.thestruct.qryfile = 0>
	<!--- Query the file to get filename and other stuff. This qry is also used within adding assets --->
	<cfif arguments.thestruct.tempid NEQ 0>
		<cfquery datasource="#arguments.thestruct.dsn#" name="arguments.thestruct.qryfile">
		SELECT tempid, filename, extension, date_add, folder_id, who, filenamenoext, 
		path, mimetype, thesize, groupid, sched_id, sched_action, file_id, link_kind, md5hash
		FROM #session.hostdbprefix#assets_temp
		WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		ORDER BY extension
		</cfquery>
	</cfif>
	<!--- If we need to send an email --->
	<cfif arguments.thestruct.sendemail>
		<!--- Get the eMail from this user --->
		<cfquery datasource="#arguments.thestruct.dsn#" name="qryuser">
		SELECT user_email
		FROM users
		WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
		</cfquery>
		<!--- Convert the now date to readable format --->
		<cfinvoke component="defaults" method="getdateformat" returnvariable="thedateformat" dsn="#arguments.thestruct.dsn#">
		<!--- The Message --->
		<!--- For adding asset --->
		<cfif arguments.thestruct.emailwhat EQ "start_adding">
			<cfset var thesubject = "Adding asset #arguments.thestruct.qryfile.filename# has started">
			<cfset var mailmessage = "Hello,
	
Razuna has started to add your asset (#arguments.thestruct.qryfile.filename#) on #dateformat(now(),"#thedateformat#")# at #timeformat(now(),"HH:mm:sstt")#.

You will get notified again when the asset is available in the system for you and others.">
		<!--- Finished adding asset --->
		<cfelseif arguments.thestruct.emailwhat EQ "end_adding">
			<cfset var thesubject = "Your asset #arguments.thestruct.thefilename# is now available">
			<cfset var mailmessage = "Hello,
	
Your asset (#arguments.thestruct.thefilename#) is now available in Razuna. We finished adding on #dateformat(now(),"#thedateformat#")# at #timeformat(now(),"HH:mm:sstt")#.">
		<!--- Start Converting --->
		<cfelseif arguments.thestruct.emailwhat EQ "start_converting">
			<cfset var thesubject = "Converting of #arguments.thestruct.emailorgname# has started">
			<cfset var mailmessage = "Hello,
	
Razuna has started converting your asset (#arguments.thestruct.emailorgname#) to the format #ucase(arguments.thestruct.convert_to)# on #dateformat(now(),"#thedateformat#")# at #timeformat(now(),"HH:mm:sstt")#.

You will get notified again when the asset is available in the system for you and others.">
		<!--- End Converting --->
		<cfelseif arguments.thestruct.emailwhat EQ "end_converting">
			<cfset var thesubject = "Converting of #arguments.thestruct.emailorgname# has finished">
			<cfset var mailmessage = "Hello,
	
Razuna has converted your asset (#arguments.thestruct.emailorgname#) to the format #ucase(arguments.thestruct.convert_to)# on #dateformat(now(),"#thedateformat#")# at #timeformat(now(),"HH:mm:sstt")#.">
		</cfif>
		<!--- Send the email --->
		<cftry>
			<cfinvoke component="email" method="send_email" to="#qryuser.user_email#" subject="#thesubject#" themessage="#mailmessage#">
		<cfcatch type="any">
			<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="debug" dump="#cfcatch#">
		</cfcatch>
		</cftry>
	</cfif>
	<!--- Return --->	
	<cfreturn arguments.thestruct.qryfile>
</cffunction>

<!--- This is the new threaded one --->
<cffunction name="addasset" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Call method to send email within that we also query the tempdb and return it here to pass it on --->
	<cfset arguments.thestruct.emailwhat = "start_adding">
	<cfset arguments.thestruct.dsn = variables.dsn>
	<cfset arguments.thestruct.setid = variables.setid>
	<cfset arguments.thestruct.database = variables.database>
	<!--- If tempid exists we make sure it has no - --->
	<cfif structkeyexists(arguments.thestruct,"tempid")>
		<cfset arguments.thestruct.tempid = replace(arguments.thestruct.tempid,"-","","ALL")>
	</cfif>
	<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
	<!--- Thread --->
	<cfif arguments.thestruct.qryfile.tempid NEQ "">
		<cfthread intstruct="#arguments.thestruct#" priority="LOW">
			<cfinvoke method="addassetthread" thestruct="#attributes.intstruct#" />
		</cfthread>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.qryfile.path>
</cffunction>

<!--- 
INSERT INTO DB 
This is the main function called directly by a single upload else from addassetserver, addassetemail, addassetftp indirectly
--->
<cffunction name="addassetthread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Default values --->
	<cfparam default="0" name="arguments.thestruct.zip_extract">
	<cfparam default="" name="arguments.thestruct.fieldname">
	<cfparam default="" name="arguments.thestruct.uploadkind">
	<cfparam default="" name="arguments.thestruct.link_kind">
	<cfparam default="false" name="arguments.thestruct.importpath">
	<cfparam default="0" name="arguments.thestruct.upl_template">
	<cfparam default="0" name="arguments.thestruct.metadata">
	<cfparam default="" name="arguments.thestruct.assetmetadata">
	<cfset arguments.thestruct.theimagepath = "#arguments.thestruct.thepath#/images">
	<!--- If zip_extract is undefined --->
	<cfif arguments.thestruct.zip_extract EQ "" OR arguments.thestruct.zip_extract EQ "undefined">
		<cfset arguments.thestruct.zip_extract = 0>
	</cfif>
	<!--- Query to get the settings --->
	<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qrysettings">
	SELECT set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, set2_img_comp_width,
	set2_img_comp_heigth, set2_vid_preview_author, set2_vid_preview_copyright, set2_path_to_assets
	FROM #session.hostdbprefix#settings_2
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- If we store assets on the file system check if folder id exists in the assets path --->
	<cfif application.razuna.storage EQ "local" AND arguments.thestruct.qryfile.link_kind NEQ "url">
		<cftry>
			<cfdirectory action="list" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#" name="mydir">
			<!--- Dir not found thus create it --->
			<cfcatch type="any">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/img" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/vid" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/doc" mode="775">
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/aud" mode="775">
			</cfcatch>
		</cftry>
	</cfif>
	<!--- check if compressed file (ZIP) --->
	<cfif arguments.thestruct.qryfile.extension EQ "zip" AND arguments.thestruct.zip_extract AND arguments.thestruct.qryfile.link_kind EQ "">
		<cfset var zipnameorg = arguments.thestruct.qryfile.filename>
		<cfinvoke method="extractFromZip" thestruct="#arguments.thestruct#">
		<cfset var returnid = 1>
		<cfset arguments.thestruct.thefile = zipnameorg>
	<cfelse>
		<!--- Get and set file type and MIME content --->
		<cfquery datasource="#variables.dsn#" name="fileType">
		SELECT type_type, type_mimecontent, type_mimesubcontent
		FROM file_types
		WHERE lower(type_id) = <cfqueryparam value="#lcase(arguments.thestruct.qryfile.extension)#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- set attributes of file structure --->
		<cfif fileType.recordCount GT 0>
			<cfset arguments.thestruct.thefiletype = fileType.type_type>
			<!---
<cfset arguments.thestruct.contentType = fileType.type_mimecontent>
			<cfset arguments.thestruct.contentSubType = fileType.type_mimesubcontent>
--->
		<cfelse>
			<cfset arguments.thestruct.thefiletype = "other">
			<!---
<cfset arguments.thestruct.contentType = "">
			<cfset arguments.thestruct.contentSubType = "">
--->
		</cfif>
		<!--- Now start the file mumbo jumbo --->
		<cfif fileType.type_type EQ "img">
			<!--- IMAGE UPLOAD (call method to process a img-file) --->
			<cfinvoke method="processImgFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
			<!--- Act on Upload Templates --->
			<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined">
				<cfset arguments.thestruct.upltemptype = "img">
				<cfset arguments.thestruct.file_id = returnid>
				<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
			</cfif>
		<cfelseif fileType.type_type EQ "vid">
			<!--- VIDEO UPLOAD (call method to process a vid-file) --->
			<cfinvoke method="processVidFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
			<!--- Act on Upload Templates --->
			<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined">
				<cfset arguments.thestruct.upltemptype = "vid">
				<cfset arguments.thestruct.file_id = returnid>
				<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
			</cfif>
		<cfelseif fileType.type_type EQ "aud">
			<!--- AUDIO UPLOAD (call method to process a aud-file) --->
			<cfinvoke method="processAudFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
			<!--- Act on Upload Templates --->
			<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined">
				<cfset arguments.thestruct.upltemptype = "aud">
				<cfset arguments.thestruct.file_id = returnid>
				<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
			</cfif>
		<cfelse>
			<!--- DOCUMENT UPLOAD (call method to process a doc-file) --->
			<cfinvoke method="processDocFile" returnvariable="returnid" thestruct="#arguments.thestruct#">
		</cfif>
	</cfif>
	<!--- Remove record in DB and file system (when we come from converting we call the function in the loop) --->
<!--- 	<cfif NOT structkeyexists(arguments.thestruct,"fromconverting") AND NOT structkeyexists(arguments.thestruct,"sched")> --->
		<cfinvoke method="removeasset" thestruct="#arguments.thestruct#">
<!--- 	</cfif> --->
	<!--- If we are coming from a scheduled task then... --->
	<cfif structkeyexists(arguments.thestruct,"sched")>
		<!--- Log Insert --->
		<cfinvoke component="scheduler" method="tolog" theschedid="#arguments.thestruct.sched_id#" theuserid="#session.theuserid#" theaction="Insert" thedesc="Added file #arguments.thestruct.qryfile.filename#">
		<!---
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#schedules_log
		(sched_log_id, sched_id_r, sched_log_action, sched_log_date, sched_log_time, sched_log_desc,
		sched_log_user, host_id)
		VALUES 
		(
		<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">, 
		<cfqueryparam value="#arguments.thestruct.sched_id#" cfsqltype="CF_SQL_VARCHAR">, 
		<cfqueryparam value="Upload" cfsqltype="cf_sql_varchar">, 
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		<cfqueryparam value="Added file #arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>
		--->
		<!--- Check if we have to remove or move the asset --->
		<!--- First only do this for assets with the same sched id --->
		<cfif arguments.thestruct.sched_id EQ arguments.thestruct.qryfile.sched_id>
			<!--- Remove --->
			<cfif arguments.thestruct.qryfile.sched_action EQ 0>
				<cffile action="delete" file="#arguments.thestruct.folderpath#/#arguments.thestruct.thefilenameoriginal#">
			<!--- Move --->
			<cfelseif arguments.thestruct.qryfile.sched_action EQ 1>
				<!--- Create the moved directory, if it is already there do nothing --->
				<cfset schedfolder = "scheduleduploads_done_" & #dateformat(now(),"yyyy_mm_dd")#>
				<cftry>
					<cfdirectory action="create" directory="#arguments.thestruct.folderpath#/#schedfolder#" mode="775">
					<cfcatch type="any"></cfcatch>
				</cftry>
				<!--- Now move the asset to the done folder --->
				<cftry>
					<cffile action="move" source="#arguments.thestruct.folderpath#/#arguments.thestruct.thefilenameoriginal#" destination="#arguments.thestruct.folderpath#/#schedfolder#/#arguments.thestruct.thefilenameoriginal#" mode="775">
				<cfcatch type="any"></cfcatch>
			</cftry>
			</cfif>
			<!--- Now remove the record in the DB --->
			<cfquery datasource="#variables.dsn#">
			DELETE FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
			</cfquery>
		</cfif>
	</cfif>
	<cfif returnid NEQ 0>
		<!--- Call method to send email --->
		<cfset arguments.thestruct.emailwhat = "end_adding">
		<cfif NOT structkeyexists(arguments.thestruct,"thefile")>
			<cfset arguments.thestruct.thefile = arguments.thestruct.qryfile.filename>
		</cfif>
		<cfset arguments.thestruct.thefile = arguments.thestruct.thefile & ",">
		<cfloop list="#arguments.thestruct.thefile#" index="i" delimiters=",">
			<cfset arguments.thestruct.thefilename = i>
			<cfinvoke method="addassetsendmail" returnvariable="arguments.thestruct.qryfile" thestruct="#arguments.thestruct#">
		</cfloop>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.qryfile.path>
</cffunction>

<!--- DELETE IN DB AND FILE SYSTEM -------------------------------------------------------------------->
<cffunction name="removeasset" output="true">
	<cfargument name="thestruct" type="struct">
	<cfset var ts = structnew()>
	<cfset ts.thepath = arguments.thestruct.thepath>
	<cfset ts.assetpath = arguments.thestruct.assetpath>
	<cfset ts.database = arguments.thestruct.database>
	<cfset ts.dsn = application.razuna.datasource>
	<cfthread intvars="#ts#" priority="LOW">
		<!--- Set time for remove --->
		<cfset removetime = DateAdd("h", -6, "#now()#")>
		<!--- Clear assets dbs from records which have no path_to_asset --->
		<cftransaction>
			<cfquery datasource="#attributes.intvars.dsn#">
			DELETE FROM #session.hostdbprefix#images
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND img_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
			</cfquery>
		</cftransaction>
		<cftransaction>
			<cfquery datasource="#attributes.intvars.dsn#">
			DELETE FROM #session.hostdbprefix#videos
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND vid_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
			</cfquery>
		</cftransaction>
		<cftransaction>
			<cfquery datasource="#attributes.intvars.dsn#">
			DELETE FROM #session.hostdbprefix#files
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND file_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
			</cfquery>
		</cftransaction>
		<cftransaction>
			<cfquery datasource="#attributes.intvars.dsn#">
			DELETE FROM #session.hostdbprefix#audios
			WHERE (path_to_asset IS NULL OR path_to_asset = '')
			AND aud_create_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
			</cfquery>
		</cftransaction>
		<!--- Select temp assets which are older then 6 hours --->
		<cfquery datasource="#attributes.intvars.dsn#" name="qry">
		SELECT path as temppath, tempid
		FROM #session.hostdbprefix#assets_temp
		WHERE date_add < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#removetime#">
		<!--- AND link_kind <cfif attributes.intvars.database EQ "oracle" OR attributes.intvars.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_varchar" value="lan">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> --->
		</cfquery>
		<!--- Loop trough the found records --->
		<cfloop query="qry">
			<!--- Delete in the DB --->
			<cfquery datasource="#attributes.intvars.dsn#">
			DELETE FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tempid#">
			<!--- AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#"> --->
			</cfquery>
			<!--- Delete on the file system --->
			<cfif directoryexists(temppath)>
				<cfdirectory action="delete" recurse="true" directory="#temppath#">
			</cfif>
		</cfloop>
		<cftry>
			<!--- Now check directory on the hard drive. This will fix issue with files that were not successfully uploaded thus missing in the temp db --->
			<cfdirectory action="list" directory="#attributes.intvars.thepath#/incoming" name="thedirs">
			<!--- Loop over dirs --->
			<cfloop query="thedirs">
				<cfif datelastmodified LT removetime AND directoryexists("#attributes.intvars.thepath#/incoming/#name#")>
					<cfdirectory action="delete" directory="#attributes.intvars.thepath#/incoming/#name#" recurse="true" mode="775">
				</cfif>
			</cfloop>
			<cfcatch type="any">
			</cfcatch>
		</cftry>
	</cfthread>
</cffunction>

<!--- PROCESS A DOCUMENT-FILE -------------------------------------------------------------------->
	<cffunction name="processDocFile" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfset arguments.thestruct.newid = 1>
		<!--- New ID --->
		<cfset arguments.thestruct.newid = arguments.thestruct.qryfile.tempid>
		<!--- Insert --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#files
		(file_id, is_available)
		VALUES(
			<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="0" cfsqltype="CF_SQL_VARCHAR">
			)
		</cfquery>
		<!--- Set Params --->
		<cfset arguments.thestruct.gettemp = GetTempDirectory()>
		<cfset arguments.thestruct.iswindows = iswindows()>
		<!--- thread --->
		<cfthread intstruct="#arguments.thestruct#" priority="LOW">
			<!--- Params --->
			<cfset cloud_url = structnew()>
			<cfset cloud_url_org = structnew()>
			<cfset cloud_url_2 = structnew()>
			<cfset cloud_url_org.theurl = "">
			<cfset cloud_url.theurl = "">
			<cfset cloud_url_2.theurl = "">
			<cfset cloud_url_org.newepoch = 0>
			<cfset file_meta = "">
			<cfset thesubject = "">
			<cfset thekeywords = "">
			<cfset theapplekeywords = "">
			<cfset attributes.intstruct.pathorg = attributes.intstruct.qryfile.path>
			<!--- Random ID for script --->
			<cfset ttpdf = Createuuid("")>
			<!--- Set some more vars but only for PDF --->
			<cfif attributes.intstruct.qryfile.extension EQ "PDF" AND attributes.intstruct.qryfile.link_kind NEQ "url">
				<!--- If this is a linked asset --->
				<cfif attributes.intstruct.qryfile.link_kind EQ "lan">
					<!--- Create var with temp directory to hold the thumbnail and images --->
					<cfset attributes.intstruct.thetempdirectory = "#attributes.intstruct.thepath#/incoming/#createuuid('')#">
					<cfset attributes.intstruct.theorgfileflat = "#attributes.intstruct.qryfile.path#[0]">
					<cfset attributes.intstruct.theorgfile = attributes.intstruct.qryfile.path>
					<cfset attributes.intstruct.theorgfileraw = attributes.intstruct.qryfile.path>
					<!--- The name for the pdf --->
					<cfset getlast = listlast(attributes.intstruct.qryfile.path,"/\")>
					<cfset attributes.intstruct.thepdfimage = replacenocase(getlast,".pdf",".jpg","all")>
				<!--- For importpath --->
				<cfelseif attributes.intstruct.importpath>
					<!--- Create var with temp directory to hold the thumbnail and images --->
					<cfset attributes.intstruct.thetempdirectory = "#attributes.intstruct.thepath#/incoming/#createuuid('')#">
					<cfset attributes.intstruct.theorgfileflat = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#[0]">
					<cfset attributes.intstruct.theorgfile = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<cfset attributes.intstruct.theorgfileraw = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<!--- The name for the pdf --->
					<cfset attributes.intstruct.thepdfimage = replacenocase(attributes.intstruct.qryfile.filename,".pdf",".jpg","all")>
					<!--- Create temp folder --->
					<cfdirectory action="create" directory="#attributes.intstruct.thetempdirectory#" mode="775" />
				<cfelse>
					<cfset attributes.intstruct.thetempdirectory = attributes.intstruct.qryfile.path>
					<cfset attributes.intstruct.theorgfileflat = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#[0]">
					<cfset attributes.intstruct.theorgfile = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<cfset attributes.intstruct.theorgfileraw = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<!--- The name for the pdf --->
					<cfset attributes.intstruct.thepdfimage = replacenocase(attributes.intstruct.qryfile.filename,".pdf",".jpg","all")>
				</cfif>
				<!--- Check the platform and then decide on the ImageMagick tag --->
				<cfif attributes.intstruct.iswindows>
					<cfset attributes.intstruct.theimconvert = """#attributes.intstruct.thetools.imagemagick#/convert.exe""">
					<cfset attributes.intstruct.theexif = """#attributes.intstruct.thetools.exiftool#/exiftool.exe""">
					<cfset attributes.intstruct.theorgfileflat = attributes.intstruct.theorgfileflat>
					<cfset attributes.intstruct.theorgfile = attributes.intstruct.theorgfile>
					<cfset attributes.intstruct.thepdfimage = attributes.intstruct.thepdfimage>
					<!--- Set scripts --->
					<cfset attributes.intstruct.thesh = "#attributes.intstruct.gettemp#/#ttpdf#.bat">
					<cfset attributes.intstruct.thesht = "#attributes.intstruct.gettemp#/#ttpdf#t.bat">
					<cfset attributes.intstruct.theshexs = "#attributes.intstruct.gettemp#/#ttpdf#exs.bat">
					<cfset attributes.intstruct.theshexk = "#attributes.intstruct.gettemp#/#ttpdf#exk.bat">
					<cfset attributes.intstruct.theshexak = "#attributes.intstruct.gettemp#/#ttpdf#exak.bat">
					<cfset attributes.intstruct.theshexmeta = "#attributes.intstruct.gettemp#/#ttpdf#exmeta.bat">
					<cfset attributes.intstruct.theshexmetaxmp = "#attributes.intstruct.gettemp#/#ttpdf#exmetaxmp.bat">
				<cfelse>
					<cfset attributes.intstruct.theimconvert = "#attributes.intstruct.thetools.imagemagick#/convert">
					<cfset attributes.intstruct.theexif = "#attributes.intstruct.thetools.exiftool#/exiftool">
					<cfset attributes.intstruct.theorgfileflat = replace(attributes.intstruct.theorgfileflat," ","\ ","all")>
					<cfset attributes.intstruct.theorgfileflat = replace(attributes.intstruct.theorgfileflat,"&","\&","all")>
					<cfset attributes.intstruct.theorgfileflat = replace(attributes.intstruct.theorgfileflat,"'","\'","all")>
					<cfset attributes.intstruct.theorgfile = replace(attributes.intstruct.theorgfile," ","\ ","all")>
					<cfset attributes.intstruct.theorgfile = replace(attributes.intstruct.theorgfile,"&","\&","all")>
					<cfset attributes.intstruct.theorgfile = replace(attributes.intstruct.theorgfile,"'","\'","all")>
					<cfset attributes.intstruct.thepdfimage = replace(attributes.intstruct.thepdfimage," ","\ ","all")>
					<cfset attributes.intstruct.thepdfimage = replace(attributes.intstruct.thepdfimage,"&","\&","all")>
					<cfset attributes.intstruct.thepdfimage = replace(attributes.intstruct.thepdfimage,"'","\'","all")>
					<!--- Set scripts --->
					<cfset attributes.intstruct.thesh = "#attributes.intstruct.gettemp#/#ttpdf#.sh">
					<cfset attributes.intstruct.thesht = "#attributes.intstruct.gettemp#/#ttpdf#t.sh">
					<cfset attributes.intstruct.theshexs = "#attributes.intstruct.gettemp#/#ttpdf#exs.sh">
					<cfset attributes.intstruct.theshexk = "#attributes.intstruct.gettemp#/#ttpdf#exk.sh">
					<cfset attributes.intstruct.theshexak = "#attributes.intstruct.gettemp#/#ttpdf#exak.sh">
					<cfset attributes.intstruct.theshexmeta = "#attributes.intstruct.gettemp#/#ttpdf#exmeta.sh">
					<cfset attributes.intstruct.theshexmetaxmp = "#attributes.intstruct.gettemp#/#ttpdf#exmetaxmp.sh">
				</cfif>
			</cfif>
			<!--- If we are PDF we create thumbnail and images from the PDF --->
			<!--- RFS --->
			<cfif !application.razuna.rfs>
				<cfif attributes.intstruct.qryfile.extension EQ "PDF" AND attributes.intstruct.qryfile.link_kind NEQ "url">
					<!--- Create a temp folder to hold the PDF images --->
					<cfset attributes.intstruct.thepdfdirectory = "#attributes.intstruct.thetempdirectory#/#createuuid('')#/razuna_pdf_images">
					<!--- Create folder to hold the images --->
					<cfdirectory action="create" directory="#attributes.intstruct.thepdfdirectory#" mode="775">
					<!--- Script: Create thumbnail --->
					<cffile action="write" file="#attributes.intstruct.thesh#" output="#attributes.intstruct.theimconvert# #attributes.intstruct.theorgfileflat# -thumbnail 128x -strip -colorspace sRGB -flatten #attributes.intstruct.thetempdirectory#/#attributes.intstruct.thepdfimage#" mode="777">
					<!--- Script: Create images --->
					<cffile action="write" file="#attributes.intstruct.thesht#" output="#attributes.intstruct.theimconvert# #attributes.intstruct.theorgfile# #attributes.intstruct.thepdfdirectory#/#attributes.intstruct.thepdfimage#" mode="777">
					<!--- Execute --->
					<cfexecute name="#attributes.intstruct.thesh#" timeout="900" />
					<cfif application.razuna.storage NEQ "amazon">
						<cfexecute name="#attributes.intstruct.thesht#" timeout="900" />
					</cfif>
					<!--- Delete scripts --->
					<cffile action="delete" file="#attributes.intstruct.thesh#">
					<cffile action="delete" file="#attributes.intstruct.thesht#">
					<!--- If no PDF could be generated then copy the thumbnail placeholder --->
					<cfif NOT fileexists("#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thepdfimage#")>
						<cffile action="copy" source="#attributes.intstruct.rootpath#global/host/dam/images/icons/icon_pdf.png" destination="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thepdfimage#" mode="775">
					</cfif>
					<cfset attributes.intstruct.qryfile.path = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
				<!--- We are normal files --->
				<cfelse>
					<!--- Check the platform and then decide on the ImageMagick tag --->
					<cfif attributes.intstruct.iswindows>
						<cfset attributes.intstruct.theexif = """#attributes.intstruct.thetools.exiftool#/exiftool.exe""">
						<cfexecute name="#attributes.intstruct.theexif#" arguments="-a -g #attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#" timeout="60" variable="file_meta" />
						<!--- On LAN Put the path into this variable for the md5 hash --->
						<cfif attributes.intstruct.qryfile.link_kind EQ "lan">
							<cfset attributes.intstruct.theorgfileraw = attributes.intstruct.qryfile.path>
						<cfelse>
							<cfset attributes.intstruct.theorgfileraw = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
						</cfif>
						<cfset attributes.intstruct.qryfile.path = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
					<cfelse>
						<cfset attributes.intstruct.theexif = "#attributes.intstruct.thetools.exiftool#/exiftool">
						<!--- Set scripts --->
						<cfset attributes.intstruct.thesh = "#attributes.intstruct.gettemp#/#ttpdf#.sh">
						<!--- On LAN --->
						<cfif attributes.intstruct.qryfile.link_kind EQ "lan">
							<cfset attributes.intstruct.theorgfileraw = attributes.intstruct.qryfile.path>
							<cfset attributes.intstruct.qryfile.path = replace(attributes.intstruct.qryfile.path," ","\ ","all")>
							<cfset attributes.intstruct.qryfile.path = replace(attributes.intstruct.qryfile.path,"&","\&","all")>
							<cfset attributes.intstruct.qryfile.path = replace(attributes.intstruct.qryfile.path,"'","\'","all")>
						<cfelse>
							<cfset attributes.intstruct.theorgfileraw = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
							<cfset attributes.intstruct.qryfile.path = "#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
						</cfif>
						<!--- Write Script --->
						<cffile action="write" file="#attributes.intstruct.thesh#" output="#attributes.intstruct.theexif# -a -g #attributes.intstruct.qryfile.path#" mode="777">
						<!--- Execute Script --->
						<cfexecute name="#attributes.intstruct.thesh#" timeout="900" variable="file_meta" />
						<!--- Delete scripts --->
						<cffile action="delete" file="#attributes.intstruct.thesh#">
					</cfif>
				</cfif>
			</cfif>
			<!--- If this is a URL then reset the path --->
			<cfif attributes.intstruct.qryfile.link_kind EQ "url">
				<cfset attributes.intstruct.qryfile.path = attributes.intstruct.pathorg>
			</cfif>
			<!--- Get Metadata for PDF --->
			<cfif attributes.intstruct.qryfile.extension EQ "PDF" AND attributes.intstruct.qryfile.link_kind NEQ "url">
				<!--- On Windows reparse the metadata again (doesnt work properly with the bat file) --->
				<cfif attributes.intstruct.isWindows>
					<cfexecute name="#attributes.intstruct.theexif#" arguments="-b -subject #attributes.intstruct.theorgfile#" timeout="60" variable="thesubject" />
					<cfexecute name="#attributes.intstruct.theexif#" arguments="-keywords #attributes.intstruct.theorgfile#" timeout="60" variable="thekeywords" />
					<cfexecute name="#attributes.intstruct.theexif#" arguments="-applekeywords #attributes.intstruct.theorgfile#" timeout="60" variable="theapplekeywords" />
					<cfexecute name="#attributes.intstruct.theexif#" arguments="-a -g #attributes.intstruct.theorgfile#" timeout="60" variable="file_meta" />
					<cfexecute name="#attributes.intstruct.theexif#" arguments="-X #attributes.intstruct.theorgfile#" timeout="60" variable="attributes.intstruct.pdf_xmp" />
				<cfelse>
					<!--- Script: Exiftool Commands --->
					<cffile action="write" file="#attributes.intstruct.theshexs#" output="#attributes.intstruct.theexif# -b -subject #attributes.intstruct.theorgfile#" mode="777">
					<cffile action="write" file="#attributes.intstruct.theshexk#" output="#attributes.intstruct.theexif# -keywords #attributes.intstruct.theorgfile#" mode="777">
					<cffile action="write" file="#attributes.intstruct.theshexak#" output="#attributes.intstruct.theexif# -applekeywords #attributes.intstruct.theorgfile#" mode="777">
					<cffile action="write" file="#attributes.intstruct.theshexmeta#" output="#attributes.intstruct.theexif# -a -g #attributes.intstruct.theorgfile#" mode="777">
					<cffile action="write" file="#attributes.intstruct.theshexmetaxmp#" output="#attributes.intstruct.theexif# -X #attributes.intstruct.theorgfile#" mode="777">
					<!--- Execute scripts --->
					<cfexecute name="#attributes.intstruct.theshexs#" timeout="60" variable="thesubject" />
					<cfexecute name="#attributes.intstruct.theshexk#" timeout="60" variable="thekeywords" />
					<cfexecute name="#attributes.intstruct.theshexak#" timeout="60" variable="theapplekeywords" />
					<cfexecute name="#attributes.intstruct.theshexmeta#" timeout="60" variable="file_meta" />
					<cfexecute name="#attributes.intstruct.theshexmetaxmp#" timeout="60" variable="attributes.intstruct.pdf_xmp" />
					<!--- Delete scripts --->
					<cffile action="delete" file="#attributes.intstruct.theshexs#">
					<cffile action="delete" file="#attributes.intstruct.theshexk#">
					<cffile action="delete" file="#attributes.intstruct.theshexak#">
					<cffile action="delete" file="#attributes.intstruct.theshexmeta#">
					<cffile action="delete" file="#attributes.intstruct.theshexmetaxmp#">							
				</cfif>
				<!--- Parse PDF XMP and write to DB --->
				<cfif attributes.intstruct.pdf_xmp NEQ "">
					<cfinvoke component="xmp" method="getpdfxmp" thestruct="#attributes.intstruct#" />
				</cfif>
			</cfif>
			<!--- If we are a new version --->
			<cfif attributes.intstruct.qryfile.file_id NEQ 0>
				<!--- Call versions component to do the versions thingy --->
				<cfinvoke component="versions" method="create" thestruct="#attributes.intstruct#">
			<!--- This is for normal adding --->
			<cfelse>
				<!--- append to the DB --->
				<cftransaction>
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET
					folder_id_r = <cfqueryparam value="#attributes.intstruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					file_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
					file_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
					file_create_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
					file_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					file_owner = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
					file_type = <cfqueryparam value="#attributes.intstruct.thefiletype#" cfsqltype="cf_sql_varchar">, 
					file_name_noext = <cfqueryparam value="#attributes.intstruct.qryfile.filenamenoext#" cfsqltype="cf_sql_varchar">, 
					file_extension = <cfqueryparam value="#attributes.intstruct.qryfile.extension#" cfsqltype="cf_sql_varchar">, 
					file_name = 
						<cfif structkeyexists(attributes.intstruct, "theoriginalfilename")>
							<cfqueryparam value="#attributes.intstruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">,
						<cfelse>
							<cfqueryparam value="#attributes.intstruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
						</cfif>
					<!--- file_contenttype = <cfqueryparam value="#attributes.intstruct.ContentType#" cfsqltype="cf_sql_varchar">,
					file_contentsubtype = <cfqueryparam value="#attributes.intstruct.ContentSubType#" cfsqltype="cf_sql_varchar">,  --->
					file_online = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">, 
					file_name_org = 
						<cfif attributes.intstruct.link_kind EQ "lan">
							<cfqueryparam value="#attributes.intstruct.lanorgname#" cfsqltype="cf_sql_varchar">,
						<cfelse>
							<cfqueryparam value="#attributes.intstruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
						</cfif>
					file_size = <cfqueryparam value="#attributes.intstruct.qryfile.thesize#" cfsqltype="cf_sql_numeric">, 
					link_path_url = <cfqueryparam value="#attributes.intstruct.qryfile.path#" cfsqltype="cf_sql_varchar">, 
					link_kind = <cfqueryparam value="#attributes.intstruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">, 
					host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">, 
					file_meta = <cfqueryparam value="#file_meta#" cfsqltype="cf_sql_varchar">,
					path_to_asset =  <cfqueryparam value="#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#" cfsqltype="cf_sql_varchar">,
					hashtag =  <cfqueryparam value="#attributes.intstruct.qryfile.md5hash#" cfsqltype="cf_sql_varchar">,
					is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="0">
					<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
						,
						lucene_key = <cfqueryparam value="#attributes.intstruct.qryfile.path#" cfsqltype="cf_sql_varchar">
					</cfif>
					WHERE file_id = <cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
				</cftransaction>
				<!--- Add the TEXTS to the DB. We have to hide this if we are coming from FCK --->
				<!--- If we are PDF we create thumbnail and images from the PDF --->
				<cfif attributes.intstruct.qryfile.extension EQ "PDF" AND attributes.intstruct.qryfile.link_kind NEQ "url" AND structkeyexists(attributes.intstruct,"langcount")>
					<!--- Grab the keywords --->
					<cfset thekeywords = trim(listlast(thekeywords,":"))>
					<cfset theapplekeywords = trim(listlast(theapplekeywords,":"))>
					<!--- If both keywords values have the same length then only use one, else combine them --->
					<cfif len(thekeywords) NEQ len(theapplekeywords)>
						<cfset thekeywords = thekeywords & ", " & theapplekeywords>
					</cfif>
					<cfloop list="#attributes.intstruct.langcount#" index="langindex">
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #session.hostdbprefix#files_desc
						(id_inc, file_id_r, lang_id_r, file_desc, file_keywords, host_id)
						values(
						<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
						<cfqueryparam value="#thesubject#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#thekeywords#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						)
						</cfquery>
					</cfloop>
				</cfif>
				<!--- If there are metadata fields then add them here --->
				<cfif attributes.intstruct.metadata EQ 1>
					<!--- Check if API is called the old way --->
					<cfif structkeyexists(attributes.intstruct,"sessiontoken")>
						<cfinvoke component="global.api.asset" method="setmetadata">
							<cfinvokeargument name="sessiontoken" value="#attributes.intstruct.sessiontoken#">
							<cfinvokeargument name="assetid" value="#attributes.intstruct.newid#">
							<cfinvokeargument name="assettype" value="doc">
							<cfinvokeargument name="assetmetadata" value="#attributes.intstruct.assetmetadata#">
						</cfinvoke>
					<cfelse>
						<!--- API2 --->
						<cfinvoke component="global.api2.asset" method="setmetadata">
							<cfinvokeargument name="api_key" value="#attributes.intstruct.api_key#">
							<cfinvokeargument name="assetid" value="#attributes.intstruct.newid#">
							<cfinvokeargument name="assettype" value="doc">
							<cfinvokeargument name="assetmetadata" value="#attributes.intstruct.assetmetadata#">
						</cfinvoke>
					</cfif>
				</cfif>
				<!--- Move the file to its own directory --->
				<cfif application.razuna.storage EQ "local" AND attributes.intstruct.qryfile.link_kind NEQ "url">
					<!--- Create folder with the asset id --->
					<cfif !directoryexists("#attributes.intstruct.qrysettings.set2_path_to_assets#/#session.hostid#/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#")>
						<cfdirectory action="create" directory="#attributes.intstruct.qrysettings.set2_path_to_assets#/#session.hostid#/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#" mode="775">
					</cfif>
					<!--- Move the file from the temp path to this folder, but not for local link assets --->
					<cfif attributes.intstruct.qryfile.link_kind NEQ "lan">
						<cffile action="copy" source="#attributes.intstruct.theorgfileraw#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#session.hostid#/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#" mode="775">
					</cfif>
					<!--- If we are PDF we need to move the thumbnail and image as well --->
					<cfif attributes.intstruct.qryfile.extension EQ "PDF" AND !application.razuna.rfs>
						<!--- Move thumbnail --->
						<cffile action="move" source="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thepdfimage#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#session.hostid#/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/#attributes.intstruct.thepdfimage#" mode="775">
						<!--- Create image folder --->
						<cfdirectory action="create" directory="#attributes.intstruct.qrysettings.set2_path_to_assets#/#session.hostid#/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/razuna_pdf_images" mode="775">
						<!--- List all images and then move them --->
						<cfdirectory action="list" directory="#attributes.intstruct.thepdfdirectory#" name="pdfjpgs">
						<cfloop query="pdfjpgs">
							<cffile action="move" source="#attributes.intstruct.thepdfdirectory#/#name#" destination="#attributes.intstruct.qrysettings.set2_path_to_assets#/#session.hostid#/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/razuna_pdf_images/#name#" mode="775">
						</cfloop>
					</cfif>
					<!--- Add to Lucene --->
					<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#attributes.intstruct#" assetid="#attributes.intstruct.newid#" category="doc">
				<!--- NIRVANIX --->
				<cfelseif application.razuna.storage EQ "nirvanix" AND attributes.intstruct.qryfile.link_kind NEQ "url">
					<cfset ttu = createuuid("")>
					<cfthread name="#ttu#" upstruct="#attributes.intstruct#" priority="HIGH">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.upstruct.qryfile.folder_id#/doc/#attributes.upstruct.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.upstruct.qryfile.path#">
							<cfinvokeargument name="nvxsession" value="#attributes.upstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for thread to finish --->
					<cfthread action="join" name="#ttu#" />	
					<!--- If we are PDF we need to upload the thumbnail and image as well --->
					<cfif attributes.intstruct.qryfile.extension EQ "PDF" AND !application.razuna.rfs>
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thepdfimage#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
						<!--- List all images and then upload them --->
						<cfdirectory action="list" directory="#attributes.intstruct.thepdfdirectory#" name="pdfjpgs">
						<!--- Upload images --->
						<cfloop query="pdfjpgs">
							<cfinvoke component="nirvanix" method="Upload">
								<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/razuna_pdf_images">
								<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thepdfdirectory#/#name#">
								<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
							</cfinvoke>
						</cfloop>
						<!--- Get signed URLS for the thumbnail --->
						<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/#attributes.intstruct.thepdfimage#" nvxsession="#attributes.intstruct.nvxsession#">
						<!--- Update DB  --->
						<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#files
						SET 
						cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
						WHERE file_id = <cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
					</cfif>
					<!--- Get signed URLS for the file --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#" nvxsession="#attributes.intstruct.nvxsession#">
					<!--- Update DB  --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET 
					cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
					cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
					WHERE file_id = <cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Add to Lucene --->
					<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#attributes.intstruct#" assetid="#attributes.intstruct.newid#" category="doc">
				<!--- AMAZON --->
				<cfelseif application.razuna.storage EQ "amazon" AND attributes.intstruct.qryfile.link_kind NEQ "url">
					<!--- Upload file --->
					<cfset upd = Createuuid("")>
					<cfthread name="#upd#" intupstruct="#attributes.intstruct#" priority="HIGH">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intupstruct.qryfile.folder_id#/doc/#attributes.intupstruct.newid#/#attributes.intupstruct.qryfile.filename#">
							<cfinvokeargument name="theasset" value="#attributes.intupstruct.qryfile.path#">
							<cfinvokeargument name="awsbucket" value="#attributes.intupstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upd#" />
					<!--- If we are PDF we need to upload the thumbnail and image as well --->
					<cfif attributes.intstruct.qryfile.extension EQ "PDF" AND !application.razuna.rfs>
						<!--- Upload thumbnail --->		
						<cfset updt = Createuuid("")>
						<cfthread name="#updt#" intuptstruct="#attributes.intstruct#" priority="HIGH">
							<cfinvoke component="amazon" method="Upload">
								<cfinvokeargument name="key" value="/#attributes.intuptstruct.qryfile.folder_id#/doc/#attributes.intuptstruct.newid#/#attributes.intuptstruct.thepdfimage#">
								<cfinvokeargument name="theasset" value="#attributes.intuptstruct.thetempdirectory#/#attributes.intuptstruct.thepdfimage#">
								<cfinvokeargument name="awsbucket" value="#attributes.intuptstruct.awsbucket#">
							</cfinvoke>
						</cfthread>
						<cfthread action="join" name="#updt#" />
						<!--- Get signed URLS for the thumbnail --->
						<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/#attributes.intstruct.thepdfimage#" awsbucket="#attributes.intstruct.awsbucket#">
						<!--- List all images and then upload them --->
						<cfdirectory action="list" directory="#attributes.intstruct.thepdfdirectory#" name="pdfjpgs">
						<!--- Upload images --->
						<cfloop query="pdfjpgs">
							<cfinvoke component="amazon" method="Upload">
								<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/razuna_pdf_images/#name#">
								<cfinvokeargument name="theasset" value="#attributes.intstruct.thepdfdirectory#/#name#">
								<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
							</cfinvoke>
						</cfloop>
						<!--- Update DB  --->
						<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#files
						SET 
						cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
						WHERE file_id = <cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						</cfquery>
					</cfif>
					<!--- Get signed URLS for the file --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#attributes.intstruct.qryfile.folder_id#/doc/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#" awsbucket="#attributes.intstruct.awsbucket#">
					<!--- Update DB  --->
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET 
					cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
					cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
					WHERE file_id = <cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Add to Lucene --->
					<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#attributes.intstruct#" assetid="#attributes.intstruct.newid#" category="doc">
				<!--- Link_kind is URL --->
				<cfelseif attributes.intstruct.qryfile.link_kind EQ "url">
					<!--- Add to Lucene --->
					<cfinvoke component="lucene" method="index_update" dsn="#application.razuna.datasource#" thestruct="#attributes.intstruct#" assetid="#attributes.intstruct.newid#" category="doc">
				</cfif>
				<!--- Update DB to make asset available --->
				<cfif !application.razuna.rfs>
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#files
					SET is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					WHERE file_id = <cfqueryparam value="#attributes.intstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				</cfif>
			</cfif>
			<!--- Log --->
			<cfinvoke component="extQueryCaching" method="log_assets">
				<cfinvokeargument name="theuserid" value="#session.theuserid#">
				<cfinvokeargument name="logaction" value="Add">
				<cfinvokeargument name="logdesc" value="Added: #attributes.intstruct.qryfile.filename#">
				<cfinvokeargument name="logfiletype" value="doc">
				<cfinvokeargument name="assetid" value="#attributes.intstruct.newid#">
			</cfinvoke>
			<!--- RFS --->
			<cfif application.razuna.rfs>
				<cfset attributes.intstruct.assettype = "doc">	
				<cfinvoke component="rfs" method="notify" thestruct="#attributes.intstruct#" />
			</cfif>
		</cfthread>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("files")>
	<cfset variables.cachetoken = resetcachetoken("folders")>
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- The return --->
	<cfif isnumeric(arguments.thestruct.newid)>
		<cfreturn arguments.thestruct.newid />
	<cfelse>
		<cfreturn 1 />
	</cfif>
</cffunction>

<!--- PROCESS A IMAGE-FILE ----------------------------------------------------------------------->
<cffunction name="processImgFile" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Set default values --->
	<cfparam name="arguments.thestruct.img_thumb"        default="">
	<cfparam name="arguments.thestruct.img_comp"         default="">
	<cfparam name="arguments.thestruct.img_comp_uw"      default="">
	<cfparam name="arguments.thestruct.groupnumber"      default="">
	<cfparam name="arguments.thestruct.publisher"        default="">
	<cfparam name="arguments.thestruct.img_thumb_width"  default="">
	<cfparam name="arguments.thestruct.img_thumb_heigth" default="">
	<cfparam name="arguments.thestruct.img_comp_width"   default="">
	<cfparam name="arguments.thestruct.img_comp_heigth"  default="">
	<cfparam name="arguments.thestruct.dsn"  			 default="#variables.dsn#">
	<cfparam name="arguments.thestruct.hostid"  		 default="#session.hostid#">
	<cfparam name="arguments.thestruct.theuserid"  		 default="#session.theuserid#">
	<cfparam name="arguments.thestruct.storage"  		 default="#application.razuna.storage#">
	<cfparam name="arguments.thestruct.database"  		 default="#variables.database#">
	<cfparam name="arguments.thestruct.hostdbprefix"  	 default="#session.hostdbprefix#">
	<cfparam name="arguments.thestruct.cftoken"		  	 default="#cftoken#">
	<!--- If we are a new version --->
	<cfif arguments.thestruct.qryfile.file_id NEQ 0>
		<!--- Call versions component to do the versions thingy --->
		<cfinvoke component="versions" method="create" thestruct="#arguments.thestruct#">
		<!--- Set the newid --->
		<cfset arguments.thestruct.newid = 1>
	<!--- For normal adding --->
	<cfelse>
		<cfset arguments.thestruct.newid = arguments.thestruct.qryfile.tempid>
		<!--- Call the import/imagemagick method --->
		<!--- <cfinvoke method="importimages" thestruct="#arguments.thestruct#"> --->
		<cfthread intstruct="#arguments.thestruct#" priority="LOW">
			<cfinvoke method="importimagesthread" thestruct="#attributes.intstruct#" />
		</cfthread>
		<!--- If above return x we failed for the image --->
		<cfif arguments.thestruct.newid EQ 0>
			<cfinvoke component="email" method="send_email" subject="Image #arguments.thestruct.qryfile.filename# not added" themessage="Unfortunately, we could not add your image #arguments.thestruct.qryfile.filename# to the system because we can't recognize it as an image!">
			<!--- Log --->
			<cfset log = #log_assets(theuserid=session.theuserid,logaction='Error',logdesc='Error: #arguments.thestruct.qryfile.filename# not recognized as image!',logfiletype='img')#>
		<cfelse>
			<!--- Add remaining data to the image table --->
			<!--- <cfthread name="processImgFile#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" priority="HIGH"> --->
				<cftransaction>
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#images
					SET
					img_filename = 
					<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
						<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
					<cfelse>
						<cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
					</cfif>,
					img_online = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">,
					img_owner = <cfqueryparam value="#arguments.thestruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
					img_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					img_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					img_create_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					img_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					img_custom_id = <cfqueryparam value="#arguments.thestruct.qryfile.filenamenoext#" cfsqltype="cf_sql_varchar">,
					img_in_progress = <cfqueryparam value="T" cfsqltype="cf_sql_varchar">,
					img_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
					thumb_extension = <cfqueryparam value="#arguments.thestruct.qrysettings.set2_img_format#" cfsqltype="cf_sql_varchar">,
					link_path_url = <cfqueryparam value="#arguments.thestruct.qryfile.path#" cfsqltype="cf_sql_varchar">,
					link_kind = <cfqueryparam value="#arguments.thestruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">,
					path_to_asset = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#" cfsqltype="cf_sql_varchar">
					<cfif !application.razuna.rfs>
						,
						is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
					</cfif>
					<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
						,
						img_filename_org = <cfqueryparam value="#arguments.thestruct.lanorgname#" cfsqltype="cf_sql_varchar">
					<cfelse>
						,
						img_filename_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
					</cfif>
					<cfif structkeyexists(arguments.thestruct.qryfile,"groupid") AND arguments.thestruct.qryfile.groupid NEQ "">
						,
						img_group = <cfqueryparam value="#arguments.thestruct.qryfile.groupid#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
					<!--- For Nirvanix --->
					<cfif (application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon") AND arguments.thestruct.qryfile.link_kind EQ "">
						,
						lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
					</cfif>
					WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
					</cfquery>
				</cftransaction>
				<!--- Remove records in temp db --->
				<cftransaction>
					<cfquery datasource="#application.razuna.datasource#">
					DELETE FROM #session.hostdbprefix#temp
					WHERE tmp_token = <cfqueryparam value="#arguments.thestruct.CFToken#" cfsqltype="cf_sql_varchar">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
					</cfquery>
				</cftransaction>
				<!--- Add to Lucene --->
				<cfif NOT structkeyexists(arguments.thestruct,"fromconverting")>
					<cfinvoke component="lucene" method="index_update" dsn="#arguments.thestruct.dsn#" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.newid#" category="img">
				</cfif>
				<!--- Add to shared options --->
				<cftransaction>
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#share_options
					(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
					VALUES(
					<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="thumb" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				</cftransaction>
				<cftransaction>
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#share_options
					(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
					VALUES(
					<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.thestruct.hostid#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="img" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="org" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				</cftransaction>
				<!--- If there are metadata fields then add them here --->
				<cfif arguments.thestruct.metadata EQ 1>
					<!--- Check if API is called the old way --->
					<cfif structkeyexists(arguments.thestruct,"sessiontoken")>
						<cfinvoke component="global.api.asset" method="setmetadata">
							<cfinvokeargument name="sessiontoken" value="#arguments.thestruct.sessiontoken#">
							<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
							<cfinvokeargument name="assettype" value="img">
							<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
						</cfinvoke>
					<cfelse>
						<!--- API2 --->
						<cfinvoke component="global.api2.asset" method="setmetadata">
							<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
							<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
							<cfinvokeargument name="assettype" value="img">
							<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
						</cfinvoke>
					</cfif>
				</cfif>
				<!--- Log --->
				<cfinvoke component="extQueryCaching" method="log_assets">
					<cfinvokeargument name="theuserid" value="#arguments.thestruct.theuserid#">
					<cfinvokeargument name="logaction" value="Add">
					<cfinvokeargument name="logdesc" value="Added: #arguments.thestruct.qryfile.filename#">
					<cfinvokeargument name="logfiletype" value="img">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.newid#">
				</cfinvoke>
				<!--- RFS --->
				<cfif application.razuna.rfs>
					<cfset arguments.thestruct.assettype = "img">
					<cfinvoke component="rfs" method="notify" thestruct="#arguments.thestruct#" />
				</cfif>
			<!--- </cfthread>
			<!--- Wait for thread --->
			<cfthread action="join" name="processImgFile#arguments.thestruct.newid#" timeout="90" /> --->
			<!--- Flush Cache --->
			<cfset variables.cachetoken = resetcachetoken("images")>
			<cfset variables.cachetoken = resetcachetoken("folders")>
			<cfset variables.cachetoken = resetcachetoken("general")>
		</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.newid />
</cffunction>

<!--- IMPORTIMAGES in a thread ---->
<cffunction name="importimages" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- <cfinvoke method="importimagesthread" thestruct="#arguments.thestruct#" /> --->
	<cfthread intstruct="#arguments.thestruct#" priority="LOW">
		<cfinvoke method="importimagesthread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- IMPORT INTO DB AND IMAGEMAGICK STUFF (called from the various image uploads components) ---->
<cffunction name="importimagesthread" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- init function internal vars --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset var isAnimGIF = 0>
	<cfset var thesourcefile = "">
	<cfset var theimconverttarget = "">
	<cfset var theimconvertcompingtarget = "">
	<cfset var theplaceholderpic = arguments.thestruct.rootpath & "global/host/dam/images/placeholders/nopic.jpg">
	<cfset var theDBurl = "">
	<cfset var iLoop = "">
	<cfset var thenewnr = 0>
	<cfset arguments.thestruct.dsn = variables.dsn>
	<cfset arguments.thestruct.database = variables.database>
	<cfset arguments.thestruct.hostid = session.hostid>
	<cfset arguments.thestruct.gettemp = GetTempDirectory()>
	<!--- Random ID for script --->
	<cfset var imguuid = arguments.thestruct.newid>
	<!--- When we add a URL image we don't need to do the below --->
	<cfif arguments.thestruct.qryfile.link_kind EQ "url">
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO #session.hostdbprefix#images
		(img_id, host_id, folder_id_r)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		)
		</cfquery>
	<cfelse>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO #session.hostdbprefix#images
		(img_id, host_id, folder_id_r)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Grab stuff for exiftool and getting raw metadata from image --->
		<cfif isWindows()>
			<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
			<!--- Set scripts --->
			<cfset arguments.thestruct.thesh = "#arguments.thestruct.gettemp#/#imguuid#.bat">
		<cfelse>
			<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
			<!--- Set scripts --->
			<cfset arguments.thestruct.thesh = "#arguments.thestruct.gettemp#/#imguuid#.sh">
		</cfif>
		<!--- If linked asset then set source and filename different --->
		<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
			<cfif isWindows()>
				<cfset arguments.thestruct.thesource = """#arguments.thestruct.qryfile.path#""">
			<cfelse>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.qryfile.path," ","\ ","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"&","\&","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"'","\'","all")>
			</cfif>
			<!--- Create var with temp directory --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
			<!--- Create temp folder --->
			<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			<cfset arguments.thestruct.thesourceraw = arguments.thestruct.qryfile.path>
		<!--- If coming from a import path --->
		<cfelseif arguments.thestruct.importpath>
			<cfif isWindows()>
				<cfset arguments.thestruct.thesource = """#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#""">
			<cfelse>
				<cfset arguments.thestruct.thesource = replacenocase("#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#"," ","\ ","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"&","\&","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"'","\'","all")>
			</cfif>
			<!--- Create var with temp directory --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
			<!--- Create temp folder --->
			<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			<cfset arguments.thestruct.thesourceraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
		<!--- For uploaded files --->
		<cfelse>
			<cfif isWindows()>
				<cfset arguments.thestruct.thesource = """#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#""">
			<cfelse>
				<cfset arguments.thestruct.thesource = replacenocase("#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#"," ","\ ","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"&","\&","all")>
				<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource,"'","\'","all")>
			</cfif>
			<!--- Create var with temp directory --->
			<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.qryfile.path#">
			<cfset arguments.thestruct.thesourceraw = "#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#">
		</cfif>
		<!--- GET RAW METADATA --->
		<cfif isWindows()>
			<!--- Execute Script --->
			<cfexecute name="#arguments.thestruct.theexif#" arguments="-a -g #arguments.thestruct.thesource#" timeout="60" variable="arguments.thestruct.img_meta" />
		<cfelse>
			<!--- Write Script --->
			<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -a -g #arguments.thestruct.thesource#" mode="777">
			<!--- Execute Script --->
			<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="arguments.thestruct.img_meta" />
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
		</cfif>	
		<!--- check if image is an anmiated GIF --->
		<cfset isAnimGIF = isAnimatedGIF("#arguments.thestruct.thesource#", arguments.thestruct.thetools.imagemagick)>
		<!--- animated GIFs can only be converted to GIF --->
		<cfif isAnimGIF>
			<cfset QuerySetCell(arguments.thestruct.qrysettings, "set2_img_format", "gif", 1)>
		</cfif>
		<!--- Add the filename to the temp table so we can remove these files in one go later on --->
		<cftransaction>
			<cfquery datasource="#variables.dsn#">
			INSERT INTO #session.hostdbprefix#temp
			(tmp_token, tmp_filename, host_id)
			VALUES (
			<cfqueryparam value="#arguments.thestruct.tempid#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			)
			</cfquery>
			<cfquery datasource="#variables.dsn#">
			INSERT INTO #session.hostdbprefix#temp
			(tmp_token, tmp_filename, host_id)
			VALUES (
			<cfqueryparam value="#arguments.thestruct.tempid#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			)
			</cfquery>
		</cftransaction>
		<!--- <cfset resizeImagett = createuuid()> --->
		<cfset arguments.thestruct.theplaceholderpic = theplaceholderpic>
		<cfset arguments.thestruct.width = arguments.thestruct.qrysettings.set2_img_thumb_width>
		<cfset arguments.thestruct.height = arguments.thestruct.qrysettings.set2_img_thumb_heigth>
		<cfset arguments.thestruct.destination = "#arguments.thestruct.thetempdirectory#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#">
		<cfif isWindows()>
			<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
			<cfset arguments.thestruct.destination = """#arguments.thestruct.destination#""">
		<cfelse>
			<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination," ","\ ","all")>
			<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination,"&","\&","all")>
			<cfset arguments.thestruct.destination = replacenocase(arguments.thestruct.destination,"'","\'","all")>
			<cfset arguments.thestruct.destinationraw = arguments.thestruct.destination>
		</cfif>
		<!--- Parse keywords and description from XMP --->
		<cfinvoke component="xmp" method="xmpwritekeydesc" thestruct="#arguments.thestruct#" />
		<!--- Parse the Metadata from the image --->
		<cfinvoke component="xmp" method="xmpparse" thestruct="#arguments.thestruct#" returnvariable="arguments.thestruct.thexmp" />
		<!--- resize original to thumb --->
		<cfinvoke method="resizeImage" thestruct="#arguments.thestruct#" />
		<!--- storing assets on file system --->
		<cfset arguments.thestruct.storage = application.razuna.storage>
		<!--- DB update --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		UPDATE #session.hostdbprefix#images
		SET
		img_filename_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">, 
		img_meta = <cfqueryparam value="#arguments.thestruct.img_meta#" cfsqltype="cf_sql_varchar">
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<!--- Write the Keywords and Description to the DB (if we are JPG we parse XMP and add them together) --->
		<cftry>
			<!--- Set Variable --->
			<cfset arguments.thestruct.assetpath = arguments.thestruct.qrysettings.set2_path_to_assets>
			<!--- Store XMP values in DB --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #session.hostdbprefix#xmp
			(id_r, asset_type, subjectcode, creator, title, authorsposition, captionwriter, ciadrextadr, category, supplementalcategories, urgency,
			description, ciadrcity, ciadrctry, location, ciadrpcode, ciemailwork, ciurlwork, citelwork, intellectualgenre, instructions, source, 
			usageterms, copyrightstatus, transmissionreference, webstatement, headline, datecreated, city, ciadrregion, country, countrycode, 
			scene, state, credit, rights, colorspace, xres, yres, resunit, host_id)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="img">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsubjectcode#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.creator#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.title#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.authorstitle#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.descwriter#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcaddress#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.category#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.categorysub#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.urgency#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.description#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccity#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccountry#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptclocation#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptczip#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcemail#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcwebsite#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcphone#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcintelgenre#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcinstructions#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcsource#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcusageterms#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copystatus#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcjobidentifier#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copyurl#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcheadline#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcdatecreated#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecity#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagestate#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountry#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcimagecountrycode#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcscene#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptcstate#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.iptccredit#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.copynotice#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.colorspace#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.xres#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.yres#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thexmp.resunit#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			)
			</cfquery>
			<cfcatch type="any">
				<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="error in images text table for jpg">
					<cfdump var="#cfcatch#" />
				</cfmail>
			</cfcatch>
		</cftry>
		<!--- Move or upload to the right places --->
		<!--- If we are local --->
		<cfif arguments.thestruct.storage EQ "local">
			<!--- Create folder with the asset id --->
			<cfif NOT directoryexists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#" mode="775">
			</cfif>
			<!--- Move original image --->
			<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
				<cfif application.razuna.rfs OR arguments.thestruct.importpath>
					<cfset var fileaction = "copy">
				<cfelse>
					<cfset var fileaction = "move">
				</cfif>
				<cffile action="#fileaction#" source="#arguments.thestruct.thesourceraw#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" mode="775">
			</cfif>
			<!--- Move thumbnail --->
			<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
				<cffile action="move" source="#arguments.thestruct.destinationraw#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" mode="775">
			<cfelseif !application.razuna.rfs>
				<cffile action="move" source="#arguments.thestruct.destinationraw#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" mode="775">
			</cfif>
			<!--- Get size of original and thumnail --->
			<cfset orgsize = arguments.thestruct.qryfile.thesize>
			<cfif !application.razuna.rfs>
				<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.qrysettings.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" returnvariable="thumbsize">
			<cfelse>
				<!--- For renderingfarm we just set the thumbsize to 1 so we don't get errors doing inserts --->
				<cfset thumbsize = 1>
			</cfif>
			<!--- NIRVANIX --->
			<cfelseif arguments.thestruct.storage EQ "nirvanix">
				<cfset uplt = "u" & Createuuid("")>
				<!--- Upload Original Image --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cftry>
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#">
							<cfinvokeargument name="uploadfile" value="#arguments.thestruct.thesource#">
							<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
						</cfinvoke>
						<cfcatch type="any">
							<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error in uploading original image to Nirvanix" dump="#cfcatch#">
						</cfcatch>
					</cftry>
				</cfif>
				<!--- Upload Thumbnail --->
				<cfif !application.razuna.rfs>
					<cftry>
						<cfthread name="upload#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" priority="HIGH">
							<cfinvoke component="nirvanix" method="Upload">
								<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#">
								<cfinvokeargument name="uploadfile" value="#attributes.intstruct.destination#">
								<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
							</cfinvoke>
						</cfthread>
						<!--- Wait for thread to finish --->
						<cfthread action="join" name="upload#arguments.thestruct.newid#" />
						<cfcatch type="any">
							<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error in uploading thumbnail image to Nirvanix" dump="#cfcatch#">
						</cfcatch>
					</cftry>
					<!--- Get thumb file size --->
					<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.destination#" returnvariable="thumbsize">
					<!--- Get signed URL --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" nvxsession="#arguments.thestruct.nvxsession#">
				<cfelse>
					<cfset thumbsize = 1>
					<cfset cloud_url.theurl = "">
				</cfif>
				<!--- Get size of original --->
				<cfset orgsize = arguments.thestruct.qryfile.thesize>
				<!--- Get signed URLS for original --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- AMAZON --->
			<cfelseif arguments.thestruct.storage EQ "amazon">
				<cftry>
					<!--- Upload Original Image --->
					<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
						<cfset upt = Createuuid("")>
						<cfthread name="#upt#" intstruct="#arguments.thestruct#" priority="HIGH">
							<cfinvoke component="amazon" method="Upload">
								<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/#attributes.intstruct.qryfile.filename#">
								<cfinvokeargument name="theasset" value="#attributes.intstruct.thesourceraw#">
								<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
							</cfinvoke>
						</cfthread>
						<cfthread action="join" name="#upt#" />
					</cfif>
					<!--- Upload Thumbnail --->
					<cfif !application.razuna.rfs>
						<cfset uptn = Createuuid("")>
						<cfthread name="#uptn#" intstruct="#arguments.thestruct#" priority="HIGH">
							<cfinvoke component="amazon" method="Upload">
								<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/img/#attributes.intstruct.newid#/thumb_#attributes.intstruct.newid#.#attributes.intstruct.qrysettings.set2_img_format#">
								<cfinvokeargument name="theasset" value="#attributes.intstruct.destinationraw#">
								<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
							</cfinvoke>
						</cfthread>
						<cfthread action="join" name="#uptn#" />
						<!--- Get size thumnail --->
						<cfinvoke component="global" method="getfilesize" filepath="#arguments.thestruct.destination#" returnvariable="thumbsize">
						<!--- Get signed URLS for thumb --->
						<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/thumb_#arguments.thestruct.newid#.#arguments.thestruct.qrysettings.set2_img_format#" awsbucket="#arguments.thestruct.awsbucket#">
					<cfelse>
						<cfset thumbsize = 1>
						<cfset cloud_url.theurl = "">
					</cfif>
					<!--- Get size of original --->
					<cfset orgsize = arguments.thestruct.qryfile.thesize>
					<!--- Get signed URLS original --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfile.folder_id#/img/#arguments.thestruct.newid#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#">
					<cfcatch type="any">
						<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error in image upload to amazon" dump="#cfcatch#">
					</cfcatch>
				</cftry>
			</cfif>
			<!--- Orgsize and thumbsize variables are not here --->
			<cfif NOT isdefined(orgsize)>
				<cfset orgsize = arguments.thestruct.qryfile.thesize>
			</cfif>
			<cfif NOT isdefined(thumbsize)>
				<cfset thumbsize = 0>
			</cfif>
			<!--- Update DB with the sizes from above --->
			<cftransaction>
				<cfquery datasource="#arguments.thestruct.dsn#">
				UPDATE #session.hostdbprefix#images
				SET 
				img_size = <cfqueryparam value="#orgsize#" cfsqltype="cf_sql_numeric">, 
				thumb_size = <cfqueryparam value="#thumbsize#" cfsqltype="cf_sql_numeric">,
				hashtag = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.md5hash#">
				<!--- AMAZON --->
				<cfif arguments.thestruct.storage EQ "amazon" OR arguments.thestruct.storage EQ "nirvanix">
					,
					cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
					cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
					cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">				
				</cfif>
				WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				</cfquery>
			</cftransaction>
		</cfif>
	<!--- return --->
	<cfreturn />
</cffunction>

<!--- CHECK IF AN IMAGE IS AN ANIMATED GIF --->
<cffunction hint="CHECK IF AN IMAGE IS AN ANIMATED GIF" name="isAnimatedGIF" returntype="boolean">
<cfargument name="imagepath" required="yes" type="string" hint="Full path to the image-file, including filename and -ending">
<cfargument name="thepathim" required="yes" type="string" hint="Path to ImageMagick-folder">
<!--- declare function-internal variables --->
<cfset var theidentifyresult = "">
<cfset var thescript = createuuid()>
<!--- check if file ends with ".gif" --->
<cfif	Right(arguments.imagepath, 4) eq ".gif">
	<!--- Check the platform and then decide on the ImageMagick tag --->
	<cfif isWindows()>
		<cfset var theidentify = """#Arguments.thepathim#/identify.exe""">
		<cfset var thearguments = """#arguments.imagepath#""">
	<cfelse>
		<cfset var theidentify = "#Arguments.thepathim#/identify">
		<cfset var thearguments = replace(arguments.imagepath," ","\ ","all")>
		<cfset thearguments = replace(thearguments,"&","\&","all")>
		<cfset thearguments = replace(thearguments,"'","\'","all")>
	</cfif>
	<!--- get image information as string using identify (ImageMagick)
	<cfexecute name="#theidentify#" arguments="#arguments.imagepath#" timeout="5" variable="theidentifyresult" /> --->
	<cfset var thesh = gettempdirectory() & "/#thescript#.sh">
	<!--- On Windows a bat --->
	<cfif isWindows()>
		<cfset thesh = gettempdirectory() & "/#thescript#.bat">
	</cfif>
	<!--- Write files --->
	<cffile action="write" file="#thesh#" output="#theidentify# #thearguments#" mode="777">
	<!--- Execute --->
	<cfexecute name="#thesh#" timeout="60" variable="theidentifyresult" />
	<!--- Delete scripts --->
	<cffile action="delete" file="#thesh#">
	<!--- check if first char after file-path is "[" --->
	<cfif Mid(theidentifyresult, Len(arguments.imagepath)+1, 1) eq "[">
		<cfreturn 1>
	</cfif>
</cfif>
<cfreturn 0>
</cffunction>

<!--- RESIZE IMAGE ------------------------------------------------------------------------------->
<cffunction name="resizeImage" returntype="void" access="public" output="false">
	<cfargument name="thestruct" type="struct" required="true">
	<!--- RFS --->
	<cfif !application.razuna.rfs>
		<!--- ID for thread --->
		<cfset var tri = createuuid("")>
		<cfthread name="#tri#" intstruct="#arguments.thestruct#" priority="LOW">
			<cfinvoke method="resizeImagethread" thestruct="#attributes.intstruct#" />
		</cfthread>
		<cfthread action="join" name="#tri#" timeout="240000" />
	</cfif>
</cffunction>

<!--- RESIZE IMAGE ------------------------------------------------------------------------------->
<cffunction name="resizeImagethread" returntype="void" access="public" output="false">
	<cfargument name="thestruct" type="struct" required="true">
	<cftry>
		<!--- function internal variables --->
		<cfset var isAnimGIF = isAnimatedGIF(arguments.thestruct.thesource, arguments.thestruct.thetools.imagemagick)>
		<cfset var theimconvert = "">
		<cfset var theImgConvertParams = "-thumbnail #arguments.thestruct.width#x -strip -colorspace sRGB">
		<!--- validate input --->
		<cfif FileExists(arguments.thestruct.destination)>
			<!--- <cfthrow message="Destination-file already exists!"> --->
			<cffile action="delete" file="#arguments.thestruct.destination#" />
		</cfif>
		<!--- Check the platform and then decide on the ImageMagick/DCRaw tag --->
		<cfif isWindows()>
			<cfset arguments.thestruct.theimconvert = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
			<cfset arguments.thestruct.themogrify = """#arguments.thestruct.thetools.imagemagick#/mogrify.exe""">
			<cfset arguments.thestruct.thedcraw = """#arguments.thestruct.thetools.dcraw#/dcraw.exe""">
		<cfelse>
			<cfset arguments.thestruct.theimconvert = "#arguments.thestruct.thetools.imagemagick#/convert">
			<cfset arguments.thestruct.themogrify = "#arguments.thestruct.thetools.imagemagick#/mogrify">
			<cfset arguments.thestruct.thedcraw = "#arguments.thestruct.thetools.dcraw#/dcraw">
		</cfif>
		<!--- ImageMagick: Create Thumbnail.
		Some images can not be converted thus we just copy the original so we have a thumbnail --->
		<cfset reimtt = Createuuid("")>
		<!--- Write the sh script files --->
		<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#reimtt#.sh">
		<cfset arguments.thestruct.theshm = GetTempDirectory() & "/#reimtt#m.sh">
		<cfset arguments.thestruct.theshht = GetTempDirectory() & "/#reimtt#ht.sh">
		<cfset arguments.thestruct.theshwt = GetTempDirectory() & "/#reimtt#wt.sh">
		<!--- On Windows a .bat --->
		<cfif iswindows()>
			<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#reimtt#.bat">
			<cfset arguments.thestruct.theshm = GetTempDirectory() & "/#reimtt#m.bat">
			<cfset arguments.thestruct.theshht = GetTempDirectory() & "/#reimtt#ht.bat">
			<cfset arguments.thestruct.theshwt = GetTempDirectory() & "/#reimtt#wt.bat">
		</cfif>
		<!--- Set correct width or heigth --->
		<cfif arguments.thestruct.thexmp.orgwidth EQ "" OR arguments.thestruct.thexmp.orgheight EQ "">
			<cfset theImgConvertParams = "-thumbnail #arguments.thestruct.width#x -strip -colorspace sRGB">
		<cfelseif arguments.thestruct.thexmp.orgheight LTE arguments.thestruct.height AND arguments.thestruct.thexmp.orgwidth LTE arguments.thestruct.width>
			<cfset theImgConvertParams = "-strip -colorspace sRGB">
		<cfelseif arguments.thestruct.thexmp.orgwidth GT arguments.thestruct.width>
			<cfset theImgConvertParams = "-thumbnail #arguments.thestruct.width#x -strip -colorspace sRGB">
		<cfelseif arguments.thestruct.thexmp.orgheight GT arguments.thestruct.height>
			<cfset theImgConvertParams = "-thumbnail x#arguments.thestruct.height# -strip -colorspace sRGB">
		</cfif>
		<!--- correct ImageMagick-convert params for animated GIFs --->
		<cfif isAnimGIF>
			<cfset theImgConvertParams = "-coalesce " & theImgConvertParams>
		</cfif>
		<cfset arguments.thestruct.theimargumentsmog = "">
		<!--- Switch to create correct arguments to pass for executables --->
		<cfswitch expression="#arguments.thestruct.qryfile.extension#">
			<!--- If the file is a PSD, AI or EPS we have to layer it to zero --->
			<cfcase value="psd,eps,ai">
				<cfset arguments.thestruct.theimarguments = "#arguments.thestruct.theimconvert# #arguments.thestruct.thesource#[0] #theImgConvertParams# -flatten #Arguments.thestruct.destination#">
			</cfcase>
			<!--- For RAW images we take dcraw --->
			<cfcase value="3fr,ari,arw,srf,sr2,bay,crw,cr2,cap,iiq,eip,dcs,dcr,drf,k25,kdc,erf,fff,mef,mos,mrw,nef,nrw,orf,ptx,pef,pxn,r3d,raf,raw,rw2,rwl,dng,rwz,x3f">
				<cfset arguments.thestruct.theimarguments = "#arguments.thestruct.thedcraw# -c -e #arguments.thestruct.thesource# > #Arguments.thestruct.destination#">
				<cfset arguments.thestruct.theimargumentsmog = "#arguments.thestruct.themogrify# #theImgConvertParams# #Arguments.thestruct.destination#">
			</cfcase>
			<!--- For everything else --->
			<cfdefaultcase>
				<cfset arguments.thestruct.theimarguments = "#arguments.thestruct.theimconvert# #arguments.thestruct.thesource# #theImgConvertParams# #Arguments.thestruct.destination#">
			</cfdefaultcase>
		</cfswitch>
		<!--- Write script file to create thumbnail --->
		<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theimarguments#" mode="777">
		<cffile action="write" file="#arguments.thestruct.theshm#" output="#arguments.thestruct.theimargumentsmog#" mode="777">
		<!--- Convert the original --->
		<cfthread name="c#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" priority="LOW">
			<cfexecute name="#attributes.intstruct.thesh#" timeout="240000" />
		</cfthread>
		<!--- Wait until Thumbnail is done --->
		<cfthread action="join" name="c#arguments.thestruct.newid#" timeout="240000" />
		<!--- Convert for raw --->
		<cfthread name="m#arguments.thestruct.newid#" intstruct="#arguments.thestruct#" priority="LOW">
			<cfexecute name="#attributes.intstruct.theshm#" timeout="240000" />
		</cfthread>
		<!--- Wait until Thumbnail is done --->
		<cfthread action="join" name="m#arguments.thestruct.newid#" timeout="240000" />
		<!--- Check if thumbail is here if not copy missing image --->
		<cfif !fileexists(arguments.thestruct.destinationraw)>
			<cffile action="copy" source="#arguments.thestruct.rootpath#global/host/dam/images/icons/image_missing.png" destination="#arguments.thestruct.destinationraw#" mode="775" nameConflict="Skip">
		</cfif>
		<!--- Get thumbnail sizes --->
		<cffile action="write" file="#arguments.thestruct.theshht#" output="#arguments.thestruct.theexif# -S -s -ImageHeight #arguments.thestruct.destination#" mode="777">
		<cffile action="write" file="#arguments.thestruct.theshwt#" output="#arguments.thestruct.theexif# -S -s -ImageWidth #arguments.thestruct.destination#" mode="777">
		<!--- Get height and width --->
		<cfexecute name="#arguments.thestruct.theshht#" timeout="60" variable="thumbheight" />
		<cfexecute name="#arguments.thestruct.theshwt#" timeout="60" variable="thumbwidth" />
		<!--- Exiftool on windows return the whole path with the sizes thus trim and get last --->
		<cfset thumbheight = trim(listlast(thumbheight," "))>
		<cfset thumbwidth = trim(listlast(thumbwidth," "))>
		<!--- Remove the temp file sh --->
		<cffile action="delete" file="#arguments.thestruct.thesh#">
		<cffile action="delete" file="#arguments.thestruct.theshm#">
		<cffile action="delete" file="#arguments.thestruct.theshht#">
		<cffile action="delete" file="#arguments.thestruct.theshwt#">
		<!--- Sometimes identify does not get height and width thus we set it here --->
		<cfif arguments.thestruct.thexmp.orgwidth EQ "">
			<cfset arguments.thestruct.thexmp.orgwidth = 0>
			<cfset thumbwidth = 0>
		</cfif>
		<cfif arguments.thestruct.thexmp.orgheight EQ "">
			<cfset arguments.thestruct.thexmp.orgheight = 0>
			<cfset thumbheight = 0>
		</cfif>
		<!--- Set original and thumbnail width and height --->
		<cftransaction>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#images
			SET
			thumb_width = <cfqueryparam value="#thumbwidth#" cfsqltype="cf_sql_numeric">, 
			thumb_height = <cfqueryparam value="#thumbheight#" cfsqltype="cf_sql_numeric">, 
			img_width = <cfqueryparam value="#arguments.thestruct.thexmp.orgwidth#" cfsqltype="cf_sql_numeric">, 
			img_height = <cfqueryparam value="#arguments.thestruct.thexmp.orgheight#" cfsqltype="cf_sql_numeric">
			WHERE img_id = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cftransaction>
		<cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="assets.cfc resizeImage">
				<cfdump var="#cfcatch#" />
			</cfmail>
		</cfcatch>
	</cftry>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Check for plattform --->
<cffunction name="isWindows" returntype="boolean" access="public" output="false">
	<!--- function internal variables --->
	<!--- function body --->
	<cfreturn FindNoCase("Windows", server.os.name)>
</cffunction>

<!--- GET FILE AND EXTENSION ------------------------------------------------------------------------->
<cffunction hint="GET FILE AND EXTENSION" name="getFileExtension" output="true" returntype="struct">
	<cfargument name="thefilename" default="" required="yes" type="string">
	<!--- Get the file extension --->
	<cfset fileNameExt.theExt  = "#lcase(listLast(listRest(arguments.thefilename, '.'), '.'))#">
	<!--- Get the file name --->
	<cfif fileNameExt.theExt NEQ "">
		<cfset lenFile = #len(arguments.thefilename)# - #len(fileNameExt.theExt)# - 1>
		<cfset fileNameExt.theName = "#left(arguments.thefilename, lenFile)#">
	<cfelse>
		<cfset fileNameExt.theName = "#arguments.thefilename#">
	</cfif>
	<cfreturn fileNameExt>
</cffunction>

<!--- PROCESS A VIDEO-FILE ----------------------------------------------------------------------->
<cffunction name="processVidFile" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var cloud_url = structnew()>
	<cfset var cloud_url_org = structnew()>
	<cfset cloud_url.theurl = "">
	<cfset cloud_url_org.theurl = "">
	<cfset cloud_url_org.newepoch = 0>
	<cfset arguments.thestruct.thisvid = structnew()>
	<cfparam name="arguments.thestruct.vid_online" default="F">
	<cfset arguments.thestruct.dsn = variables.dsn>
	<cfset arguments.thestruct.database = variables.database>
	<cfset arguments.thestruct.hostid = session.hostid>
	<cfset arguments.thestruct.theuserid = session.theuserid>
	<cfset arguments.thestruct.storage = application.razuna.storage>
	<cfset arguments.thestruct.theplaceholderpic = arguments.thestruct.rootpath & "global/host/dam/images/placeholders/nopic.jpg">
	<!--- init function internal vars --->
	<cfset var theDBurl = "">
	<cfset var iLoop = "">
	<cfset var vid_meta = "">
	<!--- function body --->
	<cfset arguments.thestruct.iswindows = iswindows()>
	<!--- If we are a new version --->
	<cfif arguments.thestruct.qryfile.file_id NEQ 0>
		<!--- Call versions component to do the versions thingy --->
		<cfinvoke component="versions" method="create" thestruct="#arguments.thestruct#">
		<!--- Set the newid --->
		<cfset arguments.thestruct.thisvid.newid = 1>
	<!--- For normal adding --->
	<cfelse>	
		<!--- Create a new ID for the video --->
		<cfset arguments.thestruct.thisvid.newid = arguments.thestruct.qryfile.tempid>
		<!--- Insert record --->		
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#videos
		(vid_id, vid_name_org, host_id, folder_id_r, path_to_asset)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.thisvid.newid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.filename#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.qryfile.folder_id#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#">
		)
		</cfquery>
		<!--- Put together the filenames --->
		<cfset arguments.thestruct.thisvid.theorgimage = replacenocase(arguments.thestruct.qryfile.filename,".#arguments.thestruct.qryfile.extension#",".jpg","one")>
		<!--- All below only if NOT from a link --->
		<cfif arguments.thestruct.qryfile.link_kind NEQ "url">
			<!--- if importpath --->
			<cfif arguments.thestruct.importpath>
				<!--- Create var with temp directory --->
				<cfset arguments.thestruct.thetempdirectory = "#arguments.thestruct.thepath#/incoming/#createuuid('')#">
				<!--- Create temp folder --->
				<cfdirectory action="create" directory="#arguments.thestruct.thetempdirectory#" mode="775">
			</cfif>
			<!--- For LOCAL storage --->
			<cfif application.razuna.storage EQ "local">
				<!--- The final path of the asset --->
				<cfset arguments.thestruct.thisvid.finalpath = "#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#">
				<cfif !arguments.thestruct.importpath>
					<cfset arguments.thestruct.thetempdirectory = arguments.thestruct.thisvid.finalpath>
				</cfif>
				<!--- Create the directory --->
				<cfdirectory action="create" directory="#arguments.thestruct.thisvid.finalpath#" mode="775">
				<!--- Move original --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cffile action="copy" source="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" destination="#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#" mode="775">
				</cfif>
			<!--- NIRVANIX / AMAZON --->
			<cfelseif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
				<!--- Just assign the current path to the finalpath --->
				<cfset arguments.thestruct.thisvid.finalpath = "#arguments.thestruct.qryfile.path#">
				<cfif !arguments.thestruct.importpath>
					<cfset arguments.thestruct.thetempdirectory = arguments.thestruct.thisvid.finalpath>
				</cfif>
			</cfif>
			<!--- Create thumbnail --->
			<cfthread name="preview#arguments.thestruct.thisvid.newid#" intstruct="#arguments.thestruct#" priority="LOW">
				<cfinvoke component="videos" method="create_previews" thestruct="#attributes.intstruct#">
			</cfthread>
			<!--- Wait --->
			<cfthread action="join" name="preview#arguments.thestruct.thisvid.newid#" />
			<!--- Check the platform and then decide on the ImageMagick tag --->
			<cfif isWindows()>
				<cfset arguments.thestruct.theidentify = """#arguments.thestruct.thetools.imagemagick#/identify.exe""">
				<cfset arguments.thestruct.theexif = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
				<cfset arguments.thestruct.theorg = """#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thisvid.theorgimage#""">
				<!--- If local link --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
					<cfset arguments.thestruct.theasset = """#arguments.thestruct.qryfile.path#""">
					<cfset arguments.thestruct.theassetraw = arguments.thestruct.qryfile.path>
				<cfelse>
					<cfset arguments.thestruct.theasset = """#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#""">
					<cfset arguments.thestruct.theassetraw = "#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#">
				</cfif>
			<cfelse>
				<cfset arguments.thestruct.theidentify = "#arguments.thestruct.thetools.imagemagick#/identify">
				<cfset arguments.thestruct.theexif = "#arguments.thestruct.thetools.exiftool#/exiftool">
				<cfset arguments.thestruct.theorg = "#arguments.thestruct.thetempdirectory#/#arguments.thestruct.thisvid.theorgimage#">
				<!--- If local link --->
				<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
					<cfset arguments.thestruct.theasset = "#arguments.thestruct.qryfile.path#">
					<cfset arguments.thestruct.theassetraw = arguments.thestruct.qryfile.path>
				<cfelse>
					<cfset arguments.thestruct.theasset = "#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#">
					<cfset arguments.thestruct.theassetraw = "#arguments.thestruct.thisvid.finalpath#/#arguments.thestruct.qryfile.filename#">
				</cfif>
				<cfset arguments.thestruct.theorg = replace(arguments.thestruct.theorg," ","\ ","all")>
				<cfset arguments.thestruct.theorg = replace(arguments.thestruct.theorg,"&","\&","all")>
				<cfset arguments.thestruct.theorg = replace(arguments.thestruct.theorg,"'","\'","all")>
				<cfset arguments.thestruct.theasset = replace(arguments.thestruct.theasset," ","\ ","all")>
				<cfset arguments.thestruct.theasset = replace(arguments.thestruct.theasset,"&","\&","all")>
				<cfset arguments.thestruct.theasset = replace(arguments.thestruct.theasset,"'","\'","all")>
			</cfif>
			<!--- Get image width --->
			<cfset var thescript = arguments.thestruct.thisvid.newid>
			<cfset arguments.thestruct.thesh = gettempdirectory() & "/#thescript#.sh">
			<cfset arguments.thestruct.thesht = gettempdirectory() & "/#thescript#t.sh">
			<cfset arguments.thestruct.theshex = gettempdirectory() & "/#thescript#ex.sh">
			<!--- On Windows a bat --->
			<cfif isWindows()>
				<cfset arguments.thestruct.thesh = gettempdirectory() & "/#thescript#.bat">
				<cfset arguments.thestruct.thesht = gettempdirectory() & "/#thescript#t.bat">
				<cfset arguments.thestruct.theshex = gettempdirectory() & "/#thescript#ex.bat">
			</cfif>
			<!--- Write files --->
			<cffile action="write" file="#arguments.thestruct.thesh#" output="#arguments.thestruct.theexif# -S -s -ImageWidth #arguments.thestruct.theorg#" mode="777">
			<cffile action="write" file="#arguments.thestruct.thesht#" output="#arguments.thestruct.theexif# -S -s -ImageHeight #arguments.thestruct.theorg#" mode="777">
			<cffile action="write" file="#arguments.thestruct.theshex#" output="#arguments.thestruct.theexif# -a -g #arguments.thestruct.theasset#" mode="777">
			<!--- Execute --->
			<cfif !application.razuna.rfs>
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" variable="orgwidth" />
				<cfexecute name="#arguments.thestruct.thesht#" timeout="60" variable="orgheight" />
				<!--- Exiftool on windows return the whole path with the sizes thus trim and get last --->
				<cfset orgwidth = trim(listlast(orgwidth," "))>
				<cfset orgheight = trim(listlast(orgheight," "))>
				<cfpause interval=2 />
			</cfif>
			<cfexecute name="#arguments.thestruct.theshex#" timeout="60" variable="vid_meta" />
			<!--- Delete scripts --->
			<cffile action="delete" file="#arguments.thestruct.thesh#">
			<cffile action="delete" file="#arguments.thestruct.thesht#">
			<cffile action="delete" file="#arguments.thestruct.theshex#">
			<!--- NIRVANIX --->
			<cfif application.razuna.storage EQ "nirvanix">
				<!--- Upload Movie Image --->
				<cfif !application.razuna.rfs>
					<cfset upmi = Createuuid("")>
					<cfthread name="#upmi#" intstruct="#arguments.thestruct#" priority="HIGH">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait --->
					<cfthread action="join" name="#upmi#" />
					<!--- Get signed URL --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.thisvid.theorgimage#" nvxsession="#arguments.thestruct.nvxsession#">
				</cfif>
				<!--- Upload Movie --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfset upmt = Createuuid("")>
					<cfthread name="#upmt#" intstruct="#arguments.thestruct#" priority="HIGH">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait --->
					<cfthread action="join" name="#upmt#" />
				</cfif>
				<!--- Get signed URLS for movie --->
				<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.qryfile.filename#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- AMAZON --->
			<cfelseif application.razuna.storage EQ "amazon">
				<!--- Upload Movie Image --->
				<cfif !application.razuna.rfs>
					<cfset upmi = Createuuid("")>
					<cfthread name="#upmi#" intstruct="#arguments.thestruct#" priority="HIGH">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thetempdirectory#/#attributes.intstruct.thisvid.theorgimage#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmi#" />
					<!--- Get signed URL --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.thisvid.theorgimage#" awsbucket="#arguments.thestruct.awsbucket#">
				</cfif>
				<!--- Upload Movie --->
				<cfif arguments.thestruct.qryfile.link_kind NEQ "lan">
					<cfset upmt = Createuuid("")>
					<cfthread name="#upmt#" intstruct="#arguments.thestruct#" priority="HIGH">
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qryfile.folder_id#/vid/#attributes.intstruct.thisvid.newid#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.qryfile.path#/#attributes.intstruct.qryfile.filename#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<cfthread action="join" name="#upmt#" />
				</cfif>
				<!--- Get signed URLS for movie --->
				<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#arguments.thestruct.qryfile.folder_id#/vid/#arguments.thestruct.thisvid.newid#/#arguments.thestruct.qryfile.filename#" awsbucket="#arguments.thestruct.awsbucket#">
			</cfif>
			<cfset var ts = arguments.thestruct.qryfile.thesize>
			<cfif !application.razuna.rfs>
				<cfif isnumeric(orgwidth)>
					<cfset var tw = orgwidth>
				<cfelse>
					<cfset var tw = 1>
				</cfif>
				<cfif isnumeric(orgheight)>
					<cfset var th = orgheight>
				<cfelse>
					<cfset var th = 1>
				</cfif>
			</cfif>
		<!--- We come from a link thus assign some variables --->
		<cfelse arguments.thestruct.qryfile.link_kind EQ "url">
			<cfset var ts = 1>
			<cfset var tw = 1>
			<cfset var th = 1>
		</cfif>
		<!--- Set shared options --->
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#share_options
		(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.thisvid.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">,
		<cfqueryparam value="#arguments.thestruct.thisvid.newid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="vid" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="org" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
		<!--- Add the rest of informations to the video db --->
		<cfquery datasource="#variables.dsn#">
		UPDATE #session.hostdbprefix#videos
		SET
		vid_name_image = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thisvid.theorgimage#">,
		vid_size = <cfqueryparam cfsqltype="cf_sql_numeric" value="#ts#">,
		<cfif !application.razuna.rfs>
			vid_width = <cfqueryparam cfsqltype="cf_sql_numeric" value="#tw#">,
			vid_height = <cfqueryparam cfsqltype="cf_sql_numeric" value="#th#">,
		</cfif>
		vid_filename = 
		<cfif structkeyexists(arguments.thestruct, "theoriginalfilename")>
			<cfqueryparam value="#arguments.thestruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
		<cfelse>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.qryfile.filename#">
		</cfif>
		,
		vid_custom_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thisvid.newid#">,
		vid_online = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.vid_online#">,
		vid_owner = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
		vid_create_date = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		vid_change_date = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
		vid_change_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		vid_create_time = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		vid_single_sale = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">,
		vid_is_new = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">,
		vid_selection = <cfqueryparam cfsqltype="cf_sql_varchar" value="f">,
		vid_in_progress = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">,
		vid_extension = <cfqueryparam value="#arguments.thestruct.qryfile.extension#" cfsqltype="cf_sql_varchar">,
		link_kind = <cfqueryparam value="#arguments.thestruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">,
		link_path_url = <cfqueryparam value="#arguments.thestruct.qryfile.path#" cfsqltype="cf_sql_varchar">,
		vid_meta = <cfqueryparam value="#vid_meta#" cfsqltype="cf_sql_varchar">,
		hashtag = <cfqueryparam value="#arguments.thestruct.qryfile.md5hash#" cfsqltype="cf_sql_varchar">
		<cfif !application.razuna.rfs>
			,
			is_available = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif arguments.thestruct.qryfile.link_kind EQ "lan">
			,
			vid_name_org = <cfqueryparam value="#arguments.thestruct.lanorgname#" cfsqltype="cf_sql_varchar">
		<cfelse>
			,
			vid_name_org = <cfqueryparam value="#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
			,
			lucene_key = <cfqueryparam value="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" cfsqltype="cf_sql_varchar">,
			cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
			cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
			cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
		</cfif>
		WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.thisvid.newid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Add the TEXTS to the DB. We have to hide this is if we are coming from FCK --->
		<cfif arguments.thestruct.fieldname NEQ "NewFile" AND structkeyexists(arguments.thestruct,"langcount")>
			<cfloop list="#arguments.thestruct.langcount#" index="langindex">
				<cfif arguments.thestruct.uploadkind EQ "many">
					<cfset desc="file_desc_" & "#countnr#" & "_" & "#langindex#">
					<cfset keywords="file_keywords_" & "#countnr#" & "_" & "#langindex#">
					<cfset title="file_title_" & "#countnr#" & "_" & "#langindex#">
				<cfelse>
					<cfset desc="arguments.thestruct.file_desc_" & "#langindex#">
					<cfset keywords="arguments.thestruct.file_keywords_" & "#langindex#">
					<cfset title="arguments.thestruct.file_title_" & "#langindex#">
				</cfif>
				<cfif desc CONTAINS "#langindex#">
					<!--- check if form-vars are present. They will be missing if not coming from a user-interface (assettransfer, etc.) --->
					<cfif IsDefined(desc) and IsDefined(keywords) and IsDefined(title)>
						<cfquery datasource="#variables.dsn#">
							INSERT INTO #session.hostdbprefix#videos_text
							(id_inc, vid_id_r, lang_id_r, vid_description, vid_keywords, vid_title, host_id)
							VALUES(
							<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#arguments.thestruct.thisvid.newid#" cfsqltype="CF_SQL_VARCHAR">,
							<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
							<cfqueryparam value="#evaluate(desc)#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#evaluate(keywords)#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#evaluate(title)#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
							)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<!--- If there are metadata fields then add them here --->
		<cfif arguments.thestruct.metadata EQ 1>
			<!--- Check if API is called the old way --->
			<cfif structkeyexists(arguments.thestruct,"sessiontoken")>
				<cfinvoke component="global.api.asset" method="setmetadata">
					<cfinvokeargument name="sessiontoken" value="#arguments.thestruct.sessiontoken#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.thisvid.newid#">
					<cfinvokeargument name="assettype" value="vid">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
			<cfelse>
				<!--- API2 --->
				<cfinvoke component="global.api2.asset" method="setmetadata">
					<cfinvokeargument name="api_key" value="#arguments.thestruct.api_key#">
					<cfinvokeargument name="assetid" value="#arguments.thestruct.thisvid.newid#">
					<cfinvokeargument name="assettype" value="vid">
					<cfinvokeargument name="assetmetadata" value="#arguments.thestruct.assetmetadata#">
				</cfinvoke>
			</cfif>
		</cfif>
		<!--- Remove records which have no folder_id_r
		<cfquery datasource="#variables.dsn#">
		DELETE FROM #session.hostdbprefix#videos
		WHERE folder_id_r IS NULL
		</cfquery> --->
		<!--- Add to Lucene --->
		<cfif NOT structkeyexists(arguments.thestruct,"fromconverting")>
			<cfinvoke component="lucene" method="index_update" dsn="#variables.dsn#" thestruct="#arguments.thestruct#" assetid="#arguments.thestruct.thisvid.newid#" category="vid" online="#arguments.thestruct.vid_online#">
		</cfif>
		<!--- Log --->
		<cfset log = #log_assets(theuserid=session.theuserid,logaction='Add',logdesc='Added: #arguments.thestruct.qryfile.filename#',logfiletype='vid',assetid='#arguments.thestruct.thisvid.newid#')#>
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("videos")>
		<cfset variables.cachetoken = resetcachetoken("folders")>
		<cfset variables.cachetoken = resetcachetoken("general")>
		<!--- RFS --->
		<cfif application.razuna.rfs>
			<cfset arguments.thestruct.newid = arguments.thestruct.thisvid.newid>
			<cfset arguments.thestruct.assettype = "vid">
			<cfinvoke component="rfs" method="notify" thestruct="#arguments.thestruct#" />
		</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn arguments.thestruct.thisvid.newid />
</cffunction>

<!--- EXTRACT A COMPRESSED FILE (ZIP) ------------------------------------------------------------>
<cffunction name="extractFromZip" output="true" access="private">
	<cfargument name="thestruct" type="struct">	
	<cftry>
		<cfparam default="0" name="arguments.thestruct.upl_template">
		<cfzip action="extract" zipfile="#arguments.thestruct.qryfile.path#/#arguments.thestruct.qryfile.filename#" destination="#arguments.thestruct.qryfile.path#" timeout="900" charset="utf-8">
		<!--- Get folder level of the folder we are in to create new folder --->
		<cfquery datasource="#variables.dsn#" name="folders">
		SELECT folder_level, folder_main_id_r
		FROM #session.hostdbprefix#folders
		WHERE folder_id = <cfqueryparam value="#arguments.thestruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- set root folder id to keep top folder during creating folder out of zip archive --->
		<cfset rootfolderId = arguments.thestruct.qryfile.folder_id>
		<cfset folderId = arguments.thestruct.qryfile.folder_id>
		<cfset folderlevel = folders.folder_level>
		<cfset loopname = "">
		<!--- Loop over the zip directories and rename them if needed --->
		<cfset var ttf = Createuuid("")>
		<cfthread name="#ttf#" intstruct="#arguments.thestruct#">
			<cfinvoke method="rec_renamefolders" thedirectory="#attributes.intstruct.qryfile.path#" />
		</cfthread>
		<cfthread action="join" name="#ttf#" />
		<!--- Get directory again since the directory names could have changed from above --->
		<cfdirectory action="list" directory="#arguments.thestruct.qryfile.path#" name="thedir" recurse="true" sort="name" type="dir">
		<!--- Get folders within the unzip RECURSIVE --->
		<cfdirectory action="list" directory="#arguments.thestruct.qryfile.path#" name="thedirfiles" recurse="true" sort="name" type="file">
		<!--- Create Directories --->
		<cfset arguments.thestruct.theid = folderId>
		<cfset arguments.thestruct.folderlevel = folderlevel>
		<cfset arguments.thestruct.rid = rootfolderId>
		<cfset arguments.thestruct.fidr = 0>
		<cfloop query="thedir">
			<cfif thedir.attributes NEQ "H" AND NOT name CONTAINS ".svn" AND NOT name CONTAINS "__MACOSX" AND NOT name CONTAINS "MACOSX">
				<cfset arguments.thestruct.foldername = listlast(name,FileSeparator())>
				<cfset arguments.thestruct.thepathtofolder = replacenocase(name,arguments.thestruct.foldername,"","one")>
				<cfif arguments.thestruct.thepathtofolder NEQ arguments.thestruct.foldername AND arguments.thestruct.thepathtofolder NEQ "">
					<cfset f = arguments.thestruct.thepathtofolder & arguments.thestruct.foldername>
				<cfelse>
					<cfset f = arguments.thestruct.foldername>
				</cfif>
				<!--- Check to see if there are other folders in here --->
				<cfdirectory action="list" directory="#directory#/#f#" name="thedirsub" recurse="false" type="dir" sort="name">
				<!--- Get the folder id of the last directory --->
				<cfquery datasource="#variables.dsn#" name="lastfolderid">
				SELECT folder_id, folder_id_r
				FROM #session.hostdbprefix#folders
				WHERE lower(folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(listlast(arguments.thestruct.thepathtofolder,FileSeparator()))#">
				AND folder_main_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.rid#"> 
				<cfif arguments.thestruct.fidr NEQ 0>
					AND folder_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.fidr#">
				</cfif>
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- If there are records found then assign the folder_id to theid else take the one given below --->
				<cfif lastfolderid.recordcount NEQ 0>
					<cfset arguments.thestruct.theid = lastfolderid.folder_id>
				</cfif>
				<cfif thedirsub.recordcount GT 1>
					<cfset arguments.thestruct.folderlevel = arguments.thestruct.folderlevel>
				<cfelse>
					<cfset arguments.thestruct.folderlevel = arguments.thestruct.folderlevel + 1>
				</cfif>
				<!--- Call CFC folders to create the new folder --->
				<cfinvoke method="createfolderfromzip" thestruct="#arguments.thestruct#" returnvariable="thenewfid" />
				<cfif thedirsub.recordcount EQ 1>
					<cfset arguments.thestruct.theid = thenewfid>
					<cfset arguments.thestruct.folderlevel = arguments.thestruct.folderlevel + 1>
					<cfset arguments.thestruct.fidr = lastfolderid.folder_id_r>
				</cfif>
			</cfif>
		</cfloop>
		<cfset variables.cachetoken = resetcachetoken("folders")>
		<cfpause interval="2" />
		<!--- Loop over ZIP-filelist to process with the extracted files with check for the file since we got errors --->
		<cfloop query="thedirfiles">
			<cfif size NEQ 0 AND fileexists("#directory#/#name#") AND attributes NEQ "H" AND NOT name CONTAINS "thumbs.db" AND NOT name CONTAINS ".svn" AND NOT name CONTAINS "__MACOSX" AND NOT name CONTAINS "MACOSX">
				<cfset md5hash = "">
				<!--- Set Original FileName --->
				<cfset arguments.thestruct.theoriginalfilename = listlast(name,FileSeparator())>
				<cfset arguments.thestruct.thepathtoname = replacenocase(name,arguments.thestruct.theoriginalfilename,"","one")>
				<!--- Rename the file so that we can remove any spaces --->
				<cfinvoke component="global" method="convertname" returnvariable="newFileName" thename="#arguments.thestruct.theoriginalfilename#">
				<cffile action="rename" source="#directory#/#name#" destination="#directory#/#arguments.thestruct.thepathtoname#/#newFileName#">
				<!--- Detect file extension --->
				<cfinvoke method="getFileExtension" theFileName="#newFileName#" returnvariable="fileNameExt">
				<cfset file = structnew()>
				<cfset file.fileSize = "#size#">
				<cfset file.oldFileSize = "#size#">
				<cfset file.dateLastAccessed = "#dateLastModified#">
				<!--- Get and set file type and MIME content --->
				<cfquery datasource="#variables.dsn#" name="fileType">
				SELECT type_type, type_mimecontent, type_mimesubcontent
				FROM file_types
				WHERE lower(type_id) = <cfqueryparam value="#lcase(fileNameExt.theext)#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- set attributes of file structure --->
				<cfif #fileType.recordCount# GT 0>
					<cfset arguments.thestruct.thefiletype = fileType.type_type>
				<cfelse>
					<cfset arguments.thestruct.thefiletype = "other">
				</cfif>
				<cfset arguments.thestruct.tempid = createuuid("")>
				<cfset arguments.thestruct.thefilename = newFileName>
				<cfset arguments.thestruct.thefilenamenoext = replacenocase("#newFileName#", ".#fileNameExt.theext#", "", "ALL")>
				<cfset arguments.thestruct.theincomingtemppath = "#directory#/#arguments.thestruct.thepathtoname#">
				<!--- MD5 Hash --->
				<cfif FileExists("#directory#/#arguments.thestruct.thepathtoname#/#newfilename#")>
					<cfset md5hash = hashbinary("#directory#/#arguments.thestruct.thepathtoname#/#newfilename#")>
				</cfif>
				<!--- Check if we have to check for md5 records --->
				<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
				<!--- Check for the same MD5 hash in the existing records --->
				<cfif checkformd5>
					<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
				<cfelse>
					<cfset var md5here = 0>
				</cfif>
				<!--- If file does not exsist continue else send user an eMail --->
				<cfif md5here EQ 0>
					<!--- Get folder id with the name of the folder --->
					<cfquery datasource="#variables.dsn#" name="qryfolderidmain">
					SELECT f.folder_id, f.folder_name,
					CASE
						WHEN EXISTS(
							SELECT s.folder_id
							FROM raz1_folders s
							WHERE s.folder_id = f.folder_id_r
							AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
						) THEN 1
						ELSE 0
					END AS ISHERE
					FROM #session.hostdbprefix#folders f
					WHERE lower(f.folder_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(listlast("#directory#/#arguments.thestruct.thepathtoname#",FileSeparator()))#">
					AND f.folder_main_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#rootfolderId#">
					AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Subselect --->
					<cfquery dbtype="query" name="qryfolderid">
					SELECT *
					FROM qryfolderidmain
					WHERE ishere = 1
					</cfquery>
					<!--- Put folder id into the general struct --->
					<cfif qryfolderid.recordcount NEQ 0>
						<cfset arguments.thestruct.theid = qryfolderid.folder_id>
						<!--- <cfset arguments.thestruct.fidr = qryfolderid.folder_id_r> --->
					<cfelse>
						<cfset arguments.thestruct.theid = rootfolderId>
						<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.theincomingtemppath#">
						<!--- <cfset arguments.thestruct.fidr = 0> --->
					</cfif>
					<!--- Add to temp db --->
					<cfquery datasource="#variables.dsn#" name="qry">
					INSERT INTO #session.hostdbprefix#assets_temp
					(tempid,filename,extension,date_add,folder_id,who,filenamenoext,path<!---,mimetype--->,thesize,file_id,host_id,md5hash)
					VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#fileNameExt.theext#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.theid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.theincomingtemppath#">,
					<!--- <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.contentType#/#arguments.thestruct.contentSubType#">, --->
					<cfif isnumeric(file.fileSize)>
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#file.fileSize#">,
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_numeric" value="0">,
					</cfif>
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
					)
					</cfquery>
					<!--- Return IDs in a variable --->
					<!--- <cfset thetempids = arguments.thestruct.tempid & "," & thetempids> --->
					<!--- For each file we need query for the file --->
					<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qryfile">
					SELECT 
					tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, mimetype,
					thesize, groupid, sched_id, sched_action, file_id, link_kind, md5hash
					FROM #session.hostdbprefix#assets_temp
					WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
					<!--- Now start the file mumbo jumbo --->
					<cfif fileType.type_type EQ "img">
						<!--- IMAGE UPLOAD (call method to process a img-file) --->
						<cfinvoke method="processImgFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined">
							<cfset arguments.thestruct.upltemptype = "img">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelseif fileType.type_type EQ "vid">
						<!--- VIDEO UPLOAD (call method to process a vid-file) --->
						<cfinvoke method="processVidFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined">
							<cfset arguments.thestruct.upltemptype = "vid">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelseif fileType.type_type EQ "aud">
						<!--- AUDIO UPLOAD (call method to process a vid-file) --->
						<cfinvoke method="processAudFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
						<!--- Act on Upload Templates --->
						<cfif arguments.thestruct.upl_template NEQ 0 AND arguments.thestruct.upl_template NEQ "" AND arguments.thestruct.upl_template NEQ "undefined">
							<cfset arguments.thestruct.upltemptype = "aud">
							<cfset arguments.thestruct.file_id = returnid>
							<cfinvoke method="process_upl_template" thestruct="#arguments.thestruct#">
						</cfif>
					<cfelse>
						<!--- DOCUMENT UPLOAD (call method to process a doc-file) --->
						<cfinvoke method="processDocFile" thestruct="#arguments.thestruct#" returnVariable="returnid">
					</cfif>
					<!--- Clear the path for the loop
					<cfset arguments.thestruct.qryfile.path = replacenocase("#arguments.thestruct.qryfile.path#", "#zipFileList.directory#", "", "ALL")> --->
				<cfelse>
					<cfinvoke component="email" method="send_email" subject="Razuna: File #arguments.thestruct.thefilename# already exists" themessage="Hi there. The file (#arguments.thestruct.thefilename#) already exists in Razuna and thus was not added to the system!">
				</cfif>
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error in Zipextract within assets.cfc">
				<cfdump var="#cfcatch#" label="Catch" />
				<cfdump var="#arguments.thestruct#" label="Arguments" />
			</cfmail>
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- Recursive function to rename folders from zip --->
<cffunction name="rec_renamefolders" output="false" access="public" returnType="void">
	<cfargument name="thedirectory" type="string">
	<!--- Get folders within the unzip --->
	<cfdirectory action="list" directory="#arguments.thedirectory#" name="thedir" recurse="true" type="dir">
	<!--- Loop over the directories only to check for any foreign chars and convert it --->
	<cfloop query="thedir">
		<cfif thedir.attributes NEQ "H" AND NOT name CONTAINS "__MACOSX">
			<!--- All foreign chars are now converted, except the FileSeparator and - --->
			<cfset d = Rereplacenocase(name,"[^0-9A-Za-z\-\#FileSeparator()#]","","ALL")>
			<!--- Rename --->
			<cfif "#directory#/#name#" NEQ "#directory#/#d#">
				<cfdirectory action="rename" directory="#directory#/#name#" newdirectory="#directory#/#d#">
			</cfif>
		</cfif>
	</cfloop>
	<cfreturn />
</cffunction>

<!--- CREATE FOLDER FROM ZIP--->
<cffunction name="createfolderfromzip" output="true" access="private">
	<cfargument name="thestruct" type="struct">
	<!--- Check that the same folder does not already exist --->
	<!--- <cfquery datasource="#variables.dsn#" name="ishere">
	SELECT folder_id
	FROM #session.hostdbprefix#folders
	WHERE lower(folder_name) = <cfqueryparam value="#lcase(arguments.thestruct.foldername)#" cfsqltype="cf_sql_varchar">
	AND folder_id_r = <cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- If not the same folder here continue else abort --->
	<cfif ishere.recordcount EQ 0> --->
		<!--- Create a new ID --->
		<cfset newfolderid = createuuid("")>
		<!--- Add the Folder --->
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#folders
		(folder_id, folder_name, folder_level, folder_id_r, folder_main_id_r, folder_owner, folder_create_date, folder_change_date, folder_create_time, folder_change_time, host_id)
		values (
		<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#arguments.thestruct.foldername#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#arguments.thestruct.folderlevel#" cfsqltype="cf_sql_numeric">,
		<cfqueryparam value="#arguments.thestruct.theid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfif Val(arguments.thestruct.rid)>
			<cfqueryparam value="#arguments.thestruct.rid#" cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			<cfqueryparam value="#newfolderid#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>,
		<cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>
<!--- 	<cfelse>
		<cfset newfolderid = 0>
	</cfif> --->
	<cfreturn newfolderid />
</cffunction>

<!--- PROCESS A AUDIO-FILE -------------------------------------------------------------------->
	<cffunction name="processAudFile" output="true">
	<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfset arguments.thestruct.newid = 1>
		<!--- Get new id --->
		<cfset arguments.thestruct.newid = arguments.thestruct.qryfile.tempid>
		<cfquery datasource="#variables.dsn#">
		INSERT INTO #session.hostdbprefix#audios
		(aud_id)
		VALUES(<cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR">)
		</cfquery>
		<cfset arguments.thestruct.dsn = variables.dsn>
		<cfset arguments.thestruct.database = variables.database>
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset arguments.thestruct.hostdbprefix = session.hostdbprefix>
		<cfset arguments.thestruct.storage = application.razuna.storage>
		<cfset arguments.thestruct.theuserid = session.theuserid>
		<cfset arguments.thestruct.iswindows = iswindows()>
		<!--- thread --->
		<cfset var tt = Createuuid("")>
		<cfthread name="#tt#" audstruct="#arguments.thestruct#" priority="LOW">
			<!--- Params --->
			<cfset cloud_url = structnew()>
			<cfset cloud_url_2 = structnew()>
			<cfset cloud_url_org = structnew()>
			<cfset cloud_url_org.theurl = "">
			<cfset cloud_url.theurl = "">
			<cfset cloud_url_2.theurl = "">
			<cfset cloud_url_org.newepoch = 0>
			<!--- If we are a new version --->
			<cfif attributes.audstruct.qryfile.file_id NEQ 0>
				<!--- Call versions component to do the versions thingy --->
				<cfinvoke component="versions" method="create" thestruct="#attributes.audstruct#">
			<!--- This is for normal adding --->
			<cfelse>
				<!--- Dont do this if the link_kind is a url --->
				<cfif attributes.audstruct.qryfile.link_kind NEQ "url">
					<!--- Set the correct path --->
					<cfif attributes.audstruct.qryfile.link_kind EQ "lan">
						<!--- Create var with temp directory --->
						<cfset attributes.audstruct.thetempdirectory = "#attributes.audstruct.thepath#/incoming/#createuuid('')#">
						<cfset attributes.audstruct.theorgfile = "#attributes.audstruct.qryfile.path#">
						<cfset attributes.audstruct.theorgfileraw = attributes.audstruct.qryfile.path>
						<!--- Create temp folder --->
						<cfdirectory action="create" directory="#attributes.audstruct.thetempdirectory#" mode="775">
					<!--- if importpath --->
					<cfelseif attributes.audstruct.importpath>
						<!--- Create var with temp directory --->
						<cfset attributes.audstruct.thetempdirectory = "#attributes.audstruct.thepath#/incoming/#createuuid('')#">
						<cfset attributes.audstruct.theorgfile = "#attributes.audstruct.qryfile.path#/#attributes.audstruct.qryfile.filename#">
						<cfset attributes.audstruct.theorgfileraw = "#attributes.audstruct.qryfile.path#/#attributes.audstruct.qryfile.filename#">
						<!--- Create temp folder --->
						<cfdirectory action="create" directory="#attributes.audstruct.thetempdirectory#" mode="775">
					<cfelse>
						<cfset attributes.audstruct.thetempdirectory = attributes.audstruct.qryfile.path>
						<cfset attributes.audstruct.theorgfile = "#attributes.audstruct.qryfile.path#/#attributes.audstruct.qryfile.filename#">
						<cfset attributes.audstruct.theorgfileraw = "#attributes.audstruct.qryfile.path#/#attributes.audstruct.qryfile.filename#">
					</cfif>
					<!--- Check the platform and then decide on the Exiftool tag --->
					<cfif attributes.audstruct.iswindows>
						<cfset attributes.audstruct.theexe = """#attributes.audstruct.thetools.exiftool#/exiftool.exe""">
						<cfset attributes.audstruct.theexeff = """#attributes.audstruct.thetools.ffmpeg#/ffmpeg.exe""">
						<cfset attributes.audstruct.theorgfile4copy = attributes.audstruct.theorgfile>
						<cfset attributes.audstruct.filenamenoext4copy = attributes.audstruct.qryfile.filenamenoext>
						<cfset attributes.audstruct.theorgfile = attributes.audstruct.theorgfile>
					<cfelse>
						<cfset attributes.audstruct.theexe = "#attributes.audstruct.thetools.exiftool#/exiftool">
						<cfset attributes.audstruct.theexeff = "#attributes.audstruct.thetools.ffmpeg#/ffmpeg">
						<cfset attributes.audstruct.theorgfile4copy = attributes.audstruct.theorgfile>
						<cfset attributes.audstruct.filenamenoext4copy = attributes.audstruct.qryfile.filenamenoext>
						<cfset attributes.audstruct.theorgfile = replace(attributes.audstruct.theorgfile," ","\ ","all")>
						<cfset attributes.audstruct.theorgfile = replace(attributes.audstruct.theorgfile,"&","\&","all")>
						<cfset attributes.audstruct.theorgfile = replace(attributes.audstruct.theorgfile,"'","\'","all")>
						<cfset attributes.audstruct.qryfile.filenamenoext = replace(attributes.audstruct.qryfile.filenamenoext," ","\ ","all")>
						<cfset attributes.audstruct.qryfile.filenamenoext = replace(attributes.audstruct.qryfile.filenamenoext,"&","\&","all")>
						<cfset attributes.audstruct.qryfile.filenamenoext = replace(attributes.audstruct.qryfile.filenamenoext,"'","\'","all")>
					</cfif>
					<!--- Write the script --->
					<cfset thescript = Createuuid("")>
					<cfset attributes.audstruct.thesh = GetTempDirectory() & "/#thescript#.sh">
					<!--- On Windows a .bat --->
					<cfif attributes.audstruct.iswindows>
						<cfset attributes.audstruct.thesh = GetTempDirectory() & "/#thescript#.bat">
					</cfif>
					<!--- Write files --->
					<cffile action="write" file="#attributes.audstruct.thesh#" output="#attributes.audstruct.theexe# -g #attributes.audstruct.theorgfile#" mode="777">
					<!--- Execute --->
					<cfexecute name="#attributes.audstruct.thesh#" timeout="60" variable="idtags" />
					<!--- Delete scripts --->
					<cffile action="delete" file="#attributes.audstruct.thesh#">
					<!--- RFS --->
					<cfif !application.razuna.rfs>
						<!--- Create Raw file --->
						<cfif attributes.audstruct.qryfile.extension NEQ "wav">
							<!--- Write files --->
							<cffile action="write" file="#attributes.audstruct.thesh#" output="#attributes.audstruct.theexeff# -i #attributes.audstruct.theorgfile# #attributes.audstruct.thetempdirectory#/#attributes.audstruct.qryfile.filenamenoext#.wav" mode="777">
							<!--- Execute --->
							<cfthread name="wav#attributes.audstruct.newid#" intaudstruct="#attributes.audstruct#">
								<cfexecute name="#attributes.intaudstruct.thesh#" timeout="60" />
							</cfthread>
							<!--- Wait until the WAV is done --->
							<cfthread action="join" name="wav#attributes.audstruct.newid#" />
							<!--- Delete scripts --->
							<cffile action="delete" file="#attributes.audstruct.thesh#">
						</cfif>
						<!--- If we are a local link and are NOT a MP3 we create one to be able to play it in the browser --->
						<cfif attributes.audstruct.qryfile.link_kind EQ "lan" AND attributes.audstruct.qryfile.extension NEQ "mp3">
							<!--- Write files --->
							<cffile action="write" file="#attributes.audstruct.thesh#" output="#attributes.audstruct.theexeff# -i #attributes.audstruct.theorgfile# -ab 192k #attributes.audstruct.thetempdirectory#/#attributes.audstruct.qryfile.filenamenoext#.mp3" mode="777">
							<!--- Execute --->
							<cfthread name="wav#attributes.audstruct.newid#" intaudstruct="#attributes.audstruct#">
								<cfexecute name="#attributes.intaudstruct.thesh#" timeout="60" />
							</cfthread>
							<!--- Wait until the WAV is done --->
							<cfthread action="join" name="wav#attributes.audstruct.newid#" />
							<!--- Delete scripts --->
							<cffile action="delete" file="#attributes.audstruct.thesh#">
						<cfelseif attributes.audstruct.qryfile.link_kind EQ "lan" AND attributes.audstruct.qryfile.extension EQ "mp3">
							<cffile action="copy" source="#attributes.audstruct.theorgfile4copy#" destination="#attributes.audstruct.thetempdirectory#/#attributes.audstruct.filenamenoext4copy#.mp3" mode="775">
						</cfif>
					</cfif>
				<!--- If link_kind is url --->
				<cfelse>
					<cfset idtags = "">
				</cfif>
				<!--- append to the DB --->
				<cftransaction>
					<cfquery datasource="#attributes.audstruct.dsn#">
					UPDATE #attributes.audstruct.hostdbprefix#audios
					SET 
					folder_id_r = <cfqueryparam value="#attributes.audstruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">, 
					aud_create_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
					aud_change_date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
					aud_create_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
					aud_change_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					aud_owner = <cfqueryparam value="#attributes.audstruct.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
					aud_type = <cfqueryparam value="#attributes.audstruct.thefiletype#" cfsqltype="cf_sql_varchar">, 
					aud_name_noext = <cfqueryparam value="#attributes.audstruct.qryfile.filenamenoext#" cfsqltype="cf_sql_varchar">, 
					aud_extension = <cfqueryparam value="#attributes.audstruct.qryfile.extension#" cfsqltype="cf_sql_varchar">, 
					aud_name = 
						<cfif structkeyexists(attributes.audstruct, "theoriginalfilename")>
							<cfqueryparam value="#attributes.audstruct.theoriginalfilename#" cfsqltype="cf_sql_varchar">
						<cfelse>
							<cfqueryparam value="#attributes.audstruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
						</cfif>, 
					<!---
					aud_contenttype = <cfqueryparam value="#attributes.audstruct.ContentType#" cfsqltype="cf_sql_varchar">,
					aud_contentsubtype = <cfqueryparam value="#attributes.audstruct.ContentSubType#" cfsqltype="cf_sql_varchar">,
					--->
					aud_online = <cfqueryparam value="F" cfsqltype="cf_sql_varchar">, 
					aud_name_org = 
						<cfif attributes.audstruct.qryfile.link_kind EQ "lan">
							<cfqueryparam value="#attributes.audstruct.lanorgname#" cfsqltype="cf_sql_varchar">
						<cfelse>
							<cfqueryparam value="#attributes.audstruct.qryfile.filename#" cfsqltype="cf_sql_varchar">
						</cfif>,
					aud_size = <cfqueryparam value="#attributes.audstruct.qryfile.thesize#" cfsqltype="cf_sql_numeric">, 
					aud_meta = <cfqueryparam value="#idtags#" cfsqltype="cf_sql_varchar">, 
					link_kind = <cfqueryparam value="#attributes.audstruct.qryfile.link_kind#" cfsqltype="cf_sql_varchar">, 
					link_path_url = <cfqueryparam value="#attributes.audstruct.qryfile.path#" cfsqltype="cf_sql_varchar">, 
					host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.audstruct.hostid#">,
					path_to_asset = <cfqueryparam value="#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#" cfsqltype="cf_sql_varchar">,
					hashtag = <cfqueryparam value="#attributes.audstruct.qryfile.md5hash#" cfsqltype="cf_sql_varchar">
					<cfif attributes.audstruct.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
						, lucene_key = <cfqueryparam value="#attributes.audstruct.theorgfile#" cfsqltype="cf_sql_varchar">
					</cfif>
					WHERE aud_id = <cfqueryparam value="#attributes.audstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
				</cftransaction>
				<!--- Add the TEXTS to the DB. We have to hide this if we are coming from FCK --->
				<cftry>
					<cfif attributes.audstruct.fieldname NEQ "NewFile" AND structkeyexists(attributes.audstruct,"langcount")>
						<cfloop list="#attributes.audstruct.langcount#" index="langindex">
							<cfset desc="attributes.audstruct.file_desc_" & "#langindex#">
							<cfset keywords="attributes.audstruct.file_keywords_" & "#langindex#">
							<cfif desc CONTAINS "#langindex#">
								<!--- check if form-vars are present. They will be missing if not coming from a user-interface (assettransfer, etc.) --->
								<cfif IsDefined(desc) and IsDefined(keywords)>
									<cfquery datasource="#attributes.audstruct.dsn#">
									INSERT INTO #attributes.audstruct.hostdbprefix#audios_text
									(id_inc, aud_id_r, lang_id_r, 
									aud_description, aud_keywords, host_id)
									values(
									<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#attributes.audstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
									<cfqueryparam value="#evaluate(desc)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#evaluate(keywords)#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.audstruct.hostid#">
									)
									</cfquery>
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
					<cfcatch type="any">
						<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="error in file upload">
							<cfdump var="#cfcatch#" />
						</cfmail>
					</cfcatch>
				</cftry>
				<cfif attributes.audstruct.qryfile.link_kind NEQ "url">
					<!--- Move the file to its own directory --->
					<cfif attributes.audstruct.storage EQ "local">
						<!--- Create folder with the asset id --->
						<cfif !directoryexists("#attributes.audstruct.qrysettings.set2_path_to_assets#/#attributes.audstruct.hostid#/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#")>
							<cfdirectory action="create" directory="#attributes.audstruct.qrysettings.set2_path_to_assets#/#attributes.audstruct.hostid#/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#" mode="775">
						</cfif>
						<!--- Move the file from the temp path to this folder --->
						<cfif attributes.audstruct.qryfile.link_kind NEQ "lan">
							<cfif attributes.audstruct.importpath>
								<cfset theaction = "copy">
							<cfelse>
								<cfset theaction = "move">
							</cfif>
							<cffile action="#theaction#" source="#attributes.audstruct.theorgfileraw#" destination="#attributes.audstruct.qrysettings.set2_path_to_assets#/#attributes.audstruct.hostid#/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filename#" mode="775">
						</cfif>
						<!--- Move the WAV --->
						<cfif attributes.audstruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs>
							<cffile action="move" source="#attributes.audstruct.thetempdirectory#/#attributes.audstruct.filenamenoext4copy#.wav" destination="#attributes.audstruct.qrysettings.set2_path_to_assets#/#attributes.audstruct.hostid#/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.filenamenoext4copy#.wav" mode="775">
						</cfif>
						<!--- Move the MP3 but only if local asset link --->
						<cfif attributes.audstruct.qryfile.link_kind EQ "lan">
							<cffile action="move" source="#attributes.audstruct.thetempdirectory#/#attributes.audstruct.filenamenoext4copy#.mp3" destination="#attributes.audstruct.qrysettings.set2_path_to_assets#/#attributes.audstruct.hostid#/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.filenamenoext4copy#.mp3" mode="775">
						</cfif>
						<!--- Add to Lucene --->
						<cfinvoke component="lucene" method="index_update" dsn="#attributes.audstruct.dsn#" thestruct="#attributes.audstruct#" assetid="#attributes.audstruct.newid#" category="aud">
					<!--- NIRVANIX --->
					<cfelseif attributes.audstruct.storage EQ "nirvanix">
						<!--- Unique --->
						<cfset upa = Createuuid("")>
						<cfset upaw = "w" & upa>
						<cfset upam = "m" & upa>
						<!--- Add to Lucene --->
						<cfinvoke component="lucene" method="index_update" dsn="#attributes.audstruct.dsn#" thestruct="#attributes.audstruct#" assetid="#attributes.audstruct.newid#" category="aud">
						<!--- Upload file --->
						<cfif attributes.audstruct.qryfile.link_kind NEQ "lan">
							<cfthread name="#upa#" audupstruct="#attributes.audstruct#" priority="HIGH">
								<cfinvoke component="nirvanix" method="Upload">
									<cfinvokeargument name="destFolderPath" value="/#attributes.audupstruct.qryfile.folder_id#/aud/#attributes.audupstruct.newid#">
									<cfinvokeargument name="uploadfile" value="#attributes.audupstruct.theorgfile#">
									<cfinvokeargument name="nvxsession" value="#attributes.audupstruct.nvxsession#">
								</cfinvoke>
							</cfthread>
							<cfthread action="join" name="#upa#" />
						</cfif>
						<!--- Upload the WAV --->
						<cfif attributes.audstruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs>
							<cfthread name="#upaw#" audupstruct="#attributes.audstruct#" priority="HIGH">
								<cfinvoke component="nirvanix" method="Upload">
									<cfinvokeargument name="destFolderPath" value="/#attributes.audupstruct.qryfile.folder_id#/aud/#attributes.audupstruct.newid#">
									<cfinvokeargument name="uploadfile" value="#attributes.audupstruct.thetempdirectory#/#attributes.audupstruct.qryfile.filenamenoext#.wav">
									<cfinvokeargument name="nvxsession" value="#attributes.audupstruct.nvxsession#">
								</cfinvoke>
							</cfthread>
							<cfthread action="join" name="#upaw#" />
						</cfif>
						<!--- Move the MP3 but only if local asset link --->
						<cfif attributes.audstruct.qryfile.link_kind EQ "lan">
							<cfthread name="#upam#" audupstruct="#attributes.audstruct#" priority="HIGH">
								<cfinvoke component="nirvanix" method="Upload">
									<cfinvokeargument name="destFolderPath" value="/#attributes.audupstruct.qryfile.folder_id#/aud/#attributes.audupstruct.newid#">
									<cfinvokeargument name="uploadfile" value="#attributes.audupstruct.thetempdirectory#/#attributes.audupstruct.qryfile.filenamenoext#.mp3">
									<cfinvokeargument name="nvxsession" value="#attributes.audupstruct.nvxsession#">
								</cfinvoke>
							</cfthread>
							<cfthread action="join" name="#upam#" />
						</cfif>
						<!--- Get signed URLS --->
						<cfif attributes.audstruct.qryfile.link_kind NEQ "lan">
							<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_org" theasset="#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filename#" nvxsession="#attributes.audstruct.nvxsession#">
						</cfif>
						<cfif attributes.audstruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs>
							<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.wav" nvxsession="#attributes.audstruct.nvxsession#">
						</cfif>
						<cfif attributes.audstruct.qryfile.link_kind EQ "lan">
							<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url_2" theasset="#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.mp3" nvxsession="#attributes.audstruct.nvxsession#">
						</cfif>
						<!--- Update DB --->
						<cfquery datasource="#attributes.audstruct.dsn#">
						UPDATE #attributes.audstruct.hostdbprefix#audios
						SET 
						cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
						cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
						cloud_url_2 = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_2.theurl#">,
						cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
						WHERE aud_id = <cfqueryparam value="#attributes.audstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.audstruct.hostid#">
						</cfquery>
					<!--- AMAZON --->
					<cfelseif attributes.audstruct.storage EQ "amazon">
						<!--- Unique --->
						<cfset upa = Createuuid("")>
						<cfset upw = "w" & upa>
						<cfset upmp = "m" & upa>
						<!--- Add to Lucene --->
						<cfinvoke component="lucene" method="index_update" dsn="#attributes.audstruct.dsn#" thestruct="#attributes.audstruct#" assetid="#attributes.audstruct.newid#" category="aud">
						<!--- Upload file --->
						<cfif attributes.audstruct.qryfile.link_kind NEQ "lan">
							<cfthread name="#upa#" audstruct="#attributes.audstruct#" priority="HIGH">
								<cfinvoke component="amazon" method="Upload">
									<cfinvokeargument name="key" value="/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filename#">
									<cfinvokeargument name="theasset" value="#attributes.audstruct.theorgfile#">
									<cfinvokeargument name="awsbucket" value="#attributes.audstruct.awsbucket#">
								</cfinvoke>
							</cfthread>
							<cfthread action="join" name="#upa#" />
						</cfif>
						<!--- Upload the WAV --->
						<cfif attributes.audstruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs>
							<cfthread name="#upw#" audstruct="#attributes.audstruct#" priority="HIGH">
								<cfinvoke component="amazon" method="Upload">
									<cfinvokeargument name="key" value="/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.wav">
									<cfinvokeargument name="theasset" value="#attributes.audstruct.thetempdirectory#/#attributes.audstruct.qryfile.filenamenoext#.wav">
									<cfinvokeargument name="awsbucket" value="#attributes.audstruct.awsbucket#">
								</cfinvoke>
							</cfthread>
							<cfthread action="join" name="#upw#" />
						</cfif>
						<!--- Move the MP3 but only if local asset link --->
						<cfif attributes.audstruct.qryfile.link_kind EQ "lan">
							<cfthread name="#upmp#" audstruct="#attributes.audstruct#" priority="HIGH">
								<cfinvoke component="amazon" method="Upload">
									<cfinvokeargument name="key" value="/#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.mp3">
									<cfinvokeargument name="theasset" value="#attributes.audstruct.thetempdirectory#/#attributes.audstruct.qryfile.filenamenoext#.mp3">
									<cfinvokeargument name="awsbucket" value="#attributes.audstruct.awsbucket#">
								</cfinvoke>
							</cfthread>
							<cfthread action="join" name="#upmp#" />
						</cfif>
						<!--- Get signed URLS --->
						<cfif attributes.audstruct.qryfile.link_kind NEQ "lan">
							<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_org" key="#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filename#" awsbucket="#attributes.audstruct.awsbucket#">
						</cfif>
						<cfif attributes.audstruct.qryfile.extension NEQ "wav" AND !application.razuna.rfs>
							<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.wav" awsbucket="#attributes.audstruct.awsbucket#">
						</cfif>
						<cfif attributes.audstruct.qryfile.link_kind EQ "lan">
							<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url_2" key="#attributes.audstruct.qryfile.folder_id#/aud/#attributes.audstruct.newid#/#attributes.audstruct.qryfile.filenamenoext#.mp3" awsbucket="#attributes.audstruct.awsbucket#">
						</cfif>
						<!--- Update DB --->
						<cfquery datasource="#attributes.audstruct.dsn#">
						UPDATE #attributes.audstruct.hostdbprefix#audios
						SET 
						cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">,
						cloud_url_org = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_org.theurl#">,
						cloud_url_2 = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url_2.theurl#">,
						cloud_url_exp = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#cloud_url_org.newepoch#">
						WHERE aud_id = <cfqueryparam value="#attributes.audstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
						AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.audstruct.hostid#">
						</cfquery>
					</cfif>
				<!--- link_kind is url --->
				<cfelseif attributes.audstruct.qryfile.link_kind EQ "url">
					<!--- Add to Lucene --->
					<cfinvoke component="lucene" method="index_update" dsn="#attributes.audstruct.dsn#" thestruct="#attributes.audstruct#" assetid="#attributes.audstruct.newid#" category="aud">
				</cfif>
				<!--- Update DB to make asset available --->
				<cfif !application.razuna.rfs>
					<cfquery datasource="#attributes.audstruct.dsn#">
					UPDATE #attributes.audstruct.hostdbprefix#audios
					SET is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
					WHERE aud_id = <cfqueryparam value="#attributes.audstruct.newid#" cfsqltype="CF_SQL_VARCHAR">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#attributes.audstruct.hostid#">
					</cfquery>
				</cfif>
				<!--- Set shared options --->
				<cfquery datasource="#attributes.audstruct.dsn#">
				INSERT INTO #attributes.audstruct.hostdbprefix#share_options
				(asset_id_r, host_id, group_asset_id, folder_id_r, asset_type, asset_format, asset_dl, asset_order, rec_uuid)
				VALUES(
				<cfqueryparam value="#attributes.audstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#attributes.audstruct.hostid#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#attributes.audstruct.newid#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#attributes.audstruct.qryfile.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="aud" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="org" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
				<!--- If there are metadata fields then add them here --->
				<cfif attributes.audstruct.metadata EQ 1>
					<!--- Check if API is called the old way --->
					<cfif structkeyexists(attributes.audstruct,"sessiontoken")>
						<cfinvoke component="global.api.asset" method="setmetadata">
							<cfinvokeargument name="sessiontoken" value="#attributes.audstruct.sessiontoken#">
							<cfinvokeargument name="assetid" value="#attributes.audstruct.newid#">
							<cfinvokeargument name="assettype" value="aud">
							<cfinvokeargument name="assetmetadata" value="#attributes.audstruct.assetmetadata#">
						</cfinvoke>
					<cfelse>
						<!--- API2 --->
						<cfinvoke component="global.api2.asset" method="setmetadata">
							<cfinvokeargument name="api_key" value="#attributes.audstruct.api_key#">
							<cfinvokeargument name="assetid" value="#attributes.audstruct.newid#">
							<cfinvokeargument name="assettype" value="aud">
							<cfinvokeargument name="assetmetadata" value="#attributes.audstruct.assetmetadata#">
						</cfinvoke>
					</cfif>
				</cfif>
				<!--- Log --->
				<cfinvoke component="extQueryCaching" method="log_assets">
					<cfinvokeargument name="theuserid" value="#attributes.audstruct.theuserid#">
					<cfinvokeargument name="logaction" value="Add">
					<cfinvokeargument name="logdesc" value="Added: #attributes.audstruct.qryfile.filename#">
					<cfinvokeargument name="logfiletype" value="aud">
					<cfinvokeargument name="assetid" value="#attributes.audstruct.newid#">
				</cfinvoke>
				<!--- RFS --->
				<cfif application.razuna.rfs AND attributes.audstruct.qryfile.extension NEQ "wav" AND attributes.audstruct.newid NEQ 0>
					<cfset attributes.audstruct.assettype = "aud">
					<cfinvoke component="rfs" method="notify" thestruct="#attributes.audstruct#" />
				</cfif>
			</cfif>
		</cfthread>
		<!--- Join above thread --->
		<cfthread action="join" name="#tt#" />
		<!--- Flush Cache --->
		<cfset variables.cachetoken = resetcachetoken("audios")>
		<cfset variables.cachetoken = resetcachetoken("folders")>
		<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Return --->
	<cfreturn arguments.thestruct.newid />
</cffunction>

<!--- Get tempid record --->
<cffunction name="gettemprecord" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<cfset arguments.thestruct.tempid = replace(arguments.thestruct.tempid,"-","","ALL")>
	<cfquery datasource="#variables.dsn#" name="q">
		<!--- Oracle --->
		<cfif variables.database EQ "oracle">
			SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM (
				SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash 
				FROM #session.hostdbprefix#assets_temp
				WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
				AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
				ORDER BY date_add DESC
				)
			WHERE ROWNUM = 1
		<!--- H2 / MySQL --->
		<cfelseif variables.database EQ "mysql" OR variables.database EQ "h2">
			SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			ORDER BY date_add DESC
			Limit 1
		<cfelseif variables.database EQ "mssql">
			SELECT TOP 1 tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			ORDER BY date_add DESC
		<!--- DB2 --->
		<cfelseif variables.database EQ "db2">
			SELECT tempid,filename,extension,date_add,folder_id,who,filenamenoext,path,mimetype,thesize,file_id,md5hash
			FROM #session.hostdbprefix#assets_temp
			WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric">
			ORDER BY date_add DESC
			FETCH FIRST 1 ROW ONLY
		</cfif>
	</cfquery>
	<cfreturn q />
</cffunction>

<!--- Activate Preview Image --->
<cffunction name="previewimageactivate" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset var cloud_url = structnew()>
	<!--- Query the image --->
	<cfinvoke method="gettemprecord" thestruct="#arguments.thestruct#" returnVariable="qry" />
	<!--- If record return zero records then abort --->
	<cfif qry.recordcount NEQ 0>
		<!--- Query existing record --->	
		<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry_existing">
		SELECT path_to_asset
		<cfif arguments.thestruct.type EQ "vid">
			,
			vid_name_image
			FROM #session.hostdbprefix#videos
			WHERE vid_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry.file_id#">
		<cfelseif arguments.thestruct.type EQ "img">
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#qry.file_id#">
		</cfif>
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Rename image on HD --->
		<cfif arguments.thestruct.type EQ "vid">
			<cfset arguments.thestruct.newname = arguments.thestruct.qry_existing.vid_name_image>
		<cfelseif arguments.thestruct.type EQ "img">
			<cfset arguments.thestruct.newname = "thumb_#qry.file_id#.jpg">
		</cfif>
		<cfset var newpath = replacenocase(qry.path, qry.filename, "", "all")>
		<cfset arguments.thestruct.thedest = newpath & "/" & arguments.thestruct.newname>
		<cffile action="rename" source="#qry.path#/#qry.filename#" destination="#arguments.thestruct.thedest#">
		<!--- Upload or move to designated area --->
		<cfif application.razuna.storage EQ "local">
			<cffile action="move" source="#arguments.thestruct.thedest#" destination="#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.newname#" mode="775">
		<!--- Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<!--- Delete existing preview --->
			<cfinvoke component="nirvanix" method="DeleteFiles">
				<cfinvokeargument name="filePath" value="/#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.newname#">
				<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
			</cfinvoke>
			<!--- Upload it --->
			<cfset upa = Createuuid("")>
			<cfthread name="#upa#" intstruct="#arguments.thestruct#" priority="HIGH">
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qry_existing.path_to_asset#">
					<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thedest#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait --->
			<cfthread action="join" name="#upa#" />
			<!--- Get signed URLS --->
			<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.newname#" nvxsession="#arguments.thestruct.nvxsession#">
			<!--- Update DB --->
			<cfif arguments.thestruct.type EQ "vid">
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#videos
				SET cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE vid_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Flush Cache --->
				<cfset variables.cachetoken = resetcachetoken("videos")>
				<cfset variables.cachetoken = resetcachetoken("folders")>
				<cfset variables.cachetoken = resetcachetoken("general")>
			<cfelseif arguments.thestruct.type EQ "img">
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#images
				SET cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE img_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Flush Cache --->
				<cfset variables.cachetoken = resetcachetoken("images")>
				<cfset variables.cachetoken = resetcachetoken("folders")>
				<cfset variables.cachetoken = resetcachetoken("general")>
			</cfif>
		<!--- Amazon --->
		<cfelseif application.razuna.storage EQ "amazon">
			<cfset upa = Createuuid("")>
			<cfthread name="#upa#" intstruct="#arguments.thestruct#" priority="HIGH">
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qry_existing.path_to_asset#/#attributes.intstruct.newname#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thedest#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
			<cfthread action="join" name="#upa#" />
			<!--- Get signed URLS --->
			<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.newname#" awsbucket="#arguments.thestruct.awsbucket#">
			<!--- Update DB --->
			<cfif arguments.thestruct.type EQ "vid">
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#videos
				SET cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE vid_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Flush Cache --->
				<cfset variables.cachetoken = resetcachetoken("videos")>
				<cfset variables.cachetoken = resetcachetoken("folders")>
				<cfset variables.cachetoken = resetcachetoken("general")>
			<cfelseif arguments.thestruct.type EQ "img">
				<cfquery datasource="#variables.dsn#">
				UPDATE #session.hostdbprefix#images
				SET cloud_url = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#cloud_url.theurl#">
				WHERE img_id = <cfqueryparam value="#qry.file_id#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- Flush Cache --->
				<cfset variables.cachetoken = resetcachetoken("images")>
				<cfset variables.cachetoken = resetcachetoken("folders")>
				<cfset variables.cachetoken = resetcachetoken("general")>
			</cfif>
		</cfif>
		<!--- Remove record in DB --->
		<cfquery datasource="#variables.dsn#">
		DELETE FROM #session.hostdbprefix#assets_temp
		WHERE tempid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">
		</cfquery>
	</cfif>
</cffunction>

<!--- Recreate Preview Image --->
<cffunction name="recreatepreviewimage" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset arguments.thestruct.hostid = session.hostid>
	<!--- <cfinvoke method="recreatepreviewimagethread" thestruct="#arguments.thestruct#" /> --->
	<cfthread intstruct="#arguments.thestruct#" priority="LOW">
		<cfinvoke method="recreatepreviewimagethread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- Recreate Preview Image --->
<cffunction name="recreatepreviewimagethread" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var theargsdc = "x">
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Check the platform and then decide on the ImageMagick tag --->
	<cfif isWindows()>
		<cfset theexe = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
		<cfset thedcraw = """#arguments.thestruct.thetools.dcraw#/dcraw.exe""">
		<cfset themogrify = """#arguments.thestruct.thetools.imagemagick#/mogrify.exe""">
		<cfset theffmpeg = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
	<cfelse>
		<cfset theexe = "#arguments.thestruct.thetools.imagemagick#/convert">
		<cfset thedcraw = "#arguments.thestruct.thetools.dcraw#/dcraw">
		<cfset themogrify = "#arguments.thestruct.thetools.imagemagick#/mogrify">
		<cfset theffmpeg = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
	</cfif>
	<!--- Loop over file id --->
	<cfloop list="#arguments.thestruct.file_id#" index="i" delimiters=",">
		<cftry>
			<cfset cloud_url = structnew()>
			<!--- Get the ID and the type --->
			<cfset theid = listfirst(i,"-")>
			<cfset thetype = listlast(i,"-")>
			<!--- Create variables according to type --->
			<cfif thetype EQ "vid">
				<cfset thedb = "#session.hostdbprefix#videos">
				<cfset theflush = "#session.theuserid#_videos">
				<cfset therecid = "vid_id">
				<cfset thecolumns = "path_to_asset, vid_name_image, vid_name_org orgname, cloud_url_org">
			<cfelseif thetype EQ "img">
				<cfset thedb = "#session.hostdbprefix#images">
				<cfset theflush = "#session.theuserid#_images">
				<cfset therecid = "img_id">
				<cfset thecolumns = "path_to_asset, folder_id_r, img_filename_org orgname, img_extension, img_filename, cloud_url_org">
			</cfif>
			<!--- Query current thumbnail info --->
			<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry_existing">
			SELECT #thecolumns#
			FROM #thedb#
			WHERE #therecid# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- If the cloud_url_org column is empty skip it --->
			<cfif arguments.thestruct.qry_existing.cloud_url_org EQ "" AND (application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix")>
				<cfset conti = false>
			<cfelse>
				<cfset conti = true>
			</cfif>
			<cfif conti>
				<!--- Create script files --->
				<cfset thescript = Createuuid("")>
				<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.sh">
				<cfset arguments.thestruct.theshdc = GetTempDirectory() & "/#thescript#dc.sh">
				<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#thescript#w.sh">
				<!--- On Windows a .bat --->
				<cfif iswindows()>
					<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.bat">
					<cfset arguments.thestruct.theshdc = GetTempDirectory() & "/#thescript#dc.bat">
					<cfset arguments.thestruct.theshw = GetTempDirectory() & "/#thescript#w.bat">
				</cfif>
				<!--- The path to original: different on local --->
				<cfif application.razuna.storage EQ "local">
					<cfset arguments.thestruct.filepath = "#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.qry_existing.path_to_asset#/">
				<cfelse>
					<!--- temp dir --->
					<cfset arguments.thestruct.filepath = GetTempDirectory()>
				</cfif>
				<!--- Set filename with complete path --->
				<cfif thetype EQ "vid">
					<cfset arguments.thestruct.thumbname = arguments.thestruct.qry_existing.vid_name_image>
					<cfset arguments.thestruct.thumbpath = arguments.thestruct.filepath & arguments.thestruct.thumbname>
					<cfset theargs = "#theffmpeg# -i #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname# -vframes 1 -f image2 -vcodec mjpeg #arguments.thestruct.thumbpath#">
				<cfelseif thetype EQ "img">
					<cfset arguments.thestruct.thumbname = "thumb_#theid#.#arguments.thestruct.qry_settings_image.set2_img_format#">
					<cfset arguments.thestruct.thumbpath = arguments.thestruct.filepath & arguments.thestruct.thumbname>
					<!--- Create the args for conversion --->
					<cfswitch expression="#arguments.thestruct.qry_existing.img_extension#">
						<!--- If the file is a PSD, AI or EPS we have to layer it to zero --->
						<cfcase value="psd,eps,ai">
							<cfset theargs = "#theexe# #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#[0] -thumbnail #arguments.thestruct.qry_settings_image.set2_img_thumb_width#x -strip -colorspace sRGB -flatten #arguments.thestruct.thumbpath#">
						</cfcase>
						<!--- For RAW images we take dcraw --->
						<cfcase value="3fr,ari,arw,srf,sr2,bay,crw,cr2,cap,iiq,eip,dcs,dcr,drf,k25,kdc,erf,fff,mef,mos,mrw,nef,nrw,orf,ptx,pef,pxn,r3d,raf,raw,rw2,rwl,dng,rwz,x3f">
							<cfset theargs = "#thedcraw# -c -e #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname# > #arguments.thestruct.thumbpath#">
							<cfset theargsdc = "#themogrify# -thumbnail #arguments.thestruct.qry_settings_image.set2_img_thumb_width#x -strip -colorspace sRGB #arguments.thestruct.thumbpath#">
						</cfcase>
						<!--- For everything else --->
						<cfdefaultcase>
							<cfset theargs = "#theexe# #arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname# -thumbnail #arguments.thestruct.qry_settings_image.set2_img_thumb_width#x -strip -colorspace sRGB #arguments.thestruct.thumbpath#">
						</cfdefaultcase>
					</cfswitch>
				</cfif>
				<!--- Write script file --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#theargs#" mode="777">
				<cffile action="write" file="#arguments.thestruct.theshdc#" output="#theargsdc#" mode="777">
				<!--- Local: Delete thumbnail --->
				<cfif application.razuna.storage EQ "local">
					<!--- Delete old thumb (if there) --->
					<cfif fileexists(arguments.thestruct.thumbpath)>
						<cffile action="delete" file="#arguments.thestruct.thumbpath#" />
					</cfif>
				<!--- Amazon & Nirvanix download file --->
				<cfelseif application.razuna.storage EQ "amazon" OR application.razuna.storage EQ "nirvanix">
					<cfhttp url="#arguments.thestruct.qry_existing.cloud_url_org#" file="#arguments.thestruct.qry_existing.orgname#" path="#arguments.thestruct.filepath#"></cfhttp>
				</cfif>
				<!--- Convert image to thumbnail --->
				<cfthread name="con#thescript#" intstruct="#arguments.thestruct#">
					<cfexecute name="#attributes.intstruct.thesh#" timeout="60" />
				</cfthread>
				<!--- Wait --->
				<cfthread action="join" name="con#thescript#" />
				<!--- For RAW image additionally use mogrify --->
				<cfthread name="con2#thescript#" intstruct="#arguments.thestruct#">
					<cfexecute name="#attributes.intstruct.theshdc#" timeout="60" />
				</cfthread>
				<!--- Wait --->
				<cfthread action="join" name="con2#thescript#" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
				<cffile action="delete" file="#arguments.thestruct.theshdc#">
				<!--- Amazon: upload file --->
				<cfif application.razuna.storage EQ "amazon">
					<cfthread name="upload#thescript#" intstruct="#arguments.thestruct#" priority="HIGH">
						<!--- Upload Thumbnail --->
						<cfinvoke component="amazon" method="Upload">
							<cfinvokeargument name="key" value="/#attributes.intstruct.qry_existing.path_to_asset#/#attributes.intstruct.thumbname#">
							<cfinvokeargument name="theasset" value="#attributes.intstruct.thumbpath#">
							<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for thread to finish --->
					<cfthread action="join" name="upload#thescript#" />
					<!--- Get signed URLS --->
					<cfinvoke component="amazon" method="signedurl" returnVariable="cloud_url" key="#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.thumbname#" awsbucket="#arguments.thestruct.awsbucket#">
					<!--- Update DB --->
					<cfquery datasource="#variables.dsn#">
					UPDATE #thedb#
					SET cloud_url = <cfqueryparam value="#cloud_url.theurl#" cfsqltype="cf_sql_varchar">
					WHERE #therecid# = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Remove the original and thumbnail --->
					<cfif fileexists("#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#")>
						<cffile action="delete" file="#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#" />
					</cfif>
					<!--- Delete old thumb (if there) --->
					<cfif fileexists(arguments.thestruct.thumbpath)>
						<cffile action="delete" file="#arguments.thestruct.thumbpath#" />
					</cfif>
				<!--- Nirvanix: delete file --->
				<cfelseif application.razuna.storage EQ "nirvanix">
					<!--- Delete existing preview --->
					<cfinvoke component="nirvanix" method="DeleteFiles">
						<cfinvokeargument name="filePath" value="/#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.thumbname#">
						<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
					</cfinvoke>
					<!--- Upload Thumbnail --->
					<cfthread name="upload#thescript#" intstruct="#arguments.thestruct#" priority="HIGH">
						<cfinvoke component="nirvanix" method="Upload">
							<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.qry_existing.path_to_asset#">
							<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thumbpath#">
							<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
						</cfinvoke>
					</cfthread>
					<!--- Wait for thread to finish --->
					<cfthread action="join" name="upload#thescript#" />
					<!--- Get signed URLS --->
					<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloud_url" theasset="#arguments.thestruct.qry_existing.path_to_asset#/#arguments.thestruct.thumbname#" nvxsession="#arguments.thestruct.nvxsession#">
					<!--- Update DB --->
					<cfquery datasource="#variables.dsn#">
					UPDATE #thedb#
					SET cloud_url = <cfqueryparam value="#cloud_url.theurl#" cfsqltype="cf_sql_varchar">
					WHERE #therecid# = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
					</cfquery>
					<!--- Remove the original and thumbnail --->
					<cfif fileexists("#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#")>
						<cffile action="delete" file="#arguments.thestruct.filepath##arguments.thestruct.qry_existing.orgname#" />
					</cfif>
					<!--- Delete old thumb (if there) --->
					<cfif fileexists(arguments.thestruct.thumbpath)>
						<cffile action="delete" file="#arguments.thestruct.thumbpath#" />
					</cfif>
				</cfif>
			</cfif>
			<cfcatch type="all">
				<cfmail from="server@razuna.com" to="support@razuna.com" subject="debug recreating preview" type="html"><cfdump var="#cfcatch#"></cfmail>
			</cfcatch>
		</cftry>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("images")>
	<cfset variables.cachetoken = resetcachetoken("videos")>
	<cfset variables.cachetoken = resetcachetoken("folders")>
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Process Upload Template --->
<cffunction name="process_upl_template" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset arguments.thestruct.convert_to = "">
	<cfset arguments.thestruct.convert = true>
	<cfset arguments.thestruct.qry_settings_image = arguments.thestruct.qrysettings>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT upl_temp_field, upl_temp_value, upl_temp_type, upl_temp_format
	FROM #session.hostdbprefix#upload_templates_val
	WHERE upl_temp_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upltemptype#">
	AND upl_temp_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.upl_template#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfloop query="qry">
		<cfif upl_temp_field EQ "convert_to">
			<cfset arguments.thestruct.convert_to = upl_temp_value & "," & arguments.thestruct.convert_to>
		</cfif>
	</cfloop>
	<!--- Images --->
	<cfif arguments.thestruct.upltemptype EQ "img">
		<cfinvoke component="images" method="convertImage" thestruct="#arguments.thestruct#" />
	<!--- Videos --->
	<cfelseif arguments.thestruct.upltemptype EQ "vid">
		<cfinvoke component="videos" method="convertvideothread" thestruct="#arguments.thestruct#" />
	<!--- Audios --->
	<cfelseif arguments.thestruct.upltemptype EQ "aud">
		<cfinvoke component="audios" method="convertaudiothread" thestruct="#arguments.thestruct#" />
	</cfif>
</cffunction>

<!--- Process Upload Additional versions --->
<cffunction name="addassetav" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset arguments.thestruct.newid = createuuid("")>
	<!--- Create a unique name for the temp directory to hold the file --->
	<cfset arguments.thestruct.thetempfolder = "api#arguments.thestruct.newid#">
	<cfset arguments.thestruct.theincomingtemppath = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.thetempfolder#">
	<!--- Create a temp directory to hold the file --->
	<cfdirectory action="create" directory="#arguments.thestruct.theincomingtemppath#" mode="775">
	<!--- Upload file --->
	<cffile action="upload" destination="#arguments.thestruct.theincomingtemppath#" nameconflict="overwrite" filefield="file" result="thefile">
	<cfset thefile.serverFileExt = lcase(thefile.serverFileExt)>
	<!--- Get and set file type and MIME content --->
	<cfquery datasource="#variables.dsn#" name="fileType">
	SELECT type_type, type_mimecontent, type_mimesubcontent
	FROM file_types
	WHERE lower(type_id) = <cfqueryparam value="#thefile.serverFileExt#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<!--- set attributes of file structure --->
	<cfif fileType.recordCount GT 0>
		<cfset arguments.thestruct.thefiletype = "#fileType.type_type#">
	<cfelse>
		<cfset arguments.thestruct.thefiletype = "doc">
	</cfif>
	<!--- Query to get the settings --->
	<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qrysettings">
	SELECT set2_path_to_assets
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#variables.setid#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Rename the file so that we can remove any spaces --->
	<cfinvoke component="global.cfc.global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#thefile.serverFile#">
	<cffile action="rename" source="#arguments.thestruct.theincomingtemppath#/#thefile.serverFile#" destination="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#">
	<!--- If we are local --->
	<cfif application.razuna.storage EQ "local">
		<!--- Create folder with the asset id --->
		<cfif NOT directoryexists("#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#")>
			<cfdirectory action="create" directory="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#" mode="775">
		</cfif>
		<!--- Move original image --->
		<cffile action="move" source="#arguments.thestruct.theincomingtemppath#/#arguments.thestruct.thefilename#" destination="#arguments.thestruct.qrysettings.set2_path_to_assets#/#session.hostid#/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#" mode="775">
		<!--- Set the URL --->
		<cfset arguments.thestruct.av_link_url = "/#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#">
	<!--- NIRVANIX --->
	<cfelseif application.razuna.storage EQ "nirvanix">
		<!--- Upload Original --->
		<cfset upt = Createuuid("")>
		<cfthread name="#upt#" intstruct="#arguments.thestruct#" priority="HIGH">
			<cfinvoke component="nirvanix" method="Upload">
				<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.folder_id#/#attributes.intstruct.thefiletype#/#arguments.thestruct.newid#">
				<cfinvokeargument name="uploadfile" value="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.thefilename#">
				<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
			</cfinvoke>
		</cfthread>
		<!--- Wait for thread to finish --->
		<cfthread action="join" name="#upt#" />
		<!--- Get signed URLS for original --->
		<cfinvoke component="nirvanix" method="signedurl" returnVariable="cloudurl" theasset="#arguments.thestruct.folder_id#/#arguments.thestruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#" nvxsession="#arguments.thestruct.nvxsession#">
		<!--- Set the URL --->
		<cfset arguments.thestruct.av_link_url = cloudurl.theurl>
	<!--- AMAZON --->
	<cfelseif application.razuna.storage EQ "amazon">
		<cfset upt = Createuuid("")>
		<cfthread name="#upt#" intstruct="#arguments.thestruct#" priority="HIGH">
			<cfinvoke component="amazon" method="Upload">
				<cfinvokeargument name="key" value="/#attributes.intstruct.folder_id#/#attributes.intstruct.thefiletype#/#attributes.intstruct.newid#/#attributes.intstruct.thefilename#">
				<cfinvokeargument name="theasset" value="#attributes.intstruct.theincomingtemppath#/#attributes.intstruct.thefilename#">
				<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
			</cfinvoke>
		</cfthread>
		<cfthread action="join" name="#upt#" />
		<!--- Get signed URLS for original --->
		<cfinvoke component="amazon" method="signedurl" returnVariable="cloudurl" key="#arguments.thestruct.folder_id#/#attributes.intstruct.thefiletype#/#arguments.thestruct.newid#/#arguments.thestruct.thefilename#" awsbucket="#arguments.thestruct.awsbucket#">
		<!--- Set the URL --->
		<cfset arguments.thestruct.av_link_url = cloudurl.theurl>
	</cfif>
	<!--- Set values for function call below --->
	<cfset arguments.thestruct.av_link = "0">
	<cfset arguments.thestruct.av_link_title = thefile.serverFile>
	<cfset arguments.thestruct.file_id = session.asset_id_r>
	<cfset arguments.thestruct.folder_id = arguments.thestruct.folder_id>
	<cfset arguments.thestruct.type = arguments.thestruct.thefiletype>
	<!--- Add Asset to db --->
	<cfinvoke component="global" method="save_add_versions_link">
		<cfinvokeargument name="thestruct" value="#arguments.thestruct#">
	</cfinvoke>
	<!--- Return Message --->
	<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>0</responsecode>
<message>success</message>
<assetid>#xmlformat(arguments.thestruct.newid)#</assetid>
<filetype>#xmlformat(arguments.thestruct.type)#</filetype>
</Response></cfoutput>
	</cfsavecontent>
	<!--- Return --->
	<cfreturn thexml />
</cffunction>

<!--- INSERT FROM PATH --->
<cffunction name="addassetpath" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Params --->
	<cfset arguments.thestruct.userid = session.theuserid>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- Read the name of the root folder --->
	<cfset arguments.thestruct.folder_name = listlast(arguments.thestruct.folder_path,"/\")>
	<!--- Add the folder --->
	<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
	<!--- If we store on the file system we create the folder here --->
	<cfif application.razuna.storage EQ "local">
		<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
		<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
		<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
		<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
		<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
	</cfif>
	<!--- Feedback --->
	<cfoutput>List files of this folder...<br><br></cfoutput>
	<cfflush>
	<!--- Now add all assets of this folder --->
	<cfdirectory action="list" directory="#arguments.thestruct.folder_path#" name="thefiles" type="file">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="thefiles">
	SELECT *
	FROM thefiles
	WHERE attributes != 'H'
	</cfquery>
	<!--- Feedback --->
	<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
	<cfflush>
	<!--- New folder id into struct --->
	<cfset arguments.thestruct.new_folder_id = new_folder_id>
	<!--- Loop over the assets --->
	<cfloop query="thefiles">
		<!--- Feedback --->
		<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
		<cfflush>
		<!--- Params --->
		<cfset arguments.thestruct.filepath = directory & "/" & name>
		<cfset arguments.thestruct.thedir = directory>
		<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
		<cfset arguments.thestruct.orgsize = size>
		<!--- Now add the asset --->
		<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
	</cfloop>
	<!--- Feedback --->
	<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
	<cfflush>
	<!--- Check if folder has subfolders if so add them recursively --->
	<cfdirectory action="list" directory="#arguments.thestruct.folder_path#" name="thedir" type="dir">
	<!--- Filter out hidden dirs --->
	<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
	SELECT *
	FROM thedir
	WHERE attributes != 'H'
	</cfquery>
	<!--- Call rec function --->
	<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
		<!--- Feedback --->
		<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
		<cfflush>
		<!--- folder_id into theid --->
		<cfset arguments.thestruct.theid = new_folder_id>
		<!--- Call function --->
		<cfinvoke method="addassetpath2" thestruct="#arguments.thestruct#">
	</cfif>
	<!--- Feedback --->
	<cfoutput><span style="color:green;font-weight:bold;">Successfully added all folders and assets!</span><br><br></cfoutput>
	<cfflush>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 2 --->
<cffunction name="addassetpath2" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder --->
		<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath3" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 3 --->
<cffunction name="addassetpath3" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder --->
		<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath2 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid2 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel2 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath4" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath2>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid2>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel2>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 4 --->
<cffunction name="addassetpath4" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder --->
		<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath3 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid3 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel3 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath5" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath3>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid3>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel3>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 5 --->
<cffunction name="addassetpath5" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder --->
		<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath4 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid4 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel4 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath6" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath4>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid4>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel4>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 6 --->
<cffunction name="addassetpath6" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder --->
		<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath5 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid5 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel5 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath7" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath5>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid5>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel5>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 7 --->
<cffunction name="addassetpath7" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder --->
		<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Feedback --->
		<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
		<cfflush>
		<!--- Check if folder has subfolders if so add them recursively --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
		SELECT *
		FROM thedir
		WHERE attributes != 'H'
		</cfquery>
		<cfset arguments.thestruct.folderpath6 = arguments.thestruct.folder_path>
		<cfset arguments.thestruct.thisfolderid6 = arguments.thestruct.theid>
		<cfset arguments.thestruct.thislevel6 = arguments.thestruct.level>
		<!--- Call rec function --->
		<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
			<!--- Feedback --->
			<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
			<cfflush>
			<!--- folder_id into theid --->
			<cfset arguments.thestruct.theid = new_folder_id>
			<!--- Add directory to the folder_path --->
			<cfset arguments.thestruct.folder_path = directory & "/#name#">
			<!--- Call function --->
			<cfinvoke method="addassetpath8" thestruct="#arguments.thestruct#">
		</cfif>
		<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath6>
		<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid6>
		<cfset arguments.thestruct.level = arguments.thestruct.thislevel6>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- INSERT FROM PATH 8 --->
<cffunction name="addassetpath8" output="true" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Feedback --->
	<cfoutput><strong>Reading: #arguments.thestruct.folder_path#</strong><br><br></cfoutput>
	<cfflush>
	<!--- Increase folder level --->
	<cfset arguments.thestruct.level = arguments.thestruct.level + 1>
	<!--- The loop --->
	<cfloop query="arguments.thestruct.thesubdirs">
		<!--- Read the name of the root folder --->
		<cfset arguments.thestruct.folder_name = listlast(name,FileSeparator())>
		<!--- Add the folder --->
		<cfinvoke component="folders" method="fnew_detail" thestruct="#arguments.thestruct#" returnvariable="new_folder_id">
		<!--- If we store on the file system we create the folder here --->
		<cfif application.razuna.storage EQ "local">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/img">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/vid">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/doc">
			<cfdirectory action="create" directory="#arguments.thestruct.assetpath#/#session.hostid#/#new_folder_id#/aud">
		</cfif>
		<!--- Add the dirname to the link_path --->
		<cfset subfolderpath = "#arguments.thestruct.folder_path#/#name#">
		<!--- Feedback --->
		<cfoutput>List files of this folder...<br><br></cfoutput>
		<cfflush>
		<!--- Now add all assets of this folder --->
		<cfdirectory action="list" directory="#subfolderpath#" name="thefiles" type="file">
		<!--- Filter out hidden dirs --->
		<cfquery dbtype="query" name="thefiles">
		SELECT *
		FROM thefiles
		WHERE attributes != 'H'
		</cfquery>
		<!--- Feedback --->
		<cfoutput>Found #thefiles.recordcount# files.<br><br></cfoutput>
		<cfflush>
		<!--- New folder id into struct --->
		<cfset arguments.thestruct.new_folder_id = new_folder_id>
		<!--- Loop over the assets --->
		<cfloop query="thefiles">
			<!--- Feedback --->
			<cfoutput>Adding: #listlast(name,FileSeparator())#<br></cfoutput>
			<cfflush>
			<!--- Params --->
			<cfset arguments.thestruct.filepath = directory & "/" & name>
			<cfset arguments.thestruct.thedir = directory>
			<cfset arguments.thestruct.filename = listlast(name,FileSeparator())>
			<cfset arguments.thestruct.orgsize = size>
			<!--- Now add the asset --->
			<cfinvoke method="addassetpathfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!---
			<!--- Feedback --->
			<cfoutput><br /><br />Checking if there are any subfolders...<br/><br/></cfoutput>
			<cfflush>
			<!--- Check if folder has subfolders if so add them recursively --->
			<cfdirectory action="list" directory="#subfolderpath#" name="thedir" type="dir">
			<!--- Filter out hidden dirs --->
			<cfquery dbtype="query" name="arguments.thestruct.thesubdirs">
			SELECT *
			FROM thedir
			WHERE attributes != 'H'
			</cfquery>
			<cfset arguments.thestruct.folderpath3 = arguments.thestruct.folder_path>
			<cfset arguments.thestruct.thisfolderid3 = arguments.thestruct.theid>
			<cfset arguments.thestruct.thislevel3 = arguments.thestruct.level>
			<!--- Call rec function --->
			<cfif arguments.thestruct.thesubdirs.recordcount NEQ 0>
				<!--- Feedback --->
				<cfoutput>Found #arguments.thestruct.thesubdirs.recordcount# sub-folder.<br><br></cfoutput>
				<cfflush>
				<!--- folder_id into theid --->
				<cfset arguments.thestruct.theid = new_folder_id>
				<!--- Add directory to the folder_path --->
				<cfset arguments.thestruct.folder_path = directory & "/#name#">
				<!--- Call function --->
				<!--- <cfinvoke method="addassetpath5" thestruct="#arguments.thestruct#"> --->
			</cfif>
			<cfset arguments.thestruct.folder_path = arguments.thestruct.folderpath3>
			<cfset arguments.thestruct.theid = arguments.thestruct.thisfolderid3>
			<cfset arguments.thestruct.level = arguments.thestruct.thislevel3>
		--->
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Add assets from import path --->
<cffunction name="addassetpathfiles" output="true">
	<cfargument name="thestruct" type="struct">	
	<cftry>
		<cfset var md5hash = "">
		<!--- Throttle engine a bit --->
		<cfpause interval="2" />
		<!--- Create a unique name for the temp directory to hold the file --->
		<cfset arguments.thestruct.tempid = createuuid("")>
		<!--- Get file extension --->
		<cfset var theextension = listlast("#arguments.thestruct.filename#",".")>
		<!--- Get extension --->
		<cfset var namenoext = replacenocase("#arguments.thestruct.filename#",".#theextension#","","All")>
		<!--- Rename the file so that we can remove any spaces --->
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilename" thename="#arguments.thestruct.filename#">
		<cfinvoke component="global" method="convertname" returnvariable="arguments.thestruct.thefilenamenoext" thename="#namenoext#">
		<!--- Do the rename action on the file --->
		<cffile action="rename" source="#arguments.thestruct.filepath#" destination="#arguments.thestruct.thedir#/#arguments.thestruct.thefilename#">
		<!--- If the extension is longer then 9 chars --->
		<cfif len(theextension) GT 9>
			<cfset theextension = "txt">
		</cfif>
		<!--- Store the original filename --->
		<cfset arguments.thestruct.thefilenameoriginal = arguments.thestruct.filename>
		<!--- MD5 Hash --->
		<cfif FileExists("#arguments.thestruct.thedir#/#arguments.thestruct.thefilename#")>
			<cfset md5hash = hashbinary("#arguments.thestruct.thedir#/#arguments.thestruct.thefilename#")>
		</cfif>
			<!--- Check if we have to check for md5 records --->
			<cfinvoke component="settings" method="getmd5check" returnvariable="checkformd5" />
			<!--- Check for the same MD5 hash in the existing records --->
			<cfif checkformd5>
				<cfinvoke method="checkmd5" returnvariable="md5here" md5hash="#md5hash#" />
			<cfelse>
				<cfset var md5here = 0>
			</cfif>
			<!--- If file does not exsist continue else send user an eMail --->
			<cfif md5here EQ 0>
				<!--- Add to temp db --->
				<cfquery datasource="#variables.dsn#">
				INSERT INTO #session.hostdbprefix#assets_temp
				(tempid, filename, extension, date_add, folder_id, who, filenamenoext, path, file_id, host_id, thesize, md5hash)
				VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.tempid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilename#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#theextension#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.new_folder_id#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thefilenamenoext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.thedir#">,
				<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="0">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.orgsize#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#md5hash#">
				)
				</cfquery>
				<!--- We don't need to send an email --->
				<cfset arguments.thestruct.sendemail = false>
				<!--- We set that this is from this function --->
				<cfset arguments.thestruct.importpath = true>
				<!--- Call the addasset function --->
				<cfthread intstruct="#arguments.thestruct#" priority="LOW">
					<cfinvoke method="addasset" thestruct="#attributes.intstruct#">
				</cfthread>
			<cfelse>
				<cfinvoke component="email" method="send_email" subject="Razuna: File #arguments.thestruct.thefilename# already exists" themessage="Hi there. The file (#arguments.thestruct.thefilename#) already exists in Razuna and thus was not added to the system!">
			</cfif>
		<cfcatch type="any">
			<cfoutput><span style="color:red;font-weight:bold;">The file "#arguments.thestruct.filename#" could not be proccessed!</span><br />#cfcatch.detail#<br /></cfoutput>
		</cfcatch>
	</cftry>
</cffunction>

<!--- Check for existing MD5 mash records --->
<cffunction name="checkmd5" output="false">
	<cfargument name="md5hash" type="string">
	<!--- Param --->
	<cfset var rec = 0>
	<!--- Images --->
	<cfinvoke component="images" method="checkmd5" md5hash="#arguments.md5hash#" returnvariable="qryimg" />
	<!--- videos --->
	<cfinvoke component="videos" method="checkmd5" md5hash="#arguments.md5hash#" returnvariable="qryvid" />
	<!--- Files --->
	<cfinvoke component="files" method="checkmd5" md5hash="#arguments.md5hash#" returnvariable="qrydoc" />
	<!--- Audios --->
	<cfinvoke component="audios" method="checkmd5" md5hash="#arguments.md5hash#" returnvariable="qryaud" />
	<!--- Put each result into var --->
	<cfset rec = qryimg.recordcount>
	<cfif !rec>
		<cfset rec = qryvid.recordcount>
	</cfif>
	<cfif !rec>
		<cfset rec = qrydoc.recordcount>
	</cfif>
	<cfif !rec>
		<cfset rec = qryaud.recordcount>
	</cfif>
	<!--- Return --->
	<cfreturn rec />
</cffunction>

</cfcomponent>
