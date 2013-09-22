<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false">

	<cfset this.name = "#right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'),64)#">
	<cfset this.sessionManagement = true>

	<!--- Application Settings --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">
		
		<!--- Set where Lucene is located --->
		<cfset application.razuna.api.lucene = "global.cfc.lucene">

		<!--- Check for config file --->
		<cfif fileexists("#ExpandPath(".")#/config/config.cfm")>
			<!--- Get value --->
			<cfset loc = trim(getProfileString("#ExpandPath(".")#/config/config.cfm", "default", "location"))>
			<!--- If value is empty then reset --->
			<cfif loc NEQ "">
				<cfset application.razuna.api.lucene = loc>
			</cfif>
		</cfif>

		<!--- Set HTTP or HTTPS --->
		<cfif cgi.HTTPS EQ "on" OR cgi.http_x_https EQ "on">
			<cfset application.razuna.api.thehttp = "https://">
		<cfelse>
			<cfset application.razuna.api.thehttp = "http://">
		</cfif>
		
		<!--- Application vars --->
		<cfset application.razuna.api.theurl = "#application.razuna.api.thehttp#" & cgi.http_host & "/assets/">
		<cfset application.razuna.api.thispath = ExpandPath(".")>
		
		<!--- Dynamic path --->
		<cfif listfirst(cgi.SCRIPT_NAME,"/") EQ "razuna">
			<cfset application.razuna.api.dynpath = "/razuna">
		<cfelse>
			<cfset application.razuna.api.dynpath = "">
		</cfif>
		
		<!--- Get config values --->
		<cfinvoke component="global.cfc.settings" method="getconfigdefaultapi" />
		<!--- Return --->
		<cfreturn true>
	</cffunction>
	
	<!--- Nothing else below here for you to take care off! --->

	<cffunction name="onSessionStart" output="false">
		<!--- Session vars --->
		<cfparam name="session.offset" default="0">
		<cfparam name="session.rowmaxpage" default="25">
		<cfparam name="session.sortby" default="name">
	</cffunction>

	<cffunction name="onError" returntype="string">
	    <cfargument name="Exception" required="true">
	    <cfargument type="String" name="EventName" required="true">
	    <!--- Log all errors. --->
	    <cflog file="api" type="error" text="Event Name: #Arguments.Eventname#" >
	    <cflog file="api" type="error" text="Message: #Arguments.Exception.message#">
	    <cflog file="api" type="error" text="Root Cause Message: #Arguments.Exception.rootcause.message#">
	    <!--- Display an error message if there is a page context. --->
	    <cfif NOT (Arguments.EventName IS "onSessionEnd") OR (Arguments.EventName IS "onApplicationEnd")>
		    <cfset x = structnew()>
		    <cfset x.message = Arguments.Exception.rootcause.message>
		    <cfset x.errorcode = Arguments.Exception.rootcause.errorcode>
		    <cfset x.detail = Arguments.Exception.rootcause.detail>
		    <cfoutput>#serializejson(x)#</cfoutput>
	    </cfif>
	</cffunction>
</cfcomponent>