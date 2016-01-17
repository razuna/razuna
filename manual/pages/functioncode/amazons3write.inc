<p>
The following example, will upload the file, 'lageFileToUpload.txt' in the background, attempting up to 3 times, with 10 seconds between each retry.  If it succeeds to upload, then the file will be deleted from the file system.  If it doesn't succeed, the file will still exist on the file system.   The CFC, 'callbackcfc.cfc' will be loaded and the method 'onAmazonS3Write()' will be called.  The CFC stub can be seen below.
</p>

<pre class="cfml"><cfscript>
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
</cfscript></pre>

<p>The CFC callback stub looks like:</p>
<pre class="cfml"><cfcomponent>

	<cffunction name="onAmazonS3Write">
		<cfargument name="file" type="string">
		<cfargument name="success" type="boolean">
		<cfargument name="callbackdata" type="string">
		<cfargument name="error" type="string">
		
		<!--- do something --->
	</cffunction>
	
</cfcomponent></pre>

<p>
A new instance of the CFC will be created for each callback, with the application scope being available for the same application that originated the AmazonS3Write() function call.
</p>

<p>
When you background an upload, the local file remains in its location, however a job file is written to the directory, 'amazons3uploader' in the OpenBD working directory (the place you find the 'bluedragon.log' file).   Background jobs remain in place over server restarts, as long as this directory is not deleted.  For every attempt, a log entry is made in the 'bluedragon.log' to track the progress.
</P>