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
<cfcomponent output="false" extends="extQueryCaching">

	<!--- Get all plugins --->
	<cffunction name="getall">
		<cfargument name="pathoneup" type="string" required="true">
		<!--- plugin path --->
		<cfset var pp = "#arguments.pathoneup#global/plugins">
		<!--- List plugins in this directory --->
		<cfdirectory action="list" directory="#pp#" name="plugindirs" recurse="false" type="dir" />
		<!--- Loop over directory list and add to db --->
		<cfloop query="plugindirs">
			<!--- If conf directory exists --->
			<cfif directoryExists("#directory#/#name#/conf")>
				<cfdump var="#getProfileString("#directory#/#name#/conf/config.ini", "information", "id")#">
			</cfif>
		</cfloop>
		<cfabort>
		<cfreturn result>
	</cffunction>
	
</cfcomponent>