<cfscript>
	// example custom verb that compiles to a <cftry> tag
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
		// validate attributes - there are no attributes for try:
		//
		// start mode:
		fb_appendLine('<' & 'cftry>');
	} else {
		//
		// end mode:
		fb_appendLine('<' & '/cftry>');
	}
</cfscript>
