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
<div>
	<form name="form_simplesearch" onsubmit="loadcontent('rightside','#myself#c.share_search&searchtext=' + escape($('##simplesearchtext').val()) + '&thetype=' + $('##simplesearchthetype').val());return false;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tablepanel">
		<tr>
			<th colspan="2"><div style="float:left;">#myFusebox.getApplicationData().defaults.trans("header_search")#</div></th>
		</tr>
		<tr>
			<td align="left" style="padding-bottom:0px;"><input name="simplesearchtext" id="simplesearchtext" size="25" type="text" class="textbold" style="width:170px;"></td>
			<td align="right" style="padding-bottom:0px;"><input type="submit" name="buttonsearch" value="#myFusebox.getApplicationData().defaults.trans("button_find")#" class="button"></td>
		</tr>
		<tr>
			<td style="padding-top:0px;" colspan="2"><select name="simplesearchthetype" id="simplesearchthetype" style="width:172px;"><option value="all" selected>#myFusebox.getApplicationData().defaults.trans("search_for_allassets")#</option><option value="img">#myFusebox.getApplicationData().defaults.trans("search_for_images")#</option><option value="doc">#myFusebox.getApplicationData().defaults.trans("search_for_documents")#</option><option value="vid">#myFusebox.getApplicationData().defaults.trans("search_for_videos")#</option><option value="aud">#myFusebox.getApplicationData().defaults.trans("search_for_audios")#</option></select></td>
		</tr>
	</table>
	</form>
</div>
</cfoutput>
