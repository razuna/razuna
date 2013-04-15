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
	<div id="gears_install">
		<h1>Razuna UpDrive</h1>
		<p>Razuna UpDrive is a technology based on <a href="http://code.google.com/apis/gears/" target="_blank">Gears</a>, which adds offline capabilities to your web browser.<br /><br />
		After you install and enable the plugin most of Razuna's images, scripts, and CSS files will be stored locally on your computer. This speeds up page load time.<br /><br />
		We advise you to not install this on a public or shared computer.<br /><br />
		<input type="button" name="ginstall" onclick="window.location = 'http://gears.google.com/?action=install&return=#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#';" value="Install Now" class="button"></p>
	</div>
	<div id="gears_store">
		<h1>Razuna UpDrive</h1>
		<p>Gears is installed on this computer but you have not enabled it for Razuna.<br /><br />
		Make sure that this site is not on the denied list in Gears Settings under your browser Tools menu, then click the button below.<br /><br />
		We advise you to not install this on a public or shared computer.<br />
		<div id="textOut"><p><input type="button" name="bgears" id="bgears" value="Enable UpDrive" onclick="createStore();" class="button"></p></div></p>
	</div>
	<div id="gears_done">
		<h1>Razuna UpDrive</h1>
		<p>UpDrive is installed and enabled on this computer.<br /><br />
		If there are any errors, try disabling UpDrive, then reload the page and enable it again.<br />
		<div id="textOutr"><p><input type="button" name="brgears" id="brgears" value="Remove UpDrive" onclick="removeStore();" class="button"><p></div></p>
	</div>
</cfoutput>

<script language="javascript">
	init();
</script>