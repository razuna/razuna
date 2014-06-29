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
				<td>
					<br />
					#myFusebox.getApplicationData().defaults.trans("export_template_desc")#
					<br/><br/>
					<em>(#myFusebox.getApplicationData().defaults.trans("multiselect")#)</em>
					<br /><br />
					<!--- IMAGES --->
					#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_images")#
					<br />
					<select name="images_metadata" multiple="multiple" style="width:400px;height:130px;">
						<!--- Default values --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
						<option value="img_id"<cfif listFind(qry_export.images_metadata,"img_id")> selected="selected"</cfif>>ID</option>
						<option value="img_filename"<cfif listFind(qry_export.images_metadata,"img_filename")> selected="selected"</cfif>>Filename</option>
						<option value="img_folder_id"<cfif listFind(qry_export.images_metadata,"img_folder_id")> selected="selected"</cfif>>FolderID</option>
						<option value="img_foldername"<cfif listFind(qry_export.images_metadata,"img_foldername")> selected="selected"</cfif>>Foldername</option>
						<option value="img_description"<cfif listFind(qry_export.images_metadata,"img_description")> selected="selected"</cfif>>Description</option>
						<option value="img_keywords"<cfif listFind(qry_export.images_metadata,"img_keywords")> selected="selected"</cfif>>Keywords</option>
						<option value="img_labels"<cfif listFind(qry_export.images_metadata,"img_labels")> selected="selected"</cfif>>Labels</option>
						<option value="img_type"<cfif listFind(qry_export.images_metadata,"img_type")> selected="selected"</cfif>>Type</option>
						<option value="img_file_url"<cfif listFind(qry_export.images_metadata,"img_file_url")> selected="selected"</cfif>>File URL</option>
						<option value="img_create_time"<cfif listFind(qry_export.images_metadata,"img_create_time")> selected="selected"</cfif>>Create Date</option>
						<option value="img_change_time"<cfif listFind(qry_export.images_metadata,"img_change_time")> selected="selected"</cfif>>Change Date</option>
						<option value="img_width"<cfif listFind(qry_export.images_metadata,"img_width")> selected="selected"</cfif>>Width</option>
						<option value="img_height"<cfif listFind(qry_export.images_metadata,"img_height")> selected="selected"</cfif>>Height</option>
						<option value="img_size"<cfif listFind(qry_export.images_metadata,"img_size")> selected="selected"</cfif>>Size</option>
						<cfif prefs.set2_upc_enabled>
							<option value="img_upc_number"<cfif listFind(qry_export.images_metadata,"img_upc_number")> selected="selected"</cfif>>UPC Number</option>
						</cfif>
						<!--- Extended metadata --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
						<cfloop list="#attributes.meta_img#" index="i">
							<!--- Upper case the first char --->
							<cfset l = len(i) - 1>
							<option value="#i#"<cfif listFind(qry_export.images_metadata,"#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
						</cfloop>
						<!--- Custom fields --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields")# ---</option>
						<cfloop query="meta_cf">
							<cfif cf_show eq 'all' or cf_show eq 'img'>
								<option value="#cf_text#:#cf_id#"<cfif listFind(qry_export.images_metadata,"#cf_text#:#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
							</cfif>
						</cfloop>
					</select>
					<br /><br />
					<!--- VIDEOS --->
					#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_videos")#
					<br />
					<select name="videos_metadata" multiple="multiple" style="width:400px;height:130px;">
						<!--- Default values --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
						<option value="vid_id"<cfif listFind(qry_export.videos_metadata,"vid_id")> selected="selected"</cfif>>ID</option>
						<option value="vid_filename"<cfif listFind(qry_export.videos_metadata,"vid_filename")> selected="selected"</cfif>>Filename</option>
						<option value="vid_folder_id"<cfif listFind(qry_export.videos_metadata,"vid_folder_id")> selected="selected"</cfif>>FolderID</option>
						<option value="vid_foldername"<cfif listFind(qry_export.videos_metadata,"vid_foldername")> selected="selected"</cfif>>Foldername</option>
						<option value="vid_description"<cfif listFind(qry_export.videos_metadata,"vid_description")> selected="selected"</cfif>>Description</option>
						<option value="vid_keywords"<cfif listFind(qry_export.videos_metadata,"vid_keywords")> selected="selected"</cfif>>Keywords</option>
						<option value="vid_labels"<cfif listFind(qry_export.videos_metadata,"vid_labels")> selected="selected"</cfif>>Labels</option>
						<option value="vid_type"<cfif listFind(qry_export.videos_metadata,"vid_type")> selected="selected"</cfif>>Type</option>
						<option value="vid_file_url"<cfif listFind(qry_export.videos_metadata,"vid_file_url")> selected="selected"</cfif>>File URL</option>
						<option value="vid_create_time"<cfif listFind(qry_export.videos_metadata,"vid_create_time")> selected="selected"</cfif>>Create Date</option>
						<option value="vid_change_time"<cfif listFind(qry_export.videos_metadata,"vid_change_time")> selected="selected"</cfif>>Change Date</option>
						<option value="vid_width"<cfif listFind(qry_export.videos_metadata,"vid_width")> selected="selected"</cfif>>Width</option>
						<option value="vid_height"<cfif listFind(qry_export.videos_metadata,"vid_height")> selected="selected"</cfif>>Height</option>
						<option value="vid_size"<cfif listFind(qry_export.videos_metadata,"vid_size")> selected="selected"</cfif>>Size</option>
						<cfif prefs.set2_upc_enabled>
							<option value="vid_upc_number"<cfif listFind(qry_export.videos_metadata,"vid_upc_number")> selected="selected"</cfif>>UPC Number</option>
						</cfif>
						<!--- Custom fields --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields")# ---</option>
						<cfloop query="meta_cf">
							<cfif cf_show eq 'all' or cf_show eq 'vid'>
								<option value="#cf_text#:#cf_id#"<cfif listFind(qry_export.videos_metadata,"#cf_text#:#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
							</cfif>
						</cfloop>
					</select>
					<br /><br />
					<!--- FILES --->
					#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_files")#
					<br />
					<select name="files_metadata" multiple="multiple" style="width:400px;height:130px;">
					<!--- Default values --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
						<option value="file_id"<cfif listFind(qry_export.files_metadata,"file_id")> selected="selected"</cfif>>ID</option>
						<option value="file_name"<cfif listFind(qry_export.files_metadata,"file_name")> selected="selected"</cfif>>Filename</option>
						<option value="file_folder_id"<cfif listFind(qry_export.files_metadata,"file_folder_id")> selected="selected"</cfif>>FolderID</option>
						<option value="file_foldername"<cfif listFind(qry_export.files_metadata,"file_foldername")> selected="selected"</cfif>>Foldername</option>
						<option value="file_desc"<cfif listFind(qry_export.files_metadata,"file_desc")> selected="selected"</cfif>>Description</option>
						<option value="file_keywords"<cfif listFind(qry_export.files_metadata,"file_keywords")> selected="selected"</cfif>>Keywords</option>
						<option value="file_labels"<cfif listFind(qry_export.files_metadata,"file_labels")> selected="selected"</cfif>>Labels</option>
						<option value="file_type"<cfif listFind(qry_export.files_metadata,"file_type")> selected="selected"</cfif>>Type</option>
						<option value="file_file_url"<cfif listFind(qry_export.files_metadata,"file_file_url")> selected="selected"</cfif>>File URL</option>
						<option value="file_create_time"<cfif listFind(qry_export.files_metadata,"file_create_time")> selected="selected"</cfif>>Create Date</option>
						<option value="file_change_time"<cfif listFind(qry_export.files_metadata,"file_change_time")> selected="selected"</cfif>>Change Date</option>
						<option value="file_size"<cfif listFind(qry_export.files_metadata,"file_size")> selected="selected"</cfif>>Size</option>
						<cfif prefs.set2_upc_enabled>
							<option value="file_upc_number"<cfif listFind(qry_export.files_metadata,"file_upc_number")> selected="selected"</cfif>>UPC Number</option>
						</cfif>
						<!--- Extended metadata --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("extended_metadata")# ---</option>
						<cfloop list="#attributes.meta_doc#" index="i">
							<!--- Upper case the first char --->
							<cfset l = len(i) - 1>
							<option value="#i#"<cfif listFind(qry_export.files_metadata,"#i#")> selected="selected"</cfif>>#ucase(left(i,1))##mid(i,2,l)#</option>
						</cfloop>
						<!--- Custom fields --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields")# ---</option>
						<cfloop query="meta_cf">
							<cfif cf_show eq 'all' or cf_show eq 'doc'>
								<option value="#cf_text#:#cf_id#"<cfif listFind(qry_export.files_metadata,"#cf_text#:#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
							</cfif>
						</cfloop>
					</select>
					<br /><br />
					<!--- AUDIOS --->
					#myFusebox.getApplicationData().defaults.trans("header_customization_fileview_audios")#
					<br />
					<select name="audios_metadata" multiple="multiple" style="width:400px;height:130px;">
						<!--- Default values --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("standard_fields")# ---</option>
						<option value="aud_id"<cfif listFind(qry_export.audios_metadata,"aud_id")> selected="selected"</cfif>>ID</option>
						<option value="aud_name"<cfif listFind(qry_export.audios_metadata,"aud_name")> selected="selected"</cfif>>Filename</option>
						<option value="aud_folder_id"<cfif listFind(qry_export.audios_metadata,"aud_folder_id")> selected="selected"</cfif>>FolderID</option>
						<option value="aud_foldername"<cfif listFind(qry_export.audios_metadata,"aud_foldername")> selected="selected"</cfif>>Foldername</option>
						<option value="aud_description"<cfif listFind(qry_export.audios_metadata,"aud_description")> selected="selected"</cfif>>Description</option>
						<option value="aud_keywords"<cfif listFind(qry_export.audios_metadata,"aud_keywords")> selected="selected"</cfif>>Keywords</option>
						<option value="aud_labels"<cfif listFind(qry_export.audios_metadata,"aud_labels")> selected="selected"</cfif>>Labels</option>
						<option value="aud_type"<cfif listFind(qry_export.audios_metadata,"aud_type")> selected="selected"</cfif>>Type</option>
						<option value="aud_file_url"<cfif listFind(qry_export.audios_metadata,"aud_file_url")> selected="selected"</cfif>>File URL</option>
						<option value="aud_create_time"<cfif listFind(qry_export.audios_metadata,"aud_create_time")> selected="selected"</cfif>>Create Date</option>
						<option value="aud_change_time"<cfif listFind(qry_export.audios_metadata,"aud_change_time")> selected="selected"</cfif>>Change Date</option>
						<option value="aud_size"<cfif listFind(qry_export.audios_metadata,"aud_size")> selected="selected"</cfif>>Size</option>
						<cfif prefs.set2_upc_enabled>
							<option value="aud_upc_number"<cfif listFind(qry_export.audios_metadata,"aud_upc_number")> selected="selected"</cfif>>UPC Number</option>
						</cfif>
						<!--- Custom fields --->
						<option value="">--- #myFusebox.getApplicationData().defaults.trans("custom_fields")# ---</option>
						<cfloop query="meta_cf">
							<cfif cf_show eq 'all' or cf_show eq 'aud'>
								<option value="#cf_text#:#cf_id#"<cfif listFind(qry_export.audios_metadata,"#cf_text#:#cf_id#")> selected="selected"</cfif>>#cf_text#</option>
							</cfif>
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
