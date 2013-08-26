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

<!--- Get the cachetoken for here --->
<cfset variables.cachetoken = getcachetoken("labels")>

	<!--- Update the label of a record --->
	<cffunction name="label_update" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- Check if users are allowed to add labels --->
		<cfinvoke component="settings" method="get_label_set" returnvariable="perm" />
		<!--- Check if label exists --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT label_text, label_id AS labelid
		FROM #session.hostdbprefix#labels
		WHERE lower(label_text) = <cfqueryparam value="#lcase(arguments.thestruct.thelab)#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- If exists then add label to this record --->
		<cfif qry.recordcount NEQ 0>
			<cfquery datasource="#application.razuna.datasource#">
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
				<cfquery datasource="#application.razuna.datasource#">
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
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.type#" fileid="#arguments.thestruct.id#" />
		<!--- Flush --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Add labels --->
	<cffunction name="label_add_all" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<cfthread intstruct="#arguments.thestruct#">
			<cfinvoke method="label_add_all_thread" thestruct="#attributes.intstruct#" />
		</cfthread>
	</cffunction>

	<!--- Add labels --->
	<cffunction name="label_add_all_thread" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- Param --->
		<cfparam name="arguments.thestruct.batch_replace" default="true">
		<!--- Update Dates --->
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.thetype#" fileid="#arguments.thestruct.fileid#" />
		<!--- Remove all labels for this record --->
		<cfif arguments.thestruct.batch_replace>
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM ct_labels
			WHERE ct_id_r = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />
			AND ct_type = <cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar" />
			</cfquery>
		</cfif>
		<cfif structkeyexists(arguments.thestruct,"labels") AND arguments.thestruct.labels NEQ "null">
			<!--- Loop over fields --->		
			<cfloop list="#arguments.thestruct.labels#" delimiters="," index="i">
				<!--- Check if same record already exists --->
				<cfquery datasource="#application.razuna.datasource#" name="lhere">
				SELECT ct_label_id
				FROM ct_labels
				WHERE ct_label_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar" />
				AND ct_id_r = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />
				</cfquery>
				<!--- If record is here do not insert --->
				<cfif lhere.recordcount EQ 0>
					<!--- Insert into cross table --->
					<cfquery datasource="#application.razuna.datasource#">
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
			<!--- Lucene: Delete Records --->
			<cfindex action="delete" collection="#session.hostid#" key="#arguments.thestruct.fileid#">
			<!--- Set index according to type --->
			<cfif arguments.thestruct.thetype EQ "img">
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE img_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.thestruct.thetype EQ "vid">
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#videos
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE vid_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.thestruct.thetype EQ "aud">
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE aud_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelse>
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE file_id = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfif>
		<!--- Flush --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Add label from batch --->
	<cffunction name="label_add_batch" output="false" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- Loop over files_ids --->
		<cfthread intstruct="#arguments.thestruct#">
			<cfloop list="#attributes.intstruct.file_ids#" index="i">
				<cfset attributes.intstruct.fileid = listfirst(i,"-")>
				<cfset attributes.intstruct.thetype = listlast(i,"-")>
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
		<cfquery datasource="#application.razuna.datasource#">
		INSERT INTO #session.hostdbprefix#labels
		(
			label_id,
			label_text,
			label_date,
			user_id,
			host_id
		)
		VALUES(
			<cfqueryparam value="#theid#" cfsqltype="cf_sql_varchar" />,
			<cfqueryparam value="#thelabel#" cfsqltype="cf_sql_varchar" />,
			<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />,
			<cfqueryparam value="#session.theuserid#" cfsqltype="cf_sql_varchar" />,
			<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		)
		</cfquery>
		<!--- Flush --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn theid />
	</cffunction>
	
	<!--- Remove the label of a record --->
	<cffunction name="label_remove" output="true" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- Get label id --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT label_id
		FROM #session.hostdbprefix#labels
		WHERE lower(label_text) = <cfqueryparam value="#lcase(arguments.thestruct.thelab)#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Remove from ct_labels --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_labels
		WHERE ct_label_id = <cfqueryparam value="#qry.label_id#" cfsqltype="cf_sql_varchar" />
		AND ct_id_r = <cfqueryparam value="#arguments.thestruct.id#" cfsqltype="cf_sql_varchar" />
		AND ct_type = <cfqueryparam value="#arguments.thestruct.type#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Update Dates --->
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.type#" fileid="#arguments.thestruct.id#" />
		<!--- Flush --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Get all labels --->
	<cffunction name="getalllabels" output="false" access="public">
		<!--- Params --->
		<cfset var st = structnew()>
		<cfset var l = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getalllabels */ label_text, label_path, label_id
		FROM #session.hostdbprefix#labels
		WHERE host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		ORDER BY lower(label_text)
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
	<cffunction name="getlabels" output="false" access="public">
		<cfargument name="theid" type="string">
		<cfargument name="thetype" type="string">
		<!--- Param --->
		<cfset var l = "">
		<cfset var qryct = "">
		<cfset var qry = "">
		<!--- Query ct table --->
		<cfquery datasource="#application.razuna.datasource#" name="qryct" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getlabels */ ct_label_id
		FROM ct_labels
		WHERE ct_id_r = <cfqueryparam value="#arguments.theid#" cfsqltype="cf_sql_varchar" />
		AND ct_type = <cfqueryparam value="#arguments.thetype#" cfsqltype="cf_sql_varchar" />
		AND ct_label_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Query --->
		<cfif qryct.recordcount NEQ 0>
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getlabels2 */ label_id
			FROM #session.hostdbprefix#labels
			WHERE label_id IN (<cfqueryparam value="#valuelist(qryct.ct_label_id)#" cfsqltype="cf_sql_varchar" list="true" />)
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			ORDER BY lower(label_text)
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
		<!--- Param --->
		<cfset var l = "">
		<!--- Query ct table --->
		<cfquery datasource="#application.razuna.datasource#" name="qryct" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getlabelstextexport */ ct_label_id
		FROM ct_labels
		WHERE ct_id_r = <cfqueryparam value="#arguments.theid#" cfsqltype="cf_sql_varchar" />
		AND ct_type = <cfqueryparam value="#arguments.thetype#" cfsqltype="cf_sql_varchar" />
		AND ct_label_id <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Query --->
		<cfif qryct.recordcount NEQ 0>
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getlabelstextexport2 */ label_path
			FROM #session.hostdbprefix#labels
			WHERE label_id IN (<cfqueryparam value="#valuelist(qryct.ct_label_id)#" cfsqltype="cf_sql_varchar" list="true" />)
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			ORDER BY lower(label_text)
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
		<!--- Remove from ct_labels --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_labels
		WHERE ct_id_r = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Flush --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Get all labels for the explorer --->
	<cffunction name="labels" output="true" access="public">
		<cfargument name="thestruct" type="struct" required="true">
		<cfargument name="id" type="string" required="true">
		<!--- Query --->
		<cfinvoke method="labels_query" thestruct="#arguments.thestruct#" id="#arguments.id#" returnVariable="qry" />
		<!--- Output for tree --->
		<cfoutput query="qry">
			<li id="#label_id#"<cfif subhere NEQ ""> class="closed"</cfif>><a href="##" onclick="loadcontent('rightside','index.cfm?fa=c.labels_main&label_id=#label_id#');return false;"><ins>&nbsp;</ins>#label_text# (#label_count#)</a></li>
		</cfoutput>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Build labels drop down menu --->
	<cffunction name="labels_dropdown" output="true" access="public">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("labels")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#labels_dropdown */ label_id, label_id_r, label_path, label_text
		FROM #session.hostdbprefix#labels
		WHERE host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
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
		<cfset variables.cachetoken = getcachetoken("labels")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#labels_query */ l.label_text, l.label_id,
			(
				SELECT count(ct.ct_label_id)
				FROM ct_labels ct
				WHERE ct.ct_label_id = l.label_id
			) AS label_count,
			(
				SELECT <cfif application.razuna.thedatabase EQ "mssql">TOP 1 </cfif>label_id
				FROM #session.hostdbprefix#labels
				WHERE label_id_r = l.label_id
				<cfif application.razuna.thedatabase EQ "oracle">
					AND ROWNUM = 1
				<cfelseif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2">
					LIMIT 1
				</cfif>
			) AS subhere
		FROM #session.hostdbprefix#labels l
		WHERE l.host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		AND 
		<cfif arguments.id EQ 0>
			(l.label_id = l.label_id_r OR l.label_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="0">)
		<cfelse>
			l.label_id <cfif variables.database EQ "oracle" OR variables.database EQ "db2"><><cfelse>!=</cfif> l.label_id_r
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
		<!--- Query ct table --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#getlabeltext */ label_text
		FROM #session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.theid#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Return --->
		<cfreturn qry.label_text />
	</cffunction>
	
	<!--- Count items for one label --->
	<cffunction name="labels_count" output="false" access="public">
		<cfargument name="label_id" type="string">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT DISTINCT /* #variables.cachetoken#labels_count */
			(
				SELECT count(ct_label_id)
				FROM ct_labels
				WHERE ct_type IN (<cfqueryparam value="img,vid,aud,doc" cfsqltype="cf_sql_varchar" list="Yes" />)
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			) AS count_assets,
			(
				SELECT count(ct_label_id)
				FROM ct_labels
				WHERE ct_type = <cfqueryparam value="comment" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			) AS count_comments,
			(
				SELECT count(ct_label_id)
				FROM ct_labels
				WHERE ct_type = <cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			) AS count_folders,
			(
				SELECT count(ct_label_id)
				FROM ct_labels
				WHERE ct_type = <cfqueryparam value="collection" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
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
		<cfargument name="rowmaxpage" type="string" required="false" default="25">
		<cfargument name="offset" type="string" required="false" default="0">
		<cfargument name="fromapi" required="false" default="false">
		<cfargument name="labels_count" required="false" default="#QueryNew("count_assets,count_comments,count_folders,count_collections")#" type="query">
		<!--- Reset the offset if there are no more files in this folder the rowmaxpage --->
		<cfif arguments.labels_count.count_assets LTE session.rowmaxpage>
			<cfset session.offset = 0>
		</cfif>
		<cfset var offset = session.offset * session.rowmaxpage>
		<cfif session.offset EQ 0>
			<cfset var min = 0>
			<cfset var max = session.rowmaxpage>
		<cfelse>
			<cfset var min = session.offset * session.rowmaxpage>
			<cfset var max = (session.offset + 1) * session.rowmaxpage>
			<cfif variables.database EQ "db2">
				<cfset var min = min + 1>
			</cfif>
		</cfif>
		<!--- Set sortby variable --->
		<cfset var sortby = session.sortby>
		<!--- Set the order by --->
		<cfif session.sortby EQ "name">
			<cfset var sortby = "filename_org">
		<cfelseif session.sortby EQ "sizedesc">
			<cfset var sortby = "size DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "size ASC">
		<cfelseif session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		</cfif>
		<!--- If there is no session for webgroups set --->
		<cfparam default="0" name="session.thegroupofuser">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("labels")>
		<!--- Get assets --->
		<cfif arguments.label_kind EQ "assets">
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			<cfif application.razuna.thedatabase EQ "oracle">
				SELECT rn, id,filename,folder_id_r,size,hashtag,ext,filename_org,kind,is_available,date_create,date_change,link_kind,link_path_url,
				path_to_asset,cloud_url	<cfif !arguments.fromapi>,permfolder</cfif>
				FROM (
				SELECT ROWNUM AS rn,id,filename,folder_id_r,size,hashtag,ext,filename_org,kind,is_available,date_create,date_change,link_kind,link_path_url,
				path_to_asset,cloud_url	<cfif !arguments.fromapi>,permfolder</cfif>
				FROM (
			</cfif>	
			<cfif application.razuna.thedatabase EQ "db2">
				SELECT id,filename,folder_id_r,size,hashtag,ext,filename_org,kind,is_available,date_create,date_change,link_kind,link_path_url,
				path_to_asset,cloud_url	<cfif !arguments.fromapi>,permfolder</cfif>
				FROM (
			</cfif>
			SELECT /* #variables.cachetoken#labels_assets */
			<cfif application.razuna.thedatabase EQ "mssql">TOP #session.rowmaxpage# </cfif>
			<cfif application.razuna.thedatabase EQ "db2">row_number() over() as rownr,</cfif>
			 i.img_id id, i.img_filename filename, 
			i.folder_id_r,i.img_size as size,i.hashtag, i.thumb_extension ext, i.img_filename_org filename_org, 'img' as kind, i.is_available,
			i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
			i.path_to_asset, i.cloud_url, 'R' as permfolder
			FROM #session.hostdbprefix#images i, ct_labels ct
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = i.img_id
			AND ct.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar" />
			<cfif application.razuna.thedatabase EQ "mssql">
				AND i.img_id NOT IN (
				SELECT TOP #min# mssql_i.img_id
				FROM #session.hostdbprefix#images mssql_i, ct_labels mssql_ct
				WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND mssql_ct.ct_id_r = mssql_i.img_id
				AND mssql_ct.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar" />
			)	
			</cfif>
			UNION ALL
			SELECT 
				<cfif application.razuna.thedatabase EQ "mssql">TOP #session.rowmaxpage# </cfif>
				<cfif application.razuna.thedatabase EQ "db2">row_number() over() as rownr,</cfif> 
				f.file_id id, f.file_name filename, f.folder_id_r,  f.file_size as size, f.hashtag,
			f.file_extension ext, f.file_name_org filename_org, f.file_type as kind, f.is_available,
			f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url,
			f.path_to_asset, f.cloud_url, 'R' as permfolder
			FROM #session.hostdbprefix#files f, ct_labels ct
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = f.file_id
			AND ct.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar" />
			<cfif application.razuna.thedatabase EQ "mssql">
				AND f.file_id NOT IN (
				SELECT TOP #min# mssql_f.file_id
				FROM #session.hostdbprefix#files mssql_f, ct_labels mssql_ct
				WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND mssql_ct.ct_id_r = mssql_f.file_id
				AND mssql_ct.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar" />
			)	
			</cfif>
			UNION ALL
			SELECT 
			<cfif application.razuna.thedatabase EQ "mssql">TOP #session.rowmaxpage# </cfif>
			<cfif application.razuna.thedatabase EQ "db2">row_number() over() as rownr,</cfif> 
			v.vid_id id, v.vid_filename filename, v.folder_id_r, v.vid_size as size, v.hashtag,
			v.vid_extension ext, v.vid_name_image filename_org, 'vid' as kind, v.is_available,
			v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url,
			v.path_to_asset, v.cloud_url, 'R' as permfolder
			FROM #session.hostdbprefix#videos v, ct_labels ct
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = v.vid_id
			AND ct.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar" />
			<cfif application.razuna.thedatabase EQ "mssql">
				AND v.vid_id NOT IN (
					SELECT TOP #min# mssql_v.vid_id
					FROM #session.hostdbprefix#videos mssql_v, ct_labels mssql_ct
					WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
					AND mssql_ct.ct_id_r = mssql_v.vid_id
					AND mssql_ct.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar" />
				)	
			</cfif>
			UNION ALL
			SELECT 
			<cfif application.razuna.thedatabase EQ "mssql">TOP #session.rowmaxpage# </cfif>
			<cfif application.razuna.thedatabase EQ "db2">row_number() over() as rownr,</cfif> 
			a.aud_id id, a.aud_name filename, a.folder_id_r, a.aud_size as size, a.hashtag,
			a.aud_extension ext, a.aud_name_org filename_org, 'aud' as kind, a.is_available,
			a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url,
			a.path_to_asset, a.cloud_url, 'R' as permfolder
			FROM #session.hostdbprefix#audios a, ct_labels ct
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = a.aud_id
			AND ct.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar" />
			<cfif application.razuna.thedatabase EQ "mssql">
				AND a.aud_id NOT IN (
					SELECT TOP #min# mssql_a.aud_id
					FROM #session.hostdbprefix#audios mssql_a, ct_labels mssql_ct
					WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
					AND mssql_ct.ct_id_r = mssql_a.aud_id
					AND mssql_ct.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar" />
				)	
			</cfif>
			ORDER BY #sortby#
			<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2"> 
				LIMIT #offset#,#arguments.rowmaxpage# 
			</cfif>
			<cfif application.razuna.thedatabase EQ "db2">
				)WHERE rownr between #min# AND #max#
			</cfif>
			<cfif application.razuna.thedatabase EQ "oracle">
					)
					WHERE ROWNUM <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#max#">
				)
				WHERE rn > <cfqueryparam cfsqltype="cf_sql_numeric" value="#min#">
			</cfif>
			</cfquery>
			<!--- Get proper folderaccess --->
			<cfloop query="qry">
				<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#folder_id_r#"  />
				<!--- Add labels query --->
				<cfset QuerySetCell(qry, "permfolder", theaccess, currentRow)>
			</cfloop>
		<!--- Get folders --->
		<cfelseif arguments.label_kind EQ "folders">
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getlabelsfolders */ f.folder_id, f.folder_name, f.folder_id_r, f.folder_is_collection, '' AS perm
			FROM #session.hostdbprefix#folders f, ct_labels ct
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = f.folder_id
			AND ct.ct_type = <cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />
			</cfquery>
			<!--- Get proper folderaccess --->
			<cfloop query="qry">
				<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#folder_id_r#"  />
				<!--- Add labels query --->
				<cfset QuerySetCell(qry, "perm", theaccess, currentRow)>
			</cfloop>
		<!--- Get collections --->
		<cfelseif arguments.label_kind EQ "collections">
			<!--- Query for collections and get permissions --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getlabelscol */ c.col_id, c.folder_id_r, ct.col_name, '' AS perm
			FROM ct_labels ctl, #session.hostdbprefix#collections c
			LEFT JOIN #session.hostdbprefix#collections_text ct ON c.col_id = ct.col_id_r 
			WHERE c.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND ctl.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ctl.ct_id_r = c.col_id
			AND ctl.ct_type = <cfqueryparam value="collection" cfsqltype="cf_sql_varchar" />
			GROUP BY c.col_id, c.folder_id_r, ct.col_name
			</cfquery>
			<!--- Get proper folderaccess --->
			<cfloop query="qry">
				<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#folder_id_r#"  />
				<!--- Add labels query --->
				<cfset QuerySetCell(qry, "perm", theaccess, currentRow)>
			</cfloop>
		</cfif>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>
	
	<!--- ADMIN: Get all labels --->
	<cffunction name="admin_get" output="false" access="public">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT label_id, label_text
		FROM #session.hostdbprefix#labels
		WHERE host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		ORDER BY lower(label_text)
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>
	
	<!--- ADMIN: Get one labels --->
	<cffunction name="admin_get_one" output="false" access="public">
		<cfargument name="label_id" type="string">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT label_id, label_text, label_id_r
		FROM #session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Return --->
		<cfreturn qry />
	</cffunction>
	
	<!--- ADMIN: Remove label --->
	<cffunction name="admin_remove" output="false" access="public">
		<cfargument name="id" type="string">
		<!--- DB labels --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- DB CT table --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_labels
		WHERE ct_label_id = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Now check for any sub labels and remove them as well --->
		<cfquery datasource="#application.razuna.datasource#" name="sub">
		SELECT label_id
		FROM #session.hostdbprefix#labels
		WHERE label_id_r = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- If we find some records --->
		<cfif sub.recordcount NEQ 0>
			<!--- Remove in DBs --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM #session.hostdbprefix#labels
			WHERE label_id IN (<cfqueryparam value="#valuelist(sub.label_id)#" cfsqltype="cf_sql_varchar" list="Yes" />)
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<!--- DB CT table --->
			<cfquery datasource="#application.razuna.datasource#">
			DELETE FROM ct_labels
			WHERE ct_label_id IN (<cfqueryparam value="#valuelist(sub.label_id)#" cfsqltype="cf_sql_varchar" list="Yes" />)
			</cfquery>
		</cfif>
		<!--- Flush --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- ADMIN: Update/Add label --->
	<cffunction name="admin_update" output="false" access="public">
		<cfargument name="thestruct" type="struct">
		<!--- Make sure there is no ' in the label text --->
		<cfset var thelabel = replace(arguments.thestruct.label_text,"'","","all")>
		<!--- If label_id EQ 0 --->
		<cfif arguments.thestruct.label_id EQ 0>
			<cfset arguments.thestruct.label_id = createuuid("")>
			<!--- Insert --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix#labels
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
				<cfqueryparam value="#thelabel#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />,
				<cfqueryparam value="#session.theuserid#" cfsqltype="cf_sql_varchar" />,
				<cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />,
				<cfqueryparam value="#arguments.thestruct.label_parent#" cfsqltype="cf_sql_varchar" />
			)
			</cfquery>
		<!--- Update --->
		<cfelse>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#labels
			SET 
			label_text = <cfqueryparam value="#thelabel#" cfsqltype="cf_sql_varchar" />
			<cfif structkeyexists(arguments.thestruct,"label_parent") AND arguments.thestruct.label_parent NEQ 0>
				,
				label_id_r = <cfqueryparam value="#arguments.thestruct.label_parent#" cfsqltype="cf_sql_varchar" />
			</cfif>
			WHERE label_id = <cfqueryparam value="#arguments.thestruct.label_id#" cfsqltype="cf_sql_varchar" />
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		</cfif>
		<!--- Get path up --->
		<cfinvoke method="label_get_path" label_id="#arguments.thestruct.label_id#" returnVariable="thepath" />
		<!--- If path is not empty update --->
		<cfif thepath NEQ "">
			<!--- If the rightest char is / remove it --->
			<cfif right(thepath,1) EQ "/">
				<cfset thelen = len(thepath)>
				<cfset thepath = removechars(thepath,thelen,1)>
			</cfif>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#labels
			SET label_path = <cfqueryparam value="#thepath#" cfsqltype="cf_sql_varchar" />
			WHERE label_id = <cfqueryparam value="#arguments.thestruct.label_id#" cfsqltype="cf_sql_varchar" />
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<cfset labelpath = thepath>
		<cfelse>
			<cfset labelpath = thelabel>
		</cfif>
		<!--- Get path down --->
		<cfinvoke method="label_get_path_down" label_id="#arguments.thestruct.label_id#" llist="#labelpath#" />
		<!--- Flush --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn arguments.thestruct.label_id />
	</cffunction>
	
	<!--- Label get recursive for path --->
	<cffunction name="label_get_path" output="false" access="public" returnType="string">
		<cfargument name="label_id" type="string" required="true">
		<cfargument name="llist" default="" type="string" required="false">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT label_id, label_text, label_id_r
		FROM #session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Set into list --->
		<cfset llist = qry.label_text & "/" & arguments.llist> 
		<!--- Call this again if this label_id_r is not empty --->
		<cfif qry.label_id_r NEQ 0>
			<!--- Set into list --->
			<cfinvoke method="label_get_path" label_id="#qry.label_id_r#" llist="#llist#" returnVariable="llist" />	
		</cfif>
		<!--- Return --->
		<cfreturn llist />
	</cffunction>
	
	<!--- Label get recursive for path DOWN --->
	<cffunction name="label_get_path_down" output="false" access="public" returnType="string">
		<cfargument name="label_id" type="string" required="true">
		<cfargument name="llist" default="" type="string" required="false">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT label_id, label_text, label_id_r
		FROM #session.hostdbprefix#labels
		WHERE label_id_r = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- Update record --->
		<cfif qry.recordcount NEQ 0>
			<!--- Set into list --->
			<cfset llist = arguments.llist & "/" & qry.label_text> 
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			UPDATE #session.hostdbprefix#labels
			SET label_path = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#llist#">
			WHERE label_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#qry.label_id#">
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<!--- Call this again to see if there are any more records below it --->
			<cfinvoke method="label_get_path_down" label_id="#qry.label_id#" llist="#llist#" returnVariable="llist" />	
		</cfif>
		<!--- Return --->
		<cfreturn llist />
	</cffunction>
</cfcomponent>

