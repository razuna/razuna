<pre class="cfml"><nocfml><cfset im = ImageRead( ExpandPath("/image/mylogo.jpg") )>
&lt;img src="<cfoutput>#ToDataURI( im, "image/jpg" )#</cfoutput>" />
</nocfml></pre>

<p style="font-size:85%; margin: 10px;">The data URI scheme is a URI scheme that
provides a way to include data in-line in web pages as if they were external resources.

HTTP request and header traffic is not required for embedded data, so data URIs consume
less bandwidth whenever the overhead of encoding the inline content as a data URI is
smaller than the HTTP overhead. For example, the required base64 encoding for an image
600 bytes long would be 800 bytes,  so if an HTTP request required more than 200 bytes of
overhead, the data URI would be more efficient.

<a href="http://en.wikipedia.org/wiki/Data_URI_scheme">More information on the DataURI</a>
</p>

