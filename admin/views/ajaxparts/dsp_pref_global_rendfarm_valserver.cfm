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
<cfoutput>
<cfif attributes.server_name NEQ "">
	<cfhttp url="#attributes.server_name#" timeout="20" throwOnError="no" />
		<cfif cfhttp.statuscode CONTAINS "200">
			<span style="color:green;font-weight:bold;">#defaultsObj.trans("server_validated")#</span>
		<cfelse>
			<span style="color:red;font-weight:bold;">#defaultsObj.trans("server_problem")# #cfhttp.errordetail#</span>
		</cfif>
	<cfelse>
		<span style="color:red;font-weight:bold;">#defaultsObj.trans("server_name_empty")#</span>
	</cfif>
</cfoutput>