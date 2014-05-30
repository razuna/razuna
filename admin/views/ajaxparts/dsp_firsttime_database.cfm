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
		<span class="loginform_header">#defaultsObj.trans("header_first_time_database")#</span>
		<br />
		#defaultsObj.trans("header_first_time_database_desc")#
		<br />
		<br />
		<span class="loginform_header">#defaultsObj.trans("header_first_time_database_2")#</span>
		<br />
		#defaultsObj.trans("header_first_time_database_2_desc")#
		<br />
		<br />
		<select id="database">
			<option value="h2">H2 (Embedded Database)</option>
			<option value="mysql">MySQL</option>
			<option value="mssql">MS SQL</option>
			<!--- <option value="oracle">Oracle</option>
			<option value="db2">DB2</option> --->
		</select>
		<div>
			<div style="float:left;padding:20px 0px 0px 0px;">
				<input type="button" id="next" value="#defaultsObj.trans("back")#" onclick="location.href=('/');" class="button">
			</div>
			<div style="float:right;padding:20px 0px 0px 0px;">
				<input type="button" id="next" value="#defaultsObj.trans("continue")#" onclick="gotodbform();" class="button">
			</div>
		</div>
	</form>
</cfoutput>

<script language="javascript">
	// Submit form
	function gotodbform() {
		// Submit Form
		loadcontent('load_steps','<cfoutput>#myself#</cfoutput>c.first_time_database_config&db=' + $('#database').val());
	}
</script>
