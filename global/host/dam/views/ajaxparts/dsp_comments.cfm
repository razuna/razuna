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
		<td>#myFusebox.getApplicationData().defaults.trans("comment")#<br />
			<textarea id="assetComment" name="assetComment" style="width:400px;height:50px;"></textarea> <br />
			<br />
			<input type="button" class="button" onclick="addcomment('#attributes.file_id#','#attributes.type#','#attributes.folder_id#'<cfif structKeyExists(attributes,'iscol')>,'T'<cfelse>,'F'</cfif>);" value="#myFusebox.getApplicationData().defaults.trans("comments_submit")#" />
		</td>
	</tr>
</table>
<div id="comlist"></div>
<div id="status_com"></div>
<!--- Load Comment list --->
<script language="JavaScript" type="text/javascript">
	loadcontent('comlist','#myself##xfa.comlist#&file_id=#attributes.file_id#&type=#attributes.type#&folder_id=#attributes.folder_id#');
	// Activate Chosen
	/* $(".chzn-select").chosen({search_contains: true}); */
</script>
</cfoutput>