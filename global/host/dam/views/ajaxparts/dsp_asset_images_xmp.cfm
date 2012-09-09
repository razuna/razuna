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
			<td class="td2" nowrap="nowrap"><strong>Document Title</strong></td>
			<td class="td2" width="100%"><input type="text" name="xmp_document_title" style="width:350px;" value="#qry_xmp.title#" onchange="javascript:document.form#attributes.file_id#.iptc_status_title.value = document.form#attributes.file_id#.xmp_document_title.value"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="nowrap"><strong>Author</strong></td>
			<td class="td2"><input type="text" name="xmp_author" style="width:350px;" value="#qry_xmp.creator#" onchange="javascript:document.form#attributes.file_id#.iptc_contact_creator.value = document.form#attributes.file_id#.xmp_author.value"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="nowrap"><strong>Author Title</strong></td>
			<td class="td2"><input type="text" name="xmp_author_title" style="width:350px;" value="#qry_xmp.authorstitle#" onchange="javascript:document.form#attributes.file_id#.iptc_contact_creator_job_title.value = document.form#attributes.file_id#.xmp_author_title.value"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="nowrap"><strong>Description Writer</strong></td>
			<td class="td2"><input type="text" name="xmp_description_writer" style="width:350px;" value="#qry_xmp.descwriter#" onchange="javascript:document.form#attributes.file_id#.iptc_content_description_writer.value = document.form#attributes.file_id#.xmp_description_writer.value"></td>
		</tr>
		<tr>
			<td class="td2" nowrap="nowrap"><strong>Copyright Status</strong></td>
			<td class="td2"><select name="xmp_copyright_status">
			<option value=""<cfif qry_xmp.copystatus EQ ""> selected="selected"</cfif>>Unknown</option>
			<option value="true"<cfif qry_xmp.copystatus EQ "true"> selected="selected"</cfif>>Copyrighted</option>
			<option value="false"<cfif qry_xmp.copystatus EQ "false"> selected="selected"</cfif>>Public Domain</option>
			</select></td>
		</tr>
		<tr>
			<td class="td2" nowrap="nowrap" valign="top"><strong>Copyright Notice</strong></td>
			<td class="td2"><textarea name="xmp_copyright_notice" style="width:350px;height:40px;" onchange="javascript:document.form#attributes.file_id#.iptc_status_copyright_notice.value = document.form#attributes.file_id#.xmp_copyright_notice.value">#qry_xmp.copynotice#</textarea></td>
		</tr>
		<tr>
			<td class="td2" nowrap="nowrap"><strong>Copyright Info URL</strong></td>
			<td class="td2"><input type="text" name="xmp_copyright_info_url" style="width:350px;" value="#qry_xmp.copyurl#"></td>
		</tr>
	</table>
</cfoutput>
