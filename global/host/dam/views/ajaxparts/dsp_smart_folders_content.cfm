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
	<!--- If empty ID --->
	<cfif attributes.sf_id EQ 0>
		<h2>#myFusebox.getApplicationData().defaults.trans("sf_content_right_when_empty")#</h2>
	<cfelse>
		<!--- If NOT for search --->
		<cfif qry_sf.sfprop.sf_prop_id NEQ "searchtext">
			<!--- Check access --->
			<cfif attributes.folderaccess EQ "n">
				<h3>You don't have access to this folder!</h3>
			<cfelse>
				<!--- Settings --->
				<cfif attributes.folderaccess EQ "x">
					<div style="padding-bottom:20px;">
						<a href="##" onclick="$('##rightside').load('#myself#c.smart_folders_settings&sf_id=#attributes.sf_id#');">#myFusebox.getApplicationData().defaults.trans("sf_smart_folders_settings")#</a>
					</div>
				</cfif>
				<!--- Load external accounts here --->
				<div id="sf_account"><img src="#dynpath#/global/host/dam/images/loading-bars.gif" border="0" style="padding:10px;"></div>
				<script type="text/javascript">
					$('##sf_account').load('#myself#c.sf_load_account', { sf_id: "#qry_sf.sf.sf_id#", sf_type: "#qry_sf.sf.sf_type#" })
				</script>
			</cfif>
		<!--- If this is a saved search --->
		<cfelseif qry_sf.sfprop.sf_prop_id EQ "searchtext">
			<!--- This loads the search --->
			<div id="sf_search"><div style="padding-top:10px;font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("search_loading")#</div></div>
			<script type="text/javascript">
				<cfif qry_sf.sfprop.sf_prop_id EQ "searchtext">
					$('##sf_search').load('#myself#c.search_simple', { folder_id:"0", searchtext: "#qry_sf.sfprop.sf_prop_value#", from_sf: true, sf_id: "#qry_sf.sf.sf_id#" });
				</cfif>
			</script>
		</cfif>
	</cfif>
</cfoutput>
