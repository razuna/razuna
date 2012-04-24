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
		<cfloop array="#thekeys#" index="i">
			<cfset thefile = listlast(i.key,"/")>
			<cfinvoke component="s3" method="renameObject">
				<cfinvokeargument name="oldBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="newBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="oldFileKey" value="#i.key#">
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
		<cfloop array="#thekeys#" index="i">
			<cfset thefile = listlast(i.key,"/")>
			<cfinvoke component="s3" method="copyObject">
				<cfinvokeargument name="oldBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="newBucketName" value="#arguments.awsbucket#">
				<cfinvokeargument name="oldFileKey" value="#i.key#">
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
	
</cfcomponent>
