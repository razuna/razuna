<p>
Using the callback feature lets you get a handle on when email gets delivered successfully or if it fails.
</p>

<pre class="cfml">
<cfmail to="alan@fail.com" from="info@alan.com" subject="this is a subject" callback="mycallback">
  My Test Email
</cfmail>
</pre>

<p>Create a CFC called 'mycallback'.   Within this callback, you do not have access to the 'form', 'url' or 'cgi' scopes, but you do have 'application'.</p>

<pre class="cfml">
<cfcomponent>

<cffunction name="onMailSend">
  <cfargument name="to" type="array"/>
  <cfargument name="from" />
  <cfargument name="subject" />
  <cfargument name="messageid" />
  <cfargument name="mailserver" />
  <cfargument name="customdata" />
</cffunction>


<cffunction name="onMailFail">
  <cfargument name="to" type="array" />
  <cfargument name="from" />
  <cfargument name="subject" />
  <cfargument name="messageid" />
  <cfargument name="mailserver" />
  <cfargument name="customdata" />
  <cfargument name="error" />
  <cfargument name="file" hint="full path to the failed file" />

</cffunction>

</cfcomponent>
</pre>

<p>
For more information on the sending features of OpenBD please refer to the <a href="./?/engine_cfmail">OpenBD Engine Mail</a> page.
</p>

<p><b>Using CFMAIL with Google Mail (GMail)</b></p>

<pre class="cfml">
<cfmail to="tosomeone@mail.com"
        from="yourmail@gmail.com"
        subject="test"
        server="smtp.gmail.com" useSSL="true" port="465"
        username="yourmail@gmail.com" password="yourgmailpassword">
Test
</cfmail>
</pre>