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
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr class="list">
			<td colspan="3">#defaultsObj.trans("global_db_desc")#</td>
		</tr>
		<tr class="list">
			<th class="textbold" colspan="2" style="padding-top:15px;padding-bottom:15px;">You are currently using the #ucase(gprefs.conf_database)# database.</th>
		</tr>
		<tr>
			<td style="padding-top:15px;">
				<div style="background-color:yellow;padding:10px;">By clicking on the button below you will be redirected to the initial setup where you will be able to choose the database and import your settings!</div>
				<br>
				<input type="button" value="I'm ready to change the database now" onclick="if (confirm('Did you do a backup of your current setup? \n\nIf you confirm your instance will load the first time wizard where you are able to change the database and import your backup!')) location.href='#myself#c.prefs_change_db';return false;" class="button">
			</td>
		</tr>
	</table>
</cfoutput>
