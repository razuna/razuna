<p>
This tag creates Javascript proxy objects to your server side CFC components.   This makes calling remote CFC from Javascript extremely easy and straight forward.
The Javascript produced by this tag is completely independent of any client side library and can safely be used along side the likes of JQuery and YUI.
</p>

<pre class="cfml">
<cfajaxproxy cfc="mycfc" jsclassname="jsmycfc">

&lt;script>
// Using Synchronized callback
getUserRecord = function( id ) {
  var jsmycfcInst = new jsmycfc();
	jsmycfcInst.setSyncMode();
	return jsmycfcInst.getUserRecord(id);
};

// Using ASynchronized callback
callbackMethod = function( result ){

};

getUserRecordAsync = function( id ) {
  var jsmycfcInst = new jsmycfc();
	jsmycfcInst.setCallbackHandler( callbackMethod );
	jsmycfcInst.getUserRecord(id);
};

setUserRecordAsync = function() {
  var jsmycfcInst = new jsmycfc();
	jsmycfcInst.setCallbackHandler( callbackMethod );
	jsmycfcInst.setUserRecord( { name:"Susan", age : 21, address : {street1: "House 1", street2: "Glebe Av.", town: "Glasgow" } }  );
};
&lt;/script>
</pre>

<p>
The following CFC would be a sample content for jsmycfc
</p>

<pre class="cfml">
<cfcomponent public="yes" output="false">

	<cffunction name="getUserRecord" access="remote" returntype="structure">
		<cfreturn {id:1, name:"susan"}>
	</cffunction>

	<cffunction name="setUserRecord" access="remote" returntype="boolean">
		<cfargument name="user" type="struct" required="true" />
		<!--- do something with this record --->
		<cfreturn true>
	</cffunction>

</cfcomponent>
</pre>

<p>
There are a number of helper methods that come with each proxied object created.
</p>

<table>
	<thead>
		<tr>
			<th>Method Name</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody
		<tr>
			<td>setCallbackHandler</td>
			<td>Takes in the Javascript function reference that will receive the callback upon completion of the result</td>
		</tr>
		<tr>
			<td>setErrorHandler</td>
			<td>Takes in the Javascript function reference that will be called should an error occur</td>
		</tr>
		<tr>
			<td>setAsyncMode</td>
			<td>Sets the mode of network operation to be asynchronized.   If you are expecting a result back then you should use a callback handler, otherwise you can fire'n'forget</td>
		</tr>
		<tr>
			<td>setSyncMode</td>
			<td>Sets the mode of network operation to be synchronized. This means the page will wait until the server responds with the result</td>
		</tr>
		<tr>
			<td>setForm</td>
			<td>The ID of the FORM that the library will automatically pull together all the values of the HTML form and post that to the server end point</td>
		</tr>
		<tr>
			<td>setHTTPMethod</td>
			<td>The type of method that will be used.  Defaults to GET but can be POST.  There will always be an anti-cache busting token added to each request to prevent browser caching</td>
		</tr>
	</tbody>
</table>
