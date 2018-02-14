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

	<!--- set application name based on the directory path --->
	<cfset this.name = hash(right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'),64))>
	<cfset this.sessionmanagement="Yes">
	<cfset this.sessiontimeout="#CreateTimeSpan(14,0,0,0)#">
	<cfset this.setClientCookies="yes">

	<cffunction name="onApplicationStart">
		<!--- <cfquery datasource="razuna_default" name="x">
		select * from razuna_config
		</cfquery>
		<cfset cacheregionnew(
			region="razcache",
			props= {
				type : 'memcached',
				server : '127.0.0.1:11211',
				waittimeseconds : 5
			}
		)>
		<cfset application.sessionstorage="memcached://127.0.0.1:11211"> --->
		<cfreturn true>
	</cffunction>

	<cffunction name="onRequestStart">
		<!--- <cfset consoleoutput(true)>


		<cfset var _absolute_path = ExpandPath("../")>

		<cfset var _file = _absolute_path & 'global/config/app_config.json.cfm'>

		<!--- <cfset var _config = GetProfilesections(_absolute_path & 'global/config/app_config.ini')> --->
		<cfset var _config = Jsonfileread( _file )>
		<!--- <cfset console( _config.cache )> --->
		<cfdump var="#_config#">

		<cfset _config.database.bla = "Schnecke">

		<cfset var _json = Serializejson(_config)>

		<cffile action="write" file="#_file#" output="#_json#" >

		<cfabort> --->
		<cfif cgi.http_host CONTAINS "local" OR cgi.http_host CONTAINS "127.0.0.1">
			<cfset application.fusebox.mode = "development-full-load">
			<cflock name="#application.applicationname#" timeout="120" type="exclusive">
				<cfinclude template="/fusebox5/corefiles/fusebox5.cfm" />
			</cflock>
		<cfelse>
			<cfset application.fusebox.mode = "production">
			<cfinclude template="/fusebox5/corefiles/fusebox5.cfm" />
		</cfif>
	</cffunction>

</cfcomponent>