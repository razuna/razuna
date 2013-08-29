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
<cfcomponent extends="extQueryCaching" output="false">

	<!--- Check for a DB update --->
	<cffunction name="update_for">
		<!--- Param --->
		<cfset var dbup = false>
		<!--- Check in database for the latest update value --->
		<cfquery datasource="#application.razuna.datasource#" name="updatenumber">
		SELECT opt_value
		FROM options
		WHERE lower(opt_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="dbupdate">
		</cfquery>
		<!--- If no record has been found then insert 0 --->
		<cfif updatenumber.recordcount EQ 0>
			<!--- Insert --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO options
			(opt_id, opt_value, rec_uuid)
			VALUES(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="dbupdate">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="0">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">
			)
			</cfquery>
			<!--- set var --->
			<cfset var dbup = true>
		<!--- Record found compare with current number --->
		<cfelse>
			<!--- Read config file for dbupdate number --->
			<cfinvoke component="settings" method="getconfig" thenode="dbupdate" returnvariable="dbupdateconfig">
			<!--- Set var --->
			<cfif dbupdateconfig GT updatenumber.opt_value AND NOT dbupdateconfig EQ updatenumber.opt_value>
				<cfset var dbup = true>
			</cfif>
		</cfif>
		<!--- Return --->
		<cfreturn dbup>
	</cffunction>

	<!--- Check for a new version --->
	<cffunction name="check_update">
		<cfargument name="thestruct" type="struct">	
		<cfset var v = structnew()>
		<!--- Set the version file on the server --->
		<cfset var versionfile = "http://cloud.razuna.com/installers/versionupdate.xml">
		<!--- Get the current version --->
		<cfinvoke component="settings" method="getconfig" thenode="version" returnvariable="currentversion">
		<!--- Parse the version file on the server --->
		<cftry>
			<cfhttp url="#versionfile#" method="get" throwonerror="yes" timeout="5">
			<cfset var xmlVar=xmlParse(trim(cfhttp.filecontent))/>
			<cfset var theversion=xmlSearch(xmlVar, "update/version[@name='version']")>
			<cfset v.newversionnr = trim(#theversion[1].thetext.xmlText#)>
			<!--- Count how many dots are in the version --->
			<cfset x = compare(v.newversionnr,currentversion)>
			<!--- If the new version is bigger then the current version --->
			<cfif x EQ 1>
				<cfset v.versionavailable = "T">
			<cfelse>
				<cfset v.versionavailable = "F">
			</cfif>
			<cfcatch type="any">
				<cfset v.versionavailable = "F">
			</cfcatch>
		</cftry>
		<!--- Return --->
		<cfreturn v>
	</cffunction>
	
	<!--- DO DB update --->
	<cffunction name="update_do">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfset var tableoptions = "">
		<!--- Name for the log --->
		<cfset var logname = "razuna_update_" & dateformat(now(),"mm_dd_yyyy") & "_" & timeformat(now(),"HH-mm-ss")>
		<!--- Detault types --->
		<cfset var theclob = "clob">
		<cfset var theint = "int">
		<cfset var thevarchar = "varchar">
		<cfset var thetimestamp = "timestamp">
		<!--- Map different types according to database --->
		<cfif application.razuna.thedatabase EQ "mysql">
			<cfset var tableoptions = "ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_bin">
			<cfset var theclob = "text">
		<cfelseif application.razuna.thedatabase EQ "mssql">
			<cfset var theclob = "NVARCHAR(max)">
			<cfset var thetimestamp = "datetime">
		<cfelseif application.razuna.thedatabase EQ "oracle">
			<cfset var theint = "number">
			<cfset var thevarchar = "varchar2">
		</cfif>

		<!--- Core DB --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_import_templates 
			(	
				imp_temp_id #thevarchar#(100), 
				imp_date_create #thetimestamp#, 
				imp_date_update #thetimestamp#,
				imp_who #thevarchar#(100),
				imp_active #thevarchar#(1) DEFAULT '0',
				host_id #theint#,
				imp_name #thevarchar#(200),
				imp_description #thevarchar#(2000),
				PRIMARY KEY (imp_temp_id)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_import_templates_val 
			(
				imp_temp_id_r #thevarchar#(100),
				rec_uuid #thevarchar#(100),
				imp_field #thevarchar#(200),
				imp_map #thevarchar#(200),
				host_id #theint#,
				imp_key #theint#,
				PRIMARY KEY (rec_uuid)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_custom 
			(
			  custom_id #thevarchar#(200),
			  custom_value #thevarchar#(100),
			  host_id #theint#
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_users_accounts 
			(
			  identifier #thevarchar#(200),
			  provider #thevarchar#(100),
			  user_id_r #thevarchar#(100),
			  host_id #theint#,
			  jr_identifier #thevarchar#(500),
			  profile_pic_url #thevarchar#(1000)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE cache 
			(
			  cache_token #thevarchar#(100) DEFAULT NULL,
			  cache_type #thevarchar#(20) DEFAULT NULL,
			  host_id #theint# DEFAULT NULL
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE ct_plugins_hosts 
			(
			  ct_pl_id_r #thevarchar#(100) DEFAULT '',
			  ct_host_id_r #theint# DEFAULT NULL,
			  rec_uuid #thevarchar#(100) DEFAULT NULL
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE plugins 
			(
			  p_id #thevarchar#(100) NOT NULL DEFAULT '',
			  p_path #thevarchar#(500) DEFAULT NULL,
			  p_active #thevarchar#(5) DEFAULT 'false',
			  p_name #thevarchar#(500) DEFAULT NULL,
			  p_url #thevarchar#(500) DEFAULT NULL,
			  p_version #thevarchar#(20) DEFAULT NULL,
			  p_author #thevarchar#(500) DEFAULT NULL,
			  p_author_url #thevarchar#(500) DEFAULT NULL,
			  p_description #thevarchar#(2000) DEFAULT NULL,
			  p_license #thevarchar#(500) DEFAULT NULL,
			  p_cfc_list #thevarchar#(500) DEFAULT NULL,
			  PRIMARY KEY (p_id)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE plugins_actions 
			(
			  action #thevarchar#(200) DEFAULT NULL,
			  comp #thevarchar#(200) DEFAULT NULL,
			  func #thevarchar#(200) DEFAULT NULL,
			  args #theclob#,
			  p_id #thevarchar#(100) DEFAULT NULL,
			  host_id #theint#,
			  p_remove #thevarchar#(10)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE options 
			(
			  opt_id #thevarchar#(100) NOT NULL DEFAULT '',
			  opt_value #theclob#,
			  rec_uuid #thevarchar#(100) NOT NULL DEFAULT '',
			  PRIMARY KEY (opt_id)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE news 
			(
			  news_id #thevarchar#(100) NOT NULL DEFAULT '',
			  news_title #thevarchar#(500) DEFAULT NULL,
			  news_active #thevarchar#(6) DEFAULT NULL,
			  news_text #theclob#,
			  news_date #thevarchar#(20) DEFAULT NULL,
			  PRIMARY KEY (news_id)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_workflow_logs 
			(
			  wf_log_id #thevarchar#(100) NOT NULL DEFAULT '',
			  wf_log_text #theclob#,
			  wf_log_date #thetimestamp# NULL DEFAULT NULL,
			  host_id #theint# DEFAULT NULL,
			  wf_log_wfid #thevarchar#(100) DEFAULT NULL,
			  wf_action #thevarchar#(100) DEFAULT NULL,
			  PRIMARY KEY (wf_log_id)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_wm_templates 
			(
			  wm_temp_id #thevarchar#(100) NOT NULL DEFAULT '',
			  wm_name #thevarchar#(200) DEFAULT NULL,
			  wm_active #thevarchar#(6) DEFAULT 'false',
			  host_id #theint# DEFAULT NULL,
			  PRIMARY KEY (wm_temp_id)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_wm_templates_val 
			(
			  wm_temp_id_r #thevarchar#(100) DEFAULT NULL,
			  wm_use_image #thevarchar#(6) DEFAULT 'false',
			  wm_use_text #thevarchar#(6) DEFAULT 'false',
			  wm_image_opacity #thevarchar#(4) DEFAULT NULL,
			  wm_text_opacity #thevarchar#(4) DEFAULT NULL,
			  wm_image_position #thevarchar#(10) DEFAULT NULL,
			  wm_text_position #thevarchar#(10) DEFAULT NULL,
			  wm_text_content #thevarchar#(400) DEFAULT NULL,
			  wm_text_font #thevarchar#(100) DEFAULT NULL,
			  wm_text_font_size #thevarchar#(5) DEFAULT NULL,
			  wm_image_path #thevarchar#(300) DEFAULT NULL,
			  host_id #theint# DEFAULT NULL,
			  rec_uuid #thevarchar#(100) NOT NULL,
			  PRIMARY KEY (rec_uuid)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Alter tables --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_xmp add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> colorspace #thevarchar#(50)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_xmp add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> xres #thevarchar#(10)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_xmp add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> yres #thevarchar#(50)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_xmp add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> resunit #thevarchar#(20)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table users add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> user_api_key #thevarchar#(100)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_labels add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> label_id_r #thevarchar#(100) default '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_labels add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> label_path #thevarchar#(500)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_custom_fields add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> cf_select_list #thevarchar#(2000)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			update raz1_labels set label_path = label_text where label_id_r = '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_custom <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column custom_value #thevarchar#(2000)<cfelse>change custom_value custom_value #thevarchar#(2000)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> set2_md5check #thevarchar#(5) default 'false'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> set2_colorspace_rgb #thevarchar#(5) default 'false'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_assets_temp <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column thesize #thevarchar#(100)<cfelse>change thesize thesize #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_images <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column img_size #thevarchar#(100)<cfelse>change img_size img_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_images <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column thumb_size #thevarchar#(100)<cfelse>change thumb_size thumb_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_videos <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column vid_size #thevarchar#(100)<cfelse>change vid_size vid_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_audios <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column aud_size #thevarchar#(100)<cfelse>change aud_size aud_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_files <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column file_size #thevarchar#(100)<cfelse>change file_size file_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_versions <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column img_size #thevarchar#(100)<cfelse>change img_size img_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_versions <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column thumb_size #thevarchar#(100)<cfelse>change thumb_size thumb_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_versions <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column vid_size #thevarchar#(100)<cfelse>change vid_size vid_size #thevarchar#(100)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_additional_versions add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> thesize #thevarchar#(100) DEFAULT '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_additional_versions add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> thewidth #thevarchar#(50) DEFAULT '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_additional_versions add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> theheight #thevarchar#(50) DEFAULT '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_custom_fields add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> cf_in_form #thevarchar#(10) DEFAULT 'true'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_collections add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> col_released #thevarchar#(5) DEFAULT 'false'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_collections add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> col_copied_from #thevarchar#(100)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_upload_templates_val <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column upl_temp_format #thevarchar#(10)<cfelse>change upl_temp_format upl_temp_format #thevarchar#(10)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_schedules add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> sched_upl_template #thevarchar#(100)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> set2_aka_url #thevarchar#(500)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> set2_aka_img #thevarchar#(200)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> set2_aka_vid #thevarchar#(200)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> set2_aka_aud #thevarchar#(200)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> set2_aka_doc #thevarchar#(200)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_custom_fields add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> cf_edit #thevarchar#(2000) default 'true'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_additional_versions add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> hashtag #thevarchar#(100)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_folders add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> share_dl_thumb #thevarchar#(1) default 't'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_widgets add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> widget_dl_thumb #thevarchar#(1) default 't'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_collections add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> share_dl_thumb #thevarchar#(1) default 't'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_smart_folders 
			(
				sf_id #thevarchar#(100),
				sf_name #thevarchar#(500),
				sf_date_create #thetimestamp# NULL DEFAULT NULL,
				sf_date_update #thetimestamp# NULL DEFAULT NULL,
				sf_type #thevarchar#(100),
				sf_description #thevarchar#(2000),
				PRIMARY KEY (sf_id)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			CREATE TABLE raz1_smart_folders_prop
			(
				sf_id_r #thevarchar#(100),
				sf_prop_id #thevarchar#(500),
				sf_prop_value #thevarchar#(2000),
				PRIMARY KEY (sf_id_r)
			)
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_settings <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column set_id #thevarchar#(500)<cfelse>change set_id set_id #thevarchar#(500)</cfif>
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add in_trash Column in raz1_audios --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_audios add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> in_trash #thevarchar#(2) default 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update in_trash (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_audios SET in_trash = 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add in_trash Column in raz1_collections --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_collections add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> in_trash #thevarchar#(2) default 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update in_trash (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_collections SET in_trash = 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add in_trash Column in raz1_collections_ct_files --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_collections_ct_files add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> in_trash #thevarchar#(2) default 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update in_trash (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_collections_ct_files SET in_trash = 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add in_trash Column in raz1_files --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_files add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> in_trash #thevarchar#(2) default 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update in_trash (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_files SET in_trash = 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add in_trash Column in raz1_folders --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_folders add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> in_trash #thevarchar#(2) default 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update in_trash (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_folders SET in_trash = 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add in_trash Column in raz1_images --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_images add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> in_trash #thevarchar#(2) default 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update in_trash (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_images SET in_trash = 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add in_trash Column in raz1_videos --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_videos add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> in_trash #thevarchar#(2) default 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update in_trash (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_videos SET in_trash = 'F'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		
		<!--- MSSQL: Drop constraints --->
		<cfif application.razuna.thedatabase EQ "mssql">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT table_name, constraint_name
				FROM information_schema.constraint_column_usage
				WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="raz1_collections_ct_files">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #lcase(table_name)# DROP CONSTRAINT #constraint_name#
					</cfquery>
				</cfloop>
				<cfcatch type="database">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
		<!--- MySQL: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT constraint_name
				FROM information_schema.TABLE_CONSTRAINTS 
				WHERE lower(TABLE_NAME) = <cfqueryparam cfsqltype="cf_sql_varchar" value="raz1_collections_ct_files">
				AND lower(CONSTRAINT_TYPE) = <cfqueryparam cfsqltype="cf_sql_varchar" value="foreign key">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_collections_ct_files DROP FOREIGN KEY #constraint_name#
					</cfquery>
				</cfloop>
				<cfcatch type="database">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
		<!--- Oracle: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT constraint_name, table_name
				FROM user_constraints
				WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="raz1_collections_ct_files">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #lcase(table_name)# DROP CONSTRAINT #constraint_name# CASCADE
					</cfquery>
				</cfloop>
				<cfcatch type="database">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Add host_id to smart folders --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_smart_folders add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> host_id #theint#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_smart_folders_prop add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> host_id #theint#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add sf_who to smart folders --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_smart_folders add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> sf_who #thevarchar#(100)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Add is_indexed  --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_images add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> is_indexed #thevarchar#(1) default '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_videos add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> is_indexed #thevarchar#(1) default '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_audios add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> is_indexed #thevarchar#(1) default '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			alter table raz1_files add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> is_indexed #thevarchar#(1) default '0'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<!--- Update is_indexed (since MS SQL doesn't add default values by adding a column) --->
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_images SET is_indexed = '1'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_videos SET is_indexed = '1'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_audios SET is_indexed = '1'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_files SET is_indexed = '1'
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>


		<!--- Add indexing to scheduler --->
		
		<!--- Query host table --->
		<cfquery datasource="#application.razuna.datasource#" name="qry_hosts">
		SELECT host_id, host_path
		FROM hosts
		</cfquery>
		<!--- Loop over hosts --->
		<cfloop query="qry_hosts">
			<cfset var newschid = createuuid()>
			<!--- Insert --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#schedules 
			(sched_id, 
			 set2_id_r, 
			 sched_user, 
			 sched_method, 
			 sched_name,
			 sched_interval,
			 host_id
			)
			VALUES 
			(<cfqueryparam value="#newschid#" cfsqltype="CF_SQL_VARCHAR">, 
			 <cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
			 <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">, 
			 <cfqueryparam value="indexing" cfsqltype="cf_sql_varchar">, 
			 <cfqueryparam value="Indexing" cfsqltype="cf_sql_varchar">,
			 <cfqueryparam value="daily" cfsqltype="cf_sql_varchar">,
			 <cfqueryparam cfsqltype="cf_sql_numeric" value="#host_id#">
			 )
			</cfquery>
			<!--- Save scheduled event in CFML scheduling engine --->
			<cfschedule action="update"
				task="RazScheduledUploadEvent[#newschid#]" 
				operation="HTTPRequest"
				url="http://#cgi.http_host#/#cgi.context_path#/#host_path#/dam/index.cfm?fa=c.scheduler_doit&sched_id=#newschid#"
				startDate="#LSDateFormat(Now(), 'mm/dd/yyyy')#"
				startTime="00:01"
				endDate=""
				endTime="23:59"
				interval="120"
			>
		</cfloop>
		
		<!--- Add to internal table --->
		<cftry>
			<cfquery dataSource="razuna_default">
			alter table razuna_config add conf_aka_token varchar(200)
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_default">
			alter table razuna_config add conf_wl BOOLEAN DEFAULT false
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		

		<!--- 
		<cftry>
			<cfquery datasource="#application.razuna.datasource#">
			
			#tableoptions#
			</cfquery>
			<cfcatch type="any">
				<cfset thelog(logname=logname,thecatch=cfcatch)>
			</cfcatch>
		</cftry>
		 --->

		<!--- Read config file for dbupdate number --->
		<cfinvoke component="settings" method="getconfig" thenode="dbupdate" returnvariable="dbupdateconfig">
		<!--- Update value in db --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE options
		SET opt_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dbupdateconfig#">
		WHERE lower(opt_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="dbupdate">
		</cfquery>
		<!--- Done --->
	</cffunction>

	<!--- DO DB update --->
	<cffunction name="thelog" returntype="void" access="private">
		<cfargument name="logname" required="true">
		<cfargument name="thecatch" required="true">
		<!--- Log error --->
		<cflog application="no" file="#arguments.logname#" type="error" text="message: #arguments.thecatch.message# Detail: #arguments.thecatch.detail#">
		<!--- Done --->
	</cffunction>

	<!--- Simply update options db --->
	<cffunction name="setoptionupdate" returntype="void" access="Public">
		<!--- Read config file for dbupdate number --->
		<cfinvoke component="settings" method="getconfig" thenode="dbupdate" returnvariable="dbupdateconfig">
		<!--- Update value in db --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO options
		(opt_id, opt_value, rec_uuid)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="dbupdate">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#dbupdateconfig#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#createuuid()#">
		)
		</cfquery>
	</cffunction>

</cfcomponent>