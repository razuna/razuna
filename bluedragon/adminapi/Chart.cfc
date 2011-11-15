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
<cfcomponent displayname="Chart" 
	     output="false" 
	     extends="Base" 
	     hint="Manages chart settings - OpenBD Admin API">

  <cffunction name="getChartSettings" access="public" output="false" returntype="struct" 
	      hint="Returns a struct containing the chart settings">
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    
    <!--- cfchart section may not exist --->
    <cfif !StructKeyExists(localConfig, "cfchart")>
      <cfset localConfig.cfchart = {} />
      <cfset localConfig.cfchart.cachesize = "1000" />
      <cfset localConfig.cfchart.storage = "file" />
      <cfset setConfig(localConfig) />
    </cfif>
    
    <cfreturn structCopy(localConfig.cfchart) />
  </cffunction>
  
  <cffunction name="setChartSettings" access="public" output="false" returntype="void" 
	      hint="Saves the chart settings">
    <cfargument name="cachesize" type="numeric" required="true" hint="Maximum number of charts to store in the cache" />
    <cfargument name="storage" type="string" required="true" hint="Storage location for charts" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    
    <cfif !StructKeyExists(localConfig, "cfchart")>
      <cfset localConfig.cfchart = structNew() />
    </cfif>
    
    <cfset localConfig.cfchart.cachesize = ToString(arguments.cachesize) />
    <cfset localConfig.cfchart.storage = arguments.storage />
    
    <cfset setConfig(localConfig) />
  </cffunction>

</cfcomponent>
