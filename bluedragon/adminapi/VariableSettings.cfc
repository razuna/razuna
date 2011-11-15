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
<cfcomponent displayname="VariableSettings" 
	     output="false" 
	     extends="Base" 
	     hint="Manages variable settings - OpenBD Admin API">

  <cffunction name="getVariableSettings" access="public" output="false" returntype="struct" 
	      hint="Returns an array containing the current variable settings">
    <cfset var localConfig = getConfig() />
    <cfset var doSetConfig = false />

    <cfset checkLoginStatus() />
    
    <!--- some of the cfapplication nodes may not exist --->
    <cfif !StructKeyExists(localConfig.cfapplication, "clientpurgeenabled")>
      <cfset localConfig.cfapplication.clientpurgeenabled = "true" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfapplication, "cf5clientdata")>
      <cfset localConfig.cfapplication.cf5clientdata = "false" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfapplication, "clientexpiry")>
      <cfset localConfig.cfapplication.clientexpiry = "90" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfapplication, "clientGlobalUpdatesDisabled")>
      <cfset localConfig.cfapplication.clientGlobalUpdatesDisabled = "true" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif doSetConfig>
      <cfset setConfig(localConfig) />
    </cfif>
    
    <cfreturn StructCopy(localConfig.cfapplication) />
  </cffunction>
  
  <cffunction name="setVariableSettings" access="public" output="false" returntype="void" 
	      hint="Saves the variable settings">
    <cfargument name="j2eesession" type="boolean" required="true" hint="Enables/disables J2EE session variables" />
    <cfargument name="appTimeoutDays" type="numeric" required="true" hint="Application timeout days" />
    <cfargument name="appTimeoutHours" type="numeric" required="true" hint="Application timeout hours" />
    <cfargument name="appTimeoutMinutes" type="numeric" required="true" hint="Application timeout minutes" />
    <cfargument name="appTimeoutSeconds" type="numeric" required="true" hint="Application timeout seconds" />
    <cfargument name="sessionTimeoutDays" type="numeric" required="true" hint="Session timeout days" />
    <cfargument name="sessionTimeoutHours" type="numeric" required="true" hint="Session timeout hours" />
    <cfargument name="sessionTimeoutMinutes" type="numeric" required="true" hint="Session timeout minutes" />
    <cfargument name="sessionTimeoutSeconds" type="numeric" required="true" hint="Session timeout seconds" />
    <cfargument name="clientstorage" type="string" required="true" hint="Client storage location" />
    <cfargument name="clientpurgeenabled" type="boolean" required="true" hint="Enable/disable automatic client variable purging" />
    <cfargument name="clientexpiry" type="numeric" required="true" hint="Number of days after which client variables are purged" />
    <cfargument name="clientGlobalUpdatesDisabled" type="boolean" required="true" hint="Enables/disables global client variable updates" />
    <cfargument name="cf5clientdata" type="boolean" required="true" hint="Enables/disables CF 5-compatible client variables" />
    
    <cfset var localConfig = getConfig() />
    <cfset var applicationtimeout = "##CreateTimeSpan(#arguments.appTimeoutDays#,#arguments.appTimeoutHours#,#arguments.appTimeoutMinutes#,#arguments.appTimeoutSeconds#)##" />
    <cfset var sessiontimeout = "##CreateTimeSpan(#arguments.sessionTimeoutDays#,#arguments.sessionTimeoutHours#,#arguments.sessionTimeoutMinutes#,#arguments.sessionTimeoutSeconds#)##" />

    <cfset checkLoginStatus() />
    
    <cfscript>
      localConfig.cfapplication.j2eesession = ToString(arguments.j2eesession);
      localConfig.cfapplication.applicationtimeout = applicationtimeout;
      localConfig.cfapplication.sessiontimeout = sessiontimeout;
      localConfig.cfapplication.clientstorage = arguments.clientstorage;
      localConfig.cfapplication.clientpurgeenabled = ToString(arguments.clientpurgeenabled);
      localConfig.cfapplication.clientexpiry = ToString(arguments.clientexpiry);
      localConfig.cfapplication.clientGlobalUpdatesDisabled = ToString(arguments.clientGlobalUpdatesDisabled);
      localConfig.cfapplication.cf5clientdata = ToString(arguments.cf5clientdata);
      
      setConfig(localConfig);
    </cfscript>
  </cffunction>
  
</cfcomponent>
