<!--- File is only invoked for ISP settings --->

<cfquery datasource="razuna_default" name="conf" cachedwithin="#CreateTimeSpan(0,3,0,0)#">
select conf_database, conf_datasource, conf_storage
from razuna_config
</cfquery>

<cfquery datasource="#conf.conf_datasource#" name="hosts" cachedwithin="#CreateTimeSpan(0,0,30,0)#">
select host_id, host_shard_group
from hosts
WHERE ( host_shard_group IS NOT NULL OR host_shard_group <cfif conf.conf_database EQ "oracle" OR conf.conf_database EQ "db2"><><cfelse>!=</cfif> '' )
</cfquery>

<cfloop query="hosts">
	<cftry>
		<!--- Get the collection --->
		<cfset CollectionStatus(host_id)>
		<!--- Collection does NOT exists, thus create it --->
		<cfcatch>
	    	<!--- Delete collection --->
	    	<cftry>
	    		<cfset CollectionDelete(host_id)>
	    		<cfcatch type="any">
	    		</cfcatch>
	    	</cftry>
	    	<!--- Delete path on disk --->
	    	<cftry>
	    		<cfdirectory action="delete" directory="#expandpath('../')#/WEB-INF/collections/#host_id#" recurse="true" />
	    		<cfcatch type="any">
	    		</cfcatch>
	    	</cftry>
	    	<!--- Create collection --->
	    	<cftry>
	    		<cfset CollectionCreate(collection=host_id,relative=true,path="/WEB-INF/collections/#host_id#")>
	    		<cfcatch type="any">
	    		</cfcatch>
	    	</cftry>
		</cfcatch>
	</cftry>
	<!--- Call to index --->
	<cfinvoke component="global.cfc.lucene" method="index_update_api">
		<cfinvokeargument name="assetid" value="0">
        <cfinvokeargument name="dsn" value="#conf.conf_datasource#">
        <cfinvokeargument name="thedatabase" value="#conf.conf_database#">
        <cfinvokeargument name="storage" value="#conf.conf_storage#">
        <cfinvokeargument name="prefix" value="#host_shard_group#">
        <cfinvokeargument name="hostid" value="#host_id#">
	</cfinvoke>
	<!--- Sleep (important if you have 4000 indexes!) --->
	<cfset sleep(2000)>
</cfloop>
