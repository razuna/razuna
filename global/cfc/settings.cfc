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

<!--- Get the cachetoken for here --->
<cfif structKeyExists(session, "hostid")>
	<cfset variables.cachetoken = getcachetoken("settings")>
<cfelse>
	<cfset variables.cachetoken = createuuid()>
</cfif>

<!--- Get all languages for this host for the Settings --->
<cffunction name="allsettings">
	<cfquery datasource="#application.razuna.datasource#" name="set">
	SELECT set_id, set_pref
	FROM #session.hostdbprefix#settings
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn set>
</cffunction>

<!--- Get md5check value --->
<cffunction name="getmd5check">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getmd5check */ set2_md5check
	FROM #session.hostdbprefix#settings_2
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry.set2_md5check>
</cffunction>

<!--- Get all settings for this host --->
<cffunction name="allsettings_2">
	<cfquery datasource="#application.razuna.datasource#" name="set2" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#allsettings_2 */ set2_id, set2_date_format, set2_date_format_del, set2_meta_author, set2_meta_publisher, set2_meta_copyright, 
	set2_meta_robots, set2_meta_revisit, set2_url_sp_original, set2_url_sp_thumb, set2_url_sp_comp, set2_url_sp_comp_uw, 
	set2_url_app_server, set2_create_imgfolders_where, set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, 
	set2_img_comp_width, set2_img_comp_heigth, set2_img_download_org, set2_doc_download, set2_intranet_reg_emails, 
	set2_intranet_reg_emails_sub, set2_intranet_gen_download, set2_cat_intra, set2_cat_web, set2_url_website, 
	set2_payment_pre, set2_payment_bill, set2_payment_pod, set2_payment_cc, set2_payment_cc_cards, set2_payment_paypal, 
	set2_email_server, set2_email_from, set2_email_smtp_user, set2_email_smtp_password, 
	set2_email_server_port,
	<!--- set2_vid_preview_width, set2_vid_preview_heigth, set2_vid_preview_time, set2_vid_preview_start, ---> 
	set2_url_sp_video_preview, set2_vid_preview_author, set2_vid_preview_copyright, set2_cat_vid_web, set2_cat_vid_intra,
	set2_create_vidfolders_where, set2_path_to_assets, set2_aws_bucket, set2_aka_url, set2_aka_img, set2_aka_vid, set2_aka_aud, set2_aka_doc
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn set2>
</cffunction>

<!--- Get settings from within DAM --->
<cffunction name="getsettingsfromdam" returntype="query">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getsettingsfromdam */ set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, set2_date_format, set2_date_format_del, set2_intranet_reg_emails, set2_intranet_reg_emails_sub, set2_md5check, set2_email_from, set2_colorspace_rgb
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Set settings from within DAM --->
<cffunction name="setsettingsfromdam" returntype="void">
	<cfargument name="thestruct" type="Struct">
	<!--- Update --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#settings_2
	SET
	set2_img_format = <cfqueryparam value="#arguments.thestruct.set2_img_format#" cfsqltype="cf_sql_varchar">,
	set2_img_thumb_width = <cfqueryparam value="#arguments.thestruct.set2_img_thumb_width#" cfsqltype="cf_sql_numeric">,
	set2_img_thumb_heigth = <cfqueryparam value="#arguments.thestruct.set2_img_thumb_heigth#" cfsqltype="cf_sql_numeric">,
	set2_date_format = <cfqueryparam value="#arguments.thestruct.set2_date_format#" cfsqltype="cf_sql_varchar">,
	set2_date_format_del = <cfqueryparam value="#arguments.thestruct.set2_date_format_del#" cfsqltype="cf_sql_varchar">,
	set2_intranet_reg_emails = <cfqueryparam value="#arguments.thestruct.set2_intranet_reg_emails#" cfsqltype="cf_sql_varchar">,
	set2_intranet_reg_emails_sub = <cfqueryparam value="#arguments.thestruct.set2_intranet_reg_emails_sub#" cfsqltype="cf_sql_varchar">,
	set2_md5check = <cfqueryparam value="#arguments.thestruct.set2_md5check#" cfsqltype="cf_sql_varchar">,
	set2_email_from = <cfqueryparam value="#arguments.thestruct.set2_email_from#" cfsqltype="cf_sql_varchar">,
	set2_colorspace_rgb = <cfqueryparam value="#arguments.thestruct.set2_colorspace_rgb#" cfsqltype="cf_sql_varchar">
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush --->
	<cfset variables.cachetoken = resetcachetoken("settings")>
</cffunction>

<!--- Settings for Globals Preferences --->
<cffunction name="prefs_global">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_global */ SET2_DATE_FORMAT, SET2_DATE_FORMAT_DEL, SET2_EMAIL_SERVER, SET2_EMAIL_FROM, SET2_EMAIL_SMTP_USER, 
	SET2_EMAIL_SMTP_PASSWORD, SET2_EMAIL_SERVER_PORT
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for Meta --->
<cffunction name="prefs_meta">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_meta */ set2_meta_author, set2_meta_publisher, set2_meta_copyright, set2_meta_robots, set2_meta_revisit
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for DAM --->
<cffunction name="prefs_dam">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_dam */ set2_intranet_gen_download, set2_doc_download, set2_img_download_org, set2_intranet_reg_emails, 
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
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_web */ set2_url_website, set2_payment_cc, set2_payment_cc_cards, set2_payment_bill, set2_payment_pod, set2_payment_pre, set2_payment_paypal
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for Image --->
<cffunction name="prefs_image">
	<cfset var qry = "">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_image */ set2_create_imgfolders_where, set2_cat_intra, set2_cat_web, 
	set2_img_format, set2_img_thumb_width, set2_img_thumb_heigth, set2_img_comp_width, set2_img_comp_heigth,
	set2_colorspace_rgb
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
		</cfif>
	</cfloop>
	<cfreturn qry>
</cffunction>

<!--- Settings for Video --->
<cffunction name="prefs_video">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_video */ set2_create_vidfolders_where, set2_cat_vid_intra, set2_cat_vid_web, <!--- set2_vid_preview_width, set2_vid_preview_heigth, set2_vid_preview_time, set2_vid_preview_start, ---> set2_vid_preview_author, set2_vid_preview_copyright
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
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_oracle */ set2_url_app_server, set2_ora_path_internal, set2_url_sp_original, set2_url_sp_thumb, set2_url_sp_comp, set2_url_sp_comp_uw, set2_url_sp_video, set2_url_sp_video_preview, set2_ora_path_incoming, set2_ora_path_incoming_batch, set2_ora_path_outgoing
	FROM #session.hostdbprefix#settings_2
	WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Settings for Storage --->
<cffunction name="prefs_storage">
	<cfset variables.cachetoken = getcachetoken("settings")>
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#prefs_storage */ 
	set2_nirvanix_name, set2_nirvanix_pass, set2_aws_bucket, 
	set2_aka_url, set2_aka_img, set2_aka_vid, set2_aka_aud, set2_aka_doc
	FROM #session.hostdbprefix#settings_2
	WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
	<cfreturn />
</cffunction>

<!--- Remove File Type --->
<cffunction name="prefs_types_del">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM file_types
	WHERE lower(type_id) = <cfqueryparam value="#lcase(arguments.thestruct.type_id)#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn />
</cffunction>

<!--- Update File Type --->
<cffunction name="prefs_types_update">
	<cfargument name="thestruct" type="Struct">
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE file_types
	SET
	type_id = <cfqueryparam value="#lcase(arguments.thestruct.type_id)#" cfsqltype="cf_sql_varchar">,
	type_type = <cfqueryparam value="#lcase(arguments.thestruct.type_type)#" cfsqltype="cf_sql_varchar">,
	type_mimecontent = <cfqueryparam value="#lcase(arguments.thestruct.type_mimecontent)#" cfsqltype="cf_sql_varchar">, 
	type_mimesubcontent = <cfqueryparam value="#lcase(arguments.thestruct.type_mimesubcontent)#" cfsqltype="cf_sql_varchar">
	WHERE lower(type_id) = <cfqueryparam value="#lcase(arguments.thestruct.type_id)#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn />
</cffunction>

<!--- Languages: Get Languages --->
<cffunction name="lang_get">
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#lang_get */ lang_id, lang_name, lang_active
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
	<cfdirectory action="list" directory="#arguments.thestruct.thepath#/global/translations" name="thelangs" />
	<cfquery dbtype="query" name="thelangs">
	SELECT *
	FROM thelangs where TYPE = 'Dir' and name != 'Custom'
	ORDER BY name
	</cfquery>
	<!--- Loop over languages --->
	<cfloop query="thelangs">
		<!--- Get name and language id --->
		<cfset thislang = thelangs.name>
		<!--- If we come from admin then take another method --->
		<cfif structkeyexists(arguments.thestruct,"fromadmin")>
			<cfinvoke component="defaults" method="propertiesfilelangid" thetransfile="#arguments.thestruct.thepath#/global/translations/#name#/HomePage.properties" returnvariable="langid">
		<cfelse>
			<cfinvoke component="defaults" method="trans" transid="thisid" thetransfile="#name#" returnvariable="langid">
		</cfif>
		<!--- Check for existing record --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#lang_get_langs */ lang_id, lang_name
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
			<cfset variables.cachetoken = resetcachetoken("settings")>
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
			<cfset variables.cachetoken = resetcachetoken("settings")>
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
	<cfset variables.cachetoken = resetcachetoken("settings")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Labels: get --->
<cffunction name="get_label_set">
	<!--- Set the active field to f on all languages --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#get_label_set */ set2_labels_users
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
	<cfset variables.cachetoken = resetcachetoken("settings")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- GET GLOBAL Settings --->
<cffunction name="get_global" access="remote" returnType="query">
	<!--- Select --->
	<cfquery datasource="razuna_default" name="qry" region="razcache" cachedwithin="1">
	SELECT /* #variables.cachetoken#get_global */ 
	conf_database, conf_schema, conf_datasource, conf_storage, conf_nirvanix_appkey, conf_nirvanix_master_name, conf_aka_token,
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
	<cfparam default="" name="qry.mp4box">
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
	<cfif StructKeyExists(#arguments.thestruct#, "conf_aka_token")>
		<cfif commad EQ "T">,</cfif>conf_aka_token = <cfqueryparam value="#arguments.thestruct.conf_aka_token#" cfsqltype="cf_sql_varchar">
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
	<cfif StructKeyExists(arguments.thestruct, "conf_rendering_farm")>
		<cfset application.razuna.rfs = arguments.thestruct.conf_rendering_farm>
	</cfif>
	<!--- Akamai --->
	<cfif StructKeyExists(arguments.thestruct, "conf_aka_token")>
		<cfset application.razuna.akatoken = arguments.thestruct.conf_aka_token>
	</cfif>
	<!--- Save in global setting the rendering farm location --->
	<cfif StructKeyExists(arguments.thestruct, "rendering_farm_location")>
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
	<!--- Save in global setting the rendering farm server --->
	<cfif StructKeyExists(arguments.thestruct, "rendering_farm_server")>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#settings
		WHERE lower(set_id) = <cfqueryparam value="rendering_farm_server" cfsqltype="cf_sql_varchar">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#settings
		(set_pref, set_id, host_id, rec_uuid)
		VALUES(
		<cfqueryparam value="#arguments.thestruct.rendering_farm_server#" cfsqltype="cf_sql_varchar">,
		<cfqueryparam value="rendering_farm_server" cfsqltype="cf_sql_varchar">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
		)
		</cfquery>
	</cfif>
	<!--- Reset cache --->
	<cfset variables.cachetoken = resetcachetoken("settings")>
</cffunction>

<!--- Update TOOLS --->
<cffunction name="update_tools">
	<cfargument name="thestruct" type="Struct">
	<!--- Update Tools --->
	<cfloop collection="#arguments.thestruct#" item="myform">
		<cfif myform CONTAINS "imagemagick" OR myform CONTAINS "exiftool" OR myform CONTAINS "ffmpeg" OR myform CONTAINS "dcraw" OR myform CONTAINS "mp4box">
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
		<cfif StructKeyExists(#arguments.thestruct#, "set2_aka_url")>
			<cfif commad EQ "T">,</cfif>set2_aka_url = <cfqueryparam value="#lcase(arguments.thestruct.set2_aka_url)#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_aka_img")>
			<cfif commad EQ "T">,</cfif>set2_aka_img = <cfqueryparam value="#lcase(arguments.thestruct.set2_aka_img)#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_aka_vid")>
			<cfif commad EQ "T">,</cfif>set2_aka_vid = <cfqueryparam value="#lcase(arguments.thestruct.set2_aka_vid)#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_aka_aud")>
			<cfif commad EQ "T">,</cfif>set2_aka_aud = <cfqueryparam value="#lcase(arguments.thestruct.set2_aka_aud)#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		<cfif StructKeyExists(#arguments.thestruct#, "set2_aka_doc")>
			<cfif commad EQ "T">,</cfif>set2_aka_doc = <cfqueryparam value="#lcase(arguments.thestruct.set2_aka_doc)#" cfsqltype="cf_sql_varchar">
			<cfset commad = "T">
		</cfif>
		WHERE set2_id = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<!--- Flush --->
	<cfset variables.cachetoken = resetcachetoken("settings")>
</cffunction>

<!--- FUNCTION: UPLOAD --->
<cffunction hint="Upload" name="upload" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.loginimg" default="false" />
	<cfparam name="arguments.thestruct.favicon" default="false" />
	<!--- Logo or favicon or loginimg --->
	<cfif !arguments.thestruct.loginimg AND !arguments.thestruct.favicon>
		<cfset var theimgpath = "logo">
	<cfelseif arguments.thestruct.loginimg AND !arguments.thestruct.favicon>
		<cfset var theimgpath = "login">
	<cfelse>
		<cfset var theimgpath = "favicon">
		<!--- just remove any previous directory (like this we prevent having more the one image) --->
		<cfif directoryExists("#arguments.thestruct.thepathup#/global/host/#theimgpath#/#session.hostid#")>
			<cfdirectory action="delete" directory="#arguments.thestruct.thepathup#global/host/#theimgpath#/#session.hostid#" recurse="true" />
		</cfif>
	</cfif>
	<!--- Create directory if not there already to hold this logo --->
	<cfif !directoryexists("#arguments.thestruct.thepathup#global/host/#theimgpath#/#session.hostid#")>
		<cfdirectory action="create" directory="#arguments.thestruct.thepathup#global/host/#theimgpath#/#session.hostid#" mode="775">
	</cfif>
	<!---  Upload file --->
	<cffile action="UPLOAD" filefield="#arguments.thestruct.thefield#" destination="#arguments.thestruct.thepathup#global/host/#theimgpath#/#session.hostid#" result="result" nameconflict="overwrite" mode="775">
	<!--- Set variables that show the file in the GUI --->
	<cfset this.thefilename = result.serverFileName>
	<!--- Get Size --->
	<cfinvoke component="global" method="converttomb" thesize="#result.filesize#" returnvariable="thesize">
	<cfset this.thesize = thesize>
	<!--- Return --->
	<cfreturn this />
</cffunction>

<!--- FUNCTION: UPLOAD WATERMARK --->
<cffunction name="upload_watermark" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Param --->
	<cfset var s = structNew()>
	<!--- just remove any previous directory (like this we prevent having more the one image) --->
	<cftry>
		<cfdirectory action="delete" directory="#arguments.thestruct.thepathup#global/host/watermark/#session.hostid#/#arguments.thestruct.wm_temp_id#" recurse="true" />
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!--- Create directory if not there already to hold this logo --->
	<cftry>
		<cfdirectory action="create" directory="#arguments.thestruct.thepathup#global/host/watermark/#session.hostid#/#arguments.thestruct.wm_temp_id#" mode="775">
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!---  Upload file --->
	<cffile action="UPLOAD" filefield="#arguments.thestruct.thefield#" destination="#arguments.thestruct.thepathup#global/host/watermark/#session.hostid#/#arguments.thestruct.wm_temp_id#" result="result" nameconflict="overwrite" mode="775">
	<!--- Create var --->
	<cfset s.fordbpath = "#arguments.thestruct.wm_temp_id#/#result.serverFile#">
	<cfset s.imgpath = "global/host/watermark/#session.hostid#/#arguments.thestruct.wm_temp_id#/#result.serverFile#">
	<!--- Return --->
	<cfreturn s />
</cffunction>

<!--- Folder Thumbnail --->
<cffunction hint="Upload folder Thumbnail" name="Upload_folderThumbnail" access="public" output="false">
	<cfargument name="thestruct" type="Struct">
	<!--- Check that vars are not empty --->
	<cfif arguments.thestruct.thumb_folder_file NEQ "" OR arguments.thestruct.thumb_folder NEQ "">
		<!--- Create directory if not there already to hold this folderthumbnail --->
		<cfif !directoryexists("#arguments.thestruct.thepathup#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#")>
			<cfdirectory action="create" directory="#arguments.thestruct.thepathup#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#/">
		</cfif>
		<cfdirectory name="myDir" action="list" directory="#ExpandPath("../../")#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#/" type="file">
		<cfif myDir.recordcount>
			<cffile action="delete" file="#arguments.thestruct.thepathup#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#/#myDir.name#">
		</cfif>
		<!--- If we choose a thumbnail from the list --->
		<cfif arguments.thestruct.thumb_folder_file eq "">
			<!--- Get extension --->
			<cfset var img_ext = listLast(arguments.thestruct.thumb_folder,'.')> 
			<!--- Set vars --->
			<cfif application.razuna.storage EQ "local" OR application.razuna.storage EQ "akamai">
				<!--- Set http --->
				<cfset var thehttp = "#session.thehttp##cgi.http_host##arguments.thestruct.thumb_folder#">
			<cfelse>
				<!--- Set http --->
				<cfset var thehttp = arguments.thestruct.thumb_folder>
			</cfif>
			<!--- Get the thumbnail --->
			<cfhttp url="#thehttp#" method="get" path="#arguments.thestruct.thepathup#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#" file="#arguments.thestruct.folderId#.#img_ext#" />
			<!--- Set filename --->
			<cfset this.thefilename = "#arguments.thestruct.folderId#.#img_ext#">
		</cfif>
		<!--- If the user uploads an image --->
		<cfif arguments.thestruct.thumb_folder_file neq "">
			<!--- Upload --->
			<cffile action="upload" destination="#arguments.thestruct.thepathup#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#/" filefield="thumb_folder_file" result="result">
			<!--- Rename --->
			<cffile action="rename" destination="#arguments.thestruct.thepathup#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#/#arguments.thestruct.folderId#.#result.serverfileext#" source="#arguments.thestruct.thepathup#global/host/folderthumbnail/#session.hostid#/#arguments.thestruct.folderId#/#result.serverFile#" >
			<!--- Set filename --->
			<cfset this.thefilename = "#arguments.thestruct.folderId#.#result.serverfileext#">
		</cfif>
		<!--- Return --->
		<cfreturn this />	
	</cfif>
</cffunction>

<!--- Delete folder thumbnail --->
<cffunction name="folderthumbnail_reset" access="public" output="false" returntype="void">
	<cfargument name="folder_id" type="string">
	<cfdirectory action="delete" directory="#expandPath("../../")#global/host/folderthumbnail/#session.hostid#/#arguments.folder_id#" recurse="true" />
</cffunction>

<!--- Get API key --->
<cffunction name="getapikey" output="false" returntype="string">
	<cfargument name="reset" required="false" default="false">
	<!--- If we need to reset the key then save first --->
	<cfif arguments.reset EQ "true">
		<cfset var tkey = createuuid("")>
		<cfinvoke method="savesetting" thefield="api_key" thevalue="#tkey#" />
	</cfif>
	<!--- See if value is there --->
	<cfinvoke method="thissetting" thefield="api_key" returnVariable="key" />
	<!--- If key is empty --->
	<cfif key EQ "">
		<cfset var key = createuuid("")>
		<cfinvoke method="savesetting" thefield="api_key" thevalue="#key#" />
	</cfif>
	<!--- Return --->
	<cfreturn key />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Get specific setting --->
<cffunction hint="Get specific setting" name="thissetting" output="false" returntype="string">
	<cfargument name="thefield" type="string" default="" required="yes">
	<cfquery datasource="#application.razuna.datasource#" name="sett">
	SELECT set_pref
	FROM #session.hostdbprefix#settings
	WHERE lower(set_id) = <cfqueryparam value="#lcase(arguments.thefield)#" cfsqltype="cf_sql_varchar">
	<cfif arguments.thefield EQ "rendering_farm_server">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
	<cfelse>
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfif>
	</cfquery>
	<cfreturn trim(sett.set_pref)>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- Save global settings --->
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
<!--- <cffunction name="getconfig" output="false" returntype="string" hint="PARSE THE CONFIG FILE OF THE ADMIN SECTION">
<cfargument name="thenode" default="" required="yes" type="string" hint="the nodename which you want to parse">
<cfinvoke component="defaults" method="getAbsolutePath" returnvariable="xmlFile">
	<cfinvokeargument name="pathSourceAbsolute" value="#GetCurrentTemplatePath()#">
	<cfinvokeargument name="pathTargetRelative" value="../config/config.xml">
</cfinvoke>
<cffile action="read" file="#xmlFile#" variable="myVar" charset="utf-8">
<cfset xmlVar=xmlParse(myVar)/>
<cfset theconfig=xmlSearch(xmlVar, "configuration/configid[@name='#arguments.thenode#']")>
<cfreturn trim(#theconfig[1].thetext.xmlText#)>
</cffunction> --->
<cffunction name="getconfig" output="false" returntype="string" hint="PARSE THE CONFIG FILE OF THE ADMIN SECTION">
<cfargument name="thenode" default="" required="yes" type="string" hint="the nodename which you want to parse">
<cfinvoke component="defaults" method="getAbsolutePath" returnvariable="xmlFile">
	<cfinvokeargument name="pathSourceAbsolute" value="#GetCurrentTemplatePath()#">
	<cfinvokeargument name="pathTargetRelative" value="../config/config.cfm">
</cfinvoke>
<!--- Return --->
<cfreturn trim(getProfileString(xmlFile, "default", arguments.thenode))>
</cffunction>

<!--- Set the value in the config file --->
<cffunction name="setconfig" output="false" returntype="void">
<cfargument name="thenode" default="" required="yes" type="string">
<cfargument name="thevalue" default="" required="yes" type="string">
<cfinvoke component="defaults" method="getAbsolutePath" returnvariable="xmlFile">
	<cfinvokeargument name="pathSourceAbsolute" value="#GetCurrentTemplatePath()#">
	<cfinvokeargument name="pathTargetRelative" value="../config/config.cfm">
</cfinvoke>
<!--- Update string --->
<cfset setProfileString(xmlFile, "default", arguments.thenode, arguments.thevalue)>
<!--- Return --->
<cfreturn />
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- PARSE THE DEFAULT CONFIGURATION --->
<cffunction name="getconfigdefaultadmin" output="false">
	<cfargument name="pathoneup" default="" required="yes" type="string">
	<!--- Check DB --->
	<cftry>
		<cfquery datasource="razuna_default" name="qry">
		SELECT conf_database, conf_schema, conf_datasource, conf_setid, conf_storage, conf_nirvanix_appkey,
		conf_nirvanix_url_services, conf_isp, conf_firsttime, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, 
		conf_rendering_farm, conf_serverid, conf_wl, conf_aka_token
		FROM razuna_config
		</cfquery>
		<cfcatch type="database">
			<!--- This is not needed anymore for post 1.6 installations --->
			<cfif structkeyexists(cfcatch,"nativeerrorcode") AND cfcatch.nativeerrorcode EQ 42122>
				<cftry>
					<cfquery datasource="razuna_default">
					alter table razuna_config add conf_wl BOOLEAN DEFAULT false
					</cfquery>
					<cfcatch type="database"></cfcatch>
				</cftry>
				<cftry>
					<cfquery datasource="razuna_default">
					alter table razuna_config add conf_aka_token varchar(200)
					</cfquery>
					<cfcatch type="database"></cfcatch>
				</cftry>
			<cfelse>
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
					conf_rendering_farm			BOOLEAN,
					conf_serverid				VARCHAR(100),
					conf_wl 					BOOLEAN DEFAULT false,
					conf_aka_token				VARCHAR(200) DEFAULT ''
				)
				</cfquery>
				<!--- Insert values --->
				<cfquery datasource="razuna_default">
				INSERT INTO razuna_config
				(conf_database, conf_schema, conf_datasource, conf_setid, conf_storage,
				conf_nirvanix_url_services, conf_isp, conf_firsttime, conf_rendering_farm, conf_serverid, conf_wl)
				VALUES(
				'h2',
				'razuna',
				'h2',
				'1',
				'local',
				'http://services.nirvanix.com',
				'false',
				true,
				false,
				'#createuuid()#',
				false
				)
				</cfquery>
				<!--- Query again --->
				<cfquery datasource="razuna_default" name="qry">
				SELECT conf_database, conf_schema, conf_datasource, conf_setid, conf_storage, conf_nirvanix_appkey,
				conf_nirvanix_url_services, conf_isp, conf_firsttime, conf_aws_access_key, conf_aws_secret_access_key, 
				conf_aws_location, conf_rendering_farm, conf_serverid, conf_wl, conf_aka_token
				FROM razuna_config
				</cfquery>
			</cfif>
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
	<!--- Check for empty serverid --->
	<cfif qry.conf_serverid EQ "">
		<cfset var theid = createuuid()>
		<!--- Update --->
		<cfquery datasource="razuna_default">
		UPDATE razuna_config
		SET conf_serverid = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
		</cfquery>
		<!--- Set the ID into application scope --->
		<cfset application.razuna.serverid = theid>
	</cfif>
	<!--- Check for config file --->
	<cfif fileExists("#arguments.pathoneup#/global/config/keys.cfm")>
		<!--- Set path --->
 		<cfset var iniFile = "#arguments.pathoneup#/global/config/keys.cfm">
 		<!--- Set WL --->
 		<cfif getProfileString(iniFile, "default", "wl") EQ 13201283703>
 			<cfset QuerySetCell(qry, "conf_wl", true)>
 			<cfset var swl = true>
		<cfelse>
			<cfset QuerySetCell(qry, "conf_wl", false)>
			<cfset var swl = false>
 		</cfif>
 		<!--- Update --->
		<cfquery datasource="razuna_default">
		UPDATE razuna_config
		SET conf_wl = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#swl#">
		</cfquery>
	</cfif>
	<!--- Now put config values into application scope --->
	<cfset application.razuna.serverid = qry.conf_serverid>
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
	<cfset application.razuna.rfs = qry.conf_rendering_farm>
	<cfset application.razuna.s3ds = AmazonRegisterDataSource("aws",qry.conf_aws_access_key,qry.conf_aws_secret_access_key,qry.conf_aws_location)>
	<cfset application.razuna.whitelabel = qry.conf_wl>
	<cfset application.razuna.akatoken = qry.conf_aka_token>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- PARSE THE DEFAULT CONFIGURATION --->
<cffunction name="getconfigdefaultapi" output="false">
	<!--- Query --->
	<cfquery datasource="razuna_default" name="qry">
	SELECT conf_database, conf_datasource, conf_setid, conf_storage, 
	conf_nirvanix_appkey, conf_nirvanix_url_services, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, 
	conf_rendering_farm, conf_isp, conf_aka_token
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
	<cfset application.razuna.api.rfs = qry.conf_rendering_farm>
	<cfset application.razuna.api.isp = qry.conf_isp>
	<cfset application.razuna.api.akatoken = qry.conf_aka_token>
</cffunction>

<!--- ------------------------------------------------------------------------------------- --->
<!--- PARSE THE DEFAULT CONFIGURATION --->
<cffunction name="getconfigdefault" output="false">
	<!--- Query --->
	<cfquery datasource="razuna_default" name="qry">
	SELECT conf_database, conf_schema, conf_datasource, conf_setid, conf_storage, conf_nirvanix_appkey, conf_aka_token,
	conf_nirvanix_url_services, conf_isp, conf_aws_access_key, conf_aws_secret_access_key, conf_aws_location, conf_rendering_farm, conf_wl
	FROM razuna_config
	</cfquery>
	<!--- Now put config values into application scope --->
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
	<cfset application.razuna.rfs = qry.conf_rendering_farm>
	<cfset application.razuna.s3ds = AmazonRegisterDataSource("aws",qry.conf_aws_access_key,qry.conf_aws_secret_access_key,qry.conf_aws_location)>
	<cfset application.razuna.whitelabel = qry.conf_wl>
	<cfset application.razuna.dynpath = cgi.context_path>
	<cfset application.razuna.akatoken = qry.conf_aka_token>
	<cfset application.razuna.dropbox.url_oauth = "https://www.dropbox.com/1">
	<cfset application.razuna.dropbox.url_api = "https://api.dropbox.com/1">
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
	<cfquery datasource="#application.razuna.datasource#" name="qLocal" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#assetpath */ set2_path_to_assets
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
	<cfquery datasource="#application.razuna.datasource#" name="qLocal">
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
	<cfquery datasource="#application.razuna.datasource#" name="qrypathassets" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#applicationcheck */ set2_path_to_assets
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
	<cfelse>
		<cfset appim = "#arguments.thestruct.thetools.imagemagick#/convert">
		<cfset appex = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset appff = "#arguments.thestruct.thetools.ffmpeg#/ffmpeg">
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
	<cfquery datasource="razuna_default" name="qry" cachedwithin="#CreateTimeSpan(0,0,30,0)#">
	SELECT news_title, news_text, news_text_long, news_date
	FROM razuna_news
	WHERE news_show = true
	<cfif structkeyexists(arguments.thestruct,"frontpage")>
		AND news_frontpage = true
		ORDER BY news_date DESC
		LIMIT 1
	<cfelse>
		ORDER BY news_date DESC
		LIMIT 7
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
	<!--- Reset cache --->
	<cfset variables.cachetoken = resetcachetoken("settings")>
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

<!--- Read custom file and store in application scope --->
<cffunction name="readcustom" output="false">
	<!--- Set the application custom scope so it exists --->
	<cfset application.razuna.custom.enabled = false>
	<!--- path to file --->
	<cfset var conffile = expandpath("../..") & "global/config/customization.cfm">
	<!--- Check if a file exsists --->
	<cfif fileexists(conffile)>
		<!--- Params --->
		<cfset var data = structNew()>
		<!--- get sections --->
		<cfset var sections = getProfileSections(conffile)>
		<!--- Parse each section and add to application scope --->
		<cfif structKeyExists(sections, "folderview")>
			<cfloop index="key" list="#sections.folderview#">
		    	<cfset data[key] = getProfileString(conffile, "folderview", key)>
		  	</cfloop>
		  	<cfset application.razuna.custom = data>
		</cfif>
		<cfif structKeyExists(sections, "assetview")>
			<cfloop index="key" list="#sections.assetview#">
		    	<cfset data[key] = getProfileString(conffile, "assetview", key)>
		  	</cfloop>
		  	<cfset application.razuna.custom = data>
		</cfif>
		<cfif structKeyExists(sections, "explorer")>
			<cfloop index="key" list="#sections.explorer#">
		    	<cfset data[key] = getProfileString(conffile, "explorer", key)>
		  	</cfloop>
		  	<cfset application.razuna.custom = data>
		</cfif>
		<cfif structKeyExists(sections, "upload")>
			<cfloop index="key" list="#sections.upload#">
		    	<cfset data[key] = getProfileString(conffile, "upload", key)>
		  	</cfloop>
		  	<cfset application.razuna.custom = data>
		</cfif>
		<cfif structKeyExists(sections, "design")>
			<cfloop index="key" list="#sections.design#">
		    	<cfset data[key] = getProfileString(conffile, "design", key)>
		  	</cfloop>
		  	<cfset application.razuna.custom = data>
		</cfif>
		<cfif structKeyExists(sections, "general")>
			<cfloop index="key" list="#sections.general#">
		    	<cfset data[key] = getProfileString(conffile, "general", key)>
		  	</cfloop>
		  	<cfset application.razuna.custom = data>
		</cfif>
		<cfset application.razuna.custom.enabled = true>
	</cfif>
</cffunction>

<!--- get tenant customization --->
<cffunction name="get_customization" output="false" returnType="struct">
	<!--- Params --->
	<cfset var qry = "">
	<!--- Query db --->
	<cfquery dataSource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#get_customization */ custom_id, custom_value
	FROM #session.hostdbprefix#custom
	WHERE host_id = <cfqueryparam value="#session.hostid#" CFSQLType="CF_SQL_NUMERIC">
	</cfquery>
	<!--- Set value here --->
	<cfset var v = structnew()>
	<cfset v.folder_redirect = "0">
	<cfset v.myfolder_create = true>
	<cfset v.myfolder_upload = true>
	<cfset v.show_top_part = true>
	<cfset v.show_bottom_part = true>
	<cfset v.show_twitter = true>
	<cfset v.tab_twitter = true>
	<cfset v.show_facebook = true>
	<cfset v.tab_facebook = true>
	<cfset v.tab_razuna_blog = true>
	<cfset v.tab_razuna_support = true>
	<cfset v.tab_collections = true>
	<cfset v.tab_labels = true>
	<cfset v.tab_add_from_server = true>
	<cfset v.tab_add_from_email = true>
	<cfset v.tab_add_from_ftp = true>
	<cfset v.tab_add_from_link = true>
	<cfset v.tab_images = true>
	<cfset v.tab_videos = true>
	<cfset v.tab_audios = true>
	<cfset v.tab_other = true>
	<cfset v.tab_pdf = true>
	<cfset v.tab_doc = true>
	<cfset v.tab_xls = true>
	<cfset v.icon_select = true>
	<cfset v.icon_refresh = true>
	<cfset v.icon_show_subfolder = true>
	<cfset v.icon_create_subfolder = true>
	<cfset v.icon_favorite_folder = true>
	<cfset v.icon_search = true>
	<cfset v.icon_print = true>
	<cfset v.icon_rss = true>
	<cfset v.icon_word = true>
	<cfset v.icon_metadata_import = true>
	<cfset v.icon_metadata_export = true>
	<cfset v.icon_download_folder = true>
	<cfset v.tab_description_keywords = true>
	<cfset v.tab_custom_fields = true>
	<cfset v.tab_convert_files = true>
	<cfset v.tab_comments = true>
	<cfset v.tab_metadata = true>
	<cfset v.tab_xmp_description = true>
	<cfset v.tab_iptc_contact = true>
	<cfset v.tab_iptc_image = true>
	<cfset v.tab_iptc_content = true>
	<cfset v.tab_iptc_status = true>
	<cfset v.tab_origin = true>
	<cfset v.tab_versions = true>
	<cfset v.tab_sharing_options = true>
	<cfset v.tab_preview_images = true>
	<cfset v.tab_additional_renditions = true>
	<cfset v.tab_history = true>
	<cfset v.button_send_email = true>
	<cfset v.button_send_ftp = true>
	<cfset v.button_basket = true>
	<cfset v.button_add_to_collection = true>
	<cfset v.button_print = true>
	<cfset v.button_move = true>
	<cfset v.button_delete = true>
	<cfset v.share_folder = false>
	<cfset v.share_download_original = false>
	<cfset v.share_download_thumb = true>
	<cfset v.share_comments = false>
	<cfset v.share_uploading = false>
	<cfset v.request_access = true>
	<cfset v.req_filename = true>
	<cfset v.req_description = false>
	<cfset v.req_keywords = false>
	<cfset v.images_metadata = "">
	<cfset v.videos_metadata = "">
	<cfset v.files_metadata = "">
	<cfset v.audios_metadata = "">
	<cfset v.assetbox_height = "">
	<cfset v.assetbox_width = "">
	<!--- Loop over query --->
	<cfif qry.recordcount NEQ 0>
		<cfloop query="qry">
			<cfif custom_id EQ "folder_redirect">
				<cfset v.folder_redirect = custom_value>
			</cfif>
			<cfif custom_id EQ "myfolder_create" AND !custom_value>
				<cfset v.myfolder_create = false>
			</cfif>
			<cfif custom_id EQ "myfolder_upload" AND !custom_value>
				<cfset v.myfolder_upload = false>
			</cfif>
			<cfif custom_id EQ "show_top_part" AND !custom_value>
				<cfset v.show_top_part = false>
			</cfif>
			<cfif custom_id EQ "show_bottom_part" AND !custom_value>
				<cfset v.show_bottom_part = false>
			</cfif>
			<cfif custom_id EQ "show_twitter" AND !custom_value>
				<cfset v.show_twitter = false>
			</cfif>
			<cfif custom_id EQ "tab_twitter" AND !custom_value>
				<cfset v.tab_twitter = false>
			</cfif>
			<cfif custom_id EQ "show_facebook" AND !custom_value>
				<cfset v.show_facebook = false>
			</cfif>
			<cfif custom_id EQ "tab_facebook" AND !custom_value>
				<cfset v.tab_facebook = false>
			</cfif>
			<cfif custom_id EQ "tab_razuna_blog" AND !custom_value>
				<cfset v.tab_razuna_blog = false>
			</cfif>
			<cfif custom_id EQ "tab_razuna_support" AND !custom_value>
				<cfset v.tab_razuna_support = false>
			</cfif>
			<cfif custom_id EQ "tab_collections" AND !custom_value>
				<cfset v.tab_collections = false>
			</cfif>
			<cfif custom_id EQ "tab_labels" AND !custom_value>
				<cfset v.tab_labels = false>
			</cfif>
			<cfif custom_id EQ "tab_add_from_server" AND !custom_value>
				<cfset v.tab_add_from_server = false>
			</cfif>
			<cfif custom_id EQ "tab_add_from_email" AND !custom_value>
				<cfset v.tab_add_from_email = false>
			</cfif>
			<cfif custom_id EQ "tab_add_from_ftp" AND !custom_value>
				<cfset v.tab_add_from_ftp = false>
			</cfif>
			<cfif custom_id EQ "tab_add_from_link" AND !custom_value>
				<cfset v.tab_add_from_link = false>
			</cfif>
			<cfif custom_id EQ "tab_images" AND !custom_value>
				<cfset v.tab_images = false>
			</cfif>
			<cfif custom_id EQ "tab_videos" AND !custom_value>
				<cfset v.tab_videos = false>
			</cfif>
			<cfif custom_id EQ "tab_audios" AND !custom_value>
				<cfset v.tab_audios = false>
			</cfif>
			<cfif custom_id EQ "tab_other" AND !custom_value>
				<cfset v.tab_other = false>
			</cfif>
			<cfif custom_id EQ "tab_pdf" AND !custom_value>
				<cfset v.tab_pdf = false>
			</cfif>
			<cfif custom_id EQ "tab_doc" AND !custom_value>
				<cfset v.tab_doc = false>
			</cfif>
			<cfif custom_id EQ "tab_xls" AND !custom_value>
				<cfset v.tab_xls = false>
			</cfif>
			<cfif custom_id EQ "icon_select" AND !custom_value>
				<cfset v.icon_select = false>
			</cfif>
			<cfif custom_id EQ "icon_refresh" AND !custom_value>
				<cfset v.icon_refresh = false>
			</cfif>
			<cfif custom_id EQ "icon_show_subfolder" AND !custom_value>
				<cfset v.icon_show_subfolder = false>
			</cfif>
			<cfif custom_id EQ "icon_create_subfolder" AND !custom_value>
				<cfset v.icon_create_subfolder = false>
			</cfif>
			<cfif custom_id EQ "icon_favorite_folder" AND !custom_value>
				<cfset v.icon_favorite_folder = false>
			</cfif>
			<cfif custom_id EQ "icon_search" AND !custom_value>
				<cfset v.icon_search = false>
			</cfif>
			<cfif custom_id EQ "icon_print" AND !custom_value>
				<cfset v.icon_print = false>
			</cfif>
			<cfif custom_id EQ "icon_rss" AND !custom_value>
				<cfset v.icon_rss = false>
			</cfif>
			<cfif custom_id EQ "icon_word" AND !custom_value>
				<cfset v.icon_word = false>
			</cfif>
			<cfif custom_id EQ "icon_metadata_import" AND !custom_value>
				<cfset v.icon_metadata_import = false>
			</cfif>
			<cfif custom_id EQ "icon_metadata_export" AND !custom_value>
				<cfset v.icon_metadata_export = false>
			</cfif>
			<cfif custom_id EQ "icon_download_folder" AND !custom_value>
				<cfset v.icon_download_folder = false>
			</cfif>
			<cfif custom_id EQ "tab_description_keywords" AND !custom_value>
				<cfset v.tab_description_keywords = false>
			</cfif>
			<cfif custom_id EQ "tab_custom_fields" AND !custom_value>
				<cfset v.tab_custom_fields = false>
			</cfif>
			<cfif custom_id EQ "tab_convert_files" AND !custom_value>
				<cfset v.tab_convert_files = false>
			</cfif>
			<cfif custom_id EQ "tab_comments" AND !custom_value>
				<cfset v.tab_comments = false>
			</cfif>
			<cfif custom_id EQ "tab_metadata" AND !custom_value>
				<cfset v.tab_metadata = false>
			</cfif>
			<cfif custom_id EQ "tab_xmp_description" AND !custom_value>
				<cfset v.tab_xmp_description = false>
			</cfif>
			<cfif custom_id EQ "tab_iptc_contact" AND !custom_value>
				<cfset v.tab_iptc_contact = false>
			</cfif>
			<cfif custom_id EQ "tab_iptc_image" AND !custom_value>
				<cfset v.tab_iptc_image = false>
			</cfif>
			<cfif custom_id EQ "tab_iptc_content" AND !custom_value>
				<cfset v.tab_iptc_content = false>
			</cfif>
			<cfif custom_id EQ "tab_iptc_status" AND !custom_value>
				<cfset v.tab_iptc_status = false>
			</cfif>
			<cfif custom_id EQ "tab_origin" AND !custom_value>
				<cfset v.tab_origin = false>
			</cfif>
			<cfif custom_id EQ "tab_versions" AND !custom_value>
				<cfset v.tab_versions = false>
			</cfif>
			<cfif custom_id EQ "tab_sharing_options" AND !custom_value>
				<cfset v.tab_sharing_options = false>
			</cfif>
			<cfif custom_id EQ "tab_preview_images" AND !custom_value>
				<cfset v.tab_preview_images = false>
			</cfif>
			<cfif custom_id EQ "tab_additional_renditions" AND !custom_value>
				<cfset v.tab_additional_renditions = false>
			</cfif>
			<cfif custom_id EQ "tab_history" AND !custom_value>
				<cfset v.tab_history = false>
			</cfif>
			<cfif custom_id EQ "button_send_email" AND !custom_value>
				<cfset v.button_send_email = false>
			</cfif>
			<cfif custom_id EQ "button_send_ftp" AND !custom_value>
				<cfset v.button_send_ftp = false>
			</cfif>
			<cfif custom_id EQ "button_basket" AND !custom_value>
				<cfset v.button_basket = false>
			</cfif>
			<cfif custom_id EQ "button_add_to_collection" AND !custom_value>
				<cfset v.button_add_to_collection = false>
			</cfif>
			<cfif custom_id EQ "button_print" AND !custom_value>
				<cfset v.button_print = false>
			</cfif>
			<cfif custom_id EQ "button_move" AND !custom_value>
				<cfset v.button_move = false>
			</cfif>
			<cfif custom_id EQ "button_delete" AND !custom_value>
				<cfset v.button_delete = false>
			</cfif>
			<cfif custom_id EQ "share_folder" AND custom_value>
				<cfset v.share_folder = true>
			</cfif>
			<cfif custom_id EQ "share_download_thumb" AND !custom_value>
				<cfset v.share_download_thumb = false>
			</cfif>
			<cfif custom_id EQ "share_download_original" AND custom_value>
				<cfset v.share_download_original = true>
			</cfif>
			<cfif custom_id EQ "share_uploading" AND custom_value>
				<cfset v.share_uploading = true>
			</cfif>
			<cfif custom_id EQ "share_comments" AND custom_value>
				<cfset v.share_comments = true>
			</cfif>
			<cfif custom_id EQ "request_access" AND !custom_value>
				<cfset v.request_access = false>
			</cfif>
			<cfif custom_id EQ "req_filename" AND !custom_value>
				<cfset v.req_filename = false>
			</cfif>
			<cfif custom_id EQ "req_description" AND custom_value>
				<cfset v.req_description = true>
			</cfif>
			<cfif custom_id EQ "req_keywords" AND custom_value>
				<cfset v.req_keywords = true>
			</cfif>
			<cfif custom_id EQ "images_metadata">
				<cfset v.images_metadata = custom_value>
			</cfif>
			<cfif custom_id EQ "videos_metadata">
				<cfset v.videos_metadata = custom_value>
			</cfif>
			<cfif custom_id EQ "files_metadata">
				<cfset v.files_metadata = custom_value>
			</cfif>
			<cfif custom_id EQ "audios_metadata">
				<cfset v.audios_metadata = custom_value>
			</cfif>
			<cfif custom_id EQ "assetbox_height">
				<cfset v.assetbox_height = custom_value>
			</cfif>
			<cfif custom_id EQ "assetbox_width">
				<cfset v.assetbox_width = custom_value>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Return --->
	<cfreturn v />
</cffunction>

<!--- Save customization --->
<cffunction name="set_customization" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- If we apply this setting to all tenants we call the subfunction --->
	<cfif structKeyExists(arguments.thestruct,"apply_global")>
		<!--- Get all the tenants and loop over the tenants --->
		<cfinvoke component="hosts" method="getall" returnvariable="t" />
		<!--- Loop --->
		<cfloop query="t">
			<cfif session.hostid NEQ host_id>
				<!--- Check & delete if directory is already exists --->
				<cfif directoryExists("#arguments.thestruct.thepathup#global/host/favicon/#host_id#")>
					<cfdirectory action="delete" directory="#arguments.thestruct.thepathup#global/host/favicon/#host_id#" recurse="true">
				</cfif>
				<!--- Create directory --->
				<cfdirectory action="create" directory="#arguments.thestruct.thepathup#global/host/favicon/#host_id#" mode="777">
				<!--- copy the favicon.ico file --->
				<cffile action="copy" destination="#arguments.thestruct.thepathup#global/host/favicon/#host_id#" source="#arguments.thestruct.thepathup#global/host/favicon/#session.hostid#/favicon.ico"/>
			</cfif>
			<cfset set_customization_internal(thestruct=arguments.thestruct,hostid=#host_id#)>
		</cfloop>
	<!--- For a single tenant --->
	<cfelse>
		<cfset set_customization_internal(thestruct=arguments.thestruct,hostid=session.hostid)>
	</cfif>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("settings")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Save customization --->
<cffunction name="set_customization_internal" output="false" access="private" returntype="void">
	<cfargument name="thestruct" type="struct">
	<cfargument name="hostid" type="numeric">
	<!--- First remove all records for this host --->
	<cfquery dataSource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#custom
	WHERE host_id = <cfqueryparam value="#arguments.hostid#" CFSQLType="CF_SQL_NUMERIC">
	</cfquery>
	<!--- Now loop over the fieldnames and do an insert for each record found --->
	<cfloop list="#arguments.thestruct.fieldnames#" index="i">
		<cfif i NEQ "apply_global">
			<cfquery dataSource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#custom
			(custom_id, custom_value, host_id)
			VALUES(
				<cfqueryparam value="#lcase(i)#" CFSQLType="CF_SQL_VARCHAR">,
				<cfqueryparam value="#evaluate(trim(i))#" CFSQLType="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.hostid#" CFSQLType="CF_SQL_NUMERIC">
			)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Turn off redirection --->
	<cfif structKeyExists(arguments.thestruct,"folder_redirect_off")>
		<cfquery dataSource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#custom
		SET custom_value = <cfqueryparam value="0" CFSQLType="CF_SQL_VARCHAR">
		WHERE host_id = <cfqueryparam value="#arguments.hostid#" CFSQLType="CF_SQL_NUMERIC">
		AND custom_id = <cfqueryparam value="folder_redirect" CFSQLType="CF_SQL_VARCHAR">
		</cfquery>
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Save JanRain --->
<cffunction name="set_janrain" output="false">
	<cfargument name="janrain_enable" type="string">
	<cfargument name="janrain_apikey" type="string">
	<cfargument name="janrain_appurl" type="string">
	<!--- Delete & Insert --->
	<cfinvoke method="savesetting" thefield="janrain_enable" thevalue="#arguments.janrain_enable#" />
	<cfinvoke method="savesetting" thefield="janrain_apikey" thevalue="#arguments.janrain_apikey#" />
	<cfinvoke method="savesetting" thefield="janrain_appurl" thevalue="#arguments.janrain_appurl#" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Save AD Server --->
<cffunction name="set_ad_server" output="false">
	<cfargument name="ad_server_name" type="string">
	<cfargument name="ad_server_port" type="string">
	<cfargument name="ad_server_username" type="string">
	<cfargument name="ad_server_password" type="string">
	<cfargument name="ad_server_filter" type="string">
	<cfargument name="ad_server_start" type="string">
	
	<!--- Delete & Insert --->
	<cfinvoke method="savesetting" thefield="ad_server_name" thevalue="#arguments.ad_server_name#" />
	<cfinvoke method="savesetting" thefield="ad_server_port" thevalue="#arguments.ad_server_port#" />
	<cfinvoke method="savesetting" thefield="ad_server_username" thevalue="#arguments.ad_server_username#" />
	<cfinvoke method="savesetting" thefield="ad_server_password" thevalue="#arguments.ad_server_password#" />
	<cfinvoke method="savesetting" thefield="ad_server_filter" thevalue="#arguments.ad_server_filter#" />
	<cfinvoke method="savesetting" thefield="ad_server_start" thevalue="#arguments.ad_server_start#" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Save options --->
<cffunction name="set_options" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Loop over fieldnames --->
	<cfloop list="#arguments.thestruct.fieldnames#" index="i">
		<!--- First remove all entries --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM options
		WHERE lower(opt_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(i)#">
		</cfquery>
		<!--- Save to DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO options
		(opt_id, opt_value, rec_uuid)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(i)#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#createUUID()#">
		)
		</cfquery>
	</cfloop>
	<!--- Set ISP --->
	<cfquery datasource="razuna_default">
	UPDATE razuna_config
	SET conf_isp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.conf_isp#">
	</cfquery>
	<!--- Flush --->
	<cfset variables.cachetoken = resetcachetoken("settings","true")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Get options --->
<cffunction name="get_options" output="false" returntype="struct">
	<!--- Param --->
	<cfset var q = "">
	<cfset var s = structNew()>
	<cfset s.wl_login_links = "">
	<cfset s.wl_razuna_tab_text = "">
	<cfset s.wl_razuna_tab_content = "">
	<cfset s.wl_html_title = "">
	<cfset s.wl_feedback = "">
	<cfset s.wl_link_search = "">
	<cfset s.wl_link_support = "">
	<cfset s.wl_link_doc = "">
	<cfset s.wl_news_rss = "">
	<cfset s.wl_main_static = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="q" cacheRegion="razcache" cachedwithin="1">
	SELECT /* #variables.cachetoken#options */ opt_id, opt_value
	FROM options
	</cfquery>
	<!--- Put query into struct --->
	<cfloop query="q">
		<cfset s["#opt_id#"] = opt_value>
	</cfloop>
	<!--- Additionally store the full query into the struct --->
	<cfset s.query = q>
	<!--- Return --->
	<cfreturn s />
</cffunction>

<!--- Get options --->
<cffunction name="get_options_one" output="false" returntype="string">
	<cfargument name="id" type="string" required="true">
	<!--- Param --->
	<cfset var q = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="q" cacheRegion="razcache" cachedwithin="1">
	SELECT /* #variables.cachetoken#options */ opt_id, opt_value
	FROM options
	WHERE lower(opt_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.id)#">
	</cfquery>
	<!--- Return --->
	<cfreturn q.opt_value />
</cffunction>

<!--- Set CSS --->
<cffunction name="set_css" output="false" returntype="void">
	<cfargument name="thecss" type="string" required="true">
	<cfargument name="pathoneup" type="string" required="true">
	<!--- Write file --->
	<cffile action="write" file="#arguments.pathoneup#/global/host/dam/views/layouts/custom/custom.css" output="#arguments.thecss#" charset="utf-8" mode="775" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Get CSS --->
<cffunction name="get_css" output="false" returntype="void">
	<cfargument name="pathoneup" type="string" required="true">
	<!--- Check if custom folder exists --->
	<cfif !directoryExists("#arguments.pathoneup#/global/host/dam/views/layouts/custom")>
		<cfdirectory action="create" directory="#arguments.pathoneup#/global/host/dam/views/layouts/custom" mode="775" />
		<cffile action="write" file="#arguments.pathoneup#/global/host/dam/views/layouts/custom/custom.css" output="" mode="775" charset="utf-8" />
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Get news edit --->
<cffunction name="get_news_edit" output="false" returntype="query">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfset var q = "">
	<!--- If we are from add then we need to insert record --->
	<cfif arguments.thestruct.add>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO news
		(news_id, news_active)
		VALUE(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.news_id#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="true">
		)
		</cfquery>
	</cfif>
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="q">
	SELECT news_id, news_active, news_text, news_date, news_title
	FROM news
	WHERE news_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.news_id#">
	</cfquery>
	<!--- Return --->
	<cfreturn q />
</cffunction>

<!--- Get news edit --->
<cffunction name="set_news_edit" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Save --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE news
	SET
	news_active = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.news_active#">, 
	news_text = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.news_text#">, 
	news_date = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.news_date#">, 
	news_title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.news_title#">
	WHERE news_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.news_id#">
	</cfquery>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Get news edit --->
<cffunction name="get_news" output="false" returntype="query">
	<cfargument name="news_main" type="string" required="false" default="false">
	<!--- Param --->
	<cfset var q = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="q">
	SELECT <cfif arguments.news_main AND application.razuna.thedatabase EQ "mssql">TOP 7 </cfif>news_id, news_active, news_date, news_title<cfif arguments.news_main>, news_text</cfif>
	FROM news
	<cfif arguments.news_main>
		WHERE news_active = <cfqueryparam cfsqltype="cf_sql_varchar" value="true">
	</cfif>
	ORDER BY news_date DESC
	<cfif arguments.news_main AND application.razuna.thedatabase NEQ "mssql">LIMIT 7</cfif>
	</cfquery>
	<!--- Return --->
	<cfreturn q />
</cffunction>

<!--- Get news edit --->
<cffunction name="del_news" output="false" returntype="void">
	<cfargument name="news_id" type="string" required="true">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM news
	WHERE news_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.news_id#">
	</cfquery>
	<!--- Return --->
	<cfreturn />
</cffunction>

	<!--- Check for app key --->
	<cffunction name="getappkey">
		<cfargument name="account" type="string">
		<!--- Param --->
		<cfset var qry_keys = "">
		<!--- Connect to DB and retrieve keys --->
		<cftry>
			<!--- Query --->
			<cfquery datasource="razuna_client" name="qry_keys">
			SELECT app_key_name, app_key_value
			FROM appkeys
			WHERE app_key_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.account#_%">
			</cfquery>
			<!--- Put keys into session scope --->
			<cfloop query="qry_keys">
				<cfif app_key_name EQ "#arguments.account#_appkey">
					<cfset "session.#arguments.account#.appkey" = app_key_value>
				<cfelseif app_key_name EQ "#arguments.account#_appsecret">
					<cfset "session.#arguments.account#.appsecret" = app_key_value>
				</cfif>
			</cfloop>
			<!--- Output --->
			<!--- <cfoutput><span style="font-weight:bold;color:green;">Got the codes please authenticate now!</span></cfoutput> --->
			<cfcatch type="any">
				<cfoutput><span style="font-weight:bold;color:red;">Error occured: #cfcatch.message# - #cfcatch.detail#</span></cfoutput>
				<cfabort>
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Get_s3 --->
	<cffunction name="get_s3" returntype="Query">
		<!--- Param --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT set_id, set_pref
		FROM #session.hostdbprefix#settings
		WHERE lower(set_id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="aws_%">
		ORDER BY lower(set_id)
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Get_s3 --->
	<cffunction name="set_s3" returntype="void">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Remove all aws fields in DB first --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#settings
		WHERE lower(set_id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="aws_%">
		</cfquery>
		<!--- Remove all sessions with AWS --->
		<cfif structKeyExists(session,"aws")>
			<cfset structClear(session.aws)>
		</cfif>
		<!--- Loop over fields and call savesettings --->
		<cfloop collection="#arguments.thestruct#" item="i">
			<cfif i CONTAINS "aws_">
				<cfif arguments.thestruct["#i#"] EQ "">
					<cfbreak>
				</cfif>
				<cfinvoke method="savesetting" thefield="#i#" thevalue="#arguments.thestruct["#i#"]#" />
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Get AD Server --->
	<cffunction name="get_ad_server" returntype="Query">
		<!--- Param --->
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT set_id, set_pref
		FROM #session.hostdbprefix#settings
		WHERE lower(set_id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="ad_server_%">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		ORDER BY lower(set_id)
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>
	
	<!--- Get AD users --->
	<cffunction name="get_ad_server_userlist" returntype="Query">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfif structKeyExists(arguments.thestruct,'searchtext') AND trim(arguments.thestruct.searchtext) NEQ ''>
			<cfldap   server = "#arguments.thestruct.ad_server_name#"  
			action = "query"  name = "results"  start = "#arguments.thestruct.ad_server_start#"
			filter="(&(objectClass=user)(samaccountname=*#arguments.thestruct.searchtext#*))" 
			attributes="cn,company,username,firstname,lastname,mail,memberof,givenname,SamAccountname,physicalDeliveryOfficeName, department"
			sort = "cn ASC"   username="#arguments.thestruct.ad_server_username#" password="#arguments.thestruct.ad_server_password#"  >
		<cfelse>
			<cfldap   server = "#arguments.thestruct.ad_server_name#"  
			action = "query"  name = "results"  start = "#arguments.thestruct.ad_server_start#"
			filter="(&(objectClass=user))" 
			attributes="cn,company,username,firstname,lastname,mail,memberof,givenname,SamAccountname,physicalDeliveryOfficeName, department"
			sort = "cn ASC"   username="#arguments.thestruct.ad_server_username#" password="#arguments.thestruct.ad_server_password#"  >
		</cfif>
		<cfreturn results/>
	</cffunction>
		

</cfcomponent>