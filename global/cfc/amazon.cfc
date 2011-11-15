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
		<cfargument name="awskey" type="string" required="true" />
		<cfargument name="awskeysecret" type="string" required="true" />
		<!--- Set --->
		<cfset application.razuna.s3ds = AmazonRegisterDataSource("amz","#arguments.awskey#","#arguments.awskeysecret#")>
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<!--- FUNCTION: VALIDATE --->
	<cffunction name="validate" returntype="string" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="yes" />
			<!--- Set Source --->
			<cfset application.razuna.s3ds = AmazonRegisterDataSource("amz","#arguments.thestruct.awskey#","#application.razuna.awskeysecret#")>
			<!--- Create a bucket --->
			<cfset var tempid = replace(createuuid(),"-","","ALL")>
			<cfinvoke component="s3" method="putBucket" bucketName="#tempid#" returnVariable="x" />
			<!--- Check to see if we can list the buckets
			<cfset awsbuckets = AmazonS3listbuckets(application.razuna.s3ds)>
			<cfdump var="#awsbuckets#"><cfabort> --->
			<cfoutput>
			<cfif x>
				<br>
				<span style="color:green;font-weight:bold;">Connection is valid!</span>
				<!--- Delete Bucket --->
				<cfinvoke component="s3" method="deleteBucket" bucketName="#tempid#" />
			<cfelse>
				<br>
				<span style="color:red;font-weight:bold;">We could not validate your credentials!</span>
			</cfif>
			</cfoutput>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: VALIDATE BUCKET --->
	<cffunction name="validatebucket" returntype="string" access="public" output="true">
		<cfargument name="awsbucket" type="string" required="true" />
		<cftry>
			<!--- Check to see if we can list the buckets --->
			<cfset mydir = AmazonS3list(application.razuna.s3ds,"#arguments.awsbucket#")>
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
		<!--- Upload asset --->
		<cfset AmazonS3write(
			datasource="#application.razuna.s3ds#",
			bucket="#arguments.awsbucket#",
			key="#arguments.key#",
			file="#arguments.theasset#"
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
			datasource="#application.razuna.s3ds#",
			bucket="#arguments.awsbucket#",
			key="#arguments.key#",
			file="#arguments.theasset#"
		)>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: SIGNED URL --->
	<cffunction name="signedurl" access="public" output="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="minutesValid" type="string" required="false" default="5259600">
		
		<cfset var x = structnew()>
		<!--- Add 10 years to the current time and convert to epoch time: 31556926 is a year in seconds --->
		<!--- <cfset x.newepoch = ceiling(getTickCount() / 1000) + 315569260> --->
		<cfset x.newepoch = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + (arguments.minutesValid * 60)>
		<!--- Wait --->
		<cfinvoke component="s3" method="getobject" bucketName="#arguments.awsbucket#" filekey="#arguments.key#" minutesValid="#arguments.minutesValid#" returnVariable="x.theurl" />

		<!---

		<!--- Get signed URL with a expiration date in 10 years --->
		<cfset x.theurl = AmazonS3geturl(application.razuna.s3ds,arguments.awsbucket, arguments.key, x.newepoch )>
		<!--- Wait --->
		<cfpause interval="10" />
		<!--- Now test the url --->
		<cfhttp url="#x.theurl#" />
		<!--- Do we have a valid URL --->
		<cfif cfhttp.statuscode DOES NOT CONTAIN "200">
			<cfpause interval="10" />
			<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="amazon url">				
				Amazon url is not valid, we are trying it again
			</cfmail>
			<cfset x.theurl = "">
			<cfset x.theurl = AmazonS3geturl(application.razuna.s3ds,arguments.awsbucket, arguments.key, x.newepoch )>		
			<cfpause interval="10" />
			<!--- Now test the url --->
			<cfhttp url="#x.theurl#" />
			<!--- Do we have a valid URL --->
			<cfif cfhttp.statuscode DOES NOT CONTAIN "200">
				<cfpause interval="10" />
				<cfmail type="html" to="support@razuna.com" from="server@razuna.com" subject="amazon url 2">				
					Amazon url is still not valid, we are trying it again for the second time
				</cfmail>
				<cfset x.theurl = "">
				<cfset x.theurl = AmazonS3geturl(application.razuna.s3ds,arguments.awsbucket, arguments.key, x.newepoch )>
			</cfif>
		 </cfif>
--->
		<!--- Return --->
		<cfreturn x />
	</cffunction>
	
	<!--- FUNCTION: List Keys --->
	<cffunction name="listkeys" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<!--- Get keys --->
		<cfinvoke component="s3" method="getbucket" bucketName="#arguments.awsbucket#" prefix="#arguments.folderpath#" returnVariable="thekeys" />
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
		<cfloop array="#thekeys#" index="i">
			<cfset AmazonS3delete(application.razuna.s3ds,arguments.awsbucket,i.key)>
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
	
</cfcomponent>