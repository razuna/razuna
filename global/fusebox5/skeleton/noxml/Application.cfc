<cfcomponent extends="fusebox5.Application" output="false">
	<!---
		sample Application.cfc for ColdFusion MX 7 and later compatible systems
	--->
	
	<!--- set application name based on the directory path --->
	<cfset this.name = right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'),64) />
	
	<cfscript>
		// must enable implicit (no-XML) mode!
		FUSEBOX_PARAMETERS.allowImplicitFusebox = true;

		// the rest is taken straight from the traditional fusebox.xml skeleton:
		FUSEBOX_PARAMETERS.defaultFuseaction = "app.welcome";
		// you may want to change this to development-full-load mode:
		FUSEBOX_PARAMETERS.mode = "development-circuit-load";
		FUSEBOX_PARAMETERS.conditionalParse = true;
		// change this to something more secure:
		FUSEBOX_PARAMETERS.password = "skeleton";
		FUSEBOX_PARAMETERS.strictMode = true;
		FUSEBOX_PARAMETERS.debug = true;
		// we use the core file error templates:
		FUSEBOX_PARAMETERS.errortemplatesPath = "/fusebox5/errortemplates/";
		
		// These are all default values that can be overridden:
		// FUSEBOX_PARAMETERS.fuseactionVariable = "fuseaction";
		// FUSEBOX_PARAMETERS.precedenceFormOrUrl = "form";
		// FUSEBOX_PARAMETERS.scriptFileDelimiter = "cfm";
		// FUSEBOX_PARAMETERS.maskedFileDelimiters = "htm,cfm,cfml,php,php4,asp,aspx";
		// FUSEBOX_PARAMETERS.characterEncoding = "utf-8";
		// FUSEBOX_PARAMETERS.strictMode = false;
		// FUSEBOX_PARAMETERS.allowImplicitCircuits = false;

		// force the directory in which we start to ensure CFC initialization works:
		FUSEBOX_CALLER_PATH = getDirectoryFromPath(getCurrentTemplatePath());
	</cfscript>
	
	<!---
		if you define any onXxxYyy() handler methods, remember to start by calling
			super.onXxxYyy(argumentCollection=arguments)
		so that Fusebox's own methods are executed before yours
	--->
	
	<cffunction name="onFuseboxApplicationStart">
	
		<cfset super.onFuseboxApplicationStart() />

		<!--- code formerly in fusebox.appinit.cfm or the appinit global fuseaction --->
		<cfset myFusebox.getApplicationData().startTime = now() />
		
	</cffunction>
	
	<cffunction name="onRequestStart">
		<cfargument name="targetPage" />
	
		<cfset super.onRequestStart(arguments.targetPage) />

		<!--- formerly in fusebox.init.cfm --->
		<cfset self = myFusebox.getSelf() />
		<cfset myself = myFusebox.getMyself() />
		
	</cffunction>
	
</cfcomponent>