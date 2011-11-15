<cfscript>
	// example custom verb that compiles to a <cfcatch> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:try>
	//        ... other code ...
	//    <cf:catch type="any">
	//        ... exception handler ...
	//    </cf:catch>
	//    </cf:try>
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes)
	// b. in start mode, generate the required CFML
	// c. in end mode, generate the required CFML
	//
	if (fb_.verbInfo.executionMode is "start") {
		//
		// validate attributes:
		// parent tag must be a try verb in the same lexicon:
		if (not structKeyExists(fb_.verbInfo,"parent") or
				fb_.verbInfo.parent.lexicon is not fb_.verbInfo.lexicon or
				fb_.verbInfo.parent.lexiconVerb is not "try") {
			fb_throw("fusebox.badGrammar.invalidNesting",
						"Verb is invalid in this context",
						"The verb 'catch' does not appear directly nested within a 'try' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		//
		// type is optional:
		if (structKeyExists(fb_.verbInfo.attributes,"type")) {
			fb_.type = ' type="#fb_.verbInfo.attributes.type#"';
		} else {
			fb_.type = '';
		}
		//
		// start mode:
		fb_appendLine('<' & 'cfcatch#fb_.type#>');
	} else {
		//
		// end mode:
		fb_appendLine('<' & '/cfcatch>');
	}
</cfscript>
