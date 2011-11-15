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
<cfcomponent displayname="WebServices" 
	     output="false" 
	     extends="Base" 
	     hint="Manages web services - OpenBD Admin API">
  
  <!--- PUBLIC METHODS --->
  <cffunction name="setWebService" access="public" output="false" returntype="void" 
	      hint="Creates or updates a web service">
    <cfargument name="name" type="string" required="true" hint="OpenBD web service name" />
    <cfargument name="wsdl" type="string" required="true" hint="WSDL URL" />
    <cfargument name="username" type="string" required="false" default="" hint="Web service user name" />
    <cfargument name="password" type="string" required="false" default="" hint="Web service password" />
    <cfargument name="action" type="string" required="true" hint="The action to perform (create or update)" />
    <cfargument name="existingWebServiceName" type="string" required="false" default="" hint="The existing web service name; used on updates" />
    
    <cfset var localConfig = getConfig() />
    <cfset var webService = {} />
    <cfset var webServiceVerified = false />
    <cfset var testWS = "" />

    <cfset checkLoginStatus() />
    
    <!--- make sure configuration structure exists, otherwise build it --->
    <cfif !StructKeyExists(localConfig, "webservices") || !StructKeyExists(localConfig.webservices, "webservice")>
      <cfset localConfig.webservices.webservice = [] />
    </cfif>

    <!--- if the web service already exists and this isn't an update, throw an error --->
    <cfif arguments.action == "create" && webServiceExists(arguments.name) ||
	  (arguments.action == "update" && arguments.name != arguments.existingWebServiceName)>
      <cfthrow message="A web service with that name already exists" type="bluedragon.adminapi.webservices" />
    </cfif>
    
    <!--- try to hit the web service and throw error if we can't --->
    <cftry>
      <cfobject name="testWS" type="webservice" webservice="#Trim(arguments.wsdl)#" 
		username="#arguments.username#" password="#arguments.password#" />
      <cfcatch type="any">
	<cfrethrow />
      </cfcatch>
    </cftry>
    
    <!--- if this is an update, delete the existing web service --->
    <cfif arguments.action is "update">
      <cfset deleteWebService(arguments.existingWebServiceName) />
      <cfset localConfig = getConfig() />
      
      <!--- if we're editing the only remaining web service, need to recreate the web service struture --->
      <cfif !StructKeyExists(localConfig, "webservices") || !StructKeyExists(localConfig.webservices, "webservice")>
	<cfset localConfig.webservices.webservice = [] />
      </cfif>
    </cfif>
    
    <!--- build up the web service info --->
    <cfscript>
      webservice.name = Trim(LCase(arguments.name));
      webservice.displayname = Trim(arguments.name);
      webservice.wsdl = Trim(arguments.wsdl);
      webservice.username = Trim(arguments.username);
      webservice.password = Trim(arguments.password);
      
      // prepend the new datasource to the localconfig array
      ArrayPrepend(localConfig.webservices.webservice, structCopy(webservice));
      
      // update the config
      setConfig(localConfig);
    </cfscript>
  </cffunction>

  <cffunction name="getWebServices" access="public" output="false" returntype="array" 
	      hint="Returns an array containing all the web services or a specified web service">
    <cfargument name="webService" type="string" required="false" default="" hint="The name of the web service to return" />
    
    <cfset var localConfig = getConfig() />
    <cfset var returnArray = "" />
    <cfset var webServiceIndex = "" />
    <cfset var sortKeys = [] />
    <cfset var sortKey = {} />

    <cfset checkLoginStatus() />
    
    <!--- Make sure there are web services --->
    <cfif !StructKeyExists(localConfig, "webservices") || !StructKeyExists(localconfig.webservices, "webservice")>
      <cfthrow message="No registered web services" type="bluedragon.adminapi.webservices" />
    </cfif>
    
    <!--- Return entire web service array, unless a web service is specified --->
    <cfif !StructKeyExists(arguments, "webService") || arguments.webservice == "">
      <!--- set the sorting information --->
      <cfset sortKey.keyName = "name" />
      <cfset sortKey.sortOrder = "ascending" />
      <cfset ArrayAppend(sortKeys, sortKey) />
      
      <cfreturn variables.udfs.sortArrayOfObjects(localConfig.webservices.webservice, sortKeys, false, false) />
      <cfelse>
	<cfset returnArray = [] />
	<cfloop index="webServiceIndex" from="1" to="#ArrayLen(localConfig.webservices.webservice)#">
	  <cfif localConfig.webservices.webservice[webServiceIndex].name == arguments.webService>
	    <cfset returnArray[1] = Duplicate(localConfig.webservices.webservice[webServiceIndex]) />
	    <cfreturn returnArray />
	  </cfif>
	</cfloop>
	<cfthrow message="#arguments.name# not registered as a web service" type="bluedragon.adminapi.webservices" />
    </cfif>
  </cffunction>
  
  <cffunction name="webServiceExists" access="public" output="false" returntype="boolean" 
	      hint="Returns a boolean indicating whether or not a web service with the specified name exists">
    <cfargument name="webService" type="string" required="true" hint="The web service name to check" />
    
    <cfset var webServiceExists = true />
    <cfset var localConfig = getConfig() />
    <cfset var i = 0 />

    <cfset checkLoginStatus() />
    
    <cfif !StructKeyExists(localConfig, "webservices")>
      <!--- no web services at all, so this one doesn't exist ---->
      <cfset webServiceExists = false />
      <cfelse>
	<cfloop index="i" from="1" to="#ArrayLen(localConfig.webservices.webservice)#">
	  <cfif localConfig.webservices.webservice[i].name == Trim(lcase(arguments.webService))>
	    <cfset webServiceExists = true />
	    <cfbreak />
	    <cfelse>
	      <cfset webServiceExists = false />
	  </cfif>
	</cfloop>
    </cfif>
    
    <cfreturn webServiceExists />
  </cffunction>
  
  <cffunction name="deleteWebService" access="public" output="false" returntype="void" 
	      hint="Deletes the specified web service">
    <cfargument name="webService" required="true" type="string" hint="The name of the web service to be deleted" />
    
    <cfset var localConfig = getConfig() />
    <cfset var webServiceIndex = 0 />

    <cfset checkLoginStatus() />

    <!--- Make sure there are datasources --->
    <cfif !StructKeyExists(localConfig, "webservices")>
      <cfthrow message="No web services defined" type="bluedragon.adminapi.webservices" />		
    </cfif>

    <cfloop index="webServiceIndex" from="1" to="#ArrayLen(localConfig.webservices.webservice)#">
      <cfif localConfig.webservices.webservice[webServiceIndex].name == arguments.webservice>
	<cfset ArrayDeleteAt(localConfig.webservices.webservice, webServiceIndex) />
	<cfset setConfig(localConfig) />
	<cfreturn />
      </cfif>
    </cfloop>
    
    <cfthrow message="#arguments.webService# not registered as a web service" type="bluedragon.adminapi.webservices" />
  </cffunction>
  
  <cffunction name="verifyWebService" access="public" output="false" returntype="boolean" 
	      hint="Verifies a web service">
    <cfargument name="webService" type="string" required="true" hint="Web service name to verify" />
    
    <cfset var verified = false />
    <cfset var theWebService = getWebServices(arguments.webservice).get(0) />
    <cfset var testWS = "" />

    <cfset checkLoginStatus() />
    
    <!--- try to hit the web service and throw error if we can't --->
    <cftry>
      <cfobject name="testWS" type="webservice" webservice="#theWebService.wsdl#" 
		username="#theWebService.username#" password="#theWebService.password#" />
      <cfset verified = true />
      <cfcatch type="any">
	<cfrethrow />
      </cfcatch>
    </cftry>
    
    <cfreturn verified />
  </cffunction>
  
</cfcomponent>
