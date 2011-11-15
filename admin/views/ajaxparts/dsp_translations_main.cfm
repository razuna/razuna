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
	<div id="transtab" class="TabbedPanels">
		<ul class="TabbedPanelsTabGroup">
			<li class="TabbedPanelsTab">#defaultsObj.trans("translations_search")#</li>
			<li class="TabbedPanelsTab" onclick="showwindow('#myself#ajax.translations_add','#defaultsObj.trans("translations_new")#',600,1);">#defaultsObj.trans("translations_new")#</li>
		</ul>
		<div class="TabbedPanelsContentGroup">
			<!--- Search Translations --->
			<div class="TabbedPanelsContent" id="tsearch">
				<form name="tsearch" onsubmit="transsearch();return false;">
				<table width="600" border="0" cellspacing="0" cellpadding="0" class="grid">
				<tr>
				<td>ID</td>
				<td colspan="2"><input type="text" name="trans_id" id="trans_id" class="text" size="40"></td>
				</tr>
				<tr>
				<td valign="top">#defaultsObj.trans("translation")#</td>
				<td colspan="2"><textarea rows="4" cols="60" class="text" name="trans_text" id="trans_text"></textarea></td>
				</tr>
				<tr>
				<td></td>
				<td colspan="2"><input type="button" name="Button" value="#defaultsObj.trans("user_search")#" class="button" onclick="javascript:transsearch();"></td>
				</tr>
				</table>
				</form>
				<!--- The results --->
				<div id="tresults"></div>
			</div>
		</div>
	</div>
</cfoutput>

<!--- Activate the Tabs --->
<script language="JavaScript" type="text/javascript">
	var transtab = new Spry.Widget.TabbedPanels("transtab", { defaultTab: 0 });
</script>