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
<cfcomponent displayname="Caching" 
	     output="false" 
	     extends="Base" 
	     hint="Manages caching - OpenBD Admin API">

  <!--- GENERAL CACHING SETTINGS/METHODS --->
  <cffunction name="getCachingSettings" access="public" output="false" returntype="struct" 
	      hint="Returns an array containing the current caching settings (file, query, and current cache status).">
    <cfset var cachingSettings = {} />
    <cfset var localConfig = getConfig() />
    <cfset var doSetConfig = false />

    <cfset checkLoginStatus() />
    
    <!--- cfquery node may not exist --->
    <cfif !StructKeyExists(localConfig, "cfquery")>
      <cfset localConfig.cfquery = {} />
      <cfset localConfig.cfquery.cachecount = "1000" />
      <cfset doSetConfig = true />
      <cfelseif !StructKeyExists(localConfig.cfquery, "cachecount")>
	<cfset localConfig.cfquery.cachecount = "1000" />
	<cfset doSetConfig = true />
    </cfif>
    
    <cfset cachingSettings.cfquery.cachecount = localConfig.cfquery.cachecount />
    
    <!--- file node may not exist --->
    <cfif !StructKeyExists(localConfig, "file")>
      <cfset localConfig.file = {} />
      <cfset localConfig.maxfiles = "1000" />
      <cfset localConfig.trustcache = "false" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.file, "maxfiles")>
      <cfset localConfig.file.maxfiles = "1000" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.file, "trustcache")>
      <cfset localConfig.file.trustcache = "false" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfset cachingSettings.file.maxfiles = localConfig.file.maxfiles />
    <cfset cachingSettings.file.trustcache = localConfig.file.trustcache />
    
    <!--- cfcachecontent node may not exist --->
    <cfif !StructKeyExists(localConfig, "cfcachecontent")>
      <cfset localConfig.cfcachecontent = {} />
      <cfset localConfig.cfcachecontent.datasource = "" />
      <cfset localConfig.cfcachecontent.total = "1000" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfcachecontent, "datasource")>
      <cfset localConfig.cfcachecontent.datasource = "" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfif !StructKeyExists(localConfig.cfcachecontent, "total")>
      <cfset localConfig.cfcachecontent.total = "1000" />
      <cfset doSetConfig = true />
    </cfif>
    
    <cfset cachingSettings.cfcachecontent.datasource = localConfig.cfcachecontent.datasource />
    <cfset cachingSettings.cfcachecontent.total = localConfig.cfcachecontent.total />
    
    <cfif doSetConfig>
      <cfset setConfig(localConfig) />
    </cfif>
    
    <cfreturn StructCopy(cachingSettings) />
  </cffunction>
  
  <cffunction name="flushCaches" access="public" output="false" returntype="void" 
	      hint="Flushes the caches passed in as a comma-delimited list">
    <cfargument name="cachesToFlush" type="string" required="true" />
    
    <cfset var theCache = "" />

    <cfset checkLoginStatus() />
    
    <cfloop list="#arguments.cachesToFlush#" index="theCache">
      <cfswitch expression="#LCase(theCache)#">
	<cfcase value="file">
	  <cfset flushFileCache() />
	</cfcase>
	
	<cfcase value="query">
	  <cfset flushQueryCache() />
	</cfcase>
	
	<cfcase value="content">
	  <cfset flushContentCache() />
	</cfcase>
	
	<cfdefaultcase>
	  <cfthrow message="Attempt to flush unknown cache" type="bluedragon.adminapi.caching" />
	</cfdefaultcase>
      </cfswitch>
    </cfloop>
  </cffunction>
  
  <!--- CONTENT CACHE METHODS --->
  <cffunction name="setCFCacheContentSettings" access="public" output="false" returntype="void" 
	      hint="Updates the CFCACHECONTENT settings">
    <cfargument name="total" type="numeric" required="true" 
		hint="The maximum number of items to cache in RAM before using the datasource" />
    <cfargument name="datasource" type="string" required="true" 
		hint="The datasource to use for items exceeding the maximum number to be stored in RAM" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    
    <cfif Find(".", arguments.total) != 0 || !IsNumeric(arguments.total) || arguments.total lte 0>
      <cfthrow message="The item cache size must be a numeric value greater than 0" 
	       type="bluedragon.adminapi.caching" />
    </cfif>
    
    <cfset localConfig.cfcachecontent.total = ToString(arguments.total) />
    <cfset localConfig.cfcachecontent.datasource = arguments.datasource />
    
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="getNumContentInCache" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of items in the content cache (i.e. created with <cfcachecontent>)">
    <cfset checkLoginStatus() />
    
    <!--- throwing this in for pre-1.0 versions of openbd --->
    <cftry>
      <cfreturn CacheStats("cfcachecontent").size />
      <cfcatch type="any">
	<cfreturn 0 />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="getContentCacheHits" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of hits in the content cache">
    <cfset checkLoginStatus() />

    <cftry>
      <cfreturn CacheStats("cfcachecontent").hits />
      <cfcatch type="any">
	<cfreturn 0 />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="getContentCacheMisses" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of misses in the content cache">
    <cfset checkLoginStatus() />
    
    <cftry>
      <cfreturn CacheStats("cfcachecontent").misses />
      <cfcatch type="any">
	<cfreturn 0 />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="flushContentCache" access="public" output="false" returntype="void" 
	      hint="Flushes the content cache">
    <cfset checkLoginStatus() />
    
    <cfset CacheDeleteAll("cfcachecontent") />
  </cffunction>
  
  <!--- FILE CACHE METHODS --->
  <cffunction name="setFileCacheSettings" access="public" output="false" returntype="void" 
	      hint="Updates the file cache settings">
    <cfargument name="maxfiles" type="numeric" required="true" hint="The maximum number of files to cache" />
    <cfargument name="trustcache" type="boolean" required="true" hint="Enable/disable trusted cache" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    
    <cfif Find(".", arguments.maxfiles) != 0 || !IsNumeric(arguments.maxfiles)>
      <cfthrow message="The value of the file cache count == not numeric" 
	       type="bluedragon.adminapi.caching" />
    </cfif>
    
    <cfset localConfig.file.maxfiles = ToString(arguments.maxfiles) />
    <cfset localConfig.file.trustcache = ToString(arguments.trustcache) />
    
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="getNumFilesInCache" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of files in the file cache">
    <cfset checkLoginStatus() />
    
    <cftry>
      <cfreturn CacheStats("filecache").size />
      <cfcatch type="any">
	<cfreturn 0 />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="flushFileCache" access="public" output="false" returntype="void" 
	      hint="Flushes the file cache">
    <cfset checkLoginStatus() />
    
    <cfset CacheDeleteAll("filecache") />
  </cffunction>
  
  <!--- QUERY CACHE METHODS --->
  <cffunction name="setQueryCacheSettings" access="public" output="false" returntype="void" 
	      hint="Updates the query cache settings">
    <cfargument name="cachecount" type="numeric" required="true" hint="The maximum number of queries to cache" />
    
    <cfset var localConfig = getConfig() />

    <cfset checkLoginStatus() />
    
    <cfif Find(".", arguments.cachecount) != 0 || !IsNumeric(arguments.cachecount)>
      <cfthrow message="The value of the query cache count is not numeric" 
	       type="bluedragon.adminapi.caching" />
    </cfif>
    
    <cfset localConfig.cfquery.cachecount = ToString(arguments.cachecount) />
    
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="getNumQueriesInCache" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of queries in the cache">
    <cfset checkLoginStatus() />
    
    <cftry>
      <cfreturn CacheStats("query").size />
      <cfcatch type="any">
	<cfreturn 0 />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="getQueryCacheHits" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of hits against the query cache">
    <cfset checkLoginStatus() />
    
    <cftry>
      <cfreturn CacheStats("query").hits />
      <cfcatch type="any">
	<cfreturn 0 />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="getQueryCacheMisses" access="public" output="false" returntype="numeric" 
	      hint="Returns the number of misses against the query cache">
    <cfset checkLoginStatus() />

    <cftry>
      <cfreturn CacheStats("query").misses />
      <cfcatch type="any">
	<cfreturn 0 />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <cffunction name="flushQueryCache" access="public" output="false" returntype="void" 
	      hint="Flushes the query cache">
    <cfset checkLoginStatus() />

    <cfset CacheDeleteAll("query") />
  </cffunction>
</cfcomponent>
