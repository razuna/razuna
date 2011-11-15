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
		<!--- Could Storage header --->
		<tr>
			<th class="textbold" colspan="2">#defaultsObj.trans("database_settings")#</th>
		</tr>
		<tr>
			<td colspan="3">#defaultsObj.trans("global_db_desc")#</td>
		</tr>
			<tr>
				<th class="textbold" colspan="2">Your current Database</th>
			</tr>
			<tr>
				<td><br>
				<strong>You are currently using the #ucase(gprefs.conf_database)# database.</strong><br /><br /> If you like to change to another database, then please click the link below. For a list of supported database and their settings please <a href="http://wiki.razuna.com/display/ecp/Connecting+Razuna+to+a+database" target="_blank">visit our Wiki pages</a>.
				<br><br>
				<div style="background-color:yellow;padding:10px;">By clicking on the link below you will get immediately redirected to the initial setup where you will be able to choose the database and import your settings (if coming from a backup).</div><br>
				<a href="#myself#c.prefs_change_db"><strong>Yes, let me change the database now!</strong></a></td>
			</tr>
			<!---
			<!--- H2 --->
			<tr>
				<th class="textbold" colspan="2">Embedded Database</th>
			</tr>
			<tr>
				<td align="center"><input type="radio" name="conf_database" value="h2"<cfif gprefs.conf_database EQ "h2"> checked</cfif>></td>
				<td>#defaultsObj.trans("global_h2_desc")#</td>
			</tr>
			<!--- MySQL --->
			<tr>
				<th class="textbold" colspan="2">MySQL</th>
			</tr>
			<tr>
				<td align="center"><input type="radio" name="conf_database" value="mysql"<cfif gprefs.conf_database EQ "mysql"> checked</cfif>></td>
				<td>#defaultsObj.trans("global_mysql_desc")#</td>
			</tr>
			<!--- Oracle --->
			<tr>
				<th class="textbold" colspan="2">Oracle</th>
			</tr>
			<tr>
				<td align="center"><input type="radio" name="conf_database" value="oracle"<cfif gprefs.conf_database EQ "oracle"> checked</cfif>></td>
				<td>#defaultsObj.trans("global_oracle_desc")#</td>
			</tr>
			<!--- MSSQL --->
			<tr>
				<th class="textbold" colspan="2">MS SQL</th>
			</tr>
			<tr>
				<td align="center"><input type="radio" name="conf_database" value="mssql"<cfif gprefs.conf_database EQ "mssql"> checked</cfif>></td>
				<td>#defaultsObj.trans("global_mssql_desc")#</td>
			</tr>
			<!--- Schema --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("global_db_schema")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("global_db_schema_desc")#</td>
			</tr>
			<tr>
				<td align="center" nowrap="true">#defaultsObj.trans("global_db_schema_name")#</td>
				<td><input type="text" name="conf_schema" value="#gprefs.conf_schema#" size="20"></td>
			</tr>
			<!--- Datasource --->
			<tr>
				<th class="textbold" colspan="2">#defaultsObj.trans("global_db_datasource")#</th>
			</tr>
			<tr>
				<td colspan="2">#defaultsObj.trans("global_db_datasource_desc")#</td>
			</tr>
			<tr>
				<td align="center" nowrap="true">#defaultsObj.trans("global_db_datasource")#</td>
				<td><input type="text" name="conf_datasource" value="#gprefs.conf_datasource#" size="20"></td>
			</tr>
			--->
	</table>
</cfoutput>
