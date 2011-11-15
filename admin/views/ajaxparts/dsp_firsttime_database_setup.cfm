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
<div>
	<span class="loginform_header">Setup the database</span>
	<br />
	Please choose from the below actions what to do next.
	<br />
	<br />
	<a href="##" onclick="loadcontent('load_steps','#myself#c.first_time_paths&type=#session.firsttime.type#');" class="first_time_hoover">
		<span class="loginform_header">Continue database setup with new data</span>
		<br />
		Choose this if you want to setup Razuna for the first time and need an empty database to start with.
		<br />
		<div style="float:right;padding:5px;"><input type="button" id="standard" value="Setup database" class="button" style="width:150px;"></div>
	</a>
	<a href="##" onclick="loadcontent('load_steps','#myself#c.first_time_database_restore');" class="first_time_hoover">
		<span class="loginform_header">Restore from Backup</span>
		<br />
		Use data from a previous instance of Razuna. If you are upgrading or replicating Razuna you probably want to select this option.
		<br />
		<div style="float:right;padding:5px;"><input type="button" id="standard" value="Restore from Backup" class="button" style="width:150px;"></div>
		<br />
		<br />
	</a>
</div>
<!---
<div>
	<div style="float:left;padding:20px 0px 0px 0px;">
		<input type="button" id="next" value="#defaultsObj.trans("back")#" onclick="loadcontent('load_steps','#myself#c.first_time_database_config');" class="button">
	</div>
</div>
--->

</cfoutput>

</div>
