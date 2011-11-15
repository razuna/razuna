<cfcomponent name="s3" displayname="Amazon S3 REST Wrapper v1.8">

<!---
Amazon S3 REST Wrapper

Written by Joe Danziger (joe@ajaxcf.com) with much help from
dorioo on the Amazon S3 Forums.  See the readme for more
details on usage and methods.
Thanks to Steve Hicks for the bucket ACL updates.
Thanks to Carlos Gallupa for the EU storage location updates.
Thanks to Joel Greutman for the fix on the getObject link.
Thanks to Jerad Sloan for the Cache Control headers.

Version 1.8 - Released: July 27, 2010
--->

<!---
	<cfset variables.accessKeyId = "">
	<cfset variables.secretAccessKey = "">
--->

	
	<cfset variables.accessKeyId = application.razuna.awskey>
	<cfset variables.secretAccessKey = application.razuna.awskeysecret>


	<cffunction name="init" access="public" returnType="s3" output="false"
				hint="Returns an instance of the CFC initialized.">
		<cfargument name="accessKeyId" type="string" required="true" hint="Amazon S3 Access Key ID.">
		<cfargument name="secretAccessKey" type="string" required="true" hint="Amazon S3 Secret Access Key.">
		
		<cfset variables.accessKeyId = arguments.accessKeyId>
		<cfset variables.secretAccessKey = arguments.secretAccessKey>
	
		<cfreturn this>
	</cffunction>
	
	<cffunction name="HMAC_SHA1" returntype="binary" access="private" output="false" hint="NSA SHA-1 Algorithm">
	   <cfargument name="signKey" type="string" required="true" />
	   <cfargument name="signMessage" type="string" required="true" />
	
	   <cfset var jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
	   <cfset var jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />
	   <cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
	   <cfset var mac = createObject("java","javax.crypto.Mac") />
	
	   <cfset key = key.init(jKey,"HmacSHA1") />
	   <cfset mac = mac.getInstance(key.getAlgorithm()) />
	   <cfset mac.init(key) />
	   <cfset mac.update(jMsg) />
	
	   <cfreturn mac.doFinal() />
	</cffunction>

	<cffunction name="createSignature" returntype="string" access="public" output="false">
	   <cfargument name="stringIn" type="string" required="true" />
		
		<!--- Replace "\n" with "chr(10) to get a correct digest --->
		<cfset var fixedData = replace(arguments.stringIn,"\n","#chr(10)#","all")>
		<!--- Calculate the hash of the information --->
		<cfset var digest = HMAC_SHA1(variables.secretAccessKey,fixedData)>
		<!--- fix the returned data to be a proper signature --->
		<cfset var signature = ToBase64("#digest#")>
		
		<cfreturn signature>
	</cffunction>

	<cffunction name="getBuckets" access="public" output="false" returntype="array" 
				description="List all available buckets.">
		
		<cfset var data = "">
		<cfset var bucket = "">
		<cfset var buckets = "">
		<cfset var thisBucket = "">
		<cfset var allBuckets = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#dateTimeString#\n/">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- get all buckets via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent)>
		<cfset buckets = xmlSearch(data, "//:Bucket")>

		<!--- create array and insert values from XML --->
		<cfset allBuckets = arrayNew(1)>
		<cfloop index="x" from="1" to="#arrayLen(buckets)#">
		   <cfset bucket = buckets[x]>
		   <cfset thisBucket = structNew()>
		   <cfset thisBucket.Name = bucket.Name.xmlText>
		   <cfset thisBucket.CreationDate = bucket.CreationDate.xmlText>
		   <cfset arrayAppend(allBuckets, thisBucket)>   
		</cfloop>
		
		<cfreturn allBuckets>		
	</cffunction>
	
	<cffunction name="putBucket" access="public" output="false" returntype="boolean" 
				description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="true">
		<cfargument name="acl" type="string" required="false" default="public-read">
		<cfargument name="storageLocation" type="string" required="false" default="">
		
		<cfset var strXML = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\ntext/html\n#dateTimeString#\nx-amz-acl:#arguments.acl#\n/#arguments.bucketName#">

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<cfif compare(arguments.storageLocation,'')>
			<cfsavecontent variable="strXML">
				<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><LocationConstraint>#arguments.storageLocation#</LocationConstraint></CreateBucketConfiguration>
			</cfsavecontent>
		<cfelse>
			<cfset strXML = "">
		</cfif>

		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Content-Type" value="text/html">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="body" value="#trim(strXML)#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getBucket" access="public" output="false" returntype="array" 
				description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="prefix" type="string" required="false" default="">
		<cfargument name="marker" type="string" required="false" default="">
		<cfargument name="maxKeys" type="string" required="false" default="">
		<cfargument name="showVersions" type="boolean" required="false" default="false">
		
		<cfset var cs = "">
		<cfset var data = "">
		<cfset var content = "">
		<cfset var contents = "">
		<cfset var version = "">
		<cfset var versions = "">
		<cfset var signature = "">
		<cfset var versioning = "">
		<cfset var prefixString = "">
		<cfset var markerString = "">
		<cfset var maxKeysString = "">
		<cfset var thisContent = "">
		<cfset var allContents = "">
		<cfset var thisVersion = "">
		<cfset var allVersions = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- add proper versioning call if requested --->
		<cfif arguments.showVersions>
			<cfset versioning = "?versions">
		</cfif>

		<!--- Create a canonical string to send --->
		<cfset cs = "GET\n\n\n#dateTimeString#\n/#arguments.bucketName##versioning#">
		
		<!--- Create a proper signature --->
		<cfset signature = createSignature(cs)>

		<!--- get the bucket via REST --->
		<cfif arguments.showVersions>
			<cfif compare(arguments.prefix,'')>
				<cfset prefixString = "&prefix=#arguments.prefix#">
			</cfif>
			<cfif compare(arguments.marker,'')>
				<cfset markerString = "&marker=#arguments.marker#">
			</cfif>
			<cfif isNumeric(arguments.maxKeys)>
				<cfset maxKeysString = "&max-keys=#arguments.maxKeys#">
			</cfif>
			<cfhttp method="GET" url="http://s3.amazonaws.com/#arguments.bucketName#?versions#prefixString##markerString##maxKeysString#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			</cfhttp>		
		<cfelse>
			<cfhttp method="GET" url="http://s3.amazonaws.com/#arguments.bucketName#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
				<cfif compare(arguments.prefix,'')>
					<cfhttpparam type="URL" name="prefix" value="#arguments.prefix#"> 
				</cfif>
				<cfif compare(arguments.marker,'')>
					<cfhttpparam type="URL" name="marker" value="#arguments.marker#"> 
				</cfif>
				<cfif isNumeric(arguments.maxKeys)>
					<cfhttpparam type="URL" name="max-keys" value="#arguments.maxKeys#"> 
				</cfif>
			</cfhttp>
		</cfif>
		
		<cfset data = xmlParse(cfhttp.FileContent)>

		<cfif arguments.showVersions>
			<cfset versions = xmlSearch(data, "//:Version")>
	
			<!--- create array and insert values from XML --->
			<cfset allVersions = arrayNew(1)>
			<cfloop index="x" from="1" to="#arrayLen(versions)#">
				<cfset version = versions[x]>
				<cfset thisVersion = structNew()>
				<cfset thisVersion.Key = version.Key.xmlText>
				<cfset thisVersion.VersionID = version.VersionID.xmlText>
				<cfset thisVersion.isLatest = version.IsLatest.xmlText>
				<cfset thisVersion.LastModified = version.LastModified.xmlText>
				<cfset thisVersion.Size = version.Size.xmlText>
				<cfset thisVersion.StorageClass = version.StorageClass.xmlText>
				<cfset arrayAppend(allVersions, thisVersion)>   
			</cfloop>
			
			<cfreturn allVersions>	
		<cfelse>
			<cfset contents = xmlSearch(data, "//:Contents")>
	
			<!--- create array and insert values from XML --->
			<cfset allContents = arrayNew(1)>
			<cfloop index="x" from="1" to="#arrayLen(contents)#">
				<cfset content = contents[x]>
				<cfset thisContent = structNew()>
				<cfset thisContent.Key = content.Key.xmlText>
				<cfset thisContent.LastModified = content.LastModified.xmlText>
				<cfset thisContent.Size = content.Size.xmlText>
				<cfset thisContent.StorageClass = content.StorageClass.xmlText>
				<cfset arrayAppend(allContents, thisContent)>   
			</cfloop>
			
			<cfreturn allContents>
		</cfif>

	</cffunction>
	
	<cffunction name="deleteBucket" access="public" output="false" returntype="boolean" 
				description="Deletes a bucket.">
		<cfargument name="bucketName" type="string" required="yes">	
		
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#"> 
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- delete the bucket via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="putObject" access="public" output="false" returntype="string" 
				description="Puts an object into a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="contentType" type="string" required="yes">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		<cfargument name="cacheControl" type="boolean" required="false" default="true">
		<cfargument name="cacheDays" type="numeric" required="false" default="30">
		<cfargument name="acl" type="string" required="no" default="public-read">
		<cfargument name="storageClass" type="string" required="no" default="STANDARD">
		
		<cfset var versionID = "">
		<cfset var binaryFileData = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:#arguments.acl#\nx-amz-storage-class:#arguments.storageClass#\n/#arguments.bucketName#/#arguments.fileKey#">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- Read the image data into a variable --->
		<cffile action="readBinary" file="#ExpandPath("./#arguments.fileKey#")#" variable="binaryFileData">
		
		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="x-amz-storage-class" value="#arguments.storageClass#">
			<cfhttpparam type="body" value="#binaryFileData#">
			<cfif arguments.cacheControl>
				<cfhttpparam type="header" name="Cache-Control" value="max-age=2592000">
				<cfhttpparam type="header" name="Expires" value="#DateFormat(now()+arguments.cacheDays,'ddd, dd mmm yyyy')# #TimeFormat(now(),'H:MM:SS')# GMT">
			</cfif>
		</cfhttp> 		
		
		<cftry>
			<cfset versionID = cfhttp.responseHeader['x-amz-version-id']>
			<cfcatch></cfcatch>
		</cftry>
		
		<cfreturn versionID>
	</cffunction>

	<cffunction name="getObject" access="public" output="false" returntype="string" 
				description="Returns a link to an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="minutesValid" type="string" required="false" default="60">
		
		<cfset var timedAmazonLink = "">
		<cfset var epochTime = DateDiff("s", DateConvert("utc2Local", "January 1 1970 00:00"), now()) + (arguments.minutesValid * 60)>

		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#epochTime#\n/#arguments.bucketName#/#arguments.fileKey#">

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<!--- Create the timed link for the image --->
		<cfset timedAmazonLink = "http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#?AWSAccessKeyId=#URLEncodedFormat(variables.accessKeyId)#&Expires=#epochTime#&Signature=#URLEncodedFormat(signature)#">

		<cfreturn timedAmazonLink>
	</cffunction>

	<cffunction name="deleteObject" access="public" output="false" returntype="boolean" 
				description="Deletes an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">

		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#/#arguments.fileKey#"> 

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<!--- delete the object via REST --->
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>

		<cfreturn true>
	</cffunction>


	<cffunction name="copyObject" access="public" output="false" returntype="boolean" 
				description="Copies an object.">
		<cfargument name="oldBucketName" type="string" required="yes">
		<cfargument name="oldFileKey" type="string" required="yes">
		<cfargument name="newBucketName" type="string" required="yes">
		<cfargument name="newFileKey" type="string" required="yes">
	
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\n\n#dateTimeString#\nx-amz-copy-source:/#arguments.oldBucketName#/#arguments.oldFileKey#\n/#arguments.newBucketName#/#arguments.newFileKey#">
		
		<!--- <cfset var cs = "PUT\n\napplication/octet-stream\n#dateTimeString#\nx-amz-copy-source:/#arguments.oldBucketName#/#arguments.oldFileKey#\n/#arguments.newBucketName#/#arguments.newFileKey#"> --->
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>	
		
		<cfif compare(arguments.oldBucketName,arguments.newBucketName) or compare(arguments.oldFileKey,arguments.newFileKey)>
		
			<!--- delete the object via REST --->
			<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.newBucketName#/#arguments.newFileKey#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
				<cfhttpparam type="header" name="x-amz-copy-source" value="/#arguments.oldBucketName#/#arguments.oldFileKey#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			</cfhttp>
						
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="renameObject" access="public" output="false" returntype="boolean" 
				description="Renames an object by copying then deleting original.">
		<cfargument name="oldBucketName" type="string" required="yes">
		<cfargument name="oldFileKey" type="string" required="yes">
		<cfargument name="newBucketName" type="string" required="yes">
		<cfargument name="newFileKey" type="string" required="yes">
		
		<cfif compare(arguments.oldBucketName,arguments.newBucketName) or compare(arguments.oldFileKey,arguments.newFileKey)>
			<cfset copyObject(arguments.oldBucketName,arguments.oldFileKey,arguments.newBucketName,arguments.newFileKey)>
			<cfset deleteObject(arguments.oldBucketName,arguments.oldFileKey)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="getBucketVersioning" access="public" output="false" returntype="string" 
				description="Determines versioning setting for a bucket.">
		<cfargument name="bucketName" type="string" required="yes">
		
		<cfset var data = "">
		<cfset var result = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send --->
		<cfset var cs = "GET\n\n\n#dateTimeString#\n/#arguments.bucketName#?versioning">

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<!--- get the bucket via REST --->
		<cfhttp method="GET" url="http://s3.amazonaws.com/#arguments.bucketName#?versioning">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>
		
		<cfset data = xmlParse(cfhttp.FileContent)>
		<cftry>
			<cfset result = data.VersioningConfiguration.Status.xmlText>
			<cfcatch><cfset result = "Disabled"></cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="setBucketVersioning" access="public" output="false" returntype="boolean" 
				description="Sets versioning on a bucket.">
		<cfargument name="bucketName" type="string" required="true">
		<cfargument name="versioning" type="string" required="false" default="Enabled">
		
		<cfset var strXML = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\ntext/html\n#dateTimeString#\n/#arguments.bucketName#?versioning">

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<cfsavecontent variable="strXML">
			<VersioningConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Status><cfoutput>#arguments.versioning#</cfoutput></Status></VersioningConfiguration>
		</cfsavecontent>

		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#?versioning" charset="utf-8">
			<cfhttpparam type="header" name="Content-Type" value="text/html">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="body" value="#trim(strXML)#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
</cfcomponent>