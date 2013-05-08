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
	<cfset pc = "">
	<strong><a href="##" onclick="$('##sf_account').load('#myself#c.sf_load_account', { sf_type: '#session.sf_account#' });return false;">Home</a> / <cfloop list="#qry_sf_list.path#" index="p" delimiters="/">
			<cfset pc = pc & "/" & p>
			<a href="##" onclick="$('##sf_account').load('#myself#c.sf_load_account', { path: '/#pc#', sf_type: '#session.sf_account#' });return false;">#p#</a> / 

		</cfloop></strong>
	<p></p>
	<cfloop array="#qry_sf_list.contents#" index="a">
		<cfif a.is_dir>
			<a href="##" onclick="$('##sf_account').load('#myself#c.sf_load_account', { path: '#a.path#', sf_type: '#session.sf_account#' });">
				<div style="float:left;padding-right:15px;">
					<img src="#dynpath#/global/host/dam/images/folder-blue-old.png" border="0">
				</div>
				<div style="float:left;padding-top:10px;font-weight:bold;">
					#listlast(a.path,"/")#
				</div>
			</a>
			<div style="clear:both;"></div>
		<cfelse>
			<div style="float:left;padding-right:15px;">
				<cfset lp = listlast(a.path,"/")>
				<cfif fileExists("#expandpath("../..")#global/host/dropbox/#session.hostid#/#lp#")>
					<img src="#attributes.thumbpath#/#lp#" border="0">
				<cfelseif a.thumb_exists AND !fileExists("#expandpath("../..")#global/host/dropbox/#session.hostid#/#lp#")>
					<span style="font-size:10px;">Fetching thumbnail and will be available soon.</span>
				</cfif>
			</div>
			<div style="float:left;padding-top:10px;font-weight:bold;">
				<a href="##">#listlast(a.path,"/")#</a>
			</div>
			<div style="clear:both;"></div>
		</cfif>
		<br />
	</cfloop><!--- 
	<cfdump var="#qry_sf_list.contents#"> --->
</cfoutput>
