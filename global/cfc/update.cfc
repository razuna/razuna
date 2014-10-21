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
	<!--- Global Object --->
	<cfobject component="global.cfc.global" name="gobj">
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
			<cfset var theclob = "longtext">
		<cfelseif application.razuna.thedatabase EQ "mssql">
			<cfset var theclob = "NVARCHAR(max)">
			<cfset var thetimestamp = "datetime">
		<cfelseif application.razuna.thedatabase EQ "oracle">
			<cfset var theint = "number">
			<cfset var thevarchar = "varchar2">
		</cfif>

		<!--- Get the correct paths for hosted vs non-hosted --->
		<cfif !application.razuna.isp>
			<cfset var taskpath =  "#session.thehttp##cgi.http_host#/#cgi.context_path#/raz1/dam">
		<cfelse>
			<cfset var taskpath =  "#session.thehttp##cgi.http_host#/admin">
		</cfif>

		<!--- Check in database for the latest update value --->
		<cfquery datasource="#application.razuna.datasource#" name="updatenumber">
		SELECT opt_value
		FROM options
		WHERE lower(opt_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="dbupdate">
		</cfquery>
		<!--- Read config file for dbupdate number --->
		<cfinvoke component="settings" method="getconfig" thenode="dbupdate" returnvariable="dbupdateconfig">
		
		<cftry>
			<!--- Fix language id's if incorrect --->
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '1' WHERE lang_name ='English'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '2' WHERE lang_name ='German'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '3' WHERE lang_name ='French'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '4' WHERE lang_name ='Dutch'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '5' WHERE lang_name ='Danish'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '6' WHERE lang_name ='Arabic'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '7' WHERE lang_name ='Vietnamese'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '8' WHERE lang_name ='Romanian'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '9' WHERE lang_name ='Spanish'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '10' WHERE lang_name ='Italian'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '11' WHERE lang_name ='Norwegian'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '12' WHERE lang_name ='Slovenian'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '13' WHERE lang_name ='Ukrainian'
			</cfquery>
			<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_languages SET lang_id = '14' WHERE lang_name ='Brazilian'
			</cfquery>
		<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
		</cftry>

		<!--- If less then 43 (1.7) --->
		<cfif updatenumber.opt_value LT 43>
			<!--- Add zip_extract column to smart_folders table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_smart_folders add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> sf_zipextract #thevarchar#(1)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<!--- Add folder_subscribe_groups table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE TABLE raz1_folder_subscribe_groups (
				  folder_id #thevarchar#(100) DEFAULT NULL,
				  group_id #thevarchar#(100) DEFAULT NULL
				  <cfif application.razuna.thedatabase EQ "mysql">,
				  KEY folder_id (folder_id),
				  KEY group_id (group_id)
				  </cfif>
				) #tableoptions#
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
		
			<!--- Add SAML columns to settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_SAML_XMLPATH_EMAIL #thevarchar#(100)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_SAML_XMLPATH_PASSWORD #thevarchar#(100)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_SAML_HTTPREDIRECT #thevarchar#(100)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<!--- Increase type_id column in table file_types --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					alter table file_types <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column <cfelse>modify </cfif> type_id #thevarchar#(10)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<!--- Add column to settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_META_EXPORT #thevarchar#(1) DEFAULT 'f'
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<!--- Add column to folders table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_folders add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> share_inherit #thevarchar#(1) DEFAULT 'f'
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<!--- Increase column length in xmp table --->
			<cfset var thexmpcol_list = "subjectcode_1000,creator_1000,title_1000,authorsposition_1000,captionwriter_1000,ciadrextadr_1000,category_1000,urgency_500,ciadrcity_1000,ciadrctry_500,location_500,intellectualgenre_500,source_1000,transmissionreference_500,headline_1000,city_1000,ciadrregion_500,country_500,countrycode_500,scene_500,state_500,credit_1000">
			<cfloop list="#thexmpcol_list#" index="thexmpcol">
				<cftry>
					<cfquery datasource="#application.razuna.datasource#">
						alter table raz1_xmp <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column <cfelse>modify </cfif> #gettoken(thexmpcol,1,'_')# #thevarchar#(#gettoken(thexmpcol,2,'_')#)
					</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
			</cfloop>

			<cfset var thexmpfilescol_list = "author_1000, authorsposition_1000,captionwriter_1000,webstatement_1000">
			<cfloop list="#thexmpfilescol_list#" index="thexmpfilecol">
				<cftry>
					<cfquery datasource="#application.razuna.datasource#">
						alter table raz1_files_xmp <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column <cfelse>modify </cfif> #gettoken(thexmpfilecol,1,'_')# #thevarchar#(#gettoken(thexmpfilecol,2,'_')#)
					</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
			</cfloop>

			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE groups add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> FOLDER_REDIRECT #thevarchar#(100)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<!--- Save FTP Task in CFML scheduling engine --->
			<cfschedule action="update"
				task="RazFTPNotifications" 
				operation="HTTPRequest"
				url="#taskpath#/index.cfm?fa=c.w_ftp_notifications_task"
				startDate="#LSDateFormat(Now(), 'mm/dd/yyyy')#"
				startTime="00:01 AM"
				endTime="23:59 PM"
				interval="3600"
			>

			<!--- Custom Fields --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_custom_fields add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> cf_xmp_path #thevarchar#(500)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<!--- Alter news --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE news add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> host_id #theint# default 0
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<!--- Since MS SQL does not honor the default for existing records update all --->
			<cfif application.razuna.thedatabase EQ "mssql">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE news
				SET host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
				</cfquery>
			</cfif>

			<!--- Alter users --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE users add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> user_search_selection #thevarchar#(100)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<!--- Alter folders --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_folders add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> in_search_selection #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<!--- Since MS SQL does not honor the default for existing records update all --->
			<cfif application.razuna.thedatabase EQ "mssql">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_folders
				SET in_search_selection = <cfqueryparam cfsqltype="cf_sql_varchar" value="false">
				</cfquery>
			</cfif>

			<!--- Alter schedules --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_schedules_log add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> NOTIFIED #thevarchar#(5)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_schedules add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SCHED_FTP_EMAIL #thevarchar#(500)
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>


			<!--- Alias db --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					CREATE TABLE ct_aliases 
					(	
						asset_id_r		#thevarchar#(100) DEFAULT NULL,
						folder_id_r		#thevarchar#(100) DEFAULT NULL,
						type			#thevarchar#(10) DEFAULT NULL,
						rec_uuid		#thevarchar#(100) DEFAULT NULL
						<cfif application.razuna.thedatabase EQ "mysql">,
						KEY asset_id_r (asset_id_r),
						KEY folder_id_r (folder_id_r)
						</cfif>
					)
					#tableoptions#
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE groups add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> FOLDER_SUBSCRIBE #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_folder_subscribe add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> auto_entry #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#">
					UPDATE raz1_folder_subscribe set auto_entry = 'false' WHERE (auto_entry IS  NULL OR auto_entry ='')
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
			<!--- Create indexes  --->
			<cfif application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "mssql">
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX hashtag ON raz1_images(hashtag)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				 <cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX hashtag ON raz1_audios(hashtag)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX hashtag ON raz1_files(hashtag)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX folder_id ON raz1_folder_subscribe(folder_id)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX user_id ON raz1_folder_subscribe(user_id)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX sched_logtime ON raz1_schedules_log(SCHED_LOG_TIME)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX notified ON raz1_schedules_log(sched_id_r, notified)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX asset_id_r  ON ct_aliases(asset_id_r)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE INDEX ct_folder_id_r  ON ct_aliases(folder_id_r)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
			<cfelseif application.razuna.thedatabase EQ "mysql">
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_images ADD INDEX  hashtag(hashtag)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_audios ADD INDEX  hashtag(hashtag)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_files ADD INDEX  hashtag(hashtag)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_folder_subscribe ADD INDEX  folder_id (folder_id)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_folder_subscribe ADD INDEX  user_id (user_id)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_schedules_log ADD INDEX sched_logtime(SCHED_LOG_TIME)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_schedules_log ADD INDEX notified(sched_id_r, notified)
				</cfquery>
					<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
			</cfif>
			<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
				<!--- Add columns for notification email settings--->
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_FOLDER_SUBSCRIBE_EMAIL_SUB #thevarchar#(50)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_FOLDER_SUBSCRIBE_EMAIL_BODY  #thevarchar#(1000)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				   <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_FOLDER_SUBSCRIBE_META  #thevarchar#(2000)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_ASSET_EXPIRY_EMAIL_SUB #thevarchar#(50)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_ASSET_EXPIRY_EMAIL_BODY  #thevarchar#(1000)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_ASSET_EXPIRY_META  #thevarchar#(2000)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				  <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_DUPLICATES_EMAIL_SUB #thevarchar#(50)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_DUPLICATES_EMAIL_BODY  #thevarchar#(2000)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				  <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_DUPLICATES_META  #thevarchar#(2000)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
		</cfif>

		<!--- If update number is lower then 26 (v. 1.6.5) --->
		<cfif updatenumber.opt_value LT 26>
			<cftry>
				<!--- Add a unique index on raz1_languages to avoid duplicate entries --->
				<cfif application.razuna.thedatabase EQ "mssql">
					<cfquery datasource="#application.razuna.datasource#">
					CREATE UNIQUE NONCLUSTERED INDEX [UNIQUE_HOSTID_LANGID] ON raz1_languages
					(
					[lang_id] ASC,
					[HOST_ID] ASC
					)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
					</cfquery>
				<cfelseif application.razuna.thedatabase EQ "mysql">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_languages ADD UNIQUE INDEX  UNIQUE_HOSTID_LANGID (host_id, lang_id)
					</cfquery>
				<cfelseif application.razuna.thedatabase EQ "h2">
					<cfquery  datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_languages ADD CONSTRAINT UNIQUE_HOSTID_LANGID UNIQUE(host_id,lang_id)
					</cfquery>
				</cfif>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<!--- Set global vars for mysql --->
			<cfif application.razuna.thedatabase EQ "mysql">
				<cftry>
					<cfquery datasource="#application.razuna.datasource#">
				  	SET GLOBAL innodb_large_prefix = 1;
					</cfquery>
				<cfcatch>   <cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
					<cfquery datasource="#application.razuna.datasource#">
					SET GLOBAL innodb_file_format = barracuda;
					</cfquery>
				<cfcatch>   <cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
				<cftry>
					<cfquery datasource="#application.razuna.datasource#">
					SET GLOBAL innodb_file_per_table = true;
					</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>
			</cfif>
		
			<!--- Add column to store file_size for versions --->
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_versions add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> file_size #thevarchar#(100)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>

			<!--- Add columns for new user email settings--->
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_NEW_USER_EMAIL_SUB #thevarchar#(500)
				 </cfquery>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_NEW_USER_EMAIL_BODY  #thevarchar#(4000)
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<cftry>
				<!--- Add default value in database for welcome emails --->
				<cfquery  name="checkemailset" datasource="#application.razuna.datasource#">
					SELECT rec_uuid FROM raz1_settings_2 WHERE (set2_new_user_email_sub ='' OR set2_new_user_email_sub is NULL) AND (set2_new_user_email_body = '' OR set2_new_user_email_body is NULL)
				</cfquery>
				<cfloop query = "checkemailset">
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE raz1_settings_2 SET set2_new_user_email_sub ='Welcome!', set2_new_user_email_body = '<p>Dear User,<br />Your Razuna account login information are as follows:<br />Username: $username$<br />Password: $password$</p>'
					WHERE rec_uuid= <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#checkemailset.rec_uuid#">
					</cfquery>
				</cfloop>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<!--- RAZ-549 Add columns for asset expiry --->
			<cftry>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_images add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> EXPIRY_DATE  DATE<cfif application.razuna.thedatabase EQ "mssql">TIME</cfif> 
				 </cfquery>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_audios add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> EXPIRY_DATE  DATE<cfif application.razuna.thedatabase EQ "mssql">TIME</cfif> 
				 </cfquery>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_videos add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> EXPIRY_DATE  DATE<cfif application.razuna.thedatabase EQ "mssql">TIME</cfif> 
				 </cfquery>
				 <cfquery datasource="#application.razuna.datasource#">
				 ALTER TABLE raz1_files add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> EXPIRY_DATE  DATE<cfif application.razuna.thedatabase EQ "mssql">TIME</cfif> 
				 </cfquery>
				 <cfcatch type="any">
				   	<cfset thelog(logname=logname,thecatch=cfcatch)>
				 </cfcatch>
			</cftry>
			<!--- RAZ-549 Insert asset expiry labels for existing hosts --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#" name="gethosts">
					select host_id, host_shard_group from hosts
				</cfquery>
				<cfloop query="gethosts">
					<cfquery datasource="#application.razuna.datasource#" name="islabelexists">
						SELECT 1 FROM #host_shard_group#labels WHERE host_id =<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#gethosts.host_id#">
						AND label_text = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="Asset has expired">
					</cfquery>
					<cfif islabelexists.recordcount eq 0>
						<!--- Insert label for asset expiry --->
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #host_shard_group#labels (label_id,label_text, label_date,user_id,host_id,label_id_r,label_path)
						VALUES (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="Asset has expired">,
							<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">,
							<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#gethosts.host_id#">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="0">,
							<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="Asset has expired">
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfcatch type="any">
					   <cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<!--- RAZ-2940 : Remove constraints from images_text, audios_text and videos_text tables --->
			<cfset var thesql = "DROP CONSTRAINT">
			<cfset var thetbl = "table_constraints">
			<cfset var thetype = "FOREIGN KEY">
			<cfif application.razuna.thedatabase EQ "mysql">
				<cfset thesql = "DROP FOREIGN KEY">
			<cfelseif application.razuna.thedatabase EQ "h2">
				<cfset var thetbl = "constraints">
				<cfset var thetype = "REFERENTIAL">
			</cfif>
				<cftry>
				<cfquery datasource="#application.razuna.datasource#"  name="getdel_sql">
					select 
					<cfif application.razuna.thedatabase NEQ "mssql">
					concat('alter table ',table_schema,'.',table_name,' #thesql# ',constraint_name, ';') 
					<cfelse>
					'alter table ' + table_schema + '.' + table_name + ' #thesql# ' + constraint_name + ';'
					</cfif>
					altersql
					from information_schema.#thetbl#
					 where constraint_type='#thetype#' 
					 and (lower(table_name) like '%_images_text'
					 or  lower(table_name) like '%_audios_text'
					 or  lower(table_name) like '%_videos_text'
					 or  lower(table_name) like '%_files_desc')
				</cfquery>
				<cfloop query ="getdel_sql">
					<cfquery datasource="#application.razuna.datasource#" name="remove_constraint">
						#getdel_sql.altersql#
					</cfquery>
				</cfloop>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
				</cftry>

			<!--- RAZ-2819 Add a UPC column in database tables for all file types --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_images add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> IMG_UPC_NUMBER #thevarchar#(15)
				</cfquery>
			<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_audios add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> AUD_UPC_NUMBER #thevarchar#(15)
				</cfquery>
			<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_videos add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> VID_UPC_NUMBER #thevarchar#(15)
				</cfquery>
			<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_files add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> FILE_UPC_NUMBER #thevarchar#(15)
				</cfquery>
			<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_UPC_ENABLED #thevarchar#(5) DEFAULT 'false' 
				</cfquery>
			<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE groups add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> UPC_SIZE #thevarchar#(2) DEFAULT NULL
				</cfquery>
			<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE groups add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> UPC_FOLDER_FORMAT #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch><cfset thelog(logname=logname,thecatch=cfcatch)></cfcatch>
			</cftry>

			<!--- RAZ-2904 --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_versions add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> cloud_url_thumb #thevarchar#(500)
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			
			<!--- RAZ-2207 Set datatype to longtext for set2_labels_users--->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					alter table raz1_settings_2 <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column SET2_LABELS_USERS #theclob#<cfelse>change SET2_LABELS_USERS SET2_LABELS_USERS #theclob#</cfif>
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>

			<!--- RAZ-2839: Add a new column for additional version thumbnail url  --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_additional_versions add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> av_thumb_url #thevarchar#(500)
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			
			<!--- RAZ-2829: Add an expiration date to a user and disable access when expiration occurs --->
			       <cftry>
				         <cfquery datasource="#application.razuna.datasource#">
				         ALTER TABLE users add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> USER_EXPIRY_DATE  DATE<cfif application.razuna.thedatabase EQ "mssql">TIME</cfif> 
				         </cfquery>
				         <cfcatch type="any">
				           <cfset thelog(logname=logname,thecatch=cfcatch)>
				         </cfcatch>
			       </cftry>
			
		    	        <cftry>
				<!--- RAZ-2815 : Folder subscribe --->
				<cfquery datasource="#application.razuna.datasource#">
				CREATE TABLE raz1_folder_subscribe 
				(	
					fs_id 	 					#thevarchar#(100),
					host_id						#theint#,
					folder_id					#thevarchar#(100),
					user_id						#thevarchar#(100),
					mail_interval_in_hours		#theint#,
					last_mail_notification_time #thetimestamp#,
			 		PRIMARY KEY (fs_id)
				)
				#tableoptions#
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<!--- RAZ-2815 : Folder subscribe --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_folder_subscribe add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> asset_keywords #thevarchar#(3) DEFAULT 'F'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE raz1_folder_subscribe add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> asset_description #thevarchar#(3) DEFAULT 'F'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>

			<!--- Save Folder Subscribe scheduled event in CFML scheduling engine --->
			<cfschedule action="update"
				task="RazFolderSubscribe" 
				operation="HTTPRequest"
				url="#taskpath#/index.cfm?fa=c.folder_subscribe_task"
				startDate="#LSDateFormat(Now(), 'mm/dd/yyyy')#"
				startTime="00:01 AM"
				endTime="23:59 PM"
				interval="120"
			>
			<!--- RAZ-549 As a user I want to share a file URL with an expiration date --->
			<cfschedule action="update"
				task="RazAssetExpiry" 
				operation="HTTPRequest"
				url="#taskpath#/index.cfm?fa=c.w_asset_expiry_task"
				startDate="#LSDateFormat(Now(), 'mm/dd/yyyy')#"
				startTime="00:01 AM"
				endTime="23:59 PM"
				interval="300"
			>
			<!--- RAZ-2815 Add FOLDER_ID Column in raz1_log_assets --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_log_assets add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> FOLDER_ID #thevarchar#(100)
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<!--- RAZ-2541 Add column SET2_EMAIL_USE_SSL to raz1_settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_EMAIL_USE_SSL #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<!--- Add column SET2_EMAIL_USE_TLS to raz1_settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_EMAIL_USE_TLS #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<!--- RAZ-2837 Add column SET2_RENDITION_METADATA to raz1_settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_RENDITION_METADATA #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<!--- RAZ-2831 : Create EXPORT_TEMPLATE table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				CREATE TABLE raz1_export_template
				(
					exp_id				#thevarchar#(100),
					exp_field			#thevarchar#(200),
					exp_value			#thevarchar#(2000),
					exp_timestamp		#thetimestamp#, 
					user_id				#thevarchar#(100),
					host_id				#theint#,
					PRIMARY KEY (exp_id)
				)
				#tableoptions#
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>

		</cfif>
		
		<!--- If update number is lower then 17 (v. 1.6.2) --->
		<cfif updatenumber.opt_value LT 18>
			<!--- RAZ-2541 Add column SET2_EMAIL_USE_SSL to raz1_settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_EMAIL_USE_SSL #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<!--- Add column SET2_EMAIL_USE_TLS to raz1_settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> SET2_EMAIL_USE_TLS #thevarchar#(5) DEFAULT 'false'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>

		<!--- If update number is lower then 17 (v. 1.6.1) --->
		<cfif updatenumber.opt_value LT 17>
			<!--- RAZ-2519 Add column set2_custom_file_ext to raz1_settings_2 table --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE raz1_settings_2 add <cfif application.razuna.thedatabase NEQ "mssql">COLUMN</cfif> set2_custom_file_ext #thevarchar#(5) DEFAULT 'true'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
		</cfif>
		
		<!--- If update number is lower then 15 (v. 1.6) --->
		<cfif updatenumber.opt_value LT 15>

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
				update raz1_labels 
				set label_path = label_text 
				where label_id_r = '0'
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
				alter table raz1_versions add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> meta_data #theclob#
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
			<!--- Add sched_ad_user_groups Column in raz1_schedules --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_schedules add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> sched_ad_user_groups #theclob#
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
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_images SET is_indexed = '1'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_videos add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> is_indexed #thevarchar#(1) default '0'
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_videos SET is_indexed = '1'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_audios add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> is_indexed #thevarchar#(1) default '0'
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_audios SET is_indexed = '1'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_files add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> is_indexed #thevarchar#(1) default '0'
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE raz1_files SET is_indexed = '1'
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_images <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column img_custom_id <cfif application.razuna.thedatabase EQ "mssql">nvarchar<cfelse>#thevarchar#</cfif>(100)<cfelse>change img_custom_id img_custom_id #thevarchar#(100)</cfif>
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>

		</cfif>

		<!--- If update number is lower then 15 (v. 1.6) --->
		<cfif updatenumber.opt_value LT 16>

			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_images <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column img_meta #theclob#<cfelse>change img_meta img_meta #theclob#</cfif>
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_videos <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column vid_meta #theclob#<cfelse>change vid_meta vid_meta #theclob#</cfif>
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_audios <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column aud_meta #theclob#<cfelse>change aud_meta aud_meta #theclob#</cfif>
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_files <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column file_meta #theclob#<cfelse>change file_meta file_meta #theclob#</cfif>
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_versions <cfif application.razuna.thedatabase EQ "mssql" OR application.razuna.thedatabase EQ "h2">alter column meta_data #theclob#<cfelse>change meta_data meta_data #theclob#</cfif>
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>

			<!--- Add err_header column to raz1_errors--->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				alter table raz1_errors add <cfif application.razuna.thedatabase NEQ "mssql">column</cfif> err_header #thevarchar#(2000)
				</cfquery>
				<cfcatch type="any">
					<cfset thelog(logname=logname,thecatch=cfcatch)>
				</cfcatch>
			</cftry>

			<!--- Add indexing to scheduler --->
			<cfif !application.razuna.isp>
				<!--- Query host table --->
				<cfquery datasource="#application.razuna.datasource#" name="qry_hosts">
				SELECT host_id, host_path, host_shard_group
				FROM hosts
				WHERE ( host_shard_group IS NOT NULL OR host_shard_group <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> '' )
				</cfquery>
				<!--- Loop over hosts --->
				<cfloop query="qry_hosts">
					<!--- Check schedules table for existing record --->
					<cfquery datasource="#application.razuna.datasource#" name="qry_exists">
					SELECT sched_id
					FROM #host_shard_group#schedules
					WHERE sched_method = <cfqueryparam value="indexing" cfsqltype="cf_sql_varchar">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#host_id#">
					</cfquery>
					<!--- If record is found then no need to insert --->
					<cfif qry_exists.recordcount EQ 0>
						<cfset var newschid = createuuid()>
						<!--- Insert --->
						<cfquery datasource="#application.razuna.datasource#">
						INSERT INTO #host_shard_group#schedules 
						(sched_id, 
						 set2_id_r, 
						 sched_user, 
						 sched_method, 
						 sched_name,
						 sched_interval,
						 host_id,
						 sched_start_time,
						 sched_end_time,
						 sched_start_date
						)
						VALUES 
						(<cfqueryparam value="#newschid#" cfsqltype="CF_SQL_VARCHAR">, 
						 <cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
						 <cfqueryparam value="1" cfsqltype="CF_SQL_VARCHAR">, 
						 <cfqueryparam value="indexing" cfsqltype="cf_sql_varchar">, 
						 <cfqueryparam value="Indexing" cfsqltype="cf_sql_varchar">,
						 <cfqueryparam value="120" cfsqltype="cf_sql_varchar">,
						 <cfqueryparam cfsqltype="cf_sql_numeric" value="#host_id#">,
						 <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LSDateFormat(now(), "yyyy-mm-dd")# 00:01">,
						 <cfqueryparam cfsqltype="cf_sql_timestamp" value="#LSDateFormat(now(), "yyyy-mm-dd")# 23:59">,
						 <cfqueryparam cfsqltype="cf_sql_date" value="#LSDateFormat(now(), "yyyy-mm-dd")#">
						 )
						</cfquery>
						<!--- Save scheduled event in CFML scheduling engine --->
						<cfschedule action="update"
							task="RazScheduledUploadEvent[#newschid#]" 
							operation="HTTPRequest"
							url="#session.thehttp##cgi.http_host#/#cgi.context_path#/raz1/dam/index.cfm?fa=c.scheduler_doit&sched_id=#newschid#"
							startDate="#LSDateFormat(Now(), 'mm/dd/yyyy')#"
							startTime="00:01 AM"
							endTime="23:59 PM"
							interval="120"
						>
					</cfif>
				</cfloop>
			</cfif>
			
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
		
		</cfif>
		

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

		
		<!--- Update value in db --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE options
		SET opt_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dbupdateconfig#">
		WHERE lower(opt_id) = <cfqueryparam cfsqltype="cf_sql_varchar" value="dbupdate">
		</cfquery>
		<!--- Done --->
		<!--- Fix db integrity issues if any --->
		<cfset gobj.fixdbintegrityissues()>
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