<cftry>

	<cfset consoleoutput(true)>
	<cfset console("#now()# --- Executing cron job to clean up trash")>

	<!--- Path --->
	<cfset _path = expandPath("../..")>
	<!--- Set time for remove --->
	<cfset _removetime = DateAdd("d", -30, now())>

	<!--- Get database --->
	<cfquery datasource="razuna_default" name="_config">
	SELECT conf_datasource, conf_database, conf_datasource, conf_storage, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_aws_tenant_in_one_bucket_name, conf_aws_tenant_in_one_bucket_enable
	FROM razuna_config
	</cfquery>

	<!--- Set DB --->
	<cfset _db = _config.conf_datasource>
	<cfset _storage = _config.conf_storage>

	<!--- Get all the hosts --->
	<cfquery datasource="#_db#" name="_qry_hosts">
	SELECT host_shard_group, host_id
	FROM hosts
	GROUP BY host_id, host_shard_group
	</cfquery>

	<cfinvoke component="global.cfc.global" method="_lockFile" qry="#_qry_hosts#" type="trash" returnvariable="_hosts" />

	<cfloop query="_hosts">

		<!--- Get host settings --->
		<cfquery datasource="#_db#" name="qry_host_settings">
		SELECT set2_path_to_assets, set2_aws_bucket
		FROM #host_shard_group#settings_2
		WHERE set2_id = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#host_id#">
		</cfquery>

		<!--- Images --->
		<cfquery datasource="#_db#" name="qry_img">
		SELECT img_id as id, path_to_asset
		FROM #host_shard_group#images
		WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND img_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
		ORDER BY img_id
		LIMIT 100
		</cfquery>
		<!--- If found --->
		<cfif qry_img.recordcount>
			<cfset console('#now()# ---------------------- Found #qry_img.recordcount# images to remove in the trash')>
			<cfset _deleteImages( file_qry = qry_img, prefix = host_shard_group, host_id = host_id, host_settings = qry_host_settings )>
		</cfif>

		<!--- Videos --->
		<cfquery datasource="#_db#" name="qry_vid">
		SELECT vid_id as id, path_to_asset
		FROM #host_shard_group#videos
		WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND vid_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
		ORDER BY vid_id
		LIMIT 100
		</cfquery>
		<!--- If found --->
		<cfif qry_vid.recordcount>
			<cfset console('#now()# ---------------------- Found #qry_vid.recordcount# videos to remove in the trash')>
			<cfset _deleteVideos( file_qry = qry_vid, prefix = host_shard_group, host_id = host_id, host_settings = qry_host_settings )>
		</cfif>

		<!--- Audios --->
		<cfquery datasource="#_db#" name="qry_aud">
		SELECT aud_id as id, path_to_asset
		FROM #host_shard_group#audios
		WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND aud_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
		ORDER BY aud_id
		LIMIT 100
		</cfquery>
		<!--- If found --->
		<cfif qry_aud.recordcount>
			<cfset console('#now()# ---------------------- Found #qry_aud.recordcount# audios to remove in the trash')>
			<cfset _deleteAudios( file_qry = qry_aud, prefix = host_shard_group, host_id = host_id, host_settings = qry_host_settings )>
		</cfif>

		<!--- Files --->
		<cfquery datasource="#_db#" name="qry_doc">
		SELECT file_id as id, path_to_asset
		FROM #host_shard_group#files
		WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND file_change_time < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#_removetime#">
		ORDER BY file_id
		LIMIT 100
		</cfquery>
		<!--- If found --->
		<cfif qry_doc.recordcount>
			<cfset console('#now()# ---------------------- Found #qry_doc.recordcount# documents to remove in the trash')>
			<cfset _deleteDocs( file_qry = qry_doc, prefix = host_shard_group, host_id = host_id, host_settings = qry_host_settings )>
		</cfif>

		<cfinvoke component="global.cfc.global" method="resetCacheExternal" type="search" host_id="#host_id#"/>
		<cfinvoke component="global.cfc.global" method="resetCacheExternal" type="folders" host_id="#host_id#"/>

	</cfloop>

	<cffunction name="_deleteImages">
		<cfargument name="file_qry" type="query">
		<cfargument name="prefix" type="string">
		<cfargument name="host_id" type="numeric">
		<cfargument name="host_settings" type="query">
		<!--- Look over ids and delete --->
		<cfloop query="arguments.file_qry">
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#images
			WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			AND img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			ORDER BY img_id
			</cfquery>
			<!--- Delete from files DB (including referenced data) --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#images_text
			WHERE img_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete from collection --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from favorites --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#users_favorites
			WHERE fav_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND fav_kind = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Versions --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#versions
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND ver_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Share Options --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#share_options
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete aliases --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_aliases
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete labels --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_labels
			WHERE ct_id_r = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			<!--- Custom field values --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#custom_fields_values
			WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			</cfquery>
			<!--- Delete file --->
			<cfset var s = structNew()>
			<cfset s.id = id>
			<cfset s.path_to_asset = path_to_asset>
			<cfset _deleteFile(file_data = s, prefix = arguments.prefix, host_id = arguments.host_id, host_settings = arguments.host_settings, category = "img")>
		</cfloop>
		<!--- Reset cache --->
		<cfinvoke component="global.cfc.global" method="resetCacheExternal" type="images" host_id="#arguments.host_id#"/>
	</cffunction>

	<cffunction name="_deleteVideos">
		<cfargument name="file_qry" type="query">
		<cfargument name="prefix" type="string">
		<cfargument name="host_id" type="numeric">
		<cfargument name="host_settings" type="query">
		<!--- Look over ids and delete --->
		<cfloop query="arguments.file_qry">
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#videos
			WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			AND vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			ORDER BY vid_id
			</cfquery>
			<!--- Delete from files DB (including referenced data) --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#videos_text
			WHERE vid_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete from collection --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from favorites --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#users_favorites
			WHERE fav_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND fav_kind = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Versions --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#versions
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND ver_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Share Options --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#share_options
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete aliases --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_aliases
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete labels --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_labels
			WHERE ct_id_r = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			<!--- Custom field values --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#custom_fields_values
			WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			</cfquery>
			<!--- Delete file --->
			<cfset var s = structNew()>
			<cfset s.id = id>
			<cfset s.path_to_asset = path_to_asset>
			<cfset _deleteFile(file_data = s, prefix = arguments.prefix, host_id = arguments.host_id, host_settings = arguments.host_settings, category = "vid")>
		</cfloop>
		<!--- Reset cache --->
		<cfinvoke component="global.cfc.global" method="resetCacheExternal" type="videos" host_id="#arguments.host_id#"/>
	</cffunction>

	<cffunction name="_deleteAudios">
		<cfargument name="file_qry" type="query">
		<cfargument name="prefix" type="string">
		<cfargument name="host_id" type="numeric">
		<cfargument name="host_settings" type="query">
		<!--- Look over ids and delete --->
		<cfloop query="arguments.file_qry">
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#audios
			WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			AND aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			ORDER BY aud_id
			</cfquery>
			<!--- Delete from files DB (including referenced data) --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#audios_text
			WHERE aud_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete from collection --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from favorites --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#users_favorites
			WHERE fav_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND fav_kind = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Versions --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#versions
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND ver_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Share Options --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#share_options
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete aliases --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_aliases
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete labels --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_labels
			WHERE ct_id_r = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			<!--- Custom field values --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#custom_fields_values
			WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			</cfquery>
			<!--- Delete file --->
			<cfset var s = structNew()>
			<cfset s.id = id>
			<cfset s.path_to_asset = path_to_asset>
			<cfset _deleteFile(file_data = s, prefix = arguments.prefix, host_id = arguments.host_id, host_settings = arguments.host_settings, category = "aud")>
		</cfloop>
		<!--- Reset cache --->
		<cfinvoke component="global.cfc.global" method="resetCacheExternal" type="audios" host_id="#arguments.host_id#"/>
	</cffunction>

	<cffunction name="_deleteDocs">
		<cfargument name="file_qry" type="query">
		<cfargument name="prefix" type="string">
		<cfargument name="host_id" type="numeric">
		<cfargument name="host_settings" type="query">
		<!--- Look over ids and delete --->
		<cfloop query="arguments.file_qry">
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#files
			WHERE in_trash = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
			AND file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			ORDER BY file_id
			</cfquery>
			<!--- Delete from collection --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#collections_ct_files
			WHERE file_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND col_file_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from favorites --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#users_favorites
			WHERE fav_id = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND fav_kind = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Versions --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#versions
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			AND ver_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Delete from Share Options --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#share_options
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete aliases --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_aliases
			WHERE asset_id_r = <cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<!--- Delete labels --->
			<cfquery datasource="#_db#">
			DELETE FROM ct_labels
			WHERE ct_id_r = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			<!--- Custom field values --->
			<cfquery datasource="#_db#">
			DELETE FROM #arguments.prefix#custom_fields_values
			WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#">
			</cfquery>
			<!--- Delete file --->
			<cfset var s = structNew()>
			<cfset s.id = id>
			<cfset s.path_to_asset = path_to_asset>
			<cfset _deleteFile(file_data = s, prefix = arguments.prefix, host_id = arguments.host_id, host_settings = arguments.host_settings, category = "doc")>
		</cfloop>
		<!--- Reset cache --->
		<cfinvoke component="global.cfc.global" method="resetCacheExternal" type="files" host_id="#arguments.host_id#"/>
	</cffunction>

	<!--- Filesytem remove --->
	<cffunction name="_deleteFile" output="false">
		<cfargument name="file_data" type="struct">
		<cfargument name="prefix" type="string">
		<cfargument name="category" type="string">
		<cfargument name="host_id" type="numeric">
		<cfargument name="host_settings" type="query">
		<cfset var qry = "">
		<cftry>
			<!--- Add to lucene delete table --->
			<cfquery datasource="#_db#">
			INSERT INTO lucene
			(id, type, host_id, time_stamp)
			VALUES (
				<cfqueryparam value="#arguments.file_data.id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.category#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.host_id#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			)
			</cfquery>
			<!--- Delete File --->
			<cfif _storage EQ "local">
				<cfif DirectoryExists("#arguments.host_settings.set2_path_to_assets#/#arguments.host_id#/#arguments.file_data.path_to_asset#") AND arguments.file_data.path_to_asset NEQ "">
					<cfdirectory action="delete" directory="#arguments.host_settings.set2_path_to_assets#/#arguments.host_id#/#arguments.file_data.path_to_asset#" recurse="true">
				</cfif>
				<!--- Versions --->
				<cfif DirectoryExists("#arguments.host_settings.set2_path_to_assets#/#arguments.host_id#/versions/img/#arguments.file_data.id#") AND arguments.file_data.id NEQ "">
					<cfdirectory action="delete" directory="#arguments.host_settings.set2_path_to_assets#/#arguments.host_id#/versions/img/#arguments.file_data.id#" recurse="true">
				</cfif>
			<!--- Amazon --->
			<cfelseif _storage EQ "amazon">
				<cfif arguments.file_data.path_to_asset NEQ "">
					<cfinvoke component="global.cfc.amazon" method="deletefolder" folderpath="#arguments.file_data.path_to_asset#" awsbucket="#arguments.host_settings.set2_aws_bucket#" tenant_enable="#_config.conf_aws_tenant_in_one_bucket_enable#" tenant_bucket="#_config.conf_aws_tenant_in_one_bucket_name#" from_cron="true" config="#_config#" host_id="#arguments.host_id#" />
					<!--- Versions --->
					<cfinvoke component="global.cfc.amazon" method="deletefolder" folderpath="versions/img/#arguments.file_data.id#" awsbucket="#arguments.host_settings.set2_aws_bucket#" tenant_enable="#_config.conf_aws_tenant_in_one_bucket_enable#" tenant_bucket="#_config.conf_aws_tenant_in_one_bucket_name#" from_cron="true" config="#_config#" host_id="#arguments.host_id#" />
				</cfif>
			</cfif>
			<cfcatch type="any">
				<cfset console("#now()# ---------------------- Error deleting file from trash cron job")>
				<cfset console(cfcatch)>
			</cfcatch>
		</cftry>
		<!--- REMOVE RELATED FOLDERS ALSO!!!! --->
		<cfif arguments.category EQ "img">
			<cfset _group = "img_group">
			<cfset _order = "img_id">
			<cfset _table = "images">
		<cfelseif arguments.category EQ "vid">
			<cfset _group = "vid_group">
			<cfset _order = "vid_id">
			<cfset _table = "videos">
		<cfelseif arguments.category EQ "aud">
			<cfset _group = "aud_group">
			<cfset _order = "aud_id">
			<cfset _table = "audios">
		</cfif>

		<cfif arguments.category NEQ "doc">

			<!--- Get all that have the same id for related --->
			<cfquery datasource="#_db#" name="qry">
			SELECT path_to_asset
			FROM #arguments.prefix##_table#
			WHERE #_group# = <cfqueryparam value="#arguments.file_data.id#" cfsqltype="CF_SQL_VARCHAR">
			ORDER BY #_order#
			</cfquery>
			<!--- Loop over the found records --->
			<cfloop query="qry">
				<cftry>
					<cfif _storage EQ "local">
						<cfif DirectoryExists("#arguments.host_settings.set2_path_to_assets#/#arguments.host_id#/#path_to_asset#") AND path_to_asset NEQ "">
							<cfdirectory action="delete" directory="#arguments.host_settings.set2_path_to_assets#/#arguments.host_id#/#path_to_asset#" recurse="true">
						</cfif>
					<cfelseif _storage EQ "amazon" AND path_to_asset NEQ "">
						<cfinvoke component="global.cfc.amazon" method="deletefolder" folderpath="#path_to_asset#" awsbucket="#arguments.host_settings.set2_aws_bucket#" tenant_enable="#_config.conf_aws_tenant_in_one_bucket_enable#" tenant_bucket="#_config.conf_aws_tenant_in_one_bucket_name#" from_cron="true" config="#_config#" host_id="#arguments.host_id#" />
					</cfif>
					<cfcatch type="any">
						<cfset console("#now()# ---------------------- Error in trash file remove cron job")>
						<cfset console(cfcatch)>
					</cfcatch>
				</cftry>
			</cfloop>
			<!--- Delete related in db as well --->
			<cfif qry.recordcount NEQ 0>
				<cfquery datasource="#_db#">
				DELETE FROM #arguments.prefix##_table#
				WHERE #_group# = <cfqueryparam value="#arguments.file_data.id#" cfsqltype="CF_SQL_VARCHAR">
				ORDER BY #_order#
				</cfquery>
			</cfif>

		</cfif>

		<cfreturn />
	</cffunction>

	<cfinvoke component="global.cfc.global" method="_removeLockFile" qry_remove_lock="#_qry_hosts#" type="trash"/>

	<cfset console("#now()# --- Finished cron job to clean up trash")>

	<cfcatch type="any">
		<cfset console("#now()# ---------------------- Error in trash remove cron job")>
		<cfset console(cfcatch)>
	</cfcatch>
</cftry>
