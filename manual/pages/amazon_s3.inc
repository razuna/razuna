<cfsilent>
	<cfset request.page.title = "Amazon S3 with OpenBD">
	<cfset request.page.section = "adv">
	<cfset request.page.desc	= "Accessing and integrating Amazon S3 service into OpenBD is very easy">
</cfsilent>

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/amazon_s3"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">
	
	<h1>Amazon S3 Integration</h1>

	<cfinclude template="pages/sidebar_advanced.inc" />
	
	<div class="section">

<p>
<a href="http://www.amazon.com/SimpleDB-AWS-Service-Pricing/b/ref=sc_fe_l_2?ie=UTF8&amp;node=342335011&amp;no=3435361&amp;me=A36L942TSJ2AJA"><img class="right" src="http://g-ecx.images-amazon.com/images/G/01/00/10/00/14/19/27/100014192753._V46777512_.gif"></a>
Amazon provides one of the best cloud storage systems on the planet, through their <a href="http://aws.amazon.com/s3">popular S3 account</a>.
S3 is an unlimited cloud based file storage system that lets you upload and download files securely, while also allowing public access
to files via HTTP and BitTorrent.
</p>

<p>
You can easily read and write files on the Amazon S3 system from within CFML using the existing <a href="./?/function/category/file">FileXXX()</a> functions, or alternatively
you can use the optimized direct access functions listed at the bottom of this page.
</p>

<p>
When you sign-up for Amazon Web Services, you are given two pieces of information that lets you interact with all the web services Amazon provide.
This is the <strong>AmazonID</strong> and the <strong>AmazonSecretKey</strong>.
</p>

<p>
When working with Amazon S3 within OpenBD, there are two ways you can address your files on S3.  You can specify the accesskey and secretkey in
the full URL of the S3 object, or you can register an Amazon datasource and use that symbolic name.
</p>

<p>
The format of an S3 URL is:
</p>

<blockquote>
s3://&lt;amazonkey@secretkey&gt;/&lt;s3 bucket&gt;/&lt;file path uri&gt;
<br/>s3://&lt;@amazondatasource&gt;/&lt;s3 bucket&gt;/&lt;file path uri&gt;
</blockquote>

<p>
To register an Amazon datasource you simply make a call to the function <a href="./?/function/amazonregisterdatasource">AmazonRegisterDataSource()</a>.  You only
need to register an Amazon datasource once for the duration of the life time of the server.   If you do wish to remove a previously
registered Amazon datasource, then use <a href="./?/function/amazonremovedatasource">AmazonRemoveDataSource()</a>
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset AmazonRegisterDataSource( "myamz", "--amazonkey--", "--amazonsecretkey ----" )>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<h2>Uploading a file to Amazon S3</h2>

<p>
Uploading a file to Amazon S3 is the same as if you were copying it from one location to another, but this time you use the S3 URL as the destination.
</p>

<cfsavecontent variable="cfml"><nocfml><cfscript>
AmazonRegisterDataSource( "amz", "--amazonkey--", "--amazonsecretkey ----" );

imgFile = FileReadBinary("e:\\tmp\\args.jpg");
FileWrite( "s3://@amz/mybucket/dir1/args.jpg", imgFile );
</cfscript></nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>Alternatively, you may wish to use <a href="./?/function/amazons3write">AmazonS3Write</a> as an alternative for send files, as this is a more efficient mechanism
particularly for files that are very large.</p>


<p>Using <a href="./?/function/amazons3write">AmazonS3Write</a> you get the ability to add in custom meta-data and specify the storage class for the object.  Amazon
offers a cheaper alternative to its storage mechanism on S3 if you feel your object doesn't need the full redundancy S3 has to offer.</p>


<cfsavecontent variable="cfml"><nocfml><cfscript>
AmazonRegisterDataSource( "amz", "--amazonkey--", "--amazonsecretkey--" );

metadata = {
  userid : 42,
  homedir : "my/data/"
  };

// Standard
AmazonS3Write( "amz", "mybucket", "/dir1/args.jpg", metadata );

// Reduced cost
AmazonS3Write( "amz", "mybucket", "/dir1/args.jpg", metadata, "REDUCED_REDUNDANCY" );
</cfscript></nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>You can retrieve your metadata back from a given object using <a href="./?/function/amazons3getinfo">AmazonS3GetInfo</a></p>


<h3>Uploading a file to Amazon S3 in the background</h3>

<p>
In addition, with <a href="./?/function/amazons3write">AmazonS3Write</a> it will manage the retries of sending the file to Amazon, but also, allow you to background the operations by quickly returning and then once uploaded (or failed after the number of retries) call a CFC with the details.
</p>

<p>
The following example, will upload the file, 'lageFileToUpload.txt' in the background, attempting up to 3 times, with 10 seconds between each retry.  If it succeeds to upload, then the file will be deleted from the file system.  If it doesn't succeed, the file will still exist on the file system.   The CFC, 'callbackcfc.cfc' will be loaded and the method 'onAmazonS3Write()' will be called.  The CFC stub can be seen below.
</p>

<cfsavecontent variable="cfml"><nocfml><cfscript>
AmazonRegisterDataSource( "amz", "--amazonkey--", "--amazonsecretkey--" );

AmazonS3Write( 	
				datasource="amz", 
				bucket="mybucket", 
				file="/tmp/largeFileToUpload.txt", 
				key="/largeFileToUpload.txt",
				background=true,
				retry=3,
				retrywaitseconds=10,
				deletefile=true,
				callback="callbackcfc",
				callbackdata="ExtraDataToPassToCallbackCFC"
				);
</cfscript></nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>The CFC callback stub looks like:</p>
<cfsavecontent variable="cfml"><nocfml><cfcomponent>

	<cffunction name="onAmazonS3Write">
		<cfargument name="file" type="string">
		<cfargument name="success" type="boolean">
		<cfargument name="callbackdata" type="string">
		<cfargument name="error" type="string">
		
		<!--- do something --->
	</cffunction>
	
</cfcomponent></nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>
A new instance of the CFC will be created for each callback, with the application scope being available for the same application that originated the AmazonS3Write() function call.
</p>


<h2>Downloading a file from Amazon S3</h2>

<p>
Downloading a file from Amazon S3 is just the same as if you were copying it, you just switch the parameters around.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset AmazonRegisterDataSource( "amz", "--amazonkey--", "--amazonsecretkey ----" )>

<cfset imgFile = FileReadBinary("s3://@amz/mybucket/dir1/args.jpg")>
<cfset FileWrite( "e:\\tmp\\args.jpg", imgFile )>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>


<p>Alternatively, you may wish to use <a href="./?/function/amazons3read">AmazonS3Read</a> as an alternative for receiving files, as this is a more efficient mechanism
particularly for files that are very large.</p>


<h2>Eucalyptus Walrus Operations</h2>

<p><a href="http://open.eucalyptus.com/">Eucalyptus</a> is an open source cloud platform, supporting amongest other things, a full Amazon S3 clone.</p>

<p>OpenBD can operate with a Eucalyptus installation by specifying the local endpoint when creating your Amazon data source.  After that, all the AmazonS3
functions operate as normal.</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset AmazonRegisterDataSource( "mywalrus", "--walruskey--", "--walrusecretkey ----", "---walrus server--" )></nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>For more information on setting up your own Amazon S3 installation see <a href="http://open.eucalyptus.com/wiki/EucalyptusStorage_v1.4">Eucalyptus Storage</a>.</p>


<h2>Amazon S3 Specific functions</h2>

<p>There are functions that let you operate with all of the services provided by Amazon S3.</p>

<table align="center" cellpadding="5" cellspacing="0" width="90%">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3delete">AmazonS3Delete</a></td>
		<td>Deletes the remote file</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3geturl">AmazonS3GetUrl</a></td>
		<td>Returns back a signed URL that gives people public access to a given file, with an optional expiration date</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3getinfo">AmazonS3GetInfo</a></td>
		<td>Returns back a structure detailing all the headers from a given remote object</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3list">AmazonS3List</a></td>
		<td>Returns all the keys for this bucket</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3listbuckets">AmazonS3ListBuckets</a></td>
		<td>Returns all the buckets for this account</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3read">AmazonS3Read</a></td>
		<td>Copies the remote file from Amazon S3 to the local file system</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3rename">AmazonS3Rename</a></td>
		<td>Rename the remote file</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3setacl">AmazonS3SetAcl</a></td>
		<td>Sets the ACL on the given object</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazons3write">AmazonS3Write</a></td>
		<td>Copies the local file upto Amazon S3</td>
	</tr>
</tbody>
</table>

<h2>Operational notes on Amazon S3</h2>

<p>
Working with Amazon S3 is fairly straight forward, but there are some operational constraints you must be aware of.
</p>

<ul>
	<li>S3 has no real concept of directories.  It stores files against a single key.  Therefore operations that operate on a Directory do not work, except for <a href="./?/function/directorylist">DirectoryList()</a></li>
	<li class="padtop">Using <a href="./?/function/amazons3list">AmazonS3List()</a> any key returned that has a slash (/) at the end, this is considered a common prefix, or sub-directory</li>
	<li class="padtop">Maximum size of a given file is 5GB</li>
	<li class="padtop">By default, files uploaded to S3 are marked private and not be publicly accessible. Use <a href="./?/function/amazons3setacl">AmazonS3SetAcl()</a></li>
	<li class="padtop">Buckets are limited to 100 per account; Create them using your <a href="http://aws.amazon.com/console/">Amazon AWS console</a></li>
	<li class="padtop">S3 access is not available using CFFILE and CFDIRECTORY</li>
	<li class="padtop">You can easily work with multiple Amazon S3, as well as Eucalyptus Walrus accounts with OpenBD</li>
	<li class="padtop">Working with objects, you do not need to start your prefix with "/".  This will only tell Amazon that you want // as a key marker</li>
</ul>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->