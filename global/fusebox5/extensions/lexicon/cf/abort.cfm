<cfscript>
	// Author: Nathan Strutz (strutz@gmail.com)
	// example custom verb that compiles to a <cfabort> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction:
	//    <cf:abort/>
	//    <cf:abort showerror="custom error message"/>
	//
	// how this works:
	// a. validate the attributes passed in (fb_.verbInfo.attributes)
	// b. in start mode, generate the required CFML
	// c. in end mode, do nothing (this tag does not nest)
	//
	if (fb_.verbInfo.executionMode is "start") {
		//
		// showerror is optional, create the text to generate:
		if (structKeyExists(fb_.verbInfo.attributes,"showerror")) {
			fb_.showerror = ' showerror="#fb_.verbInfo.attributes.showerror#"';
		} else {
			fb_.showerror = '';
		}
		//
		// start mode:
		fb_appendLine('<cfabort#fb_.showerror#>');
	} else {
		//
		// end mode - do nothing
	}
</cfscript>