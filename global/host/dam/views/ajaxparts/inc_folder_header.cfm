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
	<div style="float:left;padding-left:2px;padding-top:5px;font-weight:normal;">
		<cfif attributes.issearch>Your search returned #qry_filecount.thetotal# record(s) in this folder! | </cfif>
		<cfloop list="#qry_breadcrumb#" delimiters=";" index="i">/ <a href="##" onclick="razunatreefocusbranch('#ListGetAt(i,3,"|")#','#ListGetAt(i,2,"|")#');loadcontent('rightside','#myself#c.folder&folder_id=#ListGetAt(i,2,"|")#');">#ListGetAt(i,1,"|")#</a> </cfloop>
		<cfif session.theuserid NEQ qry_user.folder_owner>
			The user "#qry_user.user#" shared this folder with you. Your permission is: <cfif attributes.folderaccess EQ "R">Read only<cfelseif attributes.folderaccess EQ "W">Read & Write<cfelse>No Restrictions</cfif>
		</cfif>
	</div>
</cfoutput>