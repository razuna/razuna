<cfcomponent>
	
	<!--- Migrate DB --->
	<cffunction name="migrate_db">
		<cfargument name="thestruct" type="struct">
		<!--- Get host table --->
		<cfinvoke method="gethost" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_host" />
		<!--- Migrate default tables --->
		<cfinvoke method="migrate_default" thestruct="#arguments.thestruct#" />
		<!--- Migrate sharding tables --->
		<cfinvoke method="migrate_sharding" thestruct="#arguments.thestruct#" />
	</cffunction>
	
	<!--- Migrate Files --->
	<cffunction name="migrate_files" output="yes">
		<cfargument name="thestruct" type="struct">
		<!--- Get host table --->
		<cfinvoke method="gethost" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_host" />
		<!--- Grab the asset path from local --->
		<cfquery datasource="#arguments.thestruct.db_local#" name="arguments.thestruct.qry_setting">
		SELECT SET2_PATH_TO_ASSETS, set2_nirvanix_name, set2_nirvanix_pass
		FROM #arguments.thestruct.qry_host.host_shard_group#settings_2
		WHERE host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		</cfquery>
		<!--- Feedback --->
		<cfoutput><strong>Creating host folder...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Create hostid folder ---> 
		<cfif !directoryexists("#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#")>
			<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#" mode="775" />
		</cfif>
		<!--- Grab folder db --->
		<cfquery datasource="#arguments.thestruct.db_local#" name="qry_folders">
		SELECT folder_id, FOLDER_IS_COLLECTION
		FROM #arguments.thestruct.qry_host.host_shard_group#folders
		WHERE host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		AND (lower(FOLDER_IS_COLLECTION) != <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="t">
		OR FOLDER_IS_COLLECTION IS NULL)
		</cfquery>
		<!--- Feedback --->
		<cfoutput><strong>Creating folders...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Create folders --->
		<cfloop query="qry_folders">
			<cfif !directoryexists("#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#folder_id#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#folder_id#" />
				<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#folder_id#/doc" />
				<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#folder_id#/img" />
				<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#folder_id#/vid" />
				<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#folder_id#/aud" />
			</cfif>
		</cfloop>
		<!--- Call sub function on each asset table to grab assets --->
		
		<!--- FILES --->
		<cfset arguments.thestruct.type = "files">
		<cfinvoke method="getnirvanix" thestruct="#arguments.thestruct#" />
		<!--- AUDIOS --->
		<cfset arguments.thestruct.type = "audios">
		<cfinvoke method="getnirvanix" thestruct="#arguments.thestruct#" />
		<!--- VIDEOS --->
		<cfset arguments.thestruct.type = "videos">
		<cfinvoke method="getnirvanix" thestruct="#arguments.thestruct#" />
		<!--- IMAGES --->
		<cfset arguments.thestruct.type = "images">
		<cfinvoke method="getnirvanix" thestruct="#arguments.thestruct#" />
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- Get files --->
	<cffunction name="getnirvanix" output="yes">
		<cfargument name="thestruct" type="struct">
		<!--- Feedback --->
		<cfoutput><strong>Getting "#arguments.thestruct.type#" assets...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Query --->
		<cfquery datasource="#arguments.thestruct.db_local#" name="qry">
		SELECT cloud_url, cloud_url_org, path_to_asset<cfif arguments.thestruct.type EQ "files">, file_extension, folder_id_r</cfif>
		FROM #arguments.thestruct.qry_host.host_shard_group##arguments.thestruct.type#
		WHERE host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		AND (folder_id_r != '' OR folder_id_r IS NOT NULL)
		</cfquery>
		<!--- Loop --->
		<cfloop query="qry">
			<!--- Create id folder --->
			<cfif !directoryexists("#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#path_to_asset#")>
				<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#path_to_asset#" mode="775" />
			</cfif>
			<!--- Get names from cloud urls --->
			<cfset tname = listlast(cloud_url, "/")>
			<cfset oname = listlast(cloud_url_org, "/")>
			<!--- Feedback --->
			<cfoutput><strong>Getting: #oname# (#path_to_asset#)</strong><br></cfoutput>
			<cfflush>
			<!--- Get thumb --->
			<cfif !fileexists("#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#path_to_asset#/#tname#")>
				<cfhttp url="#cloud_url#" file="#tname#" path="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#path_to_asset#"></cfhttp>
			</cfif>
			<!--- Get org --->
			<cfif !fileexists("#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#path_to_asset#/#oname#")>
				<cfhttp url="#cloud_url_org#" file="#oname#" path="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#path_to_asset#"></cfhttp>
			</cfif>
			<!--- If this is a PDF then pull down thumbnail folder also --->
			<cfif arguments.thestruct.type EQ "files" AND file_extension EQ "pdf">
				<cfinvoke method="getpdfimages" thestruct="#arguments.thestruct#" pathtoasset="#path_to_asset#" />
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- List the PDF image files to be shown to the browser --->
	<cffunction name="getpdfimages" output="true">
		<cfargument name="thestruct" type="struct" required="true">
		<cfargument name="pathtoasset" type="string" required="true">
		<!--- Param --->
		<cfset var thepdfjpgslist = "">
		<!--- Get Nirvanix session --->
		<cfinvoke method="nirvanixlogin" thestruct="#arguments.thestruct#" returnVariable="nvxsession" />
		<!--- Call ListFolder --->
		<cfhttp url="http://services.nirvanix.com/ws/IMFS/ListFolder.ashx" method="get" throwonerror="no" charset="utf-8" timeout="30">
			<cfhttpparam name="sessionToken" value="#nvxsession#" type="url">
			<cfhttpparam name="folderPath" value="/#arguments.pathtoasset#/razuna_pdf_images/" type="url">
			<cfhttpparam name="pageNumber" value="1" type="url">
			<cfhttpparam name="pageSize" value="100" type="url">
			<cfhttpparam name="sortCode" value="Name" type="url">
			<cfhttpparam name="sortDescending" value="false" type="url">
		</cfhttp>
		<cfset var xmlVar = xmlParse(cfhttp.FileContent)/>
		<!--- XPath of the XML returned from Nirvanix --->
		<cfset var mysearch = xmlsearch(xmlVar, "/Response/ListFolder/File")>
		<!--- Set an empty query --->
		<cfset var qry_pdfjpgs = QueryNew("Name")>
		<!--- Get lenght of Array --->
		<cfset var nr = arraylen(mysearch)>
		<!--- Loop over XML and add it to query --->
		<cfif nr IS NOT 0>
			<cfloop from="1" to="#nr#" index="i">
				<cfset QueryAddRow(qry_pdfjpgs, i)>
				<cfset QuerySetCell(qry_pdfjpgs, "Name", "#mysearch[i].Name.xmltext#", i)>
			</cfloop>
		</cfif>
		<!--- QoQ to filter out the null values since Nirvanix pagesize is so huge --->
		<cfquery dbtype="query" name="qry_pdfjpgs">
		SELECT *
		FROM qry_pdfjpgs
		WHERE name IS NOT NULL
		</cfquery>
		<!--- Where to start in the loop. When only one record found start with 1 else with 0 --->
		<cfif qry_pdfjpgs.recordcount EQ 1>
			<cfset var theloopstart = 1>
		<cfelse>
			<cfset var theloopstart = 0>
		</cfif>
		<!--- Loop over the directory list and replace the name with the actual record number found --->
		<cfloop from="#theloopstart#" to="#qry_pdfjpgs.recordcount#" index="i">
			<cfset thepdfjpgslist = thepdfjpgslist & "," & replacenocase(qry_pdfjpgs.name,"-0","-#i#","all")>
		</cfloop>
		<!--- Create razuna_pdf_images directory --->
		<cfif !directoryexists("#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.pathtoasset#/razuna_pdf_images")>
			<cfdirectory action="create" directory="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.pathtoasset#/razuna_pdf_images" mode="775" />
		</cfif>
		<!--- Loop over list and download images --->
		<cfloop list="#thepdfjpgslist#" delimiters="," index="i">
			<cfset thenr = replacenocase(i,".jpg","","all")>
			<cfset thenr = listlast(thenr,"-")>
			<cfhttp url="http://services.nirvanix.com/#nvxsession#/razuna/#arguments.thestruct.hostid#/#arguments.pathtoasset#/razuna_pdf_images/#i#" file="#i#" path="#arguments.thestruct.qry_setting.set2_path_to_assets#/#arguments.thestruct.hostid#/#arguments.pathtoasset#/razuna_pdf_images"></cfhttp>
		</cfloop>
		<!--- Return --->
		<cfreturn />
	</cffunction>
	
	<!--- FUNCTION: LOGIN --->
	<cffunction name="nirvanixlogin" returntype="string" access="remote" output="false">
		<cfargument name="thestruct" type="struct" required="false" />
			<!--- Get session --->
			<cfhttp url="https://services.nirvanix.com/ws/Authentication/Login.ashx" method="get" throwonerror="no" charset="utf-8" timeout="30">
				<cfhttpparam name="appKey" value="cf9bcddb-da28-4a96-a107-04e09391dabd" type="url">
				<cfhttpparam name="username" value="#arguments.thestruct.qry_setting.set2_nirvanix_name#" type="url">
				<cfhttpparam name="password" value="#arguments.thestruct.qry_setting.set2_nirvanix_pass#" type="url">
			</cfhttp>
			<!--- Get the XML node for each setting --->
			<cfset var thexml = xmlparse(cfhttp.FileContent)>
			<cfset var nvxsession = thexml.Response.Sessiontoken[1].XmlText>
		<cfreturn nvxsession>
	</cffunction>
	
	<!--- Migrate sharding group tables --->
	<cffunction name="migrate_sharding">
		<cfargument name="thestruct" type="struct">
		<!--- Feedback --->
		<cfoutput><strong>Migrating sharding tables...</strong><br><br></cfoutput>
		<cfflush>
		<!--- All tables with hostid --->
		<cfset var tbl_hostid = "#arguments.thestruct.qry_host.host_shard_group#xmp,#arguments.thestruct.qry_host.host_shard_group#cart,#arguments.thestruct.qry_host.host_shard_group#folders,#arguments.thestruct.qry_host.host_shard_group#folders_desc,#arguments.thestruct.qry_host.host_shard_group#folders_groups,#arguments.thestruct.qry_host.host_shard_group#files,#arguments.thestruct.qry_host.host_shard_group#files_desc,#arguments.thestruct.qry_host.host_shard_group#images,#arguments.thestruct.qry_host.host_shard_group#images_text,#arguments.thestruct.qry_host.host_shard_group#settings,#arguments.thestruct.qry_host.host_shard_group#settings_2,#arguments.thestruct.qry_host.host_shard_group#collections,#arguments.thestruct.qry_host.host_shard_group#collections_text,#arguments.thestruct.qry_host.host_shard_group#collections_ct_files,#arguments.thestruct.qry_host.host_shard_group#collections_groups,#arguments.thestruct.qry_host.host_shard_group#users_favorites,#arguments.thestruct.qry_host.host_shard_group#videos,#arguments.thestruct.qry_host.host_shard_group#videos_text,#arguments.thestruct.qry_host.host_shard_group#custom_fields,#arguments.thestruct.qry_host.host_shard_group#custom_fields_text,#arguments.thestruct.qry_host.host_shard_group#custom_fields_values,#arguments.thestruct.qry_host.host_shard_group#comments,#arguments.thestruct.qry_host.host_shard_group#versions,#arguments.thestruct.qry_host.host_shard_group#languages,#arguments.thestruct.qry_host.host_shard_group#audios,#arguments.thestruct.qry_host.host_shard_group#audios_text,#arguments.thestruct.qry_host.host_shard_group#share_options,#arguments.thestruct.qry_host.host_shard_group#upload_templates,#arguments.thestruct.qry_host.host_shard_group#upload_templates_val,#arguments.thestruct.qry_host.host_shard_group#widgets,#arguments.thestruct.qry_host.host_shard_group#additional_versions,#arguments.thestruct.qry_host.host_shard_group#files_xmp,#arguments.thestruct.qry_host.host_shard_group#labels">
		<!--- Loop over the hostid tables and insert values from hosted --->
		<cfloop list="#tbl_hostid#" delimiters="," index="i">
			<!--- Feedback --->
			<cfoutput><strong>Working on #i#...</strong><br><br></cfoutput>
			<cfflush>
			<cfset qry = "">
			<cfset qry_columns = "">
			<cfset thecollist = "">
			<!--- Select from hosted --->
			<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry">
			SELECT *
			FROM #i#
			WHERE host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
			</cfquery>
			<!--- Get Columns --->			
			<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_columns">
			SELECT column_name, data_type
			FROM information_schema.columns
			WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(i)#">
			AND table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="razuna">
			ORDER BY column_name, data_type
			</cfquery>
			<!--- Create our custom list --->
			<cfloop query="qry_columns">
				<cfset thecollist = thecollist & column_name & "-" & data_type & ",">
			</cfloop>
			<!--- Remove the last comma --->
			<cfset l = len(thecollist)>
			<cfset thecollist = mid(thecollist,1,l-1)>
			<!--- Set variables for the query loop below --->
			<cfset len_meta = listlen(thecollist)>
			<cfset len_count_meta = 1>
			<cfset len_count_meta2 = 1>
			<!--- Disable Foreign key checks --->
			<cfquery datasource="#arguments.thestruct.db_local#">
			SET FOREIGN_KEY_CHECKS = 0
			</cfquery>
			<!--- Loop over found records and insert --->
			<cfif qry.recordcount NEQ 0>
				<cfset i = i>
				<cfloop query="qry">
					<cftry>
						<cfquery datasource="#arguments.thestruct.db_local#">
						INSERT INTO #i#
						(<cfloop list="#thecollist#" index="c" delimiters=",">#listfirst(c,"-")#<cfif len_count_meta NEQ len_meta>, </cfif><cfset len_count_meta = len_count_meta + 1></cfloop>)
						VALUES(
							<cfloop list="#qry.columnlist#" index="cl" delimiters=",">
								<cfset lf = ListContainsNoCase(thecollist, cl)>
								<cfset lg = ListGetAt(thecollist, lf)>
								<!--- Varchar --->
								<cfif trim(listlast(lg,"-")) CONTAINS "varchar" OR trim(listlast(lg,"-")) CONTAINS "text">
									<cfif evaluate(cl) EQ "">
										<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">
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
							<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "#i#"!</span><br>#cfcatch.detail#</p></cfoutput>
						</cfcatch>
					</cftry>
					<!--- Reset loop variables --->
					<cfset len_count_meta = 1>
					<cfset len_count_meta2 = 1>
				</cfloop>
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- Default Tables --->
	<cffunction name="migrate_default" output="yes">
		<cfargument name="thestruct" type="struct">
		<!--- Feedback --->
		<cfoutput><strong>Migrating default tables...</strong><br><br></cfoutput>
		<cfflush>
		<!--- Disable Foreign key checks --->
		<cfquery datasource="#arguments.thestruct.db_local#">
		SET FOREIGN_KEY_CHECKS = 0
		</cfquery>
		<!--- Hosts --->
		<cfloop query="arguments.thestruct.qry_host">
			<cftry>
				<cfquery datasource="#arguments.thestruct.db_local#">
				INSERT INTO hosts
				(HOST_ID, HOST_NAME, HOST_PATH, HOST_CREATE_DATE, HOST_DB_PREFIX, HOST_LANG, HOST_TYPE, HOST_SHARD_GROUP, HOST_NAME_CUSTOM)
				VALUES(
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#HOST_NAME#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#HOST_PATH#">,
					<cfif HOST_CREATE_DATE EQ ""><cfqueryparam CFSQLType="CF_SQL_DATE" value="#now()#"><cfelse><cfqueryparam CFSQLType="CF_SQL_DATE" value="#HOST_CREATE_DATE#"></cfif>,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#HOST_DB_PREFIX#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#HOST_LANG#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#HOST_TYPE#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#HOST_SHARD_GROUP#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#HOST_NAME#">
				)
				</cfquery>
				<cfcatch type="database">
					<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "hosts"!</span><br>#cfcatch.detail#</p></cfoutput>
				</cfcatch>
			</cftry>
		</cfloop>
		<!--- Modules --->
		<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_mod">
		SELECT MOD_ID, MOD_NAME, MOD_SHORT, MOD_HOST_ID
		FROM modules
		WHERE MOD_HOST_ID = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		</cfquery>
		<cfif qry_mod.recordcount NEQ 0>
			<cfloop query="qry_mod">
				<cftry>
					<cfquery datasource="#arguments.thestruct.db_local#">
					INSERT INTO modules
					(MOD_ID, MOD_NAME, MOD_SHORT, MOD_HOST_ID)
					VALUES
					(
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#mod_id#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#MOD_NAME#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#MOD_SHORT#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#MOD_HOST_ID#">
					)
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "modules"!</span><br>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
		<!--- permissions --->
		<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_perm">
		SELECT PER_ID, PER_KEY, PER_HOST_ID, PER_ACTIVE, PER_MOD_ID, PER_LEVEL
		FROM permissions
		WHERE PER_HOST_ID = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		</cfquery>
		<cfif qry_perm.recordcount NEQ 0>
			<cfloop query="qry_perm">
				<cftry>
					<cfquery datasource="#arguments.thestruct.db_local#">
					INSERT INTO permissions
					(PER_ID, PER_KEY, PER_HOST_ID, PER_ACTIVE, PER_MOD_ID, PER_LEVEL)
					VALUES
					(
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#PER_ID#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#PER_KEY#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#PER_HOST_ID#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#PER_ACTIVE#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#PER_MOD_ID#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#PER_LEVEL#">
					)
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "permissions"!</span><br>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
		<!--- groups --->
		<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_grp">
		SELECT grp_id, GRP_NAME, GRP_HOST_ID, GRP_MOD_ID, GRP_TRANSLATION_KEY
		FROM groups
		WHERE GRP_HOST_ID = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		</cfquery>
		<cfif qry_grp.recordcount NEQ 0>
			<cfloop query="qry_grp">
				<cftry>
					<cfquery datasource="#arguments.thestruct.db_local#">
					INSERT INTO groups
					(grp_id, GRP_NAME, GRP_HOST_ID, GRP_MOD_ID, GRP_TRANSLATION_KEY)
					VALUES
					(
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#grp_id#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#GRP_NAME#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#GRP_HOST_ID#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#GRP_MOD_ID#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#GRP_TRANSLATION_KEY#">
					)
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "groups"!</span><br>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
		<!--- Users --->
		<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_users">
		SELECT u.user_id, u.USER_LOGIN_NAME, u.USER_EMAIL, u.USER_FIRST_NAME, u.USER_LAST_NAME, u.USER_PASS, u.USER_COMPANY, u.USER_STREET,
		u.USER_STREET_NR, u.USER_STREET_2, u.USER_STREET_NR_2, u.USER_ZIP, u.USER_CITY, u.USER_COUNTRY, u.USER_PHONE, u.USER_PHONE_2,
		u.USER_MOBILE, u.USER_FAX, u.USER_CREATE_DATE, u.USER_CHANGE_DATE, u.USER_ACTIVE, u.USER_IN_ADMIN, u.USER_IN_DAM, u.USER_SALUTATION,
		u.USER_IN_VP, u.SET2_NIRVANIX_NAME, u.SET2_NIRVANIX_PASS
		FROM users u, ct_users_hosts ct
		WHERE ct.CT_U_H_HOST_ID = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		AND u.user_id = ct.CT_U_H_USER_ID
		</cfquery>
		<cfif qry_users.recordcount NEQ 0>
			<cfloop query="qry_users">
				<cftry>
					<cfquery datasource="#arguments.thestruct.db_local#">
					INSERT INTO users
					(
					user_id,
					USER_LOGIN_NAME,
					USER_EMAIL,
					USER_FIRST_NAME,
					USER_LAST_NAME,
					USER_PASS,
					USER_COMPANY,
					USER_STREET,
					USER_STREET_NR,
					USER_STREET_2,
					USER_STREET_NR_2,
					USER_ZIP,
					USER_CITY,
					USER_COUNTRY,
					USER_PHONE,
					USER_PHONE_2,
					USER_MOBILE,
					USER_FAX,
					USER_CREATE_DATE,
					USER_CHANGE_DATE,
					USER_ACTIVE,
					USER_IN_ADMIN,
					USER_IN_DAM,
					USER_SALUTATION,
					USER_IN_VP,
					SET2_NIRVANIX_NAME,
					SET2_NIRVANIX_PASS
					)
					VALUES
					(
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#user_id#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_LOGIN_NAME#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_EMAIL#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_FIRST_NAME#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_LAST_NAME#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_PASS#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_COMPANY#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_STREET#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#USER_STREET_NR#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_STREET_2#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#USER_STREET_NR_2#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#USER_ZIP#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_CITY#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_COUNTRY#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_PHONE#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_PHONE_2#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_MOBILE#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_FAX#">,
					<cfif user_create_date EQ ""><cfqueryparam CFSQLType="CF_SQL_DATE" value="#now()#"><cfelse><cfqueryparam CFSQLType="CF_SQL_DATE" value="#USER_CREATE_DATE#"></cfif>,
					<cfif USER_CHANGE_DATE EQ ""><cfqueryparam CFSQLType="CF_SQL_DATE" value="#now()#"><cfelse><cfqueryparam CFSQLType="CF_SQL_DATE" value="#USER_CHANGE_DATE#"></cfif>,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_ACTIVE#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_IN_ADMIN#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_IN_DAM#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_SALUTATION#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#USER_IN_VP#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#SET2_NIRVANIX_NAME#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#SET2_NIRVANIX_PASS#">
					)
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "users"!</span><br>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
		<!--- ct_users_hosts --->
		<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_users_hosts">
		SELECT CT_U_H_USER_ID, CT_U_H_HOST_ID, rec_uuid
		FROM ct_users_hosts
		WHERE CT_U_H_HOST_ID = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		</cfquery>
		<cfif qry_users_hosts.recordcount NEQ 0>
			<cfloop query="qry_users_hosts">
				<cftry>
					<cfquery datasource="#arguments.thestruct.db_local#">
					INSERT INTO ct_users_hosts
					(CT_U_H_USER_ID, CT_U_H_HOST_ID, rec_uuid)
					VALUES
					(
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#CT_U_H_USER_ID#">,
					<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#CT_U_H_HOST_ID#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#rec_uuid#">
					)
					</cfquery>
					<cfcatch type="database">
						<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "ct_users_hosts"!</span><br>#cfcatch.detail#</p></cfoutput>
					</cfcatch>
				</cftry>
			</cfloop>
		</cfif>
		<!--- ct_groups_users --->
		<cfif qry_users.recordcount NEQ 0>
			<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_groups_users">
			SELECT CT_G_U_GRP_ID, CT_G_U_USER_ID, rec_uuid
			FROM ct_groups_users
			WHERE CT_G_U_USER_ID IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(qry_users.user_id)#" list="Yes">)
			</cfquery>
			<cfif qry_groups_users.recordcount NEQ 0>
				<cfloop query="qry_groups_users">
					<cftry>
						<cfquery datasource="#arguments.thestruct.db_local#">
						INSERT INTO ct_groups_users
						(CT_G_U_GRP_ID, CT_G_U_USER_ID, rec_uuid)
						VALUES
						(
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#CT_G_U_GRP_ID#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#CT_G_U_USER_ID#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#rec_uuid#">
						)
						</cfquery>
						<cfcatch type="database">
							<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "ct_groups_users"!</span><br>#cfcatch.detail#</p></cfoutput>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>
		</cfif>
		<!--- ct_groups_permissions --->
		<cfif qry_grp.recordcount NEQ 0>
			<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_groups_permissions">
			SELECT CT_G_P_PER_ID, CT_G_P_GRP_ID
			FROM ct_groups_permissions
			WHERE CT_G_P_GRP_ID IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(qry_grp.grp_id)#" list="Yes">)
			</cfquery>
			<cfif qry_groups_permissions.recordcount NEQ 0>
				<cfloop query="qry_groups_permissions">
					<cftry>
						<cfquery datasource="#arguments.thestruct.db_local#">
						INSERT INTO ct_groups_permissions
						(CT_G_P_PER_ID, CT_G_P_GRP_ID)
						VALUES
						(
						<cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#CT_G_P_PER_ID#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#CT_G_P_GRP_ID#">
						)
						</cfquery>
						<cfcatch type="database">
							<cfoutput><p><span style="color:red;font-weight:bold;">Error on table "ct_groups_permissions"!</span><br>#cfcatch.detail#</p></cfoutput>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- HOST --->
	<cffunction name="gethost">
		<cfargument name="thestruct" type="struct">
		<!--- Get host table --->
		<cfquery datasource="#arguments.thestruct.db_hosted#" name="qry_host">
		SELECT HOST_ID, HOST_NAME, HOST_PATH, HOST_CREATE_DATE, HOST_DB_PREFIX, HOST_LANG, HOST_TYPE, HOST_SHARD_GROUP, HOST_NAME_CUSTOM
		FROM hosts
		WHERE host_id = <cfqueryparam CFSQLType="CF_SQL_NUMERIC" value="#arguments.thestruct.hostid#">
		</cfquery>
		<!--- Return --->
		<cfreturn qry_host>
	</cffunction>


</cfcomponent>