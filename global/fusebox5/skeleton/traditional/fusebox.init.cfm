<!---
	fusebox.init.cfm is included by the framework at the start of every request.
	It is included within a cfsilent tag so it cannot generate output. It is
	intended to be for per-request initialization and manipulation of the
	Fusebox fuseaction variables.
	
	You can set attributes.fuseaction, for example, to override the default
	fuseaction.
	
	A typical usage is to set "self" and "myself" variables, as shown below,
	for use inside display fuses when creating links.

	Fusebox 5 and earlier - set variables explicitly:
	<cfset self = "index.cfm" />
	<cfset myself = "#self#?#myFusebox.getApplication().fuseactionVariable#=" />
	
	Fusebox 5.1 and later - set variables implicitly from the Fusebox itself.
	
	Could also modify the self location here:
	<cfset myFusebox.setSelf("/myapp/start.cfm") />
--->
<cfset self = myFusebox.getSelf() />
<cfset myself = myFusebox.getMyself() />
