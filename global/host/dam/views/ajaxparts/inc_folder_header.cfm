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
		<cfif structkeyexists(attributes,"share") AND attributes.share EQ "T">
			<p><a href="#myself#c.share&fid=#session.fid#">#myFusebox.getApplicationData().defaults.trans("Back to share")#</a></p>
		<cfelse>
			<cfloop list="#qry_breadcrumb#" delimiters=";" index="i">/ <a href="##" onclick="razunatreefocusbranch('#ListGetAt(i,3,"|")#','#ListGetAt(i,2,"|")#');loadcontent('rightside','#myself#c.folder&folder_id=#ListGetAt(i,2,"|")#');">#ListGetAt(i,1,"|")#</a> </cfloop>
			<br />
		</cfif>
		<cfif attributes.issearch>
			<cfset transvalues[1] = qry_filecount.thetotal>#myFusebox.getApplicationData().defaults.trans(transid="search_returned",values=transvalues)#
			<br />
		</cfif>
		<cfif session.theuserid NEQ qry_user.folder_owner AND (!structkeyexists(attributes,"share") OR attributes.share EQ "F")><cfset transvalues[1] = qry_user.user>#myFusebox.getApplicationData().defaults.trans(transid="shared_folder_with_you",values=transvalues)#</cfif>
	</div>
</cfoutput>