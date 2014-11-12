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
				<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><LocationConstraint>#arguments.storageLocation#</LocationConstraint></CreateBucketConfiguration>
			</cfoutput></cfsavecontent>
		<cfelse>
			<cfset strXML = "">
		</cfif>
		
		<!--- put the bucket via REST --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName#" charset="utf-8">
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

	<cfscript>
		public string function generateMd5Hash( required string body ) {

		var bytes = binaryDecode( hash( body ), "hex" );

		return( binaryEncode( bytes, "base64") );

	}
	</cfscript>

	<cffunction name="putObject" access="public" output="true" returntype="boolean" description="Puts an object into a bucket using the multipart upload api.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="theasset" type="string" required="yes">
		<cfargument name="contentType" type="string" required="no" default="">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		<cfargument name="cacheControl" type="numeric" required="false" default="86400">
		<cfargument name="acl" type="string" required="no" default="public-read">
		<cfargument name="storageClass" type="string" required="no" default="STANDARD">

		<!---
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		
		<!--- If content type not defined then find content type --->
		<cfif arguments.contenttype EQ "">
			<cfset arguments.contenttype = getPageContext().getServletContext().getMimeType("#arguments.theasset#")>
		</cfif>
		
		<cfset var binaryFileData = "">
		<!--- Create a canonical string to send --->
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:#arguments.acl#\nx-amz-storage-class:#arguments.storageClass#\n/#arguments.bucketName##arguments.fileKey#">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)> 
		<!--- Read the image data into a variable --->
		<cffile action="readbinary" file="#arguments.theasset#" variable="binaryFileData">
		<!--- <cfset var md5hash = hashbinary("#arguments.theasset#")> --->
		<!--- Send the file to amazon. The "X-amz-acl" controls the access properties of the file --->
		<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName##arguments.fileKey#" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<!--- <cfhttpparam type="header" name="Content-Disposition" value=" inline; filename='photo.jpg' "> --->
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="x-amz-storage-class" value="#arguments.storageClass#">
			<cfhttpparam type="header" name="Cache-Control" value="max-age=#arguments.cacheControl#">
			<!--- <cfhttpparam type="header" name="Content-MD5" value="#md5hash#"> --->
			<!--- <cfhttpparam type="header" name="Content-Encoding" value="base64"> --->
			<!--- <cfhttpparam type="body" value="#tostring(binaryFileData)#"> --->
			<cfhttpparam type="body" value="#binaryFileData#">
		</cfhttp> 
 --->

		<cfset AmazonS3write(
			datasource=application.razuna.s3ds,
			bucket=arguments.bucketName,
			key=arguments.fileKey,
			file=arguments.theasset
		)>

		<!--- Rename object so we can set cachecontrol it --->
		<!--- <cfset renameObject(arguments.bucketName,arguments.fileKey,arguments.bucketName,arguments.fileKey,'50000')> --->

		<!--- <cftry>
			<cfset versionID = cfhttp.responseHeader['x-amz-request-id']>

			<cfcatch></cfcatch>
		</cftry>
		 --->
		<cfreturn true>
	</cffunction>

	<cffunction name="putObjectMultipart" access="public" output="true" returntype="boolean" description="Puts an object into a bucket using the multipart upload api.">
		<cfargument name="bucketName" type="string" required="yes">
		<cfargument name="fileKey" type="string" required="yes">
		<cfargument name="theasset" type="string" required="yes">
		<cfargument name="theassetsize" type="string" required="yes" hint="in kb">
		<cfargument name="contentType" type="string" required="no" default="">
		<cfargument name="HTTPtimeout" type="numeric" required="no" default="300">
		<cfargument name="cacheControl" type="boolean" required="false" default="86400">
		<cfargument name="acl" type="string" required="no" default="public-read">
		<cfargument name="storageClass" type="string" required="no" default="STANDARD">
		<cfset var versionID = "">
		<cfset var binaryFileData = "">
		<cfset var dateTimeString = GetHTTPTimeString(Now())>
		<cfset var filename = listlast(arguments.filekey,'\/')>
		<!--- If content type not defined then find content type --->
		<cfif arguments.contenttype EQ "">
			<cfset arguments.contenttype = getPageContext().getServletContext().getMimeType("#arguments.theasset#")>
		</cfif>
		<!--- <cfset var md5hash = hashbinary("#arguments.theasset#")> --->


		<!--- ************* Initiate multipart upload on AWS server and get the uploadid ******************* --->
		<!--- Create a canonical string to send --->
		<cfset var cs = "POST\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-acl:#arguments.acl#\nx-amz-storage-class:#arguments.storageClass#\n/#arguments.bucketName##arguments.fileKey#?uploads">
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<cfhttp method="POST" url="http://s3.amazonaws.com/#arguments.bucketName##arguments.fileKey#?uploads" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Cache-Control" value="max-age=#arguments.cacheControl#">
			<cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
			<cfhttpparam type="header" name="x-amz-storage-class" value="#arguments.storageClass#">
		</cfhttp> 

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
		<cfset var classpath = replace(replace("#expandpath('../../')#WEB-INF\lib","/","#fileseparator()#","ALL"),"\","#fileseparator()#","ALL")>
		<cfset arguments.theasset = replace(replace(arguments.theasset,"/","#fileseparator()#","ALL"),"\","#fileseparator()#","ALL")>
		<cfset var assetdir = replace(arguments.theasset,listlast(arguments.theasset, '\/'),'')>
		<cfset var chunksize = 10000> <!--- 10 mb chunk size by default --->
		<!--- If file > 500mb then use 100mb chunk sizes --->
		<cfif arguments.theassetsize GT 500000> 
			<cfset var chunksize = 100000> 
		<!--- If file > 5gb then use 500mb chunk sizes --->
		<cfelseif arguments.theassetsize GT 5000000> 
			<cfset var chunksize = 500000> 
		</cfif>
		<!--- Write script file --->
		<cffile action="write" file="#thescriptfile#" output="cd #classpath#" mode="777" addnewline="true">
		<cffile action="append" file="#thescriptfile#" output="java HJSplit -s#chunksize# #arguments.theasset# #assetdir#" mode="777" addnewline="true">
		<cfexecute name="#thescriptfile#" timeout="30" variable="result" errorVariable="errorvar"/>
		<cfif len(errorvar)>
			<cfthrow message="Error occurred while executing HJSplit: #errorvar#">
		</cfif>
		<!--- Delete script file --->
		<cffile action="delete" file="#thescriptfile#">

		<!--- ************* Get listing of the file parts  ******************* --->
		<cfset var dirqry ="">
		<cfdirectory action="list" directory="#assetdir#" name="dirqry">
		<cfquery name="dirqry" dbtype="query">
			SELECT name FROM dirqry WHERE name LIKE '%#filename#.%' ORDER BY name asc
		</cfquery>
		<cfset var partnum = 1>
		<cfset var etags= []> <!--- intialize etag array to hold eatgs of all the file parts after upload --->

		<!--- ************* Upload the file parts  ******************* --->		
		<cfloop query="dirqry">
			<!---
			<!--- Create a canonical string to send --->
			<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\n/#arguments.bucketName##arguments.fileKey#?partNumber=#partnum#&uploadId=#uploadID#">
			<!--- Create a proper signature --->
			<cfset var signature = createSignature(cs)>
			<cfset binaryFileData = filereadbinary("#assetdir#/#dirqry.name#")>

			 <cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.bucketName##arguments.fileKey#?partNumber=#partnum#&uploadId=#uploadID#" timeout="#arguments.HTTPtimeout#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
				<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
				<!--- <cfhttpparam type="header" name="Content-MD5" value="#md5hash#"> --->
				<cfhttpparam type="body" value="#tostring(binaryFileData)#" encoded="true" mimetype="#arguments.contentType#">
				
			</cfhttp> 
			<cfdump var="#cfhttp#">
			<cfset var etag =replace(cfhttp.responseheader.etag,'"','','ALL')> 
			<cfset etag = xmlSearch(cfhttp.filecontent, "string( //*[ local-name() = 'ETag' ] )" )>
			Partnum = #partnum#; contenttype = #arguments.contenttype#, etag = #etag#; md5hash = #md5hash#<br/><cfflush/> 
			<cfset arrayAppend( etags, etag )>--->

			
			<!--- <cfthread name="addasset_#partnum#" action="run" partnum = '#partnum#' uploadid= '#uploadid#'> 
			<cfset AmazonS3write(
				datasource=datasource,
				bucket=arguments.bucketName,
				key='#arguments.fileKey#?partNumber=#attributes.partnum#&uploadId=#attributes.uploadID#',
				file='#assetdir#/#dirqry.name#'
			)>
			</cfthread> 
			<cfthread action="join" name="addasset_#tmp#" />
			 --->
			<cfset AmazonS3write(
				datasource=application.razuna.s3ds,
				bucket=arguments.bucketName,
				key='#arguments.fileKey#?partNumber=#partnum#&uploadId=#uploadID#',
				file='#assetdir#/#dirqry.name#'
			)>
			<cfset partnum = partnum + 1>
			<cffile action="delete" file="#assetdir#/#dirqry.name#">
		</cfloop>

		<!--- ************* Get list of parts uploaded and their etag values from AWS server ******************* --->
		<!--- Get current datetime as it may have changed significantly after uploads and AWS will report time skew error if too far out from AWS server time --->
		<cfset dateTimeString = GetHTTPTimeString(Now())>
		<cfset var cs = "GET\n\n\n#dateTimeString#\n/#arguments.bucketName##arguments.fileKey#?uploadId=#uploadID#">
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		 <cfhttp method="GET" url="http://s3.amazonaws.com/#arguments.bucketName##arguments.fileKey#?uploadId=#uploadID#" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
		</cfhttp> 
		<!--- <cfdump var='#cfhttp#'> --->
		<cfset var response = xmlparse(cfhttp.filecontent)>
		<!--- <cfdump var="#response#"> --->
		<cfset var etagarr = response.ListPartsResult.Part>
		<!--- <cfdump var="#etagarr#"> --->
		<cfif isarray(etagarr)>
			<cfloop array="#etagarr#" index="i">
				<cfset arrayAppend( etags, replace(i.etag.xmltext,'"','','ALL') )>
			</cfloop>
		<cfelse>
			<cfset arrayAppend( etags, replace(etagarr.etag.xmltext,'"','','ALL') )>
		</cfif>
		<!--- Make up XML to complete the multipart upload --->
		<cfset xml = [ "<CompleteMultipartUpload>" ]>
		<cfloop from="1" to="#dirqry.recordcount#" index="i">
			<cfset arrayAppend(xml,
					"<Part>" &
						"<PartNumber>#( i )#</PartNumber>" &
						"<ETag>#etags[ i ]#</ETag>" &
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

		<cfhttp method="POST" url="http://s3.amazonaws.com/#arguments.bucketName##arguments.fileKey#?uploadId=#uploadID#" timeout="#arguments.HTTPtimeout#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="body" value="#body#">
		</cfhttp> 
		<!--- <cfdump var="#cfhttp#"> --->
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
		<cfset timedAmazonLink = "http://s3.amazonaws.com/#arguments.bucketName#/#arguments.fileKey#?AWSAccessKeyId=#URLEncodedFormat(variables.accessKeyId)#&Expires=#epochTime#&Signature=#URLEncodedFormat(signature)#">

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
		<cfhttp method="DELETE" url="http://s3.amazonaws.com/#arguments.bucketName##arguments.fileKey#">
			<cfhttpparam type="header" name="Date" value="#dateTimeString#">
			<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
		</cfhttp>

		<cfreturn true>
	</cffunction>


	<cffunction name="copyObject" access="public" output="false" returntype="boolean" description="Copies an object.">
		<cfargument name="oldBucketName" type="string" required="yes">
		<cfargument name="oldFileKey" type="string" required="yes">
		<cfargument name="newBucketName" type="string" required="yes">
		<cfargument name="newFileKey" type="string" required="yes">
		<cfargument name="cachecontrol" type="string" required="no" default="86400">
		<cfargument name="acl" type="string" required="no" default="public-read">
		<cfargument name="storageClass" type="string" required="no" default="STANDARD">

		<cfset var dateTimeString = GetHTTPTimeString(Now())>

		<!--- Create a canonical string to send based on operation requested ---> 
		<!--- <cfset var cs = "PUT\n\n\n#dateTimeString#\nx-amz-copy-source:/#arguments.oldBucketName##arguments.oldFileKey#\n/#arguments.newBucketName##arguments.newFileKey#"> --->
		
		<cfset arguments.contenttype='application/xml'>

		<cfset arguments.newFileKey = replace(arguments.newFileKey,'picture','hey')>
		<cfset var cs = "PUT\n\n#arguments.contentType#\n#dateTimeString#\nx-amz-copy-source:/#arguments.oldBucketName##arguments.oldFileKey#\n/#arguments.newbucketName##arguments.newfileKey#">
		
		<!--- <cfset var cs = "PUT\n\napplication/octet-stream\n#dateTimeString#\nx-amz-copy-source:/#arguments.oldBucketName#/#arguments.oldFileKey#\n/#arguments.newBucketName#/#arguments.newFileKey#"> --->
		
		<!--- Create a proper signature --->
		<cfset var signature = createSignature(cs)>
		
		<!--- <cfif compare(arguments.oldBucketName,arguments.newBucketName) or compare(arguments.oldFileKey,arguments.newFileKey)> --->
		
			<!--- delete the object via REST --->
			<cfhttp method="PUT" url="http://s3.amazonaws.com/#arguments.newBucketName##arguments.newFileKey#">
				<cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#">
				<cfhttpparam type="header" name="Date" value="#dateTimeString#">
				<!--- <cfhttpparam type="header" name="x-amz-acl" value="#arguments.acl#">
				<cfhttpparam type="header" name="x-amz-storage-class" value="#arguments.storageClass#"> --->
				<!--- <cfhttpparam type="header" name="x-amz-metadata-directive" value="REPLACE"> --->
				<cfhttpparam type="header" name="Cache-Control" value="public, max-age=#arguments.cacheControl#">
				<cfhttpparam type="header" name="x-amz-copy-source" value="/#arguments.oldBucketName##arguments.oldFileKey#">
				<cfhttpparam type="header" name="Authorization" value="AWS #variables.accessKeyId#:#signature#">
			</cfhttp>
			<!--- <cfset console(cfhttp.filecontent)> --->
			
		<!--- 	<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif> --->
		<cfreturn true>
	</cffunction>

	<cffunction name="renameObject" access="public" output="false" returntype="boolean" description="Renames an object by copying then deleting original.">
		<cfargument name="oldBucketName" type="string" required="yes">
		<cfargument name="oldFileKey" type="string" required="yes">
		<cfargument name="newBucketName" type="string" required="yes">
		<cfargument name="newFileKey" type="string" required="yes">
		<cfargument name="cachecontrol" type="string" required="no" default="86400">
		<!--- <cfif compare(arguments.oldBucketName,arguments.newBucketName) or compare(arguments.oldFileKey,arguments.newFileKey)> --->
			<cfset copyObject(arguments.oldBucketName,arguments.oldFileKey,arguments.newBucketName,arguments.newFileKey,arguments.cachecontrol)>
			<cfset deleteObject(arguments.oldBucketName,arguments.oldFileKey)>
			<cfreturn true>
		<!--- <cfelse>
			<cfreturn false>
		</cfif> --->
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