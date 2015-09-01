<h3>Handling foreign chars in variable</h3>
<p>When you are dealing with data coming from cfexecute and you need to parse it with xmlparse() it could be that your data is not in the format you expect it, e.g "utf-8".</p>
<p>The cfexecute tag reads the output from the exiftool using the InputStreamReader but it doesn't specify a charset so defaults to the platform default. Hence we have to get the original bytes and treat it as utf-8. The below code will give you a a xml variable in utf-8 format:</p>
<pre class="cfml">
<cfset myxml = xmlparse( ToString( yourdata.getBytes(), 'utf-8' ) )>
</pre>
