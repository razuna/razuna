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
  
  <!--- clear out old session stuff --->
  <cfset StructDelete(session, "errorFields", false) />
  <cfset StructDelete(session, "message", false) />
  
  <!--- stick everything in form and url into a struct for easy reference --->
  <cfset args = StructNew() />
  
  <cfloop collection="#url#" item="urlKey">
    <cfset args[urlKey] = url[urlKey] />
  </cfloop>
  
  <cfloop collection="#form#" item="formKey">
    <cfset args[formKey] = form[formKey] />
  </cfloop>
  
  <cfswitch expression="#args.action#">
    <!--- LOGIN --->
    <cfcase value="processLoginForm">
      <cfset errorFields = ArrayNew(2) />
      <cfset errorFieldsIndex = 1 />
      
      <cfif ArrayLen(errorFields) != 0>
	<cfset session.errorFields = errorFields />
	<cflocation url="login.cfm" addtoken="false" />
	<cfelse>
	  <!--- validate the password --->
	  <cfset passwordValid = Application.administrator.login(args.password) />
	  
	  <cfif !passwordValid>
	    <cfset StructDelete(session, "auth", false) />
	    
	    <cfset errorFields[errorFieldsIndex][1] = "password" />
	    <cfset errorFields[errorFieldsIndex][2] = "Incorrect password. Please try again." />
	    <cfset session.errorFields = errorFields />
	    
	    <cflocation url="login.cfm" addtoken="false" />
	    <cfelse>
	      <cfset session.auth.loggedIn = true />
	      <cfset session.auth.password = args.password />
	      
	      <cflocation url="index.cfm" addtoken="false" />
	  </cfif>
      </cfif>
    </cfcase>
    
    <!--- LOGOUT --->
    <cfcase value="logout">
      <cfset StructDelete(session, "auth", false) />
      
      <cfset session.message = "You have been logged out" />
      
      <cflocation url="login.cfm" addtoken="false" />
    </cfcase>
  </cfswitch>
</cfsilent>
