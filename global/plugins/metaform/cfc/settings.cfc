<cfcomponent output="false" extends="global.cfc.api">

	<!--- Get Settings --->
	<cffunction name="getSettings" access="public" output="false" returntype="struct">
		<!--- Param --->
		<cfset var s = structnew()>
		<!--- Get Custom Fields --->
		<cfset s.qry_cf = getCustomFields()>
		<!--- Metadata fields --->
		<cfset s.meta_default = "filename,keywords,description,labels" />
		<cfset s.meta_img = "subjectcode,creator,title,authorsposition,captionwriter,ciadrextadr,category,supplementalcategories,urgency,description,ciadrcity,ciadrctry,location,ciadrpcode,ciemailwork,ciurlwork,citelwork,intellectualgenre,instructions,source,usageterms,copyrightstatus,transmissionreference,webstatement,headline,datecreated,city,ciadrregion,country,countrycode,scene,state,credit,rights,colorspace" />
		<!--- Get the values of the form --->
		<cfquery datasource="#getDatasource()#" name="s.qry_mf_order">
		SELECT mf_value
		FROM #getHostPrefix()#metaform
		WHERE lower(mf_type) = <cfqueryparam cfsqltype="cf_sql_varchar" value="mf_order">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">
		</cfquery>
		<!--- Get the values of the form --->
		<cfquery datasource="#getDatasource()#" name="s.qry_mf_active">
		SELECT mf_value
		FROM #getHostPrefix()#metaform
		WHERE lower(mf_type) = <cfqueryparam cfsqltype="cf_sql_varchar" value="mf_active">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">
		</cfquery>
		<!--- if active is empty --->
        <cfif s.qry_mf_active.recordcount EQ 0>
			<cfset queryaddrow(s.qry_mf_active)>
			<cfset querysetcell(s.qry_mf_active,"mf_value","false")>
        </cfif>
		<!--- Get the values of the form --->
		<cfquery datasource="#getDatasource()#" name="s.qry">
		SELECT mf_type, mf_value, mf_order
		FROM #getHostPrefix()#metaform
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">
		</cfquery>
		<!--- Return --->
		<cfreturn s />
	</cffunction>

	<!--- setSettings --->
	<cffunction name="setSettings" access="remote" output="false" returntype="struct">
		<cfargument name="args" required="true">
		<!--- Param --->
		<cfset var v = "">
		<cfset var thecf = "">
		<!--- Remove all entries --->
		<cfquery datasource="#getDatasource()#">
		DELETE FROM #getHostPrefix()#metaform
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">
		</cfquery>
		<!--- Insert if form is active or not --->
		<cfquery datasource="#getDatasource()#">
		INSERT INTO #getHostPrefix()#metaform
		(host_id, mf_type, mf_value, mf_order)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="MF_ACTIVE">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.args.mf_active#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="0">
		)
		</cfquery>
		<!--- Insert order --->
		<cfquery datasource="#getDatasource()#">
		INSERT INTO #getHostPrefix()#metaform
		(host_id, mf_type, mf_value, mf_order)
		VALUES(
			<cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="MF_ORDER">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.args.mf_order#">,
			<cfqueryparam cfsqltype="cf_sql_numeric" value="0">
		)
		</cfquery>
		<!--- Save the action and events --->
		<cfloop list="#arguments.args.fieldnames#" delimiters="," index="i">
			<cfif i contains "mf_meta_field">
				<!--- Get number --->
				<cfset n = listlast(i,"_")>
				<!--- Only grab fields with the same number --->
				<cfif i EQ "mf_meta_field_#n#" OR i EQ "mf_meta_field_req_#n#">
					<cfif evaluate(i) CONTAINS "-">
						<cfset thecf = evaluate(i)>
					</cfif>
					<!--- Create the list --->
					<cfset v = v & i & ":" & evaluate(i) & ";" & listlast(i,"_") & ";">
					<!--- Only do this if list has 4 elements --->
					<cfif listLen(v,";") EQ 4>
						<!--- Get order --->
						<cfset o = listFindNoCase(arguments.args.mf_order,"div_metafield_#n#",",")>
						<!--- Save to DB --->
						<cfquery datasource="#getDatasource()#">
						INSERT INTO #getHostPrefix()#metaform
						(host_id, mf_type, mf_value, mf_order, mf_cf)
						VALUES(
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="mf_meta_field_#n#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#v#">,
							<cfqueryparam cfsqltype="cf_sql_numeric" value="#o#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#thecf#">
						)
						</cfquery>
						<!--- Clear variable --->
						<cfset v = "">
						<cfset thecf = "">
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<!--- We need to return a struct!!! --->
		<cfset result.page = false>
		<cfreturn result />
	</cffunction>

	<!--- loadForm --->
	<cffunction name="loadform" access="public" output="false" returntype="struct">
		<cfargument name="args" required="true">
		<!--- Param --->
		<cfset var s = structNew()>
		<cfset s.qry_fields = "">
		<cfset s.qry_files = "">
		<cfset s.active = false>
		<!--- Check if form is enabled or not --->
		<cfquery datasource="#getDatasource()#" name="qryactive">
		SELECT mf_value
		FROM #getHostPrefix()#metaform
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">
		AND lower(mf_type) = <cfqueryparam cfsqltype="cf_sql_varchar" value="mf_active">
		</cfquery>
		<cfif qryactive.recordcount NEQ 0>
			<cfset s.active = qryactive.mf_value>
		</cfif>
		<!--- If session if here or not 0 --->
		<cfif structKeyExists(session,"currentupload") AND session.currentupload NEQ 0>
			<!--- Get fields to show --->
			<cfquery datasource="#getDatasource()#" name="s.qry_fields">
			SELECT f.mf_type, f.mf_value, f.mf_order, f.mf_cf, c.cf_id, c.cf_type, c.cf_order, c.cf_enabled, c.cf_show, c.cf_select_list, ct.cf_text
			FROM #getHostPrefix()#metaform f
			LEFT JOIN #session.hostdbprefix#custom_fields c ON c.cf_id = f.mf_cf 
			LEFT JOIN #session.hostdbprefix#custom_fields_text ct ON ct.cf_id_r = c.cf_id
			WHERE f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getHostID()#">
			AND f.mf_order <cfif application.razuna.thedatabase EQ "oracle" OR application.razuna.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
			</cfquery>
			<!--- Get labels --->
			<cfset s.qry_labels = getLabels()>
			<!--- Get files --->
			<cfset s.qry_files = getFilesTemp(fileid=session.currentupload)>
		</cfif>
		<cfreturn s />
	</cffunction>

	<!--- loadForm --->
	<cffunction name="saveform" access="public" output="false" returntype="struct">
		<cfargument name="args" required="true">
		<!--- Loop over the fields --->
		<cfloop list="#arguments.args.fieldnames#" delimiters="," index="i">
			<cfif i CONTAINS "_">
				<!--- Get the fileid --->
				<cfset var thefileid = listFirst(i,"_")>
				<!--- Get the fieldname --->
				<cfset var thefield = listLast(i,"_")>
				<!--- If thefield contains a - then we are CUSTOM FIELDS --->
				<cfif thefield CONTAINS "-">
					<!--- Set application values for the api --->
					<cfset application.razuna.api.storage = application.razuna.storage>
					<cfset application.razuna.api.dsn = application.razuna.datasource>
					<cfset application.razuna.api.thedatabase = application.razuna.thedatabase>
					<cfset application.razuna.api.setid = application.razuna.setid>
					<!--- Get field --->
					<cfset a = "#thefileid#_CF_#thefield#">
					<!--- Get value --->
					<cfset e = arguments.args["#a#"]>
					<!--- Create array so we can serialize it to json and pass it to api --->
					<cfset j = arrayNew(2)>
					<cfset j[1][1] = thefield>
					<cfset j[1][2] = e>
					<cfset j = SerializeJSON(j)>
					<!--- Call API function --->
					<cfinvoke component="global.api2.customfield" method="setfieldvalue" api_key="#getHostID()#-108" assetid="#thefileid#" field_values="#j#" />
				<!--- This is for normal fields --->
				<cfelse>
					<cfset a = "#thefileid#_#thefield#">
					<cfset e = arguments.args["#a#"]>
					<!--- filenames --->
					<cfswitch expression="#thefield#">
						<!--- Filename --->
						<cfcase value="filename">
							<cfif e NEQ "">
								<cfset todb(thedb="images",thecolumn="img_filename",thecolumnid="img_id",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="videos",thecolumn="vid_filename",thecolumnid="vid_id",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="audios",thecolumn="aud_name",thecolumnid="aud_id",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="files",thecolumn="file_name",thecolumnid="file_id",thefileid="#thefileid#",thevalue="#e#")>
							</cfif>
						</cfcase>
						<!--- Keywords --->
						<cfcase value="keywords">
							<cfif e NEQ "">
								<cfset todb(thedb="images_text",thecolumn="img_keywords",thecolumnid="img_id_r",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="videos_text",thecolumn="vid_keywords",thecolumnid="vid_id_r",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="audios_text",thecolumn="aud_keywords",thecolumnid="aud_id_r",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="files_desc",thecolumn="file_keywords",thecolumnid="file_id_r",thefileid="#thefileid#",thevalue="#e#")>
							</cfif>
						</cfcase>
						<!--- Description --->
						<cfcase value="description">
							<cfif e NEQ "">
								<cfset todb(thedb="images_text",thecolumn="img_description",thecolumnid="img_id_r",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="videos_text",thecolumn="vid_description",thecolumnid="vid_id_r",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="audios_text",thecolumn="aud_description",thecolumnid="aud_id_r",thefileid="#thefileid#",thevalue="#e#")>
								<cfset todb(thedb="files_desc",thecolumn="file_desc",thecolumnid="file_id_r",thefileid="#thefileid#",thevalue="#e#")>
							</cfif>
						</cfcase>
						<!--- Description --->
						<cfcase value="labels">
							<cfif e NEQ "">
								<cfset tolabel(thefileid=thefileid,thevalue=e)>
							</cfif>
						</cfcase>
						<!---
						<!--- PDF metadata --->
						<cfcase value="author,rights,authorsposition,captionwriter,webstatement,rightsmarked">
							<cfset todb(thedb="files_xmp",thecolumn="#thefield#",thecolumnid="asset_id_r",thefileid="#thefileid#",thevalue="#e#")>
						</cfcase>
						<!--- Image XMP --->
						<cfcase value="subjectcode,creator,title,authorsposition,captionwriter,ciadrextadr,category,supplementalcategories,urgency,description,ciadrcity,ciadrctry,location,ciadrpcode,ciemailwork,ciurlwork,citelwork,intellectualgenre,instructions,source,usageterms,copyrightstatus,transmissionreference,webstatement,headline,datecreated,city,ciadrregion,country,countrycode,scene,state,credit,rights,colorspace">
							<cfset todb(thedb="xmp",thecolumn="#thefield#",thecolumnid="id_r",thefileid="#thefileid#",thevalue="#e#")>
						</cfcase>
						--->
					</cfswitch>
				</cfif>
			</cfif>
		</cfloop>
		<!--- Loop over filewithtype and call workflow for each file --->
		<cfloop list="#arguments.args.filewithtype#" delimiters="," index="i">
			<!--- First is fileid --->
			<cfset var theid = listFirst(i,"_")>
			<!--- Last is type --->
			<cfset var thetype = listLast(i,"_")>
			<!--- Now call workflow --->
			<cfset executeWorkflow(workflow="on_file_edit",fileid=theid,thetype=thetype,folderid=session.fid)>
		</cfloop>
		<!--- Reset session --->
		<cfset session.currentupload = 0>
		<!--- We need to return a struct!!! --->
		<cfset result.page = false>
		<cfreturn result />
	</cffunction>

	<cffunction name="todb" access="private">
		<cfargument name="thedb" required="true">
		<cfargument name="thecolumn" required="true">
		<cfargument name="thecolumnid" required="true">
		<cfargument name="thefileid" required="true">
		<cfargument name="thevalue" required="true">
		<!--- Update --->
		<cfquery datasource="#getDatasource()#">
		UPDATE #getHostPrefix()##arguments.thedb#
		SET #arguments.thecolumn# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thevalue#">
		WHERE #arguments.thecolumnid# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thefileid#">
		</cfquery>
		<!--- Return --->
		<cfreturn />
	</cffunction>

	<cffunction name="tolabel" access="private">
		<cfargument name="thefileid" required="true">
		<cfargument name="thevalue" required="true">
		<!--- Param --->
		<cfset var q = "">
		<!--- Get the type --->
		<cfquery datasource="#getDatasource()#" name="q">
		SELECT 'img' as type
		FROM #getHostPrefix()#images
		WHERE img_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thefileid#">
		UNION ALL
		SELECT 'vid' as type
		FROM #getHostPrefix()#videos
		WHERE vid_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thefileid#">
		UNION ALL
		SELECT 'aud' as type
		FROM #getHostPrefix()#audios
		WHERE aud_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thefileid#">
		UNION ALL
		SELECT 'doc' as type
		FROM #getHostPrefix()#files
		WHERE file_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thefileid#">
		</cfquery>
		<!--- Now add the labels --->
		<cfset addLabels(labelids=arguments.thevalue,fileid=arguments.thefileid,type=q.type)>
		<!--- Return --->
		<cfreturn />
	</cffunction>

</cfcomponent>
