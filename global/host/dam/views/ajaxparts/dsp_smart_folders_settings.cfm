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
			<!--- Name, etc. --->
			<strong>#myFusebox.getApplicationData().defaults.trans("name")#</strong>
			<br />
			<input type="text" name="sf_name" id="sf_name" value="#qry_sf.sf_name#" style="width:400px;" />
			<br />
			<strong>#myFusebox.getApplicationData().defaults.trans("description")#</strong>
			<br />
			<textarea name="sf_description" id="sf_description" style="width:400px;height;50px;">#qry_sf.sf_description#</textarea>
			<br />
			<strong>#myFusebox.getApplicationData().defaults.trans("type")#</strong>
			<br />
			<select name="sf_type" id="sf_type">
				<option value="" selected="selected"></option>
				<option value="saved_search">#myFusebox.getApplicationData().defaults.trans("sf_type_saved_search")#</option>
				<option value="FTP">#myFusebox.getApplicationData().defaults.trans("sf_type_ftp")#</option>
				<option value="s3">#myFusebox.getApplicationData().defaults.trans("sf_type_s3")#</option>
				<option value="dropbox">#myFusebox.getApplicationData().defaults.trans("sf_type_dropbox")#</option>
				<option value="box">#myFusebox.getApplicationData().defaults.trans("sf_type_box")#</option>
			</select>
			<br /><br />
			<input type="submit" name="sfsubmit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button">

			</form>
			<!--- Status --->
			<br />
			<div id="sf_status"></div>
		</div>
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
		}
	</script>
</cfoutput>
