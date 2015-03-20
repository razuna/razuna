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
    <cfset console("---------------FINISHED---------------------")>

  </cffunction>

</cfcomponent>