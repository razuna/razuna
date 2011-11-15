<!---
	fusebox.appinit.cfm is included by the framework when the application is
	started, i.e., on the very first request (in production mode) or whenever
	the framework is reloaded, either with development-full-load mode or when
	fusebox.load=true or fusebox.loadclean=true is specified.
	It is included within a cfsilent tag so it cannot generate output. It is
	intended to be for per-application initialization that can not easily be
	done in the appinit global fuseaction.
	It is included inside a conditional lock, ensuring that only one request
	can execute this file.
	
	For example, if you are sharing application variables between a Fusebox
	application and a non-Fusebox application, you can initialize them here
	and then cfinclude this file into your non-Fusebox application.
--->
