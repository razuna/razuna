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
	<!--- <div>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tablepanel">
			<tr>
				<th colspan="2">#defaultsObj.trans("goto")#</th>
			</tr>
			<tr>
				<td><img src="images/men_goto.png" border="0"></td>
				<td valign="top"><a href="../#defaultsObj.hostpath("#application.razuna.datasource#")#/dam/" target="_blank"><span style="font-size:15px;font-weight:bold;">#defaultsObj.trans("intraextra")#</span></a><!--- <br /><br /><a href="../#defaultsObj.hostpath("#application.razuna.datasource#")#/web/" target="_blank"><span style="font-size:15px;font-weight:bold;">#defaultsObj.trans("website")#</span></a> ---></td>
			</tr>
		</table>
	</div>
	<br> --->
	<div id="tabs_mainmenu">
		<ul>
			<li><a href="##">Settings</a></li>
		</ul>
		<div id="setup"><img src="images/loading.gif" border="0" style="padding:10px;"></div>
	</div>
	
<script language="JavaScript" type="text/javascript">
	jqtabs("tabs_mainmenu");
	loadcontent('setup','#myself#ajax.menu_settings');
</script>
</cfoutput>
