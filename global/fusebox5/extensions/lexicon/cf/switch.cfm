<cfscript>
	// example custom verb that compiles to a <cfswitch> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:switch expression="#someExpr#">
	//    <cf:case value="someValue">
	//        ... some code ...
	//    </cf:case>
	//    <cf:case value="anotherValue|andAnother" delimiters="|">
	//        ... more code ...
	//    </cf:case>
	//    <cf:defaultcase>
	//        ... default code ...
	//    </cf:defaultcase>
	//    </cf:switch>
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes)
	// b. in start mode, generate the required CFML
	// c. in end mode, generate the required CFML
	//
	if (fb_.verbInfo.executionMode is "start") {
		//
		// validate attributes:
		// expression is required:
		if (not structKeyExists(fb_.verbInfo.attributes,"expression")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'expression' is required, for a 'switch' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		//
		// start mode:
		fb_appendLine('<' & 'cfswitch expression="#fb_.verbInfo.attributes.expression#">');
	} else {
		//
		// end mode:
		fb_appendLine('<' & '/cfswitch>');
	}
</cfscript>
