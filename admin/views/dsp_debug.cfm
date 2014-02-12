<cfoutput>
<!--- Does lock files(s) exist --->
<h3>LOCK FILES IN TEMP</h3>
<cfdirectory action="list" directory="#GetTempDirectory()#" name="tmp" filter="*.lock">
<cfdump var="#tmp#">
<br/>
<!--- Get List of schedules tasks in database--->
<h3>SCHEDULED TASKS IN DATABASE</h3>
<cfquery name="gettasks" datasource="#application.razuna.datasource#">
	SELECT sched_id, sched_status, sched_method, host_id, sched_interval, sched_start_date, sched_start_time, sched_end_date, sched_end_time
	FROM raz1_schedules
</cfquery>
<cfdump var="#gettasks#">
<!--- Get counts of assets not indexed --->
<h3>INDEXING STATUS</h3>
<cfquery name="idxstats_img" datasource="#application.razuna.datasource#">
	SELECT count(1) cnt FROM raz1_images WHERE is_indexed = 0
</cfquery>
<cfquery name="idxstats_vid" datasource="#application.razuna.datasource#">
	SELECT count(1) cnt  FROM raz1_videos WHERE is_indexed = 0
</cfquery>
<cfquery name="idxstats_aud" datasource="#application.razuna.datasource#">
	SELECT count(1) cnt  FROM raz1_audios WHERE is_indexed = 0
</cfquery>
<cfquery name="idxstats_fil" datasource="#application.razuna.datasource#">
	SELECT count(1) cnt  FROM raz1_files WHERE is_indexed = 0
</cfquery>

Images not indexed: #idxstats_img.cnt#<br>
Videos not indexed: #idxstats_vid.cnt#<br>
Audios not indexed: #idxstats_img.cnt#<br>
Files not indexed: #idxstats_fil.cnt#

<h3>BLUEDRAGON CONFIG FILE</h3>

<cffile action="read" file="#expandpath('../')#/WEB-INF/bluedragon/bluedragon.xml" variable="filetmp">
<cfset bdxml="#xmlparse(filetmp)#">
<!--- <cfdump var="#bdxml.server#"> --->

<h5><u>SCHEDULED TASKS</u></h5>
<font size="2">
<cfloop array="#bdxml.server.cfschedule.task#" index="tsk">
	<b>BD Task Name:</b>: #tsk.name#<br>
	<b>BD Task URL:</b>: #tsk.urltouse#<br>
	<hr>
</cfloop>
</font>

<h5><u>DATASOURCES</u></h5>
<font size="2">
<cfloop array="#bdxml.server.cfquery.datasource#" index="dsn">
	<b>BD Datasource Name:</b> #dsn.name#<br>
	<b>BD Datasource hoststring:</b> #dsn.hoststring#<br>
	<hr>
</cfloop>
</font>

</cfoutput>