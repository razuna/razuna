<cftry>

	<cfset consoleoutput(true)>
	<cfset console("#now()# ---------------- Starting to clean up incoming and outgoing directories")>

	<!--- Path --->
	<cfset _path = expandPath("../..")>
	<!--- Set time for remove --->
	<cfset _removetime_incoming = DateAdd("h", -2, now())>
	<cfset _removetime_outgoing = DateAdd("d", -4, now())>

	<!--- Get database --->
	<cfquery datasource="razuna_default" name="_config">
	SELECT conf_datasource
	FROM razuna_config
	</cfquery>
	<!--- Set DB --->
	<cfset _db = _config.conf_datasource>

	<!--- Get all the hosts --->
	<cfquery datasource="#_db#" name="_qry_hosts">
	SELECT host_shard_group
	FROM hosts
	GROUP BY host_shard_group
	</cfquery>

	<!--- Loop over hosts and dirs --->
	<cfloop query="_qry_hosts">
		<!--- Remove the "_" from the host --->
		<cfset _host = replacenocase(host_shard_group, "_", "", "ALL")>
		<cfset _full_path_incoming = "#_path##_host#/dam/incoming">
		<cfset _full_path_outgoing = "#_path##_host#/dam/outgoing">
		<!--- Get incoming --->
		<cfdirectory action="list" directory="#_full_path_incoming#" name="_qry_incoming">
		<!--- Get outgoing --->
		<cfdirectory action="list" directory="#_full_path_outgoing#" name="_qry_outgoing">
		<!--- Remove incoming dirs --->
		<cfloop query="_qry_incoming">
			<cfif directoryexists("#_full_path_incoming#/#name#")>
				<cfif type EQ "dir" AND datelastmodified LT _removetime_incoming>
					<cfset console("#now()# ---------------- Removing incoming: #_full_path_incoming#/#name#")>
					<cfdirectory action="delete" directory="#_full_path_incoming#/#name#" recurse="true" mode="775">
				</cfif>
				<cfif type EQ "file" AND datelastmodified LT _removetime_incoming>
					<cfset console("#now()# ---------------- Removing incoming: #_full_path_incoming#/#name#")>
					<cffile action="delete" file="#_full_path_incoming#/#name#" />
				</cfif>
			</cfif>
		</cfloop>
		<!--- Remove outgoing dirs and files --->
		<cfloop query="_qry_outgoing">
			<cfif directoryexists("#_full_path_outgoing#/#name#")>
				<cfif type EQ "dir" AND datelastmodified LT _removetime_outgoing>
					<cfset console("#now()# ---------------- Removing outgoing: #_full_path_outgoing#/#name#")>
					<cfdirectory action="delete" directory="#_full_path_outgoing#/#name#" recurse="true" mode="775">
				</cfif>
				<cfif type EQ "file" AND datelastmodified LT _removetime_outgoing>
					<cfset console("#now()# ---------------- Removing outgoing: #_full_path_outgoing#/#name#")>
					<cffile action="delete" file="#_full_path_outgoing#/#name#" />
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>

	<cfset console("#now()# ---------------- Finished clean up job!")>

	<cfcatch type="any">
		<cfset console("#now()# ---------------- Error on clean up cron job")>
		<cfset console(cfcatch)>
	</cfcatch>
</cftry>
