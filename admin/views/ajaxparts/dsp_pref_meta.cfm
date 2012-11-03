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
	<tr>
	<th class="textbold">#defaultsObj.trans("header_title_meta_lang")#</th>
	</tr>	
	<!--- show meta tags for each language --->
	<cfloop query="qry_langs">
		<!--- IntraNet Titles --->
		<tr>
			<th colspan="2" class="textbold">#defaultsObj.trans("header_title_intra")#</th>
		</tr>
		<tr>
			<td nowrap>#defaultsObj.trans("title_in")# #lang_name#</td>
		</tr>
		<tr>
			<td><input type="text" name="set_title_intra_#lang_id#" size="80" value="#settingsObj.thissetting("set_title_intra_#lang_id#")#"></td>
		</tr>	
		<tr>
			<td>#lang_name# - #defaultsObj.trans("meta_keywords")#</td>
		</tr>
		<tr>
			<td align="left"><textarea name="set_meta_keywords_#lang_id#" rows="5" cols="80" class="text">#settingsObj.thissetting("set_meta_keywords_#lang_id#")#</textarea></td>
		</tr>
		<tr>
			<td>#lang_name# - #defaultsObj.trans("desc")#</td>
		</tr>
		<tr>
			<td align="left"><textarea name="set_meta_description_#lang_id#" rows="3" cols="80" class="text">#settingsObj.thissetting("set_meta_description_#lang_id#")#</textarea></td>
		</tr>
		<tr>
			<td>#lang_name# - #defaultsObj.trans("meta_custom")#</td>
		</tr>
		<tr>
			<td align="left"><textarea name="set_meta_custom_#lang_id#" rows="4" cols="80" class="text">#settingsObj.thissetting("set_meta_custom_#lang_id#")#</textarea><br />
		<em>#defaultsObj.trans("code_meta")# (&lt;meta name=&quot;...&quot;&gt;)</em></td>
		</tr>
	</cfloop>
	<!--- meta tags for all languages --->
	<tr>
	<th>#defaultsObj.trans("header_title_meta_general")#</th>
	</tr>
	<tr>
	<td>Author <i>(meta name="author" content="ComputerOil.com")</i></td>
	</tr>
	<tr>
	<td align="left"><input type="text" name="set2_meta_author" size="80" class="text" value="#prefs.set2_meta_author#"></td>
	</tr>
	<tr>
	<td>Publisher <i>(meta name="publisher" content="ComputerOil.com")</i></td>
	</tr>
	<tr>
	<td align="left"><input type="text" name="set2_meta_publisher" size="80" class="text" value="#prefs.set2_meta_publisher#"></td>
	</tr>
	<tr>
	<td>Copyright <i>(meta name="copyright" content="ComputerOil.com")</i></td>
	</tr>
	<tr>
	<td align="left"><input type="text" name="set2_meta_copyright" value="#prefs.set2_meta_copyright#" size="80" class="text"></td>
	</tr>
	<tr>
	<td>Robots <i>(meta name="robots" content="all")</i></td>
	</tr>
	<tr>
	<td align="left"><input type="text" name="set2_meta_robots" value="#prefs.set2_meta_robots#" size="80" class="text"></td>
	</tr>
	<tr>
	<td>Revisit-After <i>(meta name="revisit after" content="7 days")</i></td>
	</tr>
	<tr>
	<td align="left"><input type="text" name="set2_meta_revisit" value="#prefs.set2_meta_revisit#" size="80" class="text"></td>
	</tr>
	</table>
</cfoutput>