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
<cfif qry_fields.recordcount NEQ 0>
	<cfoutput>
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<th></th>
				<th nowrap="true">#myFusebox.getApplicationData().defaults.trans("custom_field_type")#</th>
				<th nowrap="true">#myFusebox.getApplicationData().defaults.trans("show_only_for")#</th>
				<th nowrap="true">#myFusebox.getApplicationData().defaults.trans("enabled")#</th>
				<th></th>
			</tr>
			<cfoutput query="qry_fields" group="cf_id">
				<tr class="list">
					<td width="100%"><a href="##" onclick="showwindow('#myself#c.custom_fields_detail&cf_id=#cf_id#','#cf_text#',680,1);return false">#cf_text#</a> <em>(ID: #cf_id#)</em></td>
					<td width="1%" nowrap="true">#cf_type#</td>
					<td width="1%" nowrap="true">
						<cfif cf_show EQ "vid">
							#myFusebox.getApplicationData().defaults.trans("search_for_videos")#
						<cfelseif cf_show EQ "img">
							#myFusebox.getApplicationData().defaults.trans("search_for_images")#
						<cfelseif cf_show EQ "aud">
							#myFusebox.getApplicationData().defaults.trans("search_for_audios")#
						<cfelseif cf_show EQ "doc">
							#myFusebox.getApplicationData().defaults.trans("search_for_documents")#
						<cfelse>
							#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#
						</cfif>
					</td>
					<td width="1%" nowrap="true" align="center"><cfif cf_enabled EQ "T"><img src="#dynpath#/global/host/dam/images/checked.png" width="16" height="16" border="0"></cfif></td>
					<td width="1%" nowrap="true" align="center"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=custom_fields&id=#cf_id#&loaddiv=thefields&order=#cf_order#','#myFusebox.getApplicationData().defaults.trans("remove_selected")#',400,1);return false"><img src="#dynpath#/global/host/dam/images/trash.png" width="16" height="16" border="0"></a></td>
				</tr>
			</cfoutput>
		</table>
	</cfoutput>
</cfif>
