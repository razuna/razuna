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
<!------------------------------------------------------------------------------
Copyright (c) 2000-2002, Jochem van Dieten e.a.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
	  this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
	  this list of conditions and the following disclaimer in the documentation 
	  and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors 
	  may be used to endorse or promote products derived from this software 
	  without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE FOR ANY 
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

------------------------------------------------------------------------------->
<!--- 
|| BEGIN FUSEDOC ||

|| RESPONSIBILITIES || 
I add[edit] and delete a CF-MX mapping.
I return the list of CF-MX mappings.
I return the directory for a particular path.

|| USAGE REASONS ||
Help a program that needs a mapping to self-initialize
when it executes [the first time] on a server.

|| COMPATABILITY WITH PREVIOUS CF-VERSIONS ||
CF-5 would automatically prepend and append a "/" to your 
mapping entry, if you didn't enter one. CF-MX doesn't do that, 
but only prepends a slash ("/"). In fact, the CF-MX administrator
actually strips any trailing "/" from your mapping path.

|| WARNING ||
If you have saved a trailing slash after a mapping, like CF5 and
earlier did automatically, CF-MX won't process the mapping at all, 
even though it shows as valid in the CFAdministrator! 

|| CALLING METHOD ||
Called as a CF-MX component.

|| ATTRIBUTES [AS NEEDED] ||
==> method (string)
	valid values are:
		addMapping
		deleteMapping
		showMapping
		getMappingPath
		
==> mapping (string)
	Logical Path
	Rules seem to be:
	- Must have something
	- Must not have // (or ///, etc)
	- Must contain a-z0-9 
	- Must not end in /
	- Allow _ and -
	- Must begin with /

==> Path (string
	Physical disk path
	
|| showMappings EXAMPLE ||
<cfinvoke 
	component="cfmxmappings"
	method="showMappings"
	returnVariable="variables.stMappings">

|| getMappingPath EXAMPLE ||
<cfinvoke 
	component="cfmxmappings"
	method="getMappingPath"
	mapping="/nfroot"
	returnVariable="variables.mapPath">

|| addMapping EXAMPLE ||
<cfinvoke 
	component="cfmxmappings" 
	method="addMapping"
	mapping="/nfroot"
	path="D:\WebProjects\"
	returnVariable="variables.bSuccess"> 

|| deleteMapping EXAMPLE ||
<cfinvoke component="cfmxmappings" 
	method="deleteMapping"
	mapping="/nfroot"
	returnVariable="variables.bSuccess"> 
	
|| DESIGNER ||
Jochem van Dieten (jochem@vandieten.net)

|| FUSEDOC BROWSER ||
A very good browser to parse/display this FUSEDOC
documentation is available at bjork.net (cf_sourcebrowser)
 
|| END FUSEDOC ||
--->

<cfcomponent displayName="CFMXMappingsCFC" output="false" 
	hint="CF-MX mapping editor"
	lastUpdated="2002-08-30"
	author="Jochem van Dieten"
	authorEmail="jochem@vandieten.net"
	>

	<!--- ************************************************************************************* --->
	<!--- ************************************************************************************* --->
	<!--- Initialization --->
	<cflock name="serviceFactory" type="exclusive" timeout="10">
		<cfscript>
			this.factory = CreateObject("java", "coldfusion.server.ServiceFactory");
			this.rt_service = this.factory.runtimeservice;
			this.mappings = this.rt_service.mappings;
		</cfscript>
	</cflock>
	<cfif not IsStruct(this.mappings)>
		<cfthrow message="The template '#lcase(getfilefrompath(getcurrenttemplatepath()))#' can't initialize.">
	</cfif>
	<!--- The constant CF uses in its logical-path mapping --->
	<cfset this.MappingSlash="/">
	
	<cfscript>
	// Insure the user has a leading slash (/) on the logical mapping parameter,
	// but no trailing slash (/). This emulates the behavior the CF-MX administrator 
	// exhibits, and protects the caller from accidental invalid entries.
	// Note: this will make an 'empty' Mapping parameter a "/". 
	function fixPath(p1) {
		var temp=p1;
		// prepend a slash (if necessary)
		if ((len(temp) is 0) or (left(temp,1) is not this.MappingSlash)) {
			temp=this.MappingSlash & temp;
		}
		// remove a trailing slash (if necessary)
		if (right(temp,1) is this.MappingSlash) {
			if (len(temp) ge 2) {
				temp=left(temp,len(temp)-1);
			}
		}
		return temp;
	}
	// Validate the mapping path so we don't put a path in that the Admistrator can't work with in the future...
	// Note: We only check on the AddMapping function.
	function validatePath (p1) {
		if (find("//",p1) or reFindNoCase("[^/a-z0-9_-]",p1)) {
			return false;
		}
		return true;
	}
	</cfscript>
	
	<!--- ************************************************************************************* --->
	<!---                         GET MAPPING DIRECTORY-PATH                                    --->
	<!--- ************************************************************************************* --->
	<cffunction name="getMappingPath" access="public" output="false" returnType="string"
		hint="Returns the path of a mapping or an empty string if not found.">
		<cfargument name="mapping" type="string" required="true"
			hint="The mapping for which to search. Starts with a slash, no trailing slash.">
			<cflock name="serviceFactory" type="exclusive" timeout="10">
				<cfif StructKeyExists(this.mappings,fixpath(mapping))>
					<cfreturn this.mappings[fixPath(mapping)]>
				</cfif>
			</cflock>
			<cfreturn "">
		
	</cffunction>

	<!--- ************************************************************************************* --->
	<!---                         ADD A NEW MAPPING  [CHANGE AN EXISTING MAPPING]               --->
	<!--- ************************************************************************************* --->
	<cffunction name="addMapping" access="public" output="false" returnType="boolean"
		hint="Adds the mapping defined by the mapping and path attributes. Returns true if set successful.">
		<cfargument name="mapping" type="string" required="true"
			hint="The mapping to add. Starts with a slash (/), no trailing slash.">
		<cfargument name="path" type="string" required="true"
			hint="The absolute path of the mapping to add. Trailing (back)slash required.">

		<!--- Insure the mapping contains only characters the administrator considers valid.
			Otherwise, we could put something in here, that we couldn't EDIT (in the Administrator) later. --->
		<cfif validatePath(mapping)>
			<cflock name="serviceFactory" type="exclusive" timeout="10">
				<cfset this.mappings[fixPath(mapping)] = path>
				<cfreturn TRUE>
			</cflock>
		</cfif>
		<cfreturn FALSE>

	</cffunction>

	<!--- ************************************************************************************* --->
	<!---                         DELETE A MAPPING                                              --->
	<!--- ************************************************************************************* --->
	<cffunction name="deleteMapping" access="public" output="false" returnType="boolean"
		hint="Deletes the mapping defined by the mapping attribute.">
		<cfargument name="mapping" type="string" required="true"
			hint="The mapping to delete. Starts with a slash (/), no trailing slash.">

		<cflock name="serviceFactory" type="exclusive" timeout="10">
			<cfreturn StructDelete(this.mappings, fixPath(mapping), TRUE)>
		</cflock>

	</cffunction>
	
	<!--- ************************************************************************************* --->
	<!---                         GET ALL MAPPINGS                                              --->
	<!--- ************************************************************************************* --->
	<cffunction name="showMappings" access="public" output="false" returntype="struct"
		hint="Returns all defined mappings in a structure.">

		<cflock name="serviceFactory" type="exclusive" timeout="10">
			<cfreturn this.mappings>
		</cflock>

	</cffunction>
	
</cfcomponent>