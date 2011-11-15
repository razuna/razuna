<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    David C. Epler - dcepler@dcepler.net
    Matt Woodward - matt@mattwoodward.com
    Jordan Michaels - jordan@viviotech.net

    This file is part of the Open BlueDragon Admin API.

    The Open BlueDragon Admin API is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Admin API is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Admin API.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfcomponent displayname="Mail" 
	     output="false" 
	     extends="Base" 
	     hint="Manages mail settings - OpenBD Admin API">

  <cffunction name="getMailSettings" access="public" output="false" returntype="struct" 
	      hint="Returns a struct containing the mail settings">
    <cfset var localConfig = getConfig() />
    <cfset var doSetConfig = false />

    <cfset checkLoginStatus() />
    
    <!--- some of the mail settings may not exist --->
    <cfif !StructKeyExists(localConfig.cfmail, "charset")>
      <cfset localConfig.cfmail.charset = getDefaultCharset() />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "interval")>
      <cfset localConfig.cfmail.interval = "240" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "threads")>
      <cfset localConfig.cfmail.threads = "1" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "timeout")>
      <cfset localConfig.cfmail.timeout = "60" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "domain")>
      <cfset localConfig.cfmail.domain = "" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "usessl")>
      <cfset localConfig.cfmail.usessl = "false" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "usetls")>
      <cfset localConfig.cfmail.usetls = "false" />
      <cfset doSetConfig = true />
    </cfif>

    <cfif !StructKeyExists(localConfig.cfmail, "catchemail")>
      <cfset localConfig.cfmail.catchemail = "" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif doSetConfig>
      <cfset setConfig(localConfig) />
    </cfif>
    
    <cfreturn localConfig.cfmail />
  </cffunction>
  
  <cffunction name="setMailSettings" access="public" output="false" returntype="void" 
	      hint="Saves mail settings">
    <cfargument name="timeout" type="numeric" required="true" hint="The connection timeout in seconds" />
    <cfargument name="threads" type="numeric" required="true" hint="The number of threads to be used by cfmail" />
    <cfargument name="interval" type="numeric" required="true" hint="The spool polling interval in seconds" />
    <cfargument name="charset" type="string" required="true" hint="The default charset used by cfmail" />
    <cfargument name="domain" type="string" required="true" hint="The default domain used by cfmail" />
    <cfargument name="usessl" type="boolean" required="true" hint="Boolean indicating whether or not to use SSL" />
    <cfargument name="usetls" type="boolean" required="true" hint="Boolean indicating whether or not to use TLS" />
    <cfargument name="catchemail" type="string" required="true" hint="Email address to which to send ALL outgoing mail" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    
    <cfset localConfig.cfmail.timeout = ToString(arguments.timeout) />
    <cfset localConfig.cfmail.threads = ToString(arguments.threads) />
    <cfset localConfig.cfmail.interval = ToString(arguments.interval) />
    <cfset localConfig.cfmail.charset = arguments.charset />
    <!--- It appears that OpenBD ignores the default domain if a zero-length string (may need to check) --->
    <cfset localConfig.cfmail.domain = arguments.domain />
    <cfset localConfig.cfmail.usessl = ToString(arguments.usessl) />
    <cfset localConfig.cfmail.usetls = ToString(arguments.usetls) />
    <cfset localConfig.cfmail.catchemail = arguments.catchemail />

    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="getMailServers" access="public" output="false" returntype="array" 
	      hint="Returns specific mail server information or all the registered mail servers">
    <cfargument name="mailServer" type="string" required="false" default="" hint="The mail server to retrieve" />
    
    <cfset var mailServers = [] />
    <cfset var mailServerList = "" />
    <cfset var theMailServer = "" />
    <cfset var returnMailServer = {} />
    <cfset var tempMailServer = {} />
    <cfset var localConfig = getConfig() />
    <cfset var doSetConfig = false />
    <cfset var i = 0 />
    <cfset var mailServerString = "" />
    <cfset var numcolons = "" />
    <cfset var numats = "" />

    <cfset checkLoginStatus() />

    <!--- some of the mail settings may not exist --->
    <cfif !StructKeyExists(localConfig.cfmail, "threads")>
      <cfset localConfig.cfmail.threads = "1" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "charset")>
      <cfset localConfig.cfmail.charset = getDefaultCharset() />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "timeout")>
      <cfset localConfig.cfmail.timeout = "60" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif doSetConfig>
      <cfset setConfig(localConfig) />
    </cfif>
    
    <cfset mailServerList = localConfig.cfmail.smtpserver />
    
    <cfloop index="i" from="1" to="#ListLen(mailServerList)#">
      <cfset tempMailServer = {} />
      <cfset theMailServer = ListGetAt(mailServerList, i) />
      
      <cfif i == 1>
	<cfset tempMailServer.isPrimary = true />
	<cfelse>
	  <cfset tempMailServer.isPrimary = false />
      </cfif>
      
      <cfset tempMailServer.username = "" />
      <cfset tempMailServer.password = "" />
      
      <!---
	  Start out by seeing how many colons we're dealing with. This will give us an idea of what data we'll be
	  working with. We'll be working with the string from right to left.
	  0 = Server Only
	  >=1 = we have to check
      --->
      <cfset mailServerString = theMailServer />
      <cfset numcolons = ListLen(mailServerString, ":") />
      <cfif numcolons gt 0>
	<!--- If we're dealing with colons we have to do some variable hunting --->
	<!--- Check to see if the last variable is numeric. Yes = port, No = Server --->
	<cfif IsNumeric(ListLast(mailServerString, ":"))>
	  <cfset tempMailServer.smtpport = ListLast(mailServerString, ":") />
	  <!--- drop the port from the string --->
	  <cfset mailServerString = Left(mailServerString, (Len(mailServerString) - (Len(ListLast(mailServerString, ":")) + 1))) />
	</cfif>
	<!--- From here, we know that the last variable is the server, so let's see if we have anything in addition to the server --->
	<cfset numats = ListLen(mailServerString, "@") />
	<cfif numats gt 1>
	  <!--- if we have an at symbol, then we know we have user information of some sort --->
	  <cfset tempMailServer.smtpserver = ListLast(mailServerString, "@") />
	  <!--- now drop the server info so all we have is user data --->
	  <cfset mailServerString = Left(mailServerString, (Len(mailServerString) - (Len(ListLast(mailServerString, "@")) + 1))) />
	  <!--- assume that if a user name is specified, a colon is too --->
	  <cfif Right(mailServerString, 1) == ":">
	    <!--- if the password field is blank --->
	    <cfset tempMailServer.username = ListFirst(mailServerString, ":") />
	    <cfset tempMailServer.password = "" />
	    <cfelse>
	      <cfset tempMailServer.username = ListFirst(mailServerString, ":") />
	      <cfset tempMailServer.password = ListLast(mailServerString, ":") />
	  </cfif>
	  <cfelse>
	    <!--- if there is no at symbol, then we're done. --->
	    <cfset tempMailServer.smtpserver = mailServerString />
	</cfif>
	<cfelse>
	  <!--- If we're not dealing with colons, just the server name was specified --->
	  <cfset tempMailServer.smtpserver = theMailServer />
      </cfif>
      <cfset ArrayAppend(mailServers, tempMailServer) />
      
      <cfif arguments.mailServer != "" && FindNoCase(arguments.mailServer, theMailServer) gt 0>
	<cfset returnMailServer = tempMailServer />
      </cfif>
    </cfloop>
    
    <cfif arguments.mailServer != "" && !StructIsEmpty(returnMailServer)>
      <cfset mailServers = [] />
      <cfset mailServers[1] = returnMailServer />
      <cfelseif arguments.mailServer != "" && (!IsStruct(returnMailServer) || StructIsEmpty(returnMailServer))>
	<cfthrow message="Could not retrieve the mail server information" type="bluedragon.adminapi.mail" />
    </cfif>
    
    <cfreturn mailServers />
  </cffunction>

  <cffunction name="setMailServer" access="public" output="false" returntype="void" 
	      hint="Creates or updates a mail server">
    <cfargument name="smtpserver" type="string" required="true" hint="The SMTP server DNS name or IP address" />
    <cfargument name="smtpport" type="numeric" required="false" hint="The SMTP port" />
    <cfargument name="username" type="string" required="false" default="" hint="The SMTP server user name" />
    <cfargument name="password" type="string" required="false" default="" hint="The SMTP server password" />
    <cfargument name="isPrimary" type="boolean" required="false" default="true" 
		hint="Boolean indicating whether or not this is the primary mail server" />
    <cfargument name="testConnection" type="boolean" required="false" default="false" 
		hint="Boolean indicating to test mail server connectivity" />
    <cfargument name="existingSMTPServer" type="string" required="false" default="" 
		hint="Existing SMTP server DNS name or IP address; used for updates" />
    <cfargument name="action" type="string" required="false" default="create" hint="Action to take (create or update)" />
    
    <cfset var localConfig = getConfig() />
    <cfset var mailServer = "" />
    <cfset var mailSession = 0 />
    <cfset var transport = 0 />
    <cfset var errorMessage = "" />
    <cfset var i = 0 />
    <cfset var doSetConfig = false />

    <cfset checkLoginStatus() />

    <!--- some of the mail settings may not exist --->
    <cfif !StructKeyExists(localConfig.cfmail, "threads")>
      <cfset localConfig.cfmail.threads = "1" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "charset")>
      <cfset localConfig.cfmail.charset = getDefaultCharset() />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfmail, "timeout")>
      <cfset localConfig.cfmail.timeout = "60" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif doSetConfig>
      <cfset setConfig(localConfig) />
    </cfif>
    
    <!--- make sure the mail server doesn't already exist --->
    <cfif arguments.action == "create" && ListContainsNoCase(localConfig.cfmail.smtpserver, arguments.smtpserver)>
      <cfthrow message="The mail server DNS name or IP address is already in the list of registered mail servers" 
	       type="bluedragon.adminapi.mail" />
    </cfif>
    
    <!--- format the mail server information based on the arguments provided --->
    <cfset mailServer = arguments.smtpserver />
    
    <cfif StructKeyExists(arguments, "smtpport")>
      <cfset mailServer &= ":" & arguments.smtpport />
      <cfelse>
	<cfset mailServer = mailServer & ":25" />
    </cfif>
    
    <cfif arguments.username != "">
      <cfset mailServer = arguments.username & ":" & arguments.password & "@" & mailServer />
    </cfif>

    <!--- test the connection if necessary --->
    <cfif arguments.testConnection>
      <cftry>
	<cfset verifyMailServer(mailServer) />
	<cfcatch type="any">
	  <cfrethrow />
	</cfcatch>
      </cftry>
    </cfif>
    
    <!--- if this is an update, delete the existing server --->
    <cfif arguments.action == "update">
      <cfset deleteMailServer(arguments.existingSMTPServer) />
      <cfset localConfig = getConfig() />
    </cfif>
    
    <!--- if this server is primary, prepend it to the list; otherwise append it to the list --->
    <cfif arguments.isPrimary>
      <cfset localConfig.cfmail.smtpserver = ListPrepend(localConfig.cfmail.smtpserver, mailServer) />
      <cfelse>
	<cfset localConfig.cfmail.smtpserver = ListAppend(localConfig.cfmail.smtpserver, mailServer) />
    </cfif>
    
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="deleteMailServer" access="public" output="false" returntype="void" 
	      hint="Deletes a mail server from the list of available mail servers">
    <cfargument name="mailServer" type="string" required="true" hint="The mail server to delete from the list of available mail servers" />
    
    <cfset var localConfig = getConfig() />
    <cfset var i = 0 />

    <cfset checkLoginStatus() />
    
    <cfloop index="i" from="1" to="#ListLen(localConfig.cfmail.smtpserver)#">
      <cfif FindNoCase(arguments.mailServer, ListGetAt(localConfig.cfmail.smtpserver, i))>
	<cfset localConfig.cfmail.smtpserver = ListDeleteAt(localConfig.cfmail.smtpserver, i) />
	<cfbreak />
      </cfif>
    </cfloop>
    
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="verifyMailServer" access="public" output="false" 
	      hint="Verifies a mail server by connecting to the server via a JavaMail session">
    <cfargument name="mailServer" type="string" required="true" hint="The mail server to verify, in format 'server', 'server:port', or 'user:pass@server:port'" />
    
    <cfset var mailSession = 0 />
    <cfset var transport = 0 />
    <cfset var theMailServer = "" />
    <cfset var port = 25 />
    <cfset var username = "" />
    <cfset var password = "" />
    <cfset var mailServerString = "" />
    <cfset var numcolons = "" />
    <cfset var numats = "" />

    <cfset checkLoginStatus() />
    
    <!---
	Start out by seeing how many colons we're dealing with. This will give us an idea of what data we'll be
	working with. We'll be working with the string from right to left.
	0 = Server Only
	>=1 = we have to check
      --->
    <cfset mailServerString = arguments.mailServer />
    <cfset numcolons = ListLen(mailServerString, ":") />
    <cfif numcolons GT 0>
      <!--- If we're dealing with colons we have to do some variable hunting --->
      <!--- Check to see if the last variable is numeric. Yes = port, No = Server --->
      <cfif IsNumeric(ListLast(mailServerString, ":"))>
	<cfset port = ListLast(mailServerString, ":") />
	<!--- drop the port from the string --->
	<cfset mailServerString = Left(mailServerString, (Len(mailServerString) - (Len(ListLast(mailServerString, ":")) + 1))) />
      </cfif>
      <!--- From here, we know that the last variable is the server, so let's see if we have anything in addition to the server --->
      <cfset numats = ListLen(mailServerString, "@") />
      <cfif numats gt 1>
	<!--- if we have an at symbol, then we know we have user information of some sort --->
	<cfset theMailServer = ListLast(mailServerString, "@") />
	<!--- now drop the server info so all we have is user data --->
	<cfset mailServerString = Left(mailServerString, (Len(mailServerString) - (Len(ListLast(mailServerString, "@")) + 1))) />
	<!--- assume that if a user name is specified, a colon is too --->
	<cfif Right(mailServerString, 1) IS ":">
	  <!--- if the password field is blank --->
	  <cfset username = ListFirst(mailServerString, ":") />
	  <cfset password = "" />
	  <cfelse>
	    <cfset username = ListFirst(mailServerString, ":") />
	    <cfset password = ListLast(mailServerString, ":") />
	</cfif>
	<cfelse>
	  <!--- if there is no at symbol, then we're done. --->
	  <cfset theMailServer = mailServerString />
      </cfif>
      <cfelse>
	<!--- If we're not dealing with colons, just the server name was specified --->
	<cfset theMailServer = arguments.mailServer />
    </cfif>
    
    <cftry>
      <cfset mailSession = CreateObject("java", "javax.mail.Session").getDefaultInstance(createObject("java", "java.util.Properties").init()) />
      <cfset transport = mailSession.getTransport("smtp") />
      <cfset transport.connect(theMailServer, JavaCast("int", port), username, password) />
      <cfset transport.close() />
      <cfcatch type="any">
	<cfthrow message="Mail server verification failed: #CFCATCH.Message#" type="bluedragon.adminapi.mail" />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="getSpooledMailCount" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of files currently in the mail spool. If this returns -1 it means an error occurred while reading the spool directory.">
    <cfset var spoolCount = 0 />
    <cfset var spoolDirList = 0 />
    <cfset var mailSpoolPath = getMailSpoolPath() />

    <cfset checkLoginStatus() />
    
    <cftry>
      <cfdirectory action="list" directory="#mailSpoolPath#" name="spoolDirList" filter="*.email" />
      <cfset spoolCount = spoolDirList.RecordCount />
      <cfcatch type="any">
	<cfset spoolCount = -1 />
      </cfcatch>
    </cftry>
    
    <cfreturn spoolCount />
  </cffunction>
  
  <cffunction name="getUndeliveredMailCount" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of files currently in the undelivered mail directory. If this returns -1 it means an error occurred while reading the undelivered directory.">
    <cfset var undeliveredCount = 0 />
    <cfset var undeliveredDirList = 0 />
    <cfset var undeliveredMailPath = getUndeliveredMailPath() />

    <cfset checkLoginStatus() />

    <cftry>
      <cfdirectory action="list" directory="#undeliveredMailPath#" name="undeliveredDirList" filter="*.email" />
      <cfset undeliveredCount = undeliveredDirList.RecordCount />
      <cfcatch type="any">
	<cfset undeliveredCount = -1 />
      </cfcatch>
    </cftry>
    
    <cfreturn undeliveredCount />
  </cffunction>
  
  <cffunction name="respoolUndeliveredMail" access="public" output="false" returntype="void" 
	      hint="Moves all the mail in the undelivered directory to the spool">
    <cfset var undeliveredMail = 0 />
    <cfset var undeliveredMailPath = getUndeliveredMailPath() />
    <cfset var mailSpoolPath = getMailSpoolPath() />

    <cfset checkLoginStatus() />

    <cfdirectory action="list" directory="#undeliveredMailPath#" name="undeliveredMail" filter="*.email" />
    
    <cfif undeliveredMail.RecordCount gt 0>
      <cfloop query="undeliveredMail">
	<cfif fileExists("#undeliveredMailPath##variables.separator.file##undeliveredMail.name#")>
	  <cffile action="move" 
		  source="#undeliveredMailPath##variables.separator.file##undeliveredMail.name#" 
		  destination="#mailSpoolPath##variables.separator.file##undeliveredMail.name#" />
	</cfif>
      </cfloop>
    </cfif>
    
    <cfset triggerMailSpool() />
  </cffunction>
  
  <cffunction name="triggerMailSpool" access="public" output="false" returntype="void" 
	      hint="Triggers the mail spool to start sending mail">
    <cfset checkLoginStatus() />
    
    <cfset createObject("java", "com.naryx.tagfusion.cfm.mail.cfMAIL").spoolingMailServer.notifySenders() />
  </cffunction>
  
  <cffunction name="getMailSpoolPath" access="public" output="false" returntype="string" 
	      hint="Returns the mail spool path">
    <cfset var mailSpoolPath = "" />
    
    <cfset checkLoginStatus() />

    <cfif variables.isMultiContextJetty>
      <cfset mailSpoolPath = "#getJVMProperty('jetty.home')##variables.separator.file#logs#variables.separator.file#openbd#variables.separator.file#cfmail#variables.separator.file#spool" />
      <cfelse>
	<cfset mailSpoolPath = expandPath("/WEB-INF/bluedragon/work/cfmail/spool") />
    </cfif>
    
    <cfreturn mailSpoolPath />
  </cffunction>
  
  <cffunction name="getUndeliveredMailPath" access="public" output="false" returntype="string" 
	      hint="Returns the undelievered mail path">
    <cfset var undeliveredMailPath = "" />

    <cfset checkLoginStatus() />
    
    <cfif variables.isMultiContextJetty>
      <cfset undeliveredMailPath = "#getJVMProperty('jetty.home')##variables.separator.file#logs#variables.separator.file#openbd#variables.separator.file#cfmail#variables.separator.file#undelivered" />
      <cfelse>
	<cfset undeliveredMailPath = expandPath("/WEB-INF/bluedragon/work/cfmail/undelivered") />
    </cfif>
    
    <cfreturn undeliveredMailPath />
  </cffunction>
</cfcomponent>
