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

<!--- List fields --->
<cffunction name="get" output="false" access="public">
	<cfargument name="fieldsenabled" type="boolean" required="false" default="false">
	<cfargument name="xmppath" type="boolean" required="false" default="false">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("general")>
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getcustomfields */ c.cf_id, c.cf_type, c.cf_order, c.cf_enabled, c.cf_show, ct.cf_text, c.cf_xmp_path
		FROM #session.hostdbprefix#custom_fields c, #session.hostdbprefix#custom_fields_text ct
		WHERE c.cf_id = ct.cf_id_r
 		AND ct.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		<cfif arguments.fieldsenabled>
			AND lower(c.cf_enabled) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		</cfif>
		<cfif arguments.xmppath>
			AND (c.cf_xmp_path IS NOT NULL OR c.cf_xmp_path <cfif application.razuna.thedatabase EQ "h2"><><cfelse>!=</cfif> '')
		</cfif>
		ORDER BY c.cf_order
		</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Add field --->
<cffunction name="add" output="false" access="public">
	<cfargument name="thestruct" type="struct">
	<!--- Params --->
	<cfset var newcfid = createuuid()>
	<cfparam name="arguments.thestruct.cf_group" default="" />
	<!--- If no group is selected --->
	<cfif !structKeyExists(arguments.thestruct,"cf_edit")>
		<cfset arguments.thestruct.cf_edit = "true">
	</cfif>
	<cftransaction>
		<!--- Add one up for order --->
		<cfquery datasource="#application.razuna.datasource#" name="neworder">
		SELECT 
		<cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2">NVL<cfelseif application.razuna.thedatabase EQ "mysql">ifnull<cfelseif application.razuna.thedatabase EQ "mssql">isnull</cfif>(max(cf_order),0) + 1 AS theorder
		FROM #session.hostdbprefix#custom_fields
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Insert record --->
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#custom_fields
		(cf_id, cf_type, cf_order, cf_enabled, cf_show, cf_group, host_id, cf_select_list, cf_edit)
		VALUES(
		<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#newcfid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_type#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#neworder.theorder#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_enabled#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_show#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_group#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_select_list#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_edit#">
		)
		</cfquery>
	</cftransaction>
	<!--- Add text to related db --->
	<cfloop list="#arguments.thestruct.langcount#" index="langindex">
		<cfset thetext="arguments.thestruct.cf_text_" & "#langindex#">
		<cfif thetext CONTAINS "#langindex#">
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#custom_fields_text
			(cf_id_r, lang_id_r, cf_text, host_id, rec_uuid)
			VALUES(
			<cfqueryparam value="#newcfid#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">,
			<cfqueryparam value="#evaluate(thetext)#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
			<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Return --->
	<cfreturn newcfid />
</cffunction>

<!--- Get fields for the detail view of assets --->
<cffunction name="getfields" output="false" access="public">
	<cfargument name="thestruct" type="struct">
	<cfparam name="arguments.thestruct.cf_show" default="">
	<!--- Param --->
	<cfset var list="">
	<cfif StructKeyExists(session,"thefileid") AND session.thefileid NEQ "" AND session.thefileid NEQ "0" >
		<cfset list="all">
		<cfloop list="#session.thefileid#" index="assets">
			<cfif not listFindNoCase(list,listLast(assets,"-"))>
				<cfset list = listAppend(list,'#listLast(assets,"-")#')>
			</cfif>
		</cfloop>
	</cfif>
	<!--- Get the cachetoken for here --->
	<cfset variables.cachetoken = getcachetoken("general")>
	<cfset var qry = "">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
	SELECT /* #variables.cachetoken#getfields */ c.cf_id, c.cf_type, c.cf_order, c.cf_select_list, c.cf_edit, ct.cf_text, cv.cf_value, c.cf_in_form, c.cf_show
	FROM #session.hostdbprefix#custom_fields_text ct, #session.hostdbprefix#custom_fields c 
	LEFT JOIN #session.hostdbprefix#custom_fields_values cv ON cv.cf_id_r = c.cf_id AND cv.asset_id_r = '#arguments.thestruct.file_id#'
	WHERE c.cf_id = ct.cf_id_r
	AND lower(c.cf_enabled) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
	<cfif list NEQ "">
		AND lower(c.cf_show) in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#list#" list="true" >)
	<cfelseif arguments.thestruct.cf_show EQ "users">
		AND lower(c.cf_show) = <cfqueryparam cfsqltype="cf_sql_varchar" value="users">
	<cfelse>
		AND (
			lower(c.cf_show) = <cfqueryparam cfsqltype="cf_sql_varchar" value="all">
			OR lower(c.cf_show) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_show#">
		)
	</cfif>
	<cfif structKeyExists(arguments.thestruct,"cf_in_form")>
		AND c.cf_in_form = <cfqueryparam cfsqltype="cf_sql_varchar" value="true">
	</cfif>
	AND ct.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.thelangid#">
	AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	ORDER BY c.cf_order
	</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Get fields for the search view --->
<cffunction name="getfieldssearch" output="false" access="public">
	<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("general")>
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getfieldssearch */ c.cf_id, c.cf_type, c.cf_order, c.cf_show, c.cf_select_list, ct.cf_text
		FROM #session.hostdbprefix#custom_fields_text ct, #session.hostdbprefix#custom_fields c 
		WHERE c.cf_id = ct.cf_id_r
		AND lower(c.cf_enabled) = <cfqueryparam cfsqltype="cf_sql_varchar" value="t">
		AND ct.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.thelangid#">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		GROUP BY c.cf_id, c.cf_type, c.cf_order, c.cf_show, c.cf_select_list, ct.cf_text
		ORDER BY c.cf_order
		</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Get text and values --->
<cffunction name="gettextvalues" output="false" access="public">
	<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("general")>
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getfieldssearch */ cv.cf_value, ct.cf_text, ct.cf_id_r
		FROM #session.hostdbprefix#custom_fields_text ct, #session.hostdbprefix#custom_fields c, #session.hostdbprefix#custom_fields_values cv
		WHERE cv.asset_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND ct.cf_id_r = cv.cf_id_r
		AND ct.cf_id_r = c.cf_id
		AND ct.lang_id_r = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.thelangid#">
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		GROUP BY cv.cf_value, ct.cf_text, c.cf_order, ct.cf_id_r
		ORDER BY c.cf_order
		</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Get detail view --->
<cffunction name="getdetail" output="false" access="public">
	<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("general")>
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getdetailcustomfields */ c.cf_id, c.cf_type, c.cf_order, c.cf_show, c.cf_enabled, c.cf_group, 
		c.cf_edit, c.cf_select_list, ct.cf_text, ct.lang_id_r, c.cf_in_form, c.cf_xmp_path
		FROM #session.hostdbprefix#custom_fields_text ct, #session.hostdbprefix#custom_fields c
		WHERE c.cf_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.cf_id#">
		AND ct.cf_id_r = c.cf_id
		AND c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfreturn qry>
</cffunction>

<!--- Save field values --->
<cffunction name="savevalues" output="false" access="public">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Loop over the fields which only are custom fields --->
	<cfloop collection="#arguments.thestruct#" item="i">
		<cfif i CONTAINS "cf_" AND i DOES NOT CONTAIN "META_" >
			<!--- <cfif arguments.thestruct[i] EQ "">
				<cfcontinue>
			</cfif> --->
			<!--- Remove the cf_ part so we only get the id --->
			<cfset theid = replacenocase("#i#", "cf_", "", "ALL")>
			<!--- Remove carriage return and new line --->
			<cfset thevalue = REReplace(arguments.thestruct[i], "\r\n|\n\r|\n|\r", "", "all")>
			<!--- RAZ-2837 :: Update custom fields when renditions exists and rendition's metadata option is True --->
			<cfif structKeyExists(arguments.thestruct,'qry_related') AND structKeyExists(arguments.thestruct,'option_rendition_meta') AND arguments.thestruct.option_rendition_meta EQ 'true'>
				<!--- Get additional renditions --->
				<cfquery datasource="#variables.dsn#" name="getaddver">
				SELECT av_id FROM #session.hostdbprefix#additional_versions
				WHERE asset_id_r in (<cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR" list="true">)
				</cfquery>
				<cfif arguments.thestruct.thefiletype EQ 'img'>
					<cfset arguments.thestruct.file_id = listappend(arguments.thestruct.file_id,'#valuelist(arguments.thestruct.qry_related.img_id)#',',')>
				<cfelseif arguments.thestruct.thefiletype EQ 'aud'>
					<cfset arguments.thestruct.file_id = listappend(arguments.thestruct.file_id,'#valuelist(arguments.thestruct.qry_related.aud_id)#',',')>
				<cfelseif arguments.thestruct.thefiletype EQ 'vid'>
					<cfset arguments.thestruct.file_id = listappend(arguments.thestruct.file_id,'#valuelist(arguments.thestruct.qry_related.vid_id)#',',')>
				</cfif>
				<cfset arguments.thestruct.file_id = listappend(arguments.thestruct.file_id,'#valuelist(getaddver.av_id)#',',')>
			</cfif>
			<cfloop list="#arguments.thestruct.file_id#" index="index" delimiters="," >
				<!--- Insert or update --->
				<cfquery datasource="#application.razuna.datasource#" name="qry">
				SELECT cf_id_r
				FROM #session.hostdbprefix#custom_fields_values
				WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
				AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#index#">
				</cfquery>
				<!--- Insert --->
				<cfif qry.recordcount EQ 0>
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#custom_fields_values
					(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
					VALUES(
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
					<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#index#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#thevalue#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				<!--- Update --->
				<cfelse>
					<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#custom_fields_values
						SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thevalue#">
						WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
						AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#index#">
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("search")>
	<cfset variables.cachetoken = resetcachetoken("general")>
</cffunction>

<!--- Save batch field values --->
<cffunction name="savebatchvalues" output="false" access="public">
	<cfargument name="thestruct" type="struct">
	<cfset var qry = "">
	<!--- Loop over the fields which only are custom fields --->
	<cfloop collection="#arguments.thestruct#" item="i">
		<cfif i CONTAINS "cf_" AND arguments.thestruct[i] NEQ ''>
			<!--- Remove the cf_ part so we only get the id --->
			<cfset theid = replacenocase("#i#", "cf_", "", "ALL")>
			<cfset list="">
			<cfif StructKeyExists(arguments.thestruct,"file_id")>
				<cfloop list="#arguments.thestruct.file_id#" index="idx">
					<cfset list = listAppend(list,'#idx#')>
				</cfloop>
			</cfif>
			<cfif list NEQ ''>
				<cfloop list="#list#" index="index" delimiters="," >
					<cfquery datasource="#application.razuna.datasource#" name="q">
					SELECT cf_show, cf_type
					FROM #session.hostdbprefix#custom_fields
					WHERE cf_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
					AND host_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.hostid#">
					</cfquery>	
					<!--- Insert or update --->
					<cfquery datasource="#application.razuna.datasource#" name="qry">
					SELECT cf_id_r,cf_value
					FROM #session.hostdbprefix#custom_fields_values
					WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
					AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#listfirst(index,"-")#">
					AND host_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#session.hostid#">
					</cfquery>
					<cfset appendValue = ''>
					<cfif arguments.thestruct.batch_replace EQ 'false' AND (q.cf_show EQ listlast(index,"-") OR q.cf_show EQ 'all')>
						<cfif qry.cf_value NEQ ''>
							<cfif q.cf_type EQ "radio" OR q.cf_type EQ "select">
								<cfset appendValue = arguments.thestruct[i]>
							<cfelse>
								<cfset appendValue = qry.cf_value &' '& arguments.thestruct[i]>
							</cfif>
						<cfelse>
							<cfset appendValue = arguments.thestruct[i]>
						</cfif>
					<cfelse>
						<cfset appendValue = arguments.thestruct[i]>
					</cfif>
					<cfif q.cf_show EQ 'all' OR q.cf_show EQ listlast(index,"-")>
						<!--- Insert --->
						<cfif qry.recordcount EQ 0>
							<cfquery datasource="#application.razuna.datasource#">
							INSERT INTO #session.hostdbprefix#custom_fields_values
							(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
							VALUES(
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">,
							<cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#listfirst(index,"-")#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct[i]#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
							<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
							)
							</cfquery>
						<!--- Update --->
						<cfelse>
							<cfquery datasource="#application.razuna.datasource#">
							UPDATE #session.hostdbprefix#custom_fields_values
							SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#appendValue#">
							WHERE cf_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#theid#">
							AND asset_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#listfirst(index,"-")#">
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset resetcachetoken("search")>
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Lucene is indexing these values in the video.cfc already thus we are done here --->
</cffunction>

<!--- Update field --->
<cffunction name="update" output="false" access="public">
	<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfparam name="arguments.thestruct.cf_in_form" default="true" />
		<cfparam name="arguments.thestruct.cf_group" default="" />
		<!--- If no group is selected --->
		<cfif !structKeyExists(arguments.thestruct,"cf_edit")>
			<cfset arguments.thestruct.cf_edit = "true">
		</cfif>
		<!--- Remove carriage return and new line --->
		<cfset var theselectvalue = REReplace(arguments.thestruct.cf_select_list, "\r\n|\n\r|\n|\r", "", "all")>
		<!--- Update record --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#custom_fields
		SET
		cf_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_type#">, 
		cf_enabled = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_enabled#">, 
		cf_show = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_show#">, 
		cf_group = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_group#">,
		cf_select_list = <cfqueryparam cfsqltype="cf_sql_varchar" value="#theselectvalue#">,
		cf_in_form = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_in_form#">,
		cf_edit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_edit#">,
		cf_xmp_path = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.cf_xmp_path#">
		WHERE cf_id = <cfqueryparam value="#arguments.thestruct.cf_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Add text to related db --->
		<cfloop list="#arguments.thestruct.langcount#" index="langindex">
			<cfparam name="arguments.thestruct.cf_text_#langindex#" default="">
			<cfset thetext="arguments.thestruct.cf_text_" & "#langindex#">
			<cfif thetext CONTAINS "#langindex#">
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#custom_fields_text
				SET cf_text = <cfqueryparam value="#evaluate(thetext)#" cfsqltype="cf_sql_varchar">
				WHERE cf_id_r = <cfqueryparam value="#arguments.thestruct.cf_id#" cfsqltype="CF_SQL_VARCHAR">
				AND lang_id_r = <cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">
				</cfquery>
			</cfif>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- Delete --->
<cffunction name="delete" access="public" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<!--- Rearrange the order --->
	<cfquery datasource="#application.razuna.datasource#">
	UPDATE #session.hostdbprefix#custom_fields
	SET cf_order = cf_order - 1
	WHERE cf_order > <cfqueryparam value="#arguments.thestruct.order#" cfsqltype="cf_sql_numeric">
	AND cf_order <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "h2" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> 1
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- remove record --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#custom_fields
	WHERE cf_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.id#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("search")>
	<cfset variables.cachetoken = resetcachetoken("general")>
</cffunction>

<!--- Save order --->
<cffunction name="saveorder" output="false" access="public" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Init vars --->
	<cfset var theorder = 1>
	<!--- Loop over fields and update DB --->
	<cfloop list="#arguments.thestruct.theorderlist#" delimiters="," index="i">
		<cfif i NEQ "thefields">
			<!--- Update record --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#custom_fields
			SET cf_order = <cfqueryparam cfsqltype="cf_sql_numeric" value="#theorder#">
			WHERE cf_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
			</cfquery>
			<!--- Increase the order --->
			<cfset theorder = theorder + 1>
		</cfif>
	</cfloop>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>

<!--- Delete values --->
<cffunction name="delete_values" output="false" access="public" returntype="void">
	<cfargument name="fileid" type="string">
	<!--- Query --->
	<cfquery datasource="#application.razuna.datasource#">
	DELETE FROM #session.hostdbprefix#custom_fields_values
	WHERE asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileid#">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset variables.cachetoken = resetcachetoken("general")>
	<cfreturn />
</cffunction>


</cfcomponent>