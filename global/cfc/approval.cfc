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
<cfcomponent output="false" extends="extQueryCaching">
	
	<cfset consoleoutput(true)>

	<!--- INIT --->
	<cffunction name="init" returntype="approval" access="public" output="false">
		<!--- Return --->
		<cfreturn this />
	</cffunction>

	<!--- Admin: Save --->
	<cffunction name="admin_save" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- If enabled is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_enabled" default="false" />
		<!--- If approval_group_1_all is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_group_1_all" default="false" />
		<!--- If approval_group_1_all is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_group_2_all" default="false" />
		<!--- If approval_folders_all is not here we set it to false --->
		<cfparam name="arguments.thestruct.approval_folders_all" default="false" />


		<!--- Set other fields in case user doesn't enter them --->
		<cfparam name="arguments.thestruct.approval_group_1" default="" />
		<cfparam name="arguments.thestruct.approval_group_2" default="" />
		<cfparam name="arguments.thestruct.approval_folders" default="" />

		<!--- Delete record in DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#approval
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Save to DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#approval
		(approval_enabled, approval_folders, approval_folders_all, approval_group_1, approval_group_2, approval_group_1_all, approval_group_2_all, host_id)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_enabled#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.approval_folders#">,
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_folders_all#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.approval_group_1#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.approval_group_2#">,
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_group_1_all#">,
			<cfqueryparam cfsqltype="cf_sql_double" value="#arguments.thestruct.approval_group_2_all#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>

		<cfreturn />
	</cffunction>

	<!--- Admin: Get --->
	<cffunction name="admin_get" access="public" output="true">
		<cfset var qry = "">
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT approval_enabled, approval_folders, approval_folders_all, approval_group_1, approval_group_2, approval_group_1_all, approval_group_2_all
		FROM #session.hostdbprefix#approval
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif qry.recordcount EQ 0>
			<cfset _qry.approval_enabled = false>
			<cfset _qry.approval_folders_all = false>
			<cfset _qry.approval_group_1_all = false>
			<cfset _qry.approval_group_2_all = false>
			<cfset QueryAddrow( query=qry, data=_qry )>
		</cfif>
		<cfreturn qry>
	</cffunction>

	<!--- Check if approval is enabled --->
	<cffunction name="check_enabled" access="public" output="true">
		<cfargument name="folder_id" type="string" required="true" />
		<!--- Param --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT approval_enabled
		FROM #session.hostdbprefix#approval
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.folder_id NEQ 0>
			AND approval_folders IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.folder_id#" list="true">)
			OR approval_folders_all = <cfqueryparam cfsqltype="cf_sql_double" value="1">
		</cfif> 
		</cfquery>
		<!--- If no record we have to add default values to qry --->
		<cfif qry.recordcount EQ 0>
			<cfset _qry.approval_enabled = false>
			<cfset QueryAddrow( query=qry, data=_qry )>
		</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Get approval users --->
	<cffunction name="get_approval_users" access="public" output="true">
		<cfargument name="all" type="boolean" required="true" />
		<!--- Get the approval values --->
		<cfset var _qry_approval = admin_get()>
		<!--- If group is empty --->
		<cfif _qry_approval.approval_group_1 EQ "">
			<cfset _qry_approval.approval_group_1 = 0>
			<cfset _qry_approval.approval_group_2 = 0>
		</cfif>
		<!--- Get all users of groups --->
		<cfinvoke component="global.cfc.groups_users" method="getUsersOfGroups" grp_id="#_qry_approval.approval_group_1#" returnvariable="qry_group_users_1" />
		<!--- Get users --->
		<cfinvoke component="global.cfc.users" method="getAllUsersFromList" user_ids="#_qry_approval.approval_group_1#" returnvariable="qry_users_1" />
		<!--- if all is true --->
		<cfif arguments.all AND _qry_approval.approval_group_2 NEQ "">
			<!--- <cfset console("GROUP 2 CHECK !!!!!!")> --->
			<!--- Get all users of groups --->
			<cfinvoke component="global.cfc.groups_users" method="getUsersOfGroups" grp_id="#_qry_approval.approval_group_2#" returnvariable="qry_group_users_2" />
			<!--- Get users --->
			<cfinvoke component="global.cfc.users" method="getAllUsersFromList" user_ids="#_qry_approval.approval_group_2#" returnvariable="qry_users_2" />
		<cfelse>
			<cfset qry_group_users_2 = queryNew("user_id, user_first_name, user_last_name, user_email")>
			<cfset qry_users_2 = queryNew("user_id, user_first_name, user_last_name, user_email")>
		</cfif>
		<!--- Combine the queries --->
		<cfquery dbtype="query" name="_qry_users">
		SELECT * FROM qry_group_users_1
		UNION ALL
		SELECT * FROM qry_users_1
		UNION ALL
		SELECT * FROM qry_group_users_2
		UNION ALL
		SELECT * FROM qry_users_2
		</cfquery>
		<!--- Return a struct --->
		<cfset var s = structNew()>
		<cfset s.qry = _qry_users>
		<cfset s.user_ids = valueList(_qry_users.user_id)>
		<!--- Return --->
		<cfreturn s>
	</cffunction>

	<!--- Get files in approval process --->
	<cffunction name="get_files" access="public" output="true">
		<!--- Param --->
		<cfset var qry = structNew()>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.files">
		SELECT r.img_id as id, r.img_filename as name, r.img_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, r.thumb_extension, 'img' as kind, u.user_first_name, u.user_last_name, f.folder_name, r.img_owner as file_owner, r.img_filename_org as filename_org, r.img_extension as extension
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#images r LEFT JOIN users u ON u.user_id = r.img_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		UNION ALL
		SELECT r.vid_id as id, r.vid_filename as name, r.vid_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, '' as thumb_extension, 'vid' as kind, u.user_first_name, u.user_last_name, f.folder_name, r.vid_owner as file_owner, r.vid_name_org as filename_org, r.vid_extension as extension
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#videos r LEFT JOIN users u ON u.user_id = r.vid_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		UNION ALL
		SELECT r.aud_id as id, r.aud_name as name, r.aud_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, '' as thumb_extension, 'aud' as kind, u.user_first_name, u.user_last_name, f.folder_name, r.aud_owner as file_owner, r.aud_name_org as filename_org, r.aud_extension as extension
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#audios r LEFT JOIN users u ON u.user_id = r.aud_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		UNION ALL
		SELECT r.file_id as id, r.file_name as name, r.file_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, '' as thumb_extension, 'doc' as kind, u.user_first_name, u.user_last_name, f.folder_name, r.file_owner as file_owner, r.file_name_org as filename_org, r.file_extension as extension
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#files r LEFT JOIN users u ON u.user_id = r.file_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		ORDER BY date_create DESC
		</cfquery>
		<!--- Get the approval done records --->
		<cfif qry.files.recordcount NEQ 0>
			<cfquery datasource="#application.razuna.datasource#" name="qry.done">
			SELECT user_id, approval_date, file_id
			FROM #session.hostdbprefix#approval_done
			WHERE file_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valueList(qry.files.id)#" list="true">)
			</cfquery>
		</cfif>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Execute Approval process --->
	<cffunction name="approval_execute" access="public" output="true">
		<cfargument name="file_id" type="string" required="true" />
		<cfargument name="file_type" type="string" required="true" />
		<cfargument name="file_owner" type="string" required="true" />
		<cfargument name="dynpath" type="string" required="true" />
		<cfargument name="urlglobal" type="string" required="true" />
		<cfargument name="urlasset" type="string" required="true" />

		<!--- Set is_available and is_indexed --->
		<cfset set_values(file_id=arguments.file_id, file_type=arguments.file_type, is_available='2', is_indexed='1')>
		
		<!--- Get the approval values --->
		<cfset var _qry_approval = admin_get()>
		<!--- Get all users of this approval process (we want the list of ids and only for group 1) --->
		<cfset var _qry_users = get_approval_users(false).user_ids>
		<!--- Send out email to approval group --->
		<cfset send_message(group_users=_qry_users, kind='request', file_owner=arguments.file_owner, file_id=arguments.file_id, file_type=arguments.file_type, dynpath=arguments.dynpath, urlasset=arguments.urlasset, urlglobal=arguments.urlglobal)>
		
		<cfset console('DONE !!!!!!!!!!!!!!!!!!!!!!!!!!!!')>

		<cfreturn />
	</cffunction>
	
	<!--- Accept --->
	<cffunction name="approval_accept" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="true" />

		<!--- Param --->
		<cfset var _release_file = true>
		<!--- Get approval record --->
		<cfset var _qry_approval = admin_get()>
		<!--- Set approval in db --->
		<cfset set_approval_done(file_id=arguments.thestruct.file_id)>

		<!--- Approval from all users in group 1 required --->
		<cfif _qry_approval.approval_group_1_all>
			<!--- Check who has approved so far --->
			<cfset var _group_result = get_approval_done(file_id=arguments.thestruct.file_id, group='1', file_type=arguments.thestruct.file_type, dynpath=arguments.thestruct.dynpath, urlasset=arguments.thestruct.urlasset, urlglobal=arguments.thestruct.urlglobal)>
			<!--- If above return false then we need further approval from others --->
			<cfif ! _group_result>
				<cfset console('EVERYONE IN GROUP 1 HAS TO APPROVE!!!!!!!!!!')>
				<!--- If all users have approved, we set the var to true --->
				<cfset var _release_file = false>
			</cfif>
		</cfif>

		<!--- Check if there are any records in approval group 2 --->
		<cfif _release_file AND _qry_approval.approval_group_2_all>
			<cfset console("WE NEED TO CHECK USERS IN GROUP 2")>
			<!--- Check who has approved so far --->
			<cfset var _group_result = get_approval_done(file_id=arguments.thestruct.file_id, group='2', file_type=arguments.thestruct.file_type, dynpath=arguments.thestruct.dynpath, urlasset=arguments.thestruct.urlasset, urlglobal=arguments.thestruct.urlglobal)>
			<!--- If above return false then we need further approval from others --->
			<cfif ! _group_result>
				<cfset console('EVERYONE IN GROUP 2 HAS TO APPROVE!!!!!!!!!!')>
				<!--- If all users have approved, we set the var to true --->
				<cfset var _release_file = false>
			</cfif>
		</cfif>

		<!--- Check if we need to get approval from anyone in group 2 but only if not group all is enabled as this is done above --->
		<cfif _release_file AND ! _qry_approval.approval_group_2_all AND _qry_approval.approval_group_2 NEQ ''>
			<!--- Check if any user in group 2 has approved --->
			<cfset var _group_result = get_approval_done(file_id=arguments.thestruct.file_id, group='2', all=false, file_type=arguments.thestruct.file_type, dynpath=arguments.thestruct.dynpath, urlasset=arguments.thestruct.urlasset, urlglobal=arguments.thestruct.urlglobal)>
			<!--- If none have approved --->
			<cfif ! _group_result>
				<cfset console('NO ONE IN GROUP 2 HAS APPROVED SO FAR !!!!!!!!!!')>
				<!--- If all users have approved, we set the var to true --->
				<cfset var _release_file = false>
			</cfif>
		</cfif>

		<!--- If approved make file available --->
		<cfif _release_file>
			<cfset console('ALL GOOD. WE ARE RELEASING THE FILE !!!!!!!!!!')>
			<!--- Get record --->
			<cfset var _qry_file = get_file_values(file_id=arguments.thestruct.file_id, file_type=arguments.thestruct.file_type, dynpath=arguments.thestruct.dynpath, urlasset=arguments.thestruct.urlasset, urlglobal=arguments.thestruct.urlglobal)>
			<!--- Set is_available and is_indexed --->
			<cfset set_values(file_id=arguments.thestruct.file_id, file_type=arguments.thestruct.file_type, is_available='1', is_indexed='0')>
			<!--- Get all users of this approval process --->
			<cfset var _qry_users = get_approval_users(true).user_ids>
			<!--- Send out email to approval group --->
			<cfset send_message(group_users=_qry_users, kind='done', file_owner=_qry_file.qry.file_owner, file_id=arguments.thestruct.file_id, file_type=arguments.thestruct.file_type, dynpath=arguments.thestruct.dynpath, urlasset=arguments.thestruct.urlasset, urlglobal=arguments.thestruct.urlglobal)>
			
			<!--- Execute workflow --->
			<cfset console("EXECUTE WORKFLOW !!!!!!!!!!!!!")>
			
			<!--- Set vars for workflow --->
			<cfset s.folder_id = _qry_file.qry.folder_id_r>
			<cfset s.fileid = arguments.thestruct.file_id>
			<cfset s.file_name = _qry_file.qry.file_name>
			<cfset s.thefiletype = arguments.thestruct.file_type>
			<!--- Check on any plugin that call the on_file_add action --->
			<cfinvoke component="global.cfc.plugins" method="getactions" theaction="on_file_add" args="#s#" />
			<cfset s.folder_action = true>
			<!--- Check on any plugin that call the on_file_add action --->
			<cfinvoke component="global.cfc.plugins" method="getactions" theaction="on_file_add" args="#s#" />
		</cfif>

		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Reject --->
	<cffunction name="approval_reject" access="public" output="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Remove the file in the system --->
		<!--- Set vars --->
		<cfif arguments.thestruct.file_type EQ "img">
			<cfset var _db = "#session.hostdbprefix#images">
			<cfset var _id = "img_id">
		<cfelseif arguments.thestruct.file_type EQ "vid">
			<cfset var _db = "#session.hostdbprefix#videos">
			<cfset var _id = "vid_id">
		<cfelseif arguments.thestruct.file_type EQ "aud">
			<cfset var _db = "#session.hostdbprefix#audios">
			<cfset var _id = "aud_id">
		<cfelse>
			<cfset var _db = "#session.hostdbprefix#files">
			<cfset var _id = "file_id">
		</cfif>
		<!--- Get all users of this approval process --->
		<cfset var _qry_users = get_approval_users(true).user_ids>
		<!--- Send out the email with the rejection --->
		<cfset send_message(group_users=_qry_users, kind='reject', reject_message=arguments.thestruct.reject_message, file_owner=arguments.thestruct.file_owner, file_id=arguments.thestruct.file_id, file_type=arguments.thestruct.file_type, dynpath=arguments.thestruct.dynpath, urlasset=arguments.thestruct.urlasset, urlglobal=arguments.thestruct.urlglobal)>
		<!--- Remove in DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #_db#
		WHERE #_id# = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn />
	</cffunction>


	<!---  --->
	<!--- PRIVATE FUNCTIONS --->
	<!---  --->


	<!--- Get file values--->
	<cffunction name="get_file_values" access="private" output="true">
		<cfargument name="file_id" type="string" required="true" />
		<cfargument name="file_type" type="string" required="true" />
		<cfargument name="dynpath" type="string" required="true" />
		<cfargument name="urlglobal" type="string" required="true" />
		<cfargument name="urlasset" type="string" required="true" />
		<!--- Local --->
		<cfset var s = structNew()>
		<!--- Set vars --->
		<cfif arguments.file_type EQ "img">
			<cfset var _db = "#session.hostdbprefix#images">
			<cfset var _id = "img_id">
			<cfset var _owner = "img_owner">
			<cfset var _name = "img_filename">
			<cfset var _extension = "img_extension">
			<cfset var _org = "img_filename_org">
			<cfset var _thumb = "thumb_extension">
		<cfelseif arguments.file_type EQ "vid">
			<cfset var _db = "#session.hostdbprefix#videos">
			<cfset var _id = "vid_id">
			<cfset var _owner = "vid_owner">
			<cfset var _name = "vid_filename">
			<cfset var _extension = "vid_extension">
			<cfset var _org = "vid_filename_org">
			<cfset var _thumb = "0">
		<cfelseif arguments.file_type EQ "aud">
			<cfset var _db = "#session.hostdbprefix#audios">
			<cfset var _id = "aud_id">
			<cfset var _owner = "aud_owner">
			<cfset var _name = "aud_name">
			<cfset var _extension = "aud_extension">
			<cfset var _org = "aud_name_org">
			<cfset var _thumb = "0">
		<cfelse>
			<cfset var _db = "#session.hostdbprefix#files">
			<cfset var _id = "file_id">
			<cfset var _owner = "file_owner">
			<cfset var _name = "file_name">
			<cfset var _extension = "file_extension">
			<cfset var _org = "file_name_org">
			<cfset var _thumb = "0">
		</cfif>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="s.qry">
		SELECT #_id# as id, folder_id_r, #_owner# as file_owner, #_name# as file_name, path_to_asset, cloud_url, #_extension# as extension, #_org# as filename_org, #_thumb# as thumb_extension
		FROM #_db#
		WHERE #_id# = <cfqueryparam value="#arguments.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Get assetpath --->
		<cfinvoke component="global.cfc.settings" method="assetpath" returnvariable="assetpath" />
		<!--- Now get thumbnail --->
		<cfsavecontent variable="s.thumbnail"><cfoutput>
			<cfif application.razuna.storage EQ "amazon">
				<cfif s.qry.cloud_url NEQ "">
					<img src="#s.qry.cloud_url#" border="0" style="max-width:400px">
				<cfelse>
					<img src="#arguments.urlglobal#global/host/dam/images/icons/image_missing.png" border="0" style="max-width:400px">
				</cfif>
			<cfelse>
				<cfif arguments.file_type EQ "img">
					<img src="#arguments.urlasset##s.qry.path_to_asset#/thumb_#s.qry.id#.#s.qry.thumb_extension#" border="0" style="max-width:400px">
				<cfelseif arguments.file_type EQ "vid">
					<cfset thethumb = replacenocase(s.qry.filename_org, ".#s.qry.extension#", ".jpg", "all")>
					<img src="#arguments.urlasset##s.qry.path_to_asset#/#thethumb#" border="0" style="max-width:400px">
				<cfelseif arguments.file_type EQ "aud">
					<img src="#arguments.urlglobal#global/host/dam/images/icons/icon_<cfif s.qry.extension EQ "mp3" OR s.qry.extension EQ "wav">#s.qry.extension#<cfelse>aud</cfif>.png" border="0">
				<cfelse>
					<cfset thethumb = replacenocase(s.qry.filename_org, ".#s.qry.extension#", ".jpg", "all")>
					<cfif FileExists("#assetpath#/#session.hostid#/#s.qry.path_to_asset#/#thethumb#") >
						<img src="#arguments.urlasset##s.qry.path_to_asset#/#thethumb#" border="0" style="max-width:400px">
					<cfelse>
						<img src="#arguments.urlglobal#global/host/dam/images/icons/icon_#s.qry.extension#.png" border="0" width="128" height="128" onerror = "this.src='#arguments.urlglobal#global/host/dam/images/icons/icon_txt.png'">
					</cfif>
				</cfif>
			</cfif>
		</cfoutput></cfsavecontent>
		<!--- Return --->
		<cfreturn s />
	</cffunction>

	<!--- Set is_available and is_indexed --->
	<cffunction name="set_values" access="private" output="true">
		<cfargument name="file_id" type="string" required="true" />
		<cfargument name="file_type" type="string" required="true" />
		<cfargument name="is_available" type="string" required="true" />
		<cfargument name="is_indexed" type="string" required="true" />
		<!--- Set vars --->
		<cfif arguments.file_type EQ "img">
			<cfset var _db = "#session.hostdbprefix#images">
			<cfset var _id = "img_id">
			<cfset var _cache = "images">
		<cfelseif arguments.file_type EQ "vid">
			<cfset var _db = "#session.hostdbprefix#videos">
			<cfset var _id = "vid_id">
			<cfset var _cache = "videos">
		<cfelseif arguments.file_type EQ "aud">
			<cfset var _db = "#session.hostdbprefix#audios">
			<cfset var _id = "aud_id">
			<cfset var _cache = "audios">
		<cfelse>
			<cfset var _db = "#session.hostdbprefix#files">
			<cfset var _id = "file_id">
			<cfset var _cache = "files">
		</cfif>
		<!--- Set the is_available to 2 and index so indexing doesn't occur --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #_db#
		SET 
		is_available = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.is_available#">,
		is_indexed = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.is_indexed#">
		WHERE #_id# = <cfqueryparam value="#arguments.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Flush cache --->
		<cfset resetcachetoken(type=_cache)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Set is_available and is_indexed --->
	<cffunction name="set_approval_done" access="private" output="true">
		<cfargument name="file_id" type="string" required="true" />
		<!--- Insert --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#approval_done
		(user_id, approval_date, file_id)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.file_id#">
		)
		</cfquery>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Set is_available and is_indexed --->
	<cffunction name="get_approval_done" access="private" output="true">
		<cfargument name="file_id" type="string" required="true" />
		<cfargument name="file_type" type="string" required="true" />
		<cfargument name="group" type="string" required="true" />
		<cfargument name="dynpath" type="string" required="true" />
		<cfargument name="urlglobal" type="string" required="true" />
		<cfargument name="urlasset" type="string" required="true" />
		<cfargument name="all" type="boolean" required="false" default="true" />
		<!--- Params --->
		<cfset var _all_approved = 0>
		<cfset var qry_approved_users = "">
		<!--- Get approval record --->
		<cfset var _qry_approval = admin_get()>
		<!--- Get users in group --->
		<cfset var _group = "_qry_approval.approval_group_#arguments.group#">
		<cfset var _group_users = evaluate(_group)>
		<!--- Query all users who have approved so far but not the sysadmin --->
		<cfquery datasource="#application.razuna.datasource#" name="qry_approved_users">
		SELECT user_id
		FROM #session.hostdbprefix#approval_done
		WHERE file_id =	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.file_id#">
		AND user_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#_group_users#" list="true">)
		</cfquery>
		<!--- If all users need to approve --->
		<cfif arguments.all>
			<!--- Loop over all records and check if they approved --->
			<cfloop query="qry_approved_users">
				<!--- <cfset console(listFind(_group_users, user_id))> --->
				<cfset _all_approved = listFind(_group_users, user_id)>
			</cfloop>
		<cfelse>
			 <cfset _all_approved = qry_approved_users.recordcount>
		</cfif>
		
		<!--- If this is still false then send out email to users who need to approve further --->
		<cfif ! _all_approved>
			<cfset console("SEND EMAIL !!!!!!")>
			<cfset send_message(qry_users=qry_approved_users, group_users=_group_users, kind='approval', file_id=arguments.file_id, file_type=arguments.file_type, dynpath=arguments.dynpath, urlasset=arguments.urlasset, urlglobal=arguments.urlglobal)>
		</cfif>
			

		<!--- <cfset console(arguments.group)>
		<cfset console(qry_approved_users)>
		<cfset console(_group_users)>
		<cfset console(_all_approved)> --->

		<cfset console("The result for all users having approved is (boolean): #_all_approved#")>

		<!--- Return --->
		<cfreturn _all_approved />
	</cffunction>

	<!--- Send out the email --->
	<cffunction name="send_message" access="private" output="true">
		<cfargument name="qry_users" type="query" required="false" />
		<cfargument name="group_users" type="string" required="true" />
		<cfargument name="kind" type="string" required="true" />
		<cfargument name="reject_message" type="string" required="false" />
		<cfargument name="file_owner" type="string" required="false" default="0" />
		<cfargument name="file_id" type="string" required="true" />
		<cfargument name="file_type" type="string" required="true" />
		<cfargument name="dynpath" type="string" required="true" />
		<cfargument name="urlglobal" type="string" required="true" />
		<cfargument name="urlasset" type="string" required="true" />

		<!--- Subject Prefix --->
		<cfset var _subject_prefix = "[Approval]:">

		<!--- Get current user --->
		<cfset thestruct.user_id = session.theuserid>
		<cfinvoke component="global.cfc.users" method="details" thestruct="#thestruct#" returnvariable="qry_current_user" />

		<!--- Get file owner if not empty --->
		<cfif arguments.file_owner NEQ 0>
			<!--- Get file owner --->
			<cfset thestruct.user_id = arguments.file_owner>
			<cfinvoke component="global.cfc.users" method="details" thestruct="#thestruct#" returnvariable="qry_owner" />
		</cfif>

		<!--- Get record --->
		<cfset var _qry_file = get_file_values(file_id=arguments.file_id, file_type=arguments.file_type, dynpath=arguments.dynpath, urlasset=arguments.urlasset, urlglobal=arguments.urlglobal)>

		<!--- Set the proper URL to get back to Razuna --->
		<cfset var _raz_url = replaceNoCase(arguments.urlglobal, "global/", "", "ONE")>
		<cfif application.razuna.isp>
			<cfset _raz_url = _raz_url & "index.cfm?fa=c.req_approval">
		<cfelse>
			<cfset _raz_url = _raz_url & "raz#session.hostid#/dam/index.cfm?fa=c.req_approval">
		</cfif>
		<!--- Send emails to approval users/groups --->
		<cfloop list="#arguments.group_users#" index="id" delimiters=",">
			<!--- For approval --->
			<cfif arguments.kind EQ "approval">
				<!--- Subject --->
				<cfset var _subject = "Approval needed">
				<!--- Has this user already approved? --->
				<cfquery dbtype="query" name="_found">
				SELECT *
				FROM arguments.qry_users
				WHERE user_id = '#id#'
				</cfquery>
				<!--- if not found send out message --->
				<cfif _found.recordcount EQ 0>
					<cfset console("User has not approved send message !!!!!!!")>
					<!--- Get users name and email --->
					<cfset thestruct.user_id = id>
					<cfinvoke component="global.cfc.users" method="details" thestruct="#thestruct#" returnvariable="qry_user" />
					<!--- Email message --->
					<cfsavecontent variable="_message"><cfoutput>
Dear #qry_user.user_first_name# #qry_user.user_last_name#,

We need an approval from you on the following file (#_qry_file.qry.file_name#):

<p>
	#trim(_qry_file.thumbnail)#
</p>
<p>
	<strong>
		<a href="#_raz_url#">Click here to get to the approval dashboard</a>	
	</strong>
</p>
					</cfoutput></cfsavecontent>
					
				</cfif>
			<!--- For request for approval --->
			<cfelseif arguments.kind EQ "request">
				<cfset console("Send message for request for approval !!!!!!!")>
				<!--- Subject --->
				<cfset var _subject = "New file has been added. Your approval is requested!">
				<!--- Get users name and email --->
				<cfset thestruct.user_id = id>
				<cfinvoke component="global.cfc.users" method="details" thestruct="#thestruct#" returnvariable="qry_user" />
				<!--- Email message --->
				<cfsavecontent variable="_message"><cfoutput>
Dear #qry_user.user_first_name# #qry_user.user_last_name#,

User #qry_owner.user_first_name# #qry_owner.user_last_name# (#qry_owner.user_email#) uploaded new file (#_qry_file.qry.file_name#) which requires your approval.

<p>
	#trim(_qry_file.thumbnail)#
</p>
<p>
	<strong>
		<a href="#_raz_url#">Click here to get to the approval dashboard</a>	
	</strong>
</p>
				</cfoutput></cfsavecontent>
				
			<!--- done --->
			<cfelseif arguments.kind EQ "done">
				<cfset console("File has been released !!!!!!!")>
				<!--- Subject --->
				<cfset var _subject = "File has been fully approved and is now available">
				<!--- Get users name and email --->
				<cfset thestruct.user_id = id>
				<cfinvoke component="global.cfc.users" method="details" thestruct="#thestruct#" returnvariable="qry_user" />
				<!--- Email message --->
				<cfsavecontent variable="_message"><cfoutput>
Dear #qry_user.user_first_name# #qry_user.user_last_name#,

This is to let you know that the file (#_qry_file.qry.file_name#) has been fully approved and is now available in the system.

<p>
	#trim(_qry_file.thumbnail)#
</p>
				</cfoutput></cfsavecontent>
				
			<!--- reject --->
			<cfelseif arguments.kind EQ "reject">
				<cfset console("File has been rejected !!!!!!!")>
				<!--- Subject --->
				<cfset var _subject = "File has been rejected">
				<!--- Get users name and email --->
				<cfset thestruct.user_id = id>
				<cfinvoke component="global.cfc.users" method="details" thestruct="#thestruct#" returnvariable="qry_user" />
				<!--- Email message --->
				<cfsavecontent variable="_message"><cfoutput>
Dear #qry_user.user_first_name# #qry_user.user_last_name#,

The file (#_qry_file.qry.file_name#) has been rejected by the user (#qry_current_user.user_first_name# #qry_current_user.user_last_name#) with the following comment:

#arguments.reject_message#

<p>
	#trim(_qry_file.thumbnail)#
</p>
<p>
	<em>The user who uploaded the file has been informed and the file has been removed from the system</em>
</p>
				</cfoutput></cfsavecontent>
				
			</cfif>

			<!--- All set call global send email function (as there could be no user for the "approval" we check of a record has been found) --->
			<cfif qry_user.recordcount NEQ 0>
				<cfinvoke component="global.cfc.email" method="send_email" to="#qry_user.user_email#" subject="#_subject_prefix# #_subject#" themessage="#_message#" />
			</cfif>

		</cfloop>

		<!--- Send email to file owner --->

		<!--- REJECT --->
		<cfif arguments.kind EQ "reject">
			<cfset console("Send message to user that file has been rejected !!!!!!!")>
			<!--- Subject --->
			<cfset var _subject = "The file you uploaded has been rejected">
			<!--- Email message --->
			<cfsavecontent variable="_message"><cfoutput>
Dear #qry_owner.user_first_name# #qry_owner.user_last_name#,

The file (#_qry_file.qry.file_name#) has been rejected by the user (#qry_current_user.user_first_name# #qry_current_user.user_last_name#) with the following comment:

#arguments.reject_message#

<p>
	#trim(_qry_file.thumbnail)#
</p>
<p>
	<em>The file has been removed from our system</em>
</p>
			</cfoutput></cfsavecontent>
			<!--- All set call global send email function --->
			<cfinvoke component="global.cfc.email" method="send_email" to="#qry_owner.user_email#" subject="#_subject_prefix# #_subject#" themessage="#_message#" />
		<!--- DONE --->
		<cfelseif arguments.kind EQ "done">
			<cfset console("Send message to user that file has been accepted !!!!!!!")>
			<!--- Subject --->
			<cfset var _subject = "The file you uploaded has been approved and is now available">
			<!--- Email message --->
			<cfsavecontent variable="_message"><cfoutput>
Dear #qry_owner.user_first_name# #qry_owner.user_last_name#,

The file (#_qry_file.qry.file_name#) has been approved and is now available in our system.

<p>
	#trim(_qry_file.thumbnail)#
</p>
			</cfoutput></cfsavecontent>
			<!--- All set call global send email function --->
			<cfinvoke component="global.cfc.email" method="send_email" to="#qry_owner.user_email#" subject="#_subject_prefix# #_subject#" themessage="#_message#" />
		</cfif>
		

		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>
