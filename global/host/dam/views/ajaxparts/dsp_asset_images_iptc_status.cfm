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
		<td class="td2"><strong>Title</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_status_title" style="width:350px;" value="#qry_xmp.title#" onchange="javascript:document.form#attributes.file_id#.xmp_document_title.value = document.form#attributes.file_id#.iptc_status_title.value"></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap"><strong>Job Identifier</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_status_job_identifier" style="width:350px;" value="#qry_xmp.iptcjobidentifier#" onchange="javascript:document.form#attributes.file_id#.xmp_origin_transmission_reference.value = document.form#attributes.file_id#.iptc_status_job_identifier.value"></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>Instructions</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_status_instruction" style="width:350px;height:40px;" onchange="javascript:document.form#attributes.file_id#.xmp_origin_instructions.value = document.form#attributes.file_id#.iptc_status_instruction.value">#qry_xmp.iptcinstructions#</textarea></td>
	</tr>
	<tr>
		<td class="td2"><strong>Provider</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_status_provider" style="width:350px;" value="#qry_xmp.iptccredit#" onchange="javascript:document.form#attributes.file_id#.xmp_origin_credit.value = document.form#attributes.file_id#.iptc_status_provider.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>Source</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_status_source" style="width:350px;" value="#qry_xmp.iptcsource#" onchange="javascript:document.form#attributes.file_id#.xmp_origin_source.value = document.form#attributes.file_id#.iptc_status_source.value"></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap" valign="top"><strong>Copyright Notice</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_status_copyright_notice" style="width:350px;height:40px;" onchange="javascript:document.form#attributes.file_id#.xmp_copyright_notice.value = document.form#attributes.file_id#.iptc_status_copyright_notice.value">#qry_xmp.copynotice#</textarea></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap" valign="top"><strong>Rights Usage Terms</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_status_rights_usage_terms" style="width:350px;height:40px;">#qry_xmp.iptcusageterms#</textarea></td>
	</tr>
	<tr>
		<td class="td2"><strong>Categories IPTC</strong></td>
		<td class="td2" width="100%"><input type="text" name="xmp_category" size="3" maxlength="3" value="#qry_xmp.category#"></td>
	</tr>
	<tr>
		<td class="td2" valign="top" nowrap="nowrap"><strong>Supplemental Categories IPTC</strong></td>
		<td class="td2" width="100%"><textarea name="xmp_supplemental_categories" style="width:350px;height:40px;">#qry_xmp.categorysub#</textarea></td>
	</tr>
	<tr>
		<td class="td2"></td>
		<td class="td2" width="100%">#myFusebox.getApplicationData().defaults.trans("comma_seperated")#</td>
	</tr>
</table>
</cfoutput>