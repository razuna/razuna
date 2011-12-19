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
<cfcomponent hint="CFC for Settings" extends="extQueryCaching">

<!--- Get all languages for this host for the Settings --->
<cffunction name="allsettings">
	<cfquery datasource="#application.razuna.datasource#" name="set">
	SELECT set_id, set_pref
	FROM #session.hostdbprefix#settings
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn set>
</cffunction>

<!--- Get all settings for this host --->
<cffunction name="allsettings_2">
	<cfquery datasource="#application.razuna.datasource#" name="set2" cachename="allsettings_2#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_id, set2_date_format, set2_date_format_del, set2_meta_author, set2_meta_publisher, set2_meta_copyright, 
	set2_meta_robots, set2_meta_revisit, set2_url_sp_original, set2_url_sp_thumb, set2_url_sp_comp, set2_url_sp_comp_uw, 
	set2_url_app_server, set2_create_imgfolders_where, set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, 
	set2_img_comp_width, set2_img_comp_heigth, set2_img_download_org, set2_doc_download, set2_intranet_reg_emails, 
	set2_intranet_reg_emails_sub, set2_intranet_gen_download, set2_cat_intra, set2_cat_web, set2_url_website, 
	set2_payment_pre, set2_payment_bill, set2_payment_pod, set2_payment_cc, set2_payment_cc_cards, set2_payment_paypal, 
	set2_email_server, set2_email_from, set2_email_smtp_user, set2_email_smtp_password, 
	set2_email_server_port,
	<!--- set2_vid_preview_width, set2_vid_preview_heigth, set2_vid_preview_time, set2_vid_preview_start, ---> 
	set2_url_sp_video_preview, set2_vid_preview_author, set2_vid_preview_copyright, set2_cat_vid_web, set2_cat_vid_intra,
	set2_create_vidfolders_where, set2_path_to_assets, set2_aws_bucket
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn set2>
</cffunction>

<!--- Settings for Globals Preferences --->
<cffunction name="prefs_global">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_global#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT SET2_DATE_FORMAT, SET2_DATE_FORMAT_DEL, SET2_EMAIL_SERVER, SET2_EMAIL_FROM, SET2_EMAIL_SMTP_USER, 
	SET2_EMAIL_SMTP_PASSWORD, SET2_EMAIL_SERVER_PORT
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for Meta --->
<cffunction name="prefs_meta">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_meta#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_meta_author, set2_meta_publisher, set2_meta_copyright, set2_meta_robots, set2_meta_revisit
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for DAM --->
<cffunction name="prefs_dam">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_dam#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_intranet_gen_download, set2_doc_download, set2_img_download_org, set2_intranet_reg_emails, 
	set2_intranet_reg_emails_sub, set2_ora_path_incoming, set2_ora_path_incoming_batch, set2_ora_path_outgoing,
	set2_path_to_assets
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for Website --->
<cffunction name="prefs_web">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_web#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_url_website, set2_payment_cc, set2_payment_cc_cards, set2_payment_bill, set2_payment_pod, set2_payment_pre, set2_payment_paypal
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for Image --->
<cffunction name="prefs_image">
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_image#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_create_imgfolders_where, set2_cat_intra, set2_cat_web, set2_img_format, set2_img_thumb_width, 
	set2_img_thumb_heigth, set2_img_comp_width, set2_img_comp_heigth
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- The tool paths --->
	<cfquery datasource="#application.razuna.datasource#" name="qrypaths">
	SELECT thetool, thepath
	FROM tools
	</cfquery>
	<!--- Get tools --->
	<cfloop query="qrypaths">
		<cfif thetool EQ "imagemagick">
			<cfset qry.set2_path_imagemagick = thepath>
		<cfelseif thetool EQ "exiftool">
			<cfset qry.set2_path_to_exiftool = thepath>
		<cfelseif thetool EQ "dcraw">
			<cfset qry.set2_path_dcraw = thepath>
		<cfelseif thetool EQ "wget">
			<cfset qry.set2_path_wget = thepath>
		</cfif>
	</cfloop>
	<cfreturn qry>
</cffunction>

<!--- Settings for Video --->
<cffunction name="prefs_video">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_video#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_create_vidfolders_where, set2_cat_vid_intra, set2_cat_vid_web, <!--- set2_vid_preview_width, set2_vid_preview_heigth, set2_vid_preview_time, set2_vid_preview_start, ---> set2_vid_preview_author, set2_vid_preview_copyright
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- The tool paths --->
	<cfquery datasource="#application.razuna.datasource#" name="qrypaths">
	SELECT thetool, thepath
	FROM tools
	WHERE lower(thetool) = <cfqueryparam value="ffmpeg" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	<cfset qry.set2_path_ffmpeg = qrypaths.thepath>
	<cfreturn qry>
</cffunction>

<!--- Settings for Oracle --->
<cffunction name="prefs_oracle">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_oracle#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_url_app_server, set2_ora_path_internal, set2_url_sp_original, set2_url_sp_thumb, set2_url_sp_comp, set2_url_sp_comp_uw, set2_url_sp_video, set2_url_sp_video_preview, set2_ora_path_incoming, set2_ora_path_incoming_batch, set2_ora_path_outgoing
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for Storage --->
<cffunction name="prefs_storage">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="prefs_storage#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_nirvanix_name, set2_nirvanix_pass, set2_aws_bucket
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for File Types --->
<cffunction name="prefs_types">
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT type_id, type_type, type_mimecontent, type_mimesubcontent
	FROM file_types
	ORDER BY lower(type_id)
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Add File Type --->
<cffunction name="prefs_types_add">
	<cfargument name="thestruct" type="Struct">
	<cftransaction>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO file_types
		(type_id, type_type, type_mimecontent, type_mimesubcontent)
		VALUES(
		<cfqueryparam value="#lcase(arguments.thestruct.type_id)#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#lcase(arguments.thestruct.type_type)#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#lcase(arguments.thestruct.type_mimecontent)#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="#lcase(arguments.thestruct.type_mimesubcontent)#" cfsqltype="cf_sql_varchar">
		)
		</cfquery>
	</cftransaction>
	<cfreturn />
</cffunction>

<!--- Remove File Type --->
<cffunction name="prefs_types_del">
	<cfargument name="thestruct" type="Struct">
	<cftransaction>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM file_types
		WHERE lower(type_id) = <cfqueryparam value="#lcase(arguments.thestruct.type_id)#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cftransaction>
	<cfreturn />
</cffunction>

<!--- Update File Type --->
<cffunction name="prefs_types_update">
	<cfargument name="thestruct" type="Struct">
	<cftransaction>
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE file_types
		SET
		type_id = <cfqueryparam value="#lcase(arguments.thestruct.type_id)#" cfsqltype="cf_sql_varchar">,
		type_type = <cfqueryparam value="#lcase(arguments.thestruct.type_type)#" cfsqltype="cf_sql_varchar">,
		type_mimecontent = <cfqueryparam value="#lcase(arguments.thestruct.type_mimecontent)#" cfsqltype="cf_sql_varchar">, 
		type_mimesubcontent = <cfqueryparam value="#lcase(arguments.thestruct.type_mimesubcontent)#" cfsqltype="cf_sql_varchar">
		WHERE lower(type_id) = <cfqueryparam value="#lcase(arguments.thestruct.type_id)#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cftransaction>
	<cfreturn />
</cffunction>

<!--- Languages: Get Languages --->
<cffunction name="lang_get">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="lang_get#session.hostid#" cachedomain="#session.hostid#_lang">
	SELECT lang_id, lang_name, lang_active
	FROM #session.hostdbprefix#languages
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY lang_id
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Languages: Update Languages --->
<cffunction name="lang_get_langs">
	<cfargument name="thestruct" type="Struct">
	<!--- Get the xml files in the translation dir --->
	<cfdirectory action="list" directory="#arguments.thestruct.thepath#/translations" name="thelangs" filter="*.xml" />
	<!--- Loop over languages --->
	<cfloop query="thelangs">
		<!--- Get name and language id --->
		<cfset thislang = replacenocase("#name#", ".xml", "", "ALL")>
		<!--- If we come from admin then take another method --->
		<cfif structkeyexists(arguments.thestruct,"fromadmin")>
			<cfinvoke component="defaults" method="xmllangid" thetransfile="#arguments.thestruct.thepath#/translations/#name#" returnvariable="langid">
		<cfelse>
			<cfinvoke component="defaults" method="trans" transid="thisid" thetransfile="#name#" returnvariable="langid">
		</cfif>
		<!--- Check for existing record --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="langgetlangs#session.hostid##langid#" cachedomain="#session.hostid#_lang">
		SELECT lang_id, lang_name
		FROM #session.hostdbprefix#languages
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND lang_id = <cfqueryparam value="#langid#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<!--- RAZ-544: If the lang name is numeric we change this to the name value --->
		<cfif isnumeric(qry.lang_name) AND qry.recordcount NEQ 0>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#languages
			SET lang_name = <cfqueryparam value="#ucase(left(thislang,1))##mid(thislang,2,20)#" cfsqltype="cf_sql_varchar">
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND lang_id = <cfqueryparam value="#langid#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.hostid#_lang" />
		</cfif>
		<!--- If no record found do an insert --->
		<cfif qry.recordcount EQ 0>
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#languages
			(lang_id, lang_name, lang_active, host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#langid#" cfsqltype="cf_sql_numeric">,
			<cfqueryparam value="#ucase(left(thislang,1))##mid(thislang,2,20)#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="f" cfsqltype="cf_sql_varchar">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
			<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.hostid#_lang" />
		</cfif>
	</cfloop>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Languages: Update Languages --->
<cffunction name="lang_save">
	<cfargument name="thestruct" type="Struct">
	<!--- Set the active field to f on all languages --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#languages
	SET lang_active = <cfqueryparam value="f" cfsqltype="cf_sql_varchar">
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Loop over the fields --->
	<cfloop delimiters="," index="myform" list="#arguments.thestruct.fieldnames#">
		<cfif myform CONTAINS "lang_active_">
			<!--- Get the ID --->
			<cfset thefield=ReplaceNoCase(myform, "lang_active_", "", "ALL")>
			<!--- Update DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#languages
			SET lang_active = <cfqueryparam value="t" cfsqltype="cf_sql_varchar">
			WHERE lang_id = <cfqueryparam value="#thefield#" cfsqltype="cf_sql_numeric">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		</cfif>
	</cfloop>
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.hostid#_lang" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Labels: get --->
<cffunction name="get_label_set">
	<!--- Set the active field to f on all languages --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachename="labset#session.hostid#" cachedomain="#session.hostid#_labels_setting">
	SELECT set2_labels_users
	FROM #session.hostdbprefix#settings_2
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Return --->
	<cfreturn qry />
</cffunction>

<!--- Labels: set --->
<cffunction name="set_label_set">
	<cfargument name="label_users" type="string">
	<!--- Set the active field to f on all languages --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#settings_2
	SET set2_labels_users = <cfqueryparam value="#arguments.label_users#" cfsqltype="cf_sql_varchar">
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.theuserid#_labels_setting" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- GET GLOBAL Settings --->
<cffunction name="get_global" access="remote" returnType="query">
	<!--- Update --->
	<cfquery datasource="razuna_default" name="qry">
	SELECT conf_database, conf_schema, conf_datasource, conf_storage, conf_nirvanix_appkey, conf_nirvanix_master_name, 
	conf_nirvanix_master_pass, conf_nirvanix_url_services, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_rendering_farm
	FROM razuna_config
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- GET Tools --->
<cffunction name="get_tools">
	<!--- Param --->
	<cfset qry = structnew()>
	<cfparam default="" name="qry.imagemagick">
	<cfparam default="" name="qry.exiftool">
	<cfparam default="" name="qry.ffmpeg">
	<cfparam default="" name="qry.dcraw">
	<cfparam default="" name="qry.wget">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qrypaths">
	SELECT thetool, thepath
	FROM tools
	</cfquery>
	<!--- Put results into vars --->
	<cfloop query="qrypaths">
		<cfset qry["#thetool#"] = thepath>
	</cfloop>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Save GLOBAL Settings --->
<cffunction name="update_global">
	<cfargument name="thestruct" type="Struct">
	<cfset commad = "F">
	<!--- Update default config --->
	<cfquery datasource="razuna_default">
	UPDATE razuna_config
	SET 
	<cfif StructKeyExists(#arguments.thestruct#, "conf_storage")>
		conf_storage = <cfqueryparam value="#arguments.thestruct.conf_storage#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_nirvanix_master_name")>
		<cfif commad EQ "T">,</cfif>conf_nirvanix_master_name = <cfqueryparam value="#arguments.thestruct.conf_nirvanix_master_name#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_nirvanix_appkey")>
		<cfif commad EQ "T">,</cfif>conf_nirvanix_appkey = <cfqueryparam value="#arguments.thestruct.conf_nirvanix_appkey#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_nirvanix_master_pass")>
		<cfif commad EQ "T">,</cfif>conf_nirvanix_master_pass = <cfqueryparam value="#arguments.thestruct.conf_nirvanix_master_pass#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_database")>
		<cfif commad EQ "T">,</cfif>conf_database = <cfqueryparam value="#arguments.thestruct.conf_database#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_schema")>
		<cfif commad EQ "T">,</cfif>conf_schema = <cfqueryparam value="#arguments.thestruct.conf_schema#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_datasource")>
		<cfif commad EQ "T">,</cfif>conf_datasource = <cfqueryparam value="#arguments.thestruct.conf_datasource#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_aws_access_key")>
		<cfif commad EQ "T">,</cfif>conf_aws_access_key = <cfqueryparam value="#arguments.thestruct.conf_aws_access_key#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_aws_secret_access_key")>
		<cfif commad EQ "T">,</cfif>conf_aws_secret_access_key = <cfqueryparam value="#arguments.thestruct.conf_aws_secret_access_key#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_aws_location")>
		<cfif commad EQ "T">,</cfif>conf_aws_location = <cfqueryparam value="#arguments.thestruct.conf_aws_location#" cfsqltype="cf_sql_varchar">
		<cfset commad = "T">
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_rendering_farm")>
		<cfif commad EQ "T">,</cfif>conf_rendering_farm = <cfqueryparam value="#arguments.thestruct.conf_rendering_farm#" cfsqltype="CF_SQL_DOUBLE">
		<cfset commad = "T">
	</cfif>
	</cfquery>
	<!--- Set application scopes --->
	<cfif StructKeyExists(#arguments.thestruct#, "conf_nirvanix_appkey")>
		<cfset application.razuna.nvxappkey = arguments.thestruct.conf_nirvanix_appkey>
	</cfif>
	<cfif StructKeyExists(#arguments.thestruct#, "conf_aws_access_key")>
		<cfset application.razuna.awskey = arguments.thestruct.conf_aws_access_key>
		<cfset application.razuna.awskeysecret = arguments.thestruct.conf_aws_secret_access_key>
		<cfset application.razuna.awslocation = arguments.thestruct.conf_aws_location>
		<cfset application.razuna.s3ds = AmazonRegisterDataSource("aws","#arguments.thestruct.conf_aws_access_key#","#arguments.thestruct.conf_aws_secret_access_key#","#arguments.thestruct.conf_aws_location#")>
	</cfif>
	<!--- Set rendering setting in application scope --->
	<cfif StructKeyExists(#arguments.thestruct#, "conf_rendering_farm")>
		<cfset application.razuna.renderingfarm = arguments.thestruct.conf_rendering_farm>
	</cfif>
	<!--- Save in global setting the rendering farm location --->
	<cfif StructKeyExists(#arguments.thestruct#, "rendering_farm_location")>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#settings
		WHERE lower(set_id) = <cfqueryparam value="rendering_farm_location" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#settings
		(set_pref, set_id, host_id, rec_uuid)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.rendering_farm_location#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="rendering_farm_location" cfsqltype="cf_sql_varchar">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
	</cfif>
</cffunction>

<!--- Update TOOLS --->
<cffunction name="update_tools">
	<cfargument name="thestruct" type="Struct">
	<!--- Update Tools --->
	<cfloop collection="#arguments.thestruct#" item="myform">
		<cfif myform CONTAINS "imagemagick" OR myform CONTAINS "exiftool" OR myform CONTAINS "ffmpeg" OR myform CONTAINS "dcraw" OR myform CONTAINS "wget">
			<!--- Select --->
			<cfquery datasource="#application.razuna.datasource#" name="x">
			SELECT thetool
			FROM tools
			WHERE lower(thetool) = <cfqueryparam value="#lcase(myform)#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- Check if here or not --->
			<cfif x.recordcount EQ 1>
				<!--- Update --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE tools
				SET thepath = <cfqueryparam value="#arguments.thestruct[myform]#" cfsqltype="cf_sql_varchar">
				WHERE lower(thetool) = <cfqueryparam value="#lcase(myform)#" cfsqltype="cf_sql_varchar">
				</cfquery>
			<cfelse>
				<!--- Insert --->
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO tools
				(thetool, thepath)
				VALUES(
				<cfqueryparam value="#lcase(myform)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.thestruct[myform]#" cfsqltype="cf_sql_varchar">
				)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>
</cffunction>

<!--- Save Settings --->
<cffunction hint="Save Settings" name="update">
	<cfargument name="thestruct" type="Struct">
	<cftransaction>
		<!--- save all settings which are language relevant. loop trough the form fields which begin with set_ --->
		<cfloop collection="#arguments.thestruct#" item="myform">
			<cfif #myform# CONTAINS "set_">
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #session.hostdbprefix#settings
				WHERE lower(set_id) = <cfqueryparam value="#lcase(myform)#" cfsqltype="cf_sql_varchar">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#settings
				(set_pref, set_id, host_id, rec_uuid)
				VALUES(
				<cfqueryparam value="#form["#myform#"]#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#lcase(myform)#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Check that there is a record with ID 1 if not then do an insert --->
		<cfquery datasource="#application.razuna.datasource#" name="ishere">
		SELECT set2_id
		FROM #session.hostdbprefix#settings_2
		WHERE set2_id = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfif ishere.recordcount EQ 0>
			<cfquery datasource="#application.razuna.datasource#" name="ishere">
			INSERT INTO #session.hostdbprefix#settings_2
			(set2_id, host_id, rec_uuid)
			VALUES
			(
			<cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		</cfif>
		<!--- Update Settings_2 --->
		<cfset commad = "F">
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#settings_2
		SET 
		<cfif StructKeyExists(#arguments.thestruct#, "set2_date_format")>
			set2_date_format = <cfqueryparam value="#arguments.thestruct.set2_date_format#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_date_format_del")>
			<cfif commad EQ "T">,</cfif>set2_date_format_del = <cfqueryparam value="#arguments.thestruct.set2_date_format_del#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_META_AUTHOR")>
			<cfif commad EQ "T">,</cfif>SET2_META_AUTHOR = <cfqueryparam value="#arguments.thestruct.SET2_META_AUTHOR#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_META_PUBLISHER")>
			<cfif commad EQ "T">,</cfif>SET2_META_PUBLISHER = <cfqueryparam value="#arguments.thestruct.SET2_META_PUBLISHER#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_META_COPYRIGHT")>
			<cfif commad EQ "T">,</cfif>SET2_META_COPYRIGHT = <cfqueryparam value="#arguments.thestruct.SET2_META_COPYRIGHT#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_META_ROBOTS")>
			<cfif commad EQ "T">,</cfif>SET2_META_ROBOTS = <cfqueryparam value="#arguments.thestruct.SET2_META_ROBOTS#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_META_REVISIT")>
			<cfif commad EQ "T">,</cfif>SET2_META_REVISIT = <cfqueryparam value="#arguments.thestruct.SET2_META_REVISIT#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_URL_SP_ORIGINAL")>
			<cfif commad EQ "T">,</cfif>SET2_URL_SP_ORIGINAL = <cfqueryparam value="#arguments.thestruct.SET2_URL_SP_ORIGINAL#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_URL_SP_THUMB")>
			<cfif commad EQ "T">,</cfif>SET2_URL_SP_THUMB = <cfqueryparam value="#arguments.thestruct.SET2_URL_SP_THUMB#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_URL_SP_COMP")>
			<cfif commad EQ "T">,</cfif>SET2_URL_SP_COMP = <cfqueryparam value="#arguments.thestruct.SET2_URL_SP_COMP#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_URL_SP_COMP_UW")>
			<cfif commad EQ "T">,</cfif>SET2_URL_SP_COMP_UW = <cfqueryparam value="#arguments.thestruct.SET2_URL_SP_COMP_UW#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_url_app_server")>
			<cfif commad EQ "T">,</cfif>set2_url_app_server = <cfqueryparam value="#arguments.thestruct.set2_url_app_server#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "thisfolder_img")>
			<cfif commad EQ "T">,</cfif>set2_create_imgfolders_where = <cfqueryparam value="#arguments.thestruct.thisfolder_img#" cfsqltype="cf_sql_numeric">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_img_format")>
			<cfif commad EQ "T">,</cfif>set2_img_format = <cfqueryparam value="#arguments.thestruct.set2_img_format#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_img_thumb_width")>
			<cfif commad EQ "T">,</cfif>set2_img_thumb_width = <cfqueryparam value="#arguments.thestruct.set2_img_thumb_width#" cfsqltype="cf_sql_numeric">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_img_thumb_heigth")>
			<cfif commad EQ "T">,</cfif>set2_img_thumb_heigth = <cfqueryparam value="#arguments.thestruct.set2_img_thumb_heigth#" cfsqltype="cf_sql_numeric">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_img_comp_width")>
			<cfif commad EQ "T">,</cfif>set2_img_comp_width = <cfqueryparam value="#arguments.thestruct.set2_img_comp_width#" cfsqltype="cf_sql_numeric">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_img_comp_heigth")>
			<cfif commad EQ "T">,</cfif>set2_img_comp_heigth = <cfqueryparam value="#arguments.thestruct.set2_img_comp_heigth#" cfsqltype="cf_sql_numeric">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_img_download_org")>
			<cfif commad EQ "T">,</cfif>set2_img_download_org = <cfqueryparam value="#arguments.thestruct.set2_img_download_org#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_doc_download")>
			<cfif commad EQ "T">,</cfif>set2_doc_download = <cfqueryparam value="#arguments.thestruct.set2_doc_download#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_intranet_reg_emails")>
			<cfif commad EQ "T">,</cfif>set2_intranet_reg_emails = <cfqueryparam value="#arguments.thestruct.set2_intranet_reg_emails#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_intranet_reg_emails_sub")>
			<cfif commad EQ "T">,</cfif>set2_intranet_reg_emails_sub = <cfqueryparam value="#arguments.thestruct.set2_intranet_reg_emails_sub#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_intranet_gen_download")>
			<cfif commad EQ "T">,</cfif>set2_intranet_gen_download = <cfqueryparam value="#arguments.thestruct.set2_intranet_gen_download#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_cat_web")>
			<cfif commad EQ "T">,</cfif>set2_cat_web = <cfqueryparam value="#arguments.thestruct.set2_cat_web#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_cat_intra")>
			<cfif commad EQ "T">,</cfif>set2_cat_intra = <cfqueryparam value="#arguments.thestruct.set2_cat_intra#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "url_website")>
			<cfif commad EQ "T">,</cfif>set2_url_website = <cfqueryparam value="#arguments.thestruct.url_website#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_PAYMENT_PRE")>
			<cfif commad EQ "T">,</cfif>SET2_PAYMENT_PRE = <cfqueryparam value="#arguments.thestruct.SET2_PAYMENT_PRE#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_PAYMENT_BILL")>
			<cfif commad EQ "T">,</cfif>SET2_PAYMENT_BILL = <cfqueryparam value="#arguments.thestruct.SET2_PAYMENT_BILL#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_PAYMENT_POD")>
			<cfif commad EQ "T">,</cfif>SET2_PAYMENT_POD  = <cfqueryparam value="#arguments.thestruct.SET2_PAYMENT_POD#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_PAYMENT_CC")>
			<cfif commad EQ "T">,</cfif>SET2_PAYMENT_CC = <cfqueryparam value="#arguments.thestruct.SET2_PAYMENT_CC#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_PAYMENT_CC_CARDS")>
			<cfif commad EQ "T">,</cfif>SET2_PAYMENT_CC_CARDS = <cfqueryparam value="#arguments.thestruct.SET2_PAYMENT_CC_CARDS#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_payment_paypal")>
			<cfif commad EQ "T">,</cfif>set2_payment_paypal = <cfqueryparam value="#arguments.thestruct.set2_payment_paypal#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_path_imagemagick")>
			<cfif commad EQ "T">,</cfif>SET2_PATH_IMAGEMAGICK = <cfqueryparam value="#arguments.thestruct.set2_path_imagemagick#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_email_server")>
			<cfif commad EQ "T">,</cfif>SET2_EMAIL_SERVER = <cfqueryparam value="#arguments.thestruct.set2_email_server#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_email_from")>
			<cfif commad EQ "T">,</cfif>SET2_EMAIL_FROM = <cfqueryparam value="#arguments.thestruct.set2_email_from#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_email_smtp_user")>
			<cfif commad EQ "T">,</cfif>SET2_EMAIL_SMTP_USER = <cfqueryparam value="#arguments.thestruct.set2_email_smtp_user#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_email_smtp_password")>
			<cfif commad EQ "T">,</cfif>SET2_EMAIL_SMTP_PASSWORD = <cfqueryparam value="#arguments.thestruct.set2_email_smtp_password#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_EMAIL_SERVER_PORT")>
			<cfif commad EQ "T">,</cfif>SET2_EMAIL_SERVER_PORT = <cfif arguments.thestruct.set2_email_server_port EQ ""><cfqueryparam value="25" cfsqltype="cf_sql_numeric"><cfelse><cfqueryparam value="#arguments.thestruct.SET2_EMAIL_SERVER_PORT#" cfsqltype="cf_sql_numeric"></cfif>
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "folder_in")>
			<cfif commad EQ "T">,</cfif>set2_ora_path_incoming = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_in#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "folder_in_batch")>
			<cfif commad EQ "T">,</cfif>set2_ora_path_incoming_batch = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_in_batch#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "folder_out")>
			<cfif commad EQ "T">,</cfif>set2_ora_path_outgoing = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.folder_out#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_vid_preview_width")>
			<cfif commad EQ "T">,</cfif>set2_vid_preview_width = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.set2_vid_preview_width#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_vid_preview_heigth")>
			<cfif commad EQ "T">,</cfif>set2_vid_preview_heigth = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.set2_vid_preview_heigth#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_path_ffmpeg")>
			<cfif commad EQ "T">,</cfif>set2_path_ffmpeg = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.set2_path_ffmpeg#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "SET2_VID_PREVIEW_TIME")>
			<cfif commad EQ "T">,</cfif>SET2_VID_PREVIEW_TIME = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.SET2_VID_PREVIEW_TIME#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_vid_preview_start")>
			<cfif commad EQ "T">,</cfif>set2_vid_preview_start = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.set2_vid_preview_start#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_url_sp_video")>
			<cfif commad EQ "T">,</cfif>set2_url_sp_video = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.set2_url_sp_video#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_url_sp_video_preview")>
			<cfif commad EQ "T">,</cfif>set2_url_sp_video_preview = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.set2_url_sp_video_preview#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_vid_preview_copyright")>
			<cfif commad EQ "T">,</cfif>set2_vid_preview_copyright = <cfqueryparam cfsqltype="cf_sql_varchar" value="#replace("#arguments.thestruct.set2_vid_preview_copyright#"," ","-","ALL")#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_vid_preview_author")>
			<cfif commad EQ "T">,</cfif>set2_vid_preview_author = <cfqueryparam cfsqltype="cf_sql_varchar" value="#replace("#arguments.thestruct.set2_vid_preview_author#"," ","-","ALL")#">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_cat_vid_web")>
			<cfif commad EQ "T">,</cfif>set2_cat_vid_web = <cfqueryparam value="#arguments.thestruct.set2_cat_vid_web#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_cat_vid_intra")>
			<cfif commad EQ "T">,</cfif>set2_cat_vid_intra = <cfqueryparam value="#arguments.thestruct.set2_cat_vid_intra#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "thisfolder_vid")>
			<cfif commad EQ "T">,</cfif>set2_create_vidfolders_where = <cfqueryparam value="#arguments.thestruct.thisfolder_vid#" cfsqltype="cf_sql_numeric">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_path_to_assets")>
			<cfif commad EQ "T">,</cfif>set2_path_to_assets = <cfqueryparam value="#arguments.thestruct.set2_path_to_assets#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_path_to_assets_webroot")>
			<cfif commad EQ "T">,</cfif>set2_path_to_assets_webroot = <cfqueryparam value="#arguments.thestruct.set2_path_to_assets_webroot#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_path_to_exiftool")>
			<cfif commad EQ "T">,</cfif>set2_path_to_exiftool = <cfqueryparam value="#arguments.thestruct.set2_path_to_exiftool#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_ora_path_internal")>
			<cfif commad EQ "T">,</cfif>set2_ora_path_internal = <cfqueryparam value="#arguments.thestruct.set2_ora_path_internal#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_nirvanix_name")>
			<cfif commad EQ "T">,</cfif>set2_nirvanix_name = <cfqueryparam value="#arguments.thestruct.set2_nirvanix_name#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_nirvanix_pass")>
			<cfif commad EQ "T">,</cfif>set2_nirvanix_pass = <cfqueryparam value="#arguments.thestruct.set2_nirvanix_pass#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_aws_bucket")>
			<cfif commad EQ "T">,</cfif>set2_aws_bucket = <cfqueryparam value="#lcase(arguments.thestruct.set2_aws_bucket)#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cftransaction>
	<!--- Flush --->
	<cfinvoke component="global" method="clearcache" theaction="flushall" thedomain="#session.hostid#_setting2" />
	
</cffunction>

<!--- FUNCTION: UPLOAD --->
<cffunction hint="Upload" name="upload" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Create directory if not there already to hold this logo --->
	<cftry>
		<cfdirectory action="create" directory="#arguments.thestruct.thepathup#global/host/logo/#session.hostid#" mode="775">
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!---  Upload file --->
	<cffile action="UPLOAD" filefield="#arguments.thestruct.thefield#" destination="#arguments.thestruct.thepathup#global/host/logo/#session.hostid#" result="result" nameconflict="overwrite" mode="775">
	<!--- 
	<!--- Get the filename --->
	<cfset thefilename = rereplacenocase("#result.serverFileName#","[^A-Za-z0-9]+","_","ALL")>	
	<!--- Re-add the extension to the name --->
	<cfif #result.serverFileExt# NEQ "">
		<cfset thefilename = "#thefilename#.#result.serverFileExt#">
	</cfif>
	
	
	<!--- Rename the file --->
	<cffile action="rename" source="#arguments.thestruct.thepath#/incoming/#result.ServerFile#" destination="#arguments.thestruct.thepathup#global/host/logo/#session.hostid#/#thefilename#"> --->
	<!--- Run the SP: IMPORT_IMAGE
	<CFSTOREDPROC PROCEDURE="#session.theoraschema#.import_intranet_logo" DATASOURCE="#application.razuna.datasource#">
		<CFPROCPARAM VALUE="#application.razuna.setid#" CFSQLTYPE="CF_SQL_NUMERIC" type="in">
		<CFPROCPARAM VALUE="#result.serverfile#" CFSQLTYPE="cf_sql_varchar" type="in">
		<CFPROCPARAM VALUE="#session.hostdbprefix#SETTINGS_2" CFSQLTYPE="cf_sql_varchar" type="in">
		<CFPROCPARAM VALUE="#arguments.thestruct.thefield#" CFSQLTYPE="cf_sql_varchar" type="in">
		<CFPROCPARAM VALUE="#arguments.thestruct.theurl#" CFSQLTYPE="cf_sql_varchar" type="in">
	</CFSTOREDPROC> --->
	<!--- Set variables that show the file in the GUI --->
	<cfset this.thefilename = #result.serverFileName#>
	<cfinvoke component="global" method="converttomb" thesize="#result.filesize#" returnvariable="thesize">
	<cfset this.thesize = #thesize#>
	<!--- Remove the file in the incoming dir
	<cffile action="delete" file="#arguments.thestruct.thepath#/incoming/#result.serverfile#"> --->
	<cfreturn this />
</cffunction>

<!--- FUNCTION: UPLOAD WATERMARK --->
<cffunction hint="Upload" name="upload_watermark" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Get the host path --->
	<cfinvoke component="defaults" method="hostpath" thesource="#application.razuna.datasource#" returnvariable="hostpath">
	<!--- Upload watermark --->
	<cffile action="upload" filefield="#arguments.thestruct.thefield#" destination="#arguments.thestruct.thepathup#/#hostpath#/dam/images/watermark" nameconflict="overwrite" result="result">
	<!--- Set variables that show the file in the GUI --->
	<cfset this.thefilename = #result.ServerFile#>
	<cfinvoke component="global" method="converttomb" thesize="#result.filesize#" returnvariable="thesize">
	<cfset this.thesize = #thesize#>
	<cfreturn this />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get specific setting --->
<cffunction hint="Get specific setting" name="thissetting" output="false" returntype="string">
	<cfargument name="thefield" type="string" default="" required="yes">
	<cfquery datasource="#application.razuna.datasource#" name="sett">
	SELECT set_pref
	FROM #session.hostdbprefix#settings
	WHERE lower(set_id) = <cfqueryparam value="#lcase(arguments.thefield)#" cfsqltype="cf_sql_varchar">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(sett.set_pref)>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get specific setting --->
<cffunction name="savesetting" output="false" returntype="void">
	<cfargument name="thefield" type="string" default="" required="yes">
	<cfargument name="thevalue" type="string" default="" required="yes">
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#settings
	WHERE lower(set_id) = <cfqueryparam value="#lcase(arguments.thefield)#" cfsqltype="cf_sql_varchar">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfquery datasource="#application.razuna.datasource#">
	INSERT INTO #session.hostdbprefix#settings
	(set_pref, set_id, host_id, rec_uuid)
	VALUES(
	<cfqueryparam value="#arguments.thevalue#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam value="#lcase(arguments.thefield)#" cfsqltype="cf_sql_varchar">,
	<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
	<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
	)
	</cfquery>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- PARSE THE CONFIG FILE OF THE ADMIN SECTION --->
<cffunction name="getconfig" output="false" returntype="string" hint="PARSE THE CONFIG FILE OF THE ADMIN SECTION">
<cfargument name="thenode" default="" required="yes" type="string" hint="the nodename which you want to parse">
<cfinvoke component="defaults" method="getAbsolutePath" returnvariable="xmlFile">
	<cfinvokeargument name="pathSourceAbsolute" value="#GetCurrentTemplatePath()#">
	<cfinvokeargument name="pathTargetRelative" value="../config/config.xml">
</cfinvoke>
<cffile action="read" file="#xmlFile#" variable="myVar" charset="utf-8">
<cfset xmlVar=xmlParse(myVar)/>
<cfset theconfig=xmlSearch(xmlVar, "configuration/configid[@name='#arguments.thenode#']")>
<cfreturn trim(#theconfig[1].thetext.xmlText#)>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- PARSE THE DEFAULT CONFIGURATION --->
<cffunction name="getconfigdefaultadmin" output="false">
	<cfargument name="pathoneup" default="" required="yes" type="string">
	<!--- Check DB --->
	<cftry>
		<cfquery datasource="razuna_default" name="qry">
		SELECT conf_database, conf_schema, conf_datasource, conf_setid, conf_storage, conf_nirvanix_appkey,
		conf_nirvanix_url_services, conf_isp, conf_firsttime, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_rendering_farm
		FROM razuna_config
		</cfquery>
		<cfcatch type="database">
			<!--- Create the config DB on the filesystem --->
			<cfinvoke component="db_h2" method="BDsetDatasource">
				<cfinvokeargument name="name" value="razuna_default" />
				<cfinvokeargument name="databasename" value="razuna_default" />
				<cfinvokeargument name="logintimeout" value="120" />
				<cfinvokeargument name="initstring" value="" />
				<cfinvokeargument name="connectionretries" value="0" />
				<cfinvokeargument name="connectiontimeout" value="120" />
				<cfinvokeargument name="username" value="razuna" />
				<cfinvokeargument name="password" value="razunaconfig" />
				<cfinvokeargument name="sqlstoredprocedures" value="true" />
				<cfinvokeargument name="hoststring" value="jdbc:h2:#arguments.pathoneup#db/razuna_default;CACHE_SIZE=100000;IGNORECASE=TRUE;MODE=Oracle;AUTO_RECONNECT=TRUE;CACHE_TYPE=SOFT_LRU;AUTO_SERVER=TRUE" />
				<cfinvokeargument name="sqlupdate" value="true" />
				<cfinvokeargument name="sqlselect" value="true" />
				<cfinvokeargument name="sqlinsert" value="true" />
				<cfinvokeargument name="sqldelete" value="true" />
				<cfinvokeargument name="perrequestconnections" value="false" />
				<cfinvokeargument name="drivername" value="org.h2.Driver" />
				<cfinvokeargument name="maxconnections" value="24" />
			</cfinvoke>
			<!--- Create Table --->
			<cfquery datasource="razuna_default">
			CREATE TABLE razuna_config
			(
				conf_database				VARCHAR(100),
				conf_schema					VARCHAR(100),
				conf_datasource				VARCHAR(100),
				conf_setid					VARCHAR(100),
				conf_storage				VARCHAR(100),
				conf_aws_access_key			VARCHAR(100),
				conf_aws_secret_access_key	VARCHAR(100),
				conf_aws_location			VARCHAR(100),
				conf_nirvanix_appkey		VARCHAR(100),
				conf_nirvanix_master_name	VARCHAR(100),
				conf_nirvanix_master_pass	VARCHAR(100),
				conf_nirvanix_url_services	VARCHAR(100),
				conf_isp					VARCHAR(100),
				conf_firsttime				BOOLEAN,
				conf_rendering_farm			BOOLEAN
			)
			</cfquery>
			<!--- Insert values --->
			<cfquery datasource="razuna_default">
			INSERT INTO razuna_config
			(conf_database, conf_schema, conf_datasource, conf_setid, conf_storage, 
			conf_nirvanix_url_services, conf_isp, conf_firsttime, conf_rendering_farm)
			VALUES(
			'h2',
			'razuna',
			'h2',
			'1',
			'local',
			'http://services.nirvanix.com',
			'false',
			true,
			false
			)
			</cfquery>
			<!--- Query again --->
			<cfquery datasource="razuna_default" name="qry">
			SELECT conf_database, conf_schema, conf_datasource, conf_setid, conf_storage, conf_nirvanix_appkey,
			conf_nirvanix_url_services, conf_isp, conf_firsttime, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_rendering_farm
			FROM razuna_config
			</cfquery>
		</cfcatch>
	</cftry>
	<!--- Check BACKUP STATUS --->
	<cftry>
		<cfquery datasource="razuna_backup">
		SELECT back_id
		FROM razuna_backup
		</cfquery>
		<cfcatch type="database">
			<!--- Create the config DB on the filesystem --->
			<cfinvoke component="db_h2" method="BDsetDatasource">
				<cfinvokeargument name="name" value="razuna_backup" />
				<cfinvokeargument name="databasename" value="razuna_backup" />
				<cfinvokeargument name="logintimeout" value="120" />
				<cfinvokeargument name="initstring" value="" />
				<cfinvokeargument name="connectionretries" value="0" />
				<cfinvokeargument name="connectiontimeout" value="120" />
				<cfinvokeargument name="username" value="razuna" />
				<cfinvokeargument name="password" value="razunadb" />
				<cfinvokeargument name="sqlstoredprocedures" value="true" />
				<cfinvokeargument name="hoststring" value="jdbc:h2:#arguments.pathoneup#admin/backup/razuna_backup;LOG=0;CACHE_SIZE=300000;IGNORECASE=TRUE;MODE=Oracle;AUTO_RECONNECT=TRUE;CACHE_TYPE=SOFT_LRU;AUTO_SERVER=TRUE" />
				<cfinvokeargument name="sqlupdate" value="true" />
				<cfinvokeargument name="sqlselect" value="true" />
				<cfinvokeargument name="sqlinsert" value="true" />
				<cfinvokeargument name="sqldelete" value="true" />
				<cfinvokeargument name="perrequestconnections" value="false" />
				<cfinvokeargument name="drivername" value="org.h2.Driver" />
				<cfinvokeargument name="maxconnections" value="24" />
			</cfinvoke>
			<!--- Create Table --->
			<cftry>
			<cfquery datasource="razuna_backup">
			CREATE TABLE backup_status 
			(
				back_id		VARCHAR(100), 
				back_date	timestamp,
				host_id		BIGINT
			) 
			</cfquery>
			<cfcatch type="database"></cfcatch>
			</cftry>
		</cfcatch>
	</cftry>
	<!--- Now put config values into application scope, but only if they differ or scope not exist --->
	<cfset application.razuna.thedatabase = qry.conf_database>
	<cfset application.razuna.datasource = qry.conf_datasource>
	<cfset application.razuna.theschema = qry.conf_schema>
	<cfset application.razuna.setid = qry.conf_setid>
	<cfset application.razuna.storage = qry.conf_storage>
	<cfset application.razuna.nvxappkey = qry.conf_nirvanix_appkey>
	<cfset application.razuna.nvxurlservices = qry.conf_nirvanix_url_services>
	<cfset application.razuna.awskey = qry.conf_aws_access_key>
	<cfset application.razuna.awskeysecret = qry.conf_aws_secret_access_key>
	<cfset application.razuna.awslocation = qry.conf_aws_location>
	<cfset application.razuna.isp = qry.conf_isp>
	<cfset application.razuna.firsttime = qry.conf_firsttime>
	<cfset application.razuna.renderingfarm = qry.conf_rendering_farm>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- PARSE THE DEFAULT CONFIGURATION --->
<cffunction name="getconfigdefaultapi" output="false">
	<!--- Query --->
	<cfquery datasource="razuna_default" name="qry">
	SELECT conf_database, conf_datasource, conf_setid, conf_storage, conf_nirvanix_appkey, conf_nirvanix_url_services,
	conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_rendering_farm
	FROM razuna_config
	</cfquery>
	<!--- Now put config values into application scope, but only if they differ or scope not exist --->
	<cfset application.razuna.api.thedatabase = qry.conf_database>
	<cfset application.razuna.api.dsn = qry.conf_datasource>
	<cfset application.razuna.api.setid = qry.conf_setid>
	<cfset application.razuna.api.storage = qry.conf_storage>
	<cfset application.razuna.api.nvxappkey = qry.conf_nirvanix_appkey>
	<cfset application.razuna.api.nvxurlservices = qry.conf_nirvanix_url_services>
	<cfset application.razuna.api.awskey = qry.conf_aws_access_key>
	<cfset application.razuna.api.awskeysecret = qry.conf_aws_secret_access_key>
	<cfset application.razuna.api.awslocation = qry.conf_aws_location>
	<cfset application.razuna.api.renderingfarm = qry.conf_rendering_farm>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- PARSE THE DEFAULT CONFIGURATION --->
<cffunction name="getconfigdefault" output="false">
	<!--- Query --->
	<cfquery datasource="razuna_default" name="qry">
	SELECT conf_database, conf_schema, conf_datasource, conf_setid, conf_storage, conf_nirvanix_appkey,
	conf_nirvanix_url_services, conf_isp, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_rendering_farm
	FROM razuna_config
	</cfquery>
	<!--- Now put config values into application scope, but only if they differ or scope not exist --->
	<cfset application.razuna.thedatabase = qry.conf_database>
	<cfset application.razuna.datasource = qry.conf_datasource>
	<cfset application.razuna.theschema = qry.conf_schema>
	<cfset application.razuna.setid = qry.conf_setid>
	<cfset application.razuna.storage = qry.conf_storage>
	<cfset application.razuna.nvxappkey = qry.conf_nirvanix_appkey>
	<cfset application.razuna.nvxurlservices = qry.conf_nirvanix_url_services>
	<cfset application.razuna.awskey = qry.conf_aws_access_key>
	<cfset application.razuna.awskeysecret = qry.conf_aws_secret_access_key>
	<cfset application.razuna.awslocation = qry.conf_aws_location>
	<cfset application.razuna.isp = qry.conf_isp>
	<cfset application.razuna.renderingfarm = qry.conf_rendering_farm>
</cffunction>

<!--- SEARCH TRANSLATION --->
<cffunction name="translationsearch" output="false" returntype="query">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT trans_id, trans_text, lang_id_r
	FROM #session.hostdbprefix#translations
	WHERE
	<cfif arguments.thestruct.trans_id IS NOT "">
		trans_id LIKE <cfqueryparam value="%#arguments.thestruct.trans_id#%" cfsqltype="cf_sql_varchar">
		<cfif arguments.thestruct.trans_text IS NOT "">
			OR
		</cfif>
	</cfif>
	<cfif arguments.thestruct.trans_text IS NOT "">
		lower(trans_text) LIKE <cfqueryparam value="%#lcase(arguments.thestruct.trans_text)#%" cfsqltype="cf_sql_varchar">
	</cfif>
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- DETAIL TRANSLATION --->
<cffunction name="translationdetail" output="false" returntype="query">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT trans_id, trans_text, lang_id_r
	FROM #session.hostdbprefix#translations
	WHERE
	lower(trans_id) LIKE <cfqueryparam value="#lcase(arguments.thestruct.trans_id)#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- UPDATE TRANSLATION --->
<cffunction name="translationupdate" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Now do the update --->
	<cfset count="">
	<cfset count2="">
	<cfloop delimiters="," index="myform" list="#arguments.thestruct.fieldnames#">
		<cfif #count# IS NOT "#myform#">
			<cfif #myform# CONTAINS "trans_lang_">
				<cfloop delimiters="," index="thenr" list="#arguments.thestruct.transid#">
				<cfset thefield=ReplaceNoCase(#myform#, "_#thenr#", "")>
					<cfif #myform# EQ "#thefield#_#thenr#">
				<!--- <cfoutput>#myform# - #thenr# - #thefield# = #form["#myform#"]#<br></cfoutput> --->
						<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#translations
						SET trans_text = <cfqueryparam value="#form["#myform#"]#" cfsqltype="CF_SQL_CHAR">, 
						trans_changed = <cfqueryparam value="T" cfsqltype="CF_SQL_CHAR">
						WHERE lang_id_r = <cfqueryparam value="#thenr#" cfsqltype="cf_sql_numeric">
						AND lower(trans_id) = <cfqueryparam value="#lcase(arguments.thestruct.trans_id)#" cfsqltype="cf_sql_varchar">
						</cfquery>
					</cfif>
				</cfloop>
			</cfif>
		<cfset count="#myform#">
		</cfif>
	</cfloop>
</cffunction>

<!--- ADD TRANSLATION --->
<cffunction name="translationadd" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Check for the same trans_id --->
	<cfquery datasource="#application.razuna.datasource#" name="thesame">
	SELECT trans_id
	FROM #session.hostdbprefix#translations
	WHERE 
	lower(trans_id) = <cfqueryparam value="#lcase(arguments.thestruct.trans_id)#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<!--- If all ok do the insert --->
	<cfif thesame.recordcount EQ 0>
		<cfset count="">
		<cfset count2="">
		<cfloop delimiters="," index="myform" list="#arguments.thestruct.fieldnames#">
			<cfif #count# IS NOT "#myform#">
				<cfif #myform# CONTAINS "trans_lang_">
					<cfloop delimiters="," index="thenr" list="#arguments.thestruct.transid#">
					<cfset thefield=ReplaceNoCase(#myform#, "_#thenr#", "")>
						<cfif #myform# EQ "#thefield#_#thenr#">
							<cfquery datasource="#application.razuna.datasource#">
							INSERT INTO #session.hostdbprefix#translations
							(trans_id, trans_text, lang_id_r)
							VALUES(
							<cfqueryparam value="#arguments.thestruct.trans_id#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#form["#myform#"]#" cfsqltype="CF_SQL_CHAR">,
							<cfqueryparam value="#thenr#" cfsqltype="cf_sql_numeric">
							)
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
			<cfset count="#myform#">
			</cfif>
		</cfloop>
	</cfif>
</cffunction>

<!--- REMOVE TRANSLATION --->
<cffunction name="translationremove" output="false">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#translations
	WHERE
	lower(trans_id) LIKE <cfqueryparam value="#lcase(arguments.thestruct.trans_id)#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn />
</cffunction>

<!--- PATH TO ASSETS --->
<cffunction name="assetpath" output="false" returntype="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qLocal" cachename="assetpath#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_path_to_assets
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(qLocal.set2_path_to_assets)>
</cffunction>

<!--- IMAGE: URL FOR THUMBNAIL --->
<cffunction hint="IMAGE: URL FOR THUMBNAIL" name="url_thumb" output="false" returntype="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#application.razuna.datasource#" name="qLocal" cachename="url_thumb#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_url_sp_thumb 
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(qLocal.set2_url_sp_thumb)>
</cffunction>

<!--- IMAGE: URL FOR COMPING --->
<cffunction hint="IMAGE: URL FOR COMPING" name="url_comp" output="false" returntype="string">
	<cfargument name="weblogin" default="F" required="no" type="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#application.razuna.datasource#" name="qLocal">
	SELECT set2_url_sp_comp<cfif #arguments.weblogin# EQ "T">_uw</cfif> thecomp
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(qLocal.thecomp)>
</cffunction>

<!--- IMAGE: URL FOR UNWATERMARKED COMPING --->
<cffunction hint="IMAGE: URL FOR UNWATERMARKED COMPING" name="url_compuw" output="false" returntype="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#application.razuna.datasource#" name="qLocal">
	SELECT set2_url_sp_comp_uw 
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(qLocal.set2_url_sp_comp_uw)>
</cffunction>

<!--- IMAGE: URL FOR ORIGINAL --->
<cffunction hint="IMAGE: URL FOR ORIGINAL" name="url_org" output="false" returntype="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#application.razuna.datasource#" name="qLocal">
	SELECT set2_url_sp_original 
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(qLocal.set2_url_sp_original)>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- INTRANET: SELECT IF CATEGORIES ARE SHOWN OR NOT, IF SO THEN SHOW THE TREE --->
<cffunction hint="INTRANET:SELECT IF CATEGORIES ARE SHOWN OR NOT, IF SO THEN SHOW THE TREE" name="cat_show" output="false" access="public" returntype="query">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#application.razuna.datasource#" name="qLocal">
		SELECT set2_cat_intra show, SET2_CAT_VID_INTRA showvid
		FROM #session.hostdbprefix#settings_2
		WHERE set2_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.setid#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qLocal />
</cffunction>

<!--- VIDEO: URL FOR PREVIEW IMAGE --->
<cffunction hint="VIDEO: URL FOR PREVIEW IMAGE" name="video_image" output="false" returntype="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#application.razuna.datasource#" name="qLocal">
	SELECT set2_url_sp_video_preview
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(qLocal.set2_url_sp_video_preview)>
</cffunction>

<!--- VIDEO: URL FOR VIDEO --->
<cffunction hint="VIDEO: URL FOR PREVIEW IDEO" name="video_stream" output="false" returntype="string">
	<!--- init internal vars --->
	<cfset var qLocal = 0>
	<cfquery datasource="#application.razuna.datasource#" name="qLocal">
	SELECT set2_url_sp_video
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn trim(qLocal.set2_url_sp_video)>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get HOST specific stuff --->
<cffunction hint="Get host specific stuff" name="hostinfo">
<cfquery datasource="#application.razuna.datasource#" name="host">
SELECT host_path
FROM hosts
WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
</cfquery>
<cfreturn host>
</cffunction>

<!--- APPLICATION CHECK --->
<cffunction name="applicationcheck" output="false">
	<!--- Params --->
	<cfset apps = structnew()>
	<cfset apps.im = "T"><!--- ImageMagick --->
	<cfset apps.ex = "T"><!--- Exiftool --->
	<cfset apps.ff = "T"><!--- FFmpeg --->
	<cfset apps.af = "T"><!--- Assets folder --->
	<cfset apps.wg = "T"><!--- wget --->
	<cfquery datasource="#application.razuna.datasource#" name="qrypathassets" cachename="applicationcheck#session.hostid#" cachedomain="#session.hostid#_settings2">
	SELECT set2_path_to_assets
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Get platform --->
	<cfinvoke component="global" method="iswindows" returnvariable="iswindows">
	<!--- Get tools --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- The executables --->
	<cfif isWindows>
		<cfset appim = """#arguments.thestruct.thetools.imagemagick#/convert.exe""">
		<cfset appex = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfset appff = """#arguments.thestruct.thetools.ffmpeg#/ffmpeg.exe""">
		<cfset appwg = """#arguments.thestruct.thetools.wget#/wget.exe""">
	<cfelse>
		<cfset appim = "#arguments.thestruct.thetools.imagemagick#/convert">
		<cfset appex = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset appff = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
		<cfset appwg = "#arguments.thestruct.thetools.wget#/wget">
	</cfif>
	<!--- Test imagemagick --->
	<cftry>
		<cfexecute name="#appim#" arguments="-version" timeout="5" />
		<cfcatch type="any">
			<cfset apps.im = "F">
		</cfcatch>
	</cftry>
	<!--- Test FFMpeg --->
	<cftry>
		<cfexecute name="#appff#" arguments="-version" timeout="5" />
		<cfcatch type="any">
			<cfset apps.ff = "F">
		</cfcatch>
	</cftry>
	<!--- Test Exiftool --->
	<cftry>
		<cfexecute name="#appex#" arguments="-version" timeout="5" />
		<cfcatch type="any">
			<cfset apps.ex = "F">
		</cfcatch>
	</cftry>
	<!--- Test Wget --->
	<cftry>
		<cfexecute name="#appwg#" arguments="-V" timeout="5" />
		<cfcatch type="any">
			<cfset apps.wg = "F">
		</cfcatch>
	</cftry>
	<!--- Test for existance of asset folder --->
	<cfif application.razuna.storage EQ "local">
		<cfif !directoryexists("#qrypathassets.set2_path_to_assets#")>
			<cfset apps.af = "F">
		</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn apps>
</cffunction>

<!--- PARSE NEWS --->
<cffunction name="news_get" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Query --->
	<cfquery datasource="razuna_default" name="qry" cachedwithin="#CreateTimeSpan(0,1,0,0)#">
	SELECT news_title, news_text, news_text_long, news_date
	FROM razuna_news
	WHERE news_show = true
	<cfif structkeyexists(arguments.thestruct,"frontpage")>
		AND news_frontpage = true
		ORDER BY news_date DESC
		LIMIT 1
	<cfelse>
		ORDER BY news_date DESC
		LIMIT 4
	</cfif>
	</cfquery>
	<!--- Return --->
	<cfreturn qry>
</cffunction>

<!--- Check paths for apps --->
<cffunction name="checkapp" output="true">
	<cfargument name="thestruct" type="Struct">
	<!--- Get platform --->
	<cfinvoke component="global" method="iswindows" returnvariable="iswindows">
	<!--- If ImageMagick we change theapp to convert --->
	<cfif arguments.thestruct.theapp EQ "imagemagick">
		<cfset arguments.thestruct.theapp = "convert">
	</cfif>
	<!--- The executables --->
	<cfif isWindows>
		<cfset thisapp = "#arguments.thestruct.thepath#/#arguments.thestruct.theapp#.exe">
		<!--- Convert the slash to windows --->
		<cfset thisapp = replacenocase(thisapp,"\","/","all")>
	<cfelse>
		<cfset thisapp = "#arguments.thestruct.thepath#/#arguments.thestruct.theapp#">
	</cfif>
	<!--- Check if the app is there --->
	<cfif fileexists("#thisapp#")>
		<cfoutput><span style="color:green;">Executable exists. You are good to go!</span></cfoutput>
	<cfelse>
		<cfoutput><span style="color:red;">Executable does not exists. Please check path!</span></cfoutput>
	</cfif>
</cffunction>

<!--- Set default DB for firsttime to false --->
<cffunction name="firsttime_false" output="false">
	<cfargument name="theboolean" type="boolean">
	<cfquery datasource="razuna_default">
	UPDATE razuna_config
	SET conf_firsttime = #arguments.theboolean#
	</cfquery>
	<cfreturn />
</cffunction>

<!--- Get Backup DB --->
<cffunction name="get_backup" output="false">
	<cfargument name="hostid" type="numeric">
	<cfquery datasource="razuna_backup" name="qry">
	SELECT back_id, back_date, host_id
	FROM backup_status
	WHERE host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.hostid#">
	ORDER BY back_date DESC
	</cfquery>
	<cfreturn qry />
</cffunction>

<!--- Drop Backup Schema --->
<cffunction name="drop_backup" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Drop schema --->
	<cfquery datasource="razuna_backup">
	DROP SCHEMA #arguments.thestruct.id#
	</cfquery>
	<!--- Drop from backup status --->
	<cfquery datasource="razuna_backup">
	DELETE FROM backup_status
	WHERE back_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
	</cfquery>
	<cfreturn />
</cffunction>

</cfcomponent>