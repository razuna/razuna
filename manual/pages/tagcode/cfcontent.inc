<p>
This tag allows you to stream remote content straight to the client without first buffering or saving it locally.  Particularly useful when you are proxying internal content to the outside world, or if you wish to protect resources
using a custom security model.
</p>

<p>
Note this technique uses very little memory, as the content is streamed in realtime from the remote resource straight to the client.
</p>

<p>
There are two supported remote types:
<ul>
	<li>type : "http"
	<li>type : "s3"
</ul>
</p>

<h3>type : "http"</h3>

<p>
To proxy a remote URL, then set the type to "http" and pass in the remote URL.  The ContentType of the remote resource will be sent to the client.
</p>

<pre class="cfml">
&lt;cfset remote={
  type : "http",
  url : "http://openbd.org/manual/images/logo.png"
} /&gt;

&lt;cfcontent remote="#remote#" /&gt;
</pre>

<h3>type : "s3"</h3>

<p>
You can proxy a remote Amazon S3 resource, by setting type to "s3".  The Amazon datasource must be pre-registered and then you set at least the bucket and the key of the remote object.   You can optionally set the aes256key encryption key that the original file was uploaded to.
</p>

<pre class="cfml">
&lt;cfset remote={
  type : "s3",
  datasource : "amz",
  bucket : "your-bucket",
  key : "a/b/c/yourkey.jpg",
	aes256key : "optional"
} /&gt;

&lt;cfcontent remote="#remote#" /&gt;
</pre>