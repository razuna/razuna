<!--- 
If you want another Cache region then the default one you need to rename this file to cache.cfm 
In order to see the available option and how this works please see 
the instructions at http://wiki.razuna.com/display/ecp/Configure+Caching
 --->
<cfset cacheregionnew(
	region="razcache",
	props=
      { 
      type : 'memcached',
      server : '127.0.0.1:11211',
      waittimeseconds : 5
      }
)>
