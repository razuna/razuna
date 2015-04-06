<p>
	Here is an example of using caching with a function call, that will cache the results for 10 seconds
</p>

<pre class="cfml"><nocfml><cffunction name="getTime" region="function" cachedwithin="#CreateTimeSpan(0,0,0,10)#">
	<cfargument name="param1">
	<cfargument name="param2">
	<cfreturn now()>
</cffunction>

<cfloop index="x" from="1" to="25">
	<cfoutput>#getTime()#</cfoutput>
	<cfset sleep(1000)>
	<cfflush>
</cfloop></nocfml></pre>

<p>
For more information on using caching and setup, visit the <a href="./?/caching">Caching</a>
</p>