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

	<cffunction name="gethosts" access="remote" output="false" returntype="String">
		<cfargument name="sessiontoken" required="true">
		<!--- Check sessiontoken --->
		<cfinvoke component="authentication" method="checkdb" sessiontoken="#arguments.sessiontoken#" returnvariable="thesession">
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query for the sysadmingroup --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qryuser">
			SELECT groupofuser
			FROM webservices
			WHERE sessiontoken = <cfqueryparam value="#arguments.sessiontoken#" cfsqltype="cf_sql_varchar">
			AND groupofuser IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="1" list="true">)
			</cfquery>
			<!--- If user is in sysadmin --->
			<cfif qryuser.recordcount NEQ 0>
				<!--- Query --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT host_id, host_name, host_path, host_db_prefix, host_shard_group
				FROM hosts
				</cfquery>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<cfloop query="qry"><host>
<id>#xmlformat(host_id)#</id>
<name>#xmlformat(host_name)#</name>
<path>#xmlformat(host_path)#</path>
<prefix>#xmlformat(host_shard_group)#</prefix>
</host>
</cfloop>
</Response></cfoutput>
				</cfsavecontent>
			<!--- User not systemadmin --->
			<cfelse>
				<!--- Create the XML --->
				<cfsavecontent variable="thexml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<Response>
<responsecode>1</responsecode>
<message>User is not a System Administrator</message>
</Response></cfoutput>
				</cfsavecontent>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfinvoke component="authentication" method="timeout" returnvariable="thexml">
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
</cfcomponent>