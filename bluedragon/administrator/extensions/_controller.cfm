<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    Matt Woodward - matt@mattwoodward.com

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
  
  <!--- stick everything in form and url into a struct for easy reference --->
  <cfset args = {} />
  
  <cfloop collection="#url#" item="urlKey">
    <cfset args[urlKey] = url[urlKey] />
  </cfloop>
  
  <cfloop collection="#form#" item="formKey">
    <cfset args[formKey] = form[formKey] />
  </cfloop>
  
  <cfswitch expression="#args.action#">
    <!--- CUSTOM TAG PATHS --->
    <cfcase value="processCustomTagPathForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Trim(args.directory) == "">
	<cfset errorFields[errorFieldsIndex][1] = "directory" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Custom Tag Path cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="customtagpaths.cfm" addtoken="false" />
      </cfif>
      
      <cftry>
	<cfset Application.extensions.setCustomTagPath(args.directory, args.customTagPathAction) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="customtagpaths.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The custom tag path was #args.customTagPathAction#d successfully" />
      <cfset session.message.type = "info" />
      <cflocation url="customtagpaths.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="deleteCustomTagPath">
      <cftry>
	<cfset Application.extensions.deleteCustomTagPath(args.directory) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="customtagpaths.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The custom tag path was deleted successfully" />
      <cfset session.message.type = "info" />
      <cflocation url="customtagpaths.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="verifyCustomTagPath">
      <cftry>
	<cfset Application.extensions.verifyCustomTagPath(args.directory) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="customtagpaths.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The custom tag path was verified successfully." />
      <cfset session.message.type = "info" />
      <cflocation url="customtagpaths.cfm" addtoken="false" />
    </cfcase>
    
    <!--- CFX TAGS --->
    <cfcase value="editJavaCFXTag">
      <cftry>
	<cfset session.cfxTag = Application.extensions.getJavaCFX(args.cfxTag).get(0) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="cfxtags.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cflocation url="javacfx.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="processJavaCFXForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Trim(args.name) == "">
	<cfset errorFields[errorFieldsIndex][1] = "name" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Tag Name cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif LCase(Left(args.name, 4)) != "cfx_">
	<cfset errorFields[errorFieldsIndex][1] = "name" />
	<cfset errorFields[errorFieldsIndex][2] = "The Tag Name must begin with cfx_" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif REFindNoCase("^([a-zA-Z0-9_-]+)$", args.name) == 0>
	<cfset errorFields[errorFieldsIndex][1] = "name" />
	<cfset errorFields[errorFieldsIndex][2] = "The Tag Name must not include special characters" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.class) == "">
	<cfset errorFields[errorFieldsIndex][1] = "class" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Class Name cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="javacfx.cfm" addtoken="false" />
      </cfif>
      
      <cftry>
	<cfset Application.extensions.setJavaCFX(args.name, args.class, 
	       args.description, args.name, 
	       args.existingCFXName, args.cfxAction) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="javacfx.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The Java CFX tag was saved successfully." />
      <cfset session.message.type = "info" />
      <cflocation url="cfxtags.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="deleteJavaCFXTag">
      <cftry>
	<cfset Application.extensions.deleteJavaCFX(args.name) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="cfxtags.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The CFX tag was deleted successfully." />
      <cfset session.message.type = "info" />
      <cflocation url="cfxtags.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="editCPPCFXTag">
      <cftry>
	<cfset session.cfxTag = Application.extensions.getCPPCFX(args.cfxTag).get(0) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="cfxtags.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cflocation url="cppcfx.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="processCPPCFXForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif Trim(args.name) == "">
	<cfset errorFields[errorFieldsIndex][1] = "name" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Tag Name cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif LCase(Left(args.name, 4)) != "cfx_">
	<cfset errorFields[errorFieldsIndex][1] = "name" />
	<cfset errorFields[errorFieldsIndex][2] = "The Tag Name must begin with cfx_" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif REFindNoCase("^([a-zA-Z0-9_-]+)$", args.name) == 0>
	<cfset errorFields[errorFieldsIndex][1] = "name" />
	<cfset errorFields[errorFieldsIndex][2] = "The Tag Name must not include special characters" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.module) == "">
	<cfset errorFields[errorFieldsIndex][1] = "module" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Module Name cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif Trim(args.function) is "">
	<cfset errorFields[errorFieldsIndex][1] = "function" />
	<cfset errorFields[errorFieldsIndex][2] = "The value of Function Name cannot be blank" />
	<cfset errorFieldsIndex++ />
      </cfif>
      
      <cfif ArrayLen(errorFields) gt 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="cppcfx.cfm" addtoken="false" />
      </cfif>
      
      <cftry>
	<cfset Application.extensions.setCPPCFX(args.name, args.module, 
	       args.description, args.name, 
	       args.keeploaded, args.function, 
	       args.existingCFXName, args.cfxAction) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="cppcfx.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The C++ CFX tag was saved successfully." />
      <cfset session.message.type = "info" />
      <cflocation url="cfxtags.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="deleteCPPCFXTag">
      <cftry>
	<cfset Application.extensions.deleteCPPCFX(args.name) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="cfxtags.cfm" addtoken="false" />
	</cfcatch>
      </cftry>
      
      <cfset session.message.text = "The CFX tag was deleted successfully." />
      <cfset session.message.type = "info" />
      <cflocation url="cfxtags.cfm" addtoken="false" />
    </cfcase>
    
    <cfcase value="verifyCFXTag">
      <cftry>
	<cfset Application.extensions.verifyCFXTag(args.name, args.type) />
	<cfcatch type="bluedragon.adminapi.extensions">
	  <cfset session.message.text = CFCATCH.Message />
	  <cfset session.message.type = "error" />
	  <cflocation url="cfxtags.cfm" addtoken="false" />
	</cfcatch>
      </cftry>

      <cfset session.message.text = "The CFX tag was verified successfully." />
      <cfset session.message.type = "info" />
      <cflocation url="cfxtags.cfm" addtoken="false" />
    </cfcase>
    
    <!--- DEFAULT CASE --->
    <cfdefaultcase>
      <cfset session.message.text = "Invalid action" />
      <cfset session.message.type = "error" />
      <cflocation url="#CGI.HTTP_REFERER#" addtoken="false" />
    </cfdefaultcase>
  </cfswitch>
</cfsilent>
