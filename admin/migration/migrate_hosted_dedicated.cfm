<cfabort>

<!---  --->
<!--- VARIABLES --->
<!---  --->

<!--- DB --->

<!--- Set the local and hosted db connections --->
<cfset localdb = "">
<!--- Set hosted DB --->
<cfset hosteddb = "">

<!--- HOSTID --->

<!--- The hosted id --->
<cfset hostedid = "">
<!--- The local hostid --->
<cfset localid = "">

<!---  --->
<!--- VARIABLES DONE --->
<!--- NOTHING ELSE TO DO FROM HERE ON --->
<!---  --->










<!--- --------------------------------------------------------------------------------------- --->
<!--- INTERNAL STUFF --->
<!--- --------------------------------------------------------------------------------------- --->

<!--- DODO: ct_groups_users !!! --->

<!--- List of tables that need to be fetched and value to be transfered --->
<cfset fetch_tables = "raz1_additional_versions,raz1_comments,raz1_custom_fields,raz1_custom_fields_text,raz1_custom_fields_values,raz1_files,raz1_files_desc,raz1_files_xmp,raz1_folders,raz1_folders_desc,raz1_folders_groups,raz1_images,raz1_images_text,raz1_labels,raz1_share_options,raz1_users_favorites,raz1_versions,raz1_videos,raz1_videos_text,raz1_xmp">

<!--- Select from hostd and insert into local --->

<!--- MySQL: Drop all constraints --->
<cfquery datasource="#localdb#">
SET FOREIGN_KEY_CHECKS = 0
</cfquery>

<cfloop list="#fetch_tables#" index="table">
	<!--- MySQL: Drop all constraints --->
	<cfquery datasource="#localdb#">
	SET FOREIGN_KEY_CHECKS = 0
	</cfquery>
	<cfflush>
	<cfoutput><br />Delete #table# <br /></cfoutput>
	<!--- delete from local table --->
	<cfquery datasource="#localdb#">
	DELETE FROM #table#
	WHERE host_id = #localid#
	OR host_id = #hostedid#
	</cfquery>
	<cfflush>
	<cfoutput>Select from #table# <br /></cfoutput>
	<!--- Select from local table --->
	<cfquery datasource="#hosteddb#" name="qry">
	SELECT * FROM #table#
	WHERE host_id = #hostedid#
	</cfquery>
	<!--- Loop over resultset --->
	<cfset insert_into_table(qry,table,localdb,hosteddb)>
	<!--- Update hostid --->
	<cftry>
		<cfflush>
		<cfoutput>Updating hostid #table#<br/><br /></cfoutput>
		<cfquery datasource="#localdb#">
		UPDATE #table#
		SET host_id = #localid#
		WHERE host_id = #hostedid#
		</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch.detail#">
		</cfcatch>
	</cftry>
</cfloop>

<cfflush>
<cfoutput>Done with Standard tables. Doing now the custom ones...<br /><br /></cfoutput>

<!--- Groups --->

<cfset table = "groups">
<cfflush>
<cfoutput>Groups<br /></cfoutput>
<cfflush>
<cfoutput>Delete #table# <br /></cfoutput>
<!--- delete from local table --->
<cfquery datasource="#localdb#">
DELETE FROM #table#
WHERE grp_host_id = #localid#
OR grp_host_id = #hostedid#
</cfquery>
<cfflush>
<cfoutput>Select from #table# <br /></cfoutput>
<!--- Select from local table --->
<cfquery datasource="#hosteddb#" name="qry">
SELECT * FROM #table#
WHERE grp_host_id = #hostedid#
</cfquery>
<!--- Loop over resultset --->
<cfset insert_into_table(qry,table,localdb,hosteddb)>
<cfflush>
<cfoutput>Update host id for #table# <br /></cfoutput>
<cfquery datasource="#localdb#">
UPDATE #table#
SET grp_host_id = #localid#
WHERE grp_host_id = #hostedid#
</cfquery>

<cfset table = "ct_labels">
<cfflush>
<cfoutput>#table#<br /></cfoutput>
<cfflush>
<cfoutput>Select labels <br /></cfoutput>
<cfquery datasource="#hosteddb#" name="qry">
SELECT ct.ct_label_id, ct.ct_id_r, ct.ct_type, ct.rec_uuid
FROM raz1_labels l LEFT JOIN ct_labels ct ON l.label_id = ct.ct_label_id
WHERE host_id = #hostedid# 
</cfquery>
<cfflush>
<cfoutput>Delete #table# <br /></cfoutput>
<!--- Loop over label_id qry --->
<cfloop query="qry">
	<!--- delete from local table --->
	<cfquery datasource="#localdb#">
	DELETE FROM #table#
	WHERE ct_label_id = "#ct_label_id#"
	</cfquery>
</cfloop>
<!--- Loop over resultset --->
<cfset insert_into_table(qry,table,localdb,hosteddb)>

<!--- USERS --->

<cfset table = "ct_users_hosts">
<cfflush>
<cfoutput>ct_users_hosts<br /></cfoutput>
<cfflush>
<cfoutput>Delete #table# <br /></cfoutput>
<!--- delete from local table --->
<cfquery datasource="#localdb#">
DELETE FROM #table#
WHERE ct_u_h_host_id = #localid#
OR ct_u_h_host_id = #hostedid#
</cfquery>
<cfflush>
<cfoutput>Select from #table# <br /></cfoutput>
<!--- Select from local table --->
<cfquery datasource="#hosteddb#" name="qry">
SELECT * FROM #table#
WHERE ct_u_h_host_id = #hostedid#
</cfquery>
<!--- Loop over resultset --->
<cfset insert_into_table(qry,table,localdb,hosteddb)>
<cfflush>
<cfoutput>Update host id for #table# <br /></cfoutput>
<cfquery datasource="#localdb#">
UPDATE #table#
SET ct_u_h_host_id = #localid#
WHERE ct_u_h_host_id = #hostedid#
</cfquery>

<cfset table = "users">
<cfflush>
<cfoutput>#table#<br /></cfoutput>
<cfflush>
<cfoutput>Select users <br /></cfoutput>
<cfquery datasource="#hosteddb#" name="qry">
SELECT u.*
FROM users u LEFT JOIN ct_users_hosts ct ON u.user_id = ct.ct_u_h_user_id
WHERE ct.ct_u_h_host_id = #hostedid# 
</cfquery>
<cfflush>
<cfoutput>Delete #table# <br /></cfoutput>
<!--- Loop over label_id qry --->
<cfloop query="qry">
	<!--- delete from local table --->
	<cfquery datasource="#localdb#">
	DELETE FROM #table#
	WHERE user_id = "#user_id#"
	</cfquery>
</cfloop>
<!--- Loop over resultset --->
<cfset insert_into_table(qry,table,localdb,hosteddb)>

<cfflush>
<cfoutput><br/><br/><strong>WE ARE DONE!!!</strong><br /></cfoutput>

<!--- FUNCTION TO INSERT DATA --->
<cffunction name="insert_into_table">
	<cfargument name="qry" required="yes" type="query">
	<cfargument name="table" required="yes" type="string">
	<cfargument name="localdb" required="yes" type="string">
	<cfargument name="hosteddb" required="yes" type="string">
	<!--- Params --->
	<cfset var thecollist = "">
	<!--- Get Columns --->			
	<cfquery datasource="#arguments.hosteddb#" name="qry_columns">
	SELECT column_name, data_type
	FROM information_schema.columns
	WHERE lower(table_name) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.table)#">
	AND lower(table_schema) = <cfqueryparam cfsqltype="cf_sql_varchar" value="razuna">
	ORDER BY column_name, data_type
	</cfquery>
	<!--- Create our custom list --->
	<cfloop query="qry_columns">
		<cfset thecollist = thecollist & column_name & "-" & data_type & ",">
	</cfloop>
	<!--- Remove the last comma --->
	<cfset var l = len(thecollist)>
	<cfset var thecollist = mid(thecollist,1,l-1)>
	<!--- Set variables for the query loop below --->
	<cfset var len_meta = listlen(thecollist)>
	<cfset var len_count_meta = 1>
	<cfset var len_count_meta2 = 1>
	<cfflush>
	<cfoutput>Starting to loop over #qry.recordcount# records from #arguments.table# <br /></cfoutput>
	<!--- Loop over qry --->
	<cfloop query="arguments.qry">
		<cftry>
			<!--- Output --->
			<cfflush>
			<cfoutput>.</cfoutput>
			<!--- MySQL: Drop all constraints --->
			<cfquery datasource="#arguments.localdb#">
			SET FOREIGN_KEY_CHECKS = 0
			</cfquery>
			<!--- Insert --->
			<cfquery dataSource="#arguments.localdb#">
			INSERT INTO #lcase(arguments.table)#
			(<cfloop list="#arguments.qry.columnlist#" index="m">#listfirst(m,"-")#<cfif len_count_meta NEQ len_meta>, </cfif><cfset len_count_meta = len_count_meta + 1></cfloop>)
			VALUES(
				<cfloop list="#arguments.qry.columnlist#" index="cl">
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
				<cfoutput><p><span style="color:red;font-weight:bold;">Error during import on table #arguments.table#!</span><br>#cfcatch.detail#<br>#cfcatch.sql#</p> <br /></cfoutput>
				<!--- Reset loop variables --->
				<cfset len_count_meta = 1>
				<cfset len_count_meta2 = 1>
			</cfcatch>
		</cftry>
	</cfloop>
	<!--- Reset collist --->
	<cfset thecollist = "">
	<cfflush>
	<cfoutput><br />Done with #arguments.table# <br /></cfoutput>
</cffunction>
