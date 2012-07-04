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
	<form name="form_plugins" id="form_plugins" method="post" action="#self#">
		<input type="hidden" name="#theaction#" value="c.prefs_global_save">
		<div id="tabs_plugins">
			<ul>
				<!--- Page --->
				<li><a href="##plugins">Plugins</a></li>
				<!--- plugins_add --->
				<li><a href="##plugins_add">#defaultsObj.trans("add_new")#</a></li>
				
			</ul>
			<!--- Plugins Main page --->
			<div id="plugins">
				List them here
			</div>
			<!--- New --->
			<div id="plugins_add"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
			
		</div>
	</form>

	<!--- Activate the Tabs --->
	<script language="JavaScript" type="text/javascript">
		jqtabs("tabs_plugins");
	</script>
</cfoutput>