<!---
	sample index.cfm if you use Application.cfm
	this should be empty if you use Application.cfc
--->

<!--- set application name based on the directory path --->
<cfapplication name="#right(REReplace(expandPath('.'),'[^A-Za-z]','','all'),64)#" />

<!--- enable debugging --->
<cfset FUSEBOX_PARAMETERS.debug = true />

<!--- include the core file runtime --->
<cfinclude template="/fusebox5/fusebox5.cfm" />
