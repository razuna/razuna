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
<table border="0" cellpadding="0" cellspacing="0" class="gridno" width="587">
	
	<cfloop query="xml_langs">
		<!--- Upper Case Lang name --->
		<cfset upname = "#ucase(mid(name,1,1))##listfirst(mid(name,2,20),".")#">
		<!--- Get Lang ID --->
		<cfinvoke component="global.cfc.defaults" method="propertiesfilelangid" thetransfile="#pathoneup#/global/translations/#name#/HomePage.properties" returnvariable="lang_id">
		<tr>
			<td width="1%" nowrap="true"><input type="checkbox" name="langs_selected" value="#lang_id#_#upname#"<cfif lang_id EQ 1> checked="checked"</cfif>></td>
			<td width="100%">#upname#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>