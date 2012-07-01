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
    <!--- <cfset cacheregionnew(
      region="razcache",
      props=
      { 
      type : 'memcached',
      server : '127.0.0.1:11211',
      waittimeseconds : 5
      }
    )> --->
  </cffunction>

</cfcomponent>