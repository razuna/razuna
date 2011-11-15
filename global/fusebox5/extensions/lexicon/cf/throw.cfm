<cfscript>
	// Author: Barney Boisvert (bboisvert@gmail.com)
	// custom verb that compiles to a <cfthrow /> tag
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cf="cf/">
	// 2. use the verb in a fuseaction (all attributes optional):
	//    <cf:throw/>
	//    <cf:throw type="error type" message="custom error message" detail="more details" />
	if (fb_.verbInfo.executionMode is "start") {
		fb_.keys = listToArray("type,message,detail");
		fb_.result = '<cfthrow';
		for (fb_.i = 1; fb_.i LTE arrayLen(fb_.keys); fb_.i = fb_.i + 1) {
			if (structKeyExists(fb_.verbInfo.attributes, fb_.keys[fb_.i])) {
				fb_.result = fb_.result & ' #fb_.keys[fb_.i]#="#fb_.verbInfo.attributes[fb_.keys[fb_.i]]#"';
			}
		}
		fb_appendLine(fb_.result & ' />');
	}
</cfscript>