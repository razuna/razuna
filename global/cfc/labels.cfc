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
		<cfset var qry = "">
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
		<cfset var i = "">
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
		<cfset var j = "">
		<!--- Loop over files_ids --->
		<cfthread intstruct="#arguments.thestruct#">
			<cfloop list="#attributes.intstruct.file_ids#" index="j">
				<cfset attributes.intstruct.fileid = listfirst(j,"-")>
				<cfset attributes.intstruct.thetype = listlast(j,"-")>
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
			<cfqueryparam value="#trim(thelabel)#" cfsqltype="cf_sql_varchar" />,
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
		<cfset var qry = "">
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
		<cfset var qry = "">
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
		<cfargument name="checkUPC" type="string" required="false" default="false" > 
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
			<cfif structKeyExists(arguments,'checkUPC') AND arguments.checkUPC EQ 'true'>
				AND lower(label_text) = <cfqueryparam value="upc" cfsqltype="cf_sql_varchar" />
			</cfif>
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
		<cfset var qry = "">
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
		<cfloop query="qry">
			<!--- If label is expiry label then only show for admins --->
			<cfif label_text EQ 'Asset has expired' AND structKeyExists(request,"securityObj") AND NOT (Request.securityObj.CheckSystemAdminUser() OR Request.securityObj.CheckAdministratorUser())>
					<cfcontinue>
			</cfif>
			<cfoutput>
			<li id="#label_id#"<cfif subhere NEQ ""> class="closed"</cfif>><a href="##" onclick="loadcontent('rightside','index.cfm?fa=c.labels_main&label_id=#label_id#');return false;"><ins>&nbsp;</ins>#label_text# (#label_count#)</a></li>
			</cfoutput>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Build labels drop down menu --->
	<cffunction name="labels_dropdown" output="true" access="public">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("labels")>
		<cfset var qry = "">
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
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#labels_query */ l.label_text, l.label_id,
			(
				SELECT count(ct.ct_label_id)
				FROM ct_labels ct
				LEFT JOIN #session.hostdbprefix#images i ON ct.ct_id_r = i.img_id AND ct.ct_type =<cfqueryparam value="img" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#audios a ON ct.ct_id_r = a.aud_id AND ct.ct_type =<cfqueryparam value="aud" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#videos v ON ct.ct_id_r = v.vid_id AND ct.ct_type =<cfqueryparam value="vid" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#files fi ON ct.ct_id_r = fi.file_id  AND ct.ct_type =<cfqueryparam value="doc" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#folders fo ON ct.ct_id_r = fo.folder_id  AND ct.ct_type =<cfqueryparam value="folder" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#collections c ON ct.ct_id_r = c.col_id  AND ct.ct_type =<cfqueryparam value="collection" cfsqltype="cf_sql_varchar"/>
				WHERE ct.ct_label_id = l.label_id
				<!--- Exclude assets in trash --->
				AND NOT EXISTS (select 1 from #session.hostdbprefix#audios where ct.ct_id_r = aud_id AND ct.ct_type ='aud' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#images where ct.ct_id_r = img_id AND ct.ct_type ='img' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#videos where ct.ct_id_r = vid_id AND ct.ct_type ='vid' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#files where ct.ct_id_r = file_id AND ct.ct_type ='doc' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#folders where ct.ct_id_r = folder_id AND ct.ct_type ='folder' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#collections where ct.ct_id_r = col_id AND ct.ct_type ='collection' AND in_trash = 'T')
				<!--- Ensure user is folder owner or has access to folder in which asset resides --->
				AND 
				(
				<!--- Check if  user is admin --->
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  fo.folder_id AND folder_owner = '#session.theuserid#' 
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#collections WHERE col_id =  c.col_id AND col_owner = '#session.theuserid#' 
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#session.theuserid#' 
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#session.theuserid#' 
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#session.theuserid#' 
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  fi.folder_id_r AND folder_owner = '#session.theuserid#' 
					) 
				OR
				<!--- Check if folder privilege is 'Everyone', groupid=0 --->
				EXISTS (
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE  fo.folder_id = f.folder_id_r  AND f.grp_id_r = '0'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#collections_groups cg WHERE c.col_id = cg.col_id_r AND cg.grp_id_r = '0' 
					UNION ALL
					SELECT 1 FROM  #session.hostdbprefix#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND f.grp_id_r = '0'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE  a.folder_id_r = f.folder_id_r AND  f.grp_id_r = '0'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE fi.folder_id_r = f.folder_id_r AND f.grp_id_r = '0'
					)
				OR
				<!--- Check is user is in group that has access --->
				EXISTS (
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND fo.folder_id = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND lower(f.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#collections_groups cg WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND c.col_id = cg.col_id_r AND cg.grp_id_r = cc.ct_g_u_grp_id AND lower(cg.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND lower(f.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND lower(f.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups f WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND fi.folder_id_r = f.folder_id_r AND f.grp_id_r = cc.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x')
					)
				)
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE 
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND lower(fg.grp_permission) NOT IN  ('w','x') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND lower(fg.grp_permission) NOT IN  ('w','x') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND lower(fg.grp_permission) NOT IN  ('w','x') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
					UNION ALL
					SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#folders_groups fg WHERE cc.ct_g_u_user_id ='#session.theuserid#' AND fi.folder_id_r = fg.folder_id_r AND cc.ct_g_u_grp_id = fg.grp_id_r AND lower(fg.grp_permission) NOT IN  ('w','x') AND fi.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
					) THEN 0
				ELSE 1 END  = 1

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
		<cfset var qry = "">
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
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT DISTINCT /* #variables.cachetoken#labels_count */
			(
				SELECT count(ct_label_id)
				FROM ct_labels l
				LEFT JOIN #session.hostdbprefix#images i ON l.ct_id_r = i.img_id AND l.ct_type =<cfqueryparam value="img" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#audios a ON l.ct_id_r = a.aud_id AND l.ct_type =<cfqueryparam value="aud" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#videos v ON l.ct_id_r = v.vid_id AND l.ct_type =<cfqueryparam value="vid" cfsqltype="cf_sql_varchar"/>
				LEFT JOIN #session.hostdbprefix#files f ON l.ct_id_r = f.file_id AND l.ct_type =<cfqueryparam value="doc" cfsqltype="cf_sql_varchar"/>
				WHERE ct_type IN (<cfqueryparam value="img,vid,aud,doc" cfsqltype="cf_sql_varchar" list="Yes" />)
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				<!--- Exclude assets in trash --->
				AND NOT EXISTS (select 1 from #session.hostdbprefix#audios where l.ct_id_r = aud_id AND l.ct_type ='aud' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#images where l.ct_id_r = img_id AND l.ct_type ='img' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#videos where l.ct_id_r = vid_id AND l.ct_type ='vid' AND in_trash = 'T')
				AND NOT EXISTS (select 1 from #session.hostdbprefix#files where l.ct_id_r = file_id AND l.ct_type ='doc' AND in_trash = 'T')
				<!--- Ensure user has access to folder in which asset resides --->
				AND 
				(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#session.theuserid#'  AND in_trash = 'F'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#session.theuserid#'  AND in_trash = 'F'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#session.theuserid#'  AND in_trash = 'F'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  f.folder_id_r AND folder_owner = '#session.theuserid#'  AND in_trash = 'F'
					) 
				OR
				EXISTS (
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND  f.grp_id_r ='0'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE  a.folder_id_r = f.folder_id_r AND f.grp_id_r ='0'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0'
					UNION ALL
					SELECT 1 FROM #session.hostdbprefix#folders_groups fg WHERE  f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = '0'
					)
				OR
				EXISTS (
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id  AND lower(f.grp_permission) IN  ('r','w','x')
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND lower(fg.grp_permission) IN  ('r','w','x')
					)
				)
				<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
				AND CASE 
				<!--- Check if admin user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
				<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
				WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND lower(grp_permission) NOT IN  ('w','x') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND lower(grp_permission) NOT IN  ('w','x') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND lower(grp_permission) NOT IN  ('w','x') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
					UNION ALL
					SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND lower(grp_permission) NOT IN  ('w','x') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />
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
				LEFT JOIN #session.hostdbprefix#folders fo ON l.ct_id_r = fo.folder_id  AND l.ct_type =<cfqueryparam value="folder" cfsqltype="cf_sql_varchar"/>
				WHERE ct_type = <cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND NOT EXISTS (select 1 from #session.hostdbprefix#folders where l.ct_id_r = folder_id AND l.ct_type ='folder' AND in_trash = 'T')
				<!--- Ensure user has access to folder --->
				AND 
				(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  l.ct_id_r AND folder_owner = '#session.theuserid#' AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">)
				OR
				EXISTS (SELECT 1 FROM  #session.hostdbprefix#folders_groups f WHERE l.ct_id_r = f.folder_id_r AND  f.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND l.ct_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x'))
				)
			) AS count_folders,
			(
				SELECT count(ct_label_id)
				FROM ct_labels l
				LEFT JOIN #session.hostdbprefix#collections c ON l.ct_id_r = c.col_id  AND l.ct_type =<cfqueryparam value="collection" cfsqltype="cf_sql_varchar"/>
				WHERE ct_type = <cfqueryparam value="collection" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND NOT EXISTS (select 1 from #session.hostdbprefix#collections where l.ct_id_r = col_id AND l.ct_type ='collection' AND in_trash = 'T')
				<!--- Ensure user has access to collection --->
				AND 
				(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#collections WHERE col_id =  l.ct_id_r AND col_owner = '#session.theuserid#' AND in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">)
				OR
				EXISTS (SELECT 1 FROM  #session.hostdbprefix#collections_groups f WHERE l.ct_id_r = f.col_id_r AND f.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#collections_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND l.ct_id_r = f.col_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x'))
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
			<cfset var sortby = "cast(size as decimal(12,0)) DESC">
		<cfelseif session.sortby EQ "sizeasc">
			<cfset var sortby = "cast(size as decimal(12,0)) ASC">
		<cfelseif session.sortby EQ "dateadd">
			<cfset var sortby = "date_create DESC">
		<cfelseif session.sortby EQ "datechanged">
			<cfset var sortby = "date_change DESC">
		</cfif>
		<!--- If there is no session for webgroups set --->
		<cfparam default="0" name="session.thegroupofuser">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("labels")>
		<cfset var qry = "">
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
			 i.img_id id, i.img_filename filename, <cfif application.razuna.thedatabase EQ "mssql">img_id + '-img'<cfelse>concat(img_id,'-img')</cfif> as fileidwithtype,
			i.folder_id_r,i.img_size as size,i.hashtag, i.thumb_extension ext, i.img_filename_org filename_org, 'img' as kind, i.is_available,
			i.img_create_time date_create, i.img_change_date date_change, i.link_kind, i.link_path_url,
			i.path_to_asset, i.cloud_url, i.cloud_url_org, 'R' as permfolder, i.expiry_date, f.folder_name, 'null' as customfields
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
			FROM ct_labels ct, #session.hostdbprefix#folders f, #session.hostdbprefix#images i 
			LEFT JOIN #session.hostdbprefix#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
			LEFT JOIN #session.hostdbprefix#xmp x ON x.id_r = i.img_id
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = i.img_id
			AND i.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar" />
			AND i.folder_id_r = f.folder_id
			<cfif application.razuna.thedatabase EQ "mssql">
				AND i.img_id NOT IN (
				SELECT TOP #min# mssql_i.img_id
				FROM #session.hostdbprefix#images mssql_i, ct_labels mssql_ct
				WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND mssql_ct.ct_id_r = mssql_i.img_id
				AND mssql_ct.ct_type = <cfqueryparam value="img" cfsqltype="cf_sql_varchar" />
			)	
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  i.folder_id_r AND folder_owner = '#session.theuserid#' ) 
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE i.folder_id_r = f.folder_id_r AND f.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x'))
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE 
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND i.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND lower(grp_permission) NOT IN  ('w','x') AND i.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			ELSE 1 END  = 1
			UNION ALL
			SELECT 
				<cfif application.razuna.thedatabase EQ "mssql">TOP #session.rowmaxpage# </cfif>
				<cfif application.razuna.thedatabase EQ "db2">row_number() over() as rownr,</cfif> 
				f.file_id id, f.file_name filename, <cfif application.razuna.thedatabase EQ "mssql">file_id + '-doc'<cfelse>concat(file_id,'-doc')</cfif> as fileidwithtype,
				f.folder_id_r,  f.file_size as size, f.hashtag,
			f.file_extension ext, f.file_name_org filename_org, f.file_type as kind, f.is_available,
			f.file_create_time date_create, f.file_change_date date_change, f.link_kind, f.link_path_url,
			f.path_to_asset, f.cloud_url, f.cloud_url_org, 'R' as permfolder, f.expiry_date, fo.folder_name, 'null' as customfields
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
			FROM ct_labels ct, #session.hostdbprefix#folders fo, #session.hostdbprefix#files f 
			LEFT JOIN #session.hostdbprefix#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1 
			LEFT JOIN #session.hostdbprefix#files_xmp x ON x.asset_id_r = f.file_id
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = f.file_id
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar" />
			AND f.folder_id_r = fo.folder_id
			<cfif application.razuna.thedatabase EQ "mssql">
				AND f.file_id NOT IN (
				SELECT TOP #min# mssql_f.file_id
				FROM #session.hostdbprefix#files mssql_f, ct_labels mssql_ct
				WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
				AND mssql_ct.ct_id_r = mssql_f.file_id
				AND mssql_ct.ct_type = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar" />
			)	
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  f.folder_id_r AND folder_owner = '#session.theuserid#' ) 
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders_groups fg WHERE f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND fg.grp_id_r = c.ct_g_u_grp_id AND lower(fg.grp_permission) IN  ('r','w','x'))
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE 
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE ct_g_u_user_id ='#session.theuserid#' AND f.folder_id_r = fg.folder_id_r AND c.ct_g_u_grp_id = fg.grp_id_r AND lower(fg.grp_permission) NOT IN  ('w','x') AND f.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			ELSE 1 END  = 1
			UNION ALL
			SELECT 
			<cfif application.razuna.thedatabase EQ "mssql">TOP #session.rowmaxpage# </cfif>
			<cfif application.razuna.thedatabase EQ "db2">row_number() over() as rownr,</cfif> 
			v.vid_id id, v.vid_filename filename, <cfif application.razuna.thedatabase EQ "mssql">vid_id + '-vid'<cfelse>concat(vid_id,'-vid')</cfif> as fileidwithtype,
			v.folder_id_r, v.vid_size as size, v.hashtag,
			v.vid_extension ext, v.vid_name_image filename_org, 'vid' as kind, v.is_available,
			v.vid_create_time date_create, v.vid_change_date date_change, v.link_kind, v.link_path_url,
			v.path_to_asset, v.cloud_url, v.cloud_url_org, 'R' as permfolder, v.expiry_date, f.folder_name, 'null' as customfields
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
			FROM ct_labels ct, #session.hostdbprefix#folders f, #session.hostdbprefix#videos v LEFT JOIN #session.hostdbprefix#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = v.vid_id
			AND v.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar" />
			AND v.folder_id_r = f.folder_id
			<cfif application.razuna.thedatabase EQ "mssql">
				AND v.vid_id NOT IN (
					SELECT TOP #min# mssql_v.vid_id
					FROM #session.hostdbprefix#videos mssql_v, ct_labels mssql_ct
					WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
					AND mssql_ct.ct_id_r = mssql_v.vid_id
					AND mssql_ct.ct_type = <cfqueryparam value="vid" cfsqltype="cf_sql_varchar" />
				)	
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  v.folder_id_r AND folder_owner = '#session.theuserid#' ) 
				OR
				EXISTS (SELECT 1 FROM  #session.hostdbprefix#folders_groups f WHERE  v.folder_id_r = f.folder_id_r AND f.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id AND lower(f.grp_permission) IN  ('r','w','x'))
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE 
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND v.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND lower(grp_permission) NOT IN  ('w','x') AND v.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			ELSE 1 END  = 1
			UNION ALL
			SELECT 
			<cfif application.razuna.thedatabase EQ "mssql">TOP #session.rowmaxpage# </cfif>
			<cfif application.razuna.thedatabase EQ "db2">row_number() over() as rownr,</cfif> 
			a.aud_id id, a.aud_name filename, <cfif application.razuna.thedatabase EQ "mssql">aud_id + '-aud'<cfelse>concat(aud_id,'-aud')</cfif> as fileidwithtype,
			a.folder_id_r, a.aud_size as size, a.hashtag,
			a.aud_extension ext, a.aud_name_org filename_org, 'aud' as kind, a.is_available,
			a.aud_create_time date_create, a.aud_change_date date_change, a.link_kind, a.link_path_url,
			a.path_to_asset, a.cloud_url, a.cloud_url_org, 'R' as permfolder, a.expiry_date, f.folder_name, 'null' as customfields
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
			FROM ct_labels ct, #session.hostdbprefix#folders f, #session.hostdbprefix#audios a LEFT JOIN #session.hostdbprefix#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = a.aud_id
			AND a.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar" />
			AND a.folder_id_r = f.folder_id
			<cfif application.razuna.thedatabase EQ "mssql">
				AND a.aud_id NOT IN (
					SELECT TOP #min# mssql_a.aud_id
					FROM #session.hostdbprefix#audios mssql_a, ct_labels mssql_ct
					WHERE mssql_ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
					AND mssql_ct.ct_id_r = mssql_a.aud_id
					AND mssql_ct.ct_type = <cfqueryparam value="aud" cfsqltype="cf_sql_varchar" />
				)	
			</cfif>
			<!--- Ensure user is owner of folder or has access to folder in which asset resides --->
			AND (
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders WHERE folder_id =  a.folder_id_r AND folder_owner = '#session.theuserid#' ) 
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#folders_groups f WHERE a.folder_id_r = f.folder_id_r AND f.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND f.grp_id_r = c.ct_g_u_grp_id  AND lower(f.grp_permission) IN  ('r','w','x'))
			   )
			<!--- Check if asset has expired and if user has only read only permissions in which case we hide asset --->
			AND CASE 
			<!--- Check if admin user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2')) THEN 1
			<!---  Check if asset is in folder for which user has read only permissions and asset has expired in which case we do not display asset to user --->
			WHEN EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND a.folder_id_r = f.folder_id_r AND c.ct_g_u_grp_id = f.grp_id_r AND lower(grp_permission) NOT IN  ('w','x') AND a.expiry_date < <cfqueryparam value="#dateformat(now(),'mm/dd/yyyy')#" cfsqltype="cf_sql_date" />) THEN 0
			ELSE 1 END  = 1
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
			<!--- Init var for new fileid --->
			<cfset var editids = "0,">
			<!--- Get proper folderaccess --->
			<cfloop query="qry">
				<cfinvoke component="folders" method="setaccess" returnvariable="theaccess" folder_id="#folder_id_r#"  />
				<!--- Add labels query --->
				<cfset QuerySetCell(qry, "permfolder", theaccess, currentRow)>
				<!--- Store only file_ids where folder access is not read-only --->
				<cfif theaccess NEQ "R" AND theaccess NEQ "n">
					<cfset editids = editids & fileidwithtype & ",">
				</cfif>
			</cfloop>
			<!--- Add the custom fields to query --->
			<cfinvoke component="folders" method="addCustomFieldsToQuery" theqry="#qry#" returnvariable="qry" />
			<!--- Save the editable ids in a session --->
			<cfset session.search.edit_ids = editids>
		<!--- Get folders --->
		<cfelseif arguments.label_kind EQ "folders">
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			SELECT /* #variables.cachetoken#getlabelsfolders */ f.folder_id, f.folder_name, f.folder_id_r, f.folder_is_collection, '' AS perm
			FROM #session.hostdbprefix#folders f, ct_labels ct
			WHERE ct.ct_label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_id_r = f.folder_id
			AND f.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ct.ct_type = <cfqueryparam value="folder" cfsqltype="cf_sql_varchar" />
			<!--- Ensure user has access to folder  --->
			AND 
			(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				folder_owner = '#session.theuserid#' 
				OR
				EXISTS (SELECT 1 FROM ct_groups_users c, #session.hostdbprefix#folders_groups fg WHERE c.ct_g_u_user_id ='#session.theuserid#' AND f.folder_id = fg.folder_id_r AND (fg.grp_id_r = c.ct_g_u_grp_id OR fg.grp_id_r = 0)AND lower(fg.grp_permission) IN  ('r','w','x'))
			)
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
			AND c.in_trash = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="F">
			AND ctl.ct_type = <cfqueryparam value="collection" cfsqltype="cf_sql_varchar" />
			<!--- Ensure user has access to collection --->
			AND 
			(
				EXISTS (SELECT 1 FROM ct_groups_users WHERE ct_g_u_user_id ='#session.theuserid#' and ct_g_u_grp_id in ('1','2'))
				OR
				col_owner = '#session.theuserid#' 
				OR
				EXISTS (SELECT 1 FROM #session.hostdbprefix#collections_groups f WHERE c.col_id = f.col_id_r AND  f.grp_id_r = '0')
				OR
				EXISTS (SELECT 1 FROM ct_groups_users cc, #session.hostdbprefix#collections_groups f WHERE ct_g_u_user_id ='#session.theuserid#' AND c.col_id = f.col_id_r AND f.grp_id_r = cc.ct_g_u_grp_id  AND lower(f.grp_permission) IN  ('r','w','x'))
			)
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
		<cfset var qry = "">
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
		<cfset var qry = "">
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
		<!--- Call this again to see if there are any more records below it --->
		<cfinvoke method="label_get_ids" label_id="#arguments.id#" llist="#arguments.id#" returnVariable="llist" />
		<!--- DB labels --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM #session.hostdbprefix#labels
		WHERE label_id IN (<cfqueryparam value="#llist#" cfsqltype="cf_sql_varchar" list="Yes" />)
		AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		<!--- DB CT table --->
		<cfquery datasource="#application.razuna.datasource#">
		DELETE FROM ct_labels
		WHERE ct_label_id IN (<cfqueryparam value="#llist#" cfsqltype="cf_sql_varchar" list="Yes" />)
		</cfquery>
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
		<!--- Check if parent label exists. If not then add to root --->
		<cfquery datasource="#application.razuna.datasource#" name="parentcheck">
			SELECT 1 FROM  #session.hostdbprefix#labels WHERE label_id = <cfqueryparam value="#arguments.thestruct.label_parent#" cfsqltype="cf_sql_varchar" />
		</cfquery>

		<cfif parentcheck.recordcount EQ 0>
			<cfset arguments.thestruct.label_parent = 0>
		</cfif>

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
				<cfqueryparam value="#trim(thelabel)#" cfsqltype="cf_sql_varchar" />,
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
			label_text = <cfqueryparam value="#trim(thelabel)#" cfsqltype="cf_sql_varchar" />, 
			label_id_r = <cfqueryparam value="#arguments.thestruct.label_parent#" cfsqltype="cf_sql_varchar" />
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
				<cfset var thelen = len(thepath)>
				<cfset var thepath = removechars(thepath,thelen,1)>
			</cfif>
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#labels
			SET label_path = <cfqueryparam value="#thepath#" cfsqltype="cf_sql_varchar" />
			WHERE label_id = <cfqueryparam value="#arguments.thestruct.label_id#" cfsqltype="cf_sql_varchar" />
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<cfset var labelpath = thepath>
		<cfelse>
			<cfset var labelpath = thelabel>
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
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
		SELECT label_id, label_text, label_id_r
		FROM #session.hostdbprefix#labels
		WHERE label_id = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<!--- Set into list --->
		<cfset llist = qry.label_text & "/" & arguments.llist> 
		<!--- Call this again if this label_id_r is not empty --->
		<cfif qry.recordcount NEQ 0 AND qry.label_id_r NEQ 0>
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
		<cfset var qry = "">
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
	
	<!--- Label Ids get recursive --->
	<cffunction name="label_get_ids" output="false" access="public" returnType="string">
		<cfargument name="label_id" type="string" required="true">
		<cfargument name="llist" default="" type="string" required="false">
		<cfset var qry = "">
			<!--- Query --->
			<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT label_id,label_id_r
			FROM #session.hostdbprefix#labels
			WHERE label_id_r = <cfqueryparam value="#arguments.label_id#" cfsqltype="cf_sql_varchar" />
			AND host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			</cfquery>
			<!--- Set into list --->
			<cfset llist = arguments.llist &","&qry.label_id>
			<!--- Check the recursive call --->
			<cfif qry.recordcount NEQ 0 AND ListContainsnocase(llist,qry.label_id,',')>
				<!--- Call this again to see if there are any more records below it --->
				<cfinvoke method="label_get_ids" label_id="#qry.label_id#" llist="#llist#" returnVariable="llist" />
			</cfif>
		<!--- Return --->
		<cfreturn llist />
	</cffunction>
	
	<!--- Get the all labels for show --->
	<cffunction name="get_all_labels_for_show" output="true" access="public" returntype="Query" hint="Get the all labels for show" >
		<cfargument name="thestruct" type="struct" required="true">
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT  /* #variables.cachetoken#get_all_labels_for_show */ <cfif application.razuna.thedatabase EQ "mssql">Top 20 </cfif> label_id, label_id_r, label_path, label_text
			FROM #session.hostdbprefix#labels
			WHERE host_id = <cfqueryparam value="#session.hostid#" cfsqltype="cf_sql_numeric" />
			<cfif structKeyExists(arguments.thestruct,'strLetter')>
				AND lower(label_text) LIKE <cfqueryparam value="#lcase(arguments.thestruct.strLetter)#%" cfsqltype="cf_sql_varchar" />
			</cfif>
			ORDER BY 
			<cfif structKeyExists(arguments.thestruct,'show') AND arguments.thestruct.show EQ 'default'>
				label_date DESC	
				<cfif application.razuna.thedatabase EQ "mysql" OR application.razuna.thedatabase EQ "h2"> 
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
	<cffunction name="asset_label_add_remove" output="true" access="public" hint="Add or remove the assets labels for choosed">
		<cfargument name="thestruct" type="struct">
		<!--- Update Dates --->
		<cfinvoke component="global" method="update_dates" type="#arguments.thestruct.thetype#" fileid="#arguments.thestruct.fileid#" />
		<!--- Remove unchecked label for this record --->
		<cfif structKeyExists(arguments.thestruct,'checked') AND arguments.thestruct.checked EQ "false">
			<cfquery datasource="#application.razuna.datasource#">
				DELETE FROM ct_labels
				WHERE ct_id_r = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="cf_sql_varchar" />
				AND ct_type = <cfqueryparam value="#arguments.thestruct.thetype#" cfsqltype="cf_sql_varchar" />
				AND ct_label_id = <cfqueryparam value="#arguments.thestruct.labels#" cfsqltype="cf_sql_varchar" />
			</cfquery>
		</cfif>
		<cfif structkeyexists(arguments.thestruct,"labels") AND structKeyExists(arguments.thestruct,'checked') AND arguments.thestruct.checked EQ "true">
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
		<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix##thedb#
			SET #d1# = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
			WHERE #theid# = <cfqueryparam value="#arguments.thestruct.fileid#" cfsqltype="CF_SQL_VARCHAR">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Flush --->
		<!--- <cfset resetcachetoken(thedb)> not sure, is it neccessary? --->
		<cfset resetcachetoken("search")>
		<cfset variables.cachetoken = resetcachetoken("labels")>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Get the search label index (A,B,..Z) --->
	<cffunction name="get_search_label_index" output="true" access="public" returntype="Query" hint="Get the search label text" >
		<cfargument name="thestruct" type="struct" required="true">
		<cfset var qry = "">
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
			SELECT DISTINCT LEFT(UPPER(RTRIM(LTRIM(label_text))),1) AS label_text_index FROM #session.hostdbprefix#labels ORDER BY label_text_index
		</cfquery>
		<!--- Return --->
		<cfreturn qry/>
	</cffunction>
	
</cfcomponent>

