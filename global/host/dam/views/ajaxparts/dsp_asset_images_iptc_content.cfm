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
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
	<tr>
		<td class="td2" valign="top"><strong>Headline</strong></td>
		<td class="td2"><textarea name="iptc_content_headline" style="width:350px;height:40px;" onchange="javascript:document.form#attributes.file_id#.xmp_origin_headline.value = document.form#attributes.file_id#.iptc_content_headline.value">#qry_xmp.iptcheadline#</textarea></td>
	</tr>
	<cfloop query="qry_langs">
		<cfset thisid = lang_id>
		<tr>
			<td class="td2" valign="top" width="1%" nowrap="true" width="200"><strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("description")#</strong></td>
			<td class="td2" width="100%"><textarea name="iptc_content_description_#thisid#" class="text" style="width:350px;height:40px;" onchange="document.form#attributes.file_id#.img_desc_#thisid#.value = document.form#attributes.file_id#.iptc_content_description_#thisid#.value;document.form#attributes.file_id#.desc_#thisid#.value = document.form#attributes.file_id#.iptc_content_description_#thisid#.value;"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_description#</cfif></cfloop></textarea></td>
		</tr>
		<tr>
			<td class="td2" valign="top" width="1%" nowrap="true"><strong>#lang_name#: #myFusebox.getApplicationData().defaults.trans("keywords")#</strong></td>
			<td class="td2" width="100%"><textarea name="iptc_content_keywords_#thisid#" class="text" style="width:350px;height:40px;" onchange="document.form#attributes.file_id#.img_keywords_#thisid#.value = document.form#attributes.file_id#.iptc_content_keywords_#thisid#.value;document.form#attributes.file_id#.keywords_#thisid#.value = document.form#attributes.file_id#.iptc_content_keywords_#thisid#.value;"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#img_keywords#</cfif></cfloop></textarea></td>
		</tr>
	</cfloop>
	<tr>
		<td class="td2" valign="top" nowrap="nowrap"><strong>IPTC Subject Code</strong></td>
		<td class="td2"><textarea name="iptc_content_subject_code" style="width:350px;height:40px;">#qry_xmp.iptcsubjectcode#</textarea></td>
	</tr>
	<tr>
		<td class="td2" valign="top"></td>
		<td class="td2">#myFusebox.getApplicationData().defaults.trans("comma_seperated")#. Subject Codes are defined at <a href="http://www.newscodes.org" target="_blank">http://www.newscodes.org</a></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap"><strong>Description Writer</strong></td>
		<td class="td2"><input type="text" name="iptc_content_description_writer" style="width:350px;" value="#qry_xmp.descwriter#" onchange="javascript:document.form#attributes.file_id#.xmp_description_writer.value = document.form#attributes.file_id#.iptc_content_description_writer.value"></td>
	</tr>
</table>
</cfoutput>