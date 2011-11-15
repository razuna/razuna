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
<form action="#self#" method="post" onsubmit="return Spry.Utils.submitForm(this, updatetransdiv);">
<input type="hidden" name="#theaction#" value="c.translation_update">
<input type="hidden" name="trans_id" value="#attributes.trans_id#">
<table width="570" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<th colspan="2">#defaultsObj.trans("translations_edit")#</th>
	</tr>
</cfoutput>
	<cfoutput query="result">
		<cfif #lang_id_r# EQ 1>
			<tr>
				<td>ID</td>
				<td><input type="text" name="trans_id" class="text" size="40" value="#trans_id#" disabled></td>
			</tr>
		</cfif>
		<cfloop from="1" to="#defaultsObj.howmanylang("#application.razuna.datasource#")#" index="langindex">
			<cfif #langindex# EQ "#lang_id_r#">
			<input type="hidden" name="transid" value="#langindex#">
				<tr>
					<td valign="top">#defaultsObj.thislang("set_lang_#langindex#")#</td>
					<td><textarea rows="4" cols="60" class="text" name="trans_lang_#langindex#">#trans_text#</textarea></td>
				</tr>
			</cfif>
		</cfloop>
	</cfoutput>
	<cfoutput>
	<tr>
		<td colspan="2" align="right" width="100%" nowrap="true"><input type="submit" name="Submit" value="#defaultsObj.trans("save")#" class="button"><div id="updatetext" style="color:##FF0000;"></div></td>
	</tr>
	</cfoutput>
</table>
</form>