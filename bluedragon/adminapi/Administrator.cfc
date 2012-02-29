<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    David C. Epler - dcepler@dcepler.net
    Matt Woodward - matt@mattwoodward.com

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
<cfcomponent displayname="Administrator" 
	     output="false" 
	     extends="Base" 
	     hint="Manages administrator security - OpenBD Admin API">
  
  <cffunction name="setInitialSecurity" access="public" output="false" returntype="void" 
	      hint="Sets the initial password to 'admin' if the password node doesn't exist in bluedragon.xml. Also creates allowedips and deniedips nodes.">
    <cfset var localConfig = getConfig() />
    <cfset var doSetConfig = false />
    
    <cfif !StructKeyExists(localConfig.system, "allowedips")>
      <cfset localConfig.system.allowedips = "" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.system, "deniedips")>
      <cfset localConfig.system.deniedips = "" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif doSetConfig>
      <!--- need to log in briefly to be able to call setConfig() --->
      <cfset session.auth.loggedIn = true />
      <cfset session.auth.password = localConfig.system.password />
      
      <cfset setConfig(localConfig) />
      
      <!--- log right back out --->
      <cfset StructDelete(session, "auth", false) />
    </cfif>
  </cffunction>
  
  <cffunction name="setPassword" access="public" output="false" returntype="void" 
	      hint="Sets the administrator password">
    <cfargument name="password" type="string" required="true" hint="The password" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    <cfset localConfig.system.password = arguments.password />
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="setAllowedIPs" access="public" output="false" returntype="void" 
	      hint="Sets the IP addresses allowed to access the admin API">
    <cfargument name="allowedIPs" type="string" required="true" hint="The allowed IPs" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    <cfset localConfig.system.allowedips = arguments.allowedIPs />
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="getAllowedIPs" access="public" output="false" returntype="string" 
	      hint="Returns the list of IP addresses allowed to access the admin API">
    <cfset var localConfig = getConfig() />
    
    <cfif !StructKeyExists(localConfig.system, "allowedips")>
      <cfset localConfig.system.allowedips = "" />
      <cfset setConfig(localConfig) />
    </cfif>
    
    <cfreturn localConfig.system.allowedips />
  </cffunction>
  
  <cffunction name="setDeniedIPs" access="public" output="false" returntype="void" 
	      hint="Sets the IP addresses not allowed to access the admin API">
    <cfargument name="deniedIPs" type="string" required="true" hint="The denied IPs" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    <cfset localConfig.system.deniedips = arguments.deniedIPs />
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="getDeniedIPs" access="public" output="false" returntype="string" 
	      hint="Returns the list of IP addresses not allowed to access the admin API">
    <cfset var localConfig = getConfig() />
    
    <cfif !StructKeyExists(localConfig.system, "deniedips")>
      <cfset localConfig.system.deniedips = "" />
      <cfset setConfig(localConfig) />
    </cfif>
    
    <cfreturn localConfig.system.deniedips />
  </cffunction>
  
  <cffunction name="login" access="public" output="false" returntype="boolean" 
	      hint="Processes login attempts and returns a boolean indicating whether or not the login was successful">
    <cfargument name="password" type="string" required="true" hint="The password provided by the user" />
    
    <cfset var success = false />
    
    <cfif CompareNoCase(arguments.password, getPassword()) == 0>
      <cfset success = true />
    </cfif>
    
    <cfreturn success />
  </cffunction>

  <cffunction name="logout" access="public" output="false" returntype="void" hint="Logs the user out">
    <cfset StructDelete(session, "auth", false) />
  </cffunction>

</cfcomponent>
