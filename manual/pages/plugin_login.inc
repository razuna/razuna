<cfset request.page.section = "plugins">
<cfset request.page.title = "Login Extension">
<cfset request.page.desc	= "Login Extension lets you hook CFML into external authenication systems such as Microsoft Windows Active Directory">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/plugin">Plugins</a></li>
      <li class="active"><a href="./?/plugin_login"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Login Extension</h1>

		<cfinclude template="pages/sidebar_plugin.inc" />
		
		<div class="section">
		
<p>
It is very common to have the need to authenticate users to your parts of your CFML application.  One of the areas that security auditors often
look for is who touches the username/password combination as it flows through the various applications.  Within the web world,  it is common for
the web server to handle this, prompting the user with a browser login panel.  However has gone out of vogue as it offers the designer no
styling opportunity or enhanced user experience.
</p>

<p>
The problem however of putting a login panel on a page is that the developer has the opportunity to capture the username/password as it flows through
their application.   This problem does not exist if you utilise web server authentication techniques, as by the time the request gets to the application,
it is unaware of any sensitive data.
</p>

<p>
The OpenBD Login Extension looks to solve this problem by removing the security call away from the developer and delegating it to the underlying OpenBD
engine without them ever getting access to the sensitive data.   This is achieved by the engine looking for a combination of a couple of FORM fields
and once detected, will attempt to authenticate the user and zero/blank out the password field.  So by the time it reaches the CFML page, all the sensitive
data has been removed and you are left with a token detailing success or failure.
</p>

<p>
You can utilize this extension to authenticate users against remote LDAP servers or Microsoft Active Directory servers.
</p>

<h2>Configuration</h2>

<p>
To enable this extension, you must edit your OpenBD bluedragon.xml file and add this block of XML inside the &lt;server> ... &lt;server/> tags.
This determines how the CFML application will interact with the login extension.   There are 4 elements that are required.
</p>

<p>
<ul>
	<li><code>returnfield</code>
	<br/>
	This is the name of the FORM field that will be created that will contain the result of the login attempt.  If it starts with "[exception]" or "[failed]" then it has
	failed to login and this will contain the error message from the LDAP server.  Otherwise it will contain the user token from the LDAP server to note this user has been
	authenticated.
	</li>
	<li><code>userfield</code>
	<br/>
	This is the name of the FORM field that will contain the username.  The extension will automatically listen to all POST requests for this variable.
	</li>
	<li><code>passwordfield</code>
	<br/>
	This is the name of the FORM field that will contain the password.  The extension will automatically listen to all POST requests for this variable.   If it see's this
	field along with the 'userfield' then it will be read by the extension and subsequently blanked out with ****** so the CFML developer does not see the password.
	</li>
	<li><code>ini</code>
	<br/>
	The full path name of the configuration connector file for this extension.  Any changes in this file will require a restart of the engine.
	</li>
</ul>
</p>

<p>
Sample bluedragon.xml snippet
</p>

<pre>
&lt;plugin>
  &lt;login>
    &lt;returnfield>_loggedin&lt;/returnfield>
    &lt;passwordfield>_password&lt;/passwordfield>
    &lt;ini>/opt/login/ldap.ini&lt;/ini>
    &lt;userfield>_username&lt;/userfield>
  &lt;/login>
 &lt;/plugin>
</pre>

<p>This example would look for the FORM fields, <code>_username</code> and <code>_password</code> in any FORM submissions, placing the result in <code>_loggedin</code> form field.
If you were to do a <code>&lt;cfdump var="#form#"></code> you would see these fields, with the <code>_password</code> starred out.</p>

<p>The following is a sample login.ini file that will authenticate against an LDAP server (Microsoft Active Directory).</p>

<pre>
[main]
ldapRealm = org.apache.shiro.realm.ldap.JndiLdapRealm
ldapRealm.userDnTemplate = {0}@MYDOMAIN.COM
ldapRealm.contextFactory.url = ldap://10.0.0.1:389
</pre>

<p>
This extension will log all attempts for login to the main bluedragon.log file.  No sensitive data is logged there.   Common problems include:
</p>

<p>
<ul>
	<li>Make sure the server can connect to the remote server.  ping/telnet to the given port to determine this</li>
	<li>The DN template can be specific to your LDAP/Windows server.  Try playing around with various combinations if the default one shown does not work<br/><strong>ldapRealm.userDnTemplate = uid={0},ou=users,dc=mycompany,dc=com</strong></li>
	<li>Make sure you are consistent to how you ask your users to login.  Is the username "lewis" or "lewis@mydomain.com".  This will be dependent on your LDAP and DN template</li>
</ul>
</p>

<h2>More information</h2>

<p>
This extension utilises the secure library from <a href="http://shiro.apache.org/">Apache Shiro</a> project.  For more information on configuration options please refer to
<a href="http://shiro.apache.org/static/current/apidocs/org/apache/shiro/realm/ldap/JndiLdapRealm.html">http://shiro.apache.org/static/current/apidocs/org/apache/shiro/realm/ldap/JndiLdapRealm.html</a>
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->