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
	<!--- Folders --->
	<div style="padding-left:10px;padding-bottom:10px;font-weight:bold;float:left;">Labels</div>
	<div style="float:right;"><a href="##labels" onclick="loadcontent('labels','#myself#c.labels_list');return false;">#defaultsObj.trans("reload_list")#</a></div>
	<div style="clear:both;"></div>
	<!--- Load Labels --->
	<div style="padding-left:10px;float:left;width:200px;">
		<cfloop query="qry_labels">
			<a href="##" onclick="loadcontent('rightside','#myself#c.labels_main&label_id=#label_id#');return false;" style="text-decoration:none;">
				<div style="float:left;padding-right:5px;"><img src="#dynpath#/global/host/dam/images/tag.png" width="16" height="16" border="0" /></div>
				<div>#label_text# (#label_count#)</div>
			</a>
			<br/>
		</cfloop>
	</div>
	
	<div style="clear:both;"></div>
	
	


</cfoutput>
	
