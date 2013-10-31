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
<!--- Define variables --->
<cfoutput>
	<form name="form#attributes.file_id#" id="form#attributes.file_id#" method="post" action="#self#">
	<input type="hidden" name="#theaction#" value="c.rend_meta_save">
	<input type="hidden" name="langcount" value="1">
	<input type="hidden" name="file_id" value="#attributes.file_id#">
	<input type="hidden" name="thetype" value="#attributes.thetype#">
	<input type="hidden" name="customfields" value="#qry_cf.recordcount#">
	<table border="0" width="450" cellpadding="0" cellspacing="0" class="grid">
		<tr>
			<td>ID</td>
			<td>#attributes.file_id#</td>
		</tr>
		<!--- Filename --->
		<tr>
			<td width="130" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("file_name")#</td>
			<td width="320" nowrap="true"><input type="text" style="width:300px;" name="fname" value="#attributes.filename#"></td>
		</tr>
		<!--- Description & Keywords --->
		<cfloop query="qry_langs">
			<cfif lang_id EQ 1>
				<cfset thisid = lang_id>
				<tr>
					<td valign="top" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("description")#</td>
					<td ><textarea name="#attributes.desc##thisid#" class="text" style="width:300px;height:30px;"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#thedesc#</cfif></cfloop></textarea></td>
				</tr>
				<tr>
					<td valign="top" nowrap="true" style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("keywords")#</td>
					<td><textarea name="#attributes.keys##thisid#" class="text" style="width:300px;height:30px;"><cfloop query="qry_detail.desc"><cfif lang_id_r EQ thisid>#thekeys#</cfif></cfloop></textarea></td>
				</tr>
			</cfif>
		</cfloop>
	</table>
	<!--- Custom Fields --->
	<cfinclude template="inc_custom_fields.cfm">
	<!--- Save and feedback --->
	<div style="float:left;padding:20px 0px 20px 0px;color:green;font-weight:bold;" id="fb#attributes.file_id#"></div>
	<div style="float:right;padding:20px 70px 20px 0px;"><input type="submit" name="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></div>
		<!--- Labels --->
		<!--- <cfif cs.tab_labels>
			<tr>
				<td style="font-weight:bold;">#myFusebox.getApplicationData().defaults.trans("labels")#</td>
				<td width="100%" nowrap="true" colspan="5">
					<select data-placeholder="Choose a label" class="chzn-select" style="width:410px;" id="tags_img" onchange="razaddlabels('tags_img','#attributes.file_id#','img');" multiple="multiple">
						<option value=""></option>
						<cfloop query="attributes.thelabelsqry">
							<option value="#label_id#"<cfif ListFind(qry_labels,'#label_id#') NEQ 0> selected="selected"</cfif>>#label_path#</option>
						</cfloop>
					</select>
					<cfif qry_label_set.set2_labels_users EQ "t" OR (Request.securityobj.CheckSystemAdminUser() OR Request.securityobj.CheckAdministratorUser())>
						<a href="##" onclick="showwindow('#myself#c.admin_labels_add&label_id=0&closewin=2','Create new label',450,2);return false;"><img src="#dynpath#/global/host/dam/images/list-add-3.png" width="24" height="24" border="0" style="margin-left:-2px;" /></a>
					</cfif>
				</td>
			</tr>
		</cfif> --->
	</form>
	<!--- JS --->
	<script type="text/javascript">
		// Submit Form
		$("##form#attributes.file_id#").submit(function(e){
			// Get data
			var url = formaction("form#attributes.file_id#");
			var items = formserialize("form#attributes.file_id#");
			// Submit Form
	       	$.ajax({
				type: "POST",
				url: url,
			   	data: items,
			   	success: function(){
					// Update Text
					$("##fb#attributes.file_id#").css("display","");
					$("##fb#attributes.file_id#").fadeTo("fast", 100);
					$("##fb#attributes.file_id#").html("#myFusebox.getApplicationData().defaults.trans("success")#");
					$("##fb#attributes.file_id#").animate({opacity: 1.0}, 3000).fadeTo("slow", 0);
			   	}
			});
	        return false;
	    });
	</script>
</cfoutput>