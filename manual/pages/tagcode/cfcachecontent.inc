<pre class="cfml">
<!--- Cache the results of myObj.myIntensiveFunction() for 1 hour --->
<cfcachecontent name="mypagecache" cachedwithin="#CreateTimeSpan( 0, 1, 0, 0 )#" >
  <cfoutput>#myObj.myIntensiveFunction()#</cfoutput>
</cfcachecontent>
</pre>