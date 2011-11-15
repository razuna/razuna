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
		<td class="td2"><strong>Creator</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_contact_creator" style="width:350px;" value="#qry_xmp.creator#" onchange="javascript:document.form#attributes.file_id#.xmp_author.value = document.form#attributes.file_id#.iptc_contact_creator.value"></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap"><strong>Creator's Job Title</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_contact_creator_job_title" style="width:350px;" value="#qry_xmp.authorstitle#" onchange="javascript:document.form#attributes.file_id#.xmp_author_title.value = document.form#attributes.file_id#.iptc_contact_creator_job_title.value"></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>Address</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_contact_address" style="width:350px;height:40px;">#qry_xmp.iptcaddress#</textarea></td>
	</tr>
	<tr>
		<td class="td2"><strong>City</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_contact_city" style="width:350px;" value="#qry_xmp.iptccity#"></td>
	</tr>
	<tr>
		<td class="td2"><strong>State/Province</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_contact_state_province" style="width:350px;" value="#qry_xmp.iptcstate#"></td>
	</tr>
	<tr>
		<td class="td2"><strong>Postal Code</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_contact_postal_code" style="width:350px;" value="#qry_xmp.iptczip#"></td>
	</tr>
	<tr>
		<td class="td2"><strong>Country</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_contact_country" style="width:350px;" value="#qry_xmp.iptccountry#"></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>Phone(s)</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_contact_phones" style="width:350px;height:40px;">#qry_xmp.iptcphone#</textarea></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>eMail(s)</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_contact_emails" style="width:350px;height:40px;">#qry_xmp.iptcemail#</textarea></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>Website(s)</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_contact_websites" style="width:350px;height:40px;">#qry_xmp.iptcwebsite#</textarea></td>
	</tr>
</table>
</cfoutput>