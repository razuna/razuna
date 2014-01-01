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
	<form name="form_admin_export" id="form_admin_export" method="post" action="#self#?#theaction#=c.admin_export_template_save">
		<!--- Metadata Export --->
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<tr>
				<br />
				#myFusebox.getApplicationData().defaults.trans("export_template_desc")#
			</tr>
			<tr>
				<td>
					<em>(#myFusebox.getApplicationData().defaults.trans("multiselect")#)</em>
					<br /><br />
					<!--- IMAGES --->
					#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_images")#
					<br />
					<select name="images_metadata" multiple="multiple" style="width:400px;height:130px;">
						<!--- Default values --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
						<option value="img_width"<cfif listFind(qry_export.images_metadata,"img_width")> selected="selected"</cfif>>Width</option>
						<option value="img_height"<cfif listFind(qry_export.images_metadata,"img_height")> selected="selected"</cfif>>Height</option>
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
						<cfloop list="#attributes.meta_img#" index="i">
							<!--- Upper case the first char --->
							<cfset l = len(i) - 1>
							<option value="#i#"<cfif listFind(qry_export.images_metadata,"#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
						</cfloop>
					</select>
					<br /><br />
					<!--- VIDEOS --->
					#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_videos")#
					<br />
					<select name="videos_metadata" multiple="multiple" style="width:400px;height:130px;">
						<!--- Default values --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
						<option value="vid_width"<cfif listFind(qry_export.videos_metadata,"vid_width")> selected="selected"</cfif>>Width</option>
						<option value="vid_height"<cfif listFind(qry_export.videos_metadata,"vid_height")> selected="selected"</cfif>>Height</option>
					</select>
					<br /><br />
					<!--- FILES --->
					#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_files")#
					<br />
					<select name="files_metadata" multiple="multiple" style="width:400px;height:130px;">
						<!--- Default values --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
						<cfloop list="#attributes.meta_doc#" index="i">
							<!--- Upper case the first char --->
							<cfset l = len(i) - 1>
							<option value="#i#"<cfif listFind(qry_export.files_metadata,"#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<div id="status_custom_2" style="float:left;padding-top:5px;"></div><div style="float:right;"><input type="submit" value="#myFusebox.getApplicationData().defaults.trans("save_changes")#" class="button" /></div>
	</form>
	<div style="clear:both;"></div>
	<!--- JS --->
	<script type="text/javascript">
		// Submit
		$("##form_admin_export").submit(function(e){
			// Get values
			var url = formaction("form_admin_export");
			var items = formserialize("form_admin_export");
			// Submit Form
			$.ajax({
				type: "POST",
				url: url,
			   	data: items
			});
			// Feedback
			$('##status_custom_2').fadeTo("fast", 100);
			$('##status_custom_2').html('<span style="font-weight:bold;color:green;">We saved the change successfully!</span>');
			$('##status_custom_2').fadeTo(5000, 0);
			return false;
		});
	</script>
</cfoutput>