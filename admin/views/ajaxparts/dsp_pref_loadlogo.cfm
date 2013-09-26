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

<cfif isdefined("url.remove")>
	<cfdirectory action="delete" directory="#pathoneup#/global/host/logo/#session.hostid#" recurse="true">
</cfif>

<cfoutput>
	<cfif directoryexists("#pathoneup#global/host/logo/#session.hostid#")>
		<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" width="200" height="29" border="0" />
	<cfelse>
		<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="220" height="34" border="0">
	</cfif>
</cfoutput>