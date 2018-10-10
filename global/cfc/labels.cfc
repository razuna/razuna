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

	<!--- Update the label of a record --->
	<cffunction name="label_update" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- Check if users are allowed to add labels --->
		<cfinvoke component="settings" method="get_label_set" thestruct="#arguments.thestruct#" returnvariable="perm" />
		<cfset var qry = "">
		<!--- Check if label exists --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT label_text, label_id AS labelid
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_text = <cfqueryparam value="#arguments.thestruct.thelab#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- If exists then add label to this record --->
		<cfif qry.recordcount NEQ 0>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO ct_labels
			(
				ct_label_id,
				ct_id_r,
				ct_type,
				rec_uuid
			)
			VALUES
			(
				<cfqueryparam value="#qry.labelid#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#arguments.thestruct.id#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		<!--- If label does NOT exists then add label and add to this record --->
		<cfelse>
			<cfif perm.set2_labels_users EQ "t">
				<!--- Insert function --->
				<cfinvoke method="label_add" returnvariable="labelid" thestruct="#arguments.thestruct#" />
				<!--- Insert to related label DB --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				INSERT INTO ct_labels
				(
					ct_label_id,
					ct_id_r,
					ct_type,
					rec_uuid
				)
				VALUES
				(
					<cfqueryparam value="#labelid#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.thestruct.id#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
				</cfquery>
			</cfif>
		</cfif>
		<!--- Update Dates --->
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.type#" fileid="#arguments.thestruct.id#" thestruct="#arguments.thestruct#" />
		<!--- Flush --->
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Add labels --->
	<cffunction name="label_add_all" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- <cfset consoleoutput(true, true)>
		<cfset console("arguments.thestruct", arguments.thestruct)> --->
		<cfinvoke method="label_add_all_thread" thestruct="#arguments.thestruct#" />
		<!--- <cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="label_add_all_thread" thestruct="#attributes.intstruct#" />
		</cfthread> --->
	</cffunction>

	<!--- Add labels --->
	<cffunction name="label_add_all_thread" output="true" access="public">
		<cfargument name="thestruct" type="struct">

		<cfif arguments.thestruct.fileid EQ "0">
			<cfreturn />
		</cfif>

		<!--- <cfset consoleoutput(true, true)>
		<cfset console("THE ID #arguments.thestruct.fileid#")>
		<cfset console("THE TYPE #arguments.thestruct.thetype#")> --->

		<cfset var i = "">
		<!--- Param --->
		<cfparam name="arguments.thestruct.batch_replace" default="true">
		<!--- Update Dates --->
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.thetype#" fileid="#arguments.thestruct.fileid#" thestruct="#arguments.thestruct#" />
		<!--- Remove all labels for this record --->
		<cfif arguments.thestruct.batch_replace>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			DELETE FROM ct_labels
			WHERE ct_id_r = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />
			AND ct_type = <cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar" />
			</cfquery>
		</cfif>
		<cfif structkeyexists(arguments.thestruct,"labels") AND arguments.thestruct.labels NEQ "null">
			<!--- Loop over fields --->
			<cfloop list="#arguments.thestruct.labels#" delimiters="," index="i">
				<!--- Check if same record already exists --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="lhere">
				SELECT ct_label_id
				FROM ct_labels
				WHERE ct_label_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar" />
				AND ct_id_r = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />
				</cfquery>
				<!--- If record is here do not insert --->
				<cfif lhere.recordcount EQ 0>
					<!--- Insert into cross table --->
					<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
					INSERT INTO ct_labels
					(
						ct_label_id,
						ct_id_r,
						ct_type,
						rec_uuid
					)
					VALUES
					(
						<cfqueryparam value="#i#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
				</cfif>
			</cfloop>
			<!--- Set index according to type --->
			<cfif arguments.thestruct.thetype EQ "img">
				<!--- Set for indexing --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				UPDATE #arguments.thestruct.razuna.session.hostdbprefix#images
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE img_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				</cfquery>
			<cfelseif arguments.thestruct.thetype EQ "vid">
				<!--- Set for indexing --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				UPDATE #arguments.thestruct.razuna.session.hostdbprefix#videos
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE vid_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				</cfquery>
			<cfelseif arguments.thestruct.thetype EQ "aud">
				<!--- Set for indexing --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				UPDATE #arguments.thestruct.razuna.session.hostdbprefix#audios
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE aud_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				</cfquery>
			<cfelse>
				<!--- Set for indexing --->
				<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				UPDATE #arguments.thestruct.razuna.session.hostdbprefix#files
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE file_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
				</cfquery>
			</cfif>
			<!--- Flush --->
			<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
			<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		</cfif>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Add label from batch --->
	<cffunction name="label_add_batch" output="false" access="public">
		<cfargument name="thestruct" type="struct">
		<cfset var j = "">
		<!--- Loop over files_ids --->
		<cfthread intstruct="#arguments.thestruct#">
			<!--- <cfset consoleoutput(true, true)>
			<cfset console("FIRST !!! attributes.intstruct.file_ids: #attributes.intstruct.file_ids#")> --->
			<cfif attributes.intstruct.file_ids EQ "all">
				<!--- As we have all get all IDS from this search --->
				<cfinvoke component="search" method="getAllIdsMain" thestruct="#attributes.intstruct#" searchupc="#attributes.intstruct.razuna.session.search.searchupc#" searchtext="#attributes.intstruct.razuna.session.search.searchtext#" searchtype="#attributes.intstruct.razuna.session.search.searchtype#" searchrenditions="#attributes.intstruct.razuna.session.search.searchrenditions#" searchfolderid="#attributes.intstruct.razuna.session.search.searchfolderid#" hostid="#attributes.intstruct.razuna.session.hostid#" returnvariable="ids">
					<!--- Set the fileid --->
					<cfset attributes.intstruct.file_ids = ids>
			</cfif>
			<!--- <cfset console("AFTER !!! attributes.intstruct.file_ids: #attributes.intstruct.file_ids#")>
			<cfabort> --->
			<cfloop list="#attributes.intstruct.file_ids#" index="j" delimiters=",">
				<!--- <cfset console("J: #j#")> --->
				<cfset attributes.intstruct.fileid = listfirst(j,"-")>
				<cfset attributes.intstruct.thetype = listlast(j,"-")>
				<!--- <cfset console("attributes.intstruct.thetype: #attributes.intstruct.thetype#")> --->
				<!--- Now pass each asset to the function above to add labels --->
				<cfinvoke method="label_add_all" thestruct="#attributes.intstruct#" />
			</cfloop>
		</cfthread>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Insert Label --->
	<cffunction name="label_add" output="false" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- ID --->
		<cfset var theid = createuuid("")>
		<cfset var thelabel = replace(arguments.thestruct.thelab,"'","","all")>
		<!--- Insert into Label DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#labels
		(
			label_id,
			label_text,
			label_date,
			user_id,
			host_id
		)
		VALUES(
			<cfqueryparam value="#theid#" cfsqltype="cf_sql_varchar" />,
			<cfqueryparam value="#trim(thelabel)#" cfsqltype="cf_sql_varchar" />,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />,
			<cfqueryparam value="#arguments.thestruct.razuna.session.theuserid#" cfsqltype="cf_sql_varchar" />,
			<cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		)
		</cfquery>
		<!--- Flush --->
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn theid />
	</cffunction>

	<!--- Remove the label of a record --->
	<cffunction name="label_remove" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<cfset var qry = "">
		<!--- Get label id --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT label_id
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_text = <cfqueryparam value="#arguments.thestruct.thelab#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Remove from ct_labels --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM ct_labels
		WHERE ct_label_id = <cfqueryparam value="#qry.label_id#" cfsqltype="cf_sql_varchar" />
		AND ct_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="cf_sql_varchar" />
		AND ct_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Update Dates --->
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.type#" fileid="#arguments.thestruct.id#" thestruct="#arguments.thestruct#" />
		<!--- Flush --->
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Get all labels --->
	<cffunction name="getalllabels" output="false" access="public">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Params --->
		<cfset var st = structnew()>
		<cfset var l = "">
		<cfset var qry = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getalllabels */ label_text, label_path, label_id
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		ORDER BY label_text
		</cfquery>
		<!--- Put into list --->
		<cfloop query="qry">
			<cfset l = l & "," & "'#label_text#'">
		</cfloop>
		<cfif l NEQ "">
			<cfset l = RemoveChars(l, 1, 1)>
		</cfif>
		<!--- Put result into struct --->
		<cfset st.l = "[#l#]">
		<cfset st.qryl = qry>
		<!--- Return --->
		<cfreturn st />
	</cffunction>

	<!--- Get label of record --->
	<cffunction name="getlabels" output="false" access="public" returntype="string">
		<cfargument name="theid" type="string">
		<cfargument name="thetype" type="string">
		<cfargument name="checkUPC" type="string" required="false" default="false" >
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Param --->
		<cfset var l = "">
		<cfset var qryct = "">
		<cfset var qry = "">
		<!--- Query ct table --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qryct" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getlabels */ ct_label_id
		FROM ct_labels
		WHERE ct_id_r = <cfqueryparam value="#arguments.theid#" cfsqltype="cf_sql_varchar" />
		AND ct_type = <cfqueryparam value="#arguments.thetype#" cfsqltype="cf_sql_varchar" />
		AND ct_label_id <cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Query --->
		<cfif qryct.recordcount NEQ 0>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #cachetoken#getlabels2 */ label_id
			FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
			WHERE label_id IN (<cfqueryparam value="#valuelist(qryct.ct_label_id)#" cfsqltype="cf_sql_varchar" list="true" />)
			AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<cfif structKeyExists(arguments,'checkUPC') AND arguments.checkUPC EQ 'true'>
				AND label_text = <cfqueryparam value="upc" cfsqltype="cf_sql_varchar" />
			</cfif>
			ORDER BY label_text
			</cfquery>
			<!--- Param --->
			<cfset var l = valuelist(qry.label_id)>
		</cfif>
		<!--- Return --->
		<cfreturn l />
	</cffunction>

	<!--- Get label of record --->
	<cffunction name="getlabelstextexport" output="false" access="public">
		<cfargument name="theid" type="string">
		<cfargument name="thetype" type="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Param --->
		<cfset var l = "">
		<cfset var qry = "">
		<cfset var qryct = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query ct table --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qryct" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getlabelstextexport */ ct_label_id
		FROM ct_labels
		WHERE ct_id_r = <cfqueryparam value="#arguments.theid#" cfsqltype="cf_sql_varchar" />
		AND ct_type = <cfqueryparam value="#arguments.thetype#" cfsqltype="cf_sql_varchar" />
		AND ct_label_id <cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Query --->
		<cfif qryct.recordcount NEQ 0>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #cachetoken#getlabelstextexport2 */ label_path
			FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
			WHERE label_id IN (<cfqueryparam value="#valuelist(qryct.ct_label_id)#" cfsqltype="cf_sql_varchar" list="true" />)
			AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			ORDER BY label_text
			</cfquery>
			<!--- Param --->
			<cfset var l = valuelist(qry.label_path)>
		</cfif>
		<!--- Return --->
		<cfreturn l />
	</cffunction>

	<!--- Remove all labels for record --->
	<cffunction name="label_ct_remove" output="true" access="public">
		<cfargument name="id" type="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Remove from ct_labels --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM ct_labels
		WHERE ct_id_r = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Flush --->
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Get all labels for the explorer --->
	<cffunction name="labels" output="true" access="public">
		<cfargument name="thestruct" type="struct" required="true">
		<cfargument name="id" type="string" required="true">
		<!--- If id is # --->
		<cfif arguments.id EQ "##">
			<cfset arguments.id = "0">
		</cfif>
		<!--- Node Array --->
		<cfset var _node = arrayNew()>
		<!--- Set row --->
		<cfset var _row = 1>
		<!--- Query --->
		<cfinvoke method="labels_query" thestruct="#arguments.thestruct#" id="#arguments.id#" returnVariable="qry" />
		<!--- Result --->
		<cfloop query="qry">
			<!--- If label is expiry label then only show for admins --->
			<cfif label_text EQ 'Asset has expired' AND NOT (arguments.thestruct.razuna.session.is_system_admin OR arguments.thestruct.razuna.session.is_administrator)>
				<cfcontinue>
			</cfif>
			<!--- Default values --->
			<cfset _node[_row].children = false>
			<!--- Set id --->
			<cfset var _id = label_id>
			<cfset _node[_row].id = _id>
			<!--- Do we have children? --->
			<cfif subhere NEQ "">
				<cfset _node[_row].children = true>
			</cfif>
			<!--- Set link --->
			<cfset var _attr = structNew()>
			<cfset _attr.onclick = "loadcontent('rightside','index.cfm?fa=c.labels_main&label_id=#_id#');return false;">
			<cfset _node[_row].a_attr = _attr >
			<!--- Folder name --->
			<cfset _node[_row].text = "#label_text# (#label_count#)">
			<!--- Icon --->
			<cfset _node[_row].icon = "#arguments.thestruct.dynpath#/global/host/dam/images/tag_16.png">
			<!--- Increase --->
			<cfset _row = _row + 1>
		</cfloop>
		<!--- Return --->
		<cfreturn _node />
	</cffunction>

	<!--- Build labels drop down menu --->
	<cffunction name="labels_dropdown" output="true" access="public">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#labels_dropdown */ label_id, label_id_r, label_path, label_text
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		AND label_path IS NOT NULL
		ORDER BY label_path
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Get all labels for the explorer --->
	<cffunction name="labels_query" output="false" access="public" returnType="query">
		<cfargument name="thestruct" type="struct" required="true">
		<cfargument name="id" type="string" required="true">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#labels_query */ l.label_text, l.label_id,
			(
				SELECT count(ct.ct_label_id)
				FROM ct_labels ct
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#images i ON ct.ct_id_r = i.img_id AND ct.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar"/> AND (i.img_group IS NULL OR i.img_group = '') AND i.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#audios a ON ct.ct_id_r = a.aud_id AND ct.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar"/> AND (a.aud_group IS NULL OR a.aud_group = '') AND a.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#videos v ON ct.ct_id_r = v.vid_id AND ct.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar"/> AND (v.vid_group IS NULL OR v.vid_group = '') AND v.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files fi ON ct.ct_id_r = fi.file_id  AND ct.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar"/> AND fi.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON ct.ct_id_r = fo.folder_id  AND ct.ct_type = <cfqueryparam value="folder" cfsqltype="cf_sql_varchar"/> AND fo.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#collections c ON ct.ct_id_r = c.col_id  AND ct.ct_type =<cfqueryparam value="collection" cfsqltype="cf_sql_varchar"/> AND c.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				WHERE ct.ct_label_id = l.label_id
				<!--- Make sure that records exists --->
				AND (
					EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#audios where ct.ct_id_r = aud_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
					OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#images where ct.ct_id_r = img_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
					OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#videos where ct.ct_id_r = vid_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
					OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#files where ct.ct_id_r = file_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				)
				<!--- Exclude assets in trash --->
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#audios where ct.ct_id_r = aud_id AND ct.ct_type ='aud' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#images where ct.ct_id_r = img_id AND ct.ct_type ='img' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#videos where ct.ct_id_r = vid_id AND ct.ct_type ='vid' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#files where ct.ct_id_r = file_id AND ct.ct_type ='doc' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#folders where ct.ct_id_r = folder_id AND ct.ct_type ='folder' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#collections where ct.ct_id_r = col_id AND ct.ct_type ='collection' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				<!--- Ensure user is folder owner or has access to folder in which asset resides --->
				AND
				(
				<!--- Check if  user is admin --->
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  fo.folder_id AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#collections WHERE col_id =  c.col_id AND col_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  fi.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					)
				OR
				<!--- Check if folder privilege is 'Everyone', groupid=0 --->
				EXISTS (
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE  fo.folder_id = f.folder_id_r  AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#collections_groups cg WHERE c.col_id = cg.col_id_r AND cg.grp_id_r = '0' AND cg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM  #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE  a.folder_id_r = f.folder_id_r AND  f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE fi.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					)
				OR
				<!--- Check is user is in group that has access --->
				EXISTS (
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND fo.folder_id = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#collections_groups cg WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND c.col_id = cg.col_id_r AND cg.grp_id_r = cc.ct_g_u_grp_id AND cg.grp_permission IN  ('r','w','x') AND cg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND fi.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					)
				)
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND fg.grp_permission NOT IN  ('w','x') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND fg.grp_permission NOT IN  ('w','x') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND fg.grp_permission NOT IN  ('w','x') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND fi.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND fg.grp_permission NOT IN  ('w','x') AND fi.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					) THEN 0
				ELSE 1 END  = 1

			) AS label_count,
			(
				SELECT <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">TOP 1 </cfif>label_id
				FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
				WHERE label_id_r = l.label_id
				AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle">
					AND ROWNUM = 1
				<cfelseif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
					LIMIT 1
				</cfif>
			) AS subhere
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels l
		WHERE l.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		AND
		<cfif arguments.id EQ 0>
			(l.label_id = l.label_id_r OR l.label_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="0">)
		<cfelse>
			l.label_id <cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "db2"><><cfelse>!=</cfif> l.label_id_r
			AND
			l.label_id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.id#">
		</cfif>
		ORDER BY l.label_text
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Get label text with cache --->
	<cffunction name="getlabeltext" output="false" access="public">
		<cfargument name="theid" type="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfset var qry = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query ct table --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getlabeltext */ label_text
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.theid#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Return --->
		<cfreturn qry.label_text />
	</cffunction>

	<!--- Count items for one label --->
	<cffunction name="labels_count" output="false" access="public">
		<cfargument name="label_id" type="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfset var qry = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT DISTINCT /* #cachetoken#labels_count */
			(
				SELECT count(ct_label_id)
				FROM ct_labels l
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#images i ON l.ct_id_r = i.img_id AND l.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar"/> AND i.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#audios a ON l.ct_id_r = a.aud_id AND l.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar"/> AND a.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#videos v ON l.ct_id_r = v.vid_id AND l.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar"/> AND v.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files f ON l.ct_id_r = f.file_id AND l.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar"/> AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				WHERE ct_type IN (<cfqueryparam value="img,vid,aud,doc" cfsqltype="cf_sql_varchar" list="Yes" />)
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				<!--- Make sure that records exists --->
				AND (
					EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#audios where l.ct_id_r = aud_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
					OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#images where l.ct_id_r = img_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
					OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#videos where l.ct_id_r = vid_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
					OR EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#files where l.ct_id_r = file_id AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				)
				<!--- Exclude assets in trash --->
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#audios where l.ct_id_r = aud_id AND l.ct_type ='aud' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#images where l.ct_id_r = img_id AND l.ct_type ='img' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#videos where l.ct_id_r = vid_id AND l.ct_type ='vid' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#files where l.ct_id_r = file_id AND l.ct_type ='doc' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				<!--- Ensure user has access to folder in which asset resides --->
				AND
				(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#'  AND in_trash = 'F' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#'  AND in_trash = 'F' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#'  AND in_trash = 'F' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  f.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#'  AND in_trash = 'F' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					)
				OR
				EXISTS (
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND  f.grp_id_r ='0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE  a.folder_id_r = f.folder_id_r AND f.grp_id_r ='0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE  f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = '0' AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					)
				OR
				EXISTS (
					SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id  AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND fg.grp_permission IN  ('r','w','x') AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					)
				)
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('w','x') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('w','x') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('w','x') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND grp_permission NOT IN  ('w','x') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
					) THEN 0
				ELSE 1 END  = 1
			) AS count_assets,
			(
				SELECT count(ct_label_id)
				FROM ct_labels
				WHERE ct_type = <cfqueryparam value="comment" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			) AS count_comments,
			(
				SELECT count(ct_label_id)
				FROM ct_labels l
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#folders fo ON l.ct_id_r = fo.folder_id  AND l.ct_type =<cfqueryparam value="folder" cfsqltype="cf_sql_varchar"/>
				WHERE ct_type = <cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#folders where l.ct_id_r = folder_id AND l.ct_type ='folder' AND in_trash = 'T')
				<!--- Ensure user has access to folder --->
				AND
				(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  l.ct_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F"> AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM  #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE l.ct_id_r = f.folder_id_r AND  f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND l.ct_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				)
			) AS count_folders,
			(
				SELECT count(ct_label_id)
				FROM ct_labels l
				LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#collections c ON l.ct_id_r = c.col_id  AND l.ct_type =<cfqueryparam value="collection" cfsqltype="cf_sql_varchar"/>
				WHERE ct_type = <cfqueryparam value="collection" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND NOT EXISTS (select 1 from #arguments.thestruct.razuna.session.hostdbprefix#collections where l.ct_id_r = col_id AND l.ct_type ='collection' AND in_trash = 'T' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				<!--- Ensure user has access to collection --->
				AND
				(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#collections WHERE col_id =  l.ct_id_r AND col_owner = '#arguments.thestruct.razuna.session.theuserid#' AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F"> AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM  #arguments.thestruct.razuna.session.hostdbprefix#collections_groups f WHERE l.ct_id_r = f.col_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#collections_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND l.ct_id_r = f.col_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				)
			) AS count_collections
		FROM ct_labels
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Get assets from label --->
	<cffunction name="labels_assets" output="false" access="public">
		<cfargument name="label_id" type="string" required="true">
		<cfargument name="label_kind" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="false">
		<cfargument name="rowmaxpage" type="string" required="false" default="25">
		<cfargument name="offset" type="string" required="false" default="0">
		<cfargument name="fromapi" required="false" default="false">
		<cfargument name="labels_count" required="false" default="#QueryNew("count_assets,count_comments,count_folders,count_collections")#" type="query">
		<!--- Reset the offset if there are no more files in this folder the rowmaxpage --->
		<cfif arguments.labels_count.count_assets LTE arguments.thestruct.razuna.session.rowmaxpage>
			<cfset arguments.thestruct.razuna.session.offset = 0>
		</cfif>
		<cfset var offset = arguments.thestruct.razuna.session.offset * arguments.thestruct.razuna.session.rowmaxpage>
		<cfif arguments.thestruct.razuna.session.offset EQ 0>
			<cfset var min = 0>
			<cfset var max = arguments.thestruct.razuna.session.rowmaxpage>
		<cfelse>
			<cfset var min = arguments.thestruct.razuna.session.offset * arguments.thestruct.razuna.session.rowmaxpage>
			<cfset var max = (arguments.thestruct.razuna.session.offset + 1) * arguments.thestruct.razuna.session.rowmaxpage>
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">
				<cfset var min = min + 1>
			</cfif>
		</cfif>
		<!--- Set sortby variable --->
		<cfset var sortby = arguments.thestruct.razuna.session.sortby>
		<!--- Set the order by --->
		<cfif arguments.thestruct.razuna.session.sortby EQ "name">
			<cfset var sortby = "filename_forsort">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "sizedesc">
			<cfset var sortby = "size DESC">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "sizeasc">
			<cfset var sortby = "size ASC">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif arguments.thestruct.razuna.session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		</cfif>
		<!--- If there is no session for webgroups set --->
		<cfparam default="0" name="arguments.thestruct.razuna.session.thegroupofuser">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset var qry = "">
		<!--- Get assets --->
		<cfif arguments.label_kind EQ "assets">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle">
				SELECT rn, id,filename,folder_id_r,size,hashtag,ext,filename_org,kind,is_available,date_create,date_change,link_kind,link_path_url,
				path_to_asset,cloud_url	<cfif !arguments.fromapi>,permfolder</cfif>
				FROM (
				SELECT ROWNUM AS rn,id,filename,folder_id_r,size,hashtag,ext,filename_org,kind,is_available,date_create,date_change,link_kind,link_path_url,
				path_to_asset,cloud_url	<cfif !arguments.fromapi>,permfolder</cfif>
				FROM (
			</cfif>
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">
				SELECT id,filename,folder_id_r,size,hashtag,ext,filename_org,kind,is_available,date_create,date_change,link_kind,link_path_url,
				path_to_asset,cloud_url	<cfif !arguments.fromapi>,permfolder</cfif>
				FROM (
			</cfif>
			SELECT /* #cachetoken#labels_assets */
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">TOP #arguments.thestruct.razuna.session.rowmaxpage# </cfif>
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">row_number() over() as rownr,</cfif>
			i.img_id id, i.img_filename filename, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">img_id + '-img'<cfelse>concat(img_id,'-img')</cfif> as fileidwithtype,
			i.folder_id_r,cast(i.img_size as decimal(12,0)) as size,i.hashtag, i.thumb_extension ext, i.img_filename_org filename_org, 'img' as kind, i.is_available,
			i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
			i.path_to_asset, i.cloud_url, i.cloud_url_org, 'R' as permfolder, i.expiry_date, f.folder_name, 'null' as customfields,
			i.img_filename as filename_forsort
			<cfif isdefined('arguments.thestruct.cs')>
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "description">it
						<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_width" OR m CONTAINS "_height" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number"  OR m CONTAINS "expiry_date">i
						<cfelse>x
						</cfif>.#m#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
			</cfif>
			FROM ct_labels ct, #arguments.thestruct.razuna.session.hostdbprefix#folders f, #arguments.thestruct.razuna.session.hostdbprefix#images i
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1 AND i.host_id = it.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#xmp x ON x.id_r = i.img_id AND i.host_id = x.host_id
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = i.img_id
			AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar" />
			AND i.folder_id_r = f.folder_id
			AND (i.img_group IS NULL OR i.img_group = '')
			AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			AND i.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				AND i.img_id NOT IN (
				SELECT TOP #min# mssql_i.img_id
				FROM #arguments.thestruct.razuna.session.hostdbprefix#images mssql_i, ct_labels mssql_ct
				WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND mssql_ct.ct_id_r = mssql_i.img_id
				AND mssql_ct.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar" />
				AND mssql_f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			)
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" /> )
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('w','x') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />) THEN 0
			ELSE 1 END  = 1
			UNION ALL
			SELECT
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">TOP #arguments.thestruct.razuna.session.rowmaxpage# </cfif>
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">row_number() over() as rownr,</cfif>
				f.file_id id, f.file_name filename, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">file_id + '-doc'<cfelse>concat(file_id,'-doc')</cfif> as fileidwithtype,
				f.folder_id_r, cast(f.file_size as decimal(12,0))  as size, f.hashtag,
			f.file_extension ext, f.file_name_org filename_org, f.file_type as kind, f.is_available,
			f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url,
			f.path_to_asset, f.cloud_url, f.cloud_url_org, 'R' as permfolder, f.expiry_date, fo.folder_name, 'null' as customfields,
			f.file_name as filename_forsort
			<cfif isdefined('arguments.thestruct.cs')>
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "desc">ft
						<cfelseif m CONTAINS "_id" OR m CONTAINS "_time" OR m CONTAINS "_size" OR m CONTAINS "_filename" OR m CONTAINS "_number"  OR m CONTAINS "expiry_date">f
						<cfelse>x
						</cfif>.#m#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
			</cfif>
			FROM ct_labels ct, #arguments.thestruct.razuna.session.hostdbprefix#folders fo, #arguments.thestruct.razuna.session.hostdbprefix#files f
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1 AND f.host_id = ft.host_id
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#files_xmp x ON x.asset_id_r = f.file_id AND f.host_id = x.host_id
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = f.file_id
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar" />
			AND f.folder_id_r = fo.folder_id
			AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			AND fo.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				AND f.file_id NOT IN (
				SELECT TOP #min# mssql_f.file_id
				FROM #arguments.thestruct.razuna.session.hostdbprefix#files mssql_f, ct_labels mssql_ct
				WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND mssql_ct.ct_id_r = mssql_f.file_id
				AND mssql_ct.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar" />
				AND mssql_f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			)
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  f.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" /> )
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = '0' AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND fg.grp_permission IN  ('r','w','x') AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND fg.grp_permission NOT IN  ('w','x') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />) THEN 0
			ELSE 1 END  = 1
			UNION ALL
			SELECT
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">TOP #arguments.thestruct.razuna.session.rowmaxpage# </cfif>
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">row_number() over() as rownr,</cfif>
			v.vid_id id, v.vid_filename filename, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">vid_id + '-vid'<cfelse>concat(vid_id,'-vid')</cfif> as fileidwithtype,
			v.folder_id_r, cast(v.vid_size as decimal(12,0))  as size, v.hashtag,
			v.vid_extension ext, v.vid_name_image filename_org, 'vid' as kind, v.is_available,
			v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url,
			v.path_to_asset, v.cloud_url, v.cloud_url_org, 'R' as permfolder, v.expiry_date, f.folder_name, 'null' as customfields,
			v.vid_filename as filename_forsort
			<cfif isdefined('arguments.thestruct.cs')>
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "description">vt
						<cfelse>v
						</cfif>.#m#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
			</cfif>
			FROM ct_labels ct, #arguments.thestruct.razuna.session.hostdbprefix#folders f, #arguments.thestruct.razuna.session.hostdbprefix#videos v LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1 AND v.host_id = vt.host_id
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = v.vid_id
			AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar" />
			AND v.folder_id_r = f.folder_id
			AND (v.vid_group IS NULL OR v.vid_group = '')
			AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			AND v.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				AND v.vid_id NOT IN (
					SELECT TOP #min# mssql_v.vid_id
					FROM #arguments.thestruct.razuna.session.hostdbprefix#videos mssql_v, ct_labels mssql_ct
					WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
					AND mssql_ct.ct_id_r = mssql_v.vid_id
					AND mssql_ct.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar" />
					AND mssql_v.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				)
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" /> )
				OR
				EXISTS (SELECT 1 FROM  #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND v.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('w','x') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />) THEN 0
			ELSE 1 END  = 1
			UNION ALL
			SELECT
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">TOP #arguments.thestruct.razuna.session.rowmaxpage# </cfif>
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">row_number() over() as rownr,</cfif>
			a.aud_id id, a.aud_name filename, <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">aud_id + '-aud'<cfelse>concat(aud_id,'-aud')</cfif> as fileidwithtype,
			a.folder_id_r, cast(a.aud_size as decimal(12,0))  as size, a.hashtag,
			a.aud_extension ext, a.aud_name_org filename_org, 'aud' as kind, a.is_available,
			a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url,
			a.path_to_asset, a.cloud_url, a.cloud_url_org, 'R' as permfolder, a.expiry_date, f.folder_name, 'null' as customfields,
			a.aud_name as filename_forsort
			<cfif isdefined('arguments.thestruct.cs')>
				<!--- custom metadata fields to show --->
				<cfif arguments.thestruct.cs.images_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.images_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.videos_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.videos_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.files_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.files_metadata#" index="m" delimiters=",">
						,null AS #listlast(m," ")#
					</cfloop>
				</cfif>
				<cfif arguments.thestruct.cs.audios_metadata NEQ "">
					<cfloop list="#arguments.thestruct.cs.audios_metadata#" index="m" delimiters=",">
						,<cfif m CONTAINS "keywords" OR m CONTAINS "description">aut
						<cfelse>a
						</cfif>.#m#
					</cfloop>
				</cfif>
			</cfif>
			FROM ct_labels ct, #arguments.thestruct.razuna.session.hostdbprefix#folders f, #arguments.thestruct.razuna.session.hostdbprefix#audios a LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1 AND a.host_id = aut.host_id
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = a.aud_id
			AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar" />
			AND a.folder_id_r = f.folder_id
			AND (a.aud_group IS NULL OR a.aud_group = '')
			AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			AND a.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">
				AND a.aud_id NOT IN (
					SELECT TOP #min# mssql_a.aud_id
					FROM #arguments.thestruct.razuna.session.hostdbprefix#audios mssql_a, ct_labels mssql_ct
					WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
					AND mssql_ct.ct_id_r = mssql_a.aud_id
					AND mssql_ct.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar" />
					AND mssql_a.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
				)
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#arguments.thestruct.razuna.session.theuserid#' AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" /> )
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE a.folder_id_r = f.folder_id_r AND f.grp_id_r = '0' AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id  AND f.grp_permission IN  ('r','w','x') AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND a.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND grp_permission NOT IN  ('w','x') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" /> AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />) THEN 0
			ELSE 1 END  = 1
			ORDER BY #sortby#
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
				LIMIT #offset#,#arguments.rowmaxpage#
			</cfif>
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "db2">
				)WHERE rownr between #min# AND #max#
			</cfif>
			<cfif arguments.thestruct.razuna.application.thedatabase EQ "oracle">
					)
					WHERE ROWNUM <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#max#">
				)
				WHERE rn > <cfqueryparam cfsqltype="cf_sql_numeric" value="#min#">
			</cfif>
			</cfquery>
			<!--- Init var for new fileid --->
			<cfset var editids = "0,">
			<!--- Get proper folderaccess --->
			<cfloop query="qry">
				<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" thestruct="#arguments.thestruct#" folder_id="#folder_id_r#"  />
				<!--- Add labels query --->
				<cfset QuerySetCell(qry, "permfolder", theaccess, currentRow)>
				<!--- Store only file_ids where folder access is not read-only --->
				<cfif theaccess NEQ "R" AND theaccess NEQ "n">
					<cfset editids = editids & fileidwithtype & ",">
				</cfif>
			</cfloop>
			<!--- Add the custom fields to query --->
			<cfinvoke component="folders" method="addCustomFieldsToQuery" theqry="#qry#" returnvariable="qry" thestruct="#arguments.thestruct#" />
			<!--- Save the editable ids in a session --->
			<cfset arguments.thestruct.razuna.session.search.edit_ids = editids>
		<!--- Get folders --->
		<cfelseif arguments.label_kind EQ "folders">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #cachetoken#getlabelsfolders */ f.folder_id, f.folder_name, f.folder_id_r, f.folder_is_collection, '' AS perm
			FROM #arguments.thestruct.razuna.session.hostdbprefix#folders f, ct_labels ct
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = f.folder_id
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />
			AND f.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<!--- Ensure user has access to folder  --->
			AND
			(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				folder_owner = '#arguments.thestruct.razuna.session.theuserid#'
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #arguments.thestruct.razuna.session.hostdbprefix#folders_groups fg WHERE c.ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND f.folder_id = fg.folder_id_r AND (fg.grp_id_r = c.ct_g_u_grp_id OR fg.grp_id_r = 0)AND fg.grp_permission IN  ('r','w','x') AND fg.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />)
			)
			</cfquery>
			<!--- Get proper folderaccess --->
			<cfloop query="qry">
				<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" thestruct="#arguments.thestruct#" folder_id="#folder_id_r#"  />
				<!--- Add labels query --->
				<cfset QuerySetCell(qry, "perm", theaccess, currentRow)>
			</cfloop>
		<!--- Get collections --->
		<cfelseif arguments.label_kind EQ "collections">
			<!--- Query for collections and get permissions --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #cachetoken#getlabelscol */ c.col_id, c.folder_id_r, ct.col_name, '' AS perm
			FROM ct_labels ctl, #arguments.thestruct.razuna.session.hostdbprefix#collections c
			LEFT JOIN #arguments.thestruct.razuna.session.hostdbprefix#collections_text ct ON c.col_id = ct.col_id_r
			WHERE c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
			AND ctl.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ctl.ct_id_r = c.col_id
			AND c.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ctl.ct_type = <cfqueryparam value="collection" cfsqltype="cf_sql_varchar" />
			AND c.host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<!--- Ensure user has access to collection --->
			AND
			(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				col_owner = '#arguments.thestruct.razuna.session.theuserid#'
				OR
				EXISTS (SELECT 1 FROM #arguments.thestruct.razuna.session.hostdbprefix#collections_groups f WHERE c.col_id = f.col_id_r AND  f.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users cc, #arguments.thestruct.razuna.session.hostdbprefix#collections_groups f WHERE ct_g_u_user_id ='#arguments.thestruct.razuna.session.theuserid#' AND c.col_id = f.col_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND f.grp_permission IN  ('r','w','x'))
			)
			GROUP BY c.col_id, c.folder_id_r, ct.col_name
			</cfquery>
			<!--- Get proper folderaccess --->
			<cfloop query="qry">
				<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" thestruct="#arguments.thestruct#" folder_id="#folder_id_r#"  />
				<!--- Add labels query --->
				<cfset QuerySetCell(qry, "perm", theaccess, currentRow)>
			</cfloop>
		</cfif>
		<cfset consoleoutput(true, true)>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- ADMIN: Get all labels --->
	<cffunction name="admin_get" output="false" access="public">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT label_id, label_text
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		ORDER BY label_text
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- ADMIN: Get one labels --->
	<cffunction name="admin_get_one" output="false" access="public">
		<cfargument name="label_id" type="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT label_id, label_text, label_id_r
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- ADMIN: Remove label --->
	<cffunction name="admin_remove" output="true" access="public">
		<cfargument name="id" type="string">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Var --->
		<cfset var thelabelist = "">
		<!--- Get all child labels for parent label --->
		<cfinvoke method="getchildlabels" label_id="#arguments.id#" level="0" thestruct="#arguments.thestruct#" returnvariable="thelabelist" />
		<!--- Append parent label to list --->
		<cfset var llist = listappend(thelabelist,id)>
		<!--- DB labels --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_id IN (<cfqueryparam value="#llist#" cfsqltype="cf_sql_varchar" list="Yes" />)
		AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- DB CT table --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM ct_labels
		WHERE ct_label_id IN (<cfqueryparam value="#llist#" cfsqltype="cf_sql_varchar" list="Yes" />)
		</cfquery>
		<!--- Flush --->
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- ADMIN: Update/Add label --->
	<cffunction name="admin_update" output="false" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- Make sure there is no ' in the label text --->
		<cfset var thelabel = replace(arguments.thestruct.label_text,"'","","all")>
		<!--- Check if parent label exists. If not then add to root --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="parentcheck">
			SELECT 1 FROM  #arguments.thestruct.razuna.session.hostdbprefix#labels WHERE label_id = <cfqueryparam value="#arguments.thestruct.label_parent#" cfsqltype="cf_sql_varchar" />
		</cfquery>

		<cfif parentcheck.recordcount EQ 0>
			<cfset arguments.thestruct.label_parent = 0>
		</cfif>

		<!--- If label_id EQ 0 --->
		<cfif arguments.thestruct.label_id EQ 0>
			<cfset arguments.thestruct.label_id = createuuid("")>
			<!--- Insert --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO #arguments.thestruct.razuna.session.hostdbprefix#labels
			(
				label_id,
				label_text,
				label_date,
				user_id,
				host_id,
				label_id_r
			)
			VALUES(
				<cfqueryparam value="#arguments.thestruct.label_id#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#trim(thelabel)#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />,
				<cfqueryparam value="#arguments.thestruct.razuna.session.theuserid#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />,
				<cfqueryparam value="#arguments.thestruct.label_parent#" cfsqltype="cf_sql_varchar" />
			)
			</cfquery>
		<!--- Update --->
		<cfelse>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#labels
			SET
			label_text = <cfqueryparam value="#trim(thelabel)#" cfsqltype="cf_sql_varchar" />,
			label_id_r = <cfqueryparam value="#arguments.thestruct.label_parent#" cfsqltype="cf_sql_varchar" />
			WHERE label_id = <cfqueryparam value="#arguments.thestruct.label_id#" cfsqltype="cf_sql_varchar" />
			AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		<!--- Get path up --->
		<cfinvoke method="label_get_path" label_id="#arguments.thestruct.label_id#" thestruct="#arguments.thestruct#" returnVariable="thepath" />
		<!--- If path is not empty update --->
		<cfif thepath NEQ "">
			<!--- If the rightest char is / remove it --->
			<cfif right(thepath,1) EQ "/">
				<cfset var thelen = len(thepath)>
				<cfset var thepath = removechars(thepath,thelen,1)>
			</cfif>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#labels
			SET label_path = <cfqueryparam value="#thepath#" cfsqltype="cf_sql_varchar" />
			WHERE label_id = <cfqueryparam value="#arguments.thestruct.label_id#" cfsqltype="cf_sql_varchar" />
			AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<cfset var labelpath = thepath>
		<cfelse>
			<cfset var labelpath = thelabel>
		</cfif>
		<!--- Get path down --->
		<cfinvoke method="label_get_path_down" label_id="#arguments.thestruct.label_id#" thestruct="#arguments.thestruct#" llist="#labelpath#" />
		<!--- Flush --->
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn arguments.thestruct.label_id />
	</cffunction>

	<!--- Label get recursive for path --->
	<cffunction name="label_get_path" output="false" access="public" returnType="string">
		<cfargument name="label_id" type="string" required="true">
		<cfargument name="llist" default="" type="string" required="false">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT label_id, label_text, label_id_r
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Set into list --->
		<cfset llist = qry.label_text & "/" & arguments.llist>
		<!--- Call this again if this label_id_r is not empty --->
		<cfif qry.recordcount NEQ 0 AND qry.label_id_r NEQ 0>
			<!--- Set into list --->
			<cfinvoke method="label_get_path" label_id="#qry.label_id_r#" llist="#llist#" thestruct="#arguments.thestruct#" returnVariable="llist" />
		</cfif>
		<!--- Return --->
		<cfreturn llist />
	</cffunction>

	<!--- Label get recursive for path DOWN --->
	<cffunction name="label_get_path_down" output="false" access="public" returnType="string">
		<cfargument name="label_id" type="string" required="true">
		<cfargument name="llist" default="" type="string" required="false">
		<cfargument name="thestruct" type="struct" required="true" />
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT label_id, label_text, label_id_r
		FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_id_r = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Update record --->
		<cfif qry.recordcount NEQ 0>
			<!--- Set into list --->
			<cfset llist = arguments.llist & "/" & qry.label_text>
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix#labels
			SET label_path = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#llist#">
			WHERE label_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.label_id#">
			AND host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<!--- Call this again to see if there are any more records below it --->
			<cfinvoke method="label_get_path_down" label_id="#qry.label_id#" llist="#llist#" thestruct="#arguments.thestruct#" returnVariable="llist" />
		</cfif>
		<!--- Return --->
		<cfreturn llist />
	</cffunction>

	<!--- Rcursive function to find all label children --->
	<cffunction name="getchildlabels" access="public" >
		<cfargument name="label_id" type="string" required="true">
		<cfargument name="label_list" type="string" required="false" default="">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Local scope list --->
		<cfset var thelist = "">
		<!--- var --->
		<cfset var checkforkids = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- check for children. if there are any, call this function recursively --->
		<cfquery name="checkforkids" datasource="#arguments.thestruct.razuna.application.datasource#" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#getchildlabelscheckforkids*/ label_id as child_id
		FROM  #arguments.thestruct.razuna.session.hostdbprefix#labels
		WHERE label_id_r = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar">
		AND label_id <cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Loop over kids records --->
		<cfif checkforkids.recordcount NEQ 0>
			<!--- Add the found record to sublabellist --->
			<cfset thelist = listappend(thelist, valuelist(checkforkids.child_id))>
			<cfset arguments.label_list = listappend(arguments.label_list, valuelist(checkforkids.child_id))>
			<!--- Loop over the childrenlist --->
			<cfloop query="checkforkids">
				<cfif listfindnocase(arguments.label_list, child_id) EQ 0>
					<!--- Call function again --->
					<cfinvoke method="getchildlabels" label_id="#child_id#" label_list="#thelist#" thestruct="#arguments.thestruct#" returnvariable="childrenlist" />
					<!--- Take the returned ids and append them to our local list --->
					<cfif childrenlist NEQ "">
						<cfset thelist = listappend(thelist, childrenlist)>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		<!--- Return --->
		<cfreturn thelist />
	</cffunction>

	<!--- Get the all labels for show --->
	<cffunction name="get_all_labels_for_show" output="true" access="public" returntype="Query"  >
		<cfargument name="thestruct" type="struct" required="true">
		<cfset var qry = "">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
			SELECT  /* #cachetoken#get_all_labels_for_show */ <cfif arguments.thestruct.razuna.application.thedatabase EQ "mssql">Top 20 </cfif> label_id, label_id_r, label_path, label_text
			FROM #arguments.thestruct.razuna.session.hostdbprefix#labels
			WHERE host_id = <cfqueryparam value="#arguments.thestruct.razuna.session.hostid#" cfsqltype="cf_sql_numeric" />
			<cfif structKeyExists(arguments.thestruct,'strLetter')>
				AND label_text LIKE <cfqueryparam value="#arguments.thestruct.strLetter#%" cfsqltype="cf_sql_varchar" />
			</cfif>
			ORDER BY
			<cfif structKeyExists(arguments.thestruct,'show') AND arguments.thestruct.show EQ 'default'>
				label_date DESC
				<cfif arguments.thestruct.razuna.application.thedatabase EQ "mysql" OR arguments.thestruct.razuna.application.thedatabase EQ "h2">
					Limit 0,20
				</cfif>
			<cfelse>
				label_text ASC
			</cfif>
		</cfquery>
		<!--- Return --->
		<cfreturn qry/>
	</cffunction>

	<!--- Add OR Remove the asset labels --->
	<cffunction name="asset_label_add_remove" output="true" access="public" >
		<cfargument name="thestruct" type="struct">
		<!--- Update Dates --->
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.thetype#" fileid="#arguments.thestruct.fileid#" thestruct="#arguments.thestruct#" />
		<!--- Remove unchecked label for this record --->
		<cfif structKeyExists(arguments.thestruct,'checked') AND arguments.thestruct.checked EQ "false">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				DELETE FROM ct_labels
				WHERE ct_id_r = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />
				AND ct_type = <cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.thestruct.labels#" cfsqltype="cf_sql_varchar" />
			</cfquery>
		</cfif>
		<cfif structkeyexists(arguments.thestruct,"labels") AND structKeyExists(arguments.thestruct,'checked') AND arguments.thestruct.checked EQ "true">
			<!--- Insert into cross table --->
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
				INSERT INTO ct_labels
				(
					ct_label_id,
					ct_id_r,
					ct_type,
					rec_uuid
				)
				VALUES
				(
					<cfqueryparam value="#arguments.thestruct.labels#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
				)
			</cfquery>
		</cfif>
		<!--- Set index according to type --->
		<cfif arguments.thestruct.thetype EQ "img">
			<cfset var thedb = "images">
			<cfset var theid = "img_id">
			<cfset var d1 = "is_indexed">
		<cfelseif arguments.thestruct.thetype EQ "vid">
			<cfset var thedb = "videos">
			<cfset var theid = "vid_id">
			<cfset var d1 = "is_indexed">
		<cfelseif arguments.thestruct.thetype EQ "aud">
			<cfset var thedb = "audios">
			<cfset var theid = "aud_id">
			<cfset var d1 = "is_indexed">
		<cfelse>
			<cfset var thedb = "files">
			<cfset var theid = "file_id">
			<cfset var d1 = "is_indexed">
		</cfif>
		<!--- Update DB --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			UPDATE #arguments.thestruct.razuna.session.hostdbprefix##thedb#
			SET #d1# = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE #theid# = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.razuna.session.hostid#">
		</cfquery>
		<!--- Flush --->
		<!--- <cfset resetcachetoken(thedb)> not sure, is it neccessary? --->
		<cfset resetcachetoken(type="search", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<cfset resetcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<!--- Get the search label index (A,B,..Z) --->
	<cffunction name="get_search_label_index" output="true" access="public" returntype="Query"  >
		<cfargument name="thestruct" type="struct" required="true">
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
			SELECT DISTINCT LEFT(UPPER(RTRIM(LTRIM(label_text))),1) AS label_text_index FROM #arguments.thestruct.razuna.session.hostdbprefix#labels ORDER BY label_text_index
		</cfquery>
		<!--- Return --->
		<cfreturn qry/>
	</cffunction>

	<!--- Save labels for ant type --->
	<cffunction name="saveToLabelsCrossTable" output="false" access="public">
		<cfargument name="labelid" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="recordid" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Remove all labels for this record --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
		DELETE FROM ct_labels
		WHERE ct_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.recordid#">
		AND ct_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#">
		</cfquery>
		<!--- Loop over labelid --->
		<cfloop list="#arguments.labelid#" index="l" delimiters=",">
			<cfquery datasource="#arguments.thestruct.razuna.application.datasource#">
			INSERT INTO ct_labels
			(
				ct_label_id,
				ct_id_r,
				ct_type,
				rec_uuid
			)
			VALUES
			(
				<cfqueryparam value="#l#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#arguments.recordid#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#arguments.type#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
			)
			</cfquery>
		</cfloop>
	</cffunction>

	<!--- Save labels for any type --->
	<cffunction name="getLabelsFromCrossTable" access="public" returntype="string">
		<cfargument name="type" type="string" required="true">
		<cfargument name="recordid" type="string" required="true">
		<cfargument name="thestruct" type="struct" required="true" />
		<!--- Param --->
		<cfset var qry = "">
		<!--- Get Labels --->
		<cfquery datasource="#arguments.thestruct.razuna.application.datasource#" name="qry">
		SELECT ct_label_id
		FROM ct_labels
		WHERE ct_id_r = <cfqueryparam value="#arguments.recordid#" cfsqltype="cf_sql_varchar" />
		AND ct_type = <cfqueryparam value="#arguments.type#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Convert to list --->
		<cfset var qry = valuelist(qry.ct_label_id) />
		<!--- Return --->
		<cfreturn qry />
	</cffunction>

	<!--- Store all values --->
	<cffunction name="store_values" output="false" returntype="void">
		<cfargument name="thestruct" required="yes" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset var cachetoken = getcachetoken(type="labels", hostid=arguments.thestruct.razuna.session.hostid, thestruct=arguments.thestruct)>
		<!--- Var --->
		<cfset var qry = "">
		<!--- Grab all files related to this labelid --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #cachetoken#store_values_labels */ <cfif application.razuna.thedatabase EQ "mssql">ct_id_r + '-' + ct_type<cfelse>concat(ct_id_r,'-', ct_type)</cfif> as id
		FROM ct_labels
		WHERE ct_label_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.label_id#">
		AND ct_type <cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Set the valuelist   --->
		<cfset var l = valuelist(qry.id)>
		<!--- Set the sessions --->
		<cfset session.file_id = l>
		<cfset session.thefileid = l>
		<cfset session.editids = l>
		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>

