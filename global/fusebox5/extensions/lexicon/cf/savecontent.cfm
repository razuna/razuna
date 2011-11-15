<cfscript>
	// example custom verb that compiles to a <cfsavecontent> tag
	//
	// author: Barney Boisvert
	//
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:savecontent variable="bodyContent">
	//        ... other code ...
	//    </cf:cfsavecontent>
	if (fb_.verbInfo.executionMode is "start") {
		if (structKeyExists(fb_.verbInfo.attributes,"variable")) {
			fb_.variable = fb_.verbInfo.attributes.variable;
		} else if (structKeyExists(fb_.verbInfo.attributes,"var")) {
			fb_.variable = fb_.verbInfo.attributes.var;
		} else {
			fb_throw(
				"fusebox.badGrammar.requiredAttributeMissing",
				"Required attribute is missing",
				"The attribute 'variable' (or the 'var' shorthand) is required, for a 'savecontent' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#."
			);
		}
		fb_appendLine('<' & 'cfsavecontent variable="#fb_.variable#">');
	} else {
		fb_appendLine('<' & '/cfsavecontent>');
	}
</cfscript>