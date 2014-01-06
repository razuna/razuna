<!--- File is only invoked for ISP settings --->

<cfquery datasource="razuna_default" name="variables.conf" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
select conf_database, conf_datasource, conf_storage
from razuna_config
</cfquery>

<cfquery datasource="#conf.conf_datasource#" name="variables.hosts" cachedwithin="#CreateTimeSpan(0,0,30,0)#">
select host_id, host_shard_group
from hosts
WHERE ( host_shard_group IS NOT NULL OR host_shard_group <cfif conf.conf_database EQ "oracle" OR conf.conf_database EQ "db2"><><cfelse>!=</cfif> '' )
</cfquery>

<cfloop query="variables.hosts">
	<cfset variables.host_shard_group = host_shard_group>
	<cfset variables.host_id = host_id>
	<!--- Create tt for thread --->
	<cfset tt = createUUID("")>
	<!--- Call to index --->
	<cfthread name="#tt#" action="run" intstruct="#variables#" priority="low">
		<cfinvoke component="global.cfc.lucene" method="index_update_api">
			<cfinvokeargument name="assetid" value="0">
	        <cfinvokeargument name="dsn" value="#attributes.intstruct.conf.conf_datasource#">
	        <cfinvokeargument name="thedatabase" value="#attributes.intstruct.conf.conf_database#">
	        <cfinvokeargument name="storage" value="#attributes.intstruct.conf.conf_storage#">
	        <cfinvokeargument name="prefix" value="#attributes.intstruct.host_shard_group#">
	        <cfinvokeargument name="hostid" value="#attributes.intstruct.host_id#">
		</cfinvoke>
	</cfthread>
	<!--- Wait and join thread --->
	<cfthread name="#tt#" action="join" />
</cfloop>
