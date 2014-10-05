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
<cfcomponent output="false" extends="authentication">

	<cffunction name="gethosts" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<cfset var thexml ="">
		<!--- If ISP --->
		<cfif application.razuna.api.isp>
			<cfset var thesession = false>
		</cfif>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in sysadmin --->
			<cfif listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT host_id, host_name, host_path, host_db_prefix, host_shard_group
				FROM hosts
				</cfquery>
			<!--- User not systemadmin --->
			<cfelse>
				<cfset var thexml = noaccess()>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<cffunction name="gethostsize" access="remote" output="false" returntype="struct" returnformat="JSON" hint="return size of host(s)">
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="host_id" required="false" type="numeric">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- If ISP --->
		<cfif application.razuna.api.isp>
			<cfset var thesession = false>
		</cfif>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in sysadmin --->
			<cfif listFind(session.thegroupofuser,"1",",") GT 0>
				<cfset var thestruct = structnew()>
				<cfset var pathoneup = ExpandPath("../")>
				<cfobject component="global.cfc.hosts" name="hobj"> <!--- Instantiate hosts object for access to its functions --->
				<!--- Get list of hosts --->
				<cfquery datasource="#application.razuna.api.dsn#" name="gethosts" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
				SELECT host_id
				FROM hosts
				<cfif structkeyexists(arguments,"host_id")>
					WHERE host_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.host_id#">
				</cfif>
				</cfquery>
				<cftry>
					<cfloop query="gethosts">
						<!--- Get host size  --->
						<cfset thestruct["#gethosts.host_id#"] = hobj.gethostsize(gethosts.host_id)> 
					</cfloop>
					<cfcatch type="any">
						<cfset thestruct.responsecode = 1>
						<cfset thestruct.message = "Error occurred: #cfcatch.message#, #cfcatch.detail#">
					</cfcatch>
				</cftry>
			<!--- User not systemadmin --->
			<cfelse>
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset thestruct = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thestruct>
	</cffunction>
</cfcomponent>