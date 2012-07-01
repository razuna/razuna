<cfcomponent>

  <cffunction name="onServerStart">
    <cfif fileExists("WEB-INF/cache.cfm")>
      <cfinclude template="cache.cfm" />
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