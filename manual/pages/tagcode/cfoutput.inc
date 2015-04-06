<p>
	OpenBD also has a shorthand notation for <strong>CFOUTPUT</strong> in the form of <code><%= %></code>
</p>

<p>
	By default this shorthand <strong>CFOUTPUT</strong> is turned off, and you will need to enable it using the
	<strong>cfoutputshorthand</strong> setting in your	bluedragon.xml file.
</p>

<p>
	Add the follow setting in the server.system block within your bluedragon.xml file.
</p>
<p>
	<code><cfoutputshorthand>true</cfoutputshorthand></code>
</p>

<h3>Example</h3>

<pre class="cfml">

&lt;html>
 &lt;body>
  &lt;h1>My First CFML Page&lt;/h1>

  &lt;ul>
   &lt;cfloop index="x" from="1" to="10">
    &lt;li>&lt;%=#x#%>&lt;/li>
   &lt;/cfloop>
  &lt;/ul>

 &lt;/body>
&lt;/html>

</pre>



