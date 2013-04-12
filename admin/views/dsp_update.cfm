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

	<!--- Page output starts here --->
	<span class="loginform_header">Razuna Database Update Required!</span>
	<br />
	<br />
	<cfif session.updatedb>
		#defaultsObj.trans("db_update_here")#
		<br />
		<br />
		<input type="submit" name="ftsubmit" value="#defaultsObj.trans("button_update")#" class="button" onclick="showupdate();">
		<br />
		<div id="updatestatus"></div>
	<cfelse>
		#defaultsObj.trans("db_update_done")#
		<!--- <br />
		<br />
		Note: You should check the <a href="#session.thehttp# #cgi.HTTP_HOST##dynpath#/bluedragon/administrator" target="_blank">Update Logfile in the OpenBD Administration</a> for any errors before continuing! Errors with "Database already exists" are of no worries, it only means you already have the update for that one table done!  --->
		<br />
		<br />
		<input type="submit" name="ftsubmit" value="#defaultsObj.trans("button_update_continue")#" class="button" onclick="location.href='#self#';">
	</cfif>
	
	</div>
	
	<script language="JavaScript" type="text/javascript">
		function showupdate(){
			$('##updatestatus').html('Please wait...');
			location.href='#myself#c.update_do&r=' + parseInt((Math.random() * 99999999));
		}
	</script>

</cfoutput>