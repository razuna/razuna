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

<!---  --->
<!--- UPDATE TABLES FOR 1.4.2 --->
<!---  --->

<cfcomponent output="true">
	
	<!--- 1. Drop all foreign keys first --->
	<!--- 2. Convert all int keys to varchar --->
	<!--- 3. Add the foreign keys again --->
	
	<!--- DO DB update --->
	<cffunction name="update_do">
		<!--- Feedback --->
		<cfoutput><strong>Starting the Update. Churning on some internal stuff...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Work on these databases --->
		<cfset tbl_defaults = "users,webservices,groups,ct_groups_users,ct_groups_permissions,ct_users_hosts">
		<cfset tbl_hosts = "raz1_users_favorites,users_comments,raz1_images,raz1_images_text,raz1_folders,raz1_folders_desc,raz1_folders_groups,raz1_files,raz1_files_desc,raz1_collections,raz1_collections_ct_files,raz1_collections_groups,raz1_collections_text,raz1_videos,raz1_videos_text,raz1_schedules,raz1_audios,raz1_audios_text,raz1_share_options,raz1_log_assets,raz1_log_folders,raz1_log_users,raz1_log_search,raz1_schedules_log,raz1_assets_temp,raz1_cart,raz1_custom_fields,raz1_custom_fields_values,raz1_custom_fields_text,raz1_comments,raz1_versions,raz1_xmp">
		<cfset tbl_all = tbl_defaults & "," & tbl_hosts>
		<!--- Param --->
		<cfset arguments.thestruct = structnew()>
		<!--- Name for the log --->
		<cfset arguments.thestruct.logname = "razuna_update_" & dateformat(now(),"mm_dd_yyyy") & "_" & timeformat(now(),"HH-mm-ss")>
		<!--- Feedback --->
		<cfoutput><strong>Working on each table now ...</strong><br><br></cfoutput>
		<cfflush>
		<!--- ORACLE --->
		<cfif application.razuna.thedatabase EQ "oracle">
			<!--- Insert ID into aud_text --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios_text ADD COLUMN id_inc VARCHAR2(100 CHAR)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<!--- Disable Keys --->
			<cfloop list="#tbl_all#" index="i">
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT lower(table_name), constraint_name
				FROM information_schema.constraint_column_usage
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#%">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #table_name# NOCHECK CONSTRAINT ALL
					</cfquery>
				</cfloop>
			</cfloop>
			<!--- Update tables --->
			<cfinvoke method="update_tables" thestruct="#arguments.thestruct#" />
			<!--- Enable Keys
			<cfloop list="#tbl_all#" index="i">
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT lower(table_name), constraint_name
				FROM information_schema.constraint_column_usage
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#%">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #table_name# CHECK CONSTRAINT ALL
					</cfquery>
				</cfloop>
			</cfloop> --->
		<!--- H2 --->
		<cfelseif application.razuna.thedatabase EQ "h2">
			<!--- Insert ID into aud_text --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios_text ADD COLUMN id_inc VARCHAR2(100 CHAR)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<!--- Disable Keys --->
			<cfquery datasource="#application.razuna.datasource#">
			SET REFERENTIAL_INTEGRITY false
			</cfquery>
			<!--- Update tables --->
			<cfinvoke method="update_tables" thestruct="#arguments.thestruct#" />
			<!--- Enable Keys
			<cfquery datasource="#application.razuna.datasource#">
			SET REFERENTIAL_INTEGRITY true
			</cfquery> --->
		<!--- MYSQL --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			<!--- Insert ID into aud_text --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios_text ADD COLUMN id_inc VARCHAR(100)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<!--- Disable Keys --->
			<cfquery datasource="#application.razuna.datasource#">
			SET foreign_key_checks = 0
			</cfquery>
			<cfloop list="#tbl_all#" index="i">
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE #i# DISABLE KEYS
				</cfquery>
			</cfloop>
			<!--- Drop foreign keys --->
			<cfinvoke method="drop_tables_keys" thestruct="#arguments.thestruct#" />
			<!--- Update tables --->
			<cfinvoke method="update_tables" thestruct="#arguments.thestruct#" />
			<!--- Create foreign keys --->
			<!--- <cfinvoke method="create_tables_keys" thestruct="#arguments.thestruct#" /> --->
			<!--- Enable Keys --->
			<cfquery datasource="#application.razuna.datasource#">
			SET foreign_key_checks = 1
			</cfquery>
			<cfloop list="#tbl_all#" index="i">
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE #i# ENABLE KEYS
				</cfquery>
			</cfloop>
		<!--- MSSQL --->
		<cfelseif application.razuna.thedatabase EQ "mssql">
			<!--- Insert ID into aud_text --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios_text ADD COLUMN id_inc VARCHAR(100)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<!--- Disable Keys --->
			<cfloop list="#tbl_all#" index="i">
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT lower(table_name), constraint_name
				FROM information_schema.constraint_column_usage
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#%">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #table_name# NOCHECK CONSTRAINT ALL
					</cfquery>
				</cfloop>
			</cfloop>
			<!--- Update tables --->
			<cfinvoke method="update_tables" thestruct="#arguments.thestruct#" />
			<!--- Enable Keys
			<cfloop list="#tbl_all#" index="i">
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT lower(table_name), constraint_name
				FROM information_schema.constraint_column_usage
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#%">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #table_name# CHECK CONSTRAINT ALL
					</cfquery>
				</cfloop>
			</cfloop> --->
		<!--- DB2 --->
		<cfelseif application.razuna.thedatabase EQ "db2">
		
		</cfif>
				
		<!--- All done and update should be flying --->
		<!--- Feedback --->
		<cfoutput><span style="color:green;font-weight:bold;">Update successfully finished!</span><br><br><a href="##" onclick="window.close();">Click to close this window</a></cfoutput>
		<cfflush>
	</cffunction>
	
	<!--- drop foreign keys --->
	<cffunction name="drop_tables_keys">
		<cfargument name="thestruct" type="struct" />
		<!--- Tables which to drop foreign key --->
		<cfset tbl_keys = "raz1_users_favorites,raz1_images_text,raz1_files_desc,raz1_collections_text,raz1_collections_ct_files,raz1_collections_groups,raz1_videos_text,raz1_schedules_log,raz1_audios_text,raz1_custom_fields_text,raz1_custom_fields_values,ct_groups_users,ct_groups_permissions">
		<!--- Loop --->
		<cfloop list="#tbl_keys#" index="i">
			<!--- Query constraint name --->
			<cfinvoke method="get_const" thetable="#i#" returnVariable="theconstname" />
			<!--- Drop foreign keys --->		
			<cfif theconstname NEQ "">
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE #i# DROP FOREIGN KEY #theconstname#
				</cfquery>
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- create foreign keys --->
	<cffunction name="create_tables_keys">
		<cfargument name="thestruct" type="struct" />
		<!--- create foreign keys --->		
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_users_favorites ADD FOREIGN KEY (USER_ID_R) REFERENCES users (USER_ID) ON DELETE SET NULL
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_images_text ADD FOREIGN KEY (IMG_ID_R) REFERENCES raz1_images (IMG_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_files_desc ADD FOREIGN KEY (FILE_ID_R)	REFERENCES raz1_files (FILE_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_collections_text ADD FOREIGN KEY (COL_ID_R) REFERENCES raz1_collections (COL_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_collections_ct_files ADD FOREIGN KEY (COL_ID_R) REFERENCES raz1_collections (COL_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_collections_groups ADD FOREIGN KEY (COL_ID_R) REFERENCES raz1_collections (COL_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_videos_text ADD FOREIGN KEY (VID_ID_R) REFERENCES raz1_videos (VID_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_schedules_log ADD FOREIGN KEY (SCHED_ID_R) REFERENCES raz1_schedules (SCHED_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_audios_text ADD FOREIGN KEY (aud_ID_R) REFERENCES raz1_audios (aud_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_custom_fields_text ADD FOREIGN KEY (cf_id_r) REFERENCES raz1_custom_fields (cf_id) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE raz1_custom_fields_values ADD FOREIGN KEY (cf_id_r) REFERENCES raz1_custom_fields (cf_id) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE ct_groups_users ADD FOREIGN KEY (CT_G_U_GRP_ID) REFERENCES groups (GRP_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE ct_groups_permissions ADD FOREIGN KEY (CT_G_P_PER_ID) REFERENCES permissions (PER_ID) ON DELETE CASCADE
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		ALTER TABLE ct_groups_permissions ADD FOREIGN KEY (CT_G_P_GRP_ID)	REFERENCES groups (GRP_ID) ON DELETE CASCADE
		</cfquery>
	</cffunction>
	
	<!--- foreign keys --->
	<cffunction name="get_const">
		<cfargument name="thetable" type="string" />
		<!--- Query constraint name --->
		<cfquery datasource="#application.razuna.datasource#" name="const_name">
		SELECT constraint_name
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
		WHERE lower(table_schema) = 'razuna'
		AND lower(table_name) = '#arguments.thetable#'
		AND constraint_name != 'PRIMARY'
		</cfquery>
		<cfreturn const_name.constraint_name>
	</cffunction>
	
	<!---Update tables --->
	<cffunction name="update_tables">
		<cfargument name="thestruct" type="struct" />
		<!--- Set the alter params --->
		<cfif application.razuna.thedatabase EQ "oracle">
			<cfset alterparam = "MODIFY">
			<cfset altertype = "VARCHAR2(100 CHAR)">
		<!--- H2 --->
		<cfelseif application.razuna.thedatabase EQ "h2">
			<cfset alterparam = "ALTER COLUMN">
			<cfset altertype = "VARCHAR(100)">
		<!--- MYSQL --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			<cfset alterparam = "MODIFY">
			<cfset altertype = "VARCHAR(100)">
		<!--- MSSQL --->
		<cfelseif application.razuna.thedatabase EQ "mssql">
			<cfset alterparam = "ALTER COLUMN">
			<cfset altertype = "VARCHAR(100)">
		</cfif>
		<!--- Log Start --->
		<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Update START">
		<!--- Feedback --->
		<cfoutput><strong>Updating each table now ...</strong><br><br></cfoutput>
		<cfflush>
		<!--- USERS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE users #alterparam# user_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- USERS FAVORITES --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_users_favorites #alterparam# fav_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_users_favorites #alterparam# user_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- USERS COMMENTS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE users_comments #alterparam# user_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- WEBSERVICES --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE webservices #alterparam# userid #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- IMAGES --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_images #alterparam# img_owner #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_images #alterparam# img_group #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_images #alterparam# img_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_images #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- IMAGES TEXT --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_images_text #alterparam# img_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- FOLDERS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders #alterparam# folder_owner #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders #alterparam# folder_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders #alterparam# folder_main_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders #alterparam# share_order_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- FOLDERS DESC --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders_desc #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- FOLDERS GROUPS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders_groups #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_folders_groups #alterparam# grp_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- FILES --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_files #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_files #alterparam# file_owner #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_files #alterparam# file_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- FILES DESC --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_files_desc #alterparam# file_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- COLLECTIONS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections #alterparam# col_owner #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections #alterparam# col_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections #alterparam# share_order_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- COLLECTIONS CT FILES --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections_ct_files #alterparam# file_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections_ct_files #alterparam# col_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- COLLECTIONS GROUPS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections_groups #alterparam# grp_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections_groups #alterparam# col_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- COLLECTIONS TEXT --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_collections_text #alterparam# col_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- VIDEOS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_videos #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_videos #alterparam# vid_owner #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_videos #alterparam# vid_group #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_videos #alterparam# vid_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- VIDEOS TEXT --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_videos_text #alterparam# vid_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- SCHEDULES --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_schedules #alterparam# sched_folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_schedules #alterparam# sched_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_schedules #alterparam# sched_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- AUDIOS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_audios #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_audios #alterparam# aud_owner #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_audios #alterparam# aud_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_audios #alterparam# aud_group #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- AUDIOS TEXT --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_audios_text #alterparam# aud_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_audios_text #alterparam# id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- SHARE OPTIONS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_share_options #alterparam# folder_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_share_options #alterparam# asset_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_share_options #alterparam# group_asset_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<!--- Feedback --->
		<cfoutput><strong>Still updating each table. Almost done ...</strong><br><br></cfoutput>
		<cfflush>
		
		<!--- LOG ASSETS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_assets #alterparam# log_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_assets #alterparam# log_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- LOG FOLDERS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_folders #alterparam# log_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_folders #alterparam# log_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- LOG USERS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_users #alterparam# log_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_users #alterparam# log_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- LOG SEARCH --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_search #alterparam# log_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_log_search #alterparam# log_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- SCHEDULUES_LOG --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_schedules_log #alterparam# sched_log_user #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_schedules_log #alterparam# sched_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_schedules_log #alterparam# sched_log_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- ASSETS TEMP --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_assets_temp #alterparam# sched_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_assets_temp #alterparam# file_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_assets_temp #alterparam# who #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_assets_temp #alterparam# folder_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- CART --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_cart #alterparam# cart_product_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_cart #alterparam# cart_order_user_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		
		<!--- Feedback --->
		<cfoutput><strong>On the finishing line ...</strong><br><br></cfoutput>
		<cfflush>
		
		<!--- CUSTOM FIELDS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_custom_fields #alterparam# cf_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- CUSTOM FIELDS VALUES --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_custom_fields_values #alterparam# cf_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_custom_fields_values #alterparam# asset_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- CUSTOM FIELDS TEXT --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_custom_fields_text #alterparam# cf_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- COMMENT --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_comments #alterparam# asset_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_comments #alterparam# user_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- VERSIONS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_versions #alterparam# asset_id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_versions #alterparam# ver_who #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- XMP --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE raz1_xmp #alterparam# id_r #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- GROUPS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE groups #alterparam# grp_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- CT GROUPS USERS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE ct_groups_users #alterparam# ct_g_u_grp_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE ct_groups_users #alterparam# ct_g_u_user_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- CT GROUPS PERMISSONS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE ct_groups_permissions #alterparam# ct_g_p_grp_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- CT USERS HOSTS --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			ALTER TABLE ct_users_hosts #alterparam# ct_u_h_user_id #altertype#
			</cfquery>
			<cfcatch type="any">
				<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
			</cfcatch>
		</cftry>
		<!--- Change type of id for desc tables --->
		<cfif application.razuna.thedatabase EQ "oracle">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_files_desc RENAME COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_images_text RENAME COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_videos_text RENAME COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios_text RENAME COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
		<!--- H2 --->
		<cfelseif application.razuna.thedatabase EQ "h2">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_files_desc ALTER COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_images_text ALTER COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_videos_text ALTER COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios_text ALTER COLUMN id RENAME TO id_inc
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
		<!--- MYSQL --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_files_desc CHANGE id id_inc VARCHAR(100)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_images_text CHANGE id id_inc VARCHAR(100)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_videos_text CHANGE id id_inc VARCHAR(100)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios_text CHANGE id id_inc VARCHAR(100)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
		<!--- MSSQL --->
		<cfelseif application.razuna.thedatabase EQ "mssql">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				EXEC sp_rename 'raz1_files_desc.id', 'ind_inc', 'COLUMN'
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				EXEC sp_rename 'raz1_images_text.id', 'ind_inc', 'COLUMN'
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				EXEC sp_rename 'raz1_videos_text.id', 'ind_inc', 'COLUMN'
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				EXEC sp_rename 'raz1_audios_text.id', 'ind_inc', 'COLUMN'
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Log Start --->
		<cflog application="no" file="#arguments.thestruct.logname#" type="error" text="Update successfully done!">
	</cffunction>

</cfcomponent>