<cfscript>
	// @ Author Nathan Strutz
	// Creates a iterator of a given type from Reactor
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:reactor="reactor/">
	// 2. use the verb in a fuseaction:
	//    <reactor:iterator alias="User" returnvariable="variables.userIterator" />
	//
	if (fb_.verbInfo.executionMode is "start") {

		// alias is required
		if (not structKeyExists(fb_.verbInfo.attributes,"alias")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'alias' is required, for a 'iterator' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		// returnvariable is required
		if (not structKeyExists(fb_.verbInfo.attributes,"returnvariable")) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'returnvariable' is required, for a 'iterator' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}

		fb_appendLine('<cfset #fb_.verbInfo.attributes.returnvariable# = myFusebox.getApplication().getApplicationData().reactor.createIterator("#fb_.verbInfo.attributes.alias#") />');

		//
	} else {
		//
		// end mode - do nothing
	}
</cfscript>