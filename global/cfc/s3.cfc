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

Modified from original by Razuna to add suport for multipart uploads and getting aws URL based on regional endpoints
--->
	<cffunction name="init" access="public" returnType="s3" output="false" hint="Returns an instance of the CFC initialized.">
		<cfargument name="accessKeyId" type="string" required="true" hint="Amazon S3 Access Key ID.">
		<cfargument name="secretAccessKey" type="string" required="true" hint="Amazon S3 Secret Access Key.">
		<cfargument name="storagelocation" type="string" required="true" hint="Amazon S3 bucket location">
		<cfset variables.accessKeyId = arguments.accessKeyId>
		<cfset variables.secretAccessKey = arguments.secretAccessKey>
		<cfset variables.awsURL = getS3Host('#arguments.storagelocation#')>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getS3Host" returntype="String" hint="Gets regional endpoint based on where bucket is located to reduce latency. See http://docs.aws.amazon.com/general/latest/gr/rande.html">
		<cfargument name="amzregion" type="string" required="true">
		<cfset var awsURL = 'https://s3.amazonaws.com'>
		 <cfif arguments.amzRegion EQ "us-east">
	  		<cfset awsURL = "https://s3.amazonaws.com">
	  	<cfelseif arguments.amzRegion EQ "us-west-1">
	  		<cfset awsURL = "https://s3-us-west-1.amazonaws.com">
	  	<cfelseif arguments.amzRegion EQ "us-west-2">
	  		<cfset awsURL = "https://s3-us-west-2.amazonaws.com">
	  	<cfelseif arguments.amzRegion EQ "eu">
	  		<cfset awsURL ="https://s3-eu-west-1.amazonaws.com">
	  	<cfelseif arguments.amzRegion EQ "ap-southeast-1">
	  		<cfset awsURL ="https://s3-ap-southeast-1.amazonaws.com">
	  	<cfelseif arguments.amzRegion EQ "ap-southeast-2">
	  		<cfset awsURL = "https://s3-ap-southeast-2.amazonaws.com">
	  	<cfelseif arguments.amzRegion EQ "ap-northeast-1">
	  		<cfset awsURL = "https://s3-ap-northeast-1.amazonaws.com">
	  	<cfelseif arguments.amzRegion EQ "sa-east-1">
	  		<cfset awsURL = "https://s3-sa-east-1.amazonaws.com">
  		</cfif> 
  		<cfreturn awsURL>
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
		<cfhttp method="GET" url="#variables.awsURL#">
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
	
	<cffunction name="putBucket" access="public" output="false" returntype="struct" description="Creates a bucket.">
		<cfargument name="bucketName" type="string" required="true">
		<cfargument name="acl" type="string" required="false" default="public-read">
		<cfargument name="storageLocation" type="string" required="false" default="">
		<cfargument name="awskey" type="string" required="true">
		
		<cfset var strXML = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "PUT\n\ntext/html\n#dateTimeString#\nx-amz-acl:#arguments.acl#\n/#arguments.bucketName#">
		
		<cfif arguments.storageLocation EQ "us-east">
			<cfset arguments.storageLocation = "">
		</cfif>
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		<cfif arguments.storageLocation NEQ "">
			<cfsavecontent variable="strXML"><cfoutput>
				<CreateBucketConfiguration xmlns="#variables.awsURL#/doc/2006-03-01/"><LocationConstraint>#arguments.storageLocation#</LocationConstraint></CreateBucketConfiguration>
			</cfoutput></cfsavecontent>
		<cfelse>
			<cfset strXML = "">
		</cfif>
		
		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="#variables.awsURL#/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Content-Type" value="text/html">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="Authorization" value="AWS #arguments.awskey#:#signature#">
			<cfhttpparam type="body" value="#trim(strXML)#">
		</cfhttp>
		
		<cfreturn cfhttp>
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
			<cfhttp method="GET" url="#variables.awsURL#/#arguments.bucketName#?versions#prefixString##markerString##maxKeysString#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			</cfhttp>		
		<cfelse>
			<cfhttp method="GET" url="#variables.awsURL#/#arguments.bucketName#">
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
		<cfargument name="awskey" type="string" required="yes">	
		<cfargument name="endpoint" type="string" required="yes">	
		
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName#"> 
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- delete the bucket via REST --->
		<cfhttp method="DELETE" url="http://s3.amazon.com/#arguments.bucketName#" charset="utf-8">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #arguments.awskey#:#signature#">
		</cfhttp>

		<cfreturn true>
	</cffunction>

	<cffunction name="putObject" access="public" output="true" returntype="boolean" description="Puts an object into a bucket using the multipart upload api.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="theasset" type="string" required="yes">
		<cfargument name="contentType" type="string" required="no" default="">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="86400">
		<cfargument name="cacheControl" type="numeric" required="false" default="86400">
		<cfargument name="acl" type="string" required="no" default="public-read">
		<cfargument name="storageClass" type="string" required="no" default="STANDARD">

		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<!--- Encode filename --->
		<cfset arguments.fileKey = urlEncodedFormat(arguments.fileKey,'utf-8')>
		<!--- If content type not defined then find content type --->
		<cfif arguments.contenttype EQ "">
			<!--- Try finding content type by looking at mime types defined at server --->
			<cfset arguments.contenttype = getPageContext().getServletContext().getMimeType("#arguments.theasset#")>
		</cfif>
		<cfset var binaryFileData = "">	
		<!--- Read the data into a variable --->
		<cffile action="readbinary" file="#arguments.theasset#" variable="binaryFileData">
		<!--- Generate the MD5 hash for the Content-MD5 header. --->
		<cfset var md5hash = binaryEncode(binarydecode(hashbinary(binaryfiledata),"hex"), "base64")>
		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n#md5hash#\n#arguments.contenttype#\n#dateTimeString#\nx-amz-acl:#arguments.acl#\nx-amz-storage-class:#arguments.storageClass#\n/#arguments.bucketName##arguments.fileKey#">
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)> 
		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cfhttp method="PUT" url="#variables.awsURL#/#arguments.bucketName##arguments.fileKey#" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-MD5" value="#md5hash#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="x-amz-storage-class" value="#arguments.storageClass#">
			<cfhttpparam type="header" name="Cache-Control" value="max-age=#arguments.cacheControl#">
			<cfhttpparam type="body" value="#tostring(binaryFileData,'iso-8859-1')#">
		</cfhttp> 
		<!--- If response is not a 2xx HTTP code (success) --->
		<cfif isdefined("cfhttp.responseheader.status_code") AND !reFind( "^2\d\d", cfhttp.responseheader.status_code)>
			<cfthrow  message="AWS file #arguments.fileKey# was not uploaded successfully" detail = "Explanation: #cfhttp.responseheader.explanation#;  Status Code: #cfhttp.responseheader.status_code#; Filecontent: #xmlformat(xmlparse(cfhttp.filecontent))#">
		</cfif>
		<cfreturn true>
	</cffunction>

	<cffunction name="putObjectMultipart" access="public" output="true" returntype="boolean" description="Puts an object into a bucket using the multipart upload api.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="theasset" type="string" required="yes">
		<cfargument name="theassetsize" type="string" required="yes" hint="in kb">
		<cfargument name="contentType" type="string" required="no" default="">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="86400">
		<cfargument name="cacheControl" type="boolean" required="false" default="86400">
		<cfargument name="acl" type="string" required="no" default="public-read">
		<cfargument name="storageClass" type="string" required="no" default="STANDARD">
		<cfset var versionID = "">
		<cfset var binaryFileData = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<cfset var filename = listlast(arguments.filekey,'\/')>

		<!--- Encode filename --->
		<cfset arguments.fileKey = urlEncodedFormat(arguments.fileKey,'utf-8')>
		
		<!--- If content type not defined then find content type --->
		<cfif arguments.contenttype EQ "">
			<cfset arguments.contenttype = getPageContext().getServletContext().getMimeType("#arguments.theasset#")>
		</cfif>

		<!--- ************* Initiate multipart upload on AWS server and get the uploadid ******************* --->
		<!--- Create a canonical string to send --->
		<cfset var cs = "POST\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:#arguments.acl#\nx-amz-storage-class:#arguments.storageClass#\n/#arguments.bucketName##arguments.fileKey#?uploads">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		<cfhttp method="POST" url="#variables.awsURL#/#arguments.bucketName##arguments.fileKey#?uploads" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Cache-Control" value="max-age=#arguments.cacheControl#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="x-amz-storage-class" value="#arguments.storageClass#">
		</cfhttp> 
		<!--- If response is not a 2xx HTTP code (success) --->
		<cfif isdefined("cfhttp.responseheader.status_code") AND !reFind( "^2\d\d", cfhttp.responseheader.status_code)>
			<cfthrow  message="AWS file #arguments.fileKey# was not uploaded successfully" detail = "Explanation: #cfhttp.responseheader.explanation#;  Status Code: #cfhttp.responseheader.status_code#; Filecontent: #xmlformat(xmlparse(cfhttp.filecontent))#">
		</cfif>
		<cfset var uploadid =xmlparse(cfhttp.filecontent)>
		<cfset uploadid  = uploadid.InitiateMultipartUploadResult.UploadId.xmltext>
		
		<!--- ************* Split file to upload into parts using HJSplit   ******************* --->
		<cfif FindNoCase("Windows", server.os.name)>
			<cfset var theext = ".bat">
		<cfelse>
			<cfset var theext = ".sh">
		</cfif>
		<cfset var result = "">
		<cfset var errorvar = "">
		<cfset var thefilename = createuuid('')>
		<cfset var thescriptfile = gettempdirectory() & "#thefilename##theext#">
		<cfset arguments.theasset = replace(replace(arguments.theasset,"/","#fileseparator()#","ALL"),"\","#fileseparator()#","ALL")>
		<cfset var assetdir = replace(arguments.theasset,listlast(arguments.theasset, '\/'),'')>
		<!--- If last char is a slash then remove it else windows will complain when calling HJSplit --->
		<cfif right(assetdir,1) EQ '\' OR right(assetdir,1) EQ '/'>
			<cfset assetdir = mid(assetdir, 1, len(assetdir)-1)>
		</cfif>
		<cfset var chunksize = 5200> <!--- 5.2 mb chunk size by default, AWS requires chunk size to be 5120 kb at minimum --->
		<!--- If file > 100mb then use 10mb chunk sizes --->
		<cfif arguments.theassetsize GT 100000 AND arguments.theassetsize LTE 5000000> 
			<cfset var chunksize = 10000> 
		<!--- If file > 5gb then use 100mb chunk sizes --->
		<cfelseif arguments.theassetsize GT 5000000> 
			<cfset var chunksize = 100000> 
		</cfif>
		<!--- If chunks are more than 10,000 then increase chunksize as AWS does not accept more than 10,000 parts --->
		<cfif int(arguments.theassetsize /chunksize) GT 10000>
			<cfset chunksize =  int(arguments.theassetsize /10000)>
		</cfif>
		<!--- Write script file --->
		<cffile action="write" file="#thescriptfile#" output="cd #session.libpath#" mode="777" addnewline="true">
		<cffile action="append" file="#thescriptfile#" output='java HJSplit -s#chunksize# "#arguments.theasset#" "#assetdir#" ' mode="777" addnewline="true">
		<cfexecute name="#thescriptfile#" timeout="30" variable="result" errorVariable="errorvar"/>
		<cfif len(errorvar)>
			<cfthrow message="Error occurred while executing HJSplit: #errorvar#">
		</cfif>
		<!--- Delete script file --->
		<cffile action="delete" file="#thescriptfile#">

		<!--- ************* Get listing of the file parts  ******************* --->
		
		<!--- There seems to be a bug in cfdirectory with files containing . in their names as the filters don't work in those cases so we will use our own code instead --->
		<!--- <cfdirectory action="list" directory="#assetdir#" name="dirqry">
		<cfquery name="dirqry" dbtype="query">
			SELECT name FROM dirqry WHERE lower(name) LIKE '%#lcase(filename)#.%' ORDER BY name ASC
		</cfquery> --->
		<cfset fileList = createObject("java","java.io.File").init("#assetdir#").listFiles() />
		<cfset var dirqry  = queryNew("Name") />
		<cfloop from="1" to="#arrayLen(fileList)#" index="i">
			 <cfif refindnocase('#filename#.[0-9]{3,}',fileList[i].getName()) > <!--- Only accept filenames ending with .[0-9] notation which are the chunks --->
			 	 <cfset queryAddRow(dirqry) />
			  	<cfset querySetCell(dirqry, "Name", fileList[i].getName()) />
			</cfif>
		</cfloop>
		<!--- Sort by name --->
		<cfquery name="dirqry" dbtype="query">
			SELECT name FROM dirqry ORDER BY name ASC
		</cfquery> 
		<cfset var orig_dirqry = dirqry>
		<cfset var etags= []> <!--- intialize etag array to hold etags of all the file parts after upload --->
		<cfset var etag = "">
		<cfset var tmp = createUUID('')>
		<cfset var threadnamelist = "">
		<cfset var retries = 0>
		<!--- If all parts have not been uploaded then re-try upto 2 times --->
		<cfloop condition="dirqry.recordcount NEQ 0 AND retries LTE 2">
			<cfset retries = retries + 1>
			<!--- ************* Upload the file parts  ******************* --->
			<cfloop query="dirqry">
				<cfset dateTimeString = GetHTTPTimeString(Now())>
				<cfset var partnum = int(listlast(dirqry.name,'.'))>
				<cffile action="readbinary" file="#assetdir#/#dirqry.name#" variable="binaryFileData">
				<!--- Generate the MD5 hash for the Content-MD5 header. --->
				<cfset var md5hash = binaryEncode(binarydecode(hashbinary(binaryfiledata),"hex"), "base64")>
				<!--- Create a canonical string to send --->
				<cfset var cs = "PUT\n#md5hash#\n#arguments.contentType#\n#dateTimeString#\n/#arguments.bucketName##arguments.fileKey#?partNumber=#partnum#&uploadId=#uploadID#">
				<!--- Create a proper signature --->
				<cfset var signature = createSignature(cs)>
				<!--- Do not use throwonerror attribute as parts with upload errors will be re-tried for upload automatically --->
				 <cfhttp method="PUT" url="#variables.awsURL#/#arguments.bucketName##arguments.fileKey#?partNumber=#partnum#&uploadId=#uploadID#" timeout="#arguments.HTTPtimeout#">
					<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
					<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
					<cfhttpparam type="header" name="Date" value="#dateTimeString#">
					<cfhttpparam type="header" name="Content-MD5" value="#md5hash#">
					<cfhttpparam type="body" value="#tostring(binaryFileData,'iso-8859-1')#">
				</cfhttp>
				<!--- If response is not a 2xx HTTP code (success)  --->
				<cfif isdefined("cfhttp.statuscode") AND !reFind( "^2\d\d", cfhttp.statuscode)>
					<cflog application="no" file="AWS_Errors" type="Error" text="AWS part file #arguments.fileKey#?partNumber=#partnum# was not uploaded successfully, ErrorDetail: #cfhttp.errordetail#; FileContent: #cfhttp.filecontent#">
				<cfelse>
					<cfset etag = replace(cfhttp.responseheader.etag,'"','','ALL')>
					<cfset etags ['#partnum#'] = etag>
					<cffile action="delete" file="#assetdir#/#dirqry.name#">
				</cfif>
				<!--- Limit threads --->
				<cfif chunksize GTE 100000>
					<cfset createObject( "java", "java.lang.Runtime" ).getRuntime().gc()>
				</cfif>
			</cfloop>
			<!--- ************* Get listing of the file parts  ******************* --->
			<cfset fileList = createObject("java","java.io.File").init("#assetdir#").listFiles() />
			<cfset var dirqry  = queryNew("Name") />
			<cfloop from="1" to="#arrayLen(fileList)#" index="i">
				 <cfif refindnocase('#filename#.[0-9]{3,}',fileList[i].getName()) > <!--- Only accept filenames ending with .[0-9] notation which are the chunks --->
				 	 <cfset queryAddRow(dirqry) />
				  	<cfset querySetCell(dirqry, "Name", fileList[i].getName()) />
				</cfif>
			</cfloop>
			<!--- Sort by name --->
			<cfquery name="dirqry" dbtype="query">
				SELECT name FROM dirqry ORDER BY name ASC
			</cfquery> 
		</cfloop>
		<!--- If all parts could not be uploaded even after 2 re-tries then throw error --->
		<cfif dirqry.recordcount NEQ 0>
			<!--- Delete leftover files --->
			<cfloop query="dirqry">
				<cffile action="delete" file="#assetdir#/#dirqry.name#">
			</cfloop>
			<cfset dateTimeString = GetHTTPTimeString(Now())>
			<!--- Abort multipart upload --->
			<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName##arguments.fileKey#?uploadId=#uploadID#">
			<!--- Create a proper signature --->
			<cfset var signature = createSignature(cs)>
			 <cfhttp method="DELETE" url="#variables.awsURL#/#arguments.bucketName##arguments.fileKey#?uploadId=#uploadID#" timeout="#arguments.HTTPtimeout#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			</cfhttp>
			<cfthrow message="All AWS parts could not be successfully uploaded for file #filename#. Please see 'AWS_Errors log' in OpenBD admin for more details.">
		</cfif>

		<!--- UPLOAD PARTS IN PARALLEL: Runs into memory issues if parts are too big. Also AWS seems to be slow to respond to parallel requests so time advantage for smaller parts does not justify using parallel uploads
		 <cfset var start = GetTickCount()>
	 	<cfloop query="dirqry">
			<cfset threadnamelist =  listappend(threadnamelist,'multipart_#dirqry.currentrow#_#tmp#')>
			<cfthread name="multipart_#dirqry.currentrow#_#tmp#" action="run" assetdir='#assetdir#' arguments='#arguments#' variables='#variables#' currentrow='#dirqry.currentrow#' filename='#dirqry.name#' uploadid='#uploadid#' dateTimeString='#dateTimeString#'> 
				<cftry>
					<cffile action="readbinary" file="#attributes.assetdir#/#attributes.filename#" variable="binaryFileData">
					<!--- Generate the MD5 hash for the Content-MD5 header. --->
					<cfset var md5hash = binaryEncode(binarydecode(hashbinary(binaryfiledata),"hex"), "base64")>
					<!--- Create a canonical string to send --->
					<cfset var cs = "PUT\n#md5hash#\n#attributes.arguments.contentType#\n#attributes.dateTimeString#\n/#attributes.arguments.bucketName##attributes.arguments.fileKey#?partNumber=#attributes.currentrow#&uploadId=#attributes.uploadID#">
					<!--- Create a proper signature --->
					<!--- <cfset var signature = createSignature(cs)> --->
					<cfset var signobj = createObject("component","global.cfc.s3").init(accessKeyId=variables.accessKeyId,secretAccessKey=variables.secretAccessKey)>
					<cfset var signature = signobj.createSignature(cs)>
					<cfset console("Start thread #attributes.currentrow#")>
					<cfset var startthread = GetTickCount()>
					 <cfhttp method="PUT" url="#variables.awsURL#/#attributes.arguments.bucketName##attributes.arguments.fileKey#?partNumber=#attributes.currentrow#&uploadId=#attributes.uploadID#" timeout="#attributes.arguments.HTTPtimeout#">
						<cfhttpparam type="header" name="Authorization" value="AWS #attributes.variables.accessKeyId#:#signature#">
						<cfhttpparam type="header" name="Content-MD5" value="#md5hash#">
						<cfhttpparam type="header" name="Content-Type" value="#attributes.arguments.contentType#">
						<cfhttpparam type="header" name="Date" value="#attributes.dateTimeString#">
						<cfhttpparam type="body" value="#tostring(binaryFileData,'iso-8859-1')#">
					</cfhttp>
					<cfset var endthread = GetTickCount()>
					<cfset var threadtottime = ((endthread-startthread)/1000)/60>
					<cfset console("THREAD #attributes.currentrow# TIME")>
					<cfset console(threadtottime)>
					<cfset console("End thread #attributes.currentrow#")>
					<cfset console(cfhttp)>
					<cfset console("****************************************")>
					<!--- If response is not 'OK' then throw error --->
					<cfif isdefined("cfhttp.statuscode") AND cfhttp.statuscode DOES NOT CONTAIN '200'>
						<cfthrow message="AWS part file #attributes.arguments.fileKey#?partNumber=#attributes.currentrow# was not uploaded successfully" detail = "Status Code: #cfhttp.statuscode#; Filecontent: #cfhttp.filecontent#">
					</cfif>
					<cffile action="delete" file="#attributes.assetdir#/#attributes.filename#">
					<cfset createObject( "java", "java.lang.Runtime" ).getRuntime().gc()>
					<cfcatch><cfset console(cfcatch)></cfcatch>
				</cftry>
			</cfthread> 
		</cfloop> 
		<cfset var thethread=cfthread["multipart_1_#tmp#"]> 
		<!--- Output to page to prevent it from timing out while thread is running --->
		<cfloop condition="#thethread.status# EQ 'RUNNING' OR thethread.Status EQ 'NOT_STARTED' "> <!--- Wait till thread is finished --->
			<cfoutput> #thethread.status#</cfoutput>
			<cfset sleep(3000) > 
			<cfflush>
		</cfloop>
		<cfthread action="join" name="#threadnamelist#"/>
		<cfset var end = GetTickCount()>
		<cfset var tottime = ((end-start)/1000)/60>
		<cfset console("TIME")>
		<cfset console(tottime)> --->

		<!--- Make up XML to complete the multipart upload --->
		<cfset xml = [ "<CompleteMultipartUpload>" ]>
		<cfloop from="1" to="#orig_dirqry.recordcount#" index="i">
			<cfset arrayAppend(xml,
					"<Part>" &
						"<PartNumber>#i#</PartNumber>" &
						"<ETag>#etags[i]#</ETag>" &
					"</Part>")
			>
		</cfloop>
		<cfset arrayAppend( xml, "</CompleteMultipartUpload>" )>
		<cfset body = arrayToList( xml, chr( 10 ) )>
		<!--- ************* Sent request to complete multipart upload and combine all parts on AWS server ******************* --->
		<cfset arguments.contenttype = "text\xml">
		<!--- Create a canonical string to send --->
		<cfset var cs = "POST\n\n#arguments.contentType#\n#dateTimeString#\n/#arguments.bucketName##arguments.fileKey#?uploadId=#uploadID#">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		<cfhttp method="POST" url="#variables.awsURL#/#arguments.bucketName##arguments.fileKey#?uploadId=#uploadID#" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="body" value="#body#">
		</cfhttp> 
		<!--- If response is not a 2xx HTTP code (success) then throw error --->
		<cfif isdefined("cfhttp.responseheader.status_code") AND !reFind( "^2\d\d", cfhttp.responseheader.status_code)>
			<cfthrow  message="AWS file #arguments.fileKey# was not uploaded successfully" detail = "Explanation: #cfhttp.responseheader.explanation#;  Status Code: #cfhttp.responseheader.status_code#; Filecontent: #xmlformat(xmlparse(cfhttp.filecontent))#">
		</cfif>
		<cfreturn true>
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
		<cfset timedAmazonLink = "#variables.awsURL#/#arguments.bucketName#/#arguments.fileKey#?AWSAccessKeyId=#URLEncodedFormat(variables.accessKeyId)#&Expires=#epochTime#&Signature=#URLEncodedFormat(signature)#">

		<cfreturn timedAmazonLink>
	</cffunction>

	<cffunction name="deleteObject" access="public" output="false" returntype="boolean" 
				description="Deletes an object.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">

		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<cfset var cs = "DELETE\n\n\n#dateTimeString#\n/#arguments.bucketName##arguments.fileKey#"> 

		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>

		<!--- delete the object via REST --->
		<cfhttp method="DELETE" url="#variables.awsURL#/#arguments.bucketName##arguments.fileKey#">
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
			<cfhttp method="PUT" url="#variables.awsURL#/#arguments.newBucketName#/#arguments.newFileKey#">
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
		<cfhttp method="GET" url="#variables.awsURL#/#arguments.bucketName#?versioning">
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
			<VersioningConfiguration xmlns="#variables.awsURL#/doc/2006-03-01/"><Status><cfoutput>#arguments.versioning#</cfoutput></Status></VersioningConfiguration>
		</cfsavecontent>

		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="#variables.awsURL#/#arguments.bucketName#?versioning" charset="utf-8">
			<cfhttpparam type="header" name="Content-Type" value="text/html">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="body" value="#trim(strXML)#">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
	
</cfcomponent>