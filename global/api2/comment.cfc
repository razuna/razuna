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

	<!--- Get all comments --->
	<cffunction name="getall" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="id" required="true">
		<cfargument name="type" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Create internal struct --->
			<cfset var s = structNew()>
			<cfset s.file_id = arguments.id>
			<cfset s.type = arguments.type>
			<!--- call internal method --->
			<cfinvoke component="global.cfc.comments" method="get" thestruct="#s#" returnVariable="thexml">
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Get one comment --->
	<cffunction name="get" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="id" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Create internal struct --->
			<cfset var s = structNew()>
			<cfset s.com_id = arguments.id>
			<!--- call internal method --->
			<cfinvoke component="global.cfc.comments" method="edit" thestruct="#s#" returnVariable="thexml">
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Add / Update comment --->
	<cffunction name="set" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="id" required="false" default="0">
		<cfargument name="id_related" required="true">
		<cfargument name="comment" required="true">
		<cfargument name="type" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Get permission for asset (folder) --->
			<cfset var folderaccess = checkFolderPerm(arguments.api_key, arguments.id_related)>
			<!--- If user has access --->
			<cfif folderaccess EQ "W" OR folderaccess EQ "X">
				<!--- Create internal struct --->
				<cfset var s = structNew()>
				<cfset s.comment = arguments.comment>
				<cfset s.file_id = arguments.id_related>
				<cfset s.type = arguments.type>
				<cfset s.com_id = arguments.id>
				<!--- For a new comment --->
				<cfif arguments.id EQ 0>
					<!--- Create new ID --->
					<cfset session.newcommentid = createuuid()>
					<!--- call internal method --->
					<cfinvoke component="global.cfc.comments" method="add" thestruct="#s#">
					<!--- Return --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Comment successfully added">
					<cfset thexml.id = session.newcommentid>
				<!--- Update --->
				<cfelse>
					<!--- call internal method --->
					<cfinvoke component="global.cfc.comments" method="update" thestruct="#s#">
					<!--- Return --->
					<cfset thexml.responsecode = 0>
					<cfset thexml.message = "Comment successfully updated">
					<cfset thexml.id = arguments.id>
				</cfif>
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Remove comment --->
	<cffunction name="remove" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="id" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If user is in admin --->
			<cfif listFind(session.thegroupofuser,"2",",") GT 0 OR listFind(session.thegroupofuser,"1",",") GT 0>
				<!--- Create internal struct --->
				<cfset var s = structNew()>
				<cfset s.id = arguments.id>
				<!--- call internal method --->
				<cfinvoke component="global.cfc.comments" method="remove" thestruct="#s#">
				<!--- Return --->
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "Comment(s) successfully removed">
			<!--- No access --->
			<cfelse>
				<!--- Return --->
				<cfset var thexml = noaccess("s")>
			</cfif>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	
	
</cfcomponent>