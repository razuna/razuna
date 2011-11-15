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
<table width="600" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<th colspan="3"><cfoutput>#defaultsObj.trans("searchresults_header")#</cfoutput></th>
	</tr>
	<cfoutput query="searchresults" group="trans_id">
	<tr>
		<td width="100%"><a href="##" onclick="showwindow('#myself#c.translation_detail&trans_id=#trans_id#','#trans_id#',600,1);return false">#trans_text#</a></td>
		<td width="1%" nowrap valign="top"><a href="##" onclick="showwindow('#myself#c.translation_detail&trans_id=#trans_id#','#trans_id#',600,1);return false">#trans_id#</a></td>
		<td width="1%" nowrap align="center" valign="top"><a href="##" onclick="showwindow('#myself#ajax.remove_record&what=translation&id=#trans_id#&loaddiv=tresults','#defaultsObj.trans("remove_selected")#',400,1);return false"><img src="images/trash.gif" width="16" height="16" border="0"></a></td>
	</tr>
	</cfoutput>
</table>


