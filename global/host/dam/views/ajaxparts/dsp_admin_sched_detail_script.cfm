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
	<div class="container">
		<form action="#self#" method="post" name="schedulerformscript" id="schedulerformscript">
			<input type="hidden" name="#theaction#" value="c.scheduler_script_save">
			<input type="hidden" name="sched_id" value="#attributes.sched_id#">

			<p class="p-1"></p>

			<div class="form-group">
				<label for="sched_script_name">Name of your script</label>
				<input type="text" class="form-control" id="sched_script_name" name="sched_script_name" value="#qry_script.sched_script_name#" autofocus>
			</div>

			<div class="form-group">
				<label for="sched_script_action">Select an action</label>
				<select class="form-control" id="sched_script_action" name="sched_script_action">
					<option value="export_to_ftp" selected>Export files to a FTP site</option>
				</select>
			</div>

			<div class="form-group">
				<label for="sched_script_interval">Action will execute...</label>
				<select class="form-control" id="sched_script_interval" name="sched_script_interval">
					<option value="1min"<cfif qry_script.sched_script_interval EQ "1min"> selected</cfif>>Every minute</option>
					<option value="5min"<cfif qry_script.sched_script_interval EQ "5min"> selected</cfif>>Every 5 minutes</option>
					<option value="15min"<cfif qry_script.sched_script_interval EQ "15min"> selected</cfif>>Every 15 minutes</option>
					<option value="hourly"<cfif qry_script.sched_script_interval EQ "hourly"> selected</cfif>>Every hour</option>
					<option value="daily"<cfif qry_script.sched_script_interval EQ "daily"> selected</cfif>>Every day (at midnight)</option>
					<option value="weekly"<cfif qry_script.sched_script_interval EQ "weekly"> selected</cfif>>Once a week</option>
					<option value="monthly"<cfif qry_script.sched_script_interval EQ "monthly"> selected</cfif>>Once a month</option>
				</select>
			</div>

			<p class="p-1"></p>
			<div class="clearfix"></div>

			<h6>Include files that match the following criterias</h6>

			<div class="form-row">
				<div class="form-group col">
					<label for="sched_script_files_time">Files that have changed in the last...</label>
					<input type="text" class="form-control" id="sched_script_files_time" name="sched_script_files_time" placeholder="Enter time" value="#qry_script.sched_script_files_time#">
				</div>
				<div class="form-group col">
					<label for="sched_script_files_time_unit">Select unit</label>
					<select class="form-control form-control-sm" id="sched_script_files_time_unit" name="sched_script_files_time_unit">
						<option value="minutes"<cfif qry_script.sched_script_files_time_unit EQ "minutes"> selected</cfif>>Minutes</option>
						<option value="hours"<cfif qry_script.sched_script_files_time_unit EQ "hours"> selected</cfif>>Hours</option>
						<option value="days"<cfif qry_script.sched_script_files_time_unit EQ "days"> selected</cfif>>Days</option>
						<option value="weeks"<cfif qry_script.sched_script_files_time_unit EQ "weeks"> selected</cfif>>Weeks</option>
						<option value="month"<cfif qry_script.sched_script_files_time_unit EQ "month"> selected</cfif>>Month</option>
					</select>
				</div>
			</div>
			<div class="form-group">
				<label for="sched_script_files_filename">Filenames that contain...</label>
				<input type="text" class="form-control" id="sched_script_files_filename" name="sched_script_files_filename" value="#qry_script.sched_script_files_filename#">
				<small class="form-text text-muted">If left empty we select all files</small>
			</div>
			<div class="form-group">
				<label for="sched_script_files_folder">Files in folder...</label>
				<select data-placeholder="Choose folder(s)" class="chzn-select form-control" name="sched_script_files_folder" id="sched_script_files_folder" multiple>
					<option value=""></option>
					<cfloop query="qry_folders">
						<option value="#folder_id#" <cfif ListFindnocase(qry_script.sched_script_files_folder, folder_id)>selected</cfif>>#folder_path#<cfif folder_of_user EQ "t"> (#username#)</cfif></option>
					</cfloop>
				</select>
				<small class="form-text text-muted">If left empty we select files in all folders</small>
			</div>
			<div class="form-group">
				<label for="sched_script_files_label">Files with label...</label>
				<select data-placeholder="#myFusebox.getApplicationData().defaults.trans('choose_label')#" class="chzn-select form-control" name="sched_script_files_label" id="sched_script_files_label" multiple>
					<option value=""></option>
					<cfloop query="attributes.thelabelsqry">
						<cfset l = replace(label_path," "," ","all")>
						<cfset l = replace(l,"/"," ","all")>
						<option value="#label_id#" <cfif ListFindnocase(qry_script.sched_script_files_label, label_id)>selected</cfif>>#label_path#</option>
					</cfloop>
				</select>
				<small class="form-text text-muted">If left empty we select all files</small>
			</div>
			<div class="form-check">
				<input class="form-check-input" type="checkbox" value="true" id="sched_script_files_include_selected" name="sched_script_files_include_selected" <cfif structKeyExists(qry_script, 'sched_script_files_include_selected') && qry_script.sched_script_files_include_selected>checked</cfif>>
				<label class="form-check-label" for="sched_script_files_include_selected">Include files that are selected (Original and renditions)</label>
			</div>
			<div class="form-check">
				<input class="form-check-input" type="checkbox" value="true" id="sched_script_files_include_preview" name="sched_script_files_include_preview" <cfif structKeyExists(qry_script, 'sched_script_files_include_preview') && qry_script.sched_script_files_include_preview>checked</cfif>>
				<label class="form-check-label" for="sched_script_files_include_preview">Save preview with export (for images and videos)</label>
			</div>
			<div class="form-check">
				<input class="form-check-input" type="checkbox" value="true" id="sched_script_files_include_metadata" name="sched_script_files_include_metadata" <cfif structKeyExists(qry_script, 'sched_script_files_include_metadata') && qry_script.sched_script_files_include_metadata>checked</cfif>>
				<label class="form-check-label" for="sched_script_files_include_metadata">Save metadata with export (XLS files)</label>
			</div>

			<div class="float-right">
				<a href="##" onclick="scriptFileSearch();">
					<button type="button" class="btn btn-outline-info btn-sm">Preview matching files</button>
				</a>
			</div>

			<p class="p-1"></p>
			<h6>File manipulation
				<br>
				<small>If you want that files will be transformed before sending them off-site then define the transform options here.</small>
			</h6>

			<strong>Images</strong>
			<br>
			<small>The options below will create a white canvas with the size provided and place the image in the middle</small>
			<br>
			<div class="form-row">
				<div class="form-group col">
					<label for="sched_script_img_canvas_width">Width</label>
					<input type="text" class="form-control" id="sched_script_img_canvas_width" name="sched_script_img_canvas_width" value="#qry_script.sched_script_img_canvas_width#">
				</div>
				<div class="form-group col">
					<label for="sched_script_img_canvas_heigth">Height</label>
					<input type="text" class="form-control" id="sched_script_img_canvas_heigth" name="sched_script_img_canvas_heigth" value="#qry_script.sched_script_img_canvas_heigth#">
				</div>
				<div class="form-group col">
					<label for="sched_script_img_dpi">Dpi</label>
					<input type="text" class="form-control" id="sched_script_img_dpi" name="sched_script_img_dpi" value="#qry_script.sched_script_img_dpi#">
				</div>
				<div class="form-group col">
					<label for="sched_script_img_format">Format</label>
					<select class="form-control form-control-sm" name="sched_script_img_format" id="sched_script_img_format">
						<option value="jpg" <cfif qry_script.sched_script_img_format EQ "jpg">selected</cfif>>JPG</option>
						<option value="png" <cfif qry_script.sched_script_img_format EQ "png">selected</cfif>>PNG</option>
					</select>
				</div>
			</div>

			<p class="p-1"></p>
			<h6>FTP
				<br>
				<small>This is where your exported files are being stored</small>
			</h6>

			<div class="form-row">
				<div class="form-group col">
					<label for="sched_script_ftp_host">FTP host</label>
					<input type="text" class="form-control" id="sched_script_ftp_host" name="sched_script_ftp_host" placeholder="Enter FTP hostname" value="#qry_script.sched_script_ftp_host#">
				</div>
				<div class="form-group col">
					<label for="sched_script_ftp_user">FTP username</label>
					<input type="text" class="form-control" id="sched_script_ftp_user" name="sched_script_ftp_user" placeholder="Enter FTP username" value="#qry_script.sched_script_ftp_user#">
				</div>
			</div>
			<div class="form-row">
				<div class="form-group col">
					<label for="sched_script_ftp_pass">FTP password</label>
					<input type="password" class="form-control" id="sched_script_ftp_pass" name="sched_script_ftp_pass" placeholder="Enter FTP password" value="#qry_script.sched_script_ftp_pass#">
				</div>
				<div class="form-group col">
					<label for="sched_script_ftp_port">FTP port</label>
					<input type="text" class="form-control" id="sched_script_ftp_port" name="sched_script_ftp_port" placeholder="Enter FTP port (this is usually 21)" value="#qry_script.sched_script_ftp_port#">
				</div>
			</div>
			<div class="form-group">
				<label for="sched_script_ftp_folder">FTP folder</label>
				<input type="text" class="form-control" id="sched_script_ftp_folder" name="sched_script_ftp_folder" value="#qry_script.sched_script_ftp_folder#">
				<small class="form-text text-muted">Where to store the files on the FTP site. Enter the whole path, e.g. /omnipix/files/</small>
			</div>

			<!--- <div class="float-right">
				<a href="##" onclick="scriptFtpConnection();">
					<button type="button" class="btn btn-outline-info btn-sm">Validate FTP connection</button>
				</a>
			</div> --->

			<p class="p-1"></p>
			<div class="clearfix"></div>

			<div class="form-check">
				<input class="form-check-input" type="checkbox" value="true" id="sched_script_active" name="sched_script_active" <cfif structKeyExists(qry_script, 'sched_script_active') && qry_script.sched_script_active>checked</cfif>>
				<label class="form-check-label" for="sched_script_active">Script is active</label>
			</div>

			<p class="p-1"></p>
			<div class="clearfix"></div>

			<button type="submit" class="btn btn-primary">Save script</button>

		</form>
	</div>
</cfoutput>

<script type="text/javascript" charset="utf-8">
	// Activate Chosen
	$(".chzn-select").chosen({search_contains: true, single_backstroke_delete : false });
	// Submit form
	$('#schedulerformscript').on('submit', function() {
		// var _action = formaction('schedulerformscript');
		var _data = formserialize('schedulerformscript');
		// Submit
		$.ajax({
			type: "POST",
			url: 'index.cfm',
			data : _data,
			statusCode: {
				// Error
				500: function(data) {
					console.log('Error', data);
				},
				// Done
				200: function(data) {
					destroywindow(1);
					loadcontent('admin_schedules','index.cfm?fa=c.scheduler_list&offset_sched=0');
				}
			}
		});
		return false;
	})
	// Show file search
	function scriptFileSearch() {
		// Get file fields
		var _filename = $('#sched_script_files_filename').val();
		var _folderid = JSON.stringify( $('#sched_script_files_folder').val() );
		var _labels = JSON.stringify( $('#sched_script_files_label').val() );
		showwindow('index.cfm?fa=c.scheduler_script_preview_search','File selection',800,2, { 'filename' : _filename, 'folderid' : _folderid, 'labels' : _labels });
	}
	// Show file search
	function scriptFtpConnection() {
		// Get file fields
		var _host = $('#sched_script_ftp_host').val();
		var _user = $('#sched_script_ftp_user').val();
		var _pass = $('#sched_script_ftp_pass').val();
		var _port = $('#sched_script_ftp_port').val();
		var _folder = $('#sched_script_ftp_folder').val();
		showwindow('index.cfm?fa=c.scheduler_script_ftp_connection','FTP connection',500,2, { 'host' : _host, 'user' : _user, 'pass' : _pass, 'port' : _port, 'folder' : _folder });
	}
</script>