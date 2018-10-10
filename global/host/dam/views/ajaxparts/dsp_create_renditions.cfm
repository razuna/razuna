<cfoutput>
	<!--- <cfdump var="#attributes#"> --->
	<p >
		This form let's you create one or many new renditions on the fly. Enter the size you need or choose from a template. Optionally, and if your Administrator enabled the function, you can also save the rendition to the file itself.
	</p>
	<form id="form_create_renditions" name="form_create_renditions" action="index.cfm?fa=c.create_renditions_do" method="post" target="_blank">
		<input type="hidden" name="fa" value="c.create_renditions_do">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="grid">
			<!--- IMAGES --->
			<cfif attributes.thetype EQ "all" OR attributes.thetype EQ "img">
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
			</cfif>
			<!--- VIDEOS --->
			<cfif attributes.thetype EQ "all" OR attributes.thetype EQ "vid">
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
			</cfif>
			<!--- AUDIOS --->
			<cfif attributes.thetype EQ "all" OR attributes.thetype EQ "aud">
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
			</cfif>
			<!--- Padding --->
			<cfmodule template="../../modules/padding_tr.cfm" colspan="4" padding="15">
			<tr>
				<td colspan="4">
					<input type="checkbox" name="save_renditions" id="save_renditions" value="true">
					<span><a href="##" onclick="clickcbk2('save_renditions')" style="text-decoration: none;">Save renditions</a></span>
				</td>
			</tr>
			<!--- Padding --->
			<cfmodule template="../../modules/padding_tr.cfm" colspan="4" padding="20">
		</table>
		<div style="float:right;padding-bottom:30px;">
			<input type="submit" name="submit_create_renditions" value="Create renditions" class="awesome large green">
		</div>
	</form>
</cfoutput>

<script type="text/javascript">
	// Submit
	$('#form_create_renditions').on('submit', function(e) {
		// Close window
		setTimeout(function() {
			destroywindow(1);
		},500);
		return true;
	});
	// Template image
	$('#template_img').on('change', function(e) {
		var _value = e.target.value;
		if ( _value === "0" ) {
			$('.type_img').prop('disabled', false);
		}
		else {
			$('.type_img').prop('disabled', true);
		}
	});
	// Template video
	$('#template_vid').on('change', function(e) {
		var _value = e.target.value;
		if ( _value === "0" ) {
			$('.type_vid').prop('disabled', false);
		}
		else {
			$('.type_vid').prop('disabled', true);
		}
	});
	// Template audio
	$('#template_aud').on('change', function(e) {
		var _value = e.target.value;
		if ( _value === "0" ) {
			$('.type_aud').prop('disabled', false);
		}
		else {
			$('.type_aud').prop('disabled', true);
		}
	});
</script>