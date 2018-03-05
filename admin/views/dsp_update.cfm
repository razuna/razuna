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
<div id="ft" style="padding:15px;">

	<cfif session.update_db_number EQ '53' AND application.razuna.thedatabase EQ "mysql">

		<h2>Welcome to the Razuna 1.9.2 update</h2>

		<p>This database update differs from others as we have to alter each table of your database as we changed the schema to be all case insensitive. This in return speeds up performance.</p>
		<p>Before you continue please make sure that you created an update of your database.</p>
		<p>Once done, please click on the update button below (you will see each step of the update).</p>
		<br />
		<p><a href="#myself#c.update_do" class="button" style="text-decoration: none;">#myFusebox.getApplicationData().defaults.trans("button_update")#</a></p>

	<cfelseif session.update_db_number EQ '53' AND application.razuna.thedatabase EQ "mssql">

		<h2>Welcome to the Razuna 1.9.2 update</h2>

		<p>This database update differs from others as we have to alter each table of your database as we changed the schema to be all case insensitive. This in return speeds up performance.</p>

		<p>However, as each MSSQL deployment is different we cannot provide an update script for you and you have to execute each step manually. Please follow the update instructions to do so in the link below.</p>

		<p><a href="http://wiki.razuna.com/display/ecp/Razuna+1.9.2">Update to Razuna 1.9.2</a></p>

	<cfelse>

		<!--- Page output starts here --->
		<span class="loginform_header">Razuna Database Update Required!</span>
		<br />
		<br />
		<cfif session.updatedb>
			#myFusebox.getApplicationData().defaults.trans("db_update_here")#
			<br />
			<br />
			<input type="submit" name="ftsubmit" value="#myFusebox.getApplicationData().defaults.trans("button_update")#" class="button" onclick="showupdate();">
			<br />
			<div id="updatestatus"></div>
		<cfelse>
			#myFusebox.getApplicationData().defaults.trans("db_update_done")#
			<!--- <br />
			<br />
			Note: You should check the <a href="#session.thehttp# #cgi.HTTP_HOST##dynpath#/bluedragon/administrator" target="_blank">Update Logfile in the OpenBD Administration</a> for any errors before continuing! Errors with "Database already exists" are of no worries, it only means you already have the update for that one table done!  --->
			<br />
			<br />
			<input type="submit" name="ftsubmit" value="#myFusebox.getApplicationData().defaults.trans("button_update_continue")#" class="button" onclick="location.href='#self#';">
		</cfif>
		
		</div>
		
		<script language="JavaScript" type="text/javascript">
			function showupdate(){
				$('##updatestatus').html('Please wait...');
				location.href='#myself#c.update_do&r=' + parseInt((Math.random() * 99999999));
			}
		</script>


	</cfif>

</cfoutput>