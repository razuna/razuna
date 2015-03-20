<cfcomponent>

  <cffunction name="onServerStart">
    <cfset consoleoutput(true)>
    <cfset console("------------SERVER STARTUP------------------")>
    <!--- Delete any .lock file --->
    <cftry>
      <cfset console("---START: Lock file cleanup---")>
      <cfdirectory action="list" directory="#GetTempdirectory()#" listinfo="name" filter="*.lock" name="l">
      <cfif l.recordcount NEQ 0>
        <cfloop query="l">
          <cfset filedelete(GetTempdirectory() & name)>
        </cfloop>
        <cfset consoleoutput(true)>
        <cfset console("All .lock files have been deleted")>
      <cfelse>
        <cfset consoleoutput(true)>
        <cfset console("No .lock file to remove")>
      </cfif>
      <cfset console("---DONE: Lock file cleanup---")>
      <cfcatch type="any">
        <cfset consoleoutput(true)>
        <cfset console("Lock removal error #cfcatch#")>
      </cfcatch>
    </cftry>

    <cfset console("---START: Cache Setup---")>
    <!--- Create the cache --->
    <cfset cacheregionnew(
      region="razcache",
      props=
      {
        type : 'memorydisk'
      }
    )>

    <!--- READ the documentation at http://wiki.razuna.com/display/ecp/Configure+Caching !!! --->

    <!--- Memcached / CouchBase --->
    <!--- 
    <cfset cacheregionnew(
    region="razcache",
    props=
        {
        type : 'memcached',
        server : '127.0.0.1:11211',
        waittimeseconds : 5
        }
    )>
    --->
    
    <!--- MongoDB --->
    <!--- 
    <cfset cacheregionnew(
    region="razcache",
    props=
        {
      type : 'mongo',
      server : '10.0.0.1:27017 10.0.0.2:27017',
      db : 'razcache',
      collection : 'nameofregion',
      user : 'username',
      password : 'password'
      }
    )>
    --->
     <cfset console("---DONE: Cache Setup---")>
     <cfset console("---------------FINISHED---------------------")>

  </cffunction>

</cfcomponent>