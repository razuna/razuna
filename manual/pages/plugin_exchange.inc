<cfset request.page.section = "plugins">
<cfset request.page.title = "Exchange Plugin">
<cfset request.page.desc	= "Exchange plugin allows you to communicate with Exchange Server to get contacts, calendar and task items">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/plugin">Plugins</a></li>
      <li class="active"><a href="./?/plugin_exchange"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Exchange Plugin</h1>
		
		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">
<p>
Exchange APIs are the methods by which the client can communicate with the Exchange Server for various operations such as Creating, Updating, Searching various objects
such as Tasks, Contacts and Calendar. The Exchange APIs enable the client to provide proper input in the SOAP Request Template and get the valid SOAP Response
from the Exchange Server. With the help of these the user can even get the information of a particular item such as Contact, Task or Calendar. Every Exchange Plugin API is associated with a web service.
</p>

<p>
For instance suppose if the User wants to create a new Task then the valid input expected by the ExchangeCreateTask is a structure containing all the fields with the corresponding values.
The output is a structure containing the Id and the ChangeKey of the new Task created.
</p>

<p>
Amongst the Exchange APIs there is ExchangeGetUserInfo which retrieves the User Information provided a valid and Authenticated Username is given as Input. The search scope is limited to the Active Directory. Only
authenticated users information is retrieved.
</p>
<p>
Exchange APIs also enables the user to get the complete list of Items such as Contacts, Calendar or Tasks present in the user's OWA Account.
It also provides the functionality to get the Folder and the Sub-Folder Ids of the specified folder.
</p>

<p>
This Exchange Plugin enables communication with the server using the following set of functions:
</p>


<ul>
	<li>ExchangeOpenConnection()</li>
	<li>ExchangeCloseConnection()</li>
	<li>ExchangeGetUserInfo()</li>
	<li>ExchangeCreateTask()</li>
	<li>ExchangeCreateCalendarItem()</li>
	<li>ExchangeUpdateTask()</li>
	<li>ExchangeUpdateCalendarItem()</li>
	<li>ExchangeUpdateContact()</li>
	<li>ExchangeSearchTasks()</li>
	<li>ExchangeSearchContacts()</li>
	<li>ExchangeSearchCalendarItems()</li>
	<li>ExchangeGetContact()</li>
	<li>ExchangeGetTask()</li>
	<li>ExchangeGetCalendarItem()</li>
	<li>ExchangeGetAllContacts()</li>
	<li>ExchangeGetAllTasks()</li>
	<li>ExchangeGetAllCalendarItems()</li>
	<li>ExchangeFindFolders()</li>
	<li>ExchangeDeleteTask()</li>
	<li>ExchangeDeleteCalendarItem()</li>
</ul>

<h2>Open Conection</h2>

<p>
	This API defines a request to the Exchange Server to open the connection with EWS.
</p>
<p>
	You can open connection to the server by simply calling the function: <strong>ExchangeOpenConnection( connection, url, domain, username, password )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server,<strong>url</strong> is the destination with which the connection is to be established,
	<strong>domain</strong> is a valid domain name, <strong>username</strong> and <strong>password</strong> are the credentials required to connect to the Exchange server.
</p>
<p>
	This API will open connection with the EWS.
</p>
<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>
	variables.username = "shravan.t";
	variables.password = "Pass*2010";
	ExchangeOpenConnection( connection="myconnection", url="https://subdomain.domain.com/EWS/exchange.asmx",
		domain = "domain", username = variables.username, password = variables.password );
</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Close Conection</h2>

<p>
	This API defines a request to the Exchange Server to close the connection with EWS.
</p>
<p>
	You can close connection with the server by simply calling the function: <strong>ExchangeCloseConnection( connection )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server.
</p>
<p>
	This API will close connection with the EWS.
</p>

<h2>Get User Information </h2>

<p>
This API defines a request to get the information about the User. It includes details such as Display Name, Given name, email Address.
</p>

<p>
You can get information of the expected User by simply calling the function: <strong>ExchangeGetUserInfo( connection, username )</strong>,
where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>username</strong> is the distinguished name of the user.
</p>

<p>
This API will return cfData containing Information of the User whose username matches with that given in the input.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	GetUserInfo = ExchangeGetUserInfo( connection = "myconnection", username="abcdef" );
	WriteDump( GetUserInfo );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Creating a new task item</h2>

<p>
	This API defines a request to create a new Task item in the Exchange store.
</p>
<p>
	You can create a new Task Item by simply calling the function: <strong>ExchangeCreateTask( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing list of all Task field elements.
</p>
<p>
	This API will return cfData containing either both the Id and the changekey of the newly created TaskItem or the Error Message Text.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">subject</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the subject for Exchange store items and response objects</td>
	</tr>
	<tr>
		<td valign="top">duedate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the date when a task item is due</td>
	</tr>
	<tr>
		<td valign="top">startdate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the start date of a task item</td>
	</tr>
	<tr>
		<td valign="top">reminderdueby</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the date and time when the event occurs</td>
	</tr>
	<tr>
		<td valign="top">reminderisset</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a reminder has been set for an item in the Exchange store</td>
	</tr>
	<tr>
		<td valign="top">body</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the actual body content of a message</td>
	</tr>
	<tr>
		<td valign="top">bodytype</td>
		<td valign="top">HTML, Text</td>
		<td valign="top">HTML</td>
		<td valign="top">false</td>
		<td valign="top">Describes how the item body is stored in the item</td>
	</tr>
	<tr>
		<td valign="top">importance</td>
		<td valign="top">Low, Normal, High </td>
		<td valign="top">Normal</td>
		<td valign="top">false</td>
		<td valign="top">Describes the importance of an item</td>
	</tr>
	<tr>
		<td valign="top">percentcomplete</td>
		<td valign="top"></td>
		<td valign="top">0</td>
		<td valign="top">false</td>
		<td valign="top">Describes the completion status of a task</td>
	</tr>
	<tr>
		<td valign="top">status</td>
		<td valign="top">Notstarted, InProgress, Completed, WaitingOnOthers, Deferred</td>
		<td valign="top">Notstarted</td>
		<td valign="top">false</td>
		<td valign="top">Represents the status of a task item</td>
	</tr>
	<tr>
		<td valign="top">reminderminutesbeforestart</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the number of minutes before an event when a reminder is displayed</td>
	</tr>
	<tr>
		<td valign="top">inreplyto</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the identifier of the item to which this item is a reply</td>
	</tr>
	<tr>
		<td valign="top">sensitivity</td>
		<td valign="top">Normal, Personal, Private, Confidential</td>
		<td valign="top">Normal</td>
		<td valign="top">false</td>
		<td valign="top">Contains the status for an item's sensitivity</td>
	</tr>
	<tr>
		<td valign="top">mileage</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents mileage for a task item</td>
	</tr>
	<tr>
		<td valign="top">billingInformation</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Holds billing information for a task</td>
	</tr>
	<tr>
		<td valign="top">totalWork</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains a description of how much work is associated with an item</td>
	</tr>
	<tr>
		<td valign="top">actualWork</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the actual amount of time that is spent on a task</td>
	</tr>
	<tr>
		<td valign="top">recurrence</td>
		<td valign="top"><strong>Repeat Pattern</strong>: Daily, Weekly, Monthly, Yearly<BR/>
						 <strong>regeneration</strong>:true, false<BR/>
		                 <strong>Month</strong>: January, February, March, April, May, June, July, August, September, October, November, December<BR/>
		                 <strong>daysofweek</strong>: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday<BR/>
		                 <strong>DayOfWeekIndex</strong>: First, Second, Third, Fourth, Last<BR/>
		                 </td>
		<td valign="top"> <strong>regeneration</strong>: false<BR/>
						  <strong>interval</strong>:1<BR/>
		</td>
		<td valign="top">false</td>
		<td valign="top">Contains recurrence information for recurring tasks</td>
	</tr>
	<tr>
		<td valign="top">companies</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the collection of companies that are associated with a contact or task</td>
	</tr>
	<tr>
		<td valign="top">Contacts</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains a list of contacts that are associated with a task</td>
	</tr>
</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	task = {
		subject:"ssscccccccccrecurrenceeeeeeeeeee",
		duedate:createdatetime(year=2009, month=12, day=7, hour=13, minute=45, second=00),
		startdate:createdatetime(year=2010, month=12, day=6, hour=13, minute=45, second=00),
		reminderdueby:createdatetime(year=2010, month=12, day=8, hour=13, minute=45, second=00),
		reminderisset:false,
		body:"&bdf&",
		bodytype:"HTML",
		importance:"High",
		percentcomplete:76,
		status:"InProgress",
		reminderminutesbeforestart:54,
		inreplyto:"cool",
		sensitivity:"Private",
		mileage:"a&b",
		billingInformation:"a&b",
		totalWork:8,
		actualWork:12,
		recurrence:{
					repeatpattern:"YeArly",
					DayOfMonth:12,
					Month:"January",
					startdate:Createdate(year=2010, month=12, day=17),
					numberofoccurrences:3
					},
		companies:["companyco&", "company2&"],
		Contacts:["contact&1"]

		};

	val = ExchangeCreateTask( connection = "myconnection", inputData = task );
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>


<h2>Creating a new calendar item</h2>
<p>
	This API defines a request to create a new Calendar item in the Exchange store.
</p>

<p>
	You can create a new Calendar Item by simply calling the function: <strong>ExchangeCreateCalendarItem( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing list of all calendar field elements.
</p>
<p>
	This API will return cfData containing either both the Id and the changekey of the newly created CalendarItem or the Error Message Text.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">subject</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the subject for Exchange store items and response objects</td>
	</tr>
	<tr>
		<td valign="top">sensitivity</td>
		<td valign="top">Normal, Personal, Private, Confidential</td>
		<td valign="top">Normal</td>
		<td valign="top">false</td>
		<td valign="top">Contains the status for an item's sensitivity</td>
	</tr>
	<tr>
		<td valign="top">reminderdueby</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the date and time when the event occurs</td>
	</tr>
	<tr>
		<td valign="top">body</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the actual body content of a message</td>
	</tr>
	<tr>
		<td valign="top">bodytype</td>
		<td valign="top">HTML, Text</td>
		<td valign="top">HTML</td>
		<td valign="top">false</td>
		<td valign="top">Describes how the item body is stored in the item</td>
	</tr>
	<tr>
		<td valign="top">importance</td>
		<td valign="top">Low, Normal, High</td>
		<td valign="top">Normal</td>
		<td valign="top">false</td>
		<td valign="top">Describes the importance of an item</td>
	</tr>
	<tr>
		<td valign="top">reminderisset</td>
		<td valign="top"></td>
		<td valign="top">true</td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a reminder has been set for an item in the Exchange store</td>
	</tr>
	<tr>
		<td valign="top">reminderminutesbeforestart</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the number of minutes before an event when a reminder is displayed</td>
	</tr>
	<tr>
		<td valign="top">location</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the location of a meeting or appointment</td>
	</tr>
	<tr>
		<td valign="top">isalldayevent</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a calendar item or meeting request represents an all-day event</td>
	</tr>
	<tr>
		<td valign="top">start</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the start of a calendar item</td>
	</tr>
	<tr>
		<td valign="top">end</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the end of a duration</td>
	</tr>
	<tr>
		<td valign="top">inreplyto</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the identifier of the item to which this item is a reply</td>
	</tr>
	<tr>
		<td valign="top">when</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Provides information about when a calendar item occurs</td>
	</tr>
	<tr>
		<td valign="top">netShowurl</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Specifies the URL for a Microsoft NetShow online meeting</td>
	</tr>
	<tr>
		<td valign="top">meetingworkspaceurl</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains the URL for the meeting workspace that is linked to by the calendar item</td>
	</tr>
	<tr>
		<td valign="top">allowNewtimeProposal</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a new meeting time can be proposed for a meeting by an attendee</td>
	</tr>
	<tr>
		<td valign="top">conferencetype</td>
		<td valign="top">NetMeeting, NetShow, Chat</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the type of conferencing that is performed with a calendar item</td>
	</tr>
	<tr>
		<td valign="top">freebusystatus</td>
		<td valign="top">Free, Tentative, Busy, OOF, NoData</td>
		<td valign="top">Busy</td>
		<td valign="top">false</td>
		<td valign="top">Represents the free/busy status of the calendar item</td>
	</tr>
	<tr>
		<td valign="top">requiredattendees</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents attendees that are required to attend a meeting</td>
	</tr>
	<tr>
		<td valign="top">optionalattendees</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents attendees that are not required to attend a meeting</td>
	</tr>
	<tr>
		<td valign="top">resources</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents a scheduled resource for a meeting</td>
	</tr>
	<tr>
		<td valign="top">recurrence</td>
		<td valign="top" width = 100px><strong>Repeat Pattern</strong>: Daily, Weekly, Monthly, Yearly<BR/>
		                 <strong>Month</strong>: January, February, March, April, May, June, July, August, September, October, November, December<BR/>
		                 <strong>daysofweek</strong>: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday<BR/>
		                 <strong>DayOfWeekIndex</strong>: First, Second, Third, Fourth, Last<BR/>
		                 </td>
		<td valign="top"><strong>interval</strong>:1<BR/></td>
		<td valign="top">false</td>
		<td valign="top">Contains recurrence information for recurring tasks</td>
	</tr>
	<tr>
		<td valign="top">starttimezoneid</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the start time zone of the calendar item</td>
	</tr>
	<tr>
		<td valign="top">endtimezoneid</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the end time zone of the calendar item</td>
	</tr>
</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>
	params = {
		subject:"final CI",
		sensitivity:"Private",
		reminderdueby:Createdatetime(year=2010, month=12, day=15, hour=01, minute=00, second=00),
		bodytype:"Text",
		body:"This is html body....",
		importance:"High",
		reminderisset:true,
		reminderminutesbeforestart: 15 ,
		location:"&&&&&",
		isalldayevent:false,
		start:Createdatetime(year=2011, month=12, day=16, hour=06, minute=00, second=00),
		end:Createdatetime(year=2012, month=12, day=27, hour=06, minute=30, second=00),
		inreplyto:"cool",
		when:"vdfve&&bfg",
		netShowurl:"ddd&&&&ddddd",
		meetingworkspaceurl:"xxxxxxxxxx",
		allowNewtimeProposal:true,
		conferencetype:"NetMeeting",
		freebusystatus:"Busy",
		requiredattendees:[{name:"a&g",email:"a@c.com"},{name:"b",email:"b@c.com"}],
		optionalattendees:[{name:"c",email:"c@c.com"},{name:"d",email:"d@c.com"}],
		resources:[{name:"e",email:"e@c.com"},{name:"f",email:"f@c.com"}],
		recurrence:{
				repeatpattern:"YeArly",
				DayOfMonth:12,
				Month:"January",
				startdate:Createdate(year=2010, month=12, day=17),
				numberofoccurrences:3
				},
		starttimezoneid:"Central Asia Standard time",
		endtimezoneid:"Central Asia Standard time"
		};

	val = ExchangeCreateCalendarItem( connection = "myconnection", inputData = params );
	WriteDump( val );
</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>


<h2>Updating a task item</h2>

<p>
	This API defines a request to update a Task Item in a mailbox.
</p>
<p>
	You can update a Task Item by simply calling the function: <strong>ExchangeUpdateTask( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing id and list of fields to be updated in a Task.
</p>
<p>
	This API will return cfData containing either both the Id and the changekey of the updated TaskItem or the Error Message Text.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">id</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">true</td>
		<td valign="top">Represents the Unique Identifier of a task</td>
	</tr>
	<tr>
		<td valign="top">changekey</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the Change Key of a task</td>
	</tr>
	<tr>
		<td valign="top">subject</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the subject for Exchange store items and response objects</td>
	</tr>
	<tr>
		<td valign="top">duedate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the date when a task item is due</td>
	</tr>
	<tr>
		<td valign="top">startdate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the start date of a task item</td>
	</tr>
	<tr>
		<td valign="top">reminderdueby</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the date and time when the event occurs</td>
	</tr>
	<tr>
		<td valign="top">reminderisset</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a reminder has been set for an item in the Exchange store</td>
	</tr>
	<tr>
		<td valign="top">body</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the actual body content of a message</td>
	</tr>
	<tr>
		<td valign="top">bodytype</td>
		<td valign="top">HTML, Text</td>
		<td valign="top">HTML</td>
		<td valign="top">false</td>
		<td valign="top">Describes how the item body is stored in the item</td>
	</tr>
	<tr>
		<td valign="top">importance</td>
		<td valign="top">Low, Normal, High</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the importance of an item</td>
	</tr>
	<tr>
		<td valign="top">percentcomplete</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the completion status of a task</td>
	</tr>
	<tr>
		<td valign="top">status</td>
		<td valign="top">Notstarted, InProgress, Completed, WaitingOnOthers, Deferred</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the status of a task item</td>
	</tr>
	<tr>
		<td valign="top">reminderminutesbeforestart</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the number of minutes before an event when a reminder is displayed</td>
	</tr>
	<tr>
		<td valign="top">inreplyto</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the identifier of the item to which this item is a reply</td>
	</tr>
	<tr>
		<td valign="top">sensitivity</td>
		<td valign="top">Normal, Personal, Private, Confidential</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains the status for an item's sensitivity</td>
	</tr>
	<tr>
		<td valign="top">mileage</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents mileage for a task item</td>
	</tr>
	<tr>
		<td valign="top">billingInformation</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Holds billing information for a task</td>
	</tr>
	<tr>
		<td valign="top">totalWork</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains a description of how much work is associated with an item</td>
	</tr>
	<tr>
		<td valign="top">actualWork</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the actual amount of time that is spent on a task</td>
	</tr>
	<tr>
		<td valign="top">recurrence</td>
		<td valign="top" width = 100px><strong>Repeat Pattern</strong>: Daily, Weekly, Monthly, Yearly<BR/>
		                 <strong>regeneration</strong>:true, false<BR/>
		                 <strong>Month</strong>: January, February, March, April, May, June, July, August, September, October, November, December<BR/>
		                 <strong>daysofweek</strong>: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday<BR/>
		                 <strong>DayOfWeekIndex</strong>: First, Second, Third, Fourth, Last<BR/>
		                 </td>
		<td valign="top"><strong>regeneration</strong>: false<BR/>
						<strong>interval</strong>:1<BR/>
		</td>
		<td valign="top">false</td>
		<td valign="top">Contains recurrence information for recurring tasks</td>
	</tr>
	<tr>
		<td valign="top">companies</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the collection of companies that are associated with a contact or task</td>
	</tr>
	<tr>
		<td valign="top">Contacts</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains a list of contacts that are associated with a task</td>
	</tr>
</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	task = {
		id:"snhTOxS5DZI3hjoguSAAAA/43fAADoD/snhTOxS5DZI3hjoguSAAAGKfkOAAA=",
		changekey:"EwAAABYAAADUfdVn0tiqSreXBHySP2UcAAAAadTF",
		subject:"bvbvbvbvbvbvb",
		duedate:Createdatetime(year=2010, month=12, day=7, hour=01, minute=00, second=00),
		startdate:Createdatetime(year=2009, month=12, day=6, hour=13, minute=45, second=00),
		Completedate:Createdatetime(year=2010, month=12, day=6, hour=13, minute=45, second=00),
		reminderdueby:Createdatetime(year=2010, month=12, day=8, hour=13, minute=45, second=00),
		reminderisset:false,
		body:"This is body element",
		bodytype:"HTML",
		importance:"High",
		percentcomplete:16.6,
		status:"InProgress",
		mileage:"Veryhigh",
		Contacts:["first", "second"],
		companies:["first", "second"],
		totalWork:10,
		actualWork:76,
		billingInformation:"Billing&Information",
		sensitivity:"Private",
		InReplyTo:"this is string",
		recurrence:{
				repeatpattern:"YeArly",
				DayOfMonth:12,
				Month:"January",
				startdate:Createdate(year=2010, month=12, day=17),
				numberofoccurrences:3
				},
		reminderminutesbeforestart:100

		};

	val = ExchangeUpdateTask( connection = "myconnection", inputData = task );
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>


<h2>Updating a calendar item</h2>
<p>
	This API defines a request to update a Calendar Item in a mailbox.
</p>

<p>
	You can update a Calendar Item by simply calling the function: <strong>ExchangeUpdateCalendarItem( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing id and list of fields to be updated in a Calendar.
</p>
<p>
	This API will return cfData containing either both the Id and the changekey of the updated CalendarItem or the Error Message Text.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">id</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">true</td>
		<td valign="top">Represents the Unique Identifier of a calendaritem</td>
	</tr>
	<tr>
		<td valign="top">changekey</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the ChangeKey of a calendaritem</td>
	</tr>
	<tr>
		<td valign="top">subject</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the subject for Exchange store items and response objects</td>
	</tr>
	<tr>
		<td valign="top">sensitivity</td>
		<td valign="top">Normal, Personal, Private, Confidential</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains the status for an item's sensitivity</td>
	</tr>
	<tr>
		<td valign="top">reminderdueby</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the date and time when the event occurs</td>
	</tr>
	<tr>
		<td valign="top">body</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the actual body content of a message</td>
	</tr>
	<tr>
		<td valign="top">bodytype</td>
		<td valign="top">HTML, Text</td>
		<td valign="top">HTML</td>
		<td valign="top">false</td>
		<td valign="top">Describes how the item body is stored in the item</td>
	</tr>
	<tr>
		<td valign="top">importance</td>
		<td valign="top">Low, Normal, High</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the importance of an item</td>
	</tr>
	<tr>
		<td valign="top">reminderisset</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a reminder has been set for an item in the Exchange store</td>
	</tr>
	<tr>
		<td valign="top">reminderminutesbeforestart</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the number of minutes before an event when a reminder is displayed</td>
	</tr>
	<tr>
		<td valign="top">location</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the location of a meeting or appointment</td>
	</tr>
	<tr>
		<td valign="top">isalldayevent</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a calendar item or meeting request represents an all-day event</td>
	</tr>
	<tr>
		<td valign="top">start</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the start of a calendar item</td>
	</tr>
	<tr>
		<td valign="top">end</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the end of a duration</td>
	</tr>
	<tr>
		<td valign="top">inreplyto</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the identifier of the item to which this item is a reply</td>
	</tr>
	<tr>
		<td valign="top">when</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Provides information about when a calendar item occurs</td>
	</tr>
	<tr>
		<td valign="top">netShowurl</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Specifies the URL for a Microsoft NetShow online meeting</td>
	</tr>
	<tr>
		<td valign="top">meetingworkspaceurl</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains the URL for the meeting workspace that is linked to by the calendar item</td>
	</tr>
	<tr>
		<td valign="top">allowNewtimeProposal</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Indicates whether a new meeting time can be proposed for a meeting by an attendee</td>
	</tr>
	<tr>
		<td valign="top">conferencetype</td>
		<td valign="top">NetMeeting, NetShow, Chat</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the type of conferencing that is performed with a calendar item</td>
	</tr>
	<tr>
		<td valign="top">freebusystatus</td>
		<td valign="top">Free, Tentative, Busy, OOF, NoData</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the free/busy status of the calendar item</td>
	</tr>
	<tr>
		<td valign="top">requiredattendees</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents attendees that are required to attend a meeting</td>
	</tr>
	<tr>
		<td valign="top">optionalattendees</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents attendees that are not required to attend a meeting</td>
	</tr>
	<tr>
		<td valign="top">resources</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents a scheduled resource for a meeting</td>
	</tr>
	<tr>
		<td valign="top">recurrence</td>
		<td valign="top" width = 100px><strong>Repeat Pattern</strong>: Daily, Weekly, Monthly, Yearly<BR/>
		                 <strong>Month</strong>: January, February, March, April, May, June, July, August, September, October, November, December<BR/>
		                 <strong>daysofweek</strong>: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday<BR/>
		                 <strong>DayOfWeekIndex</strong>: First, Second, Third, Fourth, Last<BR/>
		                 </td>
		<td valign="top"><strong>interval</strong>:1<BR/></td>
		<td valign="top">false</td>
		<td valign="top">Contains recurrence information for recurring calendar items</td>
	</tr>
	<tr>
		<td valign="top">starttimezoneid</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the start time zone of the calendar item</td>
	</tr>
	<tr>
		<td valign="top">endtimezoneid</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the end time zone of the calendar item</td>
	</tr>
</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	params = {
		id:"snhTOxS5DZI3hjoguSAAAA/43aAADoD/snhTOxS5DZI3hjoguSAAAGKhknAAA=",
		changekey:"DwAAABYAAADUfdVn0tiqSreXBHySP2UcAAAAadUA",
		subject:"0987654321",
		sensitivity:"Private",
		reminderdueby:Createdatetime(year=2010, month=12, day=15, hour=01, minute=00, second=00),
		bodytype:"Text",
		body:"This is html body....",
		importance:"High",
		reminderisset:true,
		reminderminutesbeforestart: 6,
		location:"&NHG&NFH&",
		isalldayevent:false,
		start:createdatetime(year=2011, month=12, day=16, hour=06, minute=00, second=00),
		end:createdatetime(year=2012, month=12, day=27, hour=06, minute=30, second=00),
		inreplyto:"cool",
		when:"&1&2&3",
		netShowurl:"ddd&nghf",
		meetingworkspaceurl:"&bgf&",
		allowNewtimeProposal:true,
		conferencetype:"NetMeeting",
		freebusystatus:"Busy",
		requiredattendees:[{name:"ah",email:"a.b@c.com"},{name:"b",email:"b.b@c.com"}],
		optionalattendees:[{name:"ch",email:"c.b@c.com"},{name:"d",email:"d.bh@c.com"}],
		resources:[{name:"e",email:"e.b7@c.com"},{name:"f",email:"f.b@c.com"}],
		recurrence:{
					repeatpattern:"YeArly",
					DayOfMonth:12,
					Month:"January",
					startdate:createdate(year=2010, month=12, day=17),
					numberofoccurrences:3
					},
		starttimezoneid:"Central Asia Standard time",
		endtimezoneid:"Central Asia Standard time"
		};

	val = ExchangeUpdateCalendarItem( connection = "myconnection", inputData = params );
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Updating a contact item</h2>

<p>
	This API defines a request to update a Contact Item in a mailbox.
</p>
<p>
	You can update a Contact Item by simply calling the function: <strong>ExchangeUpdateContact( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing id and list of fields to be updated in a Contact.
</p>
<p>
	This API will return cfData containing either both the Id and the changekey of the updated ContactItem or the Error Message Text.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">id</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">true</td>
		<td valign="top">Represents the Unique Identifier of a contact</td>
	</tr>
	<tr>
		<td valign="top">changekey</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the ChangeKey of a contact</td>
	</tr>
	<tr>
		<td valign="top">jobtitle</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the job title of a contact</td>
	</tr>
	<tr>
		<td valign="top">assistantname</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents an assistant to a contact</td>
	</tr>
	<tr>
		<td valign="top">businesshomepage</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the home page (Web address) for the contact</td>
	</tr>
	<tr>
		<td valign="top">businessphone1</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the businessphone1 Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">businessphone2</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the businessphone2 Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">company</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the company name that is associated with a contact</td>
	</tr>
	<tr>
		<td valign="top">displayname</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Defines the display name of a contact</td>
	</tr>
	<tr>
		<td valign="top">givenname</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains a contact's given name</td>
	</tr>
	<tr>
		<td valign="top">surname</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the surname of a contact</td>
	</tr>
	<tr>
		<td valign="top">middlename</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the middle name of a contact</td>
	</tr>
	<tr>
		<td valign="top">mobilephone</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the mobilephone Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">businessfax</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the businessfax Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">homephone1</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the homephone1 Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">homephone2</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the homephone2 Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">homephonefax</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the homephonefax Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">assistantphone</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the assistantphone Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">email</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the contact's email Address</td>
	</tr>
	<tr>
		<td valign="top">email2</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the contact's email Address</td>
	</tr>
	<tr>
		<td valign="top">email3</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the contact's email Address</td>
	</tr>
	<tr>
		<td valign="top">emaildisplayname1</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the contact's email Address Display Name</td>
	</tr>
	<tr>
		<td valign="top">emaildisplayname2</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the contact's email Address Display Name</td>
	</tr>
	<tr>
		<td valign="top">emaildisplayname3</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the contact's email Address Display Name</td>
	</tr>
	<tr>
		<td valign="top">department</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the contact's department at work</td>
	</tr>
	<tr>
		<td valign="top">businessstreet</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents a business street address for a contact item</td>
	</tr>
	<tr>
		<td valign="top">businesscity</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the business city name that is associated with a contact</td>
	</tr>
	<tr>
		<td valign="top">businessstate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the business state of residence for a contact item</td>
	</tr>
	<tr>
		<td valign="top">businesscountry</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the business country or region for a given physical address</td>
	</tr>
	<tr>
		<td valign="top">businesspostalcode</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the business postal code for a contact item</td>
	</tr>
	<tr>
		<td valign="top">homestreet</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents a home street address for a contact item</td>
	</tr>
	<tr>
		<td valign="top">homecity</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the home city name that is associated with a contact</td>
	</tr>
	<tr>
		<td valign="top">homestate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the home state of residence for a contact item</td>
	</tr>
	<tr>
		<td valign="top">homecountry</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the home country or region for a given physical address</td>
	</tr>
	<tr>
		<td valign="top">homePostalCode</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the home postal code for a contact item</td>
	</tr>
	<tr>
		<td valign="top">otherStreet</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents a street address for a contact item</td>
	</tr>
	<tr>
		<td valign="top">otherCity</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the city name that is associated with a contact</td>
	</tr>
	<tr>
		<td valign="top">otherState</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the state of residence for a contact item</td>
	</tr>
	<tr>
		<td valign="top">otherCountry</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the country or region for a given physical address</td>
	</tr>
	<tr>
		<td valign="top">otherPostalCode</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the other postal code for a contact item</td>
	</tr>
	<tr>
		<td valign="top">callback</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the Callback Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">carphone</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the Carphone Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">othertelephone</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the othertelephone Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">pager</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the pager of the contact</td>
	</tr>
	<tr>
		<td valign="top">companymainphone</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the CompanyMainphone of the contact</td>
	</tr>
	<tr>
		<td valign="top">isdn</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the isdn of the contact</td>
	</tr>
	<tr>
		<td valign="top">radiophone</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the radiophone Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">telex</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the Telex of the contact</td>
	</tr>
	<tr>
		<td valign="top">ttytddphone</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the TtyTddphone Number of the contact</td>
	</tr>
	<tr>
		<td valign="top">imaddress</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents an instant messaging address for a contact</td>
	</tr>
	<tr>
		<td valign="top">imaddress2</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents an instant messaging address for a contact</td>
	</tr>
	<tr>
		<td valign="top">imaddress3</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents an instant messaging address for a contact</td>
	</tr>
	<tr>
		<td valign="top">manager</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents a contact's manager</td>
	</tr>
	<tr>
		<td valign="top">officelocation</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the Office location</td>
	</tr>
	<tr>
		<td valign="top">notes</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the Notes of the contact</td>
	</tr>

</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	contact = {
		id:"snhTOxS5DZI3hjoguSAAAA/43bAADoD/snhTOxS5DZI3hjoguSAAAGKl5+AAA=",
		changekey:"cvvEQAAABYAAADoD/snhTOxS5DZI3hjoguSAAABAD+l",
		jobtitle:"HR Manager",
		assistantname:"Assis&&&&tant",
		businesshomepage:"homepagebt56n676i87",
		businessphone1:"745854",
		businessphone2:"8568956",
		company:"SNStech",
		displayname:"aabbcc",
		givenname:"HTML",
		surname:"xyz",
		middlename:"KUMAR",
		mobilephone:"bnfb",
		businessfax:"12345",
		homephone1:"12345",
		homephone2:"1234jh&&yjh",
		homephonefax:"12345",
		assistantphone:"12345",
		email:"Billing@Inf&ormation",
		email2:"Priv@ate",
		email3:"this@isstring",
		emaildisplayname1:"hello",
		emaildisplayname2:"hello",
		emaildisplayname3:"hello",
		department:"abc",
		businessstreet:"abc",
		businesscity:"abc",
		businessstate:"abc",
		businesscountry:"abc",
		businesspostalcode:"94306",
		homestreet:"abc",
		homecity:"abc",
		homestate:"abc",
		homecountry:"abc",
		homepostalcode:"abc",
		otherStreet:"abc",
		otherCity:"abc",
		otherState:"abc",
		otherCountry:"abc",
		otherPostalCode:"abc",
		callback:"abc",
		carphone:"abc",
		othertelephone:"abc",
		pager:"abc",
		primaryphone:"abc",
		companymainphone:"abc",
		isdn:"abc",
		radiophone:"abc",
		telex:"abc",
		ttytddphone:"abc",
		imaddress:"uuymuymm79,u5756",
		imaddress2:"abc",
		imaddress3:"abc",
		manager:"abc",
		officelocation:"abc",
		notes:"abc"
		};

	val = ExchangeUpdateContact( connection = "myconnection", inputData = contact);
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Search Task Items</h2>

<p>
	This API defines a request to find a Task Items in a mailbox.
</p>
<p>
	You can search a Task Item by simply calling the function: <strong>ExchangeSearchTasks( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing fields of Task to be searched on.
</p>
<p>
	This API will return cfData containing Information about the instances of TaskItem satisfying the search conditions.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">operator</td>
		<td valign="top">And, Or</td>
		<td valign="top">OR</td>
		<td valign="top">false</td>
		<td valign="top">Decides whether the individual results should be ANDed or ORed</td>
	</tr>
	<tr>
		<td valign="top">keywords</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the keyword to be searched on</td>
	</tr>
	<tr>
		<td valign="top">duedate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the date when a task item is due</td>
	</tr>
	<tr>
		<td valign="top">beginstartdate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the beginning start date of the Task Item to be searched on</td>
	</tr>
	<tr>
		<td valign="top">endstartdate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the end start date of the Task Item to be searched on</td>
	</tr>
	<tr>
		<td valign="top">statusNotequals</td>
		<td valign="top">Notstarted, InProgress, Completed, WaitingOnOthers, Deferred</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the status of the Task on which the search should be performed</td>
	</tr>
	<tr>
		<td valign="top">importance</td>
		<td valign="top">Low, Normal, High</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the importance of an item</td>
	</tr>
	<tr>
		<td valign="top">sensitivity</td>
		<td valign="top">Normal, Personal, Private, Confidential</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains the status for an item's sensitivity</td>
	</tr>
</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	search = {
		operator:"Or"
		keywords:"AA",
		duedate:createdatetime(year=2010, month=12, day=6, hour=00, minute=00, second=00),
		beginstartdate:createdatetime(year=2010, month=12, day=10, hour=00, minute=00, second=00),
		endstartdate:createdatetime(year=2010, month=12, day=20, hour=00, minute=00, second=00),
		statusNotequals:"Notstarted",
		importance:"High",
		sensitivity:"Private"
		};

	val = ExchangeSearchTasks( connection = "myconnection", inputData = search);
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Search contact Items</h2>

<p>
	This API defines a request to find a Contact Items in a mailbox.
</p>
<p>
	You can search a Contact Item by simply calling the function: <strong>ExchangeSearchContacts( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing fields of Contacts to be searched on.
</p>
<p>
	This API will return cfData containing Information about the instances of ContactItem satisfying the search conditions.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">searchkeyword</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the keyword to be searched on</td>
	</tr>
	<tr>
		<td valign="top">field</td>
		<td valign="top"><b>Either</b><br/>givenname,
		surname,
		subject,
		company,
		homestreet,
		homecity,
		homestate,
		homepostalcode,
		homecountry,
		businessstreet,
		businesscity,
		businessstate,
		businesspostalcode,
		businesscountry,
		fileas,
		emailaddress<br/>
		<b>Or</b><br/>
		All
		</td>
		<td valign="top">Subject</td>
		<td valign="top">false</td>
		<td valign="top">Represents the fields on which the search is to be performed</td>
	</tr>
	<tr>
		<td valign="top">searchmode</td>
		<td valign="top">FullString, Prefixed, Substring, PrefixOnWords, ExactPhrase</td>
		<td valign="top">Substring</td>
		<td valign="top">false</td>
		<td valign="top">Represents the searchmode for the search operation</td>
	</tr>
	<tr>
		<td valign="top">limit</td>
		<td valign="top"></td>
		<td valign="top">100</td>
		<td valign="top">false</td>
		<td valign="top">Represents the number of contacts that should be displayed in output</td>
	</tr>
	<tr>
		<td valign="top">offset</td>
		<td valign="top"></td>
		<td valign="top">0</td>
		<td valign="top">false</td>
		<td valign="top">Represents the offset for the search operation</td>
	</tr>
	<tr>
		<td valign="top">operator</td>
		<td valign="top">And, Or</td>
		<td valign="top">OR</td>
		<td valign="top">false</td>
		<td valign="top">Decides whether the individual results should be ANDed or ORed</td>
	</tr>
	<tr>
		<td valign="top">basepoint</td>
		<td valign="top">beginning, end</td>
		<td valign="top">beginning</td>
		<td valign="top">false</td>
		<td valign="top">Represents whether the search should start from the beginning or from the end</td>
	</tr>
	<tr>
		<td valign="top">sensitivity</td>
		<td valign="top">Normal, Personal, Private, Confidential</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains the status for an item's sensitivity</td>
	</tr>
	<tr>
		<td valign="top">importance</td>
		<td valign="top">Low, Normal, High</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the importance of an item.</td>
	</tr>
	<tr>
		<td valign="top">additionalfolders</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represent the additional folders on which the search operation is to be carried on</td>
	</tr>
</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	params = {
		searchkeyword:"x",
		field : "surname",
		searchmode:"Substring",
		limit:1,
		offset:0,
		operator:"and",
		basepoint:"eNd",
		sensitivity:"Normal",
		importance:"nOrmal",
		additionalfolders:["04MTFkLTk4NzljNzM5NDA1MQAuAAAAAAAHnh9u4S9oTLKIZo9P9ejQAQDoD/snhTOxS5DZI3hjoguSAAAGKr7mAAA="]
		};

	folders= ExchangeSearchContacts( connection = "myconnection", inputData = params );
	WriteDump( folders );


</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>


<h2>Search Calendar Items</h2>

<p>
	This API defines a request to find a Calendar Items in a mailbox.
</p>
<p>
	You can search a Calendar Item by simply calling the function: <strong>ExchangeSearchCalendarItems( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing fields of Calendar to be searched on.
</p>
<p>
	This API will return cfData containing Information about the instances of CalendarItem satisfying the search conditions.
</p>

<table>
	<tr>
		<th width = "10%"></th>
		<th width = "25%">possible values</th>
		<th width = "10%">default</th>
		<th width = "8%">required</th>
		<th>summary</th>
	</tr>
	<tr>
		<td valign="top">keywords</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the keyword to be searched on</td>
	</tr>
	<tr>
		<td valign="top">freebusystatus</td>
		<td valign="top">Free, Tentative, Busy, OOF, NoData</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the free/busy status of the calendar item</td>
	</tr>
	<tr>
		<td valign="top">operator</td>
		<td valign="top">And, Or</td>
		<td valign="top">OR</td>
		<td valign="top">false</td>
		<td valign="top">Decides whether the individual results should be ANDed or ORed</td>
	</tr>
	<tr>
		<td valign="top">importance</td>
		<td valign="top">Low, Normal, High</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Describes the importance of an item</td>
	</tr>
	<tr>
		<td valign="top">sensitivity</td>
		<td valign="top">Normal, Personal, Private, Confidential</td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Contains the status for an item's sensitivity</td>
	</tr>
	<tr>
		<td valign="top">start</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the start date of a calendar item</td>
	</tr>
	<tr>
		<td valign="top">end</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the end date of a calendar item</td>
	</tr>
	<tr>
		<td valign="top">spanstartdate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the beginning start date of the Calendar Item to be searched on</td>
	</tr>
	<tr>
		<td valign="top">spanenddate</td>
		<td valign="top"></td>
		<td valign="top"></td>
		<td valign="top">false</td>
		<td valign="top">Represents the end start date of the Calendar Item to be searched on</td>
	</tr>
</table>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	search = {
		keywords:"recurrence",
		freebusystatus:"Tentative",
		operator:"And",
		importance:"High",
		sensitivity:"Private",
		start:createdatetime(year=2010, month=12, day=6, hour=00, minute=00, second=00),
		end:createdatetime(year=2010, month=12, day=6, hour=00, minute=00, second=00),
		spanstartdate:createdatetime(year=2009, month=12, day=6, hour=00, minute=00, second=00),
		spanenddate:createdatetime(year=2011, month=12, day=6, hour=00, minute=00, second=00)
		};

	val=ExchangeSearchCalendarItems( connection = "myconnection", inputData = search );
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>



<h2>Get Contact Information</h2>

<p>
This API defines a request to get the information of a Contact Item in a mailbox.
</p>

<p>
You can get information of a Contact Item by simply calling the function: <strong>ExchangeGetContact( connection, id )</strong>,
where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>id</strong> is the unique
identifier of a contact instance.
</p>

<p>
This API will return cfData containing Information about the ContactItem whose Id matches with that given in the input.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	GetContact = ExchangeGetContact( connection = "myconnection", id = "43bAADoD/snhTOxS5DZI3hjoguSAAAGKl6AAAA=" );
	WriteDump( GetContact );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Get Task Information</h2>

<p>
This API defines a request to get the information of a Task Item in a mailbox.
</p>

<p>
You can get information of a Task Item by simply calling the function: <strong>ExchangeGetTask( connection, id )</strong>,
where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>id</strong> is the unique
identifier of a task instance.
</p>

<p>
This API will return cfData containing Information about the TaskItem whose Id matches with that given in the input.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	GetTask = ExchangeGetTask( connection = "myconnection", id = "snhTOxS5DZI3hjoguSAAAA/43fAADoD/snhTOxS5DZI3hjoguSAAAGKfkSAAA=" );
	WriteDump( GetTask );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Get CalendarItem Information</h2>

<p>
This API defines a request to get the information of a Calendar Item in a mailbox.
</p>

<p>
You can get information of a Calendar Item by simply calling the function: <strong>ExchangeGetCalendarItem( connection, id )</strong>,
where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>id</strong> is the unique
identifier of a calendar item.
</p>

<p>
This API will return cfData containing Information about the CalendarItem whose Id matches with that given in the input.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	GetCalendarItem = ExchangeGetCalendarItem( connection = "myconnection", id = "43aAADoD/snhTOxS5DZI3hjoguSAAAGKhkmAAA=" );
	WriteDump( GetCalendarItem );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>


<h2>Get All Contacts</h2>

<p>
This API defines a request to get the information of all Contact Items in a mailbox.
</p>

<p>
You can get information of all the Contact Items by simply calling the function: <strong>ExchangeGetAllContacts( connection )</strong>,
where <strong>connection</strong> is a connection object to communicate with Exchange server.
</p>

<p>
This API will return cfData containing Information of all Contact Items in a mailbox.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	GetAllContacts = ExchangeGetAllContacts( connection = "myconnection" );
	WriteDump( GetAllContacts );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>


<h2>Get All Tasks</h2>

<p>
This API defines a request to get the information of all Task Items in a mailbox.
</p>

<p>
You can get information of all the Task Items by simply calling the function: <strong>ExchangeGetAllTasks( connection )</strong>,
where <strong>connection</strong> is a connection object to communicate with Exchange server.
</p>

<p>
This API will return cfData containing Information of all Task Items in a mailbox.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	GetAllTasks = ExchangeGetAllTasks( connection = "myconnection" );
	WriteDump( GetAllTasks );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Get All CalendarItems </h2>

<p>
This API defines a request to get the information of all Calendar Items in a mailbox.
</p>

<p>
You can get information of all the Calendar Items by simply calling the function: <strong>ExchangeGetAllCalendarItems( connection )</strong>,
where <strong>connection</strong> is a connection object to communicate with Exchange server.
</p>

<p>
This API will return cfData containing Information of all Calendar Items in a mailbox.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	GetAllCalendarItems = ExchangeGetAllCalendarItems( connection = "myconnection" );
	WriteDump( GetAllCalendarItems );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Finding Folders</h2>

<p>
	This API defines a request to find folders in a mailbox.
</p>
<p>
	You can use API by simply calling the function: <strong>ExchangeFindFolders( connection, parentfolder )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>parentfolder</strong> is string containing one of these values <strong>calendar, contacts, deleteditems, drafts, inbox, journal, notes, outbox, sentitems, tasks, msgfolderroot, root, junkemail, searchfolders, voicemail</strong>.
</p>
<p>
	This API will return cfData containing an Array of folder Ids.
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	val = ExchangeFindFolders( connection = "myconnection", parentfolder = "msgfolderroot" );
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

<h2>Delete Task Items</h2>

<p>
	This API defines a request to delete a Task items from a mailbox in the Exchange store.
</p>
<p>
	You can delete a Task Item by simply calling the function: <strong>ExchangeDeleteTask( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing id and AffectedTaskOccurrences value.
</p>
<p>
	This API will return TRUE( cfBooleanData) in case the deletion is successful else the Error Message Text( cfData).
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	params= {
		Id:"snhTOxS5DZI3hjoguSAAAA/43fAADoD/snhTOxS5DZI3hjoguSAAAGKfkQAAA=",
		AffectedTaskOccurrences:"SpecifiedOccurrenceOnly"
	  	};

	val = ExchangeDeleteTask( connection = "myconnection", inputData = params );
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>


<h2>Delete Calendar Items</h2>

<p>
	This API defines a request to delete a <strong>Calendar</strong> items from a mailbox in the Exchange store.
</p>
<p>
	You can delete a Calendar Item by simply calling the function: <strong>ExchangeDeleteCalendarItem( connection, inputData )</strong>,
	where <strong>connection</strong> is a connection object to communicate with Exchange server and <strong>inputData</strong> is structure containing Different Id's and SendMeetingCancellations value.
</p>
<p>
	This API will return TRUE( cfBooleanData) in case the deletion is successful else the Error Message Text( cfData).
</p>

<h3>Example</h3>
<cfsavecontent variable="cfml"><nocfml>
<cfscript>

	params= {
		Id:"snhTOxS5DZI3hjoguSAAAA/43fAADoD/snhTOxS5DZI3hjoguSAAAGKfkQAAA=",
		SendMeetingCancellations:"SendToNone"
	  	};

	val = ExchangeDeleteCalendarItem( connection = "myconnection", inputData = params );
	WriteDump( val );

</cfscript>
</nocfml></cfsavecontent>
<pre class="cfml">
<cfoutput>#XmlFormat( Trim( cfml ) )#</cfoutput>
</pre>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->