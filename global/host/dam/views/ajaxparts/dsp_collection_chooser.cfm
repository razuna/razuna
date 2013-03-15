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
<br><br>
<cfoutput>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" style="padding-top:15px;">
		<cfif qry_col_list.collist.recordcount EQ 0>
			<tr>
				<td>There are no collections here. <cfif attributes.folderaccess NEQ "R"><a href="##" onclick="showwindow('#myself#c.saveascollection_form&folder_id=#attributes.folder_id#&coladd=T&norefresh=true','#myFusebox.getApplicationData().defaults.trans("collection_create")#',600,2);">Maybe create one now?</a></cfif></td>
			</tr>
		<cfelse>
			<tr>
				<td>Please choose in which Collection you want to save your asset(s):</td>
			</tr>
			<cfloop query="qry_col_list.collist">
				<tr>
					<td valign="top" style="padding-left:15px;"><a href="##" onclick="choosecollectiondone('#session.savehere#','#col_id#');return false;"><strong>#col_name#</strong></a></td>
				</tr>
			</cfloop>
		</cfif>
	</table>
	<div id="colfeedback" style="width:98%;float:left;padding:10px;color:green;font-weight:bold;display:none;"></div>
	<div id="coldummy"></div>
	<script>
		// When we choose a Collection
		function choosecollectiondone(xfa,colid){
			loadcontent('coldummy','#myself#' + xfa + '&col_id=' + colid);
			$("##colfeedback").fadeTo("fast", 100);
			$("##colfeedback").css("display","");
			$("##colfeedback").html('#JSStringFormat(myFusebox.getApplicationData().defaults.trans("choose_collection_done"))#');
			$("##colfeedback").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
		}
	</script>
</cfoutput>

