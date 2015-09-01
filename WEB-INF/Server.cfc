<cfcomponent>

  <cffunction name="onServerStart">
    <cfset consoleoutput(true)>
    <cfset console("------------SERVER STARTUP------------------")>
    
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

    <cftry>
      <cfset console("------------ENABLING CRON------------------")>
      <cfset cronEnable(true) />
      <cfcatch type="any">
        <cfset consoleoutput(true)>
        <cfset console("------------ Cron error !!!!!!!!!!!!!!!!!!!!!!!!!")>
        <cfset console(cfcatch)>
      </cfcatch>
    </cftry>
    <cftry>
      <cfset console("------------ENABLING CRON DIRECTORY------------------")>
       <cfset CronSetDirectory("/cron") />
      <cfcatch type="any">
        <cfset consoleoutput(true)>
        <cfset console("------------ Cron error !!!!!!!!!!!!!!!!!!!!!!!!!")>
        <cfset console(cfcatch)>
      </cfcatch>
    </cftry>

    <cfset console("---------------FINISHED---------------------")>

  </cffunction>

</cfcomponent>