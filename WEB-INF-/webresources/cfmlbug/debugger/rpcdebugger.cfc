<cfcomponent output="false">


<cffunction name="setBreakPoint" returntype="any" access="remote" returnformat="json">
	<cfargument name="file" required="true" />
	<cfargument name="lineno" required="true" />

	<cfreturn DebuggerSetBreakPoint( arguments.file, arguments.lineno )>
</cffunction>



<cffunction name="clearBreakPoint" returntype="any" access="remote" returnformat="json">
	<cfargument name="file" required="true" />
	<cfargument name="lineno" required="true" />

	<cfreturn DebuggerClearBreakPoint( arguments.file, arguments.lineno )>
</cffunction>



<cffunction name="clearAllBreakPoint" returntype="any" access="remote" returnformat="json">
	<cfreturn DebuggerClearAllBreakpoints()>
</cffunction>




<cffunction name="stepToEnd" returntype="any" access="remote" returnformat="json">
	<cfargument name="sessionid" required="true" />
	<cfreturn DebuggerStepToEnd( arguments.sessionid )>
</cffunction>


<cffunction name="stepToBreakPoint" returntype="any" access="remote" returnformat="json">
	<cfargument name="sessionid" required="true" />
	<cfreturn DebuggerStepToBreakPoint( arguments.sessionid )>
</cffunction>


<cffunction name="step" returntype="any" access="remote" returnformat="json">
	<cfargument name="sessionid" required="true" />
	<cfreturn DebuggerStep( arguments.sessionid )>
</cffunction>


<cffunction name="stepOver" returntype="any" access="remote" returnformat="json">
	<cfargument name="sessionid" required="true" />
	<cfreturn DebuggerStepOver( arguments.sessionid )>
</cffunction>



</cfcomponent>