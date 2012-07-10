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
		<td class="td2"><strong>Date created</strong></td>
		<td class="td2" width="100%"><input type="text" name="xmp_origin_date_created" style="width:350px;" value="#qry_xmp.iptcdatecreated#" onchange="javascript:document.form#attributes.file_id#.iptc_date_created.value = document.form#attributes.file_id#.xmp_origin_date_created.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>City</strong></td>
		<td class="td2" width="100%"><input type="text" name="xmp_origin_city" style="width:350px;" value="#qry_xmp.iptcimagecity#" onchange="javascript:document.form#attributes.file_id#.iptc_image_city.value = document.form#attributes.file_id#.xmp_origin_city.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>State/Province</strong></td>
		<td class="td2" width="100%"><input type="text" name="xmp_origin_state_province" style="width:350px;" value="#qry_xmp.iptcimagestate#" onchange="javascript:document.form#attributes.file_id#.iptc_image_state_province.value = document.form#attributes.file_id#.xmp_origin_state_province.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>Country</strong></td>
		<td class="td2" width="100%"><input type="text" name="xmp_origin_country" style="width:350px;" value="#qry_xmp.iptcimagecountry#" onchange="javascript:document.form#attributes.file_id#.iptc_image_country.value = document.form#attributes.file_id#.xmp_origin_country.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>Credit</strong></td>
		<td class="td2" width="100%"><input type="text" name="xmp_origin_credit" style="width:350px;" value="#qry_xmp.iptccredit#" onchange="javascript:document.form#attributes.file_id#.iptc_status_provider.value = document.form#attributes.file_id#.xmp_origin_credit.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>Source</strong></td>
		<td class="td2" width="100%"><input type="text" name="xmp_origin_source" style="width:350px;" value="#qry_xmp.iptcsource#" onchange="javascript:document.form#attributes.file_id#.iptc_status_source.value = document.form#attributes.file_id#.xmp_origin_source.value"></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>Headline</strong></td>
		<td class="td2" width="100%"><textarea name="xmp_origin_headline" style="width:350px;height:40px;" onchange="javascript:document.form#attributes.file_id#.iptc_content_headline.value = document.form#attributes.file_id#.xmp_origin_headline.value">#qry_xmp.iptcheadline#</textarea></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>Instructions</strong></td>
		<td class="td2" width="100%"><textarea name="xmp_origin_instructions" style="width:350px;height:40px;" onchange="javascript:document.form#attributes.file_id#.iptc_status_instruction.value = document.form#attributes.file_id#.xmp_origin_instructions.value">#qry_xmp.iptcinstructions#</textarea></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap" valign="top"><strong>Transmission Reference</strong></td>
		<td class="td2" width="100%"><textarea name="xmp_origin_transmission_reference" style="width:350px;height:40px;" onchange="javascript:document.form#attributes.file_id#.iptc_status_job_identifier.value = document.form#attributes.file_id#.xmp_origin_transmission_reference.value">#qry_xmp.iptcjobidentifier#</textarea></td>
	</tr>
	<tr>
		<td class="td2"><strong>Urgency</strong></td>
		<td class="td2" width="100%"><select name="xmp_origin_urgency">
		<option value="1"<cfif #qry_xmp.urgency# EQ "1"> selected="selected"</cfif>>High</option>
		<option value="2"<cfif #qry_xmp.urgency# EQ "2"> selected="selected"</cfif>>2</option>
		<option value="3"<cfif #qry_xmp.urgency# EQ "3"> selected="selected"</cfif>>3</option>
		<option value="4"<cfif #qry_xmp.urgency# EQ "4"> selected="selected"</cfif>>4</option>
		<option value="5"<cfif #qry_xmp.urgency# EQ "5"> selected="selected"</cfif>>Normal</option>
		<option value="6"<cfif #qry_xmp.urgency# EQ "6"> selected="selected"</cfif>>6</option>
		<option value="7"<cfif #qry_xmp.urgency# EQ "7"> selected="selected"</cfif>>7</option>
		<option value="8"<cfif #qry_xmp.urgency# EQ "8"> selected="selected"</cfif>>Low</option>
		<option value=""<cfif #qry_xmp.urgency# EQ ""> selected="selected"</cfif>>None</option>
		</select></td>
	</tr>
	<tr>
		<td class="td2"></td>
		<td class="td2">#myFusebox.getApplicationData().defaults.trans("comma_seperated")#</td>
	</tr>
	<!--- Submit Button --->
	<cfif attributes.folderaccess NEQ "R">
		<tr>
			<td colspan="2">
				<div style="float:right;padding:10px;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
			</td>
		</tr>
	</cfif>
</table>
</cfoutput>