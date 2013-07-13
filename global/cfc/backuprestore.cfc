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
	
	<!--- Call this from the scheduled task --->
	<cffunction name="backuptodbthread" output="true">
		<cfargument name="thestruct" type="struct">
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="backuptodb" thestruct="#attributes.intstruct#" />
		</cfthread>
	</cffunction>

	<!--- Backup to internal DB --->
	<cffunction name="backuptodb" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset arguments.thestruct.dsn = "razuna_backup">
		<cfset arguments.thestruct.fromimport = "T">
		<cfset arguments.thestruct.tschema = "B" & createuuid("")>
		<cfparam name="arguments.thestruct.admin" default="F">
		<!--- Feedback --->
		<cfoutput><strong>Starting the Backup</strong><br><br></cfoutput>
		<cfflush>
		<!--- Create schema in the backup DB --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE SCHEMA #arguments.thestruct.tschema#
		</cfquery>
		<!--- Grab the db prefix from the host table --->
		<cfquery datasource="#application.razuna.datasource#" name="qryhost">
		SELECT host_shard_group
		FROM hosts
		GROUP BY host_shard_group
		</cfquery>
		<!--- Feedback --->
		<cfoutput><strong>Churning on some internal stuff...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Loop over the prefixes and create tables --->
		<cfloop query="qryhost">
			<!--- Create backup tables --->
			<cfinvoke component="db_backup" method="setup" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Insert creation date into status db --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO backup_status
		(back_id, back_date, host_id)
		VALUES(
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.tschema#">,
			<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
			<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		)
		</cfquery>
		<!--- Feedback --->
		<cfoutput><strong>Selecting the tables...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Loop over the sharding group prefix --->
		<cfloop query="qryhost">
			<!--- Upper Case DB prefix --->
			<cfset theprefix = lcase(host_shard_group) & "%">
			<!--- Oracle --->
			<cfif application.razuna.thedatabase EQ "oracle">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables...</strong><br></cfoutput>
				<cfflush>
				<!--- Select all host tables --->
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qry">
				SELECT lower(object_name) as thetable
				FROM user_objects 
				WHERE object_type = 'TABLE' 
				AND (
				lower(object_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#theprefix#">
				<cfif arguments.thestruct.hostid EQ 0>
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_users">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_permissions">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_hosts">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_remoteusers">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="groups">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="hosts">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="log_actions">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_login">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="wisdom">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_comments">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="file_types">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="webservices">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="search_reindex">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="tools">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_labels">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="rfs">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="cache">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_plugins_hosts">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="plugins">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="plugins_actions">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="options">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="news">
				<cfelse>
					<cfif currentRow EQ 1>
						OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
						OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
					</cfif>
				</cfif>
				)
				GROUP BY object_name
				ORDER BY object_name
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writebackupdb" thestruct="#arguments.thestruct#">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables... done. Continuing...</strong><br></cfoutput>
				<cfflush>
			<!--- DB2 --->
			<cfelseif application.razuna.thedatabase EQ "db2">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables...</strong><br></cfoutput>
				<cfflush>
				<!--- Select all host tables --->
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qry">
				SELECT lower(tabname) as thetable
				FROM syscat.tables
				WHERE (
				lower(tabname) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(theprefix)#">
				<cfif arguments.thestruct.hostid EQ 0>
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_users">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_permissions">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_hosts">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_remoteusers">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="groups">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="hosts">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="log_actions">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_login">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="wisdom">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_comments">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="file_types">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="webservices">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="search_reindex">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="tools">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_labels">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="rfs">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="cache">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_plugins_hosts">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="plugins">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="plugins_actions">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="options">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="news">
				<cfelse>
					<cfif currentRow EQ 1>
						OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
						OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
					</cfif>
				</cfif>
				)
				AND tabschema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(application.razuna.theschema)#">
				GROUP BY tabname
				ORDER BY tabname
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writebackupdb" thestruct="#arguments.thestruct#">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables... done. Continuing...</strong><br></cfoutput>
				<cfflush>
			<!--- All other DBs --->
			<cfelse>
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables...</strong><br></cfoutput>
				<cfflush>
				<!--- Select all host tables --->
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qry">
				SELECT lower(table_name) as thetable
				FROM information_schema.tables
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(theprefix)#">
				<cfif arguments.thestruct.hostid EQ 0>
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="groups">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="hosts">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="log_actions">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_login">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="wisdom">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_comments">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="file_types">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="webservices">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="search_reindex">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="tools">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_users">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_permissions">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_hosts">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_remoteusers">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_labels">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="rfs">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="cache">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_plugins_hosts">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="plugins">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="plugins_actions">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="options">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="news">
				<cfelse>
					<cfif currentRow EQ 1>
						OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
						OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
					</cfif>
				</cfif>
				GROUP BY table_name
				ORDER BY table_name
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writebackupdb" thestruct="#arguments.thestruct#">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables... done!</strong><br><br></cfoutput>
				<cfflush>
			</cfif>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><span style="font-weight:bold;color:green;">Backup successfully done!</span><br><br><a href="##" onclick="window.close();">Click to close this window</a>.
		</cfoutput>
		<!--- Return --->
		<cfreturn />
	</cffunction> 
	
	<!--- Write XML --->
	<cffunction name="writebackupdb" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var thecollist = "">
		<!--- Loop over the qry results --->
		<cfloop query="arguments.thestruct.qry">
			<!--- set variables --->
			<cfset thetable = thetable>
			<!--- Feedback --->
			<cfoutput>Currently running backup of #thetable#<br></cfoutput>
			<cfflush>
			<!--- Turn off referentials --->
			<cfquery dataSource="#arguments.thestruct.dsn#">
			SET REFERENTIAL_INTEGRITY false;
			</cfquery>
			<!--- Select records from the source table --->
			<cfquery dataSource="#application.razuna.datasource#" name="sourcedb">
			SELECT *
			FROM #lcase(thetable)#
			<cfif arguments.thestruct.hostid NEQ 0>
				<cfif thetable EQ "MODULES">
					WHERE mod_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				<cfelseif thetable EQ "PERMISSIONS">
					WHERE per_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				<cfelse>
					WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
				</cfif>
			</cfif>
			</cfquery>
			<!--- Get Columns --->
			<cfif application.razuna.thedatabase EQ "db2">
				<cfquery datasource="#application.razuna.datasource#" name="qry_columns">
				SELECT colname as column_name, typename as data_type
				FROM syscat.columns
				WHERE lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thetable)#">
				ORDER BY colname, typename
				</cfquery>
			<cfelse>			
				<cfquery datasource="#application.razuna.datasource#" name="qry_columns">
				SELECT column_name, <cfif application.razuna.thedatabase EQ "h2">type_name as data_type<cfelse>data_type</cfif>
				FROM <cfif application.razuna.thedatabase EQ "oracle">all_tab_columns<cfelse>information_schema.columns</cfif>
				WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thetable)#">
				ORDER BY column_name, <cfif application.razuna.thedatabase EQ "h2">type_name<cfelse>data_type</cfif>
				</cfquery>
			</cfif>
			<!--- Create our custom list --->
			<cfloop query="qry_columns">
				<cfset thecollist = thecollist & column_name & "-" & data_type & ",">
			</cfloop>
			<!--- Set variables for the query loop below --->
			<cfset len_meta = listlen(thecollist)>
			<cfset len_count_meta = 1>
			<cfset len_count_meta2 = 1>
			<!--- Insert records into backup db	 --->	
			<cfloop query="sourcedb">
				<cftry>
					<cfquery dataSource="#arguments.thestruct.dsn#">
					INSERT INTO #lcase(arguments.thestruct.tschema)#.#lcase(thetable)#
					(<cfloop list="#sourcedb.columnlist#" index="m">#listfirst(m,"-")#<cfif len_count_meta NEQ len_meta>, </cfif><cfset len_count_meta = len_count_meta + 1></cfloop>)
					VALUES(
						<cfloop list="#sourcedb.columnlist#" index="cl">
							<cfset lf = ListContainsNoCase(thecollist, cl)>
							<cfset lg = ListGetAt(thecollist, lf)>
							<!--- Varchar --->
							<cfif trim(listlast(lg,"-")) CONTAINS "varchar" OR trim(listlast(lg,"-")) CONTAINS "text">
								<cfif evaluate(cl) EQ "">
									''
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(cl)#">
								</cfif>
							<cfelseif trim(listlast(lg,"-")) CONTAINS "clob">
								<cfif evaluate(cl) EQ "">
									NULL
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_CLOB" value="#evaluate(cl)#">
								</cfif>
							<cfelseif trim(listlast(lg,"-")) CONTAINS "int">
								<cfif isnumeric(evaluate(cl))>
									<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#evaluate(cl)#">
								<cfelse>
									NULL
								</cfif>
							<cfelseif trim(listlast(lg,"-")) EQ "date">
								<cfif evaluate(cl) EQ "">
									<cfqueryparam cfsqltype="CF_SQL_DATE" value="#now()#">
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_DATE" value="#evaluate(cl)#">
								</cfif>
							<cfelseif trim(listlast(lg,"-")) EQ "timestamp" OR trim(listlast(lg,"-")) EQ "datetime">
								<cfif evaluate(cl) EQ "">
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
								<cfelse>
									<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#evaluate(cl)#">
								</cfif>
							<cfelseif trim(listlast(lg,"-")) CONTAINS "blob">
									''
							</cfif>
							<cfif len_count_meta2 NEQ len_meta>,</cfif><cfset len_count_meta2 = len_count_meta2 + 1>
						</cfloop>
					)
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "#thetable#"!</span><br>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
				<!--- Reset loop variables --->
				<cfset len_count_meta = 1>
				<cfset len_count_meta2 = 1>
			</cfloop>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Backup to XML --->
	<cffunction name="backupxml" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Get version --->
		<cfinvoke component="settings" method="getconfig" thenode="version" returnVariable="version" />
		<!--- Feedback --->
		<cfoutput><strong>Starting the Backup</strong><br><br></cfoutput>
		<cfflush>
		<!--- Params --->
		<cfparam name="arguments.thestruct.admin" default="F">
		<!--- Create the backup file --->
		<cfset var thedate = dateformat(now(),"yyyy/mm/dd") & " " & timeformat(now(),"HH:MM tt")>
		<cfset arguments.thestruct.thedatefile = dateformat(now(),"yyyy-mm-dd") & "_" & timeformat(now(),"HH-mm-ss-l") & "." & arguments.thestruct.tofiletype>
		<cfif arguments.thestruct.tofiletype EQ "raz">
			<cfset arguments.thestruct.thedatefile = dateformat(now(),"yyyy-mm-dd") & "_" & timeformat(now(),"HH-mm-ss-l")>
			<cfset arguments.thestruct.thisdir = GetTempDirectory() & arguments.thestruct.thedatefile>
			<cfdirectory action="create" directory="#arguments.thestruct.thisdir#" mode="775">
		</cfif>
		<cfif arguments.thestruct.tofiletype EQ "xml">
		<!--- Start the XML file --->
<cfsavecontent variable="thefinalxml"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<razuna>
	<date>#xmlformat(thedate)#</date>
	<origindb>#application.razuna.thedatabase#</origindb>
</cfoutput>
</cfsavecontent>
		<!--- Write the file --->
		<cffile action="write" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thefinalxml#" mode="775" charset="utf-8">
		</cfif>
		<!--- Grab the db prefix from the host table --->
		<cfquery datasource="#variables.dsn#" name="qryhost">
		SELECT host_shard_group
		FROM hosts
		<!--- If from admin we grab all sharding groups --->
		<cfif arguments.thestruct.admin EQ "F">
			WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfif>
		GROUP BY host_shard_group
		</cfquery>
		<!--- Feedback --->
		<cfoutput><strong>Selecting the tables...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Loop over the sharding group prefix --->
		<cfloop query="qryhost">
			<!--- Upper Case DB prefix --->
			<cfset theprefix = lcase(host_shard_group) & "%">
			<!--- Oracle --->
			<cfif variables.database EQ "oracle">
				<cfif arguments.thestruct.admin EQ "T" AND currentRow EQ 1>
					<!--- Feedback --->
					<cfoutput><strong>Backing up default tables...</strong><br></cfoutput>
					<cfflush>
					<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
					SELECT lower(object_name) as thetable
					FROM user_objects 
					WHERE object_type='TABLE'
					AND lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="groups">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="hosts">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="log_actions">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_login">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_comments">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="file_types">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="webservices">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="search_reindex">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="tools">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="rfs">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="cache">
					<!---
					<cfif version GT "1.4">
						OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="sequences">
					</cfif>
					--->
					GROUP BY object_name
					ORDER BY object_name
					</cfquery>
					<!--- Write XML --->
					<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
					<!--- Now select CT tables only --->
					<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
					SELECT lower(object_name) as thetable
					FROM user_objects 
					WHERE object_type = 'TABLE'
					AND lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_users">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_permissions">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_hosts">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_remoteusers">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_labels">
					GROUP BY object_name
					</cfquery>
					<!--- Write XML --->
					<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
					<!--- Feedback --->
					<cfoutput><strong>Default tables are done. Continuing...</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables...</strong><br></cfoutput>
				<cfflush>
				<!--- Select all host tables --->
				<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
				SELECT lower(object_name) as thetable
				FROM user_objects 
				WHERE object_type = 'TABLE' 
				AND (object_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#theprefix#">
				<cfif currentRow EQ 1>
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
					OR lower(object_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
				</cfif>)
				AND lower(object_name) <> <cfqueryparam cfsqltype="cf_sql_varchar" value="raz1_errors">
				AND lower(object_name) <> <cfqueryparam cfsqltype="cf_sql_varchar" value="raz2_errors">
				GROUP BY object_name
				ORDER BY object_name
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables... done. Continuing...</strong><br></cfoutput>
				<cfflush>
			<!--- DB2 --->
			<cfelseif variables.database EQ "db2">
				<!--- If from admin select default tables also --->
				<cfif arguments.thestruct.admin EQ "T" AND currentRow EQ 1>
					<!--- Feedback --->
					<cfoutput><strong>Backing up default tables...</strong><br></cfoutput>
					<cfflush>
					<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
					SELECT lower(tabname) as thetable
					FROM syscat.tables
					WHERE (lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="groups">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="hosts">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="log_actions">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_login">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_comments">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="file_types">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="webservices">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="search_reindex">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="tools">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="rfs">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="cache">
					<!---
					<cfif version GT "1.4">
						OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="sequences">
					</cfif>
					--->
					)
					AND tabschema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(application.razuna.theschema)#">
					GROUP BY tabname
					ORDER BY tabname
					</cfquery>
					<!--- Write XML --->
					<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
					<!--- Now select CT tables only --->
					<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
					SELECT lower(tabname) as thetable
					FROM syscat.tables
					WHERE (lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_users">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_permissions">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_hosts">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_remoteusers">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_labels">)
					AND lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(application.razuna.theschema)#">
					GROUP BY tabname
					</cfquery>
					<!--- Write XML --->
					<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
					<!--- Feedback --->
					<cfoutput><strong>Default tables are done. Continuing...</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables...</strong><br></cfoutput>
				<cfflush>
				<!--- Select all host tables --->
				<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
				SELECT lower(tabname) as thetable
				FROM syscat.tables
				WHERE (lower(tabname) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#theprefix#">
				<cfif currentRow EQ 1>
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
					OR lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">)
				</cfif>
				AND lower(tabname) != <cfqueryparam cfsqltype="cf_sql_varchar" value="raz1_errors">
				AND lower(tabname) != <cfqueryparam cfsqltype="cf_sql_varchar" value="raz2_errors">
				AND lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(application.razuna.theschema)#">
				GROUP BY tabname
				ORDER BY tabname
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables... done. Continuing...</strong><br></cfoutput>
				<cfflush>
			<!--- All other DBs --->
			<cfelse>
				<!--- If from admin select default tables also --->
				<cfif arguments.thestruct.admin EQ "T" AND currentRow EQ 1>
					<!--- Feedback --->
					<cfoutput><strong>Backing up default tables...</strong><br></cfoutput>
					<cfflush>
					<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
					SELECT lower(table_name) as thetable
					FROM information_schema.tables
					WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="groups">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="hosts">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="log_actions">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_login">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users_comments">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="file_types">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="webservices">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="search_reindex">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="tools">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="rfs">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="cache">
					<!---
					<cfif variables.database EQ "h2" AND version EQ "1.4">
					<cfelse>
						OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="sequences">
					</cfif>
					--->
					GROUP BY table_name
					ORDER BY table_name
					</cfquery>
					<!--- Write XML --->
					<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
					<!--- Now select CT tables only --->
					<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
					SELECT lower(table_name) as thetable
					FROM information_schema.tables
					WHERE (lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_users">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_permissions">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_hosts">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_remoteusers">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_labels">)
					GROUP BY table_name
					</cfquery>
					<!--- Write XML --->
					<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
					<!--- Feedback --->
					<cfoutput><strong>Default tables are done. Continuing...</strong><br><br></cfoutput>
					<cfflush>
				</cfif>
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables...</strong><br></cfoutput>
				<cfflush>
				<!--- Select all host tables --->
				<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qry">
				SELECT lower(table_name) as thetable
				FROM information_schema.tables
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(theprefix)#">
				AND lower(table_name) != <cfqueryparam cfsqltype="cf_sql_varchar" value="raz1_errors">
				AND lower(table_name) != <cfqueryparam cfsqltype="cf_sql_varchar" value="raz2_errors">
				<cfif currentRow EQ 1>
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="modules">
					OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
				</cfif>
				GROUP BY table_name
				ORDER BY table_name
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables... done. Continuing...</strong><br><br></cfoutput>
				<cfflush>
			</cfif>
		</cfloop>
<!--- Select data from default tables. But only for data from this host and only needed if not from the admin --->
		<cfif arguments.thestruct.admin EQ "F">
			<!--- Feedback --->
			<cfoutput><strong>Backing up additional tables...</strong><br><br></cfoutput>
			<cfflush>
			<!--- Groups --->
			<cfquery datasource="#variables.dsn#" name="qryt">
			SELECT grp_id, grp_name, grp_host_id, grp_mod_id, grp_translation_key
			FROM groups
			WHERE grp_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
			<!--- Create the XML for this table --->
<cfsavecontent variable="thexml"><cfoutput><cfif arguments.thestruct.tofiletype EQ "xml">
	<table id="groups">
		<cfloop query="qryt"><record id="#currentRow#">
			<col id="grp_id" type="varchar">#xmlformat(grp_id)#</col>
			<col id="grp_name" type="varchar">#xmlformat(grp_name)#</col>
			<col id="grp_host_id" type="integer">#xmlformat(grp_host_id)#</col>
			<col id="grp_mod_id" type="integer">#xmlformat(grp_mod_id)#</col>
			<col id="grp_translation_key" type="varchar">#xmlformat(grp_translation_key)#</col>
		</record>
		</cfloop><cfif qryt.recordcount EQ 1><record id="FALSE">
		</record></cfif>
	</table>
	<cfelse>
<cfloop query="qryt">INSERT INTO groups (grp_id, grp_name, grp_host_id, grp_mod_id, grp_translation_key) VALUES ('#grp_id#', '#grp_name#', #grp_host_id#, #grp_mod_id#, '#grp_translation_key#');
</cfloop>
	</cfif>
</cfoutput>
</cfsavecontent>
			<!--- Write the file --->
			<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thexml#" mode="775" charset="utf-8">
			<cfset thexml = "">
			<!--- Get all the groups for this host. We take the query above and put it into a list --->
			<cfif qryt.recordcount NEQ 0>
				<cfset var groupids = valuelist(qryt.grp_id)>
				<!--- ct_groups_permissions --->
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT ct_g_p_per_id, ct_g_p_grp_id
				FROM ct_groups_permissions
				WHERE ct_g_p_grp_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#groupids#" list="true">)
				group by ct_g_p_per_id, ct_g_p_grp_id
				</cfquery>
				<!--- Create the XML for this table --->
<cfsavecontent variable="thexml"><cfoutput><cfif arguments.thestruct.tofiletype EQ "xml">
	<table id="ct_groups_permissions">
		<cfloop query="qryt"><record id="#currentRow#">
			<col id="ct_g_p_per_id" type="integer">#xmlformat(ct_g_p_per_id)#</col>
			<col id="ct_g_p_grp_id" type="varchar">#xmlformat(ct_g_p_grp_id)#</col>
		</record>
		</cfloop><cfif qryt.recordcount EQ 1><record id="FALSE">
		</record></cfif>
	</table>
	<cfelse>
<cfloop query="qryt">INSERT INTO ct_groups_permissions (ct_g_p_per_id, ct_g_p_grp_id) VALUES (#ct_g_p_per_id#, '#ct_g_p_grp_id#');
</cfloop>	
	</cfif>
</cfoutput>
</cfsavecontent>
				<!--- Write the file --->
				<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thexml#" mode="775" charset="utf-8">
				<cfset thexml = "">
			</cfif>
			<!--- ct_users_hosts --->
			<cfquery datasource="#variables.dsn#" name="qryt">
			SELECT ct_u_h_user_id, ct_u_h_host_id
			FROM ct_users_hosts
			WHERE ct_u_h_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			group by ct_u_h_user_id, ct_u_h_host_id
			</cfquery>
			<!--- Create the XML for this table --->
<cfsavecontent variable="thexml"><cfoutput><cfif arguments.thestruct.tofiletype EQ "xml">
	<table id="ct_users_hosts">
		<cfloop query="qryt"><record id="#currentRow#">
			<col id="ct_u_h_user_id" type="varchar">#xmlformat(ct_u_h_user_id)#</col>
			<col id="ct_u_h_host_id" type="integer">#xmlformat(ct_u_h_host_id)#</col>
		</record>
		</cfloop><cfif qryt.recordcount EQ 1><record id="FALSE">
		</record></cfif>
	</table>
	<cfelse>
<cfloop query="qryt">INSERT INTO ct_users_hosts (ct_u_h_user_id, ct_u_h_host_id) VALUES ('#ct_u_h_user_id#', #ct_u_h_host_id#);
</cfloop>
	</cfif>
</cfoutput>
</cfsavecontent>
			<!--- Write the file --->
			<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thexml#" mode="775" charset="utf-8">
			<cfset thexml = "">
			<!--- USERS --->
			<!--- Get all the users for this host. We take the query above and put it into a list --->
			<cfif qryt.recordcount NEQ 0>
				<cfset var userids = valuelist(qryt.ct_u_h_user_id)>
				<!--- users --->
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT user_id, user_login_name, user_email, user_first_name, user_last_name, user_pass, user_company, user_street, 
				user_street_nr, user_street_2, user_street_nr_2, user_zip, user_city, user_country, user_phone, user_phone_2, user_mobile,
				user_fax, user_create_date, user_change_date, user_active, user_in_admin, user_in_dam, user_salutation, user_in_vp, set2_nirvanix_name, set2_nirvanix_pass
				FROM users
				WHERE user_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#userids#" list="true">)
				AND user_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="1" list="true">
				</cfquery>
				<!--- Create the XML for this table --->
<cfsavecontent variable="thexml"><cfoutput><cfif arguments.thestruct.tofiletype EQ "xml">
	<table id="users">
		<cfloop query="qryt"><record id="#currentRow#">
			<col id="user_id" type="varchar">#xmlformat(user_id)#</col>
			<col id="user_login_name" type="varchar">#xmlformat(user_login_name)#</col>
			<col id="user_email" type="varchar">#xmlformat(user_email)#</col>
			<col id="user_first_name" type="varchar">#xmlformat(user_first_name)#</col>
			<col id="user_last_name" type="varchar">#xmlformat(user_last_name)#</col>
			<col id="user_pass" type="varchar">#xmlformat(user_pass)#</col>
			<col id="user_company" type="varchar">#xmlformat(user_company)#</col>
			<col id="user_street" type="varchar">#xmlformat(user_street)#</col>
			<col id="user_street_nr" type="integer">#xmlformat(user_street_nr)#</col>
			<col id="user_street_2" type="varchar">#xmlformat(user_street_2)#</col>
			<col id="user_street_nr_2" type="integer">#xmlformat(user_street_nr_2)#</col>
			<col id="user_zip" type="integer">#xmlformat(user_zip)#</col>
			<col id="user_city" type="varchar">#xmlformat(user_city)#</col>
			<col id="user_country" type="varchar">#xmlformat(user_country)#</col>
			<col id="user_phone" type="varchar">#xmlformat(user_phone)#</col>
			<col id="user_phone_2" type="varchar">#xmlformat(user_phone_2)#</col>
			<col id="user_mobile" type="varchar">#xmlformat(user_mobile)#</col>
			<col id="user_fax" type="varchar">#xmlformat(user_fax)#</col>
			<col id="user_create_date" type="date">#xmlformat(user_create_date)#</col>
			<col id="user_change_date" type="date">#xmlformat(user_change_date)#</col>
			<col id="user_active" type="varchar">#xmlformat(user_active)#</col>
			<col id="user_in_admin" type="varchar">#xmlformat(user_in_admin)#</col>
			<col id="user_in_dam" type="varchar">#xmlformat(user_in_dam)#</col>
			<col id="user_salutation" type="varchar">#xmlformat(user_salutation)#</col>
			<col id="user_in_vp" type="varchar">#xmlformat(user_in_vp)#</col>
			<col id="set2_nirvanix_name" type="varchar">#xmlformat(set2_nirvanix_name)#</col>
			<col id="set2_nirvanix_pass" type="varchar">#xmlformat(set2_nirvanix_pass)#</col>
		</record>
		</cfloop><cfif qryt.recordcount EQ 1><record id="FALSE">
		</record></cfif>
	</table>
	<cfelse>
<cfloop query="qryt">INSERT INTO users (USER_ID, USER_LOGIN_NAME, USER_EMAIL, USER_FIRST_NAME, USER_LAST_NAME, USER_PASS, USER_COMPANY, USER_STREET, USER_STREET_NR, USER_STREET_2, USER_STREET_NR_2, USER_ZIP, USER_CITY, USER_COUNTRY, USER_PHONE, USER_PHONE_2, USER_MOBILE, USER_FAX, USER_CREATE_DATE, USER_CHANGE_DATE, USER_ACTIVE, USER_IN_ADMIN, USER_IN_DAM, USER_SALUTATION, USER_IN_VP, SET2_NIRVANIX_NAME, SET2_NIRVANIX_PASS) VALUES ('#user_id#', '#user_login_name#', '#user_email#', '#user_first_name#', '#user_last_name#', '#user_pass#', '#user_company#', '#user_street#', <cfif user_street_nr EQ "">NULL<cfelse>#user_street_nr#</cfif>, '#user_street_2#', <cfif user_street_nr_2 EQ "">NULL<cfelse>#user_street_nr_2#</cfif>, <cfif user_zip EQ "">NULL<cfelse>#user_zip#</cfif>, '#user_city#', '#user_country#', '#user_phone#', '#user_phone_2#', '#user_mobile#', '#user_fax#', date '#user_create_date#', date '#user_change_date#', '#user_active#', '#user_in_admin#', '#user_in_dam#', '#user_salutation#', '#user_in_vp#', '#set2_nirvanix_name#', '#set2_nirvanix_pass#');
</cfloop>
	</cfif>
</cfoutput>
</cfsavecontent>
				<!--- Write the file --->
				<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thexml#" mode="775" charset="utf-8">
				<cfset thexml = "">
				<!--- ct_groups_users --->
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT ct_g_u_grp_id, ct_g_u_user_id
				FROM ct_groups_users
				WHERE ct_g_u_user_id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#userids#" list="true">) 
				group by ct_g_u_grp_id, ct_g_u_user_id
				</cfquery>
				<!--- Create the XML for this table --->
<cfsavecontent variable="thexml"><cfoutput><cfif arguments.thestruct.tofiletype EQ "xml">
	<table id="ct_groups_users">
		<cfloop query="qryt"><record id="#currentRow#">
			<col id="ct_g_u_grp_id" type="varchar">#xmlformat(ct_g_u_grp_id)#</col>
			<col id="ct_g_u_user_id" type="varchar">#xmlformat(ct_g_u_user_id)#</col>
		</record>
		</cfloop><cfif qryt.recordcount EQ 1><record id="FALSE">
		</record></cfif>
	</table>
	<cfelse>
<cfloop query="qryt">INSERT INTO ct_groups_users (ct_g_u_grp_id, ct_g_u_user_id) VALUES ('#ct_g_u_grp_id#', '#ct_g_u_user_id#');
</cfloop>	
	</cfif>
</cfoutput>
</cfsavecontent>
				<!--- Write the file --->
				<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thexml#" mode="775" charset="utf-8">
				<cfset thexml = "">
			</cfif>
		</cfif>
		<!--- Sequences (only needed for admin export and for version 1.4) --->
		<cfif arguments.thestruct.admin EQ "T" AND version EQ "1.4">
			<!--- If on Oracle or H2 we need to read and write the Sequences --->
			<cfif variables.database EQ "oracle">
				<!--- Query sequences --->
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT sequence_name as theseq, last_number as thevalue
				FROM all_sequences
				WHERE sequence_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ucase(application.razuna.theschema)#">
				</cfquery>
			<cfelseif variables.database EQ "h2">
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT sequence_name as theseq, current_value as thevalue
				FROM information_schema.sequences
				WHERE IS_GENERATED = false
				</cfquery>
			<cfelseif variables.database EQ "db2">
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT seqname as theseq, nextcachefirstvalue as thevalue
				FROM syscat.sequences
				WHERE seqschema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(application.razuna.theschema)#">
				AND seqtype = <cfqueryparam cfsqltype="cf_sql_varchar" value="S">
				</cfquery>
			</cfif>
<cfif variables.database EQ "oracle" OR variables.database EQ "h2" OR variables.database EQ "db2">
<cfsavecontent variable="thexml"><cfoutput><cfif arguments.thestruct.tofiletype EQ "xml">
	<sequences>
		<cfloop query="qryt"><record id="#currentRow#">
			<col id="sequence_name">#xmlformat(theseq)#</col>
			<col id="current_value">#xmlformat(thevalue)#</col>
		</record>
		</cfloop>
	</sequences>
	<cfelse>
<cfloop query="qryt">INSERT INTO sequences (theid, thevalue) VALUES ('#theseq#', #thevalue#);
</cfloop>	
	</cfif>
</cfoutput>
</cfsavecontent>
			<!--- Write the file --->
			<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thexml#" mode="775" charset="utf-8">
			<cfset thexml = "">
</cfif>
		</cfif>
		<!--- The end of the XML --->
		<cfif arguments.thestruct.tofiletype EQ "xml">
<cfsavecontent variable="theendxml"><cfoutput>
</razuna>
</cfoutput>
</cfsavecontent>
		<!--- Write the file --->
		<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#theendxml#" mode="775" charset="utf-8">
		</cfif>
		<!--- Feedback --->
		<cfoutput><strong>We are almost done. Just a few seconds more...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Backup Dir --->
		<cfif arguments.thestruct.admin EQ "F">
			<cfset var backupdir = "#arguments.thestruct.thepath#/backup/#session.hostid#">
			<cfset var scriptname = replacenocase(cgi.script_name,"index.cfm","","one")>
			<cfset var backupdl = "backup/#session.hostid#/#arguments.thestruct.thedatefile#.zip">
		<cfelseif arguments.thestruct.admin EQ "T">
			<cfset var backupdir = ExpandPath("backup")>
			<cfset var backupdl = "admin/backup/#arguments.thestruct.thedatefile#.zip">
		</cfif>
		<!--- Check if errors folder exists, else create it --->
		<cfif NOT DirectoryExists("#backupdir#")>
			<cfdirectory action="create" directory="#backupdir#" mode="775">
		</cfif>
		<!--- Zip and remove original --->
		<cfif arguments.thestruct.tofiletype EQ "raz">
			<!--- Zip it --->
			<cfzip action="create" zipfile="#backupdir#/#arguments.thestruct.thedatefile#.zip" source="#arguments.thestruct.thisdir#" />
			<!--- Remove it --->
			<cfdirectory action="delete" directory="#arguments.thestruct.thisdir#" recurse="yes" />
		<cfelse>
			<!--- Zip it --->
			<cfzip action="create" zipfile="#backupdir#/#arguments.thestruct.thedatefile#.zip" source="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" />
			<!--- Remove it --->
			<cffile action="delete" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#">
		</cfif>
		<!--- Show status --->
		<cfoutput><span style="font-weight:bold;color:green;">Backup successfully done!</span> <a href="#backupdl#">Download the backup file here</a><br><br><a href="##" onclick="window.close();">Click to close this window</a>.</cfoutput>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Restore --->
	<cffunction name="restorexml" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Get the backed up tables --->
		<cfquery dataSource="razuna_backup" name="backup_tables">
		SELECT lower(table_name) as thetable, table_schema
		FROM information_schema.tables
		WHERE lower(table_schema) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.back_id)#">
		GROUP BY table_name, table_schema
		ORDER BY table_name
		</cfquery>
		<!--- Feedback --->
		<cfoutput><strong>Starting the Restore</strong><br><br></cfoutput>
		<cfflush>
		<!--- Feedback --->
		<cfoutput><strong>Checking consistency of records...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Check that records have values and insert rec_uuid if not there already --->
		<cfinvoke method="check_rec_uuid" theschema="#arguments.thestruct.back_id#" />
		<!--- Params --->
		<cfparam name="arguments.thestruct.admin" default="F">
		<cfparam name="arguments.thestruct.uploadxml" default="F">
		<cfparam name="arguments.thestruct.dsn" default="#application.razuna.datasource#">
		<cfparam name="arguments.thestruct.theschema" default="#application.razuna.theschema#">
		<cfset var thecol = "">
		<cfset var theval = "">
		<cfset var tempgroup = "">
		<cfset var thecounter = 1>
		<cfset var errordate = "import_" & dateformat(now(),"yyyy-mm-dd") & "_" & timeformat(now(),"HH-mm-ss-l")>
		<!--- Set variables into struct for thread below --->
		<cfset arguments.thestruct.hostid = session.hostid>
		<cfset var tt = createuuid()>
		<!--- Loop over the backed up table names and remove all records first --->
		<cfoutput><strong>Database setup...</strong><br><br></cfoutput>
		<cfflush>
		<cfloop query="backup_tables">
			<cfoutput>Currently cleaning up #thetable#<br></cfoutput>
			<cfflush>
			<!--- Drop Constraints --->
			<cfinvoke method="dropconst" theindex="#thetable#">
			<!--- Delete records --->
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM #lcase(thetable)#
				<!--- If on host we only remove the records with the same host_id --->
				</cfquery>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "#thetable#"!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><strong>Database setup done. Continuing...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Feedback --->
		<cfoutput><strong>The database is now empty. Starting to import data...</strong><br></cfoutput>
		<cfflush>
		<!--- All removed ... now import --->		
		<cfoutput>Importing to tables... (please wait)<br><br></cfoutput>
		<cfflush>
		<!--- Params --->
		<cfset var thecollist = "">
		<!--- Loop over the qry results --->
		<cfloop query="backup_tables">
			<cftry>
				<!--- set variables --->
				<cfset thetable = thetable>
				<!--- Feedback --->
				<cfoutput>Currently restoring table #thetable#<br></cfoutput>
				<cfflush>
				<!--- Drop Constraints --->
				<cfinvoke method="dropconst" theindex="#thetable#">
				<!--- Select records from the backup table --->
				<cfquery dataSource="razuna_backup" name="sourcedb">
				SELECT *
				FROM #arguments.thestruct.back_id#.#lcase(thetable)#
				</cfquery>
				<!--- Get Columns --->			
				<cfquery datasource="razuna_backup" name="qry_columns">
				SELECT column_name, type_name
				FROM information_schema.columns
				WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thetable)#">
				AND table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.back_id#">
				ORDER BY column_name, type_name
				</cfquery>
				<!--- Create our custom list --->
				<cfloop query="qry_columns">
					<cfset thecollist = thecollist & column_name & "-" & type_name & ",">
				</cfloop>
				<!--- Remove the last comma --->
				<cfset l = len(thecollist)>
				<cfset thecollist = mid(thecollist,1,l-1)>
				<!--- Set variables for the query loop below --->
				<cfset len_meta = listlen(thecollist)>
				<cfset len_count_meta = 1>
				<cfset len_count_meta2 = 1>
				<!--- Drop Constraints --->
				<cfinvoke method="dropconst" theindex="#lcase(thetable)#">
				<!--- Insert records into target db --->	
				<cfloop query="sourcedb">
					<cftry>
						<!--- Feedback --->
						<cfoutput>.</cfoutput>
						<cfflush>
						<cfquery dataSource="#application.razuna.datasource#">
						INSERT INTO #lcase(thetable)#
						(<cfloop list="#sourcedb.columnlist#" index="m">#listfirst(m,"-")#<cfif len_count_meta NEQ len_meta>, </cfif><cfset len_count_meta = len_count_meta + 1></cfloop>)
						VALUES(
							<cfloop list="#sourcedb.columnlist#" index="cl">
								<cfset lf = ListContainsNoCase(thecollist, cl)>
								<cfset lg = ListGetAt(thecollist, lf)>
								<!--- Varchar --->
								<cfif trim(listlast(lg,"-")) CONTAINS "varchar" OR trim(listlast(lg,"-")) CONTAINS "text">
									<cfif evaluate(cl) EQ "">
										''
									<cfelse>
										<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#evaluate(cl)#">
									</cfif>
								<cfelseif trim(listlast(lg,"-")) CONTAINS "clob">
									<cfif evaluate(cl) EQ "">
										NULL
									<cfelse>
										<cfqueryparam CFSQLType="CF_SQL_CLOB" value="#evaluate(cl)#">
									</cfif>
								<cfelseif trim(listlast(lg,"-")) CONTAINS "int">
									<cfif isnumeric(evaluate(cl))>
										<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#evaluate(cl)#">
									<cfelse>
										NULL
									</cfif>
								<cfelseif trim(listlast(lg,"-")) EQ "date">
									<cfif evaluate(cl) EQ "">
										<cfqueryparam cfsqltype="CF_SQL_DATE" value="#now()#">
									<cfelse>
										<cfqueryparam CFSQLType="CF_SQL_DATE" value="#evaluate(cl)#">
									</cfif>
								<cfelseif trim(listlast(lg,"-")) EQ "timestamp" OR trim(listlast(lg,"-")) EQ "datetime">
									<cfif evaluate(cl) EQ "">
										<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
									<cfelse>
										<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#evaluate(cl)#">
									</cfif>
								<cfelseif trim(listlast(lg,"-")) CONTAINS "blob">
										''
								</cfif>
								<cfif len_count_meta2 NEQ len_meta>,</cfif><cfset len_count_meta2 = len_count_meta2 + 1>
							</cfloop>
						)
						</cfquery>
						<!--- Reset loop variables --->
						<cfset len_count_meta = 1>
						<cfset len_count_meta2 = 1>
						<cfcatch type="database">
							<cfoutput><p><span style="color:red;font-weight:bold;">Error during import on table #thetable#!</span><br>#cfcatch.detail#<br>#cfcatch.sql#</p></cfoutput>
							<!--- Reset loop variables --->
							<cfset len_count_meta = 1>
							<cfset len_count_meta2 = 1>
						</cfcatch>
					</cftry>
				</cfloop>
				<!--- Reset collist --->
				<cfset thecollist = "">
				<!--- Catch Error --->
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">The table #thetable# does not exist or there is something strange going on!</span><br>Please talk to your friendly administrator and let him know of the error below.</p><br>#cfcatch.detail#<br>#cfcatch.sql#</cfoutput>
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetokenall()>
		<!--- Final Feedback --->
		<cfoutput><br><br><span style="font-weight:bold;color:green;">Restore done! You can <a href="##" onclick="window.close();">close this window now</a>.</span><br></cfoutput>	
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Check rec_uuid --->
	<cffunction name="check_rec_uuid" output="true">
		<cfargument name="theschema" required="true" />
		<cftry>
			<!--- Check of label path is empty and add --->
			<cfquery datasource="razuna_backup" name="l">
			select label_id, label_text
			from #arguments.theschema#.raz1_labels
			where (label_path IS NULL OR label_path = '')
			</cfquery>
			<cfloop query="l">
				<cftry>
					<cfquery datasource="razuna_backup">
					UPDATE #arguments.theschema#.raz1_labels
					SET label_path = '#label_text#'
					WHERE label_id = '#label_id#'
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.ct_groups_users ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<!--- ct_groups_users --->
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.ct_groups_users
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.ct_groups_users
					set rec_uuid = '#createuuid()#'
					WHERE CT_G_U_GRP_ID = '#CT_G_U_GRP_ID#'
					AND CT_G_U_USER_ID = '#CT_G_U_USER_ID#'
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "ct_groups_users"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- ct_labels --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.ct_labels ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.ct_labels
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.ct_labels
					set rec_uuid = '#createuuid()#'
					WHERE ct_label_id = '#ct_label_id#'
					AND ct_id_r = '#ct_label_id#'
					AND ct_type = '#ct_label_id#'
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "ct_labels"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- ct_users_hosts --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.ct_users_hosts ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.ct_users_hosts
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.ct_users_hosts
					set rec_uuid = '#createuuid()#'
					WHERE ct_u_h_user_id = '#ct_u_h_user_id#'
					AND CT_U_H_HOST_ID = #CT_U_H_HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "ct_users_hosts"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_folders_desc --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_folders_desc ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_folders_desc
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_folders_desc
					set rec_uuid = '#createuuid()#'
					WHERE folder_id_r = '#folder_id_r#'
					AND LANG_ID_R = #LANG_ID_R#
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_folders_desc"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_folders_groups --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_folders_groups ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_folders_groups
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_folders_groups
					set rec_uuid = '#createuuid()#'
					WHERE folder_id_r = '#folder_id_r#'
					AND grp_id_r = '#grp_id_r#'
					AND GRP_PERMISSION = '#GRP_PERMISSION#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_folders_groups"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_settings --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_settings ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_settings
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_settings
					set rec_uuid = '#createuuid()#'
					WHERE set_id = '#set_id#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_settings"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_settings_2 --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_settings_2 ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_settings_2
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_settings_2
					set rec_uuid = '#createuuid()#'
					WHERE set2_id = '#set2_id#'
					AND set2_nirvanix_pass = '#set2_nirvanix_pass#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_settings_2"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_collections_text --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_collections_text ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_collections_text
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_collections_text
					set rec_uuid = '#createuuid()#'
					WHERE col_id_r = 'col_id_r'
					AND LANG_ID_R = lang_id_r
			        AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_collections_text"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_collections_ct_files --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_collections_ct_files ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_collections_ct_files
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_collections_ct_files
					set rec_uuid = '#createuuid()#'
					WHERE col_id_r = '#col_id_r#'
					AND file_id_r = '#file_id_r#'
					AND COL_FILE_TYPE = '#COL_FILE_TYPE#'
					AND COL_FILE_FORMAT = '#COL_FILE_FORMAT#'
			        AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_collections_ct_files"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_collections_groups --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_collections_groups ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_collections_groups
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_collections_groups
					set rec_uuid = '#createuuid()#'
					WHERE col_id_r = '#col_id_r#'
					AND grp_id_r = '#grp_id_r#'
					AND GRP_PERMISSION = '#GRP_PERMISSION#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_collections_groups"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_users_favorites --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_users_favorites ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_users_favorites
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_users_favorites
					set rec_uuid = '#createuuid()#'
					WHERE user_id_r = '#user_id_r#'
					AND FAV_TYPE = '#FAV_TYPE#'
					AND fav_id = '#fav_id#'
					AND FAV_KIND = '#FAV_KIND#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_users_favorites"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_custom_fields_text --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_custom_fields_text ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_custom_fields_text
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_custom_fields_text
					set rec_uuid = '#createuuid()#'
					WHERE cf_id_r = '#cf_id_r#'
					AND lang_id_r = lang_id_r
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_custom_fields_text"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_custom_fields_values --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_custom_fields_values ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_custom_fields_values
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_custom_fields_values
					set rec_uuid = '#createuuid()#'
					WHERE cf_id_r = '#cf_id_r#'
					AND asset_id_r = '#asset_id_r#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_custom_fields_values"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_versions --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_versions ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_versions
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_versions
					set rec_uuid = '#createuuid()#'
					WHERE asset_id_r = '#asset_id_r#'
					AND ver_version = #ver_version#
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_versions"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_languages --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_languages ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_languages
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_languages
					set rec_uuid = '#createuuid()#'
					WHERE lang_id = #lang_id#
					AND lang_name = '#lang_name#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_languages"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_share_options --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_share_options ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_share_options
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_share_options
					set rec_uuid = '#createuuid()#'
					WHERE asset_id_r = '#asset_id_r#'
					AND group_asset_id = '#group_asset_id#'
					AND folder_id_r = '#folder_id_r#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_share_options"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
		<!--- raz1_upload_templates_val --->
		<!--- Add the rec_uuid to the tables. Wrap in a catch in case they exists --->
		<cftry>
			<cfquery datasource="razuna_backup">
			ALTER TABLE #arguments.theschema#.raz1_upload_templates_val ADD rec_uuid VARCHAR(100)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="razuna_backup" name="x">
			select * 
			from #arguments.theschema#.raz1_upload_templates_val
			where rec_uuid IS NULL or rec_uuid = ''
			</cfquery>
			<!--- Update --->
			<cfloop query="x">
				<cftry>
					<cfquery datasource="razuna_backup">
					update #arguments.theschema#.raz1_upload_templates_val
					set rec_uuid = '#createuuid()#'
					WHERE upl_temp_id_r = '#upl_temp_id_r#'
			  		AND upl_temp_field = '#upl_temp_field#'
					AND HOST_ID = #HOST_ID#
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "raz1_upload_templates_val"!</span><br>#cfcatch.detail#</p></cfoutput>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!--- Drop Constraints --->
	<cffunction name="dropconst" output="true">
		<cfargument name="theindex" type="string">
		<!--- MSSQL: Drop all constraints --->
		<cfif application.razuna.thedatabase EQ "mssql">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE #lcase(arguments.theindex)# NOCHECK CONSTRAINT ALL
				</cfquery>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">A error occurred during import on table #arguments.theindex#!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		<!--- MySQL: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			<cfquery datasource="#application.razuna.datasource#">
			SET FOREIGN_KEY_CHECKS = 0
			</cfquery>
		<!--- H2: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "h2">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				ALTER TABLE #lcase(arguments.theindex)# SET REFERENTIAL_INTEGRITY false
				</cfquery>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">A error occurred during import on table #arguments.theindex#!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		<!--- Oracle: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "oracle">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT constraint_name
				FROM user_constraints
				WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.theindex)#">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #lcase(arguments.theindex)# DISABLE CONSTRAINT #constraint_name# CASCADE
					</cfquery>
				</cfloop>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">A error occurred during import on table #arguments.theindex#!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Drop Constraints --->
	<cffunction name="dropconstall" output="true">
		<cfargument name="theindex" type="string">
		<!--- MSSQL: Drop all constraints --->
		<cfif application.razuna.thedatabase EQ "mssql">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT table_name, constraint_name
				FROM information_schema.constraint_column_usage
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.theindex)#%">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #lcase(table_name)# NOCHECK CONSTRAINT ALL
					</cfquery>
				</cfloop>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">A error occurred during import on table #arguments.theindex#!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		<!--- MySQL: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#">
				SET foreign_key_checks = 0
				</cfquery>
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT table_name
				FROM information_schema.tables
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.theindex)#%">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #lcase(table_name)# DISABLE KEYS
					</cfquery>
				</cfloop>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">A error occurred during import on table #arguments.theindex#!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		<!--- H2: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "h2">
			<cfquery datasource="#application.razuna.datasource#">
			SET REFERENTIAL_INTEGRITY false
			</cfquery>
		<!--- Oracle: Drop all constraints --->
		<cfelseif application.razuna.thedatabase EQ "oracle">
			<cftry>
				<cfquery datasource="#application.razuna.datasource#" name="con">
				SELECT constraint_name, table_name
				FROM user_constraints
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.theindex)#%">
				</cfquery>
				<cfloop query="con">
					<cfquery datasource="#application.razuna.datasource#">
					ALTER TABLE #lcase(table_name)# DISABLE CONSTRAINT #constraint_name# CASCADE
					</cfquery>
				</cfloop>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">A error occurred during import on table #arguments.theindex#!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Write XML --->
	<cffunction name="writexml" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Params --->
		<cfset var thecolumns = "">
		<!--- Loop over the qry results --->
		<cfloop query="arguments.thestruct.qry">
			<cfif thetable DOES NOT CONTAIN "temp">
			<!--- Feedback --->
			<cfoutput>Currently running backup of #thetable#<br></cfoutput>
			<cfflush>
			<!--- Get Columns --->
			<cfif application.razuna.thedatabase EQ "db2">
				<cfquery datasource="#variables.dsn#" name="qry_columns">
				SELECT colname as column_name, typename as data_type
				FROM syscat.columns
				WHERE lower(tabname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thetable)#">
				AND colname != 'ADMIN'
				AND colname != 'NAME'
				AND colname != 'REMARKS'
				AND colname != 'ID'
				AND colname != 'IMAGE'
				AND colname != 'THUMB'
				AND colname != 'COMP'
				AND colname != 'COMP_UW'
				AND colname != 'SET2_INTRANET_LOGO'
				AND tabschema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(application.razuna.theschema)#">
				</cfquery>
			<cfelse>			
				<cfquery datasource="#variables.dsn#" name="qry_columns">
				SELECT column_name, <cfif application.razuna.thedatabase EQ "h2">type_name as data_type<cfelse>data_type</cfif>
				FROM <cfif application.razuna.thedatabase EQ "oracle">all_tab_columns<cfelse>information_schema.columns</cfif>
				WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(thetable)#">
				AND column_name != 'ADMIN'
				AND column_name != 'NAME'
				AND column_name != 'REMARKS'
				AND column_name != 'ID'
				AND column_name != 'IMAGE'
				AND column_name != 'THUMB'
				AND column_name != 'COMP'
				AND column_name != 'COMP_UW'
				AND column_name != 'SET2_INTRANET_LOGO'
				</cfquery>
			</cfif>
			<!--- Create our custom list --->
			<cfloop query="qry_columns">
				<cfset thecolumns = thecolumns & column_name & "--" & data_type & ",">
			</cfloop>
			<!--- Query values from table --->
			<cfquery datasource="#variables.dsn#" name="qryt">
			SELECT #valuelist(qry_columns.column_name)#
			FROM #thetable#
			<cfif arguments.thestruct.admin EQ "F">
				<cfif thetable EQ "MODULES">
					WHERE mod_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfelseif thetable EQ "PERMISSIONS">
					WHERE per_host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				<cfelse>
					WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfif>
			</cfif>
			</cfquery>
			<cfif arguments.thestruct.tofiletype EQ "raz">
				<cfset len_meta = listlen(thecolumns)>
				<cfset len_count = 1>
				<!--- Write the table metadata --->
				<cfsavecontent variable="thetablefile"><cfoutput><cfloop list="#thecolumns#" index="i">#lcase(listfirst(i,"--"))#-#lcase(listlast(i,"--"))#<cfif len_count NEQ len_meta>, </cfif><cfset len_count = len_count + 1></cfloop></cfoutput></cfsavecontent>
				<cffile action="append" file="#arguments.thestruct.thisdir#/#lcase(thetable)#.txt" output="#thetablefile#" mode="775" charset="utf-8">
				<!--- Write the records --->
				<cfset r = csvwrite(qryt,true)>
				<cffile action="append" file="#arguments.thestruct.thisdir#/#lcase(thetable)#.csv" output="#r#" mode="775" charset="utf-8">
				<cfset thecolumns = "">
			<cfelse>
				<!--- Create the XML for this table --->
<cfsavecontent variable="thexml"><cfoutput><cfif arguments.thestruct.tofiletype EQ "xml">
	<table id="#lcase(thetable)#">
		<cfloop query="qryt"><record id="#currentRow#">
		<cfloop list="#thecolumns#" index="i">	<col id="#lcase(listfirst(i,"--"))#" type="#lcase(listlast(i,"--"))#"><cfif listlast(i,"--") CONTAINS "varchar" OR listlast(i,"--") CONTAINS "text" OR listlast(i,"--") EQ "clob"><![CDATA[</cfif>#xmlformat(evaluate(listfirst(i,"--")))#<cfif listlast(i,"--") CONTAINS "varchar" OR listlast(i,"--") CONTAINS "text" OR listlast(i,"--") EQ "clob">]]></cfif></col>
		</cfloop></record>
		</cfloop><cfif qryt.recordcount EQ 1><record id="FALSE">
		</record></cfif>
	</table>
<cfelseif arguments.thestruct.tofiletype EQ "sql"><cfset thistable = lcase(thetable)><cfloop query="qryt"><cfset count1 = 0><cfset count2 = 0>INSERT INTO #thistable# (<cfloop list="#thecolumns#" index="i"><cfset count1 = count1 + 1>#listfirst(i,"--")#<cfif count1 NEQ listlen(thecolumns)>,</cfif></cfloop>) VALUES (<cfloop list="#thecolumns#" index="i"><cfset count2 = count2 + 1><cfif listlast(i,"--") CONTAINS "varchar" OR listlast(i,"--") CONTAINS "text" OR listlast(i,"--") EQ "clob"><cfset thet = Replace(evaluate(listfirst(i,"--")), chr(10), " ", "ALL")><cfset thet = Replace(evaluate(listfirst(i,"--")), chr(13), " ", "ALL")><cfset thet = REReplace(evaluate(listfirst(i,"--")),"[#chr(10)#|#chr(13)#]"," ","ALL")><cfset thet = Replace(thet, "'", "\'", "ALL")><cfset thet = Replace(thet, ",", "\,", "ALL")><cfset thet = Replace(thet, ";", "\;", "ALL")>'#thet#'<cfelseif evaluate(listfirst(i,"--")) EQ "">NULL<cfelseif listlast(i,"--") CONTAINS "timestamp" OR listlast(i,"--") EQ "datetime">timestamp '#evaluate(listfirst(i,"--"))#'<cfelseif listlast(i,"--") EQ "date">date '#evaluate(listfirst(i,"--"))#'<cfelse>#evaluate(listfirst(i,"--"))#</cfif><cfif count2 NEQ listlen(thecolumns)>,</cfif></cfloop>);
</cfloop>
</cfif>
</cfoutput>
</cfsavecontent>
				<!--- Write the file --->
				<cffile action="append" file="#GetTempDirectory()#/#arguments.thestruct.thedatefile#" output="#thexml#" mode="775" charset="utf-8">
				<cfset thexml = "">
				<cfset thecolumns = "">
			</cfif>
			</cfif>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Upload Backup File --->
	<cffunction name="uploadxml" output="true">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfset var mystruct = structnew()>
		<cfset var foldername = createuuid("")>
		<cftry>
			<!--- Create folder --->
			<cfdirectory action="create" directory="#arguments.thestruct.thepath#/incoming/#foldername#" mode="775">
			<!--- Upload file --->
			<cffile action="UPLOAD" filefield="#arguments.thestruct.thefield#" destination="#arguments.thestruct.thepath#/incoming/#foldername#" result="result" nameconflict="overwrite" mode="775">
			<cfcatch type="any">Ups, something went wrong with the uploaded file!</cfcatch>
		</cftry>
		<!--- The path to return --->
		<cfset mystruct.uploadpath = "#arguments.thestruct.thepath#/incoming/#foldername#">
		<cfset mystruct.thebackupfile = "#arguments.thestruct.thepath#/incoming/#foldername#/#result.serverfile#">
		<cfset mystruct.theuploadxml = "#result.serverfilename#">
		<!--- Return --->
		<cfreturn mystruct>
	</cffunction>
	
	<!--- Save scheduled backup --->
	<cffunction name="setschedbackup" output="false">
		<cfargument name="interval" type="string">
		<!--- If we need to reset the key then save first --->
		<cfif arguments.interval EQ 0>
			<cfinvoke component="settings" method="savesetting" thefield="sched_backup" thevalue="0" />
			<cfschedule action="delete" task="RazScheduledBackup" />
		<cfelse>
			<cfinvoke component="settings" method="savesetting" thefield="sched_backup" thevalue="#arguments.interval#" />
			<!--- Get Server URL --->
			<cfset serverUrl = "#session.thehttp##cgi.HTTP_HOST##cgi.SCRIPT_NAME#">
			<cfset startDate = LSDateFormat(now(), "mm/dd/yyyy")>
			<cfset startTime = LSTimeFormat(now(), "HH:mm")>
			<!--- Save scheduled event in CFML scheduling engine --->
			<cfschedule action="update"
						task="RazScheduledBackup" 
						operation="HTTPRequest"
						url="#serverUrl#?fa=c.runschedbackup&tofiletype=raz"
						startDate="#startDate#"
						startTime="#startTime#"
						interval="#arguments.interval#">
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>
