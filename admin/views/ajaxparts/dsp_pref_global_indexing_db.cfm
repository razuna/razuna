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
	<h2>Search Server Database Connection</h2>
	<p>The search server is its own application. However, it shares the same database connection as Razuna. If you are upgrading Razuna or feel that the connection is not properly established you can configure the database connection here.</p>
	<p>
		Please select your database from the below selection:
	</p>
	<p>
		<input type="radio" id="db_type" name="db_type" value="h2" onclick="db_info(false)"<cfif qry_options.ss_db_type EQ "" OR qry_options.ss_db_type EQ "h2"> checked="checked"</cfif>> Razuna uses the internal database
	</p>
	<p>
		<input type="radio" id="db_type" name="db_type" value="mysql" onclick="db_info(true)"<cfif qry_options.ss_db_type EQ "mysql"> checked="checked"</cfif>> Razuna uses MySQL
	</p>
	<p>
		<input type="radio" id="db_type" name="db_type" value="mssql" onclick="db_info(true)"<cfif qry_options.ss_db_type EQ "mssql"> checked="checked"</cfif>> Razuna uses MS SQL
	</p>
	<div id="ss_db" style="display:none;">
		<h3>Enter the database credentials:</h3>
		<strong>Database Name</strong> 
		<br />
		<input name="db_name" id="db_name" type="text" class="text" size="30" value="#qry_options.ss_db_name#">
		<br />
		<strong>Database Server (IP or Host)</strong> 
		<br />
		<input name="db_server" id="db_server" type="text" class="text" size="30" value="#qry_options.ss_db_server#">
		<br />
		<strong>Server Port</strong> 
		<br />
		<input name="db_port" id="db_port" type="text" class="text" size="10" value="#qry_options.ss_db_port#">
		<br />
		<strong>Database Schema</strong> 
		<br />
		<input name="db_schema" id="db_schema" type="text" class="text" size="30" value="#qry_options.ss_db_schema#">
		<br />
		<strong>#defaultsObj.trans("username")#</strong> 
		<br />
		<input name="db_user" id="db_user" type="text" class="text" size="30" value="#qry_options.ss_db_user#">
		<br />
		<strong>#defaultsObj.trans("password")#</strong>
		<br />
		<input name="db_pass" id="db_pass" type="password" size="30" class="text" value="#qry_options.ss_db_pass#">
	</div>
	<p>
		<br />
		<input type="button" id="submitDbButton" value="Update Connection Info" onclick="submitDbInfo();" class="button">
	</p>
</cfoutput>

<script type="text/javascript">
	// Showing db info
	function db_info(toshow) {
		if (toshow) {
			$('#ss_db').attr('style','padding-left:30px');
		}
		else {
			$('#ss_db').attr('style','display:none');
		}
	}
	// Submit to server
	function submitDbInfo() {
		// Hide button
		$('#submitDbButton').attr('style','display:none');
		// Grab values
		var db_type = $('#db_type:checked').val();
		var db_name = $('#db_name').val();
		var db_server = $('#db_server').val();
		var db_port = $('#db_port').val();
		var db_schema = $('#db_schema').val();
		var db_user = $('#db_user').val();
		var db_pass = $('#db_pass').val();
		// Submit
		$.ajax({
			type: "POST",
			url: "index.cfm?fa=c.prefs_indexing_db_submit",
		   	data: { db_type : db_type, db_name : db_name, db_server : db_server, db_port : db_port, db_schema : db_schema, db_user : db_user, db_pass : db_pass },
		   	success: function() {
		   		alert('The connection has been added successfully!');
		   	},
		   	error: function() {
		   		alert('There is a connection error with your search server!');
		   	}
		});
		return false;
	}
</script>