<cfscript>
	// usage:
	//		<reactor:populate bean="thisTask" />
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// bean - string
		if (not structKeyExists(fb_.verbInfo.attributes,"bean")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'bean' is required, for a 'populate' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		
		// generate code:
		fb_appendLine('<cfset #fb_.verbInfo.attributes.bean#.init(argumentCollection=attributes) />');
		fb_appendLine('<cfset myFusebox.trace("Reactor","Populated Bean") />');

	} else {
	}
</cfscript>
