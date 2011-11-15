<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    Matt Woodward - matt@mattwoodward.com
    Jordan Michaels - jordan@viviotech.net

    This file is part of the Open BlueDragon Administrator.

    The Open BlueDragon Administrator is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Administrator is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Administrator.  If not, see 
    <http://www.gnu.org/licenses/>.
    --->
<cfsilent>
  <cfparam name="args.action" type="string" default="" />
  
  <!--- clear out old session stuff --->
  <cfset StructDelete(session, "errorFields", false) />
  <cfset StructDelete(session, "message", false) />
  <cfset StructDelete(session, "mapping", false) />
  
  <!--- stick everything in form and url into a struct for easy reference --->
  <cfset args = {} />
  
  <cfloop collection="#url#" item="urlKey">
    <cfset args[urlKey] = url[urlKey] />
  </cfloop>
  
  <cfloop collection="#form#" item="formKey">
    <cfset args[formKey] = form[formKey] />
  </cfloop>
  
  <cfswitch expression="#args.action#">
    <!--- SECURITY --->
    <cfcase value="processAdminConsolePasswordForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif !Trim(args.password) == Trim(args.confirmPassword)>
	<cfset errorFields[errorFieldsIndex][1] = "confirmPassword" />
	<cfset errorFields[errorFieldsIndex][2] = "The password fields do not match" />
      </cfif>
      
      <cfif ArrayLen(errorFields) != 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="security.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.administrator.setPassword(Trim(args.password)) />
	    <cfcatch type="bluedragon.adminapi.administrator">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="security.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>
	  
	  <cfset session.auth.password = args.password />
	  <cfset session.message.text = "The password was updated successfully." />
	  <cfset session.message.type = "success" />
	  <cflocation url="security.cfm" addtoken="false" />
      </cfif>
    </cfcase>
    
    <cfcase value="processIPAddressForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <!--- do some basic validation on the IP addresses --->
      <cfset args.allowIPs = Trim(args.allowIPs) />
      <cfset args.denyIPs = Trim(args.denyIPs) />
      
      <cfif args.allowIPs is not "">
	<cfloop list="#args.allowIPs#" index="theIP" delimiters=",">
	  <cfif Find("*", theIP) != 0>
	    <cfset ipParts = ListToArray(theIP, ".") />
	    
	    <cfloop index="i" from="1" to="#ArrayLen(ipParts)#">
	      <cfif IsNumeric(ipParts[i])>
		<cfif ipParts[i] lt 0 || ipParts[i] gt 255>
		  <cfset errorFields[errorFieldsIndex][1] = "allowIPs" />
		  <cfset errorFields[errorFieldsIndex][2] = "One of the allowed IPs is not valid" />
		</cfif>
	      </cfif>
	    </cfloop>
	    <cfelse>
	      <cftry>
		<cfset inetAddress = CreateObject("java", "java.net.InetAddress").getByName(theIP)>
		  <cfcatch type="any">
		    <cfset errorFields[errorFieldsIndex][1] = "allowIPs" />
		    <cfset errorFields[errorFieldsIndex][2] = "One of the allowed IPs is not valid" />
		  </cfcatch>
	      </cftry>
	  </cfif>
	</cfloop>
      </cfif>
      
      <cfif args.denyIPs != "">
	<cfloop list="#args.denyIPs#" index="theIP" delimiters=",">
	  <cfif Find("*", theIP) != 0>
	    <cfset ipParts = ListToArray(theIP, ".") />
	    
	    <cfloop index="i" from="1" to="#ArrayLen(ipParts)#">
	      <cfif IsNumeric(ipParts[i])>
		<cfif ipParts[i] lt 0 || ipParts[i] gt 255>
		  <cfset errorFields[errorFieldsIndex][1] = "denyIPs" />
		  <cfset errorFields[errorFieldsIndex][2] = "One of the denied IPs is not valid" />
		</cfif>
	      </cfif>
	    </cfloop>
	    <cfelse>
	      <cftry>
		<cfset inetAddress = CreateObject("java", "java.net.InetAddress").getByName(theIP)>
		  <cfcatch type="any">
		    <cfset errorFields[errorFieldsIndex][1] = "denyIPs" />
		    <cfset errorFields[errorFieldsIndex][2] = "One of the denied IPs is not valid" />
		  </cfcatch>
	      </cftry>
	  </cfif>
	</cfloop>
      </cfif>
      
      <cfif ArrayLen(errorFields) != 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="security.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.administrator.setAllowedIPs(args.allowIPs) />
	    <cfset Application.administrator.setDeniedIPs(args.denyIPs) />
	    <cfcatch type="bluedragon.adminapi.administrator">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="security.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>

	  <cfset session.message.text = "The IP addresses were updated successfully." />
	  <cfset session.message.type = "success" />
	  <cflocation url="security.cfm" addtoken="false" />
      </cfif>
    </cfcase>
    
    <!--- SERVER SETTINGS --->
    <cfcase value="processServerSettingsForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Find(".", args.buffersize) != 0 || !IsNumeric(args.buffersize)>
	<cfset errorFields[errorFieldsIndex][1] = "buffersize" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Response Buffer Size is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.defaultcharset) == "">
	<cfset errorFields[errorFieldsIndex][1] = "defaultcharset" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Character Set cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.scriptsrc) == "">
	<cfset errorFields[errorFieldsIndex][1] = "scriptsrc" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default CFFORM Script Source Location cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.tempdirectory) == "">
	<cfset errorFields[errorFieldsIndex][1] = "tempdirectory" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Temp Directory Location cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.componentcfc) == "">
	<cfset errorFields[errorFieldsIndex][1] = "componentcfc" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Base ColdFusion Component (CFC) cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.servercfc) == "">
	<cfset errorFields[errorFieldsIndex][1] = "servercfc" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Server CFC cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) != 0>
	<!--- TODO: add nicer functionality so the entire form gets repopulated on error;
	    maybe should repopulate things like tempdirectory and componentcfc with defaults --->
	<cfset session.errorFields = errorFields />
	<cflocation url="index.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.serverSettings.setServerSettings(args.buffersize, args.whitespacecomp, args.errorhandler, 
		   args.missingtemplatehandler, args.defaultcharset, args.scriptprotect, 
		   args.strictarraypassbyreference, args.functionscopedvariables, 
		   args.formurlcombined, args.legacyformvalidation,
		   args.scriptsrc, args.tempdirectory, 
		   args.componentcfc, args.servercfc, 
		   args.verifypathsettings) />
	    <cfcatch type="bluedragon.adminapi.serversettings">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="index.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>

	  <cfset session.message.text = "The server settings were saved successfully." />
	  <cfset session.message.type = "success" />
	  <cflocation url="index.cfm" addtoken="false" />
      </cfif>
    </cfcase>
    
    <cfcase value="revertToPreviousSettings">
      <cftry>
	<cfset Application.serverSettings.revertToPreviousSettings() />
	<cfcatch type="bluedragon.adminapi.serversettings">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="index.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The previous server settings have been restored." />
      <cfset session.message.type = "success" />
      <cflocation url="index.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="reloadSettings">
      <cftry>
	<cfset Application.serverSettings.reloadSettings() />
	<cfcatch type="bluedragon.adminapi.serversettings">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="index.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The server settings have been reloaded." />
      <cfset session.message.type = "success" />
      <cflocation url="index.cfm" addtoken="false" />
    </cfcase>
    
    <!--- MAPPINGS --->
    <cfcase value="editMapping">
      <cfset session.mapping = Application.mapping.getMappings(args.name) />
      <cflocation url="mappings.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="processMappingForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Trim(args.name) == "">
	<cfset errorFields[errorFieldsIndex][1] = "name" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Logical Path cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.directory) == "">
	<cfset errorFields[errorFieldsIndex][1] = "directory" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Directory Path cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="mappings.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.mapping.setMapping(args.name, args.directory, 
		   args.mappingAction, args.existingMappingName) />
	    <cfcatch type="bluedragon.adminapi.mapping">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="mappings.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>
	  
	  <cfset session.message.text = "The mapping was #args.mappingAction#d successfully." />
	  <cfset session.message.type = "success" />
	  <cflocation url="mappings.cfm" addtoken="false" />
      </cfif>
    </cfcase>
    
    <cfcase value="verifyMapping">
      <cftry>
	<cfset Application.mapping.verifyMapping(args.name) />
	<cfcatch type="bluedragon.adminapi.mapping">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="mappings.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The mapping verified successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="mappings.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="deleteMapping">
      <cftry>
	<cfset Application.mapping.deleteMapping(args.name) />
	<cfcatch type="bluedragon.adminapi.mapping">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="mappings.cfm" addtoken="false" />
	</cfcatch>
      </cftry>

      <cfset session.message.text =  "The mapping was deleted successfully."/>
      <cfset session.message.type = "success" />
      <cflocation url="mappings.cfm" addtoken="false" />
    </cfcase>
    
    <!--- CACHING --->
    <cfcase value="processFileCacheForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Find(".", args.maxfiles) != 0 || !IsNumeric(args.maxfiles)>
	<cfset errorFields[errorFieldsIndex][1] = "maxfiles" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of File Cache Size is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="caching.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.caching.setFileCacheSettings(args.maxfiles, args.trustcache) />
	    <cfcatch type="bluedragon.adminapi.caching">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="caching.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>
	  
	  <cfset session.message.text = "The file cache settings were updated successfully." />
	  <cfset session.message.type = "success" />
	  <cflocation url="caching.cfm" addtoken="false" />
      </cfif>
    </cfcase>
    
    <cfcase value="processQueryCacheForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Find(".", args.cachecount) != 0 || !IsNumeric(args.cachecount)>
	<cfset errorFields[errorFieldsIndex][1] = "cachecount" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Query Cache Size is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="caching.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.caching.setQueryCacheSettings(args.cachecount) />
	    <cfcatch type="bluedragon.adminapi.caching">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="caching.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>
	  
	  <cfset session.message.text = "The query cache settings were updated successfully." />
	  <cfset session.message.type = "success" />
	  <cflocation url="caching.cfm" addtoken="false" />
      </cfif>
    </cfcase>
    
    <cfcase value="processFlushCacheForm">
      <cfparam name="args.cacheToFlush" type="string" default="" />
      
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif args.cacheToFlush == "">
	<cfset errorFields[errorFieldsIndex][1] = "cacheToFlush" />
	<cfset errorFields[errorFieldsIndex][2] = "No cache to flush was selected" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="caching.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.caching.flushCaches(args.cacheToFlush) />
	    <cfcatch type="bluedragon.adminapi.caching">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="caching.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>
      </cfif>
      
      <cfset session.message.text = "The selected caches were flushed successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="caching.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="processCFCacheContentForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif !IsNumeric(args.total) || args.total lte 0>
	<cfset errorFields[errorFieldsIndex][1] = "total" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Item Cache Size must be a numeric value greater than 0." />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="caching.cfm" addtoken="false" />
	<cfelse>
	  <cftry>
	    <cfset Application.caching.setCFCacheContentSettings(argumentcollection = args) />
	    <cfcatch type="bluedragon.adminapi.caching">
	      <cfset session.message.text = CFCATCH.Message />
	      <cfset session.message.type = "error" />
	      <cflocation url="caching.cfm" addtoken="false" />
	    </cfcatch>
	  </cftry>
      </cfif>
      
      <cfset session.message.text = "The CFCACHECONTENT settings were updated successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="caching.cfm" addtoken="false" />
    </cfcase>
    
    <!--- VARIABLES --->
    <cfcase value="processVariableForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <!--- make sure all the numeric values are numeric --->
      <cfif Find(".", args.appTimeoutDays) != 0 || !IsNumeric(args.appTimeoutDays)>
	<cfset errorFields[errorFieldsIndex][1] = "appTimeoutDays" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Application Timeout Days is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.appTimeoutHours) != 0 || !IsNumeric(args.appTimeoutHours)>
	<cfset errorFields[errorFieldsIndex][1] = "appTimeoutHours" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Application Timeout Hours is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.appTimeoutMinutes) != 0 || !IsNumeric(args.appTimeoutMinutes)>
	<cfset errorFields[errorFieldsIndex][1] = "appTimeoutMinutes" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Application Timeout Minutes is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.appTimeoutSeconds) != 0 || !IsNumeric(args.appTimeoutSeconds)>
	<cfset errorFields[errorFieldsIndex][1] = "appTimeoutSeconds" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Application Timeout Seconds is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.sessionTimeoutDays) != 0 || !IsNumeric(args.sessionTimeoutDays)>
	<cfset errorFields[errorFieldsIndex][1] = "sessionTimeoutDays" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Session Timeout Days is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.sessionTimeoutHours) != 0 || !IsNumeric(args.sessionTimeoutHours)>
	<cfset errorFields[errorFieldsIndex][1] = "sessionTimeoutHours" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Session Timeout Hours is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.sessionTimeoutMinutes) != 0 || !IsNumeric(args.sessionTimeoutMinutes)>
	<cfset errorFields[errorFieldsIndex][1] = "sessionTimeoutMinutes" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Session Timeout Minutes is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.sessionTimeoutSeconds) != 0 || !IsNumeric(args.sessionTimeoutSeconds)>
	<cfset errorFields[errorFieldsIndex][1] = "sessionTimeoutSeconds" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Default Session Timeout Seconds is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.clientexpiry) != 0 || !IsNumeric(args.clientexpiry)>
	<cfset errorFields[errorFieldsIndex][1] = "clientexpiry" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Client Variable Expiration Days is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.cfchartcachesize) != 0 || !IsNumeric(args.cfchartcachesize)>
	<cfset errorFields[errorFieldsIndex][1] = "cfchartcachesize" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of CFCHART Cache Size is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="variables.cfm" addtoken="false" />
      </cfif>
      
      <!--- handle checkboxes that may not come through --->
      <cfif !StructKeyExists(args, "clientpurgeenabled")>
	<cfset args.clientpurgeenabled = false />
      </cfif>
      
      <cfif !StructKeyExists(args, "clientGlobalUpdatesDisabled")>
	<cfset args.clientGlobalUpdatesDisabled = false />
      </cfif>
      
      <cfif !StructKeyExists(args, "cf5clientdata")>
	<cfset args.cf5clientdata = false />
      </cfif>
      
      <cftry>
	<cfset Application.variableSettings.setVariableSettings(args.j2eesession, args.appTimeoutDays, 
	       args.appTimeoutHours, args.appTimeoutMinutes, 
	       args.appTimeoutSeconds, args.sessionTimeoutDays, 
	       args.sessionTimeoutHours, args.sessionTimeoutMinutes, 
	       args.sessionTimeoutSeconds, args.clientstorage, 
	       args.clientpurgeenabled, args.clientexpiry, 
	       args.clientGlobalUpdatesDisabled, args.cf5clientdata) />
	<cfcatch type="bluedragon.adminapi.variableSettings">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="variables.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cftry>
	<cfset Application.chart.setChartSettings(args.cfchartcachesize, args.cfchartstorage) />
	<cfcatch type="bluedragon.adminapi.chart">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="variables.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The variable settings were updated successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="variables.cfm" addtoken="false" />
    </cfcase>
    
    <!--- MAIL --->
    <cfcase value="processMailServerForm">
      <cfparam name="args.testConnection" type="boolean" default="false" />
      <cfparam name="args.isPrimary" type="boolean" default="false" />
      
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Trim(args.smtpserver) == "">
	<cfset errorFields[errorFieldsIndex][1] = "smtpserver" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of SMTP Server cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.smtpport) != 0 || !IsNumeric(args.smtpport)>
	<cfset errorFields[errorFieldsIndex][1] = "smtpport" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of SMTP Port is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="mail.cfm" addtoken="false" />
      </cfif>
      
      <cftry>
	<cfset Application.mail.setMailServer(args.smtpserver, args.smtpport, 
	       args.username, args.password, 
	       args.isPrimary, args.testConnection, 
	       args.existingSMTPServer, args.mailServerAction) />
	<cfcatch type="bluedragon.adminapi.mail">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="mail.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The mail server was saved successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="mail.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="processMailSettingsForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Find(".", args.timeout) != 0 || !IsNumeric(args.timeout)>
	<cfset errorFields[errorFieldsIndex][1] = "timeout" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Timeout is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.threads) != 0 || !IsNumeric(args.threads)>
	<cfset errorFields[errorFieldsIndex][1] = "threads" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Mail Threads is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Find(".", args.interval) != 0 || !IsNumeric(args.interval)>
	<cfset errorFields[errorFieldsIndex][1] = "interval" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Spool Interval is not numeric" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif !StructKeyExists(args, "usessl")>
	<cfset args.usessl = false />
      </cfif>
      
      <cfif !StructKeyExists(args, "usetls")>
	<cfset args.usetls = false />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="mail.cfm" addtoken="false" />
      </cfif>
      
      <cftry>
	<cfset Application.mail.setMailSettings(args.timeout, args.threads, args.interval, 
	       args.charset, args.domain, args.usessl, 
	       args.usetls, args.catchemail) />
	<cfcatch type="bluedragon.adminapi.mail">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="mail.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The mail settings were saved successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="mail.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="editMailServer">
      <cftry>
	<cfset session.mailServer = Application.mail.getMailServers(args.mailServer) />
	<cfcatch type="any">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	</cfcatch>
      </cftry>
      
      <cflocation url="mail.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="verifyMailServer">
      <cfparam name="args.mailServer" type="string" default="" />
      <cfparam name="mailServers" type="array" default="#arrayNew(1)#" />
      
      <cfset session.mailServerStatus = [] />
	
      <!--- is args.mailServer is not "" then we're verifying a single mail server; otherwise verify all --->
      <cfif args.mailServer != "">
	<cfset mailServers = Application.mail.getMailServers(args.mailServer) />
	<cfelse>
	  <cfset mailServers = Application.mail.getMailServers() />
      </cfif>
      
      <cfloop index="i" from="1" to="#ArrayLen(mailServers)#">
	<cfset session.mailServerStatus[i].smtpserver = mailServers[i].smtpserver />
	
	<cftry>
	  <cfset mailServerString = mailServers[i].smtpserver />
	  
	  <cfif IsDefined("mailServers[i].smtpport") && mailServers[i].smtpport != "">
	    <cfset mailServerString &= ":" & mailServers[i].smtpport />
	  </cfif>
	  
	  <cfif mailServers[i].username != "">
	    <cfset mailServerString = mailServers[i].username & ":" & mailServers[i].password & "@" & mailServerString />
	  </cfif>
	  
	  <cfset Application.mail.verifyMailServer(mailServerString) />
	  
	  <cfset session.mailServerStatus[i].verified = true />
	  <cfset session.mailServerStatus[i].message = "" />
	  <cfcatch type="bluedragon.adminapi.mail">
	    <cfset session.mailServerStatus[i].verified = false />
	    <cfset session.mailServerStatus[i].message = CFCATCH.Message />
	  </cfcatch>
	</cftry>
      </cfloop>
      
      <cflocation url="mail.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="removeMailServer">
      <cftry>
	<cfset Application.mail.deleteMailServer(args.mailServer) />
	<cfcatch type="bluedragon.adminapi.mail">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="mail.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The mail server was removed successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="mail.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="respoolUndeliveredMail">
      <cftry>
	<cfset Application.mail.respoolUndeliveredMail() />
	<cfcatch type="bluedragon.adminapi.mail">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="mail.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The undelivered mail was respooled successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="mail.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="triggerMailSpool">
      <cftry>
	<cfset Application.mail.triggerMailSpool() />
	<cfcatch type="bluedragon.adminapi.mail">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="mail.cfm" addtoken="false" />
	</cfcatch>
      </cftry>

      <cfset session.message.text = "The mail spool was triggered successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="mail.cfm" addtoken="false" />
    </cfcase>
    
    <!--- FONTS --->
    <cfcase value="processFontDirForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Trim(args.fontDir) == "">
	<cfset errorFields[errorFieldsIndex][1] = "fontDir" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Font Directory cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="fonts.cfm" addtoken="false" />
      </cfif>
      
      <cftry>
	<cfset Application.fonts.setFontDirectory(args.fontDir, args.fontDirAction, args.existingFontDir) />
	<cfcatch type="bluedragon.adminapi.fonts">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="fonts.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The font directory was processed successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="fonts.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="verifyFontDirectory">
      <cftry>
	<cfset Application.fonts.verifyFontDirectory(args.fontDir) />
	<cfcatch type="any">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="fonts.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The font directory was verified successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="fonts.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="removeFontDirectory">
      <cftry>
	<cfset Application.fonts.deleteFontDirectory(args.fontDir) />
	<cfcatch type="any">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="fonts.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The font directory was removed successfully." />
      <cfset session.message.type = "success" />
      <cflocation url="fonts.cfm" addtoken="false" />
    </cfcase>
    
    <!--- SERVER INFO --->
    <cfcase value="unloadApplication">
      <cfset session.message.text = "The application was successfully unloaded." />
      <cfset session.message.type = "success" />
      
      <cftry>
	<cfset ApplicationRemove(args.applicationName) />
	<cfcatch type="any">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	</cfcatch>
      </cftry>
      
      <cflocation url="systeminfo.cfm" addtoken="false" />
    </cfcase>
    
    <!--- DEFAULT CASE --->
    <cfdefaultcase>
      <cfset session.message.text = "Invalid action" />
      <cfset session.message.type = "error" />
      <cflocation url="#CGI.HTTP_REFERER#" addtoken="false" />
    </cfdefaultcase>
  </cfswitch>
</cfsilent>
