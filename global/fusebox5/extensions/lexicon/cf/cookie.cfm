<cfscript>
	// Author: Nathan Strutz (strutz@gmail.com)
	// example custom verb that compiles to a <cfcookie> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:cookie name="" value="" expires=""/>
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes)
	// b. in start mode, generate the required CFML
	// c. in end mode, do nothing (this tag does not nest)
	//
	if (fb_.verbInfo.executionMode is "start") {
		//
		// name is required:
		if (not structKeyExists(fb_.verbInfo.attributes,"name")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'name' is required, for a 'cookie' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		//
		// value is required:
		if (not structKeyExists(fb_.verbInfo.attributes,"value")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'value' is required, for a 'cookie' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		//
		// expires is required:
		if (not structKeyExists(fb_.verbInfo.attributes,"expires")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'expires' is required, for a 'cookie' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		//
		// start mode:
		fb_appendLine('<cfcookie name="#fb_.verbInfo.attributes.name#" value="#fb_.verbInfo.attributes.value#" expires="#fb_.verbInfo.attributes.expires#"/>');
	} else {
		//
		// end mode - do nothing
	}
</cfscript>