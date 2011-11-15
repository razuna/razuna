<!---
	I just display my own parameter and custom attribute:
	- myFusebox.plugins[myFusebox.thisPlugin] is a request-local struct for this plugin
	  to access parameters and store variables, to communicate across multiple phases
	- myFusebox.getApplications().plugins[myFusebox.thisPlugin][myFusebox.thisPhase] is
	  the global fuseboxPlugin definition object
--->
<cfoutput><p>In example_plugin, parameter def = #myFusebox.plugins[myFusebox.thisPlugin].parameters.def#,
	custom attribute test:abc = #myFusebox.getApplication().plugins[myFusebox.thisPlugin][myFusebox.thisPhase].getCustomAttributes('test').abc#.</p></cfoutput>
