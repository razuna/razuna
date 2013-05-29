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
	<div id="sf_tab">
		<!--- Tab --->
		<ul>
			<li><a href="##sf_settings"><cfif attributes.sf_id EQ "0">#myFusebox.getApplicationData().defaults.trans("smart_folder_new")#<cfelse>#myFusebox.getApplicationData().defaults.trans("settings")#</cfif></a></li>
		</ul>
		<!--- Content --->
		<div id="sf_settings">
			<form name="sf_form" id="sf_form" action="#self#" onsubmit="sf_submit_form();return false;">
			<input type="hidden" name="sf_id" value="#attributes.sf_id#">
			<input type="hidden" name="#theaction#" value="c.smart_folders_update">
			<!--- <input type="hidden" name="searchtext" value="#attributes.searchtext#"> --->
			<!--- Name, etc. --->
			<strong>#myFusebox.getApplicationData().defaults.trans("name")#</strong>
			<br />
			<input type="text" name="sf_name" id="sf_name" value="#qry_sf.sf.sf_name#" style="width:400px;" />
			<br />
			<strong>#myFusebox.getApplicationData().defaults.trans("description")#</strong>
			<br />
			<textarea name="sf_description" id="sf_description" style="width:400px;height;50px;">#qry_sf.sf.sf_description#</textarea>
			<br /><br />
			<!--- If new but search text is not empty then we assume we come from the search --->
			<cfif attributes.searchtext NEQ "">
				<input type="hidden" name="sf_type" value="saved_search">
				<strong>#myFusebox.getApplicationData().defaults.trans("sf_search_string")#</strong>
				<br />
				<input type="text" name="searchtext" id="searchtext" value="#attributes.searchtext#" style="width:400px;" />
				<br />
				<em>(#myFusebox.getApplicationData().defaults.trans("sf_search_string_desc")#)</em>
			<cfelse>
				<strong>#myFusebox.getApplicationData().defaults.trans("type")#</strong>
				<br />
				<input type="radio" name="sf_type" id="sf_type" value="dropbox"<cfif qry_sf.sf.sf_type EQ "dropbox" OR qry_sf.sf.sf_type EQ ""> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("sf_type_dropbox")# <cfif chk_dropbox.recordcount EQ 0><span style="color:red;"><em>(<cfset transvalues[1] = "Dropbox">#myFusebox.getApplicationData().defaults.trans(transid="account_not_connected",values=transvalues)#)</em></span></cfif>
				<br />
				<input type="radio" name="sf_type" id="sf_type" value="amazon"<cfif qry_sf.sf.sf_type EQ "amazon"> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("sf_type_s3")# 
				<cfif chk_s3.recordcount EQ 0>
					<span style="color:red;"><em>(<cfset transvalues[1] = "Amazon S3">#myFusebox.getApplicationData().defaults.trans(transid="account_not_connected",values=transvalues)#)</em></span>
				<cfelse>
					Bucket: 
					<select name="sf_s3_bucket">
						<cfloop query="qry_s3_buckets">
							<option value="#set_id#">#set_pref#</option>
						</cfloop>
					</select>
				</cfif>
				<!--- <br />
				<input type="radio" name="sf_type" id="sf_type" value="box"<cfif qry_sf.sf.sf_type EQ "box"> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("sf_type_box")# <cfif chk_box.recordcount EQ 0><span style="color:red;"><em>(<cfset transvalues[1] = "Box">#myFusebox.getApplicationData().defaults.trans(transid="account_not_connected",values=transvalues)#)</em></span></cfif>
				<br />
				<input type="radio" name="sf_type" id="sf_type" value="ftp"<cfif qry_sf.sf.sf_type EQ "ftp"> checked="checked"</cfif> /> #myFusebox.getApplicationData().defaults.trans("sf_type_ftp")#  --->
				<br /><br />
				<em>(#myFusebox.getApplicationData().defaults.trans("sf_settings_desc_search")#)</em>
			</cfif>
			<br /><br />
			<input type="submit" name="sfsubmit" value="<cfif attributes.sf_id EQ 0>#myFusebox.getApplicationData().defaults.trans("button_save")#<cfelse>#myFusebox.getApplicationData().defaults.trans("button_update")#</cfif>" class="button">

			</form>
			<!--- Only show delete folder on detail page --->
			<cfif attributes.sf_id NEQ 0>
				<br /><br />
				<a href="##" onclick="sf_remove('#attributes.sf_id#')">#myFusebox.getApplicationData().defaults.trans("remove_folder")#</a>	
			</cfif>
			<!--- Status --->
			<br />
			<div id="sf_status"></div>
		</div>
	</div>
	
	<div id="dialog-confirm" title="#myFusebox.getApplicationData().defaults.trans("sf_delete_header")#" style="display:none;">
		<p><span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 60px 0;"></span>#myFusebox.getApplicationData().defaults.trans("sf_delete_desc")#</p>
	</div>

	<script type="text/javascript">
		// Create tabs
		jqtabs("sf_tab");
		// Submit form
		function sf_submit_form(){
			// Check name
			var sfname = $("##sf_name").val();
			// If name is empty
			if (sfname == ""){
				alert("#myFusebox.getApplicationData().defaults.trans("error_no_name")#");
			}
			else {
				$("##sf_status").fadeTo("fast", 100);
				var url = formaction("sf_form");
				var items = formserialize("sf_form");
				// Submit Form
		       	$.ajax({
					type: "POST",
					url: url,
				   	data: items,
				   	success: function(){
						// Update Text
						$("##sf_status").css('color','green');
						$("##sf_status").css('font-weight','bold');
						$("##sf_status").html("#myFusebox.getApplicationData().defaults.trans("success")#");
						$("##sf_status").animate({opacity: 1.0}, 3000).fadeTo("slow", 0.33);
						// Update folder list
						$('##explorer').load('#myself#c.smart_folders');
				   	}
				});
			}
	        return false; 
		};
		// Remove Folder
		function sf_remove(folderid){
			$( "##dialog-confirm" ).dialog( "destroy" );
			$( "##dialog-confirm" ).dialog({
				resizable: false,
				height: 200,
				modal: true,
				buttons: {
					"#myFusebox.getApplicationData().defaults.trans("remove_folder")#": function() {
						// Call action to delete this workflow
						$('##div_forall').load('#myself#c.smart_folders_remove&sf_id=' + folderid);
						// Refresh right side
						$('##rightside').load('#myself#c.smart_folders_content&sf_id=0');
						// Refresh folder list
						$('##explorer').load('#myself#c.smart_folders');
						// Close this window
						$( this ).dialog( "close" );
					},
					Cancel: function() {
						$( this ).dialog( "close" );
					}
				}
			});
		}
	</script>
</cfoutput>
