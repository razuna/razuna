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
	<cffunction name="init" returntype="amazon" access="public" output="false">
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<!--- FUNCTION: VALIDATE --->
	<cffunction name="validate" returntype="string" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="yes" />
			<cftry>
				<!--- Register Datasource --->
				<cfset AmazonRegisterDataSource("amazoncon","#arguments.thestruct.awskey#","#arguments.thestruct.awskeysecret#","#arguments.thestruct.awslocation#")>
				<cfset d = AmazonS3listbuckets("amazoncon")>
				<cfoutput>
				<br />
				<span style="color:green;font-weight:bold;">Connection is valid!</span>
				</cfoutput>
				<cfcatch type="any">
					<cfoutput>
					<br />
					<span style="color:red;font-weight:bold;">We could not validate your credentials!</span>
					<br />
					#cfcatch.message#
					</cfoutput>
				</cfcatch>
			</cftry>
			<!--- Remove source --->
			<cfset AmazonRemovedatasource("amazoncon")>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: VALIDATE BUCKET --->
	<cffunction name="validatebucket" returntype="string" access="public" output="true">
		<cfargument name="awsbucket" type="string" required="true" />
		<cftry>
			<!--- Check to see if we can list the buckets --->
			<cfset mydir = AmazonS3list(application.razuna.s3ds,"#lcase(arguments.awsbucket)#")>
			<cfoutput>
				<span style="color:green;font-weight:bold;">Success. The bucket can be read by Razuna!</span>
			</cfoutput>
			<cfcatch type="any">
				<cfoutput>
					<span style="color:red;font-weight:bold;">Unfortunately, your bucket can not be read. Make sure it exists and you did not mistype.</span>
				</cfoutput>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- FUNCTION: UPLOAD --->
	<cffunction name="upload" access="public" output="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="theasset" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<!--- <cfset var aws = AmazonRegisterDataSource("up",application.razuna.awskey,application.razuna.awskeysecret,application.razuna.awslocation)> --->
		<!--- Upload asset --->
		<cfset AmazonS3write(
			datasource=application.razuna.s3ds,
			bucket=arguments.awsbucket,
			key=arguments.key,
			file=arguments.theasset
		)>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: Download --->
	<cffunction name="download" access="public" output="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="theasset" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<!--- Download asset --->
		<cfset AmazonS3read(
			datasource=application.razuna.s3ds,
			bucket=arguments.awsbucket,
			key=arguments.key,
			file=arguments.theasset
		)>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: SIGNED URL --->
	<cffunction name="signedurl" access="public" output="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="minutesValid" type="string" required="false" default="5259600">
		<cfset var aws = AmazonRegisterDataSource("up",application.razuna.awskey,application.razuna.awskeysecret,application.razuna.awslocation)>
		<cfset var x = structnew()>
		<!--- Add 10 years to expiration --->
		<cfset epoch = dateadd("yyyy", 10, now())>
		<!--- Epoch seconds (convert local time to UTC) --->
		<cfset x.newepoch = dateDiff("s", "January 1 1970 00:00", dateConvert("Local2utc", epoch))>
		<!--- Create the signed URL --->
		<cfset x.theurl = AmazonS3geturl(
		   datasource=aws, 
		   bucket=arguments.awsbucket, 
		   key=arguments.key, 
		   expiration=epoch
		)>
		<!--- Return --->
		<cfreturn x />
	</cffunction>
	
	<!--- FUNCTION: List Keys --->
	<cffunction name="listkeys" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<!--- Get keys --->
		<!--- <cfinvoke component="s3" method="getbucket" bucketName="#arguments.awsbucket#" prefix="#arguments.folderpath#" returnVariable="thekeys" /> --->
		<!--- Get keys --->
		<cfset thekeys = AmazonS3list(
			datasource=application.razuna.s3ds, 
			bucket=arguments.awsbucket, 
			prefix="#arguments.folderpath#/"
		)>
		<!--- Return --->
		<cfreturn thekeys />
	</cffunction>
	
	<!--- FUNCTION: Delete folder --->
	<cffunction name="deletefolder" access="public" output="true">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<!--- Get keys --->
		<cfset thekeys = listkeys(arguments.folderpath,arguments.awsbucket)>
		<!--- Loop over the keys and delete them --->
		<cfloop query="thekeys">
			<cfif size NEQ 0>
				<cfset i = AmazonS3getinfo(application.razuna.s3ds,arguments.awsbucket,key)>
				<cfset AmazonS3delete(application.razuna.s3ds,arguments.awsbucket,i.key)>
			</cfif>
		</cfloop>
		<!--- Finally remove folder which is empty now --->
		<cfset AmazonS3delete(application.razuna.s3ds,arguments.awsbucket,arguments.folderpath)>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: Move folder --->
	<cffunction name="movefolder" access="public" output="true">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="folderpathdest" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<!--- Get keys --->
		<cfset thekeys = listkeys(arguments.folderpath,arguments.awsbucket)>
		<!--- Call the renameobject function which will copy and delete at the same time --->
		<cfloop query="thekeys" >
			<cfset thefile = listlast(key,"/")>
			<cfinvoke component="s3" method="renameObject">
				<cfinvokeargument name="oldBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="newBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="oldFileKey" value="#key#">
				<cfinvokeargument name="newFileKey" value="#arguments.folderpathdest#/#thefile#">
			</cfinvoke>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: Copy folder --->
	<cffunction name="copyfolder" access="public" output="true">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="folderpathdest" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<!--- Get keys --->
		<cfset thekeys = listkeys(arguments.folderpath,arguments.awsbucket)>
		<!--- Call the copyobject function --->
		<cfloop query="thekeys" >
			<cfset thefile = listlast(key,"/")>
			<cfinvoke component="s3" method="copyObject">
				<cfinvokeargument name="oldBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="newBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="oldFileKey" value="#key#">
				<cfinvokeargument name="newFileKey" value="#arguments.folderpathdest#/#thefile#">
			</cfinvoke>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- get endpoint --->
	<cffunction name="endpoints" access="public" output="true">
		<cfargument name="location" type="string" required="true" />
		<cfset var x = "">
		<!--- Define endpoint --->
		<cfif arguments.location EQ "us-east">
			<cfset x = "s3">
		<cfelseif arguments.location EQ "us-west-2">
			<cfset x = "s3-us-west-2">
		<cfelseif arguments.location EQ "us-west-1">
			<cfset x = "s3-us-west-1">
		<cfelseif arguments.location EQ "eu">
			<cfset x = "s3-eu-west-1">
		<cfelseif arguments.location EQ "ap-southeast-1">
			<cfset x = "s3-ap-southeast-1">
		<cfelseif arguments.location EQ "ap-northeast-1">
			<cfset x = "s3-ap-northeast-1">
		<cfelseif arguments.location EQ "sa-east-1">
			<cfset x = "s3-sa-east-1">
		</cfif> 
		<!--- Append amazon.com --->
		<cfset x = x & ".amazon.com">
		<!--- Return --->
		<cfreturn x />
	</cffunction>

	<!--- Retrieves file and folder metadata --->
	<cffunction name="metadata_and_thumbnails">
		<cfargument name="path" required="false" default="">
		<cfargument name="sf_id" required="true">
		<!--- Param --->
		<cfset var result = structNew()>
		<!--- Check that we have a Amazon Datasource --->
		<cfset var ar = awssourcecheck(arguments.sf_id)>
		<!--- Only continue if we are true --->
		<cfif ar>
			<!--- If path is only a / --->
			<cfif arguments.path EQ "/">
				<cfset arguments.path = "">
			</cfif>
			<!--- Get keys --->
			<cfset result.contents = AmazonS3list(
				datasource=session.aws[arguments.sf_id].datasource, 
				bucket=session.aws[arguments.sf_id].bucket, 
				prefix=arguments.path
			)>
			<!--- set path --->
			<cfset result.path = arguments.path>
		</cfif>
		<!--- Return --->
		<cfreturn result />
	</cffunction>
	
	<!--- Check RegisterDatasource --->
	<cffunction name="awssourcecheck" access="private" returntype="String">
		<cfargument name="sf_id" required="true">
		<!--- Param --->
		<cfset var exists = false>
		<cfset var qry = "">
		<cfset var qry_aws_settings = "">
		<!--- Check if a session with this smartfolder id exists --->
		<cfif !structKeyExists(session,"aws") OR !structKeyExists(session.aws,arguments.sf_id)>
			<cftry>
				<!--- Query --->
				<cfquery datasource="#application.razuna.datasource#" name="qry">
				SELECT sf_prop_value
				FROM #session.hostdbprefix#smart_folders_prop
				WHERE sf_prop_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="bucket">
				AND sf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_id#">
				</cfquery>
				<!--- Get ID from bucket variable --->
				<cfset var awsid = listLast(qry.sf_prop_value,"_")>
				<!--- Get the AWS information with the selected bucket --->
				<cfquery datasource="#application.razuna.datasource#" name="qry_aws_settings">
				SELECT set_id, set_pref
				FROM #session.hostdbprefix#settings
				WHERE lower(set_id) LIKE 'aws_%_#awsid#'
				</cfquery>
				<!--- Set the Amazon datasource --->
				<cfif qry_aws_settings.recordcount NEQ 0>
					<cfloop query="qry_aws_settings">
						<cfset aws[set_id] = set_pref>
					</cfloop>
					<!--- Set source --->
					<cfset session.aws[arguments.sf_id].datasource = AmazonRegisterDataSource(arguments.sf_id,evaluate("aws.aws_access_key_id_#awsid#"),evaluate("aws.aws_secret_access_key_#awsid#"),evaluate("aws.aws_bucket_location_#awsid#"))>
					<!--- Set Bucket --->
					<cfset session.aws[arguments.sf_id].bucket = evaluate("aws.aws_bucket_name_#awsid#")>
					<!--- Set var to true --->
					<cfset var exists = true>
				<cfelse>
					<cfthrow type="any" message="No credentials associated with this account" detail="Please enter a valid Amazon access key and token in the Razuna administration!" />
				</cfif>
				<!--- Error --->
				<cfcatch type="any">
					<cfoutput>An error has occured connecting to your Amazon S3 account<br />Message: #cfcatch.message# <br />Detail: #cfcatch.detail#</cfoutput>
					<cfset cfcatch.custom_message = "An error has occured connecting to your Amazon S3 account in function amazon.awssourcecheck">
					<cfset errobj.logerrors(cfcatch,false)/>
					<cfabort>
				</cfcatch>
			</cftry>
		<!--- All exists --->
		<cfelse>
			<!--- Set var to true --->
			<cfset var exists = true>
		</cfif>
		<!--- Return --->
		<cfreturn exists />
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
		<!--- Check if amazon dir is there --->
		<cfif !directoryExists("#td#amazon")>
			<cfdirectory action="create" directory="#td#amazon" mode="775" />
		</cfif>
		<!--- Loop over path list --->
		<cfloop list="#arguments.path#" index="f" delimiters=",">
			<!--- Now download file --->
			<cftry>
				<cfset AmazonS3read(
				   datasource=session.aws[session.sf_id].datasource, 
				   bucket=session.aws[session.sf_id].bucket, 
				   key=f,
				   file="#td#amazon/#listlast(f,"/")#"
				)>
				<!--- Set the filename. We need this is the asset function for the server add --->
				<cfset arguments.thestruct.thefile = listlast(f,"/")>
				<!--- Call internal function to add the file --->
				<cfinvoke component="assets" method="addassetserver" thestruct="#arguments.thestruct#" />
				<cfcatch type="any">
					<cfset custom_message = "Error in function amazon.downloadfilesthread">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Streams file to browser --->
	<cffunction name="media" access="public" returntype="void">
		<cfargument name="path" required="false" default="/">
		<cfargument name="download" required="false" default="false" />
		<!--- Add 10 years to expiration --->
		<cfset var epoch = dateadd("n", 10, now())>
		<!--- Epoch seconds (convert local time to UTC) --->
		<cfset var newepoch = dateDiff("s", "January 1 1970 00:00", dateConvert("Local2utc", epoch))>
		<!--- Create the signed URL --->
		<cfset var theurl = AmazonS3geturl(
		   datasource=session.aws[session.sf_id].datasource, 
		   bucket=session.aws[session.sf_id].bucket, 
		   key=arguments.path, 
		   expiration=epoch
		)>
		<!--- Redirect --->
		<cflocation url="#theurl#" />
		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>
