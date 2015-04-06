<p>
The functions, <a href="./?/function/SocketServerStart">SocketServerStart()</a>, <a href="./?/function/SocketServerStop">SocketServerStop()</a> and
<a href="./?/function/SocketServerGetClients">SocketServerGetClients()</a>, are for writing server applications that operate on custom protocols.
</p>

<p>
The following example shows how you can create a simple server application that will echo back the input received.
</p>

<pre class="cfml">
<cfset SocketServerStart( port=2001, cfc="openbdtest.functions.socket.clientcfc" )>
</pre>

<p>
This starts the server running listening on port 2001 and echoes back any line received.  The CFC will be created for each new connection, that has the following methods:
</p>

<pre class="cfml">
<cfcomponent>

<cffunction name="onConnect">
	<cfargument name="socketdata" required="true" />
	<cfset Console( "onConnect" ) >
	<cfset arguments.socketdata.sendLine("Welcome: " & arguments.socketdata.remoteip )>
</cffunction>

<cffunction name="onDisconnect">
	<cfargument name="socketdata" required="true" />
	<cfset Console( "onDisconnect" )>
</cffunction>

<cffunction name="onReadLine">
	<cfargument name="socketdata" required="true" />
	<cfargument name="line" required="true" />
	<cfset arguments.socketdata.sendLine("Rxd:" & arguments.line)>
</cffunction>

</cfcomponent>
</pre>

<p>
Within the CFC there are 3 main events that can be overridden: onConnect(), onDisconnect() and onReadLine().   The onConnect() will be called when a client first connects
and the details about that client will be available in the 'arguments.socketdata' method (see <a href="./?/function/SocketConnect">SocketConnect()</a> for more details).
</p>

<p>
The CFC that is created for this client is a persisted one.  In other words, you can set object level variables that will be retained throughout the life of the connected client.
</p>

<p>
If the server was started within the confines of a CFML application then the application scope will be available inside the CFC call as you are processing the connected client.
</p>

<p>
When a line is received by the server, the onReadLine() method is called with the line that was received.
</p>

<p>
You can persist the SocketData in the class if you wish, they are merely passed into each function as convienance.
</p>