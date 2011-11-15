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
<cfcomponent displayname="Mapping" 
	     output="false" 
	     extends="Base" 
	     hint="Manage mappings - OpenBD Admin API">

  <cffunction name="getMappings" access="public" output="false" returntype="array" 
	      hint="Returns array of mappings which equate logical paths to directory paths">
    <cfargument name="mapName" required="false" type="string" hint="The mapping to retrieve" />
    
    <cfset var localConfig = getConfig() />
    <cfset var mapIndex = "" />
    <cfset var returnArray = [] />
    <cfset var sortKeys = [] />
    <cfset var sortKey = {} />

    <cfset checkLoginStatus() />

    <!--- Make sure there are Mappings --->
    <cfif !StructKeyExists(localConfig, "cfmappings") || !StructKeyExists(localConfig.cfmappings, "mapping")>
      <cfthrow message="No Mappings Defined" type="bluedragon.adminapi.mapping" />
    </cfif>

    <!--- Return entire Mapping array, unless a map name is specified --->
    <cfif !IsDefined("arguments.mapName")>
      <!--- set the sorting information --->
      <cfset sortKey.keyName = "name" />
      <cfset sortKey.sortOrder = "ascending" />
      <cfset ArrayAppend(sortKeys, sortKey) />
      
      <cfreturn variables.udfs.sortArrayOfObjects(localConfig.cfmappings.mapping, sortKeys, false, false) />
      <cfelse>
	<cfloop index="mapIndex" from="1" to="#ArrayLen(localConfig.cfmappings.mapping)#">
	  <cfif localConfig.cfmappings.mapping[mapIndex].name == arguments.mapName>
	    <cfset returnArray[1] = Duplicate(localConfig.cfmappings.mapping[mapIndex]) />
	    <cfreturn returnArray />
	  </cfif>
	</cfloop>
	<cfthrow message="#arguments.mapName# is not defined as a mapping" type="bluedragon.adminapi.mapping" />
    </cfif>
  </cffunction>

  <cffunction name="setMapping" access="public" output="false" returntype="void" 
	      hint="Creates a mapping, equating a logical path to a directory path">
    <cfargument name="name" type="string" required="true" hint="Logical path name" />
    <cfargument name="directory" type="string" required="true" hint="Directory path name" />
    <cfargument name="action" type="string" required="false" default="create" hint="Mapping action (create or update)" />
    <cfargument name="existingMappingName" type="string" required="false" default="" 
		hint="Existing mapping name--used in the event of a name update" />
    
    <cfset var localConfig = getConfig() />
    <cfset var mapping = {} />
    <cfset var tempPath = "" />

    <cfset checkLoginStatus() />

    <!--- Make sure configuration structure exists, otherwise build it --->
    <cfif !StructKeyExists(localConfig, "cfmappings") || !StructKeyExists(localConfig.cfmappings, "mapping")>
      <cfset localConfig.cfmappings.mapping = [] />
    </cfif>
    
    <!--- make sure we can hit the physical directory --->
    <cftry>
      <cfset tempPath = getFullPath(arguments.directory) />

      <cfif !DirectoryExists(tempPath)>
	<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.mapping" />
      </cfif>
      <cfcatch type="any">
	<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.mapping" />
      </cfcatch>
    </cftry>
    
    <!--- if this is an edit, delete the existing mapping --->
    <cfif arguments.action == "update">
      <cfset deleteMapping(arguments.existingMappingName) />
      <cfset localConfig = getConfig() />
      
      <!--- if that was the only mapping, need to recreate the mapping structure --->
      <cfif !StructKeyExists(localConfig, "cfmappings") || !StructKeyExists(localConfig.cfmappings, "mapping")>
	<cfset localConfig.cfmappings.mapping = [] />
      </cfif>
    </cfif>
    
    <!--- Build Mapping Struct --->
    <cfif Left(arguments.name, 1) != "/">
      <cfset arguments.name = "/" & arguments.name />
    </cfif>
    
    <cfset mapping.name = LCase(arguments.name) />
    <cfset mapping.displayname = arguments.name />
    <cfset mapping.directory = arguments.directory />

    <!--- Prepend it to the Mapping array --->
    <cfset ArrayPrepend(localConfig.cfmappings.mapping, Duplicate(mapping)) />
    
    <cfset setConfig(localConfig) />
  </cffunction>
  
  <cffunction name="verifyMapping" access="public" output="false" returntype="void" 
	      hint="Verifies the mapping by running cfdirectory on both the physical and logical paths">
    <cfargument name="mappingName" type="string" required="true" hint="The mapping to verify" />
    
    <cfset var mapping = getMappings(arguments.mappingName) />
    <cfset var tempPath = "" />

    <cfset checkLoginStatus() />
    
    <cfset mapping = mapping[1] />
    
    <!--- check the physical directory --->
    <cftry>
      <cfset tempPath = getFullPath(mapping.directory) />
      
      <cfif !DirectoryExists(tempPath)>
	<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.mapping" />
      </cfif>
      <cfcatch type="any">
	<cfthrow message="The directory specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.mapping" />
      </cfcatch>
    </cftry>
    
    <!--- check the logical path --->
    <cftry>
      <cfif !DirectoryExists(WxpandPath(mapping.name))>
	<cfthrow message="The logical path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.mapping" />
      </cfif>
      <cfcatch type="any">
	<cfthrow message="The logical path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.mapping" />
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="deleteMapping" access="public" output="false" returntype="void" 
	      hint="Deletes the specified mapping">
    <cfargument name="mapName" required="true" type="string" hint="The mapping to delete" />
    
    <cfset var localConfig = getConfig() />
    <cfset var mapIndex = "" />

    <cfset checkLoginStatus() />

    <!--- Make sure there are Mappings --->
    <cfif !StructKeyExists(localConfig, "cfmappings") || !StructKeyExists(localConfig.cfmappings, "mapping")>
      <cfthrow message="No Mappings Defined" type="bluedragon.adminapi.mapping" />
    </cfif>

    <cfloop index="mapIndex" from="1" to="#ArrayLen(localConfig.cfmappings.mapping)#">
      <cfif localConfig.cfmappings.mapping[mapIndex].name == arguments.mapName>
	<cfset ArrayDeleteAt(localConfig.cfmappings.mapping, mapIndex) />
	<cfset setConfig(localConfig) />
	<cfreturn />
      </cfif>
    </cfloop>
    <cfthrow message="#arguments.mapName# is not defined as a mapping" type="bluedragon.adminapi.mapping" />
  </cffunction>

</cfcomponent>
