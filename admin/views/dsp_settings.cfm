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
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
<cfform action="#self#" method="post" name="settings">
<cfinput type="hidden" name="#theaction#" value="#xfa.submitform#">
<cfoutput query="thesettings">
<tr>
<td width="1%" nowrap="true">#gobj.trans("date_format")#</td>
<td width="100%" nowrap="true"><select name="date_format" class="text">
<option value="euro"<cfif #date_format# EQ "euro"> selected</cfif>>#gobj.trans("date_euro")#</option>
<option value="us"<cfif #date_format# EQ "us"> selected</cfif>>#gobj.trans("date_us")#</option>
<option value="sql"<cfif #date_format# EQ "sql"> selected</cfif>>#gobj.trans("date_sql")#</option>
</select></td>
</tr>
<tr>
<td nowrap="true">#gobj.trans("date_format_del")#</td>
<td><select name="date_format_del" class="text">
<option value="/"<cfif #date_format_del# EQ "/"> selected</cfif>>/</option>
<option value="."<cfif #date_format_del# EQ "."> selected</cfif>>.</option>
<option value=","<cfif #date_format_del# EQ ","> selected</cfif>>,</option>
<option value="-"<cfif #date_format_del# EQ "-"> selected</cfif>>-</option>
<option value=":"<cfif #date_format_del# EQ ":"> selected</cfif>>:</option>
</select></td>
</tr>
<tr>
<td nowrap="true" valign="top">#gobj.trans("head_task_settings")#</td>
<td><textarea cols="50" rows="7" name="task_categories">#task_categories#</textarea><br><i>#gobj.trans("help_delimiter_desc")#</i></td>
</tr>
<tr>
<td colspan="2" align="right"><cfinput type="submit" name="submit" value="#gobj.trans("but_save")#" class="button"></td>
</tr>
</cfoutput>
</cfform>
</table>