<cfset request.page.title = "Web Services Using SalesForce with OpenBD">
<cfset request.page.section = "adv">
<cfset request.page.desc	= "OpenBD can easily interact with one of the most popular enterprise webservices from SalesForce">

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/webservices_salesforce">Using SalesForce with OpenBD</a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">
	
		<h1>Web Services Using SalesForce with OpenBD</h1>
		
		<cfinclude template="pages/sidebar_advanced.inc" />
	
		<div class="section">

<p>
<a href="http://www.salesforce.com/">SalesForce</a> is one of the most popular online CRM and cloud based platforms for building highly connected applications.  One of its
great strengths is its ability to expose all of its operations and data through the use of Enterprise SOAP calls, allowing you to integrate deep within SalesForce briding
the online resource with your internal applications.
</p>

<p>
However, this SOAP API, presents some of the most complicated web services operations you are likely to meet.  That said, once mastered you will soon discover that nothing
will stop you in consuming and operating in the rich world of connected services.   This section will detail how OpenBD can be used to reach into the wonders of this world without
any extra work or extensions.
</p>

<h2>Obtaining the SalesForce WSDL</h2>

<p>
Before you can invoke any calls to the SalesForce API, you must first obtain the WSDL definition file.  This will be dependent on your account and the services that your account
is exposing.  Log into your System Administrators account and download the Enterprise (or partner) WSDL file.   Unlike most SOAP services, we'll be using a locally saved WSDL file
to access a remote WSDL.   Fortunately OpenBD can use a WSDL that is located on the file system as easily as a remote URL.
</p>

<h2>Creating and logging into SalesForce</h2>

<p>
Let us assume you have saved the WSDL file into the same web directory as the web page you are making the CFML calls from.  This file will be approximately 300-500KB in size which
illustrates just how functionality is available for remote calling.
</p>

<p>
<em>please note, all the following CFML snippets will assumed to be used inside CFSCRIPT.</em>
</p>

<p>
The first thing we must do is to create the object to SalesForce, using the standard <a href="./?/function/createobject">CreateObject</a> method.  You may find a short delay the first
time you invoke this method.  This is because OpenBD has to retrieve all the remote objects and assembly them locally in a compiled format.  This is then cached and any further
<a href="./?/function/createobject">CreateObject</a> calls on the same WSDL will be instant.
</p>

<pre class="cfml">
sfObj = CreateObject( "webservice", ExpandPath("enterprise.wsdl.xml") );
</pre>

<p>
SalesForce has a <a href="http://www.salesforce.com/us/developer/docs/pages/index_Left.htm#StartTopic=Content/sforce_api_concepts_security.htm">special step when authenticating the user</a> that will be invoking the remote objects.
You have to call the <strong>login()</strong> method to the salesforce object, which will return a custom endpoint that has to be used in all subsequent SOAP calls.  This URL has to override
the endpoints already definied in the original WSDL.
</p>

<p>
SalesForce requires that you use both a username and password, but also a security token, that you can find (and reset) in your account.  Depending on the user you log in with, will depend
on their scope of access.   Once logged in, you have to use the session token that SalesForce will issue and set that against the local salesforce object that will be used for all
subsequent calls.
</p>

<pre class="cfml">
// Login and set the custom endpoint that SalesForce tells us to use
loginObj = sfObj.login( "username@myemail.com", "mypassword" & "salesforce-security-token" );
sfObj._setProperty( "javax.xml.rpc.service.endpoint.address", loginObj.getServerUrl() );

// Set the session header
sh = sfObj.getClass().getClassLoader().loadClass("com.sforce.soap.enterprise.SessionHeader").newInstance();
sh.setSessionId( loginObj.getSessionId() );
sfObj.setHeader("urn:enterprise.soap.sforce.com","SessionHeader", sh );
</pre>

<p>
You will notice something possibly foreign here when it comes to working with objects.   SalesForce defines a whole host of custom objects that you have to create, set properties or call
methods on.   Since these classes do not ship with OpenBD, but instead are created on demand by the SalesForce webservices classloader, we have to use the same classloader as the one that
created the original method.   That is why we use the original object, to get the underlying Java Class method, that then allows us to get the Classloader, which inturn lets us load a
custom class and create it.
</p>

<pre class="cfml">
// Creating a custom SalesForce object
sh = sfObj.getClass().getClassLoader().loadClass("com.sforce.soap.enterprise.SessionHeader").newInstance();
</pre>

<p>
This syntax you will find familiar as you work with all the types of SalesForce objects.
</p>

<h2>Querying SalesForce</h2>

<p>
SalesForce lets you query most of its database that it is holding for you.  Precisely what attributes you can query depends largely on the accessibility of your account.  But this
example lets you see how you can use the Query method from SalesForce to create a CFML query object.
</p>

<pre class="cfml">
qryResult   = QueryNew( "OrigId,Id,Email,Name,Firstname,LastName,Title" );
records     = sfObj.query( "select Id,Email,Name,Firstname,LastName,Title from User where Email='myacc@mydomain.com'" );
recordSize  = records.getSize();

if ( recordSize > 0 ){
  recordArray = records.getRecords();
  x=1;
  for ( x=1; x <= recordSize; x=x+1 ){
    QueryAddRow( qryResult, 1 );
    QuerySetCell( qryResult, "OrigId",     recordArray[x].getId() );
    QuerySetCell( qryResult, "Id",         Left(recordArray[x].getId(),15) );
    QuerySetCell( qryResult, "Email",      ToString(recordArray[x].getEmail()) );
    QuerySetCell( qryResult, "Name",       ToString(recordArray[x].getName()) );
    QuerySetCell( qryResult, "Firstname",  ToString(recordArray[x].getFirstName()) );
    QuerySetCell( qryResult, "LastName",   ToString(recordArray[x].getLastName()) );
    QuerySetCell( qryResult, "Title",      ToString(recordArray[x].getTitle()) );
  }
}
</pre>


<h2>Create objects in SalesForce</h2>

<p>
As well as querying you can create new objects for use within SalesForce.  This depends, again, on what writes the account you are using to connect has, but SalesForce lets you do
as much as you want.  This example shows how to create a SalesForce Task object.  As you can see from the SalesForce <a href="http://www.salesforce.com/us/developer/docs/pages/index_Left.htm#StartTopic=Content/sforce_api_objects_task.htm">Task Documentation</a>
you have to create a Task object and set parameters using method calls.
</p>

<pre class="cfml">
newTask = sfObj.getClass().getClassLoader().loadClass("com.sforce.soap.enterprise.sobject.Task").newInstance();

newTask.setOwnerId( arguments.sfOwnerId );
newTask.setWhoId( arguments.sfWhoId );
newTask.setDescription( arguments.sfDescription );
newTask.setSubject( Left(arguments.sfSubject,80) );
newTask.setStatus( arguments.sfStatus );
newTask.setActivityDate( arguments.sfActivityDate );
</pre>

<p>
Once you have create the Task object, you have to pass it to the main SalesForce <strong>create()</strong> method that accepts any number of object types.  This is an array of objects,
so you can create a number of objects in one operation.
</p>

<pre class="cfml">
//Create the task
taskArray   = [ newTask ];
resultArray = sfObj.create( taskArray );

//Determine its success
if ( !resultArray[1].isSuccess() ){
  errorArray	= resultArray[1].getErrors();
  if ( ArrayLen(errorArray) > 0 ){
    throw( errorArray[1].getMessage() );
  }
}
</pre>

<p>
The result of this call returns back an array that details the result of the particular object insertion and the error message if something has gone wrong.
</p>

<h2>Working with SalesForce</h2>

<p>
SalesForce has a rich API that you can easily integrate into your CFML OpenBD application, by following the above examples and extending them to the corresponding object
you are attempting to utilise.   The ease and speed of which you can integrate to complex enterprise systems, such as SalesForce, makes CFML the ideal language choice.
</p>

<p>
Reference: <a href="http://www.salesforce.com/us/developer/docs/api/index_Left.htm">SalesForce WebServices API Documentation</a>
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->