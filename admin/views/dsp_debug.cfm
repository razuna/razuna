<cfoutput>

<!--- Search a collection with given parameters if defined --->
<cfif isdefined("colname") and isdefined("search")>
	<h3>SEARCHING COLLECTION #colname# FOR #search#</h3>
	<cfsearch collection="#colname#" criteria="#search#" name="x">
	<cfdump var="#x#"> 
</cfif>

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
	SELECT count(1) cnt FROM raz1_images i, hosts h 
	WHERE is_indexed = 0 
	AND i.host_id = h.host_id
	<cfif cgi.http_host CONTAINS "razuna.com">
	AND host_type != 0
	</cfif>
</cfquery>
<cfquery name="idxstats_vid" datasource="#application.razuna.datasource#">
	SELECT count(1) cnt FROM raz1_videos i, hosts h 
	WHERE is_indexed = 0 
	AND i.host_id = h.host_id
	<cfif cgi.http_host CONTAINS "razuna.com">
	AND host_type != 0
	</cfif>
</cfquery>
<cfquery name="idxstats_aud" datasource="#application.razuna.datasource#">
	SELECT count(1) cnt FROM raz1_audios i, hosts h 
	WHERE is_indexed = 0 
	AND i.host_id = h.host_id
	<cfif cgi.http_host CONTAINS "razuna.com">
	AND host_type != 0
	</cfif>
</cfquery>
<cfquery name="idxstats_fil" datasource="#application.razuna.datasource#">
	SELECT count(1) cnt FROM raz1_files i, hosts h 
	WHERE is_indexed = 0 
	AND i.host_id = h.host_id
	<cfif cgi.http_host CONTAINS "razuna.com">
	AND host_type != 0
	</cfif>
</cfquery>

Images not indexed: #idxstats_img.cnt#<br>
Videos not indexed: #idxstats_vid.cnt#<br>
Audios not indexed: #idxstats_aud.cnt#<br>
Files not indexed: #idxstats_fil.cnt#

<h3>BLUEDRAGON CONFIG FILE</h3>
<cffile action="read" file="#expandpath('../')#/WEB-INF/bluedragon/bluedragon.xml" variable="filetmp">
<cfset bdxml="#xmlparse(filetmp)#">
<!--- <cfdump var="#bdxml.server#"> --->

<!--- Print our search collections --->
<cfif isdefined("bdxml.server.cfcollection.collection")>
	<h5><u>SEARCH COLLECTIONS</u></h5>
	<font size="2">
	<cfif isArray(bdxml.server.cfcollection.collection)>
		<cfloop array="#bdxml.server.cfcollection.collection#" index="col">
			<b>BD CollectionName:</b>#col.name#<br>
			<b>BD Collection Path:</b>#col.path#<br>
			<hr>
		</cfloop>
	<cfelse>
		 <cfset col = bdxml.server.cfcollection.collection>
		<b>BD CollectionName:</b>#col.name#<br>
		<b>BD Collection Path:</b>#col.path#<br>
	</cfif>
	</font>
</cfif>

<!--- Print out tasks --->
<cfif isdefined("bdxml.server.cfschedule.task")>
	<h5><u>SCHEDULED TASKS</u></h5>
	<font size="2">
	<cfif isArray(bdxml.server.cfschedule.task)>
		<cfloop array="#bdxml.server.cfschedule.task#" index="tsk">
			<b>BD Task Name:</b>: #tsk.name#<br>
			<b>BD Task URL:</b>: #tsk.urltouse#<br>
			<hr>
		</cfloop>
	<cfelse>
		<cfset tsk = bdxml.server.cfschedule.task>
		<b>BD Task Name:</b>: #tsk.name#<br>
		<b>BD Task URL:</b>: #tsk.urltouse#<br>
	</cfif>
	</font>
</cfif>
<!--- Print out datasources --->
<h5><u>DATASOURCES</u></h5>
<font size="2">
<cfif isArray(bdxml.server.cfquery.datasource)>
	<cfloop array="#bdxml.server.cfquery.datasource#" index="dsn">
		<b>BD Datasource Name:</b> #dsn.name#<br>
		<b>BD Datasource hoststring:</b> #dsn.hoststring#<br>
		<hr>
	</cfloop>
<cfelse>
	<cfset dsn = bdxml.server.cfquery.datasource>
	<b>BD Datasource Name:</b> #dsn.name#<br>
	<b>BD Datasource hoststring:</b> #dsn.hoststring#<br>
</cfif>
</font>

</cfoutput>