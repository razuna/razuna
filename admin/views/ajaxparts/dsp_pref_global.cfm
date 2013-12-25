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
<table border="0" cellpadding="0" cellspacing="0" width="700" class="grid">
	<!--- <tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("settings_languages")# - <a href="##" onclick="loadcontent('pglobal','#myself#c.prefs_update_langs');">Update Languages</a></th>
	</tr>
	<cfloop query="qry_langs">
		<tr>
			<td width="1%" nowrap="true"><input type="checkbox" name="lang_active_#lang_id#" value="t"<cfif lang_active EQ "t"> checked</cfif>></td>
			<td width="100%">#lang_name#</td>
		</tr>
	</cfloop>
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("date")#</th>
	</tr>
	<tr>
	<td>#defaultsObj.trans("date_format")#</td>
	<td colspan="2"><select name="set2_date_format" class="text">
	<option value="euro"<cfif #prefs.set2_date_format# EQ "euro"> selected</cfif>>#defaultsObj.trans("date_euro")#</option>
	<option value="us"<cfif #prefs.set2_date_format# EQ "us"> selected</cfif>>#defaultsObj.trans("date_us")#</option>
	<option value="sql"<cfif #prefs.set2_date_format# EQ "sql"> selected</cfif>>#defaultsObj.trans("date_sql")#</option>
	</select></td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("date_delimiter")#</td>
	<td colspan="2"><select name="set2_date_format_del" class="text">
	<option value="/"<cfif #prefs.set2_date_format_del# EQ "/"> selected</cfif>>/</option>
	<option value="."<cfif #prefs.set2_date_format_del# EQ "."> selected</cfif>>.</option>
	<option value=","<cfif #prefs.set2_date_format_del# EQ ","> selected</cfif>>,</option>
	<option value="-"<cfif #prefs.set2_date_format_del# EQ "-"> selected</cfif>>-</option>
	<option value=":"<cfif #prefs.set2_date_format_del# EQ ":"> selected</cfif>>:</option>
	</select></td>
	</tr> --->
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("header_email_settings")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_email_settings_desc")#</td>
	</tr>
	<tr>
	<td valign="top">#defaultsObj.trans("from")#</td>
	<td><input type="text" name="SET2_EMAIL_from" value="#prefs.SET2_EMAIL_from#" size="40" class="text"><br /><em>#defaultsObj.trans("email_from_desc")#</em></td>
	</tr>
	<tr>
	<td valign="top">Mail Server</td>
	<td><input type="text" name="SET2_EMAIL_SERVER" value="#prefs.SET2_EMAIL_SERVER#" size="40" class="text"><br /><em>#defaultsObj.trans("field_emty_take_default")#</em></td>
	</tr>
	<tr>
	<td valign="top">Port</td>
	<td><input type="text" name="SET2_EMAIL_SERVER_PORT" value="#prefs.SET2_EMAIL_SERVER_PORT#" size="4" class="text"></td>
	</tr>

	<tr>
	<td valign="top">Use SSL</td>
	<td>
		<label><input type="radio"<cfif prefs.SET2_EMAIL_USE_SSL> checked="checked" </cfif> value="true" name="SET2_EMAIL_USE_SSL"> #defaultsObj.trans("yes")# </label>
		<label><input type="radio"<cfif !prefs.SET2_EMAIL_USE_SSL> checked="checked" </cfif> value="false" name="SET2_EMAIL_USE_SSL"> #defaultsObj.trans("no")# </label>
	</td>
	</tr>
	<tr>
	<td valign="top">Use TLS</td>
	<td>
		<label><input type="radio"<cfif prefs.SET2_EMAIL_USE_TLS> checked="checked" </cfif> value="true" name="SET2_EMAIL_USE_TLS"> #defaultsObj.trans("yes")# </label>
		<label><input type="radio"<cfif !prefs.SET2_EMAIL_USE_TLS> checked="checked" </cfif> value="false" name="SET2_EMAIL_USE_TLS"> #defaultsObj.trans("no")# </label>
	</td>
	</tr>

	<tr>
	<td valign="top" nowrap="true">#defaultsObj.trans("smtp_username")#</td>
	<td><input type="text" name="SET2_EMAIL_smtp_user" value="#prefs.SET2_EMAIL_smtp_user#" size="40" class="text"><br /><em>#defaultsObj.trans("smtp_username_desc")#</em></td>
	</tr>
	<tr>
	<td valign="top" nowrap="true">#defaultsObj.trans("smtp_password")#</td>
	<td><input type="password" name="SET2_EMAIL_smtp_password" value="#prefs.SET2_EMAIL_smtp_password#" size="40" class="text"><br /><em>#defaultsObj.trans("smtp_password_desc")#</em><br /><br /><em>#defaultsObj.trans("smtp_only_apply")#</em>
	</td>
	</tr>
</table>
</cfoutput>