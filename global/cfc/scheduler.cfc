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
<cfcomponent extends="extQueryCaching">

<!--- GET ALL SCHEDULED EVENTS ------------------------------------------------------------------>
<cffunction name="getAllEvents" returntype="query" output="true" access="public">
	<cfset var qry = "">
	<!--- Query to get all records --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT sched_id, sched_name, sched_method, sched_status
	FROM #session.hostdbprefix#schedules
	WHERE set2_id_r  = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY sched_name, sched_method
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- GET SCHEDULED EVENTS ------------------------------------------------------------------>
<cffunction name="getEvents" returntype="query" output="true" access="public">
	<!--- Query to get records for paging --->
	<cfinvoke method="getAllEvents" returnvariable="thetotal">
	<cfset var qry = "">
	<!--- Set the session for offset correctly if the total count of assets in lower the the total rowmaxpage --->
	<cfif thetotal.recordcount LTE session.rowmaxpage_sched>
		<cfset session.offset_sched = 0>
	</cfif>
	<cfif session.offset_sched EQ 0>
		<cfset var min = 0>
		<cfset var max = session.rowmaxpage_sched>
	<cfelse>
		<cfset var min = session.offset_sched * session.rowmaxpage_sched>
		<cfset var max = (session.offset_sched + 1) * session.rowmaxpage_sched>
	</cfif>
	<!--- MySQL Offset --->
	<cfset var mysqloffset = session.offset_sched * session.rowmaxpage_sched>
	<!--- Query to get records --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT <cfif variables.database EQ "mssql"> TOP #session.rowmaxpage_sched#</cfif> sched_id, sched_name, sched_method, sched_status,
		(
			SELECT count(sched_id)
			FROM #session.hostdbprefix#schedules
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		) as thetotal
		FROM #session.hostdbprefix#schedules
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif variables.database EQ "mssql">
			AND sched_id NOT IN 
			(
				SELECT TOP #min# sched_id
				FROM #session.hostdbprefix#schedules
				WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				ORDER BY sched_name, sched_method DESC
			)
		</cfif>
		GROUP BY sched_id, sched_name, sched_method, sched_status, host_id
		ORDER BY sched_name, sched_method DESC
		<cfif variables.database EQ "mysql" OR variables.database EQ "h2">
			LIMIT #mysqloffset#, #session.rowmaxpage_sched#
		</cfif>
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- SAVE SCHEDULED EVENT ----------------------------------------------------------------------->
<cffunction name="add" returntype="string" output="true" access="public">
	<cfargument name="thestruct" type="struct" required="yes">
	<!--- Param --->
	<cfparam default="0" name="arguments.thestruct.serverFolderRecurse">
	<cfparam default="0" name="arguments.thestruct.zipExtract">
	<cfparam default="" name="arguments.thestruct.upl_template">
	<!--- AD group users list --->
	<cfparam default="" name="arguments.thestruct.grp_id_assigneds">
	<cfparam default="1" name="session.theuserid">
	<cfset schedData.serverFolderRecurse = arguments.thestruct.serverFolderRecurse>
	<cfset schedData.zipExtract = arguments.thestruct.zipExtract>
	<cftry>
		<!--- Calculate the inverval and frequency for CF schedule --->
		<cfinvoke method="calculateInterval" returnvariable="schedData" thestruct="#arguments.thestruct#">
		<!--- Date and Time conversion (for CF Scheduler) --->
		<cfinvoke method="convertDateTime" returnvariable="schedData" thestruct="#arguments.thestruct#">
		<!--- Validate and initialise fields depending on upload method --->
		<cfinvoke method="initMethodFields" returnvariable="schedData" thestruct="#arguments.thestruct#">
		<!--- get next id --->
		<cfset var newschid = createuuid()>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#schedules 
		(sched_id, 
		 set2_id_r, 
		 sched_user, 
		 sched_method, 
		 sched_name, 
		 sched_folder_id_r, 
		 sched_zip_extract, 
		 sched_interval,
		 sched_server_folder, 
		 sched_server_recurse, 
		 sched_server_files, 
		 sched_mail_pop, 
		 sched_mail_user, 
		 sched_mail_pass, 
		 sched_mail_subject, 
		 sched_ftp_server, 
		 sched_ftp_user, 
		 sched_ftp_pass, 
		 sched_ftp_folder,
		 sched_ftp_email,
		 host_id,
		 sched_upl_template,
		 sched_ad_user_groups
		 <cfif schedData.ftpPassive is not "">, sched_ftp_passive</cfif> 
		 <cfif schedData.startDate is not "">, sched_start_date</cfif>
		 <cfif schedData.startTime is not "">, sched_start_time</cfif>
		 <cfif schedData.endDate is not "">, sched_end_date</cfif>
		 <cfif schedData.endTime is not "">, sched_end_time</cfif> 
		)
		VALUES 
		(<cfqueryparam value="#newschid#" cfsqltype="CF_SQL_VARCHAR">, 
		 <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">, 
		 <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
		 <cfqueryparam value="#schedData.method#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.taskName#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.folder_id#" cfsqltype="CF_SQL_VARCHAR">, 
		 <cfqueryparam value="#schedData.zipExtract#" cfsqltype="cf_sql_numeric">, 
		 <cfqueryparam value="#schedData.interval#" cfsqltype="cf_sql_varchar">,
		 <cfqueryparam value="#schedData.serverFolder#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.serverFolderRecurse#" cfsqltype="cf_sql_numeric">, 
		 <cfqueryparam value="1" cfsqltype="cf_sql_numeric">, 
		 <cfqueryparam value="#schedData.mailPop#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.mailUser#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.mailPass#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.mailSubject#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.ftpServer#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.ftpUser#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.ftpPass#" cfsqltype="cf_sql_varchar">, 
		 <cfqueryparam value="#schedData.ftpFolder#" cfsqltype="cf_sql_varchar">,
		 <cfqueryparam value="#schedData.ftpemails#" cfsqltype="cf_sql_varchar">,
		 <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		 <cfqueryparam value="#arguments.thestruct.upl_template#" cfsqltype="cf_sql_varchar">,
		 <cfqueryparam value="#arguments.thestruct.grp_id_assigneds#" cfsqltype="cf_sql_varchar">
		 <cfif schedData.ftpPassive is not "">, <cfqueryparam value="#schedData.ftpPassive#" cfsqltype="cf_sql_numeric"></cfif> 
		 <cfif schedData.startDate is not "">, <cfqueryparam value="#schedData.startDate#" cfsqltype="cf_sql_date"></cfif>
		 <cfif schedData.startTime is not "">, <cfqueryparam value="#schedData.startTime#" cfsqltype="cf_sql_timestamp"></cfif>
		 <cfif schedData.endDate is not "">, <cfqueryparam value="#schedData.endDate#" cfsqltype="cf_sql_date"></cfif>
		 <cfif schedData.endTime is not "">, <cfqueryparam value="#schedData.endTime#" cfsqltype="cf_sql_timestamp"></cfif> )
		</cfquery>
		<!--- Get Server URL --->
		<cfset serverUrl = "#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#">
		<!--- Save scheduled event in CFML scheduling engine --->
		<cfschedule action="update"
					task="RazScheduledUploadEvent[#newschid#]" 
					operation="HTTPRequest"
					url="#serverUrl#?fa=c.scheduler_doit&sched_id=#newschid#"
					startDate="#schedData.startDate#"
					startTime="#schedData.startTime#"
					endDate="#schedData.endDate#"
					endTime="#schedData.endTime#"
					interval="#schedData.interval#">
		<!--- Log the insert --->
		<cfinvoke method="tolog" theschedid="#newschid#" theuserid="#session.theuserid#" theaction="Insert" thedesc="Scheduled Task successfully saved">
		<cfcatch>
			<cfset cfcatch.custom_message = "Error in function scheduler.add">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- CALCULATE THE INTERVAL --------------------------------------------------------------------->
<cffunction name="calculateInterval" returntype="Struct" output="true" access="private">
	<cfargument name="thestruct" type="Struct" required="yes">
	<!--- Calculate the interval parameter for CF schedule --->
	<!--- Frequency: one-time --->
	<cfif arguments.thestruct.frequency EQ 1>
		<cfset arguments.thestruct.interval  = "once">
		<cfset arguments.thestruct.startTime = arguments.thestruct.startTime1>
		<!--- <cfset arguments.thestruct.endTime   = ""> --->
	<!--- Frequency: recurring --->
	<cfelseif arguments.thestruct.frequency EQ 2>
		<cfif arguments.thestruct.recurring EQ "daily">
			<cfset arguments.thestruct.interval = "daily">
		<cfelseif arguments.thestruct.recurring EQ "weekly">
			<cfset arguments.thestruct.interval = "weekly">
		<cfelseif arguments.thestruct.recurring EQ "monthly">
			<cfset arguments.thestruct.interval = "monthly">
		</cfif>
		<cfset arguments.thestruct.startTime = arguments.thestruct.startTime2>
		<!--- <cfset arguments.thestruct.endTime   = ""> --->
	<!--- Frequency: daily every --->
	<cfelseif arguments.thestruct.frequency EQ 3>
		<cfif arguments.thestruct.hours NEQ ""><cfset hours = arguments.thestruct.hours * 3600><cfelse><cfset hours = 0></cfif>
		<cfif arguments.thestruct.minutes NEQ ""><cfset minutes = arguments.thestruct.minutes * 60><cfelse><cfset minutes = 0></cfif>
		<cfif arguments.thestruct.seconds NEQ ""><cfset seconds = arguments.thestruct.seconds><cfelse><cfset seconds = 0></cfif>
		<cfset arguments.thestruct.interval  = hours + minutes + seconds>
		<!--- If we still have 0 as the interval it will trhow an error, thus we set it to daily --->
		<cfif arguments.thestruct.interval EQ 0>
			<cfset arguments.thestruct.interval = "daily">
		</cfif>
		<cfset arguments.thestruct.startTime = arguments.thestruct.startTime3>
	</cfif>
	<cfreturn arguments.thestruct>
</cffunction>

<!--- CONVERT DATE AND TIME FOR CF SCHEDULER ----------------------------------------------------->
<cffunction name="convertDateTime" returntype="Struct" output="true" access="private">
	<cfargument name="thestruct" type="Struct" required="yes">
	<!--- Date and Time conversion --->
	<cfif arguments.thestruct.startDate NEQ "">
		<!--- For Windows the LSDateFormat needs the date to have a time included or else it fails --->
		<cfset var startdate = "#arguments.thestruct.startDate# #arguments.thestruct.startTime#:00">
		<cfset startdate = parsedatetime("#startdate#")>
		<cfset arguments.thestruct.startDate = LSDateFormat(startdate, "mm/dd/yyyy")>
	</cfif>
	<cfif arguments.thestruct.startTime NEQ "">
		<cfset arguments.thestruct.startTime = LSTimeFormat(arguments.thestruct.startTime, "HH:mm")>
	</cfif>
	<cfif arguments.thestruct.endDate NEQ "">
		<!--- For Windows the LSDateFormat needs the date to have a time included or else it fails --->
		<cfif arguments.thestruct.endTime EQ "">
			<cfset var endtime = "00:00">
		<cfelse>
			<cfset var endtime = arguments.thestruct.endTime>
		</cfif>
		<cfset var enddate = "#arguments.thestruct.endDate# #endTime#:00">
		<cfset enddate = parsedatetime("#enddate#")>
		<cfset arguments.thestruct.endDate = LSDateFormat(enddate, "mm/dd/yyyy")>
	</cfif>
	<cfif arguments.thestruct.endTime NEQ "">
		<cfset arguments.thestruct.endTime = LSTimeFormat(arguments.thestruct.endTime, "HH:mm")>
	</cfif>
	<cfreturn arguments.thestruct>
</cffunction>

<!--- VALIDATE AND INITIALISE FIELDS DEPENDING ON THE UPLOAD METHOD ------------------------------>
<cffunction name="initMethodFields" returntype="Struct" output="true" access="private">
	<cfargument name="thestruct" type="Struct" required="yes">
	<!--- Initialise unused fields --->
	<cfparam name="arguments.thestruct.mailPop" default="">
	<cfparam name="arguments.thestruct.mailUser" default="">
	<cfparam name="arguments.thestruct.mailPass" default="">
	<cfparam name="arguments.thestruct.mailSubject" default="">
	<cfparam name="arguments.thestruct.ftpServer" default="">
	<cfparam name="arguments.thestruct.ftpUser" default="">
	<cfparam name="arguments.thestruct.ftpPass" default="">
	<cfparam name="arguments.thestruct.ftpPassive" default="">
	<cfparam name="arguments.thestruct.ftpFolder" default="">
	<cfparam name="arguments.thestruct.serverFolder" default="">
	<cfparam name="arguments.thestruct.mailPop" default="">
	<cfparam name="arguments.thestruct.mailUser" default="">
	<cfparam name="arguments.thestruct.mailPass" default="">
	<cfparam name="arguments.thestruct.mailSubject" default="">
	<cfparam name="arguments.thestruct.serverFolder" default="">
	<cfparam name="arguments.thestruct.ftpServer" default="">
	<cfparam name="arguments.thestruct.ftpUser" default="">
	<cfparam name="arguments.thestruct.ftpPass" default="">
	<cfparam name="arguments.thestruct.ftpPassive" default="">
	<cfparam name="arguments.thestruct.ftpFolder" default="">
	<cfreturn arguments.thestruct>
</cffunction>

<!--- ADD A NEW RECORD TO THE SCHEDULER-LOG ------------------------------------------------------>
<cffunction name="tolog" output="true" access="public">
	<cfargument name="theschedid" default=""  required="yes" type="string">
	<cfargument name="theuserid"  default="0" required="no"  type="string">
	<cfargument name="theaction"  default=""  required="yes" type="string">
	<cfargument name="thedesc"    default=""  required="yes" type="string">
	<cftry>
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#schedules_log
		(sched_log_id, sched_id_r, sched_log_action, sched_log_date, 
		sched_log_time, sched_log_desc<cfif structkeyexists(arguments,"theuserid")>, sched_log_user</cfif>, host_id)
		VALUES 
		(
		<cfqueryparam value="#createuuid()#" cfsqltype="CF_SQL_VARCHAR">, 
		<cfqueryparam value="#arguments.theschedid#" cfsqltype="CF_SQL_VARCHAR">, 
		<cfqueryparam value="#arguments.theaction#" cfsqltype="cf_sql_varchar">, 
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">, 
		<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, 
		<cfqueryparam value="#arguments.thedesc#" cfsqltype="cf_sql_varchar">
		<cfif structkeyexists(arguments,"theuserid")>,<cfqueryparam value="#arguments.theuserid#" cfsqltype="CF_SQL_VARCHAR"></cfif>,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		)
		</cfquery>
		<cfset variables.cachetoken = resetcachetoken("logs")>
		<cfcatch type="database">
			<cfset cfcatch.custom_message = "Database error in function scheduler.tolog">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
</cffunction>

<!--- DELETE SCHEDULED EVENT --------------------------------------------------------------------->
<cffunction name="remove" output="true" access="public">
	<cfargument name="sched_id"   type="string" required="yes" default="">
	<!--- append to the DB --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#schedules
	WHERE sched_id = <cfqueryparam value="#arguments.sched_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Delete scheduled event from CF scheduling engine --->
	<cfschedule action="delete" task="RazScheduledUploadEvent[#arguments.sched_id#]">
	<cfreturn />
</cffunction>

<!--- GET DETAIL OF ONE SCHEDULED EVENT ---------------------------------------------------------->
<cffunction name="detail" returntype="query" output="true" access="public">
	<cfargument name="sched_id" type="string" required="yes">
	<!--- Param --->
	<cfset var qSchedDetail = "">
	<!--- Query to get all records --->
	<cfquery datasource="#application.razuna.datasource#" name="qSchedDetail">
	SELECT s.sched_id, s.set2_id_r, s.sched_user, s.sched_status, s.sched_method, s.sched_name,
	s.sched_folder_id_r, s.sched_zip_extract, s.sched_server_folder, s.sched_mail_pop, s.sched_mail_user,
	s.sched_mail_pass, s.sched_mail_subject, s.sched_ftp_server, s.sched_ftp_user, s.sched_ftp_pass,
	s.sched_ftp_folder, s.sched_interval, s.sched_start_date, s.sched_start_time, s.sched_end_date,
	s.sched_end_time, s.sched_ftp_passive, s.sched_server_recurse, s.sched_server_files, s.sched_upl_template,
	s.sched_ad_user_groups, s.host_id,s.sched_ftp_email,
	f.folder_name as folder_name
	FROM #session.hostdbprefix#schedules s LEFT JOIN #session.hostdbprefix#folders f ON s.sched_folder_id_r = f.folder_id AND f.host_id = s.host_id
	WHERE s.sched_id = <cfqueryparam value="#arguments.sched_id#" cfsqltype="CF_SQL_VARCHAR">
	AND s.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<cfreturn qSchedDetail>
</cffunction>

<!--- UPDATE --------------------------------------------------------------------->
<cffunction name="update" returntype="string" output="true" access="public">
	<cfargument name="thestruct" type="struct" required="yes">
	
	<!--- Param --->
	<cfparam default="0" name="arguments.thestruct.serverFolderRecurse">
	<cfparam default="0" name="arguments.thestruct.zipExtract">
	<cfparam default="0" name="arguments.thestruct.upl_template">
	<cfparam default="" name="arguments.thestruct.grp_id_assigneds">
	
	<cfset schedData.serverFolderRecurse = arguments.thestruct.serverFolderRecurse>
	<cfset schedData.zipExtract = arguments.thestruct.zipExtract>
	<cftry>
		<!--- Calculate the inverval and frequency for CF schedule --->
		<cfinvoke method="calculateInterval" returnvariable="schedData" thestruct="#arguments.thestruct#">
		<!--- Date and Time conversion (for CF Scheduler) --->
		<cfinvoke method="convertDateTime" returnvariable="schedData" thestruct="#arguments.thestruct#">
		<!--- Validate and initialise fields depending on upload method --->
		<cfinvoke method="initMethodFields" returnvariable="schedData" thestruct="#arguments.thestruct#">
		<!--- append to the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#schedules
		SET    
		set2_id_r = <cfqueryparam value="#application.razuna.setid#" cfsqltype="cf_sql_numeric">, 
		sched_user = <cfqueryparam value="#session.theuserid#" cfsqltype="CF_SQL_VARCHAR">, 
		sched_method = <cfqueryparam value="#schedData.method#" cfsqltype="cf_sql_varchar">,
		sched_name = <cfqueryparam value="#schedData.taskName#" cfsqltype="cf_sql_varchar">,
		sched_folder_id_r = <cfqueryparam value="#schedData.folder_id#" cfsqltype="CF_SQL_VARCHAR">,
		sched_zip_extract = <cfqueryparam value="#schedData.zipExtract#" cfsqltype="cf_sql_varchar">, 
		sched_interval = <cfqueryparam value="#schedData.interval#" cfsqltype="cf_sql_varchar">,
		sched_server_folder = <cfqueryparam value="#schedData.serverFolder#" cfsqltype="cf_sql_varchar">,
		sched_server_recurse = <cfqueryparam value="#schedData.serverFolderRecurse#" cfsqltype="cf_sql_numeric">,
		<!--- sched_server_files = <cfqueryparam value="#schedData.serverFiles#" cfsqltype="cf_sql_numeric">, ---> 
		sched_mail_pop = <cfqueryparam value="#schedData.mailPop#" cfsqltype="cf_sql_varchar">, 
		sched_mail_user = <cfqueryparam value="#schedData.mailUser#" cfsqltype="cf_sql_varchar">, 
		sched_mail_pass = <cfqueryparam value="#schedData.mailPass#" cfsqltype="cf_sql_varchar">, 
		sched_mail_subject = <cfqueryparam value="#schedData.mailSubject#" cfsqltype="cf_sql_varchar">, 
		sched_ftp_server = <cfqueryparam value="#schedData.ftpServer#" cfsqltype="cf_sql_varchar">, 
		sched_ftp_user = <cfqueryparam value="#schedData.ftpUser#" cfsqltype="cf_sql_varchar">, 
		sched_ftp_pass = <cfqueryparam value="#schedData.ftpPass#" cfsqltype="cf_sql_varchar">, 
		sched_ftp_folder = <cfqueryparam value="#schedData.ftpFolder#" cfsqltype="cf_sql_varchar">,
		sched_ftp_email = <cfqueryparam value="#schedData.ftpemails#" cfsqltype="cf_sql_varchar">,
		sched_upl_template = <cfqueryparam value="#arguments.thestruct.upl_template#" cfsqltype="cf_sql_varchar">,
		sched_ad_user_groups = <cfqueryparam value="#arguments.thestruct.grp_id_assigneds#" cfsqltype="cf_sql_varchar">,
		sched_ftp_passive = 
		<cfif schedData.ftpPassive is not "">
			<cfqueryparam value="#schedData.ftpPassive#" cfsqltype="cf_sql_numeric">
		<cfelse>
			<cfqueryparam value="0" cfsqltype="cf_sql_numeric">
		</cfif>, 
		sched_start_date = 
		<cfif schedData.startDate is not "">
			<cfqueryparam value="#schedData.startDate#" cfsqltype="cf_sql_date">
		<cfelse>
			<cfqueryparam value="#schedData.startDate#" cfsqltype="cf_sql_date" null="true">
		</cfif>,
		sched_start_time = 
		<cfif schedData.startTime is not "">
			<cfqueryparam value="#schedData.startTime#" cfsqltype="cf_sql_timestamp">
		<cfelse>
			<cfqueryparam value="#schedData.startTime#" cfsqltype="cf_sql_timestamp" null="true">
		</cfif>,
		sched_end_date = 
		<cfif schedData.endDate is not "">
			<cfqueryparam value="#schedData.endDate#" cfsqltype="cf_sql_date">
		<cfelse>
			<cfqueryparam value="#schedData.endDate#" cfsqltype="cf_sql_date" null="true">
		</cfif>,
		sched_end_time = 
		<cfif schedData.endTime is not "">
			<cfqueryparam value="#schedData.endTime#" cfsqltype="cf_sql_timestamp">
		<cfelse>
			<cfqueryparam value="#schedData.endTime#" cfsqltype="cf_sql_timestamp" null="true">
		</cfif>
		WHERE sched_id = <cfqueryparam value="#schedData.sched_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfset serverUrl = "#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#">
		<!--- Update scheduled event in CF scheduling engine --->
		<cfschedule action="update"
			task="RazScheduledUploadEvent[#schedData.sched_id#]" 
			operation="HTTPRequest"
			url="#serverUrl#?fa=c.scheduler_doit&sched_id=#schedData.sched_id#"
			startDate="#schedData.startDate#"
			startTime="#schedData.startTime#"
			endDate="#schedData.endDate#"
			endTime="#schedData.endTime#"
			interval="#schedData.interval#">
		<!--- Log the update --->
		<cfinvoke method="tolog" theschedid="#schedData.sched_id#" theuserid="#session.theuserid#" theaction="Update" thedesc="Scheduled Task successfully updated">
		<cfcatch>
			<!--- Log the error --->
			<cfset cfcatch.custom_message = "Error in function scheduler.update">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<cfreturn />
</cffunction>

<!--- RECURSE THROUGH THE FOLDERS OF THIS HOST --------------------------------------------------->
<cffunction name="listServerFolder" returntype="query" output="true" access="public">
	<cfargument name="thepath" type="string" default="">
	<cfargument name="thecount" type="numeric" default="0">
	<cfargument name="thedirstring" type="string" default="" required="no">
	<cfargument name="qReturn" type="query" required="no" default="#QueryNew("path,name")#">
	<!--- Function internal variables --->
	<cfset var qReturnSub = 0>
	<cfset var thedirs = 0>
	<cfset var count = 1 + #arguments.thecount#>
	<cfset var foldername = "">
	<cfset var thisdir = "">
	<!--- Start receiving server folder input --->
	<cfdirectory action="list" directory="#arguments.thepath#" name="thedirs" sort="name ASC" type="dir" recurse="false">
	<cfoutput query="thedirs">
		<cfif type EQ "Dir" AND NOT name CONTAINS "outgoing" AND NOT name CONTAINS "controller" AND NOT name CONTAINS "js" AND NOT name CONTAINS "images" AND NOT name CONTAINS "model" AND NOT name CONTAINS "cvs" AND NOT name CONTAINS ".svn" AND NOT name CONTAINS "parsed" AND NOT name CONTAINS "translations" AND NOT name CONTAINS "views" AND NOT name CONTAINS "global" AND NOT name CONTAINS "bluedragon" AND NOT name CONTAINS "WEB-INF" AND NOT name CONTAINS ".git" AND NOT name CONTAINS "incoming" AND NOT name CONTAINS "backup">
			<cfif count GT 1>
				<cfset foldername = insert(RepeatString("--", count-1) & " ", name, 0)>
			<cfelse>
				<cfset foldername = "<b>#name#</b>">
			</cfif>
			<cfif arguments.thedirstring EQ "">
				<cfset thisdir = "#name#">
			<cfelse>
				<cfset thisdir = "#arguments.thedirstring#/#name#">
			</cfif>
			<cfset QueryAddRow(Arguments.qReturn,1)>
			<cfset QuerySetCell(Arguments.qReturn, "path", "#arguments.thepath#/#name#")>
			<cfset QuerySetCell(Arguments.qReturn, "name", "#foldername#")>
			<!--- call me again to guarantee recursive loop --->
			<cfinvoke method="listServerFolder" returnvariable="Arguments.qReturn">
				<cfinvokeargument name="thepath" value="#arguments.thepath#/#name#">
				<cfinvokeargument name="thecount" value="#count#">
				<cfinvokeargument name="thedirstring" value="#thisdir#">
				<cfinvokeargument name="qReturn" value="#Arguments.qReturn#">
			</cfinvoke>
		</cfif>
	</cfoutput>
	<cfreturn Arguments.qReturn>
</cffunction>

<!--- RUN SCHEDULED EVENT ------------------------------------------------------------------------>
<cffunction name="run" returntype="string" output="true" access="public">
	<cfargument name="sched_id" type="string" required="yes" default="">
	<cfset var returncode = "success_run">
	<cftry>
		<!--- Run --->
		<cfschedule action="run" task="RazScheduledUploadEvent[#arguments.sched_id#]">
		<!--- Log --->
		<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theuserid="#session.theuserid#" theaction="Run" thedesc="Scheduled Task successfully run">
		<cfcatch>
			<!--- Log the error --->
			<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theuserid="#session.theuserid#" theaction="Run" thedesc="Scheduled Task failed while running [#cfcatch.type# - #cfcatch.message#]">
			<cfset returncode = "sched_error">
			<cfset cfcatch.custom_message = "Error in function scheduler.run">
			<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>		
		</cfcatch>
	</cftry>
	<cfreturn returncode>
</cffunction>

<!--- GET LOG ENTRIES FOR SCHEDULED EVENT -------------------------------------------------------->
<cffunction name="getlog" returntype="query" output="true" access="public">
	<cfargument name="sched_id"   type="string" required="yes" default="">
	<cfset var qry = "">
	<!--- Query to get all records --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT l.sched_log_date, l.sched_log_time, l.sched_log_desc, l.sched_log_action, l.sched_log_user, u.user_login_name
	FROM #session.hostdbprefix#schedules_log l, users u
	WHERE l.sched_id_r = <cfqueryparam value="#arguments.sched_id#" cfsqltype="CF_SQL_VARCHAR">
	AND l.sched_log_user = u.user_id <!--- (+) --->
	ORDER BY sched_log_date DESC, sched_log_time DESC, sched_log_id DESC
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- REMOVE LOG -------------------------------------------------------->
<cffunction name="removelog" returntype="query" output="true" access="public">
	<cfargument name="sched_id"   type="string" required="yes" default="">
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#schedules_log
	WHERE sched_id_r = <cfqueryparam value="#arguments.sched_id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
</cffunction>

<!--- RUN SCHEDULE -------------------------------------------------------->
<cffunction name="doit" output="true" access="public" >
	<cfargument name="sched_id" type="string" required="yes">
	<cfargument name="incomingpath" type="string" required="yes">
	<cfargument name="sched" type="string" required="yes">
	<cfargument name="thepath" type="string" required="yes">
	<cfargument name="langcount" type="string" required="yes">
	<cfargument name="rootpath" type="string" required="yes">
	<cfargument name="assetpath" type="string" required="yes">
	<cfargument name="dynpath" type="string" required="yes">
	<cfargument name="ad_server_name" type="string" required="false" default="">
	<cfargument name="ad_server_port" type="string" required="false" default="">
	<cfargument name="ad_server_username" type="string" required="false" default="">
	<cfargument name="ad_server_password" type="string" required="false" default="">
	<cfargument name="ad_server_filter" type="string" required="false" default="">
	<cfargument name="ad_server_start" type="string" required="false" default="">
	<cfargument name="ad_ldap" type="string" required="false" default="">
	<cfargument name="ad_domain" type="string" required="false" default="">
	<cfargument name="ldap_dn" type="string" required="false" default="">
	<!--- Param --->
	<cfset var doit = structnew()>
	<cfset var x = structnew()>
	<cfset doit.dirlist = "">
	<cfset doit.directoryList = "">
	<cfset var dorecursive = false>
	<cfset var dirhere = "">
	<cfset var qry = "">
	<!--- Set arguments into new struct --->
	<cfset x.sched_id = arguments.sched_id>
	<cfset x.incomingpath = arguments.incomingpath>
	<cfset x.sched = arguments.sched>
	<cfset x.thepath = arguments.thepath>
	<cfset x.langcount = arguments.langcount>
	<cfset x.rootpath = arguments.rootpath>
	<cfset x.assetpath = arguments.assetpath>
	<cfset x.dynpath = arguments.dynpath>
	<!--- Get details of this schedule --->
	<cfinvoke method="detail" sched_id="#arguments.sched_id#" returnvariable="doit.qry_detail">
	<!-- Set return into scope -->
	<cfset x.folder_id = doit.qry_detail.sched_folder_id_r>
	<cfset x.sched_action = doit.qry_detail.sched_server_files>
	<cfset x.upl_template = doit.qry_detail.sched_upl_template>
	<cfset x.directory = doit.qry_detail.sched_server_folder>
	<cfset x.recurse = doit.qry_detail.sched_server_recurse>
	<cfset x.zip_extract = doit.qry_detail.sched_zip_extract>
	<cfset session.theuserid = doit.qry_detail.sched_user>
	<!-- Get AWS Bucket -->
	<cfinvoke component="global.cfc.settings" method="prefs_storage" returnvariable="qry_storage" />
	<!-- Set bucket -->
	<cfset x.awsbucket  = qry_storage.set2_aws_bucket />
	<!--- If no record found simply abort --->
	<cfif doit.qry_detail.recordcount EQ 0>
		<cfabort>
	<!--- Record found --->
	<cfelse>
		<!--- SERVER --->
		<cfif doit.qry_detail.sched_method EQ "server">
			<!--- 
			<!--- Look into the directory --->
			<cfdirectory action="list" directory="#doit.qry_detail.sched_server_folder#" recurse="false" name="dirhere" />
			<!--- Filter content --->
			<cfquery dbtype="query" name="dirhere">
			SELECT *
			FROM dirhere
			WHERE size != 0
			AND attributes != 'H'
			AND name != 'thumbs.db'
			AND name NOT LIKE '.DS_STORE%'
			AND name NOT LIKE '__MACOSX%'
			AND name != '.svn'
			AND name != '.git'
			</cfquery>
			<!--- NO files here simply abort --->
			<cfif dirhere.recordcount EQ 0>
				<cfabort>
			</cfif>
			<!--- Files here thus... --->
			<!--- Get the name of the original directory --->
			<cfset var thedirname = listlast(doit.qry_detail.sched_server_folder,"/\")>
			<!--- The path without the name --->
			<cfset var thedirpath = replacenocase(doit.qry_detail.sched_server_folder,thedirname,"","one")>
			<!--- Create a temp directory name --->
			<cfset var tempid = createuuid("")>
			<cfset var tempdir = thedirpath & "task_" & tempid>
			<!--- Now rename the original directory --->
			<cfdirectory action="rename" directory="#doit.qry_detail.sched_server_folder#" newdirectory="#tempdir#" mode="775" />
			<!--- and recreate the original directory --->
			<cfif !directoryExists(doit.qry_detail.sched_server_folder)>
				<cfdirectory action="create" directory="#doit.qry_detail.sched_server_folder#" mode="775" />
			</cfif>
			<!--- Set the qry to the new directory --->
			<cfset QuerySetcell( doit.qry_detail, "sched_server_folder", "#tempdir#" )>
			<!--- Sleep the process (just making sure that the rename had enough time) --->
			<cfset sleep(5000)>
			 --->
			<!-- CFC: Log start -->
			<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theaction="Upload" thedesc="Start Processing Scheduled Task" />
			<!-- Set params for adding assets -->
			<cfset x.thefile = doit.dirlist>
			<!-- CFC: Add to system -->
			<cfinvoke component="assets" method="addassetscheduledserverthread" thestruct="#x#" />
		<!--- FTP --->
		<cfelseif doit.qry_detail.sched_method EQ "ftp">
			<!-- Params -->
			<cfset session.ftp_server = doit.qry_detail.sched_ftp_server>
			<cfset session.ftp_user = doit.qry_detail.sched_ftp_user>
			<cfset session.ftp_pass = doit.qry_detail.sched_ftp_pass>
			<cfset session.ftp_passive = doit.qry_detail.sched_ftp_passive>
			<cfset x.filesonly = true> <!--- For scheduled upload we only upload files in folder and ignore any subfolders --->
			<cfset x.folderpath   = doit.qry_detail.sched_ftp_folder> <!--- Set path to folder --->
			<!-- CFC: Get FTP directory for adding to the system -->
			<cfinvoke component="ftp" method="getdirectory" thestruct="#x#" returnvariable="thefiles" />
			<cfif isdefined("thefiles.ftplist.name")>
				<cfset x.thefile = valuelist(thefiles.ftplist.name) />
				<!-- CFC: Add to system -->
				<cfinvoke component="assets" method="addassetftpthread" thestruct="#x#" />
			</cfif>
		<!--- MAIL --->
		<cfelseif doit.qry_detail.sched_method EQ "mail">
			<!-- Params -->
			<cfset x.email_server = doit.qry_detail.sched_mail_pop>
			<cfset x.email_address = doit.qry_detail.sched_mail_user>
			<cfset x.email_pass = doit.qry_detail.sched_mail_pass>
			<cfset x.email_subject = doit.qry_detail.sched_mail_subject>
			<cfset session.email_server = doit.qry_detail.sched_mail_pop>
			<cfset session.email_address = doit.qry_detail.sched_mail_user>
			<cfset session.email_pass = doit.qry_detail.sched_mail_pass>
			<!-- CFC: Get the email ids for adding to the system -->
			<cfinvoke component="email" method="emailheaders" thestruct="#x#" returnvariable="themails" />
			<cfset x.emailid = valuelist(themails.qryheaders.messagenumber)>
			<!-- CFC: Add to system -->
			<cfinvoke component="assets" method="addassetemail" thestruct="#x#" />
		<!--- AD Server --->
		<cfelseif doit.qry_detail.sched_method EQ "ADServer">
			<!--- Get LDAP User list --->
				
			<cfinvoke component="global.cfc.settings" method="get_ad_server_userlist"  returnvariable="results"  thestruct="#arguments#">
			<cfif results.recordcount NEQ 0>
				<cfset emailList = valuelist(results.mail)>
				<cfquery datasource="#application.razuna.datasource#" name="qry">
					SELECT u.user_email
					FROM users u, ct_users_hosts ct
					WHERE lower(u.user_email) in (<cfqueryparam value="#lcase(emailList)#" cfsqltype="cf_sql_varchar" list="true">)
					AND ct.ct_u_h_host_id = <cfqueryparam value="#doit.qry_detail.host_id#" cfsqltype="cf_sql_numeric">
					AND ct.ct_u_h_user_id = u.user_id
				</cfquery>
				<cfset var adlist = quotedvaluelist(qry.user_email)>
				<cfquery dbtype="query" name="qryResults">
					select * from results
					where mail not in ('#adlist#')
				</cfquery>
				<cfif qryResults.recordcount NEQ 0>
					<cfloop query="qryResults" >
						<cfset arguments.thestruct.user_first_name = qryResults.givenname>
						<cfset arguments.thestruct.user_last_name = qryResults.sn>
						<cfset arguments.thestruct.intrauser = "T">
						<cfset arguments.thestruct.user_active = "T">
						<cfset arguments.thestruct.user_pass = "">
						<cfset arguments.thestruct.hostid = doit.qry_detail.host_id>
						<cfset arguments.thestruct.user_login_name = qryResults.SamAccountname>
						<cfset arguments.thestruct.user_email = qryResults.mail>
						<cfset arguments.thestruct.grp_id_assigneds = doit.qry_detail.sched_ad_user_groups>
						<cfif arguments.thestruct.user_login_name NEQ '' OR arguments.thestruct.user_email NEQ ''> 
							<cfinvoke component="global.cfc.users" method="add"  thestruct="#arguments.thestruct#">
						</cfif>
					</cfloop> 
					<!-- CFC: Log start -->
					<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theaction="Upload" thedesc="Start Processing Scheduled Task" />
				</cfif>
			</cfif>
		<!--- Rebuild search index --->	
		<cfelseif doit.qry_detail.sched_method EQ "rebuild">
			<!-- CFC: Log start -->
			<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theaction="Upload" thedesc="Started rebuilding" />
			<!-- CFC: Call indexing -->
			<cfinvoke component="lucene" method="index_update" thestruct="#x#" assetid="all" />
		<!--- Rebuild search index --->
		<cfelseif doit.qry_detail.sched_method EQ "indexing">
			<!-- CFC: Log start -->
			<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theaction="Upload" thedesc="Started indexing" />
			<!-- CFC: Call indexing -->
			<cfinvoke component="lucene" method="index_update" thestruct="#x#" />
		</cfif>
	</cfif>
	<cfreturn doit>
</cffunction>

<!--- RUN FOLDER SUBSCRIBE SCHEDULE -------------------------------------------------------->
<cffunction name="folder_subscribe_task" output="true" access="public" >
	<!--- Only run this code between 1am - 2am. This will give people time to correct any mistakes they migth have made before we delete the entries.  --->
	<cfif hour(now()) EQ '1'>
		<!--- Delete Users that no longer have permissions to access the folder to whom they were subscribed --->
		<cfquery datasource="#application.razuna.datasource#" name="getusers_wo_access">
			SELECT  f.folder_id,u.user_id
			FROM #session.hostdbprefix#folders f 
			INNER JOIN #session.hostdbprefix#folder_subscribe fs ON f.folder_id = fs.folder_id
			INNER JOIN users u ON u.user_id = fs.user_id
			WHERE
			<!--- User is not administrator --->
			NOT EXISTS (SELECT 1 FROM ct_groups_users cu WHERE cu.ct_g_u_user_id = fs.user_id AND cu.ct_g_u_grp_id in ('1','2'))
			<!--- User is not folder_owner --->
			AND f.folder_owner <>  fs.user_id 
			 <!--- Folder is not shared with everybody --->
			AND NOT EXISTS (SELECT 1 FROM #session.hostdbprefix#folders_groups fg WHERE f.folder_id = fg.folder_id_r AND fg.grp_id_r = '0') 
			<!--- User is not part of group that has access to folder --->
			AND NOT EXISTS (SELECT 1 FROM ct_groups_users cu, #session.hostdbprefix#folders_groups g WHERE cu.ct_g_u_user_id = fs.user_id AND cu.ct_g_u_grp_id = g.grp_id_r AND f.folder_id = g.folder_id_r) 
		</cfquery>
		<cfloop query="getusers_wo_access">
			<cfquery datasource="#application.razuna.datasource#">
			DELETE
			FROM #session.hostdbprefix#folder_subscribe
			WHERE folder_id = <cfqueryparam value="#getusers_wo_access.folder_id#" cfsqltype="cf_sql_varchar">
			AND user_id = <cfqueryparam value="#getusers_wo_access.user_id#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfloop>
	</cfif>

	<!--- Get User subscribed folders --->
	<cfquery datasource="#application.razuna.datasource#" name="qGetUserSubscriptions">
		SELECT fs.*, fo.folder_name FROM #session.hostdbprefix#folder_subscribe fs
		LEFT JOIN #session.hostdbprefix#folders fo ON fs.folder_id = fo.folder_id
		WHERE 
		<!--- H2 or MSSQL --->
		<cfif application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "mssql">
			DATEADD(HOUR, mail_interval_in_hours, last_mail_notification_time)
		<!--- MYSQL --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			DATE_ADD(last_mail_notification_time, INTERVAL mail_interval_in_hours HOUR)
		<!--- Oracle, DB2 ?? --->	
		</cfif>
		< <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
	</cfquery>
	<!--- Date Format --->
	<cfinvoke component="defaults" method="getdateformat" returnvariable="dateformat">
	<!--- Get Assets Log of Subscribed folders --->
	<cfoutput query="qGetUserSubscriptions">
		<cfinvoke component="folders" method="init" returnvariable="foldersObj" />
		<!--- Get Sub-folders of Folder subscribe --->
		<cfinvoke component="#foldersObj#" method="recfolder" thelist="#qGetUserSubscriptions.folder_id#" returnvariable="folders_list" />
		<!--- Get UPC setting --->
		<cfinvoke component="settings" method="getsettingsfromdam" returnvariable="damset" />
		<!--- Get Updated Assets --->
		<cfquery datasource="#application.razuna.datasource#" name="qGetUpdatedAssets">
			SELECT l.*, u.user_first_name, u.user_last_name, u.user_id, fo.folder_name, ii.path_to_asset img_asset_path, aa.path_to_asset aud_asset_path, vv.path_to_asset vid_asset_path, ff.path_to_asset file_asset_path,
			ii.img_filename_org img_filenameorg, aa.aud_name_org aud_filenameorg,vv.vid_name_org vid_filenameorg, ff.file_name_org file_filenameorg, ii.cloud_url_org img_cloud_url, aa.cloud_url_org aud_cloud_url, vv.cloud_url_org vid_cloud_url, ff.cloud_url_org file_cloud_url , ii.thumb_extension img_thumb_ext, vv.vid_name_image vid_thumb, ii.cloud_url img_cloud_thumb, vv.cloud_url vid_cloud_thumb
			<cfif qGetUserSubscriptions.asset_keywords eq 'T' OR qGetUserSubscriptions.asset_description eq 'T'>
				, a.aud_description, a.aud_keywords, v.vid_keywords, v.vid_description, 
				i.img_keywords, i.img_description, f.file_desc, f.file_keywords
			</cfif>
			<cfif damset.set2_upc_enabled EQ 'true'>
				, ii.img_upc_number, aa.aud_upc_number, vv.vid_upc_number, ff.file_upc_number 
			</cfif>
  
			FROM (
				SELECT * FROM #session.hostdbprefix#log_assets 
				WHERE folder_id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#folders_list#" list="true">)
				AND log_timestamp > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#qGetUserSubscriptions.last_mail_notification_time#">
				) l
			LEFT JOIN users u ON l.log_user = u.user_id
			LEFT JOIN #session.hostdbprefix#folders fo ON l.folder_id = fo.folder_id
			LEFT JOIN #session.hostdbprefix#audios aa ON aa.aud_id = l.asset_id_r
			LEFT JOIN #session.hostdbprefix#files ff ON ff.file_id = l.asset_id_r
			LEFT JOIN #session.hostdbprefix#images ii ON ii.img_id = l.asset_id_r
			LEFT JOIN #session.hostdbprefix#videos vv ON vv.vid_id = l.asset_id_r
			<cfif qGetUserSubscriptions.asset_keywords eq 'T' OR qGetUserSubscriptions.asset_description eq 'T'>
				LEFT JOIN #session.hostdbprefix#audios_text a ON a.aud_id_r = l.asset_id_r AND a.lang_id_r = 1
				LEFT JOIN #session.hostdbprefix#files_desc f ON f.file_id_r = l.asset_id_r AND f.lang_id_r = 1
				LEFT JOIN #session.hostdbprefix#images_text i ON i.img_id_r = l.asset_id_r AND i.lang_id_r = 1
				LEFT JOIN #session.hostdbprefix#videos_text v ON v.vid_id_r = l.asset_id_r AND v.lang_id_r = 1
			</cfif>
			ORDER BY l.log_timestamp DESC
		</cfquery>

		<cfset var data= "">
		<cfset var datacols= "">
		<cfset var fields= "">
		<!--- Get metafields --->
		<cfinvoke component="global.cfc.settings" method="get_notifications" returnvariable="fields">
		
		<!--- Get Email subject --->
		<cfif fields.set2_folder_subscribe_email_sub NEQ "">
			<cfset email_subject = "#fields.set2_folder_subscribe_email_sub#">
		<cfelse>
			<cfinvoke component="defaults" method="trans" transid="subscribe_email_subject" returnvariable="email_subject">
		</cfif>
		<!--- Get Email Introduction--->
		<cfif len(fields.set2_folder_subscribe_email_body) GT 10>
			<cfset email_intro = "#fields.set2_folder_subscribe_email_body#">
		<cfelse>
			<cfinvoke component="defaults" method="trans" transid="subscribe_email_content" returnvariable="email_intro">
		</cfif>
		

		<!--- Email if assets are updated in Subscribed folders --->
		<cfif qGetUpdatedAssets.recordcount>
			<!--- Get columns --->
			<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid= "#qGetUpdatedAssets.asset_id_r#" metafields="#fields.set2_folder_subscribe_meta#" returnvariable="datacols">
			<!--- Mail content --->
			<cfsavecontent variable="mail" >
				#email_intro#<br>
				<h3>Subscribed Folder: #qGetUserSubscriptions.folder_name#</h3>
				<table border="1" cellpadding="4" cellspacing="0">
					<tr>
						<th nowrap="true">Date</th>
						<th nowrap="true">Time</th>
						<th nowrap="true">Thumb</th>
						<th nowrap="true">Folder/<br>Sub-Folder</th>
						<cfif damset.set2_upc_enabled EQ 'true'>
							<th>UPC Number</th>
						</cfif>
						<cfif qGetUserSubscriptions.asset_description eq 'T'>
							<th>Asset Description</th>
						</cfif>
						<cfif qGetUserSubscriptions.asset_keywords eq 'T'>
							<th>Asset Keywords</th>
						</cfif>
						<th nowrap="true">Action</th>
						<th >Details</th>
						<th nowrap="true">Type of file</th>
						<th nowrap="true">User</th>
						<th>File URL</th>
						<cfloop list="#datacols.columnlist#" index="col">
							<th nowrap="true">#col#</th>
						</cfloop>
					</tr>
				<cfloop query="qGetUpdatedAssets">
					<tr >
						<td nowrap="true" valign="top">#dateformat(qGetUpdatedAssets.log_timestamp, "#dateformat#")#</td>
						<td nowrap="true" valign="top">#timeFormat(qGetUpdatedAssets.log_timestamp, 'HH:mm:ss')#</td>
						<td>
						<!--- If action is not file delete then show thumb--->
						<cfif qGetUpdatedAssets.log_action NEQ 'delete'>
							<cfif application.razuna.storage EQ "local">
								<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
									<cfcase value="img">
										<cfif img_asset_path NEQ "">
											<img src= "#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#img_asset_path#/thumb_#qGetUpdatedAssets.asset_id_r#.#img_thumb_ext#" height="50" onerror = "this.src=''">
										</cfif>
									</cfcase>
									<cfcase value="vid">
										<cfif vid_asset_path NEQ "">
											<img src="#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#vid_asset_path#/#vid_thumb#"  height="50" onerror = "this.src=''">
										</cfif>
									</cfcase>
								</cfswitch>
							<cfelse>
								<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
									<cfcase value="img">
										<img src="#img_cloud_thumb#"  height="50" onerror = "this.src=''">
									</cfcase>
									<cfcase value="vid">
										<img src="#vid_cloud_thumb#"  height="50" onerror = "this.src=''">
									</cfcase>
								</cfswitch>
								
							</cfif>
						</cfif>
						</td>
						<td valign="top">#qGetUpdatedAssets.folder_name#</td>
						<cfif damset.set2_upc_enabled EQ 'true'>
							<td>&nbsp;
							<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
								<cfcase value="img">
									#qGetUpdatedAssets.img_upc_number#
								</cfcase>
								<cfcase value="doc">
									#qGetUpdatedAssets.file_upc_number#
								</cfcase>
								<cfcase value="vid">
									#qGetUpdatedAssets.vid_upc_number#
								</cfcase>
								<cfcase value="aud">
									#qGetUpdatedAssets.aud_upc_number#
								</cfcase>
							</cfswitch>
							</td>
						</cfif>
						<cfif qGetUserSubscriptions.asset_description eq 'T'>
							<td>&nbsp;
							<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
								<cfcase value="img">
									#qGetUpdatedAssets.img_description#
								</cfcase>
								<cfcase value="doc">
									#qGetUpdatedAssets.file_desc#
								</cfcase>
								<cfcase value="vid">
									#qGetUpdatedAssets.vid_description#
								</cfcase>
								<cfcase value="aud">
									#qGetUpdatedAssets.aud_description#
								</cfcase>
							</cfswitch>
							</td>
						</cfif>
						<cfif qGetUserSubscriptions.asset_keywords eq 'T'>
							<td>&nbsp;
							<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
								<cfcase value="img">
									#qGetUpdatedAssets.img_keywords#
								</cfcase>
								<cfcase value="doc">
									#qGetUpdatedAssets.file_keywords#
								</cfcase>
								<cfcase value="vid">
									#qGetUpdatedAssets.vid_keywords#
								</cfcase>
								<cfcase value="aud">
									#qGetUpdatedAssets.aud_keywords#
								</cfcase>
							</cfswitch>
							</td>
						</cfif>
						<td nowrap="true" align="center" valign="top">#qGetUpdatedAssets.log_action#</td>
						<td valign="top">#qGetUpdatedAssets.log_desc#</td>
						<td nowrap="true" align="center" valign="top">#qGetUpdatedAssets.log_file_type#</td>
						<td nowrap="true" align="center" valign="top">#qGetUpdatedAssets.user_first_name# #qGetUpdatedAssets.user_last_name#</td>
						<td align="center" valign="top" width="80">
						<!--- If action is not file delete then show file url --->
						<cfif qGetUpdatedAssets.log_action NEQ 'delete'>
							<cfif application.razuna.storage EQ "local">
								<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
									<cfcase value="img">
										<cfif img_asset_path NEQ "">
											#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#img_asset_path#/#img_filenameorg#
										</cfif>
									</cfcase>
									<cfcase value="doc">
										<cfif file_asset_path NEQ "">
											#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#file_asset_path#/#file_filenameorg#
										</cfif>
									</cfcase>
									<cfcase value="vid">
										<cfif vid_asset_path NEQ "">
											#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#vid_asset_path#/#vid_filenameorg#
										</cfif>
									</cfcase>
									<cfcase value="aud">
										<cfif aud_asset_path NEQ "">
											#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#aud_asset_path#/#aud_filenameorg#
										</cfif>
									</cfcase>
								</cfswitch>
							<cfelse>
								<cfswitch expression="#qGetUpdatedAssets.log_file_type#">
									<cfcase value="img">
										<cfif img_cloud_url NEQ "">
											#img_cloud_url#
										</cfif>
									</cfcase>
									<cfcase value="doc">
										<cfif file_cloud_url NEQ "">
											#file_cloud_url#
										</cfif>
									</cfcase>
									<cfcase value="vid">
										<cfif vid_cloud_url NEQ "">
											#vid_cloud_url#
										</cfif>
									</cfcase>
									<cfcase value="aud">
										<cfif aud_cloud_url NEQ "">
											#aud_cloud_url#
										</cfif>
									</cfcase>
								</cfswitch>
								
							</cfif>
						</cfif>
						</td>
						<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid= "#qGetUpdatedAssets.asset_id_r#" metafields="#fields.set2_folder_subscribe_meta#" returnvariable="data">
						<cfloop list="#datacols.columnlist#" index="col">
							<td>#data["#col#"][1]#</td>
						</cfloop>
					</tr>

				</cfloop>
				</table>
			</cfsavecontent>

			<!--- Set user id --->
			<cfset arguments.thestruct.user_id = qGetUserSubscriptions.user_Id>
			<!--- Get user details --->
			<cfinvoke component="users" method="details" thestruct="#arguments.thestruct#" returnvariable="usersdetail">
			<!--- Send the email --->
			<cfinvoke component="email" method="send_email" to="#usersdetail.user_email#" subject="#email_subject#" themessage="#mail#" userid="#usersdetail.user_id#"/>
			
		</cfif>
		<!--- Update Folder Subscribe --->
		<cfquery datasource="#application.razuna.datasource#" name="update">
			UPDATE #session.hostdbprefix#folder_subscribe 
			SET last_mail_notification_time = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			WHERE fs_id = <cfqueryparam value="#qGetUserSubscriptions.fs_id#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cfoutput>
</cffunction>

<cffunction name="asset_expiry_task" output="true" access="public" hint="Finds assets that have expired and sets the expired label for them or removes them if expiry has been reset">
	<!--- Check if expiry label is not present for a host --->
	<cfquery datasource="#application.razuna.datasource#" name="getmissing_labels">
	SELECT h.HOST_ID 
	FROM raz1_labels l RIGHT JOIN hosts h
	ON l.label_text='Asset has expired' AND l.host_id=h.host_id AND l.label_id_r = '0'
	WHERE label_id IS NULL
	</cfquery>
	<cfloop query="getmissing_labels">
		<!--- Insert label for asset expiry if missing --->
		<cfquery datasource="#application.razuna.datasource#">
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
	<!--- Get assets that  have expired --->
	<cfquery datasource="#application.razuna.datasource#" name="getexpired_assets">
	SELECT img_id id, host_id, 'img' type, (SELECT MAX(label_id) FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=i.host_id AND label_id_r = '0')label_id FROM raz1_images i WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=i.img_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=i.host_id  AND label_id_r = '0'))
	UNION ALL
	SELECT aud_id id, host_id, 'aud' type,(SELECT MAX(label_id)  FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=a.host_id AND label_id_r = '0')label_id  FROM raz1_audios a WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=a.aud_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=a.host_id AND label_id_r = '0'))

	UNION ALL
	SELECT vid_id id, host_id, 'vid' type, (SELECT MAX(label_id) FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=v.host_id AND label_id_r = '0')label_id FROM raz1_videos v WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=v.vid_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=v.host_id AND label_id_r = '0'))

	UNION ALL
	SELECT file_id id, host_id, 'doc' type,(SELECT MAX(label_id)  FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=f.host_id AND label_id_r = '0')label_id FROM raz1_files f WHERE expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=f.file_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired'AND host_id=f.host_id AND label_id_r = '0'))
	</cfquery>
	<!--- Get users that are in groups which have access to the expired assets and notify them about the expiry --->
	<cfquery datasource="#application.razuna.datasource#" name="getusers2notify">
	SELECT i.img_id id, i.img_filename name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'img' type, path_to_asset, thumb_extension thumb, cloud_url cloud_thumb
	FROM raz1_images i, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
	WHERE i.folder_id_r = f.folder_id
	AND f.folder_id = fg.folder_id_r
	AND cu.ct_g_u_grp_id = fg.grp_id_r
	AND cu.ct_g_u_user_id = u.user_id 
	AND fg.grp_id_r <>'0'
	AND lower(fg.grp_permission) in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
	AND expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> 
	AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=i.img_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=i.host_id  AND label_id_r = '0'))
	UNION ALL
	SELECT a.aud_id id, a.aud_name name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'aud' type, path_to_asset, '' thumb, '' cloud_thumb
	FROM raz1_audios a, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
	WHERE a.folder_id_r = f.folder_id
	AND f.folder_id = fg.folder_id_r
	AND cu.ct_g_u_grp_id = fg.grp_id_r
	AND cu.ct_g_u_user_id = u.user_id 
	AND fg.grp_id_r <>'0'
	AND lower(fg.grp_permission) in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
	AND expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> 
	AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=a.aud_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=a.host_id AND label_id_r = '0'))
	UNION ALL
	SELECT v.vid_id id, v.vid_filename name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'vid' type, path_to_asset, vid_name_image thumb, cloud_url cloud_thumb
	FROM raz1_videos v, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
	WHERE v.folder_id_r = f.folder_id
	AND f.folder_id = fg.folder_id_r
	AND cu.ct_g_u_grp_id = fg.grp_id_r
	AND cu.ct_g_u_user_id = u.user_id
	AND fg.grp_id_r <>'0'
	AND lower(fg.grp_permission) in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
	AND expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> 
	AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=v.vid_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=v.host_id AND label_id_r = '0'))
	UNION ALL
	SELECT fi.file_id id, fi.file_name name, f.folder_id, f.folder_name, u.user_email, u.user_Id, 'doc' type, path_to_asset, '' thumb, '' cloud_thumb
	FROM raz1_files fi, raz1_folders f,raz1_folders_groups fg, ct_groups_users cu, users u
	WHERE fi.folder_id_r = f.folder_id
	AND f.folder_id = fg.folder_id_r
	AND cu.ct_g_u_grp_id = fg.grp_id_r
	AND cu.ct_g_u_user_id = u.user_id 
	AND fg.grp_id_r <>'0'
	AND lower(fg.grp_permission) in ('w','x') <!--- Only send notification to groups with write and full access permissions --->
	AND expiry_date < <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#"> 
	AND NOT EXISTS (SELECT 1 FROM ct_labels WHERE ct_id_r=fi.file_id AND ct_label_id IN (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired'AND host_id=fi.host_id AND label_id_r = '0'))
	</cfquery>
	<!--- Extract user information from query --->
	<cfquery dbtype="query" name="getuserinfo">
		SELECT user_email, user_id FROM getusers2notify GROUP BY user_id,user_email
	</cfquery>
	<!--- Before we send out notification emails lets expire the assets first --->
	<!--- Set expired label for assets that have expired and update indexing status to re-index --->
	<cfloop query="getexpired_assets">
		<cfif getexpired_assets.label_id NEQ ''>
			<!--- Insert label for asset expiry --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO ct_labels (ct_label_id,ct_id_r,ct_type,rec_uuid)
			VALUES  (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#label_id#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#id#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#type#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid()#">
				)
			</cfquery>
			<!--- Update indexing flag --->
			<cfif type EQ 'img'>
				<cfset var tbl = 'images'>
				<cfset var col = 'img_id'>
			<cfelseif type EQ 'aud'>
				<cfset var tbl = 'audios'>
				<cfset var col = 'aud_id'>
			<cfelseif type EQ 'vid'>
				<cfset var tbl = 'videos'>
				<cfset var col = 'vid_id'>
			<cfelseif type EQ 'doc'>
				<cfset var tbl = 'files'>
				<cfset var col = 'file_id'>
			</cfif>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_#tbl# SET is_indexed = '0'
			WHERE #col# =<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#id#">
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Get assets that  were expired but now have been reset --->
	<cfquery datasource="#application.razuna.datasource#" name="getreset_assets">
	SELECT i.img_id id, rec_uuid FROM ct_labels c, raz1_images i WHERE i.img_id=c.ct_id_r AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=i.host_id AND label_id_r = '0')
	AND (expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
	UNION ALL
	SELECT a.aud_id id, rec_uuid FROM ct_labels c, raz1_audios a WHERE a.aud_id=c.ct_id_r AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=a.host_id AND label_id_r = '0')
	AND (expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
	UNION ALL
	SELECT v.vid_id id, rec_uuid FROM ct_labels c, raz1_videos v WHERE v.vid_id=c.ct_id_r AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=v.host_id AND label_id_r = '0')
	AND (expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
	UNION ALL
	SELECT f.file_id id, rec_uuid FROM ct_labels c, raz1_files f WHERE f.file_id=c.ct_id_r AND c.ct_label_id in (SELECT label_id FROM raz1_labels WHERE label_text ='Asset has expired' AND host_id=f.host_id AND label_id_r = '0')
	AND (expiry_date IS NULL OR expiry_date >= <cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">)
	</cfquery>
	<cfset var resetlist = valuelist(getreset_assets.rec_uuid)>
	<cfset var assetlist = valuelist(getreset_assets.id)>
	<cfif resetlist neq ''>
		<!--- Remove expired label from assets  that have been reset --->
		<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM ct_labels WHERE rec_uuid IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#resetlist#" list="true">)
		</cfquery>
		<!--- Update indexing statuses --->
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_images SET is_indexed = '0' WHERE img_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_audios SET is_indexed = '0' WHERE aud_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_videos SET is_indexed = '0' WHERE vid_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE raz1_files SET is_indexed = '0' WHERE file_id IN ( <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#assetlist#" list="true">)
		</cfquery>
	</cfif>
	<!--- Reset labels cache if labels have been modified--->
	<cfif getexpired_assets.recordcount NEQ 0 OR getreset_assets.recordcount NEQ 0>
		<cfset resetcachetoken("labels","true")>
	</cfif>

	<cfset var data= "">
	<cfset var datacols= "">
	<cfset var fields= "">
	<!--- Get metafields --->
	<cfinvoke component="global.cfc.settings" method="get_notifications" returnvariable="fields">
	<!--- Get columns --->
	<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid= "#getusers2notify.id#" metafields="#fields.set2_asset_expiry_meta#" returnvariable="datacols">
	
	<!--- Send out notification email about expiry to users in groups that have access to the expired assets--->
	<!--- Get Email subject --->
	<cfif fields.set2_asset_expiry_email_sub NEQ "">
		<cfset email_subject = "#fields.set2_asset_expiry_email_sub#">
	<cfelse>
		<cfinvoke component="defaults" method="trans" transid="expiry_email_subject" returnvariable="email_subject">
	</cfif>
	<!--- Get Email Introduction--->
	<cfif len(fields.set2_asset_expiry_email_body) GT 10>
		<cfset email_intro = "#fields.set2_asset_expiry_email_body#">
	<cfelse>
		<cfinvoke component="defaults" method="trans" transid="expiry_email_content" returnvariable="email_intro">
	</cfif>
	<cfset var msgbody = "">
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
			<cfloop query = "getusers2email">
				<cfinvoke component="global.cfc.settings" method="getmeta_asset" assetid= "#getusers2email.id#" metafields="#fields.set2_asset_expiry_meta#" returnvariable="data">
				<tr>
					<td nowrap="true">#getusers2email.id#</td>
					<td nowrap="true">#getusers2email.name#</td>
					<td>
					<cfif application.razuna.storage EQ "local">
						<cfif path_to_asset NEQ "">
							<cfswitch expression="#getusers2email.type#">
								<cfcase value="img">
									<img src= "#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#path_to_asset#/thumb_#getusers2email.id#.#thumb#" height="50" onerror = "this.src=''">
								</cfcase>
								<cfcase value="vid">
									<img src="#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#path_to_asset#/#thumb#"  height="50" onerror = "this.src=''">
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
		<cfinvoke component="email" method="send_email" to="#getuserinfo.user_email#" subject="#email_subject#" themessage="#msgbody#" userid="#getuserinfo.user_id#"/>
	</cfloop>
</cffunction>

<cffunction name="ftp_notifications_task" output="true" access="public" hint="Finds assets that have expired and sets the expired label for them or removes them if expiry has been reset">
	<!--- Check if expiry label is not present for a host --->
	<cfquery datasource="#application.razuna.datasource#" name="getlogs">
	SELECT l.sched_log_id, s.sched_id, s.sched_ftp_email, l.sched_log_action, l.sched_log_desc, l.sched_log_time
	FROM raz1_schedules_log l, raz1_schedules s
	WHERE s.sched_id = l.sched_id_r
	AND l.notified=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="false">
	AND s.sched_ftp_email <>'' 
	AND s.sched_ftp_email IS NOT NULL
	</cfquery>
	<cfquery name="getusers" dbtype="query">
		SELECT sched_ftp_email FROM getlogs
		GROUP BY sched_ftp_email
	</cfquery>
	<cfloop query = "getusers">
		<cfquery name="getdata" dbtype="query">
			SELECT * FROM getlogs
			WHERE sched_ftp_email ='#getusers.sched_ftp_email#'
		</cfquery>
		<cfoutput>
		 <cfsavecontent variable="msgbody">
		 	The following issues were encountered by the FTP scheduled task(s) while importing files:
		 	<table border="1" cellpadding="4" cellspacing="0">
				<tr>
					<th nowrap="true">Sched_ID</th>
					<th nowrap="true">Action</th>
					<th nowrap="true">Description</th>
					<th nowrap="true">Logtime</th>
				</tr>
				<cfloop query="getdata">
					<tr>
						<td nowrap="true">#getdata.sched_ID#</td>
						<td nowrap="true">#getdata.sched_log_action#</td>
						<td>#getdata.sched_log_desc#</td>
						<td>#dateformat(getdata.sched_log_time,"mm/dd/yyyy")#  #timeformat(getdata.sched_log_time,"hh:mm tt")#</td>
					</tr>
					<cfquery datasource="#application.razuna.datasource#" name="getlogs">
					UPDATE raz1_schedules_log SET notified=<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="true"> 
					WHERE sched_log_id =<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#getdata.sched_log_id#">
					</cfquery>
				</cfloop>
			</table>
		 </cfsavecontent>
		</cfoutput>
		 <!--- Send the email --->
		<cfinvoke component="email" method="send_email" to="#getusers.sched_ftp_email#" subject="FTP Task Notifications" themessage="#msgbody#"/>
	</cfloop>
</cffunction>

</cfcomponent>
