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
<!--- For custom views make a new application so that the session and application scopes don't get mixed with regular DAM scopes --->
<cfif cgi.http_referer contains 'c.view_custom' or cgi.query_string contains 'c.view_custom' >
	<cfset appname = '_cv'>
<cfelse> 
	<cfset appname = "">	
</cfif>
<cfset attributes.cfapplicationname = getCurrentTemplatePath() & appname>
<cfinclude template="/global/host/dam/index.cfm" />