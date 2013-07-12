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
	<!--- Query to get all records --->
	<cfquery datasource="#application.razuna.datasource#" name="qry">
	SELECT sched_id, sched_name, sched_method, sched_status
	FROM #session.hostdbprefix#schedules
	WHERE set2_id_r  = <cfqueryparam value="#variables.setid#" cfsqltype="cf_sql_numeric">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY sched_name, sched_method
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
		 host_id,
		 sched_upl_template
		 <cfif schedData.ftpPassive is not "">, sched_ftp_passive</cfif> 
		 <cfif schedData.startDate is not "">, sched_start_date</cfif>
		 <cfif schedData.startTime is not "">, sched_start_time</cfif>
		 <cfif schedData.endDate is not "">, sched_end_date</cfif>
		 <cfif schedData.endTime is not "">, sched_end_time</cfif> 
		)
		VALUES 
		(<cfqueryparam value="#newschid#" cfsqltype="CF_SQL_VARCHAR">, 
		 <cfqueryparam value="#variables.setid#" cfsqltype="cf_sql_numeric">, 
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
		 <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		 <cfqueryparam value="#arguments.thestruct.upl_template#" cfsqltype="cf_sql_varchar">
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
		<cfinvoke method="tolog" theschedid="#newschid#" theuserid="#session.theuserid#" theaction="Insert" thedesc="Scheduled Upload successfully saved">
		<cfcatch>
			<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error from Scheduler" dump="#cfcatch#">
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
	<cfswitch expression="#arguments.thestruct.method#">
		<!--- Server --->
		<cfcase value="server">
			<cfset arguments.thestruct.mailPop = "">
			<cfset arguments.thestruct.mailUser = "">
			<cfset arguments.thestruct.mailPass = "">
			<cfset arguments.thestruct.mailSubject = "">
			<cfset arguments.thestruct.ftpServer = "">
			<cfset arguments.thestruct.ftpUser = "">
			<cfset arguments.thestruct.ftpPass = "">
			<cfset arguments.thestruct.ftpPassive = "">
			<cfset arguments.thestruct.ftpFolder = "">
		</cfcase>
		<!--- FTP --->
		<cfcase value="ftp">
			<cfset arguments.thestruct.serverFolder = "">
			<cfset arguments.thestruct.mailPop = "">
			<cfset arguments.thestruct.mailUser = "">
			<cfset arguments.thestruct.mailPass = "">
			<cfset arguments.thestruct.mailSubject = "">
		</cfcase>
		<!--- eMail --->
		<cfcase value="mail">
			<cfset arguments.thestruct.serverFolder = "">
			<cfset arguments.thestruct.ftpServer = "">
			<cfset arguments.thestruct.ftpUser = "">
			<cfset arguments.thestruct.ftpPass = "">
			<cfset arguments.thestruct.ftpPassive = "">
			<cfset arguments.thestruct.ftpFolder = "">
		</cfcase>
	</cfswitch>
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
		<cfcatch type="database"></cfcatch>
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
	<!--- Query to get all records --->
	<cfquery datasource="#application.razuna.datasource#" name="qSchedDetail">
	SELECT s.sched_id, s.set2_id_r, s.sched_user, s.sched_status, s.sched_method, s.sched_name,
	s.sched_folder_id_r, s.sched_zip_extract, s.sched_server_folder, s.sched_mail_pop, s.sched_mail_user,
	s.sched_mail_pass, s.sched_mail_subject, s.sched_ftp_server, s.sched_ftp_user, s.sched_ftp_pass,
	s.sched_ftp_folder, s.sched_interval, s.sched_start_date, s.sched_start_time, s.sched_end_date,
	s.sched_end_time, s.sched_ftp_passive, s.sched_server_recurse, s.sched_server_files, s.sched_upl_template,
	f.folder_name as folder_name
	FROM #session.hostdbprefix#schedules s, #session.hostdbprefix#folders f
	WHERE s.sched_id = <cfqueryparam value="#arguments.sched_id#" cfsqltype="CF_SQL_VARCHAR">
	AND s.sched_folder_id_r = f.folder_id
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
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
		set2_id_r = <cfqueryparam value="#variables.setid#" cfsqltype="cf_sql_numeric">, 
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
		sched_upl_template = <cfqueryparam value="#arguments.thestruct.upl_template#" cfsqltype="cf_sql_varchar">,
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
		<cfinvoke method="tolog" theschedid="#schedData.sched_id#" theuserid="#session.theuserid#" theaction="Update" thedesc="Scheduled Upload successfully updated">
		<cfcatch>
			<!--- Log the error --->
			<cfinvoke component="debugme" method="email_dump" emailto="support@razuna.com" emailfrom="server@razuna.com" emailsubject="Error from Scheduler" dump="#cfcatch#">
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
		<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theuserid="#session.theuserid#" theaction="Run" thedesc="Scheduled Upload successfully run">
		<cfcatch>
			<!--- Log the error --->
			<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theuserid="#session.theuserid#" theaction="Run" thedesc="Scheduled Upload failed while running [#cfcatch.type# - #cfcatch.message#]">
			<cfset returncode = "sched_error">
		</cfcatch>
	</cftry>
	<cfreturn returncode>
</cffunction>

<!--- GET LOG ENTRIES FOR SCHEDULED EVENT -------------------------------------------------------->
<cffunction name="getlog" returntype="query" output="true" access="public">
	<cfargument name="sched_id"   type="string" required="yes" default="">
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
	<!--- Param --->
	<cfset var doit = structnew()>
	<cfset var x = structnew()>
	<cfset doit.dirlist = "">
	<cfset doit.directoryList = "">
	<cfset var dorecursive = false>
	<cfset var dirhere = "">
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
			<cfinvoke method="tolog" theschedid="#arguments.sched_id#" theaction="Upload" thedesc="Start Processing Scheduled Upload" />
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
			<!-- CFC: Get FTP directory for adding to the system -->
			<cfinvoke component="ftp" method="getdirectory" thestruct="#x#" returnvariable="thefiles" />
			<cfset x.thefile = valuelist(thefiles.ftplist.name) />
			<!-- CFC: Add to system -->
			<cfinvoke component="assets" method="addassetftpthread" thestruct="#x#" />
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
		</cfif>
	</cfif>
	<cfreturn doit>
</cffunction>

</cfcomponent>
