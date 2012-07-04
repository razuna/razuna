<cfcomponent>

  <cffunction name="onServerStart">
    <cfif fileExists("#expandpath(".")#/global/config/cache.cfm")>
      <cfinclude template="/global/config/cache.cfm" />
    <cfelse>
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
    </cfif>
  </cffunction>

</cfcomponent>