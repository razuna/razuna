<!--- <cfabort> --->

<!--- From dedicated server to hosted --->

<!--- Set the locl db and host id --->

<cfset thedb = "mysql">
<cfset thehostid = "3927">


<!--- Set remote DB --->
<cfset remotedb = "razuna_hosted">
<!--- List of tables that need to be fetched and value to be transfered --->
<cfset fetch_tables = "raz1_additional_versions,raz1_comments,raz1_custom_fields,raz1_custom_fields_text,raz1_custom_fields_values,raz1_files,raz1_files_desc,raz1_files_xmp,raz1_folders,raz1_folders_desc,raz1_folders_groups,raz1_images,raz1_images_text,raz1_labels,raz1_share_options,raz1_users_favorites,raz1_versions,raz1_videos,raz1_videos_text,raz1_xmp">
<!--- Params --->
<cfset thecollist = "">

<!--- MySQL: Drop all constraints --->
<cfquery datasource="#thedb#">
SET FOREIGN_KEY_CHECKS = 0
</cfquery>
<cfquery datasource="#remotedb#">
SET FOREIGN_KEY_CHECKS = 0
</cfquery>

<!--- Move data to hosted --->
<cfloop list="#fetch_tables#" index="table">
	<cfflush>
	<cfoutput>Delete records from #table# <br /></cfoutput>
	<!--- Select from local table --->
	<cfquery datasource="#remotedb#">
	DELETE FROM #table#
	WHERE host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#thehostid#">
	</cfquery>
	<cfflush>
	<cfoutput>Select from #table# <br /></cfoutput>
	<!--- Select from local table --->
	<cfquery datasource="#thedb#" name="qry">
	SELECT * FROM #table#
	WHERE host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#thehostid#">
	</cfquery>
	<!--- Get Columns --->
	<cfquery datasource="#thedb#" name="qry_columns">
	SELECT column_name, data_type
	FROM information_schema.columns
	WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(table)#">
	AND lower(table_schema) = <cfqueryparam cfsqltype="cf_sql_varchar" value="razuna">
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
	<cfflush>
	<cfoutput>Starting to loop over #qry.recordcount# records from #table# <br /></cfoutput>
	<!--- Loop over resultset --->
	<cfloop query="qry">
		<cftry>
			<cfflush>
			<cfoutput>.</cfoutput>
			<!--- <cfoutput><cfloop list="#qry.columnlist#" index="m">#listfirst(m,"-")#<cfif len_count_meta NEQ len_meta>, </cfif><cfset len_count_meta = len_count_meta + 1></cfloop></cfoutput> --->
			<cfquery dataSource="#remotedb#">
			INSERT INTO #lcase(table)#
			(<cfloop list="#qry.columnlist#" index="m">#listfirst(m,"-")#<cfif len_count_meta NEQ len_meta>, </cfif><cfset len_count_meta = len_count_meta + 1></cfloop>)
			VALUES(
				<cfloop list="#qry.columnlist#" index="cl">
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
							NULL
						<cfelse>
							<cfqueryparam CFSQLType="CF_SQL_DATE" value="#evaluate(cl)#">
						</cfif>
					<cfelseif trim(listlast(lg,"-")) EQ "timestamp" OR trim(listlast(lg,"-")) EQ "datetime">
						<cfif evaluate(cl) EQ "">
							NULL
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
			<cfcatch type="database">
				<cfoutput><p><span style="color:red;font-weight:bold;">Error during import on table #table#!</span><br>#cfcatch.detail#<br>#cfcatch.sql#</p> <br /></cfoutput>
				<!--- Reset loop variables --->
				<cfset len_count_meta = 1>
				<cfset len_count_meta2 = 1>
			</cfcatch>
		</cftry>
	</cfloop>
	<!--- Reset collist --->
	<cfset thecollist = "">
	<cfflush>
	<cfoutput><br>Done with #table# <br /><br /></cfoutput>

</cfloop>

<!--- LABELS --->


<!--- USERS --->

<!--- Select from cross table --->
<!--- <cfquery datasource="#thedb#" name="qry_users">
SELECT u.*
FROM ct_users_hosts ct, users u
WHERE ct_u_h_host_id = <cfqueryparam CFSQLType="cf_sql_numeric" value="#thehostid#">
AND ct.ct_u_h_user_id = u.user_id
</cfquery>
<!--- Then insert found records --->
<cfloop query="qry">
	<cftry>
		<cfflush>
		<cfoutput>.</cfoutput>

		<cfcatch type="database">
			<cfoutput><p><span style="color:red;font-weight:bold;">Error during import on table users!</span><br>#cfcatch.detail#<br>#cfcatch.sql#</p> <br /></cfoutput>
			<!--- Reset loop variables --->
			<cfset len_count_meta = 1>
			<cfset len_count_meta2 = 1>
		</cfcatch>
	</cftry>
</cfloop> --->
<!--- Grab ct_user_hosts records also --->

<!--- Insert found ones --->


<!--- MySQL: Drop all constraints --->
<cfquery datasource="#thedb#">
SET FOREIGN_KEY_CHECKS = 1
</cfquery>
<cfquery datasource="#remotedb#">
SET FOREIGN_KEY_CHECKS = 1
</cfquery>


<cfflush>
<cfoutput><h1>ALL DONE</h1></cfoutput>
