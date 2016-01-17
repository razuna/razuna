<p>
The SocketConnect() function enables you to interact with remote socket based methods.   The SocketData that is returned from the SocketConnect() is a rich object that
lets you interact with the remote server.  The following methods are available from the SocketData object:
</p>

<table style="margin-top: 20px;">
<tr>
	<td valign="top"><span class="paramDetail">.disconnect()</span></td>
	<td valign="top">disconnects the remote server.  Once disconnected you won't be able to further interact with the server</td>
</tr>
<tr>
	<td valign="top"><span class="paramDetail">.sendLine( string )</span></td>
	<td valign="top">sends the string, followed by a carriage-return/newline, to the remote server</td>
</tr>
<tr>
	<td valign="top"><span class="paramDetail">.sendString( string )</span></td>
	<td valign="top">sends the string to the remote server</td>
</tr>
<tr>
	<td valign="top"><span class="paramDetail">.sendString( string )</span></td>
	<td valign="top">sends the string to the remote server</td>
</tr>
<tr>
	<td valign="top"><span class="paramDetail">.sendBinaryData( binarydata )</span></td>
	<td valign="top">sends the binary data to the remote server</td>
</tr>
<tr>
	<td valign="top"><span class="paramDetail">.readLine( timeoutms )</span></td>
	<td valign="top">reads a line from the remote server, waiting for at least the timeoutms milliseconds.  It will read up to the carriage-return/newline, but will not include them.</td>
</tr>
<tr>
	<td valign="top" nowrap><span class="paramDetail">.readBytes( maxbytes, timeoutms )</span></td>
	<td valign="top">reads the number of given bytes from the remote server, waiting for at least timeoutms milliseconds.  This will be a binary data that is returned.</td>
</tr>
</table>

<p>
In addition to the above methods, you can also get at meta-information about the connection.  'localip', 'remoteip' and 'connected' all convey the state of the connection.
</p>

<p>
Here are some examples of using the function.
</p>

<pre>
<cfscript>
// Example connecting to a remote WEB server and doing a remote HEAD
var socket	= SocketConnect("www.bing.com", 80);

socket.sendLine( "HEAD / HTTP/1.1" );
socket.sendLine( "host: www.bing.com" );
socket.sendLine( "" );

var line	= socket.readLine( 30000 );
while ( line != null ){
	line	= socket.readLine( 30000 );
}

socket.disconnect();
</cfscript>
</pre>

<p>
This example shows how you can download binary data.
</p>

<pre>
<cfscript>
// Example connecting to a remote WEB server and downloading the logo
var socket	= SocketConnect("openbd.org", 80);

// Write out the HTTP header
socket.sendLine( "GET /manual/sd_openBD_32.png HTTP/1.1" );
socket.sendLine( "host: openbd.org" );
socket.sendLine( "" );

// Read the header
var line	= socket.readLine( 30000 );
while ( line != "" ){
	line	= socket.readLine( 30000 );
}

// Read the bytes
FileDelete(ExpandPath("./logo.png"));

var bufferSize	= 4096;
var bindata	= socket.readBytes( bufferSize, 500 );

while ( Len(bindata) > 0 ){
	FileWrite( ExpandPath("./logo.png"), bindata );
	if ( Len(bindata) < bufferSize )
		break;

	bindata	= socket.readBytes( bufferSize, 500 );
}

socket.disconnect();
</cfscript>
</pre>