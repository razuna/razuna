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

	<cffunction name="init" returntype="api" access="public" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="getStruct" access="public" returntype="struct">
		<cfset var _s = structNew()>
		<cfset _s.razuna.application = application.razuna>
		<cfset _s.razuna.session = session>
		<cfreturn _s>
	</cffunction>

	<!--- Add action --->
	<cffunction name="add_action" access="public" returntype="void">
		<cfargument name="pid" type="string" required="true" />
		<cfargument name="action" type="string" required="true" />
		<cfargument name="comp" type="string" required="true" />
		<cfargument name="func" type="string" required="true" />
		<cfargument name="args" type="string" required="false" default="" />
		<cfargument name="thestruct" type="struct">
		<!--- Query any same action first --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qryp">
		DELETE FROM plugins_actions
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		AND action = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">
		AND comp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.comp#">
		AND func = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.func#">
		AND args = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.args#">
		</cfquery>
		<!--- Add this action to DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		INSERT INTO plugins_actions
		(action, comp, func, args, p_id, host_id)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.comp#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.func#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.args#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pid#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		)
		</cfquery>
		<!--- Reset cache --->
		<cfset resetcachetoken(type="settings", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
	</cffunction>

	<!--- Del action --->
	<cffunction name="del_action" access="public" returntype="void">
		<cfargument name="pid" required="true" />
		<cfargument name="action" type="string" required="false" default="" />
		<cfargument name="comp" type="string" required="false" default="" />
		<cfargument name="func" type="string" required="false" default="" />
		<cfargument name="args" type="string" required="false" default="" />
		<cfargument name="thestruct" type="struct" required="true">
		<!--- DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM plugins_actions
		WHERE p_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		<cfif arguments.action NEQ "">
			AND action = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.action#">
		</cfif>
		<cfif arguments.comp NEQ "">
			AND comp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.comp#">
		</cfif>
		<cfif arguments.func NEQ "">
			AND func = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.func#">
		</cfif>
		<cfif arguments.args NEQ "">
			AND args LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.args#%">
		</cfif>
		</cfquery>
		<!--- Reset cache --->
		<cfset resetcachetoken(type="settings", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
	</cffunction>

	<!--- Get datasource --->
	<cffunction name="getDatasource" access="public" returntype="String">
		<cfreturn application.razuna.datasource />
	</cffunction>

	<!--- Get database --->
	<cffunction name="getDatabase" access="public" returntype="String">
		<cfreturn application.razuna.thedatabase />
	</cffunction>

	<!--- Get schema --->
	<cffunction name="getSchema" access="public" returntype="String">
		<cfreturn application.razuna.schema />
	</cffunction>

	<!--- Get storage --->
	<cffunction name="getStorage" access="public" returntype="String">
		<cfreturn application.razuna.storage />
	</cffunction>

	<!--- Get Sessions --->
	<cffunction name="getHostID" access="public" returntype="String">
		<cfreturn session.hostid />
	</cffunction>

	<!--- Get Host --->
	<cffunction name="getHost" access="public" returntype="query">
		<cfargument name="id" type="numeric" required="true" />
		<!--- Param --->
		<cfset var s = structNew()>
		<cfset s.host_id = arguments.id>
		<!--- Call host details --->
		<cfinvoke component="hosts" method="getdetail" thestruct="#s#" returnvariable="qryhost" />
		<cfreturn qryhost />
	</cffunction>

	<!--- Get Sessions --->
	<cffunction name="getUserID" access="public" returntype="String">
		<cfreturn session.theuserid />
	</cffunction>

	<!--- Get HostDBPrefix --->
	<cffunction name="getHostPrefix" access="public" returntype="String">
		<cfreturn session.hostdbprefix />
	</cffunction>

	<!--- Get Groups --->
	<cffunction name="getGroups" access="public" returntype="query">
		<cfset var _s = getStruct()>
		<cfinvoke component="groups" method="getall" thestruct="#_s#" returnvariable="qrygrp" />
		<cfreturn qrygrp />
	</cffunction>

	<!--- Get Users --->
	<cffunction name="getUsers" access="public" returntype="query">
		<cfset var _s = getStruct()>
		<cfinvoke component="users" method="getall" thestruct="#_s#" returnvariable="qryusers" />
		<cfreturn qryusers />
	</cffunction>

	<!--- Get Users --->
	<cffunction name="getUser" access="public" returntype="query">
		<cfargument name="user_id" type="string" required="true" />
		<cfinvoke component="users" method="details" thestruct="#arguments#" returnvariable="qryuser" />
		<cfreturn qryuser />
	</cffunction>

	<!--- Get Users of Groups --->
	<cffunction name="getUsersOfGroups" access="public" returntype="query">
		<cfargument name="thewho" type="string" required="true" />
		<cfinvoke component="groups_users" method="getUsersOfGroups" grp_id="#arguments.thewho#" returnvariable="qrygrp" />
		<cfreturn qrygrp />
	</cffunction>

	<!--- Get UploadTemplates --->
	<cffunction name="getUploadTemplates" access="public" returntype="query">
		<cfset var _s = getStruct()>
		<cfinvoke component="global" method="upl_templates" theactive="true" thestruct="#_s#" returnvariable="qryuptemp" />
		<cfreturn qryuptemp />
	</cffunction>

	<!--- Get Labels --->
	<cffunction name="getLabels" access="public" returntype="query">
		<cfset var _s = getStruct()>
		<cfinvoke component="labels" method="labels_dropdown" thestruct="#_s#" returnvariable="qrylabels" />
		<cfreturn qrylabels />
	</cffunction>

	<!--- Get CustomFields --->
	<cffunction name="getCustomFields" access="public" returntype="query">
		<cfset var _s = getStruct()>
		<cfinvoke component="custom_fields" method="get" fieldsenabled="true" thestruct="#_s#" returnvariable="qrycf" />
		<cfreturn qrycf />
	</cffunction>

	<!--- Get CustomFieldsValues --->
	<cffunction name="getCustomFieldsValues" access="public" returntype="query">
		<cfargument name="fileid" type="string" required="true" />
		<!--- Param --->
		<cfset var s = structNew()>
		<cfset s.file_id = arguments.fileid>
		<!--- Call method --->
		<cfinvoke component="custom_fields" method="gettextvalues" thestruct="#s#" returnvariable="qrycfv" />
		<cfreturn qrycfv />
	</cffunction>

	<!--- Set CustomFields --->
	<cffunction name="setCustomField" access="public" returntype="void">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfinvoke component="custom_fields" method="savevalues" thestruct="#arguments.thestruct#" />
		<cfreturn />
	</cffunction>

	<!--- Get PluginID --->
	<cffunction name="getMyID" access="public" returntype="string">
		<cfargument name="pluginname" type="string" required="true" />
		<!--- Param --->
		<cfset var plugID = "">
		<!--- Doing a error exception since this is also called within the admin (we don't need the id anyhow) --->
		<cftry>
			<!--- Set path --->
			<cfif listlast(expandpath("."),FileSeparator()) EQ "admin">
				<cfset var thepath = expandpath("../") & "global">
			<cfelse>
				<cfset var thepath = expandpath("../../") & "global">
			</cfif>
			<!--- Get id from config file --->
			<cfset var plugID = getProfileString("#thepath#/plugins/#arguments.pluginname#/config/config.ini", "information", "id")>
			<cfcatch type="any">
			</cfcatch>
		</cftry>
		<cfreturn plugID />
	</cffunction>

	<!--- Send eMail --->
	<cffunction name="sendEmail" access="public" returntype="void">
		<cfargument name="to" default="" required="false" type="string">
		<cfargument name="cc" default="" required="false" type="string">
		<cfargument name="bcc" default="" required="false" type="string">
		<cfargument name="from" default="" required="false" type="string">
		<cfargument name="subject" default="" required="false" type="string">
		<cfargument name="attach" default="" required="false" type="string">
		<cfargument name="message" default="" required="false" type="string">
		<cfargument name="thepath" default="" required="false" type="string">
		<cfargument name="sendaszip" default="F" required="false" type="string">
		<cfargument name="userid" default="" required="false" type="string">
		<!--- Call internal function --->
		<cfinvoke component="email" method="send_email">
			<cfinvokeargument name="to" value="#arguments.to#">
			<cfinvokeargument name="cc" value="#arguments.cc#">
			<cfinvokeargument name="bcc" value="#arguments.bcc#">
			<cfinvokeargument name="from" value="#arguments.from#">
			<cfinvokeargument name="subject" value="#arguments.subject#">
			<cfinvokeargument name="attach" value="#arguments.attach#">
			<cfinvokeargument name="themessage" value="#arguments.message#">
			<cfinvokeargument name="thepath" value="#arguments.thepath#">
			<cfinvokeargument name="sendaszip" value="#arguments.sendaszip#">
			<cfinvokeargument name="userid" value="#arguments.userid#">
		</cfinvoke>
	</cffunction>

	<!--- Get Name of Folder --->
	<cffunction name="getFolderName" access="public" returntype="string">
		<cfargument name="folderid" type="string" required="true" />
		<cfset var _s = getStruct()>
		<cfinvoke component="folders" method="getfoldername" folder_id="#arguments.folderid#" thestruct="#s#" returnvariable="fn" />
		<cfreturn fn />
	</cffunction>

	<!--- Add labels --->
	<cffunction name="addLabels" access="public" returntype="void">
		<cfargument name="labelids" type="string" required="true" />
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfset var _s = getStruct()>
		<!--- Params --->
		<cfset _s.labels = arguments.labelids>
		<cfset _s.thetype = arguments.type>
		<cfset _s.fileid = arguments.fileid>
		<!--- Call function --->
		<cfinvoke component="labels" method="label_add_all" thestruct="#_s#" />
	</cffunction>

	<!--- Execute upload Template --->
	<cffunction name="execUploadTemplate" access="public" returntype="void">
		<cfargument name="utid" type="string" required="true" />
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfargument name="args" type="struct" required="true" />
		<cfset var _s = getStruct()>
		<!--- Params --->
		<cfset _s.upl_template = arguments.utid>
		<cfset _s.file_id = arguments.fileid>
		<cfset _s.upltemptype = arguments.type>
		<cfset StructAppend(_s,arguments.args,"false")>
		<!--- Call function --->
		<cfinvoke component="assets" method="process_upl_template" thestruct="#_s#">
	</cffunction>

	<!--- Move File --->
	<cffunction name="moveFile" access="public" returntype="void">
		<cfargument name="folderid" type="string" required="true" />
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfset var _s = getStruct()>
		<!--- Params --->
		<cfset _s.folder_id = arguments.folderid>
		<!--- Images --->
		<cfif arguments.type EQ "img">
			<!--- Params --->
			<cfset _s.img_id = arguments.fileid>
			<!--- Call function --->
			<cfinvoke component="images" method="move" thestruct="#_s#">
		<!--- Videos --->
		<cfelseif arguments.type EQ "vid">
			<!--- Params --->
			<cfset _s.vid_id = arguments.fileid>
			<!--- Call function --->
			<cfinvoke component="videos" method="move" thestruct="#_s#">
		<!--- Audios --->
		<cfelseif arguments.type EQ "aud">
			<!--- Params --->
			<cfset _s.aud_id = arguments.fileid>
			<!--- Call function --->
			<cfinvoke component="audios" method="move" thestruct="#_s#">
		<!--- Docs --->
		<cfelseif arguments.type EQ "doc">
			<!--- Params --->
			<cfset _s.doc_id = arguments.fileid>
			<!--- Call function --->
			<cfinvoke component="files" method="move" thestruct="#_s#">
		</cfif>
	</cffunction>

	<!--- Set Metadata --->
	<cffunction name="setMetadata" access="public" returntype="void">
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfargument name="metadata" type="string" required="true" />
		<cfset var _s = getStruct()>
		<!--- Call function --->
		<cfinvoke component="xmp" method="setMetadata" fileid="#arguments.fileid#" type="#arguments.type#" metadata="#arguments.metadata#" thestruct="#_s#">
	</cffunction>

	<!--- Set Custom Metadata --->
	<cffunction name="setMetadataCustom" access="public" returntype="void">
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfargument name="metadata" type="string" required="true" />
		<cfset var _s = getStruct()>
		<!--- Call function --->
		<cfinvoke component="xmp" method="setMetadataCustom" fileid="#arguments.fileid#" type="#arguments.type#" metadata="#arguments.metadata#" thestruct="#_s#">
	</cffunction>

	<!--- Get Description, keywords and raw metadata --->
	<cffunction name="getMetadataOfFile" access="public" returntype="struct">
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<!--- Params --->
		<cfset var _s = getStruct()>
		<cfset _s.file_id = arguments.fileid>
		<cfset var qry = queryNew("id")>
		<cfset queryAddRow(qry)>
		<cfset querySetCell(qry, "id", arguments.fileid)>
		<cfset var r = structNew()>
		<!--- Images --->
		<cfif arguments.type EQ "img">
			<!--- Call function --->
			<cfinvoke component="images" method="gettext" qry="#qry#" thestruct="#_s#" returnvariable="r.metadata">
			<cfinvoke component="images" method="getrawmetadata" qry="#qry#" thestruct="#_s#" returnvariable="r.rawmetadata">
			<cfinvoke component="xmp" method="readxmpdb" thestruct="#s#" thestruct="#_s#" returnvariable="r.xmpmetadata">
		<!--- Videos --->
		<cfelseif arguments.type EQ "vid">
			<!--- Call function --->
			<cfinvoke component="videos" method="gettext" qry="#qry#" thestruct="#_s#" returnvariable="r.metadata">
			<cfinvoke component="videos" method="getrawmetadata" qry="#qry#" thestruct="#_s#" returnvariable="r.rawmetadata">
		<!--- Audios --->
		<cfelseif arguments.type EQ "aud">
			<!--- Call function --->
			<cfinvoke component="audios" method="gettext" qry="#qry#" thestruct="#_s#" returnvariable="r.metadata">
			<cfinvoke component="audios" method="getrawmetadata" qry="#qry#" thestruct="#_s#" returnvariable="r.rawmetadata">
		<!--- Docs --->
		<cfelseif arguments.type EQ "doc">
			<!--- Call function --->
			<cfinvoke component="files" method="gettext" qry="#qry#" thestruct="#_s#" returnvariable="r.metadata">
			<cfinvoke component="files" method="getrawmetadata" qry="#qry#" thestruct="#_s#" returnvariable="r.rawmetadata">
			<cfinvoke component="files" method="getpdfxmp" thestruct="#s#" thestruct="#_s#" returnvariable="r.xmpmetadata">
		</cfif>
		<!--- Return --->
		<cfreturn r />
	</cffunction>

	<!--- Get temp files --->
	<cffunction name="getFilesTemp" access="public" returntype="query">
		<cfargument name="fileid" type="string" required="true" />
		<!--- Param --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT 
		t.tempid AS id,
		t.filename,
		t.folder_id,
		CASE
			WHEN (f.type_type IS NULL) THEN 'doc'
			ELSE f.type_type
		END AS type
		FROM #getHostPrefix()#assets_temp t LEFT JOIN file_types f ON f.type_id = t.extension
		WHERE t.tempid IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.fileid#" list="true">)
		AND t.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Get Description, keywords and raw metadata --->
	<cffunction name="getFile" access="public" returntype="query">
		<cfargument name="fileid" type="string" required="true" />
		<!--- Param --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT
		'img' as type,
		i.img_id id, 
		i.img_filename filename, 
		i.img_filename_org filename_org,
		i.folder_id_r folder_id, 
		i.path_to_asset,
		i.cloud_url,
		i.cloud_url_org,
		CAST(i.img_width AS CHAR) as width,
		CAST(i.img_height AS CHAR) as height,
		i.img_size size,
		i.img_extension extension,
		x.colorspace,
		x.xres AS xdpi,
		x.yres AS ydpi,
		x.resunit AS unit,
		i.hashtag AS md5hash
		FROM #getHostPrefix()#images i LEFT JOIN #getHostPrefix()#xmp x ON x.id_r = i.img_id
		WHERE i.img_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.fileid#" list="true">)
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		UNION ALL
		SELECT
		'vid' as type,
		v.vid_id id, 
		v.vid_filename filename, 
		v.vid_name_org filename_org,
		v.folder_id_r folder_id, 
		v.path_to_asset,
		v.cloud_url,
		v.cloud_url_org,
		CAST(v.vid_width AS CHAR) as width,
		CAST(v.vid_height AS CHAR) as height,
		v.vid_size size,
		v.vid_extension extension,
		'' AS colorspace,
		'' AS xdpi,
		'' AS ydpi,
		'' AS unit,
		v.hashtag AS md5hash
		FROM #getHostPrefix()#videos v 
		WHERE v.vid_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.fileid#" list="true">)
		AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		UNION ALL
		SELECT
		'aud' as type,
		a.aud_id id, 
		a.aud_name filename, 
		a.aud_name_org filename_org,
		a.folder_id_r folder_id, 
		a.path_to_asset,
		a.cloud_url,
		a.cloud_url_org,
		'0' as width,
		'0' as height,
		a.aud_size size,
		a.aud_extension extension,
		'' AS colorspace,
		'' AS xdpi,
		'' AS ydpi,
		'' AS unit,
		a.hashtag AS md5hash
		FROM #getHostPrefix()#audios a
		WHERE a.aud_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.fileid#" list="true">)
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		UNION ALL
		SELECT
		'doc' as type,
		f.file_id id, 
		f.file_name filename, 
		f.file_name_org filename_org, 
		f.folder_id_r folder_id, 
		f.path_to_asset,
		f.cloud_url,
		f.cloud_url_org,
		'0' as width,
		'0' as height,
		f.file_size size,
		f.file_extension extension,
		'' AS colorspace,
		'' AS xdpi,
		'' AS ydpi,
		'' AS unit,
		f.hashtag AS md5hash
		FROM #getHostPrefix()#files f 
		WHERE f.file_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.fileid#" list="true">)
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Execute workflow --->
	<cffunction name="executeWorkflow" access="public" returntype="void">
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="thetype" type="string" required="true" />
		<cfargument name="workflow" type="string" required="true" />
		<cfargument name="folderid" type="string" required="true" />
		<cfargument name="thestruct" type="Struct">
		<!-- Variables for workflow -->
		<cfset var s = {}>
		<cfset s.fileid = arguments.fileid>
		<cfset s.thefiletype = arguments.thetype>
		<cfset s.folder_id = arguments.folderid>
		<cfset s.comingfrom = cgi.http_referer>
		<!--- Loop over fileid and execute workflow for each file --->
		<cfset s.folder_action = true>
		<cfinvoke component="plugins" method="getactions" theaction="#arguments.workflow#" args="#s#" thestruct="#arguments.thestruct#" />
		<cfset s.folder_action = false>
		<cfinvoke component="plugins" method="getactions" theaction="#arguments.workflow#" args="#s#" thestruct="#arguments.thestruct#" />
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Update Dates on files --->
	<cffunction name="updateDate" access="public" returntype="void">
		<cfargument name="fileid" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />
		<cfset var _s = getStruct()>
		<!--- Call function --->
		<cfinvoke component="global" method="update_dates" fileid="#arguments.fileid#" type="#arguments.type#" thestruct="#_s#" />
	</cffunction>

</cfcomponent>