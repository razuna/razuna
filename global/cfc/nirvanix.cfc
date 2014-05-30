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
	<!--- Errors Object --->
	<cfobject component="global.cfc.errors" name="errobj">

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
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Params --->
		<cfset var nvxsession = 0>
		<cfif !isstruct(arguments.thestruct)>
			<cfset arguments.thestruct = structnew()>
		</cfif>
		<cfparam name="arguments.thestruct.isbrowser" default="F" />
		<!--- If we call this function directly we don't have the appkey in the variables --->
		<cfif NOT structkeyexists(variables,"appkey")>
			<cfset variables.appkey = application.razuna.nvxappkey>
		</cfif>
		<!--- Grab NVX settings --->
		<cfinvoke component="settings" method="prefs_storage" returnVariable="qry_settings" />
		<!--- Login and get session token --->
		<cftry>
			<cfif arguments.thestruct.isbrowser EQ "F">
				<cfhttp url="http://services.nirvanix.com/ws/Authentication/Login.ashx" method="get" throwonerror="yes" charset="utf-8" timeout="60">
					<cfhttpparam name="appKey" value="#variables.appkey#" type="url">
					<cfhttpparam name="username" value="#qry_settings.set2_nirvanix_name#" type="url">
					<cfhttpparam name="password" value="#qry_settings.set2_nirvanix_pass#" type="url">
					<cfhttpparam name="_v" value="#createuuid()#" type="url">
				</cfhttp>
			<cfelse>
				<!--- If this is a Squid request then the ip is not in the remote_addr cgi variable --->
				<cfif structkeyexists(cgi,"http_x_forwarded_for")>
					<cfset var theremoteip = cgi.http_x_forwarded_for>
				<cfelse>
					<cfset var theremoteip = cgi.remote_addr>
				</cfif>
				<!--- Get the SessionToken --->
				<cfhttp url="http://services.nirvanix.com/ws/Authentication/LoginProxy.ashx" method="get" throwonerror="yes" charset="utf-8" timeout="60">
					<cfhttpparam name="appKey" value="#variables.appkey#" type="url">
					<cfhttpparam name="username" value="#qry_settings.set2_nirvanix_name#" type="url">
					<cfhttpparam name="password" value="#qry_settings.set2_nirvanix_pass#" type="url">
					<cfhttpparam name="consumerIP" value="#theremoteip#" type="url">
					<cfhttpparam name="_v" value="#createuuid()#" type="url">
				</cfhttp>
			</cfif>
			<!--- Get the XML node for each setting --->
			<cfset var thexml = xmlparse(cfhttp.FileContent)>
			<cfset var nvxsession = thexml.Response.Sessiontoken[1].XmlText>
			<cfset session.nvxsession = nvxsession>
			<cfcatch type="any">
				<cfset var nvxsession = 0>
				<cfset session.nvxsession = nvxsession>
				<cfset sleep(5000)>
				<cfif arguments.thecounter NEQ 1>
					<cfinvoke method="login" thestruct="#arguments.thestruct#" thecounter="1" />
				</cfif>
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
			<cfhttp url="http://services.nirvanix.com/ws/Authentication/Login.ashx" method="get" throwonerror="no" charset="utf-8" timeout="30">
				<cfhttpparam name="appKey" value="#variables.appkey#" type="url">
				<cfhttpparam name="username" value="#qry_settings.set2_nirvanix_name#" type="url">
				<cfhttpparam name="password" value="#qry_settings.set2_nirvanix_pass#" type="url">
			</cfhttp>
			<!--- Get the XML node for each setting --->
			<cfset var xmlfound = xmlSearch(cfhttp.FileContent, "//SessionToken")>
			<cfset var nvxsession = xmlfound[1].xmlText>
			<cfcatch type="any">
				<cfset var nvxsession = 0>
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
			<cfhttp url="http://services.nirvanix.com/ws/Authentication/Login.ashx" method="get" throwonerror="no" charset="utf-8" timeout="30">
				<cfhttpparam name="appKey" value="#variables.appkey#" type="url">
				<cfhttpparam name="username" value="#arguments.thestruct.nvxname#" type="url">
				<cfhttpparam name="password" value="#arguments.thestruct.nvxpass#" type="url">
			</cfhttp>
			<!--- Get the XML node for each setting --->
			<cfset var thexml = xmlparse(cfhttp.FileContent)>
			<cfset var nvxsession = thexml.Response.ResponseCode[1].XmlText>
			<cfcatch type="any">
				<cfset var nvxsession = 1>
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
		<cfif fileexists(arguments.uploadfile)>			
			<!--- Params --->
			<cfset var tt = createuuid("")>
			<!--- Get Storage Node Stuff --->
			<cfset var storagenode = getstoragenode(arguments.destFolderPath)>
			<!--- Upload Asset --->
			<cftry>
				<cfhttp url="http://#storagenode.uploadhost#/Upload.ashx" method="post" throwonerror="yes" timeout="900">
					<cfhttpparam name="uploadToken" value="#storagenode.uploadtoken#" type="formfield">
					<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="formfield">
					<cfhttpparam name="uploadFile" file="#arguments.uploadfile#" type="file">
				</cfhttp>
				<!--- Parse the response --->
				<cfset var xmlVar = xmlParse(cfhttp.filecontent) />
				<!--- If we get a message the limit is exceeded then... --->
				<cfif xmlvar.Response.Responsecode[1].XmlText EQ "80019" OR xmlvar.Response.Responsecode[1].XmlText EQ "80020" OR xmlvar.Response.Responsecode[1].XmlText EQ "80021" OR xmlvar.Response.Responsecode[1].XmlText EQ "80022">
					<cfinvoke component="email" method="send_email" subject="Razuna: Could not add your file!" themessage="Hello.<br /><br />It looks like that you have exceeded your upload/download limit for your plan.<br /><br />If you want to add more files, you will need upgrade your Razuna plan to allow for more storage and bandwidth traffic! You can do so within the Account Settings of Razuna (upper right corner).<br /><br />Thank you for using Razuna.">
					<cfabort>
				<cfelseif xmlvar.Response.Responsecode[1].XmlText NEQ 0>
					<!--- Send customer email with the fail --->
					<cfinvoke component="email" method="send_email" subject="Razuna: Error during adding your file: #arguments.uploadfile#!" themessage="Unfortunately something went wrong during uploading your file (#arguments.uploadfile#) to the storage. Thus your file is not available on Razuna.<br /><br />The Razuna support team has been notified of this and will look into it immediately.">
					<!--- Send us the error --->
					<cfmail from="server@razuna.com" to="support@razuna.com" subject="upload nirvanix error (user notified)" type="html"><cfdump var="#xmlvar#"><cfdump var="#arguments#"><cfdump var="#storagenode#"></cfmail>
					<cfabort>
				</cfif>
				<cfcatch type="any">
					<cfset cfcatch.custom_message = "Error while uploading in function nirvanix.upload">
					<cfset cfcatch.cfhttp_response = cfhttp>
					<cfset cfcatch.storagenode = storagenode>
					<cfset cfcatch.func_arguments = arguments>
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					<cfabort>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: GETSTORAGENODE --->
	<cffunction name="GetStorageNode" returntype="struct" access="public" output="false">
		<cfargument name="thepath" type="string" required="true">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Init struct --->
		<cfset var thenode = structnew()>
		
		<!--- Call --->
		<cftry>
			<!--- GetStorageNodeExtended --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/GetStorageNodeExtended.ashx" method="get" throwonerror="no" timeout="30">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<cfhttpparam name="sizeBytes" value="50000" type="url">
				<cfhttpparam name="fileOverwrite" value="true" type="url">
				<cfhttpparam name="destFolderPath" value="#arguments.thepath#" type="url">
				<!--- <cfhttpparam name="excludedNode" value="node4" type="url"> --->
			</cfhttp>
			<!--- GetStorageNode --->
			<!--- <cfhttp url="http://services.nirvanix.com/ws/IMFS/GetStorageNode.ashx" method="get" throwonerror="no" timeout="60">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<cfhttpparam name="sizeBytes" value="50000" type="url">
			</cfhttp> --->
			<!--- Parse --->
			<cfset var xmlVar = xmlParse(trim(cfhttp.filecontent))/>
			<!--- If session timed out --->
			<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
				<!--- Get session --->
				<cfset login()>
				<!--- Call method again --->
				<cfinvoke method="GetStorageNode" thepath="#arguments.thepath#" thecounter="1" />
			</cfif>
			<!--- Get the XML node for each setting --->
			<cfset thenode.uploadhost = xmlvar.Response.GetStorageNode.UploadHost[1].XmlText>
			<cfset thenode.uploadtoken = xmlvar.Response.GetStorageNode.UploadToken[1].XmlText>
			<cfcatch type="any">
				<!--- Send customer email with the fail --->
				<cfinvoke component="email" method="send_email" subject="Razuna: Error during adding your file!" themessage="Unfortunately something went wrong during uploading your file to the storage. Thus your file is not available on Razuna.<br /><br />The Razuna support team has been notified of this and will look into it immediately.">
				<!--- Send us the error --->
				<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="GetStorageNode nirvanix error">
					<cfdump var="#cfhttp.filecontent#" label="cfhttp">
					<cfdump var="#arguments#" label="arguments">
					<cfdump var="#cfcatch#" label="catch">
				</cfmail>
				<cfset cfcatch.custom_message = "Error in function nirvanix.GetStorageNode">
				<cfset cfcatch.cfhttp_filecontent = cfhttp.filecontent>
				<cfset cfcatch.func_arguments = arguments>
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				<cfabort>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn thenode>
	</cffunction>
	
	<!---  --->
	<!--- FOLDERS --->
	<!---  --->
	
	<!--- FUNCTION: CREATE FOLDERS --->
	<cffunction name="CreateFolders" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cftry>
			<!--- <cfset NxCreatefolder(variables.nvxsession,arguments.folderpath)> --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/CreateFolders.ashx" method="get" throwonerror="no" timeout="30">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<cfhttpparam name="folderPath" value="#arguments.folderpath#" type="url">
			</cfhttp>
			<!--- Parse XML --->
			<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
			<!--- If session timed out --->
			<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
				<!--- Get session --->
				<cfset login()>
				<!--- Call method again --->
				<cfinvoke method="CreateFolders" folderpath="#arguments.folderpath#" thecounter="1" />
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.CreateFolders">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: DELETE FOLDERS --->
	<cffunction name="DeleteFolders" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<!--- Call --->
		<!--- <cfset NxDeletefolder(variables.nvxsession,arguments.folderpath)> --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/DeleteFolders.ashx" method="get" throwonerror="no" timeout="30">
			<cfhttpparam name="sessionToken" value="#arguments.nvxsession#" type="url">
			<cfhttpparam name="folderPath" value="#arguments.folderpath#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: RENAME FOLDERS --->
	<cffunction name="RenameFolders" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true">
		<cfargument name="newFolderName" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<cftry>
			<!--- Call --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/RenameFolder.ashx" method="get" throwonerror="no" timeout="30">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<cfhttpparam name="folderPath" value="#arguments.folderpath#" type="url">
				<cfhttpparam name="newFolderName" value="#arguments.newFolderName#" type="url">
			</cfhttp>
			<!--- Parse XML --->
			<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
			<!--- If session timed out --->
			<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
				<!--- Get session --->
				<cfset login()>
				<!--- Call method again --->
				<cfinvoke method="RenameFolders" folderpath="#arguments.folderpath#" newFolderName="#arguments.newFolderName#" thecounter="1" />
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.RenameFolders">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: COPY FOLDERS --->
	<cffunction name="CopyFolders" access="public" output="false">
		<cfargument name="srcFolderPath" type="string" required="true">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<cftry>
			<!--- Call --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/CopyFolders.ashx" method="get" throwonerror="no" timeout="30">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<cfhttpparam name="srcFolderPath" value="#arguments.srcFolderPath#" type="url">
				<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
			</cfhttp>
			<!--- Parse XML --->
			<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
			<!--- If session timed out --->
			<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
				<!--- Get session --->
				<cfset login()>
				<!--- Call method again --->
				<cfinvoke method="CopyFolders" srcFolderPath="#arguments.srcFolderPath#" destFolderPath="#arguments.destFolderPath#" thecounter="1" />
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.CopyFolders">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: MOVE FOLDERS --->
	<cffunction name="MoveFolders" access="public" output="false">
		<cfargument name="srcFolderPath" type="string" required="true">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<cftry>
			<!--- Call --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/MoveFolders.ashx" method="get" throwonerror="no" timeout="30">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<cfhttpparam name="srcFolderPath" value="#arguments.srcFolderPath#" type="url">
				<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
			</cfhttp>
			<!--- Parse XML --->
			<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
			<!--- If session timed out --->
			<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
				<!--- Get session --->
				<cfset login()>
				<!--- Call method again --->
				<cfinvoke method="MoveFolders" srcFolderPath="#arguments.srcFolderPath#" destFolderPath="#arguments.destFolderPath#" thecounter="1" />
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.MoveFolders">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
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
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/ListFolder.ashx" method="get" throwonerror="no" charset="utf-8" timeout="30">
			<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
			<cfhttpparam name="folderPath" value="#arguments.folderPath#" type="url">
			<cfhttpparam name="pageNumber" value="#arguments.pageNumber#" type="url">
			<cfhttpparam name="pageSize" value="#arguments.pageSize#" type="url">
			<cfhttpparam name="sortCode" value="Name" type="url">
			<cfhttpparam name="sortDescending" value="false" type="url">
		</cfhttp>
		<!--- Parse XML --->
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- If session timed out --->
		<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
			<!--- Get session --->
			<cfset login()>
			<!--- Call method again --->
			<cfinvoke method="ListFolder" folderPath="#arguments.folderPath#" pageNumber="#arguments.pageNumber#" pageSize="#arguments.pageSize#" thecounter="1" />
		</cfif>
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
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/MoveFiles.ashx" method="get" throwonerror="no" timeout="30">
			<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
			<cfhttpparam name="srcFilePath" value="#arguments.srcFilePath#" type="url">
			<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
		</cfhttp>
		<!--- Parse XML --->
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- If session timed out --->
		<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
			<!--- Get session --->
			<cfset login()>
			<!--- Call method again --->
			<cfinvoke method="MoveFiles" srcFilePath="#arguments.srcFilePath#" destFolderPath="#arguments.destFolderPath#" thecounter="1" />
		</cfif>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: COPY FILES --->
	<cffunction name="CopyFiles" access="public" output="false">
		<cfargument name="srcFilePath" type="string" required="true">
		<cfargument name="destFolderPath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/CopyFiles.ashx" method="get" throwonerror="no" timeout="30">
			<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
			<cfhttpparam name="srcFilePath" value="#arguments.srcFilePath#" type="url">
			<cfhttpparam name="destFolderPath" value="#arguments.destFolderPath#" type="url">
		</cfhttp>
		<!--- Parse XML --->
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- If session timed out --->
		<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
			<!--- Get session --->
			<cfset login()>
			<!--- Call method again --->
			<cfinvoke method="CopyFiles" srcFilePath="#arguments.srcFilePath#" destFolderPath="#arguments.destFolderPath#" thecounter="1" />
		</cfif>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: DELETE FILES --->
	<cffunction name="DeleteFiles" access="public" output="false">
		<cfargument name="filePath" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<cftry>
			<!--- Call --->
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/DeleteFiles.ashx" method="get" throwonerror="no" timeout="60">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<cfhttpparam name="filePath" value="#arguments.filePath#" type="url">
			</cfhttp>
			<!--- Parse XML --->
			<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
			<!--- If session timed out --->
			<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
				<!--- Get session --->
				<cfset login()>
				<!--- Call method again --->
				<cfinvoke method="DeleteFiles" filePath="#arguments.filePath#" thecounter="1" />
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.DeleteFiles">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: RENAME FILE --->
	<cffunction name="RenameFile" access="public" output="false">
		<cfargument name="filePath" type="string" required="true">
		<cfargument name="newFileName" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/RenameFile.ashx" method="get" throwonerror="no">
			<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
			<cfhttpparam name="filePath" value="#arguments.filePath#" type="url">
			<cfhttpparam name="newFileName" value="#arguments.newFileName#" type="url">
		</cfhttp>
		<!--- Parse XML --->
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- If session timed out --->
		<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
			<!--- Get session --->
			<cfset login()>
			<!--- Call method again --->
			<cfinvoke method="RenameFile" filePath="#arguments.filePath#" newFileName="#arguments.newFileName#" thecounter="1" />
		</cfif>
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
			<cfhttp url="http://services.nirvanix.com/ws/Sharing/RemoveHostedItem.ashx" method="get" throwonerror="no">
				<cfhttpparam name="sessionToken" value="#variables.nvxsession#" type="url">
				<cfhttpparam name="sharePath" value="#arguments.sharePath#" type="url">
			</cfhttp>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.RemoveHostedItem">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
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
			<cfhttp url="http://services.nirvanix.com/ws/Sharing/CreateHostedItem.ashx" method="get" throwonerror="no">
				<cfhttpparam name="sessionToken" value="#variables.nvxsession#" type="url">
				<cfhttpparam name="sharePath" value="#arguments.sharePath#" type="url">
			</cfhttp>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.CreateHostedItem">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
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
		<cfhttp url="http://services.nirvanix.com/ws/accounting/CreateChildAccount.ashx" method="get" throwonerror="no">
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
		<cfhttp url="http://services.nirvanix.com/ws/accounting/DeleteChildAccount.ashx" method="get" throwonerror="no">
			<cfhttpparam name="sessionToken" value="#variables.nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
		</cfhttp>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: GET STORAGE USAGE --->
	<cffunction name="GetStorageUsage" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/GetStorageUsage.ashx" method="get" throwonerror="no" charset="utf-8">
			<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
		</cfhttp>
		<!--- Parse XML --->
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- If session timed out --->
		<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
			<!--- Get session --->
			<cfset login()>
			<!--- Call method again --->
			<cfinvoke method="GetStorageUsage" userName="#arguments.userName#" thecounter="1" />
		</cfif>
		<cfreturn cfhttp>
	</cffunction>
	
	<!--- FUNCTION: GET ACCOUNT USAGE --->
	<cffunction name="GetAccountUsage" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="nvxsession" type="string" required="false">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Set Structure --->
		<cfset x = structnew()>
		<cfset x.DBU = 0>
		<cfset x.UBU = 0>
		<cfset x.TSU = 0>
		<cfset x.band = 0>
		<cfif application.razuna.isp>
			<cftry>
				<!--- Call --->
				<!--- <cfset nvxusage = NxGetaccountusage(variables.nvxsession,arguments.username)> --->
				<cfhttp url="http://services.nirvanix.com/ws/accounting/GetAccountUsage.ashx" method="get" throwonerror="no" charset="utf-8" timeout="60">
					<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
					<cfhttpparam name="userName" value="#arguments.username#" type="url">
				</cfhttp>
				<!--- Parse XML --->
				<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
				<!--- If session timed out --->
				<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
					<!--- Get session --->
					<cfset login()>
					<!--- Call method again --->
					<cfinvoke method="GetAccountUsage" userName="#arguments.userName#" thecounter="1" />
				</cfif>
				<!--- Set values --->
				<cfset var nvxDBU = xmlSearch(xmlVar, "//GetUsage[ FeatureName[ text() = 'Download Bandwidth Usage' ] ]")>
				<cfset var nvxUBU = xmlSearch(xmlVar, "//GetUsage[ FeatureName[ text() = 'Upload Bandwidth Usage' ] ]")>
				<cfset var nvxTSU = xmlSearch(xmlVar, "//GetUsage[ FeatureName[ text() = 'Total Storage Usage' ] ]")>
				<!--- Set the Usage Amount into struct --->
				<cftry>
					<cfset x.DBU = nvxDBU[1].TotalUsageAmount.xmlText>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Error setting usage amount in function nirvanix.GetAccountUsage">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
				<cftry>
					<cfset x.UBU = nvxUBU[1].TotalUsageAmount.xmlText>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Error setting usage amount in function nirvanix.GetAccountUsage">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
				<cftry>
					<cfset x.TSU = nvxTSU[1].TotalUsageAmount.xmlText>
					<cfcatch type="any">
						<cfset cfcatch.custom_message = "Error setting usage amount in function nirvanix.GetAccountUsage">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
				<!--- Add bandwidth together --->
				<cfset x.band = x.DBU + x.UBU>
				<!--- According to host type set the alert --->
				<cfif session.hosttype NEQ 149>
					<!--- <cfset var storage = 16106127360 - 10485760>
					<cfset var bandud = 8053063680 - 10485760> --->
					<!--- Total minus the variable value where we want to warn the user (currently when 2GB are left) --->
					<cfset var minusvalue = 2147483648>
					<!--- 0 --->
					<cfif session.hosttype EQ 0>
						<cfset var storage = 524288000 - 104857600>
						<cfset var bandud = 524288000 - 104857600>
					</cfif>
					<!--- 8 --->
					<cfif session.hosttype EQ 8>
						<cfset var storage = 2147483648 - 524288000>
						<cfset var bandud = 2147483648 - 524288000>
					</cfif>
					<!--- 24 --->
					<cfif session.hosttype EQ 24>
						<cfset var storage = 16106127360 - minusvalue>
						<cfset var bandud = 16106127360 - minusvalue>
					</cfif>
					<!--- 49 --->
					<cfif session.hosttype EQ 49>
						<cfset var storage = 53687091200 - minusvalue>
						<cfset var bandud = 53687091200 - minusvalue>
					</cfif>
					<!--- 99 --->
					<cfif session.hosttype EQ 99>
						<cfset var storage = 161061273600 - minusvalue>
						<cfset var bandud = 161061273600 - minusvalue>
					</cfif>
					<!--- If storage or bandwidth is full then set variable and email user --->
					<cfif x.tsu GTE storage OR x.DBU GTE bandud OR x.UBU GTE bandud>
						<!--- Send eMail --->
						<cfinvoke component="email" method="send_email" subject="Razuna: Your account needs upgrading" themessage="You have exceeded the total amount of storage or traffic for your account for this month!<br /><br />If you want to add any more files you need upgrade your Razuna plan to allow for more storage and bandwidth traffic!<br /><br />Please login to Razuna and then go to your Account Settings in order to upgrade your plan now.">
						<!--- Set var --->
						<cfset x.limitup = true>
					</cfif>
				</cfif>
				<cfcatch type="any">
					<cfset cfcatch.custom_message = "Error in function nirvanix.GetAccountUsage">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Return --->
		<cfreturn x>
	</cffunction>
	
	<!--- FUNCTION: GET ACCOUNT LIMITS --->
	<cffunction name="GetAccountLimits" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/GetAccountLimits.ashx" method="get" throwonerror="no" charset="utf-8">
			<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
		</cfhttp>
		<!--- Parse XML --->
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- If session timed out --->
		<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
			<!--- Get session --->
			<cfset login()>
			<!--- Call method again --->
			<cfinvoke method="GetAccountLimits" userName="#arguments.userName#" thecounter="1" />
		</cfif>
		<cfreturn cfhttp>
	</cffunction>
	
	<!--- FUNCTION: SET ACCOUNT LIMITS --->
	<cffunction name="SetAccountLimits" access="public" output="false">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="Type" type="string" required="true">
		<cfargument name="Value" type="string" required="true">
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Call --->
		<cfhttp url="http://services.nirvanix.com/ws/accounting/SetAccountLimits.ashx" method="get" throwonerror="no">
			<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
			<cfhttpparam name="userName" value="#arguments.userName#" type="url">
			<cfhttpparam name="#arguments.Type#" value="#arguments.value#" type="url">
		</cfhttp>
		<!--- Parse XML --->
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- If session timed out --->
		<cfif arguments.thecounter NEQ 1 AND xmlvar.Response.Responsecode[1].XmlText EQ "80006" OR xmlvar.Response.Responsecode[1].XmlText EQ "80101">
			<!--- Get session --->
			<cfset login()>
			<!--- Call method again --->
			<cfinvoke method="SetAccountLimits" userName="#arguments.userName#" Type="#arguments.Type#" Value="#arguments.Value#" thecounter="1" />
		</cfif>
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: SIGNED URL --->
	<cffunction name="signedurl" access="public" output="false">
		<cfargument name="theasset" type="string" required="true" />
		<cfargument name="minutesValid" type="string" required="false" default="5259600">
		<cfargument name="nvxsession" type="string" required="false">
		<cfset sleep(5000)>
		<!--- Create Epoc time --->
		<cfset arguments.newepoch = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + (arguments.minutesValid * 60)>
		<!--- Create thread --->
		<cfset var tt = createuuid("")>
		<cfthread name="#tt#" intstruct="#arguments#" output="yes">
			<cfinvoke method="signedurlthread" thestruct="#attributes.intstruct#" returnvariable="turl">
			<cfoutput>#turl#</cfoutput>
		</cfthread>
		<!--- Join thread --->
		<cfthread action="join" name="#tt#" timeout="6000" />
		<!--- Put variables together for return --->
		<cfset var u = structnew()>
		<cfset u.theurl = trim(cfthread["#tt#"].output)>
		<cfset u.newepoch = arguments.newepoch>
		<!--- Return --->
		<cfreturn u />
	</cffunction>

	<!--- FUNCTION: SIGNED URL --->
	<cffunction name="signedurlthread" access="public" output="false" returntype="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfargument name="thecounter" type="numeric" required="false" default="0">
		<!--- Get Signed URL --->
		<cftry>
			<cfhttp url="http://services.nirvanix.com/ws/IMFS/GetOptimalUrls.ashx" method="get" throwonerror="no">
				<cfhttpparam name="sessionToken" value="#session.nvxsession#" type="url">
				<!--- <cfhttpparam name="filePath" value="//razuna/#session.hostid#/#arguments.thestruct.theasset#" type="url"> --->
				<cfhttpparam name="filePath" value="/#arguments.thestruct.theasset#" type="url">
				<cfhttpparam name="expiration" value="#arguments.thestruct.newepoch#" type="url">
			</cfhttp>
			<!--- Parse XML --->
			<cfset var d = xmlparse(cfhttp.filecontent)>
			<!--- Get ResponseCode --->
			<cfset var respcode = d.Response.Responsecode[1].XmlText>
			<!--- If session timed out --->
			<cfif arguments.thecounter NEQ 1 AND (respcode EQ "80006" OR respcode EQ "80101")>
				<!--- Get session --->
				<cfset login()>
				<!--- Call method again --->
				<cfinvoke method="signedurl" theasset="#arguments.thestruct.theasset#" thecounter="1" />
			</cfif>
			<!--- If response is 0 then ok, else let us know --->
			<cfif respcode EQ 0>
				<!--- Get Downloadtoken --->
				<cfset var theurl = d.Response.Download.DownloadURL[1].XmlText>
			<cfelse>
				<!--- Set Downloadtoken --->
				<cfset var theurl = "node1.nirvanix.com">
				<!--- Send us eMail --->
				<!--- <cfmail from="server@razuna.com" to="nitai@razuna.com" subject="Nirvanix signedurl reponsecode" type="html">
					<cfdump var="#respcode#">
					<p>
					100	Missing required parameters	Occurs when one or more required parameters is missing.<br />
					70005	Invalid path	Occurs if any of the files do not exist or a if a folder was passed in.<br />
					70009	Path too long	Occurs when the total length of a relative path exceeds the maximum length of 512 characters.<br />
					70010	File/Folder name too long	Occurs when a file or folder name exceeds the maximum length of 256 characters.<br />
					70102	Invalid path character	Occurs when any path contains illegal characters.<br />
					80006	Session not found	Occurs when the session cannot be found. This may happen after the session has been ended with an explicit log out or the session has expired due to inactivity.<br />
					80101	Invalid session token	Occurs when the session token is malformed.<br />
					</p>
					<cfdump var="//razuna/#session.hostid#/#arguments.thestruct.theasset#">
					<cfdump var="#cfhttp#">
				</cfmail> --->
				<!--- Get last part of asset --->
				<cfset var lp = listlast(arguments.thestruct.theasset,"/")>
				<!--- Send eMail --->
				<cfif lp DOES NOT CONTAIN "thumb_">
					<cfquery datasource="#application.razuna.datasource#" name="qryuser">
					SELECT user_email
					FROM users
					WHERE user_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">
					</cfquery>
					<cfinvoke component="email" method="send_email" prefix="#session.hostdbprefix#" to="#qryuser.user_email#" subject="Error on adding your asset" themessage="Your asset (#lp#) could not be added to the system. The error message is:<br />Code: #respcode# <br />Message: #d.Response.ErrorMessage[1].XmlText#">
				</cfif>
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in function nirvanix.signedurlthread">
				<cfset cfcatch.thestruct = arguments.thestruct>
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				<!--- Set Downloadtoken --->
				<cfset var theurl = "node1.nirvanix.com">
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn theurl />
	</cffunction>
	
	<!--- FUNCTION: Download --->
	<cffunction name="download" access="public" output="true">
		<cfargument name="remotefile" type="string" required="true" />
		<cfargument name="localfile" type="string" required="true" />
		<cfargument name="nvxsession" type="string" required="false" />
		<!--- Get session --->
		<cfset var nvxsession = login()>
		<!--- Download asset --->
		<cfset NXGetFile(nvxsession, arguments.remotefile, arguments.localfile)>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
</cfcomponent>
