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
<cfcomponent output="false">
	
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
		<!--- Get the approval values --->
		<cfset var _qry_approval = admin_get()>
		<!--- Get all users of groups --->
		<cfinvoke component="global.cfc.groups_users" method="getUsersOfGroups" grp_id="#_qry_approval.approval_group_1#" returnvariable="qry_group_users" />
		<!--- Get users --->
		<cfinvoke component="global.cfc.users" method="getAllUsersFromList" user_ids="#_qry_approval.approval_group_1#" returnvariable="qry_users" />
		<!--- Combine the two queries --->
		<cfquery dbtype="query" name="_qry_users">
		SELECT * FROM qry_group_users
		UNION
		SELECT * FROM qry_users
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
		SELECT r.img_id as id, r.img_filename as name, r.img_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, r.thumb_extension, 'img' as kind, u.user_first_name, u.user_last_name, f.folder_name
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#images r LEFT JOIN users u ON u.user_id = r.img_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		UNION ALL
		SELECT r.vid_id as id, r.vid_filename as name, r.vid_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, '' as thumb_extension, 'vid' as kind, u.user_first_name, u.user_last_name, f.folder_name
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#videos r LEFT JOIN users u ON u.user_id = r.vid_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		UNION ALL
		SELECT r.aud_id as id, r.aud_name as name, r.aud_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, '' as thumb_extension, 'aud' as kind, u.user_first_name, u.user_last_name, f.folder_name
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#audios r LEFT JOIN users u ON u.user_id = r.aud_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		UNION ALL
		SELECT r.file_id as id, r.file_name as name, r.file_create_time as date_create, r.cloud_url, r.cloud_url_org, r.path_to_asset, r.hashtag, r.folder_id_r, '' as thumb_extension, 'doc' as kind, u.user_first_name, u.user_last_name, f.folder_name
		FROM #session.hostdbprefix#folders f, #session.hostdbprefix#files r LEFT JOIN users u ON u.user_id = r.file_owner
		WHERE r.is_available = <cfqueryparam cfsqltype="cf_sql_varchar" value="2">
		AND f.folder_id = r.folder_id_r
		ORDER BY date_create DESC
		</cfquery>
		<!--- Get the approval done records --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.done">
		SELECT user_id, approval_date, file_id
		FROM #session.hostdbprefix#approval_done
		WHERE file_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valueList(qry.files.id)#" list="true">)
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Execute Approval process --->
	<cffunction name="approval_execute" access="public" output="true">
		<cfargument name="file_id" type="string" required="true" />
		<cfargument name="file_type" type="string" required="true" />

		<cfset consoleoutput(true)>

		<!--- Set is_available and is_indexed --->
		<cfset set_values(file_id=arguments.file_id, file_type=arguments.file_type, is_available='2', is_indexed='1')>
		
		<!--- Get the approval values --->
		<cfset var _qry_approval = admin_get()>
		<!--- Get all users of this approval process (we want the query back) --->
		<cfset var _qry_users = get_approval_users().qry>
		<!--- Send out email to approval group --->





		
		<cfset console(_qry_users)>
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

		<!--- Check if other users have to approve this too --->
		<cfif _qry_approval.approval_group_1_all>
			<!--- If other users have to approve, we have to record the current approval in db --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#approval_done
			(user_id, approval_date, file_id)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.theuserid#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.file_id#">
			)
			</cfquery>
			<!--- Check who has approved so far. If all users have approved we can check if it needs approval from group 2 --->

			<!--- If it needs further approval send out an email to all remaining users that this user has approved --->
			<cfset consoleoutput(true)>
			<cfset console('EVERYONE HAS TO APPROVE!!!!!!!!!!')>

			<!--- If all users have approved, we set the var to true --->
			<cfset var _release_file = false>

		</cfif>

		<!--- Check if there are any records in approval group 2 --->
		<cfif _release_file AND _qry_approval.approval_group_2 NEQ ''>
			
		</cfif>

		<!--- If approved make file available --->
		<cfif _release_file>
			<!--- Set is_available and is_indexed --->
			<cfset set_values(file_id=arguments.thestruct.file_id, file_type=arguments.thestruct.file_type, is_available='1', is_indexed='0')>
		</cfif>

		<!--- Return --->
		<cfreturn />
	</cffunction>


	<!--- Set is_available and is_indexed --->
	<cffunction name="set_values" access="public" output="true">
		<cfargument name="file_id" type="string" required="true" />
		<cfargument name="file_type" type="string" required="true" />
		<cfargument name="is_available" type="string" required="true" />
		<cfargument name="is_indexed" type="string" required="true" />
		<!--- Set vars --->
		<cfif arguments.file_type EQ "img">
			<cfset var _db = "#session.hostdbprefix#images">
			<cfset var _id = "img_id">

		<cfelseif arguments.type_type EQ "vid">
			<cfset var _db = "#session.hostdbprefix#videos">
			<cfset var _id = "vid_id">

		<cfelseif arguments.type_type EQ "aud">
			<cfset var _db = "#session.hostdbprefix#audios">
			<cfset var _id = "aud_id">

		<cfelse>
			<cfset var _db = "#session.hostdbprefix#files">
			<cfset var _id = "file_id">

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

		<cfreturn >
	</cffunction>



</cfcomponent>
