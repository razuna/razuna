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
<cfcomponent>

	<!---  --->
	<!--- STANDARD --->
	<!---  --->
	
	<!--- FUNCTION: INIT --->
	<cffunction name="init" returntype="nirvanix" access="public" output="false">
		<cfargument name="appkey" type="string" required="true" />
		<!--- Set --->
		<cfset variables.appkey = arguments.appkey />
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<!--- FUNCTION: LOGIN --->
	<cffunction name="login" returntype="string" access="remote" output="false">
		<cfargument name="thestruct" type="struct" required="false" />
		<cfif !isstruct(arguments.thestruct)>
			<cfset arguments.thestruct = structnew()>
			<cfset arguments.thestruct.isbrowser = "F">
		<cfelse>
			<cfparam name="arguments.thestruct.isbrowser" default="F" />
		</cfif>
		<!--- If we call this function directly we don't have the appkey in the variables --->
		<cfif NOT structkeyexists(variables,"appkey")>
			<cfset variables.appkey = application.razuna.nvxappkey>
		</cfif>
		<!--- Grab NVX settings --->
		<cfinvoke component="settings" method="prefs_storage" returnVariable="qry_settings" />
		<!--- Login and get session token --->
		<cftry>
			<cfif arguments.thestruct.isbrowser EQ "F">
				<cfhttp url="http://services.nirvanix.com/ws/Authentication/Login.ashx" method="get" throwonerror="true" charset="utf-8">
					<cfhttpparam name="appKey" value="#variables.appkey#" type="url">
					<cfhttpparam name="username" value="#qry_settings.set2_nirvanix_name#" type="url">
					<cfhttpparam name="password" value="#qry_settings.set2_nirvanix_pass#" type="url">
				</cfhttp>
			<cfelse>
				<!--- If this is a Squid request then the ip is not in the remote_addr cgi variable --->
				<cfif structkeyexists(cgi,"http_x_forwarded_for")>
					<cfset theremoteip = cgi.http_x_forwarded_for>
				<cfelse>
					<cfset theremoteip = cgi.remote_addr>
				</cfif>
				<!--- Get the SessionToken --->
				<cfhttp url="http://services.nirvanix.com/ws/Authentication/LoginProxy.ashx" method="get" throwonerror="true" charset="utf-8">
					<cfhttpparam name="appKey" value="#variables.appkey#" type="url">
					<cfhttpparam name="username" value="#qry_settings.set2_nirvanix_name#" type="url">
					<cfhttpparam name="password" value="#qry_settings.set2_nirvanix_pass#" type="url">
					<cfhttpparam name="consumerIP" value="#theremoteip#" type="url">
				</cfhttp>
			</cfif>
			<!--- Get the XML node for each setting --->
			<cfset var thexml = xmlparse(cfhttp.FileContent)>
			<cfset var nvxsession = thexml.Response.Sessiontoken[1].XmlText>
			<cfcatch type="any">
				<cfmail to="nitai@razuna.com" from="server@razuna.com" subject="nvx error during login" type="html">
					<cfdump var="#cfcatch#">
				</cfmail>
				<cfset var nvxsession = 0>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn nvxsession>
	</cffunction>
	
	<!--- FUNCTION: LOGIN Direct --->
	<cffunction name="logindirect" returntype="string" access="public" output="false">
		<cfargument name="thestruct" type="struct" required="yes" />
		<!--- If we call this function directly we don't have the appkey in the variables --->
		<cfif NOT structkeyexists(variables,"appkey")>
			<cfset variables.appkey = application.razuna.nvxappkey>
		</cfif>
		<!--- Grab NVX settings --->
		<cfinvoke component="settings" method="prefs_storage" returnVariable="qry_settings" />
		<!--- Login and get session token --->
		<cftry>
			<cfhttp url="http://services.nirvanix.com/ws/Authentication/Login.ashx" method="get" throwonerror="true" charset="utf-8">
				<cfhttpparam name="appKey" value="#variables.appkey#" type="url">
				<cfhttpparam name="username" value="#qry_settings.set2_nirvanix_name#" type="url">
				<cfhttpparam name="password" value="#qry_settings.set2_nirvanix_pass#" type="url">
			</cfhttp>
			<!--- Get the XML node for each setting --->
			<cfset xmlfound = xmlSearch(cfhttp.FileContent, "//SessionToken")>
			<cfset nvxsession = xmlfound[1].xmlText>
			<cfcatch type="any">
				<cfset nvxsession = 0>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn nvxsession>
	</cffunction>
	
	<!--- FUNCTION: VALIDATE --->
	<cffunction name="validate" returntype="string" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="yes" />		
		<!--- Set the app key manually, master has another one for testing the the child account which takes it from the application scope --->
		<cfset variables.appkey = arguments.thestruct.nvxappkey>
		<!--- Login and get session token --->
		<cftry>
			<cfhttp url="http://services.nirvanix.com/ws/Authentication/Login.ashx" method="get" throwonerror="true" charset="utf-8">
				<cfhttpparam name="appKey" value="#arguments.thestruct.nvxkey#" type="url">
				<cfhttpparam name="username" value="#arguments.thestruct.nvxname#" type="url">
				<cfhttpparam name="password" value="#arguments.thestruct.nvxpass#" type="url">
			</cfhttp>
			<!--- Get the XML node for each setting --->
			<cfset var thexml = xmlparse(cfhttp.FileContent)>
			<cfset var nvxsession = thexml.Response.ResponseCode[1].XmlText>
			<cfcatch type="any">
				<cfset nvxsession = 1>
			</cfcatch>
		</cftry>
		<cfoutput><br>
			<cfif nvxsession EQ 0>
				<span style="color:green;font-weight:bold;">Connection is valid!</span>
			<cfelse>
				<span style="color:red;font-weight:bold;">Username and/or Password is NOT valid!</span>
			</cfif>
		</cfoutput>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!---  --->
	<!--- UPLOAD --->
	<!---  --->
	
	<cffunction name="Upload" access="public" output="false">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="uploadfile" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- If file exists locally then upload --->
		<cfif fileexists("#arguments.uploadfile#")>
			<cftry>
				<!--- Params --->
				<cfset var tt = replace(createuuid(),"-","","all")>
				<!--- Get session --->
				<cfset var nvxsession = login()>
				<!--- Get Storage Node Stuff --->
				<cfset arguments.storagenode = getstoragenode(nvxsession)>
				<!--- Upload Asset --->
				<cfthread name="#tt#" intstruct="#arguments#">
					<cfhttp url="#attributes.intstruct.storagenode.uploadhost#/Upload.ashx?" method="post" throwonerror="true">
						<cfhttpparam name="uploadtoken" value="#attributes.intstruct.storagenode.uploadtoken#" type="url">
						<cfhttpparam name="destFolderPath" value="#attributes.intstruct.destFolderPath#" type="url">
						<cfhttpparam name="uploadFile" file="#attributes.intstruct.uploadfile#" type="file">
					</cfhttp>
				</cfthread>
				<cfthread action="join" name="#tt#" />
				<cfcatch type="any">
					<cfif cfcatch.message CONTAINS "bandwidth limit">
						<cfinvoke component="email" method="send_email" subject="Razuna: Bandwidth exceeded" themessage="The file you are trying to upload exceeds the bandwidth limit for your plan. If you want to continue using Razuna you either have to wait until the end of your subsription period or simply upgrade to the PRO plan for only $1.80 per GB/month.">
					<cfelse>
						<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="upload nirvanix error">
							<cfdump var="#cfcatch#" />
						</cfmail>
					</cfif>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: GETSTORAGENODE --->
	<cffunction name="GetStorageNode" returntype="struct" access="public" output="false">
		<cfargument name="nvxsession" type="string" required="false">
		<cfset var thenode = structnew()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/GetStorageNode.ashx" method="post" throwonerror="false">
			<cfhttpparam name="sessionToken" value="#arguments.nvxsession#" type="url">
			<cfhttpparam name="sizeBytes" value="15000" type="url">
		</cfhttp>
		<!--- Parse --->
		<cfset xmlVar = xmlParse(cfhttp.filecontent)/>
		<!--- Get the XML node for each setting --->
		<cfset thenode.uploadhost = xmlvar.Response.GetStorageNode.UploadHost[1].XmlText>
		<cfset thenode.uploadtoken = xmlvar.Response.GetStorageNode.UploadToken[1].XmlText>
		<!--- Return --->
		<cfreturn thenode>
	</cffunction>
	
	<!---  --->
	<!--- FOLDERS --->
	<!---  --->
	
	<!--- FUNCTION: CREATE FOLDERS --->
	<cffunction name="CreateFolders" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cftry>
			<!--- <cfset NxCreatefolder(variables.nvxsession,arguments.folderpath)> --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/CreateFolders.ashx" method="get" throwonerror="true">
				<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
				<cfhttpparam name="folderPath" value="#arguments.folderpath#" type="url">
			</cfhttp>
			<cfcatch type="any">
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="debug nirvanix create folder" dump="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: DELETE FOLDERS --->
	<cffunction name="DeleteFolders" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<!--- <cfset NxDeletefolder(variables.nvxsession,arguments.folderpath)> --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/DeleteFolders.ashx" method="get" throwonerror="false">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="folderPath" value="#arguments.folderpath#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: RENAME FOLDERS --->
	<cffunction name="RenameFolders" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true">
		<cfargument name="newFolderName" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<cftry>
			<!--- Call --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/RenameFolder.ashx" method="post" throwonerror="true">
				<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
				<cfhttpparam name="folderPath" value="#arguments.folderpath#" type="url">
				<cfhttpparam name="newFolderName" value="#arguments.newFolderName#" type="url">
			</cfhttp>
			<cfcatch type="any">
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Nirvanix error - renamefolder" dump="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: COPY FOLDERS --->
	<cffunction name="CopyFolders" access="public" output="false">
		<cfargument name="srcFolderPath" type="string" required="true">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<cftry>
			<!--- Call --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/CopyFolders.ashx" method="get" throwonerror="true">
				<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
				<cfhttpparam name="srcFolderPath" value="#arguments.srcFolderPath#" type="url">
				<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
			</cfhttp>
			<cfcatch type="any">
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Nirvanix error - copyfolder" dump="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: MOVE FOLDERS --->
	<cffunction name="MoveFolders" access="public" output="false">
		<cfargument name="srcFolderPath" type="string" required="true">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<cftry>
			<!--- Call --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/MoveFolders.ashx" method="get" throwonerror="true">
				<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
				<cfhttpparam name="srcFolderPath" value="#arguments.srcFolderPath#" type="url">
				<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
			</cfhttp>
			<cfcatch type="any">
				<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Nirvanix error - movefolder" dump="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: LIST FOLDER (lists content of folder) --->
	<cffunction name="ListFolder" access="public" output="false">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="folderPath" type="string" required="true">
		<cfargument name="pageNumber" type="numeric" required="true">
		<cfargument name="pageSize" type="numeric" required="true">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/ListFolder.ashx" method="get" throwonerror="true" charset="utf-8">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="folderPath" value="#arguments.folderPath#" type="url">
			<cfhttpparam name="pageNumber" value="#arguments.pageNumber#" type="url">
			<cfhttpparam name="pageSize" value="#arguments.pageSize#" type="url">
			<cfhttpparam name="sortCode" value="Name" type="url">
			<cfhttpparam name="sortDescending" value="false" type="url">
		</cfhttp>
		<!--- Trim the XML. Workaround for a bug in the engine that does not parse XML correctly --->
		<cfset trimxml = trim(cfhttp.FileContent)>
		<cfset thelen = len(trimxml)>
		<cfset findit = findoneof("<",cfhttp.FileContent)>
		<cfset thexml = mid(cfhttp.FileContent, findit, thelen)>
		<cfset xmlVar = xmlParse(thexml)/>
		<!--- Return --->
		<cfreturn xmlVar>
	</cffunction>
	
	<!---  --->
	<!--- FILES --->
	<!---  --->
	
	<!--- FUNCTION: MOVE FILES --->
	<cffunction name="MoveFiles" access="public" output="false">
		<cfargument name="srcFilePath" type="string" required="true">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/MoveFiles.ashx" method="get" throwonerror="true">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="srcFilePath" value="#arguments.srcFilePath#" type="url">
			<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: COPY FILES --->
	<cffunction name="CopyFiles" access="public" output="false">
		<cfargument name="srcFilePath" type="string" required="true">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/CopyFiles.ashx" method="get" throwonerror="true">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="srcFilePath" value="#arguments.srcFilePath#" type="url">
			<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: DELETE FILES --->
	<cffunction name="DeleteFiles" access="public" output="false">
		<cfargument name="filePath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/DeleteFiles.ashx" method="get" throwonerror="true">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="filePath" value="#arguments.filePath#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: RENAME FILE --->
	<cffunction name="RenameFile" access="public" output="false">
		<cfargument name="filePath" type="string" required="true">
		<cfargument name="newFileName" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/RenameFile.ashx" method="get" throwonerror="true">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="filePath" value="#arguments.filePath#" type="url">
			<cfhttpparam name="newFileName" value="#arguments.newFileName#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!---  --->
	<!--- SHARING --->
	<!---  --->
	
	<!--- FUNCTION: DISABLE SHARING --->
	<cffunction name="RemoveHostedItem" access="public" output="false">
		<cfargument name="sharePath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- If we call this function directly we don't have the session in the variables --->
		<cfif NOT structkeyexists(variables,"nvxsession")>
			<cfset variables.nvxsession = arguments.nvxsession>
		</cfif>
		<!--- Call --->
		<cftry>
			<!--- <cfset NxRemovehosteditem(variables.nvxsession,arguments.sharePath)> --->
			<cfhttp url="http://services.nirvanix.com/ws/Sharing/RemoveHostedItem.ashx" method="get" throwonerror="true">
				<cfhttpparam name="sessionToken" value="#variables.nvxsession#" type="url">
				<cfhttpparam name="sharePath" value="#arguments.sharePath#" type="url">
			</cfhttp>
			<cfcatch type="any">
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: ENABLE SHARING --->
	<cffunction name="CreateHostedItem" access="public" output="false">
		<cfargument name="sharePath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- If we call this function directly we don't have the session in the variables --->
		<cfif NOT structkeyexists(variables,"nvxsession")>
			<cfset variables.nvxsession = arguments.nvxsession>
		</cfif>
		<!--- Call --->
		<cftry>
			<!--- <cfset NxCreatehosteditem(variables.nvxsession,arguments.sharePath)> --->
			<cfhttp url="http://services.nirvanix.com/ws/Sharing/CreateHostedItem.ashx" method="get" throwonerror="true">
				<cfhttpparam name="sessionToken" value="#variables.nvxsession#" type="url">
				<cfhttpparam name="sharePath" value="#arguments.sharePath#" type="url">
			</cfhttp>
			<cfcatch type="any">
				<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="Error on CreateHostedItem">
					<cfdump var="#cfcatch#" />
				</cfmail>
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!---  --->
	<!--- ACCOUNTING --->
	<!---  --->

	<!--- FUNCTION: CREATE CHILD ACCOUNT --->
	<cffunction name="CreateChildAccount" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="firstName" type="string" required="false">
		<cfargument name="lastName" type="string" required="false">
		<cfargument name="middleInitial" type="string" required="false">
		<cfargument name="phoneNumber" type="string" required="false">
		<cfargument name="emailAddress" type="string" required="false">
		<cfargument name="emailFormat" type="string" required="false">
		<cfargument name="addressLine1" type="string" required="false">
		<cfargument name="addressLine2" type="string" required="false">
		<cfargument name="state" type="string" required="false">
		<cfargument name="countryID" type="string" required="false">
		<cfargument name="postalCode" type="string" required="false">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- If we call this function directly we don't have the session in the variables --->
		<cfif NOT structkeyexists(variables,"appkey")>
			<cfset variables.nvxsession = arguments.nvxsession>
		</cfif>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/CreateChildAccount.ashx" method="get" throwonerror="true">
			<cfhttpparam name="sessionToken" value="#variables.nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
			<cfhttpparam name="password" value="#arguments.password#" type="url">
			<cfhttpparam name="firstName" value="#arguments.firstName#" type="url">
			<cfhttpparam name="lastName" value="#arguments.lastName#" type="url">
			<cfhttpparam name="middleInitial" value="#arguments.middleInitial#" type="url">
			<cfhttpparam name="phoneNumber" value="#arguments.phoneNumber#" type="url">
			<cfhttpparam name="emailAddress" value="#arguments.emailAddress#" type="url">
			<cfhttpparam name="emailFormat" value="#arguments.emailFormat#" type="url">
			<cfhttpparam name="addressLine1" value="#arguments.addressLine1#" type="url">
			<cfhttpparam name="addressLine2" value="#arguments.addressLine2#" type="url">
			<cfhttpparam name="state" value="#arguments.state#" type="url">
			<cfhttpparam name="countryID" value="#arguments.countryID#" type="url">
			<cfhttpparam name="postalCode" value="#arguments.postalCode#" type="url">
		</cfhttp>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: DELETE CHILD ACCOUNT --->
	<cffunction name="DeleteChildAccount" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/DeleteChildAccount.ashx" method="get" throwonerror="true">
			<cfhttpparam name="sessionToken" value="#variables.nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: GET STORAGE USAGE --->
	<cffunction name="GetStorageUsage" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/GetStorageUsage.ashx" method="get" throwonerror="true" charset="utf-8">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
		</cfhttp>
		<cfreturn cfhttp>
	</cffunction>
	
	<!--- FUNCTION: GET ACCOUNT USAGE --->
	<cffunction name="GetAccountUsage" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Set Structure --->
		<cfset x = structnew()>
		<!--- Call --->
		<!--- <cfset nvxusage = NxGetaccountusage(variables.nvxsession,arguments.username)> --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/GetAccountUsage.ashx" method="get" throwonerror="true" charset="utf-8">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.username#" type="url">
		</cfhttp>
		<!--- Trim the XML. Workaround for a bug in the engine that does not parse XML correctly --->
		<cfset trimxml = trim(cfhttp.FileContent)>
		<cfset thelen = len(trimxml)>
		<cfset findit = findoneof("<",cfhttp.FileContent)>
		<cfset thexml = mid(cfhttp.FileContent, findit, thelen)>
		<cfset xmlVar = xmlParse(thexml)/>
		<!--- Get the XML node for each setting --->
		<!--- <cfset x.DBU = nvxusage[1].usage>
		<cfset x.UBU = nvxusage[3].usage>
		<cfset x.TSU = nvxusage[2].usage> --->
		<cfset DBU = xmlSearch(xmlVar, "//GetUsage[ FeatureName[ text() = 'Download Bandwidth Usage' ] ]")>
		<cfset UBU = xmlSearch(xmlVar, "//GetUsage[ FeatureName[ text() = 'Upload Bandwidth Usage' ] ]")>
		<cfset TSU = xmlSearch(xmlVar, "//GetUsage[ FeatureName[ text() = 'Total Storage Usage' ] ]")>
		<!--- Set the Usage Amount into struct --->
		<cfset x.DBU = #DBU[1].TotalUsageAmount.xmlText#>
		<cfset x.UBU = #UBU[1].TotalUsageAmount.xmlText#>
		<cfset x.TSU = #TSU[1].TotalUsageAmount.xmlText#>
		<!--- Add bandwidth together --->
		<cfset x.band = x.DBU + x.UBU>
		<!--- According to host type set the alert --->
		<cfif session.hosttype EQ "F">
			<cfset var storage = 536870912>
			<cfset var bandud = 268435456>
			<cfif x.tsu GTE storage OR x.band GTE bandud>
				<cfset x.limitup = true>
			</cfif>
		</cfif>
		<!--- Return --->
		<cfreturn x>
	</cffunction>
	
	<!--- FUNCTION: GET ACCOUNT LIMITS --->
	<cffunction name="GetAccountLimits" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/GetAccountLimits.ashx" method="get" throwonerror="true" charset="utf-8">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
		</cfhttp>
		<cfreturn cfhttp>
	</cffunction>
	
	<!--- FUNCTION: SET ACCOUNT LIMITS --->
	<cffunction name="SetAccountLimits" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="Type" type="string" required="true">
		<cfargument name="Value" type="string" required="true">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/SetAccountLimits.ashx" method="get" throwonerror="true">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
			<cfhttpparam name="#arguments.Type#" value="#arguments.value#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: SIGNED URL --->
	<cffunction name="signedurl" access="public" output="true">
		<cfargument name="theasset" type="string" required="true" />
		<cfargument name="minutesValid" type="string" required="false" default="5259600">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<cfset var x = structnew()>
		<cfset x.theurl = "">
		<!--- Create Epoc time --->
		<cfset x.newepoch = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + (arguments.minutesValid * 60)>
		<!--- Get Signed URL --->
		<cftry>
			<!--- <cfset var theurl = NxGetoptimalurls(variables.nvxsession,"//razuna/#session.hostid#/#arguments.theasset#",x.newepoch)> --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/GetOptimalUrls.ashx" method="get" throwonerror="true">
				<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
				<cfhttpparam name="filePath" value="//razuna/#session.hostid#/#arguments.theasset#" type="url">
				<cfhttpparam name="expiration" value="#x.newepoch#" type="url">
			</cfhttp>
			<!--- Get downloadurl
			<cfset xmlfound = xmlSearch(cfhttp.FileContent, "//DownloadURL")>
			<cfset x.theurl = xmlfound[1].xmlText> --->
			<!--- Parse XML --->
			<cfset var d = xmlparse(cfhttp.filecontent)>
			<!--- Get Downloadtoken --->
			<cfset x.theurl = d.Response.Download.DownloadURL[1].XmlText>
			<!--- Set download url --->
<!--- 			<cfset x.theurl = "http://services.nirvanix.com/" & dtoken & "/razuna/#session.hostid#/#arguments.theasset#"> --->
			<cfcatch type="any">
				<cfmail from="server@razuna.com" to="support@razuna.com" subject="debug signedurl" type="html">
					<cfdump var="#cfcatch#">
					<cfdump var="#arguments#">
					<cfdump var="#cfhttp#">
				</cfmail>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn x />
	</cffunction>
	
	<!--- FUNCTION: Download --->
	<cffunction name="download" access="public" output="true">
		<cfargument name="remotefile" type="string" required="true" />
		<cfargument name="localfile" type="string" required="true" />
		<cfargument name="nvxsession" type="string" required="true" />
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Download asset --->
		<cfset NXGetFile(nvxsession, arguments.remotefile, arguments.localfile)>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
</cfcomponent>