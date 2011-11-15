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
<cfcomponent displayname="Extensions" 
	     output="false" 
	     extends="Base" 
	     hint="Manages customtags and CFXs - OpenBD Admin API">
  
  <!--- CUSTOM TAG PATHS --->
  <cffunction name="getCustomTagPaths" access="public" output="false" returntype="array" 
	      hint="Returns an array of paths to customtags">
    <cfset var localConfig = getConfig() />
    <cfset var customTagPaths = arrayNew(1) />
    <cfset var customTagPath = "" />
    <cfset var i = 0 />
    <cfset var updateConfig = false />

    <cfset checkLoginStatus() />

    <!--- Make sure there are Custom Tag Paths defined --->
    <cfif !StructKeyExists(localConfig, "cfmlcustomtags") || !StructKeyExists(localConfig.cfmlcustomtags, "mapping")>
      <cfthrow message="No Custom Tag Paths Defined" type="bluedragon.adminapi.extensions" />		
    </cfif>

    
    <!--- Return entire Custom Tag Path list as an array --->
    <cfset customTagPaths = ListToArray(localConfig.cfmlcustomtags.mapping[1].directory, variables.separator.customTagPath) />

    <!--- fix any odd paths on the multi-context jetty version --->
    <cfif variables.isMultiContextJetty>
      <cfloop index="i" from="1" to="#arrayLen(customTagPaths)#">
	<cfif CompareNoCase(customTagPaths[i], "$./webroot_cfmlapps/customtags") == 0>
	  <cfset customTagPath = 
		 "#getJVMProperty('jetty.home')##variables.separator.file#webroot_cfmlapps#variables.separator.file#customtags" />
	  <cfset customTagPaths[i] = customTagPath />
	  <cfset updateConfig = true />
	</cfif>
      </cfloop>
    </cfif>
    
    <cfif updateConfig>
      <cfset localConfig.cfmlcustomtags.mapping[1].directory = ArrayToList(customTagPaths, variables.separator.customTagPath) />
      <cfset setConfig(StructCopy(localConfig)) />
    </cfif>
    
    <cfset ArraySort(customTagPaths, "textnocase", "asc") />
    
    <cfreturn customTagPaths />
  </cffunction>

  <cffunction name="setCustomTagPath" access="public" output="false" returntype="void" 
	      hint="Defines a new path to customtags">
    <cfargument name="path" type="string" required="true" hint="Custom tag path" />
    <cfargument name="customTagPathAction" type="string" required="true" hint="The action to perform (create or edit)" />
    
    <cfset var localConfig = getConfig() />
    <cfset var tempPath = "" />

    <cfset checkLoginStatus() />
    
    <!--- Make sure there are Custom Tag Paths defined --->
    <cfif !StructKeyExists(localConfig, "cfmlcustomtags") || !StructKeyExists(localConfig.cfmlcustomtags, "mapping")>
      <cfset localConfig.cfmlcustomtags.mapping = [] />
      <cfset localConfig.cfmlcustomtags.mapping[1].name = "cf" />
    </cfif>
    
    <!--- if this is an update, delete the existing custom tag path --->
    <cfif arguments.customTagPathAction is "update">
      <cfset deleteCustomTagPath(arguments.path) />
    </cfif>
    
    <!--- verify the custom tag path --->
    <cftry>
      <cfset tempPath = getFullPath(arguments.path) />
      
      <cfif !DirectoryExists(tempPath)>
	<cfthrow message="The custom tag path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.extensions" />
      </cfif>
      <cfcatch type="any">
	<cfthrow message="The custom tag path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.extensions" />
      </cfcatch>
    </cftry>
    
    <cfif !ListFind(localConfig.cfmlcustomtags.mapping[1].directory, arguments.path, variables.separator.customTagPath)>
      <cfset localConfig.cfmlcustomtags.mapping[1].directory = ListAppend(localConfig.cfmlcustomtags.mapping[1].directory, arguments.path, variables.separator.customTagPath) />
      <cfelse>
	<cfthrow message="The custom tag path already exists." type="bluedragon.adminapi.extensions" />
    </cfif>

    <cfset setConfig(localConfig) />
  </cffunction>

  <cffunction name="deleteCustomTagPath" access="public" output="false" returntype="void" 
	      hint="Deletes a custom tag path">
    <cfargument name="path" type="string" required="true" hint="Custom tag path to delete" />
    
    <cfset var localConfig = getConfig() />
    <cfset var listIndex = "" />

    <cfset checkLoginStatus() />

    <!--- Make sure there are Custom Tag Paths defined --->
    <cfif !StructKeyExists(localConfig, "cfmlcustomtags") || !StructKeyExists(localConfig.cfmlcustomtags, "mapping")>
      <cfthrow message="No Custom Tag Paths Defined" type="bluedragon.adminapi.extensions" />		
    </cfif>
    
    <!--- Find index of path in list --->
    <cfset listIndex = ListFindNoCase(localConfig.cfmlcustomtags.mapping[1].directory, arguments.path, variables.separator.customTagPath) />
    
    <!--- if found, remove customtag path from list --->
    <cfif listIndex != 0>
      <cfset localConfig.cfmlcustomtags.mapping[1].directory = ListDeleteAt(localConfig.cfmlcustomtags.mapping[1].directory, listIndex, variables.separator.customTagPath) />
      <cfset setConfig(localConfig) />
      <cfelse>
	<cfthrow message="#arguments.path# is not defined as a customtag path" type="bluedragon.adminapi.extensions" />
    </cfif>
  </cffunction>
  
  <cffunction name="verifyCustomTagPath" access="public" output="false" returntype="void" 
	      hint="Verifies a custom tag path by running directoryexists() on the path">
    <cfargument name="path" type="string" required="true" hint="Custom tag path to verify" />
    
    <cfset var localConfig = getConfig() />
    <cfset var tempPath = "" />

    <cfset checkLoginStatus() />
    
    <!--- Make sure there are Custom Tag Paths defined --->
    <cfif !StructKeyExists(localConfig, "cfmlcustomtags") || !StructKeyExists(localConfig.cfmlcustomtags, "mapping")>
      <cfthrow message="No Custom Tag Paths Defined" type="bluedragon.adminapi.extensions" />		
    </cfif>

    <!--- verify the custom tag path --->
    <cftry>
      <cfset tempPath = getFullPath(arguments.path) />
      
      <cfif !DirectoryExists(tempPath)>
	<cfthrow message="The custom tag path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.extensions" />
      </cfif>
      <cfcatch type="any">
	<cfthrow message="The custom tag path specified is not accessible. Please verify that the directory exists and has the correct permissions." 
		 type="bluedragon.adminapi.extensions" />
      </cfcatch>
    </cftry>
  </cffunction>
  
  <!--- CFX TAGS --->
  <cffunction name="getCPPCFX" access="public" output="false" returntype="array" 
	      hint="List the names of all registered C++ CFX tags or a specified C++ CFX tag">
    <cfargument name="cfxname" required="false" type="string" hint="Specifies a CFX tag name" />
    
    <cfset var localConfig = getConfig() />
    <cfset var cfxIndex = "" />
    <cfset var returnArray = [] />
    <cfset var sortKeys = [] />
    <cfset var sortKey = {} />

    <cfset checkLoginStatus() />
    
    <!--- Make sure there are C++ CFXs --->
    <cfif !StructKeyExists(localConfig, "nativecustomtags") || !StructKeyExists(localConfig.nativecustomtags, "mapping")>
      <cfthrow message="No registered C++ CFXs" type="bluedragon.adminapi.extensions" />
    </cfif>
    
    <!--- Return entire C++ CFX array, unless a CFX name is specified --->
    <cfif !IsDefined("arguments.cfxname")>
      <!--- set the sorting information --->
      <cfset sortKey.keyName = "displayname" />
      <cfset sortKey.sortOrder = "ascending" />
      <cfset ArrayAppend(sortKeys, sortKey) />
      
      <cfreturn variables.udfs.sortArrayOfObjects(localConfig.nativecustomtags.mapping, sortKeys, false, false) />
      <cfelse>
	<cfloop index="cfxIndex" from="1" to="#ArrayLen(localConfig.nativecustomtags.mapping)#">
	  <cfif localConfig.nativecustomtags.mapping[cfxIndex].name == arguments.cfxname>
	    <cfset returnArray[1] = Duplicate(localConfig.nativecustomtags.mapping[cfxIndex]) />
	    <cfreturn returnArray />
	  </cfif>
	</cfloop>
	<cfthrow message="#arguments.cfxname# not registered as a C++ CFX" type="bluedragon.adminapi.extensions" />
    </cfif>
  </cffunction>

  <cffunction name="setCPPCFX" access="public" output="false" returntype="void" 
	      hint="Registers a C++ CFX">
    <cfargument name="displayname" type="string" required="true" hint="Name of CFX tag to show in the Administrator" />
    <cfargument name="module" type="string" required="true" hint="Library module that implments the interface" />
    <cfargument name="description" type="string" required="true" hint="Description of CFX tag" />
    <cfargument name="name" type="string" required="true" default="#arguments.displayname#" hint="Name of tag, beginning with cfx_" />
    <cfargument name="keeploaded" type="boolean" required="true" hint="Indicates if BlueDragon should keep the CFX tag in memory" />
    <cfargument name="function" type="string" required="true" hint="Name of the procedure that implements the tag" />
    <cfargument name="existingCFXName" type="string" required="true" hint="The existing CFX tag name--used on updates" />
    <cfargument name="action" type="string" required="true" hint="Action to take (create or update)" />
    
    <cfset var localConfig = getConfig() />
    <cfset var cppCFX = {} />
    <cfset var tempFile = "" />
    <cfset var temp = "" />

    <cfset checkLoginStatus() />
    
    <!--- Make sure configuration structure exists, otherwise build it --->
    <cfif !StructKeyExists(localConfig, "nativecustomtags") || !StructKeyExists(localConfig.nativecustomtags, "mapping")>
      <cfset localConfig.nativecustomtags.mapping = [] />
    </cfif>
    
    <!--- make sure we can read the module --->
    <cfset tempFile = getFullPath(arguments.module) />
    
    <cftry>
      <cffile action="read" file="#tempFile#" variable="temp" />
      <cfcatch type="any">
	<cfthrow message="An error occurred while attempting to read #tempFile#. #CFCATCH.Message#" 
		 type="bluedragon.adminapi.extensions" />
      </cfcatch>
    </cftry>

    <!--- if this is an update, delete the existing tag --->
    <cfif arguments.action == "update">
      <cfset deleteCPPCFX(LCase(arguments.existingCFXName)) />
      <cfset localConfig = getConfig() />

      <cfif !StructKeyExists(localConfig, "nativecustomtags") || !StructKeyExists(localConfig.nativecustomtags, "mapping")>
	<cfset localConfig.nativecustomtags.mapping = [] />
      </cfif>
    </cfif>
    
    <cfscript>
      cppCFX.displayname = arguments.displayname;
      cppCFX.module = arguments.module;
      cppCFX.description = arguments.description;
      cppCFX.name = LCase(arguments.name);
      cppCFX.keeploaded = ToString(arguments.keeploaded);
      cppCFX.function = arguments.function;
      
      ArrayPrepend(localConfig.nativecustomtags.mapping, structCopy(cppCFX));
      
      setConfig(localConfig);
    </cfscript>
  </cffunction>

  <cffunction name="deleteCPPCFX" access="public" output="false" returntype="void" 
	      hint="Delete a C++ CFX tag">
    <cfargument name="cfxname" required="true" type="string" hint="Specifies a CFX tag name" />
    
    <cfset var localConfig = getConfig() />
    <cfset var cfxIndex = "" />

    <cfset checkLoginStatus() />

    <!--- Make sure there are C++ CFXs --->
    <cfif !StructKeyExists(localConfig, "nativecustomtags") || !StructKeyExists(localConfig.nativecustomtags, "mapping")>
      <cfthrow message="No registered C++ CFXs" type="bluedragon.adminapi.extensions" />
    </cfif>

    <cfloop index="cfxIndex" from="1" to="#ArrayLen(localConfig.nativecustomtags.mapping)#">
      <cfif localConfig.nativecustomtags.mapping[cfxIndex].name == arguments.cfxname>
	<cfset ArrayDeleteAt(localConfig.nativecustomtags.mapping, cfxIndex) />
	<cfset setConfig(localConfig) />
	<cfreturn />
      </cfif>
    </cfloop>
    <cfthrow message="#arguments.cfxname# not registered as a C++ CFX" type="bluedragon.adminapi.extensions" />
  </cffunction>

  <cffunction name="getJavaCFX" access="public" output="false" returntype="array" 
	      hint="List the names of all registered Java CFX tags or a specified Java CFX tag">
    <cfargument name="cfxname" required="false" type="string" hint="Specifies a CFX tag name" />
    
    <cfset var localConfig = getConfig() />
    <cfset var cfxIndex = "" />
    <cfset var returnArray = [] />
    <cfset var sortKeys = [] />
    <cfset var sortKey = {} />

    <cfset checkLoginStatus() />

    <!--- Make sure there are Java CFXs --->
    <cfif !StructKeyExists(localConfig, "javacustomtags") || !StructKeyExists(localConfig.javacustomtags, "mapping")>
      <cfthrow message="No registered Java CFXs" type="bluedragon.adminapi.extensions" />
    </cfif>

    <!--- Return entire Java CFX array, unless a CFX name is specified --->
    <cfif !IsDefined("arguments.cfxname")>
      <!--- set the sorting information --->
      <cfset sortKey.keyName = "displayname" />
      <cfset sortKey.sortOrder = "ascending" />
      <cfset arrayAppend(sortKeys, sortKey) />
      
      <cfreturn variables.udfs.sortArrayOfObjects(localConfig.javacustomtags.mapping, sortKeys, false, false) />
      <cfelse>
	<cfloop index="cfxIndex" from="1" to="#ArrayLen(localConfig.javacustomtags.mapping)#">
	  <cfif localConfig.javacustomtags.mapping[cfxIndex].name == arguments.cfxname>
	    <cfset returnArray[1] = Duplicate(localConfig.javacustomtags.mapping[cfxIndex]) />
	    <cfreturn returnArray />
	  </cfif>
	</cfloop>
	<cfthrow message="#arguments.cfxname# not registered as a Java CFX" type="bluedragon.adminapi.extensions" />
    </cfif>
  </cffunction>

  <cffunction name="setJavaCFX" access="public" output="false" returntype="void" 
	      hint="Registers a Java CFX">
    <cfargument name="displayname" type="string" required="true" hint="Name of CFX tag to show in the Administrator" />
    <cfargument name="class" type="string" required="true" hint="Class name (minus .class) that implments the interface" />
    <cfargument name="description" type="string" required="true" hint="Description of CFX tag" />
    <cfargument name="name" type="string" required="true" hint="Name of tag, beginning with cfx_" />
    <cfargument name="existingCFXName" type="string" required="true" hint="The existing CFX tag name--used for updates in case the name changes" />
    <cfargument name="action" type="string" required="true" hint="The action being take (create or update)" />

    <cfset var localConfig = getConfig() />
    <cfset var javaCFX = {} />
    <cfset var javaObject = 0 />

    <cfset checkLoginStatus() />

    <!--- Make sure configuration structure exists, otherwise build it --->
    <cfif !StructKeyExists(localConfig, "javacustomtags") || !StructKeyExists(localConfig.javacustomtags, "mapping")>
      <cfset localConfig.javacustomtags.mapping = [] />
    </cfif>
    
    <!--- see if we can create an instance of the java class they're using as the custom tag --->
    <cftry>
      <cfset javaObject = CreateObject("java", arguments.class) />
      <cfcatch type="any">
	<cfthrow message="Could not instantiate the Java class for the CFX tag." 
		 type="bluedragon.adminapi.extensions" />
      </cfcatch>
    </cftry>
    
    <!--- if this is an update, delete the existing tag --->
    <cfif arguments.action == "update">
      <cfset deleteJavaCFX(LCase(arguments.existingCFXName)) />
      <cfset localConfig = getConfig() />

      <cfif !StructKeyExists(localConfig, "javacustomtags") || !StructKeyExists(localConfig.javacustomtags, "mapping")>
	<cfset localConfig.javacustomtags.mapping = [] />
      </cfif>
    </cfif>
    
    <cfscript>
      javaCFX.displayname = arguments.displayname;
      javaCFX.class = arguments.class;
      javaCFX.description = arguments.description;
      javaCFX.name = LCase(arguments.name);
      
      ArrayPrepend(localConfig.javacustomtags.mapping, structCopy(javaCFX));
      
      setConfig(localConfig);
    </cfscript>
  </cffunction>

  <cffunction name="deleteJavaCFX" access="public" output="false" returntype="void" 
	      hint="Delete a Java CFX tag">
    <cfargument name="cfxname" required="true" type="string" hint="Specifies a CFX tag name" />
    
    <cfset var localConfig = getConfig() />
    <cfset var cfxIndex = "" />

    <cfset checkLoginStatus() />

    <!--- Make sure there are Java CFXs --->
    <cfif !StructKeyExists(localConfig, "javacustomtags") || !StructKeyExists(localConfig.javacustomtags, "mapping")>
      <cfthrow message="No registered Java CFXs" type="bluedragon.adminapi.extensions" />
    </cfif>

    <cfloop index="cfxIndex" from="1" to="#ArrayLen(localConfig.javacustomtags.mapping)#">
      <cfif localConfig.javacustomtags.mapping[cfxIndex].name == arguments.cfxname>
	<cfset ArrayDeleteAt(localConfig.javacustomtags.mapping, cfxIndex) />
	<cfset setConfig(localConfig) />
	<cfreturn />
      </cfif>
    </cfloop>
    <cfthrow message="#arguments.cfxname# not registered as a Java CFX" type="bluedragon.adminapi.extensions" />
  </cffunction>
  
  <cffunction name="verifyCFXTag" access="public" output="false" returntype="void" 
	      hint="Verifies a CFX tag by instantiating the Java class or doing a file read on the specified DLL">
    <cfargument name="cfxname" required="true" type="string" hint="The CFX tag name" />
    <cfargument name="type" required="true" type="string" hint="The type of CFX tag to verify (java or cpp)" />
    
    <cfset var cfxTag = 0 />
    <cfset var tempFile = "" />
    <cfset var temp = 0 />

    <cfset checkLoginStatus() />
    
    <cfif arguments.type == "java">
      <cftry>
	<cfset cfxTag = getJavaCFX(arguments.cfxname).get(0) />
	<cfcatch type="any">
	  <cfthrow message="An error occurred while retrieving the Java CFX tag information from the server configuration. #CFCATCH.Message#" 
		   type="bluedragon.adminapi.extensions" />
	</cfcatch>
      </cftry>
      
      <cftry>
	<cfset temp = CreateObject("java", cfxTag.class) />
	<cfcatch type="any">
	  <cfthrow message="Could not instantiate the Java class for the CFX tag." 
		   type="bluedragon.adminapi.extensions" />
	</cfcatch>
      </cftry>
      <cfelseif arguments.type == "cpp">
	<cfset cfxTag = getCPPCFX(arguments.cfxname) />
	
	<cftry>
	  <cfset cfxTag = getCPPCFX(arguments.cfxname).get(0) />
	  <cfcatch type="any">
	    <cfthrow message="An error occurred while retrieving the C++ CFX tag information from the server configuration. #CFCATCH.Message#" 
		     type="bluedragon.adminapi.extensions" />
	  </cfcatch>
	</cftry>
	
	<cfif Left(cfxTag.module, 1) == "$">
	  <cfset tempFile = Right(cfxTag.module, Len(cfxTag.module) - 1) />
	  <cfelse>
	    <cfset tempFile = ExpandPath(cfxTag.module) />
	</cfif>
	
	<cftry>
	  <cffile action="read" file="#tempFile#" variable="temp" />
	  <cfcatch type="any">
	    <cfthrow message="An error occurred while attempting to read #tempFile#. #CFCATCH.Message#" 
		     type="bluedragon.adminapi.extensions" />
	  </cfcatch>
	</cftry>
    </cfif>
  </cffunction>

</cfcomponent>
