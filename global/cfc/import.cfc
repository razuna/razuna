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
<cfcomponent output="false" extends="extQueryCaching">

	!--- Templates: Get all --->
	<cffunction name="getTemplates" output="true">
		<cfargument name="theactive" type="boolean" required="false" default="false">
		<!--- Query --->
		<cfquery dataSource="#application.razuna.datasource#" name="qry">
		SELECT imp_temp_id, imp_active, imp_name, imp_description
		FROM #session.hostdbprefix#import_templates
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.theactive>
			AND imp_active = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="1">
		</cfif>
		</cfquery>
		<!--- Return --->
		<cfreturn qry>
	</cffunction>

	<!--- Get DETAILED Upload Templates ---------------------------------------------------------------------->
	<cffunction name="gettemplatedetail" output="false">
		<cfargument name="imp_temp_id" type="string" required="true">
		<!--- New struct --->
		<cfset var qry = structnew()>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.imp">
		SELECT imp_who, imp_active, imp_name, imp_description
		FROM #session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Query values --->
		<cfquery datasource="#application.razuna.datasource#" name="qry.impval">
		SELECT imp_field, imp_map, imp_key
		FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.imp_temp_id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		ORDER BY imp_field
		</cfquery>
		<cfreturn qry />
	</cffunction>
	
	<!--- Save Upload Templates ---------------------------------------------------------------------->
	<cffunction name="settemplate" output="false">
		<cfargument name="thestruct" type="struct" required="true">
		<!--- Param --->
		<cfparam name="arguments.thestruct.imp_active" default="0">
		<!--- Delete all records with this ID in the MAIN DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">
		</cfquery>
		<!--- Save to main DB --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#import_templates
		(imp_temp_id, imp_date_create, imp_date_update, imp_who, imp_active, host_id, imp_name, imp_description)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_TIMESTAMP" value="#now()#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.theuserid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_active#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_name#">,
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_description#">
		)
		</cfquery>
		<!--- Delete all records with this ID in the DB --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">
		</cfquery>
		<!--- Get the name and select fields --->
		<cfset var thefield = "">
		<cfset var theselect = "">
		<cfloop collection="#arguments.thestruct#" item="i">
			<cfif i CONTAINS "field_">
				<!--- Get values --->
				<cfset f = listfirst(i,"_")>
				<cfset fn = listlast(i,"_")>
				<cfset fg = f & "_" & fn>
				<cfset thefield = thefield & "," & fg>
			</cfif>
			<cfif i CONTAINS "select_">
				<!--- Get values --->
				<cfset s = listfirst(i,"_")>
				<cfset sn = listlast(i,"_")>
				<cfset sg = s & "_" & sn>
				<cfset theselect = theselect & "," & sg>
			</cfif>
		</cfloop>
		<!--- loop over list amount and do insert and listgetat --->
		<cfloop from="1" to="#listlen(thefield)#" index="i">
			<cfset fi = listgetat(thefield, listfindnocase(thefield,"field_#i#"))>
			<cfset se = listgetat(theselect, listfindnocase(theselect,"select_#i#"))>
			<cfset fi_value = arguments.thestruct["#fi#"]>
			<cfset se_value = arguments.thestruct["#se#"]>
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#import_templates_val
			(imp_temp_id_r, host_id, rec_uuid, imp_field, imp_map<cfif arguments.thestruct.radio_key EQ i>, imp_key</cfif>)
			VALUES(
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.imp_temp_id#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#createuuid()#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#fi_value#">,
			<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#se_value#">
			<cfif arguments.thestruct.radio_key EQ i>, 				
				<cfqueryparam cfsqltype="CF_SQL_DOUBLE" value="true">
			</cfif>
			)
			</cfquery>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Remove Templates ---------------------------------------------------------------------->
	<cffunction name="removetemplate" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates
		WHERE imp_temp_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#import_templates_val
		WHERE imp_temp_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<cfreturn  />
	</cffunction>
	
	<!--- Upload ---------------------------------------------------------------------->
	<cffunction name="upload" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- Upload file to the temp folder --->
		<cffile action="upload" destination="#GetTempdirectory()#" nameconflict="overwrite" filefield="#arguments.thestruct.thefieldname#" result="thefile">
		<!--- Grab the extensions and create new name --->
		<cfset var ext = listlast(thefile.serverFile,".")>
		<cfset var thenamenew = arguments.thestruct.tempid & "." & ext>
		<!--- Rename --->
		<cffile action="rename" source="#GetTempdirectory()#/#thefile.serverFile#" destination="#GetTempdirectory()#/#thenamenew#" />
		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
	<!--- Do the Import ---------------------------------------------------------------------->
	<cffunction name="doimport" output="false">
		<cfargument name="thestruct" type="struct">
		<!--- CSV and XML --->
		<cfif arguments.thestruct.file_format EQ "csv" OR arguments.thestruct.file_format EQ "xml">
			<!--- Read the file --->
			<cffile action="read" file="#GetTempdirectory()#/#arguments.thestruct.tempid#.#arguments.thestruct.file_format#" charset="utf-8" variable="thefile" />
		<!--- XLS and XLSX --->
		<cfelse>
			
		</cfif>
		<!--- Read CSV --->
		<cfif arguments.thestruct.file_format EQ "csv">
			<cfset var thecsv = csvread(string=thefile, headerline=arguments.thestruct.imp_header)>
		</cfif>
		<cfdump var="#thecsv#"><cfabort>

		<!--- Return --->
		<cfreturn  />
	</cffunction>
	
</cfcomponent>