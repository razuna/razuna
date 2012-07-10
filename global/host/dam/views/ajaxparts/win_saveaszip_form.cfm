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
	<form name="form_saveaszip" id="form_saveaszip" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.saveaszip_do">
	<input type="hidden" name="folder_id" value="#attributes.folder_id#">
	<input type="hidden" name="langcount" value="#valuelist(qry_langs.lang_id)#">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("basket_save_as_zip")#</th>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("name_of_zip")#</td>
			<td><input type="text" name="zipname" size="40" value="basket-#createuuid('')#">.zip</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("save_in_this_folder")#</td>
			<td>#attributes.folder_name#</td>
		</tr>
		<tr>
			<th colspan="2">#myFusebox.getApplicationData().defaults.trans("asset_desc")#</th>
		</tr>
		<cfloop query="qry_langs">
			<tr>
				<td class="td2" valign="top" width="1%" nowrap="true">#lang_name#: #myFusebox.getApplicationData().defaults.trans("description")#</td>
				<td class="td2" width="100%"><textarea name="file_desc_#lang_id#" class="text" rows="2" cols="50"></textarea></td>
			</tr>
			<tr>
				<td class="td2" valign="top" width="1%" nowrap="true">#lang_name#: #myFusebox.getApplicationData().defaults.trans("keywords")#</td>
				<td class="td2" width="100%"><textarea name="file_keywords_#lang_id#" class="text" rows="2" cols="50"></textarea></td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="2"><div id="zipupdate" style="width:80%;float:left;padding:10px;color:green;font-weight:bold;display:none;"></div><div style="float:right;padding:10px;"><input type="submit" name="save" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button" /></div></td>
		</tr>
	</table>
	</form>
	<script>
		$("##form_saveaszip").submit(function(e){
			$("##zipupdate").css("display","");
			loadinggif('zipupdate');
			// Submit Form
			// Get values
			var url = formaction("form_saveaszip");
			var items = formserialize("form_saveaszip");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
			   		$("##zipupdate").html("#JSStringFormat(myFusebox.getApplicationData().defaults.trans("save_zip_done"))#");
			   		$("##zipupdate").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
			   	}
			});
			return false;
		})
	</script>
</cfoutput>