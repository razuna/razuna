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
	<th class="textbold" colspan="2">#defaultsObj.trans("header_url_app_server")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("header_url_app_server_desc")#</td>
	</tr>
	<tr>
	<td>URL</td>
	<td><input type="text" name="set2_url_app_server" value="#prefs.set2_url_app_server#" size="40" class="text"></td>
	</tr>
	<tr>
	<td>Internal URL</td>
	<td><input type="text" name="set2_ora_path_internal" value="#prefs.set2_ora_path_internal#" size="40" class="text"></td>
	</tr>
	<tr>
	<th class="textbold" colspan="2">#defaultsObj.trans("url_oracle_sp")#</th>
	</tr>
	<tr>
	<td colspan="2">#defaultsObj.trans("url_desc")#</td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("url_sp_original")#</td>
	<td><input type="text" name="set2_url_sp_original" value="#prefs.set2_url_sp_original#" size="60" class="text"></td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("url_sp_thumb")#</td>
	<td><input type="text" name="set2_url_sp_thumb" value="#prefs.set2_url_sp_thumb#" size="60" class="text"></td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("url_sp_comp")#</td>
	<td><input type="text" name="set2_url_sp_comp" value="#prefs.set2_url_sp_comp#" size="60" class="text"></td>
	</tr>
	<tr>
	<td nowrap>#defaultsObj.trans("url_sp_comp_uw")#</td>
	<td><input type="text" name="set2_url_sp_comp_uw" value="#prefs.set2_url_sp_comp_uw#" size="60" class="text"></td>
	</tr>
	<tr>
	<td>#defaultsObj.trans("url_sp_video")#</td>
	<td><input type="text" name="set2_url_sp_video" value="#prefs.set2_url_sp_video#" size="60" class="text"></td>
	</tr>
	<tr>
	<td nowrap>#defaultsObj.trans("url_sp_video_image")#</td>
	<td><input type="text" name="set2_url_sp_video_preview" value="#prefs.set2_url_sp_video_preview#" size="60" class="text"></td>
	</tr>
	</table>
</cfoutput>