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
<!--- Turn date inputs into jQuery datepicker --->
  <script>
	  $(function() {
	    $( "##endDate" ).datepicker();
	    $( "##startDate" ).datepicker();
	  });
  </script>
<form action="#self#" method="post" name="schedulerform" id="schedulerform" onSubmit="validateMethodInput(this,'Add');return false;">
<input type="hidden" name="#theaction#" value="c.scheduler_save">
<input type="hidden" name="sched_id" value="#attributes.sched_id#">
<input type="hidden" name="folder_id" id="folder_id" value="#qry_detail.sched_folder_id_r#" />
<table width="600" border="0" cellspacing="0" cellpadding="0" class="grid">
	<tr>
		<th colspan="2">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads")#</th>
	</tr>
		<!--- Details of scheduled Event --->
		<tr>
			<td colspan="2">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_info_text1")#
				<ul>
					<li>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_info_text2")#</li>
					<li>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_info_text3")#</li>
				</ul>
				#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_info_text4")#
			</td>
		</tr>
		<tr>
			<td width="150">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_task_name")#</td>
			<td><input type="text" name="taskName" id="taskName" size="50" value="#qry_detail.sched_name#" /></td>
		</tr>
		<tr>
			<td valign="top">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_method")#</td>
			<td>
				<table border="0" cellspacing="0" cellpadding="0" class="gridno">
					<tr>
						<td width="100" valign="top">
							<select name="method" id="method" class="text" onChange="showConnectDetail('new');">
								<cfif !application.razuna.isp>
									<option value="server"<cfif qry_detail.sched_method EQ "server"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_server")#</option>
								</cfif>
								<option value="ftp"<cfif qry_detail.sched_method EQ "ftp"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_ftp")#</option>
								<!--- <option value="mail"<cfif qry_detail.sched_method EQ "mail"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_mail")#</option> --->
								<cfif structKeyExists(attributes,"ad_server_name") AND attributes.ad_server_name NEQ "" AND structKeyExists(attributes,"ad_server_username") AND attributes.ad_server_username NEQ "" AND structKeyExists(attributes,"ad_server_password") AND attributes.ad_server_password NEQ "" AND structKeyExists(attributes,"ad_server_start") AND attributes.ad_server_start NEQ "">
								<option value="ADServer"<cfif qry_detail.sched_method EQ "ADServer">selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_ADServer")#</option>
								</cfif>
								<option>---</option>
								<!--- Indexing --->
								<cfif !application.razuna.isp>
									<option value="indexing"<cfif qry_detail.sched_method EQ "indexing"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_indexing")#</option>
								</cfif>
								<!--- Indexing Full --->
								<option value="rebuild"<cfif qry_detail.sched_method EQ "rebuild"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("admin_maintenance_searchsync")#</option>
							</select>
						</td>
						<td>
							<!--- Display fields for Server folder upload --->							
							<table border="0" cellspacing="0" cellpadding="0" class="gridno" id="detailsServer_new" style="display: <cfif qry_detail.sched_method EQ "server" OR qry_detail.sched_method EQ "">block<cfelse>none</cfif>">
								<tr>
									<td width="90" nowrap>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_server_folder")#</td>
									<td><select name="serverFolder" class="text">
											<option value="">Select folder...</option>
											<option value="">---</option>
											<cfloop query="qry_serverfolder">
												<cfif Left(name,2) EQ '--'>
													<option value="#path#"<cfif qry_detail.sched_server_folder EQ "#path#"> selected</cfif>>#name#</option>
												<cfelse>
													<option class="textbold" value="#path#"<cfif qry_detail.sched_server_folder EQ "#path#"> selected</cfif>>#name#</option>
												</cfif>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("sched_server_recursive")#</td>
									<td><input type="checkbox" name="serverFolderRecurse" value="1" <cfif qry_detail.sched_server_recurse EQ "" OR qry_detail.sched_server_recurse> checked</cfif>> #myFusebox.getApplicationData().defaults.trans("scheduled_uploads_server_recurse")#</td>
								</tr>
								<!--- <tr>
									<td colspan="2">#myFusebox.getApplicationData().defaults.trans("sched_server_deletemove")#</td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("sched_server_files")#</td>
									<td><input type="radio" name="serverFiles" value="0" <cfif qry_detail.sched_server_files EQ 0 OR qry_detail.sched_server_files EQ ""> checked</cfif>> #myFusebox.getApplicationData().defaults.trans("sched_server_delete")# &nbsp;  
										<input type="radio" name="serverFiles" value="1" <cfif qry_detail.sched_server_files EQ 1> checked</cfif>> #myFusebox.getApplicationData().defaults.trans("sched_server_move")#
									</td>
								</tr> --->
							</table>
							<!--- Display fields for eMail upload --->
							<table border="0" cellspacing="0" cellpadding="0" class="gridno" id="detailsMail_new" style="display: <cfif qry_detail.sched_method EQ "mail">block<cfelse>none</cfif>">
								<tr>
									<td width="90" nowrap>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_mail_server")#</td>
									<td><input type="text" name="mailPop" size="25" value="#qry_detail.sched_mail_pop#" /></td>
									<td></td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_mail_user")#</td>
									<td><input type="text" name="mailUser" size="25" value="#qry_detail.sched_mail_user#" /></td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_mail_pass")#</td>
									<td><input type="password" name="mailPass" size="25" value="#qry_detail.sched_mail_pass#" /></td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_mail_subject")#</td>
									<td><input type="text" name="mailSubject" size="25" value="#qry_detail.sched_mail_subject#" /></td>
								</tr>
							</table>
							<!--- AD Server add user group --->
							<table border="0" cellspacing="0" cellpadding="0" class="gridno" id="detailsADUserGroup_new" style="display: <cfif qry_detail.sched_method EQ "ADServer">block<cfelse>none</cfif>">
								<tr>
									<td valign="top">Group by:</td>
									<td>
										<select name="grp_id_assigneds" id="grp_id_assigneds" multiple="multiple" size="5" style="width:150px;">
							    			<cfloop query="qry_groups">
			    								<option value="#grp_id#" <cfif ListFindNoCase(qry_detail.sched_ad_user_groups,grp_id) >selected</cfif>>#grp_name#</option>
											</cfloop>
										</select>
									</td>
									<td></td>
								</tr>
							</table>

							<!--- Display fields for FTP upload --->
							<table border="0" cellspacing="0" cellpadding="0" class="gridno" id="detailsFtp_new" style="display: <cfif qry_detail.sched_method EQ "ftp">block<cfelse>none</cfif>">
								<tr>
									<td width="90" nowrap>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_ftp_server")#</td>
									<td><input type="text" name="ftpServer" size="25" value="#qry_detail.sched_ftp_server#" /></td>
									<td rowspan="5" valign="top"><a href="##" onclick="javascript:openFtp('Add');return false;">#myFusebox.getApplicationData().defaults.trans("scheduler_ftp_desc")#</a></td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_ftp_user")#</td>
									<td><input type="text" name="ftpUser" size="25" value="#qry_detail.sched_ftp_user#" /></td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_ftp_pass")#</td>
									<td><input type="password" name="ftpPass" size="25" value="#qry_detail.sched_ftp_pass#" /></td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_ftp_passive")#</td>
									<td><input type="radio" name="ftpPassive" value="0" <cfif qry_detail.sched_ftp_passive EQ 0 OR qry_detail.sched_ftp_passive EQ ""> checked="yes"</cfif>> #myFusebox.getApplicationData().defaults.trans("no")#
										<input type="radio" name="ftpPassive" value="1" <cfif qry_detail.sched_ftp_passive EQ 1> checked="yes"</cfif>> #myFusebox.getApplicationData().defaults.trans("yes")#
									</td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_ftp_folder")#</td>
									<td><input type="text" name="ftpFolder" size="25" value="#qry_detail.sched_ftp_folder#" /></td>
								</tr>
								<tr>
									<td>Notification Email(s)</td>
									<td><input type="text" name="ftpemails" size="25" value="#qry_detail.sched_ftp_email#" maxlength="500" placeholder="separate emails by comma"/></td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_duration")#</td>
			<td>
				<table border="0" cellspacing="0" cellpadding="0" class="gridno">
					<tr>
						<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_start_date")#</td>
						<td><input type="datefield" name="startDate" id="startDate" size="10" value="<cfif qry_detail.sched_start_date EQ "">#LSDateFormat(Now(), 'mm/dd/yyyy')#<cfelse>#LSDateFormat(qry_detail.sched_start_date, 'mm/dd/yyyy')#</cfif>" /></td>
						<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_end_date")#</td>
						<td><input type="datefield" name="endDate" id="endDate" size="10" value="<cfif qry_detail.sched_end_date EQ ""><!--- #LSDateFormat(Now(), 'mm/dd/yyyy')# ---><cfelse>#LSDateFormat(qry_detail.sched_end_date, 'mm/dd/yyyy')#</cfif>" /></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td valign="top">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency")#</td>
			<td>
				<table border="0" cellspacing="0" cellpadding="0" class="gridno">
					<tr>
						<td width="100">
							<!--- Get Frequency from database --->
							<cfset hours = "">
							<cfset minutes = "">
							<cfset seconds = "">
							<cfswitch expression="#qry_detail.sched_interval#">
								<cfcase value="once">
									<cfset frequency = 1>
								</cfcase>
								<cfcase value="daily,weekly,monthly">
									<cfset frequency = 2>
								</cfcase>
								<cfdefaultcase>
									<cfif !structkeyexists(attributes,"add") AND qry_detail.recordcount NEQ 0>
										<cfset frequency = 3>
										<cfset hours   = Int(qry_detail.sched_interval / 3600)>
										<cfset minutes = Int((qry_detail.sched_interval - hours * 3600) / 60)>
										<cfset seconds = Int(qry_detail.sched_interval - hours * 3600 - minutes * 60)>
									<cfelse>
										<cfset frequency = 1>
									</cfif>
								</cfdefaultcase>
							</cfswitch>
							<select name="frequency" id="frequency" class="text" onChange="showFrequencyDetail('new')">
								<option value="1"<cfif frequency EQ "1"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_onetime")#</option>
								<option value="2"<cfif frequency EQ "2"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_recurring")#</option>
								<option value="3"<cfif frequency EQ "3"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_daily_every")#</option>
							</select>
						</td>
						<td>
							<table border="0" cellspacing="0" cellpadding="5" class="gridno" id="detailsOneTime_new" style="display: <cfif #frequency# EQ "1">block<cfelse>none</cfif>">
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_at")#</td>
									<td><input type="text" name="startTime1" size="6" onBlur="fixTime(this)" value="<cfif qry_detail.sched_start_time EQ "">#LSTimeFormat(DateAdd("n", 10, Now()), 'HH:mm')#<cfelse>#LSTimeFormat(qry_detail.sched_start_time, 'HH:mm')#</cfif>" /></td>
								</tr>

							</table>
							<table border="0" cellspacing="0" cellpadding="0" class="gridno" id="detailsRecurring_new" style="display: <cfif #frequency# EQ "2">block<cfelse>none</cfif>">
								<tr>
									<td>
										<select name="recurring" class="text">
											<option value="daily"<cfif qry_detail.sched_interval EQ "daily"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_daily")#</option>
											<option value="weekly"<cfif qry_detail.sched_interval EQ "weekly"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_weekly")#</option>
											<option value="monthly"<cfif qry_detail.sched_interval EQ "monthly"> selected</cfif>>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_monthly")#</option>
										</select>
									</td>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_frequency_at")#</td>
									<td><input type="text" name="startTime2" size="6" onBlur="fixTime(this)" value="<cfif qry_detail.sched_start_time EQ "">#LSTimeFormat(DateAdd("n", 10, Now()), 'HH:mm')#<cfelse>#LSTimeFormat(qry_detail.sched_start_time, 'HH:mm')#</cfif>" /></td>
								</tr>
							</table>
							<table border="0" cellspacing="0" cellpadding="0" class="gridno" id="detailsDaily_new" style="display: <cfif #frequency# EQ "3">block<cfelse>none</cfif>">
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("hours")#</td>
									<td><input type="text" name="hours" size="2" maxlength="2" value="<cfif hours EQ "">06<cfelse>#hours#</cfif>" /></td>
									<td>#myFusebox.getApplicationData().defaults.trans("minutes")#</td>
									<td><input type="text" name="minutes" size="2" maxlength="2" value="<cfif minutes EQ "">00<cfelse>#minutes#</cfif>" /></td>
									<td>#myFusebox.getApplicationData().defaults.trans("seconds")#</td>
									<td><input type="text" name="seconds" size="2" maxlength="2" value="<cfif seconds EQ "">00<cfelse>#seconds#</cfif>" /></td>
								</tr>
								<tr>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_start_time")#</td>
									<td colspan="3"><input type="text" name="startTime3" size="6" onBlur="fixTime(this)" value="<cfif qry_detail.sched_start_time EQ "">#LSTimeFormat(Now(), 'HH:mm')#<cfelse>#LSTimeFormat(qry_detail.sched_start_time, 'HH:mm')#</cfif>" /></td>
									<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_end_time")#</td>
									<td><input type="text" name="endTime" size="6" onBlur="fixTime(this)" value="<cfif qry_detail.sched_end_time EQ "">#LSTimeFormat(DateAdd("h", 6, Now()), 'HH:mm')#<cfelse>#LSTimeFormat(qry_detail.sched_end_time, 'HH:mm')#</cfif>" /></td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td colspan="2"><em>(Time is server time. Current time is: #LSTimeFormat(now(), 'HH:mm')#)</em></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<div id="task_lower_part">
					<table border="0" cellspacing="0" cellpadding="0" class="gridno">
						<tr>
							<td width="150" nowrap="true">#myFusebox.getApplicationData().defaults.trans("choose_location")#</td>
							<td>
								<input type="text" name="folder_name" size="25" disabled="true" value="#qry_detail.folder_name#" /> <a href="##" onclick="showwindow('#myself#c.scheduler_choose_folder','#myFusebox.getApplicationData().defaults.trans("choose_location")#',600,2);">#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_task_folder_cap")#</a>
							</td>
						</tr>
						<tr>
							<td>#myFusebox.getApplicationData().defaults.trans("scheduled_uploads_zip_archive")#</td>
							<td><input type="checkbox" name="zipExtract" value="1" <cfif qry_detail.sched_zip_extract EQ 1 OR qry_detail.sched_zip_extract EQ ""> checked</cfif>> #myFusebox.getApplicationData().defaults.trans("scheduled_uploads_extract_zip")#</td>
						</tr>
						<tr>
							<td>Rendition Templates</td>
							<td>
								<cfif qry_templates.recordcount NEQ 0>
									<select name="upl_template">
										<option value="0"<cfif qry_detail.sched_upl_template EQ 0> selected="selected"</cfif>>Choose Rendition Template</option>
										<option value="0">---</option>
										<cfloop query="qry_templates">
											<option value="#upl_temp_id#"<cfif qry_detail.sched_upl_template EQ upl_temp_id> selected="selected"</cfif>>#upl_name#</option>
										</cfloop>
									</select>
								</cfif>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="right"><input type="submit" value="#myFusebox.getApplicationData().defaults.trans("button_save")#" class="button"></td>
		</tr>
</table>
</form>
</cfoutput>
<cfif application.razuna.isp>
	<script type="text/javascript">
		$('#detailsServer_new').css('display','none');
		$('#detailsMail_new').css('display','none');
		$('#detailsFtp_new').css('display','block');
		$('#detailsADUserGroup_new').css('display','none');
	</script>
</cfif>
<cfif qry_detail.sched_method EQ "rebuild" OR qry_detail.sched_method EQ "indexing" OR qry_detail.sched_method EQ "ADServer">
	<script type="text/javascript">
		showConnectDetail('new');
		// showFrequencyDetail('new');
	</script>
</cfif>