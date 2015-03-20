<cfsilent>
	<cfset request.page.section = "plugins">
	<cfset request.page.title 	= "SMTP Extension">
	<cfset request.page.desc	= "The cfSMTP extension allows you to process incoming email as if they were web requests">
</cfsilent>

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/plugin">Plugins</a></li>
      <li class="active"><a href="./?/plugin_cfsmtp"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>SMTP Extension</h1>
		
		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">
<p>
CFSMTP opens up a whole new world of possibilities to the CFML developer.   In much the same way OpenBD makes building rich web applications
for web (HTTP) requests, this plugin opens up the world of email to the CFML community.   Just as a page reacts to a request, the CFSMTP
invokes a CFC for every email that comes into the server allowing to build rich email applications.
</p>

<p>
Once you register this listener, this plugin will listen for email delivery on the standard Port25.  You have the opportunity to determine
if you wish to accept email before the sender transmits the full email body, allowing you to quickly stop spam and unwanted emails.
Once you've decided to accept the email, the plugin will ensure delivery and then call your CFC again detailing the email.
</p>

<p>
You can then process the email, looking at its headers, body, attachments and if you need to send out any email, then you use the
standard CFML CFMAIL way of achieving that.
</p>

<p>
This extension is built-in to the core distribution of OpenBD, no extra download/installation required.
</p>

<h2>Overview of functions</h2>

<p>
CFSMTP is setup using a series of functions letting you startup, shutdown and query the status of your CFSMTP endpoint.  You can
run multiple servers, each on their different interface/port, referencing them using a symbolic name.
</p>

<table width="90%" align="center" cellpadding="5" cellspacing="0">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/smtpstart">SmtpStart</a></td>
		<td>Starts up a listening service for incoming emails, calling a CFC in response to all mails</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/smtpstatus">SmtpStatus</a></td>
		<td>Returns back the stats for this SMTP end point; running, totalmails, totalconnections</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/smtpstop">SmtpStop</a></td>
		<td>Stops a running SMTP server.  Returns true if it was stopped; false if it wasn&apos;t running</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/mailread">MailRead</a></td>
		<td>Used in conjunction with MailWrite().  This function reads the previously serialized email out to disk</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/mailwrite">MailWrite</a></td>
		<td>This function writes the email out to disk for later processing or archiving</td>
	</tr>
	<tr>
		<td width="1%" nowrap align="right"><a href="./?/function/maildeliver">MailDeliver</a></td>
		<td>This function takes the email object and sends it for delivery to a new server, giving you the opportunity to override from, to, cc, bcc and server</td>
	</tr>
</tbody>
</table>

<p>
The key to the success of the CFSMTP plugin is in the CFC that is used to process the incoming email.  It is this CFC, with the pre-defined methods, that
will be called for each stage of the email processing.   Remember, these CFC's run as headless requests, which means they are outside of the normal scope of
a web request.  Therefore operations such as session management, cookie's and CGI scopes are not applicable.
</p>

<p>
However, the 'request' scope is available and is exclusive per each single transaction.  This lets you, for example, put content into it
when you are processing one of the onMailFrom() and pick it up again on the onAcceptMail()
</p>

<h2>Accepting Email</h2>

<p>
Email delivery is done in 3 stages.   First the sender sends who the email is from, then it sends who the email is for, and finally it delivers the email body.  Here
is a full example using the same CFC for both the <a href="./?/function/smtpstart">cfcmail</a> and <a href="./?/function/smtpstart">cfcfilter</a> options.
</p>

<cfsavecontent variable="cfml"><nocfml>
<cfcomponent>

  <cffunction name="onmailfrom" access="public" returntype="boolean">
    <cfargument name="email" required="yes">
    <cfargument name="ip" required="yes">
    <cfreturn true>
  </cffunction>


  <cffunction name="onmailto" access="public" returntype="boolean">
    <cfargument name="email" required="yes">
    <cfargument name="ip" required="yes">
    <cfreturn true>
  </cffunction>


  <cffunction name="onMailAccept" access="public" returntype="any" output="no">
    <cfargument name="mail" required="yes">

  </cffunction>

</cfcomponent>
</nocfml></cfsavecontent>

<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

<h3>onmailfrom / onmailto</h3>

<p>
If you specify this CFC <a href="./?/function/smtpstart">cfcfilter</a> option then you are given the opportunity to hook into the very start of the email exchange
with the remote server.   This gives you an opportunity to deny any further exchange with the remote server by returning false.  This is a huge benefit when reducing
spam and unwanted emails.
</p>

<h3>onMailAccept</h3>

<p>
This is the main processing for emails that come in to the server.  From here you can work with all aspects of the incoming email, including processing the body and downloading any attachments.
</p>

<p>
The <b>mail</b> object that is passed in has the following functions to process the mail.
</p>

<table width="90%" align="center" cellpadding="5" cellspacing="0">
<thead>
	<tr>
		<th>Function Name</th>
		<th>Description</th>
	</tr>
</thead>
<tbody>
<tr><td width="1%" nowrap align="right">getAllBodyParts()</td><td>returns Array of ALL Parts including the inner ones</td></tr>
<tr><td width="1%" nowrap align="right">getBodyParts()</td><td>returns Array of Parts; as per email</td></tr>
<tr><td width="1%" nowrap align="right">getCcList()</td><td>returns Array of Structs (name/email) of all the people addressed in the Cc field</td></tr>
<tr><td width="1%" nowrap align="right">getFromList()</td><td>returns Array of Structs (name/email) of all the people addressed in the From field</td></tr>
<tr><td width="1%" nowrap align="right">getHeaders()</td><td>returns Array of all the email headers</td></tr>
<tr><td width="1%" nowrap align="right">getHeader( string )</td><td>returns the value of the given header</td></tr>
<tr><td width="1%" nowrap align="right">getIP()</td><td>returns the IP address of the delivery agent</td></tr>
<tr><td width="1%" nowrap align="right">getMessageId()</td><td> returns the email message id</td></tr>
<tr><td width="1%" nowrap align="right">getMailFrom()</td><td> returns email address that was in the MAIL FROM</td></tr>
<tr><td width="1%" nowrap align="right">getReplyToList()</td><td> returns Array of Structs (name/email) of all the people addressed in the Reply-To field</td></tr>
<tr><td width="1%" nowrap align="right">getSentDate()</td><td> returns the date the message was sent</td></tr>
<tr><td width="1%" nowrap align="right">getReceivedDate()</td><td> returns the date the message was received</td></tr>
<tr><td width="1%" nowrap align="right">getRecipients()</td><td> returns Array of email addresses; these are the emails to which the email was delivered to via RCPT TO</td></tr>
<tr><td width="1%" nowrap align="right">getSubject()</td><td> returns the email subject</td></tr>
<tr><td width="1%" nowrap align="right">getSize() </td><td>returns the size of the email</td></tr>
<tr><td width="1%" nowrap align="right">getToList()</td><td> returns Array of Structs (name/email) of all the people addressed in the To field</td></tr>
<tr><td width="1%" nowrap align="right">spoolMailToDir(dir)</td><td> saves the mail to disk and returns the full path of the saved file</td></tr>
</tbody>
</table>

<p>
Here is an example of extracting out only the plain text part of the email.  This method works over MIME type emails as well as plain ones</p>

<cfsavecontent variable="cfml"><nocfml>
<cfcomponent>

<cfscript>
function onMailAccept( mail ){
  var body = getBodyFromParts( arguments.mail.getBodyParts(), "text/plain" );

}

function getBodyFromParts( parts, mimetype ){
  var x=true;
  var part=true;

  for ( x=1; x<=ArrayLen( arguments.parts ); x=x+1){
    part = arguments.parts[x];
    if ( part.isMultiPart() ){
      return getBodyFromParts( part.getBodyParts(), arguments.mimetype );
    } else if ( part.getContentType().indexOf(arguments.mimetype) != -1 ){
      return part.getContent().trim();
    }
  }

  //No body was found
  return "";
}
</cfscript>

</cfcomponent>
</nocfml></cfsavecontent>

<pre class="cfml"><cfoutput>#XmlFormat( Trim(cfml) )#</cfoutput></pre>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->