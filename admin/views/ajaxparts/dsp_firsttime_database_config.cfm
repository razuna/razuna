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
	<form id="form_account">
		<span class="loginform_header">#defaultsObj.trans("header_first_time_database_config")#</span>
		<br />
		#defaultsObj.trans("header_first_time_database_config_desc")#
		<br />
		<br />
		<!--- If datasource is found then insert the values into the session. Doing it in FB did somehow not work --->
		<cfif NOT arrayisempty(thedsnarray)>
			<strong>Datasource found</strong>
			<br />
			There is already a datasource configured for #ucase(session.firsttime.database)#. We have taken the values from this datasource and filled the form below.
			<br />
			<br />
			<cfset session.firsttime.db_action = "update">
			<cfset session.firsttime.db_name = thedsnarray[1].databasename>
			<cfset session.firsttime.db_server = thedsnarray[1].server>
			<cfset session.firsttime.db_port = thedsnarray[1].port>
			<cfset session.firsttime.db_schema = thedsnarray[1].username>
			<cfset session.firsttime.db_user = thedsnarray[1].username>
			<cfset session.firsttime.db_pass = thedsnarray[1].password>
		<cfelse>
			<cfset session.firsttime.db_action = "create">
		</cfif>
		<!--- Show Form --->
		<strong>Database Name</strong> 
		<br />
		<input name="db_name" id="db_name" type="text" class="text" size="30" value="#session.firsttime.db_name#">
		<br />
		<strong>Database Server (IP or Host)</strong> 
		<br />
		<input name="db_server" id="db_server" type="text" class="text" size="30" value="#session.firsttime.db_server#">
		<br />
		<strong>Server Port</strong> 
		<br />
		<cfif session.firsttime.db_port EQ "">
			<cfif session.firsttime.database EQ "oracle">
				<cfset session.firsttime.db_port = "1521">
			<cfelseif session.firsttime.database EQ "mysql">
				<cfset session.firsttime.db_port = "3306">
			<cfelseif session.firsttime.database EQ "mssql">
				<cfset session.firsttime.db_port = "1433">
			</cfif>
		</cfif>
		<input name="db_port" id="db_port" type="text" class="text" size="10" value="#session.firsttime.db_port#">
		<br />
		<strong>Database Schema</strong> 
		<br />
		<input name="db_schema" id="db_schema" type="text" class="text" size="30" value="#session.firsttime.db_schema#">
		<br />
		<strong>#defaultsObj.trans("username")#</strong> 
		<br />
		<input name="db_user" id="db_user" type="text" class="text" size="30" value="#session.firsttime.db_user#">
		<br />
		<strong>#defaultsObj.trans("password")#</strong>
		<br />
		<input name="db_pass" id="db_pass" type="password" size="30" class="text" value="#session.firsttime.db_pass#">
		<br />
		<br />
		<input type="button" id="next" value="Check Connection" onclick="checkdb();" class="button">
		<div id="divcheckdb" style="display:hidden"></div>
		<div>
			<div style="float:left;padding:20px 0px 0px 0px;">
				<input type="button" id="next" value="#defaultsObj.trans("back")#" onclick="loadcontent('load_steps','#myself#c.first_time_database');" class="button">
			</div>
			<div div="contbutton" style="float:right;padding:20px 0px 0px 0px;">
				<input type="button" id="nextdb" value="#defaultsObj.trans("continue")#" onclick="checkform();" class="button" style="display:none;">
			</div>
		</div>
	</form>
</cfoutput>

<script language="javascript">
	// Check if we can connect to DB
	function checkdb() {
		// Show Div
		$('#divcheckdb').css('display','');
		loadinggif('divcheckdb');
		// Get values
		var items = formserialize("form_account");
		// Submit Form
		loadcontent('divcheckdb','<cfoutput>#myself#</cfoutput>c.first_time_database_check&' + items);
	}
	// Submit form
	function checkform() {
		// Get path values
		var db_user = $('#db_user').val();
		var db_pass = $('#db_pass').val();
		var db_name = $('#db_name').val();
		var db_server = $('#db_server').val();
		var db_port = $('#db_port').val();
		var db_schema = $('#db_schema').val();
		// Check value or else inform user
		if ((db_user == "") | (db_pass == "") | (db_name == "") | (db_server == "") | (db_port == "") | (db_schema == "")){
			alert('Please fill in all required form fields!');
		}
		else {
			// Get values
			var items = formserialize("form_account");
			// Submit Form
			loadcontent('load_steps','<cfoutput>#myself#</cfoutput>c.first_time_database_done&' + items);
		}
	}
</script>
