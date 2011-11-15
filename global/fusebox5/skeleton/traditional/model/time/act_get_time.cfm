<cfset timeNow = now() />
<cfset startTime = myFusebox.getApplicationData().startTime />
<cfif dateDiff("d",startTime,timeNow) gt 0>
	<cfset runTime = dateDiff("d",startTime,timeNow) & " day(s)" />
<cfelseif dateDiff("h",startTime,timeNow) gt 0>
	<cfset runTime = dateDiff("h",startTime,timeNow) & " hour(s)" />
<cfelseif dateDiff("n",startTime,timeNow) gt 0>
	<cfset runTime = dateDiff("n",startTime,timeNow) & " minute(s)" />
<cfelseif dateDiff("s",startTime,timeNow) gt 0>
	<cfset runTime = dateDiff("s",startTime,timeNow) & " seconds(s)" />
<cfelse>
	<cfset runTime = "less than a second" />
</cfif>
