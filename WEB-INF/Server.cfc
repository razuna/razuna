<cfcomponent>

  <cffunction name="onServerStart">
    <!--- Create the cache --->
    <cfset cacheregionnew(
      region="razcache",
      props=
      {
      type : 'memorydisk',
      diskpersistent : true,
      diskmaxsizemb : 500
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

  </cffunction>

</cfcomponent>