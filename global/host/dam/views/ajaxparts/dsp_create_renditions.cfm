<cfoutput>
	<!--- <cfdump var="#qry_templates#"> --->
	<p >
		This form let's you create one or many new renditions on the fly. Enter the size you need or choose from a template. Optionally, and if your Administrator enabled the function, you can also save the rendition to the file itself.
	</p>
	<form id="form_create_renditions" name="form_create_renditions">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<!--- IMAGES --->
			<tr>
				<th colspan="2">
					Images
				</th>
				<th width="100%" nowrap="nowrap" colspan="2">
					<cfmodule template="../../modules/select_upload_templates.cfm" type='img' qry_templates="#qry_templates#">
				</th>
			</tr>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='jpg' type='img' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='gif' type='img' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='png' type='img' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='tif' type='img' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='bmp' type='img' fusebox='#myFusebox#'>
			<!--- VIDEOS --->
			<tr>
				<th colspan="2">
					Videos
				</th>
				<th width="100%" nowrap="nowrap" colspan="2">
					<cfmodule template="../../modules/select_upload_templates.cfm" type='vid' qry_templates="#qry_templates#">
				</th>
			</tr>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='ogv' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='webm' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='mp4' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='mov' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='mxf' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='mpg' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='avi' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='wmv' type='vid' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='flv' type='vid' fusebox='#myFusebox#'>
			<!--- AUDIOS --->
			<tr>
				<th colspan="2">
					Audios
				</th>
				<th width="100%" nowrap="nowrap" colspan="2">
					<cfmodule template="../../modules/select_upload_templates.cfm" type='aud' qry_templates="#qry_templates#">
				</th>
			</tr>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='mp3' type='aud' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='ogg' type='aud' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='wav' type='aud' fusebox='#myFusebox#'>
			<cfmodule template="../../modules/create_renditions_tr.cfm" format='flac' type='aud' fusebox='#myFusebox#'>
			<!--- Padding --->
			<cfmodule template="../../modules/padding_tr.cfm" colspan="4" padding="15">
			<tr>
				<td colspan="4">
					<input type="checkbox" name="save_renditions" value="false">
					<span>Save renditions</span>
				</td>
			</tr>
			<!--- Padding --->
			<cfmodule template="../../modules/padding_tr.cfm" colspan="4" padding="20">
			<tr>
				<td colspan="4">
					<input type="submit" name="submit_create_renditions" value="Create renditions">
				</td>
			</tr>
		</table>
	</form>
</cfoutput>

<script type="text/javascript">
	$('#form_create_renditions').on('submit', function() {
		// Serialize form
		var _data = formserialize('form_create_renditions');
		// Submit
		$.ajax({
			type: "POST",
			url: 'index.cfm?fa=c.create_renditions_do',
			data : _data,
			statusCode: {
				// Error
				500: function(data) {
					console.log('ERROR starring mailbox');
				},
				// Done
				200: function(data) {
					console.log('data', data)
				}
			}
		});
		return false;
	})
</script>