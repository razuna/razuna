<h3>Foreign chars handing and cfexecute</h3>
<p>Please note that the cfexecute tag reads the output using the InputStreamReader but it doesn't specify a charset so defaults to the platform default.</p>
<p>You can get the platform default with:</p>
<pre class="cfml">
<cfoutput>#createObject( "java", "java.lang.System" ).getProperty( "file.encoding" )#</cfoutput>
</pre>
