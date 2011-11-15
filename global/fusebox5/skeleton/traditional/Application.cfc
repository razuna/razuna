<cfcomponent extends="fusebox5.Application" output="false">
	<!---
		sample Application.cfc for ColdFusion MX 7 and later compatible systems
	--->
		
	<!--- set application name based on the directory path --->
	<cfset this.name = right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'),64) />
	
	<!--- enable debugging --->
	<cfset FUSEBOX_PARAMETERS.debug = true />
	
	<!--- force the directory in which we start to ensure CFC initialization works: --->
	<cfset FUSEBOX_CALLER_PATH = getDirectoryFromPath(getCurrentTemplatePath()) />

	<!---
		if you define any onXxxYyy() handler methods, remember to start by calling
			super.onXxxYyy(argumentCollection=arguments)
		so that Fusebox's own methods are executed before yours
	--->

</cfcomponent>