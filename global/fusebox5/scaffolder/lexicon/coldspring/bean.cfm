<cfscript>
	// @ Author Qasim Rasheed (qasimrasheed@gmail.com) 
	// Original idea taken by COldSpring lexicon by Nathan Strutz.
	// used as a child tag with coldspring initialize tag
	//  usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cs="coldspring/">
	// 2 add bean tag as a child to initialize tag
	//    <cs:initialize  coldspringfactory="servicefactory" defaultproperties="default coldspring properties">
	//			<cs:bean beanDefinitionFile="..." />
	//			more bean tags......
	//    </cs:initialize>
	
	if (fb_.verbInfo.executionMode is "start") {
		// validates attributes
		// beanDefinitionFile is required
		if (not structKeyExists( fb_.verbInfo.attributes, "beanDefinitionFile" ) ) {
			fb_throw("fusebox.badGrammar.requiredAttributeMissing",
						"Required attribute is missing",
						"The attribute 'beanDefinitionFile' is required, for a 'bean' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
		
		// must be nested inside an <cf:initialize>
		if (not structKeyExists(fb_.verbInfo,"parent") or fb_.verbInfo.parent.lexiconVerb is not "initialize") {
			fb_throw("fusebox.badGrammar.parameterNeedsInclude",
						"Verb 'bean' has no parent 'initialize' verb",
						"Found 'bean' verb with no valid parent 'initialize' verb in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
		}
				
		// append this bean to the parent data:
		arrayAppend( fb_.verbInfo.parent.beans,fb_.verbInfo.attributes.beanDefinitionFile );
		
	} 
</cfscript>
