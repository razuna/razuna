<p>
An example of using CFHEADER to disable the browser from caching the page.
</p>

<pre class="cfml">
<cfheader name="Cache-Control" value="no-cache,no-store,must-revalidate">
<cfheader name="Pragma" value="no-cache">
<cfheader name="Expires" value="Tues, 13 Sep 2011 00:00:00 GMT">
</pre>