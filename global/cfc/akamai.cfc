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
	
	<!--- INIT --->
	<cffunction name="init" returntype="akamai" access="public" output="false">
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<!--- Create token --->
	<cffunction name="createToken" access="private" output="false">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Check for windows --->
		<cfinvoke component="global" method="isWindows" returnvariable="isWindows" />
		<cfif isWindows>
			<cfset var theext = ".bat">
			<cfset var theperl = "perl.exe">
		<cfelse>
			<cfset var theext = ".sh">
			<cfset var theperl = "perl">
		</cfif>
		<!--- Temp ID --->
		<cfset var tid = createUUID("") & theext>
		<!--- Path to executable --->
		<cfset var exe = "#expandPath("../")#akamai/perl/">
		<!--- Write Execute --->
		<cfset var thef = "cd #exe# && #theperl# #exe#akam-edge-auth-url.pl #arguments.thestruct.thetype#/#arguments.thestruct.thefilename# uploadkey 10000 #application.razuna.akatoken#">
		<!--- Write script --->
		<cffile action="write" file="#getTempDirectory()##tid#" output="#thef#" mode="777" />
		<!--- Execute --->
		<cfexecute name="#getTempDirectory()##tid#" variable="thetoken" timeout="60" />
		<!--- Trim output --->
		<cfset var thetoken = reReplaceNoCase(thetoken, "[\r\n]", "", "all")>
		<cfset var thetoken = trim(thetoken)>
		<cfset var thetoken = listlast(thetoken," ")>
		<!--- Delete script --->
		<cffile action="delete" file="#tid#" />
		<!--- Log  --->
		<cflog application="no" file="akamai" type="Information" text="Token: #thetoken#">
		<!--- Return --->
		<cfreturn thetoken />
	</cffunction>

	<!--- UPLOAD --->
	<cffunction name="upload" access="public" output="false" returntype="void">
		<cfargument name="theasset" type="string" required="true" />
		<cfargument name="thetype" type="string" required="true" />
		<cfargument name="theurl" type="string" required="true" />
		<cfargument name="thefilename" type="string" required="true" />
		<!--- Get token --->
		<cfset var thetoken = createToken(arguments)>
		<!--- Check for windows --->
		<cfinvoke component="global" method="isWindows" returnvariable="isWindows" />
		<cfif isWindows>
			<cfset var theext = ".bat">
			<cfset var thecurl = "curl.exe">
		<cfelse>
			<cfset var theext = ".sh">
			<cfset var thecurl = "curl">
		</cfif>
		<!--- Temp ID --->
		<cfset var p = createUUID("") & theext>
		<cfset var t = "#getTempDirectory()##p#">
		<!--- Write Execute --->
		<cfset var e = "#thecurl# --data-binary @#arguments.theasset# #arguments.theurl##thetoken#">
		<!--- Write script --->
		<cffile action="write" file="#t#" output="#e#" mode="777" />
		<!--- Execute --->
		<cfexecute name="#t#" variable="cf" timeout="900" />
		<!--- Delete script --->
		<cffile action="delete" file="#t#" />
		<!--- Log  --->
		<cflog application="no" file="akamai" type="Information" text="Upload: #cf#">
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Download --->
	<cffunction name="delete" access="public" output="true">
		<cfargument name="theasset" type="string" required="true" />
		<cfargument name="thetype" type="string" required="true" />
		<cfargument name="theurl" type="string" required="true" />
		<cfargument name="thefilename" type="string" required="true" />
		<!--- Get token --->
		<cfset var thetoken = createToken(arguments)>
		<!--- Check for windows --->
		<cfinvoke component="global" method="isWindows" returnvariable="isWindows" />
		<cfif isWindows>
			<cfset var theext = ".bat">
			<cfset var thecurl = "curl.exe">
		<cfelse>
			<cfset var theext = ".sh">
			<cfset var thecurl = "curl">
		</cfif>
		<!--- Temp ID --->
		<cfset var p = createUUID("") & theext>
		<cfset var t = "#getTempDirectory()##p#">
		<!--- Write Execute --->
		<cfset var e = "#thecurl# -XDELETE #arguments.theurl##thetoken#">
		<!--- Write script --->
		<cffile action="write" file="#t#" output="#e#" mode="777" />
		<!--- Execute --->
		<cfexecute name="#t#" variable="cf" timeout="900" errorVariable="y" />
		<!--- Delete script --->
		<cffile action="delete" file="#t#" />
		<!--- Log  --->
		<cflog application="no" file="akamai" type="Information" text="Delete: #cf#">
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
</cfcomponent>
