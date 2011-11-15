<cfscript>
	// example custom verb that compiles to a <cfdump> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:dump var="#somevariable#" />
	//    <cf:dump label="some label" var="#somevariable#" />
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes)
	// b. in start mode, generate the required CFML
	// c. in end mode, do nothing (this tag does not nest)
	//
	if (fb_.verbInfo.executionMode is "start") {
		//
		// validate attributes:
		// var is required:
		if (not structKeyExists(fb_.verbInfo.attributes,"var")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'var' is required, for a 'dump' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// label is optional, create the text to generate - note the quoting technique:
		if (structKeyExists(fb_.verbInfo.attributes,"label")) {
			fb_.label = 'label="#fb_.verbInfo.attributes.label#"';
		} else {
			fb_.label = '';
		}
		//
		// start mode:
		fb_appendLine('<cfdump #fb_.label# var="#fb_.verbInfo.attributes.var#">');
	} else {
		//
		// end mode - do nothing
	}
</cfscript>
