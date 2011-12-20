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

<!---  --->
<!--- UPDATE FROM 1.3.5 TO 1.4 --->
<!---  --->

<cfcomponent extends="extQueryCaching" output="false">

	<cfset this.tableoptions = "ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_bin">

	<!--- Check for a DB update --->
	<cffunction name="update_for">
		<!--- Param --->
		<cfset fordb = structnew()>
		<!--- Set Update for DB here! --->
		<cfset fordb.for_oracle = 0>
		<cfset fordb.for_h2 = 0>
		<cfset fordb.for_mysql = 0>
		<cfset fordb.for_mssql = 0>
		<!--- Check for the used DB and set variables accordingly --->
		<cfif application.razuna.thedatabase EQ "oracle" AND fordb.for_oracle>
			<cfset fordb.update = 1>
		<cfelseif application.razuna.thedatabase EQ "h2" AND fordb.for_h2>
			<cfset fordb.update = 1>
		<cfelseif application.razuna.thedatabase EQ "mysql" AND fordb.for_mysql>
			<cfset fordb.update = 1>
		<cfelseif application.razuna.thedatabase EQ "mssql" AND fordb.for_mssql>
			<cfset fordb.update = 1>
		<cfelse>
			<cfset fordb.update = 0>
		</cfif>
		<cfreturn fordb>
	</cffunction>

	<!--- Check for a new version --->
	<cffunction name="check_update">
		<cfargument name="thestruct" type="struct">	
		<cfset v = structnew()>
		<!--- Set the version file on the server --->
		<cfset var versionfile = "http://cloud.razuna.com/installers/versionupdate.xml">
		<!--- Get the current version --->
		<cfinvoke component="settings" method="getconfig" thenode="version" returnvariable="currentversion">
		<!--- Parse the version file on the server --->
		<cftry>
			<cfhttp url="#versionfile#" method="get" throwonerror="no" timeout="5">
			<cfset var xmlVar=xmlParse(versionfile)/>
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
		<!--- Name for the log --->
		<cfset logname = "razuna_update_" & dateformat(now(),"mm_dd_yyyy") & "_" & timeformat(now(),"HH-mm-ss")>
		<!--- ORACLE / H2 --->
		<cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2">
			<!--- Core DB --->
			<cftry>
				<cfquery datasource="#variables.dsn#">
				CREATE TABLE search_reindex
				(
					theid		VARCHAR2(100 CHAR),
					thevalue	NUMBER,
					thehostid 	NUMBER,
					datetime 	TIMESTAMP
				)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table search_reindex: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#variables.dsn#">
				ALTER TABLE hosts ADD host_shard_group varchar2(10 CHAR)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table host_shard_group: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<!--- <cftry>
				<cfquery datasource="#variables.dsn#">
				ALTER TABLE permissions DROP CONSTRAINT PERMISSIONS_UK1
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table permissions: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry> --->
		<!--- MYSQL --->
		<cfelseif application.razuna.thedatabase EQ "mysql">
			<!--- Core DB --->
			<cftry>
				<cfquery datasource="#variables.dsn#">
				CREATE TABLE search_reindex
				(
					theid 		VARCHAR(100),
					thevalue 	INT,
					thehostid 	INT,
					datetime 	TIMESTAMP
				)
				#this.tableoptions#
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table search_reindex: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#variables.dsn#">
				ALTER TABLE hosts ADD COLUMN host_shard_group varchar(10)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table search_reindex: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<!--- <cftry>
				<cfquery datasource="#variables.dsn#">
				ALTER TABLE permissions DROP INDEX PERMISSIONS_UK1
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table permissions: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry> --->
		<!--- MSSQL --->
		<cfelseif application.razuna.thedatabase EQ "mssql">
			<!--- Core DB --->
			<cftry>
				<cfquery datasource="#variables.dsn#">
				CREATE TABLE search_reindex
				(
					theid 		VARCHAR(100),
					thevalue 	INT,
					thehostid 	INT,
					datetime 	DATETIME
				)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table search_reindex: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<cftry>
				<cfquery datasource="#variables.dsn#">
				ALTER TABLE hosts ADD host_shard_group varchar(10)
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table search_reindex: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry>
			<!--- <cftry>
				<cfquery datasource="#variables.dsn#" name="con">
				SELECT constraint_name
				FROM information_schema.constraint_column_usage
				WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="permissions">
				AND constraint_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="FK%">
				</cfquery>
				<cfquery datasource="#variables.dsn#">
				ALTER TABLE permissions DROP CONSTRAINT PERMISSIONS_UK1
				</cfquery>
				<cfcatch type="any">
					<cflog application="no" file="#logname#" type="error" text="Table permissions: message: #cfcatch.message# Detail: #cfcatch.detail#">
				</cfcatch>
			</cftry> --->
		</cfif>
		<!--- Create the RAZ1_ tables --->
		<cfset arguments.thestruct.dsn = variables.dsn>
		<cfset arguments.thestruct.host_db_prefix = "raz1_">
		<cfset arguments.thestruct.theschema = application.razuna.theschema>
		<cfinvoke component="db_#application.razuna.thedatabase#" method="create_host" thestruct="#arguments.thestruct#">
		<!--- Set sharding group to raz1_ for all hosts --->
		<cfquery datasource="#variables.dsn#">
		UPDATE hosts
		SET host_shard_group = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.host_db_prefix#">
		</cfquery>
		<!--- Loop over hosts, get tables and insert into raz1_ tables --->
		<cfloop query="arguments.thestruct.qryhosts">
			<!--- Put host_db_prefix & host_id in variable since the loop below does not see it --->
			<cfset theprefix = host_db_prefix>
			<cfset thehostid = host_id>
			<!--- Oracle --->
			<cfif application.razuna.thedatabase EQ "oracle">
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT object_name as thetable
				FROM user_objects 
				WHERE object_type='TABLE' 
				AND lower(object_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(theprefix)#%">
				</cfquery>
			<!--- all other DBs --->
			<cfelse>
				<cfquery datasource="#variables.dsn#" name="qryt">
				SELECT table_name as thetable
				FROM information_schema.tables
				WHERE lower(table_name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(theprefix)#%">
				</cfquery>
			</cfif>
			<!--- Now insert with select --->
			<cfloop query="qryt">
				<cftry>
					<!--- Set the raz1_ db name --->
					<cfset raz_table = replacenocase(thetable,theprefix,arguments.thestruct.host_db_prefix,"one")>
					<!--- Get Columns --->
					<cfquery datasource="#variables.dsn#" name="qry_columns">
					SELECT column_name
					FROM information_schema.columns
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
					<!--- Set column list --->
					<cfset thecolumns = valuelist(qry_columns.column_name)>
					<cfquery datasource="#variables.dsn#">
					INSERT INTO #raz_table#
					(#thecolumns#)
					SELECT #thecolumns#
					FROM #thetable#
					</cfquery>
					<!--- And add the host_id to this table --->
					<cfquery datasource="#variables.dsn#">
					UPDATE #raz_table#
					SET host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thehostid#">
					</cfquery>
					<cfcatch type="any">
						<cflog application="no" file="#logname#" type="error" text="Table #thetable#: message: #cfcatch.message# Detail: #cfcatch.detail#">
					</cfcatch>
				</cftry>
			</cfloop>
		</cfloop>
		<!--- Now set the path_to_asset --->
		<cfquery dataSource="#variables.dsn#" name="x">
		SELECT img_id, folder_id_r
		FROM raz1_images
		</cfquery>
		<cfloop query="x">
			<cfquery dataSource="#variables.dsn#">
			update raz1_images
			set path_to_asset = '#folder_id_r#/img/#img_id#',
			is_available = '1'
			where img_id = '#img_id#'
			</cfquery>
		</cfloop>
		<cfquery dataSource="#variables.dsn#" name="x">
		SELECT file_id, folder_id_r
		FROM raz1_files
		</cfquery>
		<cfloop query="x">
			<cfquery dataSource="#variables.dsn#">
			update raz1_files
			set path_to_asset = '#folder_id_r#/doc/#file_id#',
			is_available = '1'
			where file_id = #file_id#
			</cfquery>
		</cfloop>
		<cfquery dataSource="#variables.dsn#" name="x">
		SELECT vid_id, folder_id_r
		FROM raz1_videos
		</cfquery>
		<cfloop query="x">
			<cfquery dataSource="#variables.dsn#">
			update raz1_videos
			set path_to_asset = '#folder_id_r#/vid/#vid_id#',
			is_available = '1'
			where vid_id = #vid_id#
			</cfquery>
		</cfloop>
		<cfquery dataSource="#variables.dsn#" name="x">
		SELECT aud_id, folder_id_r
		FROM raz1_audios
		</cfquery>
		<cfloop query="x">
			<cfquery dataSource="#variables.dsn#">
			update raz1_audios
			set path_to_asset = '#folder_id_r#/aud/#aud_id#',
			is_available = '1'
			where aud_id = #aud_id#
			</cfquery>
		</cfloop>
		<!--- All done and update should be flying --->
	</cffunction>



</cfcomponent>