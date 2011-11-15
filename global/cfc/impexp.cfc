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
<cfcomponent output="false">
	
	<!--- Default Tables --->
	<cffunction name="defaultoracle2h2" access="public" output="true">
		<cfargument name="thestruct" type="Struct">
		<!--- Sequences --->
		<!--- Drop all Sequences first --->
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE CATEGORIES_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE COLLECTION_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE CONTENT_ID_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE CT_USERS_REMOTEUSERS_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE CTUAG_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE CTUG_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE CTUH_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE FILE_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE FOLDER_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE GROUPSADMIN_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE GROUPS_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE HOSTID_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE IMG_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE KEYWORDS_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE LOG_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE PERMISSIONS_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE PUB_GRP_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE PUB_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE SCHEDULE_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE SCHED_LOG_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE USERLOGIN_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE USERS_LISTS_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE USERS_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE USER_SHIP_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE VALUELIST_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE CUSTOMFIELD_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DROP SEQUENCE TEXT_SEQ;
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<!--- First select the next sequence value and then do the insert --->
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CATEGORIES_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE CATEGORIES_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT COLLECTION_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE COLLECTION_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CONTENT_ID_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE CONTENT_ID_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CT_USERS_REMOTEUSERS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE CT_USERS_REMOTEUSERS_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CTUAG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE CTUAG_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CTUG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE CTUG_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CTUH_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE CTUH_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT FILE_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE FILE_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT FOLDER_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE FOLDER_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT GROUPSADMIN_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE GROUPSADMIN_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT GROUPS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE GROUPS_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT HOSTID_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE HOSTID_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT IMG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE IMG_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT KEYWORDS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE KEYWORDS_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT LOG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE LOG_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT PERMISSIONS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE PERMISSIONS_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT PUB_GRP_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE PUB_GRP_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT PUB_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE PUB_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT SCHEDULE_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE SCHEDULE_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT SCHED_LOG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE SCHED_LOG_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USERLOGIN_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE USERLOGIN_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USERS_LISTS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE USERS_LISTS_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USERS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE USERS_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USER_SHIP_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE USER_SHIP_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT VALUELIST_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE VALUELIST_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CUSTOMFIELD_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE CUSTOMFIELD_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT TEXT_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			CREATE SEQUENCE TEXT_SEQ INCREMENT BY 1 START WITH #nseq.id#
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<!--- List of tables to select and insert to --->
		<cfset arguments.thestruct.thetables = "HOSTS,USERS,MODULES,PERMISSIONS,GROUPS,CT_GROUPS_USERS,CT_GROUPS_PERMISSIONS,LOG_ACTIONS,CT_USERS_HOSTS,USERS_LOGIN,WISDOM,USERS_COMMENTS,FILE_TYPES,CT_USERS_REMOTEUSERS,WEBSERVICES,SEARCH_REINDEX">
		<!--- Delete default tables --->
		<cfquery datasource="#arguments.thestruct.dsn_target#" name="nseq">
		SET REFERENTIAL_INTEGRITY FALSE
		</cfquery>
		<cfloop list="#arguments.thestruct.thetables#" index="dt">
			<cftry>
				<cfquery datasource="#arguments.thestruct.dsn_target#">
				DROP TABLE #dt#
				</cfquery>
				<cfcatch type="database">#cfcatch.detail#</cfcatch>
			</cftry>
		</cfloop>
		<!--- Create default tables --->
		<cfset arguments.thestruct.fromimport = "T">
		<cfinvoke component="db_h2" method="setup" thestruct="#arguments.thestruct#">
		<!--- Call function to loop over tables and do inserts  --->
		<cfinvoke method="loopinsertorah2" thestruct="#arguments.thestruct#">
	</cffunction>
	
	<!--- oracle2h2 --->
	<cffunction name="oracle2h2" access="public" output="true">
		<cfargument name="thestruct" type="Struct">
		<cfset var thispre = "#ucase(arguments.thestruct.host_db_prefix)#" & "%">
		<!--- Get all the tables of this host --->
		<cfquery datasource="#arguments.thestruct.dsn_source#" name="qry_tables">
		SELECT object_name 
		FROM user_objects 
		WHERE object_type='TABLE' 
		AND object_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#thispre#">
		</cfquery>
		<!--- Put results into list --->
		<cfset arguments.thestruct.thetables = valuelist(qry_tables.object_name)>
		<!--- Call function to loop over tables and do inserts  --->
		<cfinvoke method="loopinsertorah2" thestruct="#arguments.thestruct#">
	</cffunction>
	
	<!--- Loop over tables and do insert --->
	<cffunction name="loopinsertorah2" access="public" output="true">
		<cfargument name="thestruct" type="Struct">
		<cfset var thecounter = 1>
		<cfset var thecounterint = 1>
		<cfset var thecolumns = "">
		<!--- Loop over these default tables --->
		<cfloop list="#arguments.thestruct.thetables#" index="tb_name">
			<!--- UCASE tablename (just making sure) --->
			<cfset tb_name = ucase(tb_name)>
			<!--- Get Columns and Types --->
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="qry_columns">
			SELECT column_name,data_type
			FROM all_tab_cols 
			WHERE table_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tb_name#">
			</cfquery>
			<!--- Create our custom list --->
			<cfloop query="qry_columns">
				<cfset thecolumns = thecolumns & column_name & "--" & data_type & ",">
			</cfloop>
			<!--- Cut off the last coma --->
			<cfset thecl = len(thecolumns) - 1>
			<cfset thecolumns = mid(thecolumns,1,thecl)>
			<!--- Disable Constraints --->
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			SET REFERENTIAL_INTEGRITY FALSE
			</cfquery>
			<!--- Remove all records in the destination table --->
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DELETE FROM #tb_name#
			</cfquery>
			<!--- Select records from original table --->
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="tt">
			SELECT <cfloop list="#thecolumns#" index="v">#listfirst(v,"--")#<cfif thecounter LT qry_columns.recordcount>,</cfif><cfset thecounter = thecounter + 1></cfloop>
			FROM #tb_name#
			</cfquery>
			<!--- Reset counter --->
			<cfset thecounter = 1>
			<!--- Loop over records from original table --->
			<cfloop query="tt">
				<cftry>
					<!--- Do the insert into destination table --->
					<cfquery datasource="#arguments.thestruct.dsn_target#">
					INSERT INTO #tb_name#
					(<cfloop list="#thecolumns#" index="v">#listfirst(v,"--")#<cfif thecounter LT qry_columns.recordcount>,</cfif><cfset thecounter = thecounter + 1></cfloop>)
					VALUES(
					<cfloop list="#thecolumns#" index="i">
						<!--- Set vars --->
						<cfset thetype = listlast(i,"--")>
						<!--- Decide according to type --->
						<cfif thetype EQ "number">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								NULL
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_numeric" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype CONTAINS "timestamp">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype EQ "date">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_date" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype CONTAINS "varchar">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								NULL
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype CONTAINS "clob">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(listfirst(i,"--"))#">
						</cfif>
						<cfif thecounterint LT qry_columns.recordcount>,</cfif>
						<cfset thecounterint = thecounterint + 1>
					</cfloop>
					)
					</cfquery>
					<cfcatch type="database"><cfdump var="#cfcatch#"></cfcatch>
				</cftry>
				<!--- Reset counter --->
				<cfset thecounter = 1>
				<cfset thecounterint = 1>
			</cfloop>
			<!--- Reset Column List --->
			<cfset thecolumns = "">
		<!--- Done --->
		</cfloop>
	</cffunction>
	
	<!--- H2 to MySQL --->
	<cffunction name="h2tomysql" access="public" output="true">
		<cfargument name="thestruct" type="Struct">
		<!--- DEFAULT TABLES: List of default tables --->
		<cfset arguments.thestruct.thetables = "SEQUENCES,HOSTS,USERS,MODULES,PERMISSIONS,GROUPS,CT_GROUPS_USERS,CT_GROUPS_PERMISSIONS,LOG_ACTIONS,CT_USERS_HOSTS,USERS_LOGIN,WISDOM,USERS_COMMENTS,FILE_TYPES,CT_USERS_REMOTEUSERS,WEBSERVICES,SEARCH_REINDEX">
		<!--- DEFAULT TABLES: Drop all default tables --->
		<cfloop list="#arguments.thestruct.thetables#" index="dt">
			<cftry>
				<cfquery datasource="#arguments.thestruct.dsn_target#">
				SET foreign_key_checks = 0
				</cfquery>
				<cfquery datasource="#arguments.thestruct.dsn_target#">
				DROP TABLE #dt#
				</cfquery>
				<cfcatch type="any">#cfcatch.detail#</cfcatch>
			</cftry>
		</cfloop>
		<!--- DEFAULT TABLES: Create default tables --->
		<cfset arguments.thestruct.fromimport = "T">
		<cfset arguments.thestruct.dsn = arguments.thestruct.dsn_target>
		<cfinvoke component="db_mysql" method="setup" thestruct="#arguments.thestruct#">
		<!--- DEFAULT TABLES: Get sequences from H2 and insert into MySQL --->
		<cfinvoke method="h2tomysqlsequences" thestruct="#arguments.thestruct#">
		<!--- DEFAULT TABLES: import values --->
		<cfinvoke method="h2tomysqlvalues" thestruct="#arguments.thestruct#">
		<!--- HOST TABLES: Loop over tables schema to check if there are any tables with this prefix, if so delete them --->
		<cfquery datasource="#arguments.thestruct.dsn_source#" name="qry_tables">
		SELECT table_name
		FROM information_schema.tables
		WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.thestruct.host_db_prefix)#%">
		</cfquery>
		<!--- HOST TABLES: Drop tables --->
		<cfloop query="qry_tables">
			<cftry>
				<cfquery datasource="#arguments.thestruct.dsn_target#">
				SET foreign_key_checks = 0
				</cfquery>
				<cfquery datasource="#arguments.thestruct.dsn_target#">
				DROP TABLE #table_name#
				</cfquery>
				<cfcatch type="database">#cfcatch.detail#</cfcatch>
			</cftry>
		</cfloop>
		<!--- HOST TABLES: Setup host tables --->
		<cfinvoke component="db_mysql" method="create_host_remote" dsn="#arguments.thestruct.dsn_target#" theschema="razuna" />
		<!--- HOST TABLES: Put results into list --->
		<cfset arguments.thestruct.thetables = valuelist(qry_tables.table_name)>
		<!--- HOST TABLES: Now get values of tables and do an insert --->
		<cfinvoke method="h2tomysqlvalues" thestruct="#arguments.thestruct#">
	</cffunction>
	
	<!--- H2 to MySQL Sequences --->
	<cffunction name="h2tomysqlsequences" access="public" output="true">
		<cfargument name="thestruct" type="Struct">
		<!--- First select the next sequence value and then do the insert --->
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CATEGORIES_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('categories_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"><cfdump var="#cfcatch#"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT COLLECTION_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('collection_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CONTENT_ID_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('content_id_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CT_USERS_REMOTEUSERS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ct_users_remoteusers_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CTUAG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ctuag_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CTUG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ctug_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CTUH_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ctuh_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT FILE_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('file_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT FOLDER_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('folder_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT GROUPSADMIN_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('groupsadmin_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT GROUPS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('groups_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT HOSTID_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('hostid_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT IMG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('img_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT KEYWORDS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('keywords_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT LOG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('log_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT PERMISSIONS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('permissions_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT PUB_GRP_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('pub_grp_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT PUB_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('pub_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT SCHEDULE_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('schedule_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT SCHED_LOG_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('sched_log_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USERLOGIN_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('userlogin_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USERS_LISTS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('users_lists_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USERS_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('users_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT USER_SHIP_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('user_ship_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT VALUELIST_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('valuelist_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT CUSTOMFIELD_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('customfield_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="nseq">
			SELECT TEXT_SEQ.nextval id
			FROM dual
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('text_seq', #nseq.id#)
			</cfquery>
			<cfcatch type="database"></cfcatch>
		</cftry>
	
	
	</cffunction>
	
	<!--- H2 to MySQL: Import values --->
	<cffunction name="h2tomysqlvalues" access="public" output="true">
		<cfargument name="thestruct" type="Struct">
		<cfset var thecounter = 1>
		<cfset var thecounterint = 1>
		<cfset var thecolumns = "">
		<!--- Remove the sequences tables from the list since this table is not available in H2 --->
		<cfset arguments.thestruct.thetables = replacenocase(arguments.thestruct.thetables,"sequences,","","all")>
		<!--- Loop over these default tables --->
		<cfloop list="#arguments.thestruct.thetables#" index="tb_name">
			<!--- LCASE tablename (just making sure) --->
			<cfset tb_name = lcase(tb_name)>
			<!--- Get Columns and Types --->
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="qry_columns">
			SELECT column_name, type_name
			FROM information_schema.columns
			WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tb_name#">
			AND column_name != 'ADMIN'
			AND column_name != 'NAME'
			AND column_name != 'REMARKS'
			AND column_name != 'ID'
			</cfquery>
			<!--- Create our custom list --->
			<cfloop query="qry_columns">
				<cfset thecolumns = thecolumns & column_name & "--" & type_name & ",">
			</cfloop>
			<!--- Cut off the last coma --->
			<cfset thecl = len(thecolumns) - 1>
			<cfset thecolumns = mid(thecolumns,1,thecl)>
			<!--- Disable Constraints --->
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			SET foreign_key_checks = 0
			</cfquery>
			<!--- Remove all records in the destination table --->
			<cfquery datasource="#arguments.thestruct.dsn_target#">
			DELETE FROM #tb_name#
			</cfquery>
			<!--- Select records from original table --->
			<cfquery datasource="#arguments.thestruct.dsn_source#" name="tt">
			SELECT <cfloop list="#thecolumns#" index="v">#listfirst(v,"--")#<cfif thecounter LT qry_columns.recordcount>,</cfif><cfset thecounter = thecounter + 1></cfloop>
			FROM #tb_name#
			</cfquery>
			<!--- Reset counter --->
			<cfset thecounter = 1>
			<!--- Loop over records from original table --->
			<cfloop query="tt">
				<!--- Disable Constraints --->
				<cfquery datasource="#arguments.thestruct.dsn_target#">
				SET foreign_key_checks = 0
				</cfquery>
				<cftry>
					<!--- Do the insert into destination table --->
					<cfquery datasource="#arguments.thestruct.dsn_target#">
					INSERT INTO #tb_name#
					(<cfloop list="#thecolumns#" index="v">#listfirst(v,"--")#<cfif thecounter LT qry_columns.recordcount>,</cfif><cfset thecounter = thecounter + 1></cfloop>)
					VALUES(
					<cfloop list="#thecolumns#" index="i">
						<!--- Set vars --->
						<cfset thetype = listlast(i,"--")>
						<!--- Decide according to type --->
						<cfif thetype EQ "bigint" OR thetype EQ "integer">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								NULL
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_numeric" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype EQ "timestamp">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype EQ "date">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_date" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype EQ "varchar_ignorecase">
							<cfif evaluate(listfirst(i,"--")) EQ "">
								NULL
							<cfelse>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(listfirst(i,"--"))#">
							</cfif>
						<cfelseif thetype CONTAINS "clob">
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate(listfirst(i,"--"))#">
						<cfelseif thetype CONTAINS "blob">
							''
						</cfif>
						<cfif thecounterint LT qry_columns.recordcount>,</cfif>
						<cfset thecounterint = thecounterint + 1>
					</cfloop>
					)
					</cfquery>
					<cfcatch type="database"><cfdump var="#cfcatch#"></cfcatch>
				</cftry>
				<!--- Reset counter --->
				<cfset thecounter = 1>
				<cfset thecounterint = 1>
			</cfloop>
			<!--- Reset Column List --->
			<cfset thecolumns = "">
		<!--- Done --->
		</cfloop>
		
	</cffunction>
	
</cfcomponent>
