<cfcomponent>

  <cffunction name="onServerStart">
    <!--- Create the cache --->
    <cfset cacheregionnew(
    	props=
    	{
		  type : 'memorydisk',
		  diskpersistent : true,
		  diskmaxsizemb : 500
		}
    )>
  </cffunction>

</cfcomponent>