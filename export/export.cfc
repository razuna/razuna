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
<cfcomponent>

	<!--- Backup to DB --->
	<cffunction name="backup" output="true">
		<cfargument name="thispath" />
		<!--- Param --->
		<cfset arguments.thestruct = structnew()>
		<cfset arguments.thestruct.dsn = "razuna_backup_export">
		<cfset arguments.thestruct.fromimport = "T">
		<cfset arguments.thestruct.tschema = "B" & replace(createuuid(),"-","","all")>
		<!--- Feedback --->
		<cfoutput><strong>Starting the Backup. Churning on some internal stuff...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Check for datasource on the razuna_backup --->
		<cfinvoke method="checkdb" thispath="#arguments.thispath#" />
		<!--- Clear razuna_backup db
		<cfinvoke method="cleardb" thestruct="#arguments.thestruct#" /> --->
		<!--- Create schema in the backup DB --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE SCHEMA #arguments.thestruct.tschema#
		</cfquery>
		<!--- Create date --->
		<cfset var thedate = dateformat(now(),"yyyy/mm/dd") & " " & timeformat(now(),"HH:MM tt")>
		<cfset arguments.thestruct.thedatefile = dateformat(now(),"yyyy-mm-dd") & "_" & timeformat(now(),"HH-mm-ss-l") & ".raz">
		<!--- Grab the db prefix from the host table --->
		<cfquery datasource="#application.razuna.datasource#" name="qryhost">
		SELECT host_shard_group
		FROM hosts
		GROUP BY host_shard_group
		</cfquery>
		<!--- Loop over the prefixes and create tables --->
		<cfloop query="qryhost">
			<!--- Create tables --->
			<cfset arguments.thestruct.host_db_prefix = "#host_shard_group#">
			<cfinvoke component="db_backup" method="setup" thestruct="#arguments.thestruct#" />
			<cfinvoke component="db_backup" method="create_tables" thestruct="#arguments.thestruct#" />
		</cfloop>
		<!--- Insert creation date into status db --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO backup_status
		(back_id, back_date, host_id)
		VALUES(
			<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.tschema#">,
			<cfqueryparam CFSQLType="CF_SQL_TIMESTAMP" value="#now()#">,
			<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="0">
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
				)
				GROUP BY object_name
				ORDER BY object_name
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
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
				lower(tabname) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#theprefix#">
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
				)
				AND tabschema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(application.razuna.theschema)#">
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
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables...</strong><br></cfoutput>
				<cfflush>
				<!--- Select all host tables --->
				<cfquery datasource="#application.razuna.datasource#" name="arguments.thestruct.qry">
				SELECT lower(table_name) as thetable
				FROM information_schema.tables
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#theprefix#">
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
				OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_users">
				OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_groups_permissions">
				OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_hosts">
				OR lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="ct_users_remoteusers">
				GROUP BY table_name
				ORDER BY table_name
				</cfquery>
				<!--- Write XML --->
				<cfinvoke method="writexml" thestruct="#arguments.thestruct#">
				<!--- Feedback --->
				<cfoutput><strong>Backing up tables... done!</strong><br><br></cfoutput>
				<cfflush>
			</cfif>
		</cfloop>
		<!--- Feedback --->
		<cfoutput><span style="font-weight:bold;color:green;">Backup successfully done!</span><br><br>
		<span style="font-weight:bold;color:red;">NOTE: The Backup can be found in the Backup directory. Please make sure you follow the <a href="http://wiki.razuna.com/display/ecp/Upgrade+Guide" target="_blank">upgrade path described on our Wiki page!!!</a></span><br><br><a href="##" onclick="window.close();">Click to close this window</a></cfoutput>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Write XML --->
	<cffunction name="writexml" output="true">
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
			FROM #thetable#
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
				<cfquery dataSource="#arguments.thestruct.dsn#">
				INSERT INTO #arguments.thestruct.tschema#.#thetable#
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
						<cfelseif trim(listlast(lg,"-")) EQ "timestamp">
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
			</cfloop>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Check DB --->
	<cffunction name="checkdb" output="true">
		<cfargument name="thispath" />
		<!--- Create the DB on the filesystem --->
		<cfinvoke component="db_backup" method="BDsetDatasource">
			<cfinvokeargument name="name" value="razuna_backup_export" />
			<cfinvokeargument name="databasename" value="razuna_backup" />
			<cfinvokeargument name="logintimeout" value="120" />
			<cfinvokeargument name="initstring" value="" />
			<cfinvokeargument name="connectionretries" value="0" />
			<cfinvokeargument name="connectiontimeout" value="120" />
			<cfinvokeargument name="username" value="razuna" />
			<cfinvokeargument name="password" value="razunadb" />
			<cfinvokeargument name="sqlstoredprocedures" value="true" />
			<cfinvokeargument name="hoststring" value="jdbc:h2:file:#arguments.thispath#/backup/razuna_backup;IGNORECASE=TRUE;MODE=Oracle;AUTO_RECONNECT=TRUE;LOG=0;CACHE_SIZE=300000;CACHE_TYPE=SOFT_LRU" />
			<cfinvokeargument name="sqlupdate" value="true" />
			<cfinvokeargument name="sqlselect" value="true" />
			<cfinvokeargument name="sqlinsert" value="true" />
			<cfinvokeargument name="sqldelete" value="true" />
			<cfinvokeargument name="perrequestconnections" value="true" />
			<cfinvokeargument name="drivername" value="org.h2.Driver" />
			<cfinvokeargument name="maxconnections" value="24" />
		</cfinvoke>
	</cffunction>
	
	<!--- Clear DB --->
	<cffunction name="cleardb" output="true">
		<cfargument name="thestruct" />
		<cfquery datasource="#arguments.thestruct.dsn#" name="qry">
		SELECT table_name
		FROM information_schema.tables
		WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="PUBLIC">
		</cfquery>
		<cfloop query="qry">
			<cftry>
				<!--- Turn off referentials --->
				<cfquery dataSource="#arguments.thestruct.dsn#">
				SET REFERENTIAL_INTEGRITY false
				</cfquery>
				<cfquery datasource="#arguments.thestruct.dsn#">
				DROP TABLE #table_name#
				</cfquery>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>
	</cffunction>
	
</cfcomponent>
