<cfcomponent output="false">
	
	<cffunction name="postfuseaction">
		<cfargument name="myFusebox" />
		<cfargument name="event" />
		
		<!--- do the layout --->
		<cfset myFusebox.do( action="layout.lay_template" ) />
	
	</cffunction>

	<cffunction name="welcome">
		<cfargument name="myFusebox" />
		<cfargument name="event" />
		
		<!--- do model fuse --->
		<cfset myFusebox.do( action="time.act_get_time" ) />
		
		<!--- do display fuse and set content variable body --->
		<cfset myFusebox.do( action="display.dsp_hello", contentvariable="body" ) />
		
	</cffunction>

</cfcomponent>