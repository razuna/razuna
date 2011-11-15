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
<div id="ft">
	<!--- First Time Header --->
	<span class="loginform_header">#defaultsObj.trans("header_first_time")#</span>
	<br />
	#defaultsObj.trans("first_time")#
	<br />
	<hr noshade="noshade" width="100%" size="1px">
	<br />
	<!--- Herein we load the steps --->
	<div id="load_steps">
		<span class="loginform_header">#defaultsObj.trans("header_first_time_choose_installation")#</span>
		<br />
		#defaultsObj.trans("header_first_time_choose_installation_desc")#
		<br />
		<br />
		<a href="##" onclick="loadcontent('load_steps','#myself#c.first_time_paths&db=h2&schema=razuna&type=standard');" class="first_time_hoover">
			<span class="loginform_header">#defaultsObj.trans("header_first_time_choose_installation_standard")#</span>
			<br />
			#defaultsObj.trans("header_first_time_choose_installation_standard_desc")#
			<br />
			<div style="float:right;padding:5px;"><input type="button" id="standard" value="#defaultsObj.trans("header_first_time_choose_installation_standard")#" class="button" style="width:150px;"></div>
		</a>
		<a href="##" onclick="loadcontent('load_steps','#myself#c.first_time_database');" class="first_time_hoover">
			<span class="loginform_header">#defaultsObj.trans("header_first_time_choose_installation_custom")#</span>
			<br />
			#defaultsObj.trans("header_first_time_choose_installation_custom_desc")#
			<br />
			<div style="float:right;padding:5px;"><input type="button" id="standard" value="#defaultsObj.trans("header_first_time_choose_installation_custom")#" onclick="" class="button" style="width:150px;"></div>
			<br />
			<br />
		</a>
	</div>
	
</div>
</cfoutput>

	<!--- Oacle Settings --->
	<cfif application.razuna.thedatabase EQ "oracle">
		<tr>
			<th colspan="2">#defaultsObj.trans("oracle_settings")#</th>
		</tr>
		<tr>
			<td valign="top">#defaultsObj.trans("oracle_schema")#*</td>
			<td><input type="text" name="oracle_schema" size="40" class="text" value="#application.razuna.theschema#" required="true" message="#defaultsObj.trans("error_form")#"><br /><em>#defaultsObj.trans("oracle_schema_desc")#</em></td>
		</tr>
	</cfif>

</div>
