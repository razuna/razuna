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
		<td class="td2"><strong>#myFusebox.getApplicationData().defaults.trans("date_created_2")#</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_date_created" style="width:350px;" value="#qry_xmp.iptcdatecreated#" onchange="javascript:document.form#attributes.file_id#.xmp_origin_date_created.value = document.form#attributes.file_id#.iptc_date_created.value"></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap"><strong>#myFusebox.getApplicationData().defaults.trans("intellectual_genre")#</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_intellectual_genre" style="width:350px;" value="#qry_xmp.iptcintelgenre#"></td>
	</tr>
	<tr>
		<td class="td2" valign="top"><strong>#myFusebox.getApplicationData().defaults.trans("iptc_scene")#</strong></td>
		<td class="td2" width="100%"><textarea name="iptc_scene" style="width:350px;height:40px;">#qry_xmp.iptcscene#</textarea></td>
	</tr>
	<tr>
		<td class="td2" valign="top"></td>
		<td class="td2" width="100%">#myFusebox.getApplicationData().defaults.trans("comma_seperated")#. myFusebox.getApplicationData().defaults.trans("scene_value_defined") <a href="http://www.newscodes.org" target="_blank">http://www.newscodes.org</a></td>
	</tr>
	<tr>
		<td class="td2"><strong>#myFusebox.getApplicationData().defaults.trans("location")#</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_image_location" style="width:350px;" value="#qry_xmp.iptclocation#"></td>
	</tr>
	<tr>
		<td class="td2"><strong>#myFusebox.getApplicationData().defaults.trans("user_city")#</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_image_city" style="width:350px;" value="#qry_xmp.iptcimagecity#" onchange="javascript:document.form#attributes.file_id#.xmp_origin_city.value = document.form#attributes.file_id#.iptc_image_city.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>#myFusebox.getApplicationData().defaults.trans("state_province")#</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_image_state_province" style="width:350px;" value="#qry_xmp.iptcimagestate#" onchange="javascript:document.form#attributes.file_id#.xmp_origin_state_province.value = document.form#attributes.file_id#.iptc_image_state_province.value"></td>
	</tr>
	<tr>
		<td class="td2"><strong>#myFusebox.getApplicationData().defaults.trans("user_country")#</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_image_country" style="width:350px;" value="#qry_xmp.iptcimagecountry#" onchange="javascript:document.form#attributes.file_id#.xmp_origin_country.value = document.form#attributes.file_id#.iptc_image_country.value"></td>
	</tr>
	<tr>
		<td class="td2" nowrap="nowrap"><strong>#myFusebox.getApplicationData().defaults.trans("iso_country_code")#</strong></td>
		<td class="td2" width="100%"><input type="text" name="iptc_iso_country_code" style="width:350px;" value="#qry_xmp.iptcimagecountrycode#" maxlength="3"></td>
	</tr>
	<tr>
		<td class="td2" valign="top"></td>
		<td class="td2" width="100%">#myFusebox.getApplicationData().defaults.trans("iso_country_code_desc")#</td>
	</tr>
</table>
</cfoutput>