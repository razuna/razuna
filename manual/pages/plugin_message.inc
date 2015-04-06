<cfset request.page.section = "plugins">
<cfset request.page.title = "Message Plugin">
<cfset request.page.desc	= "Message plugin brings the power of messaging to the CFML world">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/plugin">Plugins</a></li>
      <li class="active"><a href="./?/plugin_message"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Message Plugin</h1>
		
		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">
<p>
Messaging within or between applications is a powerful way to communicate and to keep all components of your enterprise in sync with one another.  For example
you may wish to alert all areas of your application that some data has changed so if they are holding any caches they can flush or renew it.   Another example
could be to broadcast certain business logic states.  For example when someone logs in, another process sends out a welcome email.  That process may exist in
the same OpenBD application or in another separate instance.
</p>

<p>
By building such functionality as a messaging system, you break away from the sequential processing and the need for every component to explicitly know about
each other.   It is the perfect way to build and maintain truly scalable systems in a service orientated manner without worrying where everything physically
resides.
</p>

<p>
This plugin allows hooks the CFML world into this very powerful platform, by utilising the popular Java Messaging Service (JMS) as its hooks.   This plugin
contains a full ActiveMQ installation, permitting OpenBD to either act as a JMS server or to easily hook into an existing external one.   Even if you use this
in a complete standalone fashion, this provides a fast and easy way to manage the popular Design Pattern of listeners and callbacks.
</p>

<p>
Messaging is built around the notion of topics.  You create a topic with a messaging server that is used to manage messages.   Messages can then be delivered
to a topic and any person listening to that topic will receive that message, in as quick a time as possible.   Topic's live within a server's domain and
it is the servers security model that determines which clients can listen to them.
</p>

<p>
This plugin wraps up all the complexity associated with interacting with message queues using a small set of functions:
</p>

<ul>
	<li>MessageServerRegister()</li>
	<li>MessageServerStop()</li>
	<li>MessageSendTopic()</li>
	<li>MessageTopicListener()</li>
	<li>MessageRemoveTopicListener()</li>
</ul>

<h2>Creating a Server Source</h2>

<p>
Talking with a JMS Server is performed through a MessageServerSource and can be thought of in much the same way as you use a datasource to talk to databases.
You create a new source by simply calling the function: <strong>MessageServerRegister( "symbolicname" [,"jms connection url"] )</strong>.
</p>

<p>
This will then create a new MessageSource that you can use with the other messaging functions.  If you do not specify a connection string, then a local internal
JMS server will be created that can be used.  It uses a standard JMS/ActiveMQ connection string format.   If you have already created this server, then an exception will be thrown.
</p>

<p>
Once completed, you can shutdown the server using the function: <strong>MessageServerStop( "messagesource" )</strong>.   If the server is local, then it will be shutdown.
If the server is a remote one, then the data source will be de-registered and any existing listeners on the OpenBD will be cancelled.
</p>

<p>
This plugin will manage the reconnect procedure automatically for you if a remote server drops out for a period of time due.
</p>

<h2>Sending a message to a topic</h2>

<p>
Once you have a messagesource, you can easily send messages to any topic.   A topic does not need to be pre-registered.  If it doesn't already exist on the server
then it will be created on the fly.
</p>

<p>
There are basically two types of message you can send to a topic; a simple text based one, or a Map, which is a key/data value.  Any other type you want to broadcast,
then encode it to XML or JSON before hand and send it as a text string.
</p>

<p>
You use the function: <strong>MessageSendTopic( "messagesource", "topic", userdata )</strong> that will send the message to the server immediately.   If the server is not
available then an exception will be thrown.   If userdata is a simple type (boolean, date, string, number) then it will be sent as a text message.  If the userdata is a
structure then it will be sent as a Map; everything else will throw an error.
</p>


<h2>Receiving messages from a topic</h2>

<p>
Receiving message from a topic is done using a CFC with the <strong>onMessage( message, header )</strong> method defined.   For each message that comes in, this CFC
is created and the method is called.  The message will contain the message that was sent, and the header is a structure with a number of keys (id, topic, timestamp, expiration, delivery, replyto)
that describes the metadata for the message.
</p>

<p>
You can setup a message receiver using the function <strong>MessageTopicListener( "messagesource", "topic", cfc )</strong>.  You can define the CFC as either a live object, or a string
describing the location of where to load the CFC.
</p>

<p>
Once registered you do not have to worry about server disconnects.  The plugin will automatically reconnect and deliver messages to your CFC as and when they come.
</p>

<p>
To stop receiving messages you can call: <strong>MessageRemoveTopicListener( "messagesource", "topic", cfc )</strong> and no more messages will be received.
</p>

<h2>Log files</h2>

<p>
All activity on the JMS message bus is logged to a file within the working directory of OpenBD.  The file /cflog/plugin-message.log will rotate at 25MB and contains
all notes of any messages coming in and if they were processed by a CFC and the time it took.  Any errors that are produced are automatically logged to the standard
OpenBD error folder.
</p>


<p><a class="btn dload" href="http://openbd.org/downloads/" title="http://openbd.org/downloads/" rel="nofollow">download the plugin</a></p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->