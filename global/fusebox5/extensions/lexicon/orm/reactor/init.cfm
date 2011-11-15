<cfscript>
	// usage:
	//		<reactor:init
	//				configuration="/config/reactor.xml" />
	if (fb_.verbInfo.executionMode is "start") {
		// validate attributes
		// configuration - string (path)
		if (not structKeyExists(fb_.verbInfo.attributes,"configuration")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'configuration' is required, for a 'init' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// generate code:
		fb_appendLine('<cfset myFusebox.getApplication().getApplicationData().reactorFactory = ' &
				'createObject("component","reactor.reactorFactory")' &
					'.init(expandPath("#fb_.verbInfo.attributes.configuration#")) />');
		fb_appendLine('<cfset myFusebox.trace("Reactor","Created ReactorFactory") />');
	} else {
	}
</cfscript>
