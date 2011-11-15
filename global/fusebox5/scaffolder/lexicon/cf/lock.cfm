<cfscript>
	// example custom verb that compiles to a <cflock> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:lock name="myNamedLock" timeout="10" type="exclusive">
	//        ... some locked code ...
	//    </cf:lock>
	//    <cf:lock scope="session" timeout="10" type="readonly">
	//        ... more locked code ...
	//    </cf:lock>
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes)
	// b. in start mode, generate the required CFML
	// c. in end mode, generate the required CFML
	//
	if (fb_.verbInfo.executionMode is "start") {
		//
		// validate attributes:
		// one of name or scope must be present:
		if (not structKeyExists(fb_.verbInfo.attributes,"name")) {
			if (not structKeyExists(fb_.verbInfo.attributes,"scope")) {
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"Either the attribute 'name' or 'scope' is required, for a 'lock' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				// scope is present:
				fb_.nameOrScope = 'scope="#fb_.verbInfo.attributes.scope#"';
			}
		} else {
			if (structKeyExists(fb_.verbInfo.attributes,"scope")) {
				// oops! both are present!
				fb_throw("fusebox.badGrammar.requiredAttributeMissing",
							"Required attribute is missing",
							"Either the attribute 'name' or 'scope' is required, for a 'lock' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
			} else {
				// name is present:
				fb_.nameOrScope = 'name="#fb_.verbInfo.attributes.name#"';
			}
		}
		//
		// throwontimeout is optional:
		if (structKeyExists(fb_.verbInfo.attributes,"throwontimeout")) {
			fb_.throwOnTimeout = ' throwontimeout="#fb_.verbInfo.attributes.throwontimeout#"';
		} else {
			fb_.throwOnTimeout = '';
		}
		//
		// timeout is required:
		if (not structKeyExists(fb_.verbInfo.attributes,"timeout")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'timeout' is required, for a 'lock' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
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
		fb_appendLine('<' & 'cflock #fb_.nameOrScope# timeout="#fb_.verbInfo.attributes.timeout#"#fb_.throwOnTimeout##fb_.type#>');
	} else {
		//
		// end mode:
		fb_appendLine('<' & '/cflock>');
	}
</cfscript>
