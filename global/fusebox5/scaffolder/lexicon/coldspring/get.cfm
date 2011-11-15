<cfscript>
	//// @ Author Qasim Rasheed (qasimrasheed@gmail.com) 
	//  Original idea taken by COldSpring lexicon by Nathan Strutz.
	// Gets an item from ColdSpring
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cs="coldspring/">
	// 2. use the verb in a fuseaction:
	//    <cs:get bean="GenericCollection" returnvariable="variables.myCollection"/>
	//    <cs:get bean="GenericCollection" returnvariable="variables.myCollection" coldspringfactory="servicefactory"/>
	//    <cs:get beanDefinition="GenericCollection" returnvariable="variables.myBeanDefinition" coldspringfactory="servicefactory"/>
	//
	if (fb_.verbInfo.executionMode is "start") {
		// construct returnvariable
		if (structKeyExists(fb_.verbInfo.attributes,"returnvariable")) {
			fb_.returnvariable = fb_.verbInfo.attributes.returnvariable & " = ";
		} else {
			fb_.returnvariable = "";
		}

		// coldspringfactory is optional:
		fb_.coldspringfactory = 'servicefactory';
        if (structKeyExists(fb_.verbInfo.attributes,"coldspringfactory")) {
            fb_.coldspringfactory = fb_.verbInfo.attributes.coldspringfactory;
        }
        //

		if (structKeyExists(fb_.verbInfo.attributes,"bean")) {
			fb_appendLine('<cfset #fb_.returnvariable#myFusebox.getApplication().getApplicationData().#fb_.coldspringfactory#.getBean(beanName="#fb_.verbInfo.attributes.bean#")/> ');
		} else if (structKeyExists(fb_.verbInfo.attributes,"beanDefinition")) {
			fb_appendLine('<cfset #fb_.returnvariable#myFusebox.getApplication().getApplicationData().#fb_.coldspringfactory#.getBeanDefinition(beanName="#fb_.verbInfo.attributes.bean#")/> ');
		} else {
			// bean or beanDefinition is required
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'bean' or 'beanDefinition' is required, for a 'get' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		//
	} else {
		//
		// end mode - do nothing
	}
</cfscript>