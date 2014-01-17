<!--- File is only invoked for ISP settings --->

<!--- Name of lock file --->
<cfset lockfile = "lucene.lock">
<!--- Check if lucene.lock file exists and a) If it is older than a day then delete it or b) if not older than a day them abort as its probably running from a previous call --->
<cfset lockfilepath = "#GetTempDirectory()#/#lockfile#">
<cfset lockfiledelerr = false>
<cfif fileExists(lockfilepath) >
	<cfset lockfiledate = getfileinfo(lockfilepath).lastmodified>
	<cfif datediff("h", lockfiledate, now()) GT 24>
		<cftry>
			<cffile action="delete" file="#lockfilepath#">
			<cfcatch><cfset lockfiledelerr = true></cfcatch> <!--- Catch any errors on file deletion --->
		</cftry>
	<cfelse>
		<cfabort>	
	</cfif>
</cfif>
<cfif lockfiledelerr> <!--- If error on lock file deletion then abort as file is probably still being used for indexing --->
	<cfabort>
</cfif>
<cffile action="write" file="#GetTempDirectory()#/#lockfile#" output="x" mode="775" />
<!--- Query config --->
<cfquery datasource="razuna_default" name="variables.conf" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
select conf_database, conf_datasource, conf_storage
from razuna_config
</cfquery>
<!--- Query hosts --->
<cfquery datasource="#conf.conf_datasource#" name="variables.hosts" cachedwithin="#CreateTimeSpan(0,0,30,0)#">
select host_id, host_shard_group
from hosts
WHERE ( host_shard_group IS NOT NULL OR host_shard_group <cfif conf.conf_database EQ "oracle" OR conf.conf_database EQ "db2"><><cfelse>!=</cfif> '' )
</cfquery>
<!--- Loop over hosts --->
<cfloop query="variables.hosts">
    <!--- Call to index --->
    <cfinvoke component="global.cfc.lucene" method="index_update_api">
        <cfinvokeargument name="assetid" value="0">
        <cfinvokeargument name="dsn" value="#variables.conf.conf_datasource#">
        <cfinvokeargument name="thedatabase" value="#variables.conf.conf_database#">
        <cfinvokeargument name="storage" value="#variables.conf.conf_storage#">
        <cfinvokeargument name="prefix" value="#host_shard_group#">
        <cfinvokeargument name="hostid" value="#host_id#">
        <cfinvokeargument name="hosted" value="true">
    </cfinvoke>
</cfloop>
<!--- Remove lock file --->
<cftry>
	<cffile action="delete" file="#GetTempDirectory()#/#lockfile#" />
	<cfcatch type="any">
		<cfset console("--- ERROR removing lock file: #cfthread.message# - #cfthread.detail# - #now()# ---")>
	</cfcatch>
</cftry>
