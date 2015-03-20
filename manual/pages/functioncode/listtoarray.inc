<p>
	Take a list element and convert it to an array based on delimiter
</p>

<pre class="cfml">
<cfscript>
// Store the Query_String string from the CGI scope to a variable named page
// For this page - cgi.QUERY_STRING = "function/listtoarray"
var page = cgi.QUERY_STRING;

// now turn the query string into an Array using / as our delimter
var qs = listToArray( pageName, "/" );

// We now have an array named qs with two elements in
writeOutput( request.params[1] ); // would output "function"
writeOutput( request.params[2] ); // would output "listtoarray"

</cfscript>
</pre>