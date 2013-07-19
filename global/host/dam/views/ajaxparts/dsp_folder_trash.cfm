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
	<!--- Show this when user clicks on empty trash --->
	<cfif attributes.trashall>
		<span style="font-weight:bold;color:green;">#myFusebox.getApplicationData().defaults.trans("empty_trash_all_feedback")#</span>
	<!--- Show trash --->
	<cfelse>
		<div id="tabsfolder_tab">
			<ul>
				<!--- Show the trash asset and folder content--->
				<li><a href="##assets">#myFusebox.getApplicationData().defaults.trans("trash_folder_header")# (#arraySum(Count_trash['cnt'])#)</a></li>
			</ul>
			<div id="assets"></div>
		</div>
		<script type="text/javascript">
			jqtabs("tabsfolder_tab");
			$('##assets').load('#myself#c.trash_assets');
		</script>
	</cfif>
</cfoutput>
