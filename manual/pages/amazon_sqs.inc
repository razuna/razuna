<cfsilent>
	<cfset request.page.title = "Amazon SQS with OpenBD">
	<cfset request.page.section = "adv">
	<cfset request.page.desc	= "Accessing and integrating Amazon Simple Queue Service into OpenBD is very easy">
</cfsilent>

<div class="subnav">
	<div class="container">
		<ul class="breadcrumb">
			<li><a href="./?/advanced">Advanced</a></li>
			<li class="active"><a href="./?/amazon_sqs"><cfoutput>#request.page.title#</cfoutput></a></li>
		</ul>
	</div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Amazon Simple Queue System (SQS) Integration</h1>
	
		<cfinclude template="pages/sidebar_advanced.inc" />
		
		<div class="section">
	
<p>
<a href="http://aws.amazon.com/sqs/"><img class="right" src="http://g-ecx.images-amazon.com/images/G/01/00/10/00/14/19/27/100014192753._V46777512_.gif"></a>
These are the functions available to OpenBD for interacting with the Simple Queue Service from Amazon Web Services.</p>

<p>
Amazon SQS provides the following major features:
</p>

<ul><li> Redundant infrastructure - Guarantees delivery of your messages at least once, highly concurrent access to messages, and high availability for sending and retrieving messages
</li></ul>
<ul><li> Multiple writers and readers - Multiple parts of your system can send or receive messages at the same time
</li></ul>
<ul><li> SQS locks the message during processing, keeping other parts of your system from processing the message simultaneously.
</li></ul>
<ul><li> Configurable settings per queue - All of your queues don't have to be exactly alike
</li></ul>
<ul><li> Variable message size - Your messages can be up to 8 KB in size
</li></ul>
<ul><li> For even larger messages, you can store the contents of the message using the Amazon Simple Storage Service (Amazon S3) or Amazon SimpleDB and use Amazon SQS to hold a pointer to the Amazon S3 or Amazon SDB object. Alternately, you can split the larger message into smaller ones.
</li></ul>
<ul><li> Unlimited queues and messages - You can have as many queues and messages in the Amazon SQS system as you want
</li></ul>
<ul><li> Access control - You can control who can send messages to a queue, and who can receive messages from a queue
</li></ul>
<p><a href="http://aws.amazon.com/sqs/" class="external free" title="http://aws.amazon.com/sqs/">http://aws.amazon.com/sqs/</a>
</p>

<h2>Registering the datasource</h2>

<p>
To register an Amazon datasource you simply make a call to the function <a href="./?/function/amazonregisterdatasource">AmazonRegisterDataSource()</a>.  You only
need to register an Amazon datasource once for the duration of the life time of the server.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset amzDS = AmazonRegisterDataSource( "amz", "--amazonkey--", "--amazonsecretkey ----" )>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>


<h2>Creating and Deleting Queue</h2>

<p>
This function creates a new Amazon SQS queue. Every message is sent to a given queue waiting for
processing. Messages will remain on the queue for a period of 4 days only.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset AmazonRegisterDataSource( "testamz", "--amazonkey--", "--amazonsecretkey ----" )>

<!--- Create Queue --->
<cfset queueUrl = AmazonsqsCreateQueue("testamz", "testQueue" )>

<!--- Delete the Queue --->
<cfset AmazonsqsDeleteQueue( "testamz", queueUrl )>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>


<p>
This function will return the URL to the queue. This will be used as a parameter to many of the queue related functions.
If a major error occurred it will throw a CFML exception that can be caught.
</p>


<h2>Sending and Receiving Messages</h2>

<p>
Send a message to the queue using the <a href="./?/function/AmazonSqsSendMessage">AmazonSqsSendMessage()</a>.  A message can be any
ASCII text, but is limited to 8KB.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfset AmazonRegisterDataSource( "testamz", "--amazonkey--", "--amazonsecretkey ----" )>

<!--- Create Queue --->
<cfset queueUrl = AmazonsqsCreateQueue("testamz", "testQueue" )>

<!--- Send the message --->
<cfset myMessage= "This is a test message">
<cfset AmazonSqsSendMessage( "testamz", queueUrl, myMessage )>

<!--- Receive message --->
<cfset message = AmazonSqsReceiveMessage( "testamz", queueUrl )>
<cfif ArrayLen(message) neq 0>
  <cfset AmazonSqsDeleteMessage("testamz", queueUrl, message[1]["ReceiptHandle"] )>
</cfif>
</nocfml></cfsavecontent>
<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<p>
When you receive a message, you have time to process it, but once you are finished you must delete it again.  If you don't delete it
within the visibility timeout period, then the message will be made available again to another requester.
</p>


<h2>Functions for SQS</h2>
<p>
There are functions that let you operate with all of the services provided by SQS.
</p>

<table align="center" cellpadding="5" cellspacing="0" width="90%">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqsaddpermission">AmazonSqsAddPermission</a></td>
		<td>Adds the given permission to the queue within the account</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqschangemessagevisibility">AmazonSqsChangeMessageVisibility</a></td>
		<td>Changes the visibility of the given message by the value given</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqscreatequeue">AmazonSqsCreateQueue</a></td>
		<td>Creates a new Amazon SQS queue, with the default visibility.  Returns the Queue URL</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqsdeletemessage">AmazonSqsDeleteMessage</a></td>
		<td>Deletes the message on the queue</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqsdeletequeue">AmazonSqsDeleteQueue</a></td>
		<td>Deletes the queue</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqsgetattributes">AmazonSqsGetAttributes</a></td>
		<td>Gets the attributes for the given queue url</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqslistqueues">AmazonSqsListQueues</a></td>
		<td>Returns all the queues for this account</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqsreceivemessage">AmazonSqsReceiveMessage</a></td>
		<td>Returns the messages available for processing sitting in teh queue</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqsremovepermission">AmazonSqsRemovePermission</a></td>
		<td>Removes the given label permission from the queue</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqssendmessage">AmazonSqsSendMessage</a></td>
		<td>Adds the given message to the queue</td>
	</tr><tr>
		<td align="right" nowrap="nowrap" width="1%"><a href="./?/function/amazonsqssethost">AmazonSqsSetHost</a></td>
		<td>Changes the host endpoint for the Amazon SQS service.  Defaults to queue.amazonaws.com.  Possible: us-west-1.queue.amazonaws.com, eu-west-1.queue.amazonaws.com, ap-southeast-1.queue.amazonaws.com</td>
	</tr>
</tbody>
</table>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->