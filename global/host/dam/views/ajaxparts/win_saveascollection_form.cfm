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
	<cfset col_id= 0>
	<form name="form_#col_id#" id="form_#col_id#" method="post" action="#self#">
	<cfif NOT structkeyexists(attributes,"coladd")>
		<input type="hidden" name="#theaction#" value="c.saveascollection_do">
	<cfelse>
		<input type="hidden" name="#theaction#" value="c.collection_save">
	</cfif>
	<input type="hidden" name="folder_id" id="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th colspan="2">
				<cfif NOT structkeyexists(attributes,"coladd")>
				#myFusebox.getApplicationData().defaults.trans("basket_save_as_collection")#
				<cfelse>
				#myFusebox.getApplicationData().defaults.trans("collection_create")#
				</cfif>
			</th>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("header_collection_name")#</td>
			<td><input type="text" name="collectionname" id="collectionname" size="50" onkeyup="samecollectionnamecheck('#col_id#');" autocomplete="off">
			 <div id="samecollectionname"></div>
			</td>
		</tr>
		<cfif NOT structkeyexists(attributes,"coladd")>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("save_in_this_folder")#</td>
			<td>#attributes.folder_name#</td>
		</tr>
		</cfif>
		<tr>
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("asset_desc")#</th>
		</tr>
		<cfloop query="qry_langs">
			<tr>
				<td class="td2" valign="top" width="1%" nowrap="true">#lang_name#: #myFusebox.getApplicationData().defaults.trans("description")#</td>
				<td class="td2" width="100%"><textarea name="col_desc_#lang_id#" class="text" rows="2" cols="50"></textarea></td>
			</tr>
			<tr>
				<td class="td2" valign="top" width="1%" nowrap="true">#lang_name#: #myFusebox.getApplicationData().defaults.trans("keywords")#</td>
				<td class="td2" width="100%"><textarea name="col_keywords_#lang_id#" class="text" rows="2" cols="50"></textarea></td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="2"><div id="collectionupdate" style="width:80%;float:left;padding:10px;color:green;font-weight:bold;display:none;"></div><div style="float:right;padding:10px;"><input type="submit" name="save" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" id = "collectionsubmitbutton" /></div></td>
		</tr>
	</table>
	</form>
	<script>
		$("##form_#col_id#").submit(function(e){
			// If collectionname is empty
			var cn = $('##form_#col_id# ##collectionname').val();
			if (cn == ""){
				alert('Please enter a name for your collection!')
				return false;
			}
			$("##collectionupdate").css("display","");
			loadinggif('collectionupdate');
			// Submit Form
			// Get values
			var url = formaction("form_#col_id#");
			var items = formserialize("form_#col_id#");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: colfeedback
			});
			return false;
		})
		function colfeedback() {
			<cfif structkeyexists(attributes,"norefresh")>
				// Hide Window
				destroywindow(2);
				// Reload the collectiin list
				loadcontent('div_choosecol','index.cfm?fa=c.collection_chooser&withfolder=T&folder_id=#attributes.folder_id#');
			<cfelse>
				<cfif NOT structkeyexists(attributes,"coladd")>
					$("##collectionupdate").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("save_collection_done"))#");
				   	$("##collectionupdate").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
				<cfelse>
					// Hide Window
					destroywindow(1);
					// reload collection list
					$('##rightside').load('#myself#c.collections&iscol=T&folder_id=col-#attributes.folder_id#');
				</cfif>
			</cfif>
		}
	</script>
</cfoutput>

