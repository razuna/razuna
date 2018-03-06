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
<cftry>

	<cfset consoleoutput(true, true)>
	<cfset console("#now()# --- Executing cron job expiring assets")>

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

	<!--- Get all the hosts --->
	<cfquery datasource="#_db#" name="_qry_hosts">
	SELECT host_shard_group, host_id
	FROM hosts
	GROUP BY host_id, host_shard_group
	</cfquery>

	<!--- Create lock files --->
	<cfinvoke component="global.cfc.global" method="_lockFile" qry="#_qry_hosts#" type="expired_assets" returnvariable="_hosts" />

	<!--- START --->

	<cfloop query="_hosts">
		<!--- Check label --->
		<cfset _checkLabel(datasource=_db, host_id=host_id)>
		<!--- Get assets that have expired --->
		<cfset getexpired_assets = _getExpiredAssets(datasource=_db, host_id=host_id)>
		<!--- Get users that are in groups which have access to the expired assets and notify them about the expiry --->
		<cfset getusers2notify = _getUsersToNotify(datasource=_db, host_id=host_id)>
		<!--- Extract user information from query --->
		<cfset getuserinfo = "">
		<cfquery dbtype="query" name="getuserinfo">
			SELECT user_email, user_id FROM getusers2notify GROUP BY user_id,user_email
		</cfquery>
		<!--- Set expired label for assets that have expired and update indexing status to re-index --->
		<cfloop query="getexpired_assets">
			<cfif getexpired_assets.label_id NEQ ''>
				<!--- Insert label for asset expiry --->
				<cfquery datasource="#_db#">
				INSERT INTO ct_labels (ct_label_id,ct_id_r,ct_type,rec_uuid)
				VALUES  (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#label_id#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#id#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#type#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
					)
				</cfquery>
				<!--- Update indexing flag --->
				<cfif type EQ 'img'>
					<cfset tbl = 'images'>
					<cfset col = 'img_id'>
				<cfelseif type EQ 'aud'>
					<cfset tbl = 'audios'>
					<cfset col = 'aud_id'>
				<cfelseif type EQ 'vid'>
					<cfset tbl = 'videos'>
					<cfset col = 'vid_id'>
				<cfelseif type EQ 'doc'>
					<cfset tbl = 'files'>
					<cfset col = 'file_id'>
				</cfif>
				<cfquery datasource="#_db#">
				UPDATE raz1_#tbl# SET is_indexed = '0'
				WHERE #col# =<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#id#">
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Get reset assets --->
		<cfset getreset_assets = _resetAssets(datasource=_db, host_id=host_id)>
		<!--- Reset labels cache if labels have been modified--->
		<cfif getexpired_assets.recordcount NEQ 0 OR getreset_assets.recordcount NEQ 0>
			<cfinvoke component="global.cfc.global" method="resetCacheExternal" type="labels" host_id="#host_id#" dataSource="#_db#">
		</cfif>
		<!--- Send email --->
		<cfset _sendEmail(datasource=_db, host_id=host_id, getuserinfo=getuserinfo, getusers2notify=getusers2notify, dbprefix=host_shard_group)>
	</cfloop>


	<!--- Check if expiry label is not present for a host --->
	<cffunction name="_checkLabel" access="private" returntype="void">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="host_id" type="numeric" required="yes">

		<cfset var getmissing_labels = "">
		<cfquery datasource="#arguments.datasource#" name="getmissing_labels">
		SELECT h.HOST_ID
		FROM raz1_labels l RIGHT JOIN hosts h ON l.label_text='Asset has expired' AND l.host_id=#arguments.host_id# AND l.label_id_r = '0'
		WHERE label_id IS NULL
		</cfquery>
		<cfloop query="getmissing_labels">
			<!--- Insert label for asset expiry if missing --->
			<cfquery datasource="#arguments.datasource#">
			INSERT INTO raz1_labels (label_id,label_text, label_date,user_id,host_id,label_id_r,label_path)
			VALUES  (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="Asset has expired">,
					<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#getmissing_labels.host_id#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="0">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="Asset has expired">
					)
			</cfquery>
		</cfloop>

	</cffunction>

	<!--- Get assets that have expired --->
	<cffunction name="_getExpiredAssets" access="private" returntype="query">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="host_id" type="numeric" required="yes">

		<cfset var getexpired_assets = "">

		<!--- <cfquery datasource="#arguments.datasource#" name="getexpired_assets">
		SELECT img_id id, host_id, 'img' type,
		(SELECT MAX(label_id) FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_images
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=i.img_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id#  AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		UNION ALL
		SELECT aud_id id, host_id, 'aud' type,
		(SELECT MAX(label_id)  FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_audios
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=a.aud_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		UNION ALL
		SELECT vid_id id, host_id, 'vid' type,
		(SELECT MAX(label_id) FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_videos
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=v.vid_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		UNION ALL
		SELECT file_id id, host_id, 'doc' type,
		(SELECT MAX(label_id)  FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_files f
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=f.file_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired'AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery> --->

		<cfset var getexpired_assets = "">
		<cfset var _img = "">
		<cfset var _vid = "">
		<cfset var _doc = "">
		<cfset var _aud = "">
		<cfquery datasource="#arguments.datasource#" name="_img">
		SELECT img_id id, host_id, 'img' type,
		(SELECT MAX(label_id) FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_images i
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=i.img_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id#  AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>
		<cfquery datasource="#arguments.datasource#" name="_aud">
		SELECT aud_id id, host_id, 'aud' type,
		(SELECT MAX(label_id)  FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_audios a
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=a.aud_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>
		<cfquery datasource="#arguments.datasource#" name="_vid">
		SELECT vid_id id, host_id, 'vid' type,
		(SELECT MAX(label_id) FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_videos v
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=v.vid_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>
		<cfquery datasource="#arguments.datasource#" name="_doc">
		SELECT file_id id, host_id, 'doc' type,
		(SELECT MAX(label_id)  FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0') as label_id
		FROM raz1_files f
		WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=f.file_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired'AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>

		<cfquery dbtype="query" name="getexpired_assets">
		SELECT * FROM _img
		UNION
		SELECT * FROM _vid
		UNION
		SELECT * FROM _doc
		UNION
		SELECT * FROM _aud
		</cfquery>

		<cfreturn getexpired_assets />

	</cffunction>

	<!--- Get users that are in groups which have access to the expired assets and notify them about the expiry --->
	<cffunction name="_getUsersToNotify" access="private" returntype="query">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="host_id" type="numeric" required="yes">

		<cfset var getusers2notify = "">
		<cfquery datasource="#arguments.datasource#" name="getusers2notify">
		SELECT i.img_id id, i.img_filename name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'img' type, path_to_asset, thumb_extension thumb, cloud_url cloud_thumb
		FROM raz1_images i, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
		WHERE i.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		AND i.folder_id_r = f.folder_id
		AND f.folder_id = fg.folder_id_r
		AND cu.ct_g_u_grp_id = fg.grp_id_r
		AND cu.ct_g_u_user_id = u.user_id
		AND fg.grp_id_r <> <cfqueryparam CFSQLType="cf_sql_varchar" value="0">
		AND fg.grp_permission in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
		AND i.expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=i.img_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND i.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		UNION ALL
		SELECT a.aud_id id, a.aud_name name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'aud' type, path_to_asset, '' thumb, '' cloud_thumb
		FROM raz1_audios a, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
		WHERE a.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		AND a.folder_id_r = f.folder_id
		AND f.folder_id = fg.folder_id_r
		AND cu.ct_g_u_grp_id = fg.grp_id_r
		AND cu.ct_g_u_user_id = u.user_id
		AND fg.grp_id_r <> <cfqueryparam CFSQLType="cf_sql_varchar" value="0">
		AND fg.grp_permission in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
		AND a.expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=a.aud_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND a.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		UNION ALL
		SELECT v.vid_id id, v.vid_filename name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'vid' type, path_to_asset, vid_name_image thumb, cloud_url cloud_thumb
		FROM raz1_videos v, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
		WHERE v.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		AND v.folder_id_r = f.folder_id
		AND f.folder_id = fg.folder_id_r
		AND cu.ct_g_u_grp_id = fg.grp_id_r
		AND cu.ct_g_u_user_id = u.user_id
		AND fg.grp_id_r <> <cfqueryparam CFSQLType="cf_sql_varchar" value="0">
		AND fg.grp_permission in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
		AND v.expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=v.vid_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND v.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		UNION ALL
		SELECT fi.file_id id, fi.file_name name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'doc' type, path_to_asset, '' thumb, '' cloud_thumb
		FROM raz1_files fi, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
		WHERE fi.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		AND fi.folder_id_r = f.folder_id
		AND f.folder_id = fg.folder_id_r
		AND cu.ct_g_u_grp_id = fg.grp_id_r
		AND cu.ct_g_u_user_id = u.user_id
		AND fg.grp_id_r <> <cfqueryparam CFSQLType="cf_sql_varchar" value="0">
		AND fg.grp_permission in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
		AND fi.expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">
		AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=fi.file_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=#arguments.host_id# AND label_id_r = '0'))
		AND fi.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>

		<cfreturn getusers2notify />
	</cffunction>

	<!--- Get assets that were expired but now have been reset --->
	<!--- Before we send out notification emails lets expire the assets first --->
	<cffunction name="_resetAssets" access="private" returntype="query">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="host_id" type="numeric" required="yes">

		<cfset var getreset_assets = "">
		<cfset var _img = "">
		<cfset var _vid = "">
		<cfset var _doc = "">
		<cfset var _aud = "">
		<cfquery datasource="#arguments.datasource#" name="_img">
		SELECT i.img_id id, rec_uuid
		FROM ct_labels c, raz1_images i
		WHERE i.img_id=c.ct_id_r
		AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=i.host_id AND label_id_r = '0')
		AND (i.expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
		AND i.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>
		<cfquery datasource="#arguments.datasource#" name="_aud">
		SELECT a.aud_id id, rec_uuid
		FROM ct_labels c, raz1_audios a
		WHERE a.aud_id=c.ct_id_r
		AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=a.host_id AND label_id_r = '0')
		AND (a.expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
		AND a.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>
		<cfquery datasource="#arguments.datasource#" name="_vid">
		SELECT v.vid_id id, rec_uuid
		FROM ct_labels c, raz1_videos v
		WHERE v.vid_id=c.ct_id_r
		AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=v.host_id AND label_id_r = '0')
		AND (v.expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
		AND v.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>
		<cfquery datasource="#arguments.datasource#" name="_doc">
		SELECT f.file_id id, rec_uuid
		FROM ct_labels c, raz1_files f
		WHERE f.file_id=c.ct_id_r
		AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=f.host_id AND label_id_r = '0')
		AND (f.expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
		AND f.host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#arguments.host_id#">
		</cfquery>
		<cfquery dbtype="query" name="getreset_assets">
		SELECT * FROM _img
		UNION
		SELECT * FROM _vid
		UNION
		SELECT * FROM _doc
		UNION
		SELECT * FROM _aud
		</cfquery>
		<cfset var resetlist = valuelist(getreset_assets.rec_uuid)>
		<cfset var assetlist = valuelist(getreset_assets.id)>
		<cfif resetlist neq ''>
			<!--- Remove expired label from assets  that have been reset --->
			<cfquery datasource="#_db#">
				DELETE FROM ct_labels WHERE rec_uuid IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#resetlist#" list="true">)
			</cfquery>
			<!--- Update indexing statuses --->
			<cfquery datasource="#_db#">
				UPDATE raz1_images SET is_indexed = '0' WHERE img_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
			</cfquery>
			<cfquery datasource="#_db#">
				UPDATE raz1_audios SET is_indexed = '0' WHERE aud_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
			</cfquery>
			<cfquery datasource="#_db#">
				UPDATE raz1_videos SET is_indexed = '0' WHERE vid_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
			</cfquery>
			<cfquery datasource="#_db#">
				UPDATE raz1_files SET is_indexed = '0' WHERE file_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
			</cfquery>
		</cfif>

		<!--- <cfset console(getreset_assets)> --->
		<cfreturn getreset_assets />

	</cffunction>

	<!--- Sedn email --->
	<cffunction name="_sendEmail" access="private" returntype="void">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="dbprefix" type="string" required="yes">
		<cfargument name="host_id" type="numeric" required="yes">
		<cfargument name="getuserinfo" type="query" required="yes">
		<cfargument name="getusers2notify" type="query" required="yes">

		<cfset var data= "">
		<cfset var datacols= "">
		<cfset var fields= "">
		<cfset var msgbody = "">
		<cfset var getusers2email = "">

		<!--- Get metafields --->
		<cfinvoke component="global.cfc.settings" method="get_notifications" returnvariable="fields" datasource="#arguments.datasource#" host_id="#arguments.host_id#" dbprefix="#arguments.dbprefix#">
		<!--- Get columns --->
		<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid= "#getusers2notify.id#" metafields="#fields.set2_asset_expiry_meta#" returnvariable="datacols" datasource="#arguments.datasource#" host_id="#arguments.host_id#" dbprefix="#arguments.dbprefix#">
		<!--- Send out notification email about expiry to users in groups that have access to the expired assets--->
		<!--- Get Email subject --->
		<cfif fields.set2_asset_expiry_email_sub NEQ "">
			<cfset email_subject = "#fields.set2_asset_expiry_email_sub#">
		<cfelse>
			<cfinvoke component="global.cfc.defaults" method="trans" transid="expiry_email_subject" thelang="English" returnvariable="email_subject">
		</cfif>
		<!--- Get Email Introduction--->
		<cfif len(fields.set2_asset_expiry_email_body) GT 10>
			<cfset email_intro = "#fields.set2_asset_expiry_email_body#">
		<cfelse>
			<cfinvoke component="global.cfc.defaults" method="trans" transid="expiry_email_content" thelang="English" returnvariable="email_intro">
		</cfif>
		<cfloop query ="getuserinfo">
			<cfquery dbtype="query" name="getusers2email">
			SELECT * FROM getusers2notify WHERE user_email =<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#getuserinfo.user_email#">
			</cfquery>
			<cfoutput>
			 <cfsavecontent variable="msgbody">
					#email_intro#
					<table border="1" cellpadding="4" cellspacing="0">
					<tr>
						<th nowrap="true">Asset_ID</th>
						<th nowrap="true">Asset_Name</th>
						<th nowrap="true">Thumb</th>
						<th nowrap="true">Folder_ID</th>
						<th nowrap="true">Folder_Name</th>
						<cfloop list="#datacols.columnlist#" index="col">
							<th nowrap="true">#col#</th>
						</cfloop>
					</tr>
				<cfloop query="getusers2email">
					<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid= "#getusers2email.id#" metafields="#fields.set2_asset_expiry_meta#" returnvariable="data" datasource="#arguments.datasource#" host_id="#arguments.host_id#" dbprefix="#arguments.dbprefix#">
					<tr>
						<td nowrap="true">#getusers2email.id#</td>
						<td nowrap="true">#getusers2email.name#</td>
						<td>
						<cfif application.razuna.storage EQ "local">
							<cfif path_to_asset NEQ "">
								<cfswitch expression="#getusers2email.type#">
									<cfcase value="img">
										<img src= "#_config.conf_url_assets#/assets/#arguments.host_id#/#path_to_asset#/thumb_#getusers2email.id#.#thumb#" height="50" onerror = "this.src=''">
									</cfcase>
									<cfcase value="vid">
										<img src="//#_config.conf_url_assets#/assets/#arguments.host_id#/#path_to_asset#/#thumb#"  height="50" onerror = "this.src=''">
									</cfcase>
								</cfswitch>
							</cfif>
						<cfelse>
							<cfif cloud_thumb NEQ "">
								<cfswitch expression="#getusers2email.type#">
									<cfcase value="img">
										<img src="#cloud_thumb#"  height="50" onerror = "this.src=''">
									</cfcase>
									<cfcase value="vid">
										<img src="#cloud_thumb#"  height="50" onerror = "this.src=''">
									</cfcase>
								</cfswitch>
							</cfif>
						</cfif>
						</td>
						<td nowrap="true">#getusers2email.folder_id#</td>
						<td nowrap="true">#getusers2email.folder_name#</td>
						<cfloop list="#datacols.columnlist#" index="col">
							<td>#data["#col#"][1]#</td>
						</cfloop>
					</tr>
				</cfloop>
				</table>
			</cfsavecontent>
			</cfoutput>
			<!--- Send the email --->
			<cfinvoke component="global.cfc.email" method="send_email" to="#getuserinfo.user_email#" subject="#email_subject#" themessage="#msgbody#" userid="#getuserinfo.user_id#" dsn="#arguments.datasource#" hostid="#arguments.host_id#" hostdbprefix="#arguments.dbprefix#" />
		</cfloop>

	</cffunction>

	<!--- END --->

	<!--- Remove lock --->
	<cfinvoke component="global.cfc.global" method="_removeLockFile" qry_remove_lock="#_qry_hosts#" type="expired_assets"/>

	<cfset console("#now()# --- Finished cron job expiring assets")>

	<cfcatch type="any">
		<cfset console("#now()# ---------------------- Error expiring assets cron job")>
		<cfset console(cfcatch)>
	</cfcatch>
</cftry>
