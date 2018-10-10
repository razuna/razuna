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
<cfabort>

<cftry>

	<cfset consoleoutput(true, true)>
	<cfset console("#now()# --- Executing cron job folder subscribe")>

	<!--- Path --->
	<cfset _path = expandPath("../..")>

	<!--- Get database --->
	<cfquery datasource="razuna_default" name="_config">
	SELECT conf_datasource, conf_database, conf_storage, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_aws_tenant_in_one_bucket_name, conf_aws_tenant_in_one_bucket_enable, conf_url_assets
	FROM razuna_config
	</cfquery>

	<!--- Set DB --->
	<cfset _db = _config.conf_datasource>
	<cfset _storage = _config.conf_storage>

	<cfset application.razuna.datasource = _db>

	<!--- Get all the hosts --->
	<cfquery datasource="#_db#" name="_qry_hosts">
	SELECT host_shard_group, host_id
	FROM hosts
	GROUP BY host_id, host_shard_group
	</cfquery>

	<!--- Create lock files --->
	<cfinvoke component="global.cfc.global" method="_lockFile" qry="#_qry_hosts#" type="folder_subscribe" returnvariable="_hosts" />

	<!--- START --->

	<cfloop query="_hosts">
		<cfinvoke component="global.cfc.folders" method="recfolder" thelist="1" returnvariable="folders_list" datasource="#_db#" host_id="1" hostdbprefix="#host_shard_group#" />
		<!--- Delete users without access --->
		<cfset _getUsersWithoutAccess(datasource=_db, host_id=host_id, dbprefix=host_shard_group)>
		<!--- Get all users and send out emails --->
		<cfset _getUsersSubscriptions(datasource=_db, host_id=host_id, dbprefix=host_shard_group)>
	</cfloop>


	<!--- Delete Users that no longer have permissions to access the folder to whom they were subscribed --->
	<cffunction name="_getUsersWithoutAccess" access="private" returntype="void">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="dbprefix" type="string" required="yes">
		<cfargument name="host_id" type="numeric" required="yes">

		<cfset var getusers_wo_access = "">
		<cfquery datasource="#arguments.datasource#" name="getusers_wo_access">
		SELECT f.folder_id, u.user_id, f.host_id
		FROM #arguments.dbprefix#folders f
		INNER JOIN #arguments.dbprefix#folder_subscribe fs ON f.folder_id = fs.folder_id AND f.host_id = #arguments.host_id#
		INNER JOIN users u ON u.user_id = fs.user_id
		WHERE
		<!--- User is not administrator --->
		NOT EXISTS (SELECT 1 FROM ct_groups_users cu WHERE cu.ct_g_u_user_id = fs.user_id AND cu.ct_g_u_grp_id in ('1','2'))
		<!--- User is not folder_owner --->
		AND f.folder_owner <>  fs.user_id
		 <!--- Folder is not shared with everybody --->
		AND NOT EXISTS (SELECT 1 FROM #arguments.dbprefix#folders_groups fg WHERE f.folder_id = fg.folder_id_r AND fg.grp_id_r = '0')
		<!--- User is not part of group that has access to folder --->
		AND NOT EXISTS (SELECT 1 FROM ct_groups_users cu, #arguments.dbprefix#folders_groups g WHERE cu.ct_g_u_user_id = fs.user_id AND cu.ct_g_u_grp_id = g.grp_id_r AND f.folder_id = g.folder_id_r)
		</cfquery>
		<cfloop query="getusers_wo_access">
			<cfquery datasource="#arguments.datasource#">
			DELETE
			FROM #arguments.dbprefix#folder_subscribe
			WHERE folder_id = <cfqueryparam value="#getusers_wo_access.folder_id#" cfsqltype="cf_sql_varchar">
			AND user_id = <cfqueryparam value="#getusers_wo_access.user_id#" cfsqltype="cf_sql_varchar">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.host_id#">
			</cfquery>
		</cfloop>

	</cffunction>

	<!--- Get User subscribed folders --->
	<cffunction name="_getUsersSubscriptions" access="private" returntype="void">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="dbprefix" type="string" required="yes">
		<cfargument name="host_id" type="numeric" required="yes">

		<cfset var getusers_wo_access = "">
		<!--- Get User subscribed folders --->
		<cfquery datasource="#arguments.datasource#" name="qGetUserSubscriptions">
		SELECT fs.fs_id, fs.user_id, fs.folder_id, fs.asset_description, fs.asset_keywords, fs.last_mail_notification_time, fs.host_id, fo.folder_name
		FROM #arguments.dbprefix#folder_subscribe fs
		LEFT JOIN #arguments.dbprefix#folders fo ON fs.folder_id = fo.folder_id AND fs.host_id = #arguments.host_id#
		WHERE
		<!--- H2 or MSSQL --->
		<cfif application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "mssql">
			DATEADD(HOUR, mail_interval_in_hours, last_mail_notification_time)
		<!--- MYSQL --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			DATE_ADD(last_mail_notification_time, INTERVAL mail_interval_in_hours HOUR)
		</cfif>
		< <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
		</cfquery>

		<!--- Date Format --->
		<cfinvoke component="global.cfc.defaults" method="getdateformat" returnvariable="dateformat" datasource="#arguments.datasource#" hostid="#arguments.host_id#" hostdbprefix="#arguments.dbprefix#">
		<!--- Get Assets Log of Subscribed folders --->
		<cfoutput query="qGetUserSubscriptions">
			<!--- Var --->
			<cfset var qGetUpdatedAssets = "">
			<cfset var folders_list = "">
			<cfset var damset = "">
			<!--- Get Sub-folders of Folder subscribe --->
			<cfinvoke component="global.cfc.folders" method="recfolder" thelist="#qGetUserSubscriptions.folder_id#" returnvariable="folders_list" datasource="#arguments.datasource#" hostid="#arguments.host_id#" hostdbprefix="#arguments.dbprefix#" />
			<!--- Get UPC setting --->
			<cfinvoke component="global.cfc.settings" method="getsettingsfromdam" returnvariable="damset" />
			<!--- Get Updated Assets --->
			<cfquery datasource="#arguments.datasource#" name="qGetUpdatedAssets">
			SELECT l.asset_id_r, l.log_timestamp, l.log_action, l.log_file_type, l.log_desc, l.host_id, u.user_first_name, u.user_last_name, u.user_id, fo.folder_name, ii.path_to_asset img_asset_path, aa.path_to_asset aud_asset_path, vv.path_to_asset vid_asset_path, ff.path_to_asset file_asset_path,
			ii.img_filename_org img_filenameorg, aa.aud_name_org aud_filenameorg,vv.vid_name_org vid_filenameorg, ff.file_name_org file_filenameorg, ii.cloud_url_org img_cloud_url, aa.cloud_url_org aud_cloud_url, vv.cloud_url_org vid_cloud_url, ff.cloud_url_org file_cloud_url , ii.thumb_extension img_thumb_ext, vv.vid_name_image vid_thumb, ii.cloud_url img_cloud_thumb, vv.cloud_url vid_cloud_thumb
			<cfif qGetUserSubscriptions.asset_keywords eq 'T' OR qGetUserSubscriptions.asset_description eq 'T'>
				, a.aud_description, a.aud_keywords, v.vid_keywords, v.vid_description,
				i.img_keywords, i.img_description, f.file_desc, f.file_keywords
			</cfif>
			<cfif damset.set2_upc_enabled EQ 'true'>
				, ii.img_upc_number, aa.aud_upc_number, vv.vid_upc_number, ff.file_upc_number
			</cfif>
			FROM #arguments.dbprefix#log_assets l
			LEFT JOIN users u ON l.log_user = u.user_id
			LEFT JOIN #arguments.dbprefix#folders fo ON l.folder_id = fo.folder_id AND l.host_id = #arguments.host_id#
			LEFT JOIN #arguments.dbprefix#audios aa ON aa.aud_id = l.asset_id_r AND l.host_id = #arguments.host_id#
			LEFT JOIN #arguments.dbprefix#files ff ON ff.file_id = l.asset_id_r AND l.host_id = #arguments.host_id#
			LEFT JOIN #arguments.dbprefix#images ii ON ii.img_id = l.asset_id_r AND l.host_id = #arguments.host_id#
			LEFT JOIN #arguments.dbprefix#videos vv ON vv.vid_id = l.asset_id_r AND l.host_id = #arguments.host_id#
			<cfif qGetUserSubscriptions.asset_keywords eq 'T' OR qGetUserSubscriptions.asset_description eq 'T'>
				LEFT JOIN #arguments.dbprefix#audios_text a ON a.aud_id_r = l.asset_id_r AND a.lang_id_r = 1 AND l.host_id = #arguments.host_id#
				LEFT JOIN #arguments.dbprefix#files_desc f ON f.file_id_r = l.asset_id_r AND f.lang_id_r = 1 AND l.host_id = #arguments.host_id#
				LEFT JOIN #arguments.dbprefix#images_text i ON i.img_id_r = l.asset_id_r AND i.lang_id_r = 1 AND l.host_id = #arguments.host_id#
				LEFT JOIN #arguments.dbprefix#videos_text v ON v.vid_id_r = l.asset_id_r AND v.lang_id_r = 1 AND l.host_id = #arguments.host_id#
			</cfif>
			WHERE l.folder_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#folders_list#" list="true">)
			AND l.log_timestamp > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#qGetUserSubscriptions.last_mail_notification_time#">
			AND l.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.host_id#">
			ORDER BY l.log_timestamp DESC
			</cfquery>
			<!--- Vars --->
			<cfset var data = "">
			<cfset var datacols = "">
			<cfset var fields = "">
			<!--- Get metafields --->
			<cfinvoke component="global.cfc.settings" method="get_notifications" returnvariable="fields">
			<!--- Get Email subject --->
			<cfif fields.set2_folder_subscribe_email_sub NEQ "">
				<cfset email_subject = "#fields.set2_folder_subscribe_email_sub#">
			<cfelse>
				<cfinvoke component="global.cfc.defaults" method="trans" transid="subscribe_email_subject" returnvariable="email_subject">
			</cfif>
			<!--- Get Email Introduction--->
			<cfif len(fields.set2_folder_subscribe_email_body) GT 10>
				<cfset email_intro = "#fields.set2_folder_subscribe_email_body#">
			<cfelse>
				<cfinvoke component="global.cfc.defaults" method="trans" transid="subscribe_email_content" returnvariable="email_intro">
			</cfif>

			<!--- Email if assets are updated in Subscribed folders --->
			<cfif qGetUpdatedAssets.recordcount>
				<!--- Get columns --->
				<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid="#qGetUpdatedAssets.asset_id_r#" metafields="#fields.set2_folder_subscribe_meta#" returnvariable="datacols">
				<!--- Mail content --->
				<cfsavecontent variable="mail" >
					#email_intro#<br>
					<h3>Subscribed Folder: #qGetUserSubscriptions.folder_name#</h3>
					<table border="1" cellpadding="4" cellspacing="0">
						<tr>
							<th nowrap="true">Date</th>
							<th nowrap="true">Time</th>
							<th nowrap="true">Thumb</th>
							<th nowrap="true">Folder/<br>Sub-Folder</th>
							<cfif damset.set2_upc_enabled EQ 'true'>
								<th>UPC Number</th>
							</cfif>
							<cfif qGetUserSubscriptions.asset_description eq 'T'>
								<th>Asset Description</th>
							</cfif>
							<cfif qGetUserSubscriptions.asset_keywords eq 'T'>
								<th>Asset Keywords</th>
							</cfif>
							<th nowrap="true">Action</th>
							<th >Details</th>
							<th nowrap="true">Type of file</th>
							<th nowrap="true">User</th>
							<th>File URL</th>
							<cfloop list="#datacols.columnlist#" index="col">
								<th nowrap="true">#col#</th>
							</cfloop>
						</tr>
					<cfloop query="qGetUpdatedAssets">
						<tr >
							<td nowrap="true" valign="top">#dateformat(qGetUpdatedAssets.log_timestamp, "#dateformat#")#</td>
							<td nowrap="true" valign="top">#timeFormat(qGetUpdatedAssets.log_timestamp, 'HH:mm:ss')#</td>
							<td>
							<!--- If action is not file delete then show thumb--->
							<cfif qGetUpdatedAssets.log_action NEQ 'delete'>
								<cfif application.razuna.storage EQ "local">
									<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
										<cfcase value="img">
											<cfif img_asset_path NEQ "">
												<img src= "#_config.conf_url_assets#/assets/#arguments.host_id#/#img_asset_path#/thumb_#qGetUpdatedAssets.asset_id_r#.#img_thumb_ext#" height="50" onerror = "this.src=''">
											</cfif>
										</cfcase>
										<cfcase value="vid">
											<cfif vid_asset_path NEQ "">
												<img src="#_config.conf_url_assets#/assets/#arguments.host_id#/#vid_asset_path#/#vid_thumb#"  height="50" onerror = "this.src=''">
											</cfif>
										</cfcase>
									</cfswitch>
								<cfelse>
									<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
										<cfcase value="img">
											<img src="#img_cloud_thumb#"  height="50" onerror = "this.src=''">
										</cfcase>
										<cfcase value="vid">
											<img src="#vid_cloud_thumb#"  height="50" onerror = "this.src=''">
										</cfcase>
									</cfswitch>

								</cfif>
							</cfif>
							</td>
							<td valign="top">#qGetUpdatedAssets.folder_name#</td>
							<cfif damset.set2_upc_enabled EQ 'true'>
								<td>&nbsp;
								<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
									<cfcase value="img">
										#qGetUpdatedAssets.img_upc_number#
									</cfcase>
									<cfcase value="doc">
										#qGetUpdatedAssets.file_upc_number#
									</cfcase>
									<cfcase value="vid">
										#qGetUpdatedAssets.vid_upc_number#
									</cfcase>
									<cfcase value="aud">
										#qGetUpdatedAssets.aud_upc_number#
									</cfcase>
								</cfswitch>
								</td>
							</cfif>
							<cfif qGetUserSubscriptions.asset_description eq 'T'>
								<td>&nbsp;
								<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
									<cfcase value="img">
										#qGetUpdatedAssets.img_description#
									</cfcase>
									<cfcase value="doc">
										#qGetUpdatedAssets.file_desc#
									</cfcase>
									<cfcase value="vid">
										#qGetUpdatedAssets.vid_description#
									</cfcase>
									<cfcase value="aud">
										#qGetUpdatedAssets.aud_description#
									</cfcase>
								</cfswitch>
								</td>
							</cfif>
							<cfif qGetUserSubscriptions.asset_keywords eq 'T'>
								<td>&nbsp;
								<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
									<cfcase value="img">
										#qGetUpdatedAssets.img_keywords#
									</cfcase>
									<cfcase value="doc">
										#qGetUpdatedAssets.file_keywords#
									</cfcase>
									<cfcase value="vid">
										#qGetUpdatedAssets.vid_keywords#
									</cfcase>
									<cfcase value="aud">
										#qGetUpdatedAssets.aud_keywords#
									</cfcase>
								</cfswitch>
								</td>
							</cfif>
							<td nowrap="true" align="center" valign="top">#qGetUpdatedAssets.log_action#</td>
							<td valign="top">#qGetUpdatedAssets.log_desc#</td>
							<td nowrap="true" align="center" valign="top">#qGetUpdatedAssets.log_file_type#</td>
							<td nowrap="true" align="center" valign="top">#qGetUpdatedAssets.user_first_name# #qGetUpdatedAssets.user_last_name#</td>
							<td align="center" valign="top" width="80">
							<!--- If action is not file delete then show file url --->
							<cfif qGetUpdatedAssets.log_action NEQ 'delete'>
								<cfif application.razuna.storage EQ "local">
									<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
										<cfcase value="img">
											<cfif img_asset_path NEQ "">
												#_config.conf_url_assets#/assets/#arguments.host_id#/#img_asset_path#/#img_filenameorg#
											</cfif>
										</cfcase>
										<cfcase value="doc">
											<cfif file_asset_path NEQ "">
												#_config.conf_url_assets#/assets/#arguments.host_id#/#file_asset_path#/#file_filenameorg#
											</cfif>
										</cfcase>
										<cfcase value="vid">
											<cfif vid_asset_path NEQ "">
												#_config.conf_url_assets#/assets/#arguments.host_id#/#vid_asset_path#/#vid_filenameorg#
											</cfif>
										</cfcase>
										<cfcase value="aud">
											<cfif aud_asset_path NEQ "">
												#_config.conf_url_assets#/assets/#arguments.host_id#/#aud_asset_path#/#aud_filenameorg#
											</cfif>
										</cfcase>
									</cfswitch>
								<cfelse>
									<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
										<cfcase value="img">
											<cfif img_cloud_url NEQ "">
												#img_cloud_url#
											</cfif>
										</cfcase>
										<cfcase value="doc">
											<cfif file_cloud_url NEQ "">
												#file_cloud_url#
											</cfif>
										</cfcase>
										<cfcase value="vid">
											<cfif vid_cloud_url NEQ "">
												#vid_cloud_url#
											</cfif>
										</cfcase>
										<cfcase value="aud">
											<cfif aud_cloud_url NEQ "">
												#aud_cloud_url#
											</cfif>
										</cfcase>
									</cfswitch>

								</cfif>
							</cfif>
							</td>
							<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid= "#qGetUpdatedAssets.asset_id_r#" metafields="#fields.set2_folder_subscribe_meta#" returnvariable="data">
							<cfloop list="#datacols.columnlist#" index="col">
								<td>#data["#col#"][1]#</td>
							</cfloop>
						</tr>

					</cfloop>
					</table>
				</cfsavecontent>
				<!--- Set user id --->
				<cfset arguments.thestruct.user_id = qGetUserSubscriptions.user_Id>
				<!--- Get user details --->
				<cfinvoke component="global.cfc.users" method="details" thestruct="#arguments.thestruct#" returnvariable="usersdetail">
				<!--- Send the email --->
				<cfinvoke component="global.cfc.email" method="send_email" to="#usersdetail.user_email#" subject="#email_subject#" themessage="#mail#" userid="#usersdetail.user_id#" dsn="#arguments.datasource#" hostid="#arguments.host_id#" hostdbprefix="#arguments.dbprefix#" />
			</cfif>
			<!--- Update Folder Subscribe --->
			<cfquery datasource="#arguments.datasource#">
			UPDATE #arguments.dbprefix#folder_subscribe
			SET last_mail_notification_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			WHERE fs_id = <cfqueryparam value="#qGetUserSubscriptions.fs_id#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfoutput>

	</cffunction>

	<!--- END --->

	<!--- Remove lock --->
	<cfinvoke component="global.cfc.global" method="_removeLockFile" qry_remove_lock="#_qry_hosts#" type="folder_subscribe"/>

	<cfset console("#now()# --- Finished cron job folder subscribe")>

	<cfcatch type="any">
		<cfset console("#now()# ---------------------- Error folder subscribe cron job")>
		<cfset console(cfcatch)>
	</cfcatch>
</cftry>
