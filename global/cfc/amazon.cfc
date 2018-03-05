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
		<cfargument name="thestruct" type="struct" required="yes" />
		<cftry>
			<!--- Check to see if we can list the buckets --->
			<cfset mydir = AmazonS3list(arguments.thestruct.razuna.application.s3ds,"#lcase(arguments.awsbucket)#")>
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
		<cfargument name="contentType" type="string" required="no" default="">
		<cfargument name="awskey" type="string" required="no" default="#arguments.thestruct.razuna.application.awskey#">
		<cfargument name="awssecretKey" type="string" required="no" default="#arguments.thestruct.razuna.application.awskeysecret#">
		<cfargument name="awslocation" type="string" required="no" default="#arguments.thestruct.razuna.application.awslocation#">
		<cfargument name="thestruct" type="struct" required="yes" />
		<!--- <cfset consoleoutput(true, true)>
		<cfset console(arguments)> --->
		<cfset var minsize = 5200000> <!--- min file size in bytes after which multipart upload is initiated. Must be >5.120 mb which is AWS minimum chunk size for multipart upload --->
		<cfset var theassetsize = 0>
		<cftry>
			<!--- Detect content type if not specified--->
			<cfif arguments.contenttype EQ "">
				<!--- Try finding content type by looking at mime types defined at server --->
				<cfset arguments.contenttype = getPageContext().getServletContext().getMimeType("#arguments.theasset#")>
				<!--- If contenttype still empty then try looking it up in file_types tables --->
				<cfif arguments.contenttype EQ "">
					<cfset var getcontenttype = "">
					<cfset var fileext = listlast(arguments.key,'.')>
					<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="getcontenttype">
						SELECT type_mimecontent, type_mimesubcontent FROM file_types WHERE type_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#fileext#">
					</cfquery>
					<cfif getcontenttype.recordcount EQ 1 AND getcontenttype.type_mimecontent NEQ "" AND getcontenttype.type_mimesubcontent NEQ "">
						<cfset arguments.contenttype = "#getcontenttype.type_mimecontent#/#getcontenttype.type_mimesubcontent#">
					</cfif>
				</cfif>
			</cfif>
			<cfinvoke component="global.cfc.global" method="getfilesize" filepath="#arguments.theasset#" thestruct="#arguments.thestruct#" returnvariable="theassetsize">

			<!--- If we store all files in one bucket --->
			<cfset arguments = tenantCheck(arguments)>

			<!--- Cache it for one year --->
			<cfset var _cacheControl = 31557600>

			<!--- If file size > 5.2 mb use multipart upload --->
			<cfif theassetsize LT minsize>
				<cfset var singleobj = createObject("component","global.cfc.s3").init(accessKeyId=arguments.awskey,secretAccessKey=arguments.awssecretkey,storagelocation = arguments.awslocation)>
				<cfset singleobj.putobject(bucketname='#arguments.awsbucket#', filekey='#arguments.key#', theasset='#arguments.theasset#', contenttype="#arguments.contenttype#", HTTPtimeout=_cacheControl, cacheControl=_cacheControl)>
			<cfelse>
				<cfset var multiobj = createObject("component","global.cfc.s3").init(accessKeyId=arguments.awskey,secretAccessKey=arguments.awssecretkey,storagelocation = arguments.awslocation)>
				<cfset multiobj.putobjectmultipart(bucketname='#arguments.awsbucket#', filekey='#arguments.key#', theasset='#arguments.theasset#', theassetsize='#int(theassetsize/1000)#', contenttype='#arguments.contenttype#', HTTPtimeout=_cacheControl, cacheControl=_cacheControl, thestruct=arguments.thestruct)>
			</cfif>
			<cfcatch>
				<cfset consoleoutput(true, true)>
				<cfset console(cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- FUNCTION: Download --->
	<cffunction name="download" access="public" output="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="theasset" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="thestruct" type="struct" required="yes" />
		<!--- If we store all files in one bucket --->
		<cfset arguments = tenantCheck(arguments)>
		<!--- Download asset --->
		<cfset AmazonS3read(
			datasource=arguments.thestruct.razuna.application.s3ds,
			bucket=arguments.awsbucket,
			key=arguments.key,
			file=arguments.theasset
		)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- FUNCTION: Rename --->
	<cffunction name="renameObject" access="public" output="true">
		<cfargument name="oldBucketName" type="string" required="true" />
		<cfargument name="newBucketName" type="string" required="true" />
		<cfargument name="oldFileKey" type="string" required="true" />
		<cfargument name="newFileKey" type="string" required="true" />
		<cfargument name="thestruct" type="struct" required="yes" />
		<!--- If we store all files in one bucket --->
		<cfset arguments = tenantCheck(arguments)>
		<!--- Create object --->
		<cfset var renobj = createObject("component","global.cfc.s3").init(accessKeyId=arguments.thestruct.razuna.application.awskey,secretAccessKey=arguments.thestruct.razuna.application.awskeysecret,storagelocation = arguments.thestruct.razuna.application.awslocation)>
		<!--- Rename --->
		<cfset renobj.renameObject(oldBucketName='#arguments.oldBucketName#', newBucketName ="#arguments.newBucketName#", oldFileKey = "#arguments.oldFileKey#",  newFileKey = "#arguments.newFileKey#")>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- FUNCTION: SIGNED URL --->
	<!--- Need to change this to accept full URLS now --->
	<!--- S3 URL schema should be: https://nitai.s3.amazonaws.com/2.jpg --->
	<!--- nitai = bucket --->
	<!--- All S3 region URL are like: s3.us-east-2.amazonaws.com --->
	<cffunction name="signedurl" access="public" output="true">
		<cfargument name="key" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="minutesValid" type="string" required="false" default="5259600">
		<cfargument name="thestruct" type="struct" required="yes" />
		<!--- <cfset var aws = AmazonRegisterDataSource("up",arguments.thestruct.razuna.application.awskey,arguments.thestruct.razuna.application.awskeysecret,arguments.thestruct.razuna.application.awslocation)> --->
		<cfset var x = structnew()>
		<!--- Add 10 years to expiration --->
		<!--- <cfset var epoch = dateadd("yyyy", 10, now())> --->
		<!--- Epoch seconds (convert local time to UTC) --->
		<cfset x.newepoch = 0>
		<!--- If we store all files in one bucket --->
		<cfset arguments = tenantCheck(arguments)>
		<!--- Create the signed URL --->
		<!--- <cfset x.theurl = AmazonS3geturl(datasource=arguments.thestruct.razuna.application.s3ds, bucket=arguments.awsbucket, key=arguments.key, expiration=epoch)> --->

		<!--- According to region we but URL together --->
		<cfset x.theurl = _getAwsUrl(awsbucket=arguments.awsbucket, key=arguments.key, thestruct=arguments.thestruct)>

		<!--- Return --->
		<cfreturn x />
	</cffunction>

	<!--- FUNCTION: List Keys --->
	<cffunction name="listkeys" access="public" output="false">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="thestruct" type="struct" required="yes" />
		<!--- Lenght of key and remove first / --->
		<cfset var _folderpath = arguments.folderpath>
		<cfset var f = left(_folderpath, 1)>
		<cfif f EQ "/">
			<cfset _folderpath_len = len(_folderpath)>
			<cfset _folderpath_len = _folderpath_len - 1>
			<cfset _folderpath = mid(_folderpath, 2, _folderpath_len)>
		</cfif>
		<!--- Add / at the end --->
		<cfset _folderpath = _folderpath & "/">
		<!--- Get keys --->
		<cfset var thekeys = AmazonS3list(
			datasource=arguments.thestruct.razuna.application.s3ds,
			bucket=arguments.awsbucket,
			prefix=_folderpath
		)>
		<!--- Return --->
		<cfreturn thekeys />
	</cffunction>

	<!--- FUNCTION: List all files --->
	<cffunction name="listFiles" access="public" output="false">
		<cfargument name="host_id" type="numeric" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="tenant_enable" type="string" required="true" />
		<cfargument name="tenant_bucket" type="string" required="true" />
		<cfargument name="config" type="query" required="true" />
		<cfargument name="from_cron" type="string" required="true" default="false" />
		<cfargument name="one" type="string" required="false" default="false" />
		<cfargument name="aws_prefix" type="string" required="false" default="" />
		<cfargument name="s3ds" type="string" required="false" default="" />
		<cfargument name="keys" type="array" required="false" />
		<cfargument name="thestruct" type="struct" required="yes" />

		<!--- If we store all files in one bucket --->
		<cfif arguments.one>
			<cfset arguments = tenantCheck(arguments)>
			<cfset arguments.s3ds = getDataSource( from_cron=arguments.from_cron, conf_aws_access_key=arguments.config.conf_aws_access_key, conf_aws_secret_access_key=arguments.config.conf_aws_secret_access_key, conf_aws_location=arguments.config.conf_aws_location, thestruct=arguments.thestruct )>
			<!--- New array --->
			<cfset arguments.keys = ArrayNew()>
		</cfif>

		<cfset arguments.aws_prefix = arguments.one ? arguments.aws_prefix & "/" : arguments.aws_prefix>

		<!--- Get keys --->
		<cfset thekeys = AmazonS3list( datasource=arguments.s3ds, bucket=arguments.awsbucket, prefix=arguments.aws_prefix )>
		<!--- <cfset consoleoutput(true, true)> --->

		<cfloop query="thekeys">
			<!--- If size is 0 --->
			<cfif size EQ 0>
				<!--- Call this function again to get next key --->
				<cfset arguments.keys = listFiles( host_id=arguments.host_id, awsbucket=arguments.awsbucket, tenant_enable=arguments.tenant_enable, tenant_bucket=arguments.tenant_bucket, config=arguments.config, from_cron=arguments.from_cron, one="false", aws_prefix=key, s3ds=arguments.s3ds, keys=arguments.keys )>
			<cfelse>
				<!--- Append to array --->
				<cfset ArrayAppend( arguments.keys, key )>
				<!--- <cfset console(key)> --->
			</cfif>
		</cfloop>

		<!--- <cfset console(arguments.keys)> --->


		<!--- Return --->
		<cfreturn arguments.keys />
	</cffunction>

	<!--- FUNCTION: Delete folder --->
	<cffunction name="deletefolder" access="public" output="true">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="tenant_enable" type="string" required="false" />
		<cfargument name="tenant_bucket" type="string" required="false" />
		<cfargument name="config" type="query" required="false" />
		<cfargument name="from_cron" type="string" required="false" default="false" />
		<cfargument name="thestruct" type="struct" required="yes" />

		<!--- If config does not exits --->
		<cfif !structKeyExists(arguments, "config")>
			<cfquery datasource="razuna_default" name="arguments.config">
			SELECT conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location
			FROM razuna_config
			</cfquery>
		</cfif>

		<cfset var _s3ds = getDataSource( from_cron=arguments.from_cron, conf_aws_access_key=arguments.config.conf_aws_access_key, conf_aws_secret_access_key=arguments.config.conf_aws_secret_access_key, conf_aws_location=arguments.config.conf_aws_location, thestruct=arguments.thestruct )>

		<!--- <cfif _from_cron>
			<cfset var _s3ds = AmazonRegisterDataSource("aws","#arguments.config.conf_aws_access_key#","#arguments.config.conf_aws_secret_access_key#","#arguments.config.conf_aws_location#")>
		<cfelse>
			<cfset var _s3ds = arguments.thestruct.razuna.application.s3ds>
		</cfif> --->

		<!--- If we store all files in one bucket --->
		<cfset arguments = tenantCheck(arguments)>

		<!--- <cfset consoleoutput(true, true)>
		<cfset console(arguments)> --->

		<!--- Lenght of key and remove first / --->
		<cfset _len_folder = len(arguments.folderpath)>
		<cfset _len_folder = _len_folder - 1>
		<cfset _folderpath_noprefix = right(arguments.folderpath, _len_folder) & "/">

		<!--- <cfset console(_folderpath_noprefix)> --->

		<!--- Get keys --->
		<cfset var _keys = AmazonS3list( datasource=_s3ds, bucket=arguments.awsbucket, prefix=_folderpath_noprefix )>

		<!--- <cfset console(_keys)> --->

		<cfloop query="_keys">
			<cfset AmazonS3delete( datasource=_s3ds, bucket=arguments.awsbucket, key=key )>
		</cfloop>

		<cfset AmazonS3delete( datasource=_s3ds, bucket=arguments.awsbucket, key=arguments.folderpath )>


		<!--- <cfset var singleobj = createObject("component","global.cfc.s3").init(accessKeyId=arguments.thestruct.razuna.application.awskey,secretAccessKey=arguments.thestruct.razuna.application.awskeysecret,storagelocation =arguments.thestruct.razuna.application.awslocation)>
		<cfset var thekeys= singleobj.getbucket(arguments.awsbucket,arguments.folderpath)>
		<cfset console('thekeys: #thekeys#')> --->

		<!--- Loop over the keys and delete them --->
		<!--- <cfloop array = "#thekeys#" index='struct'>
			<cfset AmazonS3delete(arguments.thestruct.razuna.application.s3ds,arguments.awsbucket,struct["key"])>
		</cfloop>

		<!--- Finally remove folder which is empty now --->
		<cfset AmazonS3delete(arguments.thestruct.razuna.application.s3ds,arguments.awsbucket,arguments.folderpath)> --->
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- FUNCTION: Move folder --->
	<cffunction name="movefolder" access="public" output="true">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="folderpathdest" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="thestruct" type="struct" required="yes" />
		<cfargument name="awskey" type="string" required="no" default="#arguments.thestruct.razuna.application.awskey#">
		<cfargument name="awssecretKey" type="string" required="no" default="#arguments.thestruct.razuna.application.awskeysecret#">
		<cfargument name="awslocation" type="string" required="no" default="#arguments.thestruct.razuna.application.awslocation#">
		<!--- If we store all files in one bucket --->
		<cfset arguments = tenantCheck(arguments)>
		<!--- Get keys --->
		<cfset thekeys = listkeys(arguments.folderpath,arguments.awsbucket)>
		<!--- Call the renameobject function which will copy and delete at the same time --->
		<cfloop query="thekeys" >
			<cfset thefile = listlast(key,"/")>
			<cfset var moveobj = createObject("component","global.cfc.s3").init(accessKeyId=arguments.awskey,secretAccessKey=arguments.awssecretkey,storagelocation = arguments.awslocation)>
			<cfset moveobj.renameObject(oldBucketName='#arguments.awsbucket#', newBucketName ="#arguments.awsbucket#", oldFileKey = "#key#",  newFileKey = "#arguments.folderpathdest#/#thefile#")>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- FUNCTION: Copy folder --->
	<cffunction name="copyfolder" access="public" output="true">
		<cfargument name="folderpath" type="string" required="true" />
		<cfargument name="folderpathdest" type="string" required="true" />
		<cfargument name="awsbucket" type="string" required="true" />
		<cfargument name="thestruct" type="struct" required="yes" />
		<cfargument name="awskey" type="string" required="no" default="#arguments.thestruct.razuna.application.awskey#">
		<cfargument name="awssecretKey" type="string" required="no" default="#arguments.thestruct.razuna.application.awskeysecret#">
		<cfargument name="awslocation" type="string" required="no" default="#arguments.thestruct.razuna.application.awslocation#">
		<!--- If we store all files in one bucket --->
		<cfset arguments = tenantCheck(arguments)>
		<!--- Get keys --->
		<cfset thekeys = listkeys(arguments.folderpath,arguments.awsbucket)>
		<!--- Call the copyobject function --->
		<cfloop query="thekeys" >
			<cfset thefile = listlast(key,"/")>
			<cfset var copyobj = createObject("component","global.cfc.s3").init(accessKeyId=arguments.awskey,secretAccessKey=arguments.awssecretkey,storagelocation = arguments.awslocation)>
			<cfset copyobj.copyObject(oldBucketName='#arguments.awsbucket#', newBucketName ="#arguments.awsbucket#", oldFileKey = "#key#",  newFileKey = "#arguments.folderpathdest#/#thefile#")>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Retrieves file and folder metadata --->
	<cffunction name="metadata_and_thumbnails" access="public" >
		<cfargument name="path" required="false" default="">
		<cfargument name="sf_id" required="true">
		<cfargument name="root" required="false" default="false">
		<cfargument name="thestruct" type="struct" required="yes" />
			<!--- Param --->
		<cfset var result = structNew()>
		<!--- Check that we have a Amazon Datasource --->
		<cfset var ar = awssourcecheck(arguments.sf_id, arguments.root)>
		<!--- Only continue if we are true --->
		<cfif ar>
			<!--- If path is only a / --->
			<cfif arguments.path EQ "/">
				<cfset arguments.path = "">
			</cfif>
			<!--- Get keys --->
			<cftry>
				<cfset result.contents = AmazonS3list(
					datasource=arguments.thestruct.razuna.session.aws[arguments.sf_id].datasource,
					bucket=arguments.thestruct.razuna.session.aws[arguments.sf_id].bucket,
					prefix=arguments.path
				)>
				<cfcatch>
					<cfoutput>
						Oops, there is an error accessing this bucket. Amazon reports the following:
						<p>#cfcatch.message#</p>
					</cfoutput>
				</cfcatch>
			</cftry>
			<!--- set path --->
			<cfset result.path = arguments.path>
		</cfif>
		<!--- Return --->
		<cfreturn result />
	</cffunction>

	<!--- Check RegisterDatasource --->
	<cffunction name="awssourcecheck" access="private" returntype="String">
		<cfargument name="sf_id" required="true">
		<cfargument name="root" required="false" default="false">
		<cfargument name="thestruct" type="struct" required="yes" />

		<!--- Param --->
		<cfset var exists = false>
		<cfset var qry = "">
		<cfset var qry_aws_settings = "">

		<!--- Check if a session with this smartfolder id exists --->
		<cfif !structKeyExists(arguments.thestruct.razuna.session,"aws") OR !structKeyExists(arguments.thestruct.razuna.session.aws,arguments.sf_id) OR arguments.root>
			<cftry>
				<!--- Query --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
				SELECT sf_prop_value
				FROM #arguments.thestruct.razuna.session.hostdbprefix#smart_folders_prop
				WHERE sf_prop_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="bucket">
				AND sf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sf_id#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				</cfquery>
				<!--- Get ID from bucket variable --->
				<cfset var awsid = listLast(qry.sf_prop_value,"_")>
				<!--- Get the AWS information with the selected bucket --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry_aws_settings">
				SELECT set_id, set_pref
				FROM #arguments.thestruct.razuna.session.hostdbprefix#settings
				WHERE set_id LIKE 'aws_%_#awsid#'
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				</cfquery>
				<!--- Set the Amazon datasource --->
				<cfif qry_aws_settings.recordcount NEQ 0>
					<cfloop query="qry_aws_settings">
						<cfset aws[set_id] = set_pref>
					</cfloop>
					<!--- Set source --->
					<cfset arguments.thestruct.razuna.session.aws[arguments.sf_id].datasource = AmazonRegisterDataSource(arguments.sf_id,evaluate("aws.aws_access_key_id_#awsid#"),evaluate("aws.aws_secret_access_key_#awsid#"),evaluate("aws.aws_bucket_location_#awsid#"))>
					<!--- Set Bucket --->
					<cfset arguments.thestruct.razuna.session.aws[arguments.sf_id].bucket = evaluate("aws.aws_bucket_name_#awsid#")>
					<!--- Set var to true --->
					<cfset var exists = true>
				<cfelse>
					<cfthrow type="any" message="No credentials associated with this account" detail="Please enter a valid Amazon access key and token in the Razuna administration!" />
				</cfif>
				<!--- Error --->
				<cfcatch type="any">
					<cfoutput>An error has occured connecting to your Amazon S3 account<br />Message: #cfcatch.message# <br />Detail: #cfcatch.detail#</cfoutput>
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
				   datasource=arguments.thestruct.razuna.session.aws[arguments.thestruct.razuna.session.sf_id].datasource,
				   bucket=arguments.thestruct.razuna.session.aws[arguments.thestruct.razuna.session.sf_id].bucket,
				   key=f,
				   file="#td#amazon/#listlast(f,"/")#"
				)>
				<!--- Set the filename. We need this is the asset function for the server add --->
				<cfset arguments.thestruct.thefile = listlast(f,"/")>
				<!--- Call internal function to add the file --->
				<cfinvoke component="assets" method="addassetserver" thestruct="#arguments.thestruct#" />
				<cfcatch type="any">
					<cfset consoleoutput(true, true)>
					<cfset console(cfcatch)>
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
		<cfargument name="thestruct" type="struct" required="yes" />
		<!--- Add 10 years to expiration --->
		<cfset var epoch = dateadd("n", 10, now())>
		<!--- Epoch seconds (convert local time to UTC) --->
		<cfset var newepoch = dateDiff("s", "January 1 1970 00:00", dateConvert("Local2utc", epoch))>
		<!--- Create the signed URL --->
		<cfset var theurl = AmazonS3geturl(
		   datasource=arguments.thestruct.razuna.session.aws[arguments.thestruct.razuna.session.sf_id].datasource,
		   bucket=arguments.thestruct.razuna.session.aws[arguments.thestruct.razuna.session.sf_id].bucket,
		   key=arguments.path,
		   expiration=epoch
		)>
		<!--- Redirect --->
		<cflocation url="#theurl#" />
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Function to create key and bucket --->
	<cffunction name="tenantCheck" access="public" returntype="struct">
		<cfargument name="thestruct" required="true" type="struct">

		<cfset consoleoutput(false)>

		<cfset var _from_cron = false>

		<!--- Check from_cron --->
		<cfif structkeyexists(arguments.thestruct, "from_cron")>
			<cfset var _from_cron = arguments.thestruct.from_cron>
		</cfif>

		<!--- <cfset console(arguments.thestruct)>
		<cfset console(_from_cron)> --->
		<!--- If application scope exists --->
		<cfif ! _from_cron>
			<cfset arguments.thestruct.tenant_enable = arguments.thestruct.thestruct.razuna.application.awstenaneonebucket>
			<cfset arguments.thestruct.tenant_bucket = arguments.thestruct.thestruct.razuna.application.awstenaneonebucketname>
			<cfset arguments.thestruct.host_id = arguments.thestruct.thestruct.razuna.session.hostid>
		</cfif>
		<!--- <cfset console(arguments.thestruct)> --->
		<!--- If one bucket for all tenants --->
		<cfif arguments.thestruct.tenant_enable>
			<!--- For listing return host_id --->
			<cfset arguments.thestruct.aws_prefix = arguments.thestruct.host_id>
			<!--- Overwrite the bucket --->
			<cfset arguments.thestruct.awsbucket = arguments.thestruct.tenant_bucket>
			<!--- Check if key start with / --->
			<cfif structKeyExists(arguments.thestruct, "key")>
				<cfset var _start = Left( arguments.thestruct.key, 1 )>
				<cfset var _add_to_key = _start EQ "/" ? '/' & arguments.thestruct.host_id : '/' & arguments.thestruct.host_id & '/'>
				<!--- Tag on host_id to key --->
				<cfset arguments.thestruct.key = _add_to_key & arguments.thestruct.key>
				<!--- <cfset console(#arguments.thestruct.key#)> --->
			</cfif>
			<!--- Check if folderpath start with / --->
			<cfif structKeyExists(arguments.thestruct, "folderpath")>
				<cfset var _start = Left( arguments.thestruct.folderpath, 1 )>
				<cfset var _add_to_key = _start EQ "/" ? '/' & arguments.thestruct.host_id : '/' & arguments.thestruct.host_id & '/'>
				<!--- Tag on host_id to key --->
				<cfset arguments.thestruct.folderpath = _add_to_key & arguments.thestruct.folderpath>
				<!--- <cfset console(#arguments.thestruct.folderpath#)> --->
			</cfif>
			<!--- Check if folderpathdest start with / --->
			<cfif structKeyExists(arguments.thestruct, "folderpathdest")>
				<cfset var _start = Left( arguments.thestruct.folderpathdest, 1 )>
				<cfset var _add_to_key = _start EQ "/" ? '/' & arguments.thestruct.host_id : '/' & arguments.thestruct.host_id & '/'>
				<!--- Tag on host_id to key --->
				<cfset arguments.thestruct.folderpathdest = _add_to_key & arguments.thestruct.folderpathdest>
				<!--- <cfset console(#arguments.thestruct.folderpathdest#)> --->
			</cfif>
			<!--- Check if oldFileKey start with / --->
			<cfif structKeyExists(arguments.thestruct, "oldFileKey")>
				<cfset var _start = Left( arguments.thestruct.oldFileKey, 1 )>
				<cfset var _add_to_key = _start EQ "/" ? '/' & arguments.thestruct.host_id : '/' & arguments.thestruct.host_id & '/'>
				<!--- Tag on host_id to key --->
				<cfset arguments.thestruct.oldFileKey = _add_to_key & arguments.thestruct.oldFileKey>
				<!--- <cfset console(#arguments.thestruct.oldFileKey#)> --->
			</cfif>
			<!--- Check if newFileKey start with / --->
			<cfif structKeyExists(arguments.thestruct, "newFileKey")>
				<cfset var _start = Left( arguments.thestruct.newFileKey, 1 )>
				<cfset var _add_to_key = _start EQ "/" ? '/' & arguments.thestruct.host_id : '/' & arguments.thestruct.host_id & '/'>
				<!--- Tag on host_id to key --->
				<cfset arguments.thestruct.newFileKey = _add_to_key & arguments.thestruct.newFileKey>
				<!--- <cfset console(#arguments.thestruct.newFileKey#)> --->
			</cfif>
			<!--- <cfset console(#arguments.thestruct.awsbucket#)> --->
		</cfif>
		<!--- Return --->
		<cfreturn arguments.thestruct />
	</cffunction>

	<!--- Function to create key and bucket --->
	<cffunction name="getDataSource" access="public">
		<cfargument name="from_cron" required="true" type="string">
		<cfargument name="conf_aws_access_key" required="true" type="string">
		<cfargument name="conf_aws_secret_access_key" required="true" type="string">
		<cfargument name="conf_aws_location" required="true" type="string">
		<cfargument name="thestruct" type="struct" required="yes" />

		<cfset var _from_cron = false>

		<!--- Check from_cron --->
		<cfif structkeyexists(arguments, "from_cron")>
			<cfset var _from_cron = arguments.from_cron>
		</cfif>

		<cfif _from_cron>
			<cfset var _s3ds = AmazonRegisterDataSource("aws","#arguments.conf_aws_access_key#","#arguments.conf_aws_secret_access_key#","#arguments.conf_aws_location#")>
		<cfelse>
			<cfset var _s3ds = arguments.thestruct.razuna.application.s3ds>
		</cfif>

		<cfreturn _s3ds />
	</cffunction>

	<!--- Function to create key and bucket --->
	<cffunction name="_getAwsUrl" access="public">
		<cfargument name="awsbucket" required="true" type="string">
		<cfargument name="key" required="true" type="string">
		<cfargument name="thestruct" type="Struct">
		<!--- Var --->
		<cfset var _url = "">
		<!--- Get Region --->
		<cfswitch expression="#arguments.thestruct.razuna.application.awslocation#">
			<cfcase value="us-east">
				<cfset _url = "https://s3.amazonaws.com">
			</cfcase>
			<cfcase value="us-east-2">
				<cfset _url = "https://s3.us-east-2.amazonaws.com">
			</cfcase>
			<cfcase value="us-west-1">
				<cfset _url = "https://s3.us-west-1.amazonaws.com">
			</cfcase>
			<cfcase value="us-west-2">
				<cfset _url = "https://s3.us-west-2.amazonaws.com">
			</cfcase>
			<cfcase value="ca-central-1">
				<cfset _url = "https://s3.ca-central-1.amazonaws.com">
			</cfcase>
			<cfcase value="ap-south-1">
				<cfset _url = "https://s3.ap-south-1.amazonaws.com">
			</cfcase>
			<cfcase value="ap-northeast-1">
				<cfset _url = "https://s3.ap-northeast-1.amazonaws.com">
			</cfcase>
			<cfcase value="ap-northeast-2">
				<cfset _url = "https://s3.ap-northeast-2.amazonaws.com">
			</cfcase>
			<cfcase value="ap-northeast-3">
				<cfset _url = "https://s3.ap-northeast-3.amazonaws.com">
			</cfcase>
			<cfcase value="ap-southeast-1">
				<cfset _url = "https://s3.ap-southeast-1.amazonaws.com">
			</cfcase>
			<cfcase value="ap-southeast-2">
				<cfset _url = "https://s3.ap-southeast-2.amazonaws.com">
			</cfcase>
			<cfcase value="cn-north-1">
				<cfset _url = "https://s3.cn-north-1.amazonaws.com">
			</cfcase>
			<cfcase value="cn-northwest-1">
				<cfset _url = "https://s3.cn-northwest-1.amazonaws.com">
			</cfcase>
			<cfcase value="eu-central-1">
				<cfset _url = "https://s3.eu-central-1.amazonaws.com">
			</cfcase>
			<cfcase value="eu-west-1">
				<cfset _url = "https://s3.eu-west-1.amazonaws.com">
			</cfcase>
			<cfcase value="eu-west-2">
				<cfset _url = "https://s3.eu-west-2.amazonaws.com">
			</cfcase>
			<cfcase value="eu-west-3">
				<cfset _url = "https://s3.eu-west-3.amazonaws.com">
			</cfcase>
			<cfcase value="sa-east-1">
				<cfset _url = "https://s3.sa-east-1.amazonaws.com">
			</cfcase>
		</cfswitch>
		<!--- Tag on bucket and ket --->
		<cfset _url = _url & "/" & arguments.awsbucket & "/" & arguments.key>
		<!--- Return --->
		<cfreturn _url />
	</cffunction>

</cfcomponent>




































































